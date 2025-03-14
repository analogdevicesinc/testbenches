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

interface io_vip_if #(
  int MODE = 1, // 1 - master, 0 - slave, 2 - passthrough
      WIDTH = 1, // bitwidth
      ASYNC = 0 // clock synchronous
) (
  input bit clk
);

  import io_vip_if_base_pkg::*;

  wire [WIDTH-1:0] IO;

  logic [WIDTH-1:0] io = {WIDTH{1'b0}};

  logic intf_is_master = 0;
  logic intf_is_slave = 0;
  logic edge_case = 1'b1;

  function void set_intf_master();
    intf_is_master = 1;
    intf_is_slave = 0;
  endfunction: set_intf_master

  function void set_intf_slave();
    intf_is_master = 0;
    intf_is_slave = 1;
  endfunction: set_intf_slave

  function void set_intf_monitor();
    intf_is_master = 0;
    intf_is_slave = 0;
  endfunction: set_intf_monitor

  assign IO = (intf_is_master) ? io : {WIDTH{1'bz}};

  class io_vip_if_class #(int WIDTH = 1) extends io_vip_if_base;

    function new();
    endfunction

    virtual function void set_io(logic [1023:0] o);
      if (intf_is_master) begin
        io <= o[WIDTH-1:0];
      end else begin
        $fatal(0, "Supported only in runtime master mode");
      end
    endfunction: set_io

    virtual function logic [1023:0] get_io();
      if (intf_is_slave) begin
        if (ASYNC == 1) begin
          get_io = {{1024-WIDTH{1'b0}}, IO};
        end else begin
          if (edge_case) begin
            get_io = {{1024-WIDTH{1'b0}}, cb_p.IO};
          end else begin
            get_io = {{1024-WIDTH{1'b0}}, cb_n.IO};
          end
        end
      end else begin
        $fatal(0, "Supported only in runtime slave mode");
      end
    endfunction: get_io

    virtual task wait_io_change();
      if (ASYNC == 1) begin
        @(IO);
      end else begin
        if (edge_case) begin
          @(cb_p.IO);
        end else begin
          @(cb_n.IO);
        end
      end
    endtask: wait_io_change

    virtual task wait_posedge_clk();
      if (ASYNC == 1) begin
        $fatal(0, "Unsupported in async mode");
      end
      @(cb_p);
    endtask: wait_posedge_clk

    virtual task wait_negedge_clk();
      if (ASYNC == 1) begin
        $fatal(0, "Unsupported in async mode");
      end
      @(cb_n);
    endtask: wait_negedge_clk

    virtual function int get_width();
      get_width = WIDTH;
    endfunction: get_width

    virtual function void set_positive_edge();
      if (ASYNC == 1) begin
        $fatal(0, "Unsupported in async mode");
      end
      edge_case = 1'b1;
    endfunction: set_positive_edge

    virtual function void set_negative_edge();
      if (ASYNC == 1) begin
        $fatal(0, "Unsupported in async mode");
      end
      edge_case = 1'b0;
    endfunction: set_negative_edge

  endclass: io_vip_if_class

  io_vip_if_class #(WIDTH) vif = new();

  clocking cb_p @(posedge clk);
    default input #1step output #1ps;
    inout IO;
  endclocking : cb_p

  clocking cb_n @(negedge clk);
    default input #1step output #1ps;
    inout IO;
  endclocking : cb_n

endinterface: io_vip_if
