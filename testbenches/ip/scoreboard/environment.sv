`include "utils.svh"
`include "axi_definitions.svh"
`include "axis_definitions.svh"

package environment_pkg;

  import logger_pkg::*;
  import adi_common_pkg::*;

  import axi_vip_pkg::*;
  import axi4stream_vip_pkg::*;
  import m_axi_sequencer_pkg::*;
  import s_axi_sequencer_pkg::*;
  import m_axis_sequencer_pkg::*;
  import s_axis_sequencer_pkg::*;
  import adi_axi_agent_pkg::*;
  import adi_axis_agent_pkg::*;
  import scoreboard_pkg::*;


  class scoreboard_environment #(int `AXIS_VIP_PARAM_ORDER(adc_src), int `AXIS_VIP_PARAM_ORDER(dac_dst), int `AXI_VIP_PARAM_ORDER(adc_dst_pt), int `AXI_VIP_PARAM_ORDER(dac_src_pt)) extends adi_environment;

    // Agents
    adi_axis_master_agent #(`AXIS_VIP_PARAM_ORDER(adc_src)) adc_src_axis_agent;
    adi_axis_slave_agent #(`AXIS_VIP_PARAM_ORDER(dac_dst)) dac_dst_axis_agent;
    adi_axi_passthrough_mem_agent #(`AXI_VIP_PARAM_ORDER(adc_dst_pt)) adc_dst_axi_pt_agent;
    adi_axi_passthrough_mem_agent #(`AXI_VIP_PARAM_ORDER(dac_src_pt)) dac_src_axi_pt_agent;

    scoreboard scoreboard_tx;
    scoreboard scoreboard_rx;

    //============================================================================
    // Constructor
    //============================================================================
    function new (
      input string name,

      virtual interface axi4stream_vip_if #(`AXIS_VIP_IF_PARAMS(adc_src)) adc_src_axis_vip_if,
      virtual interface axi4stream_vip_if #(`AXIS_VIP_IF_PARAMS(dac_dst)) dac_dst_axis_vip_if,
      virtual interface axi_vip_if #(`AXI_VIP_IF_PARAMS(adc_dst_pt)) adc_dst_axi_pt_vip_if,
      virtual interface axi_vip_if #(`AXI_VIP_IF_PARAMS(dac_src_pt)) dac_src_axi_pt_vip_if);

      // creating the agents
      super.new(name);

      this.adc_src_axis_agent = new("ADC Source AXI Stream Agent", adc_src_axis_vip_if, this);
      this.dac_dst_axis_agent = new("DAC Destination AXI Stream Agent", dac_dst_axis_vip_if, this);
      this.adc_dst_axi_pt_agent = new("ADC Destination AXI Agent", adc_dst_axi_pt_vip_if, this);
      this.dac_src_axi_pt_agent = new("DAC Source AXI Agent", dac_src_axi_pt_vip_if, this);

      this.scoreboard_tx = new("Data Offload TX Scoreboard", this);
      this.scoreboard_rx = new("Data Offload RX Scoreboard", this);
    endfunction

    //============================================================================
    // Configure environment
    //   - Configure the sequencer VIPs with an initial configuration before starting them
    //============================================================================
    task configure(int bytes_to_generate);
      // ADC stub
      this.adc_src_axis_agent.sequencer.set_data_gen_mode(DATA_GEN_MODE_AUTO_INCR);
      this.adc_src_axis_agent.sequencer.add_xfer_descriptor(bytes_to_generate, 0, 0);

      // DAC stub
      this.dac_dst_axis_agent.sequencer.set_mode(XIL_AXI4STREAM_READY_GEN_NO_BACKPRESSURE);
    endtask

    //============================================================================
    // Start environment
    //   - Connect all the agents to the scoreboard
    //   - Start the agents
    //============================================================================
    task start();
      this.adc_src_axis_agent.agent.start_master();
      this.dac_dst_axis_agent.agent.start_slave();
      this.adc_dst_axi_pt_agent.agent.start_monitor();
      this.dac_src_axi_pt_agent.agent.start_monitor();

      this.dac_src_axi_pt_agent.monitor.publisher_rx.subscribe(this.scoreboard_tx.subscriber_source);
      this.dac_dst_axis_agent.monitor.publisher.subscribe(this.scoreboard_tx.subscriber_sink);

      this.adc_src_axis_agent.monitor.publisher.subscribe(this.scoreboard_rx.subscriber_source);
      this.adc_dst_axi_pt_agent.monitor.publisher_tx.subscribe(this.scoreboard_rx.subscriber_sink);
    endtask

    //============================================================================
    // Run subroutine
    //============================================================================
    task run();
      fork
        this.adc_src_axis_agent.sequencer.run();
        this.dac_dst_axis_agent.sequencer.run();

        this.adc_src_axis_agent.monitor.run();
        this.dac_dst_axis_agent.monitor.run();
        this.adc_dst_axi_pt_agent.monitor.run();
        this.dac_src_axi_pt_agent.monitor.run();

        this.scoreboard_tx.run();
        this.scoreboard_rx.run();
      join_none
    endtask

    //============================================================================
    // Stop subroutine
    //============================================================================
    task stop();
      this.adc_src_axis_agent.sequencer.stop();
      this.adc_src_axis_agent.agent.stop_master();
      this.dac_dst_axis_agent.agent.stop_slave();
    endtask

  endclass

endpackage
