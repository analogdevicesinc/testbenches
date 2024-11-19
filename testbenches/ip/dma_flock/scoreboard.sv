// ***************************************************************************
// ***************************************************************************
// Copyright 2024 (c) Analog Devices, Inc. All rights reserved.
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

  import xil_common_vip_pkg::*;
  import axi4stream_vip_pkg::*;
  import axi_vip_pkg::*;
  import logger_pkg::*;

  class scoreboard;
    // List of analysis ports from the monitors
    xil_analysis_port #(axi4stream_monitor_transaction) src_axis_ap;
    xil_analysis_port #(axi4stream_monitor_transaction) dst_axis_ap;

    protected event shutdown_event;

    function new();
    endfunction: new

    function void connect(
      xil_analysis_port #(axi4stream_monitor_transaction) src_axis_ap,
      xil_analysis_port #(axi4stream_monitor_transaction) dst_axis_ap);

      this.src_axis_ap = src_axis_ap;
      this.dst_axis_ap = dst_axis_ap;
    endfunction: connect

    task run();
      fork begin
        fork
          run_src();
          run_dst();
        join_none
        @shutdown_event;
        disable fork;
      end join_none
    endtask: run

    task run_src();
    endtask : run_src

    task run_dst();
      axi4stream_monitor_transaction dst_axis_trans;
      xil_axi4stream_data_beat  data_beat;
      int num_bytes;
      xil_axi4stream_data_byte expected_byte;
      xil_axi4stream_data_byte received_byte;
      bit received_tuser;
      bit received_tlast;
      int frame_count,prev_frame_count = 0;

      forever begin
        dst_axis_ap.get(dst_axis_trans);
        // get TDATA
        // Assumption is that all bytes from beat are valid
        data_beat = dst_axis_trans.get_data_beat();
        num_bytes = dst_axis_trans.get_data_width()/8;
        // Get TUSER[0]
        received_tuser = dst_axis_trans.get_user_beat();
        // Get TLAST
        received_tlast = dst_axis_trans.get_last();
        // TUSER marks the start of frame; set the current frame number based
        // on first beat first pixel
        if (received_tuser == 1) begin
          frame_count = data_beat[7:0];
          if (frame_count < prev_frame_count)
            `ERROR(("Frame count out of order. Expected at least: 0x%h ; Found : 0x%h", prev_frame_count, frame_count));
          else
            `INFO(("Received frame 0x%0h ", frame_count));
          prev_frame_count = frame_count;
        end
        // Compare data against the frame counter; all pixels from frame
        // should match the frame counter.
        for (int i = 0; i < num_bytes; i++) begin
          expected_byte = frame_count;
          received_byte = data_beat[i*8+:8];
          if (expected_byte !== received_byte)
            `ERROR(("Data mismatch. Expected : 0x%h ; Found : 0x%h", expected_byte, received_byte));
          else
            `INFOV(("Received byte 0x%h ", received_byte), 99);
        end
      end
    endtask : run_dst
    task shutdown;
      -> shutdown_event;
    endtask: shutdown

  endclass: scoreboard

endpackage
