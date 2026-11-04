// ***************************************************************************
// ***************************************************************************
// Copyright (C) 2021-2026 Analog Devices, Inc. All rights reserved.
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
  import io_vip_if_base_pkg::*;

  class environment #(`AXIS_VIP_PARAM_DECL(src_axis), `AXIS_VIP_PARAM_DECL(dst_axis)) extends adi_environment;

    // Agents
    adi_axis_master_agent #(`AXIS_VIP_PARAM_ORDER(src_axis)) src_axis_agent;
    adi_axis_slave_agent #(`AXIS_VIP_PARAM_ORDER(dst_axis)) dst_axis_agent;

    scoreboard #(logic [7:0]) scoreboard_data;

    // IO VIP control handles
    io_vip_if_base init_req_vip_if;
    io_vip_if_base sync_ext_vip_if;

    //============================================================================
    // Constructor
    //============================================================================
    function new (
      input string name,

      virtual interface axi4stream_vip_if #(`AXIS_VIP_IF_PARAMS(src_axis)) src_axis_vip_if,
      virtual interface axi4stream_vip_if #(`AXIS_VIP_IF_PARAMS(dst_axis)) dst_axis_vip_if,

      input io_vip_if_base init_req_vip_if,
      input io_vip_if_base sync_ext_vip_if);

      super.new(.name(name));

      // creating the agents
      this.src_axis_agent = new(.name("Source AXI Stream Agent"), .master_vip_if(src_axis_vip_if), .parent(this));
      this.dst_axis_agent = new(.name("Destination AXI Stream Agent"), .slave_vip_if(dst_axis_vip_if), .parent(this));

      this.scoreboard_data = new(.name("Data Offload Scoreboard"), .parent(this));

      this.init_req_vip_if = init_req_vip_if;
      this.sync_ext_vip_if = sync_ext_vip_if;
    endfunction

    //============================================================================
    // Configure environment
    //   - Configure the sequencer VIPs with an initial configuration
    //============================================================================
    task configure(
      input int transfer_length,
      input int transfer_count,
      input bit path_type,
      input xil_axi4stream_ready_gen_policy_t dst_ready_mode,
      input int dst_ready_high,
      input int dst_ready_low,
      input bit oneshot);

      // Source stub configuration
      this.src_axis_agent.master_sequencer.set_data_gen_mode(.data_gen_mode(DATA_GEN_MODE_AUTO_INCR));
      for (int i = 0; i < transfer_count; i++) begin
        this.src_axis_agent.master_sequencer.add_xfer_descriptor_byte_count(.bytes_to_generate(transfer_length), .gen_last(path_type), .gen_sync(0));
      end

      // Destination stub configuration
      this.dst_axis_agent.slave_sequencer.set_mode(.mode(dst_ready_mode));
      this.dst_axis_agent.slave_sequencer.set_high_time(.high_time(dst_ready_high));
      this.dst_axis_agent.slave_sequencer.set_low_time(.low_time(dst_ready_low));

      // Scoreboard configuration
      this.scoreboard_data.set_sink_type(.sink_type(oneshot));
    endtask

    //============================================================================
    // Start environment
    //   - Connect all the agents to the scoreboard
    //   - Start the agents
    //============================================================================
    task start();
      this.src_axis_agent.start_master();
      this.dst_axis_agent.start_slave();

      this.src_axis_agent.monitor.publisher.subscribe(.subscriber(this.scoreboard_data.subscriber_source));
      this.dst_axis_agent.monitor.publisher.subscribe(.subscriber(this.scoreboard_data.subscriber_sink));
    endtask

    //============================================================================
    // Run subroutine
    //============================================================================
    task run();
      fork
        this.scoreboard_data.run();
      join_none
    endtask

    //============================================================================
    // Stop subroutine
    //============================================================================
    task stop();
      this.src_axis_agent.stop_master();
      this.dst_axis_agent.stop_slave();
    endtask

  endclass

endpackage
