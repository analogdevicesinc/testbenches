// ***************************************************************************
// ***************************************************************************
// Copyright (C) 2014 - 2024 Analog Devices, Inc. All rights reserved.
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
/* Nov 08 14:35:39 2024 v0.3.49 */

package adi_regmap_iodelay_pkg;
  import regmap_pkg::*;

  class adi_regmap_iodelay;

    /* IO Delay Control (axi_ad*) */
    class DELAY_CONTROL_n_CLASS extends register_base;
      field_base DELAY_CONTROL_IO_n_F;

      function new(
        input string name,
        input int address);

        super.new(name, address);
        this.DELAY_CONTROL_IO_n_F = new("DELAY_CONTROL_IO_n", 4, 0, RW, 'h0, this);
      endfunction: new
    endclass

    DELAY_CONTROL_n_CLASS DELAY_CONTROL_0_R;
    DELAY_CONTROL_n_CLASS DELAY_CONTROL_1_R;
    DELAY_CONTROL_n_CLASS DELAY_CONTROL_2_R;
    DELAY_CONTROL_n_CLASS DELAY_CONTROL_3_R;
    DELAY_CONTROL_n_CLASS DELAY_CONTROL_4_R;
    DELAY_CONTROL_n_CLASS DELAY_CONTROL_5_R;
    DELAY_CONTROL_n_CLASS DELAY_CONTROL_6_R;
    DELAY_CONTROL_n_CLASS DELAY_CONTROL_7_R;
    DELAY_CONTROL_n_CLASS DELAY_CONTROL_8_R;
    DELAY_CONTROL_n_CLASS DELAY_CONTROL_9_R;
    DELAY_CONTROL_n_CLASS DELAY_CONTROL_10_R;
    DELAY_CONTROL_n_CLASS DELAY_CONTROL_11_R;
    DELAY_CONTROL_n_CLASS DELAY_CONTROL_12_R;
    DELAY_CONTROL_n_CLASS DELAY_CONTROL_13_R;
    DELAY_CONTROL_n_CLASS DELAY_CONTROL_14_R;
    DELAY_CONTROL_n_CLASS DELAY_CONTROL_15_R;

    function new();
      this.DELAY_CONTROL_0_R = new("DELAY_CONTROL_0", 'h0);
      this.DELAY_CONTROL_1_R = new("DELAY_CONTROL_1", 'h4);
      this.DELAY_CONTROL_2_R = new("DELAY_CONTROL_2", 'h8);
      this.DELAY_CONTROL_3_R = new("DELAY_CONTROL_3", 'hc);
      this.DELAY_CONTROL_4_R = new("DELAY_CONTROL_4", 'h10);
      this.DELAY_CONTROL_5_R = new("DELAY_CONTROL_5", 'h14);
      this.DELAY_CONTROL_6_R = new("DELAY_CONTROL_6", 'h18);
      this.DELAY_CONTROL_7_R = new("DELAY_CONTROL_7", 'h1c);
      this.DELAY_CONTROL_8_R = new("DELAY_CONTROL_8", 'h20);
      this.DELAY_CONTROL_9_R = new("DELAY_CONTROL_9", 'h24);
      this.DELAY_CONTROL_10_R = new("DELAY_CONTROL_10", 'h28);
      this.DELAY_CONTROL_11_R = new("DELAY_CONTROL_11", 'h2c);
      this.DELAY_CONTROL_12_R = new("DELAY_CONTROL_12", 'h30);
      this.DELAY_CONTROL_13_R = new("DELAY_CONTROL_13", 'h34);
      this.DELAY_CONTROL_14_R = new("DELAY_CONTROL_14", 'h38);
      this.DELAY_CONTROL_15_R = new("DELAY_CONTROL_15", 'h3c);
    endfunction: new;

  endclass;
endpackage
