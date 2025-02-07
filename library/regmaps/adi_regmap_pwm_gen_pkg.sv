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
    PULSE_n_PERIOD_CLASS PULSE_n_PERIOD_R [15:0];
    PULSE_n_WIDTH_CLASS PULSE_n_WIDTH_R [15:0];
    PULSE_n_OFFSET_CLASS PULSE_n_OFFSET_R [15:0];

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
      for (int i=0; i<16; i++) begin
        this.PULSE_n_PERIOD_R[i] = new($sformatf("PULSE_%0d_PERIOD", i), 'h40 + 'h1 * i * 4, this);
      end
      for (int i=0; i<16; i++) begin
        this.PULSE_n_WIDTH_R[i] = new($sformatf("PULSE_%0d_WIDTH", i), 'h80 + 'h1 * i * 4, this);
      end
      for (int i=0; i<16; i++) begin
        this.PULSE_n_OFFSET_R[i] = new($sformatf("PULSE_%0d_OFFSET", i), 'hc0 + 'h1 * i * 4, this);
      end

      this.info($sformatf("Initialized"), ADI_VERBOSITY_HIGH);
    endfunction: new

  endclass: adi_regmap_pwm_gen

endpackage: adi_regmap_pwm_gen_pkg
