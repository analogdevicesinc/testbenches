// ***************************************************************************
// ***************************************************************************
// Copyright 2021 (c) Analog Devices, Inc. All rights reserved.
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

  wire ad3552r_dac_spi_cs;
  wire ad3552r_dac_spi_sclk;
  wire ad3552r_dac_spi_clk;
  wire [1:0] ad3552r_dac_spi_sdi;
  wire [1:0] ad3552_dac_spi_sdio;
  wire ad3552r_dac_spi_sdo_t;
  wire [1:0] ad3552r_dac_spi_sdo; //ADD PARAM
  wire ad3552r_dac_irq;

  `TEST_PROGRAM test(
    .ad3552r_dac_irq(ad3552r_dac_irq),
    .ad3552r_dac_spi_sclk(ad3552r_dac_spi_sclk),
    .ad3552r_dac_spi_cs(ad3552r_dac_spi_cs),
    .ad3552r_dac_spi_clk(ad3552r_dac_spi_clk),
    .ad3552r_dac_spi_sdi(ad3552_dac_spi_sdio),
    .ad3552r_dac_spi_sdo_t(ad3552r_dac_spi_sdo_t),
    .ad3552r_dac_spi_sdo(ad3552r_dac_spi_sdo));

  test_harness `TH (
    .ad3552r_dac_irq(ad3552r_dac_irq),
    .ad3552r_dac_spi_cs(ad3552r_dac_spi_cs),
    .ad3552r_dac_spi_sclk(ad3552r_dac_spi_sclk),
    .ad3552r_dac_spi_clk(ad3552r_dac_spi_clk),
    .ad3552r_dac_spi_sdi(ad3552r_dac_spi_sdi),
    .ad3552r_dac_spi_sdo_t(ad3552r_dac_spi_sdo_t),
    .ad3552r_dac_spi_sdo(ad3552r_dac_spi_sdo));

  ad_iobuf #(
    .DATA_WIDTH(4)
  ) i_ad3552_spi_iobuf (
    .dio_t({ad3552r_dac_spi_sdo_t, ad3552r_dac_spi_sdo_t, ad3552r_dac_spi_sdo_t, ad3552r_dac_spi_sdo_t}),
    .dio_i(ad3552r_dac_spi_sdo),
    .dio_o(ad3552r_dac_spi_sdi),
    .dio_p(ad3552_dac_spi_sdio));

endmodule
