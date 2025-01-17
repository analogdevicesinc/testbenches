`include "utils.svh"

package environment_pkg;

  import logger_pkg::*;
  import adi_common_pkg::*;

  import axi4stream_vip_pkg::*;
  import m_axis_sequencer_pkg::*;
  import s_axis_sequencer_pkg::*;
  import adi_axis_agent_pkg::*;
  import scoreboard_pack_pkg::*;

  class util_pack_environment #(int `AXIS_VIP_PARAM_ORDER(tx_src_axis), int `AXIS_VIP_PARAM_ORDER(tx_dst_axis), int `AXIS_VIP_PARAM_ORDER(rx_src_axis), int `AXIS_VIP_PARAM_ORDER(rx_dst_axis)) extends adi_environment;

    // agents and sequencers
    adi_axis_master_agent #(`AXIS_VIP_PARAM_ORDER(tx_src_axis)) tx_src_axis_agent;
    adi_axis_slave_agent #(`AXIS_VIP_PARAM_ORDER(tx_dst_axis)) tx_dst_axis_agent;
    adi_axis_master_agent #(`AXIS_VIP_PARAM_ORDER(rx_src_axis)) rx_src_axis_agent;
    adi_axis_slave_agent #(`AXIS_VIP_PARAM_ORDER(rx_dst_axis)) rx_dst_axis_agent;
    
    scoreboard_pack #(logic [7:0]) scoreboard_tx;
    scoreboard_pack #(logic [7:0]) scoreboard_rx;

    //============================================================================
    // Constructor
    //============================================================================
    function new (
      input string name,

      virtual interface axi4stream_vip_if #(`AXIS_VIP_IF_PARAMS(tx_src_axis)) tx_src_axis_vip_if,
      virtual interface axi4stream_vip_if #(`AXIS_VIP_IF_PARAMS(tx_dst_axis)) tx_dst_axis_vip_if,
      virtual interface axi4stream_vip_if #(`AXIS_VIP_IF_PARAMS(rx_src_axis)) rx_src_axis_vip_if,
      virtual interface axi4stream_vip_if #(`AXIS_VIP_IF_PARAMS(rx_dst_axis)) rx_dst_axis_vip_if);

      // creating the agents
      super.new(name);

      this.tx_src_axis_agent = new("TX Source AXI Stream Agent", tx_src_axis_vip_if, this);
      this.tx_dst_axis_agent = new("TX Destination AXI Stream Agent", tx_dst_axis_vip_if, this);
      this.rx_src_axis_agent = new("RX Source AXI Stream Agent", rx_src_axis_vip_if, this);
      this.rx_dst_axis_agent = new("RX Destination AXI Stream Agent", rx_dst_axis_vip_if, this);

      this.scoreboard_tx = new("TX Scoreboard", `CHANNELS, `SAMPLES, `WIDTH, CPACK, this);
      this.scoreboard_rx = new("RX Scoreboard", `CHANNELS, `SAMPLES, `WIDTH, UPACK, this);
    endfunction

    //============================================================================
    // Configure environment
    //   - Configure the sequencer VIPs with an initial configuration before starting them
    //============================================================================
    task configure(int bytes_to_generate);
      // TX stubs
      this.tx_src_axis_agent.sequencer.set_data_gen_mode(DATA_GEN_MODE_AUTO_INCR);
      this.tx_src_axis_agent.sequencer.add_xfer_descriptor(bytes_to_generate, 0, 0);

      this.tx_dst_axis_agent.sequencer.set_mode(XIL_AXI4STREAM_READY_GEN_NO_BACKPRESSURE);

      // RX stub
      this.rx_src_axis_agent.sequencer.set_data_gen_mode(DATA_GEN_MODE_AUTO_INCR);
      this.rx_src_axis_agent.sequencer.add_xfer_descriptor(bytes_to_generate, 0, 0);

      this.rx_dst_axis_agent.sequencer.set_mode(XIL_AXI4STREAM_READY_GEN_NO_BACKPRESSURE);
    endtask

    //============================================================================
    // Start environment
    //   - Connect all the agents to the scoreboard
    //   - Start the agents
    //============================================================================
    task start();
      this.tx_src_axis_agent.agent.start_master();
      this.tx_dst_axis_agent.agent.start_slave();
      this.rx_src_axis_agent.agent.start_master();
      this.rx_dst_axis_agent.agent.start_slave();

      this.tx_src_axis_agent.monitor.publisher.subscribe(this.scoreboard_tx.subscriber_source);
      this.tx_dst_axis_agent.monitor.publisher.subscribe(this.scoreboard_tx.subscriber_sink);

      this.rx_src_axis_agent.monitor.publisher.subscribe(this.scoreboard_rx.subscriber_source);
      this.rx_dst_axis_agent.monitor.publisher.subscribe(this.scoreboard_rx.subscriber_sink);
    endtask

    //============================================================================
    // Run subroutine
    //============================================================================
    task run();
      fork
        this.tx_src_axis_agent.sequencer.run();
        this.tx_dst_axis_agent.sequencer.run();
        this.rx_src_axis_agent.sequencer.run();
        this.rx_dst_axis_agent.sequencer.run();

        this.scoreboard_tx.run();
        this.scoreboard_rx.run();
      join_none
    endtask

    //============================================================================
    // Stop subroutine
    //============================================================================
    task stop();
      this.tx_src_axis_agent.sequencer.stop();
      this.rx_src_axis_agent.sequencer.stop();

      this.tx_src_axis_agent.agent.stop_master();
      this.tx_dst_axis_agent.agent.stop_slave();
      this.rx_src_axis_agent.agent.stop_master();
      this.rx_dst_axis_agent.agent.stop_slave();
    endtask

  endclass

endpackage
