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

module system_tb_ad9740();

  // AD9740 DAC interface signals
  wire        ad974x_clk;
  wire [13:0] ad974x_data;

  // Clock generation for DAC
  reg dac_clk_gen = 1'b0;

  // Generate 100MHz DAC clock
  always #5 dac_clk_gen = ~dac_clk_gen;

  assign ad974x_clk = dac_clk_gen;

  // Instantiate test program with DAC signals
  test_program_ad9740 test(
    .ad974x_clk(ad974x_clk),
    .ad974x_data(ad974x_data)
  );

  // Instantiate test harness
  test_harness `TH (
    .ad974x_clk(ad974x_clk),
    .ad974x_data(ad974x_data)
  );

  // Optional: Monitor DAC output for debugging
  initial begin
    $display("AD9740 Testbench Started");
    $display("DAC Clock Frequency: 100 MHz");
    $display("DAC Resolution: 10 bits");
  end

  // Optional: Waveform dumping
  initial begin
    if ($test$plusargs("DUMP_VCD")) begin
      $dumpfile("ad9740_test.vcd");
      $dumpvars(0, system_tb_ad9740);
    end
  end

endmodule