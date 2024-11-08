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

package adi_regmap_jesd_tpl_pkg;
  import regmap_pkg::*;

  class adi_regmap_jesd_tpl;

    /* JESD TPL (up_tpl_common) */
    class TPL_CNTRL_CLASS extends register_base;
      field_base PROFILE_SEL_F;

      function new(
        input string name,
        input int address);

        super.new(name, address);
        this.PROFILE_SEL_F = new("PROFILE_SEL", 3, 0, RW, 'hXXXXXXXX, this);
      endfunction: new
    endclass

    class TPL_STATUS_CLASS extends register_base;
      field_base PROFILE_NUM_F;

      function new(
        input string name,
        input int address);

        super.new(name, address);
        this.PROFILE_NUM_F = new("PROFILE_NUM", 3, 0, RO, 'hXXXXXXXX, this);
      endfunction: new
    endclass

    class TPL_DESCRIPTORn_1_CLASS extends register_base;
      field_base JESD_F_F;
      field_base JESD_S_F;
      field_base JESD_L_F;
      field_base JESD_M_F;

      function new(
        input string name,
        input int address);

        super.new(name, address);
        this.JESD_F_F = new("JESD_F", 31, 24, RO, 'hXXXXXXXX, this);
        this.JESD_S_F = new("JESD_S", 23, 16, RO, 'hXXXXXXXX, this);
        this.JESD_L_F = new("JESD_L", 15, 8, RO, 'hXXXXXXXX, this);
        this.JESD_M_F = new("JESD_M", 7, 0, RO, 'hXXXXXXXX, this);
      endfunction: new
    endclass

    class TPL_DESCRIPTORn_2_CLASS extends register_base;
      field_base JESD_N_F;
      field_base JESD_NP_F;

      function new(
        input string name,
        input int address);

        super.new(name, address);
        this.JESD_N_F = new("JESD_N", 7, 0, RO, 'hXXXXXXXX, this);
        this.JESD_NP_F = new("JESD_NP", 15, 8, RO, 'hXXXXXXXX, this);
      endfunction: new
    endclass

    TPL_CNTRL_CLASS TPL_CNTRL_R;
    TPL_STATUS_CLASS TPL_STATUS_R;
    TPL_DESCRIPTORn_1_CLASS TPL_DESCRIPTOR0_1_R;
    TPL_DESCRIPTORn_1_CLASS TPL_DESCRIPTOR1_1_R;
    TPL_DESCRIPTORn_1_CLASS TPL_DESCRIPTOR2_1_R;
    TPL_DESCRIPTORn_2_CLASS TPL_DESCRIPTOR0_2_R;
    TPL_DESCRIPTORn_2_CLASS TPL_DESCRIPTOR1_2_R;
    TPL_DESCRIPTORn_2_CLASS TPL_DESCRIPTOR2_2_R;

    function new();
      this.TPL_CNTRL_R = new("TPL_CNTRL", 'h200);
      this.TPL_STATUS_R = new("TPL_STATUS", 'h204);
      this.TPL_DESCRIPTOR0_1_R = new("TPL_DESCRIPTOR0_1", 'h240);
      this.TPL_DESCRIPTOR1_1_R = new("TPL_DESCRIPTOR1_1", 'h248);
      this.TPL_DESCRIPTOR2_1_R = new("TPL_DESCRIPTOR2_1", 'h250);
      this.TPL_DESCRIPTOR0_2_R = new("TPL_DESCRIPTOR0_2", 'h244);
      this.TPL_DESCRIPTOR1_2_R = new("TPL_DESCRIPTOR1_2", 'h24c);
      this.TPL_DESCRIPTOR2_2_R = new("TPL_DESCRIPTOR2_2", 'h254);
    endfunction: new;

  endclass;
endpackage
