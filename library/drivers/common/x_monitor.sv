`include "utils.svh"

package x_monitor_pkg;

  import xil_common_vip_pkg::*;
  import axi4stream_vip_pkg::*;
  import axi_vip_pkg::*;
  import logger_pkg::*;
  import adi_common_pkg::*;
  import pub_sub_pkg::*;

  class x_monitor extends adi_monitor;

    protected bit enabled;

    // constructor
    function new(
      input string name,
      input adi_agent parent = null);
      
      super.new(name, parent);

      this.enabled = 0;
    endfunction

    task run();
      if (this.enabled) begin
        this.error($sformatf("Monitor is already running!"));
        return;
      end

      fork
        this.get_transaction();
      join_none

      this.enabled = 1;
      this.info($sformatf("Monitor enabled"), ADI_VERBOSITY_MEDIUM);
    endtask: run

    // virtual functions
    virtual task get_transaction();
    endtask

  endclass

  
  class x_axi_monitor #(int `AXI_VIP_PARAM_ORDER(axi)) extends x_monitor;

    // analysis port from the monitor
    protected axi_monitor #(`AXI_VIP_PARAM_ORDER(axi)) monitor;
    protected xil_analysis_port #(axi_monitor_transaction) axi_ap;

    adi_publisher #(logic [7:0]) publisher_tx;
    adi_publisher #(logic [7:0]) publisher_rx;

    // constructor
    function new(
      input string name,
      input axi_monitor #(`AXI_VIP_PARAM_ORDER(axi)) monitor,
      input adi_agent parent = null);

      super.new(name, parent);

      this.monitor = monitor;
      this.axi_ap = monitor.item_collected_port;

      this.publisher_tx = new("Publisher TX", this);
      this.publisher_rx = new("Publisher RX", this);
    endfunction

    // collect data from the DDR interface, all WRITE transaction are coming
    // from the ADC and all READ transactions are going to the DAC
    virtual task get_transaction();
      axi_monitor_transaction transaction;
      xil_axi_data_beat data_beat;
      xil_axi_strb_beat strb_beat;
      int num_bytes;
      logic [7:0] axi_byte;
      logic [7:0] data_queue [$];

      forever begin
        this.axi_ap.get(transaction);
        num_bytes = transaction.get_data_width()/8;
        for (int i=0; i<(transaction.get_len()+1); i++) begin
          data_beat = transaction.get_data_beat(i);
          strb_beat = transaction.get_strb_beat(i);
          for (int j=0; j<num_bytes; j++) begin
            axi_byte = data_beat[j*8+:8];
            // put each beat into byte queues
            if (bit'(transaction.get_cmd_type()) == 1'b0) begin // READ
              data_queue.push_back(axi_byte);
            end else if (strb_beat[j] || !this.monitor.vif_proxy.C_AXI_HAS_WSTRB) begin // WRITE
              data_queue.push_back(axi_byte);
            end
          end
          this.info($sformatf("Caught an AXI4 transaction: %d", data_queue.size()), ADI_VERBOSITY_MEDIUM);
        end
        if (bit'(transaction.get_cmd_type()) == 1'b0) begin
          this.publisher_rx.notify(data_queue);
        end else begin
          this.publisher_tx.notify(data_queue);
        end
        data_queue.delete();
      end
    endtask: get_transaction

  endclass


  class x_axis_monitor #(int `AXIS_VIP_PARAM_ORDER(axis)) extends x_monitor;

    // analysis port from the monitor
    protected axi4stream_monitor #(`AXIS_VIP_IF_PARAMS(axis)) monitor;
    protected xil_analysis_port #(axi4stream_monitor_transaction) axis_ap;

    adi_publisher #(logic [7:0]) publisher;

    // constructor
    function new(
      input string name,
      input axi4stream_monitor #(`AXIS_VIP_IF_PARAMS(axis)) monitor,
      input adi_agent parent = null);

      super.new(name, parent);

      this.monitor = monitor;
      this.axis_ap = monitor.item_collected_port;

      this.publisher = new("Publisher", this);
    endfunction

    // collect data from the AXI4Strean interface of the stub, this task
    // handles both ONESHOT and CYCLIC scenarios
    virtual task get_transaction();
      axi4stream_transaction transaction;
      xil_axi4stream_data_beat data_beat;
      xil_axi4stream_strb_beat keep_beat;
      int num_bytes;
      logic [7:0] axi_byte;
      logic [7:0] data_queue [$];

      forever begin
        this.axis_ap.get(transaction);
        // all bytes from a beat are valid
        num_bytes = transaction.get_data_width()/8;
        data_beat = transaction.get_data_beat();
        keep_beat = transaction.get_keep_beat();
        for (int j=0; j<num_bytes; j++) begin
          axi_byte = data_beat[j*8+:8];
          if (keep_beat[j+:1] || !this.monitor.vif_proxy.C_XIL_AXI4STREAM_SIGNAL_SET[XIL_AXI4STREAM_SIGSET_POS_KEEP])
            data_queue.push_back(axi_byte);
        end
        this.info($sformatf("Caught an AXI4 stream transaction: %d", data_queue.size()), ADI_VERBOSITY_MEDIUM);
        this.publisher.notify(data_queue);
        data_queue.delete();
      end
    endtask: get_transaction

  endclass

endpackage
