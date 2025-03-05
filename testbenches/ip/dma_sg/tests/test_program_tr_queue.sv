// ***************************************************************************
// ***************************************************************************
// Copyright (C) 2024 Analog Devices, Inc. All rights reserved.
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

`include "utils.svh"

import logger_pkg::*;
import test_harness_env_pkg::*;
import adi_regmap_pkg::*;
import adi_regmap_dmac_pkg::*;
import dmac_api_pkg::*;
import dma_trans_pkg::*;
import axi_vip_pkg::*;

import `PKGIFY(test_harness, mng_axi_vip)::*;
import `PKGIFY(test_harness, ddr_axi_vip)::*;

program test_program_tr_queue;

  test_harness_env #(`AXI_VIP_PARAMS(test_harness, mng_axi_vip), `AXI_VIP_PARAMS(test_harness, ddr_axi_vip)) base_env;

  // Register accessors
  dmac_api m_dmac_api;
  dmac_api s_dmac_api;

  initial begin

    // Creating environment
    base_env = new("Base Environment",
                    `TH.`SYS_CLK.inst.IF,
                    `TH.`DMA_CLK.inst.IF,
                    `TH.`DDR_CLK.inst.IF,
                    `TH.`SYS_RST.inst.IF,
                    `TH.`MNG_AXI.inst.IF,
                    `TH.`DDR_AXI.inst.IF);

    setLoggerVerbosity(ADI_VERBOSITY_NONE);

    base_env.start();
    `TH.`DEVICE_CLK.inst.IF.start_clock();
    base_env.sys_reset();

    m_dmac_api = new("TX_DMA", base_env.mng.sequencer, `TX_DMA_BA);
    m_dmac_api.probe();

    s_dmac_api = new("RX_DMA", base_env.mng.sequencer, `RX_DMA_BA);
    s_dmac_api.probe();

    #1us;

    //  -------------------------------------------------------
    //  Test TX DMA and RX DMA in loopback
    //  -------------------------------------------------------

    // Init test data
    for (int i=0;i<'h4000;i=i+2) begin
      base_env.ddr.agent.mem_model.backdoor_memory_write_4byte(xil_axi_uint'(`DDR_BA+i*2),(((i+1)) << 16) | i ,'hF);
    end

    // TX BLOCK
    // 1st Descriptor
    write_descriptor(.desc_addr     (xil_axi_uint'(`DDR_BA+'h1_0000)), .flags(2'b00), .id   ('h0123), .src_addr  (xil_axi_uint'(`DDR_BA+'h0000)), .dest_addr (0),
                     .next_desc_addr(xil_axi_uint'(`DDR_BA+'h1_0030)), .y_len(0),     .x_len('h0FFF), .src_stride(0),              .dst_stride(0));
    // 2nd Descriptor
    write_descriptor(.desc_addr     (xil_axi_uint'(`DDR_BA+'h1_0030)), .flags(2'b11), .id   ('h4567), .src_addr  (xil_axi_uint'(`DDR_BA+'h1000)), .dest_addr (0),
                     .next_desc_addr(xil_axi_uint'(`DDR_BA+'h1_0060)), .y_len(0),     .x_len('h0FFF), .src_stride(0),              .dst_stride(0));
    // 3rd Descriptor
    write_descriptor(.desc_addr     (xil_axi_uint'(`DDR_BA+'h1_0060)), .flags(2'b00), .id   ('h89AB), .src_addr  (xil_axi_uint'(`DDR_BA+'h2000)), .dest_addr (0),
                     .next_desc_addr(xil_axi_uint'(`DDR_BA+'h1_0090)), .y_len(0),     .x_len('h0FFF), .src_stride(0),              .dst_stride(0));
    // 4th Descriptor
    write_descriptor(.desc_addr     (xil_axi_uint'(`DDR_BA+'h1_0090)), .flags(2'b11), .id   ('hCDEF), .src_addr  (xil_axi_uint'(`DDR_BA+'h3000)), .dest_addr (0),
                     .next_desc_addr(xil_axi_uint'(`DDR_BA+'h1_00C0)), .y_len(0),     .x_len('h0FFF), .src_stride(0),              .dst_stride(0));
    // 5th Descriptor
    write_descriptor(.desc_addr     (xil_axi_uint'(`DDR_BA+'h1_00C0)), .flags(2'b00), .id   ('hAABB), .src_addr  (xil_axi_uint'(`DDR_BA+'h4000)), .dest_addr (0),
                     .next_desc_addr(xil_axi_uint'(`DDR_BA+'h1_00F0)), .y_len(0),     .x_len('h0FFF), .src_stride(0),              .dst_stride(0));
    // 6th Descriptor
    write_descriptor(.desc_addr     (xil_axi_uint'(`DDR_BA+'h1_00F0)), .flags(2'b11), .id   ('hCCDD), .src_addr  (xil_axi_uint'(`DDR_BA+'h5000)), .dest_addr (0),
                     .next_desc_addr(xil_axi_uint'(`DDR_BA+'h1_0120)), .y_len(0),     .x_len('h0FFF), .src_stride(0),              .dst_stride(0));
    // 7th Descriptor
    write_descriptor(.desc_addr     (xil_axi_uint'(`DDR_BA+'h1_0120)), .flags(2'b00), .id   ('hEEFF), .src_addr  (xil_axi_uint'(`DDR_BA+'h6000)), .dest_addr (0),
                     .next_desc_addr(xil_axi_uint'(`DDR_BA+'h1_0150)), .y_len(0),     .x_len('h0FFF), .src_stride(0),              .dst_stride(0));
    // 8th Descriptor
    write_descriptor(.desc_addr     (xil_axi_uint'(`DDR_BA+'h1_0150)), .flags(2'b11), .id   ('h1234), .src_addr  (xil_axi_uint'(`DDR_BA+'h7000)), .dest_addr (0),
                     .next_desc_addr(xil_axi_uint'(`DDR_BA+'h1_FFFF)), .y_len(0),     .x_len('h0FFF), .src_stride(0),              .dst_stride(0));

    // RX BLOCK
    // 1st Descriptor
    write_descriptor(.desc_addr     (xil_axi_uint'(`DDR_BA+'h1_1000)), .flags(2'b00), .id   ('h3210), .src_addr  (0), .dest_addr(xil_axi_uint'(`DDR_BA+'h8000)),
                     .next_desc_addr(xil_axi_uint'(`DDR_BA+'h1_1030)), .y_len(0),     .x_len('h0FFF), .src_stride(0), .dst_stride(0));
    // 2nd Descriptor
    write_descriptor(.desc_addr     (xil_axi_uint'(`DDR_BA+'h1_1030)), .flags(2'b00), .id   ('h7654), .src_addr  (0), .dest_addr(xil_axi_uint'(`DDR_BA+'h9000)),
                     .next_desc_addr(xil_axi_uint'(`DDR_BA+'h1_1060)), .y_len(0),     .x_len('h0FFF), .src_stride(0), .dst_stride(0));
    // 3rd Descriptor
    write_descriptor(.desc_addr     (xil_axi_uint'(`DDR_BA+'h1_1060)), .flags(2'b11), .id   ('hBA98), .src_addr  (0), .dest_addr(xil_axi_uint'(`DDR_BA+'hA000)),
                     .next_desc_addr(xil_axi_uint'(`DDR_BA+'h1_FFFF)), .y_len(0),     .x_len('h0FFF), .src_stride(0), .dst_stride(0));
    // 4th Descriptor
    write_descriptor(.desc_addr     (xil_axi_uint'(`DDR_BA+'h1_1090)), .flags(2'b00), .id   ('hFEDC), .src_addr  (0), .dest_addr(xil_axi_uint'(`DDR_BA+'hB000)),
                     .next_desc_addr(xil_axi_uint'(`DDR_BA+'h1_10C0)), .y_len(0),     .x_len('h0FFF), .src_stride(0), .dst_stride(0));
    // 5th Descriptor
    write_descriptor(.desc_addr     (xil_axi_uint'(`DDR_BA+'h1_10C0)), .flags(2'b00), .id   ('hBBAA), .src_addr  (0), .dest_addr(xil_axi_uint'(`DDR_BA+'hC000)),
                     .next_desc_addr(xil_axi_uint'(`DDR_BA+'h1_10F0)), .y_len(0),     .x_len('h0FFF), .src_stride(0), .dst_stride(0));
    // 6th Descriptor
    write_descriptor(.desc_addr     (xil_axi_uint'(`DDR_BA+'h1_10F0)), .flags(2'b00), .id   ('hDDCC), .src_addr  (0), .dest_addr(xil_axi_uint'(`DDR_BA+'hD000)),
                     .next_desc_addr(xil_axi_uint'(`DDR_BA+'h1_1120)), .y_len(0),     .x_len('h0FFF), .src_stride(0), .dst_stride(0));
    // 7th Descriptor
    write_descriptor(.desc_addr     (xil_axi_uint'(`DDR_BA+'h1_1120)), .flags(2'b00), .id   ('hFFEE), .src_addr  (0), .dest_addr(xil_axi_uint'(`DDR_BA+'hE000)),
                     .next_desc_addr(xil_axi_uint'(`DDR_BA+'h1_1150)), .y_len(0),     .x_len('h0FFF), .src_stride(0), .dst_stride(0));
    // 8th Descriptor
    write_descriptor(.desc_addr     (xil_axi_uint'(`DDR_BA+'h1_1150)), .flags(2'b11), .id   ('h4321), .src_addr  (0), .dest_addr(xil_axi_uint'(`DDR_BA+'hF000)),
                     .next_desc_addr(xil_axi_uint'(`DDR_BA+'h1_FFFF)), .y_len(0),     .x_len('h0FFF), .src_stride(0), .dst_stride(0));

    do_sg_transfer(
      .tx_desc_addr(xil_axi_uint'(`DDR_BA+'h1_0000)),
      .rx_desc_addr(xil_axi_uint'(`DDR_BA+'h1_1000))
    );

    #1us;

    check_data(
      .src_addr(xil_axi_uint'(`DDR_BA+'h0000)),
      .dest_addr(xil_axi_uint'(`DDR_BA+'h8000)),
      .length('h8000)
    );

    base_env.stop();
    `TH.`DEVICE_CLK.inst.IF.stop_clock();

    `INFO(("Test bench done!"), ADI_VERBOSITY_NONE);
    $finish();

  end

  task write_descriptor(bit [31:0] desc_addr,
                        bit [ 1:0] flags,
                        bit [31:0] id,
                        bit [31:0] dest_addr,
                        bit [31:0] src_addr,
                        bit [31:0] next_desc_addr,
                        bit [31:0] y_len,
                        bit [31:0] x_len,
                        bit [31:0] src_stride,
                        bit [31:0] dst_stride);

    base_env.ddr.agent.mem_model.backdoor_memory_write_4byte(desc_addr+'h00, flags, 'hF);
    base_env.ddr.agent.mem_model.backdoor_memory_write_4byte(desc_addr+'h04, id, 'hF);
    base_env.ddr.agent.mem_model.backdoor_memory_write_4byte(desc_addr+'h08, dest_addr, 'hF);
    base_env.ddr.agent.mem_model.backdoor_memory_write_4byte(desc_addr+'h0C, 0, 'hF);
    base_env.ddr.agent.mem_model.backdoor_memory_write_4byte(desc_addr+'h10, src_addr, 'hF);
    base_env.ddr.agent.mem_model.backdoor_memory_write_4byte(desc_addr+'h14, 0, 'hF);
    base_env.ddr.agent.mem_model.backdoor_memory_write_4byte(desc_addr+'h18, next_desc_addr, 'hF);
    base_env.ddr.agent.mem_model.backdoor_memory_write_4byte(desc_addr+'h1C, 0, 'hF);
    base_env.ddr.agent.mem_model.backdoor_memory_write_4byte(desc_addr+'h20, y_len, 'hF);
    base_env.ddr.agent.mem_model.backdoor_memory_write_4byte(desc_addr+'h24, x_len, 'hF);
    base_env.ddr.agent.mem_model.backdoor_memory_write_4byte(desc_addr+'h28, src_stride, 'hF);
    base_env.ddr.agent.mem_model.backdoor_memory_write_4byte(desc_addr+'h2C, dst_stride, 'hF);

  endtask : write_descriptor

  task do_sg_transfer(bit [31:0] tx_desc_addr,
                      bit [31:0] rx_desc_addr);

    dma_segment m_seg, s_seg;
    int m_tid, s_tid;

    base_env.mng.sequencer.RegWrite32(`TX_DMA_BA + GetAddrs(DMAC_SG_ADDRESS), tx_desc_addr); //TX descriptor first address
    base_env.mng.sequencer.RegWrite32(`TX_DMA_BA + GetAddrs(DMAC_CONTROL), //Enable DMA and set HWDESC
                       `SET_DMAC_CONTROL_HWDESC(1) |
                       `SET_DMAC_CONTROL_ENABLE(1));
    base_env.mng.sequencer.RegWrite32(`TX_DMA_BA + GetAddrs(DMAC_FLAGS), 0); //Disable all flags

    base_env.mng.sequencer.RegWrite32(`RX_DMA_BA + GetAddrs(DMAC_SG_ADDRESS), rx_desc_addr); //RX descriptor first address
    base_env.mng.sequencer.RegWrite32(`RX_DMA_BA + GetAddrs(DMAC_CONTROL), //Enable DMA and set HWDESC
                       `SET_DMAC_CONTROL_HWDESC(1) |
                       `SET_DMAC_CONTROL_ENABLE(1));
    base_env.mng.sequencer.RegWrite32(`RX_DMA_BA + GetAddrs(DMAC_FLAGS), 0); //Disable all flags

    base_env.mng.sequencer.RegWrite32(`TX_DMA_BA + GetAddrs(DMAC_TRANSFER_SUBMIT), //Test 4 consecutive TX transfers in queue
                       `SET_DMAC_TRANSFER_SUBMIT_TRANSFER_SUBMIT(1));
    base_env.mng.sequencer.RegWrite32(`RX_DMA_BA + GetAddrs(DMAC_TRANSFER_SUBMIT),
                       `SET_DMAC_TRANSFER_SUBMIT_TRANSFER_SUBMIT(1));

    base_env.mng.sequencer.RegWrite32(`TX_DMA_BA + GetAddrs(DMAC_SG_ADDRESS), tx_desc_addr+'h60); //TX descriptor first address
    base_env.mng.sequencer.RegWrite32(`TX_DMA_BA + GetAddrs(DMAC_TRANSFER_SUBMIT),
                       `SET_DMAC_TRANSFER_SUBMIT_TRANSFER_SUBMIT(1));

    base_env.mng.sequencer.RegWrite32(`TX_DMA_BA + GetAddrs(DMAC_SG_ADDRESS), tx_desc_addr+'hC0); //TX descriptor first address
    base_env.mng.sequencer.RegWrite32(`TX_DMA_BA + GetAddrs(DMAC_TRANSFER_SUBMIT),
                       `SET_DMAC_TRANSFER_SUBMIT_TRANSFER_SUBMIT(1));

    base_env.mng.sequencer.RegWrite32(`TX_DMA_BA + GetAddrs(DMAC_SG_ADDRESS), tx_desc_addr+'h120); //TX descriptor first address
    base_env.mng.sequencer.RegWrite32(`TX_DMA_BA + GetAddrs(DMAC_TRANSFER_SUBMIT),
                       `SET_DMAC_TRANSFER_SUBMIT_TRANSFER_SUBMIT(1));

    base_env.mng.sequencer.RegWrite32(`RX_DMA_BA + GetAddrs(DMAC_SG_ADDRESS), rx_desc_addr+'h90); //RX descriptor first address
    base_env.mng.sequencer.RegWrite32(`RX_DMA_BA + GetAddrs(DMAC_TRANSFER_SUBMIT),
                       `SET_DMAC_TRANSFER_SUBMIT_TRANSFER_SUBMIT(1));

    m_dmac_api.transfer_id_get(m_tid);
    s_dmac_api.transfer_id_get(s_tid);

    m_dmac_api.wait_transfer_done(m_tid-1);
    s_dmac_api.wait_transfer_done(s_tid-1);

  endtask : do_sg_transfer

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
      captured_word = base_env.ddr.agent.mem_model.backdoor_memory_read_4byte(current_dest_address);
      reference_word = base_env.ddr.agent.mem_model.backdoor_memory_read_4byte(current_src_address);

      if (captured_word !== reference_word) begin
        `ERROR(("Address 0x%h Expected 0x%h found 0x%h",current_dest_address,reference_word,captured_word));
      end

    end
  endtask : check_data

endprogram
