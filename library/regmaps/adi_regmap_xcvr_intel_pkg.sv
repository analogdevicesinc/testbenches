// ***************************************************************************
// ***************************************************************************
// Copyright 2014 - 2024 (c) Analog Devices, Inc. All rights reserved.
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

package adi_regmap_xcvr_intel_pkg;
  import regmap_pkg::*;

  class adi_regmap_xcvr_intel #(int NUM_OF_LANES);

    /* Intel XCVR (axi_xcvr) */
    class VERSION_CLASS extends register_base;
      field_base VERSION_F;

      function new(
        input string name,
        input int address);

        super.new(name, address);
        this.VERSION_F = new("VERSION", 31, 0, RO, 'hXXXXXXXX, this);
      endfunction: new
    endclass

    class ID_CLASS extends register_base;
      field_base ID_F;

      function new(
        input string name,
        input int address);

        super.new(name, address);
        this.ID_F = new("ID", 31, 0, RO, 'hXXXXXXXX, this);
      endfunction: new
    endclass

    class SCRATCH_CLASS extends register_base;
      field_base SCRATCH_F;

      function new(
        input string name,
        input int address);

        super.new(name, address);
        this.SCRATCH_F = new("SCRATCH", 31, 0, RW, 'hXXXXXXXX, this);
      endfunction: new
    endclass

    class RESETN_CLASS extends register_base;
      field_base RESETN_F;

      function new(
        input string name,
        input int address);

        super.new(name, address);
        this.RESETN_F = new("RESETN", 0, 0, RW, 'hXXXXXXXX, this);
      endfunction: new
    endclass

    class STATUS_CLASS extends register_base;
      field_base STATUS_F;

      function new(
        input string name,
        input int address);

        super.new(name, address);
        this.STATUS_F = new("STATUS", 0, 0, RO, 'hXXXXXXXX, this);
      endfunction: new
    endclass

    class STATUS_32_CLASS #(int NUM_OF_LANES) extends register_base;
      field_base UP_PLL_LOCKED_F;
      field_base CHANNEL_N_READY_F;

      function new(
        input string name,
        input int address);

        super.new(name, address);
        this.UP_PLL_LOCKED_F = new("UP_PLL_LOCKED", NUM_OF_LANES, NUM_OF_LANES, RO, 'hXXXXXXXX, this);
        this.CHANNEL_N_READY_F = new("CHANNEL_N_READY", NUM_OF_LANES-1, 0, RO, 'hXXXXXXXX, this);
      endfunction: new
    endclass

    class FPGA_INFO_CLASS extends register_base;
      field_base FPGA_TECHNOLOGY_F;
      field_base FPGA_FAMILY_F;
      field_base SPEED_GRADE_F;
      field_base DEV_PACKAGE_F;

      function new(
        input string name,
        input int address);

        super.new(name, address);
        this.FPGA_TECHNOLOGY_F = new("FPGA_TECHNOLOGY", 31, 24, RO, 'hXXXXXXXX, this);
        this.FPGA_FAMILY_F = new("FPGA_FAMILY", 23, 16, RO, 'hXXXXXXXX, this);
        this.SPEED_GRADE_F = new("SPEED_GRADE", 15, 8, RO, 'hXXXXXXXX, this);
        this.DEV_PACKAGE_F = new("DEV_PACKAGE", 7, 0, RO, 'hXXXXXXXX, this);
      endfunction: new
    endclass

    class GENERIC_INFO_CLASS extends register_base;
      field_base XCVR_TYPE_F;
      field_base TX_OR_RX_N_F;
      field_base NUM_OF_LANES_F;

      function new(
        input string name,
        input int address);

        super.new(name, address);
        this.XCVR_TYPE_F = new("XCVR_TYPE", 27, 24, RO, 'hXXXXXXXX, this);
        this.TX_OR_RX_N_F = new("TX_OR_RX_N", 8, 8, RO, 'hXXXXXXXX, this);
        this.NUM_OF_LANES_F = new("NUM_OF_LANES", 7, 0, RO, 'hXXXXXXXX, this);
      endfunction: new
    endclass

    class FPGA_VOLTAGE_CLASS extends register_base;
      field_base FPGA_VOLTAGE_F;

      function new(
        input string name,
        input int address);

        super.new(name, address);
        this.FPGA_VOLTAGE_F = new("FPGA_VOLTAGE", 15, 0, RO, 'hXXXXXXXX, this);
      endfunction: new
    endclass

    VERSION_CLASS VERSION_R;
    ID_CLASS ID_R;
    SCRATCH_CLASS SCRATCH_R;
    RESETN_CLASS RESETN_R;
    STATUS_CLASS STATUS_R;
    STATUS_32_CLASS #(NUM_OF_LANES) STATUS_32_R;
    FPGA_INFO_CLASS FPGA_INFO_R;
    GENERIC_INFO_CLASS GENERIC_INFO_R;
    FPGA_VOLTAGE_CLASS FPGA_VOLTAGE_R;

    function new();
      this.VERSION_R = new("VERSION", 'h0);
      this.ID_R = new("ID", 'h4);
      this.SCRATCH_R = new("SCRATCH", 'h8);
      this.RESETN_R = new("RESETN", 'h10);
      this.STATUS_R = new("STATUS", 'h14);
      this.STATUS_32_R = new("STATUS_32", 'h18);
      this.FPGA_INFO_R = new("FPGA_INFO", 'h1c);
      this.GENERIC_INFO_R = new("GENERIC_INFO", 'h24);
      this.FPGA_VOLTAGE_R = new("FPGA_VOLTAGE", 'h140);
    endfunction: new;

  endclass;
endpackage
