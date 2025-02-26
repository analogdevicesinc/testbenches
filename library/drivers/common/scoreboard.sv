// ***************************************************************************
// ***************************************************************************
// Copyright (C) 2024 - 2025 Analog Devices, Inc. All rights reserved.
//
// In this HDL repository, there are many different and unique modules, consisting
// of various HDL (Verilog or VHDL) components. The individual modules are
// developed independently, and may be accompanied by separate and unique license
// terms.
//
// The user should read each of these license terms, and understand the
// freedoms and responsabilities that he or she has by using this source/core.
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

package scoreboard_pkg;

  import logger_pkg::*;
  import adi_common_pkg::*;
  import adi_datatypes_pkg::*;
  import pub_sub_pkg::*;

  class scoreboard #(type data_type = int) extends adi_component;

    class subscriber_class extends adi_subscriber #(data_type);

      protected scoreboard #(data_type) scoreboard_ref;
      
      protected adi_fifo #(data_type) byte_stream;

      function new(
        input string name,
        input scoreboard #(data_type) scoreboard_ref,
        input adi_component parent = null);

        super.new(name, parent);

        this.scoreboard_ref = scoreboard_ref;

        byte_stream = new("Data queue", 0, this);
      endfunction: new

      virtual function void update(input adi_fifo #(data_type) data);
        this.info($sformatf("Data received: %d", data.size()), ADI_VERBOSITY_MEDIUM);
        while (data.size()) begin
          void'(this.byte_stream.push(data.pop()));
        end
        
        if (this.scoreboard_ref.get_enabled()) begin
          this.scoreboard_ref.compare_transaction();
        end
      endfunction: update

      function data_type get_data();
        return this.byte_stream.pop();
      endfunction: get_data

      function void put_data(data_type data);
        void'(this.byte_stream.push(data));
      endfunction: put_data

      function int get_size();
        return this.byte_stream.size();
      endfunction: get_size

      function void clear_stream();
        this.byte_stream.delete();
      endfunction: clear_stream

    endclass: subscriber_class


    subscriber_class subscriber_source;
    subscriber_class subscriber_sink;

    typedef enum bit { CYCLIC=0, ONESHOT } sink_type_t;
    protected sink_type_t sink_type;

    // counters and synchronizers
    protected bit enabled;
    protected bit byte_streams_empty_sig;

    // protected event end_of_first_cycle;
    protected event byte_streams_empty;
    protected event stop_scoreboard;

    // constructor
    function new(
      input string name,
      input adi_component parent = null);

      super.new(name, parent);

      this.subscriber_source = new("Subscriber Source", this);
      this.subscriber_sink = new("Subscriber Sink", this);

      this.enabled = 0;
      this.sink_type = ONESHOT;
      this.byte_streams_empty_sig = 1;
    endfunction: new

    // run task
    task run();
      this.enabled = 1;
      
      this.info($sformatf("Scoreboard enabled"), ADI_VERBOSITY_MEDIUM);
    endtask: run

    // stop scoreboard
    task stop();
      this.enabled = 0;
      this.clear_streams();
      this.byte_streams_empty_sig = 1;
    endtask: stop

    function bit get_enabled();
      return this.enabled;
    endfunction: get_enabled

    // set sink type
    function void set_sink_type(input bit sink_type);
      if (!this.enabled) begin
        this.sink_type = sink_type_t'(sink_type);
      end else begin
        this.error($sformatf("Can not configure sink_type while scoreboard is running."));
      end
    endfunction: set_sink_type

    // get sink type
    function bit get_sink_type();
      return this.sink_type;
    endfunction: get_sink_type

    // clear source and sink byte streams
    protected function void clear_streams();
      this.subscriber_source.clear_stream();
      this.subscriber_source.clear_stream();
    endfunction: clear_streams

    // wait until source and sink byte streams are empty, full check
    task wait_until_complete();
      if (this.byte_streams_empty_sig)
        return;
      @this.byte_streams_empty;
    endtask: wait_until_complete

    // compare the collected data
    virtual function void compare_transaction();
      data_type source_byte;
      data_type sink_byte;

      if (this.enabled == 0)
        return;
      
      while ((this.subscriber_source.get_size() > 0) &&
            (this.subscriber_sink.get_size() > 0)) begin
        byte_streams_empty_sig = 0;
        source_byte = this.subscriber_source.get_data();
        if (this.sink_type == CYCLIC)
          this.subscriber_source.put_data(source_byte);
        sink_byte = this.subscriber_sink.get_data();
        this.info($sformatf("Source-sink data: exp %h - rcv %h", source_byte, sink_byte), ADI_VERBOSITY_MEDIUM);
        if (source_byte != sink_byte) begin
          this.error($sformatf("Failed at: exp %h - rcv %h", source_byte, sink_byte));
        end
      end

      if ((this.subscriber_source.get_size() == 0) &&
          (this.subscriber_sink.get_size() == 0)) begin
        this.byte_streams_empty_sig = 1;
        ->this.byte_streams_empty;
      end
    endfunction: compare_transaction

  endclass

endpackage
