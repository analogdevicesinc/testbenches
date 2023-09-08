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

program test_program_1d;

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
    for (int i=0;i<'h4000;i=i+2) begin
      env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+i*2,(((i+1)) << 16) | i ,'hF);
    end

    // TX BLOCK
    // DMA 1st Descriptor test data
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_0000, 'h0000,'hF); //flags
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_0004, 'h0123,'hF); //id
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_0008, `DDR_BASE+'h0000,'hF); //dest_addr
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_000C, 'h0000,'hF);
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_0010, `DDR_BASE+'h0000,'hF); //src_addr
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_0014, 'h0000,'hF);
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_0018, `DDR_BASE+'h1_0030,'hF); //next_sg_addr
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_001C, 'h0000,'hF);
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_0020, 'h0000,'hF); //y_len
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_0024, 'h0FFF,'hF); //x_len
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_0028, 'h0000,'hF); //src_stride
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_002C, 'h0000,'hF); //dst_stride

    // DMA 2nd Descriptor test data
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_0030, 'h0000,'hF); //flags
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_0034, 'h4567,'hF); //id
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_0038, `DDR_BASE+'h0000,'hF); //dest_addr
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_003C, 'h0000,'hF);
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_0040, `DDR_BASE+'h1000,'hF); //src_addr
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_0044, 'h0000,'hF);
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_0048, `DDR_BASE+'h1_0060,'hF); //next_sg_addr
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_004C, 'h0000,'hF);
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_0050, 'h0000,'hF); //y_len
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_0054, 'h0FFF,'hF); //x_len
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_0058, 'h0000,'hF); //src_stride
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_005C, 'h0000,'hF); //dst_stride

    // DMA 3rd Descriptor test data
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_0060, 'h0000,'hF); //flags
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_0064, 'h89AB,'hF); //id
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_0068, `DDR_BASE+'h0000,'hF); //dest_addr
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_006C, 'h0000,'hF);
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_0070, `DDR_BASE+'h2000,'hF); //src_addr
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_0074, 'h0000,'hF);
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_0078, `DDR_BASE+'h1_0090,'hF); //next_sg_addr
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_007C, 'h0000,'hF);
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_0080, 'h0000,'hF); //y_len
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_0084, 'h0FFF,'hF); //x_len
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_0088, 'h0000,'hF); //src_stride
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_008C, 'h0000,'hF); //dst_stride

    // DMA 4th Descriptor test data
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_0090, 'h0000,'hF); //flags
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_0094, 'hCDEF,'hF); //id
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_0098, `DDR_BASE+'h0000,'hF); //dest_addr
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_009C, 'h0000,'hF);
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_00A0, `DDR_BASE+'h3000,'hF); //src_addr
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_00A4, 'h0000,'hF);
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_00A8, `DDR_BASE+'h1_00C0,'hF); //next_sg_addr
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_00AC, 'h0000,'hF);
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_00B0, 'h0000,'hF); //y_len
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_00B4, 'h0FFF,'hF); //x_len
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_00B8, 'h0000,'hF); //src_stride
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_00BC, 'h0000,'hF); //dst_stride

    // DMA 5th Descriptor test data
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_00C0, 'h0000,'hF); //flags
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_00C4, 'hAABB,'hF); //id
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_00C8, `DDR_BASE+'h0000,'hF); //dest_addr
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_00CC, 'h0000,'hF);
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_00D0, `DDR_BASE+'h4000,'hF); //src_addr
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_00D4, 'h0000,'hF);
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_00D8, `DDR_BASE+'h1_00F0,'hF); //next_sg_addr
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_00DC, 'h0000,'hF);
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_00E0, 'h0000,'hF); //y_len
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_00E4, 'h0FFF,'hF); //x_len
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_00E8, 'h0000,'hF); //src_stride
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_00EC, 'h0000,'hF); //dst_stride

    // DMA 6th Descriptor test data
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_00F0, 'h0000,'hF); //flags
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_00F4, 'hCCDD,'hF); //id
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_00F8, `DDR_BASE+'h0000,'hF); //dest_addr
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_00FC, 'h0000,'hF);
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_0100, `DDR_BASE+'h5000,'hF); //src_addr
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_0104, 'h0000,'hF);
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_0108, `DDR_BASE+'h1_0120,'hF); //next_sg_addr
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_010C, 'h0000,'hF);
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_0110, 'h0000,'hF); //y_len
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_0114, 'h0FFF,'hF); //x_len
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_0118, 'h0000,'hF); //src_stride
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_011C, 'h0000,'hF); //dst_stride

    // DMA 7th Descriptor test data
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_0120, 'h0000,'hF); //flags
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_0124, 'hEEFF,'hF); //id
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_0128, `DDR_BASE+'h0000,'hF); //dest_addr
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_012C, 'h0000,'hF);
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_0130, `DDR_BASE+'h6000,'hF); //src_addr
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_0134, 'h0000,'hF);
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_0138, `DDR_BASE+'h1_0150,'hF); //next_sg_addr
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_013C, 'h0000,'hF);
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_0140, 'h0000,'hF); //y_len
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_0144, 'h0FFF,'hF); //x_len
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_0148, 'h0000,'hF); //src_stride
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_014C, 'h0000,'hF); //dst_stride

    // DMA 8th Descriptor test data
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_0150, 'h0003,'hF); //flags
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_0154, 'h1234,'hF); //id
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_0158, `DDR_BASE+'h0000,'hF); //dest_addr
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_015C, 'h0000,'hF);
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_0160, `DDR_BASE+'h7000,'hF); //src_addr
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_0164, 'h0000,'hF);
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_0168, `DDR_BASE+'h1_FFFF,'hF); //next_sg_addr
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_016C, 'h0000,'hF);
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_0170, 'h0000,'hF); //y_len
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_0174, 'h0FFF,'hF); //x_len
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_0178, 'h0000,'hF); //src_stride
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_017C, 'h0000,'hF); //dst_stride

    // RX BLOCK
    // DMA 1st Descriptor test data
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_1000, 'h0000,'hF); //flags
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_1004, 'h3210,'hF); //id
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_1008, `DDR_BASE+'h8000,'hF); //dest_addr
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_100C, 'h0000,'hF);
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_1010, `DDR_BASE+'h0000,'hF); //src_addr
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_1014, 'h0000,'hF);
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_1018, `DDR_BASE+'h1_1030,'hF); //next_sg_addr
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_101C, 'h0000,'hF);
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_1020, 'h0000,'hF); //y_len
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_1024, 'h0FFF,'hF); //x_len
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_1028, 'h0000,'hF); //src_stride
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_102C, 'h0000,'hF); //dst_stride

    // DMA 2nd Descriptor test data
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_1030, 'h0000,'hF); //flags
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_1034, 'h7654,'hF); //id
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_1038, `DDR_BASE+'h9000,'hF); //dest_addr
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_103C, 'h0000,'hF);
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_1040, `DDR_BASE+'h0000,'hF); //src_addr
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_1044, 'h0000,'hF);
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_1048, `DDR_BASE+'h1_1060,'hF); //next_sg_addr
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_104C, 'h0000,'hF);
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_1050, 'h0000,'hF); //y_len
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_1054, 'h0FFF,'hF); //x_len
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_1058, 'h0000,'hF); //src_stride
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_105C, 'h0000,'hF); //dst_stride

    // DMA 3rd Descriptor test data
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_1060, 'h0003,'hF); //flags
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_1064, 'hBA98,'hF); //id
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_1068, `DDR_BASE+'hA000,'hF); //dest_addr
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_106C, 'h0000,'hF);
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_1070, `DDR_BASE+'h0000,'hF); //src_addr
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_1074, 'h0000,'hF);
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_1078, `DDR_BASE+'h1_FFFF,'hF); //next_sg_addr
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_107C, 'h0000,'hF);
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_1080, 'h0000,'hF); //y_len
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_1084, 'h0FFF,'hF); //x_len
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_1088, 'h0000,'hF); //src_stride
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_108C, 'h0000,'hF); //dst_stride

    // DMA 4th Descriptor test data
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_1090, 'h0000,'hF); //flags
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_1094, 'hFEDC,'hF); //id
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_1098, `DDR_BASE+'hB000,'hF); //dest_addr
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_109C, 'h0000,'hF);
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_10A0, `DDR_BASE+'h0000,'hF); //src_addr
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_10A4, 'h0000,'hF);
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_10A8, `DDR_BASE+'h1_10C0,'hF); //next_sg_addr
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_10AC, 'h0000,'hF);
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_10B0, 'h0000,'hF); //y_len
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_10B4, 'h0FFF,'hF); //x_len
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_10B8, 'h0000,'hF); //src_stride
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_10BC, 'h0000,'hF); //dst_stride

    // DMA 5th Descriptor test data
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_10C0, 'h0000,'hF); //flags
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_10C4, 'hDCDC,'hF); //id
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_10C8, `DDR_BASE+'hC000,'hF); //dest_addr
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_10CC, 'h0000,'hF);
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_10D0, `DDR_BASE+'h0000,'hF); //src_addr
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_10D4, 'h0000,'hF);
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_10D8, `DDR_BASE+'h1_10F0,'hF); //next_sg_addr
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_10DC, 'h0000,'hF);
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_10E0, 'h0000,'hF); //y_len
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_10E4, 'h1FFF,'hF); //x_len
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_10E8, 'h0000,'hF); //src_stride
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_10EC, 'h0000,'hF); //dst_stride

    // DMA 6th Descriptor test data
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_10F0, 'h0003,'hF); //flags
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_10F4, 'hFEFE,'hF); //id
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_10F8, `DDR_BASE+'hE000,'hF); //dest_addr
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_10FC, 'h0000,'hF);
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_1100, `DDR_BASE+'h0000,'hF); //src_addr
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_1104, 'h0000,'hF);
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_1108, `DDR_BASE+'h1_FFFF,'hF); //next_sg_addr
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_110C, 'h0000,'hF);
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_1110, 'h0000,'hF); //y_len
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_1114, 'h1FFF,'hF); //x_len
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_1118, 'h0000,'hF); //src_stride
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BASE+'h1_111C, 'h0000,'hF); //dst_stride

    do_sg_transfer(
      .tx_desc_addr(`DDR_BASE+'h1_0000),
      .rx_desc_addr(`DDR_BASE+'h1_1000)
    );

    #1us;

    check_data(
      .src_addr(`DDR_BASE+'h0000),
      .dest_addr(`DDR_BASE+'h8000),
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
