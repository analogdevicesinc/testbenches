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

  const reg_t REG_N_PULSES = '{ 'h0014, "REG_N_PULSES" , '{
    "": '{ 31, 0, RO, 'h0000 }}};
  `define SET_REG_N_PULSES_(x) SetField(REG_N_PULSES,"",x)
  `define GET_REG_N_PULSES_(x) GetField(REG_N_PULSES,"",x)

  const reg_t REG_PULSE_0_PERIOD = '{ 'h0040, "REG_PULSE_0_PERIOD" , '{
    "PULSE_0_PERIOD": '{ 31, 0, RW, 'h0000 }}};
  `define SET_REG_PULSE_0_PERIOD_PULSE_0_PERIOD(x) SetField(REG_PULSE_0_PERIOD,"PULSE_0_PERIOD",x)
  `define GET_REG_PULSE_0_PERIOD_PULSE_0_PERIOD(x) GetField(REG_PULSE_0_PERIOD,"PULSE_0_PERIOD",x)

  const reg_t REG_PULSE_0_WIDTH = '{ 'h0044, "REG_PULSE_0_WIDTH" , '{
    "PULSE_0_WIDTH": '{ 31, 0, RW, 'h0000 }}};
  `define SET_REG_PULSE_0_WIDTH_PULSE_0_WIDTH(x) SetField(REG_PULSE_0_WIDTH,"PULSE_0_WIDTH",x)
  `define GET_REG_PULSE_0_WIDTH_PULSE_0_WIDTH(x) GetField(REG_PULSE_0_WIDTH,"PULSE_0_WIDTH",x)

  const reg_t REG_PULSE_0_OFFSET = '{ 'h0048, "REG_PULSE_0_OFFSET" , '{
    "PULSE_0_OFFSET": '{ 31, 0, RW, 'h0000 }}};
  `define SET_REG_PULSE_0_OFFSET_PULSE_0_OFFSET(x) SetField(REG_PULSE_0_OFFSET,"PULSE_0_OFFSET",x)
  `define GET_REG_PULSE_0_OFFSET_PULSE_0_OFFSET(x) GetField(REG_PULSE_0_OFFSET,"PULSE_0_OFFSET",x)

  const reg_t REG_PULSE_1_PERIOD = '{ 'h004c, "REG_PULSE_1_PERIOD" , '{
    "PULSE_1_PERIOD": '{ 31, 0, RW, 'h0000 }}};
  `define SET_REG_PULSE_1_PERIOD_PULSE_1_PERIOD(x) SetField(REG_PULSE_1_PERIOD,"PULSE_1_PERIOD",x)
  `define GET_REG_PULSE_1_PERIOD_PULSE_1_PERIOD(x) GetField(REG_PULSE_1_PERIOD,"PULSE_1_PERIOD",x)

  const reg_t REG_PULSE_1_WIDTH = '{ 'h0050, "REG_PULSE_1_WIDTH" , '{
    "PULSE_1_WIDTH": '{ 31, 0, RW, 'h0000 }}};
  `define SET_REG_PULSE_1_WIDTH_PULSE_1_WIDTH(x) SetField(REG_PULSE_1_WIDTH,"PULSE_1_WIDTH",x)
  `define GET_REG_PULSE_1_WIDTH_PULSE_1_WIDTH(x) GetField(REG_PULSE_1_WIDTH,"PULSE_1_WIDTH",x)

  const reg_t REG_PULSE_1_OFFSET = '{ 'h0054, "REG_PULSE_1_OFFSET" , '{
    "PULSE_1_OFFSET": '{ 31, 0, RW, 'h0000 }}};
  `define SET_REG_PULSE_1_OFFSET_PULSE_1_OFFSET(x) SetField(REG_PULSE_1_OFFSET,"PULSE_1_OFFSET",x)
  `define GET_REG_PULSE_1_OFFSET_PULSE_1_OFFSET(x) GetField(REG_PULSE_1_OFFSET,"PULSE_1_OFFSET",x)

  const reg_t REG_PULSE_2_PERIOD = '{ 'h0058, "REG_PULSE_2_PERIOD" , '{
    "PULSE_2_PERIOD": '{ 31, 0, RW, 'h0000 }}};
  `define SET_REG_PULSE_2_PERIOD_PULSE_2_PERIOD(x) SetField(REG_PULSE_2_PERIOD,"PULSE_2_PERIOD",x)
  `define GET_REG_PULSE_2_PERIOD_PULSE_2_PERIOD(x) GetField(REG_PULSE_2_PERIOD,"PULSE_2_PERIOD",x)

  const reg_t REG_PULSE_2_WIDTH = '{ 'h005c, "REG_PULSE_2_WIDTH" , '{
    "PULSE_2_WIDTH": '{ 31, 0, RW, 'h0000 }}};
  `define SET_REG_PULSE_2_WIDTH_PULSE_2_WIDTH(x) SetField(REG_PULSE_2_WIDTH,"PULSE_2_WIDTH",x)
  `define GET_REG_PULSE_2_WIDTH_PULSE_2_WIDTH(x) GetField(REG_PULSE_2_WIDTH,"PULSE_2_WIDTH",x)

  const reg_t REG_PULSE_2_OFFSET = '{ 'h0060, "REG_PULSE_2_OFFSET" , '{
    "PULSE_2_OFFSET": '{ 31, 0, RW, 'h0000 }}};
  `define SET_REG_PULSE_2_OFFSET_PULSE_2_OFFSET(x) SetField(REG_PULSE_2_OFFSET,"PULSE_2_OFFSET",x)
  `define GET_REG_PULSE_2_OFFSET_PULSE_2_OFFSET(x) GetField(REG_PULSE_2_OFFSET,"PULSE_2_OFFSET",x)

  const reg_t REG_PULSE_3_PERIOD = '{ 'h0064, "REG_PULSE_3_PERIOD" , '{
    "PULSE_3_PERIOD": '{ 31, 0, RW, 'h0000 }}};
  `define SET_REG_PULSE_3_PERIOD_PULSE_3_PERIOD(x) SetField(REG_PULSE_3_PERIOD,"PULSE_3_PERIOD",x)
  `define GET_REG_PULSE_3_PERIOD_PULSE_3_PERIOD(x) GetField(REG_PULSE_3_PERIOD,"PULSE_3_PERIOD",x)

  const reg_t REG_PULSE_3_WIDTH = '{ 'h0068, "REG_PULSE_3_WIDTH" , '{
    "PULSE_3_WIDTH": '{ 31, 0, RW, 'h0000 }}};
  `define SET_REG_PULSE_3_WIDTH_PULSE_3_WIDTH(x) SetField(REG_PULSE_3_WIDTH,"PULSE_3_WIDTH",x)
  `define GET_REG_PULSE_3_WIDTH_PULSE_3_WIDTH(x) GetField(REG_PULSE_3_WIDTH,"PULSE_3_WIDTH",x)

  const reg_t REG_PULSE_3_OFFSET = '{ 'h006c, "REG_PULSE_3_OFFSET" , '{
    "PULSE_3_OFFSET": '{ 31, 0, RW, 'h0000 }}};
  `define SET_REG_PULSE_3_OFFSET_PULSE_3_OFFSET(x) SetField(REG_PULSE_3_OFFSET,"PULSE_3_OFFSET",x)
  `define GET_REG_PULSE_3_OFFSET_PULSE_3_OFFSET(x) GetField(REG_PULSE_3_OFFSET,"PULSE_3_OFFSET",x)


endpackage
