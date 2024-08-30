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

package spi_execution_environment_pkg;

  import axi_vip_pkg::*;
  import axi4stream_vip_pkg::*;
  import m_axi_sequencer_pkg::*;
  import s_axi_sequencer_pkg::*;
  import s_spi_sequencer_pkg::*;
  import m_axis_sequencer_pkg::*;
  import s_axis_sequencer_pkg::*;
  import adi_spi_vip_pkg::*;
  import test_harness_env_pkg::*;
  import `PKGIFY(test_harness, mng_axi_vip)::*;
  import `PKGIFY(test_harness, ddr_axi_vip)::*;  
  import `PKGIFY(test_harness, cmd_src)::*;
  import `PKGIFY(test_harness, sdo_src)::*;
  import `PKGIFY(test_harness, sdi_sink)::*;
  import `PKGIFY(test_harness, sync_sink)::*;
  import `PKGIFY(test_harness, spi_s_vip)::*;

  class spi_execution_environment extends test_harness_env;

    // Agents
    adi_spi_agent #(`SPI_VIP_PARAMS(test_harness, spi_s_vip)) spi_agent;
    `AGENT(test_harness, cmd_src, mst_t)    cmd_src_agent;
    `AGENT(test_harness, sdo_src, mst_t)    sdo_src_agent;
    `AGENT(test_harness, sdi_sink, slv_t)   sdi_sink_agent;
    `AGENT(test_harness, sync_sink, slv_t)  sync_sink_agent;

    // Sequencers
    s_spi_sequencer #(`SPI_VIP_PARAMS(test_harness, spi_s_vip)) spi_seq;
    m_axis_sequencer #(`AGENT(test_harness, cmd_src, mst_t),
                      `AXIS_VIP_PARAMS(test_harness, cmd_src)
                      ) cmd_src_seq;
    m_axis_sequencer #(`AGENT(test_harness, sdo_src, mst_t),
                      `AXIS_VIP_PARAMS(test_harness, sdo_src)
                      ) sdo_src_seq;
    s_axis_sequencer #(`AGENT(test_harness, sdi_sink, slv_t)) sdi_sink_seq;
    s_axis_sequencer #(`AGENT(test_harness, sync_sink, slv_t)) sync_sink_seq;

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
      virtual interface axi4stream_vip_if #(`AXIS_VIP_IF_PARAMS(test_harness, cmd_src)) cmd_src_axis_vip_if,
      virtual interface axi4stream_vip_if #(`AXIS_VIP_IF_PARAMS(test_harness, sdo_src)) sdo_src_axis_vip_if,
      virtual interface axi4stream_vip_if #(`AXIS_VIP_IF_PARAMS(test_harness, sdi_sink)) sdi_sink_axis_vip_if,
      virtual interface axi4stream_vip_if #(`AXIS_VIP_IF_PARAMS(test_harness, sync_sink)) sync_sink_axis_vip_if,
      virtual interface spi_vip_if #(`SPI_VIP_PARAMS(test_harness, spi_s_vip)) spi_s_vip_if
    );

      super.new(sys_clk_vip_if,
                dma_clk_vip_if,
                ddr_clk_vip_if,
                sys_rst_vip_if,
                mng_vip_if,
                ddr_vip_if);

      // Creating the agents
      spi_agent = new(spi_s_vip_if);
      cmd_src_agent   = new("CMD Source AXI Stream Agent", cmd_src_axis_vip_if);
      sdo_src_agent   = new("SDO Source AXI Stream Agent", sdo_src_axis_vip_if);
      sdi_sink_agent  = new("SDI Sink AXI Stream Agent", sdi_sink_axis_vip_if);
      sync_sink_agent = new("SYNC Sink AXI Stream Agent", sync_sink_axis_vip_if);
      
      // Creating the sequencers
      spi_seq = new(spi_agent);
      cmd_src_seq   = new(cmd_src_agent);
      sdo_src_seq   = new(sdo_src_agent);
      sdi_sink_seq  = new(sdi_sink_agent);
      sync_sink_seq = new(sync_sink_agent);

      
      // downgrade reset check: we are currently using a clock generator for the SPI clock,
      // so it will come a bit after the reset and trigger the default error. 
      // This is harmless for this test (we don't want to test any reset scheme)
      cmd_src_axis_vip_if.set_xilinx_reset_check_to_warn();
      sdo_src_axis_vip_if.set_xilinx_reset_check_to_warn();
      sdi_sink_axis_vip_if.set_xilinx_reset_check_to_warn();
      sync_sink_axis_vip_if.set_xilinx_reset_check_to_warn();

    endfunction

    //============================================================================
    // Configure environment
    //   - Configure the sequencer VIPs with an initial configuration before starting them
    //============================================================================
    task configure();

      xil_axi4stream_ready_gen_policy_t sdi_sink_mode;
      xil_axi4stream_ready_gen_policy_t sync_sink_mode;

      // source stub
      cmd_src_seq.set_stop_policy(STOP_POLICY_PACKET);
      sdo_src_seq.set_stop_policy(STOP_POLICY_PACKET);
      cmd_src_seq.set_data_gen_mode(DATA_GEN_MODE_TEST_DATA);
      sdo_src_seq.set_data_gen_mode(DATA_GEN_MODE_TEST_DATA);
      cmd_src_seq.set_data_beat_delay(`CMD_STREAM_BEAT_DELAY);
      sdo_src_seq.set_data_beat_delay(`SDO_STREAM_BEAT_DELAY);

      // destination stub
      sdi_sink_mode = XIL_AXI4STREAM_READY_GEN_RANDOM;
      sync_sink_mode = XIL_AXI4STREAM_READY_GEN_RANDOM;
      sdi_sink_seq.set_mode(sdi_sink_mode);
      sync_sink_seq.set_mode(sync_sink_mode);

    endtask

    //============================================================================
    // Start environment
    //   - Connect all the agents to the scoreboard
    //   - Start the agents
    //============================================================================
    task start();
      super.start();
      spi_agent.start();
      cmd_src_agent.start_master();
      sdo_src_agent.start_master();
      sdi_sink_agent.start_slave();
      sync_sink_agent.start_slave();
    endtask

    //============================================================================
    // Start the test
    //   - start the scoreboard
    //   - start the sequencers
    //============================================================================
    task test();
      super.test();
      fork
        cmd_src_seq.run();
        sdo_src_seq.run();
        sdi_sink_seq.run();
        sync_sink_seq.run();
      join_none
    endtask

    //============================================================================
    // Run subroutine
    //============================================================================
    task run;
      test();
    endtask

    //============================================================================
    // Stop subroutine
    //============================================================================
    task stop;
      spi_agent.stop();
      super.stop();
      cmd_src_seq.stop();
      sdo_src_seq.stop();
      cmd_src_agent.stop_master();
      sdo_src_agent.stop_master();
      sdi_sink_agent.stop_slave();
      sync_sink_agent.stop_slave();
    endtask

  endclass

endpackage
