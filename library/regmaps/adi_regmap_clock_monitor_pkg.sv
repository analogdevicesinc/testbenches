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

package adi_regmap_clock_monitor_pkg;
  import logger_pkg::*;
  import adi_api_pkg::*;

  class adi_regmap_clock_monitor extends adi_regmap;

    /* Clock Monitor (axi_clock_monitor) */
    class PCORE_VERSION_CLASS extends register_base;
      field_base PCORE_VERSION_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.PCORE_VERSION_F = new("PCORE_VERSION", 31, 0, RO, 'h1, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: PCORE_VERSION_CLASS

    class ID_CLASS extends register_base;
      field_base ID_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.ID_F = new("ID", 31, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: ID_CLASS

    class NUM_OF_CLOCKS_CLASS extends register_base;
      field_base NUM_OF_CLOCKS_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.NUM_OF_CLOCKS_F = new("NUM_OF_CLOCKS", 31, 0, RW, 'h8, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: NUM_OF_CLOCKS_CLASS

    class OUT_RESET_CLASS extends register_base;
      field_base RESET_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.RESET_F = new("RESET", 0, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: OUT_RESET_CLASS

    class CLOCK_n_CLASS extends register_base;
      field_base CLOCK_n_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.CLOCK_n_F = new("CLOCK_n", 31, 0, RO, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: CLOCK_n_CLASS

    PCORE_VERSION_CLASS PCORE_VERSION_R;
    ID_CLASS ID_R;
    NUM_OF_CLOCKS_CLASS NUM_OF_CLOCKS_R;
    OUT_RESET_CLASS OUT_RESET_R;
    CLOCK_n_CLASS CLOCK_n_R [15:0];

    function new(
      input string name,
      input int address,
      input adi_api parent = null);

      super.new(name, address, parent);

      this.PCORE_VERSION_R = new("PCORE_VERSION", 'h0, this);
      this.ID_R = new("ID", 'h4, this);
      this.NUM_OF_CLOCKS_R = new("NUM_OF_CLOCKS", 'hc, this);
      this.OUT_RESET_R = new("OUT_RESET", 'h10, this);
      for (int i=0; i<16; i++) begin
        this.CLOCK_n_R[i] = new($sformatf("CLOCK_%0d", i), 'h40 + i * 4, this);
      end

      this.info($sformatf("Initialized"), ADI_VERBOSITY_HIGH);
    endfunction: new

  endclass: adi_regmap_clock_monitor

endpackage: adi_regmap_clock_monitor_pkg
