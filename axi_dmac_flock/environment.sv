// ***************************************************************************
// ***************************************************************************
// Copyright 2024 (c) Analog Devices, Inc. All rights reserved.
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

package environment_pkg;

  import axi_vip_pkg::*;
  import scoreboard_pkg::*;
  import axi4stream_vip_pkg::*;
  import m_axi_sequencer_pkg::*;
  import s_axi_sequencer_pkg::*;
  import m_axis_sequencer_pkg::*;
  import s_axis_sequencer_pkg::*;
  import test_harness_env_pkg::*;
  import dma_trans_pkg::*;
  import `PKGIFY(test_harness, mng_axi_vip)::*;
  import `PKGIFY(test_harness, ddr_axi_vip)::*;
  import `PKGIFY(test_harness, src_axis_vip)::*;
  import `PKGIFY(test_harness, dst_axis_vip)::*;
  `ifdef HAS_XIL_VDMA
  import `PKGIFY(test_harness, ref_src_axis_vip)::*;
  import `PKGIFY(test_harness, ref_dst_axis_vip)::*;
  `endif

  class environment extends test_harness_env;

    // Agents
    `AGENT(test_harness, src_axis_vip, mst_t) src_axis_agent;
    `AGENT(test_harness, dst_axis_vip, slv_t) dst_axis_agent;
    `ifdef HAS_XIL_VDMA
    `AGENT(test_harness, ref_src_axis_vip, mst_t) ref_src_axis_agent;
    `AGENT(test_harness, ref_dst_axis_vip, slv_t) ref_dst_axis_agent;
    `endif

    // Sequencers
    m_axis_sequencer #(`AGENT(test_harness, src_axis_vip, mst_t),
                       `AXIS_VIP_PARAMS(test_harness, src_axis_vip)
                      ) src_axis_seq;
    s_axis_sequencer #(`AGENT(test_harness, dst_axis_vip, slv_t)) dst_axis_seq;
    `ifdef HAS_XIL_VDMA
    m_axis_sequencer #(`AGENT(test_harness, ref_src_axis_vip, mst_t),
                       `AXIS_VIP_PARAMS(test_harness, ref_src_axis_vip)
                      ) ref_src_axis_seq;
    s_axis_sequencer #(`AGENT(test_harness, ref_dst_axis_vip, slv_t)) ref_dst_axis_seq;
    `endif
    // Register accessors

    dma_transfer_group trans_q[$];
    bit done = 0;

    scoreboard scrb;

    //============================================================================
    // Constructor
    //============================================================================
    function new(
      virtual interface clk_vip_if #(.C_CLK_CLOCK_PERIOD(10)) sys_clk_vip_if,
      virtual interface clk_vip_if #(.C_CLK_CLOCK_PERIOD(5)) dma_clk_vip_if,
      virtual interface clk_vip_if #(.C_CLK_CLOCK_PERIOD(2.5)) ddr_clk_vip_if,

      virtual interface rst_vip_if #(.C_ASYNCHRONOUS(1), .C_RST_POLARITY(1)) sys_rst_vip_if,

      virtual interface axi_vip_if #(`AXI_VIP_IF_PARAMS(test_harness, mng_axi_vip)) mng_vip_if,
      virtual interface axi_vip_if #(`AXI_VIP_IF_PARAMS(test_harness, ddr_axi_vip)) ddr_vip_if,
    `ifdef HAS_XIL_VDMA
      virtual interface axi4stream_vip_if #(`AXIS_VIP_IF_PARAMS(test_harness, ref_src_axis_vip)) ref_src_axis_vip_if,
      virtual interface axi4stream_vip_if #(`AXIS_VIP_IF_PARAMS(test_harness, ref_dst_axis_vip)) ref_dst_axis_vip_if,
    `endif
      virtual interface axi4stream_vip_if #(`AXIS_VIP_IF_PARAMS(test_harness, src_axis_vip)) src_axis_vip_if,
      virtual interface axi4stream_vip_if #(`AXIS_VIP_IF_PARAMS(test_harness, dst_axis_vip)) dst_axis_vip_if
    );
      super.new(sys_clk_vip_if,
	        dma_clk_vip_if,
		ddr_clk_vip_if,
		sys_rst_vip_if,
		mng_vip_if,
		ddr_vip_if);

      // Creating the agents
      src_axis_agent = new("Src AXI stream agent", src_axis_vip_if);
      dst_axis_agent = new("Dest AXI stream agent", dst_axis_vip_if);
    `ifdef HAS_XIL_VDMA
      ref_src_axis_agent = new("Ref Src AXI stream agent", ref_src_axis_vip_if);
      ref_dst_axis_agent = new("Ref Dest AXI stream agent", ref_dst_axis_vip_if);
    `endif

      // Creating the sequencers
      src_axis_seq = new(src_axis_agent);
      dst_axis_seq = new(dst_axis_agent);
    `ifdef HAS_XIL_VDMA
      ref_src_axis_seq = new(ref_src_axis_agent);
      ref_dst_axis_seq = new(ref_dst_axis_agent);
    `endif

    scrb = new;

    endfunction

    //============================================================================
    // Start environment
    //   - Connect all the agents to the scoreboard
    //   - Start the agents
    //============================================================================
    task start();
      super.start();
      scrb.connect(
        src_axis_agent.monitor.item_collected_port,
        dst_axis_agent.monitor.item_collected_port
      );

      src_axis_agent.start_master();
      dst_axis_agent.start_slave();
    `ifdef HAS_XIL_VDMA
      ref_src_axis_agent.start_master();
      ref_dst_axis_agent.start_slave();
    `endif

    endtask

    //============================================================================
    // Start the test
    //   - start the scoreboard
    //   - start the sequencers
    //============================================================================
    task test();
      super.test();
      fork
        src_axis_seq.run();
        `ifdef HAS_XIL_VDMA
        ref_src_axis_seq.run();
        `endif
        // DEST AXIS does not have to run, scoreboard connects and
        // gathers packets from the agent
        scrb.run();
        test_c_run();
      join_none
    endtask

    //============================================================================
    // Post test subroutine
    //============================================================================
    task post_test();
      super.post_test();
      // wait until done
      scrb.shutdown();
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
      super.stop();
      src_axis_agent.stop_master();
      dst_axis_agent.stop_slave();
    `ifdef HAS_XIL_VDMA
      ref_src_axis_agent.stop_master();
      ref_dst_axis_agent.stop_slave();
    `endif
    endtask

  endclass

endpackage
