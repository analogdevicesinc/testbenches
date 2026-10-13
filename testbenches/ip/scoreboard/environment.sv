// ***************************************************************************
// ***************************************************************************
// Copyright (C) 2024-2025 Analog Devices, Inc. All rights reserved.
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

  import axi4stream_vip_pkg::*;
  import m_axis_sequencer_pkg::*;
  import s_axis_sequencer_pkg::*;
  import adi_axi_agent_pkg::*;
  import adi_axis_agent_pkg::*;
  import scoreboard_pkg::*;
  import vip_agent_typedef_pkg::*;
  import adi_axis_packet_pkg::*;
  import axis_transaction_to_byte_adapter_pkg::*;


  class scoreboard_environment extends adi_environment;

    // Agents
    adi_axis_agent_base adc_src_axis_agent;
    adi_axis_agent_base dac_dst_axis_agent;

    scoreboard #(logic [7:0]) scoreboard_tx;
    scoreboard #(logic [7:0]) scoreboard_rx;

    axis_transaction_to_byte_adapter axis_adapter_tx;
    axis_transaction_to_byte_adapter axis_adapter_rx;

    //============================================================================
    // Constructor
    //============================================================================
    function new (
      input string name,
      input adi_environment parent = null);

      // creating the agents
      super.new(name, parent);

      this.adc_src_axis_agent = new("ADC Source AXI Stream Agent", MASTER, this);
      this.dac_dst_axis_agent = new("DAC Destination AXI Stream Agent", SLAVE, this);

      this.scoreboard_tx = new("Data Offload TX Scoreboard", this);
      this.scoreboard_rx = new("Data Offload RX Scoreboard", this);

      this.axis_adapter_tx = new(
        .name("Axis Adapter TX"),
        .parent(this));

      this.axis_adapter_rx = new(
        .name("Axis Adapter RX"),
        .parent(this));
    endfunction

    //============================================================================
    // Configure environment
    //   - Configure the sequencer VIPs with an initial configuration before starting them
    //============================================================================
    task configure(input adi_axis_packet axis_packet);
      // ADC stub
      this.adc_src_axis_agent.master_sequencer.add_packet(axis_packet);

      // DAC stub
      this.dac_dst_axis_agent.slave_sequencer.set_mode(XIL_AXI4STREAM_READY_GEN_NO_BACKPRESSURE);
    endtask

    //============================================================================
    // Start environment
    //   - Connect all the agents to the scoreboard
    //   - Start the agents
    //============================================================================
    task start();
      this.adc_src_axis_agent.start_master();
      this.dac_dst_axis_agent.start_slave();

      this.dac_dst_axis_agent.monitor.publisher.subscribe(this.axis_adapter_tx.subscriber);
      this.axis_adapter_tx.publisher.subscribe(this.scoreboard_tx.subscriber_sink);

      this.adc_src_axis_agent.monitor.publisher.subscribe(this.axis_adapter_rx.subscriber);
      this.axis_adapter_rx.publisher.subscribe(this.scoreboard_rx.subscriber_source);
    endtask

    //============================================================================
    // Run subroutine
    //============================================================================
    task run();
      this.scoreboard_tx.run();
      this.scoreboard_rx.run();
    endtask

    //============================================================================
    // Stop subroutine
    //============================================================================
    task stop();
      this.adc_src_axis_agent.stop_master();
      this.dac_dst_axis_agent.stop_slave();
    endtask

  endclass

endpackage
