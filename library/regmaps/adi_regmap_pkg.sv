// ***************************************************************************
// ***************************************************************************
// Copyright (C) 2014 - 2021 Analog Devices, Inc. All rights reserved.
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

package adi_regmap_pkg;

  import logger_pkg::*;

  typedef enum {NA, R, RO, ROV, RW, RW1C, RW1CV, RW1S, W1S, WO} acc_t;


  class register_base extends adi_component;

    logic [31:0] value;
    protected logic [31:0] reset_value;
    protected int address;
    protected bit initialization_done;

    function new(
      input string name,
      input int address,
      input adi_component parent = null);

      super.new(name, parent);
      
      this.name = name;
      this.value = 'h0;
      this.reset_value = 'h0;
      this.address = address;
      this.initialization_done = 0;
    endfunction

    function logic [31:0] get();
      this.info($sformatf("Getting reg %s with value %h", this.name, this.value), ADI_VERBOSITY_HIGH);

      return value;
    endfunction

    function void set(input logic [31:0] value);
      this.info($sformatf("Setting reg %s with value %h (%h)", this.name, value, this.value), ADI_VERBOSITY_HIGH);

      this.value = value;
    endfunction

    function logic [31:0] get_reset_value();
      this.info($sformatf("Getting reg %s with reset value %h", this.name, this.reset_value), ADI_VERBOSITY_HIGH);

      return reset_value;
    endfunction

    function void set_reset_value(input logic [31:0] reset_value);
      if (initialization_done)
        this.fatal($sformatf("Changing the reset value after the registermap is created is not allowed!"));

      this.info($sformatf("Setting reg %s with reset value %h (%h)", this.name, reset_value, this.reset_value), ADI_VERBOSITY_HIGH);
    
      this.reset_value = this.reset_value | reset_value;
    endfunction

    function int get_address();
      return this.address;
    endfunction

    function string get_name();
      return this.name;
    endfunction

  endclass


  class field_base extends adi_component;

    local int msb;
    local int lsb;
    local acc_t access;
    local logic [31:0] reset_value;

    local register_base reg_handle;

    function new(
      input string name,
      input int msb,
      input int lsb,
      input acc_t access,
      input int reset_value,
      input register_base parent = null);

      automatic logic [31:0] update_value = 'h0;

      super.new(name, parent);

      this.name = name;
      this.msb = msb;
      this.lsb = lsb;
      this.access = access;
      this.reset_value = reset_value;
      this.reg_handle = parent;

      update_value = reset_value << this.lsb;
      for (int i=this.msb+1; i<=31; i++) begin
        update_value[i]=1'b0;
      end

      this.reg_handle.set_reset_value(update_value);
    endfunction

    function logic [31:0] get();
      automatic logic [31:0] value = 'h0;
      automatic logic [31:0] regvalue = this.reg_handle.get();

      for (int i=this.msb+1; i<32; i++) begin
        regvalue[i]=1'b0;
      end
      value = regvalue >> this.lsb;

      this.info($sformatf("Getting reg %s[%0d:%0d] field %s with %h", this.reg_handle.get_name(), this.msb, this.lsb, this.name, value), ADI_VERBOSITY_HIGH);

      return value;
    endfunction

    function void set(input logic [31:0] set_value);
      automatic logic [31:0] update_value = 'h0;
      automatic logic [31:0] mask = 'hFFFF;

      if (this.access == NA || this.access == R || this.access == RO || this.access == ROV)
        this.error($sformatf("Modifying a read only field!"));

      update_value = set_value << this.lsb;
      for (int i=this.msb+1;i<=31;i++) begin
        update_value[i]=1'b0;
      end

      mask = mask << this.lsb;
      for (int i=this.msb+1; i<32; i++) begin
        mask[i]=1'b0;
      end

      this.reg_handle.set(this.reg_handle.get() & ~mask);
      this.reg_handle.set(this.reg_handle.get() | update_value);

      this.info($sformatf("Setting reg %s[%0d:%0d] field %s with %h (%h)", this.reg_handle.get_name(), this.msb, this.lsb, this.name, set_value, this.reg_handle.get()), ADI_VERBOSITY_HIGH);
    endfunction

    function logic [31:0] get_reset_value();
      this.info($sformatf("Getting reg %s[%0d:%0d] field %s with reset value %h", this.reg_handle.get_name(), this.msb, this.lsb, this.name, this.reset_value), ADI_VERBOSITY_HIGH);

      return this.reset_value;
    endfunction

  endclass
  
endpackage
