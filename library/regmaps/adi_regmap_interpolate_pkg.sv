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

package adi_regmap_interpolate_pkg;
  import logger_pkg::*;
  import adi_api_pkg::*;

  class adi_regmap_interpolate extends adi_regmap;

    /* Analog Interpolation (axi_dac_interpolate) */
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
        this.VERSION_MINOR_F = new("VERSION_MINOR", 15, 8, RO, 'h5, this);
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

    class ARBITRARY_INTERPOLATION_RATIO_A_CLASS extends register_base;
      field_base FILTERED_INTERPOLATION_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.FILTERED_INTERPOLATION_F = new("FILTERED_INTERPOLATION", 31, 0, RW, 'hXXXXXXXX, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: ARBITRARY_INTERPOLATION_RATIO_A_CLASS

    class INTERPOLATION_RATIO_A_CLASS extends register_base;
      field_base FILTERED_INTERPOLATION_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.FILTERED_INTERPOLATION_F = new("FILTERED_INTERPOLATION", 2, 0, RW, 'hXXXXXXXX, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: INTERPOLATION_RATIO_A_CLASS

    class ARBITRARY_INTERPOLATION_RATIO_B_CLASS extends register_base;
      field_base FILTERED_INTERPOLATION_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.FILTERED_INTERPOLATION_F = new("FILTERED_INTERPOLATION", 31, 0, RW, 'hXXXXXXXX, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: ARBITRARY_INTERPOLATION_RATIO_B_CLASS

    class INTERPOLATION_RATIO_B_CLASS extends register_base;
      field_base FILTERED_INTERPOLATION_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.FILTERED_INTERPOLATION_F = new("FILTERED_INTERPOLATION", 2, 0, RW, 'hXXXXXXXX, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: INTERPOLATION_RATIO_B_CLASS

    class FLAGS_CLASS extends register_base;
      field_base SUSPEND_TRANSFER_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.SUSPEND_TRANSFER_F = new("SUSPEND_TRANSFER", 0, 0, RW, 'hXXXXXXXX, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: FLAGS_CLASS

    class CONFIG_CLASS extends register_base;
      field_base CORRECTION_ENABLE_B_F;
      field_base CORRECTION_ENABLE_A_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.CORRECTION_ENABLE_B_F = new("CORRECTION_ENABLE_B", 1, 1, RW, 'hXXXXXXXX, this);
        this.CORRECTION_ENABLE_A_F = new("CORRECTION_ENABLE_A", 0, 0, RW, 'hXXXXXXXX, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: CONFIG_CLASS

    class CORRECTION_COEFFICIENT_A_CLASS extends register_base;
      field_base CORRECTION_COEFFICIENT_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.CORRECTION_COEFFICIENT_F = new("CORRECTION_COEFFICIENT", 15, 0, RW, 'hXXXXXXXX, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: CORRECTION_COEFFICIENT_A_CLASS

    class CORRECTION_COEFFICIENT_B_CLASS extends register_base;
      field_base CORRECTION_COEFFICIENT_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.CORRECTION_COEFFICIENT_F = new("CORRECTION_COEFFICIENT", 15, 0, RW, 'hXXXXXXXX, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: CORRECTION_COEFFICIENT_B_CLASS

    class TRIGGER_CONFIG_CLASS extends register_base;
      field_base AUTO_REARM_TRIGGER_F;
      field_base EN_TRIGGER_LA_F;
      field_base EN_TRIGGER_ADC_F;
      field_base EN_TRIGGER_TO_F;
      field_base EN_TRIGGER_TI_F;
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

        this.AUTO_REARM_TRIGGER_F = new("AUTO_REARM_TRIGGER", 20, 20, RW, 'hXXXXXXXX, this);
        this.EN_TRIGGER_LA_F = new("EN_TRIGGER_LA", 19, 19, RW, 'hXXXXXXXX, this);
        this.EN_TRIGGER_ADC_F = new("EN_TRIGGER_ADC", 18, 18, RW, 'hXXXXXXXX, this);
        this.EN_TRIGGER_TO_F = new("EN_TRIGGER_TO", 17, 17, RW, 'hXXXXXXXX, this);
        this.EN_TRIGGER_TI_F = new("EN_TRIGGER_TI", 16, 16, RW, 'hXXXXXXXX, this);
        this.FALL_EDGE_F = new("FALL_EDGE", 9, 8, RW, 'hXXXXXXXX, this);
        this.RISE_EDGE_F = new("RISE_EDGE", 7, 6, RW, 'hXXXXXXXX, this);
        this.ANY_EDGE_F = new("ANY_EDGE", 5, 4, RW, 'hXXXXXXXX, this);
        this.HIGH_LEVEL_F = new("HIGH_LEVEL", 3, 2, RW, 'hXXXXXXXX, this);
        this.LOW_LEVEL_F = new("LOW_LEVEL", 1, 0, RW, 'hXXXXXXXX, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: TRIGGER_CONFIG_CLASS

    VERSION_CLASS VERSION_R;
    SCRATCH_CLASS SCRATCH_R;
    ARBITRARY_INTERPOLATION_RATIO_A_CLASS ARBITRARY_INTERPOLATION_RATIO_A_R;
    INTERPOLATION_RATIO_A_CLASS INTERPOLATION_RATIO_A_R;
    ARBITRARY_INTERPOLATION_RATIO_B_CLASS ARBITRARY_INTERPOLATION_RATIO_B_R;
    INTERPOLATION_RATIO_B_CLASS INTERPOLATION_RATIO_B_R;
    FLAGS_CLASS FLAGS_R;
    CONFIG_CLASS CONFIG_R;
    CORRECTION_COEFFICIENT_A_CLASS CORRECTION_COEFFICIENT_A_R;
    CORRECTION_COEFFICIENT_B_CLASS CORRECTION_COEFFICIENT_B_R;
    TRIGGER_CONFIG_CLASS TRIGGER_CONFIG_R;

    function new(
      input string name,
      input int address,
      input adi_api parent = null);

      super.new(name, address, parent);

      this.VERSION_R = new("VERSION", 'h0, this);
      this.SCRATCH_R = new("SCRATCH", 'h4, this);
      this.ARBITRARY_INTERPOLATION_RATIO_A_R = new("ARBITRARY_INTERPOLATION_RATIO_A", 'h40, this);
      this.INTERPOLATION_RATIO_A_R = new("INTERPOLATION_RATIO_A", 'h44, this);
      this.ARBITRARY_INTERPOLATION_RATIO_B_R = new("ARBITRARY_INTERPOLATION_RATIO_B", 'h48, this);
      this.INTERPOLATION_RATIO_B_R = new("INTERPOLATION_RATIO_B", 'h4c, this);
      this.FLAGS_R = new("FLAGS", 'h50, this);
      this.CONFIG_R = new("CONFIG", 'h54, this);
      this.CORRECTION_COEFFICIENT_A_R = new("CORRECTION_COEFFICIENT_A", 'h58, this);
      this.CORRECTION_COEFFICIENT_B_R = new("CORRECTION_COEFFICIENT_B", 'h5c, this);
      this.TRIGGER_CONFIG_R = new("TRIGGER_CONFIG", 'h60, this);

      this.info($sformatf("Initialized"), ADI_VERBOSITY_HIGH);
    endfunction: new

  endclass: adi_regmap_interpolate

endpackage: adi_regmap_interpolate_pkg
