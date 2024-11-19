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

package test_harness_env_pkg;

  import logger_pkg::*;
  import adi_common_pkg::*;
  import axi_vip_pkg::*;
  import axi4stream_vip_pkg::*;
  import m_axi_sequencer_pkg::*;
  import s_axi_sequencer_pkg::*;
  import x_monitor_pkg::*;


  class adi_axi_master_agent #(int `AXI_VIP_PARAM_ORDER(master)) extends adi_agent;

    axi_mst_agent #(`AXI_VIP_PARAM_ORDER(master)) agent;
    m_axi_sequencer #(`AXI_VIP_PARAM_ORDER(master)) sequencer;
    x_axi_monitor #(`AXI_VIP_PARAM_ORDER(master), WRITE_OP) monitor;

    function new(
      input string name,
      virtual interface axi_vip_if #(`AXI_VIP_IF_PARAMS(master)) master_vip_if,
      input adi_environment parent = null);

      super.new(name, parent);

      this.agent = new("Agent", master_vip_if);
      this.sequencer = new("Sequencer", this.agent, this);
      this.monitor = new("Monitor", this.agent.monitor, this);

      this.sequencer.info($sformatf("5 star"), ADI_VERBOSITY_NONE);
      this.monitor.info($sformatf("5 star"), ADI_VERBOSITY_NONE);
    endfunction: new

  endclass: adi_axi_master_agent


  class test_harness_env #(int `AXI_VIP_PARAM_ORDER(mng), int `AXI_VIP_PARAM_ORDER(ddr)) extends adi_environment;

    // Agents
    axi_mst_agent #(`AXI_VIP_PARAM_ORDER(mng)) mng_agent;
    axi_slv_mem_agent #(`AXI_VIP_PARAM_ORDER(ddr)) ddr_agent;

    adi_axi_master_agent #(`AXI_VIP_PARAM_ORDER(mng)) mng_prot;

    // Sequencers
    m_axi_sequencer #(`AXI_VIP_PARAM_ORDER(mng)) mng_seq;
    s_axi_sequencer #(`AXI_VIP_PARAM_ORDER(ddr)) ddr_seq;

    // Register accessors
    bit done = 0;

    virtual interface clk_vip_if #(.C_CLK_CLOCK_PERIOD(10)) sys_clk_vip_if;
    virtual interface clk_vip_if #(.C_CLK_CLOCK_PERIOD(5)) dma_clk_vip_if;
    virtual interface clk_vip_if #(.C_CLK_CLOCK_PERIOD(2.5)) ddr_clk_vip_if;

    virtual interface rst_vip_if #(.C_ASYNCHRONOUS(1), .C_RST_POLARITY(1)) sys_rst_vip_if;

    //============================================================================
    // Constructor
    //============================================================================
    function new(
      input string name,

      virtual interface clk_vip_if #(.C_CLK_CLOCK_PERIOD(10)) sys_clk_vip_if,
      virtual interface clk_vip_if #(.C_CLK_CLOCK_PERIOD(5)) dma_clk_vip_if,
      virtual interface clk_vip_if #(.C_CLK_CLOCK_PERIOD(2.5)) ddr_clk_vip_if,

      virtual interface rst_vip_if #(.C_ASYNCHRONOUS(1), .C_RST_POLARITY(1)) sys_rst_vip_if,

      virtual interface axi_vip_if #(`AXI_VIP_IF_PARAMS(mng)) mng_vip_if,
      virtual interface axi_vip_if #(`AXI_VIP_IF_PARAMS(ddr)) ddr_vip_if);

      super.new(name);

      this.sys_clk_vip_if = sys_clk_vip_if;
      this.dma_clk_vip_if = dma_clk_vip_if;
      this.ddr_clk_vip_if = ddr_clk_vip_if;
      this.sys_rst_vip_if = sys_rst_vip_if;

      mng_prot = new("AXI Manager agent", mng_vip_if, this);

      // Creating the agents
      mng_agent = new("AXI Manager agent", mng_vip_if);
      ddr_agent = new("AXI DDR stub agent", ddr_vip_if);

      // Creating the sequencers
      mng_seq = new("AXI Manager sequencer", mng_agent, this);
      ddr_seq = new("AXI DDR stub sequencer", ddr_agent, this);

    endfunction

    //============================================================================
    // Start environment
    //   - Connect all the agents to the scoreboard
    //   - Start the agents
    //============================================================================
    task start();
      mng_agent.start_master();
      ddr_agent.start_slave();

      sys_clk_vip_if.start_clock;
      dma_clk_vip_if.start_clock;
      ddr_clk_vip_if.start_clock;
    endtask

    //============================================================================
    // Stop subroutine
    //============================================================================
    task stop();
      mng_agent.stop_master();
      ddr_agent.stop_slave();

      sys_clk_vip_if.stop_clock;
      dma_clk_vip_if.stop_clock;
      ddr_clk_vip_if.stop_clock;
    endtask

    //============================================================================
    // System reset routine
    //============================================================================
    task sys_reset();
      //asserts all the resets for 100 ns
      sys_rst_vip_if.assert_reset;
      #200;
      sys_rst_vip_if.deassert_reset;
      #800;
    endtask

  endclass

endpackage
