// ***************************************************************************
// ***************************************************************************
// Copyright (C) 2014 - 2025 Analog Devices, Inc. All rights reserved.
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
/* Auto generated Register Map */
/* Feb 07 14:25:05 2025 v0.4.1 */

`timescale 1ns/1ps

`ifndef _ADI_REGMAP_FAN_CONTROL_PKG_DEFINITIONS_SVH_
`define _ADI_REGMAP_FAN_CONTROL_PKG_DEFINITIONS_SVH_

// Help build VIP Interface parameters name
`define ADI_REGMAP_FAN_CONTROL_PKG_PARAM_IMPORT(n)  n``.inst.ID, \
  n``.inst.INTERNAL_SYSMONE, \
  n``.inst.PWM_PERIOD, \
  n``.inst.TACHO_T100, \
  n``.inst.TACHO_T25, \
  n``.inst.TACHO_T50, \
  n``.inst.TACHO_T75, \
  n``.inst.TACHO_TOL_PERCENT, \
  n``.inst.TEMP_00_H, \
  n``.inst.TEMP_100_L, \
  n``.inst.TEMP_25_H, \
  n``.inst.TEMP_25_L, \
  n``.inst.TEMP_50_H, \
  n``.inst.TEMP_50_L, \
  n``.inst.TEMP_75_H, \
  n``.inst.TEMP_75_L

`define ADI_REGMAP_FAN_CONTROL_PKG_PARAM_DECL int  ID, \
  INTERNAL_SYSMONE, \
  PWM_PERIOD, \
  TACHO_T100, \
  TACHO_T25, \
  TACHO_T50, \
  TACHO_T75, \
  TACHO_TOL_PERCENT, \
  TEMP_00_H, \
  TEMP_100_L, \
  TEMP_25_H, \
  TEMP_25_L, \
  TEMP_50_H, \
  TEMP_50_L, \
  TEMP_75_H, \
  TEMP_75_L

`define ADI_REGMAP_FAN_CONTROL_PKG_PARAM_ORDER  ID, \
  INTERNAL_SYSMONE, \
  PWM_PERIOD, \
  TACHO_T100, \
  TACHO_T25, \
  TACHO_T50, \
  TACHO_T75, \
  TACHO_TOL_PERCENT, \
  TEMP_00_H, \
  TEMP_100_L, \
  TEMP_25_H, \
  TEMP_25_L, \
  TEMP_50_H, \
  TEMP_50_L, \
  TEMP_75_H, \
  TEMP_75_L

`endif
