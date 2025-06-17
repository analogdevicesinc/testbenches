// ***************************************************************************
// ***************************************************************************
// Copyright (C) 2024 Analog Devices, Inc. All rights reserved.
//
// In this HDL repository, there are many different and unique modules, consisting
// of various HDL (Verilog or VHDL) components. The individual modules are
// developed independently, and may be accompanied by separate and unique license
// terms.
//
// The user should read each of these license terms, and understand the
// freedoms and responsibilities that he or she has by using this source/core.
//
// This core is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
// A PARTICULAR PURPOSE.
//
// Redistribution and use of source or resulting binaries, with or without modification
// of this file, are permitted under one of the following two license terms:
//
//   1. The GNU General Public License version 2 as published by the
//      Free Software Foundation, which can be found in the top level directory
//      of this repository (LICENSE_GPL2), and also online at:
//      <https://www.gnu.org/licenses/old-licenses/gpl-2.0.html>
//
// OR
//
//   2. An ADI specific BSD license, which can be found in the top level directory
//      of this repository (LICENSE_ADIBSD), and also on-line at:
//      https://github.com/analogdevicesinc/hdl/blob/main/LICENSE_ADIBSD
//      This will allow to generate bit files and not release the source code,
//      as long as it attaches to an ADI device.
//
// ***************************************************************************
// ***************************************************************************

`include "utils.svh"

import logger_pkg::*;
import test_harness_env_pkg::*;
import adi_regmap_pkg::*;
import adi_regmap_adc_pkg::*;
import adi_regmap_common_pkg::*;
import adi_regmap_dmac_pkg::*;
import adi_regmap_pwm_gen_pkg::*;
import axi_vip_pkg::*;
import axi4stream_vip_pkg::*;
import cn0577_environment_pkg::*;

import `PKGIFY(test_harness, mng_axi_vip)::*;
import `PKGIFY(test_harness, ddr_axi_vip)::*;

localparam NUM_OF_TRANSFERS = 16;
localparam RESOLUTION = (`RESOLUTION_16_18N == 1) ? 16 : 18;

//---------------------------------------------------------------------------
// SPI Engine configuration parameters
//---------------------------------------------------------------------------

program test_program (
  input           ref_clk,
  input           dco_p,
  input           dco_n,
  output          da_n,
  output          da_p,
  output          db_n,
  output          db_p,
  output          cnv);

timeunit 1ns;
timeprecision 100ps;

typedef enum {DATA_MODE_RANDOM, DATA_MODE_RAMP, DATA_MODE_PATTERN} offload_test_t;

test_harness_env #(`AXI_VIP_PARAMS(test_harness, mng_axi_vip), `AXI_VIP_PARAMS(test_harness, ddr_axi_vip)) base_env;

// set to active debug messages
localparam bit DEBUG = 1;

// dco delay compared to the reference clk
localparam DCO_DELAY = 0.7;

// dma interface
wire                    adc_valid;
wire  [RESOLUTION-1:0]  adc_data;
reg                     adc_dovf = 1'b0;

// --------------------------
// Wrapper function for AXI read verif
// --------------------------
task axi_read_v(
    input   [31:0]  raddr,
    input   [31:0]  vdata);

  base_env.mng.sequencer.RegReadVerify32(raddr,vdata);
endtask

task axi_read(
    input   [31:0]  raddr,
    output  [31:0]  data);

  base_env.mng.sequencer.RegRead32(raddr,data);
endtask

// --------------------------
// Wrapper function for AXI write
// --------------------------
task axi_write(
  input [31:0]  waddr,
  input [31:0]  wdata);

  base_env.mng.sequencer.RegWrite32(waddr,wdata);
endtask

// --------------------------
// Main procedure
// --------------------------

initial begin

  //creating environment
  base_env = new("Base Environment",
                  `TH.`SYS_CLK.inst.IF,
                  `TH.`DMA_CLK.inst.IF,
                  `TH.`DDR_CLK.inst.IF,
                  `TH.`SYS_RST.inst.IF,
                  `TH.`MNG_AXI.inst.IF,
                  `TH.`DDR_AXI.inst.IF);

  setLoggerVerbosity(ADI_VERBOSITY_HIGH);

  base_env.start();
  base_env.sys_reset();

  sanity_test();

  #100

  data_acquisition_test();

  base_env.stop();

  `INFO(("Test Done"), ADI_VERBOSITY_NONE);
  $finish();

end


bit [31:0]  dma_data_store_arr [(NUM_OF_TRANSFERS) - 1:0];
bit transfer_status = 0;
bit [31:0] transfer_cnt;

//---------------------------------------------------------------------------
// Transfer Counter
//---------------------------------------------------------------------------

initial begin
  transfer_cnt = 0;
  forever begin
    @(posedge cnv);
     if (transfer_status) begin
      transfer_cnt = transfer_cnt + 1;
    end
    @(negedge cnv);
  end
end

//---------------------------------------------------------------------------
// Data store
//---------------------------------------------------------------------------

reg   [RESOLUTION-1:0]  data_gen = 'h3a5a5;
reg   [RESOLUTION-1:0]  data_shift = 'h0;
reg                     r_da_p = 1'b0;
reg                     r_da_n = 1'b0;
reg                     r_db_p = 1'b0;
reg                     r_db_n = 1'b0;

 
assign da_p = r_da_p;
assign da_n = r_da_n;
assign db_p = r_db_p;
assign db_n = r_db_n;

// ---------------------------------------------------------------------------
// Output data ready
// ---------------------------------------------------------------------------
  
initial begin
  forever begin
    @ (negedge dco_p) begin
      if (`TWOLANES == 1) begin
        r_da_p = data_shift[RESOLUTION - 1];
        r_da_n = ~data_shift[RESOLUTION - 1];
        r_db_p = data_shift[RESOLUTION - 2];
        r_db_n = ~data_shift[RESOLUTION - 2];
        data_shift = data_shift << 2;
      end else begin
        r_da_p = data_shift[RESOLUTION - 1];
        r_da_n = ~data_shift[RESOLUTION - 1];
        data_shift = data_shift << 1;
      end
    end
  end
end  

initial begin
  forever begin    
    @ (posedge cnv) begin
      // at the first entrance in this always, da and db will have the bits from
      // the first sample of data (which data was initialized with - 3a5a5)
      // and only afterwards to increment data; otherwise the first sample is lost
      if (`TWOLANES == 1) begin
        r_da_p = data_gen[RESOLUTION - 1];
        r_da_n = ~data_gen[RESOLUTION - 1];
        r_db_p = data_gen[RESOLUTION - 2];
        r_db_n = ~data_gen[RESOLUTION - 2];
        data_shift = data_gen << 2;
      end else begin
        r_da_p = data_gen[RESOLUTION - 1];
        r_da_n = ~data_gen[RESOLUTION - 1];
        data_shift = data_gen << 1;
      end
      //#tCONV data <= data + 1;
      data_gen <= data_gen + 16'h0001;
    end  
  end
end

// ---------------------------------------------------------------------------
// Generating expected data
// ---------------------------------------------------------------------------

//initial begin
//  forever begin
//    @ (posedge cnv_out) begin
//      cnv_count++;
//      // at the first entrance in this always, da and db will have the bits from
//      // the first sample of data (which data was initialized with - 3a5a5)
//      // and only afterwards to increment data; otherwise the first sample is lost
//      if (`TWOLANES == 1) begin
//        r_da_p = data[RESOLUTION - 1];
//        r_da_n = ~data[RESOLUTION - 1];
//        r_db_p = data[RESOLUTION - 2];
//        r_db_n = ~data[RESOLUTION - 2];
//        data_shift = data << 2;
//      end else begin
//        r_da_p = data[RESOLUTION - 1];
//        r_da_n = ~data[RESOLUTION - 1];
//        data_shift = data << 1;
//      end
//      //#tCONV data <= data + 1;
//      data <= data + 16'h0001;
//    end
//  end
// end
  
initial begin
  forever begin
    @(negedge dco_n);
      if (transfer_status)
        if (transfer_cnt[0]) begin
          dma_data_store_arr [(transfer_cnt - 1)  >> 1] [15:0] = data_gen - 16'h0001;
        end else begin
          dma_data_store_arr [(transfer_cnt - 1) >> 1] [31:16] = data_gen - 16'h0001;
        end
        //data_gen <= data_gen + 16'h0001;
      @(posedge dco_n);
  end
end

//---------------------------------------------------------------------------
// Sanity test reg interface
//---------------------------------------------------------------------------

task sanity_test();
    axi_write (`AXI_LTC2387_BA + GetAddrs(COMMON_REG_SCRATCH), `SET_COMMON_REG_SCRATCH_SCRATCH(32'hDEADBEEF));
    axi_read_v (`AXI_LTC2387_BA + GetAddrs(COMMON_REG_SCRATCH), `SET_COMMON_REG_SCRATCH_SCRATCH(32'hDEADBEEF));
    `INFO(("Sanity Test Done"), ADI_VERBOSITY_LOW);
endtask

//---------------------------------------------------------------------------
// Data Acquisition Test
//---------------------------------------------------------------------------

reg [31:0] rdata_reg;
bit [31:0] captured_word_arr [(NUM_OF_TRANSFERS) -1 :0];
bit [31:0] config_wr_SIMPLE = 'h0; // write request sent result
bit [31:0] config_SIMPLE = 'h0; // channel static data setup

task data_acquisition_test();

    // Enable all ADC channels
    for (int i = 0; i < 4; i=i+1) begin
        axi_write (`AXI_LTC2387_BA + i*'h40 + GetAddrs(ADC_CHANNEL_REG_CHAN_CNTRL), `SET_ADC_CHANNEL_REG_CHAN_CNTRL_ENABLE(32'h00000001));
    end

    // Configure AXI PWM GEN
    axi_write (`AXI_PWM_GEN_BA + GetAddrs(AXI_PWM_GEN_REG_RSTN), `SET_AXI_PWM_GEN_REG_RSTN_RESET(1)); // PWM_GEN reset in regmap (ACTIVE HIGH)
    axi_write (`AXI_PWM_GEN_BA + GetAddrs(AXI_PWM_GEN_REG_PULSE_X_PERIOD), `SET_AXI_PWM_GEN_REG_PULSE_X_PERIOD_PULSE_X_PERIOD('h8)); // set PWM period
    axi_write (`AXI_PWM_GEN_BA + GetAddrs(AXI_PWM_GEN_REG_RSTN), `SET_AXI_PWM_GEN_REG_RSTN_LOAD_CONFIG(1)); // load AXI_PWM_GEN configuration
    `INFO(("AXI_PWM_GEN started"), ADI_VERBOSITY_LOW);

    // Configure DMA
    base_env.mng.sequencer.RegWrite32(`AXI_LTC2387_DMA_BA + GetAddrs(DMAC_CONTROL), `SET_DMAC_CONTROL_ENABLE(1)); // Enable DMA
    base_env.mng.sequencer.RegWrite32(`AXI_LTC2387_DMA_BA + GetAddrs(DMAC_FLAGS),
      `SET_DMAC_FLAGS_TLAST(1) |
      `SET_DMAC_FLAGS_PARTIAL_REPORTING_EN(1)
      ); // Use TLAST
    base_env.mng.sequencer.RegWrite32(`AXI_LTC2387_DMA_BA + GetAddrs(DMAC_X_LENGTH), `SET_DMAC_X_LENGTH_X_LENGTH((NUM_OF_TRANSFERS*4)-1)); // X_LENGHTH = 1024-1
    base_env.mng.sequencer.RegWrite32(`AXI_LTC2387_DMA_BA + GetAddrs(DMAC_DEST_ADDRESS), `SET_DMAC_DEST_ADDRESS_DEST_ADDRESS(`DDR_BA));  // DEST_ADDRESS

    // Configure AXI_LTC2387
    axi_write (`AXI_LTC2387_BA + GetAddrs(ADC_COMMON_REG_RSTN), `SET_ADC_COMMON_REG_RSTN_RSTN(0));
    #5000
    axi_write (`AXI_LTC2387_BA + GetAddrs(ADC_COMMON_REG_RSTN), `SET_ADC_COMMON_REG_RSTN_RSTN(1));


    @(posedge cnv) // TBD
    #200

    transfer_status = 1;

    base_env.mng.sequencer.RegWrite32(`AXI_LTC2387_DMA_BA + GetAddrs(DMAC_TRANSFER_SUBMIT), `SET_DMAC_TRANSFER_SUBMIT_TRANSFER_SUBMIT(1)); // Submit transfer DMA

    wait(transfer_cnt == 2 * NUM_OF_TRANSFERS );

    #100
    @(negedge cnv); //TBD
    @(posedge ref_clk); //TBD
    transfer_status = 0;

    // Stop pwm gen
    axi_write (`AXI_PWM_GEN_BA + GetAddrs(AXI_PWM_GEN_REG_RSTN), `SET_AXI_PWM_GEN_REG_RSTN_RESET(1));
    `INFO(("AXI_PWM_GEN stopped"), ADI_VERBOSITY_LOW);

    // Configure axi_ltc2387
    axi_write(`AXI_LTC2387_BA + GetAddrs(ADC_COMMON_REG_RSTN), `SET_ADC_COMMON_REG_RSTN_RSTN(1'b1)); //ADC common core out of reset
    axi_write(`AXI_LTC2387_BA + GetAddrs(ADC_COMMON_REG_ADC_CONFIG_WR), `SET_ADC_COMMON_REG_ADC_CONFIG_WR_ADC_CONFIG_WR(32'h00002181)); // set static data setup in device's reg 0x21
    axi_read(`AXI_LTC2387_BA + GetAddrs(ADC_COMMON_REG_ADC_CONFIG_WR), config_SIMPLE); // read last config result
    `INFO(("Config_SIMPLE is set up, ADC_CONFIG_WR contains 0x%h",config_SIMPLE), ADI_VERBOSITY_LOW);
    axi_write(`AXI_LTC2387_BA + GetAddrs(ADC_COMMON_REG_ADC_CONFIG_CTRL), `SET_ADC_COMMON_REG_ADC_CONFIG_CTRL_ADC_CONFIG_CTRL(32'h00000001)); // send WR request
    axi_read(`AXI_LTC2387_BA + GetAddrs(ADC_COMMON_REG_ADC_CONFIG_CTRL), config_wr_SIMPLE); // read last config result
    `INFO(("Write request sent, ADC_CONFIG_CTRL contains 0x%h",config_wr_SIMPLE), ADI_VERBOSITY_LOW);

    axi_write(`AXI_LTC2387_BA + GetAddrs(ADC_COMMON_REG_ADC_CONFIG_CTRL), `SET_ADC_COMMON_REG_ADC_CONFIG_CTRL_ADC_CONFIG_CTRL(32'h00000000)); // set default control value (no rd/wr request)
    axi_read(`AXI_LTC2387_BA + GetAddrs(ADC_COMMON_REG_ADC_CONFIG_CTRL), config_wr_SIMPLE); // read last config result
    `INFO(("ADC_CONFIG_CTRL contains 0x%h",config_wr_SIMPLE), ADI_VERBOSITY_LOW);

    axi_write(`AXI_LTC2387_BA + GetAddrs(ADC_COMMON_REG_ADC_CONFIG_WR), `SET_ADC_COMMON_REG_ADC_CONFIG_WR_ADC_CONFIG_WR(32'h00000000)); // set exit from register mode sequence
    axi_write(`AXI_LTC2387_BA + GetAddrs(ADC_COMMON_REG_ADC_CONFIG_CTRL), `SET_ADC_COMMON_REG_ADC_CONFIG_CTRL_ADC_CONFIG_CTRL(32'h00000001)); // send WR request
    axi_write(`AXI_LTC2387_BA + GetAddrs(ADC_COMMON_REG_ADC_CONFIG_CTRL), `SET_ADC_COMMON_REG_ADC_CONFIG_CTRL_ADC_CONFIG_CTRL(32'h00000000)); // set default control value (no rd/wr request)

    //set HDL config mode
    axi_write(`AXI_LTC2387_BA + GetAddrs(ADC_COMMON_REG_CNTRL_3), 'h100); // set default

    #2000
    for (int i=0; i<=((NUM_OF_TRANSFERS) -1); i=i+1) begin
      #1
      captured_word_arr[i] = base_env.ddr.agent.mem_model.backdoor_memory_read_4byte(xil_axi_uint'(`DDR_BA + 4*i));
    end

    `INFO(("captured_word_arr: %x; dma_data_store_arr %x", captured_word_arr, dma_data_store_arr), ADI_VERBOSITY_HIGH);
     //`INFO(("captured_word_arr: %x; dma_data_store_arr %x", captured_word_arr, dma_data_store_arr), ADI_VERBOSITY_LOW);

    if (captured_word_arr != dma_data_store_arr) begin
      `ERROR(("Data Acquisition Test FAILED"));
    end else begin
      `INFO(("Data Acquisition Test PASSED"), ADI_VERBOSITY_LOW);
    end

endtask

endprogram
