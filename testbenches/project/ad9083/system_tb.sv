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

`timescale 1ns/1ps

`include "utils.svh"

module system_tb();

  wire sync;
  wire ref_clk;
  wire device_clk;
  wire sysref;

  wire data_0_n;
  wire data_0_p;
  wire data_1_n;
  wire data_1_p;
  wire data_2_n;
  wire data_2_p;
  wire data_3_n;
  wire data_3_p;

  `TEST_PROGRAM test();

  test_harness `TH (
    .ref_clk_out    (ref_clk),
    .rx_ref_clk_0   (ref_clk),
    .vip_ref_clk    (ref_clk),

    .device_clk_out (device_clk),
    .vip_device_clk (device_clk),
    .rx_core_clk_0  (device_clk),

    .sysref_clk_out (sysref),
    .rx_sysref_1_0  (sysref),
    .tx_sysref_0    (sysref),

    .rx_sync_1_0    (sync),            //-dir O
    .tx_sync_0      (sync),            //-dir I

    .rx_data_1_0_n    (data_0_n),        //-dir I
    .rx_data_1_0_p    (data_0_p),        //-dir I
    .rx_data_1_1_n    (data_1_n),        //-dir I
    .rx_data_1_1_p    (data_1_p),        //-dir I
    .rx_data_1_2_n    (data_2_n),        //-dir I
    .rx_data_1_2_p    (data_2_p),        //-dir I
    .rx_data_1_3_n    (data_3_n),        //-dir I
    .rx_data_1_3_p    (data_3_p),        //-dir I
    .tx_data_0_n    (data_0_n),        //-dir O
    .tx_data_0_p    (data_0_p),        //-dir O
    .tx_data_1_n    (data_1_n),        //-dir O
    .tx_data_1_p    (data_1_p),        //-dir O
    .tx_data_2_n    (data_2_n),        //-dir O
    .tx_data_2_p    (data_2_p),        //-dir O
    .tx_data_3_n    (data_3_n),        //-dir O
    .tx_data_3_p    (data_3_p)         //-dir O

  );

endmodule
