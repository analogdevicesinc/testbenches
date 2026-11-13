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

// Bound into every altera_avalon_clock_source instance (see
// adi_intel_vip_bind). The frequency is the CLOCK_RATE the instance was
// generated with.
interface adi_clock_source_bfm_if;

  import adi_clk_rst_bfm_if_base_pkg::*;

  task automatic clock_start();
    altera_avalon_clock_source.clock_start();
  endtask: clock_start

  task automatic clock_stop();
    altera_avalon_clock_source.clock_stop();
  endtask: clock_stop

  class adi_clock_source_bfm_if_class extends adi_clock_source_bfm_if_base;

    function new();
    endfunction

    virtual task start_clock();
      clock_start();
    endtask: start_clock

    virtual task stop_clock();
      clock_stop();
    endtask: stop_clock

  endclass: adi_clock_source_bfm_if_class

  adi_clock_source_bfm_if_class vif = new();

endinterface: adi_clock_source_bfm_if
