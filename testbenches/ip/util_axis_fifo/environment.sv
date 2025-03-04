`include "utils.svh"
`include "axis_definitions.svh"

package environment_pkg;

  import logger_pkg::*;
  import adi_common_pkg::*;
  import axi4stream_vip_pkg::*;
  import m_axis_sequencer_pkg::*;
  import s_axis_sequencer_pkg::*;
  import adi_axis_agent_pkg::*;
  import scoreboard_pkg::*;

  class util_axis_fifo_environment #(`AXIS_VIP_PARAM_DECL(input_axis), `AXIS_VIP_PARAM_DECL(output_axis), int INPUT_CLK, int OUTPUT_CLK) extends adi_environment;

    virtual interface clk_vip_if #(.C_CLK_CLOCK_PERIOD(INPUT_CLK)) input_clk_vip_if;
    virtual interface clk_vip_if #(.C_CLK_CLOCK_PERIOD(OUTPUT_CLK)) output_clk_vip_if;

    adi_axis_master_agent #(`AXIS_VIP_PARAM_ORDER(input_axis)) input_axis_agent;
    adi_axis_slave_agent #(`AXIS_VIP_PARAM_ORDER(output_axis)) output_axis_agent;

    scoreboard #(logic [7:0]) scoreboard_inst;

    //============================================================================
    // Constructor
    //============================================================================
    function new (
      input string name,

      virtual interface clk_vip_if #(.C_CLK_CLOCK_PERIOD(INPUT_CLK)) input_clk_vip_if,
      virtual interface clk_vip_if #(.C_CLK_CLOCK_PERIOD(OUTPUT_CLK)) output_clk_vip_if,

      virtual interface axi4stream_vip_if #(`AXIS_VIP_IF_PARAMS(input_axis)) input_axis_vip_if,
      virtual interface axi4stream_vip_if #(`AXIS_VIP_IF_PARAMS(output_axis)) output_axis_vip_if);

      // creating the agents
      super.new(name);

      this.input_clk_vip_if = input_clk_vip_if;
      this.output_clk_vip_if = output_clk_vip_if;

      this.input_axis_agent = new("Input AXI Stream Agent", input_axis_vip_if, this);
      this.output_axis_agent = new("Output AXI Stream Agent", output_axis_vip_if, this);

      this.scoreboard_inst = new("Util AXIS FIFO Scoreboard", this);
    endfunction

    //============================================================================
    // Configure environment
    //============================================================================
    task configure();
      // configuration for input
      this.input_axis_agent.sequencer.set_stop_policy(STOP_POLICY_PACKET);
      this.input_axis_agent.sequencer.set_data_gen_mode(DATA_GEN_MODE_AUTO_INCR);
      this.input_axis_agent.sequencer.set_descriptor_gen_mode(1);
      this.input_axis_agent.sequencer.set_data_beat_delay(0);
      this.input_axis_agent.sequencer.set_descriptor_delay(0);
      this.input_axis_agent.sequencer.set_inactive_drive_output_0();

      // configuration for output
      this.output_axis_agent.sequencer.set_mode(XIL_AXI4STREAM_READY_GEN_NO_BACKPRESSURE);
    endtask

    //============================================================================
    // Start environment
    //   - Connect all the agents to the scoreboard
    //   - Start the agents
    //============================================================================
    task start();
      this.input_clk_vip_if.start_clock();
      this.output_clk_vip_if.start_clock();

      this.input_axis_agent.start();
      this.output_axis_agent.start();

      this.input_axis_agent.monitor.publisher.subscribe(this.scoreboard_inst.subscriber_source);
      this.output_axis_agent.monitor.publisher.subscribe(this.scoreboard_inst.subscriber_sink);
    endtask

    //============================================================================
    // Run subroutine
    //============================================================================
    task run();
      fork
        this.input_axis_agent.run();
        this.output_axis_agent.run();

        this.scoreboard_inst.run();
      join_none
    endtask

    //============================================================================
    // Stop subroutine
    //============================================================================
    task stop();
      this.input_axis_agent.stop();
      this.output_axis_agent.stop();
    endtask

  endclass

endpackage
