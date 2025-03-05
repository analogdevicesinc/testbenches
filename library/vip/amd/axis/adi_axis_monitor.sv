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

package adi_axis_monitor_pkg;

  import axi4stream_vip_pkg::*;
  import logger_pkg::*;
  import adi_vip_pkg::*;
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
    endfunction: new

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

  endclass: adi_axis_monitor

endpackage: adi_axis_monitor_pkg
