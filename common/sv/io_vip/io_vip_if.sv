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

interface io_vip_if #(
	int MODE = 0, // 1 - driver, 0 - monitor
  WIDTH = 1
) (
	input bit clk
);

  logic [WIDTH-1:0] io = 0;

  // Driver functions
  function void set_io(int o);
		if (MODE === 0)
			$fatal("Unsupported in monitor mode");
    else
      io <= o[WIDTH-1:0];
  endfunction

  // Wait and set
  task setw_io(int o, int w=1);
    repeat(w) wait_posedge_clk();
    set_io(o);
  endtask

  // Monitor functions
  function int get_io();
    return io;
  endfunction

  task wait_posedge_clk();
    @(cb);
  endtask

  default clocking cb @(posedge clk);
    default input #1step output #1ps;
    inout io;
  endclocking : cb

endinterface
