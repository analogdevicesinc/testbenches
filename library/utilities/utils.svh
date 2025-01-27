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


`timescale 1ns/1ps

`ifndef _UTILS_SVH_
`define _UTILS_SVH_

// Help build agent package name like "<test_harness>_<mng_axi_vip>_0_pkg"
`define PKGIFY(th,vip) th``_``vip``_0_pkg

// Help build agent type like "<test_harness>_<mng_axi_vip>_0_<mst_t>"
`define AGENT(th,vip,agent_type) th``_``vip``_0_``agent_type

// Help build VIP parameter name  e.g. test_harness_dst_axis_vip_0_VIP_DATA_WIDTH
`define GETPARAM(th,vip,param) th``_``vip``_0_``param

// Macros used in Simulation files during simulation
`define INFO(m,v)  \
  PrintInfo($sformatf("%s", \
    $sformatf m ),v)

`define WARNING(m)  \
  PrintWarning($sformatf("%s", \
    $sformatf m ))

`define ERROR(m)  \
  PrintError($sformatf("%s", \
    $sformatf m ))

`define FATAL(m)  \
  PrintFatal($sformatf("%s\n  found in %s:%0d", \
    $sformatf m , `__FILE__, `__LINE__))

`define MAX(a,b) ((a > b) ? a : b)
`define MIN(a,b) ((a > b) ? b : a)

`endif
