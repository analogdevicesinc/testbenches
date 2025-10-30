// ***************************************************************************
// ***************************************************************************
// Copyright (C) 2024 - 2025 Analog Devices, Inc. All rights reserved.
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

module io_vip #(
  parameter MODE = 1, // 1 - master, 0 - slave, 2 - passthrough
  parameter WIDTH = 1, // bitwidth
  parameter ASYNC = 0 // clock synchronous
)(
  input  clk,
  input  [WIDTH-1:0] i,
  output [WIDTH-1:0] o
);

  wire intf_clk;

  logic master_mode = 0;
  logic slave_mode = 0;

  io_vip_if #(
    .MODE (MODE),
    .WIDTH (WIDTH),
    .ASYNC (ASYNC)
  ) IF (
    .clk(intf_clk));

  assign o = (master_mode) ? IF.IO : {WIDTH{1'b0}};
  
  assign IF.IO = (slave_mode) ? i : {WIDTH{1'bz}};

  assign intf_clk = (ASYNC == 0) ? clk : 1'b0;

  generate
    initial begin
      if (MODE == 1) begin
        master_mode = 1;
        IF.set_intf_master();
      end else if (MODE == 0) begin
        slave_mode = 1;
        IF.set_intf_slave();
      end else if (MODE == 2) begin
        IF.set_intf_monitor();
      end else begin
        $fatal(0, "This VIP mode does not exist");
      end
    end
  endgenerate

  function void set_master_mode();
    if (MODE == 2) begin
      master_mode = 1;
      IF.set_intf_master();
    end else begin
      $fatal(0, "VIP mode cannot be set, unless it is configured to passthrough mode");
    end
  endfunction: set_master_mode

  function void set_slave_mode();
    if (MODE == 2) begin
      slave_mode = 1;
      IF.set_intf_slave();
    end else begin
      $fatal(0, "VIP mode cannot be set, unless it is configured to passthrough mode");
    end
  endfunction: set_slave_mode

  function void set_passthrough_mode();
    if (MODE == 2) begin
      master_mode = 0;
      slave_mode = 0;
      IF.set_intf_monitor();
    end else begin
      $fatal(0, "VIP mode cannot be set, unless it is configured to passthrough mode");
    end
  endfunction: set_passthrough_mode

endmodule: io_vip
