// ***************************************************************************
// ***************************************************************************
// Copyright (C) 2014-2025 Analog Devices, Inc. All rights reserved.
//
// In this HDL repository, there are many different and unique modules, consisting
// of various HDL (Verilog or VHDL) components. The individual modules are
// developed independently, and may be accompanied by separate and unique license
// terms.
//
// The user should read each of these license terms, and understand the
// freedoms and responsibilities that he or she has by using this source/core.
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
//      https://github.com/analogdevicesinc/hdl/blob/main/LICENSE_ADIBSD
//      This will allow to generate bit files and not release the source code,
//      as long as it attaches to an ADI device.
//
// ***************************************************************************
// ***************************************************************************

`include "utils.svh"
`include "axis_definitions.svh"

package m_axis_sequencer_pkg;

  import axi4stream_vip_pkg::*;
  import adi_agent_pkg::*;
  import adi_sequencer_pkg::*;
  import logger_pkg::*;
  import adi_object_pkg::*;
  import adi_axis_transaction_pkg::*;
  import adi_axis_packet_pkg::*;
  import adi_axis_frame_pkg::*;
  import adi_fifo_class_pkg::*;
  import adi_axis_config_pkg::*;

  typedef enum bit [2:0] {
    STOP_POLICY_TRANSACTION = 3'h0, // disable after transaction has been transferred
    STOP_POLICY_PACKET = 3'h1,      // disable after packet has been transferred
    STOP_POLICY_FRAME = 3'h2,       // disable after frame has been transferred
    STOP_POLICY_SEQUENCE = 3'h3,    // disable after sequence has been transferred
    STOP_POLICY_QUEUE = 3'h4        // disable after all sequences queue has been transferred
  } stop_policy_t;


  virtual class m_axis_sequencer_base extends adi_sequencer;

    // sequencer status bits
    protected bit enabled;
    protected bit sequencer_running;
    protected bit sequences_empty_sig;
    protected bit transaction_in_progress;
    protected bit packet_in_progress;
    protected bit frame_in_progress;
    protected bit sequence_in_progress;

    // delays between transactions
    protected int transaction_delay; // delay in clock cycles
    protected int packet_delay; // delay in clock cycles
    protected int frame_delay; // delay in clock cycles
    protected int sequence_delay; // delay in clock cycles

    // events
    protected event disable_ev;
    protected event disable_sender_ev;
    protected event trigger_transaction_ev;
    protected event transaction_sent_ev;
    protected event packet_sent_ev;
    protected event frame_sent_ev;
    protected event sequence_sent_ev;
    protected event new_sequence_ev;
    protected event sequences_empty_ev;

    protected bit repeat_transaction_mode; // 0 - get transaction from test stimulus
                                           // 1 - autogenerate transaction based on the first transaction from test until sequencer is stopped

    protected stop_policy_t stop_policy;

    axi4stream_transaction xilinx_trans_object;

    adi_fifo_class #(adi_object) sequences;

    // new
    function new(
      input string name,
      input adi_agent parent = null);

      super.new(name, parent);

      this.enabled = 1'b0;
      this.repeat_transaction_mode = 1'b0;
      this.transaction_delay = 0;
      this.packet_delay = 0;
      this.frame_delay = 0;
      this.sequence_delay = 0;
      this.stop_policy = STOP_POLICY_TRANSACTION;
      this.sequences_empty_sig = 1;
      this.sequences_empty_sig = 1;
      this.transaction_in_progress = 0;
      this.packet_in_progress = 0;
      this.frame_in_progress = 0;
      this.sequence_in_progress = 0;

      xilinx_trans_object = new();

      this.sequences = new();
    endfunction: new

    // set vif proxy to drive outputs with 0 when inactive
    pure virtual task set_inactive_drive_output_0();

    // check if ready is asserted
    pure virtual function bit check_ready_asserted();

    // wait for set amount of clock cycles
    pure virtual task wait_clk_count(input int wait_clocks);

    // wait for driver to be idle
    pure virtual task wait_driver_idle();

    // processes and sends transactions out to the driver
    pure virtual task sender();

    pure virtual protected task axis_transaction_check(
      input adi_object next_sequence,
      output bit valid);
    pure virtual protected task axis_packet_check(
      input adi_object next_sequence,
      output bit valid);
    pure virtual protected task axis_frame_check(
      input adi_object next_sequence,
      output bit valid);


    // set disable policy
    function void set_stop_policy(input stop_policy_t stop_policy);
      if (enabled) begin
        this.error($sformatf("Sequencer must be disabled before configuring stop policy!"));
      end
      this.stop_policy = stop_policy;
      this.info($sformatf("Disable policy configured"), ADI_VERBOSITY_HIGH);
    endfunction: set_stop_policy

    // set data generation mode
    function void set_repeat_transaction_mode(input bit repeat_transaction_mode);
      if (enabled) begin
        this.error($sformatf("Sequencer must be disabled before configuring transaction generation mode"));
      end
      this.repeat_transaction_mode = repeat_transaction_mode;
      this.info($sformatf("transaction generation mode configured"), ADI_VERBOSITY_HIGH);
    endfunction: set_repeat_transaction_mode

    // set transaction delay
    function void set_transaction_delay(input int transaction_delay);
      this.transaction_delay = transaction_delay;
      this.info($sformatf("Transaction delay configured"), ADI_VERBOSITY_HIGH);
    endfunction: set_transaction_delay

    // set packet delay
    function void set_packet_delay(input int packet_delay);
      this.packet_delay = packet_delay;
      this.info($sformatf("Packet delay configured"), ADI_VERBOSITY_HIGH);
    endfunction: set_packet_delay

    // set frame delay
    function void set_frame_delay(input int frame_delay);
      this.frame_delay = frame_delay;
      this.info($sformatf("Frame delay configured"), ADI_VERBOSITY_HIGH);
    endfunction: set_frame_delay

    // set sequence delay
    function void set_sequence_delay(input int sequence_delay);
      this.sequence_delay = sequence_delay;
      this.info($sformatf("Sequence delay configured"), ADI_VERBOSITY_HIGH);
    endfunction: set_sequence_delay

    // add transaction to the queue
    function void add_transaction(input adi_object axis_transaction);
      void'(this.sequences.push(axis_transaction));
      this.sequences_empty_sig = 0;
      ->>this.new_sequence_ev;
    endfunction: add_transaction

    // add packet to the queue
    function void add_packet(input adi_object axis_packet);
      void'(this.sequences.push(axis_packet));
      this.sequences_empty_sig = 0;
      ->>this.new_sequence_ev;
    endfunction: add_packet

    // add frame to the queue
    function void add_frame(input adi_object axis_frame);
      void'(this.sequences.push(axis_frame));
      this.sequences_empty_sig = 0;
      ->>this.new_sequence_ev;
    endfunction: add_frame

    // add sequence to the queue
    function void add_sequence(adi_fifo_class #(adi_object) new_sequence);
      void'(this.sequences.push(new_sequence));
      this.sequences_empty_sig = 0;
      ->>this.new_sequence_ev;
    endfunction: add_sequence

    // wait until data beat is sent
    virtual task transaction_sent();
      if (this.transaction_in_progress) begin
        @this.transaction_sent_ev;
      end
    endtask: transaction_sent

    // wait until packet is sent
    virtual task packet_sent();
      if (this.packet_in_progress) begin
        @this.packet_sent_ev;
      end
    endtask: packet_sent

    // wait until packet is sent
    virtual task frame_sent();
      if (this.frame_in_progress) begin
        @this.frame_sent_ev;
      end
    endtask: frame_sent

    // wait until packet is sent
    virtual task sequence_sent();
      if (this.sequence_in_progress) begin
        @this.sequence_sent_ev;
      end
    endtask: sequence_sent

    // wait until queue is empty
    task wait_empty_sequences();
      if (!this.sequences_empty_sig) begin
        @this.sequences_empty_ev;
      end
    endtask: wait_empty_sequences

    // clear sequences queue
    task clear_sequences();
      this.sequences.delete();
    endtask: clear_sequences

    // transaction delay subroutine
    protected task transaction_delay_subroutine();
      this.xilinx_trans_object.set_delay(this.transaction_delay);
    endtask: transaction_delay_subroutine

    // packet delay subroutine
    protected task packet_delay_subroutine();
      this.wait_clk_count(packet_delay);
    endtask: packet_delay_subroutine

    // frame delay subroutine
    protected task frame_delay_subroutine();
      this.wait_clk_count(frame_delay);
    endtask: frame_delay_subroutine

    // sequence delay subroutine
    protected task sequence_delay_subroutine();
      this.wait_clk_count(sequence_delay);
    endtask: sequence_delay_subroutine

    // type-check for sequence
    protected task axis_sequence_check(
      input adi_object next_sequence,
      output bit valid);

      adi_fifo_class #(adi_object) cast_object;
      adi_object extracted_sequence;

      valid = 1;

      if ($cast(cast_object, next_sequence) == 0) begin
        valid = 0;
        return;
      end

      if (!this.enabled && this.stop_policy == STOP_POLICY_SEQUENCE) begin
        return;
      end

      for(int i=0; i<cast_object.size(); i++) begin
        extracted_sequence = cast_object.pop();
        this.check_main_class(extracted_sequence, valid);
        if (!valid) begin
          return;
        end
        void'(cast_object.push(extracted_sequence));
      end

      return;
    endtask: axis_sequence_check

    // type-check all posibilities
    protected task check_main_class(
      input adi_object next_sequence,
      output bit valid);

      valid = 1;

      this.axis_sequence_check(next_sequence, valid);
      if (!valid) begin
        this.axis_frame_check(next_sequence, valid);
        if (!valid) begin
          this.axis_packet_check(next_sequence, valid);
          if (!valid) begin
            this.axis_transaction_check(next_sequence, valid);
            if (!valid) begin
              return;
            end
          end
        end
      end
    endtask: check_main_class

    task sequencer();
      // next sequence object
      adi_object next_sequence;
      bit valid;

      forever begin
        fork begin
          fork
            begin
              @disable_ev;
            end
            begin
              if (this.sequences.size() == 0) begin
                this.sequences_empty_sig = 1;
                ->>sequences_empty_ev;
                @new_sequence_ev;
              end
            end
          join_any
          disable fork;
        end join

        if (!this.enabled && (stop_policy != STOP_POLICY_QUEUE || this.sequences.size() == 'd0)) begin
          ->>this.disable_sender_ev;
          this.sequencer_running = 0;
          return;
        end

        next_sequence = this.sequences.pop();
        if (this.repeat_transaction_mode) begin
          void'(this.sequences.push(next_sequence));
        end

        this.sequence_in_progress = 1;
        // check which one is it's main class
        this.check_main_class(next_sequence, valid);
        if (!valid) begin
          this.fatal($sformatf("Sequence found in the sequence list is not compatible with this AXIS Sequencer!"));
        end
        this.sequence_in_progress = 0;

        this.sequence_delay_subroutine();

        ->>this.sequence_sent_ev;
        this.info($sformatf("Axis sequence sent"), ADI_VERBOSITY_HIGH);
      end
    endtask: sequencer

    task start();
      if (this.sequencer_running) begin
        if (this.enabled) begin
          this.warning($sformatf("Sequencer is already running!"));
        end else begin
          this.warning($sformatf("Sequencer is still running, ending the task!"));
        end
        return;
      end
      this.info($sformatf("Sequencer started"), ADI_VERBOSITY_HIGH);
      this.enabled = 1;
      fork
        this.sequencer();
        this.sender();
      join_none
      this.sequencer_running = 1;
    endtask: start

    task stop();
      this.info($sformatf("Sequencer stopped"), ADI_VERBOSITY_HIGH);
      this.enabled = 0;
      ->>this.disable_ev;
      this.wait_clk_count(2);
    endtask: stop

  endclass: m_axis_sequencer_base


  class m_axis_sequencer #(`AXIS_VIP_PARAM_DECL(AXIS)) extends m_axis_sequencer_base;

    protected axi4stream_mst_driver #(`AXIS_VIP_IF_PARAMS(AXIS)) driver;

    protected adi_axis_transaction transaction_object;


    function new(
      input string name,
      input axi4stream_mst_driver #(`AXIS_VIP_IF_PARAMS(AXIS)) driver,
      input adi_agent parent = null);

      adi_axis_config axis_cfg = new(`AXIS_TRANSACTION_SEQ_PARAM(AXIS));

      super.new(name, parent);

      this.driver = driver;

      this.driver.vif_proxy.set_no_insert_x_when_keep_low(1);

      this.transaction_object = new(.cfg(axis_cfg));
    endfunction: new


    // set vif proxy to drive outputs with 0 when inactive
    virtual task set_inactive_drive_output_0();
      this.driver.vif_proxy.set_dummy_drive_type(XIL_AXI4STREAM_VIF_DRIVE_NONE);

      this.wait_clk_count(2);
    endtask: set_inactive_drive_output_0

    // check if ready is asserted
    virtual function bit check_ready_asserted();
      return this.driver.vif_proxy.is_ready_asserted();
    endfunction: check_ready_asserted

    // wait for set amount of clock cycles
    virtual task wait_clk_count(input int wait_clocks);
      this.driver.vif_proxy.wait_aclks(wait_clocks);
    endtask: wait_clk_count

    // wait for driver to be idle
    virtual task wait_driver_idle();
      while (!this.driver.is_driver_idle()) begin
        this.wait_clk_count(1);
      end
    endtask: wait_driver_idle

    virtual task sender();
      xil_axi4stream_data_byte tdata[];
      xil_axi4stream_strb tkeep[];
      xil_axi4stream_strb tstrb[];
      bit tlast;
      xil_axi4stream_uint tid;
      xil_axi4stream_uint tdest;
      xil_axi4stream_user_beat tuser;

      tdata = new[this.transaction_object.cfg.BYTES_PER_TRANSACTION];
      tkeep = new[this.transaction_object.cfg.BYTES_PER_TRANSACTION];
      tstrb = new[this.transaction_object.cfg.BYTES_PER_TRANSACTION];

      this.info($sformatf("Sender started"), ADI_VERBOSITY_HIGH);
      fork begin
        fork
          begin
            @this.disable_sender_ev;
          end
          forever begin
            @this.trigger_transaction_ev;

            this.info($sformatf("Processing axis transaction"), ADI_VERBOSITY_HIGH);

            this.xilinx_trans_object = this.driver.create_transaction();
            this.xilinx_trans_object.set_delay('d0);

            // extract information from object
            for (int i=0; i<this.transaction_object.cfg.BYTES_PER_TRANSACTION; i++) begin
              tdata[i] = this.transaction_object.bytes[i].tdata;
              tkeep[i] = this.transaction_object.bytes[i].tkeep;
              tstrb[i] = this.transaction_object.bytes[i].tstrb;
            end
            tlast = this.transaction_object.tlast;
            tid = this.transaction_object.tid;
            tdest = this.transaction_object.tdest;
            if (AXIS_VIP_USER_BITS_PER_BYTE) begin
              for (int i=0; i<this.transaction_object.cfg.BYTES_PER_TRANSACTION; i++) begin
                tuser[AXIS_VIP_USER_WIDTH/(AXIS_VIP_DATA_WIDTH/8)*i+:AXIS_VIP_USER_WIDTH/(AXIS_VIP_DATA_WIDTH/8)] = this.transaction_object.bytes[i].tuser;
              end
            end else begin
              tuser = this.transaction_object.tuser;
            end

            // create transaction
            this.xilinx_trans_object.set_data(tdata);
            if (AXIS_VIP_SIGNAL_SET & XIL_AXI4STREAM_SIGSET_KEEP) begin
              this.xilinx_trans_object.set_keep(tkeep);
            end
            if (AXIS_VIP_SIGNAL_SET & XIL_AXI4STREAM_SIGSET_STRB) begin
              this.xilinx_trans_object.set_strb(tstrb);
            end
            if (AXIS_VIP_SIGNAL_SET & XIL_AXI4STREAM_SIGSET_LAST) begin
              this.xilinx_trans_object.set_last(tlast);
            end
            if (AXIS_VIP_SIGNAL_SET & XIL_AXI4STREAM_SIGSET_ID) begin
              this.xilinx_trans_object.set_id(tid[this.driver.C_XIL_AXI4STREAM_ID_WIDTH-1:0]);
            end
            if (AXIS_VIP_SIGNAL_SET & XIL_AXI4STREAM_SIGSET_DEST) begin
              this.xilinx_trans_object.set_dest(tdest[this.driver.C_XIL_AXI4STREAM_DEST_WIDTH-1:0]);
            end
            if (AXIS_VIP_SIGNAL_SET & XIL_AXI4STREAM_SIGSET_USER) begin
              this.xilinx_trans_object.set_user_beat(tuser[this.driver.C_XIL_AXI4STREAM_USER_WIDTH-1:0]);
            end

            this.driver.send(this.xilinx_trans_object);
            while (this.driver.is_driver_idle()) begin
              this.wait_clk_count(1);
            end

            this.transaction_delay_subroutine();

            this.info($sformatf("Axis transaction sent"), ADI_VERBOSITY_HIGH);
            ->>this.transaction_sent_ev;
          end
        join_any
        disable fork;
      end join
    endtask: sender

    // type-check for transaction
    virtual protected task axis_transaction_check(
      input adi_object next_sequence,
      output bit valid);

      adi_axis_transaction cast_object;

      valid = 1;

      if ($cast(cast_object, next_sequence) == 0) begin
        valid = 0;
        return;
      end

      if (!this.enabled && this.stop_policy == STOP_POLICY_TRANSACTION) begin
        return;
      end

      cast_object.copy(this.transaction_object);

      ->>this.trigger_transaction_ev;
      @this.transaction_sent_ev;

      return;
    endtask: axis_transaction_check

    // type-check for packet
    virtual protected task axis_packet_check(
      input adi_object next_sequence,
      output bit valid);

      adi_axis_packet cast_object;

      valid = 1;

      if ($cast(cast_object, next_sequence) == 0) begin
        valid = 0;
        return;
      end

      if (!this.enabled && this.stop_policy == STOP_POLICY_PACKET) begin
        return;
      end

      this.packet_in_progress = 1;
      for (int i=0; i<cast_object.transactions.size(); i++) begin
        this.axis_transaction_check(cast_object.transactions[i], valid);
        if (!valid) begin
          return;
        end
      end
      this.packet_in_progress = 0;

      this.packet_delay_subroutine();

      ->>this.packet_sent_ev;
      this.info($sformatf("Axis packet sent"), ADI_VERBOSITY_HIGH);

      return;
    endtask: axis_packet_check

    // type-check for frame
    virtual protected task axis_frame_check(
      input adi_object next_sequence,
      output bit valid);

      adi_axis_frame cast_object;

      valid = 1;

      if ($cast(cast_object, next_sequence) == 0) begin
        valid = 0;
        return;
      end

      if (!this.enabled && this.stop_policy == STOP_POLICY_FRAME) begin
        return;
      end

      this.frame_in_progress = 1;
      for (int i=0; i<cast_object.packets.size(); i++) begin
        this.axis_packet_check(cast_object.packets[i], valid);
        if (!valid) begin
          return;
        end
      end
      this.frame_in_progress = 0;

      this.frame_delay_subroutine();
      this.info($sformatf("Axis frame sent"), ADI_VERBOSITY_HIGH);

      ->>this.frame_sent_ev;

      return;
    endtask: axis_frame_check

  endclass: m_axis_sequencer

endpackage: m_axis_sequencer_pkg
