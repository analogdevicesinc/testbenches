// ***************************************************************************
// ***************************************************************************
// Copyright 2023 (c) Analog Devices, Inc. All rights reserved.
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
  wire [1:0]  adc_config_mode;
  wire        rx_cnvst_n;
  wire        rx_busy;
  wire [15:0] rx_db_i;
  wire [15:0] rx_db_o;
  wire        rx_db_t;
  wire        rx_rd_n;
  wire        rx_wr_n;
  wire        rx_cs_n;
  wire        rx_first_data;
  wire        rx_data_ready;
  wire [3:0]  rx_ch_count;
  wire        sys_clk;

  reg         rx_cnvst_n_d = 1'b0;
  reg         rx_rd_n_d = 1'b0;
  reg [3:0]   rx_ch_count_d = 4'b0;

  wire [4:0] num_chs;

  parameter DEV_CONFIG = 0;
  localparam NEG_EDGE = 1;

  `TEST_PROGRAM test(
    .adc_config_mode (adc_config_mode),
    .rx_cnvst_n (rx_cnvst_n),
    .rx_busy (rx_busy),
    .rx_db_i (rx_db_i),
    .rx_db_o (rx_db_o),
    .rx_db_t (rx_db_t),
    .rx_rd_n (rx_rd_n),
    .rx_wr_n (rx_wr_n),
    .rx_cs_n (rx_cs_n),
    .rx_first_data (rx_first_data),
    .rx_data_ready (rx_data_ready),
    .rx_ch_count (rx_ch_count),
    .sys_clk (sys_clk));

  test_harness `TH (
    .rx_cnvst_n (rx_cnvst_n),
    .rx_busy (rx_busy),
    .rx_db_i (rx_db_i),
    .rx_db_o (rx_db_o),
    .rx_db_t (rx_db_t),
    .rx_rd_n (rx_rd_n),
    .rx_wr_n (rx_wr_n),
    .rx_cs_n (rx_cs_n),
    .rx_first_data (rx_first_data),
    .sys_clk (sys_clk));

  always @(posedge sys_clk) begin
    rx_cnvst_n_d <= rx_cnvst_n;
    rx_rd_n_d <= rx_rd_n;
  end

  always @(posedge sys_clk) begin
    if (~rx_rd_n & rx_rd_n_d) begin
      rx_ch_count_d <= rx_ch_count_d  + 1;
    end
    if (rx_ch_count_d  == num_chs && (rx_rd_n & ~rx_rd_n_d)) begin // if ch_count is equal to number of channels to be read and is the rising_edge rd_n after last channel
      rx_ch_count_d <= 0;
    end
  end

  assign num_chs = (DEV_CONFIG == 0 || DEV_CONFIG == 1) ? ((adc_config_mode == 0 ? 8 : (adc_config_mode == 1 ? 9 : (adc_config_mode == 2 ? 16 : 17)))) : ((adc_config_mode == 0 || adc_config_mode == 2) ? 16 : 17);
  assign rx_busy = (~rx_cnvst_n & rx_cnvst_n_d) ? 1'b1 : 1'b0;
  assign rx_ch_count = rx_ch_count_d;
  assign rx_data_ready = (~rx_rd_n & rx_rd_n_d) ? 1'b1 : 1'b0;
  assign rx_first_data = (rx_ch_count_d == 1'b1) ? 1'b1 : 1'b0;

endmodule
