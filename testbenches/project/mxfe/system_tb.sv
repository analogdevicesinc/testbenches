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

module system_tb();

  wire rx_sync_0;
  reg ext_sync = 1'b0;

  logic rx_resetdone;
  logic tx_resetdone;
  logic gt_powergood;
  logic gt_reset_rx_pll_and_datapath = 1'b0;
  logic gt_reset_tx_pll_and_datapath = 1'b0;
  logic gt_reset_rx_datapath = 1'b0;
  logic gt_reset_tx_datapath = 1'b0;
  logic gt_reset = ~gt_powergood;

  wire [3:0] rx_p;
  wire [3:0] rx_n;

  `TEST_PROGRAM test();

  test_harness `TH (
    .rx_resetdone (rx_resetdone),
    .tx_resetdone (tx_resetdone),
    .gt_powergood (gt_powergood),
    .gt_reset (gt_reset),
    .gt_reset_rx_pll_and_datapath (gt_reset_rx_pll_and_datapath),
    .gt_reset_tx_pll_and_datapath (gt_reset_tx_pll_and_datapath),
    .gt_reset_rx_datapath (gt_reset_rx_datapath),
    .gt_reset_tx_datapath (gt_reset_tx_datapath),

    .ref_clk_out    (ref_clk),
    .device_clk_out (device_clk),
    .sysref_clk_out (sysref),

    .rx_device_clk  (device_clk),      //-dir I
    .tx_device_clk  (device_clk),      //-dir I
    .rx_0_n (rx_n),
    .rx_0_p (rx_p),
    .tx_0_n (rx_n),
    .tx_0_p (rx_p),
    // .rx_data_0_n    (data_0_n),        //-dir I
    // .rx_data_0_p    (data_0_p),        //-dir I
    // .rx_data_1_n    (data_1_n),        //-dir I
    // .rx_data_1_p    (data_1_p),        //-dir I
    // .rx_data_2_n    (data_2_n),        //-dir I
    // .rx_data_2_p    (data_2_p),        //-dir I
    // .rx_data_3_n    (data_3_n),        //-dir I
    // .rx_data_3_p    (data_3_p),        //-dir I
    // .rx_data_4_n    (data_4_n),        //-dir I
    // .rx_data_4_p    (data_4_p),        //-dir I
    // .rx_data_5_n    (data_5_n),        //-dir I
    // .rx_data_5_p    (data_5_p),        //-dir I
    // .rx_data_6_n    (data_6_n),        //-dir I
    // .rx_data_6_p    (data_6_p),        //-dir I
    // .rx_data_7_n    (data_7_n),        //-dir I
    // .rx_data_7_p    (data_7_p),        //-dir I
    // .tx_data_0_n    (data_0_n),        //-dir O
    // .tx_data_0_p    (data_0_p),        //-dir O
    // .tx_data_1_n    (data_1_n),        //-dir O
    // .tx_data_1_p    (data_1_p),        //-dir O
    // .tx_data_2_n    (data_2_n),        //-dir O
    // .tx_data_2_p    (data_2_p),        //-dir O
    // .tx_data_3_n    (data_3_n),        //-dir O
    // .tx_data_3_p    (data_3_p),        //-dir O
    // .tx_data_4_n    (data_4_n),        //-dir O
    // .tx_data_4_p    (data_4_p),        //-dir O
    // .tx_data_5_n    (data_5_n),        //-dir O
    // .tx_data_5_p    (data_5_p),        //-dir O
    // .tx_data_6_n    (data_6_n),        //-dir O
    // .tx_data_6_p    (data_6_p),        //-dir O
    // .tx_data_7_n    (data_7_n),        //-dir O
    // .tx_data_7_p    (data_7_p),        //-dir O
    .rx_sysref_0    (sysref),          //-dir I
    .tx_sysref_0    (sysref),          //-dir I
    .rx_sync_0      (rx_sync_0),       //-dir O
    .tx_sync_0      (rx_sync_0),       //-dir I
    .ref_clk_q0     (ref_clk),         //-dir I
    .ref_clk_q1     (ref_clk),         //-dir I
    .rx_usrclk_in   (ref_clk),
    .tx_usrclk_in   (ref_clk),
    .ext_sync_in    (ext_sync)
  );

  integer gtm_ch0_txp_integer;
  integer gtm_ch1_txp_integer;
  integer gtm_ch2_txp_integer;
  integer gtm_ch3_txp_integer;
  integer gtm_ch0_txn_integer;
  integer gtm_ch1_txn_integer;
  integer gtm_ch2_txn_integer;
  integer gtm_ch3_txn_integer;

  // PG315 Chapter7 "Test Bench" for proper loopback
  // Connecting the tx_n/p to rx_n/p doesn't work since they are
  // always in 'Z'. This is expected behaviour apparently.
  always_comb begin
    force gtm_ch0_txp_integer = `TH.jesd204_phy_rxtx.xcvr.inst.intf_quad_map_inst.quad_top_inst.gt_quad_base_0_inst.inst.quad_inst.CH0_GTMTXP_integer;
    force gtm_ch1_txp_integer = `TH.jesd204_phy_rxtx.xcvr.inst.intf_quad_map_inst.quad_top_inst.gt_quad_base_0_inst.inst.quad_inst.CH1_GTMTXP_integer;
    force gtm_ch2_txp_integer = `TH.jesd204_phy_rxtx.xcvr.inst.intf_quad_map_inst.quad_top_inst.gt_quad_base_0_inst.inst.quad_inst.CH2_GTMTXP_integer;
    force gtm_ch3_txp_integer = `TH.jesd204_phy_rxtx.xcvr.inst.intf_quad_map_inst.quad_top_inst.gt_quad_base_0_inst.inst.quad_inst.CH3_GTMTXP_integer;
    force gtm_ch0_txn_integer = `TH.jesd204_phy_rxtx.xcvr.inst.intf_quad_map_inst.quad_top_inst.gt_quad_base_0_inst.inst.quad_inst.CH0_GTMTXN_integer;
    force gtm_ch1_txn_integer = `TH.jesd204_phy_rxtx.xcvr.inst.intf_quad_map_inst.quad_top_inst.gt_quad_base_0_inst.inst.quad_inst.CH1_GTMTXN_integer;
    force gtm_ch2_txn_integer = `TH.jesd204_phy_rxtx.xcvr.inst.intf_quad_map_inst.quad_top_inst.gt_quad_base_0_inst.inst.quad_inst.CH2_GTMTXN_integer;
    force gtm_ch3_txn_integer = `TH.jesd204_phy_rxtx.xcvr.inst.intf_quad_map_inst.quad_top_inst.gt_quad_base_0_inst.inst.quad_inst.CH3_GTMTXN_integer;

    force `TH.jesd204_phy_rxtx.xcvr.inst.intf_quad_map_inst.quad_top_inst.gt_quad_base_0_inst.inst.quad_inst.CH0_GTMRXP_integer = gtm_ch0_txp_integer;
    force `TH.jesd204_phy_rxtx.xcvr.inst.intf_quad_map_inst.quad_top_inst.gt_quad_base_0_inst.inst.quad_inst.CH1_GTMRXP_integer = gtm_ch1_txp_integer;
    force `TH.jesd204_phy_rxtx.xcvr.inst.intf_quad_map_inst.quad_top_inst.gt_quad_base_0_inst.inst.quad_inst.CH2_GTMRXP_integer = gtm_ch2_txp_integer;
    force `TH.jesd204_phy_rxtx.xcvr.inst.intf_quad_map_inst.quad_top_inst.gt_quad_base_0_inst.inst.quad_inst.CH3_GTMRXP_integer = gtm_ch3_txp_integer;
    force `TH.jesd204_phy_rxtx.xcvr.inst.intf_quad_map_inst.quad_top_inst.gt_quad_base_0_inst.inst.quad_inst.CH0_GTMRXN_integer = gtm_ch0_txn_integer;
    force `TH.jesd204_phy_rxtx.xcvr.inst.intf_quad_map_inst.quad_top_inst.gt_quad_base_0_inst.inst.quad_inst.CH1_GTMRXN_integer = gtm_ch1_txn_integer;
    force `TH.jesd204_phy_rxtx.xcvr.inst.intf_quad_map_inst.quad_top_inst.gt_quad_base_0_inst.inst.quad_inst.CH2_GTMRXN_integer = gtm_ch2_txn_integer;
    force `TH.jesd204_phy_rxtx.xcvr.inst.intf_quad_map_inst.quad_top_inst.gt_quad_base_0_inst.inst.quad_inst.CH3_GTMRXN_integer = gtm_ch3_txn_integer;
  end

endmodule
