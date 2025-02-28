`include "utils.svh"

package adi_axis_monitor_pkg;

  import axi4stream_vip_pkg::*;
  import logger_pkg::*;
  import adi_common_pkg::*;
  import pub_sub_pkg::*;

  class adi_axis_monitor #(`AXIS_VIP_PARAM_DECL(AXIS)) extends adi_monitor;

    // analysis port from the monitor
    protected axi4stream_monitor #(`AXIS_VIP_IF_PARAMS(AXIS)) monitor;

    adi_publisher #(logic [7:0]) publisher;

    protected bit enabled;
    protected event enable_ev;

    // constructor
    function new(
      input string name,
      input axi4stream_monitor #(`AXIS_VIP_IF_PARAMS(AXIS)) monitor,
      input adi_agent parent = null);

      super.new(name, parent);

      this.monitor = monitor;

      this.publisher = new("Publisher", this);

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

    // collect data from the AXI4Strean interface of the stub, this task
    // handles both ONESHOT and CYCLIC scenarios
    task get_transaction();
      axi4stream_transaction transaction;
      xil_axi4stream_data_beat data_beat;
      xil_axi4stream_strb_beat keep_beat;
      int num_bytes;
      logic [7:0] axi_byte;
      logic [7:0] data_queue [$];

      forever begin
        this.monitor.item_collected_port.get(transaction);
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
