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
import axi_vip_pkg::*;
import axi4stream_vip_pkg::*;
import logger_pkg::*;
import adi_regmap_pkg::*;
import adi_regmap_dmac_pkg::*;
import dmac_api_pkg::*;
import dma_trans_pkg::*;

`define RX_DMA      32'h7c42_0000
`define TX_DMA      32'h7c43_0000
`define DDR_BASE    32'h8000_0000

program test_program;

  test_harness_env env;
  // Register accessors
  dmac_api m_dmac_api;
  dmac_api s_dmac_api;

  initial begin

    //creating environment
    env = new(`TH.`SYS_CLK.inst.IF,
              `TH.`DMA_CLK.inst.IF,
              `TH.`DDR_CLK.inst.IF,
              `TH.`SYS_RST.inst.IF,
              `TH.`MNG_AXI.inst.IF,
              `TH.`DDR_AXI.inst.IF);

    #2ps;

    setLoggerVerbosity(6);
    env.start();

    m_dmac_api = new("TX_DMA", env.mng, `TX_DMA);
    m_dmac_api.probe();

    s_dmac_api = new("RX_DMA", env.mng, `RX_DMA);
    s_dmac_api.probe();

    start_clocks();
    sys_reset();

    #1us;

    //  -------------------------------------------------------
    //  Test TX DMA and RX DMA in loopback 
    //  -------------------------------------------------------

    // Init test data
    for (int i=0;i<2048*2 ;i=i+2) begin
      env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+i*2,(((i+1)) << 16) | i ,'hF);
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

    dma_segment m_seg, s_seg;
    int m_tid, s_tid;

    m_dmac_api.enable_dma();
    m_dmac_api.set_flags(0);

    s_dmac_api.enable_dma();
    s_dmac_api.set_flags(0);

    m_seg = new(m_dmac_api.get_params());
    m_seg.length = length;
    m_seg.src_addr = src_addr;

    s_seg = new(s_dmac_api.get_params());
    s_seg.length = length;
    s_seg.dst_addr = dest_addr;

    m_dmac_api.submit_transfer(m_seg, m_tid);
    s_dmac_api.submit_transfer(s_seg, s_tid);

    m_dmac_api.wait_transfer_done(m_tid);
    s_dmac_api.wait_transfer_done(s_tid);

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

  task start_clocks;

    `TH.`DEVICE_CLK.inst.IF.start_clock;

  endtask

  task stop_clocks;

    `TH.`DEVICE_CLK.inst.IF.stop_clock;

  endtask

  task sys_reset;

    //asserts all the resets for 100 ns
    `TH.`SYS_RST.inst.IF.assert_reset;
    #100
    `TH.`SYS_RST.inst.IF.deassert_reset;

  endtask


endprogram
