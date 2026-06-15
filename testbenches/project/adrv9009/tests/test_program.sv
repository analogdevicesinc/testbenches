// ***************************************************************************
// ***************************************************************************
// Copyright (C) 2014-2024, 2026 Analog Devices, Inc. All rights reserved.
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
import adi_axi_agent_pkg::*;
import adi_regmap_pkg::*;
import axi_vip_pkg::*;
import axi4stream_vip_pkg::*;
import logger_pkg::*;
import adi_jesd204_pkg::*;
import adi_xcvr_pkg::*;
import clk_gen_api_pkg::*;
import common_api_pkg::*;
import adc_api_pkg::*;
import dac_api_pkg::*;
import data_offload_api_pkg::*;
import dmac_api_pkg::*;

import `PKGIFY(test_harness, mng_axi_vip)::*;
import `PKGIFY(test_harness, ddr_axi_vip)::*;

`define fmod(A, B) (A - (B * $floor(A / B)))

program test_program;

  timeunit 1ns;
  timeprecision 1ps;

  test_harness_env base_env;

  adi_axi_master_agent #(`AXI_VIP_PARAMS(test_harness, mng_axi_vip)) mng;
  adi_axi_slave_mem_agent #(`AXI_VIP_PARAMS(test_harness, ddr_axi_vip)) ddr;

  clk_gen_api tx_clkgen_api;
  clk_gen_api rx_clkgen_api;
  clk_gen_api rx_os_clkgen_api;
  dmac_api tx_dmac_api;
  dmac_api rx_dmac_api;
  dmac_api rx_os_dmac_api;
  dmac_api ex_rx_dmac_api;
  dmac_api ex_tx_dmac_api;
  dmac_api ex_tx_os_dmac_api;
  dac_api tx_dac_api;
  dac_api ex_dac_api;
  dac_api ex_dac_os_api;
  adc_api rx_adc_api;
  adc_api rx_os_adc_api;
  adc_api ex_adc_api;

  bit [31:0] lane_rate_khz = `LANE_RATE*1000000;
  longint lane_rate = lane_rate_khz*1000;
  int tx_link_clk_ratio = (`RX_JESD_L == 1) ? 2 : 1;

  real rx_device_clk, tx_device_clk, tx_link_clk, tx_os_device_clk;
  real rx_sysref_clk, tx_sysref_clk, tx_os_sysref_clk, common_sysref_clk;

  jesd_link tx_link;
  jesd_link rx_link;
  jesd_link rx_os_link;

  rx_link_layer ex_rx_ll;
  tx_link_layer ex_tx_ll;
  tx_link_layer ex_tx_os_ll;
  xcvr ex_rx_xcvr;
  xcvr ex_tx_xcvr;
  xcvr ex_tx_os_xcvr;

  rx_link_layer dut_rx_ll;
  rx_link_layer dut_rx_os_ll;
  tx_link_layer dut_tx_ll;
  xcvr dut_rx_xcvr;
  xcvr dut_rx_os_xcvr;
  xcvr dut_tx_xcvr;

  initial begin

    // Create environment
    base_env = new(
      .name("Base Environment"),
      .sys_clk_vip_if(`TH.`SYS_CLK.inst.IF),
      .dma_clk_vip_if(`TH.`DMA_CLK.inst.IF),
      .ddr_clk_vip_if(`TH.`DDR_CLK.inst.IF),
      .sys_rst_vip_if(`TH.`SYS_RST.inst.IF),
      .irq_base_address(`IRQ_C_BA),
      .irq_vip_if(`TH.`IRQ.inst.inst.IF.vif));

    mng = new("", `TH.`MNG_AXI.inst.IF);
    ddr = new("", `TH.`DDR_AXI.inst.IF);

    `LINK(mng, base_env, mng)
    `LINK(ddr, base_env, ddr)

    tx_clkgen_api = new(
      "TX CLKGEN API",
      base_env.mng.master_sequencer,
      `AXI_CLKGEN_TX_BA);

    rx_clkgen_api = new(
      "RX CLKGEN API",
      base_env.mng.master_sequencer,
      `AXI_CLKGEN_RX_BA);

    rx_os_clkgen_api = new(
      "RX OS CLKGEN API",
      base_env.mng.master_sequencer,
      `AXI_CLKGEN_RX_OS_BA);

    tx_dmac_api = new(
      "TX DMAC API",
      base_env.mng.master_sequencer,
      `TX_DMA_BA);

    rx_dmac_api = new(
      "RX DMAC API",
      base_env.mng.master_sequencer,
      `RX_DMA_BA);

    rx_os_dmac_api = new(
      "RX OS DMAC API",
      base_env.mng.master_sequencer,
      `RX_OS_DMA_BA);

    ex_rx_dmac_api = new(
      "EX RX DMAC API",
      base_env.mng.master_sequencer,
      `EX_RX_DMA_BA);

    ex_tx_dmac_api = new(
      "EX TX DMAC API",
      base_env.mng.master_sequencer,
      `EX_TX_DMA_BA);

    ex_tx_os_dmac_api = new(
      "EX TX OS DMAC API",
      base_env.mng.master_sequencer,
      `EX_TX_OS_DMA_BA);

    tx_dac_api = new(
      "TX DAC TPL API",
      base_env.mng.master_sequencer,
      `DAC_TPL_BA);

    ex_dac_api = new(
      "EX DAC TPL API",
      base_env.mng.master_sequencer,
      `EX_DAC_TPL_BA);

    ex_dac_os_api = new(
      "EX DAC OS TPL API",
      base_env.mng.master_sequencer,
      `EX_DAC_OS_TPL_BA);

    rx_adc_api = new(
      "RX ADC TPL API",
      base_env.mng.master_sequencer,
      `ADC_TPL_BA);

    rx_os_adc_api = new(
      "RX OS ADC TPL API",
      base_env.mng.master_sequencer,
      `ADC_OS_TPL_BA);

    ex_adc_api = new(
      "EX ADC TPL API",
      base_env.mng.master_sequencer,
      `EX_ADC_TPL_BA);

    setLoggerVerbosity(ADI_VERBOSITY_NONE);

    base_env.start();
    base_env.sys_reset();

    tx_link = new;
    tx_link.set_L(`TX_JESD_L);
    tx_link.set_M(`TX_JESD_M);
    tx_link.set_F(`TX_JESD_F);
    tx_link.set_S(`TX_JESD_S);
    tx_link.set_K(32);
    tx_link.set_N(`TX_JESD_NP);
    tx_link.set_NP(`TX_JESD_NP);
    tx_link.set_encoding(enc8b10b);
    tx_link.set_lane_rate(lane_rate);

    rx_link = new;
    rx_link.set_L(`RX_JESD_L);
    rx_link.set_M(`RX_JESD_M);
    rx_link.set_F(`RX_JESD_F);
    rx_link.set_S(`RX_JESD_S);
    rx_link.set_K(32);
    rx_link.set_N(`RX_JESD_NP);
    rx_link.set_NP(`RX_JESD_NP);
    rx_link.set_encoding(enc8b10b);
    rx_link.set_lane_rate(lane_rate);

    rx_os_link = new;
    rx_os_link.set_L(`RX_OS_JESD_L);
    rx_os_link.set_M(`RX_OS_JESD_M);
    rx_os_link.set_F(`RX_OS_JESD_F);
    rx_os_link.set_S(`RX_OS_JESD_S);
    rx_os_link.set_K(32);
    rx_os_link.set_N(`RX_OS_JESD_NP);
    rx_os_link.set_NP(`RX_OS_JESD_NP);
    rx_os_link.set_encoding(enc8b10b);
    rx_os_link.set_lane_rate(lane_rate);

    ex_rx_ll = new("EX RX_LINK_LAYER", base_env.mng.master_sequencer, `EX_AXI_JESD_RX_BA, tx_link);
    ex_rx_ll.probe();

    ex_tx_ll = new("EX TX_LINK_LAYER", base_env.mng.master_sequencer, `EX_AXI_JESD_TX_BA, rx_link);
    ex_tx_ll.probe();

    ex_tx_os_ll = new("EX TX_OS_LINK_LAYER", base_env.mng.master_sequencer, `EX_AXI_JESD_TX_OS_BA, rx_os_link);
    ex_tx_os_ll.probe();

    ex_rx_xcvr = new("EX RX_XCVR", base_env.mng.master_sequencer, `EX_AXI_XCVR_RX_BA);
    ex_rx_xcvr.probe();

    ex_tx_xcvr = new("EX TX_XCVR", base_env.mng.master_sequencer, `EX_AXI_XCVR_TX_BA);
    ex_tx_xcvr.probe();

    ex_tx_os_xcvr = new("EX TX_OS_XCVR", base_env.mng.master_sequencer, `EX_AXI_XCVR_TX_OS_BA);
    ex_tx_os_xcvr.probe();

    dut_rx_xcvr = new("DUT RX_XCVR", base_env.mng.master_sequencer, `DUT_AXI_XCVR_RX_BA);
    dut_rx_xcvr.probe();

    dut_rx_os_xcvr = new("DUT RX_OS_XCVR", base_env.mng.master_sequencer, `DUT_AXI_XCVR_RX_OS_BA);
    dut_rx_os_xcvr.probe();

    dut_tx_xcvr = new("DUT TX_XCVR", base_env.mng.master_sequencer, `DUT_AXI_XCVR_TX_BA);
    dut_tx_xcvr.probe();

    dut_rx_ll = new("DUT RX_LINK_LAYER", base_env.mng.master_sequencer, `AXI_JESD_RX_BA, rx_link);
    dut_rx_ll.probe();

    dut_rx_os_ll = new("DUT RX_OS_LINK_LAYER", base_env.mng.master_sequencer, `AXI_JESD_RX_OS_BA, rx_os_link);
    dut_rx_os_ll.probe();

    dut_tx_ll = new("DUT TX_LINK_LAYER", base_env.mng.master_sequencer, `AXI_JESD_TX_BA, tx_link);
    dut_tx_ll.probe();

    `TH.`REF_CLK.inst.IF.set_clk_frq(.user_frequency(`REF_CLK_RATE*1000000));

    rx_device_clk = ex_rx_ll.calc_device_clk();
    tx_device_clk = ex_tx_ll.calc_device_clk();
    tx_link_clk = tx_device_clk * tx_link_clk_ratio;
    tx_os_device_clk = ex_tx_os_ll.calc_device_clk();

    `TH.`RX_DEVICE_CLK.inst.IF.set_clk_frq(rx_device_clk);
    `TH.`TX_DEVICE_CLK.inst.IF.set_clk_frq(tx_device_clk);
    `TH.`TX_LINK_CLK.inst.IF.set_clk_frq(tx_link_clk);
    `TH.`TX_OS_DEVICE_CLK.inst.IF.set_clk_frq(tx_os_device_clk);

    rx_sysref_clk = ex_rx_ll.calc_sysref_clk();
    tx_sysref_clk = ex_tx_ll.calc_sysref_clk();
    tx_os_sysref_clk = ex_tx_os_ll.calc_sysref_clk();

    // Common SYSREF clock frequency computation
    if (tx_sysref_clk >= rx_sysref_clk && `fmod(tx_sysref_clk, rx_sysref_clk) == 0) begin
      if (rx_sysref_clk >= tx_os_sysref_clk && `fmod(rx_sysref_clk, tx_os_sysref_clk) == 0) begin
        common_sysref_clk = tx_os_sysref_clk;
      end else if (rx_sysref_clk < tx_os_sysref_clk && `fmod(tx_os_sysref_clk, rx_sysref_clk) == 0) begin
        common_sysref_clk = rx_sysref_clk;
      end else begin
        `FATAL(("RX_SYSREF_CLK and TX_OS_SYSREF_CLK are not divisible!\n RX_SYSREF_CLK: %f\n TX_OS_SYSREF_CLK: %f\n", rx_sysref_clk, tx_os_sysref_clk));
      end
    end else if (tx_sysref_clk < rx_sysref_clk && `fmod(rx_sysref_clk, tx_sysref_clk) == 0) begin
      if (tx_sysref_clk >= tx_os_sysref_clk && `fmod(tx_sysref_clk, tx_os_sysref_clk) == 0) begin
        common_sysref_clk = tx_os_sysref_clk;
      end else if (tx_sysref_clk < tx_os_sysref_clk && `fmod(tx_os_sysref_clk, tx_sysref_clk) == 0) begin
        common_sysref_clk = tx_sysref_clk;
      end else begin
        `FATAL(("TX_SYSREF_CLK and TX_OS_SYSREF_CLK are not divisible!\n TX_SYSREF_CLK: %f\n TX_OS_SYSREF_CLK: %f\n", tx_sysref_clk, tx_os_sysref_clk));
      end
    end else begin
      `FATAL(("RX_SYSREF_CLK and TX_SYSREF_CLK are not divisible!\n RX_SYSREF_CLK: %f\n TX_SYSREF_CLK: %f\n", rx_sysref_clk, tx_sysref_clk));
    end

    `TH.`SYSREF_CLK.inst.IF.set_clk_frq(.user_frequency(common_sysref_clk));

    `TH.`REF_CLK.inst.IF.start_clock();
    `TH.`RX_DEVICE_CLK.inst.IF.start_clock();
    `TH.`TX_DEVICE_CLK.inst.IF.start_clock();
    `TH.`TX_LINK_CLK.inst.IF.start_clock();
    `TH.`TX_OS_DEVICE_CLK.inst.IF.start_clock();
    `TH.`SYSREF_CLK.inst.IF.start_clock();

    ex_rx_xcvr.setup_clocks(lane_rate,
                            `REF_CLK_RATE*1000000);

    ex_tx_xcvr.setup_clocks(lane_rate,
                            `REF_CLK_RATE*1000000);

    ex_tx_os_xcvr.setup_clocks(lane_rate,
                            `REF_CLK_RATE*1000000);

    dut_tx_xcvr.setup_clocks(lane_rate,
                            `REF_CLK_RATE*1000000, '{QPLL0, QPLL1});

    dut_rx_xcvr.setup_clocks(lane_rate,
                            `REF_CLK_RATE*1000000, '{CPLL});

    dut_rx_os_xcvr.setup_clocks(lane_rate,
                            `REF_CLK_RATE*1000000, '{CPLL});

    tx_tpl_test(.use_dds(0));
    rx_tpl_test(.use_dds (0));
    rx_os_tpl_test(.use_dds (0));

    base_env.stop();

    `TH.`REF_CLK.inst.IF.stop_clock();
    `TH.`RX_DEVICE_CLK.inst.IF.stop_clock();
    `TH.`TX_DEVICE_CLK.inst.IF.stop_clock();
    `TH.`TX_LINK_CLK.inst.IF.stop_clock();
    `TH.`TX_OS_DEVICE_CLK.inst.IF.stop_clock();
    `TH.`SYSREF_CLK.inst.IF.stop_clock();

    `INFO(("Test Done"), ADI_VERBOSITY_NONE);
    $finish();

  end

  task tx_tpl_test(int use_dds);
    for (int i = 0; i < `TX_JESD_M; i++) begin
      if (use_dds) begin
        // Select DDS as source
        tx_dac_api.set_channel_control_7(
          .channel(i),
          .dds_sel(4'h0));
        // Configure tone amplitude and frequency
        tx_dac_api.set_channel_control_1(
          .channel(i),
          .dds_scale_1(16'h0fff));
        tx_dac_api.set_channel_control_2(
          .channel(i),
          .dds_init_1(16'h0000),
          .dds_incr_1(16'h0100));
      end else begin
        // Set DMA as source for DAC TPL
        tx_dac_api.set_channel_control_7(
          .channel(i),
          .dds_sel(4'h2));
      end
    end

    for (int i = 0; i < `TX_JESD_M; i++) begin
      ex_adc_api.enable_channel(i);
    end

    tx_dac_api.reset(
      .ce_n(1'b0),
      .mmcm_rstn(1'b0),
      .rstn(1'b1));
    ex_adc_api.reset(
      .ce_n(1'b0),
      .mmcm_rstn(1'b0),
      .rstn(1'b1));

    if (use_dds) begin
      // Sync DDS cores
      tx_dac_api.set_common_control_1(
        .sync(1'b1),
        .ext_sync_arm(1'b0),
        .ext_sync_disarm(1'b0),
        .manual_sync_request(1'b0));
    end

    if (!use_dds) begin
      for (int i=0;i<2048*2 ;i=i+2) begin
        base_env.ddr.slave_sequencer.BackdoorWrite32(xil_axi_uint'(`DDR_BA+i*2),(((i+1)) << 16) | i ,15);
      end

      // Configure TX DMA
      tx_dmac_api.enable_dma();
      tx_dmac_api.set_flags(
        .cyclic(1'b0),
        .tlast(1'b1),
        .partial_reporting_en(1'b0));
      tx_dmac_api.set_lengths(
        .xfer_length_x(32'h00000FFF),
        .xfer_length_y(32'h0));
      tx_dmac_api.set_src_addr(`DDR_BA+32'h00000000);
      tx_dmac_api.transfer_start();

      // Configure EX RX DMA
      ex_rx_dmac_api.enable_dma();
      ex_rx_dmac_api.set_flags(
        .cyclic(1'b0),
        .tlast(1'b1),
        .partial_reporting_en(1'b0));
      ex_rx_dmac_api.set_lengths(
        .xfer_length_x(32'h000003DF),
        .xfer_length_y(32'h0));
      ex_rx_dmac_api.set_dest_addr(`DDR_BA+32'h00001000);
      ex_rx_dmac_api.transfer_start();

      // Wait until data propagates through the dma
      #5us;
    end

    // Bring-Up DUT TX Path
    tx_clkgen_api.enable_clkgen();

    dut_tx_xcvr.up();
    dut_tx_ll.link_up();

    ex_rx_xcvr.up();
    ex_rx_ll.link_up();

    dut_tx_ll.wait_link_up();
    ex_rx_ll.wait_link_up();

    // Move data around for a while
    #5us;

    if (~use_dds) begin
      check_captured_data(
        .address (`DDR_BA+'h00001000),
        .length (992),
        .step (1),
        .max_sample(2048)
      );
    end

    tx_dmac_api.disable_dma();
    ex_rx_dmac_api.disable_dma();

    ex_rx_xcvr.down();
    dut_tx_xcvr.down();
  endtask

  task rx_tpl_test(int use_dds);
    for (int i = 0; i < `RX_JESD_M; i++) begin
      if (use_dds) begin
        // Select DDS as source
        ex_dac_api.set_channel_control_7(
          .channel(i),
          .dds_sel(4'h0));
        // Configure tone amplitude and frequency
        ex_dac_api.set_channel_control_1(
          .channel(i),
          .dds_scale_1(16'h0fff));
        ex_dac_api.set_channel_control_2(
          .channel(i),
          .dds_init_1(16'h0000),
          .dds_incr_1(16'h0100));
      end else begin
        // Set DMA as source for DAC TPL
        ex_dac_api.set_channel_control_7(
          .channel(i),
          .dds_sel(4'h2));
      end
    end

    for (int i = 0; i < `RX_JESD_M; i++) begin
      rx_adc_api.enable_channel(i);
    end

    ex_dac_api.reset(
      .ce_n(1'b0),
      .mmcm_rstn(1'b0),
      .rstn(1'b1));
    rx_adc_api.reset(
      .ce_n(1'b0),
      .mmcm_rstn(1'b0),
      .rstn(1'b1));

    if (use_dds) begin
      // Sync DDS cores
      ex_dac_api.set_common_control_1(
        .sync(1'b1),
        .ext_sync_arm(1'b0),
        .ext_sync_disarm(1'b0),
        .manual_sync_request(1'b0));
    end

    if (!use_dds) begin
      for (int i=0;i<2048*2 ;i=i+2) begin
        base_env.ddr.slave_sequencer.BackdoorWrite32(xil_axi_uint'(`DDR_BA+i*2),(((i+1)) << 16) | i ,15);
      end

      // Configure EX TX DMA
      ex_tx_dmac_api.enable_dma();
      ex_tx_dmac_api.set_flags(
        .cyclic(1'b1),
        .tlast(1'b0),
        .partial_reporting_en(1'b0));
      ex_tx_dmac_api.set_lengths(
        .xfer_length_x(32'h00000FFF),
        .xfer_length_y(32'h0));
      ex_tx_dmac_api.set_src_addr(`DDR_BA+32'h00000000);
      ex_tx_dmac_api.transfer_start();

      // Configure RX DMA
      rx_dmac_api.enable_dma();
      rx_dmac_api.set_flags(
        .cyclic(1'b0),
        .tlast(1'b1),
        .partial_reporting_en(1'b0));
      rx_dmac_api.set_lengths(
        .xfer_length_x(32'h000003DF),
        .xfer_length_y(32'h0));
      rx_dmac_api.set_dest_addr(`DDR_BA+32'h00001000);
      rx_dmac_api.transfer_start();

      // Wait until data propagates through the dma
      #5us;
    end

    // Bring-Up DUT RX Path
    rx_clkgen_api.enable_clkgen();

    ex_tx_xcvr.up();
    ex_tx_ll.link_up();

    dut_rx_xcvr.up();
    dut_rx_ll.link_up();

    ex_tx_ll.wait_link_up();
    dut_rx_ll.wait_link_up();

    // Move data around for a while
    #5us;

    if (!use_dds) begin
      check_captured_data(
        .address (`DDR_BA+'h00001000),
        .length (992),
        .step (1),
        .max_sample(2048)
      );
    end

    ex_tx_dmac_api.disable_dma();
    rx_dmac_api.disable_dma();

    dut_rx_xcvr.down();
    ex_tx_xcvr.down();
  endtask

  task rx_os_tpl_test(int use_dds);
    for (int i = 0; i < `RX_OS_JESD_M; i++) begin
      if (use_dds) begin
        // Select DDS as source
        ex_dac_os_api.set_channel_control_7(
          .channel(i),
          .dds_sel(4'h0));
        // Configure tone amplitude and frequency
        ex_dac_os_api.set_channel_control_1(
          .channel(i),
          .dds_scale_1(16'h0fff));
        ex_dac_os_api.set_channel_control_2(
          .channel(i),
          .dds_init_1(16'h0000),
          .dds_incr_1(16'h0100));
      end else begin
        // Set DMA as source for DAC TPL
        ex_dac_os_api.set_channel_control_7(
          .channel(i),
          .dds_sel(4'h2));
      end
    end

    for (int i = 0; i < `RX_OS_JESD_M; i++) begin
      rx_os_adc_api.enable_channel(i);
    end

    ex_dac_os_api.reset(
      .ce_n(1'b0),
      .mmcm_rstn(1'b0),
      .rstn(1'b1));
    rx_os_adc_api.reset(
      .ce_n(1'b0),
      .mmcm_rstn(1'b0),
      .rstn(1'b1));

    if (use_dds) begin
      // Sync DDS cores
      ex_dac_os_api.set_common_control_1(
        .sync(1'b1),
        .ext_sync_arm(1'b0),
        .ext_sync_disarm(1'b0),
        .manual_sync_request(1'b0));
    end

    if (!use_dds) begin
      for (int i=0;i<2048*2 ;i=i+2) begin
        base_env.ddr.slave_sequencer.BackdoorWrite32(xil_axi_uint'(`DDR_BA+i*2),(((i+1)) << 16) | i ,15);
      end

      // Configure EX TX OS DMA
      ex_tx_os_dmac_api.enable_dma();
      ex_tx_os_dmac_api.set_flags(
        .cyclic(1'b1),
        .tlast(1'b0),
        .partial_reporting_en(1'b0));
      ex_tx_os_dmac_api.set_lengths(
        .xfer_length_x(32'h00000FFF),
        .xfer_length_y(32'h0));
      ex_tx_os_dmac_api.set_src_addr(`DDR_BA+32'h00000000);
      ex_tx_os_dmac_api.transfer_start();

      // Configure RX OBS DMA
      rx_os_dmac_api.enable_dma();
      rx_os_dmac_api.set_flags(
        .cyclic(1'b0),
        .tlast(1'b1),
        .partial_reporting_en(1'b0));
      rx_os_dmac_api.set_lengths(
        .xfer_length_x(32'h000003DF),
        .xfer_length_y(32'h0));
      rx_os_dmac_api.set_dest_addr(`DDR_BA+32'h00001000);
      rx_os_dmac_api.transfer_start();

      // Wait until data propagates through the dma
      #5us;
    end

    // Bring-Up DUT RX OBS Path
    rx_os_clkgen_api.enable_clkgen();

    ex_tx_os_xcvr.up();
    ex_tx_os_ll.link_up();

    dut_rx_os_xcvr.up();
    dut_rx_os_ll.link_up();

    ex_tx_os_ll.wait_link_up();
    dut_rx_os_ll.wait_link_up();

    // Move data around for a while
    #5us;

    if (!use_dds) begin
      check_captured_data(
        .address (`DDR_BA+'h00001000),
        .length (992),
        .step (1),
        .max_sample(2048)
      );
    end

    ex_tx_os_dmac_api.disable_dma();
    rx_os_dmac_api.disable_dma();

    ex_tx_os_xcvr.down();
    dut_rx_os_xcvr.down();
  endtask

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
        end
      end
    end
  endtask

endprogram
