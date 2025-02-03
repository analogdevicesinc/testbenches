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

`include "utils.svh"

package adi_api_pkg;

  import logger_pkg::*;
  import adi_common_pkg::*;
  import m_axi_sequencer_pkg::*;

  class adi_api extends adi_component;
  
    protected m_axi_sequencer_base bus;
    protected bit [31:0] base_address;

    // Semantic versioning
    bit [7:0] ver_major;
    bit [7:0] ver_minor;
    bit [7:0] ver_patch;

    function new(
      input string name,
      input m_axi_sequencer_base bus,
      input bit [31:0] base_address,
      input adi_component parent = null);

      super.new(name, parent);

      this.bus = bus;
      this.base_address = base_address;
    endfunction: new


    virtual task probe();
      bit [31:0] val;
      this.bus.RegRead32(this.base_address + 'h0, val);
      {ver_major, ver_minor, ver_patch} = val;
      this.info($sformatf("Found peripheral version: %0d.%0d.%s", ver_major, ver_minor, ver_patch), ADI_VERBOSITY_HIGH);
    endtask
    
    task axi_read(
      input  [31:0] addr,
      output [31:0] data);

      this.bus.RegRead32(this.base_address + addr, data);
    endtask: axi_read

    task axi_write(
      input [31:0] addr,
      input [31:0] data);

      this.bus.RegWrite32(this.base_address + addr, data);
    endtask: axi_write

    task axi_verify(
      input [31:0] addr,
      input [31:0] data);

      this.bus.RegReadVerify32(this.base_address + addr, data);
    endtask: axi_verify

  endclass: adi_api

  
  class adi_regmap extends adi_component;
    function new(
      input string name,
      input adi_api parent = null);

      super.new(name, parent);
    endfunction: new
  endclass: adi_regmap

endpackage: adi_api_pkg
