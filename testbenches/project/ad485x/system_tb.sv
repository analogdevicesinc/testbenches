// ***************************************************************************
// ***************************************************************************
// Copyright (C) 2026 Analog Devices, Inc. All rights reserved.
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

`timescale 1ns/1ps

module system_tb();
  generate
    wire sys_200m_clk_tb;
    wire cnvs_tb;
    wire busy_tb;

    if (`LVDS_CMOS_N == 0) begin
      wire scki_tb;
      wire scko_tb;
      wire adc_lane_0_tb;
      wire adc_lane_1_tb;
      wire adc_lane_2_tb;
      wire adc_lane_3_tb;
      wire adc_lane_4_tb;
      wire adc_lane_5_tb;
      wire adc_lane_6_tb;
      wire adc_lane_7_tb;
      `TEST_PROGRAM test(
        .scki_tp(scki_tb),
        .cnvs_tp(cnvs_tb),
        .busy_tp(busy_tb),
        .scko_tp(scko_tb),
        .adc_lane_0_tp(adc_lane_0_tb),
        .adc_lane_1_tp(adc_lane_1_tb),
        .adc_lane_2_tp(adc_lane_2_tb),
        .adc_lane_3_tp(adc_lane_3_tb),
        .adc_lane_4_tp(adc_lane_4_tb),
        .adc_lane_5_tp(adc_lane_5_tb),
        .adc_lane_6_tp(adc_lane_6_tb),
        .adc_lane_7_tp(adc_lane_7_tb));
      test_harness `TH (
        .sys_200mhz_clk_out(sys_200m_clk_tb),
        .cnv(cnvs_tb),
        .busy(busy_tb),
        .scki(scki_tb),
        .scko(scko_tb),
        .adc_lane_0(adc_lane_0_tb),
        .adc_lane_1(adc_lane_1_tb),
        .adc_lane_2(adc_lane_2_tb),
        .adc_lane_3(adc_lane_3_tb),
        .adc_lane_4(adc_lane_4_tb),
        .adc_lane_5(adc_lane_5_tb),
        .adc_lane_6(adc_lane_6_tb),
        .adc_lane_7(adc_lane_7_tb));
    end
    else begin
      wire scki_p_tb;
      wire scki_n_tb;
      wire scko_p_tb;
      wire scko_n_tb;
      wire sdo_p_tb;
      wire sdo_n_tb;
      `TEST_PROGRAM test(
        .scki_p_tp(scki_p_tb),
        .scki_n_tp(scki_n_tb),
        .cnvs_tp(cnvs_tb),
        .busy_tp(busy_tb),
        .scko_p_tp(scko_p_tb),
        .scko_n_tp(scko_n_tb),
        .sdo_p_tp(sdo_p_tb),
        .sdo_n_tp(sdo_n_tb));
      test_harness `TH (
        .sys_200mhz_clk_out(sys_200m_clk_tb),
        .cnv(cnvs_tb),
        .scki_p(scki_p_tb),
        .scki_n(scki_n_tb),
        .busy(busy_tb),
        .scko_p(scko_p_tb),
        .scko_n(scko_n_tb),
        .sdo_p(sdo_p_tb),
        .sdo_n(sdo_n_tb));
    end
  endgenerate
endmodule
