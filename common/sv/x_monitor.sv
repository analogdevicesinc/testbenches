`include "utils.svh"

package x_monitor_pkg;

  import xil_common_vip_pkg::*;
  import axi4stream_vip_pkg::*;
  import axi_vip_pkg::*;
  import logger_pkg::*;
  import mailbox_pkg::*;


  class x_monitor extends xil_component;

    mailbox_c #(logic [7:0]) mailbox;
    protected semaphore semaphore_key;
    protected event transaction_event;
    protected event scoreboard_event;

    protected bit enabled;


    // constructor
    function new(input string name);
      super.new(name);

      this.mailbox = new;
      this.semaphore_key = new(1);
    endfunction

    // semaphore functions
    task get_key();
      this.semaphore_key.get();
    endtask

    task put_key();
      this.semaphore_key.put();
    endtask

    // event functions
    task transaction_captured();
      ->this.transaction_event;
    endtask

    task wait_for_transaction_event();
      @this.transaction_event;
    endtask

    task scoreboard_notified();
      ->>this.scoreboard_event;
    endtask

    task wait_for_scoreboard_event();
      @this.scoreboard_event;
    endtask

    // run task
    task run();
      fork
        this.enabled = 1;
        get_transaction();
      join_none
    endtask

    virtual function bit get_packet_type();
    endfunction

    virtual task get_transaction();
    endtask

  endclass: x_monitor

  
  class x_axi_monitor #( type T, xil_axi_cmd_t operation_type ) extends x_monitor;

    // analysis port from the monitor
    protected xil_analysis_port #(axi_monitor_transaction) axi_ap;

    protected T agent;

    // constructor
    function new(input string name, T agent);

      super.new(name);

      this.enabled = 0;

      this.agent = agent;
      this.axi_ap = this.agent.monitor.item_collected_port;

    endfunction: new

    // check if monitor is sending an entire packet at once
    virtual function bit get_packet_type();
      return 1;
    endfunction: get_packet_type

    // collect data from an AXI4 interface
    // to monitor both operations, use 2 monitors
    virtual task get_transaction();

      axi_monitor_transaction transaction;
      xil_axi_data_beat data_beat;
      xil_axi_strb_beat strb_beat;
      int transaction_length;
      int num_bytes;
      int valid_bytes;
      logic [7:0] axi_packet [];

      forever begin
        this.axi_ap.get(transaction);
        if (transaction.get_cmd_type() == operation_type) begin
          num_bytes = transaction.get_data_width()/8;
          transaction_length = transaction.get_len()+1;
          
          for (int i=0; i<transaction_length; i++) begin
            data_beat = transaction.get_data_beat(i);
            strb_beat = transaction.get_strb_beat(i);
            `INFOV(("Packet received: %h - %h", data_beat, strb_beat), 200);

            valid_bytes = 0;
            if (this.agent.vif_proxy.C_AXI_HAS_WSTRB && transaction.get_cmd_type() == XIL_AXI_WRITE) begin
              for (int j=0; j<num_bytes; j++)
                if (strb_beat[j])
                  valid_bytes++;
            end else
              valid_bytes = num_bytes;
            axi_packet = new [axi_packet.size()+valid_bytes] (axi_packet);
            `INFOV(("Monitor packet length: %d", valid_bytes), 200);

            for (int j=0; j<valid_bytes; j++)
              axi_packet[axi_packet.size()-valid_bytes+j] = data_beat[j*8+:8];
          end
          
          this.get_key();
          for (int i=0; i<axi_packet.size(); i++)
            this.mailbox.put(axi_packet[i]);
          this.put_key();
          `INFOV(("Packet mail length: %d", this.mailbox.num()), 200);
          this.transaction_captured();
          this.wait_for_scoreboard_event();
          this.get_key();
          this.mailbox.flush();
          this.put_key();
        end else begin
          this.axi_ap.write(transaction);
          #1;
        end
      end

    endtask: get_transaction

  endclass: x_axi_monitor


  class x_axis_monitor #( type T) extends x_monitor;

    // analysis port from the monitor
    protected xil_analysis_port #(axi4stream_monitor_transaction) axis_ap;

    protected T agent;

    // constructor
    function new(input string name, T agent);

      super.new(name);

      this.enabled = 0;

      this.agent = agent;
      this.axis_ap = this.agent.monitor.item_collected_port;

    endfunction: new

    // check if monitor is sending an entire packet at once
    virtual function bit get_packet_type();
      return this.agent.vif_proxy.C_XIL_AXI4STREAM_SIGNAL_SET[XIL_AXI4STREAM_SIGSET_POS_LAST];
    endfunction: get_packet_type

    // collect data from the AXI4Stream interface of the stub
    virtual task get_transaction();

      axi4stream_transaction transaction;
      xil_axi4stream_data_beat data_beat;
      xil_axi4stream_strb_beat keep_beat;
      int num_bytes;
      int valid_bytes;
      logic [7:0] axi_packet [];

      forever begin
        this.axis_ap.get(transaction);
        // all bytes from a beat are valid
        num_bytes = transaction.get_data_width()/8;
        data_beat = transaction.get_data_beat();
        keep_beat = transaction.get_keep_beat();
        `INFOV(("Packet received: %h - %h", data_beat, keep_beat), 200);

        valid_bytes = 0;
        if (this.agent.vif_proxy.C_XIL_AXI4STREAM_SIGNAL_SET[XIL_AXI4STREAM_SIGSET_POS_KEEP]) begin
          for (int i=0; i<num_bytes; i++)
            if (keep_beat[i])
              valid_bytes++;
        end else
          valid_bytes = num_bytes;
        axi_packet = new [axi_packet.size()+valid_bytes] (axi_packet);
        `INFOV(("Monitor packet length: %d", valid_bytes), 200);
        
        for (int i=0; i<valid_bytes; i++)
          axi_packet[axi_packet.size()-valid_bytes+i] = data_beat[i*8+:8];
        
        if (transaction.get_last()) begin
          this.get_key();
          for (int i=0; i<axi_packet.size(); i++)
            this.mailbox.put(axi_packet[i]);
          this.put_key();
          `INFOV(("Packet mail length: %d", this.mailbox.num()), 200);
          axi_packet = new [0];
          this.transaction_captured();
          this.wait_for_scoreboard_event();
          this.get_key();
          this.mailbox.flush();
          this.put_key();
        end
      end

    endtask: get_transaction

  endclass: x_axis_monitor

endpackage
