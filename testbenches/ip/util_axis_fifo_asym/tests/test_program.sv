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
//
//
//
`include "utils.svh"

import axi_vip_pkg::*;
import axi4stream_vip_pkg::*;
import logger_pkg::*;
import environment_pkg::*;
import m_axis_sequencer_pkg::*;
import s_axis_sequencer_pkg::*;
import watchdog_pkg::*;

program test_program (
  clk_if input_clk_if,
  clk_if output_clk_if);

  // declare the class instances
  environment env;

  watchdog send_data_wd;

  initial begin

    // create environment
    env = new(`TH.`SYS_CLK.inst.IF,
              `TH.`DMA_CLK.inst.IF,
              `TH.`DDR_CLK.inst.IF,
              `TH.`SYS_RST.inst.IF,
              `TH.`MNG_AXI.inst.IF,
              `TH.`DDR_AXI.inst.IF,

              input_clk_if,
              output_clk_if,

              `TH.`INPUT_AXIS.inst.IF,
              `TH.`OUTPUT_AXIS.inst.IF
             );

    setLoggerVerbosity(5);
    
    env.start();
    env.sys_reset();

    env.configure();

    env.run();

    send_data_wd = new(500000, "Send data");

    send_data_wd.start();

    env.input_axis_seq.start();

    // stimulus
    repeat($urandom_range(5,13)) begin
      send_data_wd.reset();
      
      repeat($urandom_range(1,5))
        env.input_axis_seq.add_xfer_descriptor($urandom_range(1,1000), 1, 0);
      
      #($urandom_range(1,10)*1us);

      env.input_axis_seq.clear_descriptor_queue();

      #1us;

      env.scoreboard_inst.wait_until_complete();

      `INFOV(("Packet finished."), 5);
    end

    send_data_wd.stop();
        
    env.stop();
    
    `INFO(("Test bench done!"));
    $finish();

  end

endprogram
