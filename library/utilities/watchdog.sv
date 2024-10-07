// ***************************************************************************
// ***************************************************************************
// Copyright 2014 - 2021 (c) Analog Devices, Inc. All rights reserved.
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
//      https://github.com/analogdevicesinc/hdl/blob/master/LICENSE_ADIBSD
//      This will allow to generate bit files and not release the source code,
//      as long as it attaches to an ADI device.
//
// ***************************************************************************
// ***************************************************************************
`include "utils.svh"

package watchdog_pkg;

  import logger_pkg::*;

  class watchdog;
    
    protected event stop_event;
    protected bit [31:0] timer;
    protected string message;

    
    function new(
      bit [31:0] timer, 
      string message);

      this.timer = timer;
      this.message = message;
    endfunction

    function void update_message(string message);
      this.message = message;
    endfunction: update_message

    function void update_timer(bit [31:0] timer);
      this.timer = timer;
    endfunction: update_timer

    task reset();
      this.stop();
      #1step;
      this.start();
    endtask: reset

    task stop();
      ->>this.stop_event;
    endtask: stop

    task start();
      fork
        begin
          fork
            begin
              #(this.timer*1ns);
              `ERROR(("Watchdog timer timed out! %s", this.message));
            end
            @this.stop_event;
          join_any
          disable fork;
          `INFOV(("Watchdog timer reset. %s", this.message), 100);
        end
      join_none
    endtask: start

  endclass

endpackage
