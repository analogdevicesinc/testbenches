// ***************************************************************************
// ***************************************************************************
// Copyright (C) 2026 Analog Devices, Inc. All rights reserved.
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

package adi_avmm_agent_pkg;

  import logger_pkg::*;
  import adi_vip_pkg::*;
  import adi_environment_pkg::*;
  import adi_avmm_bfm_if_base_pkg::*;
  import m_axi_sequencer_pkg::*;
  import s_avmm_sequencer_pkg::*;
  import vip_agent_typedef_pkg::*;

  class adi_avmm_agent_base extends adi_agent;

    m_axi_sequencer_base master_sequencer;
    s_avmm_sequencer_base slave_sequencer;

    local agent_typedef agent_type;

    function new(
      input string name,
      input agent_typedef agent_type,
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

  endclass: adi_avmm_agent_base


  class adi_avmm_master_agent extends adi_avmm_agent_base;

    m_avmm_sequencer master_sequencer;

    function new(
      input string name,
      input adi_avmm_master_bfm_if_base master_bfm_if,
      input adi_environment parent = null);

      super.new(name, MASTER, parent);

      this.master_sequencer = new("Master Sequencer", master_bfm_if, this);
    endfunction: new

    function void pre_link_agent(adi_avmm_agent_base adi_avmm_agent);
      this.name = adi_avmm_agent.name;
      this.parent = adi_avmm_agent.parent;
    endfunction: pre_link_agent

    function void post_link_agent(adi_avmm_agent_base adi_avmm_agent);
      adi_avmm_agent.master_sequencer = this.master_sequencer;
    endfunction: post_link_agent

  endclass: adi_avmm_master_agent


  class adi_avmm_slave_mem_agent extends adi_avmm_agent_base;

    s_avmm_sequencer slave_sequencer;

    protected adi_avmm_slave_bfm_if_base slave_bfm_if;

    function new(
      input string name,
      input adi_avmm_slave_bfm_if_base slave_bfm_if,
      input adi_environment parent = null);

      super.new(name, SLAVE, parent);

      this.slave_bfm_if = slave_bfm_if;
      this.slave_sequencer = new("Slave Sequencer", slave_bfm_if, this);
    endfunction: new

    function void pre_link_agent(adi_avmm_agent_base adi_avmm_agent);
      this.name = adi_avmm_agent.name;
      this.parent = adi_avmm_agent.parent;
    endfunction: pre_link_agent

    function void post_link_agent(adi_avmm_agent_base adi_avmm_agent);
      adi_avmm_agent.slave_sequencer = this.slave_sequencer;
    endfunction: post_link_agent

    virtual task start_slave();
      super.start_slave();
      this.slave_bfm_if.start();
    endtask: start_slave

    virtual task stop_slave();
      super.stop_slave();
      this.slave_bfm_if.stop();
    endtask: stop_slave

  endclass: adi_avmm_slave_mem_agent

endpackage: adi_avmm_agent_pkg
