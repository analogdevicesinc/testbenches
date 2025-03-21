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

package xcvr_api_pkg;

  import logger_pkg::*;
  import adi_api_pkg::*;
  import adi_regmap_xcvr_pkg::*;
  import adi_regmap_pkg::*;
  import m_axi_sequencer_pkg::*;

  class xcvr_api extends adi_api;

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
      this.axi_verify(GetAddrs(XCVR_VERSION), `SET_XCVR_VERSION_VERSION(`DEFAULT_XCVR_VERSION_VERSION));
      // scratch
      data = 32'hdeadbeef;
      this.axi_write(GetAddrs(XCVR_SCRATCH), `SET_XCVR_SCRATCH_SCRATCH(data));
      this.axi_verify(GetAddrs(XCVR_SCRATCH), `SET_XCVR_SCRATCH_SCRATCH(data));
    endtask

    task reset(
      input bit bufstatus_rst,
      input bit resetn);

      this.axi_write(GetAddrs(XCVR_RESETN),
        `SET_XCVR_RESETN_BUFSTATUS_RST(bufstatus_rst) |
        `SET_XCVR_RESETN_RESETN(resetn));
    endtask

    task get_control(
      output logic lpm_dfe_n,
      output logic [2:0] rate,
      output logic [1:0] sysclk_sel,
      output logic [2:0] outclk_sel);

      this.axi_read(GetAddrs(XCVR_CONTROL), val);
      lpm_dfe_n = `GET_XCVR_CONTROL_LPM_DFE_N(val);
      rate = `GET_XCVR_CONTROL_RATE(val);
      sysclk_sel = `GET_XCVR_CONTROL_SYSCLK_SEL(val);
      outclk_sel = `GET_XCVR_CONTROL_OUTCLK_SEL(val);
    endtask

    task set_control(
      input bit lpm_dfe_n,
      input bit [2:0] rate,
      input bit [1:0] sysclk_sel,
      input bit [2:0] outclk_sel);

      this.axi_write(GetAddrs(XCVR_CONTROL),
        `SET_XCVR_CONTROL_LPM_DFE_N(lpm_dfe_n) |
        `SET_XCVR_CONTROL_RATE(rate) |
        `SET_XCVR_CONTROL_SYSCLK_SEL(sysclk_sel) |
        `SET_XCVR_CONTROL_OUTCLK_SEL(outclk_sel));
    endtask

  endclass

endpackage
