// ***************************************************************************
// ***************************************************************************
// Copyright 2014 - 2018 (c) Analog Devices, Inc. All rights reserved.
//
// In this HDL repository, there are many different and unique modules, consisting
// of various HDL (Verilog or VHDL) components. The individual modules are
// developed independently, and may be accompanied by separate and unique license
// terms.
//
// The user should read each of these license terms, and understand the
// freedoms and responsabilities that he or she has by using this source/core.
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
//      https://github.com/analogdevicesinc/hdl/blob/master/LICENSE_ADIBSD
//      This will allow to generate bit files and not release the source code,
//      as long as it attaches to an ADI device.
//
// ***************************************************************************
// ***************************************************************************

`include "utils.svh"
`include "axis_definitions.svh"

package s_axis_sequencer_pkg;

  import axi4stream_vip_pkg::*;
  import adi_common_pkg::*;
  import logger_pkg::*;

  class s_axis_sequencer_base extends adi_component;

    protected xil_axi4stream_data_byte byte_stream [$];
    protected xil_axi4stream_ready_gen_policy_t mode;

    protected bit variable_ranges;

    protected xil_axi4stream_uint high_time;
    protected xil_axi4stream_uint low_time;

    protected xil_axi4stream_uint high_time_min;
    protected xil_axi4stream_uint high_time_max;

    protected xil_axi4stream_uint low_time_min;
    protected xil_axi4stream_uint low_time_max;


    // new
    function new(
      input string name,
      input adi_agent parent = null);
      
      super.new(name, parent);

      this.mode = XIL_AXI4STREAM_READY_GEN_RANDOM;
      this.low_time = 0;
      this.high_time = 1;
      this.high_time_min = 1;
      this.high_time_max = 1;
      this.low_time_min = 0;
      this.low_time_max = 0;
      this.variable_ranges = 0;
    endfunction: new


    // function for variable ranges
    function void set_use_variable_ranges();
      this.variable_ranges = 1;
    endfunction: set_use_variable_ranges

    function void clr_use_variable_ranges();
      this.variable_ranges = 0;
    endfunction: clr_use_variable_ranges

    // ready generation policy functions
    function void set_mode(input xil_axi4stream_ready_gen_policy_t mode);
      this.mode = mode;
    endfunction

    function xil_axi4stream_ready_gen_policy_t get_mode();
      return this.mode;
    endfunction

    // high time functions
    function void set_high_time(input xil_axi4stream_uint high_time);
      this.high_time = high_time;
    endfunction

    function xil_axi4stream_uint get_high_time();
      return this.high_time;
    endfunction

    function void set_high_time_range(
      input xil_axi4stream_uint high_time_min, 
      input xil_axi4stream_uint high_time_max);

      this.high_time_min = high_time_min;
      this.high_time_max = high_time_max;
    endfunction

    // low time functions
    function void set_low_time(input xil_axi4stream_uint low_time);
      this.low_time = low_time;
    endfunction

    function xil_axi4stream_uint get_low_time();
      return this.low_time;
    endfunction

    function void set_low_time_range(
      input xil_axi4stream_uint low_time_min, 
      input xil_axi4stream_uint low_time_max);

      this.low_time_min = low_time_min;
      this.low_time_max = low_time_max;
    endfunction

    // function for verifying bytes
    task verify_byte(input bit [7:0] refdata);
      bit [7:0] data;
      if (byte_stream.size() == 0) begin
        this.error($sformatf("Byte steam empty !!!"));
      end else begin
        data = byte_stream.pop_front();
        if (data !== refdata) begin
          this.error($sformatf("Unexpected data received. Expected: %0h Found: %0h Left : %0d", refdata, data, byte_stream.size()));
        end
      end
    endtask

    // call ready generation function
    task run();
      user_gen_tready();
    endtask


    // virtual tasks to be implemented
    virtual task user_gen_tready();
    endtask

    virtual task get_transfer();
    endtask

  endclass: s_axis_sequencer_base


  class s_axis_sequencer #(int `AXIS_VIP_PARAM_ORDER(AXIS)) extends s_axis_sequencer_base;

    protected axi4stream_slv_driver #(`AXIS_VIP_IF_PARAMS(AXIS)) driver;


    function new(
      input string name,
      input axi4stream_slv_driver #(`AXIS_VIP_IF_PARAMS(AXIS)) driver,
      input adi_agent parent = null);
      
      super.new(name, parent);

      this.driver = driver;
    endfunction


    virtual task user_gen_tready();
      axi4stream_ready_gen tready_gen;
      
      tready_gen = this.driver.create_ready("TREADY");
      
      tready_gen.set_ready_policy(this.mode);

      if (this.variable_ranges)
        tready_gen.set_use_variable_ranges();
      else
        tready_gen.clr_use_variable_ranges();

      if (this.mode != XIL_AXI4STREAM_READY_GEN_NO_BACKPRESSURE) begin
        tready_gen.set_low_time(this.low_time);
        tready_gen.set_high_time(this.high_time);

        tready_gen.set_low_time_range(this.low_time_min, this.low_time_max);
        tready_gen.set_high_time_range(this.high_time_min, this.high_time_max);
      end
      this.driver.send_tready(tready_gen);
    endtask

  endclass

endpackage
