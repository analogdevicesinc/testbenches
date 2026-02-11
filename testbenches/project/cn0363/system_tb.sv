// ***************************************************************************
// ***************************************************************************
// Copyright (C) 2022-2025 Analog Devices, Inc. All rights reserved.
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

  wire cn0363_spi_sclk;
  wire cn0363_spi_sdo;
  wire cn0363_spi_sdi;
  wire [1:0] cn0363_spi_cs;
  wire cn0363_spi_clk;
  wire cn0363_irq;

  `TEST_PROGRAM test(
    .cn0363_spi_clk (cn0363_spi_clk),
    .cn0363_irq (cn0363_irq),
    .cn0363_spi_sdi (cn0363_spi_sdi),
    .cn0363_spi_cs (cn0363_spi_cs),
    .cn0363_spi_sclk (cn0363_spi_sclk));

  test_harness `TH (
    .cn0363_spi_clk (cn0363_spi_clk),
    .cn0363_irq (cn0363_irq),
    .spi_sdo (cn0363_spi_sdo),
    .spi_sdi (cn0363_spi_sdi),
    .spi_cs (cn0363_spi_cs),
    .spi_sclk (cn0363_spi_sclk));

endmodule
