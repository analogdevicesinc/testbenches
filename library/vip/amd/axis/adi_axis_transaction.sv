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
  import axi4stream_vip_pkg::*;


  class adi_axis_byte #(int TUSER = 0) extends adi_object;
    logic [7:0] tdata;
    logic tkeep;
    logic tstrb;
    logic [TUSER:0] tuser;

    function new(input string name = "");
      super.new(name);
    endfunction: new

    function void add_byte_info(
      input logic [7:0] tdata,
      input logic tkeep,
      input logic tstrb,
      input logic [TUSER:0] tuser = 0);

      this.tdata = tdata;
      this.tkeep = tkeep;
      this.tstrb = tstrb;
      this.tuser = tuser;
    endfunction: add_byte_info

    virtual function string convert2string();
      string str;
      str = {"ADI AXIS Byte\n",
        $sformatf("name: %s\n", this.name),
        $sformatf("tdata: %d\n", this.tdata),
        $sformatf("tkeep: %d\n", this.tkeep),
        $sformatf("tstrb: %d\n", this.tstrb),
        $sformatf("tuser: %d\n", this.tuser)};
      return(str);
    endfunction: convert2string

    virtual function void do_copy(input adi_object object);
      adi_axis_byte #(TUSER) cast_object;

      if ($cast(
        .dest_var(cast_object),
        .source_exp(object)) == 0) begin

        `FATAL(("Input object %s type is not compatible with current object %s type!", object.sprint(), this.sprint()));
      end

      cast_object.add_transfer(
        .tdata(this.tdata),
        .tkeep(this.tkeep),
        .tstrb(this.tstrb),
        .tuser(this.tuser));
    endfunction: do_copy

    virtual function bit do_compare(input data_type object);
      adi_axis_byte #(TUSER) cast_object;

      if ($cast(
        .dest_var(cast_object),
        .source_exp(object)) == 0) begin

        `FATAL(0, ("Cast object %s type is not compatible with current object %s type!", object.sprint(), this.sprint()));
      end

      if (this.tdata != cast_object.tdata ||
        this.tkeep != cast_object.tkeep ||
        this.tstrb != cast_object.tstrb ||
        this.tuser != cast_object.tuser) begin

        return 0;
      end
      return 1;
    endfunction: do_compare
  endclass: adi_axis_byte


  class adi_axis_transaction #(
    int TID = 0,
    int TDEST = 0,
    int TUSER = 0) extends adi_object;

    adi_axis_byte #(TUSER) bytes [];
    logic tlast;
    logic [TID:0] tid;
    logic [TDEST:0] tdest;
    logic [TUSER:0] tuser;

    function new(input string name = "");
      super.new(name);

      this.bytes = new();
    endfunction: new

    function void add_transfer(
      input logic tlast,
      input logic [TID:0] tid,
      input logic [TDEST:0] tdest,
      input logic [TUSER:0] tuser);

      this.tlast = tlast;
      this.tid = tid;
      this.tdest = tdest;
      this.tuser = tuser;
    endfunction: add_transfer

    function void add_data_byte(
      input logic [7:0] tdata,
      input logic tkeep,
      input logic tstrb,
      input logic [TUSER:0] tuser = 0);

      adi_axis_byte #(TUSER) byte_info = new();

      byte_info.add_byte_info(
        .tdata(tdata),
        .tkeep(tkeep),
        .tstrb(tstrb),
        .tuser(tuser));

      this.bytes = new [this.bytes.size()+1] (this.bytes);
      this.bytes[this.bytes.size()-1] = byte_info;
    endfunction: add_data_byte

    virtual function string convert2string();
      string str;
      str = {"ADI AXIS Transaction\n",
        $sformatf("name: %s\n", this.name),
        $sformatf("tlast: %d\n", this.tlast),
        $sformatf("tid: %d\n", this.tid),
        $sformatf("tdest: %d\n", this.tdest),
        $sformatf("tuser: %d\n", this.tuser)};
      return(str);
    endfunction: convert2string

    virtual function void do_copy(input adi_object object);
      adi_axis_transaction #(TID, TDEST, TUSER) cast_object;

      if ($cast(
        .dest_var(cast_object),
        .source_exp(object)) == 0) begin

        `FATAL(("Input object %s type is not compatible with current object %s type!", object.sprint(), this.sprint()));
      end

      cast_object.add_transfer(
        .tlast(this.tlast),
        .tid(this.tid),
        .tdest(this.tdest),
        .tuser(this.tuser));

      cast_object.bytes = new [this.bytes.size()];

      for (int i=0; i<this.bytes.size(); i++) begin
        this.bytes[i].copy(cast_object.bytes[i]);
      end
    endfunction: do_copy

    function bit compare(input adi_object object);
      adi_axis_transaction #(TID, TDEST, TUSER) cast_object;

      if ($cast(
        .dest_var(cast_object),
        .source_exp(object)) == 0) begin

        `FATAL(0, ("Cast object %s type is not compatible with current object %s type!", object.sprint(), this.sprint()));
      end

      if (this.bytes.size() != cast_object.bytes.size()) begin
        return 0;
      end

      return do_compare(.object(cast_object));
    endfunction: compare

    virtual function bit do_compare(input data_type object);
      adi_axis_transaction #(TID, TDEST, TUSER) cast_object;

      if ($cast(
        .dest_var(cast_object),
        .source_exp(object)) == 0) begin

        `FATAL(0, ("Cast object %s type is not compatible with current object %s type!", object.sprint(), this.sprint()));
      end

      if (this.tlast != cast_object.tlast ||
        this.tid != cast_object.tid ||
        this.tdest != cast_object.tdest ||
        this.tuser != cast_object.tuser) begin

        return 0;
      end

      for (int i=0; i<this.bytes.size(); i++) begin
        if (this.bytes[i].compare(cast_object.bytes[i]) == 0) begin
          return 0;
        end
      end
      return 1;
    endfunction: do_compare
  endclass: adi_axis_transaction

endpackage: adi_axis_transaction_pkg
