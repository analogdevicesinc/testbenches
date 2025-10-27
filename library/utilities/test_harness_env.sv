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
  import irq_handler_pkg::*;
  import io_vip_if_base_pkg::*;
  import vip_agent_typedef_pkg::*;

  class test_harness_env extends adi_environment;

    // Agents
    adi_axi_agent_base mng;
    adi_axi_agent_base ddr;

    irq_handler_class irq_handler;

    virtual interface clk_vip_if #(.C_CLK_CLOCK_PERIOD(10)) sys_clk_vip_if;
    virtual interface clk_vip_if #(.C_CLK_CLOCK_PERIOD(5)) dma_clk_vip_if;
    virtual interface clk_vip_if #(.C_CLK_CLOCK_PERIOD(2.5)) ddr_clk_vip_if;

    virtual interface rst_vip_if #(.C_ASYNCHRONOUS(1), .C_RST_POLARITY(1)) sys_rst_vip_if;

    watchdog simulation_watchdog;

    local bit [31:0] irq_base_address;
    local io_vip_if_base irq_vip_if;

    //============================================================================
    // Constructor
    //============================================================================
    function new(
      input string name,
      input virtual interface clk_vip_if #(.C_CLK_CLOCK_PERIOD(10)) sys_clk_vip_if,
      input virtual interface clk_vip_if #(.C_CLK_CLOCK_PERIOD(5)) dma_clk_vip_if,
      input virtual interface clk_vip_if #(.C_CLK_CLOCK_PERIOD(2.5)) ddr_clk_vip_if,
      input virtual interface rst_vip_if #(.C_ASYNCHRONOUS(1), .C_RST_POLARITY(1)) sys_rst_vip_if,
      input bit [31:0] irq_base_address,
      input io_vip_if_base irq_vip_if,
      input adi_environment parent = null);

      super.new(name, parent);

      this.simulation_watchdog = new("Simulation watchdog", 10**6, "Simulation might be hanging!");

      this.sys_clk_vip_if = sys_clk_vip_if;
      this.dma_clk_vip_if = dma_clk_vip_if;
      this.ddr_clk_vip_if = ddr_clk_vip_if;
      this.sys_rst_vip_if = sys_rst_vip_if;

      this.irq_base_address = irq_base_address;
      this.irq_vip_if = irq_vip_if;

      // Creating the agents
      this.mng = new("AXI Manager agent", MASTER, this);
      this.ddr = new("AXI DDR stub agent", SLAVE, this);
    endfunction

    //============================================================================
    // Start environment
    //   - Connect all the agents to the scoreboard
    //   - Start the agents
    //============================================================================
    task start();
      this.irq_handler = new("IRQ handler", this.mng.master_sequencer, this.irq_base_address, this.irq_vip_if, this);

      this.simulation_watchdog.start();

      this.sys_clk_vip_if.start_clock();
      this.dma_clk_vip_if.start_clock();
      this.ddr_clk_vip_if.start_clock();

      this.mng.start_master();
      this.ddr.start_slave();
    endtask

    //============================================================================
    // Stop subroutine
    //============================================================================
    task stop();
      this.mng.stop_master();
      this.ddr.stop_slave();

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
