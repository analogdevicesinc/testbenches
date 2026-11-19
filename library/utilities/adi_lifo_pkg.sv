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

package adi_lifo_pkg;

  import logger_pkg::*;
  import adi_object_pkg::*;

  class adi_lifo #(type data_type = int) extends adi_object;

    local data_type lifo [$];
    local int depth;

    function new(
      input string name = "",
      input int depth);

      super.new(name);

      this.depth = depth;
    endfunction: new

    function adi_object clone();
      adi_lifo #(data_type) object;

      object = new(
        .name(this.name),
        .depth(this.depth));

      this.copy(object);

      return object;
    endfunction: clone

    function void copy(input adi_object object);
      adi_lifo #(data_type) cast_object;
      adi_lifo #(data_type) temporary_lifo;
      data_type temporary_storage;
      int depth;

      $cast(cast_object, object);

      temporary_lifo = new(
        .name("Temp storage"),
        .depth(this.depth));

      depth = this.size();

      for (int i=0; i<depth; i++) begin
        void'(temporary_lifo.push(this.pop()));
      end

      for (int i=0; i<depth; i++) begin
        temporary_storage = temporary_lifo.pop();

        void'(this.push(temporary_storage));

        void'(cast_object.push(temporary_storage));
      end
    endfunction: copy

    function bit compare(
      input adi_object object,
      input bit logical_equality = 1'b0);

      adi_lifo #(data_type) cast_object;
      adi_lifo #(data_type) temporary_local_lifo;
      adi_lifo #(data_type) temporary_object_lifo;
      data_type local_storage;
      data_type object_storage;
      int depth;
      bit result = 1;

      $cast(cast_object, object);

      temporary_local_lifo = new(
        .name("Local LIFO"),
        .depth(this.depth));

      temporary_object_lifo = new(
        .name("Object LIFO"),
        .depth(this.depth));

      depth = this.size();

      if (depth != cast_object.size()) begin
        return 0;
      end

      for (int i=0; i<depth; i++) begin
        local_storage = this.pop();
        void'(temporary_local_lifo.push(local_storage));

        object_storage = cast_object.pop();
        void'(temporary_object_lifo.push(object_storage));
      end

      for (int i=0; i<depth; i++) begin
        local_storage = temporary_local_lifo.pop();
        void'(this.push(local_storage));

        object_storage = temporary_object_lifo.pop();
        void'(cast_object.push(object_storage));

        if (logical_equality == 1'b1) begin
          if (local_storage != object_storage) begin
            result = 0;
          end
        end else begin
          if (local_storage !== object_storage) begin
            result = 0;
          end
        end
      end
      return result;
    endfunction: compare

    function bit push(input data_type data);
      if (this.lifo.size() == this.depth && this.depth != 0) begin
        return 1'b0;
      end else begin
        this.lifo.push_front(data);
        return 1'b1;
      end
    endfunction: push

    function data_type pop();
      return this.lifo.pop_front();
    endfunction: pop

    function int room();
      return depth-this.lifo.size();
    endfunction: room

    function int size();
      return this.lifo.size();
    endfunction: size

    function void clear();
      this.lifo.delete();
    endfunction: clear

    function bit insert(
      input int index,
      input data_type data);

      if (this.lifo.size() == this.depth && this.depth != 0) begin
        return 1'b0;
      end else begin
        this.lifo.insert(index, data);
        return 1'b1;
      end
    endfunction: insert

  endclass: adi_lifo

endpackage: adi_lifo_pkg
