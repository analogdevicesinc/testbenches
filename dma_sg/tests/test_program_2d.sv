// ***************************************************************************
// ***************************************************************************
// Copyright (C) 2023 Analog Devices, Inc. All rights reserved.
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

program test_program_2d;

  test_harness_env env;
  // Register accessors
  dmac_api m_dmac_api;
  dmac_api s_dmac_api;

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
    for (int i=0,offset=0;i<8;i=i+1) begin

      //Incremental data
      for (int j=0;j<'h800;j=j+2) begin
        env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+offset+j*2,(((j+1+'h1000*i)) << 16) | (j+'h1000*i) ,'hF);
      end
      offset = offset + 'h1000;

      //Buffer filled with 0
      for (int k=0;k<'h80;k=k+1) begin
        env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+offset+k*4, 32'h0,'hF);
      end
      offset = offset + 'h200;

    end

    // TX BLOCK
    // DMA 1st Descriptor test data
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_1000, 'h0000,'hF); //flags
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_1004, 'h0123,'hF); //id
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_1008, `DDR_BASE+'h0000,'hF); //dest_addr
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_100C, 'h0000,'hF);
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_1010, `DDR_BASE+'h0000,'hF); //src_addr
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_1014, 'h0000,'hF);
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_1018, `DDR_BASE+'h1_1030,'hF); //next_sg_addr
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_101C, 'h0000,'hF);
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_1020, 'h0001,'hF); //y_len
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_1024, 'h0FFF,'hF); //x_len
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_1028, 'h1200,'hF); //src_stride
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_102C, 'h0000,'hF); //dst_stride

    // DMA 2nd Descriptor test data
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_1030, 'h0000,'hF); //flags
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_1034, 'h4567,'hF); //id
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_1038, `DDR_BASE+'h0000,'hF); //dest_addr
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_103C, 'h0000,'hF);
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_1040, `DDR_BASE+'h2400,'hF); //src_addr
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_1044, 'h0000,'hF);
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_1048, `DDR_BASE+'h1_1060,'hF); //next_sg_addr
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_104C, 'h0000,'hF);
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_1050, 'h0001,'hF); //y_len
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_1054, 'h0FFF,'hF); //x_len
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_1058, 'h1200,'hF); //src_stride
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_105C, 'h0000,'hF); //dst_stride

    // DMA 3rd Descriptor test data
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_1060, 'h0000,'hF); //flags
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_1064, 'h89AB,'hF); //id
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_1068, `DDR_BASE+'h0000,'hF); //dest_addr
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_106C, 'h0000,'hF);
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_1070, `DDR_BASE+'h4800,'hF); //src_addr
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_1074, 'h0000,'hF);
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_1078, `DDR_BASE+'h1_1090,'hF); //next_sg_addr
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_107C, 'h0000,'hF);
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_1080, 'h0001,'hF); //y_len
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_1084, 'h0FFF,'hF); //x_len
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_1088, 'h1200,'hF); //src_stride
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_108C, 'h0000,'hF); //dst_stride

    // DMA 4th Descriptor test data
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_1090, 'h0003,'hF); //flags
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_1094, 'hCDEF,'hF); //id
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_1098, `DDR_BASE+'h0000,'hF); //dest_addr
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_109C, 'h0000,'hF);
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_10A0, `DDR_BASE+'h6C00,'hF); //src_addr
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_10A4, 'h0000,'hF);
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_10A8, `DDR_BASE+'h1_FFFF,'hF); //next_sg_addr
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_10AC, 'h0000,'hF);
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_10B0, 'h0001,'hF); //y_len
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_10B4, 'h0FFF,'hF); //x_len
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_10B8, 'h1200,'hF); //src_stride
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_10BC, 'h0000,'hF); //dst_stride

    // RX BLOCK
    // DMA 1st Descriptor test data
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_2000, 'h0000,'hF); //flags
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_2004, 'h3210,'hF); //id
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_2008, `DDR_BASE+'h9000,'hF); //dest_addr
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_200C, 'h0000,'hF);
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_2010, `DDR_BASE+'h0000,'hF); //src_addr
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_2014, 'h0000,'hF);
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_2018, `DDR_BASE+'h1_2030,'hF); //next_sg_addr
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_201C, 'h0000,'hF);
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_2020, 'h0001,'hF); //y_len
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_2024, 'h0FFF,'hF); //x_len
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_2028, 'h0000,'hF); //src_stride
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_202C, 'h1000,'hF); //dst_stride

    // DMA 2nd Descriptor test data
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_2030, 'h0000,'hF); //flags
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_2034, 'h7654,'hF); //id
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_2038, `DDR_BASE+'hB000,'hF); //dest_addr
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_203C, 'h0000,'hF);
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_2040, `DDR_BASE+'h0000,'hF); //src_addr
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_2044, 'h0000,'hF);
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_2048, `DDR_BASE+'h1_2060,'hF); //next_sg_addr
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_204C, 'h0000,'hF);
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_2050, 'h0001,'hF); //y_len
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_2054, 'h0FFF,'hF); //x_len
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_2058, 'h0000,'hF); //src_stride
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_205C, 'h1000,'hF); //dst_stride

    // DMA 3rd Descriptor test data
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_2060, 'h0003,'hF); //flags
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_2064, 'hBA98,'hF); //id
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_2068, `DDR_BASE+'hD000,'hF); //dest_addr
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_206C, 'h0000,'hF);
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_2070, `DDR_BASE+'h0000,'hF); //src_addr
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_2074, 'h0000,'hF);
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_2078, `DDR_BASE+'h1_FFFF,'hF); //next_sg_addr
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_207C, 'h0000,'hF);
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_2080, 'h0001,'hF); //y_len
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_2084, 'h0FFF,'hF); //x_len
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_2088, 'h0000,'hF); //src_stride
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_208C, 'h1000,'hF); //dst_stride

    // DMA 4th Descriptor test data
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_2090, 'h0003,'hF); //flags
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_2094, 'hFEDC,'hF); //id
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_2098, `DDR_BASE+'hF000,'hF); //dest_addr
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_209C, 'h0000,'hF);
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_20A0, `DDR_BASE+'h0000,'hF); //src_addr
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_20A4, 'h0000,'hF);
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_20A8, `DDR_BASE+'h1_FFFF,'hF); //next_sg_addr
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_20AC, 'h0000,'hF);
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_20B0, 'h0001,'hF); //y_len
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_20B4, 'h0FFF,'hF); //x_len
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_20B8, 'h0000,'hF); //src_stride
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_20BC, 'h1000,'hF); //dst_stride

    do_sg_transfer(
      .tx_desc_addr(`DDR_BASE+'h1_1000),
      .rx_desc_addr(`DDR_BASE+'h1_2000)
    );

    #1us;

    check_data(
      .src_addr(`DDR_BASE+'h0000),
      .dest_addr(`DDR_BASE+'h9000),
      .length('h8000)
    );

  end

  task do_sg_transfer(bit [31:0] tx_desc_addr,
                      bit [31:0] rx_desc_addr);

    dma_segment m_seg, s_seg;
    int m_tid, s_tid;

    env.mng.RegWrite32(`TX_DMA+'h47C, tx_desc_addr); //TX descriptor first address
    env.mng.RegWrite32(`TX_DMA + GetAddrs(DMAC_CONTROL), 3'b101); //Enable DMA and set HWDESC
    env.mng.RegWrite32(`TX_DMA + GetAddrs(DMAC_FLAGS), 3'b000); //Disable all flags

    env.mng.RegWrite32(`RX_DMA+'h47C, rx_desc_addr); //RX descriptor first address
    env.mng.RegWrite32(`RX_DMA + GetAddrs(DMAC_CONTROL), 3'b101); //Enable DMA and set HWDESC
    env.mng.RegWrite32(`RX_DMA + GetAddrs(DMAC_FLAGS), 3'b000); //Disable all flags

    env.mng.RegWrite32(`TX_DMA + GetAddrs(DMAC_TRANSFER_SUBMIT), 1'b1);
    env.mng.RegWrite32(`RX_DMA + GetAddrs(DMAC_TRANSFER_SUBMIT), 1'b1);

    env.mng.RegWrite32(`RX_DMA+'h47C, rx_desc_addr+'h90); //RX descriptor first address
    env.mng.RegWrite32(`RX_DMA + GetAddrs(DMAC_TRANSFER_SUBMIT), 1'b1);

    m_dmac_api.transfer_id_get(m_tid);
    s_dmac_api.transfer_id_get(s_tid);

    m_dmac_api.wait_transfer_done(m_tid-1);
    s_dmac_api.wait_transfer_done(s_tid-1);

  endtask


  // Check captured data 
  task check_data(bit [31:0] src_addr,
                  bit [31:0] dest_addr,
                  bit [31:0] length);

    bit [31:0] current_dest_address;
    bit [31:0] current_src_address;
    bit [31:0] captured_word;
    bit [31:0] reference_word;

    for (int i=0;i<length;i=i+4) begin
      current_src_address = src_addr+i+(i/'h1000)*'h200;
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
