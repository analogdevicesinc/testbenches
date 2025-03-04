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

import test_harness_env_pkg::*;
import axi_vip_pkg::*;
import axi4stream_vip_pkg::*;
import logger_pkg::*;
import adi_regmap_pkg::*;
import adi_regmap_dmac_pkg::*;
import adi_regmap_dac_pkg::*;
import adi_regmap_adc_pkg::*;
import adi_regmap_common_pkg::*;
import adi_regmap_tdd_gen_pkg::*;

import `PKGIFY(test_harness, mng_axi_vip)::*;
import `PKGIFY(test_harness, ddr_axi_vip)::*;

program test_program;

  localparam CH0 = 8'h00;
  localparam CH1 = 8'h40;
  localparam CH2 = 8'h80;
  localparam CH3 = 8'hC0;

  localparam RX1_COMMON  = `AXI_AD9361_BA;
  localparam RX1_CHANNEL = `AXI_AD9361_BA;
  localparam TX1_COMMON  = `AXI_AD9361_BA + 'h4000;
  localparam TX1_CHANNEL = `AXI_AD9361_BA + 'h4000;
  localparam TDD1        = `AXI_AD9361_BA + 'h8000;

  test_harness_env #(`AXI_VIP_PARAMS(test_harness, mng_axi_vip), `AXI_VIP_PARAMS(test_harness, ddr_axi_vip)) base_env;

  bit [31:0] val = 32'h0;
  int r1_mode, rate;

  // --------------------------
  // Wrapper function for AXI read
  // --------------------------
  task axi_read(
    input   [31:0]  raddr,
    output  [31:0]  rdata);

    base_env.mng.sequencer.RegRead32(raddr,rdata);
  endtask

  // --------------------------
  // Wrapper function for AXI read verify
  // --------------------------
  task axi_read_v(
    input   [31:0]  raddr,
    input   [31:0]  vdata);

    base_env.mng.sequencer.RegReadVerify32(raddr,vdata);
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

    // Creating environment
    base_env = new("Base Environment",
                    `TH.`SYS_CLK.inst.IF,
                    `TH.`DMA_CLK.inst.IF,
                    `TH.`DDR_CLK.inst.IF,
                    `TH.`SYS_RST.inst.IF,
                    `TH.`MNG_AXI.inst.IF,
                    `TH.`DDR_AXI.inst.IF);

    setLoggerVerbosity(ADI_VERBOSITY_NONE);
    base_env.start();

    // Set source synchronous interface clock frequency
    `TH.`SSI_CLK.inst.IF.set_clk_frq(.user_frequency(61440000));
    `TH.`SSI_CLK.inst.IF.start_clock();

    // Initial system reset
    base_env.sys_reset();

    // This is required since the AD9361 interface always requires to receive
    // something first before transmitting. This is not possible in loopback mode.
    force `TH.axi_ad9361.inst.i_tx.dac_sync_enable = 1'b1;

    sanity_test();

    // 1R1T mode
    r1_mode = 1;

    pn_test();

    dds_test();

    dma_test();

    // 2R2T mode
    r1_mode = 0;

    pn_test();

    dds_test();

    dma_test();

    tdd_test();

    base_env.stop();
    `TH.`SSI_CLK.inst.IF.stop_clock();

    `INFO(("Test Done"), ADI_VERBOSITY_NONE);
    $finish();

  end

  // --------------------------
  // Sanity test reg interface
  // --------------------------
  task sanity_test();
    // Check ADC VERSION
    axi_read_v (RX1_COMMON + GetAddrs(COMMON_REG_VERSION),
               `SET_COMMON_REG_VERSION_VERSION('h000a0300));
    // Check DAC VERSION
    axi_read_v (TX1_COMMON + GetAddrs(COMMON_REG_VERSION),
               `SET_COMMON_REG_VERSION_VERSION('h00090262));
  endtask

  // --------------------------
  // Setup link
  // --------------------------
  task link_setup();
    // Set the DAC rate
    rate = r1_mode ? 1 : 2;

    // Configure RX interface
    axi_write (RX1_COMMON + GetAddrs(ADC_COMMON_REG_CNTRL),
              `SET_ADC_COMMON_REG_CNTRL_R1_MODE(r1_mode));

    // Configure TX interface
    axi_write (TX1_COMMON + GetAddrs(DAC_COMMON_REG_CNTRL_2),
              `SET_DAC_COMMON_REG_CNTRL_2_R1_MODE(r1_mode));
    axi_write (TX1_COMMON + GetAddrs(DAC_COMMON_REG_RATECNTRL),
              `SET_DAC_COMMON_REG_RATECNTRL_RATE(rate-1));

    // Pull out RX of reset
    axi_write (RX1_COMMON + GetAddrs(ADC_COMMON_REG_RSTN),
              `SET_ADC_COMMON_REG_RSTN_RSTN(1));
    // Pull out TX of reset
    axi_write (TX1_COMMON + GetAddrs(DAC_COMMON_REG_RSTN),
              `SET_DAC_COMMON_REG_RSTN_RSTN(1));
  endtask

  // --------------------------
  // Link teardown
  // --------------------------
  task link_down();
    // Put RX in reset
    axi_write (RX1_COMMON + GetAddrs(ADC_COMMON_REG_RSTN),
              `SET_ADC_COMMON_REG_RSTN_RSTN(0));
    // Put TX in reset
    axi_write (TX1_COMMON + GetAddrs(DAC_COMMON_REG_RSTN),
              `SET_DAC_COMMON_REG_RSTN_RSTN(0));
    #1us;
  endtask

  // --------------------------
  // Test pattern test
  // --------------------------
  task pn_test();
    link_setup();

    // Enable test data for TX
    axi_write (TX1_CHANNEL + CH0 + GetAddrs(DAC_CHANNEL_REG_CHAN_CNTRL_7),
              `SET_DAC_CHANNEL_REG_CHAN_CNTRL_7_DAC_DDS_SEL(9));
    axi_write (TX1_CHANNEL + CH1 + GetAddrs(DAC_CHANNEL_REG_CHAN_CNTRL_7),
              `SET_DAC_CHANNEL_REG_CHAN_CNTRL_7_DAC_DDS_SEL(9));
    if (r1_mode==0) begin
      axi_write (TX1_CHANNEL + CH2 + GetAddrs(DAC_CHANNEL_REG_CHAN_CNTRL_7),
                `SET_DAC_CHANNEL_REG_CHAN_CNTRL_7_DAC_DDS_SEL(9));
      axi_write (TX1_CHANNEL + CH3 + GetAddrs(DAC_CHANNEL_REG_CHAN_CNTRL_7),
                `SET_DAC_CHANNEL_REG_CHAN_CNTRL_7_DAC_DDS_SEL(9));
    end

    // Enable test data check for RX
    axi_write (RX1_CHANNEL + CH0 + GetAddrs(ADC_CHANNEL_REG_CHAN_CNTRL_3),
              `SET_ADC_CHANNEL_REG_CHAN_CNTRL_3_ADC_PN_SEL(9));
    axi_write (RX1_CHANNEL + CH1 + GetAddrs(ADC_CHANNEL_REG_CHAN_CNTRL_3),
              `SET_ADC_CHANNEL_REG_CHAN_CNTRL_3_ADC_PN_SEL(9));
    if (r1_mode==0) begin
      axi_write (RX1_CHANNEL + CH2 + GetAddrs(ADC_CHANNEL_REG_CHAN_CNTRL_3),
                `SET_ADC_CHANNEL_REG_CHAN_CNTRL_3_ADC_PN_SEL(9));
      axi_write (RX1_CHANNEL + CH3 + GetAddrs(ADC_CHANNEL_REG_CHAN_CNTRL_3),
                `SET_ADC_CHANNEL_REG_CHAN_CNTRL_3_ADC_PN_SEL(9));
    end

    // SYNC DAC channels
    axi_write (TX1_COMMON+GetAddrs(DAC_COMMON_REG_CNTRL_1),
              `SET_DAC_COMMON_REG_CNTRL_1_SYNC(1));
    // SYNC ADC channels
    axi_write (RX1_COMMON+GetAddrs(ADC_COMMON_REG_CNTRL),
              `SET_ADC_COMMON_REG_CNTRL_R1_MODE(r1_mode) |
              `SET_ADC_COMMON_REG_CNTRL_SYNC(1));

    // Allow initial OOS to propagate
    #15us;

    // Clear PN OOS and PN ERR
    axi_write (RX1_CHANNEL + CH0 + GetAddrs(ADC_CHANNEL_REG_CHAN_STATUS),
              `SET_ADC_CHANNEL_REG_CHAN_STATUS_PN_ERR(1) |
              `SET_ADC_CHANNEL_REG_CHAN_STATUS_PN_OOS(1) |
              `SET_ADC_CHANNEL_REG_CHAN_STATUS_OVER_RANGE(1));
    axi_write (RX1_CHANNEL + CH1 + GetAddrs(ADC_CHANNEL_REG_CHAN_STATUS),
              `SET_ADC_CHANNEL_REG_CHAN_STATUS_PN_ERR(1) |
              `SET_ADC_CHANNEL_REG_CHAN_STATUS_PN_OOS(1) |
              `SET_ADC_CHANNEL_REG_CHAN_STATUS_OVER_RANGE(1));
    if (r1_mode==0) begin
      axi_write (RX1_CHANNEL + CH2 + GetAddrs(ADC_CHANNEL_REG_CHAN_STATUS),
                `SET_ADC_CHANNEL_REG_CHAN_STATUS_PN_ERR(1) |
                `SET_ADC_CHANNEL_REG_CHAN_STATUS_PN_OOS(1) |
                `SET_ADC_CHANNEL_REG_CHAN_STATUS_OVER_RANGE(1));
      axi_write (RX1_CHANNEL + CH3 + GetAddrs(ADC_CHANNEL_REG_CHAN_STATUS),
                `SET_ADC_CHANNEL_REG_CHAN_STATUS_PN_ERR(1) |
                `SET_ADC_CHANNEL_REG_CHAN_STATUS_PN_OOS(1) |
                `SET_ADC_CHANNEL_REG_CHAN_STATUS_OVER_RANGE(1));
    end

    #10us;

    // Check PN OOS and PN ERR flags
    axi_read_v (RX1_COMMON + GetAddrs(ADC_COMMON_REG_STATUS),
               `SET_ADC_COMMON_REG_STATUS_STATUS('h1));

    link_down();
  endtask

  // --------------------------
  // DDS test procedure
  // --------------------------
  task dds_test();

    //  -------------------------------------------------------
    //  Test DDS path
    //  -------------------------------------------------------

    link_setup();

    // Select DDS as source
    axi_write (TX1_CHANNEL + CH0 + GetAddrs(DAC_CHANNEL_REG_CHAN_CNTRL_7),
              `SET_DAC_CHANNEL_REG_CHAN_CNTRL_7_DAC_DDS_SEL(0));
    axi_write (TX1_CHANNEL + CH1 + GetAddrs(DAC_CHANNEL_REG_CHAN_CNTRL_7),
              `SET_DAC_CHANNEL_REG_CHAN_CNTRL_7_DAC_DDS_SEL(0));
    if (r1_mode==0) begin
      axi_write (TX1_CHANNEL + CH2 + GetAddrs(DAC_CHANNEL_REG_CHAN_CNTRL_7),
                `SET_DAC_CHANNEL_REG_CHAN_CNTRL_7_DAC_DDS_SEL(0));
      axi_write (TX1_CHANNEL + CH3 + GetAddrs(DAC_CHANNEL_REG_CHAN_CNTRL_7),
                `SET_DAC_CHANNEL_REG_CHAN_CNTRL_7_DAC_DDS_SEL(0));
    end

    // Enable normal data path for RX
    axi_write (RX1_CHANNEL + CH0 + GetAddrs(ADC_CHANNEL_REG_CHAN_CNTRL_3),
              `SET_ADC_CHANNEL_REG_CHAN_CNTRL_3_ADC_PN_SEL(0));
    axi_write (RX1_CHANNEL + CH1 + GetAddrs(ADC_CHANNEL_REG_CHAN_CNTRL_3),
              `SET_ADC_CHANNEL_REG_CHAN_CNTRL_3_ADC_PN_SEL(0));
    if (r1_mode==0) begin
      axi_write (RX1_CHANNEL + CH2 + GetAddrs(ADC_CHANNEL_REG_CHAN_CNTRL_3),
                `SET_ADC_CHANNEL_REG_CHAN_CNTRL_3_ADC_PN_SEL(0));
      axi_write (RX1_CHANNEL + CH3 + GetAddrs(ADC_CHANNEL_REG_CHAN_CNTRL_3),
                `SET_ADC_CHANNEL_REG_CHAN_CNTRL_3_ADC_PN_SEL(0));
    end

    // Configure tone amplitude and frequency
    axi_write (TX1_CHANNEL + CH0 + GetAddrs(DAC_CHANNEL_REG_CHAN_CNTRL_1),
              `SET_DAC_CHANNEL_REG_CHAN_CNTRL_1_DDS_SCALE_1(16'h0fff));
    axi_write (TX1_CHANNEL + CH1 + GetAddrs(DAC_CHANNEL_REG_CHAN_CNTRL_1),
              `SET_DAC_CHANNEL_REG_CHAN_CNTRL_1_DDS_SCALE_1(16'h07ff));
    if (r1_mode==0) begin
      axi_write (TX1_CHANNEL + CH2 + GetAddrs(DAC_CHANNEL_REG_CHAN_CNTRL_1),
                `SET_DAC_CHANNEL_REG_CHAN_CNTRL_1_DDS_SCALE_1(16'h03ff));
      axi_write (TX1_CHANNEL + CH3 + GetAddrs(DAC_CHANNEL_REG_CHAN_CNTRL_1),
                `SET_DAC_CHANNEL_REG_CHAN_CNTRL_1_DDS_SCALE_1(16'h01ff));
    end
    axi_write (TX1_CHANNEL + CH0 + GetAddrs(DAC_CHANNEL_REG_CHAN_CNTRL_2),
              `SET_DAC_CHANNEL_REG_CHAN_CNTRL_2_DDS_INCR_1(16'h0100));
    axi_write (TX1_CHANNEL + CH1 + GetAddrs(DAC_CHANNEL_REG_CHAN_CNTRL_2),
              `SET_DAC_CHANNEL_REG_CHAN_CNTRL_2_DDS_INCR_1(16'h0200));
    if (r1_mode==0) begin
      axi_write (TX1_CHANNEL + CH2 + GetAddrs(DAC_CHANNEL_REG_CHAN_CNTRL_2),
                `SET_DAC_CHANNEL_REG_CHAN_CNTRL_2_DDS_INCR_1(16'h0400));
      axi_write (TX1_CHANNEL + CH3 + GetAddrs(DAC_CHANNEL_REG_CHAN_CNTRL_2),
                `SET_DAC_CHANNEL_REG_CHAN_CNTRL_2_DDS_INCR_1(16'h0800));
    end

    // Enable Rx channel, enable sign extension
    axi_write (RX1_CHANNEL + CH0 + GetAddrs(ADC_CHANNEL_REG_CHAN_CNTRL),
              `SET_ADC_CHANNEL_REG_CHAN_CNTRL_ENABLE(1) |
              `SET_ADC_CHANNEL_REG_CHAN_CNTRL_FORMAT_ENABLE(1) |
              `SET_ADC_CHANNEL_REG_CHAN_CNTRL_FORMAT_SIGNEXT(1));
    axi_write (RX1_CHANNEL + CH1 + GetAddrs(ADC_CHANNEL_REG_CHAN_CNTRL),
              `SET_ADC_CHANNEL_REG_CHAN_CNTRL_ENABLE(1) |
              `SET_ADC_CHANNEL_REG_CHAN_CNTRL_FORMAT_ENABLE(1) |
              `SET_ADC_CHANNEL_REG_CHAN_CNTRL_FORMAT_SIGNEXT(1));
    if (r1_mode==0) begin
      axi_write (RX1_CHANNEL + CH2 + GetAddrs(ADC_CHANNEL_REG_CHAN_CNTRL),
                `SET_ADC_CHANNEL_REG_CHAN_CNTRL_ENABLE(1) |
                `SET_ADC_CHANNEL_REG_CHAN_CNTRL_FORMAT_ENABLE(1) |
                `SET_ADC_CHANNEL_REG_CHAN_CNTRL_FORMAT_SIGNEXT(1));
      axi_write (RX1_CHANNEL + CH3 + GetAddrs(ADC_CHANNEL_REG_CHAN_CNTRL),
                `SET_ADC_CHANNEL_REG_CHAN_CNTRL_ENABLE(1) |
                `SET_ADC_CHANNEL_REG_CHAN_CNTRL_FORMAT_ENABLE(1) |
                `SET_ADC_CHANNEL_REG_CHAN_CNTRL_FORMAT_SIGNEXT(1));
    end

    // SYNC DAC channels
    axi_write (TX1_COMMON+GetAddrs(DAC_COMMON_REG_CNTRL_1),
              `SET_DAC_COMMON_REG_CNTRL_1_SYNC(1));
    // SYNC ADC channels
    axi_write (RX1_COMMON+GetAddrs(ADC_COMMON_REG_CNTRL),
              `SET_ADC_COMMON_REG_CNTRL_R1_MODE(r1_mode) |
              `SET_ADC_COMMON_REG_CNTRL_SYNC(1));

    #20us;

    link_down();
  endtask

  // --------------------------
  // DMA test procedure
  // --------------------------
  task dma_test();

    //  -------------------------------------------------------
    //  Test DMA path
    //  -------------------------------------------------------

    // Init test data
    for (int i=0;i<2048*2 ;i=i+2) begin
      base_env.ddr.agent.mem_model.backdoor_memory_write_4byte(xil_axi_uint'(`DDR_BA+i*2),(((i+1)<<4) << 16) | i<<4 ,15); // (<< 4) - 4 LSBs are dropped in the AXI_AD9361
    end

    // Configure TX DMA
    axi_write (`TX_DMA_BA+GetAddrs(DMAC_CONTROL),
               `SET_DMAC_CONTROL_ENABLE(1));
    axi_write (`TX_DMA_BA+GetAddrs(DMAC_X_LENGTH),
               `SET_DMAC_X_LENGTH_X_LENGTH(32'h00000FFF));
    axi_write (`TX_DMA_BA+GetAddrs(DMAC_FLAGS),
               `SET_DMAC_FLAGS_CYCLIC(1));
    axi_write (`TX_DMA_BA+GetAddrs(DMAC_SRC_ADDRESS),
               `SET_DMAC_SRC_ADDRESS_SRC_ADDRESS(`DDR_BA+32'h00000000));
    axi_write (`TX_DMA_BA+GetAddrs(DMAC_TRANSFER_SUBMIT),
               `SET_DMAC_TRANSFER_SUBMIT_TRANSFER_SUBMIT(1));

    // Select DMA as source
    axi_write (TX1_CHANNEL + CH0 + GetAddrs(DAC_CHANNEL_REG_CHAN_CNTRL_7),
              `SET_DAC_CHANNEL_REG_CHAN_CNTRL_7_DAC_DDS_SEL(2));
    axi_write (TX1_CHANNEL + CH1 + GetAddrs(DAC_CHANNEL_REG_CHAN_CNTRL_7),
              `SET_DAC_CHANNEL_REG_CHAN_CNTRL_7_DAC_DDS_SEL(2));
    if (r1_mode==0) begin
      axi_write (TX1_CHANNEL + CH2 + GetAddrs(DAC_CHANNEL_REG_CHAN_CNTRL_7),
                `SET_DAC_CHANNEL_REG_CHAN_CNTRL_7_DAC_DDS_SEL(2));
      axi_write (TX1_CHANNEL + CH3 + GetAddrs(DAC_CHANNEL_REG_CHAN_CNTRL_7),
                `SET_DAC_CHANNEL_REG_CHAN_CNTRL_7_DAC_DDS_SEL(2));
    end


    // Enable normal data path for RX
    axi_write (RX1_CHANNEL + CH0 + GetAddrs(ADC_CHANNEL_REG_CHAN_CNTRL_3),
              `SET_ADC_CHANNEL_REG_CHAN_CNTRL_3_ADC_PN_SEL(0));
    axi_write (RX1_CHANNEL + CH1 + GetAddrs(ADC_CHANNEL_REG_CHAN_CNTRL_3),
              `SET_ADC_CHANNEL_REG_CHAN_CNTRL_3_ADC_PN_SEL(0));
    if (r1_mode==0) begin
      axi_write (RX1_CHANNEL + CH2 + GetAddrs(ADC_CHANNEL_REG_CHAN_CNTRL_3),
                `SET_ADC_CHANNEL_REG_CHAN_CNTRL_3_ADC_PN_SEL(0));
      axi_write (RX1_CHANNEL + CH3 + GetAddrs(ADC_CHANNEL_REG_CHAN_CNTRL_3),
                `SET_ADC_CHANNEL_REG_CHAN_CNTRL_3_ADC_PN_SEL(0));
    end


    // Enable Rx channel, enable sign extension
    axi_write (RX1_CHANNEL + CH0 + GetAddrs(ADC_CHANNEL_REG_CHAN_CNTRL),
              `SET_ADC_CHANNEL_REG_CHAN_CNTRL_ENABLE(1) |
              `SET_ADC_CHANNEL_REG_CHAN_CNTRL_FORMAT_ENABLE(1) |
              `SET_ADC_CHANNEL_REG_CHAN_CNTRL_FORMAT_SIGNEXT(1));
    axi_write (RX1_CHANNEL + CH1 + GetAddrs(ADC_CHANNEL_REG_CHAN_CNTRL),
              `SET_ADC_CHANNEL_REG_CHAN_CNTRL_ENABLE(1) |
              `SET_ADC_CHANNEL_REG_CHAN_CNTRL_FORMAT_ENABLE(1) |
              `SET_ADC_CHANNEL_REG_CHAN_CNTRL_FORMAT_SIGNEXT(1));
    if (r1_mode==0) begin
      axi_write (RX1_CHANNEL + CH2 + GetAddrs(ADC_CHANNEL_REG_CHAN_CNTRL),
                `SET_ADC_CHANNEL_REG_CHAN_CNTRL_ENABLE(1) |
                `SET_ADC_CHANNEL_REG_CHAN_CNTRL_FORMAT_ENABLE(1) |
                `SET_ADC_CHANNEL_REG_CHAN_CNTRL_FORMAT_SIGNEXT(1));
      axi_write (RX1_CHANNEL + CH3 + GetAddrs(ADC_CHANNEL_REG_CHAN_CNTRL),
                `SET_ADC_CHANNEL_REG_CHAN_CNTRL_ENABLE(1) |
                `SET_ADC_CHANNEL_REG_CHAN_CNTRL_FORMAT_ENABLE(1) |
                `SET_ADC_CHANNEL_REG_CHAN_CNTRL_FORMAT_SIGNEXT(1));
    end

    // SYNC DAC channels
    axi_write (TX1_COMMON+GetAddrs(DAC_COMMON_REG_CNTRL_1),
              `SET_DAC_COMMON_REG_CNTRL_1_SYNC(1));
    // SYNC ADC channels
    axi_write (RX1_COMMON+GetAddrs(ADC_COMMON_REG_CNTRL),
              `SET_ADC_COMMON_REG_CNTRL_R1_MODE(r1_mode) |
              `SET_ADC_COMMON_REG_CNTRL_SYNC(1));

    link_setup();

    #20us;

    // Configure RX DMA
    axi_write (`RX_DMA_BA+GetAddrs(DMAC_CONTROL),
               `SET_DMAC_CONTROL_ENABLE(1));
    axi_write (`RX_DMA_BA+GetAddrs(DMAC_FLAGS),
               `SET_DMAC_FLAGS_TLAST(1));
    axi_write (`RX_DMA_BA+GetAddrs(DMAC_X_LENGTH),
               `SET_DMAC_X_LENGTH_X_LENGTH(32'h000003FF));
    axi_write (`RX_DMA_BA+GetAddrs(DMAC_DEST_ADDRESS),
               `SET_DMAC_DEST_ADDRESS_DEST_ADDRESS(`DDR_BA+32'h00002000));
    axi_write (`RX_DMA_BA+GetAddrs(DMAC_TRANSFER_SUBMIT),
               `SET_DMAC_TRANSFER_SUBMIT_TRANSFER_SUBMIT(1));

    #10us;

    axi_write (`TX_DMA_BA+GetAddrs(DMAC_CONTROL), 
               `SET_DMAC_CONTROL_ENABLE(0)); 
    axi_write (`RX_DMA_BA+GetAddrs(DMAC_CONTROL), 
               `SET_DMAC_CONTROL_ENABLE(0)); 

    check_captured_data(
      .address (`DDR_BA+'h00002000),
      .length (1024),
      .step (1),
      .max_sample(2048)
    );

    link_down();
  endtask

  // --------------------------
  // TDD test procedure
  // --------------------------
  task tdd_test();

    // Init test data
    for (int i=0;i<2048*2 ;i=i+2) begin
      base_env.ddr.agent.mem_model.backdoor_memory_write_4byte(xil_axi_uint'(`DDR_BA+i*2),(((i+1)<<4) << 16) | i<<4 ,15); // (<< 4) - 4 LSBs are dropped in the AXI_AD9361
    end

    link_setup();

    //  -------------------------------------------------------
    //  Configure the TX/RX Channels
    //  -------------------------------------------------------
  
    // Select DMA as source
    axi_write (TX1_CHANNEL + CH0 + GetAddrs(DAC_CHANNEL_REG_CHAN_CNTRL_7),
              `SET_DAC_CHANNEL_REG_CHAN_CNTRL_7_DAC_DDS_SEL(2));
    axi_write (TX1_CHANNEL + CH1 + GetAddrs(DAC_CHANNEL_REG_CHAN_CNTRL_7),
              `SET_DAC_CHANNEL_REG_CHAN_CNTRL_7_DAC_DDS_SEL(2));
    axi_write (TX1_CHANNEL + CH2 + GetAddrs(DAC_CHANNEL_REG_CHAN_CNTRL_7),
              `SET_DAC_CHANNEL_REG_CHAN_CNTRL_7_DAC_DDS_SEL(2));
    axi_write (TX1_CHANNEL + CH3 + GetAddrs(DAC_CHANNEL_REG_CHAN_CNTRL_7),
              `SET_DAC_CHANNEL_REG_CHAN_CNTRL_7_DAC_DDS_SEL(2));

    // Enable normal data path for RX
    axi_write (RX1_CHANNEL + CH0 + GetAddrs(ADC_CHANNEL_REG_CHAN_CNTRL_3),
              `SET_ADC_CHANNEL_REG_CHAN_CNTRL_3_ADC_PN_SEL(0));
    axi_write (RX1_CHANNEL + CH1 + GetAddrs(ADC_CHANNEL_REG_CHAN_CNTRL_3),
              `SET_ADC_CHANNEL_REG_CHAN_CNTRL_3_ADC_PN_SEL(0));
    axi_write (RX1_CHANNEL + CH2 + GetAddrs(ADC_CHANNEL_REG_CHAN_CNTRL_3),
              `SET_ADC_CHANNEL_REG_CHAN_CNTRL_3_ADC_PN_SEL(0));
    axi_write (RX1_CHANNEL + CH3 + GetAddrs(ADC_CHANNEL_REG_CHAN_CNTRL_3),
              `SET_ADC_CHANNEL_REG_CHAN_CNTRL_3_ADC_PN_SEL(0));

    // Enable Rx channel, enable sign extension
    axi_write (RX1_CHANNEL + CH0 + GetAddrs(ADC_CHANNEL_REG_CHAN_CNTRL),
              `SET_ADC_CHANNEL_REG_CHAN_CNTRL_ENABLE(1) |
              `SET_ADC_CHANNEL_REG_CHAN_CNTRL_FORMAT_ENABLE(1) |
              `SET_ADC_CHANNEL_REG_CHAN_CNTRL_FORMAT_SIGNEXT(1));
    axi_write (RX1_CHANNEL + CH1 + GetAddrs(ADC_CHANNEL_REG_CHAN_CNTRL),
              `SET_ADC_CHANNEL_REG_CHAN_CNTRL_ENABLE(1) |
              `SET_ADC_CHANNEL_REG_CHAN_CNTRL_FORMAT_ENABLE(1) |
              `SET_ADC_CHANNEL_REG_CHAN_CNTRL_FORMAT_SIGNEXT(1));
    axi_write (RX1_CHANNEL + CH2 + GetAddrs(ADC_CHANNEL_REG_CHAN_CNTRL),
              `SET_ADC_CHANNEL_REG_CHAN_CNTRL_ENABLE(1) |
              `SET_ADC_CHANNEL_REG_CHAN_CNTRL_FORMAT_ENABLE(1) |
              `SET_ADC_CHANNEL_REG_CHAN_CNTRL_FORMAT_SIGNEXT(1));
    axi_write (RX1_CHANNEL + CH3 + GetAddrs(ADC_CHANNEL_REG_CHAN_CNTRL),
              `SET_ADC_CHANNEL_REG_CHAN_CNTRL_ENABLE(1) |
              `SET_ADC_CHANNEL_REG_CHAN_CNTRL_FORMAT_ENABLE(1) |
              `SET_ADC_CHANNEL_REG_CHAN_CNTRL_FORMAT_SIGNEXT(1));

    // SYNC DAC channels
    axi_write (TX1_COMMON+GetAddrs(DAC_COMMON_REG_CNTRL_1),
              `SET_DAC_COMMON_REG_CNTRL_1_SYNC(1));
    // SYNC ADC channels
    axi_write (RX1_COMMON+GetAddrs(ADC_COMMON_REG_CNTRL),
              `SET_ADC_COMMON_REG_CNTRL_SYNC(1));

    //  -------------------------------------------------------
    //  Configure the TX/RX DMA
    //  -------------------------------------------------------

    // Configure TX DMA
    axi_write (`TX_DMA_BA+GetAddrs(DMAC_CONTROL),
               `SET_DMAC_CONTROL_ENABLE(1));
    axi_write (`TX_DMA_BA+GetAddrs(DMAC_X_LENGTH),
               `SET_DMAC_X_LENGTH_X_LENGTH(32'h000003FF));
    axi_write (`TX_DMA_BA+GetAddrs(DMAC_FLAGS),
               `SET_DMAC_FLAGS_CYCLIC(1) |
               `SET_DMAC_FLAGS_TLAST(1));
    axi_write (`TX_DMA_BA+GetAddrs(DMAC_SRC_ADDRESS),
               `SET_DMAC_SRC_ADDRESS_SRC_ADDRESS(`DDR_BA+32'h00000000));

    // Configure RX DMA
    axi_write (`RX_DMA_BA+GetAddrs(DMAC_CONTROL),
               `SET_DMAC_CONTROL_ENABLE(1));
    axi_write (`RX_DMA_BA+GetAddrs(DMAC_FLAGS),
               `SET_DMAC_FLAGS_TLAST(1));
    axi_write (`RX_DMA_BA+GetAddrs(DMAC_IRQ_PENDING),
               `SET_DMAC_IRQ_PENDING_TRANSFER_COMPLETED(1) |
               `SET_DMAC_IRQ_PENDING_TRANSFER_QUEUED(1));
    axi_write (`RX_DMA_BA+GetAddrs(DMAC_IRQ_MASK),
               `SET_DMAC_IRQ_MASK_TRANSFER_COMPLETED(0) |
               `SET_DMAC_IRQ_MASK_TRANSFER_QUEUED(1));
    axi_write (`RX_DMA_BA+GetAddrs(DMAC_X_LENGTH),
               `SET_DMAC_X_LENGTH_X_LENGTH(32'h000003FF));
    axi_write (`RX_DMA_BA+GetAddrs(DMAC_DEST_ADDRESS),
               `SET_DMAC_DEST_ADDRESS_DEST_ADDRESS(`DDR_BA+32'h00002000));

    //  -------------------------------------------------------
    //  Configure the TDD for the phaser synchronization
    //  -------------------------------------------------------

    // Configure the TDD for the application
    axi_write (`TDDN_BA+GetAddrs(TDDN_CNTRL_BURST_COUNT),
               `SET_TDDN_CNTRL_BURST_COUNT_BURST_COUNT(32'h10));

    axi_write (`TDDN_BA+GetAddrs(TDDN_CNTRL_STARTUP_DELAY),
               `SET_TDDN_CNTRL_STARTUP_DELAY_STARTUP_DELAY(32'h0F));

    axi_write (`TDDN_BA+GetAddrs(TDDN_CNTRL_FRAME_LENGTH),
               `SET_TDDN_CNTRL_FRAME_LENGTH_FRAME_LENGTH(32'hFF));

    axi_write (`TDDN_BA+GetAddrs(TDDN_CNTRL_CH0_ON),
               `SET_TDDN_CNTRL_CH0_ON_CH0_ON(32'h00));

    axi_write (`TDDN_BA+GetAddrs(TDDN_CNTRL_CH0_OFF),
               `SET_TDDN_CNTRL_CH0_OFF_CH0_OFF(32'h10));

    axi_write (`TDDN_BA+GetAddrs(TDDN_CNTRL_CH1_ON),
               `SET_TDDN_CNTRL_CH1_ON_CH1_ON(32'h20));

    axi_write (`TDDN_BA+GetAddrs(TDDN_CNTRL_CH1_OFF),
               `SET_TDDN_CNTRL_CH1_OFF_CH1_OFF(32'h30));

    axi_write (`TDDN_BA+GetAddrs(TDDN_CNTRL_CH2_ON),
               `SET_TDDN_CNTRL_CH2_ON_CH2_ON(32'h00));

    axi_write (`TDDN_BA+GetAddrs(TDDN_CNTRL_CH2_OFF),
               `SET_TDDN_CNTRL_CH2_OFF_CH2_OFF(32'h10));

    axi_write (`TDDN_BA+GetAddrs(TDDN_CNTRL_CHANNEL_ENABLE),
               `SET_TDDN_CNTRL_CHANNEL_ENABLE_CHANNEL_ENABLE(32'b111));

    axi_write (`TDDN_BA+GetAddrs(TDDN_CNTRL_CONTROL),
               `SET_TDDN_CNTRL_CONTROL_SYNC_EXT(1) |
               `SET_TDDN_CNTRL_CONTROL_ENABLE(1));

    // Submit the DMA transfer and wait for the TDD sync
    axi_write (`TX_DMA_BA+GetAddrs(DMAC_TRANSFER_SUBMIT),
               `SET_DMAC_TRANSFER_SUBMIT_TRANSFER_SUBMIT(1));

    // Send the external sync signal
    trigger_ext_event();

    // The first RX transfer is submitted between the first two TDD pulses
    #2us;
    axi_write (`RX_DMA_BA+GetAddrs(DMAC_TRANSFER_SUBMIT),
               `SET_DMAC_TRANSFER_SUBMIT_TRANSFER_SUBMIT(1));

    check_cyclic_data();

    link_down();
  endtask

  // Check captured data against incremental pattern based on first sample
  // Pattern should be contiguous
  task check_captured_data(
    input bit [31:0] address,
    input int length,
    input int step,
    input int max_sample);

    bit [31:0] current_address;
    bit [31:0] captured_word;
    bit [31:0] reference_word;
    bit [15:0] first;

    for (int i=0;i<length/2;i=i+2) begin
      current_address = address+(i*2);
      captured_word = base_env.ddr.agent.mem_model.backdoor_memory_read_4byte(current_address);
      if (i==0) begin
        first = captured_word[15:0];
      end else begin
        reference_word = (((first + (i+1)*step)%max_sample) << 16) | ((first + (i*step))%max_sample);

        if (captured_word !== reference_word) begin
          `ERROR(("Address 0x%h Expected 0x%h found 0x%h",current_address,reference_word,captured_word));
        end
      end
    end
  endtask

  // Check the cyclic buffer integrity after each transmission
  task check_cyclic_data();
    // After each RX DMA end of transfer, check the captured data and issue a new transfer
    @(posedge `TH.axi_ad9361_adc_dma.irq);
    axi_write (`RX_DMA_BA+GetAddrs(DMAC_IRQ_PENDING),
               `SET_DMAC_IRQ_PENDING_TRANSFER_COMPLETED(1));
    axi_write (`RX_DMA_BA+GetAddrs(DMAC_TRANSFER_SUBMIT),
               `SET_DMAC_TRANSFER_SUBMIT_TRANSFER_SUBMIT(1));

    check_captured_data(
      .address (`DDR_BA+'h00002000),
      .length (1024),
      .step (1),
      .max_sample(512)
    );

    @(posedge `TH.axi_ad9361_adc_dma.irq);
    axi_write (`RX_DMA_BA+GetAddrs(DMAC_IRQ_PENDING),
               `SET_DMAC_IRQ_PENDING_TRANSFER_COMPLETED(1));
    axi_write (`RX_DMA_BA+GetAddrs(DMAC_TRANSFER_SUBMIT),
               `SET_DMAC_TRANSFER_SUBMIT_TRANSFER_SUBMIT(1));

    check_captured_data(
      .address (`DDR_BA+'h00002000),
      .length (1024),
      .step (1),
      .max_sample(512)
    );

    @(posedge `TH.axi_ad9361_adc_dma.irq);
    axi_write (`RX_DMA_BA+GetAddrs(DMAC_IRQ_PENDING),
               `SET_DMAC_IRQ_PENDING_TRANSFER_COMPLETED(1));

    check_captured_data(
      .address (`DDR_BA+'h00002000),
      .length (1024),
      .step (1),
      .max_sample(512)
    );
  endtask

  // Trigger an external event
  task trigger_ext_event();
    #5ns;
    `TB.burst =1'b1;
    #50ns;
    `TB.burst =1'b0;
  endtask

endprogram
