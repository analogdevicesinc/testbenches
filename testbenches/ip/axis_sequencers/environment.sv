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
    //   - Configure the sequencer VIPs with an initial configuration before starting them
    //============================================================================
    task configure();
      xil_axi4stream_ready_gen_policy_t dac_mode;

      // source stub
      this.src_axis_agent.sequencer.set_stop_policy(STOP_POLICY_PACKET);

      // destination stub
      dac_mode = XIL_AXI4STREAM_READY_GEN_NO_BACKPRESSURE;
      this.dst_axis_agent.sequencer.set_mode(dac_mode);
    endtask

    //============================================================================
    // Start environment
    //============================================================================
    task start();
      this.src_axis_agent.agent.start_master();
      this.dst_axis_agent.agent.start_slave();
    endtask

    //============================================================================
    // Run subroutine
    //============================================================================
    task run;
      fork
        this.src_axis_agent.sequencer.run();
        this.dst_axis_agent.sequencer.run();
      join_none
    endtask

    //============================================================================
    // Stop subroutine
    //============================================================================
    task stop;
      this.src_axis_agent.sequencer.stop();
      this.src_axis_agent.agent.stop_master();
      this.dst_axis_agent.agent.stop_slave();
    endtask

  endclass

endpackage
