// ***************************************************************************
// ***************************************************************************
// Copyright 2025 (c) Analog Devices, Inc. All rights reserved.
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

`include "utils.svh"

module system_tb ();

  wire dco_p;
  wire dco_n;
  wire da_p;
  wire da_n;
  wire db_p;
  wire db_n;
  wire sync_n;
  wire frame_p;
  wire frame_n;

  `TEST_PROGRAM test (
    .dco_p(dco_p),
    .dco_n(dco_n),
    .da_p(da_p),
    .da_n(da_n),
    .db_p(db_p),
    .db_n(db_n),
    .sync_n(sync_n),
    .frame_p(frame_p),
    .frame_n(frame_n));

  test_harness `TH (
    .dco_p(dco_p),
    .dco_n(dco_n),
    .d0a_p(da_p),
    .d0a_n(da_n),
    .d1a_p(db_p),
    .d1a_n(db_n),
    .sync_n(sync_n),
    .frame_p(frame_p),
    .frame_n(frame_n));

endmodule
