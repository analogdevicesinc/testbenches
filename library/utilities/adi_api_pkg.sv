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
  typedef class adi_regmap;
  typedef class adi_register;
  typedef class adi_field;

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

    task axi_read(input adi_register register);
      automatic logic [31:0] data;

      this.bus.RegRead32(register.get_address(), data);
      register.set_value(data);
    endtask: axi_read

    task axi_read_return(
      input  adi_register        register,
      output logic         [31:0] data);

      this.bus.RegRead32(register.get_address(), data);
      register.set_value(data);
    endtask: axi_read_return

    task axi_read_direct(
      input  bit   [31:0] addr,
      output logic [31:0] data);

      this.bus.RegRead32(this.address + addr, data);
    endtask: axi_read_direct

    task axi_write(input adi_register register);
      this.bus.RegWrite32(register.get_address(), register.get_value());
    endtask: axi_write

    task axi_write_direct(
      input bit [31:0] addr,
      input bit [31:0] data);

      this.bus.RegWrite32(this.address + addr, data);
    endtask: axi_write_direct

    task axi_verify(input adi_register register);
      this.bus.RegReadVerify32(register.get_address(), register.get_value());
    endtask: axi_verify

    task axi_verify_direct(
      input bit [31:0] addr,
      input bit [31:0] data);

      this.bus.RegReadVerify32(this.address + addr, data);
    endtask: axi_verify_direct

  endclass: adi_api


  class adi_regmap extends adi_component;

    local int address;

    protected adi_register registers [];

    function new(
      input string name,
      input int address,
      input adi_component parent = null);

      super.new(name, parent);

      this.address = address;
      this.registers = new [0];
    endfunction: new

    function adi_register add_register(
      input string name,
      input int address);

      this.registers = new [this.registers.size() + 1] (this.registers);
      this.registers[this.registers.size() - 1] = new(name, address, this);

      return this.registers[this.registers.size() - 1];
    endfunction: add_register

    function adi_register get_register(input string name);
      for (int i=0; i<this.registers.size(); i++) begin
        if (this.registers[i].name == name) begin
          return this.registers[i];
        end
      end

      return null;
    endfunction: get_register

    function int get_address();
      adi_regmap cast_object;

      if (this.parent == null) begin
        return this.address;
      end else if ($cast(cast_object, this.parent) == 0) begin
        return this.address;
      end else begin
        return this.address + cast_object.get_address();
      end
    endfunction: get_address

    function void init_done();
      for (int i=0; i<this.registers.size(); i++) begin
        this.registers[i].init_done();
      end
    endfunction: init_done

  endclass: adi_regmap


  class adi_register extends adi_component;

    local logic [31:0] value;
    local logic [31:0] reset_value;
    local int address;
    local bit initialization_done;

    protected adi_field fields [];

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
      this.fields = new [0];
    endfunction: new

    function void add_field(
      input string name,
      input int msb,
      input int lsb,
      input acc_t access,
      input int reset_value);

      this.fields = new [this.fields.size() + 1] (this.fields);
      this.fields[this.fields.size() - 1] = new(name, msb, lsb, access, reset_value, this);
    endfunction: add_field

    function adi_field get_field(input string name);
      for (int i=0; i<this.fields.size(); i++) begin
        if (this.fields[i].name == name) begin
          return this.fields[i];
        end
      end

      return null;
    endfunction: get_field

    function logic [31:0] get_value();
      this.info($sformatf("Getting reg value %h", this.value), ADI_VERBOSITY_HIGH);

      return value;
    endfunction: get_value

    function void set_value(input logic [31:0] value);
      this.info($sformatf("Setting reg value %h (%h)", value, this.value), ADI_VERBOSITY_HIGH);

      this.value = value;
    endfunction: set_value

    function logic [31:0] get_reset_value();
      this.info($sformatf("Getting reg reset value %h", this.reset_value), ADI_VERBOSITY_HIGH);

      return reset_value;
    endfunction: get_reset_value

    function void set_reset_value(input logic [31:0] reset_value);
      if (initialization_done) begin
        this.fatal($sformatf("Changing the reset value after the registermap is created is not allowed!"));
      end

      this.reset_value = this.reset_value | reset_value;

      this.info($sformatf("Setting reg reset value %h (%h)", reset_value, this.reset_value), ADI_VERBOSITY_HIGH);
    endfunction: set_reset_value

    function int get_address();
      adi_regmap cast_object;

      if ($cast(cast_object, this.parent) == 0) begin
        this.fatal($sformatf("Input object %s type is not compatible with current object type!", this.parent.name));
      end

      return this.address + cast_object.get_address();
    endfunction: get_address

    function void init_done();
      this.initialization_done = 1;
    endfunction: init_done

  endclass: adi_register


  class adi_field extends adi_component;

    local int msb;
    local int lsb;
    local acc_t access;
    local logic [31:0] reset_value;

    local adi_register reg_handle;

    function new(
      input string name,
      input int msb,
      input int lsb,
      input acc_t access,
      input int reset_value,
      input adi_register parent);

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

    function logic [31:0] get_value();
      automatic logic [31:0] value = 'h0;
      automatic logic [31:0] regvalue = this.reg_handle.get_value();

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

      this.info($sformatf("Getting field [%0d:%0d] value %h (%h)", this.msb, this.lsb, value, this.reg_handle.get_value()), ADI_VERBOSITY_HIGH);

      return value;
    endfunction: get_value

    function void set_value(input logic [31:0] set_value);
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

      this.reg_handle.set_value(this.reg_handle.get_value() & ~mask);
      this.reg_handle.set_value(this.reg_handle.get_value() | update_value);

      this.info($sformatf("Setting field [%0d:%0d] value %h (%h)", this.msb, this.lsb, set_value, this.reg_handle.get_value()), ADI_VERBOSITY_HIGH);
    endfunction: set_value

    function logic [31:0] get_reset_value();
      this.info($sformatf("Getting field[%0d:%0d] reset value %h (%h)", this.msb, this.lsb, this.reset_value, this.reg_handle.get_reset_value()), ADI_VERBOSITY_HIGH);

      return this.reset_value;
    endfunction: get_reset_value

  endclass: adi_field

endpackage: adi_api_pkg
