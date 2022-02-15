// ***************************************************************************
// ***************************************************************************
// Copyright 2014 - 2018 (c) Analog Devices, Inc. All rights reserved.
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

`define RX_DMA      32'h7c42_0000
`define TX_DMA      32'h7c43_0000
`define DDR_BASE    32'h8000_0000

program test_program;

  test_harness_env env;
  bit [31:0] val;
  bit [31:0] src_addr;

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

    `TH.`DEVICE_CLK.inst.IF.start_clock;

    //asserts all the resets for 100 ns
    `TH.`SYS_RST.inst.IF.assert_reset;
    #100
    `TH.`SYS_RST.inst.IF.deassert_reset;

    #1us;

    //  -------------------------------------------------------
    //  Test TX DMA and RX DMA in loopback 
    //  -------------------------------------------------------

    // Init test data
    for (int i=0;i<2048*2 ;i=i+2) begin
      env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+src_addr+i*2,(((i+1)) << 16) | i ,'hF);
    end

    do_transfer(
      .src_addr(`DDR_BASE+'h0000),
      .dest_addr(`DDR_BASE+'h2000),
      .length('h1000)
    );

    #20us;

    check_data(
      .src_addr(`DDR_BASE+'h0000),
      .dest_addr(`DDR_BASE+'h2000),
      .length('h1000)
    );

  end

  task do_transfer(bit [31:0] src_addr,
                   bit [31:0] dest_addr,
                   bit [31:0] length);

    // Configure TX DMA
    env.mng.RegWrite32(`TX_DMA+GetAddrs(DMAC_CONTROL),
                       `SET_DMAC_CONTROL_ENABLE(1));
    env.mng.RegWrite32(`TX_DMA+GetAddrs(DMAC_FLAGS),
                       `SET_DMAC_FLAGS_TLAST(32'h00000006));
    env.mng.RegWrite32(`TX_DMA+GetAddrs(DMAC_X_LENGTH),
                       `SET_DMAC_X_LENGTH_X_LENGTH(length-1));
    env.mng.RegWrite32(`TX_DMA+GetAddrs(DMAC_SRC_ADDRESS),
                       `SET_DMAC_SRC_ADDRESS_SRC_ADDRESS(src_addr));
    env.mng.RegWrite32(`TX_DMA+GetAddrs(DMAC_TRANSFER_SUBMIT),
                       `SET_DMAC_TRANSFER_SUBMIT_TRANSFER_SUBMIT(1));

    // Configure RX DMA
    env.mng.RegWrite32(`RX_DMA+GetAddrs(DMAC_CONTROL),
                       `SET_DMAC_CONTROL_ENABLE(1));
    env.mng.RegWrite32(`RX_DMA+GetAddrs(DMAC_FLAGS),
                       `SET_DMAC_FLAGS_TLAST(32'h00000006));
    env.mng.RegWrite32(`RX_DMA+GetAddrs(DMAC_X_LENGTH),
                       `SET_DMAC_X_LENGTH_X_LENGTH(length-1));
    env.mng.RegWrite32(`RX_DMA+GetAddrs(DMAC_DEST_ADDRESS),
                       `SET_DMAC_DEST_ADDRESS_DEST_ADDRESS(dest_addr));
    env.mng.RegWrite32(`RX_DMA+GetAddrs(DMAC_TRANSFER_SUBMIT),
                       `SET_DMAC_TRANSFER_SUBMIT_TRANSFER_SUBMIT(1));
  endtask


  // Check captured data 
  task check_data(bit [31:0] src_addr,
                  bit [31:0] dest_addr,
                  bit [31:0] length);

    bit [31:0] current_dest_address;
    bit [31:0] current_src_address;
    bit [31:0] captured_word;
    bit [31:0] reference_word;

    for (int i=0;i<length/4;i=i+4) begin
      current_src_address = src_addr+i;
      current_dest_address = dest_addr+i;
      captured_word = env.ddr_axi_agent.mem_model.backdoor_memory_read_4byte(current_dest_address);
      reference_word = env.ddr_axi_agent.mem_model.backdoor_memory_read_4byte(current_src_address);

      if (captured_word !== reference_word) begin
        `ERROR(("Address 0x%h Expected 0x%h found 0x%h",current_dest_address,reference_word,captured_word));
      end

    end
  endtask

endprogram
