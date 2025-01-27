// ***************************************************************************
// ***************************************************************************
// Copyright (C) 2021 Analog Devices, Inc. All rights reserved.
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

  import m_axi_sequencer_pkg::*;
  import m_axis_sequencer_pkg::*;
  import s_axis_sequencer_pkg::*;
  import do_scoreboard_pkg::*;

  import logger_pkg::*;

  import axi_vip_pkg::*;
  import axi4stream_vip_pkg::*;
  import `PKGIFY(test_harness, mng_axi)::*;
  import `PKGIFY(test_harness, src_axis)::*;
  import `PKGIFY(test_harness, dst_axis)::*;

  class environment;

    // agents and sequencers
    `AGENT(test_harness, mng_axi, mst_t) mng_agent;
    `AGENT(test_harness, src_axis, mst_t) src_axis_agent;
    `AGENT(test_harness, dst_axis, slv_t) dst_axis_agent;

    m_axi_sequencer  #(`AGENT(test_harness, mng_axi, mst_t)) mng;
    m_axis_sequencer #(`AGENT(test_harness, src_axis, mst_t),
                       `AXIS_VIP_PARAMS(test_harness, src_axis)
                      ) src_axis_seq;
    s_axis_sequencer #(`AGENT(test_harness, dst_axis, slv_t)) dst_axis_seq;

    do_scoreboard scoreboard;

    //============================================================================
    // Constructor
    //============================================================================
    function new (
      virtual interface axi_vip_if #(`AXI_VIP_IF_PARAMS(test_harness, mng_axi)) mng_vip_if,
      virtual interface axi4stream_vip_if #(`AXIS_VIP_IF_PARAMS(test_harness, src_axis)) src_axis_vip_if,
      virtual interface axi4stream_vip_if #(`AXIS_VIP_IF_PARAMS(test_harness, dst_axis)) dst_axis_vip_if
    );

      // creating the agents
      mng_agent = new("AXI Manager Agent", mng_vip_if);
      src_axis_agent = new("Source AXI Stream Agent", src_axis_vip_if);
      dst_axis_agent = new("Destination AXI Stream Agent", dst_axis_vip_if);

      // create sequencers
      mng = new("AXI Manager Sequencer", mng_agent);
      src_axis_seq = new("Source AXI Stream Sequencer", src_axis_agent);
      dst_axis_seq = new("Destination AXI Stream Sequencer", dst_axis_agent);

      scoreboard = new("do_scoreboard");

    endfunction

    //============================================================================
    // Start environment
    //   - Connect all the agents to the scoreboard
    //   - Start the agents
    //============================================================================
    task start();

      // start agents, one by one
      mng_agent.start_master();
      src_axis_agent.start_master();
      dst_axis_agent.start_slave();

      scoreboard.set_ports(src_axis_agent.monitor.item_collected_port,
                           dst_axis_agent.monitor.item_collected_port);


    endtask

    //============================================================================
    // Start the test
    //   - start the RX scoreboard and sequencer
    //   - start the TX scoreboard and sequencer
    //   - setup the RX DMA
    //   - setup the TX DMA
    //============================================================================
    task test();
      fork

        src_axis_seq.run();
        dst_axis_seq.run();

        scoreboard.run();

        // adc_stream_gen();

      join_none
    endtask


    //============================================================================
    // Generate a data stream as an ADC
    //
    //   - clock to data rate ratio is 1
    //
    //============================================================================

    axi4stream_transaction rx_transaction;
    int data_rate_ratio = 1;

    task adc_stream_gen();

      while(1) begin
        if (src_axis_agent.driver.is_driver_idle) begin
          rx_transaction = src_axis_agent.driver.create_transaction("");
          TRANSACTION_FAIL: assert(rx_transaction.randomize());
          rx_transaction.set_delay(data_rate_ratio - 1);
          src_axis_agent.driver.send(rx_transaction);
          `INFO(("Sent new transaction to ADC driver"), ADI_VERBOSITY_LOW);
          #0;
        end else begin
          #1;
        end
      end

    endtask

    //============================================================================
    // Post test subroutine
    //============================================================================
    task post_test();
      // Evaluate the scoreboard's results
      fork
        scoreboard.post_test();
      join
    endtask

    //============================================================================
    // Run subroutine
    //============================================================================
    task run;
      //pre_test();
      test();
    endtask

    //============================================================================
    // Stop subroutine
    //============================================================================
    task stop;
      src_axis_seq.stop();
      src_axis_agent.stop_master();
      dst_axis_agent.stop_slave();
      mng_agent.stop_master();
      post_test();
    endtask

  endclass

endpackage
