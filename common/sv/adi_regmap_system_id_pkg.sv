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

package adi_regmap_system_id_pkg;
  import adi_regmap_pkg::*;


/* System ID (axi_system_id) */

  const reg_t AXI_SYSTEM_ID_VERSION = '{ 'h0000, "VERSION" , '{
    "VERSION_MAJOR": '{ 31, 16, RO, 'h0001 },
    "VERSION_MINOR": '{ 15, 8, RO, 'h00 },
    "VERSION_PATCH": '{ 7, 0, RO, 'h61 }}};
  `define SET_AXI_SYSTEM_ID_VERSION_VERSION_MAJOR(x) SetField(AXI_SYSTEM_ID_VERSION,"VERSION_MAJOR",x)
  `define GET_AXI_SYSTEM_ID_VERSION_VERSION_MAJOR(x) GetField(AXI_SYSTEM_ID_VERSION,"VERSION_MAJOR",x)
  `define SET_AXI_SYSTEM_ID_VERSION_VERSION_MINOR(x) SetField(AXI_SYSTEM_ID_VERSION,"VERSION_MINOR",x)
  `define GET_AXI_SYSTEM_ID_VERSION_VERSION_MINOR(x) GetField(AXI_SYSTEM_ID_VERSION,"VERSION_MINOR",x)
  `define SET_AXI_SYSTEM_ID_VERSION_VERSION_PATCH(x) SetField(AXI_SYSTEM_ID_VERSION,"VERSION_PATCH",x)
  `define GET_AXI_SYSTEM_ID_VERSION_VERSION_PATCH(x) GetField(AXI_SYSTEM_ID_VERSION,"VERSION_PATCH",x)

  const reg_t AXI_SYSTEM_ID_PERIPHERAL_ID = '{ 'h0004, "PERIPHERAL_ID" , '{
    "PERIPHERAL_ID": '{ 31, 0, RO, 0 }}};
  `define SET_AXI_SYSTEM_ID_PERIPHERAL_ID_PERIPHERAL_ID(x) SetField(AXI_SYSTEM_ID_PERIPHERAL_ID,"PERIPHERAL_ID",x)
  `define GET_AXI_SYSTEM_ID_PERIPHERAL_ID_PERIPHERAL_ID(x) GetField(AXI_SYSTEM_ID_PERIPHERAL_ID,"PERIPHERAL_ID",x)

  const reg_t AXI_SYSTEM_ID_SCRATCH = '{ 'h0008, "SCRATCH" , '{
    "SCRATCH": '{ 31, 0, RW, 'h00000000 }}};
  `define SET_AXI_SYSTEM_ID_SCRATCH_SCRATCH(x) SetField(AXI_SYSTEM_ID_SCRATCH,"SCRATCH",x)
  `define GET_AXI_SYSTEM_ID_SCRATCH_SCRATCH(x) GetField(AXI_SYSTEM_ID_SCRATCH,"SCRATCH",x)

  const reg_t AXI_SYSTEM_ID_IDENTIFICATION = '{ 'h000c, "IDENTIFICATION" , '{
    "IDENTIFICATION": '{ 31, 0, RO, 'h53594944 }}};
  `define SET_AXI_SYSTEM_ID_IDENTIFICATION_IDENTIFICATION(x) SetField(AXI_SYSTEM_ID_IDENTIFICATION,"IDENTIFICATION",x)
  `define GET_AXI_SYSTEM_ID_IDENTIFICATION_IDENTIFICATION(x) GetField(AXI_SYSTEM_ID_IDENTIFICATION,"IDENTIFICATION",x)

  const reg_t AXI_SYSTEM_ID_SYSROM_START = '{ 'h0800, "SYSROM_START" , '{
    "SYSROM_START": '{ 31, 0, RO, 0 }}};
  `define SET_AXI_SYSTEM_ID_SYSROM_START_SYSROM_START(x) SetField(AXI_SYSTEM_ID_SYSROM_START,"SYSROM_START",x)
  `define GET_AXI_SYSTEM_ID_SYSROM_START_SYSROM_START(x) GetField(AXI_SYSTEM_ID_SYSROM_START,"SYSROM_START",x)

  const reg_t AXI_SYSTEM_ID_PRROM_START = '{ 'h1000, "PRROM_START" , '{
    "SYSROM_START": '{ 31, 0, RO, 0 }}};
  `define SET_AXI_SYSTEM_ID_PRROM_START_SYSROM_START(x) SetField(AXI_SYSTEM_ID_PRROM_START,"SYSROM_START",x)
  `define GET_AXI_SYSTEM_ID_PRROM_START_SYSROM_START(x) GetField(AXI_SYSTEM_ID_PRROM_START,"SYSROM_START",x)


endpackage
