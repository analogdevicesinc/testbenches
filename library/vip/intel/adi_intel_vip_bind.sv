// ***************************************************************************
// ***************************************************************************
// Copyright (C) 2026 Analog Devices, Inc. All rights reserved.
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

// Attaches the ADI interfaces to the Intel BFMs of the test harness. A bind in
// the compilation unit scope is not applied, so this module has to be
// elaborated as an additional top level.
module adi_intel_vip_bind;

  bind altera_avalon_mm_master_bfm adi_avmm_master_bfm_if IF();

  bind altera_avalon_mm_slave_bfm adi_avmm_slave_bfm_if #(
    .AV_SYMBOL_W (AV_SYMBOL_W),
    .AV_NUMSYMBOLS (AV_NUMSYMBOLS)
  ) IF();

  bind altera_avalon_clock_source adi_clock_source_bfm_if IF();

  bind altera_avalon_reset_source adi_reset_source_bfm_if IF();

endmodule: adi_intel_vip_bind
