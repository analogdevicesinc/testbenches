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
/* Feb 07 11:48:47 2025 v0.4.1 */

package adi_regmap_axi_logic_analyzer_pkg;
  import logger_pkg::*;
  import adi_api_pkg::*;

  class adi_regmap_axi_logic_analyzer extends adi_regmap;

    /* Logic Analyzer and Pattern Generator (axi_logic_analyzer) */
    class VERSION_CLASS extends register_base;
      field_base VERSION_MAJOR_F;
      field_base VERSION_MINOR_F;
      field_base VERSION_PATCH_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.VERSION_MAJOR_F = new("VERSION_MAJOR", 31, 16, RO, 'h2, this);
        this.VERSION_MINOR_F = new("VERSION_MINOR", 15, 8, RO, 'h1, this);
        this.VERSION_PATCH_F = new("VERSION_PATCH", 7, 0, RO, 'h0, this);

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

        this.SCRATCH_F = new("SCRATCH", 31, 0, RW, 'hXXXXXXXX, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: SCRATCH_CLASS

    class DIVIDER_COUNTER_LA_CLASS extends register_base;
      field_base DIVIDER_COUNTER_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.DIVIDER_COUNTER_F = new("DIVIDER_COUNTER", 31, 0, RW, 'hXXXXXXXX, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: DIVIDER_COUNTER_LA_CLASS

    class DIVIDER_COUNTER_PG_CLASS extends register_base;
      field_base DIVIDER_COUNTER_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.DIVIDER_COUNTER_F = new("DIVIDER_COUNTER", 31, 0, RW, 'hXXXXXXXX, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: DIVIDER_COUNTER_PG_CLASS

    class IO_SELECTION_CLASS extends register_base;
      field_base DIRECTION_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.DIRECTION_F = new("DIRECTION", 15, 0, RW, 'hXXXXXXXX, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: IO_SELECTION_CLASS

    class EDGE_DETECT_CONTROL_CLASS extends register_base;
      field_base TRIGGER_F;
      field_base DATA_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.TRIGGER_F = new("TRIGGER", 17, 16, RW, 'hXXXXXXXX, this);
        this.DATA_F = new("DATA", 15, 0, RW, 'hXXXXXXXX, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: EDGE_DETECT_CONTROL_CLASS

    class RISE_EDGE_CONTROL_CLASS extends register_base;
      field_base TRIGGER_F;
      field_base DATA_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.TRIGGER_F = new("TRIGGER", 17, 16, RW, 'hXXXXXXXX, this);
        this.DATA_F = new("DATA", 15, 0, RW, 'hXXXXXXXX, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: RISE_EDGE_CONTROL_CLASS

    class FALL_EDGE_CONTROL_CLASS extends register_base;
      field_base TRIGGER_F;
      field_base DATA_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.TRIGGER_F = new("TRIGGER", 17, 16, RW, 'hXXXXXXXX, this);
        this.DATA_F = new("DATA", 15, 0, RW, 'hXXXXXXXX, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: FALL_EDGE_CONTROL_CLASS

    class LOW_LEVEL_CONTROL_CLASS extends register_base;
      field_base TRIGGER_F;
      field_base DATA_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.TRIGGER_F = new("TRIGGER", 17, 16, RW, 'hXXXXXXXX, this);
        this.DATA_F = new("DATA", 15, 0, RW, 'hXXXXXXXX, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: LOW_LEVEL_CONTROL_CLASS

    class HIGH_LEVEL_CONTROL_CLASS extends register_base;
      field_base TRIGGER_F;
      field_base DATA_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.TRIGGER_F = new("TRIGGER", 17, 16, RW, 'hXXXXXXXX, this);
        this.DATA_F = new("DATA", 15, 0, RW, 'hXXXXXXXX, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: HIGH_LEVEL_CONTROL_CLASS

    class FIFO_DEPTH_CLASS extends register_base;
      field_base FIFO_DEPTH_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.FIFO_DEPTH_F = new("FIFO_DEPTH", 31, 0, RW, 'hXXXXXXXX, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: FIFO_DEPTH_CLASS

    class TRIGGER_LOGIC_CLASS extends register_base;
      field_base TRIGGER_MUX_OUT_F;
      field_base TRIGGER_LOGIC_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.TRIGGER_MUX_OUT_F = new("TRIGGER_MUX_OUT", 6, 4, RW, 'hXXXXXXXX, this);
        this.TRIGGER_LOGIC_F = new("TRIGGER_LOGIC", 0, 0, RW, 'hXXXXXXXX, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: TRIGGER_LOGIC_CLASS

    class CLOCK_SELECT_CLASS extends register_base;
      field_base CLOCK_SELECT_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.CLOCK_SELECT_F = new("CLOCK_SELECT", 0, 0, RW, 'hXXXXXXXX, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: CLOCK_SELECT_CLASS

    class OVERWRITE_MASK_CLASS extends register_base;
      field_base OVERWRITE_MASK_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.OVERWRITE_MASK_F = new("OVERWRITE_MASK", 15, 0, RW, 'hXXXXXXXX, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: OVERWRITE_MASK_CLASS

    class OVERWRITE_DATA_CLASS extends register_base;
      field_base OVERWRITE_DATA_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.OVERWRITE_DATA_F = new("OVERWRITE_DATA", 15, 0, RW, 'hXXXXXXXX, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: OVERWRITE_DATA_CLASS

    class INPUT_DATA_CLASS extends register_base;
      field_base INPUT_DATA_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.INPUT_DATA_F = new("INPUT_DATA", 15, 0, RO, 'hXXXXXXXX, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: INPUT_DATA_CLASS

    class OUTPUT_MODE_CLASS extends register_base;
      field_base OUTPUT_MODE_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.OUTPUT_MODE_F = new("OUTPUT_MODE", 0, 0, RW, 'hXXXXXXXX, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: OUTPUT_MODE_CLASS

    class TRIGGER_DELAY_CLASS extends register_base;
      field_base TRIGGER_DELAY_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.TRIGGER_DELAY_F = new("TRIGGER_DELAY", 31, 0, RW, 'hXXXXXXXX, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: TRIGGER_DELAY_CLASS

    class TRIGGERED_CLASS extends register_base;
      field_base TRIGGERED_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.TRIGGERED_F = new("TRIGGERED", 0, 0, RW1C, 'hXXXXXXXX, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: TRIGGERED_CLASS

    class STREAMING_CLASS extends register_base;
      field_base STREAMING_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.STREAMING_F = new("STREAMING", 0, 0, RW, 'hXXXXXXXX, this);

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

        this.TRIGGER_HOLDOFF_F = new("TRIGGER_HOLDOFF", 31, 0, RW, 'hXXXXXXXX, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: TRIGGER_HOLDOFF_CLASS

    class PG_TRIGGER_CONFIG_CLASS extends register_base;
      field_base EN_TRIGGER_LA_F;
      field_base EN_TRIGGER_ADC_F;
      field_base EN_TRIGGER_TO_F;
      field_base EN_TRIGGER_TI_F;
      field_base HIGH_LEVEL_F;
      field_base LOW_LEVEL_F;
      field_base FALL_EDGE_F;
      field_base RISE_EDGE_F;
      field_base ANY_EDGE_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.EN_TRIGGER_LA_F = new("EN_TRIGGER_LA", 19, 19, RW, 'hXXXXXXXX, this);
        this.EN_TRIGGER_ADC_F = new("EN_TRIGGER_ADC", 18, 18, RW, 'hXXXXXXXX, this);
        this.EN_TRIGGER_TO_F = new("EN_TRIGGER_TO", 17, 17, RW, 'hXXXXXXXX, this);
        this.EN_TRIGGER_TI_F = new("EN_TRIGGER_TI", 16, 16, RW, 'hXXXXXXXX, this);
        this.HIGH_LEVEL_F = new("HIGH_LEVEL", 9, 8, RW, 'hXXXXXXXX, this);
        this.LOW_LEVEL_F = new("LOW_LEVEL", 7, 6, RW, 'hXXXXXXXX, this);
        this.FALL_EDGE_F = new("FALL_EDGE", 5, 4, RW, 'hXXXXXXXX, this);
        this.RISE_EDGE_F = new("RISE_EDGE", 3, 2, RW, 'hXXXXXXXX, this);
        this.ANY_EDGE_F = new("ANY_EDGE", 1, 0, RW, 'hXXXXXXXX, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: PG_TRIGGER_CONFIG_CLASS

    class DATA_DELAY_CONTROL_CLASS extends register_base;
      field_base MASTER_DELAY_CTRL_F;
      field_base RATE_GEN_SELECT_F;
      field_base MANUAL_DATA_DELAY_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.MASTER_DELAY_CTRL_F = new("MASTER_DELAY_CTRL", 9, 9, RW, 'hXXXXXXXX, this);
        this.RATE_GEN_SELECT_F = new("RATE_GEN_SELECT", 8, 8, RW, 'hXXXXXXXX, this);
        this.MANUAL_DATA_DELAY_F = new("MANUAL_DATA_DELAY", 5, 0, RW, 'hXXXXXXXX, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: DATA_DELAY_CONTROL_CLASS

    VERSION_CLASS VERSION_R;
    SCRATCH_CLASS SCRATCH_R;
    DIVIDER_COUNTER_LA_CLASS DIVIDER_COUNTER_LA_R;
    DIVIDER_COUNTER_PG_CLASS DIVIDER_COUNTER_PG_R;
    IO_SELECTION_CLASS IO_SELECTION_R;
    EDGE_DETECT_CONTROL_CLASS EDGE_DETECT_CONTROL_R;
    RISE_EDGE_CONTROL_CLASS RISE_EDGE_CONTROL_R;
    FALL_EDGE_CONTROL_CLASS FALL_EDGE_CONTROL_R;
    LOW_LEVEL_CONTROL_CLASS LOW_LEVEL_CONTROL_R;
    HIGH_LEVEL_CONTROL_CLASS HIGH_LEVEL_CONTROL_R;
    FIFO_DEPTH_CLASS FIFO_DEPTH_R;
    TRIGGER_LOGIC_CLASS TRIGGER_LOGIC_R;
    CLOCK_SELECT_CLASS CLOCK_SELECT_R;
    OVERWRITE_MASK_CLASS OVERWRITE_MASK_R;
    OVERWRITE_DATA_CLASS OVERWRITE_DATA_R;
    INPUT_DATA_CLASS INPUT_DATA_R;
    OUTPUT_MODE_CLASS OUTPUT_MODE_R;
    TRIGGER_DELAY_CLASS TRIGGER_DELAY_R;
    TRIGGERED_CLASS TRIGGERED_R;
    STREAMING_CLASS STREAMING_R;
    TRIGGER_HOLDOFF_CLASS TRIGGER_HOLDOFF_R;
    PG_TRIGGER_CONFIG_CLASS PG_TRIGGER_CONFIG_R;
    DATA_DELAY_CONTROL_CLASS DATA_DELAY_CONTROL_R;

    function new(
      input string name,
      input int address,
      input adi_api parent = null);

      super.new(name, address, parent);

      this.VERSION_R = new("VERSION", 'h0, this);
      this.SCRATCH_R = new("SCRATCH", 'h4, this);
      this.DIVIDER_COUNTER_LA_R = new("DIVIDER_COUNTER_LA", 'h8, this);
      this.DIVIDER_COUNTER_PG_R = new("DIVIDER_COUNTER_PG", 'hc, this);
      this.IO_SELECTION_R = new("IO_SELECTION", 'h10, this);
      this.EDGE_DETECT_CONTROL_R = new("EDGE_DETECT_CONTROL", 'h14, this);
      this.RISE_EDGE_CONTROL_R = new("RISE_EDGE_CONTROL", 'h18, this);
      this.FALL_EDGE_CONTROL_R = new("FALL_EDGE_CONTROL", 'h1c, this);
      this.LOW_LEVEL_CONTROL_R = new("LOW_LEVEL_CONTROL", 'h20, this);
      this.HIGH_LEVEL_CONTROL_R = new("HIGH_LEVEL_CONTROL", 'h24, this);
      this.FIFO_DEPTH_R = new("FIFO_DEPTH", 'h28, this);
      this.TRIGGER_LOGIC_R = new("TRIGGER_LOGIC", 'h2c, this);
      this.CLOCK_SELECT_R = new("CLOCK_SELECT", 'h30, this);
      this.OVERWRITE_MASK_R = new("OVERWRITE_MASK", 'h34, this);
      this.OVERWRITE_DATA_R = new("OVERWRITE_DATA", 'h38, this);
      this.INPUT_DATA_R = new("INPUT_DATA", 'h3c, this);
      this.OUTPUT_MODE_R = new("OUTPUT_MODE", 'h40, this);
      this.TRIGGER_DELAY_R = new("TRIGGER_DELAY", 'h44, this);
      this.TRIGGERED_R = new("TRIGGERED", 'h48, this);
      this.STREAMING_R = new("STREAMING", 'h4c, this);
      this.TRIGGER_HOLDOFF_R = new("TRIGGER_HOLDOFF", 'h50, this);
      this.PG_TRIGGER_CONFIG_R = new("PG_TRIGGER_CONFIG", 'h54, this);
      this.DATA_DELAY_CONTROL_R = new("DATA_DELAY_CONTROL", 'h50, this);

      this.info($sformatf("Initialized"), ADI_VERBOSITY_HIGH);
    endfunction: new

  endclass: adi_regmap_axi_logic_analyzer

endpackage: adi_regmap_axi_logic_analyzer_pkg
