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

package adi_axis_byte_pkg;

  import logger_pkg::*;
  import adi_object_pkg::*;


  class adi_axis_byte extends adi_object;

    bit EN_TKEEP;
    bit EN_TSTRB;
    bit EN_TUSER;
    int TUSER_WIDTH;

    rand logic [7:0] tdata = 8'd0;
    rand logic tkeep = 1'b1;
    rand logic tstrb = 1'b0;
    rand logic [32-1:0] tuser = {32{1'b0}};

    constraint c_tkeep { (this.EN_TKEEP == 0) -> (tkeep == 1'b1); }
    constraint c_tstrb { (this.EN_TSTRB == 0 || tkeep == 1'b0) -> (tstrb == tkeep); }
    constraint c_tstrb_order { solve tkeep before tstrb; }
    constraint c_tuser { (this.EN_TUSER == 0) -> (tuser == {32{1'b0}});
                         tuser < 2**this.TUSER_WIDTH; }

    function new(
      input string name = "",
      bit EN_TKEEP = 0,
      bit EN_TSTRB = 0,
      bit EN_TUSER = 0,
      int TUSER_WIDTH = 1);

      super.new(name);

      this.EN_TKEEP = EN_TKEEP;
      this.EN_TSTRB = EN_TSTRB;
      this.EN_TUSER = EN_TUSER;
      this.TUSER_WIDTH = TUSER_WIDTH;
    endfunction: new

    function void randomize_byte();
      if (!this.randomize()) begin
        `FATAL(("Randomization failed!"));
      end
    endfunction: randomize_byte

    function void update_tdata(input logic [7:0] tdata);
      this.tdata = tdata;
    endfunction: update_tdata

    function void update_tkeep(input logic tkeep);
      if (this.EN_TKEEP) begin
        this.tkeep = tkeep;
      end else begin
        if (tkeep != 1'b1) begin
          `WARNING(("Writing on a disabled TKEEP parameter is ignored!"));
          `ERROR(("Writing on a disabled TKEEP parameter is ignored!"));
        end
      end
    endfunction: update_tkeep

    function void update_tstrb(input logic tstrb);
      if (this.EN_TSTRB) begin
        this.tstrb = tstrb;
      end else begin
        if (tstrb != tkeep) begin
          `WARNING(("Writing on a disabled TSTRB parameter is ignored!"));
          `ERROR(("Writing on a disabled TSTRB parameter is ignored!"));
        end
      end
    endfunction: update_tstrb

    function void update_tuser(input logic [32-1:0] tuser);
      if (this.EN_TUSER) begin
        this.tuser = tuser;
      end else begin
        if (tuser != {32{1'b0}}) begin
          `WARNING(("Writing on a disabled TUSER parameter is ignored!"));
          `ERROR(("Writing on a disabled TUSER parameter is ignored!"));
        end
      end
    endfunction: update_tuser

    function void update_byte_info(
      input logic [7:0] tdata,
      input logic tkeep = 1'b1,
      input logic tstrb = 1'b0,
      input logic [32-1:0] tuser = {32{1'b0}});

      this.update_tdata(tdata);
      this.update_tkeep(tkeep);
      this.update_tstrb(tstrb);
      this.update_tuser(tuser);
    endfunction: update_byte_info

    function void update_byte_info_class(input adi_axis_byte byte_info);
      this.update_tdata(byte_info.tdata);
      this.update_tkeep(byte_info.tkeep);
      this.update_tstrb(byte_info.tstrb);
      this.update_tuser(byte_info.tuser);
    endfunction: update_byte_info_class

    virtual function string convert2string();
      string str;
      str = {"ADI AXIS Byte\n",
        $sformatf("name: %s\n", this.name)};
      return(str);
    endfunction: convert2string

    virtual function void do_copy(input adi_object object);
      adi_axis_byte cast_object;

      if ($cast(cast_object, object) == 0) begin
        `FATAL(("Input object %s type is not compatible with current object %s type!", object.sprint(), this.sprint()));
      end

      cast_object.update_byte_info(
        .tdata(this.tdata),
        .tkeep(this.tkeep),
        .tstrb(this.tstrb),
        .tuser(this.tuser));
    endfunction: do_copy

    virtual function bit do_compare(input adi_object object);
      adi_axis_byte cast_object;

      if ($cast(cast_object, object) == 0) begin
        `FATAL(("Cast object %s type is not compatible with current object %s type!", object.sprint(), this.sprint()));
      end

      if (this.tdata != cast_object.tdata ||
        (this.EN_TKEEP && (this.tkeep != cast_object.tkeep)) ||
        (this.EN_TSTRB && (this.tstrb != cast_object.tstrb)) ||
        (this.EN_TUSER && (this.tuser != cast_object.tuser))) begin

        return 0;
      end
      return 1;
    endfunction: do_compare

  endclass: adi_axis_byte

endpackage: adi_axis_byte_pkg
