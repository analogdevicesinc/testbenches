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

package adi_avmm_bfm_if_base_pkg;

  virtual class adi_avmm_master_bfm_if_base;

    function new();
    endfunction

    pure virtual task write32(
      input bit [63:0] addr,
      input bit [31:0] data);

    pure virtual task read32(
      input bit [63:0] addr,
      output bit [31:0] data);

  endclass: adi_avmm_master_bfm_if_base


  virtual class adi_avmm_slave_bfm_if_base;

    function new();
    endfunction

    pure virtual task start();
    pure virtual task stop();

    // Prints every command the slave receives
    pure virtual function void set_debug(input bit enable);

    // Beats and address ranges of the accesses since the last clear_stats
    pure virtual function void clear_stats();
    pure virtual function string get_stats();

    pure virtual function logic [31:0] backdoor_read32(input bit [63:0] addr);

    pure virtual function void backdoor_write32(
      input bit [63:0] addr,
      input logic [31:0] data,
      input bit [3:0] strb);

  endclass: adi_avmm_slave_bfm_if_base

endpackage: adi_avmm_bfm_if_base_pkg
