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

package adi_fifo_pkg;

  import logger_pkg::*;
  import adi_object_pkg::*;

  class adi_fifo #(type data_type = int) extends adi_object;

    data_type fifo [$];
    protected int depth;

    function new(
      input string name = "",
      input int depth = 0);

      super.new(.name(name));

      this.depth = depth;
    endfunction: new

    function int size();
      return this.fifo.size();
    endfunction: size

    function void delete();
      this.fifo.delete();
    endfunction: delete

    function int room();
      if (this.depth == 0) begin
        return `INT_MAX-this.size();
      end else begin
        return this.depth-this.size();
      end
    endfunction: room

    function bit insert(
      input int index,
      input data_type data);

      if (this.room()) begin
        return 0;
      end else begin
        this.fifo.insert(index, data);
        return 1;
      end
    endfunction: insert

    function bit push(input data_type data);
      if (!this.room()) begin
        return 0;
      end else begin
        this.fifo.push_back(data);
        return 1;
      end
    endfunction: push

    function data_type pop();
      return this.fifo.pop_front();
    endfunction: pop

    virtual function string convert2string();
      string str;
      str = {$sformatf("ADI FIFO\n"),
        $sformatf("  name: %s\n", this.name),
        $sformatf("  depth: %d\n", this.depth)};
      return(str);
    endfunction: convert2string

    function void copy(input adi_object object);
      adi_fifo #(data_type) cast_object;

      if ($cast(cast_object, object) == 0) begin
        `FATAL(("Input object %s type is not compatible with current object %s type!", object.sprint(), this.sprint()));
      end

      if (this.size() == 0) begin
        return;
      end

      this.do_copy(.object(cast_object));
    endfunction: copy

    virtual function void do_copy(input adi_object object);
      adi_fifo #(data_type) cast_object;
      data_type temporary_storage;

      if ($cast(cast_object, object) == 0) begin
        `FATAL(("Input object %s type is not compatible with current object %s type!", object.sprint(), this.sprint()));
      end

      for (int i=0; i<this.size(); i++) begin
        temporary_storage = this.pop();
        void'(this.push(.data(temporary_storage)));

        void'(cast_object.push(.data(temporary_storage)));
      end
    endfunction: do_copy

    function bit compare(input adi_object object);
      adi_fifo #(data_type) cast_object;

      if ($cast(cast_object, object) == 0) begin
        `FATAL(("Cast object %s type is not compatible with current object %s type!", object.sprint(), this.sprint()));
      end

      if (this.room() != cast_object.room()) begin
        `ERROR(("Room size missmatch: %d - %d", this.room(), cast_object.room()));
        return 0;
      end

      if (this.size() != cast_object.size()) begin
        `ERROR(("Size missmatch: %d - %d", this.size(), cast_object.size()));
        return 0;
      end

      return do_compare(.object(cast_object));
    endfunction: compare

  endclass: adi_fifo

endpackage: adi_fifo_pkg
