`include "utils.svh"
`include "axi_definitions.svh"
`include "axis_definitions.svh"

package environment_pkg;

  import logger_pkg::*;
  import adi_environment_pkg::*;
  import axi_vip_pkg::*;
  import axi4stream_vip_pkg::*;
  import m_axi_sequencer_pkg::*;
  import s_axi_sequencer_pkg::*;
  import m_axis_sequencer_pkg::*;
  import s_axis_sequencer_pkg::*;
  import adi_axi_agent_pkg::*;
  import adi_axis_agent_pkg::*;
  import vip_agent_typedef_pkg::*;
  import scoreboard_pkg::*;
  import axis_transaction_to_byte_adapter_pkg::*;
  import adi_axis_packet_pkg::*;


  class scoreboard_environment extends adi_environment;

    // Agents
    adi_axis_agent_base adc_src_axis_agent;
    adi_axi_agent_base adc_dst_axi_pt_agent;
    adi_axi_agent_base dac_src_axi_pt_agent;
    adi_axis_agent_base dac_dst_axis_agent;

    scoreboard #(logic [7:0]) scoreboard_tx;
    scoreboard #(logic [7:0]) scoreboard_rx;

    axis_transaction_to_byte_adapter axis_adapter_tx;
    axis_transaction_to_byte_adapter axis_adapter_rx;

    //============================================================================
    // Constructor
    //============================================================================
    function new (
      input string name,
      input adi_environment parent = null);

      super.new(name, parent);

      this.adc_src_axis_agent = new("ADC Source AXI Stream Agent", MASTER, this);
      this.adc_dst_axi_pt_agent = new("ADC Destination AXI Agent", PASSTHROUGH, this);
      this.dac_src_axi_pt_agent = new("DAC Source AXI Agent", PASSTHROUGH, this);
      this.dac_dst_axis_agent = new("DAC Destination AXI Stream Agent", SLAVE, this);

      this.scoreboard_tx = new("Data Offload TX Scoreboard", this);
      this.scoreboard_rx = new("Data Offload RX Scoreboard", this);

      this.axis_adapter_tx = new(
        .name("Axis Adapter TX"),
        .parent(this));

      this.axis_adapter_rx = new(
        .name("Axis Adapter RX"),
        .parent(this));
    endfunction

    //============================================================================
    // Configure environment
    //   - Configure the sequencer VIPs with an initial configuration before starting them
    //============================================================================
    task configure(input adi_axis_packet axis_packet);
      // ADC stub
      this.adc_src_axis_agent.master_sequencer.add_packet(axis_packet);

      // DAC stub
      this.dac_dst_axis_agent.slave_sequencer.set_mode(XIL_AXI4STREAM_READY_GEN_NO_BACKPRESSURE);
    endtask

    //============================================================================
    // Start environment
    //   - Connect all the agents to the scoreboard
    //   - Start the agents
    //============================================================================
    task start();
      this.adc_src_axis_agent.start_master();
      this.adc_dst_axi_pt_agent.start_monitor();

      this.dac_src_axi_pt_agent.start_monitor();
      this.dac_dst_axis_agent.start_slave();

      this.dac_src_axi_pt_agent.monitor.publisher_rx.subscribe(this.scoreboard_tx.subscriber_source);
      this.dac_dst_axis_agent.monitor.publisher.subscribe(this.axis_adapter_tx.subscriber);
      this.axis_adapter_tx.publisher.subscribe(this.scoreboard_tx.subscriber_sink);

      this.adc_src_axis_agent.monitor.publisher.subscribe(this.axis_adapter_rx.subscriber);
      this.axis_adapter_rx.publisher.subscribe(this.scoreboard_rx.subscriber_source);
      this.adc_dst_axi_pt_agent.monitor.publisher_tx.subscribe(this.scoreboard_rx.subscriber_sink);
    endtask

    //============================================================================
    // Run subroutine
    //============================================================================
    task run();
      this.scoreboard_tx.run();
      this.scoreboard_rx.run();
    endtask

    //============================================================================
    // Stop subroutine
    //============================================================================
    task stop();
      this.adc_src_axis_agent.stop_master();
      this.adc_dst_axi_pt_agent.stop_monitor();

      this.dac_src_axi_pt_agent.stop_monitor();
      this.dac_dst_axis_agent.stop_slave();
    endtask

  endclass

endpackage
