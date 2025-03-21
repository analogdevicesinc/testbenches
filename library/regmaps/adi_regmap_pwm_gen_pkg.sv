// ***************************************************************************
// ***************************************************************************
// Copyright (C) 2014-2024 Analog Devices, Inc. All rights reserved.
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
/* Auto generated Register Map */
/* Tue Apr  9 06:15:30 2024 */

package adi_regmap_pwm_gen_pkg;
  import adi_regmap_pkg::*;


/* PWM Generator (axi_pwm_gen) */

  const reg_t AXI_PWM_GEN_REG_VERSION = '{ 'h0000, "REG_VERSION" , '{
    "VERSION": '{ 31, 0, RO, 'h00020101 }}};
  `define SET_AXI_PWM_GEN_REG_VERSION_VERSION(x) SetField(AXI_PWM_GEN_REG_VERSION,"VERSION",x)
  `define GET_AXI_PWM_GEN_REG_VERSION_VERSION(x) GetField(AXI_PWM_GEN_REG_VERSION,"VERSION",x)
  `define DEFAULT_AXI_PWM_GEN_REG_VERSION_VERSION GetResetValue(AXI_PWM_GEN_REG_VERSION,"VERSION")
  `define UPDATE_AXI_PWM_GEN_REG_VERSION_VERSION(x,y) UpdateField(AXI_PWM_GEN_REG_VERSION,"VERSION",x,y)

  const reg_t AXI_PWM_GEN_REG_ID = '{ 'h0004, "REG_ID" , '{
    "ID": '{ 31, 0, RO, 'h00000000 }}};
  `define SET_AXI_PWM_GEN_REG_ID_ID(x) SetField(AXI_PWM_GEN_REG_ID,"ID",x)
  `define GET_AXI_PWM_GEN_REG_ID_ID(x) GetField(AXI_PWM_GEN_REG_ID,"ID",x)
  `define DEFAULT_AXI_PWM_GEN_REG_ID_ID GetResetValue(AXI_PWM_GEN_REG_ID,"ID")
  `define UPDATE_AXI_PWM_GEN_REG_ID_ID(x,y) UpdateField(AXI_PWM_GEN_REG_ID,"ID",x,y)

  const reg_t AXI_PWM_GEN_REG_SCRATCH = '{ 'h0008, "REG_SCRATCH" , '{
    "SCRATCH": '{ 31, 0, RW, 'h00000000 }}};
  `define SET_AXI_PWM_GEN_REG_SCRATCH_SCRATCH(x) SetField(AXI_PWM_GEN_REG_SCRATCH,"SCRATCH",x)
  `define GET_AXI_PWM_GEN_REG_SCRATCH_SCRATCH(x) GetField(AXI_PWM_GEN_REG_SCRATCH,"SCRATCH",x)
  `define DEFAULT_AXI_PWM_GEN_REG_SCRATCH_SCRATCH GetResetValue(AXI_PWM_GEN_REG_SCRATCH,"SCRATCH")
  `define UPDATE_AXI_PWM_GEN_REG_SCRATCH_SCRATCH(x,y) UpdateField(AXI_PWM_GEN_REG_SCRATCH,"SCRATCH",x,y)

  const reg_t AXI_PWM_GEN_REG_CORE_MAGIC = '{ 'h000c, "REG_CORE_MAGIC" , '{
    "CORE_MAGIC": '{ 31, 0, RW, 'h601a3471 }}};
  `define SET_AXI_PWM_GEN_REG_CORE_MAGIC_CORE_MAGIC(x) SetField(AXI_PWM_GEN_REG_CORE_MAGIC,"CORE_MAGIC",x)
  `define GET_AXI_PWM_GEN_REG_CORE_MAGIC_CORE_MAGIC(x) GetField(AXI_PWM_GEN_REG_CORE_MAGIC,"CORE_MAGIC",x)
  `define DEFAULT_AXI_PWM_GEN_REG_CORE_MAGIC_CORE_MAGIC GetResetValue(AXI_PWM_GEN_REG_CORE_MAGIC,"CORE_MAGIC")
  `define UPDATE_AXI_PWM_GEN_REG_CORE_MAGIC_CORE_MAGIC(x,y) UpdateField(AXI_PWM_GEN_REG_CORE_MAGIC,"CORE_MAGIC",x,y)

  const reg_t AXI_PWM_GEN_REG_RSTN = '{ 'h0010, "REG_RSTN" , '{
    "LOAD_CONFIG": '{ 1, 1, WO, 'h0 },
    "RESET": '{ 0, 0, RW, 'h0 }}};
  `define SET_AXI_PWM_GEN_REG_RSTN_LOAD_CONFIG(x) SetField(AXI_PWM_GEN_REG_RSTN,"LOAD_CONFIG",x)
  `define GET_AXI_PWM_GEN_REG_RSTN_LOAD_CONFIG(x) GetField(AXI_PWM_GEN_REG_RSTN,"LOAD_CONFIG",x)
  `define DEFAULT_AXI_PWM_GEN_REG_RSTN_LOAD_CONFIG GetResetValue(AXI_PWM_GEN_REG_RSTN,"LOAD_CONFIG")
  `define UPDATE_AXI_PWM_GEN_REG_RSTN_LOAD_CONFIG(x,y) UpdateField(AXI_PWM_GEN_REG_RSTN,"LOAD_CONFIG",x,y)
  `define SET_AXI_PWM_GEN_REG_RSTN_RESET(x) SetField(AXI_PWM_GEN_REG_RSTN,"RESET",x)
  `define GET_AXI_PWM_GEN_REG_RSTN_RESET(x) GetField(AXI_PWM_GEN_REG_RSTN,"RESET",x)
  `define DEFAULT_AXI_PWM_GEN_REG_RSTN_RESET GetResetValue(AXI_PWM_GEN_REG_RSTN,"RESET")
  `define UPDATE_AXI_PWM_GEN_REG_RSTN_RESET(x,y) UpdateField(AXI_PWM_GEN_REG_RSTN,"RESET",x,y)

  const reg_t AXI_PWM_GEN_REG_NB_PULSES = '{ 'h0014, "REG_NB_PULSES" , '{
    "NB_PULSES": '{ 31, 0, RO, 'h0000 }}};
  `define SET_AXI_PWM_GEN_REG_NB_PULSES_NB_PULSES(x) SetField(AXI_PWM_GEN_REG_NB_PULSES,"NB_PULSES",x)
  `define GET_AXI_PWM_GEN_REG_NB_PULSES_NB_PULSES(x) GetField(AXI_PWM_GEN_REG_NB_PULSES,"NB_PULSES",x)
  `define DEFAULT_AXI_PWM_GEN_REG_NB_PULSES_NB_PULSES GetResetValue(AXI_PWM_GEN_REG_NB_PULSES,"NB_PULSES")
  `define UPDATE_AXI_PWM_GEN_REG_NB_PULSES_NB_PULSES(x,y) UpdateField(AXI_PWM_GEN_REG_NB_PULSES,"NB_PULSES",x,y)

  const reg_t AXI_PWM_GEN_REG_PULSE_X_PERIOD = '{ 'h0040, "REG_PULSE_X_PERIOD" , '{
    "PULSE_X_PERIOD": '{ 31, 0, RW, 'h0000 }}};
  `define SET_AXI_PWM_GEN_REG_PULSE_X_PERIOD_PULSE_X_PERIOD(x) SetField(AXI_PWM_GEN_REG_PULSE_X_PERIOD,"PULSE_X_PERIOD",x)
  `define GET_AXI_PWM_GEN_REG_PULSE_X_PERIOD_PULSE_X_PERIOD(x) GetField(AXI_PWM_GEN_REG_PULSE_X_PERIOD,"PULSE_X_PERIOD",x)
  `define DEFAULT_AXI_PWM_GEN_REG_PULSE_X_PERIOD_PULSE_X_PERIOD GetResetValue(AXI_PWM_GEN_REG_PULSE_X_PERIOD,"PULSE_X_PERIOD")
  `define UPDATE_AXI_PWM_GEN_REG_PULSE_X_PERIOD_PULSE_X_PERIOD(x,y) UpdateField(AXI_PWM_GEN_REG_PULSE_X_PERIOD,"PULSE_X_PERIOD",x,y)

  const reg_t AXI_PWM_GEN_REG_PULSE_X_WIDTH = '{ 'h0080, "REG_PULSE_X_WIDTH" , '{
    "PULSE_X_WIDTH": '{ 31, 0, RW, 'h0000 }}};
  `define SET_AXI_PWM_GEN_REG_PULSE_X_WIDTH_PULSE_X_WIDTH(x) SetField(AXI_PWM_GEN_REG_PULSE_X_WIDTH,"PULSE_X_WIDTH",x)
  `define GET_AXI_PWM_GEN_REG_PULSE_X_WIDTH_PULSE_X_WIDTH(x) GetField(AXI_PWM_GEN_REG_PULSE_X_WIDTH,"PULSE_X_WIDTH",x)
  `define DEFAULT_AXI_PWM_GEN_REG_PULSE_X_WIDTH_PULSE_X_WIDTH GetResetValue(AXI_PWM_GEN_REG_PULSE_X_WIDTH,"PULSE_X_WIDTH")
  `define UPDATE_AXI_PWM_GEN_REG_PULSE_X_WIDTH_PULSE_X_WIDTH(x,y) UpdateField(AXI_PWM_GEN_REG_PULSE_X_WIDTH,"PULSE_X_WIDTH",x,y)

  const reg_t AXI_PWM_GEN_REG_PULSE_X_OFFSET = '{ 'h00c0, "REG_PULSE_X_OFFSET" , '{
    "PULSE_X_OFFSET": '{ 31, 0, RW, 'h0000 }}};
  `define SET_AXI_PWM_GEN_REG_PULSE_X_OFFSET_PULSE_X_OFFSET(x) SetField(AXI_PWM_GEN_REG_PULSE_X_OFFSET,"PULSE_X_OFFSET",x)
  `define GET_AXI_PWM_GEN_REG_PULSE_X_OFFSET_PULSE_X_OFFSET(x) GetField(AXI_PWM_GEN_REG_PULSE_X_OFFSET,"PULSE_X_OFFSET",x)
  `define DEFAULT_AXI_PWM_GEN_REG_PULSE_X_OFFSET_PULSE_X_OFFSET GetResetValue(AXI_PWM_GEN_REG_PULSE_X_OFFSET,"PULSE_X_OFFSET")
  `define UPDATE_AXI_PWM_GEN_REG_PULSE_X_OFFSET_PULSE_X_OFFSET(x,y) UpdateField(AXI_PWM_GEN_REG_PULSE_X_OFFSET,"PULSE_X_OFFSET",x,y)


endpackage
