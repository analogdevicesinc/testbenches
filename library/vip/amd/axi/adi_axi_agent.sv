// ***************************************************************************
// ***************************************************************************
// Copyright 2014 - 2018 (c) Analog Devices, Inc. All rights reserved.
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
//      https://github.com/analogdevicesinc/hdl/blob/master/LICENSE_ADIBSD
//      This will allow to generate bit files and not release the source code,
//      as long as it attaches to an ADI device.
//
// ***************************************************************************
// ***************************************************************************

`include "utils.svh"
`include "axi_definitions.svh"

package adi_axi_agent_pkg;

  import logger_pkg::*;
  import adi_common_pkg::*;
  import axi_vip_pkg::*;
  import m_axi_sequencer_pkg::*;
  import s_axi_sequencer_pkg::*;
  import adi_axi_monitor_pkg::*;


  class adi_axi_master_agent #(int `AXI_VIP_PARAM_ORDER(master)) extends adi_agent;

    axi_mst_agent #(`AXI_VIP_PARAM_ORDER(master)) agent;
    m_axi_sequencer #(`AXI_VIP_PARAM_ORDER(master)) sequencer;
    adi_axi_monitor #(`AXI_VIP_PARAM_ORDER(master)) monitor;

    function new(
      input string name,
      virtual interface axi_vip_if #(`AXI_VIP_IF_PARAMS(master)) master_vip_if,
      input adi_environment parent = null);

      super.new(name, parent);

      this.agent = new("Agent", master_vip_if);
      this.sequencer = new("Sequencer", this.agent.wr_driver, this.agent.rd_driver, this);
      this.monitor = new("Monitor TX", this.agent.monitor, this);
    endfunction: new

    task start();
      this.agent.start_master();
    endtask: start

    task run();
      this.monitor.run();
    endtask: run

    task stop();
      this.monitor.stop();
      this.agent.stop_master();
    endtask: stop

  endclass: adi_axi_master_agent


  class adi_axi_slave_mem_agent #(int `AXI_VIP_PARAM_ORDER(slave)) extends adi_agent;

    axi_slv_mem_agent #(`AXI_VIP_PARAM_ORDER(slave)) agent;
    s_axi_sequencer #(`AXI_VIP_PARAM_ORDER(slave)) sequencer;
    adi_axi_monitor #(`AXI_VIP_PARAM_ORDER(slave)) monitor;

    function new(
      input string name,
      virtual interface axi_vip_if #(`AXI_VIP_IF_PARAMS(slave)) slave_vip_if,
      input adi_environment parent = null);

      super.new(name, parent);

      this.agent = new("Agent", slave_vip_if);
      this.sequencer = new("Sequencer", this.agent.mem_model, this);
      this.monitor = new("Monitor TX", this.agent.monitor, this);
    endfunction: new

    task start();
      this.agent.start_slave();
    endtask: start

    task run();
      this.monitor.run();
    endtask: run

    task stop();
      this.monitor.stop();
      this.agent.stop_slave();
    endtask: stop

  endclass: adi_axi_slave_mem_agent


  class adi_axi_passthrough_mem_agent #(int `AXI_VIP_PARAM_ORDER(passthrough)) extends adi_agent;

    axi_passthrough_mem_agent #(`AXI_VIP_PARAM_ORDER(passthrough)) agent;
    m_axi_sequencer #(`AXI_VIP_PARAM_ORDER(passthrough)) master_sequencer;
    s_axi_sequencer #(`AXI_VIP_PARAM_ORDER(passthrough)) slave_sequencer;
    adi_axi_monitor #(`AXI_VIP_PARAM_ORDER(passthrough)) monitor;

    function new(
      input string name,
      virtual interface axi_vip_if #(`AXI_VIP_IF_PARAMS(passthrough)) passthrough_vip_if,
      input adi_environment parent = null);

      super.new(name, parent);

      this.agent = new("Agent", passthrough_vip_if);
      this.master_sequencer = new("Slave Sequencer", this.agent.mst_wr_driver, this.agent.mst_rd_driver, this);
      this.slave_sequencer = new("Slave Sequencer", this.agent.mem_model, this);
      this.monitor = new("Monitor TX", this.agent.monitor, this);
    endfunction: new

    task start();
      this.warning($sformatf("Start must called manually in the test program or environment"));
    endtask: start

    task run();
      this.monitor.run();
    endtask: run

    task stop();
      this.monitor.stop();
      this.agent.stop_slave();
      this.agent.stop_master();
    endtask: stop

  endclass: adi_axi_passthrough_mem_agent

endpackage
