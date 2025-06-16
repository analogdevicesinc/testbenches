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

  import logger_pkg::*;
  import adi_environment_pkg::*;
  import adi_axis_agent_pkg::*;
  import m_axis_sequencer_pkg::*;
  import s_axis_sequencer_pkg::*;
  import axi4stream_vip_pkg::*;
  import adi_spi_vip_pkg::*;
  import adi_spi_vip_if_base_pkg::*;
  import watchdog_pkg::*;

  class spi_execution_environment #(
                                    `AXIS_VIP_PARAM_DECL(cmd_src),
                                    `AXIS_VIP_PARAM_DECL(sdo_src),
                                    `AXIS_VIP_PARAM_DECL(sdi_sink),
                                    `AXIS_VIP_PARAM_DECL(sync_sink)
                                  ) extends adi_environment;

    // Agents
    adi_spi_agent spi_agent;
    adi_axis_master_agent #(`AXIS_VIP_PARAM_ORDER(cmd_src))    cmd_src_agent;
    adi_axis_master_agent #(`AXIS_VIP_PARAM_ORDER(sdo_src))    sdo_src_agent;
    adi_axis_slave_agent  #(`AXIS_VIP_PARAM_ORDER(sdi_sink))   sdi_sink_agent;
    adi_axis_slave_agent  #(`AXIS_VIP_PARAM_ORDER(sync_sink))  sync_sink_agent;

    //============================================================================
    // Constructor
    //============================================================================
    function new(
      input string name,
      adi_spi_vip_if_base spi_s_vip_if,
      virtual interface axi4stream_vip_if #(`AXIS_VIP_IF_PARAMS(cmd_src))    cmd_src_axis_vip_if,
      virtual interface axi4stream_vip_if #(`AXIS_VIP_IF_PARAMS(sdo_src))    sdo_src_axis_vip_if,
      virtual interface axi4stream_vip_if #(`AXIS_VIP_IF_PARAMS(sdi_sink))   sdi_sink_axis_vip_if,
      virtual interface axi4stream_vip_if #(`AXIS_VIP_IF_PARAMS(sync_sink))  sync_sink_axis_vip_if
     );

      super.new(name);

      // Creating the agents
      spi_agent = new("SPI VIP Agent", spi_s_vip_if, this);
      cmd_src_agent   = new("CMD Source AXI Stream Agent", cmd_src_axis_vip_if, this);
      sdo_src_agent   = new("SDO Source AXI Stream Agent", sdo_src_axis_vip_if, this);
      sdi_sink_agent  = new("SDI Sink AXI Stream Agent", sdi_sink_axis_vip_if, this);
      sync_sink_agent = new("SYNC Sink AXI Stream Agent", sync_sink_axis_vip_if, this);

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
      this.cmd_src_agent.sequencer.set_stop_policy(STOP_POLICY_PACKET);
      this.sdo_src_agent.sequencer.set_stop_policy(STOP_POLICY_PACKET);
      this.cmd_src_agent.sequencer.set_data_gen_mode(DATA_GEN_MODE_TEST_DATA);
      this.sdo_src_agent.sequencer.set_data_gen_mode(DATA_GEN_MODE_TEST_DATA);
      this.cmd_src_agent.sequencer.set_data_beat_delay(`CMD_STREAM_BEAT_DELAY);
      this.sdo_src_agent.sequencer.set_data_beat_delay(`SDO_STREAM_BEAT_DELAY);

      // destination stub
      sdi_sink_mode = XIL_AXI4STREAM_READY_GEN_RANDOM;
      sync_sink_mode = XIL_AXI4STREAM_READY_GEN_RANDOM;
      this.sdi_sink_agent.sequencer.set_mode(sdi_sink_mode);
      this.sync_sink_agent.sequencer.set_mode(sync_sink_mode);

    endtask

    //============================================================================
    // Start environment
    //   - Connect all the agents to the scoreboard
    //   - Start the agents
    //============================================================================
    task start();
      this.spi_agent.start();
      this.cmd_src_agent.start();
      this.sdo_src_agent.start();
      this.sdi_sink_agent.start();
      this.sync_sink_agent.start();
    endtask

    //============================================================================
    // Run subroutine
    //============================================================================
    task run;
      fork
        this.cmd_src_agent.run();
        this.sdo_src_agent.run();
        this.sdi_sink_agent.run();
        this.sync_sink_agent.run();
      join_none
    endtask

    //============================================================================
    // Stop subroutine
    //============================================================================
    task stop;
      this.spi_agent.stop();
      this.cmd_src_agent.stop();
      this.sdo_src_agent.stop();
      this.sdi_sink_agent.stop();
      this.sync_sink_agent.stop();
    endtask

  endclass

endpackage
