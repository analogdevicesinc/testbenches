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

  localparam DATAPATH_WIDTH = 4;
  localparam RX_SAMPLES_PER_CHANNEL = (`RX_JESD_L*DATAPATH_WIDTH*8) / `RX_JESD_M / `RX_JESD_NP;
  localparam RX_DMA_NP = `RX_JESD_NP;

  reg [`RX_JESD_M*RX_SAMPLES_PER_CHANNEL*RX_DMA_NP-1:0] tx_ex_dac_data = 'h0;

  `TEST_PROGRAM test();

  test_harness `TH (
    .ref_clk_out       (ref_clk),         //-dir O
    .rx_device_clk_out (rx_device_clk),   //-dir O
    .tx_device_clk_out (tx_device_clk),   //-dir O

    .rx_data_0_n       (ex_data_0_n),     //-dir I
    .rx_data_0_p       (ex_data_0_p),     //-dir I
    .rx_data_1_n       (ex_data_1_n),     //-dir I
    .rx_data_1_p       (ex_data_1_p),     //-dir I
    .rx_data_2_n       (ex_data_2_n),     //-dir I
    .rx_data_2_p       (ex_data_2_p),     //-dir I
    .rx_data_3_n       (ex_data_3_n),     //-dir I
    .rx_data_3_p       (ex_data_3_p),     //-dir I
    .rx_data_4_n       (ex_data_5_n),     //-dir I
    .rx_data_4_p       (ex_data_5_p),     //-dir I
    .rx_data_5_n       (ex_data_7_n),     //-dir I
    .rx_data_5_p       (ex_data_7_p),     //-dir I
    .rx_data_6_n       (ex_data_6_n),     //-dir I
    .rx_data_6_p       (ex_data_6_p),     //-dir I
    .rx_data_7_n       (ex_data_4_n),     //-dir I
    .rx_data_7_p       (ex_data_4_p),     //-dir I
    .tx_data_0_n       (data_0_n),        //-dir O
    .tx_data_0_p       (data_0_p),        //-dir O
    .tx_data_1_n       (data_1_n),        //-dir O
    .tx_data_1_p       (data_1_p),        //-dir O
    .tx_data_2_n       (data_2_n),        //-dir O
    .tx_data_2_p       (data_2_p),        //-dir O
    .tx_data_3_n       (data_3_n),        //-dir O
    .tx_data_3_p       (data_3_p),        //-dir O
    .tx_data_4_n       (data_4_n),        //-dir O
    .tx_data_4_p       (data_4_p),        //-dir O
    .tx_data_5_n       (data_5_n),        //-dir O
    .tx_data_5_p       (data_5_p),        //-dir O
    .tx_data_6_n       (data_6_n),        //-dir O
    .tx_data_6_p       (data_6_p),        //-dir O
    .tx_data_7_n       (data_7_n),        //-dir O
    .tx_data_7_p       (data_7_p),        //-dir O

    .ex_rx_data_0_n    (data_0_n),        //-dir I
    .ex_rx_data_0_p    (data_0_p),        //-dir I
    .ex_rx_data_1_n    (data_1_n),        //-dir I
    .ex_rx_data_1_p    (data_1_p),        //-dir I
    .ex_rx_data_2_n    (data_2_n),        //-dir I
    .ex_rx_data_2_p    (data_2_p),        //-dir I
    .ex_rx_data_3_n    (data_3_n),        //-dir I
    .ex_rx_data_3_p    (data_3_p),        //-dir I
    .ex_rx_data_4_n    (data_7_n),        //-dir I
    .ex_rx_data_4_p    (data_7_p),        //-dir I
    .ex_rx_data_5_n    (data_4_n),        //-dir I
    .ex_rx_data_5_p    (data_4_p),        //-dir I
    .ex_rx_data_6_n    (data_6_n),        //-dir I
    .ex_rx_data_6_p    (data_6_p),        //-dir I
    .ex_rx_data_7_n    (data_5_n),        //-dir I
    .ex_rx_data_7_p    (data_5_p),        //-dir I
    .ex_tx_data_0_n    (ex_data_0_n),     //-dir O
    .ex_tx_data_0_p    (ex_data_0_p),     //-dir O
    .ex_tx_data_1_n    (ex_data_1_n),     //-dir O
    .ex_tx_data_1_p    (ex_data_1_p),     //-dir O
    .ex_tx_data_2_n    (ex_data_2_n),     //-dir O
    .ex_tx_data_2_p    (ex_data_2_p),     //-dir O
    .ex_tx_data_3_n    (ex_data_3_n),     //-dir O
    .ex_tx_data_3_p    (ex_data_3_p),     //-dir O
    .ex_tx_data_4_n    (ex_data_4_n),     //-dir O
    .ex_tx_data_4_p    (ex_data_4_p),     //-dir O
    .ex_tx_data_5_n    (ex_data_5_n),     //-dir O
    .ex_tx_data_5_p    (ex_data_5_p),     //-dir O
    .ex_tx_data_6_n    (ex_data_6_n),     //-dir O
    .ex_tx_data_6_p    (ex_data_6_p),     //-dir O
    .ex_tx_data_7_n    (ex_data_7_n),     //-dir O
    .ex_tx_data_7_p    (ex_data_7_p),     //-dir O

    .dac_data_0        (tx_ex_dac_data),

    .rx_sync_0         (rx_sync),         //-dir O
    .tx_sync_0         (ex_rx_sync),      //-dir I
    .ex_rx_sync        (ex_rx_sync),      //-dir O
    .ex_tx_sync        (rx_sync),         //-dir I

    .rx_sysref_0       (1'b0),            //-dir I
    .tx_sysref_0       (1'b0),            //-dir I
    .ex_sysref         (1'b0),            //-dir I
    .rx_ref_clk_0      (ref_clk),         //-dir I
    .tx_ref_clk_0      (ref_clk),         //-dir I
    .ex_ref_clk        (ref_clk),         //-dir I
    .ex_rx_device_clk  (rx_device_clk),   //-dir I
    .ex_tx_device_clk  (tx_device_clk)    //-dir I
  );

  reg [RX_DMA_NP-1:0] sample = 'h0;
  integer sample_counter = 0;
  always @(posedge `TH.i_tx_jesd_exerciser.device_clk) begin
    for (int i = 0; i < `RX_JESD_M; i++) begin
      for (int j = 0; j < RX_SAMPLES_PER_CHANNEL; j++) begin
        // Test incrementing data on consecutive samples
        if (`TH.i_tx_jesd_exerciser.tx_tpl_core.dac_enable_0) begin
          sample = sample_counter+`RX_JESD_M*j+i;
        end else begin
          sample = 'h0;
        end
        tx_ex_dac_data[RX_DMA_NP*(RX_SAMPLES_PER_CHANNEL*i+j) +:RX_DMA_NP] = sample;
      end
    end
    sample_counter = sample_counter + `RX_JESD_M*RX_SAMPLES_PER_CHANNEL;
  end

endmodule
