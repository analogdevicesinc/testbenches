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

package clk_gen_api_pkg;

  import logger_pkg::*;
  import adi_api_pkg::*;
  import adi_regmap_clkgen_pkg::*;
  import adi_regmap_pkg::*;
  import m_axi_sequencer_pkg::*;

  class clk_gen_api extends adi_api;

    function new(
      input string name,
      input m_axi_sequencer_base bus,
      input bit [31:0] base_address,
      input adi_component parent = null);

      super.new(name, bus, base_address, parent);
    endfunction


    task enable_clkgen();
      this.axi_write(GetAddrs(AXI_CLKGEN_REG_RSTN),
        `SET_AXI_CLKGEN_REG_RSTN_MMCM_RSTN(1) |
        `SET_AXI_CLKGEN_REG_RSTN_RSTN(1));
    endtask

  endclass

endpackage
