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

package adi_regmap_clkgen_pkg;
  import logger_pkg::*;
  import adi_api_pkg::*;

  class adi_regmap_clkgen extends adi_regmap;

    /* Clock Generator (axi_clkgen) */
    class RSTN_CLASS extends register_base;
      field_base MMCM_RSTN_F;
      field_base RSTN_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.MMCM_RSTN_F = new("MMCM_RSTN", 1, 1, RW, 'h0, this);
        this.RSTN_F = new("RSTN", 0, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: RSTN_CLASS

    class CLK_SEL_CLASS extends register_base;
      field_base CLK_SEL_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.CLK_SEL_F = new("CLK_SEL", 0, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: CLK_SEL_CLASS

    class MMCM_STATUS_CLASS extends register_base;
      field_base MMCM_LOCKED_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.MMCM_LOCKED_F = new("MMCM_LOCKED", 0, 0, RO, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: MMCM_STATUS_CLASS

    class DRP_CNTRL_CLASS extends register_base;
      field_base DRP_RWN_F;
      field_base DRP_ADDRESS_F;
      field_base DRP_WDATA_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.DRP_RWN_F = new("DRP_RWN", 28, 28, RW, 'h0, this);
        this.DRP_ADDRESS_F = new("DRP_ADDRESS", 27, 16, RW, 'h0, this);
        this.DRP_WDATA_F = new("DRP_WDATA", 15, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: DRP_CNTRL_CLASS

    class DRP_STATUS_CLASS extends register_base;
      field_base MMCM_LOCKED_F;
      field_base DRP_STATUS_F;
      field_base DRP_RDATA_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.MMCM_LOCKED_F = new("MMCM_LOCKED", 17, 17, RO, 'h0, this);
        this.DRP_STATUS_F = new("DRP_STATUS", 16, 16, RO, 'h0, this);
        this.DRP_RDATA_F = new("DRP_RDATA", 15, 0, RO, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: DRP_STATUS_CLASS

    class FPGA_VOLTAGE_CLASS extends register_base;
      field_base FPGA_VOLTAGE_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.FPGA_VOLTAGE_F = new("FPGA_VOLTAGE", 15, 0, RO, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: FPGA_VOLTAGE_CLASS

    RSTN_CLASS RSTN_R;
    CLK_SEL_CLASS CLK_SEL_R;
    MMCM_STATUS_CLASS MMCM_STATUS_R;
    DRP_CNTRL_CLASS DRP_CNTRL_R;
    DRP_STATUS_CLASS DRP_STATUS_R;
    FPGA_VOLTAGE_CLASS FPGA_VOLTAGE_R;

    function new(
      input string name,
      input int address,
      input adi_api parent = null);

      super.new(name, address, parent);

      this.RSTN_R = new("RSTN", 'h40, this);
      this.CLK_SEL_R = new("CLK_SEL", 'h44, this);
      this.MMCM_STATUS_R = new("MMCM_STATUS", 'h5c, this);
      this.DRP_CNTRL_R = new("DRP_CNTRL", 'h70, this);
      this.DRP_STATUS_R = new("DRP_STATUS", 'h74, this);
      this.FPGA_VOLTAGE_R = new("FPGA_VOLTAGE", 'h140, this);

      this.info($sformatf("Initialized"), ADI_VERBOSITY_HIGH);
    endfunction: new

  endclass: adi_regmap_clkgen

endpackage: adi_regmap_clkgen_pkg
