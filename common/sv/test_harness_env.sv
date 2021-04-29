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

  import axi_vip_pkg::*;
  import axi4stream_vip_pkg::*;
  import m_axi_sequencer_pkg::*;
  import s_axi_sequencer_pkg::*;
  import `PKGIFY(test_harness, mng_axi_vip)::*;
  import `PKGIFY(test_harness, ddr_axi_vip)::*;

  class test_harness_env;

    // Agents
    `AGENT(test_harness, mng_axi_vip, mst_t) mng_agent;
    `AGENT(test_harness, ddr_axi_vip, slv_mem_t) ddr_axi_agent;
    // Sequencers
    m_axi_sequencer #(`AGENT(test_harness, mng_axi_vip, mst_t)) mng;
    s_axi_sequencer #(`AGENT(test_harness, ddr_axi_vip, slv_mem_t)) ddr_axi_seq;

    // Register accessors
    bit done = 0;

    virtual interface clk_vip_if #(.C_CLK_CLOCK_PERIOD(10)) sys_clk_vip_if;
    virtual interface clk_vip_if #(.C_CLK_CLOCK_PERIOD(5)) dma_clk_vip_if;
    virtual interface clk_vip_if #(.C_CLK_CLOCK_PERIOD(2.5)) ddr_clk_vip_if;

    //============================================================================
    // Constructor
    //============================================================================
    function new(
      virtual interface clk_vip_if #(.C_CLK_CLOCK_PERIOD(10)) sys_clk_vip_if,
      virtual interface clk_vip_if #(.C_CLK_CLOCK_PERIOD(5)) dma_clk_vip_if,
      virtual interface clk_vip_if #(.C_CLK_CLOCK_PERIOD(2.5)) ddr_clk_vip_if,
      virtual interface axi_vip_if #(`AXI_VIP_IF_PARAMS(test_harness, mng_axi_vip)) mng_vip_if,
      virtual interface axi_vip_if #(`AXI_VIP_IF_PARAMS(test_harness, ddr_axi_vip)) ddr_vip_if
    );

      this.sys_clk_vip_if = sys_clk_vip_if;
      this.dma_clk_vip_if = dma_clk_vip_if;
      this.ddr_clk_vip_if = ddr_clk_vip_if;

      // Creating the agents
      mng_agent = new("AXI Manager agent", mng_vip_if);
      ddr_axi_agent = new("AXI DDR stub agent", ddr_vip_if);

      // Creating the sequencers
      mng = new(mng_agent);
      ddr_axi_seq = new(ddr_axi_agent);

    endfunction

    //============================================================================
    // Start environment
    //   - Connect all the agents to the scoreboard
    //   - Start the agents
    //============================================================================
    task start();
      mng_agent.start_master();
      ddr_axi_agent.start_slave();

      sys_clk_vip_if.start_clock;
      dma_clk_vip_if.start_clock;
      ddr_clk_vip_if.start_clock;
    endtask

    //============================================================================
    // Start the test
    //   - start the scoreboard
    //   - start the sequencers
    //============================================================================
    task test();
      fork

      join_none
    endtask

    //============================================================================
    // Post test subroutine
    //============================================================================
    task post_test();
      // wait until done
      wait_done();
    endtask

    //============================================================================
    // Run subroutine
    //============================================================================
    task run;
      test();
      post_test();
    endtask

    //============================================================================
    // Stop subroutine
    //============================================================================
    task stop;
      mng_agent.stop_master();
      ddr_axi_agent.stop_slave();
    endtask

    //============================================================================
    // Wait until all component are done
    //============================================================================
    task wait_done;
      wait (done == 1);
      //`INFO(("Shutting down"));
    endtask

    //============================================================================
    // Test controller routine
    //============================================================================
    task test_c_run();
      done = 1;
    endtask



  endclass

endpackage
