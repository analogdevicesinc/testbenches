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

package adi_regmap_common_pkg;
  import adi_regmap_pkg::*;


/* Base (common to all cores) */

  const reg_t REG_VERSION = '{ 'h0000, "REG_VERSION" , '{
    "VERSION": '{ 31, 0, RO, 'h00000000 }}};
  `define SET_REG_VERSION_VERSION(x) SetField(REG_VERSION,"VERSION",x)
  `define GET_REG_VERSION_VERSION(x) GetField(REG_VERSION,"VERSION",x)

  const reg_t REG_ID = '{ 'h0004, "REG_ID" , '{
    "ID": '{ 31, 0, RO, 'h00000000 }}};
  `define SET_REG_ID_ID(x) SetField(REG_ID,"ID",x)
  `define GET_REG_ID_ID(x) GetField(REG_ID,"ID",x)

  const reg_t REG_SCRATCH = '{ 'h0008, "REG_SCRATCH" , '{
    "SCRATCH": '{ 31, 0, RW, 'h00000000 }}};
  `define SET_REG_SCRATCH_SCRATCH(x) SetField(REG_SCRATCH,"SCRATCH",x)
  `define GET_REG_SCRATCH_SCRATCH(x) GetField(REG_SCRATCH,"SCRATCH",x)

  const reg_t REG_CONFIG = '{ 'h000c, "REG_CONFIG" , '{
    "IQCORRECTION_DISABLE": '{ 0, 0, RO, 'h0 },
    "DCFILTER_DISABLE": '{ 1, 1, RO, 'h0 },
    "DATAFORMAT_DISABLE": '{ 2, 2, RO, 'h0 },
    "USERPORTS_DISABLE": '{ 3, 3, RO, 'h0 },
    "MODE_1R1T": '{ 4, 4, RO, 'h0 },
    "DELAY_CONTROL_DISABLE": '{ 5, 5, RO, 'h0 },
    "DDS_DISABLE": '{ 6, 6, RO, 'h0 },
    "CMOS_OR_LVDS_N": '{ 7, 7, RO, 'h0 },
    "PPS_RECEIVER_ENABLE": '{ 8, 8, RO, 'h0 },
    "SCALECORRECTION_ONLY": '{ 9, 9, RO, 'h0 }}};
  `define SET_REG_CONFIG_IQCORRECTION_DISABLE(x) SetField(REG_CONFIG,"IQCORRECTION_DISABLE",x)
  `define GET_REG_CONFIG_IQCORRECTION_DISABLE(x) GetField(REG_CONFIG,"IQCORRECTION_DISABLE",x)
  `define SET_REG_CONFIG_DCFILTER_DISABLE(x) SetField(REG_CONFIG,"DCFILTER_DISABLE",x)
  `define GET_REG_CONFIG_DCFILTER_DISABLE(x) GetField(REG_CONFIG,"DCFILTER_DISABLE",x)
  `define SET_REG_CONFIG_DATAFORMAT_DISABLE(x) SetField(REG_CONFIG,"DATAFORMAT_DISABLE",x)
  `define GET_REG_CONFIG_DATAFORMAT_DISABLE(x) GetField(REG_CONFIG,"DATAFORMAT_DISABLE",x)
  `define SET_REG_CONFIG_USERPORTS_DISABLE(x) SetField(REG_CONFIG,"USERPORTS_DISABLE",x)
  `define GET_REG_CONFIG_USERPORTS_DISABLE(x) GetField(REG_CONFIG,"USERPORTS_DISABLE",x)
  `define SET_REG_CONFIG_MODE_1R1T(x) SetField(REG_CONFIG,"MODE_1R1T",x)
  `define GET_REG_CONFIG_MODE_1R1T(x) GetField(REG_CONFIG,"MODE_1R1T",x)
  `define SET_REG_CONFIG_DELAY_CONTROL_DISABLE(x) SetField(REG_CONFIG,"DELAY_CONTROL_DISABLE",x)
  `define GET_REG_CONFIG_DELAY_CONTROL_DISABLE(x) GetField(REG_CONFIG,"DELAY_CONTROL_DISABLE",x)
  `define SET_REG_CONFIG_DDS_DISABLE(x) SetField(REG_CONFIG,"DDS_DISABLE",x)
  `define GET_REG_CONFIG_DDS_DISABLE(x) GetField(REG_CONFIG,"DDS_DISABLE",x)
  `define SET_REG_CONFIG_CMOS_OR_LVDS_N(x) SetField(REG_CONFIG,"CMOS_OR_LVDS_N",x)
  `define GET_REG_CONFIG_CMOS_OR_LVDS_N(x) GetField(REG_CONFIG,"CMOS_OR_LVDS_N",x)
  `define SET_REG_CONFIG_PPS_RECEIVER_ENABLE(x) SetField(REG_CONFIG,"PPS_RECEIVER_ENABLE",x)
  `define GET_REG_CONFIG_PPS_RECEIVER_ENABLE(x) GetField(REG_CONFIG,"PPS_RECEIVER_ENABLE",x)
  `define SET_REG_CONFIG_SCALECORRECTION_ONLY(x) SetField(REG_CONFIG,"SCALECORRECTION_ONLY",x)
  `define GET_REG_CONFIG_SCALECORRECTION_ONLY(x) GetField(REG_CONFIG,"SCALECORRECTION_ONLY",x)

  const reg_t REG_PPS_IRQ_MASK = '{ 'h0010, "REG_PPS_IRQ_MASK" , '{
    "PPS_IRQ_MASK": '{ 0, 0, RW, 'h1 }}};
  `define SET_REG_PPS_IRQ_MASK_PPS_IRQ_MASK(x) SetField(REG_PPS_IRQ_MASK,"PPS_IRQ_MASK",x)
  `define GET_REG_PPS_IRQ_MASK_PPS_IRQ_MASK(x) GetField(REG_PPS_IRQ_MASK,"PPS_IRQ_MASK",x)

  const reg_t REG_FPGA_INFO = '{ 'h001c, "REG_FPGA_INFO" , '{
    "FPGA_TECHNOLOGY": '{ 31, 24, RO, 'h0 },
    "FPGA_FAMILY": '{ 23, 16, RO, 'h0 },
    "SPEED_GRADE": '{ 15, 8, RO, 'h0 },
    "DEV_PACKAGE": '{ 7, 0, RO, 'h0 }}};
  `define SET_REG_FPGA_INFO_FPGA_TECHNOLOGY(x) SetField(REG_FPGA_INFO,"FPGA_TECHNOLOGY",x)
  `define GET_REG_FPGA_INFO_FPGA_TECHNOLOGY(x) GetField(REG_FPGA_INFO,"FPGA_TECHNOLOGY",x)
  `define SET_REG_FPGA_INFO_FPGA_FAMILY(x) SetField(REG_FPGA_INFO,"FPGA_FAMILY",x)
  `define GET_REG_FPGA_INFO_FPGA_FAMILY(x) GetField(REG_FPGA_INFO,"FPGA_FAMILY",x)
  `define SET_REG_FPGA_INFO_SPEED_GRADE(x) SetField(REG_FPGA_INFO,"SPEED_GRADE",x)
  `define GET_REG_FPGA_INFO_SPEED_GRADE(x) GetField(REG_FPGA_INFO,"SPEED_GRADE",x)
  `define SET_REG_FPGA_INFO_DEV_PACKAGE(x) SetField(REG_FPGA_INFO,"DEV_PACKAGE",x)
  `define GET_REG_FPGA_INFO_DEV_PACKAGE(x) GetField(REG_FPGA_INFO,"DEV_PACKAGE",x)


endpackage
