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

package adi_datatypes_pkg;

  import logger_pkg::*;
  import adi_common_pkg::*;

  virtual class adi_datatype;

    function new();
    endfunction

    pure virtual function adi_datatype clone (adi_datatype in);

    pure virtual function adi_datatype copy (adi_datatype in);

    pure virtual function bit compare (adi_datatype in);

    pure virtual function string to_string();

  endclass: adi_datatype

  class adi_fifo #(type data_type = int) extends adi_datatype;

    local data_type fifo [$];
    local int depth;

    function new(
      input int depth);

      super.new();

      this.depth = depth;
    endfunction: new

    function adi_fifo #(data_type) clone (input adi_datatype in);
      adi_fifo #(data_type) src;
      adi_fifo #(data_type) res;
      if (! $cast(src,in)) begin
        $error("cast to adi_fifo failed!");
        return res;
      end
      res = new(src.depth);
      res.copy(src);
      return res;
    endfunction: clone

    function adi_datatype copy (input adi_datatype in);
      adi_fifo #(data_type) src;
      if (! $cast(src,in)) begin
        $error("cast to adi_fifo failed!");
      end
      this.clean();
      this.depth = src.depth;
      this.fifo = src.fifo; // sv queues already deep copy with this
    endfunction: copy

    function bit push(input data_type data);
      if (this.fifo.size() == this.depth && this.depth != 0) begin
        return 1'b0;
      end else begin
        this.fifo.push_back(data);
        return 1'b1;
      end
    endfunction: push

    function data_type pop();
      if (this.fifo.size() == 0) begin
        return null;
      end else begin
        return this.fifo.pop_front();
      end
    endfunction: pop

    function int room();
      return depth-this.fifo.size();
    endfunction: room

    function int size();
      return this.fifo.size();
    endfunction: size

    function void clean();
      this.fifo.delete();
    endfunction: clean

    function bit insert(
      input int index,
      input data_type data);

      if (this.fifo.size() == this.depth && this.depth != 0) begin
        return 1'b0;
      end else begin
        this.fifo.insert(index, data);
        return 1'b1;
      end
    endfunction: insert

    function bit compare(
      input adi_datatype in);
      adi_fifo #(data_type) src;
      if (! $cast(src,in)) begin
        $error("cast to adi_fifo failed!");
      end
      return (src.fifo == this.fifo); // sv queues compare "deeply" already
      // TODO: do we care about depth?
    endfunction: compare

    function string to_string();
      string str;
      str = {
        $sformatf("adi_fifo of %s, ", $typename(data_type)),
        $sformatf("depth: %d,", this.depth),
        $sformatf("%d elements, ", this.fifo.size()),
        $sformatf("%p", this.fifo)};
      return str;
    endfunction: to_string
  endclass: adi_fifo


  class adi_lifo #(type data_type = int) extends adi_datatype;

    local data_type lifo [$];
    local int depth;

    function new(
      input int depth);

      super.new();

      this.depth = depth;
    endfunction: new

    function adi_lifo #(data_type) clone (input adi_datatype in);
      adi_lifo #(data_type) src;
      adi_lifo #(data_type) res;
      if (! $cast(src,in)) begin
        $error("cast to adi_lifo failed!");
      end
      res = new(src.depth);
      res.copy(src);
      return res;
    endfunction: clone

    function adi_datatype copy (input adi_datatype in);
      adi_lifo #(data_type) src;
      if (! $cast(src,in)) begin
        $error("cast to adi_lifo failed!");
      end
      this.clean();
      this.depth = src.depth;
      this.lifo = src.lifo; // sv queues already deep copy with this
    endfunction: copy

    function bit push(input data_type data);
      if (this.lifo.size() == this.depth && this.depth != 0) begin
        return 1'b0;
      end else begin
        this.lifo.push_front(data);
        return 1'b1;
      end
    endfunction: push

    function data_type pop();
      if (this.lifo.size() == 0) begin
        return null;
      end else begin
        return this.lifo.pop_front();
      end
    endfunction: pop

    function int room();
      return depth-this.lifo.size();
    endfunction: room

    function int size();
      return this.lifo.size();
    endfunction: size

    function void clean();
      this.lifo.delete();
    endfunction: clean

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

    function bit compare(
      input adi_lifo #(data_type) in);
      adi_lifo #(data_type) src;
      if (! $cast(src,in)) begin
        $error("cast to adi_lifo failed!");
      end
      return (src.lifo == this.lifo); // sv queues compare "deeply" already
      // TODO: do we care about depth?

    endfunction: compare

    function string to_string();
      string str;
      str = {
        $sformatf("adi_lifo of %s, ", $typename(this.data_type)),
        $sformatf("depth: %d,", this.depth),
        $sformatf("%d elements, ", this.lifo.size()),
        $sformatf("%p", this.lifo)};
      return str;
    endfunction: to_string

  endclass: adi_lifo

endpackage: adi_datatypes_pkg
