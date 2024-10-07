`include "utils.svh"

package environment_pkg;

  import m_axi_sequencer_pkg::*;
  import s_axi_sequencer_pkg::*;
  import m_axis_sequencer_pkg::*;
  import s_axis_sequencer_pkg::*;
  import logger_pkg::*;

  import axi_vip_pkg::*;
  import axi4stream_vip_pkg::*;
  import test_harness_env_pkg::*;
  import scoreboard_pack_pkg::*;
  import x_monitor_pkg::*;

  import `PKGIFY(test_harness, mng_axi_vip)::*;
  import `PKGIFY(test_harness, ddr_axi_vip)::*;

  import `PKGIFY(test_harness, tx_src_axis)::*;
  import `PKGIFY(test_harness, tx_dst_axis)::*;
  import `PKGIFY(test_harness, rx_src_axis)::*;
  import `PKGIFY(test_harness, rx_dst_axis)::*;

  class environment extends test_harness_env;

    // agents and sequencers
    `AGENT(test_harness, tx_src_axis, mst_t) tx_src_axis_agent;
    `AGENT(test_harness, tx_dst_axis, slv_t) tx_dst_axis_agent;
    `AGENT(test_harness, rx_src_axis, mst_t) rx_src_axis_agent;
    `AGENT(test_harness, rx_dst_axis, slv_t) rx_dst_axis_agent;
    
    m_axis_sequencer #(`AGENT(test_harness, tx_src_axis, mst_t),
                      `AXIS_VIP_PARAMS(test_harness, tx_src_axis)) tx_src_axis_seq;
    s_axis_sequencer #(`AGENT(test_harness, tx_dst_axis, slv_t)) tx_dst_axis_seq;
    m_axis_sequencer #(`AGENT(test_harness, rx_src_axis, mst_t),
                      `AXIS_VIP_PARAMS(test_harness, rx_src_axis)) rx_src_axis_seq;
    s_axis_sequencer #(`AGENT(test_harness, rx_dst_axis, slv_t)) rx_dst_axis_seq;

    x_axis_monitor #(`AGENT(test_harness, tx_src_axis, mst_t)) tx_src_axis_mon;
    x_axis_monitor #(`AGENT(test_harness, tx_dst_axis, slv_t)) tx_dst_axis_mon;
    x_axis_monitor #(`AGENT(test_harness, rx_src_axis, mst_t)) rx_src_axis_mon;
    x_axis_monitor #(`AGENT(test_harness, rx_dst_axis, slv_t)) rx_dst_axis_mon;

    scoreboard_pack scoreboard_tx;
    scoreboard_pack scoreboard_rx;

    //============================================================================
    // Constructor
    //============================================================================
    function new (
      virtual interface clk_vip_if #(.C_CLK_CLOCK_PERIOD(10)) sys_clk_vip_if,
      virtual interface clk_vip_if #(.C_CLK_CLOCK_PERIOD(5)) dma_clk_vip_if,
      virtual interface clk_vip_if #(.C_CLK_CLOCK_PERIOD(2.5)) ddr_clk_vip_if,

      virtual interface rst_vip_if #(.C_ASYNCHRONOUS(1), .C_RST_POLARITY(1)) sys_rst_vip_if,

      virtual interface axi_vip_if #(`AXI_VIP_IF_PARAMS(test_harness, mng_axi_vip)) mng_vip_if,
      virtual interface axi_vip_if #(`AXI_VIP_IF_PARAMS(test_harness, ddr_axi_vip)) ddr_vip_if,

      virtual interface axi4stream_vip_if #(`AXIS_VIP_IF_PARAMS(test_harness, tx_src_axis)) tx_src_axis_vip_if,
      virtual interface axi4stream_vip_if #(`AXIS_VIP_IF_PARAMS(test_harness, tx_dst_axis)) tx_dst_axis_vip_if,
      virtual interface axi4stream_vip_if #(`AXIS_VIP_IF_PARAMS(test_harness, rx_src_axis)) rx_src_axis_vip_if,
      virtual interface axi4stream_vip_if #(`AXIS_VIP_IF_PARAMS(test_harness, rx_dst_axis)) rx_dst_axis_vip_if
    );

      // creating the agents
      super.new(sys_clk_vip_if, 
                dma_clk_vip_if, 
                ddr_clk_vip_if, 
                sys_rst_vip_if, 
                mng_vip_if, 
                ddr_vip_if);

      tx_src_axis_agent = new("TX Source AXI Stream Agent", tx_src_axis_vip_if);
      tx_dst_axis_agent = new("TX Destination AXI Stream Agent", tx_dst_axis_vip_if);
      rx_src_axis_agent = new("RX Source AXI Stream Agent", rx_src_axis_vip_if);
      rx_dst_axis_agent = new("RX Destination AXI Stream Agent", rx_dst_axis_vip_if);
      
      tx_src_axis_seq = new(tx_src_axis_agent);
      tx_dst_axis_seq = new(tx_dst_axis_agent);
      rx_src_axis_seq = new(rx_src_axis_agent);
      rx_dst_axis_seq = new(rx_dst_axis_agent);
      
      tx_src_axis_mon = new("TX Source AXIS Transaction Monitor", tx_src_axis_agent);
      tx_dst_axis_mon = new("TX Destination AXIS Transaction Monitor", tx_dst_axis_agent);
      rx_src_axis_mon = new("RX Source AXIS Transaction Monitor", rx_src_axis_agent);
      rx_dst_axis_mon = new("RX Destination AXIS Transaction Monitor", rx_dst_axis_agent);

      scoreboard_tx = new("Pack Verification Environment TX Scoreboard", `CHANNELS, `SAMPLES, `WIDTH, CPACK);
      scoreboard_rx = new("Pack Verification Environment RX Scoreboard", `CHANNELS, `SAMPLES, `WIDTH, UPACK);

    endfunction

    //============================================================================
    // Configure environment
    //   - Configure the sequencer VIPs with an initial configuration before starting them
    //============================================================================
    task configure(int bytes_to_generate);

      // TX stubs
      tx_src_axis_seq.set_data_gen_mode(DATA_GEN_MODE_AUTO_INCR);
      tx_src_axis_seq.add_xfer_descriptor(bytes_to_generate, 0, 0);

      tx_dst_axis_seq.set_mode(XIL_AXI4STREAM_READY_GEN_NO_BACKPRESSURE);

      // RX stub
      rx_src_axis_seq.set_data_gen_mode(DATA_GEN_MODE_AUTO_INCR);
      rx_src_axis_seq.add_xfer_descriptor(bytes_to_generate, 0, 0);

      rx_dst_axis_seq.set_mode(XIL_AXI4STREAM_READY_GEN_NO_BACKPRESSURE);

    endtask

    //============================================================================
    // Start environment
    //   - Connect all the agents to the scoreboard
    //   - Start the agents
    //============================================================================
    task start();

      super.start();

      tx_src_axis_agent.start_master();
      tx_dst_axis_agent.start_slave();
      rx_src_axis_agent.start_master();
      rx_dst_axis_agent.start_slave();

      scoreboard_tx.set_source_stream(tx_src_axis_mon);
      scoreboard_tx.set_sink_stream(tx_dst_axis_mon);

      scoreboard_rx.set_source_stream(rx_src_axis_mon);
      scoreboard_rx.set_sink_stream(rx_dst_axis_mon);

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
        tx_src_axis_seq.run();
        tx_dst_axis_seq.run();
        rx_src_axis_seq.run();
        rx_dst_axis_seq.run();

        tx_src_axis_mon.run();
        tx_dst_axis_mon.run();
        rx_src_axis_mon.run();
        rx_dst_axis_mon.run();

        scoreboard_tx.run();
        scoreboard_rx.run();
      join_none

    endtask


    //============================================================================
    // Post test subroutine
    //============================================================================
    task post_test();
      // Evaluate the scoreboard's results
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

      super.stop();

      tx_src_axis_seq.stop();
      rx_src_axis_seq.stop();

      tx_src_axis_agent.stop_master();
      tx_dst_axis_agent.stop_slave();
      rx_src_axis_agent.stop_master();
      rx_dst_axis_agent.stop_slave();

      post_test();

    endtask

  endclass

endpackage
