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

package adi_regmap_iodelay_pkg;
  import logger_pkg::*;
  import adi_api_pkg::*;

  class adi_regmap_iodelay extends adi_regmap;

    /* IO Delay Control (axi_ad*) */
    class DELAY_CONTROL_n_CLASS extends register_base;
      field_base DELAY_CONTROL_IO_n_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.DELAY_CONTROL_IO_n_F = new("DELAY_CONTROL_IO_n", 4, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: DELAY_CONTROL_n_CLASS

    DELAY_CONTROL_n_CLASS DELAY_CONTROL_n_R [15:0];

    function new(
      input string name,
      input int address,
      input adi_api parent = null);

      super.new(name, address, parent);

      for (int i=0; i<16; i++) begin
        this.DELAY_CONTROL_n_R[i] = new($sformatf("DELAY_CONTROL_%0d", i), 'h0 + 'h1 * i * 4, this);
      end

      this.info($sformatf("Initialized"), ADI_VERBOSITY_HIGH);
    endfunction: new

  endclass: adi_regmap_iodelay

endpackage: adi_regmap_iodelay_pkg
