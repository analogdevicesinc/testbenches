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

package scoreboard_primitive_pkg;

  import logger_pkg::*;
  import pub_sub_pkg::*;
  import adi_fifo_primitive_pkg::*;
  import scoreboard_pkg::*;

  class scoreboard_primitive #(type data_type = int) extends scoreboard#(.data_type(data_type));

    class subscriber_class extends adi_subscriber #(data_type);

      protected scoreboard #(data_type) scoreboard_ref;

      protected adi_fifo_primitive #(data_type) data_fifo;

      function new(
        input string name,
        input scoreboard #(data_type) scoreboard_ref,
        input adi_component parent = null);

        super.new(name, parent);

        this.scoreboard_ref = scoreboard_ref;
      endfunction: new

      virtual task update(input data_type data);
        this.info($sformatf("Data received: %d", data), ADI_VERBOSITY_MEDIUM);

        if (this.scoreboard_ref.get_enabled()) begin
          this.put_data(data);
          this.scoreboard_ref.compare_transaction();
        end
      endtask: update

      function data_type get_data();
        return this.data_fifo.pop();
      endfunction: get_data

      function void put_data(data_type data);
        void'(this.data_fifo.push(data));
      endfunction: put_data

      function int size();
        return this.data_fifo.size();
      endfunction: size

      function void clear_fifo();
        this.data_fifo.delete();
      endfunction: clear_fifo

    endclass: subscriber_class


    subscriber_class subscriber_source;
    subscriber_class subscriber_sink;

    // constructor
    function new(
      input string name,
      input adi_component parent = null);

      super.new(name, parent);

      this.subscriber_source = new("Subscriber Source", this);
      this.subscriber_sink = new("Subscriber Sink", this);

      this.enabled = 0;
      this.sink_type = ONESHOT;
      this.data_fifos_empty_sig = 1;

      this.subscriber_sem = new(1);
    endfunction: new

    // clear source and sink fifos
    virtual protected task clear_fifos();
      this.subscriber_sem.get(1);
      this.subscriber_source.clear_fifo();
      this.subscriber_source.clear_fifo();
      this.subscriber_sem.put(1);
    endtask: clear_fifos

    // compare the collected data
    virtual task compare_transaction();
      data_type source_data;
      data_type sink_data;

      this.subscriber_sem.get(1);
      if (this.enabled == 0) begin
        this.subscriber_sem.put(1);
        return;
      end

      this.data_fifos_empty_sig = 0;

      while ((this.subscriber_source.size() > 0) &&
            (this.subscriber_sink.size() > 0)) begin
        source_data = this.subscriber_source.get_data();
        if (this.sink_type == CYCLIC) begin
          this.subscriber_source.put_data(source_data);
        end
        sink_data = this.subscriber_sink.get_data();
        this.info($sformatf("Source-sink data: exp %h - rcv %h", source_data, sink_data), ADI_VERBOSITY_MEDIUM);
        if (source_data !== sink_data) begin
          this.error($sformatf("Failed at: exp %h - rcv %h", source_data, sink_data));
        end
      end

      if ((this.subscriber_source.size() == 0) &&
          (this.subscriber_sink.size() == 0)) begin
        this.data_fifos_empty_sig = 1;
        -> this.data_fifos_empty;
      end
      this.subscriber_sem.put(1);
    endtask: compare_transaction

  endclass

endpackage
