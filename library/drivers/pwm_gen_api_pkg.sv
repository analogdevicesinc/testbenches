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

package pwm_gen_api_pkg;

  import logger_pkg::*;
  import adi_component_pkg::*;
  import adi_api_pkg::*;
  import adi_regmap_pwm_gen_pkg::*;
  import adi_regmap_pkg::*;
  import m_axi_sequencer_pkg::*;

  class pwm_gen_api extends adi_api;

    bit reset_state;

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
      this.axi_verify(GetAddrs(AXI_PWM_GEN_REG_VERSION), `SET_AXI_PWM_GEN_REG_VERSION_VERSION(`DEFAULT_AXI_PWM_GEN_REG_VERSION_VERSION));
      // scratch
      data = 32'hdeadbeef;
      this.axi_write(GetAddrs(AXI_PWM_GEN_REG_SCRATCH), `SET_AXI_PWM_GEN_REG_SCRATCH_SCRATCH(data));
      this.axi_verify(GetAddrs(AXI_PWM_GEN_REG_SCRATCH), `SET_AXI_PWM_GEN_REG_SCRATCH_SCRATCH(data));
      // magic
      this.axi_verify(GetAddrs(AXI_PWM_GEN_REG_CORE_MAGIC), `SET_AXI_PWM_GEN_REG_CORE_MAGIC_CORE_MAGIC(`DEFAULT_AXI_PWM_GEN_REG_CORE_MAGIC_CORE_MAGIC));
    endtask

    task reset();
      this.reset_state = 1'b1;
      this.axi_write(GetAddrs(AXI_PWM_GEN_REG_RSTN), `SET_AXI_PWM_GEN_REG_RSTN_RESET(1));
    endtask

    task start();
      this.reset_state = 1'b0;
      this.axi_write(GetAddrs(AXI_PWM_GEN_REG_RSTN), `SET_AXI_PWM_GEN_REG_RSTN_RESET(0));
    endtask

    task load_config();
      this.axi_write(GetAddrs(AXI_PWM_GEN_REG_RSTN),
        `SET_AXI_PWM_GEN_REG_RSTN_LOAD_CONFIG(1) |
        `SET_AXI_PWM_GEN_REG_RSTN_RESET(this.reset_state));
    endtask

    task pulse_config(
      input bit [7:0] channel,
      input bit [31:0] period,
      input bit [31:0] width,
      input bit [31:0] offset);

      this.pulse_period_config(channel, period);
      this.pulse_width_config(channel, width);
      this.pulse_offset_config(channel, offset);
    endtask

    task pulse_period_config(
      input bit [7:0] channel,
      input bit [31:0] period);

      this.axi_write(channel * 'h4 + GetAddrs(AXI_PWM_GEN_REG_PULSE_X_PERIOD), `SET_AXI_PWM_GEN_REG_PULSE_X_PERIOD_PULSE_X_PERIOD(period));
    endtask

    task pulse_width_config(
      input bit [7:0] channel,
      input bit [31:0] width);

      this.axi_write(channel * 'h4 + GetAddrs(AXI_PWM_GEN_REG_PULSE_X_WIDTH), `SET_AXI_PWM_GEN_REG_PULSE_X_WIDTH_PULSE_X_WIDTH(width));
    endtask

    task pulse_offset_config(
      input bit [7:0] channel,
      input bit [31:0] offset);

      this.axi_write(channel * 'h4 + GetAddrs(AXI_PWM_GEN_REG_PULSE_X_OFFSET), `SET_AXI_PWM_GEN_REG_PULSE_X_OFFSET_PULSE_X_OFFSET(offset));
    endtask

  endclass

endpackage
