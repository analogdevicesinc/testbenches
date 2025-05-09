// ***************************************************************************
// ***************************************************************************
// Copyright (C) 2025 Analog Devices, Inc. All rights reserved.
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

`include "utils.svh"

package adi_vip_pkg;

  import logger_pkg::*;
  import adi_common_pkg::*;
  import adi_environment_pkg::*;

  class adi_agent extends adi_component;
    function new(
      input string name,
      input adi_environment parent = null);

      super.new(name, parent);
    endfunction: new
  endclass: adi_agent


  class adi_driver extends adi_component;
    function new(
      input string name,
      input adi_agent parent = null);

      super.new(name, parent);
    endfunction: new
  endclass: adi_driver


  class adi_sequencer extends adi_component;
    function new(
      input string name,
      input adi_agent parent = null);

      super.new(name, parent);
    endfunction: new
  endclass: adi_sequencer


  class adi_monitor extends adi_component;
    function new(
      input string name,
      input adi_agent parent = null);

      super.new(name, parent);
    endfunction: new
  endclass: adi_monitor

endpackage: adi_vip_pkg
