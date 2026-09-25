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

  wire [15:0] ex2dut_serial_lane_n;
  wire [15:0] ex2dut_serial_lane_p;

  wire [15:0] dut2ex_serial_lane_n;
  wire [15:0] dut2ex_serial_lane_p;

  `TEST_PROGRAM test();

  test_harness `TH (
    .ext_ddr_clk_out(ext_ddr_clk),
    .ref_clk_out(ref_clk_ex),
    .rx_device_clk_out(rx_device_clk),
    .tx_device_clk_out(tx_device_clk),
    .tx_link_clk_out(tx_link_clk),
    .tx_os_device_clk_out(tx_os_device_clk),
    .sysref_clk_out(sysref),

    .ext_ddr_clk(ext_ddr_clk),
    .rx_device_clk(rx_device_clk),
    .tx_device_clk(tx_device_clk),
    .tx_link_clk(tx_link_clk),
    .tx_os_device_clk(tx_os_device_clk),
    .ref_clk_a(ref_clk_ex),
    .ref_clk_b(ref_clk_ex),
    .ref_clk_c(ref_clk_ex),
    .ref_clk_d(ref_clk_ex),
    .ref_clk_ex(ref_clk_ex),
    .sysref(sysref),
    .tx_sysref_0(sysref),
    .rx_sysref_0(sysref),
    .rx_sysref_8(sysref),

    .core_clk_a(tx_device_clk),
    .core_clk_b(rx_device_clk),

    .tx_sync_0(rx_sync),
    .ex_rx_sync(rx_sync),

    .rx_sync_0(tx_sync),
    .ex_tx_sync(tx_sync),

    .rx_sync_8(tx_os_sync),
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
    .rx_data1_8_n(dut2ex_serial_lane_n[8]),
    .rx_data1_8_p(dut2ex_serial_lane_p[8]),
    .rx_data1_9_n(dut2ex_serial_lane_n[9]),
    .rx_data1_9_p(dut2ex_serial_lane_p[9]),
    .rx_data1_10_n(dut2ex_serial_lane_n[10]),
    .rx_data1_10_p(dut2ex_serial_lane_p[10]),
    .rx_data1_11_n(dut2ex_serial_lane_n[11]),
    .rx_data1_11_p(dut2ex_serial_lane_p[11]),
    .rx_data1_12_n(dut2ex_serial_lane_n[12]),
    .rx_data1_12_p(dut2ex_serial_lane_p[12]),
    .rx_data1_13_n(dut2ex_serial_lane_n[13]),
    .rx_data1_13_p(dut2ex_serial_lane_p[13]),
    .rx_data1_14_n(dut2ex_serial_lane_n[14]),
    .rx_data1_14_p(dut2ex_serial_lane_p[14]),
    .rx_data1_15_n(dut2ex_serial_lane_n[15]),
    .rx_data1_15_p(dut2ex_serial_lane_p[15]),

    .tx_data1_0_n(ex2dut_serial_lane_n[0]),
    .tx_data1_0_p(ex2dut_serial_lane_p[0]),
    .tx_data1_1_n(ex2dut_serial_lane_n[1]),
    .tx_data1_1_p(ex2dut_serial_lane_p[1]),
    .tx_data1_2_n(ex2dut_serial_lane_n[2]),
    .tx_data1_2_p(ex2dut_serial_lane_p[2]),
    .tx_data1_3_n(ex2dut_serial_lane_n[3]),
    .tx_data1_3_p(ex2dut_serial_lane_p[3]),
    .tx_data1_4_n(ex2dut_serial_lane_n[4]),
    .tx_data1_4_p(ex2dut_serial_lane_p[4]),
    .tx_data1_5_n(ex2dut_serial_lane_n[5]),
    .tx_data1_5_p(ex2dut_serial_lane_p[5]),
    .tx_data1_6_n(ex2dut_serial_lane_n[6]),
    .tx_data1_6_p(ex2dut_serial_lane_p[6]),
    .tx_data1_7_n(ex2dut_serial_lane_n[7]),
    .tx_data1_7_p(ex2dut_serial_lane_p[7]),

    .tx_os_data1_0_n(ex2dut_serial_lane_n[8]),
    .tx_os_data1_0_p(ex2dut_serial_lane_p[8]),
    .tx_os_data1_1_n(ex2dut_serial_lane_n[9]),
    .tx_os_data1_1_p(ex2dut_serial_lane_p[9]),
    .tx_os_data1_2_n(ex2dut_serial_lane_n[10]),
    .tx_os_data1_2_p(ex2dut_serial_lane_p[10]),
    .tx_os_data1_3_n(ex2dut_serial_lane_n[11]),
    .tx_os_data1_3_p(ex2dut_serial_lane_p[11]),
    .tx_os_data1_4_n(ex2dut_serial_lane_n[12]),
    .tx_os_data1_4_p(ex2dut_serial_lane_p[12]),
    .tx_os_data1_5_n(ex2dut_serial_lane_n[13]),
    .tx_os_data1_5_p(ex2dut_serial_lane_p[13]),
    .tx_os_data1_6_n(ex2dut_serial_lane_n[14]),
    .tx_os_data1_6_p(ex2dut_serial_lane_p[14]),
    .tx_os_data1_7_n(ex2dut_serial_lane_n[15]),
    .tx_os_data1_7_p(ex2dut_serial_lane_p[15]),

    .rx_data_0_n(ex2dut_serial_lane_n[0]),
    .rx_data_0_p(ex2dut_serial_lane_p[0]),
    .rx_data_1_n(ex2dut_serial_lane_n[1]),
    .rx_data_1_p(ex2dut_serial_lane_p[1]),
    .rx_data_2_n(ex2dut_serial_lane_n[8]),
    .rx_data_2_p(ex2dut_serial_lane_p[8]),
    .rx_data_3_n(ex2dut_serial_lane_n[9]),
    .rx_data_3_p(ex2dut_serial_lane_p[9]),
    .rx_data_4_n(ex2dut_serial_lane_n[2]),
    .rx_data_4_p(ex2dut_serial_lane_p[2]),
    .rx_data_5_n(ex2dut_serial_lane_n[3]),
    .rx_data_5_p(ex2dut_serial_lane_p[3]),
    .rx_data_6_n(ex2dut_serial_lane_n[10]),
    .rx_data_6_p(ex2dut_serial_lane_p[10]),
    .rx_data_7_n(ex2dut_serial_lane_n[11]),
    .rx_data_7_p(ex2dut_serial_lane_p[11]),
    .rx_data_8_n(ex2dut_serial_lane_n[4]),
    .rx_data_8_p(ex2dut_serial_lane_p[4]),
    .rx_data_9_n(ex2dut_serial_lane_n[5]),
    .rx_data_9_p(ex2dut_serial_lane_p[5]),
    .rx_data_10_n(ex2dut_serial_lane_n[12]),
    .rx_data_10_p(ex2dut_serial_lane_p[12]),
    .rx_data_11_n(ex2dut_serial_lane_n[13]),
    .rx_data_11_p(ex2dut_serial_lane_p[13]),
    .rx_data_12_n(ex2dut_serial_lane_n[6]),
    .rx_data_12_p(ex2dut_serial_lane_p[6]),
    .rx_data_13_n(ex2dut_serial_lane_n[7]),
    .rx_data_13_p(ex2dut_serial_lane_p[7]),
    .rx_data_14_n(ex2dut_serial_lane_n[14]),
    .rx_data_14_p(ex2dut_serial_lane_p[14]),
    .rx_data_15_n(ex2dut_serial_lane_n[15]),
    .rx_data_15_p(ex2dut_serial_lane_p[15]),

    .tx_data_0_n(dut2ex_serial_lane_n[0]),
    .tx_data_0_p(dut2ex_serial_lane_p[0]),
    .tx_data_1_n(dut2ex_serial_lane_n[1]),
    .tx_data_1_p(dut2ex_serial_lane_p[1]),
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
    .tx_data_8_n(dut2ex_serial_lane_n[8]),
    .tx_data_8_p(dut2ex_serial_lane_p[8]),
    .tx_data_9_n(dut2ex_serial_lane_n[9]),
    .tx_data_9_p(dut2ex_serial_lane_p[9]),
    .tx_data_10_n(dut2ex_serial_lane_n[10]),
    .tx_data_10_p(dut2ex_serial_lane_p[10]),
    .tx_data_11_n(dut2ex_serial_lane_n[11]),
    .tx_data_11_p(dut2ex_serial_lane_p[11]),
    .tx_data_12_n(dut2ex_serial_lane_n[12]),
    .tx_data_12_p(dut2ex_serial_lane_p[12]),
    .tx_data_13_n(dut2ex_serial_lane_n[13]),
    .tx_data_13_p(dut2ex_serial_lane_p[13]),
    .tx_data_14_n(dut2ex_serial_lane_n[14]),
    .tx_data_14_p(dut2ex_serial_lane_p[14]),
    .tx_data_15_n(dut2ex_serial_lane_n[15]),
    .tx_data_15_p(dut2ex_serial_lane_p[15]),

    .dac_data_0(tx_ex_dac_data[RX_SAMPLES_PER_CHANNEL*RX_DMA_NP*0 +: RX_SAMPLES_PER_CHANNEL*RX_DMA_NP]),
    .dac_data_1(tx_ex_dac_data[RX_SAMPLES_PER_CHANNEL*RX_DMA_NP*1 +: RX_SAMPLES_PER_CHANNEL*RX_DMA_NP]),
    .dac_data_2(tx_ex_dac_data[RX_SAMPLES_PER_CHANNEL*RX_DMA_NP*2 +: RX_SAMPLES_PER_CHANNEL*RX_DMA_NP]),
    .dac_data_3(tx_ex_dac_data[RX_SAMPLES_PER_CHANNEL*RX_DMA_NP*3 +: RX_SAMPLES_PER_CHANNEL*RX_DMA_NP]),
    .dac_data_4(tx_ex_dac_data[RX_SAMPLES_PER_CHANNEL*RX_DMA_NP*4 +: RX_SAMPLES_PER_CHANNEL*RX_DMA_NP]),
    .dac_data_5(tx_ex_dac_data[RX_SAMPLES_PER_CHANNEL*RX_DMA_NP*5 +: RX_SAMPLES_PER_CHANNEL*RX_DMA_NP]),
    .dac_data_6(tx_ex_dac_data[RX_SAMPLES_PER_CHANNEL*RX_DMA_NP*6 +: RX_SAMPLES_PER_CHANNEL*RX_DMA_NP]),
    .dac_data_7(tx_ex_dac_data[RX_SAMPLES_PER_CHANNEL*RX_DMA_NP*7 +: RX_SAMPLES_PER_CHANNEL*RX_DMA_NP]),
    .dac_data_8(tx_ex_dac_data[RX_SAMPLES_PER_CHANNEL*RX_DMA_NP*8 +: RX_SAMPLES_PER_CHANNEL*RX_DMA_NP]),
    .dac_data_9(tx_ex_dac_data[RX_SAMPLES_PER_CHANNEL*RX_DMA_NP*9 +: RX_SAMPLES_PER_CHANNEL*RX_DMA_NP]),
    .dac_data_10(tx_ex_dac_data[RX_SAMPLES_PER_CHANNEL*RX_DMA_NP*10 +: RX_SAMPLES_PER_CHANNEL*RX_DMA_NP]),
    .dac_data_11(tx_ex_dac_data[RX_SAMPLES_PER_CHANNEL*RX_DMA_NP*11 +: RX_SAMPLES_PER_CHANNEL*RX_DMA_NP]),
    .dac_data_12(tx_ex_dac_data[RX_SAMPLES_PER_CHANNEL*RX_DMA_NP*12 +: RX_SAMPLES_PER_CHANNEL*RX_DMA_NP]),
    .dac_data_13(tx_ex_dac_data[RX_SAMPLES_PER_CHANNEL*RX_DMA_NP*13 +: RX_SAMPLES_PER_CHANNEL*RX_DMA_NP]),
    .dac_data_14(tx_ex_dac_data[RX_SAMPLES_PER_CHANNEL*RX_DMA_NP*14 +: RX_SAMPLES_PER_CHANNEL*RX_DMA_NP]),
    .dac_data_15(tx_ex_dac_data[RX_SAMPLES_PER_CHANNEL*RX_DMA_NP*15 +: RX_SAMPLES_PER_CHANNEL*RX_DMA_NP]),

    .dac_os_data_0(tx_os_ex_dac_data[RX_OS_SAMPLES_PER_CHANNEL*RX_OS_DMA_NP*0 +: RX_OS_SAMPLES_PER_CHANNEL*RX_OS_DMA_NP]),
    .dac_os_data_1(tx_os_ex_dac_data[RX_OS_SAMPLES_PER_CHANNEL*RX_OS_DMA_NP*1 +: RX_OS_SAMPLES_PER_CHANNEL*RX_OS_DMA_NP]),
    .dac_os_data_2(tx_os_ex_dac_data[RX_OS_SAMPLES_PER_CHANNEL*RX_OS_DMA_NP*2 +: RX_OS_SAMPLES_PER_CHANNEL*RX_OS_DMA_NP]),
    .dac_os_data_3(tx_os_ex_dac_data[RX_OS_SAMPLES_PER_CHANNEL*RX_OS_DMA_NP*3 +: RX_OS_SAMPLES_PER_CHANNEL*RX_OS_DMA_NP]),
    .dac_os_data_4(tx_os_ex_dac_data[RX_OS_SAMPLES_PER_CHANNEL*RX_OS_DMA_NP*4 +: RX_OS_SAMPLES_PER_CHANNEL*RX_OS_DMA_NP]),
    .dac_os_data_5(tx_os_ex_dac_data[RX_OS_SAMPLES_PER_CHANNEL*RX_OS_DMA_NP*5 +: RX_OS_SAMPLES_PER_CHANNEL*RX_OS_DMA_NP]),
    .dac_os_data_6(tx_os_ex_dac_data[RX_OS_SAMPLES_PER_CHANNEL*RX_OS_DMA_NP*6 +: RX_OS_SAMPLES_PER_CHANNEL*RX_OS_DMA_NP]),
    .dac_os_data_7(tx_os_ex_dac_data[RX_OS_SAMPLES_PER_CHANNEL*RX_OS_DMA_NP*7 +: RX_OS_SAMPLES_PER_CHANNEL*RX_OS_DMA_NP]),
    .dac_os_data_8(tx_os_ex_dac_data[RX_OS_SAMPLES_PER_CHANNEL*RX_OS_DMA_NP*8 +: RX_OS_SAMPLES_PER_CHANNEL*RX_OS_DMA_NP]),
    .dac_os_data_9(tx_os_ex_dac_data[RX_OS_SAMPLES_PER_CHANNEL*RX_OS_DMA_NP*9 +: RX_OS_SAMPLES_PER_CHANNEL*RX_OS_DMA_NP]),
    .dac_os_data_10(tx_os_ex_dac_data[RX_OS_SAMPLES_PER_CHANNEL*RX_OS_DMA_NP*10 +: RX_OS_SAMPLES_PER_CHANNEL*RX_OS_DMA_NP]),
    .dac_os_data_11(tx_os_ex_dac_data[RX_OS_SAMPLES_PER_CHANNEL*RX_OS_DMA_NP*11 +: RX_OS_SAMPLES_PER_CHANNEL*RX_OS_DMA_NP]),
    .dac_os_data_12(tx_os_ex_dac_data[RX_OS_SAMPLES_PER_CHANNEL*RX_OS_DMA_NP*12 +: RX_OS_SAMPLES_PER_CHANNEL*RX_OS_DMA_NP]),
    .dac_os_data_13(tx_os_ex_dac_data[RX_OS_SAMPLES_PER_CHANNEL*RX_OS_DMA_NP*13 +: RX_OS_SAMPLES_PER_CHANNEL*RX_OS_DMA_NP]),
    .dac_os_data_14(tx_os_ex_dac_data[RX_OS_SAMPLES_PER_CHANNEL*RX_OS_DMA_NP*14 +: RX_OS_SAMPLES_PER_CHANNEL*RX_OS_DMA_NP]),
    .dac_os_data_15(tx_os_ex_dac_data[RX_OS_SAMPLES_PER_CHANNEL*RX_OS_DMA_NP*15 +: RX_OS_SAMPLES_PER_CHANNEL*RX_OS_DMA_NP])
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

