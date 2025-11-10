// ***************************************************************************
// ***************************************************************************
// Copyright (C) 2014-2026 Analog Devices, Inc. All rights reserved.
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

`include "utils.svh"

module system_tb();

  wire ad463x_busy;
  wire ad463x_cnv;
  wire ad463x_echo_sclk;
  wire ad463x_ext_clk;
  wire ad463x_spi_cs;
  wire ad463x_spi_sclk;
  wire ad463x_spi_clk;
  wire [`NUM_OF_SDI-1:0] ad463x_spi_sdi;
  wire ad463x_spi_sdo;
  wire ad463x_irq;

  `TEST_PROGRAM test(
    .ad463x_irq(ad463x_irq),
    .ad463x_cnv(ad463x_cnv),
    .ad463x_busy(ad463x_busy),
    .ad463x_echo_sclk(ad463x_echo_sclk),
    .ad463x_ext_clk(ad463x_ext_clk),
    .ad463x_spi_sclk(ad463x_spi_sclk),
    .ad463x_spi_cs(ad463x_spi_cs),
    .ad463x_spi_clk(ad463x_spi_clk),
    .ad463x_spi_sdi(ad463x_spi_sdi)
  );

  test_harness `TH (
    .ad463x_busy(ad463x_busy),
    .ad463x_irq(ad463x_irq),
    .ad463x_cnv(ad463x_cnv),
    .ad463x_trigger(1'b0),
    .ad463x_echo_sclk(ad463x_echo_sclk),
    .ad463x_ext_clk(ad463x_ext_clk),
    .ad463x_spi_cs(ad463x_spi_cs),
    .ad463x_spi_sclk(ad463x_spi_sclk),
    .ad463x_spi_clk(ad463x_spi_clk),
    .ad463x_spi_sdi(ad463x_spi_sdi),
    .ad463x_spi_sdo(ad463x_spi_sdo)
  );

endmodule
