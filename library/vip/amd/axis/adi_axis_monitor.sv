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
  import adi_agent_pkg::*;
  import adi_monitor_pkg::*;
  import pub_sub_pkg::*;
  import adi_object_pkg::*;
  import adi_axis_transaction_pkg::*;
  import adi_fifo_class_pkg::*;
  import adi_axis_config_pkg::*;

  class adi_axis_monitor_base extends adi_monitor;

    adi_publisher #(adi_axis_transaction) publisher;

    protected bit enabled;
    protected event enable_ev;

    // constructor
    function new(
      input string name,
      input adi_agent parent = null);

      super.new(name, parent);

      this.publisher = new("Publisher", this);

      this.enabled = 0;
    endfunction: new

    task start();
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
    endtask: start

    function void stop();
      this.enabled = 0;
      -> enable_ev;
    endfunction: stop

    virtual task get_transaction();
    endtask: get_transaction

  endclass: adi_axis_monitor_base


  class adi_axis_monitor #(`AXIS_VIP_PARAM_DECL(AXIS)) extends adi_axis_monitor_base;

    // analysis port from the monitor
    protected axi4stream_monitor #(`AXIS_VIP_IF_PARAMS(AXIS)) monitor;

    // constructor
    function new(
      input string name,
      input axi4stream_monitor #(`AXIS_VIP_IF_PARAMS(AXIS)) monitor,
      input adi_agent parent = null);

      super.new(name, parent);

      this.monitor = monitor;
    endfunction: new

    // collect data from the AXI4Strean interface of the stub, this task
    // handles both ONESHOT and CYCLIC scenarios
    virtual task get_transaction();
      axi4stream_transaction xil_transaction;
      xil_axi4stream_data_byte tdata[];
      xil_axi4stream_strb tkeep[];
      xil_axi4stream_strb tstrb[];
      bit tlast;
      xil_axi4stream_uint tid;
      xil_axi4stream_uint tdest;
      xil_axi4stream_user_beat tuser;
      adi_axis_config axis_cfg = new(`AXIS_TRANSACTION_SEQ_PARAM(AXIS));
      adi_axis_transaction adi_transaction = new(.cfg(axis_cfg));
      adi_fifo_class #(adi_axis_transaction) data_queue = new();

      tdata = new[axis_cfg.BYTES_PER_TRANSACTION];
      tkeep = new[axis_cfg.BYTES_PER_TRANSACTION];
      tstrb = new[axis_cfg.BYTES_PER_TRANSACTION];

      forever begin
        this.monitor.item_collected_port.get(xil_transaction);
        // extract data from Xil AXIS transaction
        xil_transaction.get_data(tdata);
        xil_transaction.get_keep(tkeep);
        xil_transaction.get_strb(tstrb);
        tlast = xil_transaction.get_last();
        tid = xil_transaction.get_id();
        tdest = xil_transaction.get_dest();
        tuser = xil_transaction.get_user_beat();

        // create ADI AXIS transaction from extracted data
        if (axis_cfg.EN_TLAST) begin
          adi_transaction.update_tlast(tlast);
        end
        adi_transaction.update_tid(tid);
        adi_transaction.update_tdest(tdest);
        if (!AXIS_VIP_USER_BITS_PER_BYTE && AXIS_VIP_USER_WIDTH > 0) begin
          adi_transaction.update_tuser(tuser);
        end
        for (int i=0; i<AXIS_VIP_DATA_WIDTH/8; i++) begin
          adi_transaction.bytes[i].update_tdata(tdata[i]);
          if (axis_cfg.EN_TKEEP) begin
            adi_transaction.bytes[i].update_tkeep(tkeep[i]);
          end else begin
            adi_transaction.bytes[i].update_tkeep(1'b1);
          end
          if (axis_cfg.EN_TSTRB) begin
            adi_transaction.bytes[i].update_tstrb(tstrb[i]);
          end else begin
            adi_transaction.bytes[i].update_tstrb(adi_transaction.bytes[i].tkeep);
          end
          if (AXIS_VIP_USER_BITS_PER_BYTE && AXIS_VIP_USER_WIDTH > 0) begin
            adi_transaction.bytes[i].update_tuser(tuser[i*AXIS_VIP_USER_WIDTH/(AXIS_VIP_DATA_WIDTH/8)+:AXIS_VIP_USER_WIDTH/(AXIS_VIP_DATA_WIDTH/8)]);
          end
        end
        void'(data_queue.push(adi_transaction));
        this.info($sformatf("Caught an AXI4 stream transaction: %d", data_queue.size()), ADI_VERBOSITY_MEDIUM);
        this.publisher.notify(data_queue);
        data_queue.delete();
      end
    endtask: get_transaction

  endclass: adi_axis_monitor

endpackage: adi_axis_monitor_pkg
