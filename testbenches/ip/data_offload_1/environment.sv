// ***************************************************************************
// ***************************************************************************
// Copyright (C) 2021-2026 Analog Devices, Inc. All rights reserved.
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
`include "axis_definitions.svh"

package environment_pkg;

  import logger_pkg::*;
  import adi_environment_pkg::*;
  import axi_vip_pkg::*;
  import axi4stream_vip_pkg::*;
  import m_axi_sequencer_pkg::*;
  import s_axi_sequencer_pkg::*;
  import m_axis_sequencer_pkg::*;
  import s_axis_sequencer_pkg::*;
  import adi_axi_agent_pkg::*;
  import adi_axis_agent_pkg::*;
  import scoreboard_pkg::*;

  class environment #(
    `AXIS_VIP_PARAM_DECL(adc_src), `AXI_VIP_PARAM_DECL(adc_dst),
    `AXI_VIP_PARAM_DECL(dac_src), `AXIS_VIP_PARAM_DECL(dac_dst)) extends adi_environment;

    // Agents
    adi_axis_master_agent #(`AXIS_VIP_PARAM_ORDER(adc_src)) adc_src_axis_agent;
    adi_axi_passthrough_mem_agent #(`AXI_VIP_PARAM_ORDER(adc_dst)) adc_dst_axi_agent;

    adi_axi_passthrough_mem_agent #(`AXI_VIP_PARAM_ORDER(dac_src)) dac_src_axi_agent;
    adi_axis_slave_agent #(`AXIS_VIP_PARAM_ORDER(dac_dst)) dac_dst_axis_agent;

    scoreboard #(logic [7:0]) scoreboard_tx;
    scoreboard #(logic [7:0]) scoreboard_rx;

    //============================================================================
    // Constructor
    //============================================================================
    function new (
      input string name,

      virtual interface axi4stream_vip_if #(`AXIS_VIP_IF_PARAMS(adc_src)) adc_src_axis_vip_if,
      virtual interface axi_vip_if #(`AXI_VIP_IF_PARAMS(adc_dst)) adc_dst_if,

      virtual interface axi_vip_if #(`AXI_VIP_IF_PARAMS(dac_src)) dac_src_if,
      virtual interface axi4stream_vip_if #(`AXIS_VIP_IF_PARAMS(dac_dst)) dac_dst_axis_vip_if);

      // creating the agents
      super.new(.name(name));

      this.adc_src_axis_agent = new(.name("ADC Source AXI Stream Agent"), .master_vip_if(adc_src_axis_vip_if), .parent(this));
      this.adc_dst_axi_agent = new(.name("ADC Destination AXI Agent"), .passthrough_vip_if(adc_dst_if), .parent(this));

      this.dac_src_axi_agent = new(.name("DAC Source AXI Agent"), .passthrough_vip_if(dac_src_if), .parent(this));
      this.dac_dst_axis_agent = new(.name("DAC Destination AXI Stream Agent"), .slave_vip_if(dac_dst_axis_vip_if), .parent(this));

      this.scoreboard_tx = new(.name("Data Offload TX Scoreboard"), .parent(this));
      this.scoreboard_rx = new(.name("Data Offload RX Scoreboard"), .parent(this));
    endfunction

    //============================================================================
    // Configure environment
    //   - Configure the sequencer VIPs with an initial configuration before starting them
    //============================================================================
    task configure(int bytes_to_generate);
      // ADC stub
      this.adc_src_axis_agent.master_sequencer.set_data_gen_mode(.data_gen_mode(DATA_GEN_MODE_AUTO_INCR));
      this.adc_src_axis_agent.master_sequencer.add_xfer_descriptor_byte_count(.bytes_to_generate(bytes_to_generate), .gen_last(0), .gen_sync(0));

      // DAC stub
      this.dac_dst_axis_agent.slave_sequencer.set_mode(.mode(XIL_AXI4STREAM_READY_GEN_NO_BACKPRESSURE));
    endtask

    //============================================================================
    // Start environment
    //   - Connect all the agents to the scoreboard
    //   - Start the agents
    //============================================================================
    task start();
      this.adc_src_axis_agent.start_master();
      this.adc_dst_axi_agent.start_monitor();

      this.dac_src_axi_agent.start_monitor();
      this.dac_dst_axis_agent.start_slave();

      this.dac_src_axi_agent.monitor.publisher_rx.subscribe(.subscriber(this.scoreboard_tx.subscriber_source));
      this.dac_dst_axis_agent.monitor.publisher.subscribe(.subscriber(this.scoreboard_tx.subscriber_sink));

      this.adc_src_axis_agent.monitor.publisher.subscribe(.subscriber(this.scoreboard_rx.subscriber_source));
      this.adc_dst_axi_agent.monitor.publisher_tx.subscribe(.subscriber(this.scoreboard_rx.subscriber_sink));
    endtask

    //============================================================================
    // Run subroutine
    //============================================================================
    task run();
      fork
        this.scoreboard_tx.run();
        this.scoreboard_rx.run();
      join_none
    endtask

    //============================================================================
    // Stop subroutine
    //============================================================================
    task stop();
      this.adc_src_axis_agent.stop_master();
      this.adc_dst_axi_agent.stop_monitor();

      this.dac_src_axi_agent.stop_monitor();
      this.dac_dst_axis_agent.stop_slave();
    endtask

  endclass

endpackage
