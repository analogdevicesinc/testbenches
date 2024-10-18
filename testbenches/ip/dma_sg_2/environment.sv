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
  import scoreboard_pkg::*;
  import x_monitor_pkg::*;

  import `PKGIFY(test_harness, mng_axi_vip)::*;
  import `PKGIFY(test_harness, ddr_axi_vip)::*;

  import `PKGIFY(test_harness, adc_src_axis)::*;
  import `PKGIFY(test_harness, dac_dst_axis)::*;
  import `PKGIFY(test_harness, adc_dst_axi_pt)::*;
  import `PKGIFY(test_harness, dac_src_axi_pt)::*;

  class environment extends test_harness_env;

    // agents and sequencers
    `AGENT(test_harness, adc_src_axis, mst_t) adc_src_axis_agent;
    `AGENT(test_harness, dac_dst_axis, slv_t) dac_dst_axis_agent;
    `AGENT(test_harness, adc_dst_axi_pt, passthrough_mem_t) adc_dst_axi_pt_agent;
    `AGENT(test_harness, dac_src_axi_pt, passthrough_mem_t) dac_src_axi_pt_agent;

    m_axis_sequencer #(`AGENT(test_harness, adc_src_axis, mst_t),
                      `AXIS_VIP_PARAMS(test_harness, adc_src_axis)
                      ) adc_src_axis_seq;
    s_axis_sequencer #(`AGENT(test_harness, dac_dst_axis, slv_t)) dac_dst_axis_seq;
    s_axi_sequencer #(`AGENT(test_harness, adc_dst_axi_pt, passthrough_mem_t)) adc_dst_axi_pt_seq;
    s_axi_sequencer #(`AGENT(test_harness, dac_src_axi_pt, passthrough_mem_t)) dac_src_axi_pt_seq;

    x_axis_monitor #(`AGENT(test_harness, adc_src_axis, mst_t)) adc_src_axis_mon;
    x_axis_monitor #(`AGENT(test_harness, dac_dst_axis, slv_t)) dac_dst_axis_mon;
    x_axi_monitor #(`AGENT(test_harness, adc_dst_axi_pt, passthrough_mem_t), WRITE_OP) adc_dst_axi_pt_mon;
    x_axi_monitor #(`AGENT(test_harness, dac_src_axi_pt, passthrough_mem_t), READ_OP) dac_src_axi_pt_mon;

    scoreboard scoreboard_tx;
    scoreboard scoreboard_rx;

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

      virtual interface axi4stream_vip_if #(`AXIS_VIP_IF_PARAMS(test_harness, adc_src_axis)) adc_src_axis_vip_if,
      virtual interface axi4stream_vip_if #(`AXIS_VIP_IF_PARAMS(test_harness, dac_dst_axis)) dac_dst_axis_vip_if,
      virtual interface axi_vip_if #(`AXI_VIP_IF_PARAMS(test_harness, adc_dst_axi_pt)) adc_dst_axi_pt_vip_if,
      virtual interface axi_vip_if #(`AXI_VIP_IF_PARAMS(test_harness, dac_src_axi_pt)) dac_src_axi_pt_vip_if
    );

      // creating the agents
      super.new(sys_clk_vip_if, 
                dma_clk_vip_if, 
                ddr_clk_vip_if, 
                sys_rst_vip_if, 
                mng_vip_if, 
                ddr_vip_if);

      adc_src_axis_agent = new("ADC Source AXI Stream Agent", adc_src_axis_vip_if);
      dac_dst_axis_agent = new("DAC Destination AXI Stream Agent", dac_dst_axis_vip_if);
      adc_dst_axi_pt_agent = new("ADC Destination AXI Agent", adc_dst_axi_pt_vip_if);
      dac_src_axi_pt_agent = new("DAC Source AXI Agent", dac_src_axi_pt_vip_if);

      adc_src_axis_seq = new(adc_src_axis_agent);
      dac_dst_axis_seq = new(dac_dst_axis_agent);
      adc_dst_axi_pt_seq = new(adc_dst_axi_pt_agent);
      dac_src_axi_pt_seq = new(dac_src_axi_pt_agent);

      adc_src_axis_mon = new("ADC Source AXIS Transaction Monitor", adc_src_axis_agent);
      dac_dst_axis_mon = new("DAC Destination AXIS Transaction Monitor", dac_dst_axis_agent);
      adc_dst_axi_pt_mon = new("ADC Destination AXI Transaction Monitor", adc_dst_axi_pt_agent);
      dac_src_axi_pt_mon = new("DAC Source AXI Transaction Monitor", dac_src_axi_pt_agent);

      scoreboard_tx = new("Data Offload Verification Environment TX Scoreboard");
      scoreboard_rx = new("Data Offload Verification Environment RX Scoreboard");

    endfunction

    //============================================================================
    // Configure environment
    //   - Configure the sequencer VIPs with an initial configuration before starting them
    //============================================================================
    task configure();

      // ADC stub
      adc_src_axis_seq.set_data_gen_mode(DATA_GEN_MODE_AUTO_INCR);
      adc_src_axis_seq.set_keep_all();

      // DAC stub
      dac_dst_axis_seq.set_mode(XIL_AXI4STREAM_READY_GEN_NO_BACKPRESSURE);

    endtask

    //============================================================================
    // Start environment
    //   - Connect all the agents to the scoreboard
    //   - Start the agents
    //============================================================================
    task start();

      super.start();

      adc_src_axis_agent.start_master();
      dac_dst_axis_agent.start_slave();
      adc_dst_axi_pt_agent.start_monitor();
      dac_src_axi_pt_agent.start_monitor();

      scoreboard_tx.set_source_stream(dac_src_axi_pt_mon);
      scoreboard_tx.set_sink_stream(dac_dst_axis_mon);

      scoreboard_rx.set_source_stream(adc_src_axis_mon);
      scoreboard_rx.set_sink_stream(adc_dst_axi_pt_mon);

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

        adc_src_axis_mon.run();
        dac_dst_axis_mon.run();
        adc_dst_axi_pt_mon.run();
        dac_src_axi_pt_mon.run();

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

      adc_src_axis_seq.stop();
      adc_src_axis_agent.stop_master();
      dac_dst_axis_agent.stop_slave();

      post_test();

    endtask

  endclass

endpackage
