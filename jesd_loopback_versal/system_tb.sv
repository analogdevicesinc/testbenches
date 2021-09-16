// ***************************************************************************
// ***************************************************************************
// Copyright 2014 - 2018 (c) Analog Devices, Inc. All rights reserved.
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

  localparam SAMPLES_PER_CHANNEL = (`JESD_L*`LL_OUT_BYTES*8) / `JESD_M / `JESD_NP;
  localparam DMA_NP = `JESD_NP == 12 ? 16 : `JESD_NP;
  localparam MAX_CHANNLES = 16;

  reg [`JESD_M*SAMPLES_PER_CHANNEL*DMA_NP-1:0] dac_data = 'h0;

  wire [3:0] ex2dut_serial_lane_n;
  wire [3:0] ex2dut_serial_lane_p;

  wire [3:0] dut2ext_serial_lane_n;
  wire [3:0] dut2ext_serial_lane_p;

  `TEST_PROGRAM test();

  test_harness `TH (
    .drp_clk_out    (drp_clk),
    .ref_clk_out    (ref_clk),
    .device_clk_out (device_clk),
    .sysref_clk_out (sysref),

    .drp_clk(drp_clk),
    .device_clk(device_clk),
    .ref_clk(ref_clk),

    .sysref(sysref),

    .gt_bridge_ip_0_diff_gt_ref_clock_0_clk_p(ref_clk),
    .gt_bridge_ip_0_diff_gt_ref_clock_0_clk_n(~ref_clk),

    .GT_Serial_0_grx_n(ex2dut_serial_lane_n),
    .GT_Serial_0_grx_p(ex2dut_serial_lane_p),

    .GT_Serial_0_gtx_n(dut2ex_serial_lane_n),
    .GT_Serial_0_gtx_p(dut2ex_serial_lane_p),

    .rx_data_0_p(dut2ex_serial_lane_p[0]),
    .rx_data_0_n(dut2ex_serial_lane_n[0]),
    .rx_data_1_p(dut2ex_serial_lane_p[1]),
    .rx_data_1_n(dut2ex_serial_lane_n[1]),
    .rx_data_2_p(dut2ex_serial_lane_p[2]),
    .rx_data_2_n(dut2ex_serial_lane_n[2]),
    .rx_data_3_p(dut2ex_serial_lane_p[3]),
    .rx_data_3_n(dut2ex_serial_lane_n[3]),

    .tx_data_0_p(ex2dut_serial_lane_p[0]),
    .tx_data_0_n(ex2dut_serial_lane_n[0]),
    .tx_data_1_p(ex2dut_serial_lane_p[1]),
    .tx_data_1_n(ex2dut_serial_lane_n[1]),
    .tx_data_2_p(ex2dut_serial_lane_p[2]),
    .tx_data_2_n(ex2dut_serial_lane_n[2]),
    .tx_data_3_p(ex2dut_serial_lane_p[3]),
    .tx_data_3_n(ex2dut_serial_lane_n[3]),

    .dac_data_0(dac_data[SAMPLES_PER_CHANNEL*DMA_NP*0 +: SAMPLES_PER_CHANNEL*DMA_NP]),
    .dac_data_1(dac_data[SAMPLES_PER_CHANNEL*DMA_NP*1 +: SAMPLES_PER_CHANNEL*DMA_NP]),
    .dac_data_2(dac_data[SAMPLES_PER_CHANNEL*DMA_NP*2 +: SAMPLES_PER_CHANNEL*DMA_NP]),
    .dac_data_3(dac_data[SAMPLES_PER_CHANNEL*DMA_NP*3 +: SAMPLES_PER_CHANNEL*DMA_NP]),
    .dac_data_4(dac_data[SAMPLES_PER_CHANNEL*DMA_NP*4 +: SAMPLES_PER_CHANNEL*DMA_NP]),
    .dac_data_5(dac_data[SAMPLES_PER_CHANNEL*DMA_NP*5 +: SAMPLES_PER_CHANNEL*DMA_NP]),
    .dac_data_6(dac_data[SAMPLES_PER_CHANNEL*DMA_NP*6 +: SAMPLES_PER_CHANNEL*DMA_NP]),
    .dac_data_7(dac_data[SAMPLES_PER_CHANNEL*DMA_NP*7 +: SAMPLES_PER_CHANNEL*DMA_NP]),
    .dac_data_8(dac_data[SAMPLES_PER_CHANNEL*DMA_NP*8 +: SAMPLES_PER_CHANNEL*DMA_NP]),
    .dac_data_9(dac_data[SAMPLES_PER_CHANNEL*DMA_NP*9 +: SAMPLES_PER_CHANNEL*DMA_NP]),
    .dac_data_10 (dac_data[SAMPLES_PER_CHANNEL*DMA_NP*10 +: SAMPLES_PER_CHANNEL*DMA_NP]),
    .dac_data_11 (dac_data[SAMPLES_PER_CHANNEL*DMA_NP*11 +: SAMPLES_PER_CHANNEL*DMA_NP]),
    .dac_data_12 (dac_data[SAMPLES_PER_CHANNEL*DMA_NP*12 +: SAMPLES_PER_CHANNEL*DMA_NP]),
    .dac_data_13 (dac_data[SAMPLES_PER_CHANNEL*DMA_NP*13 +: SAMPLES_PER_CHANNEL*DMA_NP]),
    .dac_data_14 (dac_data[SAMPLES_PER_CHANNEL*DMA_NP*14 +: SAMPLES_PER_CHANNEL*DMA_NP]),
    .dac_data_15 (dac_data[SAMPLES_PER_CHANNEL*DMA_NP*15 +: SAMPLES_PER_CHANNEL*DMA_NP])
  );

  reg [DMA_NP-1:0] sample = 'h0;
  integer sample_couter = 0;
  always @(posedge device_clk) begin
    for (int i = 0; i < `JESD_M; i++) begin
      for (int j = 0; j < SAMPLES_PER_CHANNEL; j++) begin
        // First 256 sample is channel count on each nibble
        // Next 256 sample is channel count on MS nibble and incr pattern
        if (sample_couter[8]) begin
          sample[DMA_NP-1 -: 4] = i;
          sample[7:0] = sample_couter+j;
        end else begin
          sample = {4{i[3:0]}};
        end
        dac_data[DMA_NP*(SAMPLES_PER_CHANNEL*i+j) +:DMA_NP] = sample;
      end
    end
    sample_couter = sample_couter + SAMPLES_PER_CHANNEL;
  end

endmodule
