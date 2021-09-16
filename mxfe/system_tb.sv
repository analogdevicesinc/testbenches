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

`timescale 1ns/1ps

`include "utils.svh"

module system_tb();

  wire rx_sync_0;
  wire [3:0] tx_data_p;
  wire [3:0] tx_data_n;

  `TEST_PROGRAM test();

  test_harness `TH (
    .ref_clk_out    (ref_clk),
    .device_clk_out (device_clk),
    .sysref_clk_out (sysref),

    .rx_device_clk  (device_clk),      //-dir I
    .tx_device_clk  (device_clk),      //-dir I
    .GT_Serial_0_gtx_p (tx_data_p[3:0]),
    .GT_Serial_0_gtx_n (tx_data_n[3:0]),
    .GT_Serial_0_grx_p (tx_data_p[3:0]),
    .GT_Serial_0_grx_n (tx_data_n[3:0]),

    .gt_bridge_ip_0_diff_gt_ref_clock_0_clk_p(ref_clk),
    .gt_bridge_ip_0_diff_gt_ref_clock_0_clk_n(~ref_clk),

    .rx_sysref_0    (sysref),          //-dir I
    .tx_sysref_0    (sysref)//,          //-dir I
    //.rx_sync_0      (rx_sync_0),       //-dir O
    //.tx_sync_0      (rx_sync_0),       //-dir I
    //.ref_clk_q0     (ref_clk),         //-dir I
    //.ref_clk_q1     (ref_clk)          //-dir I

  );

endmodule
