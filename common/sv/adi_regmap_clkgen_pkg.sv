// ***************************************************************************
// ***************************************************************************
// Copyright 2014 - 2021 (c) Analog Devices, Inc. All rights reserved.
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

package adi_regmap_clkgen_pkg;
  import adi_regmap_pkg::*;


/* Clock Generator (axi_clkgen) */

  const reg_t AXI_CLKGEN_REG_RSTN = '{ 'h0040, "REG_RSTN" , '{
    "MMCM_RSTN": '{ 1, 1, RW, 'h0 },
    "RSTN": '{ 0, 0, RW, 'h0 }}};
  `define SET_AXI_CLKGEN_REG_RSTN_MMCM_RSTN(x) SetField(AXI_CLKGEN_REG_RSTN,"MMCM_RSTN",x)
  `define GET_AXI_CLKGEN_REG_RSTN_MMCM_RSTN(x) GetField(AXI_CLKGEN_REG_RSTN,"MMCM_RSTN",x)
  `define SET_AXI_CLKGEN_REG_RSTN_RSTN(x) SetField(AXI_CLKGEN_REG_RSTN,"RSTN",x)
  `define GET_AXI_CLKGEN_REG_RSTN_RSTN(x) GetField(AXI_CLKGEN_REG_RSTN,"RSTN",x)

  const reg_t AXI_CLKGEN_REG_CLK_SEL = '{ 'h0044, "REG_CLK_SEL" , '{
    "CLK_SEL": '{ 0, 0, RW, 'h0 }}};
  `define SET_AXI_CLKGEN_REG_CLK_SEL_CLK_SEL(x) SetField(AXI_CLKGEN_REG_CLK_SEL,"CLK_SEL",x)
  `define GET_AXI_CLKGEN_REG_CLK_SEL_CLK_SEL(x) GetField(AXI_CLKGEN_REG_CLK_SEL,"CLK_SEL",x)

  const reg_t AXI_CLKGEN_REG_MMCM_STATUS = '{ 'h005c, "REG_MMCM_STATUS" , '{
    "MMCM_LOCKED": '{ 0, 0, RO, 'h0 }}};
  `define SET_AXI_CLKGEN_REG_MMCM_STATUS_MMCM_LOCKED(x) SetField(AXI_CLKGEN_REG_MMCM_STATUS,"MMCM_LOCKED",x)
  `define GET_AXI_CLKGEN_REG_MMCM_STATUS_MMCM_LOCKED(x) GetField(AXI_CLKGEN_REG_MMCM_STATUS,"MMCM_LOCKED",x)

  const reg_t AXI_CLKGEN_REG_DRP_CNTRL = '{ 'h0070, "REG_DRP_CNTRL" , '{
    "DRP_RWN": '{ 28, 28, RW, 'h0 },
    "DRP_ADDRESS": '{ 27, 16, RW, 'h000 },
    "DRP_WDATA": '{ 15, 0, RW, 'h0000 }}};
  `define SET_AXI_CLKGEN_REG_DRP_CNTRL_DRP_RWN(x) SetField(AXI_CLKGEN_REG_DRP_CNTRL,"DRP_RWN",x)
  `define GET_AXI_CLKGEN_REG_DRP_CNTRL_DRP_RWN(x) GetField(AXI_CLKGEN_REG_DRP_CNTRL,"DRP_RWN",x)
  `define SET_AXI_CLKGEN_REG_DRP_CNTRL_DRP_ADDRESS(x) SetField(AXI_CLKGEN_REG_DRP_CNTRL,"DRP_ADDRESS",x)
  `define GET_AXI_CLKGEN_REG_DRP_CNTRL_DRP_ADDRESS(x) GetField(AXI_CLKGEN_REG_DRP_CNTRL,"DRP_ADDRESS",x)
  `define SET_AXI_CLKGEN_REG_DRP_CNTRL_DRP_WDATA(x) SetField(AXI_CLKGEN_REG_DRP_CNTRL,"DRP_WDATA",x)
  `define GET_AXI_CLKGEN_REG_DRP_CNTRL_DRP_WDATA(x) GetField(AXI_CLKGEN_REG_DRP_CNTRL,"DRP_WDATA",x)

  const reg_t AXI_CLKGEN_REG_DRP_STATUS = '{ 'h0074, "REG_DRP_STATUS" , '{
    "MMCM_LOCKED": '{ 17, 17, RO, 'h0 },
    "DRP_STATUS": '{ 16, 16, RO, 'h0 },
    "DRP_RDATA": '{ 15, 0, RO, 'h0000 }}};
  `define SET_AXI_CLKGEN_REG_DRP_STATUS_MMCM_LOCKED(x) SetField(AXI_CLKGEN_REG_DRP_STATUS,"MMCM_LOCKED",x)
  `define GET_AXI_CLKGEN_REG_DRP_STATUS_MMCM_LOCKED(x) GetField(AXI_CLKGEN_REG_DRP_STATUS,"MMCM_LOCKED",x)
  `define SET_AXI_CLKGEN_REG_DRP_STATUS_DRP_STATUS(x) SetField(AXI_CLKGEN_REG_DRP_STATUS,"DRP_STATUS",x)
  `define GET_AXI_CLKGEN_REG_DRP_STATUS_DRP_STATUS(x) GetField(AXI_CLKGEN_REG_DRP_STATUS,"DRP_STATUS",x)
  `define SET_AXI_CLKGEN_REG_DRP_STATUS_DRP_RDATA(x) SetField(AXI_CLKGEN_REG_DRP_STATUS,"DRP_RDATA",x)
  `define GET_AXI_CLKGEN_REG_DRP_STATUS_DRP_RDATA(x) GetField(AXI_CLKGEN_REG_DRP_STATUS,"DRP_RDATA",x)

  const reg_t AXI_CLKGEN_REG_FPGA_VOLTAGE = '{ 'h0140, "REG_FPGA_VOLTAGE" , '{
    "FPGA_VOLTAGE": '{ 15, 0, RO, 'h0 }}};
  `define SET_AXI_CLKGEN_REG_FPGA_VOLTAGE_FPGA_VOLTAGE(x) SetField(AXI_CLKGEN_REG_FPGA_VOLTAGE,"FPGA_VOLTAGE",x)
  `define GET_AXI_CLKGEN_REG_FPGA_VOLTAGE_FPGA_VOLTAGE(x) GetField(AXI_CLKGEN_REG_FPGA_VOLTAGE,"FPGA_VOLTAGE",x)


endpackage
