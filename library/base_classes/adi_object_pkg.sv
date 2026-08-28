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

package adi_object_pkg;

  import logger_pkg::*;

  class adi_object;
    protected string name;

    function new(input string name);
      this.name = name;
    endfunction

    virtual function adi_object clone();
      adi_object object;
      object = new(.name(this.name));
      this.copy(object);
      return object;
    endfunction: clone

    virtual function string convert2string();
      string str;
      str = {"ADI Object\n",
        $sformatf("name: %s\n", this.name)};
      return(str);
    endfunction: convert2string

    function void copy(input adi_object object);
      this.do_copy(.object(object));
    endfunction: copy

    virtual function void do_copy(input adi_object object);
      return;
    endfunction: do_copy

    function void print();
      `INFO(("%s", this.do_print()), ADI_VERBOSITY_NONE);
    endfunction: print

    function string sprint();
      return this.do_print();
    endfunction: sprint

    virtual function string do_print();
      return this.convert2string();
    endfunction: do_print

    function bit compare(input adi_object object);
      return this.do_compare(.object(object));
    endfunction: compare

    virtual function bit do_compare(input adi_object object);
      return 1;
    endfunction: do_compare
  endclass: adi_object

endpackage: adi_object_pkg
