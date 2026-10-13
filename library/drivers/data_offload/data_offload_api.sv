// ***************************************************************************
// ***************************************************************************
// Copyright (C) 2024-2025 Analog Devices, Inc. All rights reserved.
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

`include "utils.svh"

package data_offload_api_pkg;

  import logger_pkg::*;
  import adi_component_pkg::*;
  import adi_api_pkg::*;
  import adi_regmap_pkg::*;
  import adi_regmap_data_offload_pkg::*;
  import m_axi_sequencer_pkg::*;

  class data_offload_api extends adi_api;

    // -----------------
    //
    // -----------------
    function new(
      input string name,
      input m_axi_sequencer_base bus,
      input bit [31:0] base_address,
      input adi_component parent = null);

      super.new(name, bus, base_address, parent);
    endfunction

    // -----------------
    //
    // -----------------
    task set_transfer_length(input int length);
      this.axi_write(GetAddrs(DO_TRANSFER_LENGTH),
                        `SET_DO_TRANSFER_LENGTH_PARTIAL_LENGTH(length-1));
    endtask

    // -----------------
    //
    // -----------------
    task enable_oneshot_mode();
      this.axi_write(GetAddrs(DO_CONTROL),
                        `SET_DO_CONTROL_ONESHOT_EN(1));
    endtask

    // -----------------
    //
    // -----------------
    task disable_oneshot_mode();
      this.axi_write(GetAddrs(DO_CONTROL),
                        `SET_DO_CONTROL_ONESHOT_EN(0));
    endtask

    // -----------------
    //
    // -----------------
    task enable_bypass_mode();
      this.axi_write(GetAddrs(DO_CONTROL),
                        `SET_DO_CONTROL_OFFLOAD_BYPASS(1));
    endtask

    // -----------------
    //
    // -----------------
    task disable_bypass_mode();
      this.axi_write(GetAddrs(DO_CONTROL),
                        `SET_DO_CONTROL_OFFLOAD_BYPASS(0));
    endtask

    // -----------------
    //
    // -----------------
    task assert_reset();
      this.axi_write(GetAddrs(DO_CONTROL),
                        `SET_DO_RESETN_OFFLOAD_RESETN(0));
    endtask

    // -----------------
    //
    // -----------------
    task deassert_reset();
      this.axi_write(GetAddrs(DO_RESETN_OFFLOAD),
                        `SET_DO_RESETN_OFFLOAD_RESETN(1));
    endtask

  endclass

endpackage
