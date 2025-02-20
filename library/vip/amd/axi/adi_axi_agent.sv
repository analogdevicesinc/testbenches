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
`include "axi_definitions.svh"

package adi_axi_agent_pkg;

  import logger_pkg::*;
  import adi_vip_pkg::*;
  import adi_environment_pkg::*;
  import axi_vip_pkg::*;
  import m_axi_sequencer_pkg::*;
  import s_axi_sequencer_pkg::*;
  import adi_axi_monitor_pkg::*;

  typedef enum {MASTER, SLAVE, PASSTHROUGH} axi_agent_typedef;
  
  class adi_axi_agent_base extends adi_agent;

    m_axi_sequencer_base master_sequencer;
    s_axi_sequencer_base slave_sequencer;
    adi_axi_monitor_base monitor;

    local axi_agent_typedef agent_type;

    function new(
      input string name,
      input axi_agent_typedef agent_type,
      input adi_environment parent = null);

      super.new(name, parent);

      this.agent_type = agent_type;
    endfunction: new

    virtual task start_master();
      if (agent_type == SLAVE) begin
        this.fatal($sformatf("Agent is in slave mode!"));
      end
    endtask: start_master
    
    virtual task start_slave();
      if (agent_type == MASTER) begin
        this.fatal($sformatf("Agent is in master mode!"));
      end
    endtask: start_slave
    
    virtual task start_monitor();
      if (agent_type != PASSTHROUGH) begin
        this.fatal($sformatf("Agent is not in passthrough mode!"));
      end
    endtask: start_monitor
    
    virtual task stop_master();
      if (agent_type == SLAVE) begin
        this.fatal($sformatf("Agent is in slave mode!"));
      end
    endtask: stop_master

    virtual task stop_slave();
      if (agent_type == MASTER) begin
        this.fatal($sformatf("Agent is in master mode!"));
      end
    endtask: stop_slave

    virtual task stop_monitor();
      if (agent_type != PASSTHROUGH) begin
        this.fatal($sformatf("Agent is not in passthrough mode!"));
      end
    endtask: stop_monitor
    
  endclass: adi_axi_agent_base


  class adi_axi_master_agent #(int `AXI_VIP_PARAM_ORDER(master)) extends adi_axi_agent_base;

    axi_mst_agent #(`AXI_VIP_PARAM_ORDER(master)) agent;
    m_axi_sequencer #(`AXI_VIP_PARAM_ORDER(master)) master_sequencer;
    adi_axi_monitor #(`AXI_VIP_PARAM_ORDER(master)) monitor;

    function new(
      input string name,
      virtual interface axi_vip_if #(`AXI_VIP_IF_PARAMS(master)) master_vip_if,
      input adi_environment parent = null);

      super.new(name, MASTER, parent);

      this.agent = new("Agent", master_vip_if);
      this.master_sequencer = new("Master Sequencer", this.agent.wr_driver, this.agent.rd_driver, this);
      this.monitor = new("Monitor TX", this.agent.monitor, this);
    endfunction: new

    function void pre_link_agent(adi_axi_agent_base adi_axi_agent);
      this.name = adi_axi_agent.name;
      this.parent = adi_axi_agent.parent;
    endfunction: pre_link_agent

    function void post_link_agent(adi_axi_agent_base adi_axi_agent);
      adi_axi_agent.master_sequencer = this.master_sequencer;
      adi_axi_agent.monitor = this.monitor;
    endfunction: post_link_agent

    virtual task start_master();
      super.start_master();
      this.agent.start_master();
      this.monitor.start();
    endtask: start_master

    virtual task stop_master();
      super.stop_master();
      this.agent.stop_master();
      this.monitor.stop();
    endtask: stop_master

  endclass: adi_axi_master_agent


  class adi_axi_slave_mem_agent #(int `AXI_VIP_PARAM_ORDER(slave)) extends adi_axi_agent_base;

    axi_slv_mem_agent #(`AXI_VIP_PARAM_ORDER(slave)) agent;
    s_axi_sequencer #(`AXI_VIP_PARAM_ORDER(slave)) slave_sequencer;
    adi_axi_monitor #(`AXI_VIP_PARAM_ORDER(slave)) monitor;

    function new(
      input string name,
      virtual interface axi_vip_if #(`AXI_VIP_IF_PARAMS(slave)) slave_vip_if,
      input adi_environment parent = null);

      super.new(name, SLAVE, parent);

      this.agent = new("Agent", slave_vip_if);
      this.slave_sequencer = new("Slave Sequencer", this.agent.mem_model, this);
      this.monitor = new("Monitor TX", this.agent.monitor, this);
    endfunction: new

    function void pre_link_agent(adi_axi_agent_base adi_axi_agent);
      this.name = adi_axi_agent.name;
      this.parent = adi_axi_agent.parent;
    endfunction: pre_link_agent

    function void post_link_agent(adi_axi_agent_base adi_axi_agent);
      adi_axi_agent.slave_sequencer = this.slave_sequencer;
      adi_axi_agent.monitor = this.monitor;
    endfunction: post_link_agent

    virtual task start_slave();
      super.start_slave();
      this.agent.start_slave();
      this.monitor.start();
    endtask: start_slave

    virtual task stop_slave();
      super.stop_slave();
      this.agent.stop_slave();
      this.monitor.stop();
    endtask: stop_slave

  endclass: adi_axi_slave_mem_agent


  class adi_axi_passthrough_mem_agent #(int `AXI_VIP_PARAM_ORDER(passthrough)) extends adi_axi_agent_base;

    axi_passthrough_mem_agent #(`AXI_VIP_PARAM_ORDER(passthrough)) agent;
    m_axi_sequencer #(`AXI_VIP_PARAM_ORDER(passthrough)) master_sequencer;
    s_axi_sequencer #(`AXI_VIP_PARAM_ORDER(passthrough)) slave_sequencer;
    adi_axi_monitor #(`AXI_VIP_PARAM_ORDER(passthrough)) monitor;

    function new(
      input string name,
      virtual interface axi_vip_if #(`AXI_VIP_IF_PARAMS(passthrough)) passthrough_vip_if,
      input adi_environment parent = null);

      super.new(name, PASSTHROUGH, parent);

      this.agent = new("Agent", passthrough_vip_if);
      this.master_sequencer = new("Master Sequencer", this.agent.mst_wr_driver, this.agent.mst_rd_driver, this);
      this.slave_sequencer = new("Slave Sequencer", this.agent.mem_model, this);
      this.monitor = new("Monitor TX", this.agent.monitor, this);
    endfunction: new

    function void pre_link_agent(adi_axi_agent_base adi_axi_agent);
      this.name = adi_axi_agent.name;
      this.parent = adi_axi_agent.parent;
    endfunction: pre_link_agent

    function void post_link_agent(adi_axi_agent_base adi_axi_agent);
      adi_axi_agent.master_sequencer = this.master_sequencer;
      adi_axi_agent.slave_sequencer = this.slave_sequencer;
      adi_axi_agent.monitor = this.monitor;
    endfunction: post_link_agent

    virtual task start_master();
      super.start_master();
      this.agent.start_master();
      this.monitor.start();
    endtask: start_master

    virtual task start_slave();
      super.start_slave();
      this.agent.start_slave();
      this.monitor.start();
    endtask: start_slave

    virtual task start_monitor();
      super.start_monitor();
      this.agent.start_monitor();
      this.monitor.start();
    endtask: start_monitor

    virtual task stop_master();
      super.stop_master();
      this.agent.stop_master();
      this.monitor.stop();
    endtask: stop_master

    virtual task stop_slave();
      super.stop_slave();
      this.agent.stop_slave();
      this.monitor.stop();
    endtask: stop_slave

    virtual task stop_monitor();
      super.stop_monitor();
      this.agent.stop_monitor();
      this.monitor.stop();
    endtask: stop_monitor

  endclass: adi_axi_passthrough_mem_agent

endpackage: adi_axi_agent_pkg
