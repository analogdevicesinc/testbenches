// ***************************************************************************
// ***************************************************************************
// Copyright (C) 2021 Analog Devices, Inc. All rights reserved.
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

package do_scoreboard_pkg;

  import xil_common_vip_pkg::*;
  import axi4stream_vip_pkg::*;
  import axi_vip_pkg::*;
  import logger_pkg::*;

  class do_scoreboard extends xil_component;

    typedef enum bit { CYCLIC=0, ONESHOT } do_mode_t;
    do_mode_t do_mode;

    typedef enum bit { RX=0, TX } path_type_t;
    path_type_t path_type;

    bit reading = 1'b0;
    semaphore reading_lock;

    // List of analysis ports from the monitors
    xil_analysis_port #(axi4stream_monitor_transaction) src_axis_ap;
    xil_analysis_port #(axi4stream_monitor_transaction) dst_axis_ap;

    // transaction queues (because the source and sink interface can have
    // different widths, byte streams are used)
    logic [7:0] byte_stream [$];

    int transfer_size;

    // counters and synchronizers
    bit enabled;
    event end_of_first_cycle;

    // constructor
    function new(input string name);
      super.new(name);
      this.enabled = 0;

      this.do_mode = CYCLIC;
      this.path_type = RX;
      this.transfer_size = 0;

      reading_lock = new(1);
    endfunction /* new */

    // connect the analysis ports of the monitor to the scoreboard
    function void set_ports(
      xil_analysis_port #(axi4stream_monitor_transaction)  src_axis_ap,
      xil_analysis_port #(axi4stream_monitor_transaction)  dst_axis_ap);
      this.src_axis_ap = src_axis_ap;
      this.dst_axis_ap = dst_axis_ap;
    endfunction /* set_ports */

    // run task
    task run();
      if (this.path_type == TX) begin
        fork
          this.enabled = 1;
          get_src_transaction();
          get_dst_transaction();
        join_none
      end
    endtask /* run */

    function void set_oneshot(input bit do_mode);
      if (!this.enabled) begin
        this.do_mode = do_mode_t'(do_mode);
      end else begin
        `FATAL(("ERROR Scoreboard: Can not configure oneshot mode while scoreboard is running."));
      end
    endfunction

    function void set_path_type(input bit path_type);
      if (!this.enabled) begin
        this.path_type = path_type_t'(path_type);
      end else begin
        `FATAL(("ERROR Scoreboard: Can not configure path type while scoreboard is running!"));
      end
    endfunction

    function bit get_oneshot();
      return this.do_mode;
    endfunction

    function bit get_path_type();
      return this.path_type;
    endfunction

    task get_src_transaction();

      axi4stream_transaction transaction;
      xil_axi4stream_data_beat data_beat;
      int num_bytes;

      forever begin
        if (this.src_axis_ap.get_item_cnt() > 0) begin
          `INFO(("Caught a TX AXI4 stream transaction: %d", this.src_axis_ap.get_item_cnt()), ADI_VERBOSITY_LOW);
          this.src_axis_ap.get(transaction);
          // all bytes from a beat are valid
          num_bytes = transaction.get_data_width()/8;
          data_beat = transaction.get_data_beat();

          reading_lock.get();

          if (reading == 1 && this.do_mode == CYCLIC)
            this.byte_stream.delete();

          reading = 0;
          reading_lock.put();

          for (int j=0; j<num_bytes; j++) begin
            this.byte_stream.push_back(data_beat[j*8+:8]);
          end

          if (transaction.get_last())
            this.transfer_size = 0;
          else
            this.transfer_size++;
        end
        #1step;
      end

    endtask /* get_tx_sink_transaction */

    // collect data from the AXI4Strean interface of the ADC stub
    task get_dst_transaction();

      axi4stream_transaction transaction;
      xil_axi4stream_data_beat data_beat;
      int num_bytes;

      logic [7:0] queue_byte;

      forever begin
        if (this.dst_axis_ap.get_item_cnt() > 0) begin
          `INFO(("Caught a RX AXI4 stream transaction: %d", this.dst_axis_ap.get_item_cnt()), ADI_VERBOSITY_LOW);
          this.dst_axis_ap.get(transaction);
          // all bytes from a beat are valid
          num_bytes = transaction.get_data_width()/8;
          data_beat = transaction.get_data_beat();

          reading_lock.get();
          reading = 1;
          reading_lock.put();

          if (this.byte_stream.size() == 0) begin
            `FATAL(("ERROR: Received unexpected transfer - is the data_offload running cyclically?"));
            continue;
          end

          for (int j=0; j<num_bytes; j++) begin
            queue_byte = this.byte_stream.pop_front();
            if (this.do_mode == CYCLIC)
              this.byte_stream.push_back(queue_byte);

            if (queue_byte !== data_beat[j*8+:8]) begin
              `ERROR(("ERROR: Failed rx stream comparison! tx != rx: %d != %d", queue_byte, data_beat[j*8+:8]));
            end;
          end
        end
        #1step;
      end

    endtask /* get_rx_source_transaction */

    function void post_test();
      if (this.enabled == 0) begin
        `INFO(("Scoreboard was inactive."), ADI_VERBOSITY_LOW);
      end else begin
          if (this.do_mode == ONESHOT && this.byte_stream.size() > 0) begin
            `FATAL(("ERROR: Not all samples have arrived yet!"));
          end else begin
            `INFO(("Scoreboard passed!"), ADI_VERBOSITY_LOW);
          end
      end
    endfunction /* post_tx_test */

  endclass

endpackage
