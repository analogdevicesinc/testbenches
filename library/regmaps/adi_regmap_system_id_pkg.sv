// ***************************************************************************
// ***************************************************************************
// Copyright 2014 - 2024 (c) Analog Devices, Inc. All rights reserved.
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

package adi_regmap_system_id_pkg;
  import regmap_pkg::*;

  class adi_regmap_system_id #(int ID);

    /* System ID (axi_system_id) */
    class VERSION_CLASS extends register_base;
      field_base VERSION_MAJOR_F;
      field_base VERSION_MINOR_F;
      field_base VERSION_PATCH_F;

      function new(
        input string name,
        input int address);

        super.new(name, address);
        this.VERSION_MAJOR_F = new("VERSION_MAJOR", 31, 16, RO, 'h1, this);
        this.VERSION_MINOR_F = new("VERSION_MINOR", 15, 8, RO, 'h0, this);
        this.VERSION_PATCH_F = new("VERSION_PATCH", 7, 0, RO, 'h61, this);
      endfunction: new
    endclass

    class PERIPHERAL_ID_CLASS #(int ID) extends register_base;
      field_base PERIPHERAL_ID_F;

      function new(
        input string name,
        input int address);

        super.new(name, address);
        this.PERIPHERAL_ID_F = new("PERIPHERAL_ID", 31, 0, RO, ID, this);
      endfunction: new
    endclass

    class SCRATCH_CLASS extends register_base;
      field_base SCRATCH_F;

      function new(
        input string name,
        input int address);

        super.new(name, address);
        this.SCRATCH_F = new("SCRATCH", 31, 0, RW, 'h0, this);
      endfunction: new
    endclass

    class IDENTIFICATION_CLASS extends register_base;
      field_base IDENTIFICATION_F;

      function new(
        input string name,
        input int address);

        super.new(name, address);
        this.IDENTIFICATION_F = new("IDENTIFICATION", 31, 0, RO, 'h53594944, this);
      endfunction: new
    endclass

    class SYSROM_START_CLASS extends register_base;
      field_base SYSROM_START_F;

      function new(
        input string name,
        input int address);

        super.new(name, address);
        this.SYSROM_START_F = new("SYSROM_START", 31, 0, RO, 'hXXXXXXXX, this);
      endfunction: new
    endclass

    class PRROM_START_CLASS extends register_base;
      field_base SYSROM_START_F;

      function new(
        input string name,
        input int address);

        super.new(name, address);
        this.SYSROM_START_F = new("SYSROM_START", 31, 0, RO, 'hXXXXXXXX, this);
      endfunction: new
    endclass

    VERSION_CLASS VERSION_R;
    PERIPHERAL_ID_CLASS #(ID) PERIPHERAL_ID_R;
    SCRATCH_CLASS SCRATCH_R;
    IDENTIFICATION_CLASS IDENTIFICATION_R;
    SYSROM_START_CLASS SYSROM_START_R;
    PRROM_START_CLASS PRROM_START_R;

    function new();
      this.VERSION_R = new("VERSION", 'h0);
      this.PERIPHERAL_ID_R = new("PERIPHERAL_ID", 'h4);
      this.SCRATCH_R = new("SCRATCH", 'h8);
      this.IDENTIFICATION_R = new("IDENTIFICATION", 'hc);
      this.SYSROM_START_R = new("SYSROM_START", 'h800);
      this.PRROM_START_R = new("PRROM_START", 'h1000);
    endfunction: new;

  endclass;
endpackage
