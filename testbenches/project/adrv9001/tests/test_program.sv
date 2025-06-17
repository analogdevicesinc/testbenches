// ***************************************************************************
// ***************************************************************************
// Copyright (C) 2014-2018 Analog Devices, Inc. All rights reserved.
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

import axi_vip_pkg::*;
import axi4stream_vip_pkg::*;
import logger_pkg::*;
import test_harness_env_pkg::*;
import dmac_api_pkg::*;
import adc_api_pkg::*;
import dac_api_pkg::*;
import common_api_pkg::*;

import `PKGIFY(test_harness, mng_axi_vip)::*;
import `PKGIFY(test_harness, ddr_axi_vip)::*;

`define PN7 0
`define PN15 1
`define NIBBLE_RAMP 2
`define FULL_RAMP 3

program test_program;

  timeunit 1ns;
  timeprecision 1ps;

  parameter CMOS_LVDS_N = 1;
  parameter SDR_DDR_N = 1;
  parameter SINGLE_LANE = 1;
  parameter SYNTH_R1_MODE = 0;
  parameter USE_RX_CLK_FOR_TX = 0;
  parameter DDS_DISABLE = 0;
  parameter IQCORRECTION_DISABLE = 1;
  parameter SYMB_OP = 0;
  parameter SYMB_8_16B = 0;
  parameter SELECTABLE_CLOCK = 1;

  parameter CH0 = 8'h0;
  parameter CH1 = 8'h1;
  parameter CH2 = 8'h2;
  parameter CH3 = 8'h3;

  parameter RX1_COMMON  = `AXI_ADRV9001_BA + 'h00_00 * 4;
  parameter RX1_CHANNEL = `AXI_ADRV9001_BA + 'h00_00 * 4;

  parameter RX1_DLY = `AXI_ADRV9001_BA + 'h02_00 * 4;

  parameter RX2_COMMON  = `AXI_ADRV9001_BA + 'h04_00 * 4;
  parameter RX2_CHANNEL = `AXI_ADRV9001_BA + 'h04_00 * 4;

  parameter RX2_DLY = `AXI_ADRV9001_BA + 'h06_00 * 4;

  parameter TX1_COMMON  = `AXI_ADRV9001_BA + 'h08_00 * 4;
  parameter TX1_CHANNEL = `AXI_ADRV9001_BA + 'h08_00 * 4;

  parameter TX2_COMMON  = `AXI_ADRV9001_BA + 'h10_00 * 4;
  parameter TX2_CHANNEL = `AXI_ADRV9001_BA + 'h10_00 * 4;

  parameter TDD1 = `AXI_ADRV9001_BA + 'h12_00 * 4;
  parameter TDD2 = `AXI_ADRV9001_BA + 'h13_00 * 4;

  test_harness_env #(`AXI_VIP_PARAMS(test_harness, mng_axi_vip), `AXI_VIP_PARAMS(test_harness, ddr_axi_vip)) base_env;

  dmac_api tx1_dmac_api;
  dmac_api rx1_dmac_api;
  dac_api tx1_dac_api;
  adc_api rx1_adc_api;
  common_api tx1_common_api;
  common_api rx1_common_api;

  dmac_api tx2_dmac_api;
  dmac_api rx2_dmac_api;
  dac_api tx2_dac_api;
  adc_api rx2_adc_api;
  common_api tx2_common_api;
  common_api rx2_common_api;

  int R1_MODE = 0;

  integer rate;
  initial begin
    case ({CMOS_LVDS_N[0],SINGLE_LANE[0],SDR_DDR_N[0],SYMB_OP[0],SYMB_8_16B[0]})
      5'b00000 : rate = 2;
      5'b01000 : rate = 4;
      5'b11100 : rate = 8;
      5'b11000 : rate = 4;
      5'b10000 : rate = 1;
      5'b10100 : rate = 2;
      5'b11111 : rate = 2; // SYMB 8b SDR
      5'b11011 : rate = 1; // SYMB 8b DDR
      5'b11110 : rate = 4; // SYMB 16b SDR
      5'b11010 : rate = 2; // SYMB 16b DDR
      default : rate = 1;
    endcase
  end

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

    tx1_dmac_api = new(
      "TX1 DMAC API",
      base_env.mng.sequencer,
      `TX1_DMA_BA);

    rx1_dmac_api = new(
      "RX1 DMAC API",
      base_env.mng.sequencer,
      `RX1_DMA_BA);

    tx1_dac_api = new(
      "TX1 DAC Common API",
      base_env.mng.sequencer,
      TX1_COMMON);

    rx1_adc_api = new(
      "RX1 ADC Common API",
      base_env.mng.sequencer,
      RX1_COMMON);

    tx1_common_api = new(
      "TX1 Common API",
      base_env.mng.sequencer,
      TX1_COMMON);

    rx1_common_api = new(
      "RX1 Common API",
      base_env.mng.sequencer,
      RX1_COMMON);

    tx2_dmac_api = new(
      "TX2 DMAC API",
      base_env.mng.sequencer,
      `TX2_DMA_BA);

    rx2_dmac_api = new(
      "RX2 DMAC API",
      base_env.mng.sequencer,
      `RX2_DMA_BA);

    tx2_dac_api = new(
      "TX2 DAC Common API",
      base_env.mng.sequencer,
      TX2_COMMON);

    rx2_adc_api = new(
      "RX2 ADC Common API",
      base_env.mng.sequencer,
      RX2_COMMON);

    tx2_common_api = new(
      "TX2 Common API",
      base_env.mng.sequencer,
      TX2_COMMON);

    rx2_common_api = new(
      "RX2 Common API",
      base_env.mng.sequencer,
      RX2_COMMON);

    setLoggerVerbosity(ADI_VERBOSITY_NONE);

    base_env.start();

    //set source synchronous interface clock frequency
    `TH.`SSI_CLK.inst.IF.set_clk_frq(.user_frequency(80000000));
    `TH.`SSI_CLK.inst.IF.start_clock();

    base_env.sys_reset();

    sanity_test();

    // R2T2 tests
    R1_MODE = 0;
    if (SYMB_OP[0] & SYMB_8_16B[0]) begin
    `INFO(("PN Test Skipped in 8 bits symbol mode"), ADI_VERBOSITY_LOW);
    end else begin
      pn_test(`NIBBLE_RAMP);
      pn_test(`FULL_RAMP);
      pn_test(`PN7);
      pn_test(`PN15);
    end
    if (DDS_DISABLE == 0) begin
      dds_test();
    end

    dma_test();

    // independent R1T1 tests
    R1_MODE = 1;
    // enable normal data path for RX2
    rx2_adc_api.set_channel_control_3(
      .channel(CH0),
      .pn_sel(4'h0),
      .data_sel(4'h0));
    if (!SYMB_OP[0]) begin
      rx2_adc_api.set_channel_control_3(
        .channel(CH1),
        .pn_sel(4'h0),
        .data_sel(4'h0));
    end

    dma_test_ch2();

    // Test internal loopback DAC2->ADC2
    // Enable internal loopback
    if (!(SYMB_OP[0] & SYMB_8_16B[0])) begin
      rx2_adc_api.set_channel_control_3(
        .channel(CH0),
        .pn_sel(4'h0),
        .data_sel(4'h1));
      rx2_adc_api.set_channel_control_3(
        .channel(CH1),
        .pn_sel(4'h0),
        .data_sel(4'h1));

      dma_test_ch2();
    end

    base_env.stop();

    `TH.`SSI_CLK.inst.IF.stop_clock();

    `INFO(("Test Done"), ADI_VERBOSITY_NONE);
    $finish();

  end

  // --------------------------
  // Sanity test reg interface
  // --------------------------
  task sanity_test();
    tx1_dmac_api.sanity_test();
    rx1_dmac_api.sanity_test();
    tx2_dmac_api.sanity_test();
    rx2_dmac_api.sanity_test();
    // TODO: Rewrite sanity test
    // tx1_common_api.sanity_test();
    // rx1_common_api.sanity_test();
    // tx2_common_api.sanity_test();
    // rx2_common_api.sanity_test();

    // // check ADC VERSION
    // axi_read_v (RX1_COMMON + GetAddrs(COMMON_REG_VERSION),
    //                 `SET_COMMON_REG_VERSION_VERSION('h000a0300));
    // axi_read_v (RX2_COMMON + GetAddrs(COMMON_REG_VERSION),
    //                 `SET_COMMON_REG_VERSION_VERSION('h000a0300));
    // //check DAC VERSION
    // axi_read_v (TX1_COMMON + GetAddrs(COMMON_REG_VERSION),
    //                 `SET_COMMON_REG_VERSION_VERSION('h00090262));
    // axi_read_v (TX2_COMMON + GetAddrs(COMMON_REG_VERSION),
    //                 `SET_COMMON_REG_VERSION_VERSION('h00090262));
    // check DAC CONFIG
    // tx1_common_api.verify_config(
    //   .rd_raw_data(1'b0),
    //   .ext_sync(1'b0),
    //   .scalecorrection_only(USE_RX_CLK_FOR_TX),
    //   .pps_receiver_enable(1'b0),
    //   .cmos_or_lvds_n(CMOS_LVDS_N),
    //   .dds_disable(DDS_DISABLE),
    //   .delay_control_disable(1'b0),
    //   .mode_1r1t(SYNTH_R1_MODE),
    //   .userports_disable(1'b0),
    //   .dataformat_disable(1'b0),
    //   .dcfilter_disable(1'b0),
    //   .iqcorrection_disable(IQCORRECTION_DISABLE),
    //   .selectable_clock(SELECTABLE_CLOCK));
    // tx2_common_api.verify_config(
    //   .rd_raw_data(1'b0),
    //   .ext_sync(1'b0),
    //   .scalecorrection_only(USE_RX_CLK_FOR_TX),
    //   .pps_receiver_enable(1'b0),
    //   .cmos_or_lvds_n(CMOS_LVDS_N),
    //   .dds_disable(DDS_DISABLE),
    //   .delay_control_disable(1'b0),
    //   .mode_1r1t(1'b1),
    //   .userports_disable(1'b0),
    //   .dataformat_disable(1'b0),
    //   .dcfilter_disable(1'b0),
    //   .iqcorrection_disable(IQCORRECTION_DISABLE),
    //   .selectable_clock(SELECTABLE_CLOCK));
  endtask

  // --------------------------
  // Setup link
  // --------------------------
  task link_setup(bit rx1_en = 1,
                  bit rx2_en = 1,
                  bit tx1_en = 1,
                  bit tx2_en = 1);

    // Configure Rx interface
    rx1_adc_api.set_common_control(
      .pin_mode(1'b0),
      .ddr_edgesel(1'b0),
      .r1_mode(R1_MODE),
      .sync(1'b0),
      .num_lanes(SINGLE_LANE),
      .symb_8_16b(SYMB_8_16B),
      .symb_op(SYMB_OP),
      .sdr_ddr_n(SDR_DDR_N));
    rx2_adc_api.set_common_control(
      .pin_mode(1'b0),
      .ddr_edgesel(1'b0),
      .r1_mode(R1_MODE),
      .sync(1'b0),
      .num_lanes(SINGLE_LANE),
      .symb_8_16b(SYMB_8_16B),
      .symb_op(SYMB_OP),
      .sdr_ddr_n(SDR_DDR_N));
    // Configure Tx interface
    tx1_dac_api.set_common_control_2(
      .data_format(1'b0),
      .num_lanes(SINGLE_LANE),
      .par_enb(1'b0),
      .par_type(1'b0),
      .r1_mode(R1_MODE),
      .sdr_ddr_n(SDR_DDR_N),
      .symb_8_16b(SYMB_8_16B),
      .symb_op(SYMB_OP));
    tx2_dac_api.set_common_control_2(
      .data_format(1'b0),
      .num_lanes(SINGLE_LANE),
      .par_enb(1'b0),
      .par_type(1'b0),
      .r1_mode(R1_MODE),
      .sdr_ddr_n(SDR_DDR_N),
      .symb_8_16b(SYMB_8_16B),
      .symb_op(SYMB_OP));
    tx1_dac_api.set_rate(rate-1);
    tx2_dac_api.set_rate(rate-1);

    // pull out TX of reset
    tx1_dac_api.reset(
      .ce_n(0),
      .mmcm_rstn(tx1_en),
      .rstn(tx1_en));
    tx2_dac_api.reset(
      .ce_n(0),
      .mmcm_rstn(tx2_en),
      .rstn(tx2_en));

    gen_mssi_sync();

    // pull out RX of reset
    rx1_adc_api.reset(
      .ce_n(0),
      .mmcm_rstn(rx1_en),
      .rstn(rx1_en));
    rx2_adc_api.reset(
      .ce_n(0),
      .mmcm_rstn(rx2_en),
      .rstn(rx2_en));
  endtask

  // --------------------------
  // Link teardown
  // --------------------------
  task link_down();
    // put RX in reset
    rx1_adc_api.reset(
      .ce_n(0),
      .mmcm_rstn(0),
      .rstn(0));
    rx2_adc_api.reset(
      .ce_n(0),
      .mmcm_rstn(0),
      .rstn(0));
    // put TX in reset
    tx1_dac_api.reset(
      .ce_n(0),
      .mmcm_rstn(0),
      .rstn(0));
    tx2_dac_api.reset(
      .ce_n(0),
      .mmcm_rstn(0),
      .rstn(0));
    #1000ns;
  endtask

  // --------------------------
  // Test pattern test
  // --------------------------
  task pn_test(input bit [3:0] pattern);

    logic status;

    reg [3:0] tx_pattern_map[0:3];
    reg [3:0] rx_pattern_map[0:3];

    tx_pattern_map[`PN7] = 6;
    tx_pattern_map[`PN15] = 7;
    tx_pattern_map[`NIBBLE_RAMP] = 10;
    tx_pattern_map[`FULL_RAMP] = 11;

    rx_pattern_map[`PN7] = 4;
    rx_pattern_map[`PN15] = 5;
    rx_pattern_map[`NIBBLE_RAMP] = 10;
    rx_pattern_map[`FULL_RAMP] = 11;

    link_setup();
    // enable test data for TX1
    tx1_dac_api.set_channel_control_7(
      .channel(CH0),
      .dds_sel(tx_pattern_map[pattern]));
    tx1_dac_api.set_channel_control_7(
      .channel(CH2),
      .dds_sel(tx_pattern_map[pattern]));
    if (!SYMB_OP[0]) begin
      tx1_dac_api.set_channel_control_7(
        .channel(CH1),
        .dds_sel(tx_pattern_map[pattern]));
      tx1_dac_api.set_channel_control_7(
        .channel(CH3),
        .dds_sel(tx_pattern_map[pattern]));
    end

    // enable test data check for RX1
    rx1_adc_api.set_channel_control_3(
      .channel(CH0),
      .pn_sel(rx_pattern_map[pattern]),
      .data_sel(4'h0));
    rx1_adc_api.set_channel_control_3(
      .channel(CH2),
      .pn_sel(rx_pattern_map[pattern]),
      .data_sel(4'h0));
    if (!SYMB_OP[0]) begin
      rx1_adc_api.set_channel_control_3(
        .channel(CH1),
        .pn_sel(rx_pattern_map[pattern]),
        .data_sel(4'h0));
      rx1_adc_api.set_channel_control_3(
        .channel(CH3),
        .pn_sel(rx_pattern_map[pattern]),
        .data_sel(4'h0));
    end

    // Allow initial OOS to propagate
    #15000ns;

    // clear PN OOS and PN ERR
    rx1_adc_api.clear_channel_status(CH0);
    rx1_adc_api.clear_channel_status(CH2);
    if (!SYMB_OP[0]) begin
      rx1_adc_api.clear_channel_status(CH1);
      rx1_adc_api.clear_channel_status(CH3);
    end

    #10000ns;

    // check PN OOS and PN ERR flags
    rx1_adc_api.get_status(status);
    if (status != 1'b1) begin
      `ERROR(("ADC Common Status error!"));
    end

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
    tx1_dac_api.set_channel_control_7(
      .channel(CH0),
      .dds_sel(4'h0));
    tx1_dac_api.set_channel_control_7(
      .channel(CH2),
      .dds_sel(4'h0));
    if (!SYMB_OP[0]) begin
      tx1_dac_api.set_channel_control_7(
        .channel(CH1),
        .dds_sel(4'h0));
      tx1_dac_api.set_channel_control_7(
        .channel(CH3),
        .dds_sel(4'h0));
    end

    // enable normal data path for RX1
    rx1_adc_api.set_channel_control_3(
      .channel(CH0),
      .pn_sel(4'h0),
      .data_sel(4'h0));
    rx1_adc_api.set_channel_control_3(
      .channel(CH2),
      .pn_sel(4'h0),
      .data_sel(4'h0));
    if (!SYMB_OP[0]) begin
      rx1_adc_api.set_channel_control_3(
        .channel(CH1),
        .pn_sel(4'h0),
        .data_sel(4'h0));
      rx1_adc_api.set_channel_control_3(
        .channel(CH3),
        .pn_sel(4'h0),
        .data_sel(4'h0));
    end

    // Configure tone amplitude and frequency
    tx1_dac_api.set_channel_control_1(
      .channel(CH0),
      .dds_scale_1(16'h0fff));
    tx1_dac_api.set_channel_control_1(
      .channel(CH2),
      .dds_scale_1(16'h07ff));
    if (!SYMB_OP[0]) begin
      tx1_dac_api.set_channel_control_1(
        .channel(CH1),
        .dds_scale_1(16'h03ff));
      tx1_dac_api.set_channel_control_1(
        .channel(CH3),
        .dds_scale_1(16'h01ff));
    end
    tx1_dac_api.set_channel_control_2(
      .channel(CH0),
      .dds_init_1(16'h0),
      .dds_incr_1(16'h0100));
    tx1_dac_api.set_channel_control_2(
      .channel(CH2),
      .dds_init_1(16'h0),
      .dds_incr_1(16'h0200));
    if (!SYMB_OP[0]) begin
      tx1_dac_api.set_channel_control_2(
        .channel(CH1),
        .dds_init_1(16'h0),
        .dds_incr_1(16'h0400));
      tx1_dac_api.set_channel_control_2(
        .channel(CH3),
        .dds_init_1(16'h0),
        .dds_incr_1(16'h0800));
    end

    // Enable Rx channel, enable sign extension
    rx1_adc_api.set_channel_control(
      .channel(CH0),
      .adc_lb_owr(1'b0),
      .adc_pn_sel_owr(1'b0),
      .iqcor_enb(1'b0),
      .dcfilt_enb(1'b0),
      .format_signext(1'b1),
      .format_type(1'b0),
      .format_enable(1'b1),
      .adc_pn_type_owr(1'b0),
      .enable(1'b1));
    rx1_adc_api.set_channel_control(
      .channel(CH2),
      .adc_lb_owr(1'b0),
      .adc_pn_sel_owr(1'b0),
      .iqcor_enb(1'b0),
      .dcfilt_enb(1'b0),
      .format_signext(1'b1),
      .format_type(1'b0),
      .format_enable(1'b1),
      .adc_pn_type_owr(1'b0),
      .enable(1'b1));
    if (!SYMB_OP[0]) begin
      rx1_adc_api.set_channel_control(
        .channel(CH1),
        .adc_lb_owr(1'b0),
        .adc_pn_sel_owr(1'b0),
        .iqcor_enb(1'b0),
        .dcfilt_enb(1'b0),
        .format_signext(1'b1),
        .format_type(1'b0),
        .format_enable(1'b1),
        .adc_pn_type_owr(1'b0),
        .enable(1'b1));
      rx1_adc_api.set_channel_control(
        .channel(CH3),
        .adc_lb_owr(1'b0),
        .adc_pn_sel_owr(1'b0),
        .iqcor_enb(1'b0),
        .dcfilt_enb(1'b0),
        .format_signext(1'b1),
        .format_type(1'b0),
        .format_enable(1'b1),
        .adc_pn_type_owr(1'b0),
        .enable(1'b1));
    end

    // SYNC DAC channels
    tx1_dac_api.set_common_control_1(
      .sync(1'b1),
      .ext_sync_arm(1'b0),
      .ext_sync_disarm(1'b0),
      .manual_sync_request(1'b0));

    #20000ns;

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
      if (SYMB_OP[0] & SYMB_8_16B[0]) begin
        base_env.ddr.agent.mem_model.backdoor_memory_write_4byte(xil_axi_uint'(`DDR_BA+i*2),(((i+1)<<8) << 16) | i<<8 ,15);// (<< 8) - 8 LSBs are dropped in 8 bit data symbol format
      end else begin
        base_env.ddr.agent.mem_model.backdoor_memory_write_4byte(xil_axi_uint'(`DDR_BA+i*2),((i+1) << 16) | i,15);
      end
      // Clear destination region
      base_env.ddr.agent.mem_model.backdoor_memory_write_4byte(xil_axi_uint'(`DDR_BA+'h2000+i*2),'hBEEF,15);
    end

    // Configure TX DMA
    tx1_dmac_api.enable_dma();
    tx1_dmac_api.set_flags(
      .cyclic(1'b1),
      .tlast(1'b0),
      .partial_reporting_en(1'b0));
    tx1_dmac_api.set_lengths(
      .xfer_length_x(32'h00000FFF),
      .xfer_length_y(32'h0));
    tx1_dmac_api.set_src_addr(`DDR_BA+32'h00000000);
    tx1_dmac_api.transfer_start();

    // Select DMA as source
    tx1_dac_api.set_channel_control_7(
      .channel(CH0),
      .dds_sel(4'h2));
    tx1_dac_api.set_channel_control_7(
      .channel(CH2),
      .dds_sel(4'h2));
    if (!SYMB_OP[0]) begin
      tx1_dac_api.set_channel_control_7(
        .channel(CH1),
        .dds_sel(4'h2));
      tx1_dac_api.set_channel_control_7(
        .channel(CH3),
        .dds_sel(4'h2));
    end

    // enable normal data path for RX1
    rx1_adc_api.set_channel_control_3(
      .channel(CH0),
      .pn_sel(4'h0),
      .data_sel(4'h0));
    rx1_adc_api.set_channel_control_3(
      .channel(CH2),
      .pn_sel(4'h0),
      .data_sel(4'h0));
    if (!SYMB_OP[0]) begin
      rx1_adc_api.set_channel_control_3(
        .channel(CH1),
        .pn_sel(4'h0),
        .data_sel(4'h0));
      rx1_adc_api.set_channel_control_3(
        .channel(CH3),
        .pn_sel(4'h0),
        .data_sel(4'h0));
    end

    // Enable Rx channel, enable sign extension
    rx1_adc_api.set_channel_control(
      .channel(CH0),
      .adc_lb_owr(1'b0),
      .adc_pn_sel_owr(1'b0),
      .iqcor_enb(1'b0),
      .dcfilt_enb(1'b0),
      .format_signext(1'b1),
      .format_type(1'b0),
      .format_enable(1'b1),
      .adc_pn_type_owr(1'b0),
      .enable(1'b1));
    rx1_adc_api.set_channel_control(
      .channel(CH2),
      .adc_lb_owr(1'b0),
      .adc_pn_sel_owr(1'b0),
      .iqcor_enb(1'b0),
      .dcfilt_enb(1'b0),
      .format_signext(1'b1),
      .format_type(1'b0),
      .format_enable(1'b1),
      .adc_pn_type_owr(1'b0),
      .enable(1'b1));
    if (!SYMB_OP[0]) begin
      rx1_adc_api.set_channel_control(
        .channel(CH1),
        .adc_lb_owr(1'b0),
        .adc_pn_sel_owr(1'b0),
        .iqcor_enb(1'b0),
        .dcfilt_enb(1'b0),
        .format_signext(1'b1),
        .format_type(1'b0),
        .format_enable(1'b1),
        .adc_pn_type_owr(1'b0),
        .enable(1'b1));
      rx1_adc_api.set_channel_control(
        .channel(CH3),
        .adc_lb_owr(1'b0),
        .adc_pn_sel_owr(1'b0),
        .iqcor_enb(1'b0),
        .dcfilt_enb(1'b0),
        .format_signext(1'b1),
        .format_type(1'b0),
        .format_enable(1'b1),
        .adc_pn_type_owr(1'b0),
        .enable(1'b1));
    end

    // SYNC DAC channels
    tx1_dac_api.set_common_control_1(
      .sync(1'b1),
      .ext_sync_arm(1'b0),
      .ext_sync_disarm(1'b0),
      .manual_sync_request(1'b0));

    link_setup();

    #20us;

    // Configure RX DMA
    rx1_dmac_api.set_irq_mask(
      .transfer_completed(1'b0),
      .transfer_queued(1'b1));
    rx1_dmac_api.enable_dma();
    rx1_dmac_api.set_flags(
      .cyclic(1'b0),
      .tlast(1'b1),
      .partial_reporting_en(1'b1));
    rx1_dmac_api.set_lengths(
      .xfer_length_x(32'h000003FF),
      .xfer_length_y(32'h0));
    rx1_dmac_api.set_dest_addr(`DDR_BA+32'h00002000);
    rx1_dmac_api.transfer_start();

    @(posedge system_tb.test_harness.axi_adrv9001_rx1_dma.irq);

    //Clear interrupt
    rx1_dmac_api.clear_irq_pending(
      .transfer_completed(1'b1),
      .transfer_queued(1'b0));

    check_captured_data(
      .address (`DDR_BA+'h00002000),
      .length (1024),
      .step (1),
      .max_sample(2048)
    );
  endtask

  // --------------------------
  // DMA test procedure for Rx2/Tx2 independent pairs
  // --------------------------
  task dma_test_ch2();

    //  -------------------------------------------------------
    //  Test DMA path
    //  -------------------------------------------------------

    // Init test data
    for (int i=0;i<2048*2 ;i=i+2) begin
      if (SYMB_OP[0] & SYMB_8_16B[0]) begin
        base_env.ddr.agent.mem_model.backdoor_memory_write_4byte(xil_axi_uint'(`DDR_BA+i*2),(((i+1)<<8) << 16) | i<<8 ,15);// (<< 8) - 8 LSBs are dropped in 8 bit data symbol format
      end else begin
        base_env.ddr.agent.mem_model.backdoor_memory_write_4byte(xil_axi_uint'(`DDR_BA+i*2),((i+1) << 16) | i,15);
      end
      // Clear destination region
      base_env.ddr.agent.mem_model.backdoor_memory_write_4byte(xil_axi_uint'(`DDR_BA+'h2000+i*2),'hBEEF,15);
    end

    // Configure TX DMA
    tx2_dmac_api.enable_dma();
    tx2_dmac_api.set_flags(
      .cyclic(1'b1),
      .tlast(1'b0),
      .partial_reporting_en(1'b0));
    tx2_dmac_api.set_lengths(
      .xfer_length_x(32'h00000FFF),
      .xfer_length_y(32'h0));
    tx2_dmac_api.set_src_addr(`DDR_BA+32'h00000000);
    tx2_dmac_api.transfer_start();

    // Select DMA as source
    tx2_dac_api.set_channel_control_7(
      .channel(CH0),
      .dds_sel(4'h2));
    if (!SYMB_OP[0]) begin
      tx2_dac_api.set_channel_control_7(
        .channel(CH1),
        .dds_sel(4'h2));
    end

    // Enable Rx channel, enable sign extension
    rx2_adc_api.set_channel_control(
      .channel(CH0),
      .adc_lb_owr(1'b0),
      .adc_pn_sel_owr(1'b0),
      .iqcor_enb(1'b0),
      .dcfilt_enb(1'b0),
      .format_signext(1'b1),
      .format_type(1'b0),
      .format_enable(1'b1),
      .adc_pn_type_owr(1'b0),
      .enable(1'b1));
    if (!SYMB_OP[0]) begin
      rx2_adc_api.set_channel_control(
        .channel(CH1),
        .adc_lb_owr(1'b0),
        .adc_pn_sel_owr(1'b0),
        .iqcor_enb(1'b0),
        .dcfilt_enb(1'b0),
        .format_signext(1'b1),
        .format_type(1'b0),
        .format_enable(1'b1),
        .adc_pn_type_owr(1'b0),
        .enable(1'b1));
    end

    // SYNC DAC channels
    tx2_dac_api.set_common_control_1(
      .sync(1'b1),
      .ext_sync_arm(1'b0),
      .ext_sync_disarm(1'b0),
      .manual_sync_request(1'b0));

    link_setup(0,1,0,1);

    #20us;

    // Configure RX DMA
    rx2_dmac_api.set_irq_mask(
      .transfer_completed(1'b0),
      .transfer_queued(1'b1));
    rx2_dmac_api.enable_dma();
    rx2_dmac_api.set_flags(
      .cyclic(1'b0),
      .tlast(1'b1),
      .partial_reporting_en(1'b1));
    rx2_dmac_api.set_lengths(
      .xfer_length_x(32'h000003FF),
      .xfer_length_y(32'h0));
    rx2_dmac_api.set_dest_addr(`DDR_BA+32'h00002000);
    rx2_dmac_api.transfer_start();

    @(posedge system_tb.test_harness.axi_adrv9001_rx2_dma.irq);

    //Clear interrupt
    rx2_dmac_api.clear_irq_pending(
      .transfer_completed(1'b1),
      .transfer_queued(1'b0));

    check_captured_data(
      .address (`DDR_BA+'h00002000),
      .length (1024),
      .step (1),
      .max_sample(2048)
    );
  endtask

  // Check captured data against incremental pattern based on first sample
  // Pattern should be contiguous
  task check_captured_data(bit [31:0] address,
                           int length = 1024,
                           int step = 1,
                           int max_sample = 2048
                          );

    bit [31:0] current_address;
    bit [31:0] captured_word;
    bit [31:0] reference_word;
    bit [15:0] first;

    for (int i=0;i<length/2;i=i+2) begin
      current_address = address+(i*2);
      captured_word = base_env.ddr.agent.mem_model.backdoor_memory_read_4byte(current_address);
      if (SYMB_OP[0] & SYMB_8_16B[0]) begin
        captured_word = captured_word & 32'h00ff00ff;
      end
      if (i==0) begin
        if (SYMB_OP[0] & SYMB_8_16B[0]) begin
        first = captured_word[7:0];
        end else begin
        first = captured_word[15:0];
        end
      end else begin
        reference_word = (((first + (i+1)*step)%max_sample) << 16) | ((first + (i*step))%max_sample);
        if (SYMB_OP[0] & SYMB_8_16B[0]) begin
            reference_word = reference_word & 32'h00ff00ff;
        end
        if (captured_word !== reference_word) begin
          `ERROR(("Address 0x%h Expected 0x%h found 0x%h",current_address,reference_word,captured_word));
        end
      end
    end
  endtask

endprogram
