// ***************************************************************************
// ***************************************************************************
// Copyright (C) 2014-2025 Analog Devices, Inc. All rights reserved.
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
`include "axi_definitions.svh"

package test_harness_env_pkg;

  import logger_pkg::*;
  import adi_environment_pkg::*;
  import adi_axi_agent_pkg::*;
  import watchdog_pkg::*;


  class test_harness_env #(int `AXI_VIP_PARAM_ORDER(mng), int `AXI_VIP_PARAM_ORDER(ddr)) extends adi_environment;

    // Agents
    adi_axi_master_agent #(`AXI_VIP_PARAM_ORDER(mng)) mng;
    adi_axi_slave_mem_agent #(`AXI_VIP_PARAM_ORDER(ddr)) ddr;

    virtual interface clk_vip_if #(.C_CLK_CLOCK_PERIOD(10)) sys_clk_vip_if;
    virtual interface clk_vip_if #(.C_CLK_CLOCK_PERIOD(5)) dma_clk_vip_if;
    virtual interface clk_vip_if #(.C_CLK_CLOCK_PERIOD(2.5)) ddr_clk_vip_if;

    virtual interface rst_vip_if #(.C_ASYNCHRONOUS(1), .C_RST_POLARITY(1)) sys_rst_vip_if;

    watchdog simulation_watchdog;

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

      this.simulation_watchdog = new("Simulation watchdog", 10**6, "Simulation might be hanging!");

      this.sys_clk_vip_if = sys_clk_vip_if;
      this.dma_clk_vip_if = dma_clk_vip_if;
      this.ddr_clk_vip_if = ddr_clk_vip_if;
      this.sys_rst_vip_if = sys_rst_vip_if;

      // Creating the agents
      this.mng = new("AXI Manager agent", mng_vip_if, this);
      this.ddr = new("AXI DDR stub agent", ddr_vip_if, this);
    endfunction

    //============================================================================
    // Start environment
    //   - Connect all the agents to the scoreboard
    //   - Start the agents
    //============================================================================
    task start();
      this.simulation_watchdog.start();

      this.mng.agent.start_master();
      this.ddr.agent.start_slave();

      this.sys_clk_vip_if.start_clock();
      this.dma_clk_vip_if.start_clock();
      this.ddr_clk_vip_if.start_clock();
    endtask

    //============================================================================
    // Stop subroutine
    //============================================================================
    task stop();
      this.mng.agent.stop_master();
      this.ddr.agent.stop_slave();

      this.sys_clk_vip_if.stop_clock();
      this.dma_clk_vip_if.stop_clock();
      this.ddr_clk_vip_if.stop_clock();

      this.simulation_watchdog.stop();
    endtask

    //============================================================================
    // System reset routine
    //============================================================================
    task sys_reset();
      //asserts all the resets for 100 ns
      this.sys_rst_vip_if.assert_reset();
      #200ns;
      this.sys_rst_vip_if.deassert_reset();
      #800ns;
    endtask

  endclass

endpackage
