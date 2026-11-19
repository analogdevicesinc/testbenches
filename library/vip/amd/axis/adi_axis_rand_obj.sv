// ***************************************************************************
// ***************************************************************************
// Copyright (C) 2024-2025 Analog Devices, Inc. All rights reserved.
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

package adi_axis_rand_obj_pkg;

  import logger_pkg::*;
  import adi_object_pkg::*;


  class adi_axis_rand_obj extends adi_object;

    // standard signaling
    logic [7:0] tdata = 8'd0;
    logic tkeep = 1'b1;
    logic tstrb = 1'b1;
    logic [32-1:0] tuser_byte = {32{1'b0}};
    logic [32-1:0] tid = {32{1'b0}};
    logic [32-1:0] tdest = {32{1'b0}};
    logic [32-1:0] tuser_tx = {32{1'b0}};

    // transfer specific signaling
    logic [512-1:0] tkeep_count = 'd0;

    function new(input string name = "");
      super.new(name);
    endfunction: new

    function void update_rand_obj_class(input adi_axis_rand_obj rand_obj_info);
      this.tdata = rand_obj_info.tdata;
      this.tkeep = rand_obj_info.tkeep;
      this.tstrb = rand_obj_info.tstrb;
      this.tuser_byte = rand_obj_info.tuser_byte;
      this.tid = rand_obj_info.tid;
      this.tdest = rand_obj_info.tdest;
      this.tuser_tx = rand_obj_info.tuser_tx;
      this.tkeep_count = rand_obj_info.tkeep_count;
    endfunction: update_rand_obj_class

    virtual function adi_object clone();
      adi_axis_rand_obj object;
      object = new(.name(this.name));
      this.copy(object);
      return object;
    endfunction: clone

    virtual function string convert2string();
      string str;
      str = {"ADI AXIS Configuration\n",
        $sformatf("name: %s\n", this.name)};
      return(str);
    endfunction: convert2string

    virtual function void do_copy(input adi_object object);
      adi_axis_rand_obj cast_object;

      if ($cast(cast_object, object) == 0) begin
        `FATAL(("Input object %s type is not compatible with current object %s type!", object.sprint(), this.sprint()));
      end

      cast_object.update_rand_obj_class(.rand_obj_info(this));
    endfunction: do_copy

    virtual function bit do_compare(input adi_object object);
      adi_axis_rand_obj cast_object;

      if ($cast(cast_object, object) == 0) begin
        `FATAL(("Cast object %s type is not compatible with current object %s type!", object.sprint(), this.sprint()));
      end

      if (this.tdata != cast_object.tdata ||
        (this.tkeep != cast_object.tkeep) ||
        (this.tstrb != cast_object.tstrb) ||
        (this.tuser_byte != cast_object.tuser_byte) ||
        (this.tid != cast_object.tid) ||
        (this.tdest != cast_object.tdest) ||
        (this.tuser_tx != cast_object.tuser_tx) ||
        (this.tkeep_count != cast_object.tkeep_count)) begin

        return 0;
      end
      return 1;
    endfunction: do_compare

  endclass: adi_axis_rand_obj

endpackage: adi_axis_rand_obj_pkg
