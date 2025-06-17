// ***************************************************************************
// ***************************************************************************
// Copyright (C) 2014-2025 Analog Devices, Inc. All rights reserved.
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
import adi_regmap_jesd_tx_pkg::*;
import adi_regmap_jesd_rx_pkg::*;
import adi_regmap_common_pkg::*;
import adi_regmap_dac_pkg::*;
import adi_regmap_adc_pkg::*;
import adi_regmap_xcvr_pkg::*;
import adi_jesd204_pkg::*;
import adi_xcvr_pkg::*;

import `PKGIFY(test_harness, mng_axi_vip)::*;
import `PKGIFY(test_harness, ddr_axi_vip)::*;

`define MODE_8B10B 1
`define MODE_64B66B 2

`define PRBS_OFF 4'b0000
`define PRBS_7   4'b0001
`define PRBS_9   4'b0010
`define PRBS_15  4'b0011
`define PRBS_23  4'b0100
`define PRBS_31  4'b0101

program test_program;

  timeunit 1ns;
  timeprecision 1ps;

  test_harness_env #(`AXI_VIP_PARAMS(test_harness, mng_axi_vip), `AXI_VIP_PARAMS(test_harness, ddr_axi_vip)) base_env;
  bit [31:0] val;

  jesd_link link;
  rx_link_layer rx_ll;
  tx_link_layer tx_ll;
  xcvr rx_xcvr;
  xcvr tx_xcvr;

  int use_dds = 1;
  bit [31:0] lane_rate_khz = `LANE_RATE*1000000;
  longint unsigned lane_rate = lane_rate_khz*1000;

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

    link = new;
    link.set_L(`JESD_L);
    link.set_M(`JESD_M);
    link.set_F(`JESD_F);
    link.set_S(`JESD_S);
    link.set_K(`JESD_K);
    link.set_N(`JESD_NP);
    link.set_NP(`JESD_NP);
    link.set_encoding(`LINK_MODE == `MODE_8B10B ? enc8b10b : enc64b66b);
    link.set_lane_rate(lane_rate);

    rx_ll = new("RX_LINK_LAYER", base_env.mng.sequencer, `AXI_JESD_RX_BA, link);
    rx_ll.probe();

    tx_ll = new("TX_LINK_LAYER", base_env.mng.sequencer, `AXI_JESD_TX_BA, link);
    tx_ll.probe();

    rx_xcvr = new("RX_XCVR", base_env.mng.sequencer, `ADC_XCVR_BA);
    rx_xcvr.probe();

    tx_xcvr = new("TX_XCVR", base_env.mng.sequencer, `DAC_XCVR_BA);
    tx_xcvr.probe();

    `TH.`REF_CLK.inst.IF.set_clk_frq(.user_frequency(`REF_CLK_RATE*1000000));
    `TH.`DEVICE_CLK.inst.IF.set_clk_frq(.user_frequency(rx_ll.calc_device_clk()));
    `TH.`SYSREF_CLK.inst.IF.set_clk_frq(.user_frequency(rx_ll.calc_sysref_clk()));

    `TH.`REF_CLK.inst.IF.start_clock();
    `TH.`DEVICE_CLK.inst.IF.start_clock();
    `TH.`SYSREF_CLK.inst.IF.start_clock();

    rx_xcvr.setup_clocks(lane_rate,
                         `REF_CLK_RATE*1000000);

    tx_xcvr.setup_clocks(lane_rate,
                         `REF_CLK_RATE*1000000);

    // =======================
    // PRBS TEST
    // =======================
    prbs_test();

    // =======================
    // JESD LINK TEST
    // =======================
    jesd_link_test();

    // Check link restart counter
    base_env.mng.sequencer.RegReadVerify32(`AXI_JESD_RX_BA + 'h2c4, 1);

    // =======================
    // TPL SYNC control test
    // =======================
    arm_disarm_test();

    base_env.stop();
    `TH.`REF_CLK.inst.IF.stop_clock();
    `TH.`DEVICE_CLK.inst.IF.stop_clock();
    `TH.`SYSREF_CLK.inst.IF.stop_clock();

    `INFO(("Test bench done!"), ADI_VERBOSITY_NONE);
    $finish();

  end

  // -----------------
  //
  // -----------------
  task jesd_link_test();

    `INFO(("======================="), ADI_VERBOSITY_LOW);
    `INFO(("      JESD TEST        "), ADI_VERBOSITY_LOW);
    `INFO(("======================="), ADI_VERBOSITY_LOW);
    // -----------------------
    // TX PHY INIT
    // -----------------------
    tx_xcvr.up();

    // -----------------------
    // Configure TPL
    // -----------------------
    for (int i = 0; i < `JESD_M; i++) begin
      if (use_dds) begin
        // Select DDS as source
        base_env.mng.sequencer.RegWrite32(`DAC_TPL_BA + 'h40 * i + GetAddrs(DAC_CHANNEL_REG_CHAN_CNTRL_7),
                           `SET_DAC_CHANNEL_REG_CHAN_CNTRL_7_DAC_DDS_SEL(0));
        // Configure tone amplitude and frequency
        base_env.mng.sequencer.RegWrite32(`DAC_TPL_BA + 'h40 * i + GetAddrs(DAC_CHANNEL_REG_CHAN_CNTRL_1),
                           `SET_DAC_CHANNEL_REG_CHAN_CNTRL_1_DDS_SCALE_1(16'h0fff));
        base_env.mng.sequencer.RegWrite32(`DAC_TPL_BA + 'h40 * i + GetAddrs(DAC_CHANNEL_REG_CHAN_CNTRL_2),
                           `SET_DAC_CHANNEL_REG_CHAN_CNTRL_2_DDS_INCR_1(16'h0100));
      end else begin
        // Set DMA as source for DAC TPL
        base_env.mng.sequencer.RegWrite32(`DAC_TPL_BA + 'h40 * i + GetAddrs(DAC_CHANNEL_REG_CHAN_CNTRL_7),
                           `SET_DAC_CHANNEL_REG_CHAN_CNTRL_7_DAC_DDS_SEL(2));
      end
    end

    base_env.mng.sequencer.RegWrite32(`DAC_TPL_BA + GetAddrs(DAC_COMMON_REG_RSTN),
                       `SET_DAC_COMMON_REG_RSTN_RSTN(1));

    if (use_dds) begin
      // Sync DDS cores
      base_env.mng.sequencer.RegWrite32(`DAC_TPL_BA + GetAddrs(DAC_COMMON_REG_CNTRL_1),
                         `SET_DAC_COMMON_REG_CNTRL_1_SYNC(1));
    end

    tx_ll.link_up();

    // -----------------------
    // RX PHY INIT
    // -----------------------
    rx_xcvr.up();

    // -----------------------
    // Configure ADC TPL
    // -----------------------
    for (int i = 0; i < `JESD_M; i++) begin
      base_env.mng.sequencer.RegWrite32(`ADC_TPL_BA + 'h40 * i + GetAddrs(ADC_CHANNEL_REG_CHAN_CNTRL),
                         `SET_ADC_CHANNEL_REG_CHAN_CNTRL_ENABLE(1));
    end

    base_env.mng.sequencer.RegWrite32(`ADC_TPL_BA + GetAddrs(ADC_COMMON_REG_RSTN),
                       `SET_ADC_COMMON_REG_RSTN_RSTN(1));

    rx_ll.link_up();

    rx_ll.wait_link_up();
    tx_ll.wait_link_up();

    // Move data around for a while
    #5us;

    // Arm external sync
    base_env.mng.sequencer.RegWrite32(`DAC_TPL_BA + GetAddrs(DAC_COMMON_REG_CNTRL_1),2);
    base_env.mng.sequencer.RegWrite32(`ADC_TPL_BA + 'h48,2);
    #1us;
    // Check if armed
    base_env.mng.sequencer.RegReadVerify32(`DAC_TPL_BA + GetAddrs(DAC_COMMON_REG_SYNC_STATUS),
                            `SET_DAC_COMMON_REG_SYNC_STATUS_DAC_SYNC_STATUS(1));
    base_env.mng.sequencer.RegReadVerify32(`ADC_TPL_BA + GetAddrs(ADC_COMMON_REG_SYNC_STATUS),
                            `SET_ADC_COMMON_REG_SYNC_STATUS_ADC_SYNC(1));
    #1us;
    // Trigger external sync
    @(posedge system_tb.device_clk);
    system_tb.ext_sync <= 1'b1;
    @(posedge system_tb.device_clk);
    system_tb.ext_sync <= 1'b0;

    #1us;
    // Check if trigger captured
    base_env.mng.sequencer.RegReadVerify32(`DAC_TPL_BA + GetAddrs(DAC_COMMON_REG_SYNC_STATUS),
                            `SET_DAC_COMMON_REG_SYNC_STATUS_DAC_SYNC_STATUS(0));

    #5us;


    // =======================
    // Test SYSREF alignment
    // =======================

    // Drift SYSREF with one device clock
    //
    system_tb.sysref_dly_sel = 2'b01;
    #1us;
    @(posedge system_tb.sysref);
    @(negedge system_tb.sysref);
    // Check SYSREF alignment ERROR
    base_env.mng.sequencer.RegReadVerify32(`AXI_JESD_TX_BA + GetAddrs(JESD_TX_SYSREF_STATUS),
                       `SET_JESD_TX_SYSREF_STATUS_SYSREF_ALIGNMENT_ERROR(1) |
                       `SET_JESD_TX_SYSREF_STATUS_SYSREF_DETECTED(1));
    base_env.mng.sequencer.RegReadVerify32(`AXI_JESD_RX_BA + GetAddrs(JESD_RX_SYSREF_STATUS),
                       `SET_JESD_RX_SYSREF_STATUS_SYSREF_ALIGNMENT_ERROR(1) |
                       `SET_JESD_RX_SYSREF_STATUS_SYSREF_DETECTED(1));

    base_env.mng.sequencer.RegWrite32(`AXI_JESD_TX_BA + GetAddrs(JESD_TX_SYSREF_STATUS),
                       `SET_JESD_TX_SYSREF_STATUS_SYSREF_ALIGNMENT_ERROR(1) |
                       `SET_JESD_TX_SYSREF_STATUS_SYSREF_DETECTED(1));
    base_env.mng.sequencer.RegWrite32(`AXI_JESD_RX_BA + GetAddrs(JESD_RX_SYSREF_STATUS),
                       `SET_JESD_RX_SYSREF_STATUS_SYSREF_ALIGNMENT_ERROR(1) |
                       `SET_JESD_RX_SYSREF_STATUS_SYSREF_DETECTED(1));

    // Invert SYSREF
    //
    system_tb.sysref_dly_sel = 2'b10;
    #1us;
    @(posedge system_tb.sysref);
    @(negedge system_tb.sysref);
    // Check SYSREF alignment ERROR
    base_env.mng.sequencer.RegReadVerify32(`AXI_JESD_TX_BA + GetAddrs(JESD_TX_SYSREF_STATUS),
                       `SET_JESD_TX_SYSREF_STATUS_SYSREF_ALIGNMENT_ERROR(1) |
                       `SET_JESD_TX_SYSREF_STATUS_SYSREF_DETECTED(1));
    base_env.mng.sequencer.RegReadVerify32(`AXI_JESD_RX_BA + GetAddrs(JESD_RX_SYSREF_STATUS),
                       `SET_JESD_RX_SYSREF_STATUS_SYSREF_ALIGNMENT_ERROR(1) |
                       `SET_JESD_RX_SYSREF_STATUS_SYSREF_DETECTED(1));

    base_env.mng.sequencer.RegWrite32(`AXI_JESD_TX_BA + GetAddrs(JESD_TX_SYSREF_STATUS),
                       `SET_JESD_TX_SYSREF_STATUS_SYSREF_ALIGNMENT_ERROR(1) |
                       `SET_JESD_TX_SYSREF_STATUS_SYSREF_DETECTED(1));
    base_env.mng.sequencer.RegWrite32(`AXI_JESD_RX_BA + GetAddrs(JESD_RX_SYSREF_STATUS),
                       `SET_JESD_RX_SYSREF_STATUS_SYSREF_ALIGNMENT_ERROR(1) |
                       `SET_JESD_RX_SYSREF_STATUS_SYSREF_DETECTED(1));

    #1us;

    rx_xcvr.down();
    tx_xcvr.down();

    `INFO(("======================="), ADI_VERBOSITY_LOW);
    `INFO(("  JESD LINK TEST DONE  "), ADI_VERBOSITY_LOW);
    `INFO(("======================="), ADI_VERBOSITY_LOW);

  endtask : jesd_link_test

  // -----------------
  //
  // -----------------
  task arm_disarm_test();
    // Arm external sync
    base_env.mng.sequencer.RegWrite32(`DAC_TPL_BA + GetAddrs(DAC_COMMON_REG_CNTRL_1),2);
    base_env.mng.sequencer.RegWrite32(`ADC_TPL_BA + 'h48,2);
    #1us;

    // Check if armed
    base_env.mng.sequencer.RegReadVerify32(`DAC_TPL_BA + GetAddrs(DAC_COMMON_REG_SYNC_STATUS),
                            `SET_DAC_COMMON_REG_SYNC_STATUS_DAC_SYNC_STATUS(1));
    base_env.mng.sequencer.RegReadVerify32(`ADC_TPL_BA + GetAddrs(ADC_COMMON_REG_SYNC_STATUS),
                            `SET_ADC_COMMON_REG_SYNC_STATUS_ADC_SYNC(1));

    // DisArm external sync
    base_env.mng.sequencer.RegWrite32(`DAC_TPL_BA + GetAddrs(DAC_COMMON_REG_CNTRL_1),4);
    base_env.mng.sequencer.RegWrite32(`ADC_TPL_BA + 'h48,4);
    #1us;

    // Check if disarmed
    base_env.mng.sequencer.RegReadVerify32(`DAC_TPL_BA + GetAddrs(DAC_COMMON_REG_SYNC_STATUS),
                            `SET_DAC_COMMON_REG_SYNC_STATUS_DAC_SYNC_STATUS(0));
    base_env.mng.sequencer.RegReadVerify32(`ADC_TPL_BA + GetAddrs(ADC_COMMON_REG_SYNC_STATUS),
                            `SET_ADC_COMMON_REG_SYNC_STATUS_ADC_SYNC(0));
    `INFO(("======================="), ADI_VERBOSITY_LOW);
    `INFO(("  ARM-DISARM TEST DONE "), ADI_VERBOSITY_LOW);
    `INFO(("======================="), ADI_VERBOSITY_LOW);

  endtask : arm_disarm_test


  // -----------------
  //
  // -----------------
  task prbs_test();

    bit [2:0] rx_out_clk_sel;
    bit [2:0] tx_out_clk_sel;

    `INFO(("======================="), ADI_VERBOSITY_LOW);
    `INFO(("      PRBS TEST        "), ADI_VERBOSITY_LOW);
    `INFO(("======================="), ADI_VERBOSITY_LOW);

    // Disable gearbox path for 64b66b mode
    // PRBS is on the buffer path
    if (`LINK_MODE == `MODE_64B66B) begin
      for (int ch_idx = 0; ch_idx < link.L; ch_idx++) begin
        // set TXGEARBOX_EN to 0
        // set TXBUF_EN to 1
        tx_xcvr.drp_ch_update(ch_idx, 'h7c,
                              0 << 13 |
                              1 << 7,
                              {1{1'b1}} << 13 |
                              {1{1'b1}} << 7
                             );
        // set RXGEARBOX_EN to 0
        // set RXBUF_EN to 1
        rx_xcvr.drp_ch_update(ch_idx, 'h64,
                              0 << 0 |
                              1 << 3,
                              {1{1'b1}} << 0 |
                              {1{1'b1}} << 3
                             );
      end
      // set TXOUTCLKSEL to 3'b010 (TXOUTCLKPMA)
      base_env.mng.sequencer.RegRead32(`DAC_XCVR_BA + GetAddrs(XCVR_CONTROL), val);
      tx_out_clk_sel = `GET_XCVR_CONTROL_OUTCLK_SEL(val);

      base_env.mng.sequencer.RegWrite32(`DAC_XCVR_BA + GetAddrs(XCVR_CONTROL),
                         val & (~{32'b111} << 0) |
                         `SET_XCVR_CONTROL_OUTCLK_SEL(2));

      // set RXOUTCLKSEL to 3'b010 (RXOUTCLKPMA)
      base_env.mng.sequencer.RegRead32(`ADC_XCVR_BA + GetAddrs(XCVR_CONTROL), val);
      rx_out_clk_sel = `GET_XCVR_CONTROL_OUTCLK_SEL(val);

      base_env.mng.sequencer.RegWrite32(`ADC_XCVR_BA + GetAddrs(XCVR_CONTROL),
                         val & (~{32'b111} << 0) |
                         `SET_XCVR_CONTROL_OUTCLK_SEL(2));

    end

    fork
      rx_xcvr.up();
      tx_xcvr.up();
    join

    // -----------------------
    // Put XCVR in PRBS mode
    // -----------------------
    base_env.mng.sequencer.RegWrite32(`DAC_XCVR_BA + 32'h0180, `PRBS_9);
    base_env.mng.sequencer.RegWrite32(`ADC_XCVR_BA + 32'h0180, `PRBS_7);

    #1us;
    // Error should be detected
    base_env.mng.sequencer.RegReadVerify32(`ADC_XCVR_BA + 32'h0184, 1<<8 | 0);

    // Check if error can be cleared
    base_env.mng.sequencer.RegWrite32(`DAC_XCVR_BA + 32'h0180, `PRBS_7);
    base_env.mng.sequencer.RegWrite32(`ADC_XCVR_BA + 32'h0180, `PRBS_7 | 1 << 8); // Set prbs err cntr reset
    base_env.mng.sequencer.RegWrite32(`ADC_XCVR_BA + 32'h0180, `PRBS_7 | 0 << 8); // Clear prbs err cntr reset

    #1us;
    // No error should be detected, Lock should be set
    base_env.mng.sequencer.RegReadVerify32(`ADC_XCVR_BA + 32'h0184, 0<<8 | 1);

    // -----------------------
    // Check Error injection
    // -----------------------
    base_env.mng.sequencer.RegWrite32(`DAC_XCVR_BA + 32'h0180, `PRBS_7 | 1<<16 ); // Enable Error inject
    base_env.mng.sequencer.RegWrite32(`ADC_XCVR_BA + 32'h0180, 1 << 8); // Clear prbs err
    base_env.mng.sequencer.RegWrite32(`ADC_XCVR_BA + 32'h0180, `PRBS_7);

    #1us;
    // Error should be detected
    base_env.mng.sequencer.RegReadVerify32(`ADC_XCVR_BA + 32'h0184, 1<<8 | 0);

    base_env.mng.sequencer.RegWrite32(`DAC_XCVR_BA + 32'h0180, `PRBS_OFF);
    base_env.mng.sequencer.RegWrite32(`ADC_XCVR_BA + 32'h0180, 1 << 8); // Clear prbs err
    base_env.mng.sequencer.RegWrite32(`ADC_XCVR_BA + 32'h0180, `PRBS_OFF);

    rx_xcvr.down();
    tx_xcvr.down();

    // restore gearbox path for 64b66b mode
    if (`LINK_MODE == `MODE_64B66B) begin
      for (int ch_idx = 0; ch_idx < link.L; ch_idx++) begin
        // set TXGEARBOX_EN to 1
        // set TXBUF_EN to 0
        tx_xcvr.drp_ch_update(ch_idx, 'h7c,
                              1 << 13 |
                              0 << 7,
                              {1{1'b1}} << 13 |
                              {1{1'b1}} << 7
                             );
        // set RXGEARBOX_EN to 1
        // set RXBUF_EN to 0
        rx_xcvr.drp_ch_update(ch_idx, 'h64,
                              1 << 0 |
                              0 << 3,
                              {1{1'b1}} << 0 |
                              {1{1'b1}} << 3
                             );
      end
      // set TXOUTCLKSEL old value
      base_env.mng.sequencer.RegRead32(`DAC_XCVR_BA + GetAddrs(XCVR_CONTROL), val);
      base_env.mng.sequencer.RegWrite32(`DAC_XCVR_BA + GetAddrs(XCVR_CONTROL),
                         val & (~{32'b111} << 0) |
                         `SET_XCVR_CONTROL_OUTCLK_SEL(tx_out_clk_sel));

      // set RXOUTCLKSEL to 3'b010 (RXOUTCLKPMA)
      base_env.mng.sequencer.RegRead32(`ADC_XCVR_BA + GetAddrs(XCVR_CONTROL), val);
      base_env.mng.sequencer.RegWrite32(`ADC_XCVR_BA + GetAddrs(XCVR_CONTROL),
                         val & (~{32'b111} << 0) |
                         `SET_XCVR_CONTROL_OUTCLK_SEL(rx_out_clk_sel));

    end

    `INFO(("======================="), ADI_VERBOSITY_LOW);
    `INFO(("   PRBS TEST DONE      "), ADI_VERBOSITY_LOW);
    `INFO(("======================="), ADI_VERBOSITY_LOW);

  endtask : prbs_test

endprogram
