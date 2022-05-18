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

module system_tb #(
) ();

  localparam DCO_HALF_PERIOD = 10;
  localparam BITS_PER_CYCLE = (`SINGLE_LANE ? 1 : 2) * (`SDR_DDR_N==1 ? 1 : 2);
  localparam CNV_HALF_PERIOD = DCO_HALF_PERIOD * (20 / BITS_PER_CYCLE);
  localparam LATENCY = `SDR_DDR_N ? `SINGLE_LANE ? 6 : 5
                                  : `SINGLE_LANE ? 4 : 3;

  reg sync_n = 1'b0;
  reg ssi_clk = 1'b0;
  reg cnv_clk = 1'b0;

  reg dco_p = 1'b0;
  reg dco_n = 1'b1;

  `TEST_PROGRAM test();

  test_harness `TH (

    .dco_p (dco_p),
    .dco_n (dco_n),
    .da_p (da_p),
    .da_n (da_n),
    .db_p (db_p),
    .db_n (db_n),
    .sync_n (sync_n)

  );

  reg sync_n_d = 1'b0;
  // Add some transport delay to simulate PCB and clock chip propagation delay
  always @(*) sync_n_d <=  #25 sync_n;

  // Add transport delay to the DCO clock to simulate longer internal delay of
  // the clock path inside the FPGA
  always @(*) dco_p <=  #3 ssi_clk;
  always @(*) dco_n <=  #3 ~ssi_clk;

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

  initial begin
    while (1) begin
      #1;
      @(posedge sync_n_d);
      while (sync_n_d) begin
         cnv_clk <= ~cnv_clk;
         #CNV_HALF_PERIOD;
      end
      cnv_clk <= 1'b0;
    end
  end

  //
  // Data generation
  //
  reg [19:0] sample = 'h000001;
  reg da_p = 1'b0;
  reg da_n = 1'b1;
  reg db_p = 1'b0;
  reg db_n = 1'b1;

  `ifdef M1
  always @(negedge cnv_clk) begin
  `else
  always @(posedge cnv_clk) begin
  `endif
    repeat (LATENCY) @(posedge ssi_clk);
    fork
      drive_sample(sample);
    join_none
    #1;
    sample = sample + 1;
   // sample = {sample[18:0],sample[19]};
  end

  task automatic drive_sample(bit [19:0] sample_t);
    int num_lanes = (`SINGLE_LANE==1) ? 1 : 2;
    int bits_per_cycle = num_lanes * (`SDR_DDR_N==1 ? 1 : 2);
    for (int i = 19; i >= 0; i=i-bits_per_cycle) begin
      @(negedge ssi_clk);
      #1;
      da_p <= sample_t[i];
      da_n <= ~sample_t[i];
      if (`SINGLE_LANE == 0) begin
        db_p <= sample_t[i-1];
        db_n <= ~sample_t[i-1];
      end
      if (`SDR_DDR_N == 0) begin
        @(posedge ssi_clk);
        #1;
        if (`SINGLE_LANE == 1) begin
          da_p <= sample_t[i-1];
          da_n <= ~sample_t[i-1];
        end else begin
          da_p <= sample_t[i-2];
          da_n <= ~sample_t[i-2];
          db_p <= sample_t[i-3];
          db_n <= ~sample_t[i-3];
        end
      end
    end
  endtask

endmodule
