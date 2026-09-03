// ***************************************************************************
// ***************************************************************************
// Copyright (C) 2026 Analog Devices, Inc. All rights reserved.
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
`include "axis_definitions.svh"

package environment_pkg;

  import logger_pkg::*;
  import adi_environment_pkg::*;
  import axi4stream_vip_pkg::*;
  import m_axis_sequencer_pkg::*;
  import s_axis_sequencer_pkg::*;
  import adi_axis_agent_pkg::*;
  import scoreboard_pkg::*;

  // Milestone-2 REAL-IP MRMAC + Corundum MAC-shim loopback environment.
  //
  //   eth_tx_axis (master VIP) -> DUT axis_eth_tx  ]  the shim packs to the 384b
  //   ] segmented MRMAC bus, the REAL mrmac_0 + gtwiz_versal transmit it over the
  //   ] GT serial loopback, the real MRMAC RX + shim unpack it, and             ]
  //   DUT axis_eth_rx -> eth_rx_axis (slave VIP)    ]
  //
  // Same fpga_core-facing byte-exact scoreboard as the behavioral mrmac_loopback
  // (TX monitor -> source, RX monitor -> sink, ONESHOT byte compare), so a full
  // frame round-trip through the REAL MAC+PCS+GT must be byte-exact.
  //
  // KEY DIFFERENCE vs the behavioral env: there is NO axis_clk_vip. The AXIS
  // client clock is produced by the REAL clk_wizard (clk_out1 = 390.625 MHz) that
  // the island builds, and reaches the VIPs through mrmac_dut/tx_clk|rx_clk. So
  // this env neither holds a clk_vip virtual interface nor starts/stops it -- the
  // clock is already running the moment the free-running clock (which feeds the
  // clk_wizard) is started in the test program. The class is therefore
  // parameterized ONLY on the two AXIS VIPs (no AXIS_CLK localparam).
  class mrmac_loopback_environment #(`AXIS_VIP_PARAM_DECL(eth_tx_axis), `AXIS_VIP_PARAM_DECL(eth_rx_axis)) extends adi_environment;

    adi_axis_master_agent #(`AXIS_VIP_PARAM_ORDER(eth_tx_axis)) eth_tx_axis_agent;
    adi_axis_slave_agent #(`AXIS_VIP_PARAM_ORDER(eth_rx_axis)) eth_rx_axis_agent;

    scoreboard #(logic [7:0]) scoreboard_inst;

    //============================================================================
    // Constructor
    //============================================================================
    function new (
      input string name,

      virtual interface axi4stream_vip_if #(`AXIS_VIP_IF_PARAMS(eth_tx_axis)) eth_tx_axis_vip_if,
      virtual interface axi4stream_vip_if #(`AXIS_VIP_IF_PARAMS(eth_rx_axis)) eth_rx_axis_vip_if);

      // creating the agents
      super.new(name);

      this.eth_tx_axis_agent = new("ETH TX AXI Stream Agent", eth_tx_axis_vip_if, this);
      this.eth_rx_axis_agent = new("ETH RX AXI Stream Agent", eth_rx_axis_vip_if, this);

      this.scoreboard_inst = new("MRMAC Real-IP Loopback Scoreboard", this);
    endfunction

    //============================================================================
    // Configure environment
    //============================================================================
    task configure();
      // TX master: emit whole packets, auto-incrementing payload, keep all bytes
      // (frames are exact multiples of the beat; sized >= 60B by the test so the
      // shim's runt padding never lengthens the frame -> byte-exact round-trip).
      this.eth_tx_axis_agent.sequencer.set_stop_policy(STOP_POLICY_PACKET);
      this.eth_tx_axis_agent.sequencer.set_data_gen_mode(DATA_GEN_MODE_AUTO_INCR);
      this.eth_tx_axis_agent.sequencer.set_descriptor_gen_mode(1);
      this.eth_tx_axis_agent.sequencer.set_data_beat_delay(0);
      this.eth_tx_axis_agent.sequencer.set_descriptor_delay(0);
      this.eth_tx_axis_agent.sequencer.set_keep_all();
      this.eth_tx_axis_agent.sequencer.set_inactive_drive_output_0();

      // RX slave: the DUT's rx_axis has no TREADY, so never back-pressure.
      this.eth_rx_axis_agent.sequencer.set_mode(XIL_AXI4STREAM_READY_GEN_NO_BACKPRESSURE);
    endtask

    //============================================================================
    // Start environment
    //   - Start the agents (NO clock: the AXIS clock is the real clk_wizard).
    //   - Connect both monitors to the scoreboard.
    //============================================================================
    task start();
      // start_master/start_slave live on the raw axi4stream_vip agent (.agent),
      // not the adi wrapper (which exposes start()/run()/stop()) -- the current
      // API, matching the axis_sequencers reference environment.sv.
      this.eth_tx_axis_agent.agent.start_master();
      this.eth_rx_axis_agent.agent.start_slave();

      this.eth_tx_axis_agent.monitor.publisher.subscribe(this.scoreboard_inst.subscriber_source);
      this.eth_rx_axis_agent.monitor.publisher.subscribe(this.scoreboard_inst.subscriber_sink);
    endtask

    //============================================================================
    // Run subroutine
    //============================================================================
    task run();
      fork
        this.scoreboard_inst.run();
      join_none
    endtask

    //============================================================================
    // Stop subroutine
    //============================================================================
    task stop();
      this.eth_tx_axis_agent.agent.stop_master();
      this.eth_rx_axis_agent.agent.stop_slave();
    endtask

  endclass

endpackage
