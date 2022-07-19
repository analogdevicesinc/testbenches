// ***************************************************************************
// ***************************************************************************
// Copyright 2014 - 2018 (c) Analog Devices, Inc. All rights reserved.
//
// In this HDL repository, there are many different and unique modules, consisting
// of various HDL (Verilog or VHDL) components. The individual modules are
// developed independently, and may be accompanied by separate and unique license
// terms.
//
// The user should read each of these license terms, and understand the
// freedoms and responsabilities that he or she has by using this source/core.
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
//      https://github.com/analogdevicesinc/hdl/blob/master/LICENSE_ADIBSD
//      This will allow to generate bit files and not release the source code,
//      as long as it attaches to an ADI device.
//
// ***************************************************************************
// ***************************************************************************
//
//
//
`include "utils.svh"

import test_harness_env_pkg::*;
import adi_regmap_pkg::*;
import axi_vip_pkg::*;
import axi4stream_vip_pkg::*;
import logger_pkg::*;
import adi_regmap_dmac_pkg::*;
import adi_regmap_jesd_tx_pkg::*;
import adi_regmap_jesd_rx_pkg::*;
import adi_regmap_common_pkg::*;
import adi_regmap_dac_pkg::*;
import adi_regmap_adc_pkg::*;
import adi_regmap_tdd_pkg::*;
import adi_jesd204_pkg::*;
import adi_xcvr_pkg::*;


`define RX_DMA      32'h7c42_0000
`define RX_XCVR     32'h44a6_0000
`define TX_DMA      32'h7c43_0000
`define TX_XCVR     32'h44b6_0000
`define AXI_JESD_RX 32'h44a9_0000
`define ADC_TPL     32'h44a1_0000
`define DAC_TPL     32'h44b1_0000
`define AXI_JESD_TX 32'h44b9_0000
`define DDR_BASE    32'h8000_0000
`define RX_OFFLOAD  32'h7C45_0000
`define TX_OFFLOAD  32'h7C44_0000
`define TDD         32'h7C46_0000

program test_program;

  test_harness_env env;
  bit [31:0] val;

  jesd_link link;
  rx_link_layer rx_ll;
  tx_link_layer tx_ll;
  xcvr rx_xcvr;
  xcvr tx_xcvr;

  int use_dds = 1;
  bit [31:0] lane_rate_khz = `RX_LANE_RATE*1000000;
  longint unsigned lane_rate = lane_rate_khz*1000;

  initial begin
    //creating environment
    env = new(`TH.`SYS_CLK.inst.IF,
              `TH.`DMA_CLK.inst.IF,
              `TH.`DDR_CLK.inst.IF,
              `TH.`MNG_AXI.inst.IF,
              `TH.`DDR_AXI.inst.IF);

    #2ps;

    setLoggerVerbosity(6);
    env.start();

    link = new;
    link.set_L(`RX_JESD_L);
    link.set_M(`RX_JESD_M);
    link.set_F(`RX_JESD_F);
    link.set_S(`RX_JESD_S);
    link.set_K(`RX_JESD_K);
    link.set_N(`RX_JESD_NP);
    link.set_NP(`RX_JESD_NP);
    link.set_encoding(`JESD_MODE != "64B66B" ? enc8b10b : enc64b66b);
    link.set_lane_rate(lane_rate);

    rx_ll = new("RX_LINK_LAYER", env.mng, `AXI_JESD_RX, link);
    rx_ll.probe();

    tx_ll = new("TX_LINK_LAYER", env.mng, `AXI_JESD_TX, link);
    tx_ll.probe();

    rx_xcvr = new("RX_XCVR", env.mng, `RX_XCVR);
    rx_xcvr.probe();

    tx_xcvr = new("TX_XCVR", env.mng, `TX_XCVR);
    tx_xcvr.probe();

    `TH.`REF_CLK.inst.IF.set_clk_frq(.user_frequency(`REF_CLK_RATE*1000000));
    `TH.`DEVICE_CLK.inst.IF.set_clk_frq(.user_frequency(rx_ll.calc_device_clk()));
    `TH.`SYSREF_CLK.inst.IF.set_clk_frq(.user_frequency(rx_ll.calc_sysref_clk()));
    `TH.`DMA_CLK.inst.IF.set_clk_frq(.user_frequency(rx_ll.calc_device_clk()));

    `TH.`REF_CLK.inst.IF.start_clock;
    `TH.`DEVICE_CLK.inst.IF.start_clock;
    `TH.`SYSREF_CLK.inst.IF.start_clock;

    rx_xcvr.setup_clocks(lane_rate,
                         `REF_CLK_RATE*1000000);

    tx_xcvr.setup_clocks(lane_rate,
                         `REF_CLK_RATE*1000000);

    // =======================
    // JESD LINK TEST - DDS
    // =======================
    jesd_link_test(1);

    // =======================
    // JESD LINK TEST - DMA
    // =======================
    jesd_link_test(0);

    // =======================
    // JESD LINK TEST - DMA - RX/TX BYPASS
    // =======================
    jesd_link_test(0,1,1);
    //jesd_link_test(0,1,1);

    // =======================
    // JESD LINK TEST - DMA - DO -TDD
    // =======================
    jesd_link_test(0,0,0,1);

    // =======================
    // JESD LINK TEST - DDS - EXT_SYNC
    // =======================
    jesd_link_test_ext_sync(1);

    // =======================
    // JESD LINK TEST - DMA - EXT_SYNC
    // =======================
    jesd_link_test_ext_sync(0);

    `INFO(("======================="));
    `INFO(("      TB   DONE        "));
    `INFO(("======================="));
  end

  // -----------------
  //
  // -----------------
  task jesd_link_test(input use_dds = 1,
                      input rx_bypass = 0,
                      input tx_bypass = 0,
                      input tdd_enabled = 0);

    `INFO(("======================="));
    `INFO(("      JESD TEST        "+(use_dds ? "DDS" : "DMA")));
    `INFO(("======================="));

    // -----------------------
    // TX PHY INIT
    // -----------------------
    tx_xcvr.up();

    // -----------------------
    // Configure TPL
    // -----------------------
    for (int i = 0; i < `RX_JESD_M; i++) begin
      if (use_dds) begin
        // Select DDS as source
        env.mng.RegWrite32(`DAC_TPL + 'h40 * i + GetAddrs(DAC_CHANNEL_REG_CHAN_CNTRL_7),
                           `SET_DAC_CHANNEL_REG_CHAN_CNTRL_7_DAC_DDS_SEL(0));
        // Configure tone amplitude and frequency
        env.mng.RegWrite32(`DAC_TPL + 'h40 * i + GetAddrs(DAC_CHANNEL_REG_CHAN_CNTRL_1),
                           `SET_DAC_CHANNEL_REG_CHAN_CNTRL_1_DDS_SCALE_1(16'h0fff));
        env.mng.RegWrite32(`DAC_TPL + 'h40 * i + GetAddrs(DAC_CHANNEL_REG_CHAN_CNTRL_2),
                           `SET_DAC_CHANNEL_REG_CHAN_CNTRL_2_DDS_INCR_1(16'h0100));
      end else begin
        // Set DMA as source for DAC TPL
        env.mng.RegWrite32(`DAC_TPL + 'h40 * i + GetAddrs(DAC_CHANNEL_REG_CHAN_CNTRL_7),
                           `SET_DAC_CHANNEL_REG_CHAN_CNTRL_7_DAC_DDS_SEL(2));
      end
    end

    env.mng.RegWrite32(`DAC_TPL + GetAddrs(DAC_COMMON_REG_RSTN),
                       `SET_DAC_COMMON_REG_RSTN_RSTN(1));

    if (use_dds) begin
      // Sync DDS cores
      env.mng.RegWrite32(`DAC_TPL + GetAddrs(DAC_COMMON_REG_CNTRL_1),
                         `SET_DAC_COMMON_REG_CNTRL_1_SYNC(1));
    end

    //
    // Configure Offload
    //
    // Transfer length
    //env.mng.RegWrite32(`RX_OFFLOAD+'h1C, 'h1000/64);
    // Set One shot and bypass
    env.mng.RegWrite32(`RX_OFFLOAD+'h88, 2 | rx_bypass);

    // Set Tx offload bypass
    // for TDD set single shot
    env.mng.RegWrite32(`TX_OFFLOAD+'h88, 2*tdd_enabled | tx_bypass);
    // Sync option set for hw sync
    env.mng.RegWrite32(`TX_OFFLOAD+'h104, tdd_enabled);
    env.mng.RegWrite32(`RX_OFFLOAD+'h104, tdd_enabled);

    if (tdd_enabled) begin
      env.mng.RegWrite32(`TDD+GetAddrs(TDD_CNTRL_REG_TDD_FRAME_LENGTH),
          `SET_TDD_CNTRL_REG_TDD_FRAME_LENGTH_TDD_FRAME_LENGTH(2048));

      env.mng.RegWrite32(`TDD+GetAddrs(TDD_CNTRL_REG_TDD_TX_DP_ON_1),
          `SET_TDD_CNTRL_REG_TDD_TX_DP_ON_1_TDD_TX_DP_ON_1(0));

      env.mng.RegWrite32(`TDD+GetAddrs(TDD_CNTRL_REG_TDD_TX_DP_OFF_1),
          `SET_TDD_CNTRL_REG_TDD_TX_DP_OFF_1_TDD_TX_DP_OFF_1(10));

      // Trigger RX capture later due rountrip latency ~96 cycles
      env.mng.RegWrite32(`TDD+GetAddrs(TDD_CNTRL_REG_TDD_RX_DP_ON_1),
          `SET_TDD_CNTRL_REG_TDD_RX_DP_ON_1_TDD_RX_DP_ON_1(96));

      env.mng.RegWrite32(`TDD+GetAddrs(TDD_CNTRL_REG_TDD_RX_DP_OFF_1),
          `SET_TDD_CNTRL_REG_TDD_RX_DP_OFF_1_TDD_RX_DP_OFF_1(106));

      env.mng.RegWrite32(`TDD+GetAddrs(TDD_CNTRL_REG_TDD_CONTROL_0),
          `SET_TDD_CNTRL_REG_TDD_CONTROL_0_TDD_GATED_TX_DMAPATH(1) |
          `SET_TDD_CNTRL_REG_TDD_CONTROL_0_TDD_GATED_RX_DMAPATH(1) |
          `SET_TDD_CNTRL_REG_TDD_CONTROL_0_TDD_ENABLE(1));
    end

    if (~use_dds) begin

      // Init test data
      // .step (1),
      // .max_sample(2048)
      for (int i=0;i<2048*2 ;i=i+2) begin
        if (`TX_JESD_NP == 12) begin
          env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+i*2,(((i+1)) << 20) | (i << 4) ,15);
        end else begin
          env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+i*2,(((i+1)) << 16) | i ,15);
        end
      end
      // Configure TX DMA
      env.mng.RegWrite32(`TX_DMA+GetAddrs(DMAC_CONTROL),
                         `SET_DMAC_CONTROL_ENABLE(1));
      env.mng.RegWrite32(`TX_DMA+GetAddrs(DMAC_FLAGS),
                         `SET_DMAC_FLAGS_CYCLIC(tx_bypass) |
                         `SET_DMAC_FLAGS_TLAST(1));
      env.mng.RegWrite32(`TX_DMA+GetAddrs(DMAC_X_LENGTH),
                         `SET_DMAC_X_LENGTH_X_LENGTH(32'h00001FFF));
      env.mng.RegWrite32(`TX_DMA+GetAddrs(DMAC_SRC_ADDRESS),
                         `SET_DMAC_SRC_ADDRESS_SRC_ADDRESS(`DDR_BASE+32'h00000000));
      env.mng.RegWrite32(`TX_DMA+GetAddrs(DMAC_TRANSFER_SUBMIT),
                         `SET_DMAC_TRANSFER_SUBMIT_TRANSFER_SUBMIT(1));
      // Configure RX DMA
      env.mng.RegWrite32(`RX_DMA+GetAddrs(DMAC_CONTROL),
                         `SET_DMAC_CONTROL_ENABLE(1));
      env.mng.RegWrite32(`RX_DMA+GetAddrs(DMAC_FLAGS),
                         `SET_DMAC_FLAGS_TLAST(1));
      env.mng.RegWrite32(`RX_DMA+GetAddrs(DMAC_X_LENGTH),
                         `SET_DMAC_X_LENGTH_X_LENGTH(32'h000007FF));
      env.mng.RegWrite32(`RX_DMA+GetAddrs(DMAC_DEST_ADDRESS),
                         `SET_DMAC_DEST_ADDRESS_DEST_ADDRESS(`DDR_BASE+32'h00002000));
      env.mng.RegWrite32(`RX_DMA+GetAddrs(DMAC_TRANSFER_SUBMIT),
                         `SET_DMAC_TRANSFER_SUBMIT_TRANSFER_SUBMIT(1));
      // Wait until data propagates through the dma+offload
      #5us;
    end

    tx_ll.link_up();

    // -----------------------
    // RX PHY INIT
    // -----------------------
    rx_xcvr.up();

    // -----------------------
    // Configure ADC TPL
    // -----------------------
    for (int i = 0; i < `RX_JESD_M; i++) begin
      env.mng.RegWrite32(`ADC_TPL + 'h40 * i + GetAddrs(ADC_CHANNEL_REG_CHAN_CNTRL),
                         `SET_ADC_CHANNEL_REG_CHAN_CNTRL_ENABLE(1));
    end

    env.mng.RegWrite32(`ADC_TPL + GetAddrs(ADC_COMMON_REG_RSTN),
                       `SET_ADC_COMMON_REG_RSTN_RSTN(1));

    rx_ll.link_up();

    rx_ll.wait_link_up();
    tx_ll.wait_link_up();

    // Move data around for a while
    #5us;

    if (~use_dds) begin
      check_captured_data(
        .address (`DDR_BASE+'h00002000),
        .length (1024),
        .step (1),
        .max_sample(4096)
      );
    end
    rx_ll.link_down();
    tx_ll.link_down();

    env.mng.RegWrite32(`ADC_TPL + GetAddrs(ADC_COMMON_REG_RSTN),
                       `SET_ADC_COMMON_REG_RSTN_RSTN(0));
    env.mng.RegWrite32(`DAC_TPL + GetAddrs(DAC_COMMON_REG_RSTN),
                       `SET_DAC_COMMON_REG_RSTN_RSTN(0));

    rx_xcvr.down();
    tx_xcvr.down();

    `INFO(("======================="));
    `INFO(("  JESD LINK TEST DONE  "));
    `INFO(("======================="));

  endtask : jesd_link_test

  // -----------------
  //
  // -----------------
  task jesd_link_test_ext_sync(input use_dds = 1);

    `INFO(("======================="));
    `INFO(("      JESD TEST  EXT SYNC      "+(use_dds ? "DDS" : "DMA")));
    `INFO(("======================="));
    // -----------------------
    // TX PHY INIT
    // -----------------------
    tx_xcvr.up();

    // -----------------------
    // Configure TPL
    // -----------------------
    for (int i = 0; i < `RX_JESD_M; i++) begin
      if (use_dds) begin
        // Select DDS as source
        env.mng.RegWrite32(`DAC_TPL + 'h40 * i + GetAddrs(DAC_CHANNEL_REG_CHAN_CNTRL_7),
                           `SET_DAC_CHANNEL_REG_CHAN_CNTRL_7_DAC_DDS_SEL(0));
        // Configure tone amplitude and frequency
        env.mng.RegWrite32(`DAC_TPL + 'h40 * i + GetAddrs(DAC_CHANNEL_REG_CHAN_CNTRL_1),
                           `SET_DAC_CHANNEL_REG_CHAN_CNTRL_1_DDS_SCALE_1(16'h0fff));
        env.mng.RegWrite32(`DAC_TPL + 'h40 * i + GetAddrs(DAC_CHANNEL_REG_CHAN_CNTRL_2),
                           `SET_DAC_CHANNEL_REG_CHAN_CNTRL_2_DDS_INCR_1(16'h0100));
      end else begin
        // Set DMA as source for DAC TPL
        env.mng.RegWrite32(`DAC_TPL + 'h40 * i + GetAddrs(DAC_CHANNEL_REG_CHAN_CNTRL_7),
                           `SET_DAC_CHANNEL_REG_CHAN_CNTRL_7_DAC_DDS_SEL(2));
      end
    end

    env.mng.RegWrite32(`DAC_TPL + GetAddrs(DAC_COMMON_REG_RSTN),
                       `SET_DAC_COMMON_REG_RSTN_RSTN(1));

    if (use_dds) begin
      // Sync DDS cores
      env.mng.RegWrite32(`DAC_TPL + GetAddrs(DAC_COMMON_REG_CNTRL_1),
                         `SET_DAC_COMMON_REG_CNTRL_1_SYNC(1));
    end

    //
    // Configure Offload
    //
    // Transfer length
    env.mng.RegWrite32(`RX_OFFLOAD+'h1C, 'h1000/64);
    // One shot
    env.mng.RegWrite32(`RX_OFFLOAD+'h88, 2);

    tx_ll.link_up();

    // -----------------------
    // RX PHY INIT
    // -----------------------
    rx_xcvr.up();

    // -----------------------
    // Configure ADC TPL
    // -----------------------
    for (int i = 0; i < `RX_JESD_M; i++) begin
      env.mng.RegWrite32(`ADC_TPL + 'h40 * i + GetAddrs(ADC_CHANNEL_REG_CHAN_CNTRL),
                         `SET_ADC_CHANNEL_REG_CHAN_CNTRL_ENABLE(1));
    end

    env.mng.RegWrite32(`ADC_TPL + GetAddrs(ADC_COMMON_REG_RSTN),
                       `SET_ADC_COMMON_REG_RSTN_RSTN(1));

    rx_ll.link_up();

    rx_ll.wait_link_up();
    tx_ll.wait_link_up();

    // Move data around for a while
    #5us;

    env.mng.RegWrite32(`DAC_TPL + GetAddrs(DAC_COMMON_REG_CNTRL_1),2);
    env.mng.RegWrite32(`ADC_TPL + 'h48,2);
    #1us;
    // Check if armed
    env.mng.RegReadVerify32(`DAC_TPL + GetAddrs(DAC_COMMON_REG_SYNC_STATUS),
                            `SET_DAC_COMMON_REG_SYNC_STATUS_DAC_SYNC_STATUS(1));
    env.mng.RegReadVerify32(`ADC_TPL + GetAddrs(ADC_COMMON_REG_SYNC_STATUS),
                            `SET_ADC_COMMON_REG_SYNC_STATUS_ADC_SYNC(1));
    #1us;

    if (~use_dds) begin

      // Init test data
      // .step (1),
      // .max_sample(2048)
      for (int i=0;i<2048*2 ;i=i+2) begin
        if (`TX_JESD_NP == 12) begin
          env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+i*2,(((i+1)) << 20) | (i << 4) ,15);
        end else begin
          env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+i*2,(((i+1)) << 16) | i ,15);
        end
      end

      // Configure TX DMA
      env.mng.RegWrite32(`TX_DMA+GetAddrs(DMAC_CONTROL),
                         `SET_DMAC_CONTROL_ENABLE(1));
      env.mng.RegWrite32(`TX_DMA+GetAddrs(DMAC_FLAGS),
                         `SET_DMAC_FLAGS_TLAST(1));
      env.mng.RegWrite32(`TX_DMA+GetAddrs(DMAC_X_LENGTH),
                         `SET_DMAC_X_LENGTH_X_LENGTH(32'h00000FFF));
      env.mng.RegWrite32(`TX_DMA+GetAddrs(DMAC_SRC_ADDRESS),
                         `SET_DMAC_SRC_ADDRESS_SRC_ADDRESS(`DDR_BASE+32'h00000000));
      env.mng.RegWrite32(`TX_DMA+GetAddrs(DMAC_TRANSFER_SUBMIT),
                         `SET_DMAC_TRANSFER_SUBMIT_TRANSFER_SUBMIT(1));
      // Configure RX DMA
      env.mng.RegWrite32(`RX_DMA+GetAddrs(DMAC_CONTROL),
                         `SET_DMAC_CONTROL_ENABLE(1));
      env.mng.RegWrite32(`RX_DMA+GetAddrs(DMAC_FLAGS),
                         `SET_DMAC_FLAGS_TLAST(1));
      env.mng.RegWrite32(`RX_DMA+GetAddrs(DMAC_X_LENGTH),
                         `SET_DMAC_X_LENGTH_X_LENGTH(32'h000003DF));
      env.mng.RegWrite32(`RX_DMA+GetAddrs(DMAC_DEST_ADDRESS),
                         `SET_DMAC_DEST_ADDRESS_DEST_ADDRESS(`DDR_BASE+32'h00002000));
      env.mng.RegWrite32(`RX_DMA+GetAddrs(DMAC_TRANSFER_SUBMIT),
                         `SET_DMAC_TRANSFER_SUBMIT_TRANSFER_SUBMIT(1));
      // Wait until data propagates through the dma+offload
      #5us;
    end

    // Trigger external sync
    @(posedge system_tb.device_clk);
    system_tb.ext_sync <= 1'b1;
    @(posedge system_tb.device_clk);
    system_tb.ext_sync <= 1'b0;

    #1us;
    // Check if trigger captured
    env.mng.RegReadVerify32(`DAC_TPL + GetAddrs(DAC_COMMON_REG_SYNC_STATUS),
                            `SET_DAC_COMMON_REG_SYNC_STATUS_DAC_SYNC_STATUS(0));
    env.mng.RegReadVerify32(`ADC_TPL + GetAddrs(ADC_COMMON_REG_SYNC_STATUS),
                            `SET_ADC_COMMON_REG_SYNC_STATUS_ADC_SYNC(0));
    #5us;

    rx_ll.link_down();
    tx_ll.link_down();

    env.mng.RegWrite32(`ADC_TPL + GetAddrs(ADC_COMMON_REG_RSTN),
                       `SET_ADC_COMMON_REG_RSTN_RSTN(0));
    env.mng.RegWrite32(`DAC_TPL + GetAddrs(DAC_COMMON_REG_RSTN),
                       `SET_DAC_COMMON_REG_RSTN_RSTN(0));

    rx_xcvr.down();
    tx_xcvr.down();

    `INFO(("======================="));
    `INFO(("  JESD LINK TEST DONE  "));
    `INFO(("======================="));

  endtask : jesd_link_test_ext_sync

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
      captured_word = env.ddr_axi_agent.mem_model.backdoor_memory_read_4byte(current_address);
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
