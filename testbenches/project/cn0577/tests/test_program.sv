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
  input           ref_clk_p,
  input           ref_clk_n,
  output          clk_p,
  output          clk_n,
  input           dco_p,
  input           dco_n,
  input           da_n,
  input           da_p,
  input           db_n,
  input           db_p,
  output          cnv_p,
  output          cnv_n,
  output          cnv_en,
  output          pd_cntrl,
  output          testpat_cntrl,
  output          twolanes_cntrl);

timeunit 1ns;
timeprecision 100ps;

typedef enum {DATA_MODE_RANDOM, DATA_MODE_RAMP, DATA_MODE_PATTERN} offload_test_t;

test_harness_env #(`AXI_VIP_PARAMS(test_harness, mng_axi_vip), `AXI_VIP_PARAMS(test_harness, ddr_axi_vip)) base_env;

// set to active debug messages
localparam bit DEBUG = 1;

// dco delay compared to the reference clk
localparam DCO_DELAY = 0.7;

// reg signals
reg                     ref_clk = 1'b0;
reg                     ref_clk_out = 1'b0;
reg                     cnv_out = 1'b0;
reg                     clk_gate = 1'b0;
reg                     dco_p = 1'b0;
reg                     dco_n = 1'b0;
reg                     da_p = 1'b0;
reg                     da_n = 1'b0;
reg                     db_p = 1'b0;
reg                     db_n = 1'b0;

// dma interface
wire                    adc_valid;
wire  [RESOLUTION-1:0]  adc_data;
reg                     adc_dovf = 1'b0;

// local wires and registers
reg   clk_gate_d = 1'b0;
reg   [RESOLUTION-1:0]  data = 'h3a5a5;
reg   [RESOLUTION-1:0]  data_int = 'h0;
reg   [9:0]  cnv_counter = 9'hd;
reg   gate_start = 1'b0;

integer clk_gate_counter = 0;
integer clk_gate_high = (RESOLUTION == 16) ?
                          (`TWOLANES == 0) ? 8 : 4 :
                        (RESOLUTION == 18) ?
                           (`TWOLANES == 0) ? 9 : 5 :
                         5;

integer clk_gate_low = (RESOLUTION == 16) ?
                          (`TWOLANES == 0) ? 5 : 9 :
                       (RESOLUTION == 18) ?
                          (`TWOLANES == 0) ? 4 : 8 :
                        8;

integer clk_gate_period = clk_gate_high + clk_gate_low;
// it takes 1 CNV impulse for the adc_data to be populated at the first run
integer cnv_count = 0;

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

  #100

  //data_acquisition_test();

  base_env.stop();

  `INFO(("Test Done"), ADI_VERBOSITY_NONE);
  $finish();

end

reg [15:0]  tx_data_buf = 16'h0101;
bit [31:0]  dma_data_store_arr [(NUM_OF_TRANSFERS) - 1:0];
bit transfer_status = 0;
bit [31:0] transfer_cnt;

// ---------------------------------------------------------------------------
// Creating a "gate" through which the data clock can run (and only then)
// ---------------------------------------------------------------------------

//always @ (*) begin
//  if (clk_gate == 1'b1) begin
//    ref_clk_out = ref_clk;
//  end else begin
//    ref_clk_out = 1'b0;
//  end
//end

initial begin
  #500
  @(posedge ref_clk);
  while (1) begin
    if (clk_gate_counter < (clk_gate_period - 1)) begin
      clk_gate_counter++;
    end else begin
      clk_gate_counter = 0;
    end

    @(posedge ref_clk);
    if (clk_gate_counter > (clk_gate_low - 1)) begin
      clk_gate <= 1;
    end else begin
      clk_gate <= 0;
    end

   if (clk_gate_counter == clk_gate_low) begin
      gate_start <= 1'b1;
      cnv_out <= 1'b1;
    end else begin
      gate_start <= 1'b0;
      cnv_out <= 1'b0;
    end
  end
end

//initial begin
//  s_axi_aresetn <= 1'b0;
//  repeat(10) @(posedge s_axi_aclk);
//  s_axi_aresetn <= 1'b1;
//end

initial begin
  dco_p = 0;
  dco_n = 1;
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
    axi_write (`AXI_PWM_GEN_BA + GetAddrs(AXI_PWM_GEN_REG_PULSE_X_PERIOD), `SET_AXI_PWM_GEN_REG_PULSE_X_PERIOD_PULSE_X_PERIOD('h64)); // set PWM period
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

    //@(negedge rx_busy) - TBD!!!
    #200

    transfer_status = 1;

    base_env.mng.sequencer.RegWrite32(`AXI_LTC2387_DMA_BA + GetAddrs(DMAC_TRANSFER_SUBMIT), `SET_DMAC_TRANSFER_SUBMIT_TRANSFER_SUBMIT(1)); // Submit transfer DMA

   // wait(transfer_cnt == 2 * NUM_OF_TRANSFERS ); - TBD!!!

    #100
    //@(negedge rx_rd_n_negedge_s); - TBD!!!
    //@(posedge sys_clk); - TBD!!!
    transfer_status = 0;

    // Stop pwm gen
    axi_write (`AXI_PWM_GEN_BA + GetAddrs(AXI_PWM_GEN_REG_RSTN), `SET_AXI_PWM_GEN_REG_RSTN_RESET(1));
    `INFO(("AXI_PWM_GEN stopped"), ADI_VERBOSITY_LOW);
endtask

endprogram
