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
  import adi_axis_agent_pkg::*;
  import scoreboard_pack_pkg::*;
  import vip_agent_typedef_pkg::*;
  import axis_transaction_to_byte_adapter_pkg::*;
  import adi_axis_packet_pkg::*;

  class util_pack_environment extends adi_environment;

    adi_axis_agent_base tx_src_axis_agent;
    adi_axis_agent_base tx_dst_axis_agent;
    adi_axis_agent_base rx_src_axis_agent;
    adi_axis_agent_base rx_dst_axis_agent;

    scoreboard_pack #(logic [7:0]) scoreboard_tx;
    scoreboard_pack #(logic [7:0]) scoreboard_rx;

    axis_transaction_to_byte_adapter axis_adapter_tx_src;
    axis_transaction_to_byte_adapter axis_adapter_tx_dst;
    axis_transaction_to_byte_adapter axis_adapter_rx_src;
    axis_transaction_to_byte_adapter axis_adapter_rx_dst;

    //============================================================================
    // Constructor
    //============================================================================
    function new (input string name);
      // creating the agents
      super.new(name);

      this.tx_src_axis_agent = new("TX Source AXI Stream Agent", MASTER, this);
      this.tx_dst_axis_agent = new("TX Destination AXI Stream Agent", SLAVE, this);
      this.rx_src_axis_agent = new("RX Source AXI Stream Agent", MASTER, this);
      this.rx_dst_axis_agent = new("RX Destination AXI Stream Agent", SLAVE, this);

      this.scoreboard_tx = new("TX Scoreboard", `CHANNELS, `SAMPLES, `WIDTH, CPACK, this);
      this.scoreboard_rx = new("RX Scoreboard", `CHANNELS, `SAMPLES, `WIDTH, UPACK, this);

      this.axis_adapter_tx_src = new(
        .name("Axis Adapter TX Source"),
        .parent(this));
      this.axis_adapter_tx_dst = new(
        .name("Axis Adapter TX Destination"),
        .parent(this));

      this.axis_adapter_rx_src = new(
        .name("Axis Adapter RX Source"),
        .parent(this));
      this.axis_adapter_rx_dst = new(
        .name("Axis Adapter RX Destination"),
        .parent(this));
    endfunction

    //============================================================================
    // Configure environment
    //   - Configure the sequencer VIPs with an initial configuration before starting them
    //============================================================================
    // task configure(int bytes_to_generate);
    task configure(
      input adi_axis_packet tx_packet,
      input adi_axis_packet rx_packet);

      // TX stubs
      this.tx_src_axis_agent.master_sequencer.add_packet(tx_packet);

      this.tx_dst_axis_agent.slave_sequencer.set_mode(XIL_AXI4STREAM_READY_GEN_NO_BACKPRESSURE);

      // RX stub
      this.rx_src_axis_agent.master_sequencer.add_packet(rx_packet);

      this.rx_dst_axis_agent.slave_sequencer.set_mode(XIL_AXI4STREAM_READY_GEN_NO_BACKPRESSURE);
    endtask

    //============================================================================
    // Start environment
    //   - Connect all the agents to the scoreboard
    //   - Start the agents
    //============================================================================
    task start();
      this.tx_src_axis_agent.start_master();
      this.tx_dst_axis_agent.start_slave();
      this.rx_src_axis_agent.start_master();
      this.rx_dst_axis_agent.start_slave();

      this.tx_src_axis_agent.monitor.publisher.subscribe(this.axis_adapter_tx_src.subscriber);
      this.axis_adapter_tx_src.publisher.subscribe(this.scoreboard_tx.subscriber_source);
      this.tx_dst_axis_agent.monitor.publisher.subscribe(this.axis_adapter_tx_dst.subscriber);
      this.axis_adapter_tx_dst.publisher.subscribe(this.scoreboard_tx.subscriber_sink);

      this.rx_src_axis_agent.monitor.publisher.subscribe(this.axis_adapter_rx_src.subscriber);
      this.axis_adapter_rx_src.publisher.subscribe(this.scoreboard_rx.subscriber_source);
      this.rx_dst_axis_agent.monitor.publisher.subscribe(this.axis_adapter_rx_dst.subscriber);
      this.axis_adapter_rx_dst.publisher.subscribe(this.scoreboard_rx.subscriber_sink);
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
      this.tx_src_axis_agent.stop_master();
      this.tx_dst_axis_agent.stop_slave();

      this.rx_src_axis_agent.stop_master();
      this.rx_dst_axis_agent.stop_slave();
    endtask

  endclass

endpackage
