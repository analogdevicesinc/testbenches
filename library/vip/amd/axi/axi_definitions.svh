// ***************************************************************************
// ***************************************************************************
// Copyright 2014 - 2024 (c) Analog Devices, Inc. All rights reserved.
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


`timescale 1ns/1ps

`ifndef _AXI_DEFINITIONS_SVH_
`define _AXI_DEFINITIONS_SVH_

// Help build VIP Interface parameters name
`define AXI_VIP_IF_PARAMS(n)  n``_VIP_PROTOCOL,\
                              n``_VIP_ADDR_WIDTH,\
                              n``_VIP_WDATA_WIDTH,\
                              n``_VIP_RDATA_WIDTH,\
                              n``_VIP_WID_WIDTH,\
                              n``_VIP_RID_WIDTH,\
                              n``_VIP_AWUSER_WIDTH,\
                              n``_VIP_WUSER_WIDTH,\
                              n``_VIP_BUSER_WIDTH,\
                              n``_VIP_ARUSER_WIDTH,\
                              n``_VIP_RUSER_WIDTH,\
                              n``_VIP_SUPPORTS_NARROW,\
                              n``_VIP_HAS_BURST,\
                              n``_VIP_HAS_LOCK,\
                              n``_VIP_HAS_CACHE,\
                              n``_VIP_HAS_REGION,\
                              n``_VIP_HAS_PROT,\
                              n``_VIP_HAS_QOS,\
                              n``_VIP_HAS_WSTRB,\
                              n``_VIP_HAS_BRESP,\
                              n``_VIP_HAS_RRESP,\
                              n``_VIP_HAS_ARESETN

`define AXI_VIP_PARAM_ORDER(n)  n``_VIP_PROTOCOL,\
                                n``_VIP_ADDR_WIDTH,\
                                n``_VIP_WDATA_WIDTH,\
                                n``_VIP_RDATA_WIDTH,\
                                n``_VIP_WID_WIDTH,\
                                n``_VIP_RID_WIDTH,\
                                n``_VIP_AWUSER_WIDTH,\
                                n``_VIP_WUSER_WIDTH,\
                                n``_VIP_BUSER_WIDTH,\
                                n``_VIP_ARUSER_WIDTH,\
                                n``_VIP_RUSER_WIDTH,\
                                n``_VIP_SUPPORTS_NARROW,\
                                n``_VIP_HAS_BURST,\
                                n``_VIP_HAS_LOCK,\
                                n``_VIP_HAS_CACHE,\
                                n``_VIP_HAS_REGION,\
                                n``_VIP_HAS_PROT,\
                                n``_VIP_HAS_QOS,\
                                n``_VIP_HAS_WSTRB,\
                                n``_VIP_HAS_BRESP,\
                                n``_VIP_HAS_RRESP,\
                                n``_VIP_HAS_ARESETN

`define AXI_VIP_PARAMS(th,vip)  th``_``vip``_0_VIP_PROTOCOL,\
                                th``_``vip``_0_VIP_ADDR_WIDTH,\
                                th``_``vip``_0_VIP_DATA_WIDTH,\
                                th``_``vip``_0_VIP_DATA_WIDTH,\
                                th``_``vip``_0_VIP_ID_WIDTH,\
                                th``_``vip``_0_VIP_ID_WIDTH,\
                                th``_``vip``_0_VIP_AWUSER_WIDTH,\
                                th``_``vip``_0_VIP_WUSER_WIDTH,\
                                th``_``vip``_0_VIP_BUSER_WIDTH,\
                                th``_``vip``_0_VIP_ARUSER_WIDTH,\
                                th``_``vip``_0_VIP_RUSER_WIDTH,\
                                th``_``vip``_0_VIP_SUPPORTS_NARROW,\
                                th``_``vip``_0_VIP_HAS_BURST,\
                                th``_``vip``_0_VIP_HAS_LOCK,\
                                th``_``vip``_0_VIP_HAS_CACHE,\
                                th``_``vip``_0_VIP_HAS_REGION,\
                                th``_``vip``_0_VIP_HAS_PROT,\
                                th``_``vip``_0_VIP_HAS_QOS,\
                                th``_``vip``_0_VIP_HAS_WSTRB,\
                                th``_``vip``_0_VIP_HAS_BRESP,\
                                th``_``vip``_0_VIP_HAS_RRESP,\
                                th``_``vip``_0_VIP_HAS_ARESETN

`endif
