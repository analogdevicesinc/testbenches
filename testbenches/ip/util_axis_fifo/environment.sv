// ***************************************************************************
// ***************************************************************************
// Copyright (C) 2025 Analog Devices, Inc. All rights reserved.
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
  import scoreboard_pkg::*;
  import adi_axis_transaction_pkg::*;

  class util_axis_fifo_environment #(`AXIS_VIP_PARAM_DECL(input_axis), `AXIS_VIP_PARAM_DECL(output_axis), int INPUT_CLK, int OUTPUT_CLK) extends adi_environment;

    virtual interface clk_vip_if #(.C_CLK_CLOCK_PERIOD(INPUT_CLK)) input_clk_vip_if;
    virtual interface clk_vip_if #(.C_CLK_CLOCK_PERIOD(OUTPUT_CLK)) output_clk_vip_if;

    adi_axis_master_agent #(`AXIS_VIP_PARAM_ORDER(input_axis)) input_axis_agent;
    adi_axis_slave_agent #(`AXIS_VIP_PARAM_ORDER(output_axis)) output_axis_agent;

    scoreboard #(adi_axis_transaction) scoreboard_inst;

    //============================================================================
    // Constructor
    //============================================================================
    function new (
      input string name,

      virtual interface clk_vip_if #(.C_CLK_CLOCK_PERIOD(INPUT_CLK)) input_clk_vip_if,
      virtual interface clk_vip_if #(.C_CLK_CLOCK_PERIOD(OUTPUT_CLK)) output_clk_vip_if,

      virtual interface axi4stream_vip_if #(`AXIS_VIP_IF_PARAMS(input_axis)) input_axis_vip_if,
      virtual interface axi4stream_vip_if #(`AXIS_VIP_IF_PARAMS(output_axis)) output_axis_vip_if);

      // creating the agents
      super.new(name);

      this.input_clk_vip_if = input_clk_vip_if;
      this.output_clk_vip_if = output_clk_vip_if;

      this.input_axis_agent = new("Input AXI Stream Agent", input_axis_vip_if, this);
      this.output_axis_agent = new("Output AXI Stream Agent", output_axis_vip_if, this);

      this.scoreboard_inst = new("Util AXIS FIFO Scoreboard", this);
    endfunction

    //============================================================================
    // Configure environment
    //============================================================================
    task configure();
      int policy_randomizer;

      // configure input

      // stop policy
      policy_randomizer = $urandom_range(1, 5);
      case (policy_randomizer)
        'd1: this.input_axis_agent.master_sequencer.set_stop_policy(.stop_policy(STOP_POLICY_TRANSACTION));
        'd2: this.input_axis_agent.master_sequencer.set_stop_policy(.stop_policy(STOP_POLICY_PACKET));
        'd3: this.input_axis_agent.master_sequencer.set_stop_policy(.stop_policy(STOP_POLICY_FRAME));
        'd4: this.input_axis_agent.master_sequencer.set_stop_policy(.stop_policy(STOP_POLICY_SEQUENCE));
        'd5: this.input_axis_agent.master_sequencer.set_stop_policy(.stop_policy(STOP_POLICY_QUEUE));
      endcase

      // delays
      this.input_axis_agent.master_sequencer.set_transaction_delay(.transaction_delay($urandom_range(0, 10)));
      this.input_axis_agent.master_sequencer.set_packet_delay(.packet_delay($urandom_range(0, 10)));
      this.input_axis_agent.master_sequencer.set_frame_delay(.frame_delay($urandom_range(0, 10)));
      this.input_axis_agent.master_sequencer.set_sequence_delay(.sequence_delay($urandom_range(0, 10)));

      // miscellaneous
      this.input_axis_agent.master_sequencer.set_repeat_transaction_mode(.repeat_transaction_mode(1));
      this.input_axis_agent.master_sequencer.set_inactive_drive_output_0();

      // configure output

      // ready generation policy
      policy_randomizer = $urandom_range(1, 8);
      case (policy_randomizer)
        'd1: this.output_axis_agent.slave_sequencer.set_mode(.mode(XIL_AXI4STREAM_READY_GEN_NO_BACKPRESSURE));
        'd2: this.output_axis_agent.slave_sequencer.set_mode(.mode(XIL_AXI4STREAM_READY_GEN_SINGLE));
        'd3: this.output_axis_agent.slave_sequencer.set_mode(.mode(XIL_AXI4STREAM_READY_GEN_EVENTS));
        'd4: this.output_axis_agent.slave_sequencer.set_mode(.mode(XIL_AXI4STREAM_READY_GEN_OSC));
        'd5: this.output_axis_agent.slave_sequencer.set_mode(.mode(XIL_AXI4STREAM_READY_GEN_RANDOM));
        'd6: this.output_axis_agent.slave_sequencer.set_mode(.mode(XIL_AXI4STREAM_READY_GEN_AFTER_VALID_SINGLE));
        'd7: this.output_axis_agent.slave_sequencer.set_mode(.mode(XIL_AXI4STREAM_READY_GEN_AFTER_VALID_EVENTS));
        'd8: this.output_axis_agent.slave_sequencer.set_mode(.mode(XIL_AXI4STREAM_READY_GEN_AFTER_VALID_OSC));
      endcase

      // random high/low times
      if ($urandom_range(0, 1)) begin
        this.output_axis_agent.slave_sequencer.set_use_variable_ranges();
      end else begin
        this.output_axis_agent.slave_sequencer.clr_use_variable_ranges();
      end

      // high times
      this.output_axis_agent.slave_sequencer.set_high_time(.high_time($urandom_range(1, 10)));
      this.output_axis_agent.slave_sequencer.set_high_time_range(
        .high_time_min($urandom_range(1, 5)),
        .high_time_max($urandom_range(5, 10)));

      // low times
      this.output_axis_agent.slave_sequencer.set_low_time(.low_time($urandom_range(1, 10)));
      this.output_axis_agent.slave_sequencer.set_low_time_range(
        .low_time_min($urandom_range(1, 5)),
        .low_time_max($urandom_range(5, 10)));

      // event counts
      this.output_axis_agent.slave_sequencer.set_event_count(.event_count($urandom_range(1, 10)));
      this.output_axis_agent.slave_sequencer.set_event_count_range(
        .event_count_min($urandom_range(1, 5)),
        .event_count_max($urandom_range(5, 10)));
    endtask

    //============================================================================
    // Start environment
    //   - Connect all the agents to the scoreboard
    //   - Start the agents
    //============================================================================
    task start();
      this.input_clk_vip_if.start_clock();
      this.output_clk_vip_if.start_clock();

      this.input_axis_agent.start_master();
      this.output_axis_agent.start_slave();

      this.input_axis_agent.monitor.publisher.subscribe(this.scoreboard_inst.subscriber_source);
      this.output_axis_agent.monitor.publisher.subscribe(this.scoreboard_inst.subscriber_sink);
    endtask

    //============================================================================
    // Run subroutine
    //============================================================================
    task run();
      this.input_axis_agent.master_sequencer.start();
      this.output_axis_agent.slave_sequencer.start();
      fork
        this.scoreboard_inst.run();
      join_none
    endtask

    //============================================================================
    // Stop subroutine
    //============================================================================
    task stop();
      this.input_axis_agent.master_sequencer.wait_driver_idle();

      this.input_axis_agent.stop_master();
      this.output_axis_agent.stop_slave();

      this.input_clk_vip_if.stop_clock();
      this.output_clk_vip_if.stop_clock();
    endtask

  endclass

endpackage
