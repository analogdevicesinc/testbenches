// ***************************************************************************
// ***************************************************************************
// Copyright 2024 (c) Analog Devices, Inc. All rights reserved.
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

import axi_vip_pkg::*;
import axi4stream_vip_pkg::*;
import logger_pkg::*;
import environment_pkg::*;
import filter_pkg::*;

program test_program;

  // Declare the class instances
  environment env;

  // Process variables
  process current_process;
  string current_process_random_state;

  logic [7:0] packet_to_filter[8];
  filter_tree_class ft;
  

  initial begin

    current_process = process::self();
    current_process_random_state = current_process.get_randstate();
    `INFO(("Randomization state: %s", current_process_random_state));

    setLoggerVerbosity(250);

    // Create environment
    env = new(`TH.`SYS_CLK.inst.IF,
              `TH.`DMA_CLK.inst.IF,
              `TH.`DDR_CLK.inst.IF,
              `TH.`SYS_RST.inst.IF,
              `TH.`MNG_AXI.inst.IF,
              `TH.`DDR_AXI.inst.IF
             );

    env.start();
    env.sys_reset();

    /* Add other configurations if necessary before calling run */

    env.run();

    /* Add stimulus tasks */

    packet_to_filter[0] = 8'h08;
    packet_to_filter[1] = 8'h19;
    packet_to_filter[2] = 8'h2A;
    packet_to_filter[3] = 8'h3B;
    packet_to_filter[4] = 8'h4C;
    packet_to_filter[5] = 8'h5D;
    packet_to_filter[6] = 8'h6E;
    packet_to_filter[7] = 8'h7F;
  
    ft = new(
      .filter_type(0),
      .nr_of_filters(1),
      .nr_of_filter_trees(1));
    ft.add_filter(
      .filter_nr(0),
      .position(0),
      .value(8'hX8));
    ft.add_filter_tree(
      .filter_tree_nr(0),
      .filter_type(1),
      .nr_of_filters(2),
      .nr_of_filter_trees(0));
    ft.ft[0].add_filter(
      .filter_nr(0),
      .position(0),
      .value(8'hX9));
    ft.ft[0].add_filter(
      .filter_nr(1),
      .position(7),
      .value(8'b0111111X));

    ft.apply_filter(packet_to_filter);
    `INFO(("Filter result: %d", ft.result));
        
    env.stop();
    
    `INFO(("Test bench done!"));
    $finish();

  end

endprogram
