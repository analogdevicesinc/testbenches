// ***************************************************************************
// ***************************************************************************
// Copyright (C) 2024 Analog Devices, Inc. All rights reserved.
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
//      https://github.com/analogdevicesinc/hdl/blob/main/LICENSE_ADIBSD
//      This will allow to generate bit files and not release the source code,
//      as long as it attaches to an ADI device.
//
// ***************************************************************************
// ***************************************************************************

`timescale 1ns/1ps

`include "utils.svh"

module system_tb();
  wire i3c_irq;
  wire i3c_clk;
  wire i3c_scl;
  wire i3c_sda;
  wire i3c_sdi;
  wire i3c_sdo;
  wire i3c_t;

  ad_iobuf #(
    .DATA_WIDTH(1)
  ) i_iobuf_sda (
    .dio_t(i3c_t),
    .dio_i(i3c_sdo),
    .dio_o(i3c_sdi),
    .dio_p(i3c_sda));

  `TEST_PROGRAM test(
    .i3c_irq(i3c_irq),
    .i3c_clk(i3c_clk),
    .i3c_controller_0_scl(i3c_scl),
    .i3c_controller_0_sda(i3c_sda));

  test_harness `TH (
    .i3c_irq(i3c_irq),
    .i3c_clk(i3c_clk),
    .i3c_controller_0_scl(i3c_scl),
    .i3c_controller_0_sdi(i3c_sdi),
    .i3c_controller_0_sdo(i3c_sdo),
    .i3c_controller_0_t(i3c_t));

endmodule
