// ***************************************************************************
// ***************************************************************************
// Copyright (C) 2021 - 2023 Analog Devices, Inc. All rights reserved.
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
  wire spi_engine_spi_cs;
  wire spi_engine_spi_sclk;
  wire spi_engine_spi_clk;
  wire spi_engine_spi_sdi;
  wire spi_engine_spi_sdo;
  wire spi_engine_irq;
`ifdef DEF_ECHO_SCLK
  wire spi_engine_echo_sclk;
`endif

  `TEST_PROGRAM test(
    .spi_engine_irq(spi_engine_irq),
    .spi_engine_spi_sclk(spi_engine_spi_sclk),
    .spi_engine_spi_cs(spi_engine_spi_cs),
    .spi_engine_spi_clk(spi_engine_spi_clk),
    `ifdef DEF_ECHO_SCLK
    .spi_engine_echo_sclk(spi_engine_echo_sclk),
    `endif
    .spi_engine_spi_sdi(spi_engine_spi_sdi));

  test_harness `TH (
    .spi_engine_irq(spi_engine_irq),
    .spi_engine_spi_cs(spi_engine_spi_cs),
    .spi_engine_spi_sclk(spi_engine_spi_sclk),
    .spi_engine_spi_clk(spi_engine_spi_clk),
    .spi_engine_spi_sdi(spi_engine_spi_sdi),
    `ifdef DEF_ECHO_SCLK
    .spi_engine_echo_sclk(spi_engine_echo_sclk),
    `endif
    .spi_engine_spi_sdo(spi_engine_spi_sdo));

endmodule
