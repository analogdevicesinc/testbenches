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

import test_harness_env_pkg::*;
import axi_vip_pkg::*;
import axi4stream_vip_pkg::*;
import logger_pkg::*;
import adi_regmap_pkg::*;

`define SELMAP       32'h7c00_0000

`define CORE_MAGIC   32'h0000_0000
`define SCRATCH      32'h0000_0004
`define RESET        32'h0000_0008
`define PROGRAM_B    32'h0000_000C
`define DEVICE_READY 32'h0000_0010
`define CSI_B        32'h0000_0014
`define DATA         32'h0000_0018
`define BYTE_CNT     32'h0000_001C
`define DONE         32'h0000_0020

program test_program;

  //instantiate the environment
  test_harness_env env;
  bit [31:0] val;

  initial begin
    //creating environment
    env = new(`TH.`SYS_CLK.inst.IF,
              `TH.`DMA_CLK.inst.IF,
              `TH.`DDR_CLK.inst.IF,
              `TH.`MNG_AXI.inst.IF,
              `TH.`DDR_AXI.inst.IF);

    #2ps;

    setLoggerVerbosity(6);
    env.start();

    #1us;

    //  -------------------------------------------------------
    //  Test start
    //  -------------------------------------------------------

    // Init test data
    // Test scratch
    env.mng.RegWrite32(`SELMAP + `SCRATCH, 32'd1234);
    env.mng.RegRead32(`SELMAP + `SCRATCH, val);
    if (val != 'd1234) begin
      `ERROR(("Expected 1234 at scratch register found %d", val));
    end

    // Reset
    env.mng.RegWrite32(`SELMAP + `RESET, 1'b0);
    env.mng.RegRead32(`SELMAP + `SCRATCH, val);
    if (val != 0) begin
      `ERROR(("Scratch should be 0 after reset but was: 0x%x", val));
    end

    // Simulate init_b coming from the Selmap slave
    `TB.init_b = 1'b0;
    #10us;
    `TB.init_b = 1'b1;
    #5us;
    env.mng.RegRead32(`SELMAP + `DEVICE_READY, val);
    if (val != 'd1) begin
      `ERROR(("Device is not ready!"));
    end

    // Writing
    env.mng.RegWrite32(`SELMAP + `CSI_B, 0);
    for (int i = 1; i <= 512; i=i+1) begin
      env.mng.RegWrite32(`SELMAP + `DATA, i % 512);
      #1ns;
      env.mng.RegRead32(`SELMAP + `BYTE_CNT, val);
      if (val != i) begin
        `ERROR(("Invalid byte count: %d should be %d", val, i));
      end
    end

    // Simulate programming done
    `TB.done = 1'b1;
    #10ns;
    env.mng.RegRead32(`SELMAP + `DONE, val);
    if (val != 1'b1) begin
      `ERROR(("Done should be 1"));
    end

    `INFO(("Testbench done"));

  end
endprogram
