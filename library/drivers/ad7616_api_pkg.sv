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

package ad7616_api_pkg;

  import logger_pkg::*;
  import adi_peripheral_pkg::*;
  import adi_regmap_ad7616_pkg::*;
  import adi_regmap_pkg::*;
  import reg_accessor_pkg::*;

  class ad7616_api extends adi_peripheral;

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
      this.axi_verify(GetAddrs(AXI_AD7616_REG_VERSION), `DEFAULT_AXI_AD7616_REG_VERSION_VERSION);
      // scratch
      data = 32'hdeadbeef;
      this.axi_write(GetAddrs(AXI_AD7616_REG_SCRATCH), `SET_AXI_AD7616_REG_SCRATCH_SCRATCH(data));
      this.axi_verify(GetAddrs(AXI_AD7616_REG_SCRATCH), `GET_AXI_AD7616_REG_SCRATCH_SCRATCH(data));
    endtask

    task enable_device();
      this.axi_write(GetAddrs(AXI_AD7616_REG_UP_CNTRL),
        `SET_AXI_AD7616_REG_UP_CNTRL_RESETN(1) |
        `SET_AXI_AD7616_REG_UP_CNTRL_CNVST_EN(0));
    endtask

    task disable_device();
      this.axi_write(GetAddrs(AXI_AD7616_REG_UP_CNTRL),
        `SET_AXI_AD7616_REG_UP_CNTRL_RESETN(0) |
        `SET_AXI_AD7616_REG_UP_CNTRL_CNVST_EN(0));
    endtask

    task start_device();
      this.axi_write(GetAddrs(AXI_AD7616_REG_UP_CNTRL),
        `SET_AXI_AD7616_REG_UP_CNTRL_RESETN(1) |
        `SET_AXI_AD7616_REG_UP_CNTRL_CNVST_EN(1));
    endtask

    task stop_device();
      this.axi_write(GetAddrs(AXI_AD7616_REG_UP_CNTRL),
        `SET_AXI_AD7616_REG_UP_CNTRL_RESETN(1) |
        `SET_AXI_AD7616_REG_UP_CNTRL_CNVST_EN(0));
    endtask

    task parallel_write_reg();
      this.axi_write(GetAddrs(AXI_AD7616_REG_UP_WRITE_DATA), `SET_AXI_AD7616_REG_UP_WRITE_DATA_UP_WRITE_DATA(0));
    endtask

    task parallel_read_reg(output logic [31:0] data);
      this.axi_read(GetAddrs(AXI_AD7616_REG_UP_READ_DATA), val);
      data = `GET_AXI_AD7616_REG_UP_READ_DATA_UP_READ_DATA(val);
    endtask

  endclass

endpackage
