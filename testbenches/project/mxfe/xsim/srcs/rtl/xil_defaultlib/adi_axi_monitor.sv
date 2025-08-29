// ***************************************************************************
// ***************************************************************************
// Copyright (C) 2024-2025 Analog Devices, Inc. All rights reserved.
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

package adi_axi_monitor_pkg;

  import axi_vip_pkg::*;
  import logger_pkg::*;
  import adi_vip_pkg::*;
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

  endclass: adi_axi_monitor

endpackage: adi_axi_monitor_pkg
