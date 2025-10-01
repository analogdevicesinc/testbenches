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

package adi_axis_packet_pkg;

  import logger_pkg::*;
  import adi_object_pkg::*;
  import adi_axis_transaction_pkg::*;


  class adi_axis_packet #(
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

    adi_axis_transaction #(BYTES_PER_TRANSACTION, EN_TKEEP, EN_TSTRB, EN_TUSER, EN_TID, EN_TDEST, TUSER_BYTE_BASED, TID_WIDTH, TDEST_WIDTH, TUSER_WIDTH) transactions[];
    int packet_size_limit;

    function new(
      input string name = "",
      input int packet_size_limit = 0);

      super.new(name);

      this.packet_size_limit = packet_size_limit;
      if (this.packet_size_limit != 0) begin
        this.create_packet(this.packet_size_limit);
      end
    endfunction: new

    function void randomize_packet();
      if (this.transactions.size() == 0) begin
        `FATAL(("The packet is empty, nothing to randomize!"));
      end

      this.transactions[0].randomize_all();
      this.transactions[0].update_tlast(1'b0);
      for (int i=1; i<this.transactions.size(); i++) begin
        this.transactions[i].randomize_all();
        this.transactions[i].update_tlast(1'b0);
        this.transactions[i].update_tid(this.transactions[0].tid);
        this.transactions[i].update_tdest(this.transactions[0].tdest);
      end
      this.transactions[this.transactions.size()-1].update_tlast(1'b1);
    endfunction: randomize_packet

    function void randomize_all();
      if (packet_size_limit == 0) begin
        this.create_packet($urandom());
      end else begin
        this.create_packet($urandom_range(1, this.packet_size_limit));
      end

      this.randomize_packet();
    endfunction: randomize_all

    function void create_packet(input int packet_size);
      this.transactions = new[packet_size];

      for (int i=0; i<this.transactions.size(); i++) begin
        this.transactions[i] = new();
        this.transactions[i].update_tlast(1'b0);
      end
      this.transactions[this.transactions.size()-1].update_tlast(1'b1);
    endfunction: create_packet

    function void update_transaction_class(
      input int location,
      input adi_axis_transaction #(BYTES_PER_TRANSACTION, EN_TKEEP, EN_TSTRB, EN_TUSER, EN_TID, EN_TDEST, TUSER_BYTE_BASED, TID_WIDTH, TDEST_WIDTH, TUSER_WIDTH) transaction_info);

      if (location != 0) begin
        if (transaction_info.tid != this.transactions[0].tid) begin
          `ERROR(("TID must be the same for all transactions in the packet! First transaction's TID value: %0h, input transaction TID value: %0h", this.transactions[0].tid, transaction_info.tid));
        end
        if (transaction_info.tdest != this.transactions[0].tdest) begin
          `ERROR(("TDEST must be the same for all transactions in the packet! First transaction's TDEST value: %0h, input transaction TDEST value: %0h", this.transactions[0].tdest, transaction_info.tdest));
        end
      end

      if (location != this.transactions.size()-1) begin
        if (transaction_info.tlast == 1'b1) begin
          `ERROR(("The TLAST value can only be 1 in the last transaction!"));
        end
      end

      transaction_info.copy(this.transactions[location]);
    endfunction: update_transaction_class

    function void add_transaction_class(input adi_axis_transaction #(BYTES_PER_TRANSACTION, EN_TKEEP, EN_TSTRB, EN_TUSER, EN_TID, EN_TDEST, TUSER_BYTE_BASED, TID_WIDTH, TDEST_WIDTH, TUSER_WIDTH) transaction_info);
      this.transactions[this.transactions.size()-1].update_tlast(1'b0);
      this.transactions = new [this.transactions.size() + 1] (this.transactions);
      this.transactions[this.transactions.size()-1] = new();

      this.update_transaction_class(
        .location(this.transactions.size()-1),
        .transaction_info(transaction_info));
    endfunction: add_transaction_class

    virtual function string convert2string();
      string str;
      str = {"ADI AXIS Packet\n",
        $sformatf("name: %s\n", this.name)};
      return(str);
    endfunction: convert2string

    virtual function void do_copy(input adi_object object);
      adi_axis_packet #(BYTES_PER_TRANSACTION, EN_TKEEP, EN_TSTRB, EN_TUSER, EN_TID, EN_TDEST, TUSER_BYTE_BASED, TID_WIDTH, TDEST_WIDTH, TUSER_WIDTH) cast_object;

      if ($cast(cast_object, object) == 0) begin
        `FATAL(("Input object %s type is not compatible with current object %s type!", object.sprint(), this.sprint()));
      end

      cast_object.transactions = new[this.transactions.size()];

      for (int i=0; i<this.transactions.size(); i++) begin
        cast_object.transactions[i] = new();
        this.transactions[i].copy(cast_object.transactions[i]);
      end
    endfunction: do_copy

    virtual function bit do_compare(input adi_object object);
      adi_axis_packet #(BYTES_PER_TRANSACTION, EN_TKEEP, EN_TSTRB, EN_TUSER, EN_TID, EN_TDEST, TUSER_BYTE_BASED, TID_WIDTH, TDEST_WIDTH, TUSER_WIDTH) cast_object;

      if ($cast(cast_object, object) == 0) begin
        `FATAL(("Cast object %s type is not compatible with current object %s type!", object.sprint(), this.sprint()));
      end

      for (int i=0; i<this.transactions.size(); i++) begin
        if (this.transactions[i].compare(cast_object.transactions[i]) == 0) begin
          return 0;
        end
      end
      return 1;
    endfunction: do_compare

  endclass: adi_axis_packet

endpackage: adi_axis_packet_pkg
