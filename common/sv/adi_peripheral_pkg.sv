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
//      <https://www.gnu.org/licenses/old_licenses/gpl_2.0.html>
//
// OR
//
//   2. An ADI specific BSD license, which can be found in the top level directory
//      of this repository (LICENSE_ADIBSD), and also on_line at:
//      https://github.com/analogdevicesinc/hdl/blob/master/LICENSE_ADIBSD
//      This will allow to generate bit files and not release the source code,
//      as long as it attaches to an ADI device.
//
// ***************************************************************************
// ***************************************************************************
`include "utils.svh"

package adi_peripheral_pkg;

  import logger_pkg::*;
  import reg_accessor_pkg::*;

   //============================================================================
  // Base peripheral class
  //============================================================================
  class adi_peripheral;
    reg_accessor bus;
    bit [31:0] base_address;

    // Semantic versioning
    bit [7:0] ver_major;
    bit [7:0] ver_minor;
    bit [7:0] ver_patch;

    // -----------------
    //
    // -----------------
    function new (reg_accessor bus, bit [31:0] base_address);
      this.bus = bus;
      this.base_address = base_address;
    endfunction

    // -----------------
    //
    // -----------------
    virtual task probe();
      bit [31:0] val;
      this.bus.RegRead32(this.base_address + 'h0, val);
      {ver_major,ver_minor,ver_patch} = val;
      `INFO(("Found peripheral version: %0d.%0d.%s",ver_major,ver_minor,ver_patch));
    endtask

  endclass

endpackage
