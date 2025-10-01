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


  class adi_axis_transaction #(
    int BYTES_PER_TRANSACTION,
    bit EN_TKEEP = 0,
    bit EN_TSTRB = 0,
    bit EN_TLAST = 0,
    bit EN_TUSER = 0,
    bit EN_TID = 0,
    bit EN_TDEST = 0,
    bit TUSER_BYTE_BASED = 0,
    int TID_WIDTH = 1,
    int TDEST_WIDTH = 1,
    int TUSER_WIDTH = 1) extends adi_object;

    adi_axis_byte #(EN_TKEEP, EN_TSTRB, (EN_TUSER && TUSER_BYTE_BASED), TUSER_WIDTH) bytes [BYTES_PER_TRANSACTION-1:0];
    rand logic tlast = 1'b1;
    rand logic [TID_WIDTH-1:0] tid = {TID_WIDTH{1'b0}};
    rand logic [TDEST_WIDTH-1:0] tdest = {TDEST_WIDTH{1'b0}};
    rand logic [TUSER_WIDTH-1:0] tuser = {TUSER_WIDTH{1'b0}};

    constraint c_tlast { (EN_TLAST == 0) -> (tlast == 1'b0); }
    constraint c_tid { (EN_TID == 0) -> (tid == {TID_WIDTH{1'b0}}); }
    constraint c_tdest { (EN_TDEST == 0) -> (tdest == {TDEST_WIDTH{1'b0}}); }
    constraint c_tuser { (EN_TUSER == 0 || TUSER_BYTE_BASED == 1) -> (tuser == {TUSER_WIDTH{1'b0}}); }

    function new(input string name = "");
      super.new(name);

      for (int i=0; i<BYTES_PER_TRANSACTION; i++) begin
        this.bytes[i] = new();
      end

      if (TUSER_WIDTH == 0) begin
        `FATAL(("TUSER width value cannot be 0!"));
      end
      if (TID_WIDTH == 0) begin
        `FATAL(("TID width value cannot be 0!"));
      end
      if (TDEST_WIDTH == 0) begin
        `FATAL(("TDEST width value cannot be 0!"));
      end
    endfunction: new

    function void randomize_transaction();
      if (!this.randomize()) begin
        `FATAL(("Randomization failed!"));
      end
    endfunction: randomize_transaction

    function void randomize_all();
      this.randomize_transaction();
      for (int i=0; i<this.BYTES_PER_TRANSACTION; i++) begin
        this.bytes[i].randomize_all();
      end
    endfunction: randomize_all

    function void update_tlast(input logic tlast);
      if (EN_TLAST) begin
        this.tlast = tlast;
      end else begin
        if (tlast != 1'b1) begin
          `WARNING(("Writing on a disabled TLAST parameter is not accepted!"));
        end
      end
    endfunction: update_tlast

    function void update_tid(input logic [TID_WIDTH:0] tid);
      if (EN_TID) begin
        this.tid = tid;
      end else begin
        if (tid != {TID_WIDTH{1'b0}}) begin
          `WARNING(("Writing on a disabled TID parameter is not accepted!"));
        end
      end
    endfunction: update_tid

    function void update_tdest(input logic [TDEST_WIDTH:0] tdest);
      if (EN_TDEST) begin
        this.tdest = tdest;
      end else begin
        if (tdest != {TDEST_WIDTH{1'b0}}) begin
          `WARNING(("Writing on a disabled TDEST parameter is not accepted!"));
        end
      end
    endfunction: update_tdest

    function void update_tuser(input logic [TUSER_WIDTH:0] tuser);
      if (EN_TUSER) begin
        this.tuser = tuser;
      end else begin
        if (tuser != {TUSER_WIDTH{1'b0}}) begin
          `WARNING(("Writing on a disabled TUSER parameter is not accepted!"));
        end
      end
    endfunction: update_tuser

    function void add_transaction_info(
      input logic tlast = 1'b1,
      input logic [TID_WIDTH:0] tid = {TID_WIDTH{1'b0}},
      input logic [TDEST_WIDTH:0] tdest = {TDEST_WIDTH{1'b0}},
      input logic [TUSER_WIDTH:0] tuser = {TUSER_WIDTH{1'b0}});

      this.update_tlast(tlast);
      this.update_tid(tid);
      this.update_tdest(tdest);
      this.update_tuser(tuser);
    endfunction: add_transaction_info

    function void add_transaction_info_class(input adi_axis_transaction #(BYTES_PER_TRANSACTION, EN_TKEEP, EN_TSTRB, EN_TUSER, EN_TID, EN_TDEST, TUSER_BYTE_BASED, TID_WIDTH, TDEST_WIDTH, TUSER_WIDTH) transaction_info);
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
      input logic [TUSER_WIDTH:0] tuser = {TUSER_WIDTH{1'b0}});

      adi_axis_byte #(EN_TKEEP, EN_TSTRB, (EN_TUSER && TUSER_BYTE_BASED), TUSER_WIDTH) byte_info = new();

      byte_info.update_byte_info(
        .tdata(tdata),
        .tkeep(tkeep),
        .tstrb(tstrb),
        .tuser(tuser));

      this.bytes[location] = byte_info;
    endfunction: update_data_byte

    function void update_data_byte_class(
      input int location,
      input adi_axis_byte #(EN_TKEEP, EN_TSTRB, (EN_TUSER && TUSER_BYTE_BASED), TUSER_WIDTH) byte_info);

      byte_info.copy(this.bytes[location]);
    endfunction: update_data_byte_class

    virtual function string convert2string();
      string str;
      str = {"ADI AXIS Transaction\n",
        $sformatf("name: %s\n", this.name)};
      return(str);
    endfunction: convert2string

    virtual function void do_copy(input adi_object object);
      adi_axis_transaction #(BYTES_PER_TRANSACTION, EN_TKEEP, EN_TSTRB, EN_TUSER, EN_TID, EN_TDEST, TUSER_BYTE_BASED, TID_WIDTH, TDEST_WIDTH, TUSER_WIDTH) cast_object;

      if ($cast(cast_object, object) == 0) begin
        `FATAL(("Input object %s type is not compatible with current object %s type!", object.sprint(), this.sprint()));
      end

      cast_object.add_transaction_info(
        .tlast(this.tlast),
        .tid(this.tid),
        .tdest(this.tdest),
        .tuser(this.tuser));

      for (int i=0; i<this.BYTES_PER_TRANSACTION; i++) begin
        this.bytes[i].copy(cast_object.bytes[i]);
      end
    endfunction: do_copy

    virtual function bit do_compare(input adi_object object);
      adi_axis_transaction #(BYTES_PER_TRANSACTION, EN_TKEEP, EN_TSTRB, EN_TUSER, EN_TID, EN_TDEST, TUSER_BYTE_BASED, TID_WIDTH, TDEST_WIDTH, TUSER_WIDTH) cast_object;

      if ($cast(cast_object, object) == 0) begin
        `FATAL(("Cast object %s type is not compatible with current object %s type!", object.sprint(), this.sprint()));
      end

      if (this.tlast != cast_object.tlast ||
        this.tid != cast_object.tid ||
        this.tdest != cast_object.tdest ||
        this.tuser != cast_object.tuser) begin

        return 0;
      end

      for (int i=0; i<this.BYTES_PER_TRANSACTION; i++) begin
        if (this.bytes[i].compare(cast_object.bytes[i]) == 0) begin
          return 0;
        end
      end
      return 1;
    endfunction: do_compare

  endclass: adi_axis_transaction

endpackage: adi_axis_transaction_pkg
