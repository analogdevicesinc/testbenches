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

  parameter ID = 0;
  parameter FPGA_TECHNOLOGY = 1;
  parameter IO_DELAY_GROUP = "adc_if_delay_group";
  parameter DELAY_REFCLK_FREQUENCY = 200;
  parameter TWOLANES = 1;
  parameter RESOLUTION = 18;

  parameter tCYC = 66.6;
  parameter tCONV = 63;
  parameter tFIRST_CLK = 65;
  parameter tLAST_CLK = 49;
  parameter tACQ = tCYC - 39;

  // set to active debug messages
  localparam bit DEBUG = 1;

  // dco delay compared to the reference clk
  localparam DCO_DELAY = 0.7;

  // reg signals

  reg                     ref_clk = 1'b0;
  reg                     ref_clk_out = 1'b0;
  reg                     cnv_out = 1'b0;
  reg                     clk_gate = 1'b0;
  reg                     dco_p = 1'b0;
  reg                     dco_n = 1'b0;
  reg                     da_p = 1'b0;
  reg                     da_n = 1'b0;
  reg                     db_p = 1'b0;
  reg                     db_n = 1'b0;

  // dma interface

  wire                    adc_valid;
  wire  [RESOLUTION-1:0]  adc_data;
  reg                     adc_dovf = 1'b0;


  // local wires and registers

  reg   clk_gate_d = 1'b0;
  reg   [RESOLUTION-1:0]  data = 'h3a5a5;
  reg   [RESOLUTION-1:0]  data_int = 'h0;
  reg   [9:0]  cnv_counter = 9'hd;
  reg   gate_start = 1'b0;

  integer clk_gate_counter = 0;
  integer clk_gate_high = (RESOLUTION == 16) ?
                            (TWOLANES == 0) ? 8 : 4 :
                          (RESOLUTION == 18) ?
                             (TWOLANES == 0) ? 9 : 5 :
                           5;

  integer clk_gate_low = (RESOLUTION == 16) ?
                            (TWOLANES == 0) ? 5 : 9 :
                         (RESOLUTION == 18) ?
                            (TWOLANES == 0) ? 4 : 8 :
                          8;
  integer clk_gate_period = clk_gate_high + clk_gate_low;
  // it takes 1 CNV impulse for the adc_data to be populated at the first run
  integer cnv_count = 0;


  // test bench variables

  always #2.564 ref_clk = ~ref_clk;

      `TEST_PROGRAM test(
       .dco_p (dco_p),
       .dco_n (dco_n),
       .da_p (da_p),
       .da_n (da_n),
       .db_p (db_p),
       .db_n (db_n));

     test_harness `TH (
       .ref_clk (ref_clk),
       .sampling_clk (sampling_clk),
       .dco_p (dco_p),
       .dco_n (dco_n),
       .cnv (cnv),
       .da_n (da_n),
       .da_p (da_p),
       .db_n (db_n),
       .db_p (db_p),
       .clk_gate (clk_gate));

endmodule

