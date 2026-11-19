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

package adi_fifo_primitive_pkg;

  import logger_pkg::*;
  import adi_object_pkg::*;
  import adi_fifo_pkg::*;

  class adi_fifo_primitive #(type data_type = int) extends adi_fifo#(.data_type(data_type));

    function new(
      input string name = "",
      input int depth = 0);

      super.new(.name(name));

      this.depth = depth;
    endfunction: new

    virtual function adi_object clone();
      adi_fifo_primitive #(data_type) object;

      object = new(
        .name(this.name),
        .depth(this.depth));

      this.copy(.object(object));

      return object;
    endfunction: clone

    virtual function bit do_compare(input adi_object object);
      adi_fifo_primitive #(data_type) cast_object;
      data_type local_storage;
      data_type object_storage;

      if ($cast(cast_object, object) == 0) begin
        `FATAL(("Cast object %s type is not compatible with current object %s type!", object.sprint(), this.sprint()));
      end

      for (int i=0; i<this.size(); i++) begin
        local_storage = this.pop();
        void'(this.push(.data(local_storage)));

        object_storage = cast_object.pop();
        void'(cast_object.push(.data(object_storage)));

        if (local_storage !== object_storage) begin
          `ERROR(("Data missmatch: %d - %d", local_storage, object_storage));
          return 0;
        end
      end
      return 1;
    endfunction: do_compare

  endclass: adi_fifo_primitive

endpackage: adi_fifo_primitive_pkg
