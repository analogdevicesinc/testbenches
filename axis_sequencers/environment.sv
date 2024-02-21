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

  import `PKGIFY(test_harness, mng_axi_vip)::*;
  import `PKGIFY(test_harness, ddr_axi_vip)::*;

  import `PKGIFY(test_harness, src_axis)::*;
  import `PKGIFY(test_harness, dst_axis)::*;

  class environment extends test_harness_env;

    // agents and sequencers
    `AGENT(test_harness, src_axis, mst_t) src_axis_agent;
    `AGENT(test_harness, dst_axis, slv_t) dst_axis_agent;

    m_axis_sequencer #(`AGENT(test_harness, src_axis, mst_t),
                      `AXIS_VIP_PARAMS(test_harness, src_axis)
                      ) src_axis_seq;
    s_axis_sequencer #(`AGENT(test_harness, dst_axis, slv_t)) dst_axis_seq;

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

      virtual interface axi4stream_vip_if #(`AXIS_VIP_IF_PARAMS(test_harness, src_axis)) src_axis_vip_if,
      virtual interface axi4stream_vip_if #(`AXIS_VIP_IF_PARAMS(test_harness, dst_axis)) dst_axis_vip_if
    );

      // creating the agents
      super.new(sys_clk_vip_if, 
                dma_clk_vip_if, 
                ddr_clk_vip_if, 
                sys_rst_vip_if, 
                mng_vip_if, 
                ddr_vip_if);

      src_axis_agent = new("Source AXI Stream Agent", src_axis_vip_if);
      dst_axis_agent = new("Destination AXI Stream Agent", dst_axis_vip_if);

      src_axis_seq = new(src_axis_agent);
      dst_axis_seq = new(dst_axis_agent);

    endfunction

    //============================================================================
    // Configure environment
    //   - Configure the sequencer VIPs with an initial configuration before starting them
    //============================================================================
    task configure();

      xil_axi4stream_ready_gen_policy_t dac_mode;

      // source stub
      src_axis_seq.set_stop_policy(STOP_POLICY_PACKET);

      // destination stub
      dac_mode = XIL_AXI4STREAM_READY_GEN_NO_BACKPRESSURE;
      dst_axis_seq.set_mode(dac_mode);

    endtask

    //============================================================================
    // Start environment
    //============================================================================
    task start();

      super.start();

      src_axis_agent.start_master();
      dst_axis_agent.start_slave();

    endtask

    //============================================================================
    // Start the test
    //============================================================================
    task test();
      fork
        src_axis_seq.run();
        dst_axis_seq.run();
      join_none
    endtask


    //============================================================================
    // Post test subroutine
    //============================================================================
    task post_test();
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
        src_axis_seq.stop();
        src_axis_agent.stop_master();
        dst_axis_agent.stop_slave();
      post_test();

    endtask

  endclass

endpackage
