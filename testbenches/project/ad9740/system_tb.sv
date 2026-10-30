// ***************************************************************************
// ***************************************************************************
// Copyright (C) 2025 Analog Devices, Inc. All rights reserved.
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

  // ---------------------------------------------------------------------------
  // Clock generation - simulates external 210 MHz DAC clock from ADF4351
  // ---------------------------------------------------------------------------
  reg ad9740_clk_in = 1'b0;

  // Generate 210 MHz input clock (4.761ns period, use 4.76ns for simplicity)
  always #2.38 ad9740_clk_in = ~ad9740_clk_in;

  // ---------------------------------------------------------------------------
  // BUFR clock divider - matches system_top.v
  // ---------------------------------------------------------------------------
  wire ad9740_clk;

  // BUFR: divide input clock by 2 for logic, ODDR outputs DDR data
  BUFR #(
    .BUFR_DIVIDE ("2")
  ) i_ad9740_clk_bufr (
    .CLR (1'b0),
    .CE (1'b1),
    .I (ad9740_clk_in),
    .O (ad9740_clk));

  // ---------------------------------------------------------------------------
  // DAC data path
  // ---------------------------------------------------------------------------
  // DAC data - 14-bit DDR output from block design (post-ODDR)
  // ODDRs are inside axi_ad9740_if, test_harness outputs the final DDR signal
  wire [13:0] ad9740_data;

  // ---------------------------------------------------------------------------
  // Test program interface
  // ---------------------------------------------------------------------------
  `TEST_PROGRAM test(
    .ad974x_clk  (ad9740_clk),
    .ad974x_data (ad9740_data)
  );

  // ---------------------------------------------------------------------------
  // Test harness (block design) - outputs 14-bit post-ODDR DDR data
  // ---------------------------------------------------------------------------
  test_harness `TH (
    .ad9740_clk  (ad9740_clk),
    .ad9740_data (ad9740_data)
  );

endmodule
