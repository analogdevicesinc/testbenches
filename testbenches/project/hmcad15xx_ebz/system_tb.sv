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

  localparam CLK_HALF_PERIOD = 1;
  localparam CNV_HALF_PERIOD = 4;

  reg        clk_p   = 'b0;
  reg        clk_n   = 'b0;
  reg        fclk_in_p  = 'b0;
  reg        fclk_in_n  = 'b0;
  reg  [7:0] adc_data_in_p  = 'hab;
  reg  [7:0] adc_data_in_n  = 'hab;
  reg        ssi_clk = 1'b0;
  reg        cnv_clk = 1'b0;

  `TEST_PROGRAM test();

  test_harness `TH (
    .clk_in_p(clk_p),
    .clk_in_n(clk_n),
    .fclk_p(fclk_in_p),
    .fclk_n(fclk_in_n),
    .data_in_p(adc_data_in_p),
    .data_in_n(adc_data_in_n));


  // Add transport delay to the DCO clock to simulate longer internal delay of
  // the clock path inside the FPGA
  always @(*) clk_p     <=    ssi_clk;
  always @(*) clk_n     <=   ~ssi_clk;
  always @(*) fclk_in_p <=  #0.5   cnv_clk;
  always @(*) fclk_in_n <=  #0.5  ~cnv_clk;



  //
  // Clock generation
  //

  initial begin
    while (1) begin
       ssi_clk <= ~ssi_clk;
       #CLK_HALF_PERIOD;
    end
    ssi_clk <= 1'b0;
  end

  initial begin
    while (1) begin
       cnv_clk <= ~cnv_clk;
       #CNV_HALF_PERIOD;
    end
    cnv_clk <= 1'b0;
  end

//
// FClock generation
//

reg [7:0] sample = 'h33;

always @(posedge cnv_clk) begin
    fork
      begin
         drive_sample(sample);
      end
    join_none
    #1;
    sample = sample + 1;
  end


task automatic drive_sample(bit [7:0] sample_t);

  for (int i = 7; i >= 0; i=i-2) begin

     @(negedge ssi_clk);
     #0.5;

      adc_data_in_p[0] <=  sample_t[i];
      adc_data_in_n[0] <= ~sample_t[i];
      adc_data_in_p[1] <=  sample_t[i];
      adc_data_in_n[1] <= ~sample_t[i];
      adc_data_in_p[2] <=  sample_t[i];
      adc_data_in_n[2] <= ~sample_t[i];
      adc_data_in_p[3] <=  sample_t[i];
      adc_data_in_n[3] <= ~sample_t[i];
      adc_data_in_p[4] <=  sample_t[i];
      adc_data_in_n[4] <= ~sample_t[i];
      adc_data_in_p[5] <=  sample_t[i];
      adc_data_in_n[5] <= ~sample_t[i];
      adc_data_in_p[6] <=  sample_t[i];
      adc_data_in_n[6] <= ~sample_t[i];
      adc_data_in_p[7] <=  sample_t[i];
      adc_data_in_n[7] <= ~sample_t[i];

     @(posedge ssi_clk);
     #0.5;
     adc_data_in_p[0] <=  sample_t[i-1];
     adc_data_in_n[0] <= ~sample_t[i-1];
     adc_data_in_p[1] <=  sample_t[i-1];
     adc_data_in_n[1] <= ~sample_t[i-1];
     adc_data_in_p[2] <=  sample_t[i-1];
     adc_data_in_n[2] <= ~sample_t[i-1];
     adc_data_in_p[3] <=  sample_t[i-1];
     adc_data_in_n[3] <= ~sample_t[i-1];
     adc_data_in_p[4] <=  sample_t[i-1];
     adc_data_in_n[4] <= ~sample_t[i-1];
     adc_data_in_p[5] <=  sample_t[i-1];
     adc_data_in_n[5] <= ~sample_t[i-1];
     adc_data_in_p[6] <=  sample_t[i-1];
     adc_data_in_n[6] <= ~sample_t[i-1];
     adc_data_in_p[7] <=  sample_t[i-1];
     adc_data_in_n[7] <= ~sample_t[i-1];
  end

endtask




endmodule
