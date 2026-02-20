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
/* Feb 07 14:25:05 2025 v0.4.1 */

package adi_regmap_common_duo_pkg;
  import logger_pkg::*;
  import adi_api_pkg::*;
  import adi_regmap_common_pkg::*;

  class adi_regmap_common_duo extends adi_regmap;

    adi_regmap_common common1;
    adi_regmap_common common2;

    function new(
      input string name,
      input int address,
      input adi_component parent = null);

      adi_register register;

      super.new(name, address, parent);

      /* Common1 */
      this.common1 = new("Common1", 'h0000, this);

      /* Common2 */
      this.common2 = new("Common2", 'h1000, this);

      /* Base (common to all cores) */
      // VERSION
      register = this.add_register("VERSION", 'h0);
      register.add_field("VERSION", 31, 0, RO, 'h0);

      this.init_done();

      this.info($sformatf("Initialized"), ADI_VERBOSITY_HIGH);
    endfunction: new

  endclass: adi_regmap_common_duo

endpackage: adi_regmap_common_duo_pkg
