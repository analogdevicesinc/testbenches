// ***************************************************************************
// ***************************************************************************
// Copyright 2025 (c) Analog Devices, Inc. All rights reserved.
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

`ifndef FRAME_SHIFT_CNT
  `define FRAME_SHIFT_CNT 0
`endif

module system_tb();

  localparam DCO_HALF_PERIOD = 1;
  localparam FRAME_HALF_PERIOD = 4;
  localparam BITS_PER_CYCLE = 2 * 2;
  localparam LATENCY = 3;
  localparam FRAME_SHIFT_CNT = `FRAME_SHIFT_CNT;
  localparam FRAME_DELAY = FRAME_HALF_PERIOD + (8 - FRAME_SHIFT_CNT) * DCO_HALF_PERIOD + ((FRAME_SHIFT_CNT % 2) * DCO_HALF_PERIOD);
  localparam DATA_DELAY = FRAME_DELAY;

  reg sync_n = 1'b0;
  reg ssi_clk = 1'b0;
  reg frame_clk = 1'b1;
  reg div_clock = 1'b0;
  reg enable_pattern = 1'b0;
  reg tdd_ext_sync = 1'b0;
  reg dco_p = 1'b0;
  reg dco_n = 1'b1;
  reg frame_clock_p = 1'b0;
  reg frame_clock_n = 1'b0;
  reg late_signal_p = 1'b0;
  reg late_signal_n = 1'b0;

  `TEST_PROGRAM test();

  test_harness `TH (

    .dco_p (dco_p),
    .dco_n (dco_n),
    .d0a_p (da_p),
    .d0a_n (da_n),
    .d1a_p (db_p),
    .d1a_n (db_n),
    .sync_n (sync_n),
    .frame_p (frame_clock_p),
    .frame_n (frame_clock_n)
`ifdef TDD_EN
    ,.trig_fmc_in (tdd_ext_sync)
    ,.trig_fmc_out ()
`endif
  );

  reg sync_n_d = 1'b0;
  always @(*) sync_n_d <=  #25 sync_n;
  always @(*) dco_p <=  #3 ssi_clk;
  always @(*) dco_n <=  #3 ~ssi_clk;
  always @(*) frame_clock_p <= #3.5 frame_clk;
  always @(*) frame_clock_n <= #3.5 ~frame_clk;

  reg [2:0] ssi_edge_cnt = 3'd0;
  reg frame_sync_active = 1'b0;
  initial begin
    #1;
    @(posedge sync_n_d);
    $display("[TB] FRAME_SHIFT_CNT=%0d, FRAME_DELAY=%0d ns", FRAME_SHIFT_CNT, FRAME_DELAY);
    repeat(FRAME_DELAY + FRAME_HALF_PERIOD) begin
      #DCO_HALF_PERIOD;
      ssi_clk = ~ssi_clk;
    end
    frame_clk = ~frame_clk;
    ssi_edge_cnt = 3'd0;
    forever begin
      #DCO_HALF_PERIOD;
      ssi_clk = ~ssi_clk;
      if (ssi_edge_cnt == 3'd3) begin
        ssi_edge_cnt = 3'd0;
        #0;
        frame_clk = ~frame_clk;
      end else begin
        ssi_edge_cnt = ssi_edge_cnt + 1;
      end
    end
  end

  initial begin
    #1;
    @(posedge sync_n_d);
    while (sync_n_d) begin
      div_clock <= ~div_clock;
      #FRAME_HALF_PERIOD;
    end
  end

  always @(*) late_signal_p <= #3 div_clock;
  always @(*) late_signal_n <= #3 ~div_clock;

  reg [15:0] sample = 16'h1234;
  reg da_p_int = 1'b0;
  reg db_p_int = 1'b0;
  reg da_p = 1'b0;
  reg da_n = 1'b1;
  reg db_p = 1'b0;
  reg db_n = 1'b1;

  localparam real PI = 3.14159265358979;
  localparam SINE_AMPLITUDE = 8191;
  localparam SINE_OFFSET = 8192;
  localparam SINE_PERIOD = 64;

  function [15:0] calc_sine_sample;
    input [31:0] idx;
    real angle;
    real sine_val;
    integer result;
    begin
      angle = 2.0 * PI * $itor(idx) / $itor(SINE_PERIOD);
      sine_val = $sin(angle);
      result = SINE_OFFSET + $rtoi(sine_val * $itor(SINE_AMPLITUDE));
      if (result < 0) result = 0;
      if (result > 16383) result = 16383;
      calc_sine_sample = result[15:0];
    end
  endfunction

  always @(*) da_p <= #3.5 da_p_int;
  always @(*) da_n <= #3.5 ~da_p_int;
  always @(*) db_p <= #3.5 db_p_int;
  always @(*) db_n <= #3.5 ~db_p_int;

  reg [31:0] sample_count = 0;

`ifdef TDD_EN
  reg [31:0] laser_fire_sample_idx = 0;
  wire tdd_ch0_rising;
  reg tdd_ch0_d = 0;
  reg [15:0] sample_at_laser_fire = 0;
  reg [15:0] sample_at_gate_open = 0;
  reg [31:0] samples_captured_count = 0;
  reg laser_fired_marker = 0;
  reg gate_opened_marker = 0;
  always @(posedge `TH.axi_tdd_0.clk) begin
    tdd_ch0_d <= `TH.axi_tdd_0.tdd_channel_0;
  end
  assign tdd_ch0_rising = `TH.axi_tdd_0.tdd_channel_0 && !tdd_ch0_d;

  always @(posedge `TH.axi_tdd_0.clk) begin
    if (tdd_ch0_rising) begin
      laser_fire_sample_idx <= sample_count;
      sample_at_laser_fire <= `TH.axi_ada4355_adc.adc_data[15:0];
      laser_fired_marker <= 1'b1;
      $display("[TB] @%0t: LASER FIRED at sample_count=%0d, adc_data=0x%04h",
               $time, sample_count, `TH.axi_ada4355_adc.adc_data[15:0]);
    end else begin
      laser_fired_marker <= 1'b0;
    end
  end

  reg tdd_ch1_d = 0;
  wire tdd_ch1_rising;
  always @(posedge `TH.axi_tdd_0.clk) begin
    tdd_ch1_d <= `TH.axi_tdd_0.tdd_channel_1;
  end
  assign tdd_ch1_rising = `TH.axi_tdd_0.tdd_channel_1 && !tdd_ch1_d;

  reg tdd_ch1_active = 0;
  always @(posedge `TH.axi_tdd_0.clk) begin
    tdd_ch1_active <= `TH.axi_tdd_0.tdd_channel_1;
    if (tdd_ch1_rising) begin
      sample_at_gate_open <= `TH.axi_ada4355_adc.adc_data[15:0];
      gate_opened_marker <= 1'b1;
      $display("[TB] @%0t: ADC GATE OPENED at sample_count=%0d, adc_data=0x%04h",
               $time, sample_count, `TH.axi_ada4355_adc.adc_data[15:0]);
    end else begin
      gate_opened_marker <= 1'b0;
    end
  end

  reg dma_capture_active = 0;

  always @(posedge `TH.axi_ada4355_dma.fifo_wr_clk) begin
    if (tdd_ch1_rising) begin
      dma_capture_active <= 1;
      samples_captured_count <= 0;
    end else if (dma_capture_active && `TH.axi_ada4355_dma.fifo_wr_en) begin
      samples_captured_count <= samples_captured_count + 1;
      if (samples_captured_count < 3) begin
        $display("[TB] @%0t: SAMPLE CAPTURED #%0d: 0x%04h", $time, samples_captured_count, `TH.axi_ada4355_dma.fifo_wr_din);
      end
    end
  end
`endif

  initial begin
    @(posedge sync_n_d);
    sample = calc_sine_sample(0);
    $display("[TB] @%0t: Starting sine wave data generation", $time);
    $display("[TB] FRAME_SHIFT_CNT=%0d, DATA_DELAY=%0d ns", FRAME_SHIFT_CNT, DATA_DELAY);
    #DATA_DELAY;
    da_p_int <= sample[14];
    db_p_int <= sample[15];
    forever begin
      @(posedge ssi_clk);
      da_p_int <= sample[12];
      db_p_int <= sample[13];

      @(negedge ssi_clk);
      da_p_int <= sample[10];
      db_p_int <= sample[11];

      @(posedge ssi_clk);
      da_p_int <= sample[8];
      db_p_int <= sample[9];

      @(negedge ssi_clk);
      da_p_int <= sample[6];
      db_p_int <= sample[7];

      @(posedge ssi_clk);
      da_p_int <= sample[4];
      db_p_int <= sample[5];

      @(negedge ssi_clk);
      da_p_int <= sample[2];
      db_p_int <= sample[3];

      @(posedge ssi_clk);
      da_p_int <= sample[0];
      db_p_int <= sample[1];

      @(negedge ssi_clk);
      sample_count <= sample_count + 1;
      da_p_int <= sample[14];
      db_p_int <= sample[15];
      sample <= calc_sine_sample(sample_count + 1);
    end
  end

endmodule
