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

  import `PKGIFY(test_harness, input_axis)::*;
  import `PKGIFY(test_harness, output_axis)::*;

  class environment extends test_harness_env;

    virtual interface clk_if input_clk_if;
    virtual interface clk_if output_clk_if;

    // agents and sequencers
    `AGENT(test_harness, input_axis, mst_t) input_axis_agent;
    `AGENT(test_harness, output_axis, slv_t) output_axis_agent;

    m_axis_sequencer #(`AGENT(test_harness, input_axis, mst_t),
                      `AXIS_VIP_PARAMS(test_harness, input_axis)
                      ) input_axis_seq;
    s_axis_sequencer #(`AGENT(test_harness, output_axis, slv_t)) output_axis_seq;

    x_axis_monitor #(`AGENT(test_harness, input_axis, mst_t)) input_axis_mon;
    x_axis_monitor #(`AGENT(test_harness, output_axis, slv_t)) output_axis_mon;

    scoreboard scoreboard_inst;

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

      virtual interface clk_if input_clk_if,
      virtual interface clk_if output_clk_if,

      virtual interface axi4stream_vip_if #(`AXIS_VIP_IF_PARAMS(test_harness, input_axis)) input_axis_vip_if,
      virtual interface axi4stream_vip_if #(`AXIS_VIP_IF_PARAMS(test_harness, output_axis)) output_axis_vip_if
    );

      // creating the agents
      super.new(sys_clk_vip_if, 
                dma_clk_vip_if, 
                ddr_clk_vip_if, 
                sys_rst_vip_if, 
                mng_vip_if, 
                ddr_vip_if);

      this.input_clk_if = input_clk_if;
      this.output_clk_if = output_clk_if;

      input_axis_agent = new("Input AXI Stream Agent", input_axis_vip_if);
      output_axis_agent = new("Output AXI Stream Agent", output_axis_vip_if);

      input_axis_seq = new(input_axis_agent);
      output_axis_seq = new(output_axis_agent);

      input_axis_mon = new("Input AXIS Transaction Monitor", input_axis_agent);
      output_axis_mon = new("Output AXIS Transaction Monitor", output_axis_agent);

      scoreboard_inst = new("Verification Environment Scoreboard");

    endfunction

    //============================================================================
    // Configure environment
    //============================================================================
    task configure();

      // configuration for input
      this.input_axis_seq.set_stop_policy(STOP_POLICY_PACKET);
      this.input_axis_seq.set_data_gen_mode(DATA_GEN_MODE_AUTO_INCR);
      this.input_axis_seq.set_descriptor_gen_mode(1);
      this.input_axis_seq.set_data_beat_delay(0);
      this.input_axis_seq.set_descriptor_delay(0);
      this.input_axis_seq.set_inactive_drive_output_0();

      // configuration for output
      this.output_axis_seq.set_mode(XIL_AXI4STREAM_READY_GEN_NO_BACKPRESSURE);

      // this.output_axis_seq.set_use_variable_ranges();
      // this.output_axis_seq.set_high_time_range(1,1);
      // this.output_axis_seq.set_low_time_range(0,0);

      // this.output_axis_seq.clr_use_variable_ranges();
      // this.output_axis_seq.set_high_time(1);
      // this.output_axis_seq.set_low_time(1);

    endtask

    //============================================================================
    // Start environment
    //   - Connect all the agents to the scoreboard
    //   - Start the agents
    //============================================================================
    task start();

      super.start();

      input_clk_if.start_clock(`INPUT_CLK);
      output_clk_if.start_clock(`OUTPUT_CLK);

      input_axis_agent.start_master();
      output_axis_agent.start_slave();

      scoreboard_inst.set_source_stream(input_axis_mon);
      scoreboard_inst.set_sink_stream(output_axis_mon);

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
        input_axis_seq.run();
        output_axis_seq.run();

        input_axis_mon.run();
        output_axis_mon.run();

        scoreboard_inst.run();
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

      input_axis_seq.stop();
      input_axis_agent.stop_master();
      output_axis_agent.stop_slave();

      post_test();

    endtask

  endclass

endpackage
