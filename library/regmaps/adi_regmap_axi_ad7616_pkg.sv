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

package adi_regmap_axi_ad7616_pkg;
  import logger_pkg::*;
  import adi_api_pkg::*;

  class adi_regmap_axi_ad7616 extends adi_regmap;

    /* AXI AD7616 (axi_ad7616) */
    class VERSION_CLASS extends register_base;
      field_base VERSION_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.VERSION_F = new("VERSION", 31, 0, RO, 'h1002, this);

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

    class UP_CNTRL_CLASS extends register_base;
      field_base CNVST_EN_F;
      field_base RESETN_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.CNVST_EN_F = new("CNVST_EN", 1, 1, RW, 'h0, this);
        this.RESETN_F = new("RESETN", 0, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: UP_CNTRL_CLASS

    class UP_CONV_RATE_CLASS extends register_base;
      field_base UP_CONV_RATE_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.UP_CONV_RATE_F = new("UP_CONV_RATE", 31, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: UP_CONV_RATE_CLASS

    class UP_BURST_LENGTH_CLASS extends register_base;
      field_base UP_BURST_LENGTH_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.UP_BURST_LENGTH_F = new("UP_BURST_LENGTH", 4, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: UP_BURST_LENGTH_CLASS

    class UP_READ_DATA_CLASS extends register_base;
      field_base UP_READ_DATA_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.UP_READ_DATA_F = new("UP_READ_DATA", 31, 0, RO, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: UP_READ_DATA_CLASS

    class UP_WRITE_DATA_CLASS extends register_base;
      field_base UP_WRITE_DATA_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.UP_WRITE_DATA_F = new("UP_WRITE_DATA", 31, 0, WO, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: UP_WRITE_DATA_CLASS

    VERSION_CLASS VERSION_R;
    ID_CLASS ID_R;
    SCRATCH_CLASS SCRATCH_R;
    UP_CNTRL_CLASS UP_CNTRL_R;
    UP_CONV_RATE_CLASS UP_CONV_RATE_R;
    UP_BURST_LENGTH_CLASS UP_BURST_LENGTH_R;
    UP_READ_DATA_CLASS UP_READ_DATA_R;
    UP_WRITE_DATA_CLASS UP_WRITE_DATA_R;

    function new(
      input string name,
      input int address,
      input adi_api parent = null);

      super.new(name, address, parent);

      this.VERSION_R = new("VERSION", 'h400, this);
      this.ID_R = new("ID", 'h404, this);
      this.SCRATCH_R = new("SCRATCH", 'h408, this);
      this.UP_CNTRL_R = new("UP_CNTRL", 'h440, this);
      this.UP_CONV_RATE_R = new("UP_CONV_RATE", 'h444, this);
      this.UP_BURST_LENGTH_R = new("UP_BURST_LENGTH", 'h448, this);
      this.UP_READ_DATA_R = new("UP_READ_DATA", 'h44c, this);
      this.UP_WRITE_DATA_R = new("UP_WRITE_DATA", 'h450, this);

      this.info($sformatf("Initialized"), ADI_VERBOSITY_HIGH);
    endfunction: new

  endclass: adi_regmap_axi_ad7616

endpackage: adi_regmap_axi_ad7616_pkg
