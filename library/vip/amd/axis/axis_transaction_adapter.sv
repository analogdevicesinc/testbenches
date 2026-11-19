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

package axis_transaction_adapter_pkg;

  import logger_pkg::*;
  import adi_component_pkg::*;
  import pub_sub_pkg::*;
  import adi_fifo_pkg::*;
  import adi_axis_transaction_pkg::*;
  import adi_axis_config_pkg::*;

  class axis_transaction_adapter extends adi_component;

    class subscriber_class extends adi_subscriber #(adi_axis_transaction);

      protected axis_transaction_adapter adapter_ref;

      adi_fifo #(adi_axis_transaction) data_fifo;

      function new(
        input string name,
        input axis_transaction_adapter adapter_ref,
        input adi_component parent = null);

        super.new(name, parent);

        this.data_fifo = new();

        this.adapter_ref = adapter_ref;
      endfunction: new

      virtual task update(input adi_fifo #(adi_axis_transaction) data);
        this.info($sformatf("Data received: %d", data.size()), ADI_VERBOSITY_MEDIUM);

        if (!this.data_fifo.size()) begin
          data.copy(this.data_fifo);
        end else begin
          while (data.size()) begin
            void'(this.data_fifo.push(data.pop()));
          end
        end
        this.adapter_ref.process_transaction();
      endtask: update

    endclass: subscriber_class


    subscriber_class subscriber_source;
    subscriber_class subscriber_sink;

    adi_publisher #(adi_axis_transaction) publisher_source;
    adi_publisher #(adi_axis_transaction) publisher_sink;

    protected int source_ratio;
    protected int sink_ratio;

    // constructor
    function new(
      input string name,
      input int source_bytes_per_transaction,
      input int sink_bytes_per_transaction,
      input adi_component parent = null);

      super.new(name, parent);

      this.subscriber_source = new("Subscriber Source", this, this);
      this.subscriber_sink = new("Subscriber Sink", this, this);

      this.publisher_source = new("Publisher Source", this);
      this.publisher_sink = new("Publisher Sink", this);

      this.source_ratio = source_bytes_per_transaction/`MIN(source_bytes_per_transaction, sink_bytes_per_transaction);
      this.sink_ratio = sink_bytes_per_transaction/`MIN(source_bytes_per_transaction, sink_bytes_per_transaction);
    endfunction: new

    protected task adapt_and_publish(
      input adi_publisher #(adi_axis_transaction) publisher_obj,
      input adi_fifo #(adi_axis_transaction) data_fifo_in,
      input int ratio);

      adi_fifo #(adi_axis_transaction) data_fifo = new();

      adi_axis_transaction axis_transaction;
      adi_axis_transaction axis_transaction_in;

      adi_axis_config axis_cfg;

      while (data_fifo_in.size()) begin
        axis_transaction_in = data_fifo_in.pop();

        axis_cfg = adi_axis_config'(axis_transaction_in.cfg.clone());
        axis_cfg.BYTES_PER_TRANSACTION = axis_cfg.BYTES_PER_TRANSACTION/ratio;
        axis_transaction = new(.cfg(axis_cfg));

        // add conditionals to everything
        axis_transaction.add_transaction_info_class(.transaction_info(axis_transaction_in));
        for (int i=0; i<ratio; i++) begin
          if (axis_transaction.cfg.EN_TLAST && i == ratio-1) begin
            axis_transaction.tlast = axis_transaction_in.tlast;
          end else begin
            axis_transaction.tlast = 1'b0;
          end
          for (int j=0; j<axis_transaction.cfg.BYTES_PER_TRANSACTION; j++) begin
            axis_transaction.bytes[j].update_tdata(axis_transaction_in.bytes[i*axis_transaction.cfg.BYTES_PER_TRANSACTION + j].tdata);
            if (axis_transaction.cfg.EN_TKEEP) begin
              axis_transaction.bytes[j].update_tkeep(axis_transaction_in.bytes[i*axis_transaction.cfg.BYTES_PER_TRANSACTION + j].tkeep);
            end
            if (axis_transaction.cfg.EN_TSTRB) begin
              axis_transaction.bytes[j].update_tstrb(axis_transaction_in.bytes[i*axis_transaction.cfg.BYTES_PER_TRANSACTION + j].tstrb);
            end
            axis_transaction.bytes[j].update_tuser(axis_transaction_in.bytes[i*axis_transaction.cfg.BYTES_PER_TRANSACTION + j].tuser);
          end
          for (int j=0; j<axis_transaction.cfg.BYTES_PER_TRANSACTION; j++) begin
            if (axis_transaction.bytes[j].tkeep == 1'b1) begin
              void'(data_fifo.push(axis_transaction));
              break;
            end
          end
        end
      end

      publisher_obj.notify(data_fifo);
    endtask: adapt_and_publish

    // process the collected data
    task process_transaction();
      this.adapt_and_publish(
        .publisher_obj(this.publisher_source),
        .data_fifo_in(this.subscriber_source.data_fifo),
        .ratio(this.source_ratio));

      this.adapt_and_publish(
        .publisher_obj(this.publisher_sink),
        .data_fifo_in(this.subscriber_sink.data_fifo),
        .ratio(this.sink_ratio));
    endtask: process_transaction

  endclass: axis_transaction_adapter

endpackage: axis_transaction_adapter_pkg
