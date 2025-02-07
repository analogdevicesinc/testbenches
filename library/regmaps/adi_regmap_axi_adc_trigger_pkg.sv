// ***************************************************************************
// ***************************************************************************
// Copyright (C) 2014 - 2025 Analog Devices, Inc. All rights reserved.
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
/* Feb 07 14:25:05 2025 v0.4.1 */

package adi_regmap_axi_adc_trigger_pkg;
  import logger_pkg::*;
  import adi_api_pkg::*;

  class adi_regmap_axi_adc_trigger extends adi_regmap;

    /* AXI ADC Trigger (axi_adc_trigger) */
    class VERSION_CLASS extends register_base;
      field_base VERSION_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.VERSION_F = new("VERSION", 31, 0, RO, 'h30000, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: VERSION_CLASS

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

    class TRIGGER_O_CLASS extends register_base;
      field_base TRIGGER_O_1_F;
      field_base TRIGGER_O_0_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.TRIGGER_O_1_F = new("TRIGGER_O_1", 1, 1, RW, 'h0, this);
        this.TRIGGER_O_0_F = new("TRIGGER_O_0", 0, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: TRIGGER_O_CLASS

    class IO_SELECTION_CLASS extends register_base;
      field_base TRIGGER_O_1_F;
      field_base TRIGGER_O_0_F;
      field_base IO_SELECTION_1_F;
      field_base IO_SELECTION_0_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.TRIGGER_O_1_F = new("TRIGGER_O_1", 7, 5, RW, 'h0, this);
        this.TRIGGER_O_0_F = new("TRIGGER_O_0", 4, 2, RW, 'h0, this);
        this.IO_SELECTION_1_F = new("IO_SELECTION_1", 1, 1, RW, 'h0, this);
        this.IO_SELECTION_0_F = new("IO_SELECTION_0", 0, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: IO_SELECTION_CLASS

    class CONFIG_TRIGGER_I_CLASS extends register_base;
      field_base FALL_EDGE_F;
      field_base RISE_EDGE_F;
      field_base ANY_EDGE_F;
      field_base HIGH_LEVEL_F;
      field_base LOW_LEVEL_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.FALL_EDGE_F = new("FALL_EDGE", 9, 8, RW, 'h0, this);
        this.RISE_EDGE_F = new("RISE_EDGE", 7, 6, RW, 'h0, this);
        this.ANY_EDGE_F = new("ANY_EDGE", 5, 4, RW, 'h0, this);
        this.HIGH_LEVEL_F = new("HIGH_LEVEL", 3, 2, RW, 'h0, this);
        this.LOW_LEVEL_F = new("LOW_LEVEL", 1, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: CONFIG_TRIGGER_I_CLASS

    class LIMIT_A_CLASS extends register_base;
      field_base LIMIT_A_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.LIMIT_A_F = new("LIMIT_A", 15, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: LIMIT_A_CLASS

    class FUNCTION_A_CLASS extends register_base;
      field_base TRIGGER_FUNCTION_A_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.TRIGGER_FUNCTION_A_F = new("TRIGGER_FUNCTION_A", 1, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: FUNCTION_A_CLASS

    class HYSTERESIS_A_CLASS extends register_base;
      field_base HYSTERESIS_A_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.HYSTERESIS_A_F = new("HYSTERESIS_A", 31, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: HYSTERESIS_A_CLASS

    class TRIGGER_MUX_A_CLASS extends register_base;
      field_base TRIGGER_MUX_A_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.TRIGGER_MUX_A_F = new("TRIGGER_MUX_A", 3, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: TRIGGER_MUX_A_CLASS

    class LIMIT_B_CLASS extends register_base;
      field_base LIMIT_B_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.LIMIT_B_F = new("LIMIT_B", 15, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: LIMIT_B_CLASS

    class FUNCTION_B_CLASS extends register_base;
      field_base TRIGGER_FUNCTION_B_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.TRIGGER_FUNCTION_B_F = new("TRIGGER_FUNCTION_B", 1, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: FUNCTION_B_CLASS

    class HYSTERESIS_B_CLASS extends register_base;
      field_base HYSTERESIS_B_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.HYSTERESIS_B_F = new("HYSTERESIS_B", 31, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: HYSTERESIS_B_CLASS

    class TRIGGER_MUX_B_CLASS extends register_base;
      field_base TRIGGER_MUX_B_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.TRIGGER_MUX_B_F = new("TRIGGER_MUX_B", 3, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: TRIGGER_MUX_B_CLASS

    class TRIGGER_OUT_CONTROL_CLASS extends register_base;
      field_base EMBEDDED_TRIGGER_F;
      field_base TRIGGER_MUX_OUT_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.EMBEDDED_TRIGGER_F = new("EMBEDDED_TRIGGER", 16, 16, RW, 'h0, this);
        this.TRIGGER_MUX_OUT_F = new("TRIGGER_MUX_OUT", 3, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: TRIGGER_OUT_CONTROL_CLASS

    class FIFO_DEPTH_CLASS extends register_base;
      field_base FIFO_DEPTH_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.FIFO_DEPTH_F = new("FIFO_DEPTH", 31, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: FIFO_DEPTH_CLASS

    class TRIGGERED_CLASS extends register_base;
      field_base TRIGGERED_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.TRIGGERED_F = new("TRIGGERED", 1, 1, RW1C, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: TRIGGERED_CLASS

    class TRIGGER_DELAY_CLASS extends register_base;
      field_base TRIGGER_DELAY_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.TRIGGER_DELAY_F = new("TRIGGER_DELAY", 31, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: TRIGGER_DELAY_CLASS

    class STREAMING_CLASS extends register_base;
      field_base STREAMING_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.STREAMING_F = new("STREAMING", 0, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: STREAMING_CLASS

    class TRIGGER_HOLDOFF_CLASS extends register_base;
      field_base TRIGGER_HOLDOFF_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.TRIGGER_HOLDOFF_F = new("TRIGGER_HOLDOFF", 31, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: TRIGGER_HOLDOFF_CLASS

    class TRIGGER_OUT_HOLD_PINS_CLASS extends register_base;
      field_base TRIGGER_OUT_HOLD_PINS_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.TRIGGER_OUT_HOLD_PINS_F = new("TRIGGER_OUT_HOLD_PINS", 1, 1, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: TRIGGER_OUT_HOLD_PINS_CLASS

    VERSION_CLASS VERSION_R;
    SCRATCH_CLASS SCRATCH_R;
    TRIGGER_O_CLASS TRIGGER_O_R;
    IO_SELECTION_CLASS IO_SELECTION_R;
    CONFIG_TRIGGER_I_CLASS CONFIG_TRIGGER_I_R;
    LIMIT_A_CLASS LIMIT_A_R;
    FUNCTION_A_CLASS FUNCTION_A_R;
    HYSTERESIS_A_CLASS HYSTERESIS_A_R;
    TRIGGER_MUX_A_CLASS TRIGGER_MUX_A_R;
    LIMIT_B_CLASS LIMIT_B_R;
    FUNCTION_B_CLASS FUNCTION_B_R;
    HYSTERESIS_B_CLASS HYSTERESIS_B_R;
    TRIGGER_MUX_B_CLASS TRIGGER_MUX_B_R;
    TRIGGER_OUT_CONTROL_CLASS TRIGGER_OUT_CONTROL_R;
    FIFO_DEPTH_CLASS FIFO_DEPTH_R;
    TRIGGERED_CLASS TRIGGERED_R;
    TRIGGER_DELAY_CLASS TRIGGER_DELAY_R;
    STREAMING_CLASS STREAMING_R;
    TRIGGER_HOLDOFF_CLASS TRIGGER_HOLDOFF_R;
    TRIGGER_OUT_HOLD_PINS_CLASS TRIGGER_OUT_HOLD_PINS_R;

    function new(
      input string name,
      input int address,
      input adi_api parent = null);

      super.new(name, address, parent);

      this.VERSION_R = new("VERSION", 'h0, this);
      this.SCRATCH_R = new("SCRATCH", 'h4, this);
      this.TRIGGER_O_R = new("TRIGGER_O", 'h8, this);
      this.IO_SELECTION_R = new("IO_SELECTION", 'hc, this);
      this.CONFIG_TRIGGER_I_R = new("CONFIG_TRIGGER_I", 'h10, this);
      this.LIMIT_A_R = new("LIMIT_A", 'h14, this);
      this.FUNCTION_A_R = new("FUNCTION_A", 'h18, this);
      this.HYSTERESIS_A_R = new("HYSTERESIS_A", 'h1c, this);
      this.TRIGGER_MUX_A_R = new("TRIGGER_MUX_A", 'h20, this);
      this.LIMIT_B_R = new("LIMIT_B", 'h24, this);
      this.FUNCTION_B_R = new("FUNCTION_B", 'h28, this);
      this.HYSTERESIS_B_R = new("HYSTERESIS_B", 'h2c, this);
      this.TRIGGER_MUX_B_R = new("TRIGGER_MUX_B", 'h30, this);
      this.TRIGGER_OUT_CONTROL_R = new("TRIGGER_OUT_CONTROL", 'h34, this);
      this.FIFO_DEPTH_R = new("FIFO_DEPTH", 'h38, this);
      this.TRIGGERED_R = new("TRIGGERED", 'h3c, this);
      this.TRIGGER_DELAY_R = new("TRIGGER_DELAY", 'h40, this);
      this.STREAMING_R = new("STREAMING", 'h44, this);
      this.TRIGGER_HOLDOFF_R = new("TRIGGER_HOLDOFF", 'h48, this);
      this.TRIGGER_OUT_HOLD_PINS_R = new("TRIGGER_OUT_HOLD_PINS", 'h4c, this);

      this.info($sformatf("Initialized"), ADI_VERBOSITY_HIGH);
    endfunction: new

  endclass: adi_regmap_axi_adc_trigger

endpackage: adi_regmap_axi_adc_trigger_pkg
