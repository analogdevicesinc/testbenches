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

  // DAC clock - directly generated as free-running clock in testbench
  reg ad974x_clk = 1'b0;

  // DAC data - internal 14-bit bus from block design
  wire [13:0] ad974x_data_int;

  // DAC data - after bit selection (mimics system_top.v behavior)
  reg [13:0] ad974x_data;

  // Device identifiers - used for case matching with DEVICE define
  localparam AD9748 = 0;
  localparam AD9740 = 1;
  localparam AD9742 = 2;
  localparam AD9744 = 3;

  // Generate DAC clock (~210 MHz = 4.76ns period, use 5ns for simplicity)
  always #2.5 ad974x_clk = ~ad974x_clk;

  // ---------------------------------------------------------------------------
  // Replicate system_top.v bit selection logic based on DEVICE define
  // This ensures the testbench verifies the same data path as real hardware
  // ---------------------------------------------------------------------------
  // Apply bit selection based on DEVICE define from cfg file
  // DEVICE expands to bare identifier (e.g., AD9740) which matches localparam
  always @(*) begin
    case (`DEVICE)
      AD9748: begin
        // AD9748: 8-bit DAC - MSB aligned, upper 8 bits, lower 6 bits = 0
        ad974x_data[13:6] = ad974x_data_int[13:6];
        ad974x_data[5:0]  = 6'b000000;
      end
      AD9740: begin
        // AD9740: 10-bit DAC - MSB aligned, upper 10 bits, lower 4 bits = 0
        ad974x_data[13:4] = ad974x_data_int[13:4];
        ad974x_data[3:0]  = 4'b0000;
      end
      AD9742: begin
        // AD9742: 12-bit DAC - MSB aligned, upper 12 bits, lower 2 bits = 0
        ad974x_data[13:2] = ad974x_data_int[13:2];
        ad974x_data[1:0]  = 2'b00;
      end
      default: begin
        // AD9744: 14-bit DAC - use all bits
        ad974x_data = ad974x_data_int;
      end
    endcase
  end

  // Connect test program to DAC signals for verification
  `TEST_PROGRAM test(
    .ad974x_clk  (ad974x_clk),
    .ad974x_data (ad974x_data)
  );

  // Connect test harness (block design) - outputs internal 14-bit bus
  test_harness `TH (
    .ad9740_clk  (ad974x_clk),
    .ad9740_data (ad974x_data_int)
  );

endmodule
