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

    if (`LVDS_CMOS_N == 0) begin
      // ADC 0 CMOS wires
      wire adc_0_scki_tb;
      wire adc_0_scko_tb;
      wire adc_0_cnv_tb;
      wire adc_0_busy_tb;
      wire adc_0_lane_0_tb;
      wire adc_0_lane_1_tb;
      wire adc_0_lane_2_tb;
      wire adc_0_lane_3_tb;
      wire adc_0_lane_4_tb;
      wire adc_0_lane_5_tb;
      wire adc_0_lane_6_tb;
      wire adc_0_lane_7_tb;
      // ADC 1 CMOS wires
      wire adc_1_scki_tb;
      wire adc_1_scko_tb;
      wire adc_1_cnv_tb;
      wire adc_1_busy_tb;
      wire adc_1_lane_0_tb;
      wire adc_1_lane_1_tb;
      wire adc_1_lane_2_tb;
      wire adc_1_lane_3_tb;
      wire adc_1_lane_4_tb;
      wire adc_1_lane_5_tb;
      wire adc_1_lane_6_tb;
      wire adc_1_lane_7_tb;
      `TEST_PROGRAM test(
        // ADC 0
        .adc_0_scki_tp(adc_0_scki_tb),
        .adc_0_cnvs_tp(adc_0_cnv_tb),
        .adc_0_busy_tp(adc_0_busy_tb),
        .adc_0_scko_tp(adc_0_scko_tb),
        .adc_0_lane_0_tp(adc_0_lane_0_tb),
        .adc_0_lane_1_tp(adc_0_lane_1_tb),
        .adc_0_lane_2_tp(adc_0_lane_2_tb),
        .adc_0_lane_3_tp(adc_0_lane_3_tb),
        .adc_0_lane_4_tp(adc_0_lane_4_tb),
        .adc_0_lane_5_tp(adc_0_lane_5_tb),
        .adc_0_lane_6_tp(adc_0_lane_6_tb),
        .adc_0_lane_7_tp(adc_0_lane_7_tb),
        // ADC 1
        .adc_1_scki_tp(adc_1_scki_tb),
        .adc_1_cnvs_tp(adc_1_cnv_tb),
        .adc_1_busy_tp(adc_1_busy_tb),
        .adc_1_scko_tp(adc_1_scko_tb),
        .adc_1_lane_0_tp(adc_1_lane_0_tb),
        .adc_1_lane_1_tp(adc_1_lane_1_tb),
        .adc_1_lane_2_tp(adc_1_lane_2_tb),
        .adc_1_lane_3_tp(adc_1_lane_3_tb),
        .adc_1_lane_4_tp(adc_1_lane_4_tb),
        .adc_1_lane_5_tp(adc_1_lane_5_tb),
        .adc_1_lane_6_tp(adc_1_lane_6_tb),
        .adc_1_lane_7_tp(adc_1_lane_7_tb));
      test_harness `TH (
        .sys_200mhz_clk_out(sys_200m_clk_tb),
        // ADC 0
        .adc_0_cnv(adc_0_cnv_tb),
        .adc_0_busy(adc_0_busy_tb),
        .adc_0_scki(adc_0_scki_tb),
        .adc_0_scko(adc_0_scko_tb),
        .adc_0_lane_0(adc_0_lane_0_tb),
        .adc_0_lane_1(adc_0_lane_1_tb),
        .adc_0_lane_2(adc_0_lane_2_tb),
        .adc_0_lane_3(adc_0_lane_3_tb),
        .adc_0_lane_4(adc_0_lane_4_tb),
        .adc_0_lane_5(adc_0_lane_5_tb),
        .adc_0_lane_6(adc_0_lane_6_tb),
        .adc_0_lane_7(adc_0_lane_7_tb),
        // ADC 1
        .adc_1_cnv(adc_1_cnv_tb),
        .adc_1_busy(adc_1_busy_tb),
        .adc_1_scki(adc_1_scki_tb),
        .adc_1_scko(adc_1_scko_tb),
        .adc_1_lane_0(adc_1_lane_0_tb),
        .adc_1_lane_1(adc_1_lane_1_tb),
        .adc_1_lane_2(adc_1_lane_2_tb),
        .adc_1_lane_3(adc_1_lane_3_tb),
        .adc_1_lane_4(adc_1_lane_4_tb),
        .adc_1_lane_5(adc_1_lane_5_tb),
        .adc_1_lane_6(adc_1_lane_6_tb),
        .adc_1_lane_7(adc_1_lane_7_tb));
    end
    else begin
      // ADC 0 LVDS wires
      wire adc_0_scki_p_tb;
      wire adc_0_scki_n_tb;
      wire adc_0_scko_p_tb;
      wire adc_0_scko_n_tb;
      wire adc_0_sdo_p_tb;
      wire adc_0_sdo_n_tb;
      wire adc_0_cnv_tb;
      wire adc_0_busy_tb;
      // ADC 1 LVDS wires
      wire adc_1_scki_p_tb;
      wire adc_1_scki_n_tb;
      wire adc_1_scko_p_tb;
      wire adc_1_scko_n_tb;
      wire adc_1_sdo_p_tb;
      wire adc_1_sdo_n_tb;
      wire adc_1_cnv_tb;
      wire adc_1_busy_tb;
      `TEST_PROGRAM test(
        // ADC 0
        .adc_0_scki_p_tp(adc_0_scki_p_tb),
        .adc_0_scki_n_tp(adc_0_scki_n_tb),
        .adc_0_cnvs_tp(adc_0_cnv_tb),
        .adc_0_busy_tp(adc_0_busy_tb),
        .adc_0_scko_p_tp(adc_0_scko_p_tb),
        .adc_0_scko_n_tp(adc_0_scko_n_tb),
        .adc_0_sdo_p_tp(adc_0_sdo_p_tb),
        .adc_0_sdo_n_tp(adc_0_sdo_n_tb),
        // ADC 1
        .adc_1_scki_p_tp(adc_1_scki_p_tb),
        .adc_1_scki_n_tp(adc_1_scki_n_tb),
        .adc_1_cnvs_tp(adc_1_cnv_tb),
        .adc_1_busy_tp(adc_1_busy_tb),
        .adc_1_scko_p_tp(adc_1_scko_p_tb),
        .adc_1_scko_n_tp(adc_1_scko_n_tb),
        .adc_1_sdo_p_tp(adc_1_sdo_p_tb),
        .adc_1_sdo_n_tp(adc_1_sdo_n_tb));
      test_harness `TH (
        .sys_200mhz_clk_out(sys_200m_clk_tb),
        // ADC 0
        .adc_0_cnv(adc_0_cnv_tb),
        .adc_0_busy(adc_0_busy_tb),
        .adc_0_scki_p(adc_0_scki_p_tb),
        .adc_0_scki_n(adc_0_scki_n_tb),
        .adc_0_scko_p(adc_0_scko_p_tb),
        .adc_0_scko_n(adc_0_scko_n_tb),
        .adc_0_sdo_p(adc_0_sdo_p_tb),
        .adc_0_sdo_n(adc_0_sdo_n_tb),
        // ADC 1
        .adc_1_cnv(adc_1_cnv_tb),
        .adc_1_busy(adc_1_busy_tb),
        .adc_1_scki_p(adc_1_scki_p_tb),
        .adc_1_scki_n(adc_1_scki_n_tb),
        .adc_1_scko_p(adc_1_scko_p_tb),
        .adc_1_scko_n(adc_1_scko_n_tb),
        .adc_1_sdo_p(adc_1_sdo_p_tb),
        .adc_1_sdo_n(adc_1_sdo_n_tb));
    end
  endgenerate
endmodule
