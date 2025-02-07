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
/* Feb 07 11:48:47 2025 v0.4.1 */

package adi_regmap_gpreg_pkg;
  import logger_pkg::*;
  import adi_api_pkg::*;

  class adi_regmap_gpreg extends adi_regmap;

    /* General Purpose Registers (axi_gpreg) */
    class IO_ENBn_CLASS extends register_base;
      field_base IO_ENB_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.IO_ENB_F = new("IO_ENB", 31, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: IO_ENBn_CLASS

    class IO_OUTn_CLASS extends register_base;
      field_base IO_OUT_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.IO_OUT_F = new("IO_OUT", 31, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: IO_OUTn_CLASS

    class IO_INn_CLASS extends register_base;
      field_base IO_IN_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.IO_IN_F = new("IO_IN", 31, 0, RO, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: IO_INn_CLASS

    class CM_RESETn_CLASS extends register_base;
      field_base CM_RESET_N_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.CM_RESET_N_F = new("CM_RESET_N", 0, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: CM_RESETn_CLASS

    class CM_COUNTn_CLASS extends register_base;
      field_base CM_CLK_COUNT_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.CM_CLK_COUNT_F = new("CM_CLK_COUNT", 31, 0, RO, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: CM_COUNTn_CLASS

    IO_ENBn_CLASS IO_ENBn_R [15:0];
    IO_OUTn_CLASS IO_OUTn_R [15:0];
    IO_INn_CLASS IO_INn_R [15:0];
    CM_RESETn_CLASS CM_RESETn_R [15:0];
    CM_COUNTn_CLASS CM_COUNTn_R [15:0];

    function new(
      input string name,
      input int address,
      input adi_api parent = null);

      super.new(name, address, parent);

      for (int i=0; i<16; i++) begin
        this.IO_ENBn_R[i] = new($sformatf("IO_ENB%0d", i), 'h400 + i * 4, this);
      end
      for (int i=0; i<16; i++) begin
        this.IO_OUTn_R[i] = new($sformatf("IO_OUT%0d", i), 'h404 + i * 4, this);
      end
      for (int i=0; i<16; i++) begin
        this.IO_INn_R[i] = new($sformatf("IO_IN%0d", i), 'h408 + i * 4, this);
      end
      for (int i=0; i<16; i++) begin
        this.CM_RESETn_R[i] = new($sformatf("CM_RESET%0d", i), 'h800 + i * 4, this);
      end
      for (int i=0; i<16; i++) begin
        this.CM_COUNTn_R[i] = new($sformatf("CM_COUNT%0d", i), 'h808 + i * 4, this);
      end

      this.info($sformatf("Initialized"), ADI_VERBOSITY_HIGH);
    endfunction: new

  endclass: adi_regmap_gpreg

endpackage: adi_regmap_gpreg_pkg
