// ***************************************************************************
// ***************************************************************************
// Copyright (C) 2014-2024 Analog Devices, Inc. All rights reserved.
//
// In this HDL repository, there are many different and unique modules, consisting
// of various HDL (Verilog or VHDL) components. The individual modules are
// developed independently, and may be accompanied by separate and unique license
// terms.
//
// The user should read each of these license terms, and understand the
// freedoms and responsibilities that he or she has by using this source/core.
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
/* Feb 07 14:25:05 2025 v0.4.1 */

package adi_regmap_fan_control_pkg;
  import logger_pkg::*;
  import adi_api_pkg::*;

  class adi_regmap_fan_control extends adi_regmap;

    /* Fan Controller (axi_fan_control) */
    class VERSION_CLASS extends register_base;
      field_base VERSION_MAJOR_F;
      field_base VERSION_MINOR_F;
      field_base VERSION_PATCH_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.VERSION_MAJOR_F = new("VERSION_MAJOR", 31, 16, RO, 'h1, this);
        this.VERSION_MINOR_F = new("VERSION_MINOR", 15, 8, RO, 'h0, this);
        this.VERSION_PATCH_F = new("VERSION_PATCH", 7, 0, RO, 'h61, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: VERSION_CLASS

    class PERIPHERAL_ID_CLASS extends register_base;
      field_base PERIPHERAL_ID_F;

      function new(
        input string name,
        input int address,
        input int ID,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.PERIPHERAL_ID_F = new("PERIPHERAL_ID", 31, 0, RO, ID, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: PERIPHERAL_ID_CLASS

    class SCRATCH_CLASS extends register_base;
      field_base SCRATCH_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.SCRATCH_F = new("SCRATCH", 31, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: SCRATCH_CLASS

    class IDENTIFICATION_CLASS extends register_base;
      field_base IDENTIFICATION_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.IDENTIFICATION_F = new("IDENTIFICATION", 31, 0, RO, 'h46414e43, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: IDENTIFICATION_CLASS

    class IRQ_MASK_CLASS extends register_base;
      field_base NEW_TACHO_MEASUREMENT_F;
      field_base TEMP_INCREASE_F;
      field_base TACHO_ERR_F;
      field_base PWM_CHANGED_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.NEW_TACHO_MEASUREMENT_F = new("NEW_TACHO_MEASUREMENT", 3, 3, RW, 'h1, this);
        this.TEMP_INCREASE_F = new("TEMP_INCREASE", 2, 2, RW, 'h1, this);
        this.TACHO_ERR_F = new("TACHO_ERR", 1, 1, RW, 'h1, this);
        this.PWM_CHANGED_F = new("PWM_CHANGED", 0, 0, RW, 'h1, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: IRQ_MASK_CLASS

    class IRQ_PENDING_CLASS extends register_base;
      field_base NEW_TACHO_MEASUREMENT_F;
      field_base TEMP_INCREASE_F;
      field_base TACHO_ERR_F;
      field_base PWM_CHANGED_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.NEW_TACHO_MEASUREMENT_F = new("NEW_TACHO_MEASUREMENT", 3, 3, RW1C, 'h0, this);
        this.TEMP_INCREASE_F = new("TEMP_INCREASE", 2, 2, RW1C, 'h0, this);
        this.TACHO_ERR_F = new("TACHO_ERR", 1, 1, RW1C, 'h0, this);
        this.PWM_CHANGED_F = new("PWM_CHANGED", 0, 0, RW1C, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: IRQ_PENDING_CLASS

    class IRQ_SOURCE_CLASS extends register_base;
      field_base NEW_TACHO_MEASUREMENT_F;
      field_base TEMP_INCREASE_F;
      field_base TACHO_ERR_F;
      field_base PWM_CHANGED_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.NEW_TACHO_MEASUREMENT_F = new("NEW_TACHO_MEASUREMENT", 3, 3, RO, 'h0, this);
        this.TEMP_INCREASE_F = new("TEMP_INCREASE", 2, 2, RO, 'h0, this);
        this.TACHO_ERR_F = new("TACHO_ERR", 1, 1, RO, 'h0, this);
        this.PWM_CHANGED_F = new("PWM_CHANGED", 0, 0, RO, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: IRQ_SOURCE_CLASS

    class RSTN_CLASS extends register_base;
      field_base RSTN_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.RSTN_F = new("RSTN", 0, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: RSTN_CLASS

    class PWM_WIDTH_CLASS extends register_base;
      field_base PWM_WIDTH_F;

      function new(
        input string name,
        input int address,
        input int PWM_PERIOD,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.PWM_WIDTH_F = new("PWM_WIDTH", 31, 0, RW, PWM_PERIOD, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: PWM_WIDTH_CLASS

    class TACHO_PERIOD_CLASS extends register_base;
      field_base TACHO_PERIOD_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.TACHO_PERIOD_F = new("TACHO_PERIOD", 31, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: TACHO_PERIOD_CLASS

    class TACHO_TOLERANCE_CLASS extends register_base;
      field_base TACHO_TOLERANCE_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.TACHO_TOLERANCE_F = new("TACHO_TOLERANCE", 31, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: TACHO_TOLERANCE_CLASS

    class TEMP_DATA_SOURCE_CLASS extends register_base;
      field_base TEMP_DATA_SOURCE_F;

      function new(
        input string name,
        input int address,
        input int INTERNAL_SYSMONE,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.TEMP_DATA_SOURCE_F = new("TEMP_DATA_SOURCE", 31, 0, RO, INTERNAL_SYSMONE, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: TEMP_DATA_SOURCE_CLASS

    class PWM_PERIOD_CLASS extends register_base;
      field_base PWM_PERIOD_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.PWM_PERIOD_F = new("PWM_PERIOD", 31, 0, RO, 'h4e20, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: PWM_PERIOD_CLASS

    class TACHO_MEASUREMENT_CLASS extends register_base;
      field_base TACHO_MEASUREMENT_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.TACHO_MEASUREMENT_F = new("TACHO_MEASUREMENT", 31, 0, RO, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: TACHO_MEASUREMENT_CLASS

    class TEMPERATURE_CLASS extends register_base;
      field_base TEMPERATURE_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.TEMPERATURE_F = new("TEMPERATURE", 31, 0, RO, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: TEMPERATURE_CLASS

    class TEMP_00_H_CLASS extends register_base;
      field_base TEMP_00_H_F;

      function new(
        input string name,
        input int address,
        input int TEMP_00_H,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.TEMP_00_H_F = new("TEMP_00_H", 31, 0, RW, TEMP_00_H, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: TEMP_00_H_CLASS

    class TEMP_25_L_CLASS extends register_base;
      field_base TEMP_25_L_F;

      function new(
        input string name,
        input int address,
        input int TEMP_25_L,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.TEMP_25_L_F = new("TEMP_25_L", 31, 0, RW, TEMP_25_L, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: TEMP_25_L_CLASS

    class TEMP_25_H_CLASS extends register_base;
      field_base TEMP_25_H_F;

      function new(
        input string name,
        input int address,
        input int TEMP_25_H,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.TEMP_25_H_F = new("TEMP_25_H", 31, 0, RW, TEMP_25_H, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: TEMP_25_H_CLASS

    class TEMP_50_L_CLASS extends register_base;
      field_base TEMP_50_L_F;

      function new(
        input string name,
        input int address,
        input int TEMP_50_L,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.TEMP_50_L_F = new("TEMP_50_L", 31, 0, RW, TEMP_50_L, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: TEMP_50_L_CLASS

    class TEMP_50_H_CLASS extends register_base;
      field_base TEMP_50_H_F;

      function new(
        input string name,
        input int address,
        input int TEMP_50_H,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.TEMP_50_H_F = new("TEMP_50_H", 31, 0, RW, TEMP_50_H, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: TEMP_50_H_CLASS

    class TEMP_75_L_CLASS extends register_base;
      field_base TEMP_75_L_F;

      function new(
        input string name,
        input int address,
        input int TEMP_75_L,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.TEMP_75_L_F = new("TEMP_75_L", 31, 0, RW, TEMP_75_L, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: TEMP_75_L_CLASS

    class TEMP_75_H_CLASS extends register_base;
      field_base TEMP_75_H_F;

      function new(
        input string name,
        input int address,
        input int TEMP_75_H,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.TEMP_75_H_F = new("TEMP_75_H", 31, 0, RW, TEMP_75_H, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: TEMP_75_H_CLASS

    class TEMP_100_L_CLASS extends register_base;
      field_base TEMP_100_L_F;

      function new(
        input string name,
        input int address,
        input int TEMP_100_L,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.TEMP_100_L_F = new("TEMP_100_L", 31, 0, RW, TEMP_100_L, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: TEMP_100_L_CLASS

    class TACHO_25_CLASS extends register_base;
      field_base TACHO_25_F;

      function new(
        input string name,
        input int address,
        input int TACHO_T25,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.TACHO_25_F = new("TACHO_25", 31, 0, RW, TACHO_T25, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: TACHO_25_CLASS

    class TACHO_50_CLASS extends register_base;
      field_base TACHO_50_F;

      function new(
        input string name,
        input int address,
        input int TACHO_T50,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.TACHO_50_F = new("TACHO_50", 31, 0, RW, TACHO_T50, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: TACHO_50_CLASS

    class TACHO_75_CLASS extends register_base;
      field_base TACHO_75_F;

      function new(
        input string name,
        input int address,
        input int TACHO_T75,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.TACHO_75_F = new("TACHO_75", 31, 0, RW, TACHO_T75, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: TACHO_75_CLASS

    class TACHO_100_CLASS extends register_base;
      field_base TACHO_100_F;

      function new(
        input string name,
        input int address,
        input int TACHO_T100,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.TACHO_100_F = new("TACHO_100", 31, 0, RW, TACHO_T100, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: TACHO_100_CLASS

    class TACHO_25_TOL_CLASS extends register_base;
      field_base TACHO_25_TOL_F;

      function new(
        input string name,
        input int address,
        input int TACHO_T25,
        input int TACHO_TOL_PERCENT,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.TACHO_25_TOL_F = new("TACHO_25_TOL", 31, 0, RW, TACHO_T25*TACHO_TOL_PERCENT/100, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: TACHO_25_TOL_CLASS

    class TACHO_50_TOL_CLASS extends register_base;
      field_base TACHO_50_TOL_F;

      function new(
        input string name,
        input int address,
        input int TACHO_T50,
        input int TACHO_TOL_PERCENT,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.TACHO_50_TOL_F = new("TACHO_50_TOL", 31, 0, RW, TACHO_T50*TACHO_TOL_PERCENT/100, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: TACHO_50_TOL_CLASS

    class TACHO_75_TOL_CLASS extends register_base;
      field_base TACHO_75_TOL_F;

      function new(
        input string name,
        input int address,
        input int TACHO_T75,
        input int TACHO_TOL_PERCENT,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.TACHO_75_TOL_F = new("TACHO_75_TOL", 31, 0, RW, TACHO_T75*TACHO_TOL_PERCENT/100, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: TACHO_75_TOL_CLASS

    class TACHO_100_TOL_CLASS extends register_base;
      field_base TACHO_100_TOL_F;

      function new(
        input string name,
        input int address,
        input int TACHO_T100,
        input int TACHO_TOL_PERCENT,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.TACHO_100_TOL_F = new("TACHO_100_TOL", 31, 0, RW, TACHO_T100*TACHO_TOL_PERCENT/100, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: TACHO_100_TOL_CLASS

    VERSION_CLASS VERSION_R;
    PERIPHERAL_ID_CLASS PERIPHERAL_ID_R;
    SCRATCH_CLASS SCRATCH_R;
    IDENTIFICATION_CLASS IDENTIFICATION_R;
    IRQ_MASK_CLASS IRQ_MASK_R;
    IRQ_PENDING_CLASS IRQ_PENDING_R;
    IRQ_SOURCE_CLASS IRQ_SOURCE_R;
    RSTN_CLASS RSTN_R;
    PWM_WIDTH_CLASS PWM_WIDTH_R;
    TACHO_PERIOD_CLASS TACHO_PERIOD_R;
    TACHO_TOLERANCE_CLASS TACHO_TOLERANCE_R;
    TEMP_DATA_SOURCE_CLASS TEMP_DATA_SOURCE_R;
    PWM_PERIOD_CLASS PWM_PERIOD_R;
    TACHO_MEASUREMENT_CLASS TACHO_MEASUREMENT_R;
    TEMPERATURE_CLASS TEMPERATURE_R;
    TEMP_00_H_CLASS TEMP_00_H_R;
    TEMP_25_L_CLASS TEMP_25_L_R;
    TEMP_25_H_CLASS TEMP_25_H_R;
    TEMP_50_L_CLASS TEMP_50_L_R;
    TEMP_50_H_CLASS TEMP_50_H_R;
    TEMP_75_L_CLASS TEMP_75_L_R;
    TEMP_75_H_CLASS TEMP_75_H_R;
    TEMP_100_L_CLASS TEMP_100_L_R;
    TACHO_25_CLASS TACHO_25_R;
    TACHO_50_CLASS TACHO_50_R;
    TACHO_75_CLASS TACHO_75_R;
    TACHO_100_CLASS TACHO_100_R;
    TACHO_25_TOL_CLASS TACHO_25_TOL_R;
    TACHO_50_TOL_CLASS TACHO_50_TOL_R;
    TACHO_75_TOL_CLASS TACHO_75_TOL_R;
    TACHO_100_TOL_CLASS TACHO_100_TOL_R;

    function new(
      input string name,
      input int address,
      input int ID,
      input int INTERNAL_SYSMONE,
      input int PWM_PERIOD,
      input int TACHO_T100,
      input int TACHO_T25,
      input int TACHO_T50,
      input int TACHO_T75,
      input int TACHO_TOL_PERCENT,
      input int TEMP_00_H,
      input int TEMP_100_L,
      input int TEMP_25_H,
      input int TEMP_25_L,
      input int TEMP_50_H,
      input int TEMP_50_L,
      input int TEMP_75_H,
      input int TEMP_75_L,
      input adi_api parent = null);

      super.new(name, address, parent);

      this.VERSION_R = new("VERSION", 'h0, this);
      this.PERIPHERAL_ID_R = new("PERIPHERAL_ID", 'h4, ID, this);
      this.SCRATCH_R = new("SCRATCH", 'h8, this);
      this.IDENTIFICATION_R = new("IDENTIFICATION", 'hc, this);
      this.IRQ_MASK_R = new("IRQ_MASK", 'h40, this);
      this.IRQ_PENDING_R = new("IRQ_PENDING", 'h44, this);
      this.IRQ_SOURCE_R = new("IRQ_SOURCE", 'h48, this);
      this.RSTN_R = new("RSTN", 'h80, this);
      this.PWM_WIDTH_R = new("PWM_WIDTH", 'h84, PWM_PERIOD, this);
      this.TACHO_PERIOD_R = new("TACHO_PERIOD", 'h88, this);
      this.TACHO_TOLERANCE_R = new("TACHO_TOLERANCE", 'h8c, this);
      this.TEMP_DATA_SOURCE_R = new("TEMP_DATA_SOURCE", 'h90, INTERNAL_SYSMONE, this);
      this.PWM_PERIOD_R = new("PWM_PERIOD", 'hc0, this);
      this.TACHO_MEASUREMENT_R = new("TACHO_MEASUREMENT", 'hc4, this);
      this.TEMPERATURE_R = new("TEMPERATURE", 'hc8, this);
      this.TEMP_00_H_R = new("TEMP_00_H", 'h100, TEMP_00_H, this);
      this.TEMP_25_L_R = new("TEMP_25_L", 'h104, TEMP_25_L, this);
      this.TEMP_25_H_R = new("TEMP_25_H", 'h108, TEMP_25_H, this);
      this.TEMP_50_L_R = new("TEMP_50_L", 'h10c, TEMP_50_L, this);
      this.TEMP_50_H_R = new("TEMP_50_H", 'h110, TEMP_50_H, this);
      this.TEMP_75_L_R = new("TEMP_75_L", 'h114, TEMP_75_L, this);
      this.TEMP_75_H_R = new("TEMP_75_H", 'h118, TEMP_75_H, this);
      this.TEMP_100_L_R = new("TEMP_100_L", 'h11c, TEMP_100_L, this);
      this.TACHO_25_R = new("TACHO_25", 'h140, TACHO_T25, this);
      this.TACHO_50_R = new("TACHO_50", 'h144, TACHO_T50, this);
      this.TACHO_75_R = new("TACHO_75", 'h148, TACHO_T75, this);
      this.TACHO_100_R = new("TACHO_100", 'h14c, TACHO_T100, this);
      this.TACHO_25_TOL_R = new("TACHO_25_TOL", 'h150, TACHO_T25, TACHO_TOL_PERCENT, this);
      this.TACHO_50_TOL_R = new("TACHO_50_TOL", 'h154, TACHO_T50, TACHO_TOL_PERCENT, this);
      this.TACHO_75_TOL_R = new("TACHO_75_TOL", 'h158, TACHO_T75, TACHO_TOL_PERCENT, this);
      this.TACHO_100_TOL_R = new("TACHO_100_TOL", 'h15c, TACHO_T100, TACHO_TOL_PERCENT, this);

      this.info($sformatf("Initialized"), ADI_VERBOSITY_HIGH);
    endfunction: new

  endclass: adi_regmap_fan_control

endpackage: adi_regmap_fan_control_pkg
