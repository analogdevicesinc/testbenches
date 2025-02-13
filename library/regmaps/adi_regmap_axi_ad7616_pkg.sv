// ***************************************************************************
// ***************************************************************************
// Copyright (C) 2014 - 2023 Analog Devices, Inc. All rights reserved.
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
/* Thu Mar 28 13:19:02 2024 */

package adi_regmap_axi_ad7616_pkg;
  import adi_regmap_pkg::*;


/* AXI AD7616 (axi_ad7616) */

  const reg_t AXI_AD7616_REG_VERSION = '{ 'h0000, "REG_VERSION" , '{
    "VERSION": '{ 31, 0, RO, 'h00001002 }}};
  `define SET_AXI_AD7616_REG_VERSION_VERSION(x) SetField(AXI_AD7616_REG_VERSION,"VERSION",x)
  `define GET_AXI_AD7616_REG_VERSION_VERSION(x) GetField(AXI_AD7616_REG_VERSION,"VERSION",x)

  const reg_t AXI_AD7616_REG_ID = '{ 'h0004, "REG_ID" , '{
    "ID": '{ 31, 0, RO, 'h00000000 }}};
  `define SET_AXI_AD7616_REG_ID_ID(x) SetField(AXI_AD7616_REG_ID,"ID",x)
  `define GET_AXI_AD7616_REG_ID_ID(x) GetField(AXI_AD7616_REG_ID,"ID",x)

  const reg_t AXI_AD7616_REG_SCRATCH = '{ 'h0008, "REG_SCRATCH" , '{
    "SCRATCH": '{ 31, 0, RW, 'h00000000 }}};
  `define SET_AXI_AD7616_REG_SCRATCH_SCRATCH(x) SetField(AXI_AD7616_REG_SCRATCH,"SCRATCH",x)
  `define GET_AXI_AD7616_REG_SCRATCH_SCRATCH(x) GetField(AXI_AD7616_REG_SCRATCH,"SCRATCH",x)

  const reg_t AXI_AD7616_REG_UP_CNTRL = '{ 'h0040, "REG_UP_CNTRL" , '{
    "CNVST_EN": '{ 1, 1, RW, 'h0 },
    "RESETN": '{ 0, 0, RW, 'h0 }}};
  `define SET_AXI_AD7616_REG_UP_CNTRL_CNVST_EN(x) SetField(AXI_AD7616_REG_UP_CNTRL,"CNVST_EN",x)
  `define GET_AXI_AD7616_REG_UP_CNTRL_CNVST_EN(x) GetField(AXI_AD7616_REG_UP_CNTRL,"CNVST_EN",x)
  `define SET_AXI_AD7616_REG_UP_CNTRL_RESETN(x) SetField(AXI_AD7616_REG_UP_CNTRL,"RESETN",x)
  `define GET_AXI_AD7616_REG_UP_CNTRL_RESETN(x) GetField(AXI_AD7616_REG_UP_CNTRL,"RESETN",x)

  const reg_t AXI_AD7616_REG_UP_CONV_RATE = '{ 'h0044, "REG_UP_CONV_RATE" , '{
    "UP_CONV_RATE": '{ 31, 0, RW, 'h00000000 }}};
  `define SET_AXI_AD7616_REG_UP_CONV_RATE_UP_CONV_RATE(x) SetField(AXI_AD7616_REG_UP_CONV_RATE,"UP_CONV_RATE",x)
  `define GET_AXI_AD7616_REG_UP_CONV_RATE_UP_CONV_RATE(x) GetField(AXI_AD7616_REG_UP_CONV_RATE,"UP_CONV_RATE",x)

  const reg_t AXI_AD7616_REG_UP_BURST_LENGTH = '{ 'h0048, "REG_UP_BURST_LENGTH" , '{
    "UP_BURST_LENGTH": '{ 4, 0, RW, 'h000 }}};
  `define SET_AXI_AD7616_REG_UP_BURST_LENGTH_UP_BURST_LENGTH(x) SetField(AXI_AD7616_REG_UP_BURST_LENGTH,"UP_BURST_LENGTH",x)
  `define GET_AXI_AD7616_REG_UP_BURST_LENGTH_UP_BURST_LENGTH(x) GetField(AXI_AD7616_REG_UP_BURST_LENGTH,"UP_BURST_LENGTH",x)

  const reg_t AXI_AD7616_REG_UP_READ_DATA = '{ 'h004c, "REG_UP_READ_DATA" , '{
    "UP_READ_DATA": '{ 31, 0, RO, 'h00000000 }}};
  `define SET_AXI_AD7616_REG_UP_READ_DATA_UP_READ_DATA(x) SetField(AXI_AD7616_REG_UP_READ_DATA,"UP_READ_DATA",x)
  `define GET_AXI_AD7616_REG_UP_READ_DATA_UP_READ_DATA(x) GetField(AXI_AD7616_REG_UP_READ_DATA,"UP_READ_DATA",x)

  const reg_t AXI_AD7616_REG_UP_WRITE_DATA = '{ 'h0050, "REG_UP_WRITE_DATA" , '{
    "UP_WRITE_DATA": '{ 31, 0, WO, 'h00000000 }}};
  `define SET_AXI_AD7616_REG_UP_WRITE_DATA_UP_WRITE_DATA(x) SetField(AXI_AD7616_REG_UP_WRITE_DATA,"UP_WRITE_DATA",x)
  `define GET_AXI_AD7616_REG_UP_WRITE_DATA_UP_WRITE_DATA(x) GetField(AXI_AD7616_REG_UP_WRITE_DATA,"UP_WRITE_DATA",x)


endpackage
