`include "utils.svh"

package adi_axi_monitor_pkg;

  import axi_vip_pkg::*;
  import logger_pkg::*;
  import adi_common_pkg::*;
  import pub_sub_pkg::*;

  class adi_axi_monitor #(int `AXI_VIP_PARAM_ORDER(axi)) extends adi_monitor;

    // analysis port from the monitor
    protected axi_monitor #(`AXI_VIP_PARAM_ORDER(axi)) monitor;

    adi_publisher #(logic [7:0]) publisher_tx;
    adi_publisher #(logic [7:0]) publisher_rx;

    protected bit enabled;
    protected event enable_ev;

    // constructor
    function new(
      input string name,
      input axi_monitor #(`AXI_VIP_PARAM_ORDER(axi)) monitor,
      input adi_agent parent = null);

      super.new(name, parent);

      this.monitor = monitor;

      this.publisher_tx = new("Publisher TX", this);
      this.publisher_rx = new("Publisher RX", this);

      this.enabled = 0;
    endfunction

    task run();
      if (this.enabled) begin
        this.error($sformatf("Monitor is already running!"));
        return;
      end

      this.enabled = 1;
      this.info($sformatf("Monitor enabled"), ADI_VERBOSITY_MEDIUM);

      fork
        begin
          this.get_transaction();
        end
        begin
          if (this.enabled == 1) begin
            @enable_ev;
          end
          disable fork;
        end
      join_none
    endtask: run

    function void stop();
      this.enabled = 0;
      -> enable_ev;
    endfunction: stop

    // collect data from the DDR interface, all WRITE transaction are coming
    // from the ADC and all READ transactions are going to the DAC
    task get_transaction();
      axi_monitor_transaction transaction;
      xil_axi_data_beat data_beat;
      xil_axi_strb_beat strb_beat;
      int num_bytes;
      logic [7:0] axi_byte;
      logic [7:0] data_queue [$];

      forever begin
        this.monitor.item_collected_port.get(transaction);
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

endpackage
