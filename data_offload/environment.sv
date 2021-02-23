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
import `PKGIFY(test_harness, ddr_axi)::*;
import `PKGIFY(test_harness, plddr_axi)::*;
import `PKGIFY(test_harness, adc_src_axis)::*;
import `PKGIFY(test_harness, dac_dst_axis)::*;

class environment;

  // agents and sequencers
  `AGENT(test_harness, mng_axi, mst_t) mng_agent;
  `AGENT(test_harness, ddr_axi, slv_mem_t) ddr_agent;
  `AGENT(test_harness, plddr_axi, slv_mem_t) plddr_agent;
  `AGENT(test_harness, adc_src_axis, mst_t) adc_src_axis_agent;
  `AGENT(test_harness, dac_dst_axis, slv_t) dac_dst_axis_agent;

  m_axi_sequencer  #(`AGENT(test_harness, mng_axi, mst_t)) mng;
  s_axi_sequencer  #(`AGENT(test_harness, ddr_axi, slv_mem_t)) ddr;
  m_axis_sequencer #(`AGENT(test_harness, adc_src_axis, mst_t),
                     `AXIS_VIP_PARAMS(test_harness, adc_src_axis)
                    ) adc_src_axis_seq;
  s_axis_sequencer #(`AGENT(test_harness, dac_dst_axis, slv_t)) dac_dst_axis_seq;

  do_scoreboard scoreboard;

  //============================================================================
  // Constructor
  //============================================================================
  function new (
    virtual interface axi_vip_if #(`AXI_VIP_IF_PARAMS(test_harness, mng_axi)) mng_vip_if,
    virtual interface axi_vip_if #(`AXI_VIP_IF_PARAMS(test_harness, ddr_axi)) ddr_vip_if,
    virtual interface axi_vip_if #(`AXI_VIP_IF_PARAMS(test_harness, plddr_axi)) pl_ddr_vip_if,
    virtual interface axi4stream_vip_if #(`AXIS_VIP_IF_PARAMS(test_harness, adc_src_axis)) adc_src_axis_vip_if,
    virtual interface axi4stream_vip_if #(`AXIS_VIP_IF_PARAMS(test_harness, dac_dst_axis)) dac_dst_axis_vip_if
  );

    // creating the agents
    mng_agent = new("AXI Manager Agent", mng_vip_if);
    ddr_agent = new("System DDR Agent", ddr_vip_if);
    plddr_agent = new("PL DDR Agent", pl_ddr_vip_if);
    adc_src_axis_agent = new("ADC Source AXI Stream Agent", adc_src_axis_vip_if);

    dac_dst_axis_agent = new("DAC Destination AXI Stream Agent", dac_dst_axis_vip_if);

    // create sequencers
    mng = new(mng_agent);
    ddr = new(ddr_agent);
    adc_src_axis_seq = new(adc_src_axis_agent);
    dac_dst_axis_seq = new(dac_dst_axis_agent);

    // create scoreboard
    scoreboard = new("Data Offload Verification Environment Scoreboard");

  endfunction

  //============================================================================
  // Start environment
  //   - Connect all the agents to the scoreboard
  //   - Start the agents
  //============================================================================
  task start();

    // start agents, one by one
    mng_agent.start_master();
    ddr_agent.start_slave();
    plddr_agent.start_slave();
    adc_src_axis_agent.start_master();
    dac_dst_axis_agent.start_slave();

    // connect agents to the scoreboard
    scoreboard.set_ports(ddr_agent.monitor.item_collected_port,
                         dac_dst_axis_agent.monitor.item_collected_port,
                         adc_src_axis_agent.monitor.item_collected_port
                         );

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

      adc_src_axis_seq.run();
      dac_dst_axis_seq.run();
      scoreboard.run();

    join_none
  endtask


  //============================================================================
  // Generate a data stream as an ADC
  //
  //   - clock to data rate ratio is 1
  //
  //============================================================================

  axi4stream_transaction rx_transaction;
  int adc_data_rate_ratio = 1;

  task adc_stream_gen();

    while(1) begin
      if (adc_src_axis_agent.driver.is_driver_idle) begin
        rx_transaction = adc_src_axis_agent.driver.create_transaction("");
        ADC_TRANSACTION_FAIL: assert(rx_transaction.randomize());
        rx_transaction.set_delay(adc_data_rate_ratio - 1);
        adc_src_axis_agent.driver.send(rx_transaction);
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
      scoreboard.post_rx_test();
      scoreboard.post_tx_test();
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
    adc_src_axis_seq.stop();
    adc_src_axis_agent.stop_master();
    dac_dst_axis_agent.stop_slave();
    mng_agent.stop_master();
    ddr_agent.stop_slave();
    plddr_agent.stop_slave();
    post_test();
  endtask

endclass

`endif
