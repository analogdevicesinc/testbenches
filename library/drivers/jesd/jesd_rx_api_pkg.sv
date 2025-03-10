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

package jesd_rx_api_pkg;

  import logger_pkg::*;
  import adi_peripheral_pkg::*;
  import adi_regmap_jesd_rx_pkg::*;
  import adi_regmap_pkg::*;
  import reg_accessor_pkg::*;

  class jesd_rx_api extends adi_peripheral;

    protected logic [31:0] val;

    function new(
      input string name,
      input reg_accessor bus,
      input bit [31:0] base_address,
      input adi_component parent = null);

      super.new(name, bus, base_address, parent);
    endfunction

    
    task sanity_test();
      reg [31:0] data;
      // version
      this.axi_verify(GetAddrs(JESD_RX_VERSION), 
        `SET_JESD_RX_VERSION_VERSION_MAJOR(`DEFAULT_JESD_RX_VERSION_VERSION_MAJOR) |
        `SET_JESD_RX_VERSION_VERSION_MINOR(`DEFAULT_JESD_RX_VERSION_VERSION_MINOR) |
        `SET_JESD_RX_VERSION_VERSION_PATCH(`DEFAULT_JESD_RX_VERSION_VERSION_PATCH));
      // scratch
      data = 32'hdeadbeef;
      this.axi_write(GetAddrs(JESD_RX_SCRATCH), `SET_JESD_RX_SCRATCH_SCRATCH(data));
      this.axi_verify(GetAddrs(JESD_RX_SCRATCH), `GET_JESD_RX_SCRATCH_SCRATCH(data));
      // magic
      this.axi_verify(GetAddrs(JESD_RX_IDENTIFICATION), `DEFAULT_JESD_RX_IDENTIFICATION_IDENTIFICATION);
    endtask

    task get_sysref_status(
      output logic sysref_alignment_error,
      output logic sysref_detected);

      this.axi_read(GetAddrs(JESD_RX_SYSREF_STATUS), val);
      sysref_alignment_error = `GET_JESD_RX_SYSREF_STATUS_SYSREF_ALIGNMENT_ERROR(val);
      sysref_detected = `GET_JESD_RX_SYSREF_STATUS_SYSREF_DETECTED(val);
    endtask

    task enable_link();
      this.axi_write(GetAddrs(JESD_RX_LINK_DISABLE), `SET_JESD_RX_LINK_DISABLE_LINK_DISABLE(0));
    endtask

    task disable_link();
      this.axi_write(GetAddrs(JESD_RX_LINK_DISABLE), `SET_JESD_RX_LINK_DISABLE_LINK_DISABLE(1));
    endtask

    task enable_sysref_conf();
      this.axi_write(GetAddrs(JESD_RX_SYSREF_CONF), `SET_JESD_RX_SYSREF_CONF_SYSREF_DISABLE(0));
    endtask

    task set_link_conf0(
      input logic [2:0] octets_per_frame,
      input logic [9:0] octets_per_multiframe);

      this.axi_write(GetAddrs(JESD_RX_LINK_CONF0),
        `SET_JESD_RX_LINK_CONF0_OCTETS_PER_FRAME(octets_per_frame) |
        `SET_JESD_RX_LINK_CONF0_OCTETS_PER_MULTIFRAME(octets_per_multiframe));
    endtask

    task set_link_conf1(
      input logic char_replacement_disable,
      input logic descrambler_disable);

      this.axi_write(GetAddrs(JESD_RX_LINK_CONF1),
        `SET_JESD_RX_LINK_CONF1_CHAR_REPLACEMENT_DISABLE(char_replacement_disable) |
        `SET_JESD_RX_LINK_CONF1_DESCRAMBLER_DISABLE(descrambler_disable));
    endtask

    task set_link_conf2(
      input logic buffer_early_release,
      input logic [9:0] buffer_delay);

      this.axi_write(GetAddrs(JESD_RX_LINK_CONF2),
        `SET_JESD_RX_LINK_CONF2_BUFFER_EARLY_RELEASE(buffer_early_release) |
        `SET_JESD_RX_LINK_CONF2_BUFFER_DEALY(buffer_delay));
    endtask

    task set_link_conf4(input logic [7:0] tpl_beats_per_multiframe);
      this.axi_write(GetAddrs(JESD_RX_LINK_CONF4), `SET_JESD_RX_LINK_CONF4_TPL_BEATS_PER_MULTIFRAME(tpl_beats_per_multiframe));
    endtask

    task get_status(output logic [1:0] status_state);

      this.axi_read(GetAddrs(JESD_RX_LINK_STATUS), val);
      status_state = `GET_JESD_RX_LINK_STATUS_STATUS_STATE(val);
    endtask

  endclass

endpackage
