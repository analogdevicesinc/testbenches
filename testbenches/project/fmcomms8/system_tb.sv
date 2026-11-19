// ***************************************************************************
// ***************************************************************************
// Copyright (C) 2014-2025 Analog Devices, Inc. All rights reserved.
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

  localparam RX_SAMPLES_PER_CHANNEL = (`RX_JESD_L*`LL_OUT_BYTES*8) / `RX_JESD_M / `RX_JESD_NP;
  localparam RX_DMA_NP = `RX_JESD_NP == 12 ? 16 : `RX_JESD_NP;

  localparam RX_OS_SAMPLES_PER_CHANNEL = (`RX_OS_JESD_L*`LL_OUT_BYTES1*8) / `RX_OS_JESD_M / `RX_OS_JESD_NP;
  localparam RX_OS_DMA_NP = `RX_OS_JESD_NP == 12 ? 16 : `RX_OS_JESD_NP;

  reg [`RX_JESD_M*RX_SAMPLES_PER_CHANNEL*RX_DMA_NP-1:0] tx_ex_dac_data = 'h0;
  reg [`RX_OS_JESD_M*RX_OS_SAMPLES_PER_CHANNEL*RX_OS_DMA_NP-1:0] tx_os_ex_dac_data = 'h0;

  wire rx_sync;
  wire tx_sync;
  wire tx_os_sync;

  wire [7:0] ex2dut_serial_lane_n;
  wire [7:0] ex2dut_serial_lane_p;

  wire [7:0] dut2ex_serial_lane_n;
  wire [7:0] dut2ex_serial_lane_p;

  `TEST_PROGRAM test();

  test_harness `TH (
    .ref_clk_c(ref_clk_ex),
    .ref_clk_d(ref_clk_ex),
    .ref_clk_out(ref_clk_ex),
    .rx_device_clk_out(rx_device_clk),
    .tx_device_clk_out(tx_device_clk),
    .tx_link_clk_out(tx_link_clk),
    .tx_os_device_clk_out(tx_os_device_clk),
    .sysref_clk_out(sysref),

    .rx_device_clk(rx_device_clk),
    .tx_device_clk(tx_device_clk),
    .tx_link_clk(tx_link_clk),
    .tx_os_device_clk(tx_os_device_clk),
    .core_clk_c(tx_device_clk),
    .core_clk_d(rx_device_clk),
    .ref_clk_ex(ref_clk_ex),
    .sysref(sysref),
    .tx_sysref_0(sysref),
    .rx_sysref_0(sysref),
    .rx_sysref_4(sysref),

    .tx_sync_0(rx_sync),
    .ex_rx_sync(rx_sync),

    .rx_sync_0(tx_sync),
    .ex_tx_sync(tx_sync),

    .rx_sync_4(tx_os_sync),
    .ex_tx_os_sync(tx_os_sync),

    .rx_data1_0_n(dut2ex_serial_lane_n[0]),
    .rx_data1_0_p(dut2ex_serial_lane_p[0]),
    .rx_data1_1_n(dut2ex_serial_lane_n[1]),
    .rx_data1_1_p(dut2ex_serial_lane_p[1]),
    .rx_data1_2_n(dut2ex_serial_lane_n[2]),
    .rx_data1_2_p(dut2ex_serial_lane_p[2]),
    .rx_data1_3_n(dut2ex_serial_lane_n[3]),
    .rx_data1_3_p(dut2ex_serial_lane_p[3]),
    .rx_data1_4_n(dut2ex_serial_lane_n[4]),
    .rx_data1_4_p(dut2ex_serial_lane_p[4]),
    .rx_data1_5_n(dut2ex_serial_lane_n[5]),
    .rx_data1_5_p(dut2ex_serial_lane_p[5]),
    .rx_data1_6_n(dut2ex_serial_lane_n[6]),
    .rx_data1_6_p(dut2ex_serial_lane_p[6]),
    .rx_data1_7_n(dut2ex_serial_lane_n[7]),
    .rx_data1_7_p(dut2ex_serial_lane_p[7]),

    .tx_data1_0_n(ex2dut_serial_lane_n[0]),
    .tx_data1_0_p(ex2dut_serial_lane_p[0]),
    .tx_data1_1_n(ex2dut_serial_lane_n[1]),
    .tx_data1_1_p(ex2dut_serial_lane_p[1]),
    .tx_data1_2_n(ex2dut_serial_lane_n[2]),
    .tx_data1_2_p(ex2dut_serial_lane_p[2]),
    .tx_data1_3_n(ex2dut_serial_lane_n[3]),
    .tx_data1_3_p(ex2dut_serial_lane_p[3]),

    .tx_os_data1_0_n(ex2dut_serial_lane_n[4]),
    .tx_os_data1_0_p(ex2dut_serial_lane_p[4]),
    .tx_os_data1_1_n(ex2dut_serial_lane_n[5]),
    .tx_os_data1_1_p(ex2dut_serial_lane_p[5]),
    .tx_os_data1_2_n(ex2dut_serial_lane_n[6]),
    .tx_os_data1_2_p(ex2dut_serial_lane_p[6]),
    .tx_os_data1_3_n(ex2dut_serial_lane_n[7]),
    .tx_os_data1_3_p(ex2dut_serial_lane_p[7]),

    .rx_data_0_n(ex2dut_serial_lane_n[0]),
    .rx_data_0_p(ex2dut_serial_lane_p[0]),
    .rx_data_1_n(ex2dut_serial_lane_n[1]),
    .rx_data_1_p(ex2dut_serial_lane_p[1]),
    .rx_data_2_n(ex2dut_serial_lane_n[4]),
    .rx_data_2_p(ex2dut_serial_lane_p[4]),
    .rx_data_3_n(ex2dut_serial_lane_n[5]),
    .rx_data_3_p(ex2dut_serial_lane_p[5]),
    .rx_data_4_n(ex2dut_serial_lane_n[2]),
    .rx_data_4_p(ex2dut_serial_lane_p[2]),
    .rx_data_5_n(ex2dut_serial_lane_n[3]),
    .rx_data_5_p(ex2dut_serial_lane_p[3]),
    .rx_data_6_n(ex2dut_serial_lane_n[6]),
    .rx_data_6_p(ex2dut_serial_lane_p[6]),
    .rx_data_7_n(ex2dut_serial_lane_n[7]),
    .rx_data_7_p(ex2dut_serial_lane_p[7]),

    .tx_data_0_n(dut2ex_serial_lane_n[1]),
    .tx_data_0_p(dut2ex_serial_lane_p[1]),
    .tx_data_1_n(dut2ex_serial_lane_n[0]),
    .tx_data_1_p(dut2ex_serial_lane_p[0]),
    .tx_data_2_n(dut2ex_serial_lane_n[2]),
    .tx_data_2_p(dut2ex_serial_lane_p[2]),
    .tx_data_3_n(dut2ex_serial_lane_n[3]),
    .tx_data_3_p(dut2ex_serial_lane_p[3]),
    .tx_data_4_n(dut2ex_serial_lane_n[4]),
    .tx_data_4_p(dut2ex_serial_lane_p[4]),
    .tx_data_5_n(dut2ex_serial_lane_n[5]),
    .tx_data_5_p(dut2ex_serial_lane_p[5]),
    .tx_data_6_n(dut2ex_serial_lane_n[6]),
    .tx_data_6_p(dut2ex_serial_lane_p[6]),
    .tx_data_7_n(dut2ex_serial_lane_n[7]),
    .tx_data_7_p(dut2ex_serial_lane_p[7]),

    .dac_data_0(tx_ex_dac_data[RX_SAMPLES_PER_CHANNEL*RX_DMA_NP*0 +: RX_SAMPLES_PER_CHANNEL*RX_DMA_NP]),
    .dac_data_1(tx_ex_dac_data[RX_SAMPLES_PER_CHANNEL*RX_DMA_NP*1 +: RX_SAMPLES_PER_CHANNEL*RX_DMA_NP]),
    .dac_data_2(tx_ex_dac_data[RX_SAMPLES_PER_CHANNEL*RX_DMA_NP*2 +: RX_SAMPLES_PER_CHANNEL*RX_DMA_NP]),
    .dac_data_3(tx_ex_dac_data[RX_SAMPLES_PER_CHANNEL*RX_DMA_NP*3 +: RX_SAMPLES_PER_CHANNEL*RX_DMA_NP]),
    .dac_data_4(tx_ex_dac_data[RX_SAMPLES_PER_CHANNEL*RX_DMA_NP*4 +: RX_SAMPLES_PER_CHANNEL*RX_DMA_NP]),
    .dac_data_5(tx_ex_dac_data[RX_SAMPLES_PER_CHANNEL*RX_DMA_NP*5 +: RX_SAMPLES_PER_CHANNEL*RX_DMA_NP]),
    .dac_data_6(tx_ex_dac_data[RX_SAMPLES_PER_CHANNEL*RX_DMA_NP*6 +: RX_SAMPLES_PER_CHANNEL*RX_DMA_NP]),
    .dac_data_7(tx_ex_dac_data[RX_SAMPLES_PER_CHANNEL*RX_DMA_NP*7 +: RX_SAMPLES_PER_CHANNEL*RX_DMA_NP]),

    .dac_os_data_0(tx_os_ex_dac_data[RX_OS_SAMPLES_PER_CHANNEL*RX_OS_DMA_NP*0 +: RX_OS_SAMPLES_PER_CHANNEL*RX_OS_DMA_NP]),
    .dac_os_data_1(tx_os_ex_dac_data[RX_OS_SAMPLES_PER_CHANNEL*RX_OS_DMA_NP*1 +: RX_OS_SAMPLES_PER_CHANNEL*RX_OS_DMA_NP]),
    .dac_os_data_2(tx_os_ex_dac_data[RX_OS_SAMPLES_PER_CHANNEL*RX_OS_DMA_NP*2 +: RX_OS_SAMPLES_PER_CHANNEL*RX_OS_DMA_NP]),
    .dac_os_data_3(tx_os_ex_dac_data[RX_OS_SAMPLES_PER_CHANNEL*RX_OS_DMA_NP*3 +: RX_OS_SAMPLES_PER_CHANNEL*RX_OS_DMA_NP])
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

  reg [RX_OS_DMA_NP-1:0] sample1 = 'h0;
  integer sample_counter1 = 0;
  always @(posedge `TH.i_tx_os_jesd_exerciser.device_clk) begin
    for (int i = 0; i < `RX_OS_JESD_M; i++) begin
      for (int j = 0; j < RX_OS_SAMPLES_PER_CHANNEL; j++) begin
        // Test incrementing data on consecutive samples
        if (`TH.i_tx_os_jesd_exerciser.tx_tpl_core.dac_enable_0) begin
          sample1 = sample_counter1+`RX_OS_JESD_M*j+i;
        end else begin
          sample1 = 'h0;
        end
        tx_os_ex_dac_data[RX_OS_DMA_NP*(RX_OS_SAMPLES_PER_CHANNEL*i+j) +:RX_OS_DMA_NP] = sample1;
      end
    end
    sample_counter1 = sample_counter1 + `RX_OS_JESD_M*RX_OS_SAMPLES_PER_CHANNEL;
  end

endmodule

