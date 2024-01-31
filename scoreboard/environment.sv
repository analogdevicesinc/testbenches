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

  import `PKGIFY(test_harness, adc_src_axis_0)::*;
  import `PKGIFY(test_harness, dac_dst_axis_0)::*;
  import `PKGIFY(test_harness, adc_dst_axi_pt_0)::*;
  import `PKGIFY(test_harness, dac_src_axi_pt_0)::*;
  
  import `PKGIFY(test_harness, adc_src_axis_1)::*;
  import `PKGIFY(test_harness, dac_dst_axis_1)::*;
  import `PKGIFY(test_harness, adc_dst_axi_pt_1)::*;
  import `PKGIFY(test_harness, dac_src_axi_pt_1)::*;

  class environment extends test_harness_env;

    // agents and sequencers
    `AGENT(test_harness, adc_src_axis_0, mst_t) adc_src_axis_agent_0;
    `AGENT(test_harness, dac_dst_axis_0, slv_t) dac_dst_axis_agent_0;
    `AGENT(test_harness, adc_dst_axi_pt_0, passthrough_mem_t) adc_dst_axi_pt_agent_0;
    `AGENT(test_harness, dac_src_axi_pt_0, passthrough_mem_t) dac_src_axi_pt_agent_0;

    `AGENT(test_harness, adc_src_axis_1, mst_t) adc_src_axis_agent_1;
    `AGENT(test_harness, dac_dst_axis_1, slv_t) dac_dst_axis_agent_1;
    `AGENT(test_harness, adc_dst_axi_pt_1, passthrough_mem_t) adc_dst_axi_pt_agent_1;
    `AGENT(test_harness, dac_src_axi_pt_1, passthrough_mem_t) dac_src_axi_pt_agent_1;

    m_axis_sequencer #(`AGENT(test_harness, adc_src_axis_0, mst_t),
                      `AXIS_VIP_PARAMS(test_harness, adc_src_axis_0)
                      ) adc_src_axis_seq_0;
    s_axis_sequencer #(`AGENT(test_harness, dac_dst_axis_0, slv_t)) dac_dst_axis_seq_0;
    s_axi_sequencer #(`AGENT(test_harness, adc_dst_axi_pt_0, passthrough_mem_t)) adc_dst_axi_pt_seq_0;
    s_axi_sequencer #(`AGENT(test_harness, dac_src_axi_pt_0, passthrough_mem_t)) dac_src_axi_pt_seq_0;

    m_axis_sequencer #(`AGENT(test_harness, adc_src_axis_1, mst_t),
                      `AXIS_VIP_PARAMS(test_harness, adc_src_axis_1)
                      ) adc_src_axis_seq_1;
    s_axis_sequencer #(`AGENT(test_harness, dac_dst_axis_1, slv_t)) dac_dst_axis_seq_1;
    s_axi_sequencer #(`AGENT(test_harness, adc_dst_axi_pt_1, passthrough_mem_t)) adc_dst_axi_pt_seq_1;
    s_axi_sequencer #(`AGENT(test_harness, dac_src_axi_pt_1, passthrough_mem_t)) dac_src_axi_pt_seq_1;

    x_axis_monitor #(`AGENT(test_harness, adc_src_axis_0, mst_t)) adc_src_axis_0_mon;
    x_axis_monitor #(`AGENT(test_harness, dac_dst_axis_0, slv_t)) dac_dst_axis_0_mon;
    x_axi_monitor #(`AGENT(test_harness, adc_dst_axi_pt_0, passthrough_mem_t)) adc_dst_axi_pt_0_mon;
    x_axi_monitor #(`AGENT(test_harness, dac_src_axi_pt_0, passthrough_mem_t)) dac_src_axi_pt_0_mon;

    x_axis_monitor #(`AGENT(test_harness, adc_src_axis_1, mst_t)) adc_src_axis_1_mon;
    x_axis_monitor #(`AGENT(test_harness, dac_dst_axis_1, slv_t)) dac_dst_axis_1_mon;
    x_axi_monitor #(`AGENT(test_harness, adc_dst_axi_pt_1, passthrough_mem_t)) adc_dst_axi_pt_1_mon;
    x_axi_monitor #(`AGENT(test_harness, dac_src_axi_pt_1, passthrough_mem_t)) dac_src_axi_pt_1_mon;

    scoreboard scoreboard_tx0;
    scoreboard scoreboard_rx0;
    scoreboard scoreboard_tx1;
    scoreboard scoreboard_rx1;

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

      virtual interface axi4stream_vip_if #(`AXIS_VIP_IF_PARAMS(test_harness, adc_src_axis_0)) adc_src_axis_vip_if_0,
      virtual interface axi4stream_vip_if #(`AXIS_VIP_IF_PARAMS(test_harness, dac_dst_axis_0)) dac_dst_axis_vip_if_0,
      virtual interface axi_vip_if #(`AXI_VIP_IF_PARAMS(test_harness, adc_dst_axi_pt_0)) adc_dst_axi_pt_vip_if_0,
      virtual interface axi_vip_if #(`AXI_VIP_IF_PARAMS(test_harness, dac_src_axi_pt_0)) dac_src_axi_pt_vip_if_0,

      virtual interface axi4stream_vip_if #(`AXIS_VIP_IF_PARAMS(test_harness, adc_src_axis_1)) adc_src_axis_vip_if_1,
      virtual interface axi4stream_vip_if #(`AXIS_VIP_IF_PARAMS(test_harness, dac_dst_axis_1)) dac_dst_axis_vip_if_1,
      virtual interface axi_vip_if #(`AXI_VIP_IF_PARAMS(test_harness, adc_dst_axi_pt_1)) adc_dst_axi_pt_vip_if_1,
      virtual interface axi_vip_if #(`AXI_VIP_IF_PARAMS(test_harness, dac_src_axi_pt_1)) dac_src_axi_pt_vip_if_1

    );

      // creating the agents
      super.new(sys_clk_vip_if, 
                dma_clk_vip_if, 
                ddr_clk_vip_if, 
                sys_rst_vip_if, 
                mng_vip_if, 
                ddr_vip_if);

      adc_src_axis_agent_0 = new("ADC Source AXI Stream Agent 0", adc_src_axis_vip_if_0);
      dac_dst_axis_agent_0 = new("DAC Destination AXI Stream Agent 0", dac_dst_axis_vip_if_0);
      adc_dst_axi_pt_agent_0 = new("ADC Destination AXI Agent 0", adc_dst_axi_pt_vip_if_0);
      dac_src_axi_pt_agent_0 = new("DAC Source AXI Agent 0", dac_src_axi_pt_vip_if_0);

      adc_src_axis_agent_1 = new("ADC Source AXI Stream Agent 1", adc_src_axis_vip_if_1);
      dac_dst_axis_agent_1 = new("DAC Destination AXI Stream Agent 1", dac_dst_axis_vip_if_1);
      adc_dst_axi_pt_agent_1 = new("ADC Destination AXI Agent 1", adc_dst_axi_pt_vip_if_1);
      dac_src_axi_pt_agent_1 = new("DAC Source AXI Agent 1", dac_src_axi_pt_vip_if_1);

      adc_src_axis_seq_0 = new(adc_src_axis_agent_0);
      dac_dst_axis_seq_0 = new(dac_dst_axis_agent_0);
      adc_dst_axi_pt_seq_0 = new(adc_dst_axi_pt_agent_0);
      dac_src_axi_pt_seq_0 = new(dac_src_axi_pt_agent_0);

      adc_src_axis_seq_1 = new(adc_src_axis_agent_1);
      dac_dst_axis_seq_1 = new(dac_dst_axis_agent_1);
      adc_dst_axi_pt_seq_1 = new(adc_dst_axi_pt_agent_1);
      dac_src_axi_pt_seq_1 = new(dac_src_axi_pt_agent_1);

      adc_src_axis_0_mon = new("ADC Source AXIS 0 Transaction Monitor", adc_src_axis_agent_0);
      dac_dst_axis_0_mon = new("DAC Destination AXIS 0 Transaction Monitor", dac_dst_axis_agent_0);
      adc_dst_axi_pt_0_mon = new("ADC Destination AXI 0 Transaction Monitor", adc_dst_axi_pt_agent_0);
      dac_src_axi_pt_0_mon = new("DAC Source AXI 0 Transaction Monitor", dac_src_axi_pt_agent_0);

      adc_src_axis_1_mon = new("ADC Source AXIS 1 Transaction Monitor", adc_src_axis_agent_1);
      dac_dst_axis_1_mon = new("DAC Destination AXIS 1 Transaction Monitor", dac_dst_axis_agent_1);
      adc_dst_axi_pt_1_mon = new("ADC Destination AXI 1 Transaction Monitor", adc_dst_axi_pt_agent_1);
      dac_src_axi_pt_1_mon = new("DAC Source AXI 1 Transaction Monitor", dac_src_axi_pt_agent_1);

      scoreboard_tx0 = new("Data Offload Verification Environment TX 0 Scoreboard");
      scoreboard_rx0 = new("Data Offload Verification Environment RX 0 Scoreboard");
      scoreboard_tx1 = new("Data Offload Verification Environment TX 1 Scoreboard");
      scoreboard_rx1 = new("Data Offload Verification Environment RX 1 Scoreboard");

    endfunction

    //============================================================================
    // Configure environment
    //   - Configure the sequencer VIPs with an initial configuration before starting them
    //============================================================================
    task configure(int bytes_to_generate);

      // ADC stub
      adc_src_axis_seq_0.set_data_gen_mode(1);
      adc_src_axis_seq_0.set_rand_valid(0);
      adc_src_axis_seq_0.add_xfer_descriptor(bytes_to_generate, 0, 0);

      // DAC stub
      dac_dst_axis_seq_0.set_mode(XIL_AXI4STREAM_READY_GEN_NO_BACKPRESSURE);

      // ADC stub
      adc_src_axis_seq_1.set_data_gen_mode(1);
      adc_src_axis_seq_1.set_rand_valid(0);
      adc_src_axis_seq_1.add_xfer_descriptor(bytes_to_generate, 0, 0);

      // DAC stub
      dac_dst_axis_seq_1.set_mode(XIL_AXI4STREAM_READY_GEN_NO_BACKPRESSURE);

    endtask

    //============================================================================
    // Start environment
    //   - Connect all the agents to the scoreboard
    //   - Start the agents
    //============================================================================
    task start();

      super.start();

      adc_src_axis_agent_0.start_master();
      dac_dst_axis_agent_0.start_slave();
      adc_dst_axi_pt_agent_0.start_monitor();
      dac_src_axi_pt_agent_0.start_monitor();
      
      adc_src_axis_agent_1.start_master();
      dac_dst_axis_agent_1.start_slave();
      adc_dst_axi_pt_agent_1.start_monitor();
      dac_src_axi_pt_agent_1.start_monitor();

      adc_src_axis_seq_0.start();
      adc_src_axis_seq_1.start();

      scoreboard_tx0.set_source_stream(dac_src_axi_pt_0_mon, dac_src_axi_pt_0_mon.tx_mailbox);
      scoreboard_tx0.set_sink_stream(dac_dst_axis_0_mon, dac_dst_axis_0_mon.x_mailbox);

      scoreboard_rx0.set_source_stream(adc_src_axis_0_mon, adc_src_axis_0_mon.x_mailbox);
      scoreboard_rx0.set_sink_stream(adc_dst_axi_pt_0_mon, adc_dst_axi_pt_0_mon.rx_mailbox);

      scoreboard_tx1.set_source_stream(dac_src_axi_pt_1_mon, dac_src_axi_pt_1_mon.tx_mailbox);
      scoreboard_tx1.set_sink_stream(dac_dst_axis_1_mon, dac_dst_axis_1_mon.x_mailbox);

      scoreboard_rx1.set_source_stream(adc_src_axis_1_mon, adc_src_axis_1_mon.x_mailbox);
      scoreboard_rx1.set_sink_stream(adc_dst_axi_pt_1_mon, adc_dst_axi_pt_1_mon.rx_mailbox);

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
        adc_src_axis_seq_0.run();
        dac_dst_axis_seq_0.run();

        adc_src_axis_seq_1.run();
        dac_dst_axis_seq_1.run();

        adc_src_axis_0_mon.run();
        dac_dst_axis_0_mon.run();
        adc_dst_axi_pt_0_mon.run();
        dac_src_axi_pt_0_mon.run();

        adc_src_axis_1_mon.run();
        dac_dst_axis_1_mon.run();
        adc_dst_axi_pt_1_mon.run();
        dac_src_axi_pt_1_mon.run();

        scoreboard_tx0.run();
        scoreboard_rx0.run();

        scoreboard_tx1.run();
        scoreboard_rx1.run();
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

      adc_src_axis_seq_0.stop();
      adc_src_axis_agent_0.stop_master();
      dac_dst_axis_agent_0.stop_slave();

      adc_src_axis_seq_1.stop();
      adc_src_axis_agent_1.stop_master();
      dac_dst_axis_agent_1.stop_slave();

      post_test();

    endtask

  endclass

endpackage
