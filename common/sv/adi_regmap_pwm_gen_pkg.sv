// ***************************************************************************
// ***************************************************************************
// Copyright 2014 - 2023 (c) Analog Devices, Inc. All rights reserved.
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
/* Auto generated Register Map */
/* Wed Sep 21 10:12:17 2022 */

package adi_regmap_pwm_gen_pkg;
  import adi_regmap_pkg::*;


/* axi_pwm_gen */

  const reg_t REG_RSTN = '{ 'h0010, "REG_RSTN" , '{
    "LOAD_CONFIG": '{ 1, 1, WO, 'h0 },
    "RESET": '{ 0, 0, RW, 'h0 }}};
  `define SET_REG_RSTN_LOAD_CONFIG(x) SetField(REG_RSTN,"LOAD_CONFIG",x)
  `define GET_REG_RSTN_LOAD_CONFIG(x) GetField(REG_RSTN,"LOAD_CONFIG",x)
  `define SET_REG_RSTN_RESET(x) SetField(REG_RSTN,"RESET",x)
  `define GET_REG_RSTN_RESET(x) GetField(REG_RSTN,"RESET",x)

  const reg_t REG_N_PWMS = '{ 'h0014, "REG_N_PWMS" , '{
    "": '{ 31, 0, RO, 'h0000 }}};
  `define SET_REG_N_PWMS_(x) SetField(REG_N_PWMS,"",x)
  `define GET_REG_N_PWMS_(x) GetField(REG_N_PWMS,"",x)

  const reg_t REG_PULSE_0_PERIOD = '{ 'h0040, "REG_PULSE_0_PERIOD" , '{
    "PULSE_0_PERIOD": '{ 31, 0, RW, 'h0000 }}};
  `define SET_REG_PULSE_0_PERIOD_PULSE_0_PERIOD(x) SetField(REG_PULSE_0_PERIOD,"PULSE_0_PERIOD",x)
  `define GET_REG_PULSE_0_PERIOD_PULSE_0_PERIOD(x) GetField(REG_PULSE_0_PERIOD,"PULSE_0_PERIOD",x)

  const reg_t REG_PULSE_0_WIDTH = '{ 'h0080, "REG_PULSE_0_WIDTH" , '{
    "PULSE_0_WIDTH": '{ 31, 0, RW, 'h0000 }}};
  `define SET_REG_PULSE_0_WIDTH_PULSE_0_WIDTH(x) SetField(REG_PULSE_0_WIDTH,"PULSE_0_WIDTH",x)
  `define GET_REG_PULSE_0_WIDTH_PULSE_0_WIDTH(x) GetField(REG_PULSE_0_WIDTH,"PULSE_0_WIDTH",x)

  const reg_t REG_PULSE_0_OFFSET = '{ 'h00c0, "REG_PULSE_0_OFFSET" , '{
    "PULSE_0_OFFSET": '{ 31, 0, RW, 'h0000 }}};
  `define SET_REG_PULSE_0_OFFSET_PULSE_0_OFFSET(x) SetField(REG_PULSE_0_OFFSET,"PULSE_0_OFFSET",x)
  `define GET_REG_PULSE_0_OFFSET_PULSE_0_OFFSET(x) GetField(REG_PULSE_0_OFFSET,"PULSE_0_OFFSET",x)

  const reg_t REG_PULSE_1_PERIOD = '{ 'h0044, "REG_PULSE_1_PERIOD" , '{
    "PULSE_1_PERIOD": '{ 31, 0, RW, 'h0000 }}};
  `define SET_REG_PULSE_1_PERIOD_PULSE_1_PERIOD(x) SetField(REG_PULSE_1_PERIOD,"PULSE_1_PERIOD",x)
  `define GET_REG_PULSE_1_PERIOD_PULSE_1_PERIOD(x) GetField(REG_PULSE_1_PERIOD,"PULSE_1_PERIOD",x)

  const reg_t REG_PULSE_1_WIDTH = '{ 'h0084, "REG_PULSE_1_WIDTH" , '{
    "PULSE_1_WIDTH": '{ 31, 0, RW, 'h0000 }}};
  `define SET_REG_PULSE_1_WIDTH_PULSE_1_WIDTH(x) SetField(REG_PULSE_1_WIDTH,"PULSE_1_WIDTH",x)
  `define GET_REG_PULSE_1_WIDTH_PULSE_1_WIDTH(x) GetField(REG_PULSE_1_WIDTH,"PULSE_1_WIDTH",x)

  const reg_t REG_PULSE_1_OFFSET = '{ 'h00c4, "REG_PULSE_1_OFFSET" , '{
    "PULSE_1_OFFSET": '{ 31, 0, RW, 'h0000 }}};
  `define SET_REG_PULSE_1_OFFSET_PULSE_1_OFFSET(x) SetField(REG_PULSE_1_OFFSET,"PULSE_1_OFFSET",x)
  `define GET_REG_PULSE_1_OFFSET_PULSE_1_OFFSET(x) GetField(REG_PULSE_1_OFFSET,"PULSE_1_OFFSET",x)

  const reg_t REG_PULSE_2_PERIOD = '{ 'h0048, "REG_PULSE_2_PERIOD" , '{
    "PULSE_2_PERIOD": '{ 31, 0, RW, 'h0000 }}};
  `define SET_REG_PULSE_2_PERIOD_PULSE_2_PERIOD(x) SetField(REG_PULSE_2_PERIOD,"PULSE_2_PERIOD",x)
  `define GET_REG_PULSE_2_PERIOD_PULSE_2_PERIOD(x) GetField(REG_PULSE_2_PERIOD,"PULSE_2_PERIOD",x)

  const reg_t REG_PULSE_2_WIDTH = '{ 'h0088, "REG_PULSE_2_WIDTH" , '{
    "PULSE_2_WIDTH": '{ 31, 0, RW, 'h0000 }}};
  `define SET_REG_PULSE_2_WIDTH_PULSE_2_WIDTH(x) SetField(REG_PULSE_2_WIDTH,"PULSE_2_WIDTH",x)
  `define GET_REG_PULSE_2_WIDTH_PULSE_2_WIDTH(x) GetField(REG_PULSE_2_WIDTH,"PULSE_2_WIDTH",x)

  const reg_t REG_PULSE_2_OFFSET = '{ 'h00c8, "REG_PULSE_2_OFFSET" , '{
    "PULSE_2_OFFSET": '{ 31, 0, RW, 'h0000 }}};
  `define SET_REG_PULSE_2_OFFSET_PULSE_2_OFFSET(x) SetField(REG_PULSE_2_OFFSET,"PULSE_2_OFFSET",x)
  `define GET_REG_PULSE_2_OFFSET_PULSE_2_OFFSET(x) GetField(REG_PULSE_2_OFFSET,"PULSE_2_OFFSET",x)

  const reg_t REG_PULSE_3_PERIOD = '{ 'h004c, "REG_PULSE_3_PERIOD" , '{
    "PULSE_3_PERIOD": '{ 31, 0, RW, 'h0000 }}};
  `define SET_REG_PULSE_3_PERIOD_PULSE_3_PERIOD(x) SetField(REG_PULSE_3_PERIOD,"PULSE_3_PERIOD",x)
  `define GET_REG_PULSE_3_PERIOD_PULSE_3_PERIOD(x) GetField(REG_PULSE_3_PERIOD,"PULSE_3_PERIOD",x)

  const reg_t REG_PULSE_3_WIDTH = '{ 'h008c, "REG_PULSE_3_WIDTH" , '{
    "PULSE_3_WIDTH": '{ 31, 0, RW, 'h0000 }}};
  `define SET_REG_PULSE_3_WIDTH_PULSE_3_WIDTH(x) SetField(REG_PULSE_3_WIDTH,"PULSE_3_WIDTH",x)
  `define GET_REG_PULSE_3_WIDTH_PULSE_3_WIDTH(x) GetField(REG_PULSE_3_WIDTH,"PULSE_3_WIDTH",x)

  const reg_t REG_PULSE_3_OFFSET = '{ 'h00cc, "REG_PULSE_3_OFFSET" , '{
    "PULSE_3_OFFSET": '{ 31, 0, RW, 'h0000 }}};
  `define SET_REG_PULSE_3_OFFSET_PULSE_3_OFFSET(x) SetField(REG_PULSE_3_OFFSET,"PULSE_3_OFFSET",x)
  `define GET_REG_PULSE_3_OFFSET_PULSE_3_OFFSET(x) GetField(REG_PULSE_3_OFFSET,"PULSE_3_OFFSET",x)

  const reg_t REG_PULSE_4_PERIOD = '{ 'h0050, "REG_PULSE_4_PERIOD" , '{
    "PULSE_4_PERIOD": '{ 31, 0, RW, 'h0000 }}};
  `define SET_REG_PULSE_4_PERIOD_PULSE_4_PERIOD(x) SetField(REG_PULSE_4_PERIOD,"PULSE_4_PERIOD",x)
  `define GET_REG_PULSE_4_PERIOD_PULSE_4_PERIOD(x) GetField(REG_PULSE_4_PERIOD,"PULSE_4_PERIOD",x)

  const reg_t REG_PULSE_4_WIDTH = '{ 'h0090, "REG_PULSE_4_WIDTH" , '{
    "PULSE_4_WIDTH": '{ 31, 0, RW, 'h0000 }}};
  `define SET_REG_PULSE_4_WIDTH_PULSE_4_WIDTH(x) SetField(REG_PULSE_4_WIDTH,"PULSE_4_WIDTH",x)
  `define GET_REG_PULSE_4_WIDTH_PULSE_4_WIDTH(x) GetField(REG_PULSE_4_WIDTH,"PULSE_4_WIDTH",x)

  const reg_t REG_PULSE_4_OFFSET = '{ 'h00d0, "REG_PULSE_4_OFFSET" , '{
    "PULSE_4_OFFSET": '{ 31, 0, RW, 'h0000 }}};
  `define SET_REG_PULSE_4_OFFSET_PULSE_4_OFFSET(x) SetField(REG_PULSE_4_OFFSET,"PULSE_4_OFFSET",x)
  `define GET_REG_PULSE_4_OFFSET_PULSE_4_OFFSET(x) GetField(REG_PULSE_4_OFFSET,"PULSE_4_OFFSET",x)

  const reg_t REG_PULSE_5_PERIOD = '{ 'h0054, "REG_PULSE_5_PERIOD" , '{
    "PULSE_5_PERIOD": '{ 31, 0, RW, 'h0000 }}};
  `define SET_REG_PULSE_5_PERIOD_PULSE_5_PERIOD(x) SetField(REG_PULSE_5_PERIOD,"PULSE_5_PERIOD",x)
  `define GET_REG_PULSE_5_PERIOD_PULSE_5_PERIOD(x) GetField(REG_PULSE_5_PERIOD,"PULSE_5_PERIOD",x)

  const reg_t REG_PULSE_5_WIDTH = '{ 'h0094, "REG_PULSE_5_WIDTH" , '{
    "PULSE_5_WIDTH": '{ 31, 0, RW, 'h0000 }}};
  `define SET_REG_PULSE_5_WIDTH_PULSE_5_WIDTH(x) SetField(REG_PULSE_5_WIDTH,"PULSE_5_WIDTH",x)
  `define GET_REG_PULSE_5_WIDTH_PULSE_5_WIDTH(x) GetField(REG_PULSE_5_WIDTH,"PULSE_5_WIDTH",x)

  const reg_t REG_PULSE_5_OFFSET = '{ 'h00d4, "REG_PULSE_5_OFFSET" , '{
    "PULSE_5_OFFSET": '{ 31, 0, RW, 'h0000 }}};
  `define SET_REG_PULSE_5_OFFSET_PULSE_5_OFFSET(x) SetField(REG_PULSE_5_OFFSET,"PULSE_5_OFFSET",x)
  `define GET_REG_PULSE_5_OFFSET_PULSE_5_OFFSET(x) GetField(REG_PULSE_5_OFFSET,"PULSE_5_OFFSET",x)

  const reg_t REG_PULSE_6_PERIOD = '{ 'h0058, "REG_PULSE_6_PERIOD" , '{
    "PULSE_6_PERIOD": '{ 31, 0, RW, 'h0000 }}};
  `define SET_REG_PULSE_6_PERIOD_PULSE_6_PERIOD(x) SetField(REG_PULSE_6_PERIOD,"PULSE_6_PERIOD",x)
  `define GET_REG_PULSE_6_PERIOD_PULSE_6_PERIOD(x) GetField(REG_PULSE_6_PERIOD,"PULSE_6_PERIOD",x)

  const reg_t REG_PULSE_6_WIDTH = '{ 'h0098, "REG_PULSE_6_WIDTH" , '{
    "PULSE_6_WIDTH": '{ 31, 0, RW, 'h0000 }}};
  `define SET_REG_PULSE_6_WIDTH_PULSE_6_WIDTH(x) SetField(REG_PULSE_6_WIDTH,"PULSE_6_WIDTH",x)
  `define GET_REG_PULSE_6_WIDTH_PULSE_6_WIDTH(x) GetField(REG_PULSE_6_WIDTH,"PULSE_6_WIDTH",x)

  const reg_t REG_PULSE_6_OFFSET = '{ 'h00d8, "REG_PULSE_6_OFFSET" , '{
    "PULSE_6_OFFSET": '{ 31, 0, RW, 'h0000 }}};
  `define SET_REG_PULSE_6_OFFSET_PULSE_6_OFFSET(x) SetField(REG_PULSE_6_OFFSET,"PULSE_6_OFFSET",x)
  `define GET_REG_PULSE_6_OFFSET_PULSE_6_OFFSET(x) GetField(REG_PULSE_6_OFFSET,"PULSE_6_OFFSET",x)

  const reg_t REG_PULSE_7_PERIOD = '{ 'h005c, "REG_PULSE_7_PERIOD" , '{
    "PULSE_7_PERIOD": '{ 31, 0, RW, 'h0000 }}};
  `define SET_REG_PULSE_7_PERIOD_PULSE_7_PERIOD(x) SetField(REG_PULSE_7_PERIOD,"PULSE_7_PERIOD",x)
  `define GET_REG_PULSE_7_PERIOD_PULSE_7_PERIOD(x) GetField(REG_PULSE_7_PERIOD,"PULSE_7_PERIOD",x)

  const reg_t REG_PULSE_7_WIDTH = '{ 'h009c, "REG_PULSE_7_WIDTH" , '{
    "PULSE_7_WIDTH": '{ 31, 0, RW, 'h0000 }}};
  `define SET_REG_PULSE_7_WIDTH_PULSE_7_WIDTH(x) SetField(REG_PULSE_7_WIDTH,"PULSE_7_WIDTH",x)
  `define GET_REG_PULSE_7_WIDTH_PULSE_7_WIDTH(x) GetField(REG_PULSE_7_WIDTH,"PULSE_7_WIDTH",x)

  const reg_t REG_PULSE_7_OFFSET = '{ 'h00dc, "REG_PULSE_7_OFFSET" , '{
    "PULSE_7_OFFSET": '{ 31, 0, RW, 'h0000 }}};
  `define SET_REG_PULSE_7_OFFSET_PULSE_7_OFFSET(x) SetField(REG_PULSE_7_OFFSET,"PULSE_7_OFFSET",x)
  `define GET_REG_PULSE_7_OFFSET_PULSE_7_OFFSET(x) GetField(REG_PULSE_7_OFFSET,"PULSE_7_OFFSET",x)

  const reg_t REG_PULSE_8_PERIOD = '{ 'h0060, "REG_PULSE_8_PERIOD" , '{
    "PULSE_8_PERIOD": '{ 31, 0, RW, 'h0000 }}};
  `define SET_REG_PULSE_8_PERIOD_PULSE_8_PERIOD(x) SetField(REG_PULSE_8_PERIOD,"PULSE_8_PERIOD",x)
  `define GET_REG_PULSE_8_PERIOD_PULSE_8_PERIOD(x) GetField(REG_PULSE_8_PERIOD,"PULSE_8_PERIOD",x)

  const reg_t REG_PULSE_8_WIDTH = '{ 'h00a0, "REG_PULSE_8_WIDTH" , '{
    "PULSE_8_WIDTH": '{ 31, 0, RW, 'h0000 }}};
  `define SET_REG_PULSE_8_WIDTH_PULSE_8_WIDTH(x) SetField(REG_PULSE_8_WIDTH,"PULSE_8_WIDTH",x)
  `define GET_REG_PULSE_8_WIDTH_PULSE_8_WIDTH(x) GetField(REG_PULSE_8_WIDTH,"PULSE_8_WIDTH",x)

  const reg_t REG_PULSE_8_OFFSET = '{ 'h00e0, "REG_PULSE_8_OFFSET" , '{
    "PULSE_8_OFFSET": '{ 31, 0, RW, 'h0000 }}};
  `define SET_REG_PULSE_8_OFFSET_PULSE_8_OFFSET(x) SetField(REG_PULSE_8_OFFSET,"PULSE_8_OFFSET",x)
  `define GET_REG_PULSE_8_OFFSET_PULSE_8_OFFSET(x) GetField(REG_PULSE_8_OFFSET,"PULSE_8_OFFSET",x)

  const reg_t REG_PULSE_9_PERIOD = '{ 'h0064, "REG_PULSE_9_PERIOD" , '{
    "PULSE_9_PERIOD": '{ 31, 0, RW, 'h0000 }}};
  `define SET_REG_PULSE_9_PERIOD_PULSE_9_PERIOD(x) SetField(REG_PULSE_9_PERIOD,"PULSE_9_PERIOD",x)
  `define GET_REG_PULSE_9_PERIOD_PULSE_9_PERIOD(x) GetField(REG_PULSE_9_PERIOD,"PULSE_9_PERIOD",x)

  const reg_t REG_PULSE_9_WIDTH = '{ 'h00a4, "REG_PULSE_9_WIDTH" , '{
    "PULSE_9_WIDTH": '{ 31, 0, RW, 'h0000 }}};
  `define SET_REG_PULSE_9_WIDTH_PULSE_9_WIDTH(x) SetField(REG_PULSE_9_WIDTH,"PULSE_9_WIDTH",x)
  `define GET_REG_PULSE_9_WIDTH_PULSE_9_WIDTH(x) GetField(REG_PULSE_9_WIDTH,"PULSE_9_WIDTH",x)

  const reg_t REG_PULSE_9_OFFSET = '{ 'h00e4, "REG_PULSE_9_OFFSET" , '{
    "PULSE_9_OFFSET": '{ 31, 0, RW, 'h0000 }}};
  `define SET_REG_PULSE_9_OFFSET_PULSE_9_OFFSET(x) SetField(REG_PULSE_9_OFFSET,"PULSE_9_OFFSET",x)
  `define GET_REG_PULSE_9_OFFSET_PULSE_9_OFFSET(x) GetField(REG_PULSE_9_OFFSET,"PULSE_9_OFFSET",x)

  const reg_t REG_PULSE_10_PERIOD = '{ 'h0068, "REG_PULSE_10_PERIOD" , '{
    "PULSE_10_PERIOD": '{ 31, 0, RW, 'h0000 }}};
  `define SET_REG_PULSE_10_PERIOD_PULSE_10_PERIOD(x) SetField(REG_PULSE_10_PERIOD,"PULSE_10_PERIOD",x)
  `define GET_REG_PULSE_10_PERIOD_PULSE_10_PERIOD(x) GetField(REG_PULSE_10_PERIOD,"PULSE_10_PERIOD",x)

  const reg_t REG_PULSE_10_WIDTH = '{ 'h00a8, "REG_PULSE_10_WIDTH" , '{
    "PULSE_10_WIDTH": '{ 31, 0, RW, 'h0000 }}};
  `define SET_REG_PULSE_10_WIDTH_PULSE_10_WIDTH(x) SetField(REG_PULSE_10_WIDTH,"PULSE_10_WIDTH",x)
  `define GET_REG_PULSE_10_WIDTH_PULSE_10_WIDTH(x) GetField(REG_PULSE_10_WIDTH,"PULSE_10_WIDTH",x)

  const reg_t REG_PULSE_10_OFFSET = '{ 'h00e8, "REG_PULSE_10_OFFSET" , '{
    "PULSE_10_OFFSET": '{ 31, 0, RW, 'h0000 }}};
  `define SET_REG_PULSE_10_OFFSET_PULSE_10_OFFSET(x) SetField(REG_PULSE_10_OFFSET,"PULSE_10_OFFSET",x)
  `define GET_REG_PULSE_10_OFFSET_PULSE_10_OFFSET(x) GetField(REG_PULSE_10_OFFSET,"PULSE_10_OFFSET",x)

  const reg_t REG_PULSE_11_PERIOD = '{ 'h006c, "REG_PULSE_11_PERIOD" , '{
    "PULSE_11_PERIOD": '{ 31, 0, RW, 'h0000 }}};
  `define SET_REG_PULSE_11_PERIOD_PULSE_11_PERIOD(x) SetField(REG_PULSE_11_PERIOD,"PULSE_11_PERIOD",x)
  `define GET_REG_PULSE_11_PERIOD_PULSE_11_PERIOD(x) GetField(REG_PULSE_11_PERIOD,"PULSE_11_PERIOD",x)

  const reg_t REG_PULSE_11_WIDTH = '{ 'h00ac, "REG_PULSE_11_WIDTH" , '{
    "PULSE_11_WIDTH": '{ 31, 0, RW, 'h0000 }}};
  `define SET_REG_PULSE_11_WIDTH_PULSE_11_WIDTH(x) SetField(REG_PULSE_11_WIDTH,"PULSE_11_WIDTH",x)
  `define GET_REG_PULSE_11_WIDTH_PULSE_11_WIDTH(x) GetField(REG_PULSE_11_WIDTH,"PULSE_11_WIDTH",x)

  const reg_t REG_PULSE_11_OFFSET = '{ 'h00ec, "REG_PULSE_11_OFFSET" , '{
    "PULSE_11_OFFSET": '{ 31, 0, RW, 'h0000 }}};
  `define SET_REG_PULSE_11_OFFSET_PULSE_11_OFFSET(x) SetField(REG_PULSE_11_OFFSET,"PULSE_11_OFFSET",x)
  `define GET_REG_PULSE_11_OFFSET_PULSE_11_OFFSET(x) GetField(REG_PULSE_11_OFFSET,"PULSE_11_OFFSET",x)

  const reg_t REG_PULSE_12_PERIOD = '{ 'h0070, "REG_PULSE_12_PERIOD" , '{
    "PULSE_12_PERIOD": '{ 31, 0, RW, 'h0000 }}};
  `define SET_REG_PULSE_12_PERIOD_PULSE_12_PERIOD(x) SetField(REG_PULSE_12_PERIOD,"PULSE_12_PERIOD",x)
  `define GET_REG_PULSE_12_PERIOD_PULSE_12_PERIOD(x) GetField(REG_PULSE_12_PERIOD,"PULSE_12_PERIOD",x)

  const reg_t REG_PULSE_12_WIDTH = '{ 'h00b0, "REG_PULSE_12_WIDTH" , '{
    "PULSE_12_WIDTH": '{ 31, 0, RW, 'h0000 }}};
  `define SET_REG_PULSE_12_WIDTH_PULSE_12_WIDTH(x) SetField(REG_PULSE_12_WIDTH,"PULSE_12_WIDTH",x)
  `define GET_REG_PULSE_12_WIDTH_PULSE_12_WIDTH(x) GetField(REG_PULSE_12_WIDTH,"PULSE_12_WIDTH",x)

  const reg_t REG_PULSE_12_OFFSET = '{ 'h00f0, "REG_PULSE_12_OFFSET" , '{
    "PULSE_12_OFFSET": '{ 31, 0, RW, 'h0000 }}};
  `define SET_REG_PULSE_12_OFFSET_PULSE_12_OFFSET(x) SetField(REG_PULSE_12_OFFSET,"PULSE_12_OFFSET",x)
  `define GET_REG_PULSE_12_OFFSET_PULSE_12_OFFSET(x) GetField(REG_PULSE_12_OFFSET,"PULSE_12_OFFSET",x)

  const reg_t REG_PULSE_13_PERIOD = '{ 'h0074, "REG_PULSE_13_PERIOD" , '{
    "PULSE_13_PERIOD": '{ 31, 0, RW, 'h0000 }}};
  `define SET_REG_PULSE_13_PERIOD_PULSE_13_PERIOD(x) SetField(REG_PULSE_13_PERIOD,"PULSE_13_PERIOD",x)
  `define GET_REG_PULSE_13_PERIOD_PULSE_13_PERIOD(x) GetField(REG_PULSE_13_PERIOD,"PULSE_13_PERIOD",x)

  const reg_t REG_PULSE_13_WIDTH = '{ 'h00b4, "REG_PULSE_13_WIDTH" , '{
    "PULSE_13_WIDTH": '{ 31, 0, RW, 'h0000 }}};
  `define SET_REG_PULSE_13_WIDTH_PULSE_13_WIDTH(x) SetField(REG_PULSE_13_WIDTH,"PULSE_13_WIDTH",x)
  `define GET_REG_PULSE_13_WIDTH_PULSE_13_WIDTH(x) GetField(REG_PULSE_13_WIDTH,"PULSE_13_WIDTH",x)

  const reg_t REG_PULSE_13_OFFSET = '{ 'h00f4, "REG_PULSE_13_OFFSET" , '{
    "PULSE_13_OFFSET": '{ 31, 0, RW, 'h0000 }}};
  `define SET_REG_PULSE_13_OFFSET_PULSE_13_OFFSET(x) SetField(REG_PULSE_13_OFFSET,"PULSE_13_OFFSET",x)
  `define GET_REG_PULSE_13_OFFSET_PULSE_13_OFFSET(x) GetField(REG_PULSE_13_OFFSET,"PULSE_13_OFFSET",x)

  const reg_t REG_PULSE_14_PERIOD = '{ 'h0078, "REG_PULSE_14_PERIOD" , '{
    "PULSE_14_PERIOD": '{ 31, 0, RW, 'h0000 }}};
  `define SET_REG_PULSE_14_PERIOD_PULSE_14_PERIOD(x) SetField(REG_PULSE_14_PERIOD,"PULSE_14_PERIOD",x)
  `define GET_REG_PULSE_14_PERIOD_PULSE_14_PERIOD(x) GetField(REG_PULSE_14_PERIOD,"PULSE_14_PERIOD",x)

  const reg_t REG_PULSE_14_WIDTH = '{ 'h00b8, "REG_PULSE_14_WIDTH" , '{
    "PULSE_14_WIDTH": '{ 31, 0, RW, 'h0000 }}};
  `define SET_REG_PULSE_14_WIDTH_PULSE_14_WIDTH(x) SetField(REG_PULSE_14_WIDTH,"PULSE_14_WIDTH",x)
  `define GET_REG_PULSE_14_WIDTH_PULSE_14_WIDTH(x) GetField(REG_PULSE_14_WIDTH,"PULSE_14_WIDTH",x)

  const reg_t REG_PULSE_14_OFFSET = '{ 'h00f8, "REG_PULSE_14_OFFSET" , '{
    "PULSE_14_OFFSET": '{ 31, 0, RW, 'h0000 }}};
  `define SET_REG_PULSE_14_OFFSET_PULSE_14_OFFSET(x) SetField(REG_PULSE_14_OFFSET,"PULSE_14_OFFSET",x)
  `define GET_REG_PULSE_14_OFFSET_PULSE_14_OFFSET(x) GetField(REG_PULSE_14_OFFSET,"PULSE_14_OFFSET",x)

  const reg_t REG_PULSE_15_PERIOD = '{ 'h007c, "REG_PULSE_15_PERIOD" , '{
    "PULSE_15_PERIOD": '{ 31, 0, RW, 'h0000 }}};
  `define SET_REG_PULSE_15_PERIOD_PULSE_15_PERIOD(x) SetField(REG_PULSE_15_PERIOD,"PULSE_15_PERIOD",x)
  `define GET_REG_PULSE_15_PERIOD_PULSE_15_PERIOD(x) GetField(REG_PULSE_15_PERIOD,"PULSE_15_PERIOD",x)

  const reg_t REG_PULSE_15_WIDTH = '{ 'h00bc, "REG_PULSE_15_WIDTH" , '{
    "PULSE_15_WIDTH": '{ 31, 0, RW, 'h0000 }}};
  `define SET_REG_PULSE_15_WIDTH_PULSE_15_WIDTH(x) SetField(REG_PULSE_15_WIDTH,"PULSE_15_WIDTH",x)
  `define GET_REG_PULSE_15_WIDTH_PULSE_15_WIDTH(x) GetField(REG_PULSE_15_WIDTH,"PULSE_15_WIDTH",x)

  const reg_t REG_PULSE_15_OFFSET = '{ 'h00fc, "REG_PULSE_15_OFFSET" , '{
    "PULSE_15_OFFSET": '{ 31, 0, RW, 'h0000 }}};
  `define SET_REG_PULSE_15_OFFSET_PULSE_15_OFFSET(x) SetField(REG_PULSE_15_OFFSET,"PULSE_15_OFFSET",x)
  `define GET_REG_PULSE_15_OFFSET_PULSE_15_OFFSET(x) GetField(REG_PULSE_15_OFFSET,"PULSE_15_OFFSET",x)

endpackage
