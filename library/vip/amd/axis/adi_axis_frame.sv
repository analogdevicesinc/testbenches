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

package adi_axis_frame_pkg;

  import logger_pkg::*;
  import adi_object_pkg::*;
  import adi_axis_packet_pkg::*;


  class adi_axis_frame extends adi_object;

    int BYTES_PER_TRANSACTION;
    bit EN_TKEEP;
    bit EN_TSTRB;
    bit EN_TLAST;
    bit EN_TUSER;
    bit EN_TID;
    bit EN_TDEST;
    bit TUSER_BYTE_BASED;
    int TID_WIDTH;
    int TDEST_WIDTH;
    int TUSER_WIDTH;

    adi_axis_packet packets[];
    int frame_size_limit;
    int packet_size_limit;

    function new(
      input string name = "",
      input int frame_size_limit = 0,
      input int packet_size_limit = 0,
      input int BYTES_PER_TRANSACTION,
      input bit EN_TKEEP = 0,
      input bit EN_TSTRB = 0,
      input bit EN_TLAST = 0,
      input bit EN_TUSER = 0,
      input bit EN_TID = 0,
      input bit EN_TDEST = 0,
      input bit TUSER_BYTE_BASED = 0,
      input int TID_WIDTH = 0,
      input int TDEST_WIDTH = 0,
      input int TUSER_WIDTH = 0);

      super.new(name);

      this.BYTES_PER_TRANSACTION = BYTES_PER_TRANSACTION;
      this.EN_TKEEP = EN_TKEEP;
      this.EN_TSTRB = EN_TSTRB;
      this.EN_TLAST = EN_TLAST;
      this.EN_TUSER = EN_TUSER;
      this.EN_TID = EN_TID;
      this.EN_TDEST = EN_TDEST;
      this.TUSER_BYTE_BASED = TUSER_BYTE_BASED;
      this.TID_WIDTH = TID_WIDTH;
      this.TDEST_WIDTH = TDEST_WIDTH;
      this.TUSER_WIDTH = TUSER_WIDTH;

      this.frame_size_limit = frame_size_limit;
      this.packet_size_limit = packet_size_limit;

      if (this.frame_size_limit != 0) begin
        this.create_frame(this.frame_size_limit);
      end
    endfunction: new

    function void randomize_frame();
      if (this.packets.size() == 0) begin
        `FATAL(("The frame is empty, nothing to randomize!"));
      end

      for (int i=0; i<this.packets.size(); i++) begin
        this.packets[i].randomize_packet();
      end
    endfunction: randomize_frame

    function void randomize_all();
      if (frame_size_limit == 0) begin
        this.create_frame($urandom());
      end else begin
        this.create_frame($urandom_range(1, this.frame_size_limit));
      end

      for (int i=0; i<this.packets.size(); i++) begin
        this.packets[i].randomize_all();
      end
    endfunction: randomize_all

    function void create_frame(input int frame_size);
      this.packets = new[frame_size];

      if (this.packet_size_limit != 0) begin
        for (int i=0; i<this.packets.size(); i++) begin
          this.packets[i] = new(
            .packet_size_limit(this.packet_size_limit),
            .BYTES_PER_TRANSACTION(this.BYTES_PER_TRANSACTION),
            .EN_TKEEP(this.EN_TKEEP),
            .EN_TSTRB(this.EN_TSTRB),
            .EN_TLAST(this.EN_TLAST),
            .EN_TUSER(this.EN_TUSER),
            .EN_TID(this.EN_TID),
            .EN_TDEST(this.EN_TDEST),
            .TUSER_BYTE_BASED(this.TUSER_BYTE_BASED),
            .TID_WIDTH(this.TID_WIDTH),
            .TDEST_WIDTH(this.TDEST_WIDTH),
            .TUSER_WIDTH(this.TUSER_WIDTH));
        end
      end
    endfunction: create_frame

    function void update_packet_class(
      input int location,
      input adi_axis_packet packet_info);

      packet_info.copy(this.packets[location]);
    endfunction: update_packet_class

    function void add_packet_class(input adi_axis_packet packet_info);
      this.packets = new [this.packets.size() + 1] (this.packets);
      this.packets[this.packets.size()-1] = new(
        .packet_size_limit(packet_info.packet_size_limit),
        .BYTES_PER_TRANSACTION(this.BYTES_PER_TRANSACTION),
        .EN_TKEEP(this.EN_TKEEP),
        .EN_TSTRB(this.EN_TSTRB),
        .EN_TLAST(this.EN_TLAST),
        .EN_TUSER(this.EN_TUSER),
        .EN_TID(this.EN_TID),
        .EN_TDEST(this.EN_TDEST),
        .TUSER_BYTE_BASED(this.TUSER_BYTE_BASED),
        .TID_WIDTH(this.TID_WIDTH),
        .TDEST_WIDTH(this.TDEST_WIDTH),
        .TUSER_WIDTH(this.TUSER_WIDTH));

      this.update_packet_class(
        .location(this.packets.size()-1),
        .packet_info(packet_info));
    endfunction: add_packet_class

    virtual function string convert2string();
      string str;
      str = {"ADI AXIS frame\n",
        $sformatf("name: %s\n", this.name)};
      return(str);
    endfunction: convert2string

    virtual function void do_copy(input adi_object object);
      adi_axis_frame cast_object;

      if ($cast(cast_object, object) == 0) begin
        `FATAL(("Input object %s type is not compatible with current object %s type!", object.sprint(), this.sprint()));
      end

      cast_object.packets = new[this.packets.size()];

      for (int i=0; i<this.packets.size(); i++) begin
        cast_object.packets[i] = new(
          .BYTES_PER_TRANSACTION(this.BYTES_PER_TRANSACTION),
          .EN_TKEEP(this.EN_TKEEP),
          .EN_TSTRB(this.EN_TSTRB),
          .EN_TLAST(this.EN_TLAST),
          .EN_TUSER(this.EN_TUSER),
          .EN_TID(this.EN_TID),
          .EN_TDEST(this.EN_TDEST),
          .TUSER_BYTE_BASED(this.TUSER_BYTE_BASED),
          .TID_WIDTH(this.TID_WIDTH),
          .TDEST_WIDTH(this.TDEST_WIDTH),
          .TUSER_WIDTH(this.TUSER_WIDTH));
        this.packets[i].copy(cast_object.packets[i]);
      end
    endfunction: do_copy

    virtual function bit do_compare(input adi_object object);
      adi_axis_frame cast_object;

      if ($cast(cast_object, object) == 0) begin
        `FATAL(("Cast object %s type is not compatible with current object %s type!", object.sprint(), this.sprint()));
      end

      for (int i=0; i<this.packets.size(); i++) begin
        if (this.packets[i].compare(cast_object.packets[i]) == 0) begin
          return 0;
        end
      end
      return 1;
    endfunction: do_compare

  endclass: adi_axis_frame

endpackage: adi_axis_frame_pkg
