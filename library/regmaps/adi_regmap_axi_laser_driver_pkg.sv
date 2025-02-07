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

package adi_regmap_axi_laser_driver_pkg;
  import logger_pkg::*;
  import adi_api_pkg::*;

  class adi_regmap_axi_laser_driver extends adi_regmap;

    /* AXI Laser Driver (axi_laser_driver) */
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
        this.VERSION_MINOR_F = new("VERSION_MINOR", 15, 8, RO, 'h1, this);
        this.VERSION_PATCH_F = new("VERSION_PATCH", 7, 0, RO, 'h61, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: VERSION_CLASS

    class ID_CLASS extends register_base;
      field_base ID_F;

      function new(
        input string name,
        input int address,
        input int ID,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.ID_F = new("ID", 31, 0, RO, ID, this);

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

    class CONFIG_PWM_CLASS extends register_base;
      field_base RESET_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.RESET_F = new("RESET", 0, 0, RW, 'h1, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: CONFIG_PWM_CLASS

    class CONFIG_PERIOD_CLASS extends register_base;
      field_base PWM_PERIOD_F;

      function new(
        input string name,
        input int address,
        input int PULSE_PERIOD,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.PWM_PERIOD_F = new("PWM_PERIOD", 31, 0, RW, PULSE_PERIOD, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: CONFIG_PERIOD_CLASS

    class CONFIG_WIDTH_CLASS extends register_base;
      field_base PWM_WIDTH_F;

      function new(
        input string name,
        input int address,
        input int PULSE_WIDTH,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.PWM_WIDTH_F = new("PWM_WIDTH", 31, 0, RW, PULSE_WIDTH, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: CONFIG_WIDTH_CLASS

    class STATUS_LDRIVER_CLASS extends register_base;
      field_base DRIVER_OTW_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.DRIVER_OTW_F = new("DRIVER_OTW", 0, 0, RO, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: STATUS_LDRIVER_CLASS

    class EXT_CLK_MONITOR_CLASS extends register_base;
      field_base EXT_CLK_FREQ_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.EXT_CLK_FREQ_F = new("EXT_CLK_FREQ", 31, 0, RO, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: EXT_CLK_MONITOR_CLASS

    class IRQ_PENDING_CLASS extends register_base;
      field_base IRQ_PULSE_PENDING_F;
      field_base IRQ_OTW_ENTER_PENDING_F;
      field_base IRQ_OTW_EXIT_PENDING_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.IRQ_PULSE_PENDING_F = new("IRQ_PULSE_PENDING", 0, 0, RW1C, 'h0, this);
        this.IRQ_OTW_ENTER_PENDING_F = new("IRQ_OTW_ENTER_PENDING", 1, 1, RW1C, 'h0, this);
        this.IRQ_OTW_EXIT_PENDING_F = new("IRQ_OTW_EXIT_PENDING", 2, 2, RW1C, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: IRQ_PENDING_CLASS

    class IRQ_SOURCE_CLASS extends register_base;
      field_base IRQ_PULSE_SOURCE_F;
      field_base IRQ_OTW_ENTER_SOURCE_F;
      field_base IRQ_OTW_EXIT_SOURCE_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.IRQ_PULSE_SOURCE_F = new("IRQ_PULSE_SOURCE", 0, 0, RO, 'h0, this);
        this.IRQ_OTW_ENTER_SOURCE_F = new("IRQ_OTW_ENTER_SOURCE", 1, 1, RO, 'h0, this);
        this.IRQ_OTW_EXIT_SOURCE_F = new("IRQ_OTW_EXIT_SOURCE", 2, 2, RO, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: IRQ_SOURCE_CLASS

    class SEQUENCER_CONTROL_CLASS extends register_base;
      field_base SEQUENCER_ENABLE_F;
      field_base AUTO_SEQUENCE_EN_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.SEQUENCER_ENABLE_F = new("SEQUENCER_ENABLE", 0, 0, RW, 'h0, this);
        this.AUTO_SEQUENCE_EN_F = new("AUTO_SEQUENCE_EN", 1, 1, RW, 'h1, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: SEQUENCER_CONTROL_CLASS

    class SEQUENCER_OFFSET_CLASS extends register_base;
      field_base TIA_CHSEL_OFFSET_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.TIA_CHSEL_OFFSET_F = new("TIA_CHSEL_OFFSET", 31, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: SEQUENCER_OFFSET_CLASS

    class SEQUENCE_AUTO_CONFIG_CLASS extends register_base;
      field_base SEQUENCE_VALUE0_F;
      field_base SEQUENCE_VALUE1_F;
      field_base SEQUENCE_VALUE2_F;
      field_base SEQUENCE_VALUE3_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.SEQUENCE_VALUE0_F = new("SEQUENCE_VALUE0", 1, 0, RW, 'h0, this);
        this.SEQUENCE_VALUE1_F = new("SEQUENCE_VALUE1", 5, 4, RW, 'h1, this);
        this.SEQUENCE_VALUE2_F = new("SEQUENCE_VALUE2", 9, 8, RW, 'h2, this);
        this.SEQUENCE_VALUE3_F = new("SEQUENCE_VALUE3", 13, 12, RW, 'h3, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: SEQUENCE_AUTO_CONFIG_CLASS

    class TIA_MANUAL_CONFIG_CLASS extends register_base;
      field_base TIA0_CHSEL_MANUAL_F;
      field_base TIA1_CHSEL_MANUAL_F;
      field_base TIA2_CHSEL_MANUAL_F;
      field_base TIA3_CHSEL_MANUAL_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.TIA0_CHSEL_MANUAL_F = new("TIA0_CHSEL_MANUAL", 1, 0, RW, 'h0, this);
        this.TIA1_CHSEL_MANUAL_F = new("TIA1_CHSEL_MANUAL", 5, 4, RW, 'h0, this);
        this.TIA2_CHSEL_MANUAL_F = new("TIA2_CHSEL_MANUAL", 9, 8, RW, 'h0, this);
        this.TIA3_CHSEL_MANUAL_F = new("TIA3_CHSEL_MANUAL", 13, 12, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: TIA_MANUAL_CONFIG_CLASS

    VERSION_CLASS VERSION_R;
    ID_CLASS ID_R;
    SCRATCH_CLASS SCRATCH_R;
    CONFIG_PWM_CLASS CONFIG_PWM_R;
    CONFIG_PERIOD_CLASS CONFIG_PERIOD_R;
    CONFIG_WIDTH_CLASS CONFIG_WIDTH_R;
    STATUS_LDRIVER_CLASS STATUS_LDRIVER_R;
    EXT_CLK_MONITOR_CLASS EXT_CLK_MONITOR_R;
    IRQ_PENDING_CLASS IRQ_PENDING_R;
    IRQ_SOURCE_CLASS IRQ_SOURCE_R;
    SEQUENCER_CONTROL_CLASS SEQUENCER_CONTROL_R;
    SEQUENCER_OFFSET_CLASS SEQUENCER_OFFSET_R;
    SEQUENCE_AUTO_CONFIG_CLASS SEQUENCE_AUTO_CONFIG_R;
    TIA_MANUAL_CONFIG_CLASS TIA_MANUAL_CONFIG_R;

    function new(
      input string name,
      input int address,
      input int ID,
      input int PULSE_PERIOD,
      input int PULSE_WIDTH,
      input adi_api parent = null);

      super.new(name, address, parent);

      this.VERSION_R = new("VERSION", 'h0, this);
      this.ID_R = new("ID", 'h4, ID, this);
      this.SCRATCH_R = new("SCRATCH", 'h8, this);
      this.CONFIG_PWM_R = new("CONFIG_PWM", 'h10, this);
      this.CONFIG_PERIOD_R = new("CONFIG_PERIOD", 'h14, PULSE_PERIOD, this);
      this.CONFIG_WIDTH_R = new("CONFIG_WIDTH", 'h18, PULSE_WIDTH, this);
      this.STATUS_LDRIVER_R = new("STATUS_LDRIVER", 'h84, this);
      this.EXT_CLK_MONITOR_R = new("EXT_CLK_MONITOR", 'h88, this);
      this.IRQ_PENDING_R = new("IRQ_PENDING", 'ha4, this);
      this.IRQ_SOURCE_R = new("IRQ_SOURCE", 'ha8, this);
      this.SEQUENCER_CONTROL_R = new("SEQUENCER_CONTROL", 'hac, this);
      this.SEQUENCER_OFFSET_R = new("SEQUENCER_OFFSET", 'hb0, this);
      this.SEQUENCE_AUTO_CONFIG_R = new("SEQUENCE_AUTO_CONFIG", 'hb4, this);
      this.TIA_MANUAL_CONFIG_R = new("TIA_MANUAL_CONFIG", 'hb8, this);

      this.info($sformatf("Initialized"), ADI_VERBOSITY_HIGH);
    endfunction: new

  endclass: adi_regmap_axi_laser_driver

endpackage: adi_regmap_axi_laser_driver_pkg
