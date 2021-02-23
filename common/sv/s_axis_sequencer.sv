`include "utils.svh"

`ifndef __S_AXIS_SEQUENCER_SV__
`define __S_AXIS_SEQUENCER_SV__

import axi4stream_vip_pkg::*;
import logger_pkg::*;

class s_axis_sequencer #(type T);

    protected T agent;
    protected xil_axi4stream_data_byte byte_stream [$];
    protected xil_axi4stream_ready_gen_policy_t mode;
    protected xil_axi4stream_uint high_time;
    protected xil_axi4stream_uint low_time;

  function new(T agent);
    this.agent = agent;
    this.mode = XIL_AXI4STREAM_READY_GEN_RANDOM;
    this.low_time = 1;
    this.high_time = 1;
  endfunction

  function void set_mode(xil_axi4stream_ready_gen_policy_t mode);
    this.mode = mode;
  endfunction

  function xil_axi4stream_ready_gen_policy_t get_mode();
    return this.mode;
  endfunction

  function void set_high_time(xil_axi4stream_uint high_time);
    this.high_time = high_time;
  endfunction

  function xil_axi4stream_uint get_high_time();
    return this.high_time;
  endfunction

  function void set_low_time(xil_axi4stream_uint low_time);
    this.low_time = low_time;
  endfunction

  function xil_axi4stream_uint get_low_time();
    return this.low_time;
  endfunction

  // TODO: test different ready policies

  task user_gen_tready();
    axi4stream_ready_gen tready_gen;
    tready_gen = agent.driver.create_ready("TREADY");
    tready_gen.set_ready_policy(this.mode);
    if (this.mode != XIL_AXI4STREAM_READY_GEN_NO_BACKPRESSURE) begin
      tready_gen.set_low_time(this.low_time);
      tready_gen.set_high_time(this.high_time);
    end
    agent.driver.send_tready(tready_gen);
  endtask

  // Get transfer from the monitor and serialize data into a byte stream
  // Assumption: all bytes from beat are valid (no position or null bytes)
  task get_transfer();

    axi4stream_monitor_transaction mytrans;
    xil_axi4stream_data_beat  data_beat;

    agent.monitor.item_collected_port.get(mytrans);

    //$display(mytrans.convert2string);

    data_beat = mytrans.get_data_beat();

    for (int i=0; i<mytrans.get_data_width()/8; i++) begin
      byte_stream.push_back(data_beat[i*8+:8]);
    end
  endtask;

  task verify_byte(bit [7:0] refdata);
    bit [7:0] data;
    if (byte_stream.size() == 0) begin
      `ERROR(("Byte steam empty !!!"));
    end else begin
      data = byte_stream.pop_front();
      if (data !== refdata) begin
        `ERROR(("Unexpected data received. Expected: %0h Found: %0h Left : %0d", refdata, data, byte_stream.size()));
      end
    end
  endtask

  task run();
    user_gen_tready();
  endtask

endclass

`endif
