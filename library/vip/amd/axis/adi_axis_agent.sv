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

package adi_axis_agent_pkg;

  import logger_pkg::*;
  import adi_vip_pkg::*;
  import adi_environment_pkg::*;
  import axi4stream_vip_pkg::*;
  import m_axis_sequencer_pkg::*;
  import s_axis_sequencer_pkg::*;
  import adi_axis_monitor_pkg::*;


  class adi_axis_master_agent #(`AXIS_VIP_PARAM_DECL(master)) extends adi_agent;

    axi4stream_mst_agent #(`AXIS_VIP_IF_PARAMS(master)) agent;
    m_axis_sequencer #(`AXIS_VIP_PARAM_ORDER(master)) sequencer;
    adi_axis_monitor #(`AXIS_VIP_PARAM_ORDER(master)) monitor;

    function new(
      input string name,
      virtual interface axi4stream_vip_if #(`AXIS_VIP_IF_PARAMS(master)) master_vip_if,
      input adi_environment parent = null);

      super.new(name, parent);

      this.agent = new("Agent", master_vip_if);
      this.sequencer = new("Sequencer", this.agent.driver, this);
      this.monitor = new("Monitor", this.agent.monitor, this);
    endfunction: new

    task start();
      this.agent.start_master();
    endtask: start

    task run();
      this.sequencer.run();
      this.monitor.run();
    endtask: run

    task stop();
      this.monitor.stop();
      this.sequencer.stop();
      this.agent.stop_master();
    endtask: stop

  endclass: adi_axis_master_agent


  class adi_axis_slave_agent #(`AXIS_VIP_PARAM_DECL(slave)) extends adi_agent;

    axi4stream_slv_agent #(`AXIS_VIP_IF_PARAMS(slave)) agent;
    s_axis_sequencer #(`AXIS_VIP_PARAM_ORDER(slave)) sequencer;
    adi_axis_monitor #(`AXIS_VIP_PARAM_ORDER(slave)) monitor;

    function new(
      input string name,
      virtual interface axi4stream_vip_if #(`AXIS_VIP_IF_PARAMS(slave)) slave_vip_if,
      input adi_environment parent = null);

      super.new(name, parent);

      this.agent = new("Agent", slave_vip_if);
      this.sequencer = new("Sequencer", this.agent.driver, this);
      this.monitor = new("Monitor", this.agent.monitor, this);
    endfunction: new

    task start();
      this.agent.start_slave();
    endtask: start

    task run();
      this.sequencer.run();
      this.monitor.run();
    endtask: run

    task stop();
      this.monitor.stop();
      this.agent.stop_slave();
    endtask: stop

  endclass: adi_axis_slave_agent


  class adi_axis_passthrough_mem_agent #(`AXIS_VIP_PARAM_DECL(passthrough)) extends adi_agent;

    axi4stream_passthrough_agent #(`AXIS_VIP_IF_PARAMS(passthrough)) agent;
    m_axis_sequencer #(`AXIS_VIP_PARAM_ORDER(passthrough)) master_sequencer;
    s_axis_sequencer #(`AXIS_VIP_PARAM_ORDER(passthrough)) slave_sequencer;
    adi_axis_monitor #(`AXIS_VIP_PARAM_ORDER(passthrough)) monitor;

    function new(
      input string name,
      virtual interface axi4stream_vip_if #(`AXIS_VIP_IF_PARAMS(passthrough)) passthrough_vip_if,
      input adi_environment parent = null);

      super.new(name, parent);

      this.agent = new("Agent", passthrough_vip_if);
      this.master_sequencer = new("Master Sequencer", this.agent.mst_driver, this);
      this.slave_sequencer = new("Slave Sequencer", this.agent.slv_driver, this);
      this.monitor = new("Monitor", this.agent.monitor, this);
    endfunction: new

    task start();
      this.warning($sformatf("Start must called manually in the test program or environment"));
    endtask: start

    task run();
      this.master_sequencer.run();
      this.slave_sequencer.run();
      this.monitor.run();
    endtask: run

    task stop();
      this.monitor.stop();
      this.master_sequencer.stop();
      this.agent.stop_slave();
      this.agent.stop_master();
    endtask: stop

  endclass: adi_axis_passthrough_mem_agent

endpackage: adi_axis_agent_pkg
