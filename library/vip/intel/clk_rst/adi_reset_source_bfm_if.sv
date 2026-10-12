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

// Bound into every altera_avalon_reset_source instance (see
// adi_intel_vip_bind). The polarity is the ASSERT_HIGH_RESET the instance was
// generated with.
interface adi_reset_source_bfm_if;

  import adi_clk_rst_bfm_if_base_pkg::*;

  task automatic reset_assert();
    altera_avalon_reset_source.reset_assert();
  endtask: reset_assert

  task automatic reset_deassert();
    altera_avalon_reset_source.reset_deassert();
  endtask: reset_deassert

  class adi_reset_source_bfm_if_class extends adi_reset_source_bfm_if_base;

    function new();
    endfunction

    virtual task assert_reset();
      reset_assert();
    endtask: assert_reset

    virtual task deassert_reset();
      reset_deassert();
    endtask: deassert_reset

  endclass: adi_reset_source_bfm_if_class

  adi_reset_source_bfm_if_class vif = new();

endinterface: adi_reset_source_bfm_if
