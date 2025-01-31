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

`ifndef EN_UNCOR
    `define EN_UNCOR 0
`endif

module system_tb #(
) ();

  localparam DCO_HALF_PERIOD = 1; // Period 2 ns -> 500 MHz DCO
  localparam FRAME_HALF_PERIOD = 4; // Period 8 ns -> 125 MHz Frame
  localparam BITS_PER_CYCLE = 2 * 2;
  //localparam CNV_HALF_PERIOD_COR = DCO_HALF_PERIOD * (20 / BITS_PER_CYCLE);
  //localparam CNV_HALF_PERIOD = `EN_UNCOR ? 4 * CNV_HALF_PERIOD_COR : CNV_HALF_PERIOD_COR;
  localparam LATENCY = 3;                              

  reg sync_n = 1'b0;
  reg ssi_clk = 1'b0;
  reg frame_clk = 1'b0;
  reg div_clock = 1'b0;
  reg enable_pattern = 1'b0;
  reg dco_p = 1'b0;
  reg dco_n = 1'b1;
  reg frame_clock_p = 1'b0;
  reg frame_clock_n = 1'b0;

  `TEST_PROGRAM test();

  test_harness `TH (

    .dco_p (dco_p),
    .dco_n (dco_n),
    .da_p (da_p),
    .da_n (da_n),
    .db_p (db_p),
    .db_n (db_n),
    .sync_n (sync_n),
    .frame_clock_p(frame_clock_p),
    .frame_clock_n(frame_clock_n)
  );

  reg sync_n_d = 1'b0;
  // Add some transport delay to simulate PCB and clock chip propagation delay
  always @(*) sync_n_d <=  #25 sync_n;

  // Add transport delay to the DCO clock to simulate longer internal delay of
  // the clock path inside the FPGA
  always @(*) dco_p <=  #3 ssi_clk;
  always @(*) dco_n <=  #3 ~ssi_clk;

  always @(*) frame_clock_p <=  frame_clk;
  always @(*) frame_clock_n <= ~frame_clk;

  //
  // Clock generation
  //
  // Start clocks with rising edge once sync_n_d deasserts
  initial begin
    #1;
    @(posedge sync_n_d);
    while (sync_n_d) begin
       ssi_clk <= ~ssi_clk;
       #DCO_HALF_PERIOD;
    end
    ssi_clk <= 1'b0;
  end

  // Starts frame clock

  initial begin
    #1;
    @(posedge sync_n_d);
    while (sync_n_d) begin
      frame_clk <= ~frame_clk;
      #FRAME_HALF_PERIOD;
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

  //
  // Data generation
  //
  reg [15:0] sample = 16'h0;
//  reg [15:0] sample = 16'haaa8;

  reg da_p = 1'b0;
  reg da_n = 1'b1;
  reg db_p = 1'b0;
  reg db_n = 1'b1;
  wire [15:0] final_sample;
  assign final_sample = /*(enable_pattern) ? 8'hF0 :*/ sample;
  always @(posedge frame_clock_p) begin
    repeat (LATENCY) @(posedge ssi_clk);
    fork
      begin
        /*if (`EN_UNCOR) begin
          // Drive uncorrected data
          drive_sample({20{1'b1}});
          drive_sample(~sample);
          drive_sample({20{1'b0}});
        end*/
         drive_sample(final_sample);
      end
    join_none
    #1;
    
//    if (sample [15]==1) begin
//        sample = sample >> 1;
//    end else begin
//        sample =16'haaa8;
//    end
    
    
    
    sample = ~sample;
    
    
   // sample = {sample[18:0],sample[19]};
  end

  task automatic drive_sample(bit [15:0] sample_t);
    int num_lanes = 2;
    int bits_per_cycle = num_lanes * 2;
    for (int i = 15; i >= 0; i=i-bits_per_cycle) begin // for (int i = 19; i >= 0;)
      @(negedge ssi_clk);
      #1;
      da_p <= sample_t[i];
      da_n <= ~sample_t[i];
      db_p <= sample_t[i-1];
      db_n <= ~sample_t[i-1];
      @(posedge ssi_clk);
      #1;
      da_p <= sample_t[i-2];
      da_n <= ~sample_t[i-2];
      db_p <= sample_t[i-3];
      db_n <= ~sample_t[i-3];
    end
  endtask

endmodule
