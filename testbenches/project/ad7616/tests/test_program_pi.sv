// ***************************************************************************
// ***************************************************************************
// Copyright (C) 2022 Analog Devices, Inc. All rights reserved.
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
//
//

`include "utils.svh"
`include "axi_definitions.svh"

import axi_vip_pkg::*;
import axi4stream_vip_pkg::*;
import adi_regmap_pkg::*;
import adi_regmap_adc_pkg::*;
import adi_regmap_clkgen_pkg::*;
import adi_regmap_common_pkg::*;
import adi_regmap_dmac_pkg::*;
import adi_regmap_pwm_gen_pkg::*;
import logger_pkg::*;
import test_harness_env_pkg::*;

import `PKGIFY(test_harness, mng_axi_vip)::*;
import `PKGIFY(test_harness, ddr_axi_vip)::*;

localparam AD7616_CTRL_CNVST_EN       = 2;
localparam NUM_OF_TRANSFERS           = 16;

program test_program_pi (
  output [15:0] rx_db_i,
  input         rx_db_t,
  input         rx_rd_n,
  input         rx_wr_n,
  output        rx_cs_n,
  input  [15:0] rx_db_o,
  input         sys_clk,
  input         rx_busy);

  timeunit 1ns;
  timeprecision 1ps;

test_harness_env #(`AXI_VIP_PARAMS(test_harness, mng_axi_vip), `AXI_VIP_PARAMS(test_harness, ddr_axi_vip)) base_env;

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

  setLoggerVerbosity(ADI_VERBOSITY_NONE);

  base_env.start();
  base_env.sys_reset();

  sanity_test();

  #100ns;

  data_acquisition_test();

  base_env.stop();

  `INFO(("Test Done"), ADI_VERBOSITY_NONE);
  $finish();

end

wire        rx_rd_n_negedge_s;
wire        rx_rd_n_posedge_s;
reg         rx_rd_n_d;
reg         rx_rd_n_tmp;
reg [15:0]  tx_data_buf = 16'h0101;
bit [31:0]  dma_data_store_arr [(NUM_OF_TRANSFERS) - 1:0];
bit [31:0] transfer_cnt;
bit transfer_status = 0;

assign rx_db_i = tx_data_buf;

initial begin
  forever begin
    @(posedge sys_clk);
    rx_rd_n_tmp <= rx_rd_n;
    fork
      rx_rd_n_d <= rx_rd_n_tmp;
    join_none
  end
end

assign rx_rd_n_negedge_s = ~rx_rd_n & rx_rd_n_d;
assign rx_rd_n_posedge_s = rx_rd_n & ~rx_rd_n_d;

initial begin
  forever begin
    @(negedge rx_rd_n);
      if (transfer_status)
        if (transfer_cnt[0]) begin
          dma_data_store_arr [(transfer_cnt - 1)  >> 1] [15:0] = tx_data_buf - 16'h0001;
        end else begin
          dma_data_store_arr [(transfer_cnt - 1) >> 1] [31:16] = tx_data_buf - 16'h0001;
        end
        tx_data_buf <= tx_data_buf + 16'h0001;
      @(posedge rx_rd_n);
  end
end


//---------------------------------------------------------------------------
// Sanity test reg interface
//---------------------------------------------------------------------------

task sanity_test();
    axi_write (`AXI_AD7616_BA + GetAddrs(COMMON_REG_SCRATCH), `SET_COMMON_REG_SCRATCH_SCRATCH(32'hDEADBEEF));
    axi_read_v (`AXI_AD7616_BA + GetAddrs(COMMON_REG_SCRATCH), `SET_COMMON_REG_SCRATCH_SCRATCH(32'hDEADBEEF));
    `INFO(("Sanity Test Done"), ADI_VERBOSITY_LOW);
endtask

//---------------------------------------------------------------------------
// Transfer Counter
//---------------------------------------------------------------------------

initial begin
  forever begin
    @(posedge rx_rd_n);
    if (transfer_status)
        transfer_cnt <= transfer_cnt + 'h1;
        @(negedge rx_rd_n);
    end
end

//---------------------------------------------------------------------------
// Data Acquisition Test
//---------------------------------------------------------------------------

reg [31:0] rdata_reg;
bit [31:0] captured_word_arr [(NUM_OF_TRANSFERS) -1 :0];
bit [31:0] config_wr_SIMPLE = 'h0; // write request sent result
bit [31:0] config_SIMPLE = 'h0; // channel static data setup

task data_acquisition_test();

    // Enable all ADC channels
    for (int i = 0; i < 16; i=i+1) begin
        axi_write (`AXI_AD7616_BA + i*'h40 + GetAddrs(ADC_CHANNEL_REG_CHAN_CNTRL), `SET_ADC_CHANNEL_REG_CHAN_CNTRL_ENABLE(32'h00000001));
    end

    // Configure pwm gen
    axi_write (`AD7616_PWM_GEN_BA + GetAddrs(AXI_PWM_GEN_REG_RSTN), `SET_AXI_PWM_GEN_REG_RSTN_RESET(1)); // PWM_GEN reset in regmap (ACTIVE HIGH)
    axi_write (`AD7616_PWM_GEN_BA + GetAddrs(AXI_PWM_GEN_REG_PULSE_X_PERIOD), `SET_AXI_PWM_GEN_REG_PULSE_X_PERIOD_PULSE_X_PERIOD('h64)); // set PWM period
    axi_write (`AD7616_PWM_GEN_BA + GetAddrs(AXI_PWM_GEN_REG_RSTN), `SET_AXI_PWM_GEN_REG_RSTN_LOAD_CONFIG(1)); // load AXI_PWM_GEN configuration
    `INFO(("Axi_pwm_gen started"), ADI_VERBOSITY_LOW);

     // Configure DMA
    base_env.mng.sequencer.RegWrite32(`AD7616_DMA_BA + GetAddrs(DMAC_CONTROL), `SET_DMAC_CONTROL_ENABLE(1)); // Enable DMA
    base_env.mng.sequencer.RegWrite32(`AD7616_DMA_BA + GetAddrs(DMAC_FLAGS),
      `SET_DMAC_FLAGS_TLAST(1) |
      `SET_DMAC_FLAGS_PARTIAL_REPORTING_EN(1)
      ); // Use TLAST
    base_env.mng.sequencer.RegWrite32(`AD7616_DMA_BA + GetAddrs(DMAC_X_LENGTH), `SET_DMAC_X_LENGTH_X_LENGTH((NUM_OF_TRANSFERS*4)-1)); // X_LENGHTH = 1024-1
    base_env.mng.sequencer.RegWrite32(`AD7616_DMA_BA + GetAddrs(DMAC_DEST_ADDRESS), `SET_DMAC_DEST_ADDRESS_DEST_ADDRESS(`DDR_BA));  // DEST_ADDRESS

     // Configure AXI_AD7616
    axi_write (`AXI_AD7616_BA + GetAddrs(ADC_COMMON_REG_RSTN), `SET_ADC_COMMON_REG_RSTN_RSTN(0));
    #5000ns;
    axi_write (`AXI_AD7616_BA + GetAddrs(ADC_COMMON_REG_RSTN), `SET_ADC_COMMON_REG_RSTN_RSTN(1));

    @(negedge rx_busy)
    #200ns;

    transfer_status = 1;

    base_env.mng.sequencer.RegWrite32(`AD7616_DMA_BA + GetAddrs(DMAC_TRANSFER_SUBMIT), `SET_DMAC_TRANSFER_SUBMIT_TRANSFER_SUBMIT(1)); // Submit transfer DMA

    wait(transfer_cnt == 2 * NUM_OF_TRANSFERS );

    #100ns;
    @(negedge rx_rd_n_negedge_s);
    @(posedge sys_clk);
    transfer_status = 0;

    // Stop pwm gen
    axi_write (`AD7616_PWM_GEN_BA + GetAddrs(AXI_PWM_GEN_REG_RSTN), `SET_AXI_PWM_GEN_REG_RSTN_RESET(1));
    `INFO(("Axi_pwm_gen stopped"), ADI_VERBOSITY_LOW);

    // Configure axi_ad7616
    axi_write(`AXI_AD7616_BA + GetAddrs(ADC_COMMON_REG_RSTN), `SET_ADC_COMMON_REG_RSTN_RSTN(1'b1)); //ADC common core out of reset
    axi_write(`AXI_AD7616_BA + GetAddrs(ADC_COMMON_REG_ADC_CONFIG_WR), `SET_ADC_COMMON_REG_ADC_CONFIG_WR_ADC_CONFIG_WR(32'h00002181)); // set static data setup in device's reg 0x21
    axi_read(`AXI_AD7616_BA + GetAddrs(ADC_COMMON_REG_ADC_CONFIG_WR), config_SIMPLE); // read last config result
    `INFO(("Config_SIMPLE is set up, ADC_CONFIG_WR contains 0x%h",config_SIMPLE), ADI_VERBOSITY_LOW);
    axi_write(`AXI_AD7616_BA + GetAddrs(ADC_COMMON_REG_ADC_CONFIG_CTRL), `SET_ADC_COMMON_REG_ADC_CONFIG_CTRL_ADC_CONFIG_CTRL(32'h00000001)); // send WR request
    axi_read(`AXI_AD7616_BA + GetAddrs(ADC_COMMON_REG_ADC_CONFIG_CTRL), config_wr_SIMPLE); // read last config result
    `INFO(("Write request sent, ADC_CONFIG_CTRL contains 0x%h",config_wr_SIMPLE), ADI_VERBOSITY_LOW);

    `INFO(("Data on DB_O port: 0x%h",rx_db_o), ADI_VERBOSITY_LOW); // read written data

    axi_write(`AXI_AD7616_BA + GetAddrs(ADC_COMMON_REG_ADC_CONFIG_CTRL), `SET_ADC_COMMON_REG_ADC_CONFIG_CTRL_ADC_CONFIG_CTRL(32'h00000000)); // set default control value (no rd/wr request)
    axi_read(`AXI_AD7616_BA + GetAddrs(ADC_COMMON_REG_ADC_CONFIG_CTRL), config_wr_SIMPLE); // read last config result
    `INFO(("ADC_CONFIG_CTRL contains 0x%h",config_wr_SIMPLE), ADI_VERBOSITY_LOW);

    axi_write(`AXI_AD7616_BA + GetAddrs(ADC_COMMON_REG_ADC_CONFIG_WR), `SET_ADC_COMMON_REG_ADC_CONFIG_WR_ADC_CONFIG_WR(32'h00000000)); // set exit from register mode sequence
    axi_write(`AXI_AD7616_BA + GetAddrs(ADC_COMMON_REG_ADC_CONFIG_CTRL), `SET_ADC_COMMON_REG_ADC_CONFIG_CTRL_ADC_CONFIG_CTRL(32'h00000001)); // send WR request
    axi_write(`AXI_AD7616_BA + GetAddrs(ADC_COMMON_REG_ADC_CONFIG_CTRL), `SET_ADC_COMMON_REG_ADC_CONFIG_CTRL_ADC_CONFIG_CTRL(32'h00000000)); // set default control value (no rd/wr request)

    //set HDL config mode
    axi_write(`AXI_AD7616_BA + GetAddrs(ADC_COMMON_REG_CNTRL_3), 'h100); // set default

    #2000ns;

    for (int i=0; i<=((NUM_OF_TRANSFERS) -1); i=i+1) begin
      captured_word_arr[i] = base_env.ddr.agent.mem_model.backdoor_memory_read_4byte(xil_axi_uint'(`DDR_BA + 4*i));
    end

    `INFO(("captured_word_arr: %x; dma_data_store_arr %x", captured_word_arr, dma_data_store_arr), ADI_VERBOSITY_LOW);

    if (captured_word_arr != dma_data_store_arr) begin
      `ERROR(("Data Acquisition Test FAILED"));
    end else begin
      `INFO(("Data Acquisition Test PASSED"), ADI_VERBOSITY_LOW);
    end
endtask

endprogram
