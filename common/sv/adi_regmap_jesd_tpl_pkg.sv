// ***************************************************************************
// ***************************************************************************
// Copyright 2014 _ 2018 (c) Analog Devices, Inc. All rights reserved.
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
//      <https://www.gnu.org/licenses/old_licenses/gpl_2.0.html>
//
// OR
//
//   2. An ADI specific BSD license, which can be found in the top level directory
//      of this repository (LICENSE_ADIBSD), and also on_line at:
//      https://github.com/analogdevicesinc/hdl/blob/master/LICENSE_ADIBSD
//      This will allow to generate bit files and not release the source code,
//      as long as it attaches to an ADI device.
//
// ***************************************************************************
// ***************************************************************************
/* Auto generated Register Map */
/* Fri May 28 12:27:32 2021 */

package adi_regmap_jesd_tpl_pkg;
  import adi_regmap_pkg::*;


/* JESD TPL (up_tpl_common) */

  const reg_t JESD_TPL_REG_TPL_CNTRL = '{ 'h0200, "REG_TPL_CNTRL" , '{
    "PROFILE_SEL": '{ 3, 0, RW, 'h00 }}};
  `define SET_JESD_TPL_REG_TPL_CNTRL_PROFILE_SEL(x) SetField(JESD_TPL_REG_TPL_CNTRL,"PROFILE_SEL",x)
  `define GET_JESD_TPL_REG_TPL_CNTRL_PROFILE_SEL(x) GetField(JESD_TPL_REG_TPL_CNTRL,"PROFILE_SEL",x)

  const reg_t JESD_TPL_REG_TPL_STATUS = '{ 'h0204, "REG_TPL_STATUS" , '{
    "PROFILE_NUM": '{ 3, 0, RO, 'h00 }}};
  `define SET_JESD_TPL_REG_TPL_STATUS_PROFILE_NUM(x) SetField(JESD_TPL_REG_TPL_STATUS,"PROFILE_NUM",x)
  `define GET_JESD_TPL_REG_TPL_STATUS_PROFILE_NUM(x) GetField(JESD_TPL_REG_TPL_STATUS,"PROFILE_NUM",x)

  const reg_t JESD_TPL_REG_TPL_DESCRIPTOR_1 = '{ 'h0240, "REG_TPL_DESCRIPTOR_1" , '{
    "JESD_F": '{ 31, 24, RO, 'h00 },
    "JESD_S": '{ 23, 16, RO, 'h00 },
    "JESD_L": '{ 15, 8, RO, 'h00 },
    "JESD_M": '{ 7, 0, RO, 'h00 }}};
  `define SET_JESD_TPL_REG_TPL_DESCRIPTOR_1_JESD_F(x) SetField(JESD_TPL_REG_TPL_DESCRIPTOR_1,"JESD_F",x)
  `define GET_JESD_TPL_REG_TPL_DESCRIPTOR_1_JESD_F(x) GetField(JESD_TPL_REG_TPL_DESCRIPTOR_1,"JESD_F",x)
  `define SET_JESD_TPL_REG_TPL_DESCRIPTOR_1_JESD_S(x) SetField(JESD_TPL_REG_TPL_DESCRIPTOR_1,"JESD_S",x)
  `define GET_JESD_TPL_REG_TPL_DESCRIPTOR_1_JESD_S(x) GetField(JESD_TPL_REG_TPL_DESCRIPTOR_1,"JESD_S",x)
  `define SET_JESD_TPL_REG_TPL_DESCRIPTOR_1_JESD_L(x) SetField(JESD_TPL_REG_TPL_DESCRIPTOR_1,"JESD_L",x)
  `define GET_JESD_TPL_REG_TPL_DESCRIPTOR_1_JESD_L(x) GetField(JESD_TPL_REG_TPL_DESCRIPTOR_1,"JESD_L",x)
  `define SET_JESD_TPL_REG_TPL_DESCRIPTOR_1_JESD_M(x) SetField(JESD_TPL_REG_TPL_DESCRIPTOR_1,"JESD_M",x)
  `define GET_JESD_TPL_REG_TPL_DESCRIPTOR_1_JESD_M(x) GetField(JESD_TPL_REG_TPL_DESCRIPTOR_1,"JESD_M",x)

  const reg_t JESD_TPL_REG_TPL_DESCRIPTOR_2 = '{ 'h0244, "REG_TPL_DESCRIPTOR_2" , '{
    "JESD_N": '{ 7, 0, RO, 'h00 },
    "JESD_NP": '{ 15, 8, RO, 'h00 }}};
  `define SET_JESD_TPL_REG_TPL_DESCRIPTOR_2_JESD_N(x) SetField(JESD_TPL_REG_TPL_DESCRIPTOR_2,"JESD_N",x)
  `define GET_JESD_TPL_REG_TPL_DESCRIPTOR_2_JESD_N(x) GetField(JESD_TPL_REG_TPL_DESCRIPTOR_2,"JESD_N",x)
  `define SET_JESD_TPL_REG_TPL_DESCRIPTOR_2_JESD_NP(x) SetField(JESD_TPL_REG_TPL_DESCRIPTOR_2,"JESD_NP",x)
  `define GET_JESD_TPL_REG_TPL_DESCRIPTOR_2_JESD_NP(x) GetField(JESD_TPL_REG_TPL_DESCRIPTOR_2,"JESD_NP",x)


endpackage
