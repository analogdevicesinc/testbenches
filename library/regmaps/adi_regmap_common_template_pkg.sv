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

package adi_regmap_common_template_pkg;
  import logger_pkg::*;
  import adi_api_pkg::*;

  class adi_regmap_common_template extends adi_regmap;

    /* Base */
    class VERSION_CLASS extends register_base;
      field_base VERSION_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.VERSION_F = new("VERSION", 31, 0, RO, 'h0, this);

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

    class CONFIG_CLASS extends register_base;
      field_base IQCORRECTION_DISABLE_F;
      field_base DCFILTER_DISABLE_F;
      field_base DATAFORMAT_DISABLE_F;
      field_base USERPORTS_DISABLE_F;
      field_base MODE_1R1T_F;
      field_base DELAY_CONTROL_DISABLE_F;
      field_base DDS_DISABLE_F;
      field_base CMOS_OR_LVDS_N_F;
      field_base PPS_RECEIVER_ENABLE_F;
      field_base SCALECORRECTION_ONLY_F;
      field_base EXT_SYNC_F;
      field_base RD_RAW_DATA_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.IQCORRECTION_DISABLE_F = new("IQCORRECTION_DISABLE", 0, 0, RO, 'h0, this);
        this.DCFILTER_DISABLE_F = new("DCFILTER_DISABLE", 1, 1, RO, 'h0, this);
        this.DATAFORMAT_DISABLE_F = new("DATAFORMAT_DISABLE", 2, 2, RO, 'h0, this);
        this.USERPORTS_DISABLE_F = new("USERPORTS_DISABLE", 3, 3, RO, 'h0, this);
        this.MODE_1R1T_F = new("MODE_1R1T", 4, 4, RO, 'h0, this);
        this.DELAY_CONTROL_DISABLE_F = new("DELAY_CONTROL_DISABLE", 5, 5, RO, 'h0, this);
        this.DDS_DISABLE_F = new("DDS_DISABLE", 6, 6, RO, 'h0, this);
        this.CMOS_OR_LVDS_N_F = new("CMOS_OR_LVDS_N", 7, 7, RO, 'h0, this);
        this.PPS_RECEIVER_ENABLE_F = new("PPS_RECEIVER_ENABLE", 8, 8, RO, 'h0, this);
        this.SCALECORRECTION_ONLY_F = new("SCALECORRECTION_ONLY", 9, 9, RO, 'h0, this);
        this.EXT_SYNC_F = new("EXT_SYNC", 12, 12, RO, 'h0, this);
        this.RD_RAW_DATA_F = new("RD_RAW_DATA", 13, 13, RO, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: CONFIG_CLASS

    class PPS_IRQ_MASK_CLASS extends register_base;
      field_base PPS_IRQ_MASK_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.PPS_IRQ_MASK_F = new("PPS_IRQ_MASK", 0, 0, RW, 'h1, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: PPS_IRQ_MASK_CLASS

    class FPGA_INFO_CLASS extends register_base;
      field_base FPGA_TECHNOLOGY_F;
      field_base FPGA_FAMILY_F;
      field_base SPEED_GRADE_F;
      field_base DEV_PACKAGE_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.FPGA_TECHNOLOGY_F = new("FPGA_TECHNOLOGY", 31, 24, RO, 'h0, this);
        this.FPGA_FAMILY_F = new("FPGA_FAMILY", 23, 16, RO, 'h0, this);
        this.SPEED_GRADE_F = new("SPEED_GRADE", 15, 8, RO, 'h0, this);
        this.DEV_PACKAGE_F = new("DEV_PACKAGE", 7, 0, RO, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: FPGA_INFO_CLASS

    VERSION_CLASS VERSION_R;
    ID_CLASS ID_R;
    SCRATCH_CLASS SCRATCH_R;
    CONFIG_CLASS CONFIG_R;
    PPS_IRQ_MASK_CLASS PPS_IRQ_MASK_R;
    FPGA_INFO_CLASS FPGA_INFO_R;

    function new(
      input string name,
      input int address,
      input adi_api parent = null);

      super.new(name, address, parent);

      this.VERSION_R = new("VERSION", 'h0, this);
      this.ID_R = new("ID", 'h4, this);
      this.SCRATCH_R = new("SCRATCH", 'h8, this);
      this.CONFIG_R = new("CONFIG", 'hc, this);
      this.PPS_IRQ_MASK_R = new("PPS_IRQ_MASK", 'h10, this);
      this.FPGA_INFO_R = new("FPGA_INFO", 'h1c, this);

      this.info($sformatf("Initialized"), ADI_VERBOSITY_HIGH);
    endfunction: new

  endclass: adi_regmap_common_template

endpackage: adi_regmap_common_template_pkg
