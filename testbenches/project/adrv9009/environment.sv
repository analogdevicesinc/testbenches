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
  import adi_common_pkg::*;
  import adi_environment_pkg::*;
  import axi4stream_vip_pkg::*;
  import m_axis_sequencer_pkg::*;
  import s_axis_sequencer_pkg::*;
  import adi_axis_agent_pkg::*;
  import scoreboard_pkg::*;

  typedef class phase_scoreboard;

  class environment #(`AXIS_VIP_PARAM_DECL(ex_rx), `AXIS_VIP_PARAM_DECL(ex_tx), `AXIS_VIP_PARAM_DECL(ex_tx_os)) extends adi_environment;

    // Exerciser AXI Stream agents (non-DUT side of the JESD links)
    adi_axis_slave_agent  #(`AXIS_VIP_PARAM_ORDER(ex_rx))    ex_rx_axis_agent;
    adi_axis_master_agent #(`AXIS_VIP_PARAM_ORDER(ex_tx))    ex_tx_axis_agent;
    adi_axis_master_agent #(`AXIS_VIP_PARAM_ORDER(ex_tx_os)) ex_tx_os_axis_agent;

    phase_scoreboard ex_rx_scoreboard;

    //============================================================================
    // Constructor
    //============================================================================
    function new(
      input string name,
      virtual interface axi4stream_vip_if #(`AXIS_VIP_IF_PARAMS(ex_rx))    ex_rx_vip_if,
      virtual interface axi4stream_vip_if #(`AXIS_VIP_IF_PARAMS(ex_tx))    ex_tx_vip_if,
      virtual interface axi4stream_vip_if #(`AXIS_VIP_IF_PARAMS(ex_tx_os)) ex_tx_os_vip_if);

      super.new(name);

      this.ex_rx_axis_agent    = new(.name("EX RX AXIS Agent"),    .slave_vip_if(ex_rx_vip_if),     .parent(this));
      this.ex_tx_axis_agent    = new(.name("EX TX AXIS Agent"),    .master_vip_if(ex_tx_vip_if),    .parent(this));
      this.ex_tx_os_axis_agent = new(.name("EX TX OS AXIS Agent"), .master_vip_if(ex_tx_os_vip_if), .parent(this));

      this.ex_rx_scoreboard = new(.name("EX RX Scoreboard"), .parent(this));
    endfunction: new

    //============================================================================
    // Start environment
    //   - Start the agents
    //   - Slave VIP always accepts the exerciser stream
    //   - Wire the RX capture monitor into the scoreboard sink
    //============================================================================
    task start();
      this.ex_rx_axis_agent.start_slave();
      this.ex_tx_axis_agent.start_master();
      this.ex_tx_os_axis_agent.start_master();

      this.ex_rx_axis_agent.slave_sequencer.set_mode(XIL_AXI4STREAM_READY_GEN_NO_BACKPRESSURE);

      this.ex_rx_axis_agent.monitor.publisher.subscribe(this.ex_rx_scoreboard.subscriber_sink);
    endtask: start

    //============================================================================
    // Configure a master exerciser to source a cyclic auto-incrementing stream
    //============================================================================
    task configure_tx_source(input bit [31:0] bytes_to_generate = 32'h1000);
      this.ex_tx_axis_agent.master_sequencer.set_data_gen_mode(DATA_GEN_MODE_AUTO_INCR);
      this.ex_tx_axis_agent.master_sequencer.set_descriptor_gen_mode(1); // cyclic
      this.ex_tx_axis_agent.master_sequencer.add_xfer_descriptor_byte_count(bytes_to_generate, 0, 0);
    endtask: configure_tx_source

    task configure_tx_os_source(input bit [31:0] bytes_to_generate = 32'h1000);
      this.ex_tx_os_axis_agent.master_sequencer.set_data_gen_mode(DATA_GEN_MODE_AUTO_INCR);
      this.ex_tx_os_axis_agent.master_sequencer.set_descriptor_gen_mode(1); // cyclic
      this.ex_tx_os_axis_agent.master_sequencer.add_xfer_descriptor_byte_count(bytes_to_generate, 0, 0);
    endtask: configure_tx_os_source

    //============================================================================
    // Stop subroutine
    //============================================================================
    task stop();
      this.ex_rx_axis_agent.stop_slave();
      this.ex_tx_axis_agent.stop_master();
      this.ex_tx_os_axis_agent.stop_master();
    endtask: stop

  endclass: environment


  // Phase-seeded scoreboard for the RX exerciser capture path.
  //
  // The DUT TX transmits a 16-bit ramp (samples 0..MAX_SAMPLE-1, little-endian
  // bytes {low, high}); the RX exerciser reproduces it on its m_axis and the
  // slave VIP monitor feeds those bytes into subscriber_sink. Because the
  // exerciser begins streaming at an arbitrary point in the ramp, the absolute
  // byte-for-byte compare of the base scoreboard cannot line up. This override
  // seeds the expected value from the first captured sample, then requires each
  // subsequent sample to increment by one (mod MAX_SAMPLE). subscriber_source is
  // unused.
  class phase_scoreboard extends scoreboard #(logic [7:0]);

    protected int  max_sample;
    protected bit  seeded;
    protected int  expected;
    protected int  sample_index;

    function new(
      input string name,
      input adi_component parent = null);

      super.new(name, parent);

      this.max_sample   = 2048;
      this.seeded       = 1'b0;
      this.expected     = 0;
      this.sample_index = 0;
    endfunction: new

    function void set_max_sample(input int max_sample);
      this.max_sample = max_sample;
    endfunction: set_max_sample

    // Consume whole 16-bit samples from the sink queue and phase-check them.
    virtual function void compare_transaction();
      logic [7:0]  low_byte;
      logic [7:0]  high_byte;
      int          sample;

      if (this.get_enabled() == 0)
        return;

      while (this.subscriber_sink.get_size() >= 2) begin
        low_byte  = this.subscriber_sink.get_data();
        high_byte = this.subscriber_sink.get_data();
        sample    = {high_byte, low_byte};

        if (!this.seeded) begin
          this.expected = sample;
          this.seeded   = 1'b1;
          this.info($sformatf("Phase seed: first sample = %0d", sample), ADI_VERBOSITY_MEDIUM);
        end else begin
          if (sample != this.expected) begin
            this.error($sformatf("Sample %0d: expected %0d found %0d", this.sample_index, this.expected, sample));
          end
        end

        this.expected = (this.expected + 1) % this.max_sample;
        this.sample_index++;
      end
    endfunction: compare_transaction

  endclass: phase_scoreboard

endpackage: environment_pkg
