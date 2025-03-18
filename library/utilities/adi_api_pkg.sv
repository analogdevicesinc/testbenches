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

`include "utils.svh"

package adi_api_pkg;

  import logger_pkg::*;
  import adi_common_pkg::*;
  import m_axi_sequencer_pkg::*;

  typedef enum {NA, R, RO, ROV, RW, RW1C, RW1CV, RW1S, W1S, WO} acc_t;

  // forward declaration to avoid errors
  typedef class register_base;

  class adi_api extends adi_component;

    local m_axi_sequencer_base bus;
    protected bit [31:0] address;

    function new(
      input string name,
      input m_axi_sequencer_base bus,
      input bit [31:0] address,
      input adi_component parent = null);

      super.new(name, parent);

      this.bus = bus;
      this.address = address;
    endfunction: new


    task axi_read(input register_base register);
      automatic logic [31:0] data;

      this.bus.RegRead32(register.parent.get_address() + register.get_address(), data);
      register.set(data);
    endtask: axi_read

    task axi_read_return(
      input  register_base        register,
      output logic         [31:0] data);

      this.bus.RegRead32(register.parent.get_address() + register.get_address(), data);
      register.set(data);
    endtask: axi_read_return

    task axi_read_direct(
      input  bit   [31:0] addr,
      output logic [31:0] data);

      this.bus.RegRead32(this.address + addr, data);
    endtask: axi_read_direct

    task axi_write(input register_base register);
      this.bus.RegWrite32(register.parent.get_address() + register.get_address(), register.get());
    endtask: axi_write

    task axi_write_direct(
      input bit [31:0] addr,
      input bit [31:0] data);

      this.bus.RegWrite32(this.address + addr, data);
    endtask: axi_write_direct

    task axi_verify(input register_base register);
      this.bus.RegReadVerify32(register.parent.get_address() + register.get_address(), register.get());
    endtask: axi_verify

    task axi_verify_direct(
      input bit [31:0] addr,
      input bit [31:0] data);

      this.bus.RegReadVerify32(this.address + addr, data);
    endtask: axi_verify_direct

  endclass: adi_api


  class adi_regmap extends adi_component;

    local int address;

    function new(
      input string name,
      input int address,
      input adi_api parent = null);

      super.new(name, parent);

      this.address = address;
    endfunction: new

    function int get_address();
      return this.address;
    endfunction: get_address

  endclass: adi_regmap


  class register_base extends adi_component;

    local logic [31:0] value;
    local logic [31:0] reset_value;
    local int address;
    local bit initialization_done;

    function new(
      input string name,
      input int address,
      input adi_regmap parent);

      super.new(name, parent);

      this.name = name;
      this.value = 'h0;
      this.reset_value = 'h0;
      this.address = address;
      this.initialization_done = 0;
    endfunction: new

    function logic [31:0] get();
      this.info($sformatf("Getting reg %s with value %h", this.name, this.value), ADI_VERBOSITY_HIGH);

      return value;
    endfunction: get

    function void set(input logic [31:0] value);
      this.info($sformatf("Setting reg %s with value %h (%h)", this.name, value, this.value), ADI_VERBOSITY_HIGH);

      this.value = value;
    endfunction: set

    function logic [31:0] get_reset_value();
      this.info($sformatf("Getting reg %s with reset value %h", this.name, this.reset_value), ADI_VERBOSITY_HIGH);

      return reset_value;
    endfunction: get_reset_value

    function void set_reset_value(input logic [31:0] reset_value);
      if (initialization_done) begin
        this.fatal($sformatf("Changing the reset value after the registermap is created is not allowed!"));
      end

      this.info($sformatf("Setting reg %s with reset value %h (%h)", this.name, reset_value, this.reset_value), ADI_VERBOSITY_HIGH);

      this.reset_value = this.reset_value | reset_value;
    endfunction: set_reset_value

    function int get_address();
      return this.address;
    endfunction: get_address

    function string get_name();
      return this.name;
    endfunction: get_name

  endclass: register_base


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
      input register_base parent);

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
    endfunction: new

    function logic [31:0] get();
      automatic logic [31:0] value = 'h0;
      automatic logic [31:0] regvalue = this.reg_handle.get();

      case (this.access)
        NA: begin
          this.fatal($sformatf("Trying to read a field with unknown access type!"));
        end
        WO: begin
          this.error($sformatf("Trying to read a field with write only access type!"));
        end
        default:;
      endcase

      for (int i=this.msb+1; i<32; i++) begin
        regvalue[i]=1'b0;
      end
      value = regvalue >> this.lsb;

      this.info($sformatf("Getting reg %s[%0d:%0d] field %s with %h", this.reg_handle.get_name(), this.msb, this.lsb, this.name, value), ADI_VERBOSITY_HIGH);

      return value;
    endfunction: get

    function void set(input logic [31:0] set_value);
      automatic logic [31:0] update_value = 'h0;
      automatic logic [31:0] mask = 'hFFFF;

      case (this.access)
        NA: begin
          this.fatal($sformatf("Trying to write a field with unknown access type!"));
        end
        R, RO, ROV: begin
          this.warning($sformatf("Trying to write a field with read only access type!"));
        end
        default:;
      endcase

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
    endfunction: set

    function logic [31:0] get_reset_value();
      this.info($sformatf("Getting reg %s[%0d:%0d] field %s with reset value %h", this.reg_handle.get_name(), this.msb, this.lsb, this.name, this.reset_value), ADI_VERBOSITY_HIGH);

      return this.reset_value;
    endfunction: get_reset_value

  endclass: field_base

endpackage: adi_api_pkg
