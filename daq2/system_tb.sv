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

  //localparam SAMPLES_PER_CHANNEL = (`RX_JESD_L*`LL_OUT_BYTES*8) / `JESD_M / `JESD_NP;
  localparam RX_DMA_NP = 16;
  localparam MAX_LANES = 16;
  localparam MAX_CHANNLES = 32;
  localparam RX_JESD_NP = 16;
  localparam RX_SAMPLES_PER_CHANNEL = (`RX_JESD_L*`LL_OUT_BYTES*8) / `RX_JESD_M / `RX_JESD_NP;

  //reg [`JESD_M*SAMPLES_PER_CHANNEL*DMA_NP-1:0] dac_data = 'h0;
  reg dac_sync = 1'b0; 

  reg [`RX_JESD_M*RX_SAMPLES_PER_CHANNEL*RX_DMA_NP-1:0] tx_ex_dac_data = 'h0; 

  wire rx_sync;
  wire tx_sync;

  wire [3:0] ex2dut_serial_lane_n;
  wire [3:0] ex2dut_serial_lane_p;

  wire [3:0] dut2ex_serial_lane_n;
  wire [3:0] dut2ex_serial_lane_p;

  `TEST_PROGRAM test();

  test_harness `TH (
    .tx_ref_clk_0(ref_clk),
    .rx_ref_clk_0(ref_clk),
    .ref_clk_out(ref_clk),
    .tx_device_clk_out(tx_device_clk),
    .rx_device_clk_out(rx_device_clk),
    .sysref_clk_out(sysref), 
    .sysref(sysref),  
    .ref_clk(ref_clk),
    .sys_rst(sys_rst), 

    .rx_data_0_p(ex2dut_serial_lane_p[0]),
    .rx_data_0_n(ex2dut_serial_lane_n[0]),
    .rx_data_1_p(ex2dut_serial_lane_p[1]),
    .rx_data_1_n(ex2dut_serial_lane_n[1]),
    .rx_data_2_p(ex2dut_serial_lane_p[2]),
    .rx_data_2_n(ex2dut_serial_lane_n[2]),
    .rx_data_3_p(ex2dut_serial_lane_p[3]),
    .rx_data_3_n(ex2dut_serial_lane_n[3]),    
    .rx_sysref_0(sysref),
    .rx_sync_0(tx_sync),

    .tx_data_0_p(dut2ex_serial_lane_p[0]),
    .tx_data_0_n(dut2ex_serial_lane_n[0]),
    .tx_data_1_p(dut2ex_serial_lane_p[1]),
    .tx_data_1_n(dut2ex_serial_lane_n[1]),
    .tx_data_2_p(dut2ex_serial_lane_p[2]),
    .tx_data_2_n(dut2ex_serial_lane_n[2]),
    .tx_data_3_p(dut2ex_serial_lane_p[3]),
    .tx_data_3_n(dut2ex_serial_lane_n[3]),
    .tx_sysref_0(sysref),
    .tx_sync_0(rx_sync),    

    .dac_data_0(tx_ex_dac_data[RX_SAMPLES_PER_CHANNEL*RX_DMA_NP*0 +: RX_SAMPLES_PER_CHANNEL*RX_DMA_NP]),
    .dac_data_1(tx_ex_dac_data[RX_SAMPLES_PER_CHANNEL*RX_DMA_NP*1 +: RX_SAMPLES_PER_CHANNEL*RX_DMA_NP])
  );

  reg [RX_DMA_NP-1:0] sample = 'h0;
  integer sample_counter = 0;
  always @(posedge tx_device_clk) begin
    for (int i = 0; i < `RX_JESD_M; i++) begin
      for (int j = 0; j < RX_SAMPLES_PER_CHANNEL; j++) begin
        // First 256 sample is channel count on each nibble
        // Next 256 sample is channel count on MS nibble and incr pattern
        //if (sample_counter[9] | 1) begin
        //  sample[RX_DMA_NP-1 -: 4] = i;
        //  sample[7:0] = sample_counter+j;
        //end else begin
        //  sample = {4{i[3:0]}};
        //end
        sample = i*RX_SAMPLES_PER_CHANNEL + j;
        tx_ex_dac_data[RX_DMA_NP*(RX_SAMPLES_PER_CHANNEL*i+j) +:RX_DMA_NP] = sample;
      end
    end
    //sample_counter = sample_counter + RX_SAMPLES_PER_CHANNEL;
  end

endmodule
