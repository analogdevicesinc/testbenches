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

package adi_regmap_jesd_tpl_pkg;
  import logger_pkg::*;
  import adi_api_pkg::*;

  class adi_regmap_jesd_tpl extends adi_regmap;

    /* JESD TPL (up_tpl_common) */
    class TPL_CNTRL_CLASS extends register_base;
      field_base PROFILE_SEL_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.PROFILE_SEL_F = new("PROFILE_SEL", 3, 0, RW, 'hXXXXXXXX, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: TPL_CNTRL_CLASS

    class TPL_STATUS_CLASS extends register_base;
      field_base PROFILE_NUM_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.PROFILE_NUM_F = new("PROFILE_NUM", 3, 0, RO, 'hXXXXXXXX, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: TPL_STATUS_CLASS

    class TPL_DESCRIPTORn_1_CLASS extends register_base;
      field_base JESD_F_F;
      field_base JESD_S_F;
      field_base JESD_L_F;
      field_base JESD_M_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.JESD_F_F = new("JESD_F", 31, 24, RO, 'hXXXXXXXX, this);
        this.JESD_S_F = new("JESD_S", 23, 16, RO, 'hXXXXXXXX, this);
        this.JESD_L_F = new("JESD_L", 15, 8, RO, 'hXXXXXXXX, this);
        this.JESD_M_F = new("JESD_M", 7, 0, RO, 'hXXXXXXXX, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: TPL_DESCRIPTORn_1_CLASS

    class TPL_DESCRIPTORn_2_CLASS extends register_base;
      field_base JESD_N_F;
      field_base JESD_NP_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.JESD_N_F = new("JESD_N", 7, 0, RO, 'hXXXXXXXX, this);
        this.JESD_NP_F = new("JESD_NP", 15, 8, RO, 'hXXXXXXXX, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: TPL_DESCRIPTORn_2_CLASS

    TPL_CNTRL_CLASS TPL_CNTRL_R;
    TPL_STATUS_CLASS TPL_STATUS_R;
    TPL_DESCRIPTORn_1_CLASS TPL_DESCRIPTORn_1_R [2:0];
    TPL_DESCRIPTORn_2_CLASS TPL_DESCRIPTORn_2_R [2:0];

    function new(
      input string name,
      input int address,
      input adi_api parent = null);

      super.new(name, address, parent);

      this.TPL_CNTRL_R = new("TPL_CNTRL", 'h200, this);
      this.TPL_STATUS_R = new("TPL_STATUS", 'h204, this);
      for (int i=0; i<3; i++) begin
        this.TPL_DESCRIPTORn_1_R[i] = new($sformatf("TPL_DESCRIPTOR%0d_1", i), 'h240 + i * 4, this);
      end
      for (int i=0; i<3; i++) begin
        this.TPL_DESCRIPTORn_2_R[i] = new($sformatf("TPL_DESCRIPTOR%0d_2", i), 'h244 + i * 4, this);
      end

      this.info($sformatf("Initialized"), ADI_VERBOSITY_HIGH);
    endfunction: new

  endclass: adi_regmap_jesd_tpl

endpackage: adi_regmap_jesd_tpl_pkg
