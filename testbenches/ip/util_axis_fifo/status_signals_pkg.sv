// ***************************************************************************
// ***************************************************************************
// Copyright (C) 2026 Analog Devices, Inc. All rights reserved.
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

package status_signals_pkg;

  import logger_pkg::*;
  import adi_component_pkg::*;
  import adi_environment_pkg::*;
  import io_vip_if_base_pkg::*;

  class status_signals extends adi_component;

    protected static int elements_in_fifo_master;
    protected static int elements_in_fifo_slave;
    protected static int triggers_in_progress;

    protected bit async;
    protected bit [31:0] address;
    protected bit [31:0] almost_empty;
    protected bit [31:0] almost_full;

    protected event trigger_done;
    protected event slave_check_status;
    protected event slave_done_checking;
    protected event master_check_status;
    protected event master_done_checking;

    protected io_vip_if_base master_status_signals_vip_if;
    protected io_vip_if_base slave_status_signals_vip_if;
    protected io_vip_if_base master_control_signals_vip_if;
    protected io_vip_if_base slave_control_signals_vip_if;

    enum bit {
      SLAVE=1'b1,
      MASTER=1'b0
    } side_t;

    function new(
      input string name,
      input bit async,
      input bit [31:0] address,
      input bit [31:0] almost_empty,
      input bit [31:0] almost_full,
      input io_vip_if_base master_status_signals_vip_if,
      input io_vip_if_base slave_status_signals_vip_if,
      input io_vip_if_base master_control_signals_vip_if,
      input io_vip_if_base slave_control_signals_vip_if,
      input adi_environment parent = null);

      super.new(name, parent);

      this.elements_in_fifo_master = 'd0;
      this.elements_in_fifo_slave = 'd0;
      this.triggers_in_progress = 'd0;

      this.async = async;
      this.address = address;
      this.almost_empty = almost_empty;
      this.almost_full = almost_full;

      this.master_status_signals_vip_if = master_status_signals_vip_if;
      this.slave_status_signals_vip_if = slave_status_signals_vip_if;
      this.master_control_signals_vip_if = master_control_signals_vip_if;
      this.slave_control_signals_vip_if = slave_control_signals_vip_if;

      this.master_status_signals_vip_if.set_negative_edge();
      this.slave_status_signals_vip_if.set_negative_edge();
      this.master_control_signals_vip_if.set_negative_edge();
      this.slave_control_signals_vip_if.set_negative_edge();
    endfunction: new

    virtual task slave_checker();
      logic [35:0] status_io_value;

      forever begin
        @this.slave_check_status;

        status_io_value = this.slave_status_signals_vip_if.get_io();
        this.info($sformatf("Slave: %0d | Room: %0d", this.elements_in_fifo_slave, status_io_value[35:4]), ADI_VERBOSITY_MEDIUM);
        this.info($sformatf("Slave Empty: %0d | Almost: %0d | Full: %0d | Almost: %0d | Room: %0d", status_io_value[0], status_io_value[1], status_io_value[2], status_io_value[3], status_io_value[35:4]), ADI_VERBOSITY_MEDIUM);

        if (2**this.address-1 - this.elements_in_fifo_slave !== status_io_value[35:4]) begin
          this.error($sformatf("Incorrect FIFO room! Simulated room: %0d | Actual room: %0d", 2**this.address-1 - this.elements_in_fifo_slave, status_io_value[35:4]));
        end
        if ((this.elements_in_fifo_slave != 'd0 && status_io_value[0]) ||
          (this.elements_in_fifo_slave == 'd0 && !status_io_value[0])) begin
          this.error($sformatf("Incorrect Empty status! Actual elements: %0d", this.elements_in_fifo_slave));
        end
        if ((this.elements_in_fifo_slave > this.almost_empty && status_io_value[1]) ||
          (this.elements_in_fifo_slave <= this.almost_empty && !status_io_value[1])) begin
          this.error($sformatf("Incorrect Almost Empty status! Actual elements: %0d | Threshold: %0d", this.elements_in_fifo_slave, this.almost_empty));
        end
        if ((this.elements_in_fifo_slave != 2**this.address-1 && status_io_value[2]) ||
          (this.elements_in_fifo_slave == 2**this.address-1 && !status_io_value[2])) begin
          this.error($sformatf("Incorrect Full status! Actual elements: %0d | Max elements: %0d", this.elements_in_fifo_slave, 2**this.address-1));
        end
        if ((this.elements_in_fifo_slave < 2**this.address-1-this.almost_full && status_io_value[3]) ||
          (this.elements_in_fifo_slave >= 2**this.address-1-this.almost_full && !status_io_value[3])) begin
          this.error($sformatf("Incorrect Almost Full status! Actual elements: %0d | Max elements: %0d | Threshold: %0d", this.elements_in_fifo_slave, 2**this.address-1, this.almost_full));
        end

        -> this.slave_done_checking;
      end
    endtask: slave_checker

    virtual task master_checker();
      logic [35:0] status_io_value;

      forever begin
        @this.master_check_status;

        status_io_value = this.master_status_signals_vip_if.get_io();
        this.info($sformatf("Master: %0d | Level: %0d", this.elements_in_fifo_master, status_io_value[35:4]), ADI_VERBOSITY_MEDIUM);
        this.info($sformatf("Master Empty: %0d | Almost: %0d | Full: %0d | Almost: %0d | Level: %0d", status_io_value[0], status_io_value[1], status_io_value[2], status_io_value[3], status_io_value[35:4]), ADI_VERBOSITY_MEDIUM);

        if (this.elements_in_fifo_master !== status_io_value[35:4]) begin
          this.error($sformatf("Incorrect FIFO level! Simulated level: %0d | Actual level: %0d", this.elements_in_fifo_master, status_io_value[35:4]));
        end
        if ((this.elements_in_fifo_master != 'd0 && status_io_value[0]) ||
          (this.elements_in_fifo_master == 'd0 && !status_io_value[0])) begin
          this.error($sformatf("Incorrect Empty status! Actual elements: %0d", this.elements_in_fifo_master));
        end
        if ((this.elements_in_fifo_master > this.almost_empty && status_io_value[1]) ||
          (this.elements_in_fifo_master <= this.almost_empty && !status_io_value[1])) begin
          this.error($sformatf("Incorrect Almost Empty status! Actual elements: %0d | Threshold: %0d", this.elements_in_fifo_master, this.almost_empty));
        end
        if ((this.elements_in_fifo_master != 2**this.address-1 && status_io_value[2]) ||
          (this.elements_in_fifo_master == 2**this.address-1 && !status_io_value[2])) begin
          this.error($sformatf("Incorrect Full status! Actual elements: %0d | Max elements: %0d", this.elements_in_fifo_master, 2**this.address-1));
        end
        if ((this.elements_in_fifo_master < 2**this.address-1-this.almost_full && status_io_value[3]) ||
          (this.elements_in_fifo_master >= 2**this.address-1-this.almost_full && !status_io_value[3])) begin
          this.error($sformatf("Incorrect Almost Full status! Actual elements: %0d | Max elements: %0d | Threshold: %0d", this.elements_in_fifo_master, 2**this.address-1, this.almost_full));
        end

        -> this.master_done_checking;
      end
    endtask: master_checker

    virtual automatic task slave_trigger_slave_status();
      this.triggers_in_progress++;

      this.slave_status_signals_vip_if.wait_posedge_clk();

      this.elements_in_fifo_slave = this.elements_in_fifo_slave + 'd1;

      ->> this.slave_check_status;
      @this.slave_done_checking;

      this.triggers_in_progress--;
      ->> this.trigger_done;
    endtask: slave_trigger_slave_status

    virtual automatic task slave_trigger_master_status();
      this.triggers_in_progress++;

      if (this.async) begin
        this.slave_control_signals_vip_if.wait_posedge_clk();
        repeat(3) begin
          this.master_status_signals_vip_if.wait_posedge_clk();
        end
      end
      this.master_status_signals_vip_if.wait_posedge_clk();

      this.elements_in_fifo_master = this.elements_in_fifo_master + 'd1;

      ->> this.master_check_status;
      @this.master_done_checking;

      this.triggers_in_progress--;
      ->> this.trigger_done;
    endtask: slave_trigger_master_status

    virtual automatic task master_trigger_master_status();
      this.triggers_in_progress++;

      this.elements_in_fifo_master = this.elements_in_fifo_master - 'd1;

      ->> this.master_check_status;
      @this.master_done_checking;

      this.triggers_in_progress--;
      ->> this.trigger_done;
    endtask: master_trigger_master_status

    virtual automatic task master_trigger_slave_status();
      this.triggers_in_progress++;

      if (this.async) begin
        repeat(3) begin
          this.slave_status_signals_vip_if.wait_posedge_clk();
        end
        this.slave_status_signals_vip_if.wait_posedge_clk();
      end

      this.elements_in_fifo_slave = this.elements_in_fifo_slave - 'd1;

      ->> this.slave_check_status;
      @this.slave_done_checking;

      this.triggers_in_progress--;
      ->> this.trigger_done;
    endtask: master_trigger_slave_status

    task monitor_slave_control_io();
      logic [1:0] control_io_value;

      forever begin
        this.slave_control_signals_vip_if.wait_posedge_clk();
        control_io_value = this.slave_control_signals_vip_if.get_io();

        if (control_io_value == 2'b11) begin
          fork
            this.slave_trigger_slave_status();
            this.slave_trigger_master_status();
          join_none
        end
      end
    endtask: monitor_slave_control_io

    task monitor_master_control_io();
      logic [1:0] control_io_value;
      bit control_triggered = 1'b0;

      forever begin
        this.master_control_signals_vip_if.wait_posedge_clk();
        control_io_value = this.master_control_signals_vip_if.get_io();

        if (!control_triggered && control_io_value[0]) begin
          fork
            this.master_trigger_master_status();
            this.master_trigger_slave_status();
          join_none
          control_triggered = 1'b1;
        end

        if (control_io_value == 2'b11) begin
          control_triggered = 1'b0;
        end
      end
    endtask: monitor_master_control_io

    task start();
      if (address > 1) begin
        fork
          this.monitor_slave_control_io();
          this.monitor_master_control_io();
          this.slave_checker();
          this.master_checker();
          ->> this.slave_check_status;
          ->> this.master_check_status;
        join_none
      end
    endtask: start

    task wait_triggers();
      while (this.triggers_in_progress) begin
        @this.trigger_done;
      end
    endtask: wait_triggers

  endclass: status_signals

endpackage: status_signals_pkg
