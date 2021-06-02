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
//      <https://www.gnu.org/licenses/old_licenses/gpl-2.0.html>
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
/* Fri May 28 12:27:32 2021 */

package adi_regmap_iodelay_pkg;
  import adi_regmap_pkg::*;


/* IO Delay Control (axi_ad*) */

  const reg_t IO_DELAY_CNTRL_REG_DELAY_CONTROL_0 = '{ 'h0000, "REG_DELAY_CONTROL_0" , '{
    "DELAY_CONTROL_IO_0": '{ 4, 0, RW, 'h00 }}};
  `define SET_IO_DELAY_CNTRL_REG_DELAY_CONTROL_0_DELAY_CONTROL_IO_0(x) SetField(IO_DELAY_CNTRL_REG_DELAY_CONTROL_0,"DELAY_CONTROL_IO_0",x)
  `define GET_IO_DELAY_CNTRL_REG_DELAY_CONTROL_0_DELAY_CONTROL_IO_0(x) GetField(IO_DELAY_CNTRL_REG_DELAY_CONTROL_0,"DELAY_CONTROL_IO_0",x)

  const reg_t IO_DELAY_CNTRL_REG_DELAY_CONTROL_1 = '{ 'h0004, "REG_DELAY_CONTROL_1" , '{
    "DELAY_CONTROL_IO_1": '{ 4, 0, RW, 'h00 }}};
  `define SET_IO_DELAY_CNTRL_REG_DELAY_CONTROL_1_DELAY_CONTROL_IO_1(x) SetField(IO_DELAY_CNTRL_REG_DELAY_CONTROL_1,"DELAY_CONTROL_IO_1",x)
  `define GET_IO_DELAY_CNTRL_REG_DELAY_CONTROL_1_DELAY_CONTROL_IO_1(x) GetField(IO_DELAY_CNTRL_REG_DELAY_CONTROL_1,"DELAY_CONTROL_IO_1",x)

  const reg_t IO_DELAY_CNTRL_REG_DELAY_CONTROL_F = '{ 'h003c, "REG_DELAY_CONTROL_F" , '{
    "DELAY_CONTROL_IO_F": '{ 4, 0, RW, 'h00 }}};
  `define SET_IO_DELAY_CNTRL_REG_DELAY_CONTROL_F_DELAY_CONTROL_IO_F(x) SetField(IO_DELAY_CNTRL_REG_DELAY_CONTROL_F,"DELAY_CONTROL_IO_F",x)
  `define GET_IO_DELAY_CNTRL_REG_DELAY_CONTROL_F_DELAY_CONTROL_IO_F(x) GetField(IO_DELAY_CNTRL_REG_DELAY_CONTROL_F,"DELAY_CONTROL_IO_F",x)


endpackage
