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

package adi_regmap_fan_control_pkg;
  import regmap_pkg::*;

  class adi_regmap_fan_control #(int ID, int INTERNAL_SYSMONE, int PWM_PERIOD, int TACHO_T100, int TACHO_T25, int TACHO_T50, int TACHO_T75, int TACHO_TOL_PERCENT, int TEMP_00_H, int TEMP_100_L, int TEMP_25_H, int TEMP_25_L, int TEMP_50_H, int TEMP_50_L, int TEMP_75_H, int TEMP_75_L);

    /* Fan Controller (axi_fan_control) */
    class VERSION_CLASS extends register_base;
      field_base VERSION_MAJOR_F;
      field_base VERSION_MINOR_F;
      field_base VERSION_PATCH_F;

      function new(
        input string name,
        input int address);

        super.new(name, address);
        this.VERSION_MAJOR_F = new("VERSION_MAJOR", 31, 16, RO, 'h1, this);
        this.VERSION_MINOR_F = new("VERSION_MINOR", 15, 8, RO, 'h0, this);
        this.VERSION_PATCH_F = new("VERSION_PATCH", 7, 0, RO, 'h61, this);
      endfunction: new
    endclass

    class PERIPHERAL_ID_CLASS #(int ID) extends register_base;
      field_base PERIPHERAL_ID_F;

      function new(
        input string name,
        input int address);

        super.new(name, address);
        this.PERIPHERAL_ID_F = new("PERIPHERAL_ID", 31, 0, RO, ID, this);
      endfunction: new
    endclass

    class SCRATCH_CLASS extends register_base;
      field_base SCRATCH_F;

      function new(
        input string name,
        input int address);

        super.new(name, address);
        this.SCRATCH_F = new("SCRATCH", 31, 0, RW, 'h0, this);
      endfunction: new
    endclass

    class IDENTIFICATION_CLASS extends register_base;
      field_base IDENTIFICATION_F;

      function new(
        input string name,
        input int address);

        super.new(name, address);
        this.IDENTIFICATION_F = new("IDENTIFICATION", 31, 0, RO, 'h46414e43, this);
      endfunction: new
    endclass

    class IRQ_MASK_CLASS extends register_base;
      field_base NEW_TACHO_MEASUREMENT_F;
      field_base TEMP_INCREASE_F;
      field_base TACHO_ERR_F;
      field_base PWM_CHANGED_F;

      function new(
        input string name,
        input int address);

        super.new(name, address);
        this.NEW_TACHO_MEASUREMENT_F = new("NEW_TACHO_MEASUREMENT", 3, 3, RW, 'h1, this);
        this.TEMP_INCREASE_F = new("TEMP_INCREASE", 2, 2, RW, 'h1, this);
        this.TACHO_ERR_F = new("TACHO_ERR", 1, 1, RW, 'h1, this);
        this.PWM_CHANGED_F = new("PWM_CHANGED", 0, 0, RW, 'h1, this);
      endfunction: new
    endclass

    class IRQ_PENDING_CLASS extends register_base;
      field_base NEW_TACHO_MEASUREMENT_F;
      field_base TEMP_INCREASE_F;
      field_base TACHO_ERR_F;
      field_base PWM_CHANGED_F;

      function new(
        input string name,
        input int address);

        super.new(name, address);
        this.NEW_TACHO_MEASUREMENT_F = new("NEW_TACHO_MEASUREMENT", 3, 3, RW1C, 'h0, this);
        this.TEMP_INCREASE_F = new("TEMP_INCREASE", 2, 2, RW1C, 'h0, this);
        this.TACHO_ERR_F = new("TACHO_ERR", 1, 1, RW1C, 'h0, this);
        this.PWM_CHANGED_F = new("PWM_CHANGED", 0, 0, RW1C, 'h0, this);
      endfunction: new
    endclass

    class IRQ_SOURCE_CLASS extends register_base;
      field_base NEW_TACHO_MEASUREMENT_F;
      field_base TEMP_INCREASE_F;
      field_base TACHO_ERR_F;
      field_base PWM_CHANGED_F;

      function new(
        input string name,
        input int address);

        super.new(name, address);
        this.NEW_TACHO_MEASUREMENT_F = new("NEW_TACHO_MEASUREMENT", 3, 3, RO, 'h0, this);
        this.TEMP_INCREASE_F = new("TEMP_INCREASE", 2, 2, RO, 'h0, this);
        this.TACHO_ERR_F = new("TACHO_ERR", 1, 1, RO, 'h0, this);
        this.PWM_CHANGED_F = new("PWM_CHANGED", 0, 0, RO, 'h0, this);
      endfunction: new
    endclass

    class RSTN_CLASS extends register_base;
      field_base RSTN_F;

      function new(
        input string name,
        input int address);

        super.new(name, address);
        this.RSTN_F = new("RSTN", 0, 0, RW, 'h0, this);
      endfunction: new
    endclass

    class PWM_WIDTH_CLASS #(int PWM_PERIOD) extends register_base;
      field_base PWM_WIDTH_F;

      function new(
        input string name,
        input int address);

        super.new(name, address);
        this.PWM_WIDTH_F = new("PWM_WIDTH", 31, 0, RW, PWM_PERIOD, this);
      endfunction: new
    endclass

    class TACHO_PERIOD_CLASS extends register_base;
      field_base TACHO_PERIOD_F;

      function new(
        input string name,
        input int address);

        super.new(name, address);
        this.TACHO_PERIOD_F = new("TACHO_PERIOD", 31, 0, RW, 'h0, this);
      endfunction: new
    endclass

    class TACHO_TOLERANCE_CLASS extends register_base;
      field_base TACHO_TOLERANCE_F;

      function new(
        input string name,
        input int address);

        super.new(name, address);
        this.TACHO_TOLERANCE_F = new("TACHO_TOLERANCE", 31, 0, RW, 'h0, this);
      endfunction: new
    endclass

    class TEMP_DATA_SOURCE_CLASS #(int INTERNAL_SYSMONE) extends register_base;
      field_base TEMP_DATA_SOURCE_F;

      function new(
        input string name,
        input int address);

        super.new(name, address);
        this.TEMP_DATA_SOURCE_F = new("TEMP_DATA_SOURCE", 31, 0, RO, INTERNAL_SYSMONE, this);
      endfunction: new
    endclass

    class PWM_PERIOD_CLASS extends register_base;
      field_base PWM_PERIOD_F;

      function new(
        input string name,
        input int address);

        super.new(name, address);
        this.PWM_PERIOD_F = new("PWM_PERIOD", 31, 0, RO, 'h4e20, this);
      endfunction: new
    endclass

    class TACHO_MEASUREMENT_CLASS extends register_base;
      field_base TACHO_MEASUREMENT_F;

      function new(
        input string name,
        input int address);

        super.new(name, address);
        this.TACHO_MEASUREMENT_F = new("TACHO_MEASUREMENT", 31, 0, RO, 'h0, this);
      endfunction: new
    endclass

    class TEMPERATURE_CLASS extends register_base;
      field_base TEMPERATURE_F;

      function new(
        input string name,
        input int address);

        super.new(name, address);
        this.TEMPERATURE_F = new("TEMPERATURE", 31, 0, RO, 'h0, this);
      endfunction: new
    endclass

    class TEMP_00_H_CLASS #(int TEMP_00_H) extends register_base;
      field_base TEMP_00_H_F;

      function new(
        input string name,
        input int address);

        super.new(name, address);
        this.TEMP_00_H_F = new("TEMP_00_H", 31, 0, RW, TEMP_00_H, this);
      endfunction: new
    endclass

    class TEMP_25_L_CLASS #(int TEMP_25_L) extends register_base;
      field_base TEMP_25_L_F;

      function new(
        input string name,
        input int address);

        super.new(name, address);
        this.TEMP_25_L_F = new("TEMP_25_L", 31, 0, RW, TEMP_25_L, this);
      endfunction: new
    endclass

    class TEMP_25_H_CLASS #(int TEMP_25_H) extends register_base;
      field_base TEMP_25_H_F;

      function new(
        input string name,
        input int address);

        super.new(name, address);
        this.TEMP_25_H_F = new("TEMP_25_H", 31, 0, RW, TEMP_25_H, this);
      endfunction: new
    endclass

    class TEMP_50_L_CLASS #(int TEMP_50_L) extends register_base;
      field_base TEMP_50_L_F;

      function new(
        input string name,
        input int address);

        super.new(name, address);
        this.TEMP_50_L_F = new("TEMP_50_L", 31, 0, RW, TEMP_50_L, this);
      endfunction: new
    endclass

    class TEMP_50_H_CLASS #(int TEMP_50_H) extends register_base;
      field_base TEMP_50_H_F;

      function new(
        input string name,
        input int address);

        super.new(name, address);
        this.TEMP_50_H_F = new("TEMP_50_H", 31, 0, RW, TEMP_50_H, this);
      endfunction: new
    endclass

    class TEMP_75_L_CLASS #(int TEMP_75_L) extends register_base;
      field_base TEMP_75_L_F;

      function new(
        input string name,
        input int address);

        super.new(name, address);
        this.TEMP_75_L_F = new("TEMP_75_L", 31, 0, RW, TEMP_75_L, this);
      endfunction: new
    endclass

    class TEMP_75_H_CLASS #(int TEMP_75_H) extends register_base;
      field_base TEMP_75_H_F;

      function new(
        input string name,
        input int address);

        super.new(name, address);
        this.TEMP_75_H_F = new("TEMP_75_H", 31, 0, RW, TEMP_75_H, this);
      endfunction: new
    endclass

    class TEMP_100_L_CLASS #(int TEMP_100_L) extends register_base;
      field_base TEMP_100_L_F;

      function new(
        input string name,
        input int address);

        super.new(name, address);
        this.TEMP_100_L_F = new("TEMP_100_L", 31, 0, RW, TEMP_100_L, this);
      endfunction: new
    endclass

    class TACHO_25_CLASS #(int TACHO_T25) extends register_base;
      field_base TACHO_25_F;

      function new(
        input string name,
        input int address);

        super.new(name, address);
        this.TACHO_25_F = new("TACHO_25", 31, 0, RW, TACHO_T25, this);
      endfunction: new
    endclass

    class TACHO_50_CLASS #(int TACHO_T50) extends register_base;
      field_base TACHO_50_F;

      function new(
        input string name,
        input int address);

        super.new(name, address);
        this.TACHO_50_F = new("TACHO_50", 31, 0, RW, TACHO_T50, this);
      endfunction: new
    endclass

    class TACHO_75_CLASS #(int TACHO_T75) extends register_base;
      field_base TACHO_75_F;

      function new(
        input string name,
        input int address);

        super.new(name, address);
        this.TACHO_75_F = new("TACHO_75", 31, 0, RW, TACHO_T75, this);
      endfunction: new
    endclass

    class TACHO_100_CLASS #(int TACHO_T100) extends register_base;
      field_base TACHO_100_F;

      function new(
        input string name,
        input int address);

        super.new(name, address);
        this.TACHO_100_F = new("TACHO_100", 31, 0, RW, TACHO_T100, this);
      endfunction: new
    endclass

    class TACHO_25_TOL_CLASS #(int TACHO_T25, int TACHO_TOL_PERCENT) extends register_base;
      field_base TACHO_25_TOL_F;

      function new(
        input string name,
        input int address);

        super.new(name, address);
        this.TACHO_25_TOL_F = new("TACHO_25_TOL", 31, 0, RW, TACHO_T25*TACHO_TOL_PERCENT/100, this);
      endfunction: new
    endclass

    class TACHO_50_TOL_CLASS #(int TACHO_T50, int TACHO_TOL_PERCENT) extends register_base;
      field_base TACHO_50_TOL_F;

      function new(
        input string name,
        input int address);

        super.new(name, address);
        this.TACHO_50_TOL_F = new("TACHO_50_TOL", 31, 0, RW, TACHO_T50*TACHO_TOL_PERCENT/100, this);
      endfunction: new
    endclass

    class TACHO_75_TOL_CLASS #(int TACHO_T75, int TACHO_TOL_PERCENT) extends register_base;
      field_base TACHO_75_TOL_F;

      function new(
        input string name,
        input int address);

        super.new(name, address);
        this.TACHO_75_TOL_F = new("TACHO_75_TOL", 31, 0, RW, TACHO_T75*TACHO_TOL_PERCENT/100, this);
      endfunction: new
    endclass

    class TACHO_100_TOL_CLASS #(int TACHO_T100, int TACHO_TOL_PERCENT) extends register_base;
      field_base TACHO_100_TOL_F;

      function new(
        input string name,
        input int address);

        super.new(name, address);
        this.TACHO_100_TOL_F = new("TACHO_100_TOL", 31, 0, RW, TACHO_T100*TACHO_TOL_PERCENT/100, this);
      endfunction: new
    endclass

    VERSION_CLASS VERSION_R;
    PERIPHERAL_ID_CLASS #(ID) PERIPHERAL_ID_R;
    SCRATCH_CLASS SCRATCH_R;
    IDENTIFICATION_CLASS IDENTIFICATION_R;
    IRQ_MASK_CLASS IRQ_MASK_R;
    IRQ_PENDING_CLASS IRQ_PENDING_R;
    IRQ_SOURCE_CLASS IRQ_SOURCE_R;
    RSTN_CLASS RSTN_R;
    PWM_WIDTH_CLASS #(PWM_PERIOD) PWM_WIDTH_R;
    TACHO_PERIOD_CLASS TACHO_PERIOD_R;
    TACHO_TOLERANCE_CLASS TACHO_TOLERANCE_R;
    TEMP_DATA_SOURCE_CLASS #(INTERNAL_SYSMONE) TEMP_DATA_SOURCE_R;
    PWM_PERIOD_CLASS PWM_PERIOD_R;
    TACHO_MEASUREMENT_CLASS TACHO_MEASUREMENT_R;
    TEMPERATURE_CLASS TEMPERATURE_R;
    TEMP_00_H_CLASS #(TEMP_00_H) TEMP_00_H_R;
    TEMP_25_L_CLASS #(TEMP_25_L) TEMP_25_L_R;
    TEMP_25_H_CLASS #(TEMP_25_H) TEMP_25_H_R;
    TEMP_50_L_CLASS #(TEMP_50_L) TEMP_50_L_R;
    TEMP_50_H_CLASS #(TEMP_50_H) TEMP_50_H_R;
    TEMP_75_L_CLASS #(TEMP_75_L) TEMP_75_L_R;
    TEMP_75_H_CLASS #(TEMP_75_H) TEMP_75_H_R;
    TEMP_100_L_CLASS #(TEMP_100_L) TEMP_100_L_R;
    TACHO_25_CLASS #(TACHO_T25) TACHO_25_R;
    TACHO_50_CLASS #(TACHO_T50) TACHO_50_R;
    TACHO_75_CLASS #(TACHO_T75) TACHO_75_R;
    TACHO_100_CLASS #(TACHO_T100) TACHO_100_R;
    TACHO_25_TOL_CLASS #(TACHO_T25, TACHO_TOL_PERCENT) TACHO_25_TOL_R;
    TACHO_50_TOL_CLASS #(TACHO_T50, TACHO_TOL_PERCENT) TACHO_50_TOL_R;
    TACHO_75_TOL_CLASS #(TACHO_T75, TACHO_TOL_PERCENT) TACHO_75_TOL_R;
    TACHO_100_TOL_CLASS #(TACHO_T100, TACHO_TOL_PERCENT) TACHO_100_TOL_R;

    function new();
      this.VERSION_R = new("VERSION", 'h0);
      this.PERIPHERAL_ID_R = new("PERIPHERAL_ID", 'h4);
      this.SCRATCH_R = new("SCRATCH", 'h8);
      this.IDENTIFICATION_R = new("IDENTIFICATION", 'hc);
      this.IRQ_MASK_R = new("IRQ_MASK", 'h40);
      this.IRQ_PENDING_R = new("IRQ_PENDING", 'h44);
      this.IRQ_SOURCE_R = new("IRQ_SOURCE", 'h48);
      this.RSTN_R = new("RSTN", 'h80);
      this.PWM_WIDTH_R = new("PWM_WIDTH", 'h84);
      this.TACHO_PERIOD_R = new("TACHO_PERIOD", 'h88);
      this.TACHO_TOLERANCE_R = new("TACHO_TOLERANCE", 'h8c);
      this.TEMP_DATA_SOURCE_R = new("TEMP_DATA_SOURCE", 'h90);
      this.PWM_PERIOD_R = new("PWM_PERIOD", 'hc0);
      this.TACHO_MEASUREMENT_R = new("TACHO_MEASUREMENT", 'hc4);
      this.TEMPERATURE_R = new("TEMPERATURE", 'hc8);
      this.TEMP_00_H_R = new("TEMP_00_H", 'h100);
      this.TEMP_25_L_R = new("TEMP_25_L", 'h104);
      this.TEMP_25_H_R = new("TEMP_25_H", 'h108);
      this.TEMP_50_L_R = new("TEMP_50_L", 'h10c);
      this.TEMP_50_H_R = new("TEMP_50_H", 'h110);
      this.TEMP_75_L_R = new("TEMP_75_L", 'h114);
      this.TEMP_75_H_R = new("TEMP_75_H", 'h118);
      this.TEMP_100_L_R = new("TEMP_100_L", 'h11c);
      this.TACHO_25_R = new("TACHO_25", 'h140);
      this.TACHO_50_R = new("TACHO_50", 'h144);
      this.TACHO_75_R = new("TACHO_75", 'h148);
      this.TACHO_100_R = new("TACHO_100", 'h14c);
      this.TACHO_25_TOL_R = new("TACHO_25_TOL", 'h150);
      this.TACHO_50_TOL_R = new("TACHO_50_TOL", 'h154);
      this.TACHO_75_TOL_R = new("TACHO_75_TOL", 'h158);
      this.TACHO_100_TOL_R = new("TACHO_100_TOL", 'h15c);
    endfunction: new;

  endclass;
endpackage
