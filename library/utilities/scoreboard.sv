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

package scoreboard_pkg;

  import logger_pkg::*;
  import adi_component_pkg::*;

  virtual class scoreboard #(type data_type = int) extends adi_component;

    // class subscriber_class extends adi_subscriber #(data_type);

    //   protected scoreboard #(data_type) scoreboard_ref;

    //   protected adi_fifo #(data_type) data_fifo;

    //   function new(
    //     input string name,
    //     input scoreboard #(data_type) scoreboard_ref,
    //     input adi_component parent = null);

    //     super.new(name, parent);

    //     this.scoreboard_ref = scoreboard_ref;
    //   endfunction: new

    //   virtual function void update(input adi_fifo #(data_type) data);
    //     this.info($sformatf("Data received: %d", data.sprint()), ADI_VERBOSITY_MEDIUM);

    //     if (this.scoreboard_ref.get_enabled()) begin
    //       this.data_fifo.put_data(data);
    //       this.scoreboard_ref.compare_transaction();
    //     end
    //   endfunction: update

    //   function data_type get_data();
    //     return this.data_fifo.pop();
    //   endfunction: get_data

    //   function void put_data(data_type data);
    //     this.data_fifo.push(data);
    //   endfunction: put_data

    //   function int size();
    //     return this.data_fifo.size();
    //   endfunction: size

    //   function void clear_fifo();
    //     this.data_fifo.delete();
    //   endfunction: clear_fifo

    // endclass: subscriber_class


    // subscriber_class subscriber_source;
    // subscriber_class subscriber_sink;

    typedef enum bit {
      CYCLIC=0,
      ONESHOT
    } sink_type_t;
    protected sink_type_t sink_type;

    // counters and synchronizers
    protected bit enabled;
    protected bit data_fifos_empty_sig;

    // protected event end_of_first_cycle;
    protected event data_fifos_empty;
    protected event stop_scoreboard;

    protected semaphore subscriber_sem;

    // constructor
    function new(
      input string name,
      input adi_component parent = null);

      super.new(name, parent);

      // this.subscriber_source = new("Subscriber Source", this);
      // this.subscriber_sink = new("Subscriber Sink", this);

      // this.enabled = 0;
      // this.sink_type = ONESHOT;
      // this.data_fifos_empty_sig = 1;

      // this.subscriber_sem = new(1);
    endfunction: new

    // run task
    task run();
      this.enabled = 1;

      this.info($sformatf("Scoreboard enabled"), ADI_VERBOSITY_MEDIUM);
    endtask: run

    // stop scoreboard
    task stop();
      this.enabled = 0;
      this.clear_fifos();
      this.data_fifos_empty_sig = 1;
      -> this.data_fifos_empty;
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

    // // clear source and sink fifos
    // protected task clear_fifos();
    //   this.subscriber_sem.get(1);
    //   this.subscriber_source.clear_fifo();
    //   this.subscriber_source.clear_fifo();
    //   this.subscriber_sem.put(1);
    // endtask: clear_fifos

    // wait until source and sink fifos are empty, full check
    task wait_until_complete();
      if (this.data_fifos_empty_sig == 1) begin
        return;
      end
      @this.data_fifos_empty;
    endtask: wait_until_complete

    // compare the collected data
    pure virtual task compare_transaction();

    pure virtual protected task clear_fifos();

  endclass

endpackage
