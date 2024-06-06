// ***************************************************************************
// ***************************************************************************
// Copyright 2014 - 2024 (c) Analog Devices, Inc. All rights reserved.
//
// In this HDL repository, there are many different and unique modules, consisting
// of various HDL (Verilog or VHDL) components. The individual modules are
// developed independently, and may be accompanied by separate and unique license
// terms.
//
// The user should read each of these license terms, and understand the
// freedoms and responsabilities that he or she has by using this source/core.
//
// This core is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
// A PARTICULAR PURPOSE.
//
// Redistribution and use of source or resulting binaries, with or without modification
// of this file, are permitted under one of the following two license terms:
//
//   1. The GNU General Public License version 2 as published by the
//      Free Software Foundation, which can be found in the top level directory
//      of this repository (LICENSE_GPL2), and also online at:
//      <https://www.gnu.org/licenses/old-licenses/gpl-2.0.html>
//
// OR
//
//   2. An ADI specific BSD license, which can be found in the top level directory
//      of this repository (LICENSE_ADIBSD), and also on-line at:
//      https://github.com/analogdevicesinc/hdl/blob/master/LICENSE_ADIBSD
//      This will allow to generate bit files and not release the source code,
//      as long as it attaches to an ADI device.
//
// ***************************************************************************
// ***************************************************************************

`include "utils.svh"

package m_axis_sequencer_pkg;

  import axi4stream_vip_pkg::*;
  import logger_pkg::*;

  typedef enum {
      DATA_GEN_MODE_TEST_DATA,  // get data from test
      DATA_GEN_MODE_AUTO_INCR,  // autogenerate incrementing data until aborted
      DATA_GEN_MODE_AUTO_RAND   // autogenerate randomized data until aborted
  } data_gen_mode_t;

  typedef enum bit [1:0] {
    STOP_POLICY_IMMEDIATE = 2'h0,        // disable as soon as possible
    STOP_POLICY_DATA_BEAT = 2'h1,        // disable after the data beat has been transferred
    STOP_POLICY_PACKET = 2'h2,           // disable after the packet has been transferred
    STOP_POLICY_DESCRIPTOR_QUEUE = 2'h3  // disable after the packet queue has been transferred
  } stop_policy_t;


  class m_axis_sequencer_base;

    protected bit enabled;
    protected bit queue_empty_sig;
    protected event enable_ev;
    protected event disable_ev;

    protected data_gen_mode_t data_gen_mode;

    protected bit descriptor_gen_mode;  // 0 - get descriptor from test;
                                        // 1 - autogenerate descriptor based on the first descriptor from test until aborted
    
    protected int byte_count;

    protected int data_beat_delay; // delay in clock cycles
    protected int descriptor_delay; // delay in clock cycles

    protected stop_policy_t stop_policy;

    protected event data_av_ev;
    protected event beat_done;
    protected event packet_done;
    protected event queue_empty;
    protected event byte_stream_ev;
    protected event queue_ev;

    protected axi4stream_transaction trans;
    protected xil_axi4stream_data_byte byte_stream [$];

    typedef struct{
      int num_bytes;
      bit gen_last;
      bit gen_sync;
    } descriptor_t;

    protected descriptor_t descriptor_q [$];


    // new
    function new();
      this.enabled = 1'b0;
      this.data_gen_mode = DATA_GEN_MODE_AUTO_INCR;
      this.descriptor_gen_mode = 1'b0;
      this.byte_count = 0;
      this.data_beat_delay = 0;
      this.descriptor_delay = 0;
      this.stop_policy = STOP_POLICY_DATA_BEAT;
      this.queue_empty_sig = 1;
    endfunction: new


    // set vif proxy to drive outputs with 0 when inactive
    virtual task set_inactive_drive_output_0();
    endtask: set_inactive_drive_output_0

    // check if ready is asserted
    virtual function bit check_ready_asserted();
    endfunction: check_ready_asserted

    // wait for set amount of clock cycles
    virtual task wait_clk_count(input int wait_clocks);
    endtask: wait_clk_count

    // pack the byte stream into transfers(beats) then in packets by setting the tlast
    virtual protected task packetize();
    endtask: packetize

    virtual protected task sender();
    endtask: sender

    // create transfer based on data beats per packet
    virtual function void add_xfer_descriptor_packet_size(
      input int data_beats_per_packet,
      input int gen_tlast = 1,
      input int gen_sync = 1);
    endfunction: add_xfer_descriptor_packet_size


    // set disable policy
    function void set_stop_policy(input stop_policy_t stop_policy);
      if (enabled)
        `ERROR(("Sequencer must be disabled before configuring stop policy"));
      this.stop_policy = stop_policy;
      `INFOV(("Disable policy configured"), 55);
    endfunction: set_stop_policy

    // set data generation mode
    function void set_data_gen_mode(input data_gen_mode_t data_gen_mode);
      if (enabled)
        `ERROR(("Sequencer must be disabled before configuring data generation mode"));
      this.data_gen_mode = data_gen_mode;
      `INFOV(("Data generation mode configured"), 55);
    endfunction: set_data_gen_mode

    // set data generation mode
    function void set_descriptor_gen_mode(input bit descriptor_gen_mode);
      if (enabled)
        `ERROR(("Sequencer must be disabled before configuring descriptor generation mode"));
      this.descriptor_gen_mode = descriptor_gen_mode;
      `INFOV(("Descriptor generation mode configured"), 55);
    endfunction: set_descriptor_gen_mode

    // set data beat delay
    function void set_data_beat_delay(input int data_beat_delay);
      this.data_beat_delay = data_beat_delay;
      `INFOV(("Data beat delay configured"), 55);
    endfunction: set_data_beat_delay

    // set descriptor delay
    function void set_descriptor_delay(input int descriptor_delay);
      this.descriptor_delay = descriptor_delay;
      `INFOV(("Descriptor delay configured"), 55);
    endfunction: set_descriptor_delay

    // create transfer descriptor
    function void add_xfer_descriptor(
      input int bytes_to_generate,
      input int gen_last = 1,
      input int gen_sync = 1);

      descriptor_t descriptor;
      descriptor.num_bytes = bytes_to_generate;
      descriptor.gen_last = gen_last;
      descriptor.gen_sync = gen_sync;
      // `INFOV(("Updating generator with %0d bytes with last %0d, sync %0d",
      //          bytes_to_generate, gen_last, gen_sync), 5);

      descriptor_q.push_back(descriptor);
      this.queue_empty_sig = 0;
      ->>queue_ev;
    endfunction: add_xfer_descriptor

    // descriptor delay subroutine
    // - can be overridden in inherited classes for more specific delay generation
    protected task descriptor_delay_subroutine();
      wait_clk_count(descriptor_delay);
    endtask: descriptor_delay_subroutine

    // wait until data beat is sent
    task beat_sent();
      @beat_done;
    endtask: beat_sent

    // wait until packet is sent
    task packet_sent();
      @packet_done;
    endtask: packet_sent

    // wait until queue is empty
    task wait_empty_descriptor_queue();
      if (this.queue_empty_sig)
        return;
      @queue_empty;
    endtask: wait_empty_descriptor_queue

    // generate transfer with transfer descriptors
    protected task generator();
      `INFOV(("generator start"), 55);
      forever begin
        `INFOV(("Waiting for enable"), 55);
        @enable_ev;
        `INFOV(("Enable found"), 55);
        fork begin
          fork
            begin
              @disable_ev;
              case (stop_policy)
                STOP_POLICY_DESCRIPTOR_QUEUE: begin
                  if (!this.queue_empty_sig)
                    @queue_empty;
                end
                STOP_POLICY_PACKET: @packet_done;
                STOP_POLICY_DATA_BEAT: @beat_done;
                STOP_POLICY_IMMEDIATE: ;
              endcase
            end
            forever begin
              if (descriptor_q.size() > 0) begin
                if (enabled || (!enabled && stop_policy == STOP_POLICY_DESCRIPTOR_QUEUE)) begin
                  packetize();
                  descriptor_delay_subroutine();
                end else
                  @enable_ev;
              end else begin
                this.queue_empty_sig = 1;
                ->> queue_empty;
                @queue_ev;
              end
            end
          join_any
          disable fork;
        end join
      end
    endtask: generator

    // function 
    function void push_byte_for_stream(xil_axi4stream_data_byte byte_stream);
      this.byte_stream.push_back(byte_stream);
      ->>byte_stream_ev;
    endfunction: push_byte_for_stream

    // descriptor delay subroutine
    // - can be overridden in inherited classes for more specific delay generation
    protected task data_beat_delay_subroutine();
      trans.set_delay(data_beat_delay);
    endtask: data_beat_delay_subroutine

    task start();
      `INFOV(("enable sequencer"), 55);
      enabled = 1;
      ->> enable_ev;
    endtask: start

    task stop();
      `INFOV(("disable sequencer"), 55);
      enabled = 0;
      byte_count = 0;
      ->> disable_ev;
    endtask: stop

    task run();
      fork
        generator();
        sender();
      join_none
    endtask: run

  endclass: m_axis_sequencer_base


  class m_axis_sequencer #( type T, `AXIS_VIP_PARAM_DECL) extends m_axis_sequencer_base;

    protected T agent;


    function new(T agent);
      super.new();

      this.agent = agent;
    endfunction: new


    // create transfer based on data beats per packet
    virtual function void add_xfer_descriptor_packet_size(
      input int data_beats_per_packet,
      input int gen_tlast = 1,
      input int gen_sync = 1);
      
      add_xfer_descriptor(data_beats_per_packet*AXIS_VIP_DATA_WIDTH/8, gen_tlast, gen_sync);
    endfunction: add_xfer_descriptor_packet_size

    // set vif proxy to drive outputs with 0 when inactive
    virtual task set_inactive_drive_output_0();
      agent.vif_proxy.set_dummy_drive_type(XIL_AXI4STREAM_VIF_DRIVE_NONE);

      this.wait_clk_count(2);
    endtask: set_inactive_drive_output_0

    // check if ready is asserted
    virtual function bit check_ready_asserted();
      return agent.vif_proxy.is_ready_asserted();
    endfunction: check_ready_asserted

    // wait for set amount of clock cycles
    virtual task wait_clk_count(input int wait_clocks);
      agent.vif_proxy.wait_aclks(wait_clocks);
    endtask: wait_clk_count

    // pack the byte stream into transfers(beats) then in packets by setting the tlast
    virtual protected task packetize();
      xil_axi4stream_data_byte data[];
      xil_axi4stream_strb keep[];
      int packet_length;
      int byte_per_beat;
      descriptor_t descriptor;

      `INFOV(("packetize start"), 55);
      byte_per_beat = AXIS_VIP_DATA_WIDTH/8;
      data = new[byte_per_beat];
      keep = new[byte_per_beat];
      descriptor = descriptor_q.pop_front();

      // put a copy of the descriptor back into the queue and continue processing
      if (this.descriptor_gen_mode == 1 && enabled)
        descriptor_q.push_back(descriptor);

      packet_length = descriptor.num_bytes / byte_per_beat;

      for (int tc=0; tc<packet_length; tc++) begin : packet_loop

        for (int i=0; i<byte_per_beat; i++) begin
          case (data_gen_mode)
            DATA_GEN_MODE_TEST_DATA:
              // block transfer until we get data from byte stream queue
              forever begin
                if (byte_stream.size() > 0) begin
                  data[i] = byte_stream.pop_front();
                  keep[i] = 1'b1;
                  break;
                end else
                  @byte_stream_ev;
              end
            DATA_GEN_MODE_AUTO_INCR: begin
              data[i] = byte_count++;
              keep[i] = 1'b1;
            end
            DATA_GEN_MODE_AUTO_RAND: begin
              data[i] = $random;
              keep[i] = 1'b1;
            end
          endcase
        end

        `INFOV(("generating axis transaction"), 55);
        trans = agent.driver.create_transaction();
        trans.set_data(data);
        trans.set_id('h0);
        trans.set_dest('h0);
        data_beat_delay_subroutine();

        if (AXIS_VIP_HAS_TKEEP)
          trans.set_keep(keep);

        if (AXIS_VIP_HAS_TLAST)
          trans.set_last((tc == packet_length-1) & descriptor.gen_last);

        if (AXIS_VIP_USER_WIDTH > 0)
          trans.set_user_beat((tc == 0) & descriptor.gen_sync);

        ->> data_av_ev;
        `INFOV(("waiting transfer to complete"), 55);
        @beat_done;
      end
      ->> packet_done;
    endtask: packetize

    // packet sender function
    virtual protected task sender();
      `INFOV(("sender start"), 55);
      forever begin
        `INFOV(("Waiting for enable"), 55);
        @enable_ev;
        `INFOV(("Enable found"), 55);
        fork begin
          fork
            begin
              @disable_ev;
              case (stop_policy)
                STOP_POLICY_DESCRIPTOR_QUEUE: begin
                if (!this.queue_empty_sig)
                  @queue_empty;
                end
                STOP_POLICY_PACKET: @packet_done;
                STOP_POLICY_DATA_BEAT: @beat_done;
                STOP_POLICY_IMMEDIATE: ;
              endcase
            end
            forever begin
              @data_av_ev;
              `INFOV(("sending axis transaction"), 55);
              agent.driver.send(trans);
              ->> beat_done;
            end
          join_any
          disable fork;
        end join
      end
    endtask: sender

  endclass

endpackage
