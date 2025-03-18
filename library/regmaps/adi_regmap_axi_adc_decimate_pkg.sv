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

package adi_regmap_axi_adc_decimate_pkg;
  import logger_pkg::*;
  import adi_api_pkg::*;

  class adi_regmap_axi_adc_decimate extends adi_regmap;

    /* Analog Decimation (axi_adc_decimate) */
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

        this.SCRATCH_F = new("SCRATCH", 31, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: SCRATCH_CLASS

    class DECIMATION_RATIO_CLASS extends register_base;
      field_base DECIMATION_RATIO_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.DECIMATION_RATIO_F = new("DECIMATION_RATIO", 31, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: DECIMATION_RATIO_CLASS

    class DECIMATION_STAGE_ENABLE_CLASS extends register_base;
      field_base FILTERED_DECIMATION_RATIO_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.FILTERED_DECIMATION_RATIO_F = new("FILTERED_DECIMATION_RATIO", 2, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: DECIMATION_STAGE_ENABLE_CLASS

    class CONFIG_CLASS extends register_base;
      field_base CORRECTION_ENABLE_B_F;
      field_base CORRECTION_ENABLE_A_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.CORRECTION_ENABLE_B_F = new("CORRECTION_ENABLE_B", 1, 1, RW, 'h0, this);
        this.CORRECTION_ENABLE_A_F = new("CORRECTION_ENABLE_A", 0, 0, RW, 'h0, this);

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

        this.CORRECTION_COEFFICIENT_F = new("CORRECTION_COEFFICIENT", 15, 0, RW, 'h0, this);

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

        this.CORRECTION_COEFFICIENT_F = new("CORRECTION_COEFFICIENT", 15, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: CORRECTION_COEFFICIENT_B_CLASS

    VERSION_CLASS VERSION_R;
    SCRATCH_CLASS SCRATCH_R;
    DECIMATION_RATIO_CLASS DECIMATION_RATIO_R;
    DECIMATION_STAGE_ENABLE_CLASS DECIMATION_STAGE_ENABLE_R;
    CONFIG_CLASS CONFIG_R;
    CORRECTION_COEFFICIENT_A_CLASS CORRECTION_COEFFICIENT_A_R;
    CORRECTION_COEFFICIENT_B_CLASS CORRECTION_COEFFICIENT_B_R;

    function new(
      input string name,
      input int address,
      input adi_api parent = null);

      super.new(name, address, parent);

      this.VERSION_R = new("VERSION", 'h0, this);
      this.SCRATCH_R = new("SCRATCH", 'h4, this);
      this.DECIMATION_RATIO_R = new("DECIMATION_RATIO", 'h40, this);
      this.DECIMATION_STAGE_ENABLE_R = new("DECIMATION_STAGE_ENABLE", 'h44, this);
      this.CONFIG_R = new("CONFIG", 'h48, this);
      this.CORRECTION_COEFFICIENT_A_R = new("CORRECTION_COEFFICIENT_A", 'h4c, this);
      this.CORRECTION_COEFFICIENT_B_R = new("CORRECTION_COEFFICIENT_B", 'h50, this);

      this.info($sformatf("Initialized"), ADI_VERBOSITY_HIGH);
    endfunction: new

  endclass: adi_regmap_axi_adc_decimate

endpackage: adi_regmap_axi_adc_decimate_pkg
