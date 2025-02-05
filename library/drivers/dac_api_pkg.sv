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

package dac_api_pkg;

  import logger_pkg::*;
  import adi_peripheral_pkg::*;
  import adi_regmap_dac_pkg::*;
  import adi_regmap_pkg::*;
  import reg_accessor_pkg::*;

  class dac_api extends adi_peripheral;

    protected logic [31:0] val;

    function new(
      input string name,
      input reg_accessor bus,
      input bit [31:0] base_address,
      input adi_component parent = null);

      super.new(name, bus, base_address, parent);
    endfunction

    task enable();
      this.axi_write(GetAddrs(DAC_COMMON_REG_RSTN), `SET_DAC_COMMON_REG_RSTN_RSTN(1));
    endtask

    task set_control_1(
      input logic sync,
      input logic ext_sync_arm,
      input logic ext_sync_disarm,
      input logic manual_sync_request);

      this.axi_write(GetAddrs(DAC_COMMON_REG_CNTRL_1), 
        `SET_DAC_COMMON_REG_CNTRL_1_SYNC(sync) |
        `SET_DAC_COMMON_REG_CNTRL_1_EXT_SYNC_ARM(ext_sync_arm) |
        `SET_DAC_COMMON_REG_CNTRL_1_EXT_SYNC_DISARM(ext_sync_disarm) |
        `SET_DAC_COMMON_REG_CNTRL_1_MANUAL_SYNC_REQUEST(manual_sync_request));
    endtask

    task get_status(output logic status)
      this.axi_read(GetAddrs(DAC_COMMON_REG_SYNC_STATUS), val);
      status = `GET_DAC_COMMON_REG_SYNC_STATUS_DAC_SYNC_STATUS(val);
    endtask

  endclass

endpackage
