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
  import adi_axis_config_pkg::*;
  import adi_axis_rand_config_pkg::*;
  import adi_axis_rand_obj_pkg::*;


  class adi_axis_packet extends adi_object;

    adi_axis_config cfg;
    adi_axis_rand_config rand_cfg;
    adi_axis_rand_obj rand_obj;

    adi_axis_transaction transactions[];
    int transactions_per_packet;
    int bytes_per_packet;

    function new(
      input string name = "",
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

      this.bytes_per_packet = bytes_per_packet;
      this.transactions_per_packet = `MAX($ceil(this.bytes_per_packet/this.cfg.BYTES_PER_TRANSACTION), transactions_per_packet);

      if (this.bytes_per_packet) begin
        this.rand_cfg.TKEEP_MODE = 1;
      end

      if (this.transactions_per_packet > 0 || this.bytes_per_packet > 0) begin
        this.create_packet();
      end
    endfunction: new

    function void randomize_packet();
      if (this.transactions.size() == 0) begin
        `FATAL(("The packet is empty, nothing to randomize!"));
      end

      if (!this.randomize()) begin
        `FATAL(("Randomization failed!"));
      end

      for (int i=0; i<this.transactions.size(); i++) begin
        this.transactions[i].randomize_transaction();
        if (this.cfg.EN_TLAST) begin
          this.transactions[i].update_tlast(1'b0);
        end
        if (this.cfg.EN_TID) begin
          this.transactions[i].update_tid(this.transactions[0].tid);
        end
        if (this.cfg.EN_TDEST) begin
          this.transactions[i].update_tdest(this.transactions[0].tdest);
        end
      end
      if (this.cfg.EN_TLAST) begin
        this.transactions[this.transactions.size()-1].update_tlast(1'b1);
      end
    endfunction: randomize_packet

    function void post_randomize();
      if (this.rand_cfg.TID_MODE == 2) begin
        this.rand_obj.tid = this.rand_obj.tid + 1;
      end
      if (this.rand_cfg.TDEST_MODE == 2) begin
        this.rand_obj.tdest = this.rand_obj.tdest + 1;
      end
    endfunction: post_randomize

    function void create_packet(
      input int transactions_per_packet = 0,
      input int bytes_per_packet = 0);

      if (transactions_per_packet > 0 || bytes_per_packet > 0) begin
        this.bytes_per_packet = bytes_per_packet;
        this.transactions_per_packet = `MAX($ceil(this.bytes_per_packet/this.cfg.BYTES_PER_TRANSACTION), transactions_per_packet);
      end

      if (this.transactions_per_packet == 0 && this.bytes_per_packet == 0) begin
        `FATAL(("Creating a packet without transaction count or byte size set is not allowed!"));
      end else begin
        this.transactions = new[`MAX($ceil(this.bytes_per_packet/this.cfg.BYTES_PER_TRANSACTION), this.transactions_per_packet)];
      end

      for (int i=0; i<this.transactions.size(); i++) begin
        this.transactions[i] = new(
          .cfg(this.cfg),
          .rand_cfg(this.rand_cfg),
          .rand_obj(this.rand_obj));
      end

      if (this.bytes_per_packet) begin
        this.transactions[this.transactions.size()-1].rand_obj = adi_axis_rand_obj'(this.rand_obj.clone());
        this.rand_obj.tkeep_count = this.bytes_per_packet % this.cfg.BYTES_PER_TRANSACTION;
      end
    endfunction: create_packet

    function void update_rand_cfg_obj(input adi_axis_rand_config rand_cfg);
      this.rand_cfg = rand_cfg;

      for (int i=0; i<this.transactions.size(); i++) begin
        this.transactions[i].update_rand_cfg_obj(this.rand_cfg);
      end
    endfunction: update_rand_cfg_obj

    function void update_rand_obj(input adi_axis_rand_obj rand_obj);
      this.rand_obj = rand_obj;

      for (int i=0; i<this.transactions.size(); i++) begin
        this.transactions[i].update_rand_obj(this.rand_obj);
      end
    endfunction: update_rand_obj

    function void update_transaction_class(
      input int location,
      input adi_axis_transaction transaction_info);

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
          `ERROR(("The TLAST value can only be 1 at the last transaction in the packet!"));
        end
      end

      transaction_info.copy(this.transactions[location]);
    endfunction: update_transaction_class

    function void add_transaction_class(input adi_axis_transaction transaction_info);
      if (this.cfg.EN_TLAST) begin
        this.transactions[this.transactions.size()-1].update_tlast(1'b0);
      end
      this.transactions = new [this.transactions.size() + 1] (this.transactions);
      this.transactions[this.transactions.size()-1] = new(
        .cfg(this.cfg),
        .rand_cfg(this.rand_cfg),
        .rand_obj(this.rand_obj));

      this.update_transaction_class(
        .location(this.transactions.size()-1),
        .transaction_info(transaction_info));
    endfunction: add_transaction_class

    virtual function adi_object clone();
      adi_axis_packet object;
      object = new(
        .name(this.name),
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
      str = {"ADI AXIS Packet\n",
        $sformatf("name: %s\n", this.name)};
      return(str);
    endfunction: convert2string

    virtual function void do_copy(input adi_object object);
      adi_axis_packet cast_object;

      if ($cast(cast_object, object) == 0) begin
        `FATAL(("Input object %s type is not compatible with current object %s type!", object.sprint(), this.sprint()));
      end

      cast_object.transactions = new[this.transactions.size()];

      for (int i=0; i<this.transactions.size(); i++) begin
        cast_object.transactions[i] = new(
          .cfg(this.cfg),
          .rand_cfg(this.rand_cfg),
          .rand_obj(this.rand_obj));
        this.transactions[i].copy(cast_object.transactions[i]);
      end
    endfunction: do_copy

    virtual function bit do_compare(input adi_object object);
      adi_axis_packet cast_object;

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
