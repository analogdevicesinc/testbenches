// ***************************************************************************
// ***************************************************************************
// Copyright (C) 2025 Analog Devices, Inc. All rights reserved.
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

`ifndef _AXIS_DEFINITIONS_SVH_
`define _AXIS_DEFINITIONS_SVH_

// Help build VIP Interface parameters name
`define AXIS_VIP_PARAM_DECL(n)  int n``_VIP_INTERFACE_MODE, \
                                    n``_VIP_SIGNAL_SET, \
                                    n``_VIP_DATA_WIDTH, \
                                    n``_VIP_ID_WIDTH, \
                                    n``_VIP_DEST_WIDTH, \
                                    n``_VIP_USER_WIDTH, \
                                    n``_VIP_USER_BITS_PER_BYTE, \
                                    n``_VIP_HAS_TREADY, \
                                    n``_VIP_HAS_TSTRB, \
                                    n``_VIP_HAS_TKEEP, \
                                    n``_VIP_HAS_TLAST, \
                                    n``_VIP_HAS_ACLKEN, \
                                    n``_VIP_HAS_ARESETN

`define AXIS_VIP_PARAM_ORDER(n) n``_VIP_INTERFACE_MODE,\
                                n``_VIP_SIGNAL_SET,\
                                n``_VIP_DATA_WIDTH,\
                                n``_VIP_ID_WIDTH,\
                                n``_VIP_DEST_WIDTH,\
                                n``_VIP_USER_WIDTH,\
                                n``_VIP_USER_BITS_PER_BYTE,\
                                n``_VIP_HAS_TREADY,\
                                n``_VIP_HAS_TSTRB,\
                                n``_VIP_HAS_TKEEP,\
                                n``_VIP_HAS_TLAST,\
                                n``_VIP_HAS_ACLKEN,\
                                n``_VIP_HAS_ARESETN

`define AXIS_VIP_IF_PARAMS(n) n``_VIP_SIGNAL_SET,\
                              n``_VIP_DEST_WIDTH,\
                              n``_VIP_DATA_WIDTH,\
                              n``_VIP_ID_WIDTH,\
                              n``_VIP_USER_WIDTH,\
                              n``_VIP_USER_BITS_PER_BYTE,\
                              n``_VIP_HAS_ARESETN

`define AXIS_VIP_PARAMS(th,vip) th``_``vip``_0_VIP_INTERFACE_MODE,\
                                th``_``vip``_0_VIP_SIGNAL_SET,\
                                th``_``vip``_0_VIP_DATA_WIDTH,\
                                th``_``vip``_0_VIP_ID_WIDTH,\
                                th``_``vip``_0_VIP_DEST_WIDTH,\
                                th``_``vip``_0_VIP_USER_WIDTH,\
                                th``_``vip``_0_VIP_USER_BITS_PER_BYTE,\
                                th``_``vip``_0_VIP_HAS_TREADY,\
                                th``_``vip``_0_VIP_HAS_TSTRB,\
                                th``_``vip``_0_VIP_HAS_TKEEP,\
                                th``_``vip``_0_VIP_HAS_TLAST,\
                                th``_``vip``_0_VIP_HAS_ACLKEN,\
                                th``_``vip``_0_VIP_HAS_ARESETN

`define AXIS_TRANSACTION_PARAM(th,vip)  .BYTES_PER_TRANSACTION(``th``_``vip``_0_VIP_DATA_WIDTH/8), \
                                        .EN_TKEEP(``th``_``vip``_0_VIP_HAS_TKEEP), \
                                        .EN_TSTRB(``th``_``vip``_0_VIP_HAS_TSTRB), \
                                        .EN_TLAST(``th``_``vip``_0_VIP_HAS_TLAST), \
                                        .EN_TUSER((``th``_``vip``_0_VIP_USER_WIDTH) ? 1'b1 : 1'b0), \
                                        .EN_TID((``th``_``vip``_0_VIP_ID_WIDTH) ? 1'b1 : 1'b0), \
                                        .EN_TDEST((``th``_``vip``_0_VIP_DEST_WIDTH) ? 1'b1 : 1'b0), \
                                        .TUSER_BYTE_BASED((``th``_``vip``_0_VIP_USER_BITS_PER_BYTE) ? 1'b1 : 1'b0), \
                                        .TID_WIDTH((``th``_``vip``_0_VIP_ID_WIDTH) ? ``th``_``vip``_0_VIP_ID_WIDTH : 'd1), \
                                        .TDEST_WIDTH((``th``_``vip``_0_VIP_DEST_WIDTH) ? ``th``_``vip``_0_VIP_DEST_WIDTH : 'd1), \
                                        .TUSER_WIDTH((``th``_``vip``_0_VIP_USER_WIDTH) ? ``th``_``vip``_0_VIP_USER_WIDTH : 'd1)

`define AXIS_TRANSACTION_SEQ_PARAM(n) .BYTES_PER_TRANSACTION(``n``_VIP_DATA_WIDTH/8), \
                                      .EN_TKEEP(``n``_VIP_HAS_TKEEP), \
                                      .EN_TSTRB(``n``_VIP_HAS_TSTRB), \
                                      .EN_TLAST(``n``_VIP_HAS_TLAST), \
                                      .EN_TUSER((``n``_VIP_USER_WIDTH) ? 1'b1 : 1'b0), \
                                      .EN_TID((``n``_VIP_ID_WIDTH) ? 1'b1 : 1'b0), \
                                      .EN_TDEST((``n``_VIP_DEST_WIDTH) ? 1'b1 : 1'b0), \
                                      .TUSER_BYTE_BASED((``n``_VIP_USER_BITS_PER_BYTE) ? 1'b1 : 1'b0), \
                                      .TID_WIDTH((``n``_VIP_ID_WIDTH) ? ``n``_VIP_ID_WIDTH : 'd1), \
                                      .TDEST_WIDTH((``n``_VIP_DEST_WIDTH) ? ``n``_VIP_DEST_WIDTH : 'd1), \
                                      .TUSER_WIDTH((``n``_VIP_USER_WIDTH) ? ``n``_VIP_USER_WIDTH : 'd1)

`endif
