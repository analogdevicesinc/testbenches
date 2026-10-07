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
 
  localparam RX_SAMPLES_PER_CHANNEL = (`RX_JESD_L*`LL_OUT_BYTES*8) / `RX_JESD_M / `RX_JESD_NP;
  localparam RX_DMA_NP = `RX_JESD_NP;

  reg [`RX_JESD_M*RX_SAMPLES_PER_CHANNEL*RX_DMA_NP-1:0] tx_0_ex_dac_data = 'h0;
  reg [`RX_JESD_M*RX_SAMPLES_PER_CHANNEL*RX_DMA_NP-1:0] tx_1_ex_dac_data = 'h0;

  wire tx_0_sync;
  wire tx_1_sync;
  
  wire [15:0] ex2dut_serial_lane_n;
  wire [15:0] ex2dut_serial_lane_p;

  `TEST_PROGRAM test();

  test_harness `TH (
    .ref_clk_out(ref_clk),
    .rx_device_clk_out(rx_device_clk),
    .sysref_clk_out(sysref),

    .rx_ref_clk_0(ref_clk),
    .rx_ref_clk_1(ref_clk),
    .glbl_clk_0(rx_device_clk),
    .rx_sysref_0(sysref),
    .rx_sysref_1_0(sysref),

    .tx_device_clk(rx_device_clk),
    .ref_clk_ex(ref_clk),
    .sysref(sysref),

    .rx_sync_0(tx_0_sync),
    .ex_tx_0_sync(tx_0_sync),

    .rx_sync_1_0(tx_1_sync),
    .ex_tx_1_sync(tx_1_sync),
    
    .tx_0_data1_0_n(ex2dut_serial_lane_n[0]),
    .tx_0_data1_0_p(ex2dut_serial_lane_p[0]),
    .tx_0_data1_1_n(ex2dut_serial_lane_n[1]),
    .tx_0_data1_1_p(ex2dut_serial_lane_p[1]),
    .tx_0_data1_2_n(ex2dut_serial_lane_n[2]),
    .tx_0_data1_2_p(ex2dut_serial_lane_p[2]),
    .tx_0_data1_3_n(ex2dut_serial_lane_n[3]),
    .tx_0_data1_3_p(ex2dut_serial_lane_p[3]),
    .tx_0_data1_4_n(ex2dut_serial_lane_n[4]),
    .tx_0_data1_4_p(ex2dut_serial_lane_p[4]),
    .tx_0_data1_5_n(ex2dut_serial_lane_n[5]),
    .tx_0_data1_5_p(ex2dut_serial_lane_p[5]),
    .tx_0_data1_6_n(ex2dut_serial_lane_n[6]),
    .tx_0_data1_6_p(ex2dut_serial_lane_p[6]),
    .tx_0_data1_7_n(ex2dut_serial_lane_n[7]),
    .tx_0_data1_7_p(ex2dut_serial_lane_p[7]),

    .tx_1_data1_0_n(ex2dut_serial_lane_n[8]),
    .tx_1_data1_0_p(ex2dut_serial_lane_p[8]),
    .tx_1_data1_1_n(ex2dut_serial_lane_n[9]),
    .tx_1_data1_1_p(ex2dut_serial_lane_p[9]),
    .tx_1_data1_2_n(ex2dut_serial_lane_n[10]),
    .tx_1_data1_2_p(ex2dut_serial_lane_p[10]),
    .tx_1_data1_3_n(ex2dut_serial_lane_n[11]),
    .tx_1_data1_3_p(ex2dut_serial_lane_p[11]),
    .tx_1_data1_4_n(ex2dut_serial_lane_n[12]),
    .tx_1_data1_4_p(ex2dut_serial_lane_p[12]),
    .tx_1_data1_5_n(ex2dut_serial_lane_n[13]),
    .tx_1_data1_5_p(ex2dut_serial_lane_p[13]),
    .tx_1_data1_6_n(ex2dut_serial_lane_n[14]),
    .tx_1_data1_6_p(ex2dut_serial_lane_p[14]),
    .tx_1_data1_7_n(ex2dut_serial_lane_n[15]),
    .tx_1_data1_7_p(ex2dut_serial_lane_p[15]),

    .rx_data_0_n(ex2dut_serial_lane_n[0]),
    .rx_data_0_p(ex2dut_serial_lane_p[0]),
    .rx_data_1_n(ex2dut_serial_lane_n[1]),
    .rx_data_1_p(ex2dut_serial_lane_p[1]),
    .rx_data_2_n(ex2dut_serial_lane_n[2]),
    .rx_data_2_p(ex2dut_serial_lane_p[2]),
    .rx_data_3_n(ex2dut_serial_lane_n[3]),
    .rx_data_3_p(ex2dut_serial_lane_p[3]),
    .rx_data_4_n(ex2dut_serial_lane_n[4]),
    .rx_data_4_p(ex2dut_serial_lane_p[4]),
    .rx_data_5_n(ex2dut_serial_lane_n[5]),
    .rx_data_5_p(ex2dut_serial_lane_p[5]),
    .rx_data_6_n(ex2dut_serial_lane_n[6]),
    .rx_data_6_p(ex2dut_serial_lane_p[6]),
    .rx_data_7_n(ex2dut_serial_lane_n[7]),
    .rx_data_7_p(ex2dut_serial_lane_p[7]),

    .rx_data_1_0_n(ex2dut_serial_lane_n[8]),
    .rx_data_1_0_p(ex2dut_serial_lane_p[8]),
    .rx_data_1_1_n(ex2dut_serial_lane_n[9]),
    .rx_data_1_1_p(ex2dut_serial_lane_p[9]),
    .rx_data_1_2_n(ex2dut_serial_lane_n[10]),
    .rx_data_1_2_p(ex2dut_serial_lane_p[10]),
    .rx_data_1_3_n(ex2dut_serial_lane_n[11]),
    .rx_data_1_3_p(ex2dut_serial_lane_p[11]),
    .rx_data_1_4_n(ex2dut_serial_lane_n[12]),
    .rx_data_1_4_p(ex2dut_serial_lane_p[12]),
    .rx_data_1_5_n(ex2dut_serial_lane_n[13]),
    .rx_data_1_5_p(ex2dut_serial_lane_p[13]),
    .rx_data_1_6_n(ex2dut_serial_lane_n[14]),
    .rx_data_1_6_p(ex2dut_serial_lane_p[14]),
    .rx_data_1_7_n(ex2dut_serial_lane_n[15]),
    .rx_data_1_7_p(ex2dut_serial_lane_p[15]),
    
    .dac_0_data_0(tx_0_ex_dac_data[RX_SAMPLES_PER_CHANNEL*RX_DMA_NP*0 +: RX_SAMPLES_PER_CHANNEL*RX_DMA_NP]),
    .dac_0_data_1(tx_0_ex_dac_data[RX_SAMPLES_PER_CHANNEL*RX_DMA_NP*1 +: RX_SAMPLES_PER_CHANNEL*RX_DMA_NP]),

    .dac_1_data_0(tx_1_ex_dac_data[RX_SAMPLES_PER_CHANNEL*RX_DMA_NP*0 +: RX_SAMPLES_PER_CHANNEL*RX_DMA_NP]),
    .dac_1_data_1(tx_1_ex_dac_data[RX_SAMPLES_PER_CHANNEL*RX_DMA_NP*1 +: RX_SAMPLES_PER_CHANNEL*RX_DMA_NP])
  );

  reg [RX_DMA_NP-1:0] sample = 'h0;
  integer sample_counter = 0;
  always @(posedge `TH.i_tx_0_jesd_exerciser.device_clk) begin
    for (int i = 0; i < `RX_JESD_M; i++) begin
      for (int j = 0; j < RX_SAMPLES_PER_CHANNEL; j++) begin
        // Test incrementing data on consecutive samples
        if (`TH.i_tx_0_jesd_exerciser.tx_tpl_core.dac_enable_0) begin
          sample = sample_counter+`RX_JESD_M*j*2+i;
        end else begin
          sample = 'h0;
        end
        tx_0_ex_dac_data[RX_DMA_NP*(RX_SAMPLES_PER_CHANNEL*i+j) +:RX_DMA_NP] = sample;
        tx_1_ex_dac_data[RX_DMA_NP*(RX_SAMPLES_PER_CHANNEL*i+j) +:RX_DMA_NP] = sample+2;
      end
    end
    sample_counter = sample_counter + `RX_JESD_M*RX_SAMPLES_PER_CHANNEL*2;
  end

endmodule

