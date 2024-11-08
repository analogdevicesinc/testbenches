// ***************************************************************************
// ***************************************************************************
// Copyright (C) 2014 - 2024 Analog Devices, Inc. All rights reserved.
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
//      https://github.com/analogdevicesinc/hdl/blob/main/LICENSE_ADIBSD
//      This will allow to generate bit files and not release the source code,
//      as long as it attaches to an ADI device.
//
// ***************************************************************************
// ***************************************************************************
/* Auto generated Register Map */
/* Nov 08 14:35:39 2024 v0.3.49 */

package adi_regmap_clkgen_pkg;
  import regmap_pkg::*;

  class adi_regmap_clkgen;

    /* Clock Generator (axi_clkgen) */
    class RSTN_CLASS extends register_base;
      field_base MMCM_RSTN_F;
      field_base RSTN_F;

      function new(
        input string name,
        input int address);

        super.new(name, address);
        this.MMCM_RSTN_F = new("MMCM_RSTN", 1, 1, RW, 'h0, this);
        this.RSTN_F = new("RSTN", 0, 0, RW, 'h0, this);
      endfunction: new
    endclass

    class CLK_SEL_CLASS extends register_base;
      field_base CLK_SEL_F;

      function new(
        input string name,
        input int address);

        super.new(name, address);
        this.CLK_SEL_F = new("CLK_SEL", 0, 0, RW, 'h0, this);
      endfunction: new
    endclass

    class MMCM_STATUS_CLASS extends register_base;
      field_base MMCM_LOCKED_F;

      function new(
        input string name,
        input int address);

        super.new(name, address);
        this.MMCM_LOCKED_F = new("MMCM_LOCKED", 0, 0, RO, 'h0, this);
      endfunction: new
    endclass

    class DRP_CNTRL_CLASS extends register_base;
      field_base DRP_RWN_F;
      field_base DRP_ADDRESS_F;
      field_base DRP_WDATA_F;

      function new(
        input string name,
        input int address);

        super.new(name, address);
        this.DRP_RWN_F = new("DRP_RWN", 28, 28, RW, 'h0, this);
        this.DRP_ADDRESS_F = new("DRP_ADDRESS", 27, 16, RW, 'h0, this);
        this.DRP_WDATA_F = new("DRP_WDATA", 15, 0, RW, 'h0, this);
      endfunction: new
    endclass

    class DRP_STATUS_CLASS extends register_base;
      field_base MMCM_LOCKED_F;
      field_base DRP_STATUS_F;
      field_base DRP_RDATA_F;

      function new(
        input string name,
        input int address);

        super.new(name, address);
        this.MMCM_LOCKED_F = new("MMCM_LOCKED", 17, 17, RO, 'h0, this);
        this.DRP_STATUS_F = new("DRP_STATUS", 16, 16, RO, 'h0, this);
        this.DRP_RDATA_F = new("DRP_RDATA", 15, 0, RO, 'h0, this);
      endfunction: new
    endclass

    class FPGA_VOLTAGE_CLASS extends register_base;
      field_base FPGA_VOLTAGE_F;

      function new(
        input string name,
        input int address);

        super.new(name, address);
        this.FPGA_VOLTAGE_F = new("FPGA_VOLTAGE", 15, 0, RO, 'h0, this);
      endfunction: new
    endclass

    RSTN_CLASS RSTN_R;
    CLK_SEL_CLASS CLK_SEL_R;
    MMCM_STATUS_CLASS MMCM_STATUS_R;
    DRP_CNTRL_CLASS DRP_CNTRL_R;
    DRP_STATUS_CLASS DRP_STATUS_R;
    FPGA_VOLTAGE_CLASS FPGA_VOLTAGE_R;

    function new();
      this.RSTN_R = new("RSTN", 'h40);
      this.CLK_SEL_R = new("CLK_SEL", 'h44);
      this.MMCM_STATUS_R = new("MMCM_STATUS", 'h5c);
      this.DRP_CNTRL_R = new("DRP_CNTRL", 'h70);
      this.DRP_STATUS_R = new("DRP_STATUS", 'h74);
      this.FPGA_VOLTAGE_R = new("FPGA_VOLTAGE", 'h140);
    endfunction: new;

  endclass;
endpackage
