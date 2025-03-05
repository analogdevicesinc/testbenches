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

  class adi_fifo #(type data_type = int) extends adi_component;

    local data_type adi_fifo [$];
    local int depth;

    function new(
      input string name,
      input int depth,
      input adi_component parent = null);

      super.new(name, parent);

      this.depth = depth;
    endfunction: new

    function bit push(input data_type data);
      if (this.adi_fifo.size() == this.depth && this.depth != 0) begin
        return 1'b0;
      end else begin
        this.adi_fifo.push_back(data);
        return 1'b1;
      end
    endfunction: push

    function data_type pop();
      if (this.adi_fifo.size() == 0) begin
        return null;
      end else begin
        return this.adi_fifo.pop_front();
      end
    endfunction: pop

    function int room();
      return depth-this.adi_fifo.size();
    endfunction: room

    function int size();
      return this.adi_fifo.size();
    endfunction: room

    function void clear();
      this.adi_fifo.delete();
    endfunction: clear

    function bit insert(
      input int index,
      input data_type data);

      if (this.adi_fifo.size() == this.depth && this.depth != 0) begin
        return 1'b0;
      end else begin
        this.adi_fifo.insert(index, data);
        return 1'b1;
      end
    endfunction: clear

  endclass: adi_fifo


  class adi_lifo #(type data_type = int) extends adi_component;

    local data_type adi_fifo [$];
    local int depth;

    function new(
      input string name,
      input int depth,
      input adi_component parent = null);

      super.new(name, parent);

      this.depth = depth;
    endfunction: new

    function bit push(input data_type data);
      if (this.adi_fifo.size() == this.depth && this.depth != 0) begin
        return 1'b0;
      end else begin
        this.adi_fifo.push_front(data);
        return 1'b1;
      end
    endfunction: push

    function data_type pop();
      if (this.adi_fifo.size() == 0) begin
        return null;
      end else begin
        return this.adi_fifo.pop_front();
      end
    endfunction: pop

    function int room();
      return depth-this.adi_fifo.size();
    endfunction: room

    function int size();
      return this.adi_fifo.size();
    endfunction: room

    function void clear();
      this.adi_fifo.delete();
    endfunction: clear

    function bit insert(
      input int index,
      input data_type data);

      if (this.adi_fifo.size() == this.depth && this.depth != 0) begin
        return 1'b0;
      end else begin
        this.adi_fifo.insert(index, data);
        return 1'b1;
      end
    endfunction: clear

  endclass: adi_lifo

endpackage: adi_datatypes_pkg
