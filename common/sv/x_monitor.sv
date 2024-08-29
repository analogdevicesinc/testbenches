`include "utils.svh"

package x_monitor_pkg;

  import xil_common_vip_pkg::*;
  import axi4stream_vip_pkg::*;
  import axi_vip_pkg::*;
  import logger_pkg::*;
  import mailbox_pkg::*;
  import filter_pkg::*;


  class x_monitor extends xil_component;

    mailbox_c #(logic [7:0]) mailbox;
    protected semaphore semaphore_key;
    protected event transaction_event;

    protected bit enabled;
    protected bit filter_enabled;
    protected filter_tree_class filter_tree;


    // constructor
    function new(input string name);
      super.new(name);

      this.mailbox = new;
      this.semaphore_key = new(1);
      this.filter_enabled = 0;
    endfunction

    // enable data filtering
    function void enable_filtering();
      if (!this.enabled)
        this.filter_enabled = 1;
      else
        `ERROR(("Cannot enable data filtering while monitor is running"));
    endfunction: enable_filtering

    // disable data filtering
    function void disable_filtering();
      if (!this.enabled)
        this.filter_enabled = 0;
      else
        `ERROR(("Cannot disable data filtering while monitor is running"));
    endfunction: disable_filtering

    // set filter tree
    function void set_filter_tree(filter_tree_class filter_tree);
      if (!this.enabled)
        this.filter_tree = filter_tree;
      else
        `ERROR(("Cannot change filter tree while monitor is running"));
    endfunction: set_filter_tree

    // semaphore functions
    task get_key();
      this.semaphore_key.get();
    endtask

    task put_key();
      this.semaphore_key.put();
    endtask

    // event functions
    task transaction_captured();
      ->>this.transaction_event;
    endtask

    task wait_for_transaction_event();
      @this.transaction_event;
    endtask

    // run task
    task run();
      if (this.filter_tree == null && this.filter_enabled)
        `ERROR(("Filter tree is not set"));
      fork
        this.enabled = 1;
        get_transaction();
      join_none
    endtask

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

    // collect data from an AXI4 interface
    // the monitor filters read and write operations
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
        this.get_key();
        this.axi_ap.get(transaction);
        if (transaction.get_cmd_type() == operation_type) begin
          this.put_key();
          num_bytes = transaction.get_data_width()/8;
          transaction_length = transaction.get_len()+1;
          
          for (int i=0; i<transaction_length; i++) begin
            data_beat = transaction.get_data_beat(i);
            strb_beat = transaction.get_strb_beat(i);

            valid_bytes = 0;
            if (this.agent.vif_proxy.C_AXI_HAS_WSTRB && transaction.get_cmd_type() == XIL_AXI_WRITE) begin
              for (int j=0; j<num_bytes; j++)
                if (strb_beat[j])
                  valid_bytes++;
            end else
              valid_bytes = num_bytes;
            axi_packet = new [axi_packet.size()+valid_bytes] (axi_packet);

            for (int j=0; j<valid_bytes; j++)
              axi_packet[axi_packet.size()-valid_bytes+j] = data_beat[j*8+:8];
          end

          if (this.filter_enabled)
            this.filter_tree.apply_filter(axi_packet);
          
          if (!this.filter_enabled || this.filter_tree.result) begin
            for (int i=0; i<transaction_length*num_bytes; i++)
              this.mailbox.put(axi_packet[i]);
            this.transaction_captured();
            #1step;
            this.mailbox.flush();
          end else
            `INFOV(("Packet filtered out"), 100);
        end else begin
          this.axi_ap.write(transaction);
          this.put_key();
          #1step;
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

    // collect data from the AXI4Stream interface of the stub
    virtual task get_transaction();

      axi4stream_transaction transaction;
      xil_axi4stream_data_beat data_beat;
      xil_axi4stream_strb_beat keep_beat;
      int num_bytes;
      int valid_bytes;
      logic [7:0] axi_packet [];

      if (this.filter_enabled && !this.agent.vif_proxy.C_XIL_AXI4STREAM_SIGNAL_SET[XIL_AXI4STREAM_SIGSET_POS_LAST])
        `ERROR(("Packet filtering cannot be enabled if last signal is disabled"));

      forever begin
        this.axis_ap.get(transaction);
        // all bytes from a beat are valid
        num_bytes = transaction.get_data_width()/8;
        data_beat = transaction.get_data_beat();
        keep_beat = transaction.get_keep_beat();

        valid_bytes = 0;
        if (this.agent.vif_proxy.C_XIL_AXI4STREAM_SIGNAL_SET[XIL_AXI4STREAM_SIGSET_POS_KEEP]) begin
          for (int i=0; i<num_bytes; i++)
            if (keep_beat[i])
              valid_bytes++;
        end else
          valid_bytes = num_bytes;
        axi_packet = new [axi_packet.size()+valid_bytes] (axi_packet);
        
        for (int i=0; i<valid_bytes; i++)
          axi_packet[axi_packet.size()-valid_bytes+i] = data_beat[i*8+:8];

        if (this.filter_enabled && transaction.get_last())
          this.filter_tree.apply_filter(axi_packet);
        
        if (transaction.get_last())
          if ((!this.filter_enabled || this.filter_tree.result)) begin
            for (int i=0; i<axi_packet.size(); i++)
              this.mailbox.put(axi_packet[i]);
            axi_packet = new [0];
            this.transaction_captured();
            #1step;
            this.mailbox.flush();
          end else
            `INFOV(("Packet filtered out"), 100);
      end

    endtask: get_transaction

  endclass: x_axis_monitor

endpackage
