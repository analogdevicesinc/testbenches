// ***************************************************************************
// ***************************************************************************
// Copyright (C) 2014-2023 Analog Devices, Inc. All rights reserved.
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
import adi_regmap_pkg::*;
import axi_vip_pkg::*;
import axi4stream_vip_pkg::*;
import logger_pkg::*;
import dmac_api_pkg::*;
import dac_api_pkg::*;
import adc_api_pkg::*;
import common_api_pkg::*;

import `PKGIFY(test_harness, mng_axi_vip)::*;
import `PKGIFY(test_harness, ddr_axi_vip)::*;

program test_program;

  timeunit 1ns;
  timeprecision 1ps;

  parameter R1_MODE = 0;

  parameter CH0 = 8'h0;
  parameter CH1 = 8'h1;
  parameter CH2 = 8'h2;
  parameter CH3 = 8'h3;

  parameter RX1_COMMON  = `AXI_AD9361_BA + 'h00_00 * 4;
  parameter RX1_CHANNEL = `AXI_AD9361_BA;

  parameter RX1_DLY = `AXI_AD9361_BA + 'h02_00 * 4;

  parameter TX1_COMMON  = `AXI_AD9361_BA + 'h10_00 * 4;
  parameter TX1_CHANNEL = `AXI_AD9361_BA + 32'h0000_4000;

  parameter TDD1 = `AXI_AD9361_BA + 'h12_00 * 4;

  test_harness_env #(`AXI_VIP_PARAMS(test_harness, mng_axi_vip), `AXI_VIP_PARAMS(test_harness, ddr_axi_vip)) base_env;
  dmac_api tx_dmac_api;
  dmac_api rx_dmac_api;
  dac_api tx_dac_api;
  adc_api rx_adc_api;
  common_api tx_common_api;
  common_api rx_common_api;

  integer rate;
  initial begin
      rate = R1_MODE ? 2 : 4;
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

    tx_dmac_api = new(
      "TX DMAC API",
      base_env.mng.master_sequencer,
      `TX_DMA_BA);

    rx_dmac_api = new(
      "RX DMAC API",
      base_env.mng.master_sequencer,
      `RX_DMA_BA);

    tx_dac_api = new(
      "TX DAC Common API",
      base_env.mng.master_sequencer,
      TX1_COMMON);

    rx_adc_api = new(
      "RX ADC Common API",
      base_env.mng.master_sequencer,
      RX1_COMMON);

    tx_common_api = new(
      "TX Common API",
      base_env.mng.master_sequencer,
      TX1_COMMON);

    rx_common_api = new(
      "RX Common API",
      base_env.mng.master_sequencer,
      RX1_COMMON);

    setLoggerVerbosity(ADI_VERBOSITY_NONE);

    base_env.start();

    //set source synchronous interface clock frequency
    `TH.`SSI_CLK.inst.IF.set_clk_frq(.user_frequency(80000000));
    `TH.`SSI_CLK.inst.IF.start_clock();

    base_env.sys_reset();

    // This is required since the AD9361 interface always requires to receive
    // something first before transmitting. This is not possible in loopback mode.
    force system_tb.test_harness.axi_ad9361.inst.i_tx.dac_sync_enable = 1'b1;

    sanity_test();

    pn_test();

    dds_test();

    dma_test();

    base_env.stop();
    `TH.`SSI_CLK.inst.IF.stop_clock();

    `INFO(("Test Done"), ADI_VERBOSITY_NONE);
    $finish();

  end

  // --------------------------
  // Sanity test reg interface
  // --------------------------
  task sanity_test();
    tx_dmac_api.sanity_test();
    rx_dmac_api.sanity_test();
    // TODO: Rewrite sanity test
    // tx_common_api.sanity_test();
    // rx_common_api.sanity_test();

    // //check ADC VERSION
    // axi_read_v (RX1_COMMON + GetAddrs(COMMON_REG_VERSION),
    //            `SET_COMMON_REG_VERSION_VERSION('h000a0300));
    // //check DAC VERSION
    // axi_read_v (TX1_COMMON + GetAddrs(COMMON_REG_VERSION),
    //            `SET_COMMON_REG_VERSION_VERSION('h00090262));
  endtask

  // --------------------------
  // Setup link
  // --------------------------
  task link_setup();
    // Configure Rx interface
    rx_adc_api.set_common_control(
      .pin_mode(0),
      .ddr_edgesel(0),
      .r1_mode(R1_MODE),
      .sync(0),
      .num_lanes(0),
      .symb_8_16b(0),
      .symb_op(0),
      .sdr_ddr_n(0));

    // Configure Tx interface
    tx_dac_api.set_common_control_2(
      .data_format(0),
      .num_lanes(0),
      .par_enb(0),
      .par_type(0),
      .r1_mode(R1_MODE),
      .sdr_ddr_n(0),
      .symb_8_16b(0),
      .symb_op(0));
    tx_dac_api.set_rate(rate-1);

    // pull out RX of reset
    rx_adc_api.reset(
      .ce_n(0),
      .mmcm_rstn(0),
      .rstn(1));
    // pull out TX of reset
    tx_dac_api.reset(
      .ce_n(0),
      .mmcm_rstn(0),
      .rstn(1));
  endtask

  // --------------------------
  // Link teardown
  // --------------------------
  task link_down();
    // put RX in reset
    rx_adc_api.reset(
      .ce_n(0),
      .mmcm_rstn(0),
      .rstn(0));
    // put TX in reset
    tx_dac_api.reset(
      .ce_n(0),
      .mmcm_rstn(0),
      .rstn(0));
    #1000ns;
  endtask

  // --------------------------
  // Test pattern test
  // --------------------------
  task pn_test();
    logic status;

    link_setup();

    // enable test data for TX1
    tx_dac_api.set_channel_control_7(
      .channel(CH0),
      .dds_sel(4'h9));
    tx_dac_api.set_channel_control_7(
      .channel(CH1),
      .dds_sel(4'h9));
    if (R1_MODE==0) begin
      tx_dac_api.set_channel_control_7(
        .channel(CH2),
        .dds_sel(4'h9));
      tx_dac_api.set_channel_control_7(
        .channel(CH3),
        .dds_sel(4'h9));
    end

    // enable test data check for RX1
    rx_adc_api.set_channel_control_3(
      .channel(CH0),
      .pn_sel(4'h9),
      .data_sel(4'h0));
    rx_adc_api.set_channel_control_3(
      .channel(CH1),
      .pn_sel(4'h9),
      .data_sel(4'h0));
    if (R1_MODE==0) begin
      rx_adc_api.set_channel_control_3(
        .channel(CH2),
        .pn_sel(4'h9),
        .data_sel(4'h0));
      rx_adc_api.set_channel_control_3(
        .channel(CH3),
        .pn_sel(4'h9),
        .data_sel(4'h0));
    end

    // SYNC DAC channels
    tx_dac_api.set_common_control_1(
      .sync(1'b1),
      .ext_sync_arm(1'b0),
      .ext_sync_disarm(1'b0),
      .manual_sync_request(1'b0));
    // SYNC ADC channels
    rx_adc_api.set_common_control(
      .pin_mode(1'b0),
      .ddr_edgesel(1'b0),
      .r1_mode(1'b0),
      .sync(1'b1),
      .num_lanes(4'h0),
      .symb_8_16b(1'b0),
      .symb_op(1'b0),
      .sdr_ddr_n(1'b0));

    // Allow initial OOS to propagate
    #15000ns;

    // clear PN OOS and PN ER
    rx_adc_api.clear_channel_status(CH0);
    rx_adc_api.clear_channel_status(CH1);
    if (R1_MODE==0) begin
      rx_adc_api.clear_channel_status(CH2);
      rx_adc_api.clear_channel_status(CH3);
    end

    #10000ns;

    // check PN OOS and PN ERR flags
    rx_adc_api.get_status(status);
    if (status !== 1'b1) begin
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
    tx_dac_api.set_channel_control_7(
      .channel(CH0),
      .dds_sel(4'h0));
    tx_dac_api.set_channel_control_7(
      .channel(CH1),
      .dds_sel(4'h0));
    if (R1_MODE==0) begin
      tx_dac_api.set_channel_control_7(
        .channel(CH2),
        .dds_sel(4'h0));
      tx_dac_api.set_channel_control_7(
        .channel(CH3),
        .dds_sel(4'h0));
    end

    // enable normal data path for RX1
    rx_adc_api.set_channel_control_3(
      .channel(CH0),
      .pn_sel(4'h0),
      .data_sel(4'h0));
    rx_adc_api.set_channel_control_3(
      .channel(CH1),
      .pn_sel(4'h0),
      .data_sel(4'h0));
    if (R1_MODE==0) begin
      rx_adc_api.set_channel_control_3(
        .channel(CH2),
        .pn_sel(4'h0),
        .data_sel(4'h0));
      rx_adc_api.set_channel_control_3(
        .channel(CH3),
        .pn_sel(4'h0),
        .data_sel(4'h0));
    end

    // Configure tone amplitude and frequency
    tx_dac_api.set_channel_control_1(
      .channel(CH0),
      .dds_scale_1(16'h0fff));
    tx_dac_api.set_channel_control_1(
      .channel(CH1),
      .dds_scale_1(16'h07ff));
    if (R1_MODE==0) begin
      tx_dac_api.set_channel_control_1(
        .channel(CH2),
        .dds_scale_1(16'h03ff));
      tx_dac_api.set_channel_control_1(
        .channel(CH3),
        .dds_scale_1(16'h01ff));
    end
    tx_dac_api.set_channel_control_2(
      .channel(CH0),
      .dds_init_1(16'h0),
      .dds_incr_1(16'h0100));
    tx_dac_api.set_channel_control_2(
      .channel(CH1),
      .dds_init_1(16'h0),
      .dds_incr_1(16'h0200));
    if (R1_MODE==0) begin
      tx_dac_api.set_channel_control_2(
        .channel(CH2),
        .dds_init_1(16'h0),
        .dds_incr_1(16'h0400));
      tx_dac_api.set_channel_control_2(
        .channel(CH3),
        .dds_init_1(16'h0),
        .dds_incr_1(16'h0800));
    end

    // Enable Rx channel, enable sign extension
    rx_adc_api.set_channel_control(
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
    rx_adc_api.set_channel_control(
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
    if (R1_MODE==0) begin
      rx_adc_api.set_channel_control(
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
      rx_adc_api.set_channel_control(
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
    tx_dac_api.set_common_control_1(
      .sync(1'b1),
      .ext_sync_arm(1'b0),
      .ext_sync_disarm(1'b0),
      .manual_sync_request(1'b0));
    // SYNC ADC channels
    rx_adc_api.set_common_control(
      .pin_mode(1'b0),
      .ddr_edgesel(1'b0),
      .r1_mode(1'b0),
      .sync(1'b1),
      .num_lanes(4'h0),
      .symb_8_16b(1'b0),
      .symb_op(1'b0),
      .sdr_ddr_n(1'b0));
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
      base_env.ddr.slave_sequencer.BackdoorWrite32(xil_axi_uint'(`DDR_BA+i*2),(((i+1)<<4) << 16) | i<<4 ,15); // (<< 4) - 4 LSBs are dropped in the AXI_AD9361_BA
    end

    // Configure TX DMA
    tx_dmac_api.enable_dma();
    tx_dmac_api.set_lengths(
      .xfer_length_x(32'h00000FFF),
      .xfer_length_y(32'h0));
    tx_dmac_api.set_flags(
      .cyclic(1'b1),
      .tlast(1'b0),
      .partial_reporting_en(1'b0));
    tx_dmac_api.set_src_addr(`DDR_BA+32'h00000000);
    tx_dmac_api.transfer_start();

    // Select DMA as source
    tx_dac_api.set_channel_control_7(
      .channel(CH0),
      .dds_sel(4'h2));
    tx_dac_api.set_channel_control_7(
      .channel(CH1),
      .dds_sel(4'h2));
    if (R1_MODE==0) begin
      tx_dac_api.set_channel_control_7(
        .channel(CH2),
        .dds_sel(4'h2));
      tx_dac_api.set_channel_control_7(
        .channel(CH3),
        .dds_sel(4'h2));
    end

    // enable normal data path for RX1
    rx_adc_api.set_channel_control_3(
      .channel(CH0),
      .pn_sel(4'h0),
      .data_sel(4'h0));
    rx_adc_api.set_channel_control_3(
      .channel(CH1),
      .pn_sel(4'h0),
      .data_sel(4'h0));
    if (R1_MODE==0) begin
      rx_adc_api.set_channel_control_3(
        .channel(CH2),
        .pn_sel(4'h0),
        .data_sel(4'h0));
      rx_adc_api.set_channel_control_3(
        .channel(CH3),
        .pn_sel(4'h0),
        .data_sel(4'h0));
    end

    // Enable Rx channel, enable sign extension
    rx_adc_api.set_channel_control(
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
    rx_adc_api.set_channel_control(
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
    if (R1_MODE==0) begin
      rx_adc_api.set_channel_control(
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
      rx_adc_api.set_channel_control(
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
    tx_dac_api.set_common_control_1(
      .sync(1'b1),
      .ext_sync_arm(1'b0),
      .ext_sync_disarm(1'b0),
      .manual_sync_request(1'b0));
    // SYNC ADC channels
    rx_adc_api.set_common_control(
      .pin_mode(1'b0),
      .ddr_edgesel(1'b0),
      .r1_mode(1'b0),
      .sync(1'b1),
      .num_lanes(4'h0),
      .symb_8_16b(1'b0),
      .symb_op(1'b0),
      .sdr_ddr_n(1'b0));

    link_setup();

    #20us;

    // Configure RX DMA
    rx_dmac_api.enable_dma();
    rx_dmac_api.set_flags(
      .cyclic(1'b0),
      .tlast(1'b1),
      .partial_reporting_en(1'b0));
    rx_dmac_api.set_lengths(
      .xfer_length_x(32'h000003FF),
      .xfer_length_y(32'h0));
    rx_dmac_api.set_dest_addr(`DDR_BA+32'h00002000);
    rx_dmac_api.transfer_start();

    #10us;

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
      captured_word = base_env.ddr.slave_sequencer.BackdoorRead32(current_address);
      if (i==0) begin
        first = captured_word[15:0];
      end else begin
        reference_word = (((first + (i+1)*step)%max_sample) << 16) | ((first + (i*step))%max_sample);

        if (captured_word !== reference_word) begin
          `ERROR(("Address 0x%h Expected 0x%h found 0x%h",current_address,reference_word,captured_word));
        end else begin
          `INFO(("Address 0x%h Expected 0x%h found 0x%h",current_address,reference_word,captured_word), ADI_VERBOSITY_LOW);
        end
      end
    end
  endtask

endprogram
