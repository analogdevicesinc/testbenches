// ***************************************************************************
// ***************************************************************************
// Copyright (C) 2014-2025 Analog Devices, Inc. All rights reserved.
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
`include "axis_definitions.svh"

package s_axis_sequencer_pkg;

  import axi4stream_vip_pkg::*;
  import adi_agent_pkg::*;
  import adi_sequencer_pkg::*;
  import logger_pkg::*;

  virtual class s_axis_sequencer_base extends adi_sequencer;

    protected xil_axi4stream_ready_gen_policy_t mode;

    protected bit variable_ranges;

    protected xil_axi4stream_uint high_time;
    protected xil_axi4stream_uint high_time_min;
    protected xil_axi4stream_uint high_time_max;

    protected xil_axi4stream_uint low_time;
    protected xil_axi4stream_uint low_time_min;
    protected xil_axi4stream_uint low_time_max;

    protected xil_axi4stream_uint event_count;
    protected xil_axi4stream_uint event_count_min;
    protected xil_axi4stream_uint event_count_max;


    // new
    function new(
      input string name,
      input adi_agent parent = null);

      super.new(name, parent);

      // ready gen policy
      this.mode = XIL_AXI4STREAM_READY_GEN_RANDOM;

      // high times
      this.high_time = 1;
      this.high_time_min = 1;
      this.high_time_max = 1;

      // low times
      this.low_time = 0;
      this.low_time_min = 0;
      this.low_time_max = 0;

      // variablel high/low times
      this.variable_ranges = 0;

      // event counts
      this.event_count = 0;
      this.event_count_min = 0;
      this.event_count_max = 0;
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
    endfunction: set_mode

    // high time functions
    function void set_high_time(input xil_axi4stream_uint high_time);
      this.high_time = high_time;
    endfunction: set_high_time

    function void set_high_time_range(
      input xil_axi4stream_uint high_time_min,
      input xil_axi4stream_uint high_time_max);

      this.high_time_min = high_time_min;
      this.high_time_max = high_time_max;
    endfunction: set_high_time_range

    // low time functions
    function void set_low_time(input xil_axi4stream_uint low_time);
      this.low_time = low_time;
    endfunction: set_low_time

    function void set_low_time_range(
      input xil_axi4stream_uint low_time_min,
      input xil_axi4stream_uint low_time_max);

      this.low_time_min = low_time_min;
      this.low_time_max = low_time_max;
    endfunction: set_low_time_range

    // event count functions
    function void set_event_count(input xil_axi4stream_uint event_count);
      this.event_count = event_count;
    endfunction: set_event_count

    function void set_event_count_range(
      input xil_axi4stream_uint event_count_min,
      input xil_axi4stream_uint event_count_max);

      this.event_count_min = event_count_min;
      this.event_count_max = event_count_max;
    endfunction: set_event_count_range

    // virtual tasks to be implemented
    pure virtual task start();

    pure virtual task stop();

  endclass: s_axis_sequencer_base


  class s_axis_sequencer #(`AXIS_VIP_PARAM_DECL(AXIS)) extends s_axis_sequencer_base;

    protected axi4stream_slv_driver #(`AXIS_VIP_IF_PARAMS(AXIS)) driver;


    function new(
      input string name,
      input axi4stream_slv_driver #(`AXIS_VIP_IF_PARAMS(AXIS)) driver,
      input adi_agent parent = null);

      super.new(name, parent);

      this.driver = driver;
    endfunction: new


    virtual task start();
      axi4stream_ready_gen tready_gen;

      tready_gen = this.driver.create_ready("TREADY");

      tready_gen.set_ready_policy(this.mode);

      if (this.mode != XIL_AXI4STREAM_READY_GEN_NO_BACKPRESSURE) begin
        if (this.variable_ranges) begin
          tready_gen.set_use_variable_ranges();
        end else begin
          tready_gen.clr_use_variable_ranges();
        end

        tready_gen.set_low_time(this.low_time);
        tready_gen.set_low_time_range(this.low_time_min, this.low_time_max);

        tready_gen.set_high_time(this.high_time);
        tready_gen.set_high_time_range(this.high_time_min, this.high_time_max);

        tready_gen.set_event_count(this.event_count);
        tready_gen.set_event_count_range(this.event_count_min, this.event_count_max);
      end
      this.driver.send_tready(tready_gen);
    endtask: start

    virtual task stop();
      this.driver.vif_proxy.reset();
    endtask: stop

  endclass: s_axis_sequencer

endpackage: s_axis_sequencer_pkg
