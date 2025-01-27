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
`include "axis_definitions.svh"

package environment_pkg;

  import logger_pkg::*;
  import adi_environment_pkg::*;

  import scoreboard_pkg::*;
  import axi4stream_vip_pkg::*;
  import m_axis_sequencer_pkg::*;
  import s_axis_sequencer_pkg::*;
  import adi_axis_agent_pkg::*;

  class dma_flock_environment #(`AXIS_VIP_PARAM_DECL(src_axis), `AXIS_VIP_PARAM_DECL(dst_axis)) extends adi_environment;

    // Agents
    adi_axis_master_agent #(`AXIS_VIP_PARAM_ORDER(src_axis)) src_axis_agent;
    adi_axis_slave_agent #(`AXIS_VIP_PARAM_ORDER(dst_axis)) dst_axis_agent;

    scoreboard scrb;

    //============================================================================
    // Constructor
    //============================================================================
    function new(
      input string name,

      virtual interface axi4stream_vip_if #(`AXIS_VIP_IF_PARAMS(src_axis)) src_axis_vip_if,
      virtual interface axi4stream_vip_if #(`AXIS_VIP_IF_PARAMS(dst_axis)) dst_axis_vip_if);

      super.new(name);

      // Creating the agents
      this.src_axis_agent = new("Src AXI stream agent", src_axis_vip_if, this);
      this.dst_axis_agent = new("Dest AXI stream agent", dst_axis_vip_if, this);

      this.scrb = new("Scoreboard", this);

    endfunction

    //============================================================================
    // Start environment
    //   - Connect all the agents to the scoreboard
    //   - Start the agents
    //============================================================================
    task start();
      this.scrb.connect(
        this.src_axis_agent.agent.monitor.item_collected_port,
        this.dst_axis_agent.agent.monitor.item_collected_port);

      this.src_axis_agent.agent.start_master();
      this.dst_axis_agent.agent.start_slave();
    endtask

    //============================================================================
    // Start the test
    //   - start the scoreboard
    //   - start the sequencers
    //============================================================================
    task test();
      this.src_axis_agent.sequencer.run();
      // DEST AXIS does not have to run, scoreboard connects and
      // gathers packets from the agent
      this.scrb.run();
    endtask

    //============================================================================
    // Post test subroutine
    //============================================================================
    task post_test();
      // wait until done
      this.scrb.shutdown();
    endtask

    //============================================================================
    // Run subroutine
    //============================================================================
    task run();
      test();
      post_test();
    endtask

    //============================================================================
    // Stop subroutine
    //============================================================================
    task stop();
      this.src_axis_agent.agent.stop_master();
      this.dst_axis_agent.agent.stop_slave();
    endtask

  endclass

endpackage
