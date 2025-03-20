// ***************************************************************************
// ***************************************************************************
// Copyright 2014 - 2025 (c) Analog Devices, Inc. All rights reserved.
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

package tdd_api_pkg;

  import logger_pkg::*;
  import adi_api_pkg::*;
  import adi_regmap_tdd_gen_pkg::*;
  import adi_regmap_pkg::*;
  import m_axi_sequencer_pkg::*;

  class tdd_api extends adi_api;

    protected logic [31:0] val;

    function new(
      input string name,
      input m_axi_sequencer_base bus,
      input bit [31:0] base_address,
      input adi_component parent = null);

      super.new(name, bus, base_address, parent);
    endfunction


    task sanity_test();
      reg [31:0] data;
      // version
      this.axi_verify(GetAddrs(TDDN_CNTRL_VERSION),
        `SET_TDDN_CNTRL_VERSION_VERSION_MAJOR(`DEFAULT_TDDN_CNTRL_VERSION_VERSION_MAJOR) |
        `SET_TDDN_CNTRL_VERSION_VERSION_MINOR(`DEFAULT_TDDN_CNTRL_VERSION_VERSION_MINOR) |
        `SET_TDDN_CNTRL_VERSION_VERSION_PATCH(`DEFAULT_TDDN_CNTRL_VERSION_VERSION_PATCH));
      // scratch
      data = 32'hdeadbeef;
      this.axi_write(GetAddrs(TDDN_CNTRL_SCRATCH), `SET_TDDN_CNTRL_SCRATCH_SCRATCH(data));
      this.axi_verify(GetAddrs(TDDN_CNTRL_SCRATCH), `SET_TDDN_CNTRL_SCRATCH_SCRATCH(data));
      // magic
      this.axi_verify(GetAddrs(TDDN_CNTRL_IDENTIFICATION), `SET_TDDN_CNTRL_IDENTIFICATION_IDENTIFICATION(`DEFAULT_TDDN_CNTRL_IDENTIFICATION_IDENTIFICATION));
    endtask

    task get_interface_description(output logic [31:0] description);
      this.axi_read(GetAddrs(TDDN_CNTRL_INTERFACE_DESCRIPTION), description);
    endtask

    task set_channel_enable(input bit [31:0] enable);
      this.axi_write(GetAddrs(TDDN_CNTRL_CHANNEL_ENABLE), `SET_TDDN_CNTRL_CHANNEL_ENABLE_CHANNEL_ENABLE(enable));
    endtask

    task get_channel_enable(output logic [31:0] enable);
      this.axi_read(GetAddrs(TDDN_CNTRL_CHANNEL_ENABLE), val);
      enable = `GET_TDDN_CNTRL_CHANNEL_ENABLE_CHANNEL_ENABLE(val);
    endtask

    task set_channel_polarity(input bit [31:0] polarity);
      this.axi_write(GetAddrs(TDDN_CNTRL_CHANNEL_POLARITY), `SET_TDDN_CNTRL_CHANNEL_POLARITY_CHANNEL_POLARITY(polarity));
    endtask

    task get_channel_polarity(output logic [31:0] polarity);
      this.axi_read(GetAddrs(TDDN_CNTRL_CHANNEL_POLARITY), val);
      polarity = `GET_TDDN_CNTRL_CHANNEL_POLARITY_CHANNEL_POLARITY(val);
    endtask

    task set_burst_count(input bit [31:0] count);
      this.axi_write(GetAddrs(TDDN_CNTRL_BURST_COUNT), `SET_TDDN_CNTRL_BURST_COUNT_BURST_COUNT(count+1));
    endtask

    task get_burst_count(output logic [31:0] count);
      this.axi_read(GetAddrs(TDDN_CNTRL_BURST_COUNT), val);
      count = `GET_TDDN_CNTRL_BURST_COUNT_BURST_COUNT(val) + 1;
    endtask

    task set_startup_delay(input bit [31:0] delay);
      this.axi_write(GetAddrs(TDDN_CNTRL_STARTUP_DELAY), `SET_TDDN_CNTRL_STARTUP_DELAY_STARTUP_DELAY(delay));
    endtask

    task get_startup_delay(output logic [31:0] delay);
      this.axi_read(GetAddrs(TDDN_CNTRL_STARTUP_DELAY), val);
      delay = `GET_TDDN_CNTRL_STARTUP_DELAY_STARTUP_DELAY(val);
    endtask

    task set_frame_length(input bit [31:0] length);
      this.axi_write(GetAddrs(TDDN_CNTRL_FRAME_LENGTH), `SET_TDDN_CNTRL_FRAME_LENGTH_FRAME_LENGTH(length));
    endtask

    task get_frame_length(output logic [31:0] length);
      this.axi_read(GetAddrs(TDDN_CNTRL_FRAME_LENGTH), val);
      length = `GET_TDDN_CNTRL_FRAME_LENGTH_FRAME_LENGTH(val);
    endtask

    task set_sync_counter_low(input bit [31:0] counter);
      this.axi_write(GetAddrs(TDDN_CNTRL_SYNC_COUNTER_LOW), `SET_TDDN_CNTRL_SYNC_COUNTER_LOW_SYNC_COUNTER_LOW(counter));
    endtask

    task get_sync_counter_low(output logic [31:0] counter);
      this.axi_read(GetAddrs(TDDN_CNTRL_SYNC_COUNTER_LOW), val);
      counter = `GET_TDDN_CNTRL_SYNC_COUNTER_LOW_SYNC_COUNTER_LOW(val);
    endtask

    task set_sync_counter_high(input bit [31:0] counter);
      this.axi_write(GetAddrs(TDDN_CNTRL_SYNC_COUNTER_HIGH), `SET_TDDN_CNTRL_SYNC_COUNTER_HIGH_SYNC_COUNTER_HIGH(counter));
    endtask

    task get_sync_counter_high(output logic [31:0] counter);
      this.axi_read(GetAddrs(TDDN_CNTRL_SYNC_COUNTER_HIGH), val);
      counter = `GET_TDDN_CNTRL_SYNC_COUNTER_HIGH_SYNC_COUNTER_HIGH(val);
    endtask

    task set_sync_counter(
      input bit [31:0] counter_low,
      input bit [31:0] counter_high);

      this.set_sync_counter_low(counter_low);
      this.set_sync_counter_high(counter_high);
    endtask

    task get_status(output logic [31:0] status);
      this.axi_read(GetAddrs(TDDN_CNTRL_STATUS), val);
      status = `GET_TDDN_CNTRL_STATUS_STATE(val);
    endtask

    task set_control(
      input bit sync_soft,
      input bit sync_ext,
      input bit sync_int,
      input bit sync_rst,
      input bit enable);

      this.axi_write(GetAddrs(TDDN_CNTRL_CONTROL),
        `SET_TDDN_CNTRL_CONTROL_SYNC_SOFT(sync_soft) |
        `SET_TDDN_CNTRL_CONTROL_SYNC_EXT(sync_ext) |
        `SET_TDDN_CNTRL_CONTROL_SYNC_INT(sync_int) |
        `SET_TDDN_CNTRL_CONTROL_SYNC_RST(sync_rst) |
        `SET_TDDN_CNTRL_CONTROL_ENABLE(enable));
    endtask

    task disable_tdd();
      this.axi_write(GetAddrs(TDDN_CNTRL_CONTROL), `SET_TDDN_CNTRL_CONTROL_ENABLE(0));
    endtask

  endclass

endpackage
