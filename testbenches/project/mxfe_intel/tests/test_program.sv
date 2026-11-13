// ***************************************************************************
// ***************************************************************************
// Copyright (C) 2026 Analog Devices, Inc. All rights reserved.
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

import test_harness_intel_env_pkg::*;
import adi_avmm_agent_pkg::*;
import adi_regmap_pkg::*;
import logger_pkg::*;
import adi_regmap_dmac_pkg::*;
import adi_regmap_jesd_tx_pkg::*;
import adi_regmap_jesd_rx_pkg::*;
import adi_regmap_common_pkg::*;
import adi_regmap_dac_pkg::*;
import adi_regmap_adc_pkg::*;
import adi_regmap_xcvr_pkg::*;
import adi_jesd204_pkg::*;

// program is not supported by Intel's QuestaSim, use module instead
module test_program;

  timeunit 1ns;
  timeprecision 1ps;

  test_harness_intel_env base_env;

  adi_avmm_master_agent mng;
  adi_avmm_slave_mem_agent ddr;

  jesd_link link;
  rx_link_layer rx_ll;
  tx_link_layer tx_ll;

  bit [31:0] lane_rate_khz = `RX_LANE_RATE*1000000;
  longint unsigned lane_rate = lane_rate_khz*1000;

  initial begin

    base_env = new(
      .name("Base Environment"),
      .sys_clk_vip_if(`TH.`SYS_CLK.`SYS_CLK.IF.vif),
      .dma_clk_vip_if(`TH.`DMA_CLK.`DMA_CLK.IF.vif),
      .sys_rst_vip_if(`TH.`SYS_RST.`SYS_RST.IF.vif));

    mng = new("", `TH.`MNG_AVMM.`MNG_AVMM.IF.vif);
    ddr = new("", `TH.`DDR_AVMM.`DDR_AVMM.IF.vif);

    `LINK(mng, base_env, mng)
    `LINK(ddr, base_env, ddr)

    setLoggerVerbosity(ADI_VERBOSITY_NONE);

    // Leave time for the GTS reset sequence and calibration
    base_env.simulation_watchdog.update_timer(10**7);

    base_env.start();
    base_env.sys_reset();

    // As the a5e software does with a GPIO, once the clocks are running
    system_tb.refclk_ready <= 1'b1;

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

    rx_ll = new("RX_LINK_LAYER", base_env.mng.master_sequencer, `AXI_JESD_RX_BA, link);
    rx_ll.probe();

    tx_ll = new("TX_LINK_LAYER", base_env.mng.master_sequencer, `AXI_JESD_TX_BA, link);
    tx_ll.probe();

    // The device and SYSREF clock sources are generated with fixed rates
    if (rx_ll.calc_device_clk() != `DEVICE_CLK_RATE*1000000) begin
      `ERROR(("DEVICE_CLK_RATE %0d MHz does not match the link, expected %0d Hz",
        `DEVICE_CLK_RATE, rx_ll.calc_device_clk()));
    end
    void'(rx_ll.calc_sysref_clk());

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

    base_env.stop();

    `INFO(("Test Done"), ADI_VERBOSITY_MEDIUM);
    $finish();

  end

  task xcvr_up(input bit [31:0] base_address);

    bit [31:0] val;
    int timeout = 1000;

    base_env.mng.master_sequencer.RegWrite32(base_address + GetAddrs(XCVR_RESETN),
                       `SET_XCVR_RESETN_RESETN(1));
    // wait until the PHY completes the reset handshake
    do begin
      #1us;
      base_env.mng.master_sequencer.RegRead32(base_address + GetAddrs(XCVR_STATUS), val);
      timeout--;
    end while (`GET_XCVR_STATUS_STATUS(val) == 0 && timeout > 0);

    if (timeout == 0) begin
      `ERROR(("XCVR at 0x%h status: 0", base_address));
    end
  endtask : xcvr_up

  task jesd_link_test(input use_dds = 1,
                      input rx_bypass = 0,
                      input tx_bypass = 0);

    `INFO(("======================="), ADI_VERBOSITY_LOW);
    `INFO(("      JESD TEST        "+(use_dds ? "DDS" : "DMA")), ADI_VERBOSITY_LOW);
    `INFO(("======================="), ADI_VERBOSITY_LOW);

    // -----------------------
    // TX PHY INIT
    // -----------------------
    xcvr_up(`TX_XCVR_BA);

    // -----------------------
    // Configure TPL
    // -----------------------
    for (int i = 0; i < `RX_JESD_M; i++) begin
      if (use_dds) begin
        // Select DDS as source
        base_env.mng.master_sequencer.RegWrite32(`DAC_TPL_BA + 'h40 * i + GetAddrs(DAC_CHANNEL_REG_CHAN_CNTRL_7),
                           `SET_DAC_CHANNEL_REG_CHAN_CNTRL_7_DAC_DDS_SEL(0));
        // Configure tone amplitude and frequency
        base_env.mng.master_sequencer.RegWrite32(`DAC_TPL_BA + 'h40 * i + GetAddrs(DAC_CHANNEL_REG_CHAN_CNTRL_1),
                           `SET_DAC_CHANNEL_REG_CHAN_CNTRL_1_DDS_SCALE_1(16'h0fff));
        base_env.mng.master_sequencer.RegWrite32(`DAC_TPL_BA + 'h40 * i + GetAddrs(DAC_CHANNEL_REG_CHAN_CNTRL_2),
                           `SET_DAC_CHANNEL_REG_CHAN_CNTRL_2_DDS_INCR_1(16'h0100));
      end else begin
        // Set DMA as source for DAC TPL
        base_env.mng.master_sequencer.RegWrite32(`DAC_TPL_BA + 'h40 * i + GetAddrs(DAC_CHANNEL_REG_CHAN_CNTRL_7),
                           `SET_DAC_CHANNEL_REG_CHAN_CNTRL_7_DAC_DDS_SEL(2));
      end
    end

    base_env.mng.master_sequencer.RegWrite32(`DAC_TPL_BA + GetAddrs(DAC_COMMON_REG_RSTN),
                       `SET_DAC_COMMON_REG_RSTN_RSTN(1));

    if (use_dds) begin
      // Sync DDS cores
      base_env.mng.master_sequencer.RegWrite32(`DAC_TPL_BA + GetAddrs(DAC_COMMON_REG_CNTRL_1),
                         `SET_DAC_COMMON_REG_CNTRL_1_SYNC(1));
    end

    //
    // Configure Offload
    //
    // Set One shot and bypass
    base_env.mng.master_sequencer.RegWrite32(`RX_OFFLOAD_BA+'h88, 2 | rx_bypass);

    // Set Tx offload bypass
    base_env.mng.master_sequencer.RegWrite32(`TX_OFFLOAD_BA+'h88, tx_bypass);

    if (~use_dds) begin

      // Init test data
      // .step (1),
      // .max_sample(2048)
      for (int i=0;i<2048*2 ;i=i+2) begin
        base_env.ddr.slave_sequencer.BackdoorWrite32(`DDR_BA+i*2,(((i+1)) << 16) | i ,15);
      end
      // Configure TX DMA
      base_env.mng.master_sequencer.RegWrite32(`TX_DMA_BA+GetAddrs(DMAC_CONTROL),
                         `SET_DMAC_CONTROL_ENABLE(1));
      base_env.mng.master_sequencer.RegWrite32(`TX_DMA_BA+GetAddrs(DMAC_FLAGS),
                         `SET_DMAC_FLAGS_CYCLIC(tx_bypass) |
                         `SET_DMAC_FLAGS_TLAST(1));
      base_env.mng.master_sequencer.RegWrite32(`TX_DMA_BA+GetAddrs(DMAC_X_LENGTH),
                         `SET_DMAC_X_LENGTH_X_LENGTH(32'h00001FFF));
      base_env.mng.master_sequencer.RegWrite32(`TX_DMA_BA+GetAddrs(DMAC_SRC_ADDRESS),
                         `SET_DMAC_SRC_ADDRESS_SRC_ADDRESS(`DDR_BA+32'h00000000));
      base_env.mng.master_sequencer.RegWrite32(`TX_DMA_BA+GetAddrs(DMAC_TRANSFER_SUBMIT),
                         `SET_DMAC_TRANSFER_SUBMIT_TRANSFER_SUBMIT(1));
      // Configure RX DMA
      base_env.mng.master_sequencer.RegWrite32(`RX_DMA_BA+GetAddrs(DMAC_CONTROL),
                         `SET_DMAC_CONTROL_ENABLE(1));
      base_env.mng.master_sequencer.RegWrite32(`RX_DMA_BA+GetAddrs(DMAC_FLAGS),
                         `SET_DMAC_FLAGS_TLAST(1));
      base_env.mng.master_sequencer.RegWrite32(`RX_DMA_BA+GetAddrs(DMAC_X_LENGTH),
                         `SET_DMAC_X_LENGTH_X_LENGTH(32'h000007FF));
      base_env.mng.master_sequencer.RegWrite32(`RX_DMA_BA+GetAddrs(DMAC_DEST_ADDRESS),
                         `SET_DMAC_DEST_ADDRESS_DEST_ADDRESS(`DDR_BA+32'h00002000));
      base_env.mng.master_sequencer.RegWrite32(`RX_DMA_BA+GetAddrs(DMAC_TRANSFER_SUBMIT),
                         `SET_DMAC_TRANSFER_SUBMIT_TRANSFER_SUBMIT(1));
      // Wait until data propagates through the dma+offload
      #5us;
    end

    tx_ll.link_up();

    // -----------------------
    // RX PHY INIT
    // -----------------------
    xcvr_up(`RX_XCVR_BA);

    // -----------------------
    // Configure ADC TPL
    // -----------------------
    for (int i = 0; i < `RX_JESD_M; i++) begin
      base_env.mng.master_sequencer.RegWrite32(`ADC_TPL_BA + 'h40 * i + GetAddrs(ADC_CHANNEL_REG_CHAN_CNTRL),
                         `SET_ADC_CHANNEL_REG_CHAN_CNTRL_ENABLE(1));
    end

    base_env.mng.master_sequencer.RegWrite32(`ADC_TPL_BA + GetAddrs(ADC_COMMON_REG_RSTN),
                       `SET_ADC_COMMON_REG_RSTN_RSTN(1));

    rx_ll.link_up();

    rx_ll.wait_link_up();
    tx_ll.wait_link_up();

    // Move data around for a while
    #5us;

    if (~use_dds) begin
      check_captured_data(
        .address (`DDR_BA+'h00002000),
        .length (1024),
        .step (1),
        .max_sample(4096)
      );
    end

    rx_ll.link_down();
    tx_ll.link_down();

    base_env.mng.master_sequencer.RegWrite32(`ADC_TPL_BA + GetAddrs(ADC_COMMON_REG_RSTN),
                       `SET_ADC_COMMON_REG_RSTN_RSTN(0));
    base_env.mng.master_sequencer.RegWrite32(`DAC_TPL_BA + GetAddrs(DAC_COMMON_REG_RSTN),
                       `SET_DAC_COMMON_REG_RSTN_RSTN(0));

    base_env.mng.master_sequencer.RegWrite32(`RX_XCVR_BA + GetAddrs(XCVR_RESETN),
                       `SET_XCVR_RESETN_RESETN(0));
    base_env.mng.master_sequencer.RegWrite32(`TX_XCVR_BA + GetAddrs(XCVR_RESETN),
                       `SET_XCVR_RESETN_RESETN(0));

    `INFO(("======================="), ADI_VERBOSITY_LOW);
    `INFO(("  JESD LINK TEST DONE  "), ADI_VERBOSITY_LOW);
    `INFO(("======================="), ADI_VERBOSITY_LOW);

  endtask : jesd_link_test

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
        end
      end

    end
  endtask

endmodule
