// ***************************************************************************
// ***************************************************************************
// Copyright (C) 2014-2018 Analog Devices, Inc. All rights reserved.
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

  reg clk_enable = 1'b0;
  reg [31:0] sclk_edge_count = 0;
  reg ad463x_spi_vip_cs_prev = 1'b1;
  reg cs_active = 1'b0;
  wire ad463x_busy;
  wire ad463x_cnv;
  reg ad463x_busy_sclk;
  reg ad463x_echo_sclk;
  reg ad463x_ext_clk = 0;
  wire ad463x_spi_vip_cs;
  reg ad463x_spi_vip_sclk_int;
  wire ad463x_spi_vip_sclk;
  reg ad463x_spi_vip_1_div_4_sclk;
  reg ad463x_ddr_sclk_int;
  wire ad463x_ddr_sclk;
  wire ad463x_spi_clk;
  wire [`NUM_OF_SDI-1:0] ad463x_spi_vip_sdi;
  wire ad463x_spi_vip_sdo;
  wire ad463x_irq;

  `TEST_PROGRAM test(
    .ad463x_irq(ad463x_irq),
    .ad463x_echo_sclk(),
    .ad463x_spi_sclk(ad463x_spi_vip_sclk),
    .ad463x_spi_cs(ad463x_spi_vip_cs),
    .ad463x_spi_clk(ad463x_spi_clk),
    .ad463x_spi_sdi(ad463x_spi_vip_sdi));

  test_harness `TH (
    .ad463x_busy(ad463x_busy),
    .ad463x_irq(ad463x_irq),
    .ad463x_cnv(ad463x_cnv),
    .ad463x_echo_sclk(ad463x_echo_sclk),
    .ad463x_ext_clk(ad463x_ext_clk),
    .ad463x_spi_vip_cs(ad463x_spi_vip_cs),
    .ad463x_spi_vip_sclk(ad463x_spi_vip_sclk),
    .ad463x_ddr_sclk(ad463x_ddr_sclk),
    .ad463x_spi_clk(ad463x_spi_clk),
    .ad463x_spi_vip_sdi(ad463x_spi_vip_sdi),
    .ad463x_spi_vip_sdo(ad463x_spi_vip_sdo));

  //---------------------------------------------------------------------------
  // Echo SCLK generation - we need this only if ECHO_SCLK is enabled
  //---------------------------------------------------------------------------
  localparam SDI_PHY_DELAY = 18;

  reg     [SDI_PHY_DELAY:0] echo_delay_sclk = {SDI_PHY_DELAY{1'b0}};
  reg     delay_clk = 0;

  assign ad463x_busy = (`CAPTURE_ZONE == 2) ? (ad463x_busy_sclk) : ad463x_cnv;

  initial begin
    forever @(ad463x_spi_vip_sclk) begin
      if (clk_enable) begin
        ad463x_busy_sclk           <= #((`ECHO_SCLK_DELAY) * 1ns) ad463x_spi_vip_sclk;
      end else begin
        ad463x_busy_sclk           <= #(`ECHO_SCLK_DELAY * 1ns) `CPOL;  // Keep clock low when disabled
      end
      ad463x_spi_vip_sclk_int      <= ad463x_spi_vip_sclk;
      ad463x_echo_sclk             <= #((`ECHO_SCLK_DELAY) * 1ns) ad463x_spi_vip_sclk;
      ad463x_spi_vip_1_div_4_sclk  <= #(3.125ns) ad463x_spi_vip_sclk; //it only works for 12.5ns sclk period
    end
  end

  //it is necessary to create DDR SCLK without delay to feed the SPI VIP
  assign ad463x_ddr_sclk            = ad463x_spi_vip_sclk_int ^ ad463x_spi_vip_1_div_4_sclk;

  // Detect CS falling edge (high to low transition)
  always @(posedge delay_clk) begin
    ad463x_spi_vip_cs_prev <= ad463x_spi_vip_cs;
    if (ad463x_spi_vip_cs_prev == 1'b1 && ad463x_spi_vip_cs == 1'b0) begin
      cs_active <= 1'b1;  // CS falling edge detected, start counting
    end else if (ad463x_spi_vip_cs == 1'b1) begin
      cs_active <= 1'b0;  // CS deasserted, stop counting
      sclk_edge_count <= 0;
    end
  end

  // Count SCLK edges when CS is active
  always @(posedge ad463x_spi_vip_sclk or negedge ad463x_spi_vip_sclk) begin
    if (cs_active) begin  // Count only after CS falling edge
      sclk_edge_count <= sclk_edge_count + 1;
    end
  end

  // Gate the DDR clock to only toggle when CS is active and limit to half the cycles
  // Enable DDR clock for only half the SCLK edges
  always @(*) begin
    if (`DDR_EN == 1) begin
      // In DDR mode, only enable for half the edges (DATA_DLENGTH_DDR worth of cycles)
      clk_enable = (ad463x_spi_vip_cs == 1'b0) && (sclk_edge_count < `DATA_DLENGTH_SDR);
    end else begin
      clk_enable = 1'b1;  // Always enable in SDR mode
    end
  end

  always #0.5ns       delay_clk = ~delay_clk;
  always #5ns         ad463x_ext_clk = ~ad463x_ext_clk;

endmodule
