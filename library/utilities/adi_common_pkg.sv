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

package adi_common_pkg;

  import logger_pkg::*;

  class adi_reporter;
    string name;
    adi_reporter parent;
    
    function new(
      input string name,
      input adi_reporter parent = null);

      this.name = name;
      this.parent = parent;
    endfunction

    function string get_path();
      if (this.parent == null)
        return this.name;
      else
        return $sformatf("%s.%s", this.parent.get_path(), this.name);
    endfunction: get_path

    function void info(
      input string message,
      input adi_verbosity_t verbosity);

      `INFO(("[%s] %s", this.get_path(), message), verbosity);
    endfunction: info

    function void warning(input string message);
      `WARNING(("[%s] %s", this.get_path(), message));
    endfunction: warning

    function void error(input string message);
      `ERROR(("[%s] %s", this.get_path(), message));
    endfunction: error

    function void fatal(input string message);
      `FATAL(("[%s] %s", this.get_path(), message));
    endfunction: fatal
  endclass: adi_reporter


  class adi_component extends adi_reporter;
    function new(
      input string name,
      input adi_component parent = null);

      super.new(name, parent);
    endfunction: new
  endclass: adi_component

endpackage: adi_common_pkg
