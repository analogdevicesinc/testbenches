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
  import adi_axis_config_pkg::*;
  import adi_axis_rand_config_pkg::*;
  import adi_axis_rand_obj_pkg::*;


  class adi_axis_frame extends adi_object;

    adi_axis_config cfg;
    adi_axis_rand_config rand_cfg;
    adi_axis_rand_obj rand_obj;

    adi_axis_packet packets[];
    int packets_per_frame;
    int transactions_per_packet;
    int bytes_per_packet;

    function new(
      input string name = "",
      input int packets_per_frame = 0,
      input int transactions_per_packet = 0,
      input int bytes_per_packet = 0,
      input adi_axis_config cfg,
      input adi_axis_rand_config rand_cfg = null,
      input adi_axis_rand_obj rand_obj = null);

      super.new(name);

      this.cfg = cfg;
      if (rand_cfg == null) begin
        this.rand_cfg = new();
      end else begin
        this.rand_cfg = rand_cfg;
      end
      if (rand_obj == null) begin
        this.rand_obj = new();
      end else begin
        this.rand_obj = rand_obj;
      end

      this.packets_per_frame = packets_per_frame;
      this.transactions_per_packet = transactions_per_packet;
      this.bytes_per_packet = bytes_per_packet;

      if (this.bytes_per_packet) begin
        this.rand_cfg.TKEEP_MODE = 1;
      end

      if (this.packets_per_frame != 0) begin
        this.create_frame();
      end
    endfunction: new

    function void randomize_frame();
      if (this.packets.size() == 0) begin
        `FATAL(("The frame is empty, nothing to randomize!"));
      end

      if (!this.randomize()) begin
        `FATAL(("Randomization failed!"));
      end

      for (int i=0; i<this.packets.size(); i++) begin
        this.packets[i].randomize_packet();
      end
    endfunction: randomize_frame

    function void post_randomize();
      if (this.rand_cfg.TID_MODE == 3) begin
        this.rand_obj.tid = this.rand_obj.tid + 1;
      end
      if (this.rand_cfg.TDEST_MODE == 3) begin
        this.rand_obj.tdest = this.rand_obj.tdest + 1;
      end
    endfunction: post_randomize

    function void create_frame(
      input int packets_per_frame = 0,
      input int transactions_per_packet = 0,
      input int bytes_per_packet = 0);

      if (packets_per_frame > 0) begin
        this.packets_per_frame = packets_per_frame;
      end

      if (this.packets_per_frame == 0) begin
        `FATAL(("Creating a frame without packet count set is not allowed!"));
      end else begin
        this.packets = new[this.packets_per_frame];
      end

      if (!this.randomize()) begin
        `FATAL(("Randomization failed!"));
      end

      if (transactions_per_packet > 0 || bytes_per_packet > 0) begin
        this.bytes_per_packet = bytes_per_packet;
        this.transactions_per_packet = transactions_per_packet;
      end

      if (this.transactions_per_packet > 0 || this.bytes_per_packet > 0) begin
        for (int i=0; i<this.packets.size(); i++) begin
          this.packets[i] = new(
            .transactions_per_packet(this.transactions_per_packet),
            .bytes_per_packet(this.bytes_per_packet),
            .cfg(this.cfg),
            .rand_cfg(this.rand_cfg),
            .rand_obj(this.rand_obj));
        end
      end
    endfunction: create_frame

    function void update_rand_cfg_obj(input adi_axis_rand_config rand_cfg);
      this.rand_cfg = rand_cfg;

      for (int i=0; i<this.packets.size(); i++) begin
        this.packets[i].update_rand_cfg_obj(this.rand_cfg);
      end
    endfunction: update_rand_cfg_obj

    function void update_rand_obj(input adi_axis_rand_obj rand_obj);
      this.rand_obj = rand_obj;

      for (int i=0; i<this.packets.size(); i++) begin
        this.packets[i].update_rand_obj(this.rand_obj);
      end
    endfunction: update_rand_obj

    function void update_packet_class(
      input int location,
      input adi_axis_packet packet_info);

      packet_info.copy(this.packets[location]);
    endfunction: update_packet_class

    function void add_packet_class(input adi_axis_packet packet_info);
      this.packets = new [this.packets.size() + 1] (this.packets);
      this.packets[this.packets.size()-1] = new(
        .transactions_per_packet(packet_info.transactions_per_packet),
        .bytes_per_packet(this.bytes_per_packet),
        .cfg(this.cfg),
        .rand_cfg(this.rand_cfg),
        .rand_obj(this.rand_obj));

      this.update_packet_class(
        .location(this.packets.size()-1),
        .packet_info(packet_info));
    endfunction: add_packet_class

    virtual function adi_object clone();
      adi_axis_frame object;
      object = new(
        .name(this.name),
        .packets_per_frame(this.packets_per_frame),
        .transactions_per_packet(this.transactions_per_packet),
        .bytes_per_packet(this.bytes_per_packet),
        .cfg(this.cfg),
        .rand_cfg(this.rand_cfg),
        .rand_obj(this.rand_obj));
      this.copy(object);
      return object;
    endfunction: clone

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
          .transactions_per_packet(this.transactions_per_packet),
          .bytes_per_packet(this.bytes_per_packet),
          .cfg(this.cfg),
          .rand_cfg(this.rand_cfg),
          .rand_obj(this.rand_obj));
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
