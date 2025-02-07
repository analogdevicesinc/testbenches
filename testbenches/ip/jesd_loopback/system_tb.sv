// ***************************************************************************
// ***************************************************************************
// Copyright (C) 2014 - 2018 Analog Devices, Inc. All rights reserved.
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
//      https://github.com/analogdevicesinc/hdl/blob/main/LICENSE_ADIBSD
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
  localparam MAX_LANES = 16;
  localparam MAX_CHANNLES = 32;

  reg [`JESD_M*SAMPLES_PER_CHANNEL*DMA_NP-1:0] dac_data = 'h0;
  reg ext_sync = 1'b0;

  reg sysref_s = 1'b0;
  reg sysref_d = 1'b0;
  reg [1:0] sysref_dly_sel = 2'b00;

  always @(posedge device_clk) begin
    sysref_d <= sysref;
  end

  always @(*) begin
    case (sysref_dly_sel)
      2'b00: begin
        sysref_s = sysref;
      end
      2'b01: begin
        sysref_s = sysref_d;
      end
      2'b10: begin
        sysref_s = ~sysref;
      end
      default: begin
        sysref_s = sysref;
      end
    endcase
  end

  `TEST_PROGRAM test();

  test_harness `TH (
    .ref_clk_out    (ref_clk),
    .device_clk_out (device_clk),
    .sysref_clk_out (sysref),

    .ref_clk(ref_clk),
    .device_clk(device_clk),

    .rx_data_0_p(data_0_p),
    .rx_data_0_n(data_0_n),
    .rx_data_1_p(data_1_p),
    .rx_data_1_n(data_1_n),
    .rx_data_2_p(data_2_p),
    .rx_data_2_n(data_2_n),
    .rx_data_3_p(data_3_p),
    .rx_data_3_n(data_3_n),
    .rx_data_4_p(data_4_p),
    .rx_data_4_n(data_4_n),
    .rx_data_5_p(data_5_p),
    .rx_data_5_n(data_5_n),
    .rx_data_6_p(data_6_p),
    .rx_data_6_n(data_6_n),
    .rx_data_7_p(data_7_p),
    .rx_data_7_n(data_7_n),
    .rx_data_8_p(data_8_p),
    .rx_data_8_n(data_8_n),
    .rx_data_9_p(data_9_p),
    .rx_data_9_n(data_9_n),
    .rx_data_10_p(data_10_p),
    .rx_data_10_n(data_10_n),
    .rx_data_11_p(data_11_p),
    .rx_data_11_n(data_11_n),
    .rx_data_12_p(data_12_p),
    .rx_data_12_n(data_12_n),
    .rx_data_13_p(data_13_p),
    .rx_data_13_n(data_13_n),
    .rx_data_14_p(data_14_p),
    .rx_data_14_n(data_14_n),
    .rx_data_15_p(data_15_p),
    .rx_data_15_n(data_15_n),
    .rx_sysref_0(sysref_s),
    .rx_sync_0(sync_0),

    .tx_data_0_p(data_0_p),
    .tx_data_0_n(data_0_n),
    .tx_data_1_p(data_1_p),
    .tx_data_1_n(data_1_n),
    .tx_data_2_p(data_2_p),
    .tx_data_2_n(data_2_n),
    .tx_data_3_p(data_3_p),
    .tx_data_3_n(data_3_n),
    .tx_data_4_p(data_4_p),
    .tx_data_4_n(data_4_n),
    .tx_data_5_p(data_5_p),
    .tx_data_5_n(data_5_n),
    .tx_data_6_p(data_6_p),
    .tx_data_6_n(data_6_n),
    .tx_data_7_p(data_7_p),
    .tx_data_7_n(data_7_n),
    .tx_data_8_p(data_8_p),
    .tx_data_8_n(data_8_n),
    .tx_data_9_p(data_9_p),
    .tx_data_9_n(data_9_n),
    .tx_data_10_p(data_10_p),
    .tx_data_10_n(data_10_n),
    .tx_data_11_p(data_11_p),
    .tx_data_11_n(data_11_n),
    .tx_data_12_p(data_12_p),
    .tx_data_12_n(data_12_n),
    .tx_data_13_p(data_13_p),
    .tx_data_13_n(data_13_n),
    .tx_data_14_p(data_14_p),
    .tx_data_14_n(data_14_n),
    .tx_data_15_p(data_15_p),
    .tx_data_15_n(data_15_n),
    .tx_sysref_0(sysref_s),
    .tx_sync_0(sync_0),

    .ext_sync_in(ext_sync),

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
    .dac_data_10(dac_data[SAMPLES_PER_CHANNEL*DMA_NP*10 +: SAMPLES_PER_CHANNEL*DMA_NP]),
    .dac_data_11(dac_data[SAMPLES_PER_CHANNEL*DMA_NP*11 +: SAMPLES_PER_CHANNEL*DMA_NP]),
    .dac_data_12(dac_data[SAMPLES_PER_CHANNEL*DMA_NP*12 +: SAMPLES_PER_CHANNEL*DMA_NP]),
    .dac_data_13(dac_data[SAMPLES_PER_CHANNEL*DMA_NP*13 +: SAMPLES_PER_CHANNEL*DMA_NP]),
    .dac_data_14(dac_data[SAMPLES_PER_CHANNEL*DMA_NP*14 +: SAMPLES_PER_CHANNEL*DMA_NP]),
    .dac_data_15(dac_data[SAMPLES_PER_CHANNEL*DMA_NP*15 +: SAMPLES_PER_CHANNEL*DMA_NP]),
    .dac_data_16(dac_data[SAMPLES_PER_CHANNEL*DMA_NP*16 +: SAMPLES_PER_CHANNEL*DMA_NP]),
    .dac_data_17(dac_data[SAMPLES_PER_CHANNEL*DMA_NP*17 +: SAMPLES_PER_CHANNEL*DMA_NP]),
    .dac_data_18(dac_data[SAMPLES_PER_CHANNEL*DMA_NP*18 +: SAMPLES_PER_CHANNEL*DMA_NP]),
    .dac_data_19(dac_data[SAMPLES_PER_CHANNEL*DMA_NP*19 +: SAMPLES_PER_CHANNEL*DMA_NP]),
    .dac_data_20(dac_data[SAMPLES_PER_CHANNEL*DMA_NP*20 +: SAMPLES_PER_CHANNEL*DMA_NP]),
    .dac_data_21(dac_data[SAMPLES_PER_CHANNEL*DMA_NP*21 +: SAMPLES_PER_CHANNEL*DMA_NP]),
    .dac_data_22(dac_data[SAMPLES_PER_CHANNEL*DMA_NP*22 +: SAMPLES_PER_CHANNEL*DMA_NP]),
    .dac_data_23(dac_data[SAMPLES_PER_CHANNEL*DMA_NP*23 +: SAMPLES_PER_CHANNEL*DMA_NP]),
    .dac_data_24(dac_data[SAMPLES_PER_CHANNEL*DMA_NP*24 +: SAMPLES_PER_CHANNEL*DMA_NP]),
    .dac_data_25(dac_data[SAMPLES_PER_CHANNEL*DMA_NP*25 +: SAMPLES_PER_CHANNEL*DMA_NP]),
    .dac_data_26(dac_data[SAMPLES_PER_CHANNEL*DMA_NP*26 +: SAMPLES_PER_CHANNEL*DMA_NP]),
    .dac_data_27(dac_data[SAMPLES_PER_CHANNEL*DMA_NP*27 +: SAMPLES_PER_CHANNEL*DMA_NP]),
    .dac_data_28(dac_data[SAMPLES_PER_CHANNEL*DMA_NP*28 +: SAMPLES_PER_CHANNEL*DMA_NP]),
    .dac_data_29(dac_data[SAMPLES_PER_CHANNEL*DMA_NP*29 +: SAMPLES_PER_CHANNEL*DMA_NP]),
    .dac_data_30(dac_data[SAMPLES_PER_CHANNEL*DMA_NP*30 +: SAMPLES_PER_CHANNEL*DMA_NP]),
    .dac_data_31(dac_data[SAMPLES_PER_CHANNEL*DMA_NP*31 +: SAMPLES_PER_CHANNEL*DMA_NP])
  );

  reg [DMA_NP-1:0] sample = 'h0;
  integer sample_couter = 0;
  always @(posedge device_clk) begin
    for (int i = 0; i < `JESD_M; i++) begin
      for (int j = 0; j < SAMPLES_PER_CHANNEL; j++) begin
        // First 256 sample is channel count on each nibble
        // Next 256 sample is channel count on MS nibble and incr pattern
        if (sample_couter[9] | 1) begin
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
