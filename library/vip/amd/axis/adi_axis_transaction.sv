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

package adi_axis_transaction_pkg;

  import logger_pkg::*;
  import adi_object_pkg::*;
  import adi_axis_byte_pkg::*;
  import adi_axis_config_pkg::*;
  import adi_axis_rand_config_pkg::*;
  import adi_axis_rand_obj_pkg::*;


  class adi_axis_transaction extends adi_object;

    adi_axis_config cfg;
    adi_axis_rand_config rand_cfg;
    adi_axis_rand_obj rand_obj;

    adi_axis_byte bytes [];
    rand logic tlast = 1'b1;
    rand logic [32-1:0] tid = {32{1'b0}};
    rand logic [32-1:0] tdest = {32{1'b0}};
    rand logic [32-1:0] tuser = {32{1'b0}};

    constraint c_tlast {
      if (this.cfg.EN_TLAST == 0) {
        this.tlast == 1'b1;
      }
    }
    constraint c_tid {
      if (this.cfg.EN_TID == 0) {
        this.tid == {32{1'b0}};
      }
      if (this.rand_cfg.TID_MODE != 0) {
        this.tid == this.rand_obj.tid;
      } else {
        this.tid < 2**this.cfg.TID_WIDTH;
      }
    }
    constraint c_tdest {
      if (this.cfg.EN_TDEST == 0) {
        this.tdest == {32{1'b0}};
      }
      if (this.rand_cfg.TDEST_MODE != 0) {
        this.tdest == this.rand_obj.tdest;
      } else {
        this.tdest < 2**this.cfg.TDEST_WIDTH;
      }
    }
    constraint c_tuser {
      if (this.cfg.EN_TUSER == 0 || this.cfg.TUSER_BYTE_BASED == 1) {
        this.tuser == {32{1'b0}};
      }
      if (this.cfg.EN_TUSER == 1 && this.cfg.TUSER_BYTE_BASED == 0) {
        if (this.rand_cfg.TUSER_TX_MODE == 1 || this.rand_cfg.TUSER_TX_MODE == 2) {
          this.tuser == this.rand_obj.tuser_tx;
        } else {
          this.tuser < 2**this.cfg.TUSER_WIDTH;
        }
      }
    }

    function new(
      input string name = "",
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

      this.create_transaction();
    endfunction: new

    function void randomize_transaction();
      if (!this.randomize()) begin
        `FATAL(("Randomization failed!"));
      end

      for (int i=0; i<this.cfg.BYTES_PER_TRANSACTION; i++) begin
        this.bytes[i].randomize_byte();
      end

      if (this.rand_obj.tkeep_count) begin
        for (int i=this.rand_obj.tkeep_count; i<this.cfg.BYTES_PER_TRANSACTION; i++) begin
          this.bytes[i].tkeep = 1'b0;
          this.bytes[i].tstrb = 1'b0;
        end
      end
    endfunction: randomize_transaction

    function void post_randomize();
      if (this.rand_cfg.TID_MODE == 1) begin
        this.rand_obj.tid = this.rand_obj.tid + 1;
      end
      if (this.rand_cfg.TDEST_MODE == 1) begin
        this.rand_obj.tdest = this.rand_obj.tdest + 1;
      end
      if (this.rand_cfg.TUSER_BYTE_MODE == 1) begin
        this.rand_obj.tuser_tx = this.rand_obj.tuser_tx + 1;
      end
    endfunction: post_randomize

    function void create_transaction();
      this.bytes = new [this.cfg.BYTES_PER_TRANSACTION];

      for (int i=0; i<this.cfg.BYTES_PER_TRANSACTION; i++) begin
        this.bytes[i] = new(
          .cfg(this.cfg),
          .rand_cfg(this.rand_cfg),
          .rand_obj(this.rand_obj));
      end
    endfunction: create_transaction

    function void update_rand_cfg_obj(input adi_axis_rand_config rand_cfg);
      this.rand_cfg = rand_cfg;

      for (int i=0; i<this.cfg.BYTES_PER_TRANSACTION; i++) begin
        this.bytes[i].update_rand_cfg_obj(this.rand_cfg);
      end
    endfunction: update_rand_cfg_obj

    function void update_rand_obj(input adi_axis_rand_obj rand_obj);
      this.rand_obj = rand_obj;

      for (int i=0; i<this.cfg.BYTES_PER_TRANSACTION; i++) begin
        this.bytes[i].update_rand_obj(this.rand_obj);
      end
    endfunction: update_rand_obj

    function void update_tlast(input logic tlast);
      if (this.cfg.EN_TLAST) begin
        this.tlast = tlast;
      end else begin
        if (tlast != 1'b1) begin
          `WARNING(("Writing on a disabled TLAST parameter is ignored!"));
        end
      end
    endfunction: update_tlast

    function void update_tid(input logic [32-1:0] tid);
      if (this.cfg.EN_TID) begin
        this.tid = tid;
      end else begin
        if (tid != {32{1'b0}}) begin
          `WARNING(("Writing on a disabled TID parameter is ignored!"));
        end
      end
    endfunction: update_tid

    function void update_tdest(input logic [32-1:0] tdest);
      if (this.cfg.EN_TDEST) begin
        this.tdest = tdest;
      end else begin
        if (tdest != {32{1'b0}}) begin
          `WARNING(("Writing on a disabled TDEST parameter is ignored!"));
        end
      end
    endfunction: update_tdest

    function void update_tuser(input logic [32-1:0] tuser);
      if (this.cfg.EN_TUSER) begin
        this.tuser = tuser;
      end else begin
        if (tuser != {32{1'b0}}) begin
          `WARNING(("Writing on a disabled TUSER parameter is ignored!"));
        end
      end
    endfunction: update_tuser

    function void add_transaction_info(
      input logic tlast = 1'b1,
      input logic [32-1:0] tid = {32{1'b0}},
      input logic [32-1:0] tdest = {32{1'b0}},
      input logic [32-1:0] tuser = {32{1'b0}});

      this.update_tlast(tlast);
      this.update_tid(tid);
      this.update_tdest(tdest);
      this.update_tuser(tuser);
    endfunction: add_transaction_info

    function void add_transaction_info_class(input adi_axis_transaction transaction_info);
      this.update_tlast(transaction_info.tlast);
      this.update_tid(transaction_info.tid);
      this.update_tdest(transaction_info.tdest);
      this.update_tuser(transaction_info.tuser);
    endfunction: add_transaction_info_class

    function void update_data_byte(
      input int location,
      input logic [7:0] tdata,
      input logic tkeep = 1,
      input logic tstrb = 0,
      input logic [32-1:0] tuser = {32{1'b0}});

      adi_axis_byte byte_info = new(
        .cfg(this.cfg),
        .rand_cfg(this.rand_cfg),
        .rand_obj(this.rand_obj));

      byte_info.update_byte_info(
        .tdata(tdata),
        .tkeep(tkeep),
        .tstrb(tstrb),
        .tuser(tuser));

      this.bytes[location] = byte_info;
    endfunction: update_data_byte

    function void update_data_byte_class(
      input int location,
      input adi_axis_byte byte_info);

      byte_info.copy(this.bytes[location]);
    endfunction: update_data_byte_class

    virtual function adi_object clone();
      adi_axis_transaction object;
      object = new(
        .name(this.name),
        .cfg(this.cfg),
        .rand_cfg(this.rand_cfg),
        .rand_obj(this.rand_obj));
      this.copy(object);
      return object;
    endfunction: clone

    virtual function string convert2string();
      string str;
      str = {"ADI AXIS Transaction\n",
        $sformatf("name: %s\n", this.name)};
      return(str);
    endfunction: convert2string

    virtual function void do_copy(input adi_object object);
      adi_axis_transaction cast_object;

      if ($cast(cast_object, object) == 0) begin
        `FATAL(("Input object %s type is not compatible with current object %s type!", object.sprint(), this.sprint()));
      end

      cast_object.add_transaction_info(
        .tlast(this.tlast),
        .tid(this.tid),
        .tdest(this.tdest),
        .tuser(this.tuser));

      for (int i=0; i<this.cfg.BYTES_PER_TRANSACTION; i++) begin
        this.bytes[i].copy(cast_object.bytes[i]);
      end
    endfunction: do_copy

    virtual function bit do_compare(input adi_object object);
      adi_axis_transaction cast_object;

      if ($cast(cast_object, object) == 0) begin
        `FATAL(("Cast object %s type is not compatible with current object %s type!", object.sprint(), this.sprint()));
      end

      if ((this.cfg.EN_TLAST && (this.tlast != cast_object.tlast)) ||
        (this.cfg.EN_TID && (this.tid != cast_object.tid)) ||
        (this.cfg.EN_TDEST && (this.tdest != cast_object.tdest)) ||
        (this.cfg.EN_TUSER && this.cfg.TUSER_BYTE_BASED && (this.tuser != cast_object.tuser))) begin

        return 0;
      end

      for (int i=0; i<this.cfg.BYTES_PER_TRANSACTION; i++) begin
        if (this.bytes[i].compare(cast_object.bytes[i]) == 0) begin
          return 0;
        end
      end
      return 1;
    endfunction: do_compare

  endclass: adi_axis_transaction

endpackage: adi_axis_transaction_pkg
