// ***************************************************************************
// ***************************************************************************
// Copyright 2014-2023 (c) Analog Devices, Inc. All rights reserved.
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
  wire pwm_gen_o_0;
  wire pwm_gen_o_1;
  wire pwm_gen_o_2;
  wire pwm_gen_o_3;
  wire pwm_gen_o_4;
  wire pwm_gen_o_5;
  wire pwm_gen_o_6;
  wire pwm_gen_o_7;
  wire pwm_gen_o_8;
  wire pwm_gen_o_9;
  wire pwm_gen_o_10;
  wire pwm_gen_o_11;
  wire pwm_gen_o_12;
  wire pwm_gen_o_13;
  wire pwm_gen_o_14;
  wire pwm_gen_o_15;

  wire sys_clk;

  `TEST_PROGRAM test(
    .pwm_gen_o_0 (pwm_gen_o_0),
    .pwm_gen_o_1 (pwn_gen_o_1),
    .pwm_gen_o_2 (pwm_gen_o_2),
    .pwm_gen_o_3 (pwm_gen_o_3),
    .pwm_gen_o_4 (pwm_gen_o_4),
    .pwm_gen_o_5 (pwm_gen_o_5),
    .pwm_gen_o_6 (pwm_gen_o_6),
    .pwm_gen_o_7 (pwm_gen_o_7),
    .pwm_gen_o_8 (pwm_gen_o_8),
    .pwm_gen_o_9 (pwn_gen_o_9),
    .pwm_gen_o_10 (pwm_gen_o_10),
    .pwm_gen_o_11 (pwm_gen_o_11),
    .pwm_gen_o_12 (pwm_gen_o_12),
    .pwm_gen_o_13 (pwm_gen_o_13),
    .pwm_gen_o_14 (pwm_gen_o_14),
    .pwm_gen_o_15 (pwm_gen_o_15),

    .sys_clk (sys_clk));

  test_harness `TH (
    .pwm_gen_o_0 (pwm_gen_o_0),
    .pwm_gen_o_1 (pwn_gen_o_1),
    .pwm_gen_o_2 (pwm_gen_o_2),
    .pwm_gen_o_3 (pwm_gen_o_3),
    .pwm_gen_o_4 (pwm_gen_o_4),
    .pwm_gen_o_5 (pwm_gen_o_5),
    .pwm_gen_o_6 (pwm_gen_o_6),
    .pwm_gen_o_7 (pwm_gen_o_7),
    .pwm_gen_o_8 (pwm_gen_o_8),
    .pwm_gen_o_9 (pwn_gen_o_9),
    .pwm_gen_o_10 (pwm_gen_o_10),
    .pwm_gen_o_11 (pwm_gen_o_11),
    .pwm_gen_o_12 (pwm_gen_o_12),
    .pwm_gen_o_13 (pwm_gen_o_13),
    .pwm_gen_o_14 (pwm_gen_o_14),
    .pwm_gen_o_15 (pwm_gen_o_15),
    .sys_clk (sys_clk));

endmodule
