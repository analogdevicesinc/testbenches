// ***************************************************************************
// ***************************************************************************
// Copyright 2021 (c) Analog Devices, Inc. All rights reserved.
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
import data_offload_pkg::*;

//=============================================================================
// Register Maps
//=============================================================================

`define TRANSFER_LENGTH 32'h200

module test_program(
  output  reg       init_req = 1'b0,
  output  reg       sync_ext = 1'b0
);

  //declaring environment instance
  environment                       env;
  xil_axi4stream_ready_gen_policy_t dac_mode;
  
  data_offload                      dut;
  
  initial begin
    //creating environment
    env = new(`TH.`MNG_AXI.inst.IF,
              `TH.`SRC_AXIS.inst.IF,
              `TH.`DST_AXIS.inst.IF
             );
             
    dut = new(env.mng, `DOFF_BA);

    //=========================================================================
    // Setup generator/monitor stubs
    //=========================================================================

    // ADC stub
    env.src_axis_seq.configure(1, 0);
    for (int i = 0; i < 20; i++)
      env.src_axis_seq.update(`TRANSFER_LENGTH, 1, 0);

    env.src_axis_seq.enable();

    // DAC stub
    env.dst_axis_seq.set_mode(XIL_AXI4STREAM_READY_GEN_NO_BACKPRESSURE);
    // env.dst_axis_seq.set_mode(XIL_AXI4STREAM_READY_GEN_OSC);
    env.dst_axis_seq.set_high_time(1);
    env.dst_axis_seq.set_low_time(3);

    //=========================================================================

    setLoggerVerbosity(250);

    start_clocks;
    sys_reset;

    #1
    env.start();

    #100
    `INFO(("Bring up IP from reset."));
    systemBringUp;

    // Start the ADC/DAC stubs
    `INFO(("Call the run() ..."));
    env.run();
    
    init_req <= 1'b1;
    
    #10000
    // env.src_axis_seq.update(`TRANSFER_LENGTH, 1, 0);
    #400

    #30000
    env.stop();

    stop_clocks;

    `INFO(("Test bench done!"));
    $finish();

  end

  task start_clocks;

    #1
    `TH.`SRC_CLK.inst.IF.start_clock;
    #1
    `TH.`DST_CLK.inst.IF.start_clock;
    #1
    `TH.`SYS_CLK.inst.IF.start_clock;
  endtask

  task stop_clocks;

    `TH.`SRC_CLK.inst.IF.stop_clock;
    `TH.`DST_CLK.inst.IF.stop_clock;
    `TH.`SYS_CLK.inst.IF.stop_clock;
    
  endtask

  task sys_reset;

    `TH.`SRC_RST.inst.IF.assert_reset;
    `TH.`DST_RST.inst.IF.assert_reset;
    `TH.`SYS_RST.inst.IF.assert_reset;
    
    #500
    `TH.`SRC_RST.inst.IF.deassert_reset;
    `TH.`DST_RST.inst.IF.deassert_reset;
    `TH.`SYS_RST.inst.IF.deassert_reset;

  endtask

  task systemBringUp;

    // bring up the Data Offload instances from reset
    `INFO(("Bring up TX Data Offload"));
    dut.set_oneshot(1'b1);
    // dut.set_transfer_length(`TRANSFER_LENGTH);
    
    dut.set_resetn(1'b1);
    
  endtask

endmodule
