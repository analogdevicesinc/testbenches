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
/* Jan 28 13:30:16 2025 v0.3.55 */

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

    IO_ENBn_CLASS IO_ENB0_R;
    IO_ENBn_CLASS IO_ENB1_R;
    IO_ENBn_CLASS IO_ENB2_R;
    IO_ENBn_CLASS IO_ENB3_R;
    IO_ENBn_CLASS IO_ENB4_R;
    IO_ENBn_CLASS IO_ENB5_R;
    IO_ENBn_CLASS IO_ENB6_R;
    IO_ENBn_CLASS IO_ENB7_R;
    IO_ENBn_CLASS IO_ENB8_R;
    IO_ENBn_CLASS IO_ENB9_R;
    IO_ENBn_CLASS IO_ENB10_R;
    IO_ENBn_CLASS IO_ENB11_R;
    IO_ENBn_CLASS IO_ENB12_R;
    IO_ENBn_CLASS IO_ENB13_R;
    IO_ENBn_CLASS IO_ENB14_R;
    IO_ENBn_CLASS IO_ENB15_R;
    IO_OUTn_CLASS IO_OUT0_R;
    IO_OUTn_CLASS IO_OUT1_R;
    IO_OUTn_CLASS IO_OUT2_R;
    IO_OUTn_CLASS IO_OUT3_R;
    IO_OUTn_CLASS IO_OUT4_R;
    IO_OUTn_CLASS IO_OUT5_R;
    IO_OUTn_CLASS IO_OUT6_R;
    IO_OUTn_CLASS IO_OUT7_R;
    IO_OUTn_CLASS IO_OUT8_R;
    IO_OUTn_CLASS IO_OUT9_R;
    IO_OUTn_CLASS IO_OUT10_R;
    IO_OUTn_CLASS IO_OUT11_R;
    IO_OUTn_CLASS IO_OUT12_R;
    IO_OUTn_CLASS IO_OUT13_R;
    IO_OUTn_CLASS IO_OUT14_R;
    IO_OUTn_CLASS IO_OUT15_R;
    IO_INn_CLASS IO_IN0_R;
    IO_INn_CLASS IO_IN1_R;
    IO_INn_CLASS IO_IN2_R;
    IO_INn_CLASS IO_IN3_R;
    IO_INn_CLASS IO_IN4_R;
    IO_INn_CLASS IO_IN5_R;
    IO_INn_CLASS IO_IN6_R;
    IO_INn_CLASS IO_IN7_R;
    IO_INn_CLASS IO_IN8_R;
    IO_INn_CLASS IO_IN9_R;
    IO_INn_CLASS IO_IN10_R;
    IO_INn_CLASS IO_IN11_R;
    IO_INn_CLASS IO_IN12_R;
    IO_INn_CLASS IO_IN13_R;
    IO_INn_CLASS IO_IN14_R;
    IO_INn_CLASS IO_IN15_R;
    CM_RESETn_CLASS CM_RESET0_R;
    CM_RESETn_CLASS CM_RESET1_R;
    CM_RESETn_CLASS CM_RESET2_R;
    CM_RESETn_CLASS CM_RESET3_R;
    CM_RESETn_CLASS CM_RESET4_R;
    CM_RESETn_CLASS CM_RESET5_R;
    CM_RESETn_CLASS CM_RESET6_R;
    CM_RESETn_CLASS CM_RESET7_R;
    CM_RESETn_CLASS CM_RESET8_R;
    CM_RESETn_CLASS CM_RESET9_R;
    CM_RESETn_CLASS CM_RESET10_R;
    CM_RESETn_CLASS CM_RESET11_R;
    CM_RESETn_CLASS CM_RESET12_R;
    CM_RESETn_CLASS CM_RESET13_R;
    CM_RESETn_CLASS CM_RESET14_R;
    CM_RESETn_CLASS CM_RESET15_R;
    CM_COUNTn_CLASS CM_COUNT0_R;
    CM_COUNTn_CLASS CM_COUNT1_R;
    CM_COUNTn_CLASS CM_COUNT2_R;
    CM_COUNTn_CLASS CM_COUNT3_R;
    CM_COUNTn_CLASS CM_COUNT4_R;
    CM_COUNTn_CLASS CM_COUNT5_R;
    CM_COUNTn_CLASS CM_COUNT6_R;
    CM_COUNTn_CLASS CM_COUNT7_R;
    CM_COUNTn_CLASS CM_COUNT8_R;
    CM_COUNTn_CLASS CM_COUNT9_R;
    CM_COUNTn_CLASS CM_COUNT10_R;
    CM_COUNTn_CLASS CM_COUNT11_R;
    CM_COUNTn_CLASS CM_COUNT12_R;
    CM_COUNTn_CLASS CM_COUNT13_R;
    CM_COUNTn_CLASS CM_COUNT14_R;
    CM_COUNTn_CLASS CM_COUNT15_R;

    function new(
      input string name,
      input int address,
      input adi_api parent = null);

      super.new(name, address, parent);

      this.IO_ENB0_R = new("IO_ENB0", 'h400, this);
      this.IO_ENB1_R = new("IO_ENB1", 'h458, this);
      this.IO_ENB2_R = new("IO_ENB2", 'h4b0, this);
      this.IO_ENB3_R = new("IO_ENB3", 'h508, this);
      this.IO_ENB4_R = new("IO_ENB4", 'h560, this);
      this.IO_ENB5_R = new("IO_ENB5", 'h5b8, this);
      this.IO_ENB6_R = new("IO_ENB6", 'h610, this);
      this.IO_ENB7_R = new("IO_ENB7", 'h668, this);
      this.IO_ENB8_R = new("IO_ENB8", 'h6c0, this);
      this.IO_ENB9_R = new("IO_ENB9", 'h718, this);
      this.IO_ENB10_R = new("IO_ENB10", 'h770, this);
      this.IO_ENB11_R = new("IO_ENB11", 'h7c8, this);
      this.IO_ENB12_R = new("IO_ENB12", 'h820, this);
      this.IO_ENB13_R = new("IO_ENB13", 'h878, this);
      this.IO_ENB14_R = new("IO_ENB14", 'h8d0, this);
      this.IO_ENB15_R = new("IO_ENB15", 'h928, this);
      this.IO_OUT0_R = new("IO_OUT0", 'h404, this);
      this.IO_OUT1_R = new("IO_OUT1", 'h45c, this);
      this.IO_OUT2_R = new("IO_OUT2", 'h4b4, this);
      this.IO_OUT3_R = new("IO_OUT3", 'h50c, this);
      this.IO_OUT4_R = new("IO_OUT4", 'h564, this);
      this.IO_OUT5_R = new("IO_OUT5", 'h5bc, this);
      this.IO_OUT6_R = new("IO_OUT6", 'h614, this);
      this.IO_OUT7_R = new("IO_OUT7", 'h66c, this);
      this.IO_OUT8_R = new("IO_OUT8", 'h6c4, this);
      this.IO_OUT9_R = new("IO_OUT9", 'h71c, this);
      this.IO_OUT10_R = new("IO_OUT10", 'h774, this);
      this.IO_OUT11_R = new("IO_OUT11", 'h7cc, this);
      this.IO_OUT12_R = new("IO_OUT12", 'h824, this);
      this.IO_OUT13_R = new("IO_OUT13", 'h87c, this);
      this.IO_OUT14_R = new("IO_OUT14", 'h8d4, this);
      this.IO_OUT15_R = new("IO_OUT15", 'h92c, this);
      this.IO_IN0_R = new("IO_IN0", 'h408, this);
      this.IO_IN1_R = new("IO_IN1", 'h460, this);
      this.IO_IN2_R = new("IO_IN2", 'h4b8, this);
      this.IO_IN3_R = new("IO_IN3", 'h510, this);
      this.IO_IN4_R = new("IO_IN4", 'h568, this);
      this.IO_IN5_R = new("IO_IN5", 'h5c0, this);
      this.IO_IN6_R = new("IO_IN6", 'h618, this);
      this.IO_IN7_R = new("IO_IN7", 'h670, this);
      this.IO_IN8_R = new("IO_IN8", 'h6c8, this);
      this.IO_IN9_R = new("IO_IN9", 'h720, this);
      this.IO_IN10_R = new("IO_IN10", 'h778, this);
      this.IO_IN11_R = new("IO_IN11", 'h7d0, this);
      this.IO_IN12_R = new("IO_IN12", 'h828, this);
      this.IO_IN13_R = new("IO_IN13", 'h880, this);
      this.IO_IN14_R = new("IO_IN14", 'h8d8, this);
      this.IO_IN15_R = new("IO_IN15", 'h930, this);
      this.CM_RESET0_R = new("CM_RESET0", 'h800, this);
      this.CM_RESET1_R = new("CM_RESET1", 'h858, this);
      this.CM_RESET2_R = new("CM_RESET2", 'h8b0, this);
      this.CM_RESET3_R = new("CM_RESET3", 'h908, this);
      this.CM_RESET4_R = new("CM_RESET4", 'h960, this);
      this.CM_RESET5_R = new("CM_RESET5", 'h9b8, this);
      this.CM_RESET6_R = new("CM_RESET6", 'ha10, this);
      this.CM_RESET7_R = new("CM_RESET7", 'ha68, this);
      this.CM_RESET8_R = new("CM_RESET8", 'hac0, this);
      this.CM_RESET9_R = new("CM_RESET9", 'hb18, this);
      this.CM_RESET10_R = new("CM_RESET10", 'hb70, this);
      this.CM_RESET11_R = new("CM_RESET11", 'hbc8, this);
      this.CM_RESET12_R = new("CM_RESET12", 'hc20, this);
      this.CM_RESET13_R = new("CM_RESET13", 'hc78, this);
      this.CM_RESET14_R = new("CM_RESET14", 'hcd0, this);
      this.CM_RESET15_R = new("CM_RESET15", 'hd28, this);
      this.CM_COUNT0_R = new("CM_COUNT0", 'h808, this);
      this.CM_COUNT1_R = new("CM_COUNT1", 'h860, this);
      this.CM_COUNT2_R = new("CM_COUNT2", 'h8b8, this);
      this.CM_COUNT3_R = new("CM_COUNT3", 'h910, this);
      this.CM_COUNT4_R = new("CM_COUNT4", 'h968, this);
      this.CM_COUNT5_R = new("CM_COUNT5", 'h9c0, this);
      this.CM_COUNT6_R = new("CM_COUNT6", 'ha18, this);
      this.CM_COUNT7_R = new("CM_COUNT7", 'ha70, this);
      this.CM_COUNT8_R = new("CM_COUNT8", 'hac8, this);
      this.CM_COUNT9_R = new("CM_COUNT9", 'hb20, this);
      this.CM_COUNT10_R = new("CM_COUNT10", 'hb78, this);
      this.CM_COUNT11_R = new("CM_COUNT11", 'hbd0, this);
      this.CM_COUNT12_R = new("CM_COUNT12", 'hc28, this);
      this.CM_COUNT13_R = new("CM_COUNT13", 'hc80, this);
      this.CM_COUNT14_R = new("CM_COUNT14", 'hcd8, this);
      this.CM_COUNT15_R = new("CM_COUNT15", 'hd30, this);

      this.info($sformatf("Initialized"), ADI_VERBOSITY_HIGH);
    endfunction: new

  endclass: adi_regmap_gpreg

endpackage: adi_regmap_gpreg_pkg
