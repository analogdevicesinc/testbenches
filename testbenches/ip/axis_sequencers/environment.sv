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
`include "axis_definitions.svh"

package environment_pkg;

  import logger_pkg::*;
  import adi_environment_pkg::*;
  import axi4stream_vip_pkg::*;
  import m_axis_sequencer_pkg::*;
  import s_axis_sequencer_pkg::*;
  import adi_axis_agent_pkg::*;

  class axis_sequencer_environment #(`AXIS_VIP_PARAM_DECL(src_axis), `AXIS_VIP_PARAM_DECL(dst_axis)) extends adi_environment;

    // Agents
    adi_axis_master_agent #(`AXIS_VIP_PARAM_ORDER(src_axis)) src_axis_agent;
    adi_axis_slave_agent #(`AXIS_VIP_PARAM_ORDER(dst_axis)) dst_axis_agent;

    //============================================================================
    // Constructor
    //============================================================================
    function new (
      input string name,

      virtual interface axi4stream_vip_if #(`AXIS_VIP_IF_PARAMS(src_axis)) src_axis_vip_if,
      virtual interface axi4stream_vip_if #(`AXIS_VIP_IF_PARAMS(dst_axis)) dst_axis_vip_if);

      // creating the agents
      super.new(name);

      this.src_axis_agent = new("Source AXI Stream Agent", src_axis_vip_if, this);
      this.dst_axis_agent = new("Destination AXI Stream Agent", dst_axis_vip_if, this);
    endfunction

    //============================================================================
    // Configure environment
    //   - Configure the sequencer VIPs with parameters from the configuration file
    //============================================================================
    task configure(
      // Source (Master) configuration
      input int src_stop_policy = 2,
      input int src_transaction_delay = 0,
      input int src_packet_delay = 0,
      input int src_frame_delay = 0,
      input int src_sequence_delay = 0,
      input bit src_repeat_mode = 0,
      input bit src_inactive_drive_0 = 0,
      // Destination (Slave) configuration
      input int dest_ready_mode = 1,
      input bit dest_use_variable_ranges = 0,
      input int dest_high_time = 1,
      input int dest_low_time = 1,
      input int dest_high_time_min = 1,
      input int dest_high_time_max = 5,
      input int dest_low_time_min = 1,
      input int dest_low_time_max = 5,
      input int dest_event_count = 1,
      input int dest_event_count_min = 1,
      input int dest_event_count_max = 5
    );

      //------------------------------------------------------------------------
      // Source (Master) Configuration
      //------------------------------------------------------------------------

      // Set source delays
      this.src_axis_agent.master_sequencer.set_transaction_delay(src_transaction_delay);
      this.src_axis_agent.master_sequencer.set_packet_delay(src_packet_delay);
      this.src_axis_agent.master_sequencer.set_frame_delay(src_frame_delay);
      this.src_axis_agent.master_sequencer.set_sequence_delay(src_sequence_delay);

      // Set repeat transaction mode
      this.src_axis_agent.master_sequencer.set_repeat_transaction_mode(src_repeat_mode);

      // Set inactive drive output to 0
      if (src_inactive_drive_0) begin
        this.src_axis_agent.master_sequencer.set_inactive_drive_output_0();
      end

      // Set source stop policy
      case (src_stop_policy)
        1: this.src_axis_agent.master_sequencer.set_stop_policy(STOP_POLICY_TRANSACTION);
        2: this.src_axis_agent.master_sequencer.set_stop_policy(STOP_POLICY_PACKET);
        3: this.src_axis_agent.master_sequencer.set_stop_policy(STOP_POLICY_FRAME);
        4: this.src_axis_agent.master_sequencer.set_stop_policy(STOP_POLICY_SEQUENCE);
        5: this.src_axis_agent.master_sequencer.set_stop_policy(STOP_POLICY_QUEUE);
        default: `FATAL(("Source stop policy parameter incorrect!"));
      endcase

      //------------------------------------------------------------------------
      // Destination (Slave) Configuration
      //------------------------------------------------------------------------

      // Set destination ready generation mode
      case (dest_ready_mode)
        1: this.dst_axis_agent.slave_sequencer.set_mode(XIL_AXI4STREAM_READY_GEN_NO_BACKPRESSURE);
        2: this.dst_axis_agent.slave_sequencer.set_mode(XIL_AXI4STREAM_READY_GEN_SINGLE);
        3: this.dst_axis_agent.slave_sequencer.set_mode(XIL_AXI4STREAM_READY_GEN_EVENTS);
        4: this.dst_axis_agent.slave_sequencer.set_mode(XIL_AXI4STREAM_READY_GEN_OSC);
        5: this.dst_axis_agent.slave_sequencer.set_mode(XIL_AXI4STREAM_READY_GEN_RANDOM);
        6: this.dst_axis_agent.slave_sequencer.set_mode(XIL_AXI4STREAM_READY_GEN_AFTER_VALID_SINGLE);
        7: this.dst_axis_agent.slave_sequencer.set_mode(XIL_AXI4STREAM_READY_GEN_AFTER_VALID_EVENTS);
        8: this.dst_axis_agent.slave_sequencer.set_mode(XIL_AXI4STREAM_READY_GEN_AFTER_VALID_OSC);
        default: `FATAL(("Destination ready mode parameter incorrect!"));
      endcase

      // Set variable ranges mode
      if (dest_use_variable_ranges) begin
        this.dst_axis_agent.slave_sequencer.set_use_variable_ranges();
      end else begin
        this.dst_axis_agent.slave_sequencer.clr_use_variable_ranges();
      end

      // Set high times
      this.dst_axis_agent.slave_sequencer.set_high_time(dest_high_time);
      this.dst_axis_agent.slave_sequencer.set_high_time_range(
        .high_time_min(dest_high_time_min),
        .high_time_max(dest_high_time_max));

      // Set low times
      this.dst_axis_agent.slave_sequencer.set_low_time(dest_low_time);
      this.dst_axis_agent.slave_sequencer.set_low_time_range(
        .low_time_min(dest_low_time_min),
        .low_time_max(dest_low_time_max));

      // Set event counts
      this.dst_axis_agent.slave_sequencer.set_event_count(dest_event_count);
      this.dst_axis_agent.slave_sequencer.set_event_count_range(
        .event_count_min(dest_event_count_min),
        .event_count_max(dest_event_count_max));

    endtask

    //============================================================================
    // Start environment
    //============================================================================
    task start();
      this.src_axis_agent.start_master();
      this.dst_axis_agent.start_slave();
    endtask

    //============================================================================
    // Stop subroutine
    //============================================================================
    task stop;
      this.src_axis_agent.stop_master();
      this.dst_axis_agent.stop_slave();
    endtask

  endclass

endpackage
