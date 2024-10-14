// ***************************************************************************
// ***************************************************************************
// Copyright 2024 (c) Analog Devices, Inc. All rights reserved.
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

  `ifdef DEF_ECHO_SCLK
  wire                     quad_adaq77681_echo_sclk;
  `endif
  wire                     quad_adaq77681_spi_clk;
  wire                     quad_adaq77681_spi_sclk;
  wire [(`NUM_OF_CS-1) :0] quad_adaq77681_spi_cs;
  wire [(`NUM_OF_SDI-1):0] quad_adaq77681_spi_sdi;
  wire [(`NUM_OF_SDO-1):0] quad_adaq77681_spi_sdo;
  wire                     quad_adaq77681_irq;
  
  `TEST_PROGRAM test(
    `ifdef DEF_ECHO_SCLK
    .quad_adaq77681_echo_sclk(quad_adaq77681_echo_sclk),
    `endif
    .quad_adaq77681_spi_clk(quad_adaq77681_spi_clk),
    .quad_adaq77681_spi_sclk(quad_adaq77681_spi_sclk),
    .quad_adaq77681_spi_cs(quad_adaq77681_spi_cs),
    .quad_adaq77681_spi_sdi(quad_adaq77681_spi_sdi),
    .quad_adaq77681_irq(quad_adaq77681_irq));

  test_harness `TH (
    `ifdef DEF_ECHO_SCLK
    .quad_adaq77681_echo_sclk(quad_adaq77681_echo_sclk),
    `endif
    .quad_adaq77681_spi_vip_clk(quad_adaq77681_spi_clk),
    .quad_adaq77681_spi_vip_sclk(quad_adaq77681_spi_sclk),
    .quad_adaq77681_spi_vip_cs(quad_adaq77681_spi_cs),
    .quad_adaq77681_spi_vip_sdi(quad_adaq77681_spi_sdi),
    .quad_adaq77681_spi_vip_sdo(quad_adaq77681_spi_sdo),
    .quad_adaq77681_irq(quad_adaq77681_irq));

endmodule
