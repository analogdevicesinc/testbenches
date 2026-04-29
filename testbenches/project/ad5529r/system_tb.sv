// ***************************************************************************
// ***************************************************************************
// Copyright (C) 2026 Analog Devices, Inc. All rights reserved.
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
  wire ad5529r_spi_clk;
  wire ad5529r_spi_irq;
  wire ad5529r_tg0;
  wire ad5529r_tg1;
  wire ad5529r_tg2;
  wire ad5529r_tg3;

  // SPI signals exposed for timing measurement
  // These are directly assigned from the SPI VIP interface
  wire spi_sclk;
  wire spi_cs;
  wire spi_mosi;
  wire spi_miso;

  assign spi_sclk = `TH.`SPI_S.inst.IF.s_sclk;
  assign spi_cs   = `TH.`SPI_S.inst.IF.s_cs;
  assign spi_mosi = `TH.`SPI_S.inst.IF.s_mosi;
  assign spi_miso = `TH.`SPI_S.inst.IF.s_miso;

  // SPI VIP reset signal - directly driven by test_program for precise timing control
  // Must be asserted BEFORE system reset so VIP knows to expect CS glitches
  wire spi_resetn;
  assign `TH.`SPI_S.inst.IF.resetn = spi_resetn;

  `TEST_PROGRAM test(
    .ad5529r_spi_irq(ad5529r_spi_irq),
    .ad5529r_spi_clk(ad5529r_spi_clk),
    .ad5529r_tg0(ad5529r_tg0),
    .ad5529r_tg1(ad5529r_tg1),
    .ad5529r_tg2(ad5529r_tg2),
    .ad5529r_tg3(ad5529r_tg3),
    .spi_sclk(spi_sclk),
    .spi_cs(spi_cs),
    .spi_mosi(spi_mosi),
    .spi_miso(spi_miso),
    .spi_resetn(spi_resetn));

  test_harness `TH (
    .ad5529r_spi_irq(ad5529r_spi_irq),
    .ad5529r_spi_clk(ad5529r_spi_clk),
    .ad5529r_tg0(ad5529r_tg0),
    .ad5529r_tg1(ad5529r_tg1),
    .ad5529r_tg2(ad5529r_tg2),
    .ad5529r_tg3(ad5529r_tg3));

endmodule
