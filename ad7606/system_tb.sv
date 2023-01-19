// ***************************************************************************
// ***************************************************************************
// Copyright 2022 (c) Analog Devices, Inc. All rights reserved.
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
    generate
      wire       ad7606_spi_sclk;
      wire       ad7606_spi_sdo;
      wire [3:0] ad7606_spi_sdi;
      wire       ad7606_spi_cs;
      wire       adc_busy;
      wire       adc_cnvst;
      wire       spi_clk;
      wire       irq;
  
    `TEST_PROGRAM test(
      .spi_clk (spi_clk),
      .irq (irq),
      .ad7606_spi_sdi(ad7606_spi_sdi),
      .ad7606_spi_cs (ad7606_spi_cs),
      .ad7606_spi_sclk (ad7606_spi_sclk));   
  
    test_harness `TH (
      .spi_clk (spi_clk),
      .irq (irq),
      .rx_busy (adc_busy),
      .rx_cnvst (adc_cnvst),
      .ad7606_spi_sdo (ad7606_spi_sdo),  
      .ad7606_spi_sdi (ad7606_spi_sdi),  
      .ad7606_spi_cs (ad7606_spi_cs),
      .ad7606_spi_sclk (ad7606_spi_sclk));
      
      assign adc_busy = adc_cnvst;  
    endgenerate
endmodule
