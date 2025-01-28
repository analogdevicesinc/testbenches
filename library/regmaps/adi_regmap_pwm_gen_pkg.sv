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
/* Jan 28 13:30:16 2025 v0.3.55 */

package adi_regmap_pwm_gen_pkg;
  import logger_pkg::*;
  import adi_api_pkg::*;

  class adi_regmap_pwm_gen extends adi_regmap;

    /* PWM Generator (axi_pwm_gen) */
    class VERSION_CLASS extends register_base;
      field_base VERSION_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.VERSION_F = new("VERSION", 31, 0, RO, 'h20101, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: VERSION_CLASS

    class ID_CLASS extends register_base;
      field_base ID_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.ID_F = new("ID", 31, 0, RO, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: ID_CLASS

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

    class CORE_MAGIC_CLASS extends register_base;
      field_base CORE_MAGIC_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.CORE_MAGIC_F = new("CORE_MAGIC", 31, 0, RW, 'h504c5347, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: CORE_MAGIC_CLASS

    class RSTN_CLASS extends register_base;
      field_base LOAD_CONFIG_F;
      field_base RESET_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.LOAD_CONFIG_F = new("LOAD_CONFIG", 1, 1, WO, 'h0, this);
        this.RESET_F = new("RESET", 0, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: RSTN_CLASS

    class CONFIG_CLASS extends register_base;
      field_base EXT_SYNC_ALIGN_F;
      field_base FORCE_ALIGN_F;
      field_base START_AT_SYNC_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.EXT_SYNC_ALIGN_F = new("EXT_SYNC_ALIGN", 2, 2, RW, 'h0, this);
        this.FORCE_ALIGN_F = new("FORCE_ALIGN", 1, 1, RW, 'h0, this);
        this.START_AT_SYNC_F = new("START_AT_SYNC", 0, 0, RW, 'h1, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: CONFIG_CLASS

    class NB_PULSES_CLASS extends register_base;
      field_base NB_PULSES_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.NB_PULSES_F = new("NB_PULSES", 31, 0, RO, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: NB_PULSES_CLASS

    class PULSE_n_PERIOD_CLASS extends register_base;
      field_base PULSE_PERIOD_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.PULSE_PERIOD_F = new("PULSE_PERIOD", 31, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: PULSE_n_PERIOD_CLASS

    class PULSE_n_WIDTH_CLASS extends register_base;
      field_base PULSE_WIDTH_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.PULSE_WIDTH_F = new("PULSE_WIDTH", 31, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: PULSE_n_WIDTH_CLASS

    class PULSE_n_OFFSET_CLASS extends register_base;
      field_base PULSE_OFFSET_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.PULSE_OFFSET_F = new("PULSE_OFFSET", 31, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: PULSE_n_OFFSET_CLASS

    VERSION_CLASS VERSION_R;
    ID_CLASS ID_R;
    SCRATCH_CLASS SCRATCH_R;
    CORE_MAGIC_CLASS CORE_MAGIC_R;
    RSTN_CLASS RSTN_R;
    CONFIG_CLASS CONFIG_R;
    NB_PULSES_CLASS NB_PULSES_R;
    PULSE_n_PERIOD_CLASS PULSE_0_PERIOD_R;
    PULSE_n_PERIOD_CLASS PULSE_1_PERIOD_R;
    PULSE_n_PERIOD_CLASS PULSE_2_PERIOD_R;
    PULSE_n_PERIOD_CLASS PULSE_3_PERIOD_R;
    PULSE_n_PERIOD_CLASS PULSE_4_PERIOD_R;
    PULSE_n_PERIOD_CLASS PULSE_5_PERIOD_R;
    PULSE_n_PERIOD_CLASS PULSE_6_PERIOD_R;
    PULSE_n_PERIOD_CLASS PULSE_7_PERIOD_R;
    PULSE_n_PERIOD_CLASS PULSE_8_PERIOD_R;
    PULSE_n_PERIOD_CLASS PULSE_9_PERIOD_R;
    PULSE_n_PERIOD_CLASS PULSE_10_PERIOD_R;
    PULSE_n_PERIOD_CLASS PULSE_11_PERIOD_R;
    PULSE_n_PERIOD_CLASS PULSE_12_PERIOD_R;
    PULSE_n_PERIOD_CLASS PULSE_13_PERIOD_R;
    PULSE_n_PERIOD_CLASS PULSE_14_PERIOD_R;
    PULSE_n_PERIOD_CLASS PULSE_15_PERIOD_R;
    PULSE_n_WIDTH_CLASS PULSE_0_WIDTH_R;
    PULSE_n_WIDTH_CLASS PULSE_1_WIDTH_R;
    PULSE_n_WIDTH_CLASS PULSE_2_WIDTH_R;
    PULSE_n_WIDTH_CLASS PULSE_3_WIDTH_R;
    PULSE_n_WIDTH_CLASS PULSE_4_WIDTH_R;
    PULSE_n_WIDTH_CLASS PULSE_5_WIDTH_R;
    PULSE_n_WIDTH_CLASS PULSE_6_WIDTH_R;
    PULSE_n_WIDTH_CLASS PULSE_7_WIDTH_R;
    PULSE_n_WIDTH_CLASS PULSE_8_WIDTH_R;
    PULSE_n_WIDTH_CLASS PULSE_9_WIDTH_R;
    PULSE_n_WIDTH_CLASS PULSE_10_WIDTH_R;
    PULSE_n_WIDTH_CLASS PULSE_11_WIDTH_R;
    PULSE_n_WIDTH_CLASS PULSE_12_WIDTH_R;
    PULSE_n_WIDTH_CLASS PULSE_13_WIDTH_R;
    PULSE_n_WIDTH_CLASS PULSE_14_WIDTH_R;
    PULSE_n_WIDTH_CLASS PULSE_15_WIDTH_R;
    PULSE_n_OFFSET_CLASS PULSE_0_OFFSET_R;
    PULSE_n_OFFSET_CLASS PULSE_1_OFFSET_R;
    PULSE_n_OFFSET_CLASS PULSE_2_OFFSET_R;
    PULSE_n_OFFSET_CLASS PULSE_3_OFFSET_R;
    PULSE_n_OFFSET_CLASS PULSE_4_OFFSET_R;
    PULSE_n_OFFSET_CLASS PULSE_5_OFFSET_R;
    PULSE_n_OFFSET_CLASS PULSE_6_OFFSET_R;
    PULSE_n_OFFSET_CLASS PULSE_7_OFFSET_R;
    PULSE_n_OFFSET_CLASS PULSE_8_OFFSET_R;
    PULSE_n_OFFSET_CLASS PULSE_9_OFFSET_R;
    PULSE_n_OFFSET_CLASS PULSE_10_OFFSET_R;
    PULSE_n_OFFSET_CLASS PULSE_11_OFFSET_R;
    PULSE_n_OFFSET_CLASS PULSE_12_OFFSET_R;
    PULSE_n_OFFSET_CLASS PULSE_13_OFFSET_R;
    PULSE_n_OFFSET_CLASS PULSE_14_OFFSET_R;
    PULSE_n_OFFSET_CLASS PULSE_15_OFFSET_R;

    function new(
      input string name,
      input int address,
      input adi_api parent = null);

      super.new(name, address, parent);

      this.VERSION_R = new("VERSION", 'h0, this);
      this.ID_R = new("ID", 'h4, this);
      this.SCRATCH_R = new("SCRATCH", 'h8, this);
      this.CORE_MAGIC_R = new("CORE_MAGIC", 'hc, this);
      this.RSTN_R = new("RSTN", 'h10, this);
      this.CONFIG_R = new("CONFIG", 'h18, this);
      this.NB_PULSES_R = new("NB_PULSES", 'h14, this);
      this.PULSE_0_PERIOD_R = new("PULSE_0_PERIOD", 'h40, this);
      this.PULSE_1_PERIOD_R = new("PULSE_1_PERIOD", 'h44, this);
      this.PULSE_2_PERIOD_R = new("PULSE_2_PERIOD", 'h48, this);
      this.PULSE_3_PERIOD_R = new("PULSE_3_PERIOD", 'h4c, this);
      this.PULSE_4_PERIOD_R = new("PULSE_4_PERIOD", 'h50, this);
      this.PULSE_5_PERIOD_R = new("PULSE_5_PERIOD", 'h54, this);
      this.PULSE_6_PERIOD_R = new("PULSE_6_PERIOD", 'h58, this);
      this.PULSE_7_PERIOD_R = new("PULSE_7_PERIOD", 'h5c, this);
      this.PULSE_8_PERIOD_R = new("PULSE_8_PERIOD", 'h60, this);
      this.PULSE_9_PERIOD_R = new("PULSE_9_PERIOD", 'h64, this);
      this.PULSE_10_PERIOD_R = new("PULSE_10_PERIOD", 'h68, this);
      this.PULSE_11_PERIOD_R = new("PULSE_11_PERIOD", 'h6c, this);
      this.PULSE_12_PERIOD_R = new("PULSE_12_PERIOD", 'h70, this);
      this.PULSE_13_PERIOD_R = new("PULSE_13_PERIOD", 'h74, this);
      this.PULSE_14_PERIOD_R = new("PULSE_14_PERIOD", 'h78, this);
      this.PULSE_15_PERIOD_R = new("PULSE_15_PERIOD", 'h7c, this);
      this.PULSE_0_WIDTH_R = new("PULSE_0_WIDTH", 'h80, this);
      this.PULSE_1_WIDTH_R = new("PULSE_1_WIDTH", 'h84, this);
      this.PULSE_2_WIDTH_R = new("PULSE_2_WIDTH", 'h88, this);
      this.PULSE_3_WIDTH_R = new("PULSE_3_WIDTH", 'h8c, this);
      this.PULSE_4_WIDTH_R = new("PULSE_4_WIDTH", 'h90, this);
      this.PULSE_5_WIDTH_R = new("PULSE_5_WIDTH", 'h94, this);
      this.PULSE_6_WIDTH_R = new("PULSE_6_WIDTH", 'h98, this);
      this.PULSE_7_WIDTH_R = new("PULSE_7_WIDTH", 'h9c, this);
      this.PULSE_8_WIDTH_R = new("PULSE_8_WIDTH", 'ha0, this);
      this.PULSE_9_WIDTH_R = new("PULSE_9_WIDTH", 'ha4, this);
      this.PULSE_10_WIDTH_R = new("PULSE_10_WIDTH", 'ha8, this);
      this.PULSE_11_WIDTH_R = new("PULSE_11_WIDTH", 'hac, this);
      this.PULSE_12_WIDTH_R = new("PULSE_12_WIDTH", 'hb0, this);
      this.PULSE_13_WIDTH_R = new("PULSE_13_WIDTH", 'hb4, this);
      this.PULSE_14_WIDTH_R = new("PULSE_14_WIDTH", 'hb8, this);
      this.PULSE_15_WIDTH_R = new("PULSE_15_WIDTH", 'hbc, this);
      this.PULSE_0_OFFSET_R = new("PULSE_0_OFFSET", 'hc0, this);
      this.PULSE_1_OFFSET_R = new("PULSE_1_OFFSET", 'hc4, this);
      this.PULSE_2_OFFSET_R = new("PULSE_2_OFFSET", 'hc8, this);
      this.PULSE_3_OFFSET_R = new("PULSE_3_OFFSET", 'hcc, this);
      this.PULSE_4_OFFSET_R = new("PULSE_4_OFFSET", 'hd0, this);
      this.PULSE_5_OFFSET_R = new("PULSE_5_OFFSET", 'hd4, this);
      this.PULSE_6_OFFSET_R = new("PULSE_6_OFFSET", 'hd8, this);
      this.PULSE_7_OFFSET_R = new("PULSE_7_OFFSET", 'hdc, this);
      this.PULSE_8_OFFSET_R = new("PULSE_8_OFFSET", 'he0, this);
      this.PULSE_9_OFFSET_R = new("PULSE_9_OFFSET", 'he4, this);
      this.PULSE_10_OFFSET_R = new("PULSE_10_OFFSET", 'he8, this);
      this.PULSE_11_OFFSET_R = new("PULSE_11_OFFSET", 'hec, this);
      this.PULSE_12_OFFSET_R = new("PULSE_12_OFFSET", 'hf0, this);
      this.PULSE_13_OFFSET_R = new("PULSE_13_OFFSET", 'hf4, this);
      this.PULSE_14_OFFSET_R = new("PULSE_14_OFFSET", 'hf8, this);
      this.PULSE_15_OFFSET_R = new("PULSE_15_OFFSET", 'hfc, this);

      this.info($sformatf("Initialized"), ADI_VERBOSITY_HIGH);
    endfunction: new

  endclass: adi_regmap_pwm_gen

endpackage: adi_regmap_pwm_gen_pkg
