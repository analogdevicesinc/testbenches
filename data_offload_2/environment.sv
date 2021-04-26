`include "utils.svh"
`include "m_axi_sequencer.sv"
`include "s_axi_sequencer.sv"
`include "m_axis_sequencer.sv"
`include "s_axis_sequencer.sv"
`include "do_scoreboard.sv"

`ifndef __ENVIRONMENT_SV__
`define __ENVIRONMENT_SV__

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
    mng = new(mng_agent);
    src_axis_seq = new(src_axis_agent);
    dst_axis_seq = new(dst_axis_agent);

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
        `INFOV(("Sent new transaction to ADC driver"), 55);
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

`endif
