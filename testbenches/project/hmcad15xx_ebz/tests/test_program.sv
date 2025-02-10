// ***************************************************************************
// ***************************************************************************
// Copyright 2014 - 2023 (c) Analog Devices, Inc. All rights reserved.
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
import adi_regmap_pkg::*;
import axi_vip_pkg::*;
import axi4stream_vip_pkg::*;
import logger_pkg::*;
import adi_regmap_dmac_pkg::*;
import adi_regmap_adc_pkg::*;
import adi_regmap_common_pkg::*;

program test_program;

  parameter RX1_COMMON  = `AXI_HMCAD15XX_BA + 'h00_00 * 4;

  test_harness_env env;
  bit [31:0] val;

  // --------------------------
  // Wrapper function for AXI read verify
  // --------------------------
  task axi_read_v(
      input   [31:0]  raddr,
      input   [31:0]  vdata);

    env.mng.RegReadVerify32(raddr,vdata);
  endtask

  // --------------------------
  // Wrapper function for AXI write
  // --------------------------
  task axi_write(
    input [31:0]  waddr,
    input [31:0]  wdata);

    env.mng.RegWrite32(waddr,wdata);
  endtask

  // --------------------------
  // Main procedure
  // --------------------------
  initial begin

    //creating environment
    env = new("HMCAD15XX Environment",
              `TH.`SYS_CLK.inst.IF,
              `TH.`DMA_CLK.inst.IF,
              `TH.`DDR_CLK.inst.IF,
              `TH.`SYS_RST.inst.IF,
              `TH.`MNG_AXI.inst.IF,
              `TH.`DDR_AXI.inst.IF);

    #2ps;

    setLoggerVerbosity(ADI_VERBOSITY_NONE);
    env.start();

    //asserts all the resets for 100 ns
    `TH.`SYS_RST.inst.IF.assert_reset;
    #100
    `TH.`SYS_RST.inst.IF.deassert_reset;

    #1us;

    sanity_test();

    capture_test();
    #5us;
    env.stop();

    `INFO(("Test Done"), ADI_VERBOSITY_NONE);
    $finish;

  end

  // --------------------------
  // Sanity test reg interface
  // --------------------------
  task sanity_test();
    //check ADC VERSION
    axi_read_v (RX1_COMMON + GetAddrs(COMMON_REG_VERSION),
               `SET_COMMON_REG_VERSION_VERSION('h000a0300));
  endtask

  // --------------------------
  // Setup link
  // --------------------------
  task link_setup();

    // pull out RX of reset
    axi_write (RX1_COMMON + GetAddrs(ADC_COMMON_REG_RSTN),
              `SET_ADC_COMMON_REG_RSTN_RSTN(1));
    axi_write (RX1_COMMON + GetAddrs(ADC_COMMON_REG_CNTRL_3),
          `SET_ADC_COMMON_REG_CNTRL_3_CUSTOM_CONTROL(16));
  endtask

  // --------------------------
  // Link teardown
  // --------------------------
  task link_down();
  endtask

  // --------------------------
  // Test capture_test
  // --------------------------
  task capture_test();
    link_setup();


    #10000;


  endtask

  // --------------------------
  // DMA test procedure
  // --------------------------
  task dma_test();

  endtask

  // Check captured data against incremental pattern based on first sample
  // Pattern should be contiguous

endprogram
