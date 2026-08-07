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

package status_signals_asym_pkg;

  import logger_pkg::*;
  import adi_environment_pkg::*;
  import io_vip_if_base_pkg::*;
  import status_signals_pkg::*;

  class status_signals_asym extends status_signals;

    protected bit reduced_fifo;
    protected bit ratio_type; // 0 - small slave / big   master
                              // 1 - big   slave / small master
    protected int ratio;

    function new(
      input string name,
      input bit async,
      input bit [31:0] address,
      input bit [31:0] almost_empty,
      input bit [31:0] almost_full,
      input bit [31:0] input_width,
      input bit [31:0] output_width,
      input bit reduced_fifo,
      input io_vip_if_base master_status_signals_vip_if,
      input io_vip_if_base slave_status_signals_vip_if,
      input io_vip_if_base master_control_signals_vip_if,
      input io_vip_if_base slave_control_signals_vip_if,
      input adi_environment parent = null);

      super.new(
        .name(name),
        .async(async),
        .address(address),
        .almost_empty(almost_empty),
        .almost_full(almost_full),
        .master_status_signals_vip_if(master_status_signals_vip_if),
        .slave_status_signals_vip_if(slave_status_signals_vip_if),
        .master_control_signals_vip_if(master_control_signals_vip_if),
        .slave_control_signals_vip_if(slave_control_signals_vip_if),
        .parent(parent));

      if (input_width >= output_width) begin
        this.ratio_type = 1;
        this.ratio = input_width / output_width;
      end else begin
        this.ratio_type = 0;
        this.ratio = output_width / input_width;
      end
      this.reduced_fifo = reduced_fifo;
    endfunction: new

    virtual task slave_checker();
      logic [35:0] status_io_value;

      forever begin
        @this.slave_check_status;

        status_io_value = this.slave_status_signals_vip_if.get_io();
        // this.info($sformatf("Slave: %0d | Room: %0d", this.elements_in_fifo_slave, status_io_value[35:4]), ADI_VERBOSITY_NONE);
        // this.info($sformatf("Slave Empty: %0d | Almost: %0d | Full: %0d | Almost: %0d | Room: %0d", status_io_value[0], status_io_value[1], status_io_value[2], status_io_value[3], status_io_value[35:4]), ADI_VERBOSITY_MEDIUM);

        if (this.ratio_type) begin
          if (this.reduced_fifo) begin
            // if (2**this.address-1 - this.elements_in_fifo_slave !== status_io_value[35:4]) begin
            //   this.error($sformatf("Incorrect FIFO room! Simulated room: %0d | Actual room: %0d", 2**this.address-1 - this.elements_in_fifo_slave, status_io_value[35:4]));
            // end
            // if ((this.elements_in_fifo_slave != 'd0 && status_io_value[0]) ||
            //   (this.elements_in_fifo_slave == 'd0 && !status_io_value[0])) begin
            //   this.error($sformatf("Incorrect Empty status! Actual elements: %0d", this.elements_in_fifo_slave));
            // end
            // if ((this.elements_in_fifo_slave > this.almost_empty && status_io_value[1]) ||
            //   (this.elements_in_fifo_slave <= this.almost_empty && !status_io_value[1])) begin
            //   this.error($sformatf("Incorrect Almost Empty status! Actual elements: %0d | Threshold: %0d", this.elements_in_fifo_slave, this.almost_empty));
            // end
            // if ((this.elements_in_fifo_slave != 2**this.address-1 && status_io_value[2]) ||
            //   (this.elements_in_fifo_slave == 2**this.address-1 && !status_io_value[2])) begin
            //   this.error($sformatf("Incorrect Full status! Actual elements: %0d | Max elements: %0d", this.elements_in_fifo_slave, 2**this.address-1));
            // end
            // if ((this.elements_in_fifo_slave < 2**this.address-1-this.almost_full && status_io_value[3]) ||
            //   (this.elements_in_fifo_slave >= 2**this.address-1-this.almost_full && !status_io_value[3])) begin
            //   this.error($sformatf("Incorrect Almost Full status! Actual elements: %0d | Max elements: %0d | Threshold: %0d", this.elements_in_fifo_slave, 2**this.address-1, this.almost_full));
            // end
          end else begin
              // if (2**this.address-1 - this.elements_in_fifo_slave !== status_io_value[35:4]) begin
            //   this.error($sformatf("Incorrect FIFO room! Simulated room: %0d | Actual room: %0d", 2**this.address-1 - this.elements_in_fifo_slave, status_io_value[35:4]));
            // end
            // if ((this.elements_in_fifo_slave != 'd0 && status_io_value[0]) ||
            //   (this.elements_in_fifo_slave == 'd0 && !status_io_value[0])) begin
            //   this.error($sformatf("Incorrect Empty status! Actual elements: %0d", this.elements_in_fifo_slave));
            // end
            // if ((this.elements_in_fifo_slave > this.almost_empty && status_io_value[1]) ||
            //   (this.elements_in_fifo_slave <= this.almost_empty && !status_io_value[1])) begin
            //   this.error($sformatf("Incorrect Almost Empty status! Actual elements: %0d | Threshold: %0d", this.elements_in_fifo_slave, this.almost_empty));
            // end
            // if ((this.elements_in_fifo_slave != 2**this.address-1 && status_io_value[2]) ||
            //   (this.elements_in_fifo_slave == 2**this.address-1 && !status_io_value[2])) begin
            //   this.error($sformatf("Incorrect Full status! Actual elements: %0d | Max elements: %0d", this.elements_in_fifo_slave, 2**this.address-1));
            // end
            // if ((this.elements_in_fifo_slave < 2**this.address-1-this.almost_full && status_io_value[3]) ||
            //   (this.elements_in_fifo_slave >= 2**this.address-1-this.almost_full && !status_io_value[3])) begin
            //   this.error($sformatf("Incorrect Almost Full status! Actual elements: %0d | Max elements: %0d | Threshold: %0d", this.elements_in_fifo_slave, 2**this.address-1, this.almost_full));
            // end
          end
        end else begin
          if (this.reduced_fifo) begin
            // if (2**this.address-1 - this.elements_in_fifo_slave !== status_io_value[35:4]) begin
            //   this.error($sformatf("Incorrect FIFO room! Simulated room: %0d | Actual room: %0d", 2**this.address-1 - this.elements_in_fifo_slave, status_io_value[35:4]));
            // end
            // if ((this.elements_in_fifo_slave != 'd0 && status_io_value[0]) ||
            //   (this.elements_in_fifo_slave == 'd0 && !status_io_value[0])) begin
            //   this.error($sformatf("Incorrect Empty status! Actual elements: %0d", this.elements_in_fifo_slave));
            // end
            // if ((this.elements_in_fifo_slave > this.almost_empty && status_io_value[1]) ||
            //   (this.elements_in_fifo_slave <= this.almost_empty && !status_io_value[1])) begin
            //   this.error($sformatf("Incorrect Almost Empty status! Actual elements: %0d | Threshold: %0d", this.elements_in_fifo_slave, this.almost_empty));
            // end
            // if ((this.elements_in_fifo_slave != 2**this.address-1 && status_io_value[2]) ||
            //   (this.elements_in_fifo_slave == 2**this.address-1 && !status_io_value[2])) begin
            //   this.error($sformatf("Incorrect Full status! Actual elements: %0d | Max elements: %0d", this.elements_in_fifo_slave, 2**this.address-1));
            // end
            // if ((this.elements_in_fifo_slave < 2**this.address-1-this.almost_full && status_io_value[3]) ||
            //   (this.elements_in_fifo_slave >= 2**this.address-1-this.almost_full && !status_io_value[3])) begin
            //   this.error($sformatf("Incorrect Almost Full status! Actual elements: %0d | Max elements: %0d | Threshold: %0d", this.elements_in_fifo_slave, 2**this.address-1, this.almost_full));
            // end
          end else begin
            // if (2**this.address*ratio-ratio - this.elements_in_fifo_slave !== status_io_value[35:4]) begin
            //   this.error($sformatf("Incorrect FIFO room! Simulated room: %0d | Actual room: %0d", 2**this.address*ratio-ratio - this.elements_in_fifo_slave, status_io_value[35:4]));
            // end
            // if ((this.elements_in_fifo_slave != 'd0 && status_io_value[0]) ||
            //   (this.elements_in_fifo_slave == 'd0 && !status_io_value[0])) begin
            //   this.error($sformatf("Incorrect Empty status! Actual elements: %0d", this.elements_in_fifo_slave));
            // end
            // if ((this.elements_in_fifo_slave > this.almost_empty && status_io_value[1]) ||
            //   (this.elements_in_fifo_slave <= this.almost_empty && !status_io_value[1])) begin
            //   this.error($sformatf("Incorrect Almost Empty status! Actual elements: %0d | Threshold: %0d", this.elements_in_fifo_slave, this.almost_empty));
            // end
            // if ((this.elements_in_fifo_slave != 2**this.address-1 && status_io_value[2]) ||
            //   (this.elements_in_fifo_slave == 2**this.address-1 && !status_io_value[2])) begin
            //   this.error($sformatf("Incorrect Full status! Actual elements: %0d | Max elements: %0d", this.elements_in_fifo_slave, 2**this.address-1));
            // end
            // if ((this.elements_in_fifo_slave < 2**this.address-1-this.almost_full && status_io_value[3]) ||
            //   (this.elements_in_fifo_slave >= 2**this.address-1-this.almost_full && !status_io_value[3])) begin
            //   this.error($sformatf("Incorrect Almost Full status! Actual elements: %0d | Max elements: %0d | Threshold: %0d", this.elements_in_fifo_slave, 2**this.address-1, this.almost_full));
            // end
          end
        end

        -> this.slave_done_checking;
      end
    endtask: slave_checker

    virtual task master_checker();
      logic [35:0] status_io_value;

      forever begin
        @this.master_check_status;

        status_io_value = this.master_status_signals_vip_if.get_io();
        // this.info($sformatf("Master: %0d | Level: %0d", this.elements_in_fifo_master, status_io_value[35:4]), ADI_VERBOSITY_NONE);
        // this.info($sformatf("Master Empty: %0d | Almost: %0d | Full: %0d | Almost: %0d | Level: %0d", status_io_value[0], status_io_value[1], status_io_value[2], status_io_value[3], status_io_value[35:4]), ADI_VERBOSITY_MEDIUM);

        if (this.ratio_type) begin
          if (this.reduced_fifo) begin
            // if (this.elements_in_fifo_master !== status_io_value[35:4]) begin
            //   this.error($sformatf("Incorrect FIFO level! Simulated level: %0d | Actual level: %0d", this.elements_in_fifo_master, status_io_value[35:4]));
            // end
            // if ((this.elements_in_fifo_master != 'd0 && status_io_value[0]) ||
            //   (this.elements_in_fifo_master == 'd0 && !status_io_value[0])) begin
            //   this.error($sformatf("Incorrect Empty status! Actual elements: %0d", this.elements_in_fifo_master));
            // end
            // if ((this.elements_in_fifo_master > this.almost_empty && status_io_value[1]) ||
            //   (this.elements_in_fifo_master <= this.almost_empty && !status_io_value[1])) begin
            //   this.error($sformatf("Incorrect Almost Empty status! Actual elements: %0d | Threshold: %0d", this.elements_in_fifo_master, this.almost_empty));
            // end
            // if ((this.elements_in_fifo_master != 2**this.address-1 && status_io_value[2]) ||
            //   (this.elements_in_fifo_master == 2**this.address-1 && !status_io_value[2])) begin
            //   this.error($sformatf("Incorrect Full status! Actual elements: %0d | Max elements: %0d", this.elements_in_fifo_master, 2**this.address-1));
            // end
            // if ((this.elements_in_fifo_master < 2**this.address-1-this.almost_full && status_io_value[3]) ||
            //   (this.elements_in_fifo_master >= 2**this.address-1-this.almost_full && !status_io_value[3])) begin
            //   this.error($sformatf("Incorrect Almost Full status! Actual elements: %0d | Max elements: %0d | Threshold: %0d", this.elements_in_fifo_master, 2**this.address-1, this.almost_full));
            // end
          end else begin
            // if (this.elements_in_fifo_master !== status_io_value[35:4]) begin
            //   this.error($sformatf("Incorrect FIFO level! Simulated level: %0d | Actual level: %0d", this.elements_in_fifo_master, status_io_value[35:4]));
            // end
            // if ((this.elements_in_fifo_master != 'd0 && status_io_value[0]) ||
            //   (this.elements_in_fifo_master == 'd0 && !status_io_value[0])) begin
            //   this.error($sformatf("Incorrect Empty status! Actual elements: %0d", this.elements_in_fifo_master));
            // end
            // if ((this.elements_in_fifo_master > this.almost_empty && status_io_value[1]) ||
            //   (this.elements_in_fifo_master <= this.almost_empty && !status_io_value[1])) begin
            //   this.error($sformatf("Incorrect Almost Empty status! Actual elements: %0d | Threshold: %0d", this.elements_in_fifo_master, this.almost_empty));
            // end
            // if ((this.elements_in_fifo_master != 2**this.address-1 && status_io_value[2]) ||
            //   (this.elements_in_fifo_master == 2**this.address-1 && !status_io_value[2])) begin
            //   this.error($sformatf("Incorrect Full status! Actual elements: %0d | Max elements: %0d", this.elements_in_fifo_master, 2**this.address-1));
            // end
            // if ((this.elements_in_fifo_master < 2**this.address-1-this.almost_full && status_io_value[3]) ||
            //   (this.elements_in_fifo_master >= 2**this.address-1-this.almost_full && !status_io_value[3])) begin
            //   this.error($sformatf("Incorrect Almost Full status! Actual elements: %0d | Max elements: %0d | Threshold: %0d", this.elements_in_fifo_master, 2**this.address-1, this.almost_full));
            // end
          end
        end else begin
          if (this.reduced_fifo) begin
            // if (this.elements_in_fifo_master !== status_io_value[35:4]) begin
            //   this.error($sformatf("Incorrect FIFO level! Simulated level: %0d | Actual level: %0d", this.elements_in_fifo_master, status_io_value[35:4]));
            // end
            // if ((this.elements_in_fifo_master != 'd0 && status_io_value[0]) ||
            //   (this.elements_in_fifo_master == 'd0 && !status_io_value[0])) begin
            //   this.error($sformatf("Incorrect Empty status! Actual elements: %0d", this.elements_in_fifo_master));
            // end
            // if ((this.elements_in_fifo_master > this.almost_empty && status_io_value[1]) ||
            //   (this.elements_in_fifo_master <= this.almost_empty && !status_io_value[1])) begin
            //   this.error($sformatf("Incorrect Almost Empty status! Actual elements: %0d | Threshold: %0d", this.elements_in_fifo_master, this.almost_empty));
            // end
            // if ((this.elements_in_fifo_master != 2**this.address-1 && status_io_value[2]) ||
            //   (this.elements_in_fifo_master == 2**this.address-1 && !status_io_value[2])) begin
            //   this.error($sformatf("Incorrect Full status! Actual elements: %0d | Max elements: %0d", this.elements_in_fifo_master, 2**this.address-1));
            // end
            // if ((this.elements_in_fifo_master < 2**this.address-1-this.almost_full && status_io_value[3]) ||
            //   (this.elements_in_fifo_master >= 2**this.address-1-this.almost_full && !status_io_value[3])) begin
            //   this.error($sformatf("Incorrect Almost Full status! Actual elements: %0d | Max elements: %0d | Threshold: %0d", this.elements_in_fifo_master, 2**this.address-1, this.almost_full));
            // end
          end else begin
            // if (this.elements_in_fifo_master !== status_io_value[35:4]) begin
            //   this.error($sformatf("Incorrect FIFO level! Simulated level: %0d | Actual level: %0d", this.elements_in_fifo_master, status_io_value[35:4]));
            // end
            // if ((this.elements_in_fifo_master != 'd0 && status_io_value[0]) ||
            //   (this.elements_in_fifo_master == 'd0 && !status_io_value[0])) begin
            //   this.error($sformatf("Incorrect Empty status! Actual elements: %0d", this.elements_in_fifo_master));
            // end
            // if ((this.elements_in_fifo_master > this.almost_empty && status_io_value[1]) ||
            //   (this.elements_in_fifo_master <= this.almost_empty && !status_io_value[1])) begin
            //   this.error($sformatf("Incorrect Almost Empty status! Actual elements: %0d | Threshold: %0d", this.elements_in_fifo_master, this.almost_empty));
            // end
            // if ((this.elements_in_fifo_master != 2**this.address-1 && status_io_value[2]) ||
            //   (this.elements_in_fifo_master == 2**this.address-1 && !status_io_value[2])) begin
            //   this.error($sformatf("Incorrect Full status! Actual elements: %0d | Max elements: %0d", this.elements_in_fifo_master, 2**this.address-1));
            // end
            // if ((this.elements_in_fifo_master < 2**this.address-1-this.almost_full && status_io_value[3]) ||
            //   (this.elements_in_fifo_master >= 2**this.address-1-this.almost_full && !status_io_value[3])) begin
            //   this.error($sformatf("Incorrect Almost Full status! Actual elements: %0d | Max elements: %0d | Threshold: %0d", this.elements_in_fifo_master, 2**this.address-1, this.almost_full));
            // end
          end
        end

        -> this.master_done_checking;
      end
    endtask: master_checker

    virtual automatic task slave_trigger_slave_status();
      this.triggers_in_progress++;

      this.slave_status_signals_vip_if.wait_posedge_clk();

      this.elements_in_fifo_slave = this.elements_in_fifo_slave + ((this.ratio_type) ? this.ratio : 'd1);

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

      this.elements_in_fifo_master = this.elements_in_fifo_master + ((this.ratio_type) ? this.ratio : 'd1);

      ->> this.master_check_status;
      @this.master_done_checking;

      this.triggers_in_progress--;
      ->> this.trigger_done;
    endtask: slave_trigger_master_status

    virtual automatic task master_trigger_master_status();
      this.triggers_in_progress++;

      this.elements_in_fifo_master = this.elements_in_fifo_master - ((this.ratio_type) ? 'd1 : this.ratio);

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

      this.elements_in_fifo_slave = this.elements_in_fifo_slave - ((this.ratio_type) ? 'd1 : this.ratio);

      ->> this.slave_check_status;
      @this.slave_done_checking;

      this.triggers_in_progress--;
      ->> this.trigger_done;
    endtask: master_trigger_slave_status

  endclass: status_signals_asym

endpackage: status_signals_asym_pkg
