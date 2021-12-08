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
 
  wire rx_sync;
  wire tx_sync;
  wire tx_os_sync;
  
  wire [3:0] ex2dut_serial_lane_n;
  wire [3:0] ex2dut_serial_lane_p;

  wire [3:0] dut2ex_serial_lane_n;
  wire [3:0] dut2ex_serial_lane_p;

  `TEST_PROGRAM test();

  test_harness `TH (
    .tx_ref_clk_0 (ref_clk),
    .rx_ref_clk_0 (ref_clk),
    .rx_ref_clk_2 (ref_clk),
    .ref_clk_out  (ref_clk),
    .rx_device_clk_out (rx_device_clk),
    .tx_device_clk_out (tx_device_clk),
    .tx_os_device_clk_out (tx_os_device_clk),
    .sysref_clk_out (sysref),

    .rx_device_clk(rx_device_clk),
    .tx_device_clk(tx_device_clk),
    .tx_os_device_clk(tx_os_device_clk),
    .ref_clk(ref_clk),
    .sysref(sysref),
    .tx_sysref_0(sysref),
    .rx_sysref_0(sysref),
    .rx_sysref_2(sysref),

    .tx_sync_0(rx_sync),
    .ex_rx_sync(rx_sync),

    .rx_sync_0(tx_sync),
    .ex_tx_sync(tx_sync),

    .rx_sync_2(tx_os_sync),
    .ex_tx_os_sync(tx_os_sync),

    .rx_data1_0_n(dut2ex_serial_lane_n[0]),
    .rx_data1_0_p(dut2ex_serial_lane_p[0]),
    .rx_data1_1_n(dut2ex_serial_lane_n[1]),
    .rx_data1_1_p(dut2ex_serial_lane_p[1]),
    .rx_data1_2_n(dut2ex_serial_lane_n[2]),
    .rx_data1_2_p(dut2ex_serial_lane_p[2]),
    .rx_data1_3_n(dut2ex_serial_lane_n[3]),
    .rx_data1_3_p(dut2ex_serial_lane_p[3]),
    
    .tx_data1_0_n(ex2dut_serial_lane_n[0]),
    .tx_data1_0_p(ex2dut_serial_lane_p[0]),
    .tx_data1_1_n(ex2dut_serial_lane_n[1]),
    .tx_data1_1_p(ex2dut_serial_lane_p[1]),

    .tx_os_data1_0_n(ex2dut_serial_lane_n[2]),
    .tx_os_data1_0_p(ex2dut_serial_lane_p[2]),
    .tx_os_data1_1_n(ex2dut_serial_lane_n[3]),
    .tx_os_data1_1_p(ex2dut_serial_lane_p[3]),

    .rx_data_0_n(ex2dut_serial_lane_n[0]),
    .rx_data_0_p(ex2dut_serial_lane_p[0]),
    .rx_data_1_n(ex2dut_serial_lane_n[1]),
    .rx_data_1_p(ex2dut_serial_lane_p[1]),
    .rx_data_2_n(ex2dut_serial_lane_n[2]),
    .rx_data_2_p(ex2dut_serial_lane_p[2]),
    .rx_data_3_n(ex2dut_serial_lane_n[3]),
    .rx_data_3_p(ex2dut_serial_lane_p[3]),
       
    .tx_data_0_n(dut2ex_serial_lane_n[0]),
    .tx_data_0_p(dut2ex_serial_lane_p[0]),
    .tx_data_1_n(dut2ex_serial_lane_n[3]),
    .tx_data_1_p(dut2ex_serial_lane_p[3]),
    .tx_data_2_n(dut2ex_serial_lane_n[2]),
    .tx_data_2_p(dut2ex_serial_lane_p[2]),
    .tx_data_3_n(dut2ex_serial_lane_n[1]),
    .tx_data_3_p(dut2ex_serial_lane_p[1])
  );

endmodule

