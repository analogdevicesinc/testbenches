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
import dmac_api_pkg::*;
import adi_regmap_pkg::*;
import adi_regmap_dmac_pkg::*;

`define ADC_TRANSFER_LENGTH 32'h600

program test_program;

  // declare the class instances
  environment env;

  dmac_api dmac_tx;
  dmac_api dmac_rx;

  int val;

  initial begin

    // create environment
    env = new(`TH.`SYS_CLK.inst.IF,
              `TH.`DMA_CLK.inst.IF,
              `TH.`DDR_CLK.inst.IF,
              `TH.`SYS_RST.inst.IF,
              `TH.`MNG_AXI.inst.IF,
              `TH.`DDR_AXI.inst.IF,

              `TH.`ADC_SRC_AXIS.inst.IF,
              `TH.`DAC_DST_AXIS.inst.IF,
              `TH.`ADC_DST_AXI_PT.inst.IF,
              `TH.`DAC_SRC_AXI_PT.inst.IF
             );

    dmac_tx = new("DMAC TX", env.mng, `TX_DMA_BA);
    dmac_rx = new("DMAC RX", env.mng, `RX_DMA_BA);

    //=========================================================================
    // Setup generator/monitor stubs
    //=========================================================================

    setLoggerVerbosity(10);
    
    env.start();
    env.sys_reset();

    // configure environment sequencers
    env.configure();

    `INFO(("Bring up IP from reset."));
    systemBringUp();
    
    // Start the ADC/DAC stubs
    `INFO(("Call the run() ..."));
    env.run();

    // Init test data
    `INFO(("Initialize the memory ..."));
    for (int i=0;i<'h4000;i=i+2) begin
      env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(`DDR_BA+i*2,(((i+1)) << 16) | i ,'hF);
    end

    //=========================================================================
    // TX Block descriptors
    // DMA 1st Descriptor test data
    init_mem_bd(
      .bd_addr(`DDR_BA+'h1_0000),
      .flags('h0003),
      .id('h0001),
      .dest_addr(`DDR_BA+'h0000),
      .src_addr(`DDR_BA+'h0000),
      .next_sg_addr(`DDR_BA+'h1_FFFF),
      .y_len('h0000),
      .x_len('h0057));

    // DMA 2nd Descriptor test data
    init_mem_bd(
      .bd_addr(`DDR_BA+'h1_0030),
      .flags('h0003),
      .id('h0002),
      .dest_addr(`DDR_BA+'h0000),
      .src_addr(`DDR_BA+'h1000),
      .next_sg_addr(`DDR_BA+'h1_FFFF),
      .y_len('h0000),
      .x_len('h0024));

    // DMA 3rd Descriptor test data
    init_mem_bd(
      .bd_addr(`DDR_BA+'h1_0060),
      .flags('h0003),
      .id('h0003),
      .dest_addr(`DDR_BA+'h0000),
      .src_addr(`DDR_BA+'h2000),
      .next_sg_addr(`DDR_BA+'h1_FFFF),
      .y_len('h0000),
      .x_len('h0199));

    // DMA 4th Descriptor test data
    init_mem_bd(
      .bd_addr(`DDR_BA+'h1_0090),
      .flags('h0003),
      .id('hCDEF),
      .dest_addr(`DDR_BA+'h0000),
      .src_addr(`DDR_BA+'h3000),
      .next_sg_addr(`DDR_BA+'h1_FFFF),
      .y_len('h0000),
      .x_len('h0FFF));

    // DMA 5th Descriptor test data
    init_mem_bd(
      .bd_addr(`DDR_BA+'h1_00C0),
      .flags('h0003),
      .id('hAABB),
      .dest_addr(`DDR_BA+'h0000),
      .src_addr(`DDR_BA+'h4000),
      .next_sg_addr(`DDR_BA+'h1_FFFF),
      .y_len('h0000),
      .x_len('h0FFF));

    // DMA 6th Descriptor test data
    init_mem_bd(
      .bd_addr(`DDR_BA+'h1_00F0),
      .flags('h0003),
      .id('hCCDD),
      .dest_addr(`DDR_BA+'h0000),
      .src_addr(`DDR_BA+'h5000),
      .next_sg_addr(`DDR_BA+'h1_FFFF),
      .y_len('h0000),
      .x_len('h0FFF));

    // DMA 7th Descriptor test data
    init_mem_bd(
      .bd_addr(`DDR_BA+'h1_0120),
      .flags('h0003),
      .id('hEEFF),
      .dest_addr(`DDR_BA+'h0000),
      .src_addr(`DDR_BA+'h6000),
      .next_sg_addr(`DDR_BA+'h1_FFFF),
      .y_len('h0000),
      .x_len('h0FFF));

    // DMA 8th Descriptor test data
    init_mem_bd(
      .bd_addr(`DDR_BA+'h1_0150),
      .flags('h0003),
      .id('h1234),
      .dest_addr(`DDR_BA+'h0000),
      .src_addr(`DDR_BA+'h7000),
      .next_sg_addr(`DDR_BA+'h1_FFFF),
      .y_len('h0000),
      .x_len('h0FFF));

    //=========================================================================
    // RX Block descriptors
    // DMA 1st Descriptor test data
    init_mem_bd(
      .bd_addr(`DDR_BA+'h1_1000),
      .flags('h0002),
      .id('h3210),
      .dest_addr(`DDR_BA+'h8000),
      .src_addr(`DDR_BA+'h0000),
      .next_sg_addr(`DDR_BA+'h1_1030),
      .y_len('h0000),
      .x_len('hFFFF));

    // DMA 2nd Descriptor test data
    init_mem_bd(
      .bd_addr(`DDR_BA+'h1_1030),
      .flags('h0002),
      .id('h7654),
      .dest_addr(`DDR_BA+'h9000),
      .src_addr(`DDR_BA+'h0000),
      .next_sg_addr(`DDR_BA+'h1_1060),
      .y_len('h0000),
      .x_len('hFFFF));

    // DMA 3rd Descriptor test data
    init_mem_bd(
      .bd_addr(`DDR_BA+'h1_1060),
      .flags('h0002),
      .id('hBA98),
      .dest_addr(`DDR_BA+'hA000),
      .src_addr(`DDR_BA+'h0000),
      .next_sg_addr(`DDR_BA+'h1_1090),
      .y_len('h0000),
      .x_len('hFFFF));

    // DMA 4th Descriptor test data
    init_mem_bd(
      .bd_addr(`DDR_BA+'h1_1090),
      .flags('h0002),
      .id('hFEDC),
      .dest_addr(`DDR_BA+'hB000),
      .src_addr(`DDR_BA+'h0000),
      .next_sg_addr(`DDR_BA+'h1_10C0),
      .y_len('h0000),
      .x_len('hFFFF));

    // DMA 5th Descriptor test data
    init_mem_bd(
      .bd_addr(`DDR_BA+'h1_10C0),
      .flags('h0002),
      .id('hDCDC),
      .dest_addr(`DDR_BA+'hC000),
      .src_addr(`DDR_BA+'h0000),
      .next_sg_addr(`DDR_BA+'h1_10F0),
      .y_len('h0000),
      .x_len('hFFFF));

    // DMA 6th Descriptor test data
    init_mem_bd(
      .bd_addr(`DDR_BA+'h1_10F0),
      .flags('h0002),
      .id('hFEFE),
      .dest_addr(`DDR_BA+'hD000),
      .src_addr(`DDR_BA+'h0000),
      .next_sg_addr(`DDR_BA+'h1_1000),
      .y_len('h0000),
      .x_len('hFFFF));

    //=========================================================================
    // Test RX DMA
    //=========================================================================

    env.adc_src_axis_seq.start();

    // Generate DMA transfers
    `INFO(("Start RX DMA ..."));
    do_sg_transfer(
      .dma_addr(`RX_DMA_BA),
      .control(3'b101),
      .flags(3'b110),
      .irq_mask(3'b001),
      .bd_addr(`DDR_BA+'h1_1000));

    fork
      forever
        wait(`TH.i_rx_dmac.irq) begin
          env.mng.RegRead32(`RX_DMA_BA + GetAddrs(DMAC_PARTIAL_TRANSFER_LENGTH), val);
          `INFO(("PTL: %d", val));
          env.mng.RegRead32(`RX_DMA_BA + GetAddrs(DMAC_PARTIAL_TRANSFER_ID), val);
          `INFO(("PTID: %d", val));

          env.mng.RegRead32(`RX_DMA_BA + GetAddrs(DMAC_DESCRIPTOR_ID), val);
          `INFO(("BDID: %d", val));
          
          env.mng.RegWrite32(`RX_DMA_BA + GetAddrs(DMAC_IRQ_PENDING), 2'b10);
        end
    join_none

    // create data packet of random size within limits
    repeat($urandom_range(5, 10))
      env.adc_src_axis_seq.add_xfer_descriptor($urandom_range(32, 256), 1, 0);

    env.adc_src_axis_seq.wait_empty_descriptor_queue();
    env.scoreboard_rx.wait_until_complete();

    //=========================================================================
    // Test TX DMA
    //=========================================================================

    `INFO(("Start TX DMA ..."));
    for (int i=0; i<8; i++)
      do_sg_transfer(
        .dma_addr(`TX_DMA_BA),
        .control(3'b101),
        .flags(3'b010),
        .irq_mask(3'b001),
        .bd_addr(`DDR_BA+'h1_0000+i*'h30));

    #1us;
    env.scoreboard_tx.wait_until_complete();
        
    env.stop();
    
    `INFO(("Test bench done!"));
    $finish();

  end

  // bring up the DMAC instances from reset
  task systemBringUp();
    `INFO(("Bring up RX DMAC"));
    dmac_rx.enable_dma();
    `INFO(("Bring up TX DMAC"));
    dmac_tx.enable_dma();
  endtask: systemBringUp

  // RX DMA transfer generator
  task rx_dma_transfer(
    input dmac_api dmac, 
    input int xfer_addr, 
    input int xfer_length);

    dmac.set_flags('b110);
    dmac.set_dest_addr(xfer_addr);
    dmac.set_lengths(xfer_length - 1, 0);
    dmac.transfer_start();
  endtask: rx_dma_transfer

  task tx_dma_transfer(
    input dmac_api dmac, 
    input int xfer_addr, 
    input int xfer_length);

    dmac.set_flags('b010); // enable TLAST, CYCLIC
    dmac.set_src_addr(xfer_addr);
    dmac.set_lengths(xfer_length - 1, 0);
    dmac.transfer_start();
  endtask: tx_dma_transfer

  // Memory initialization function for a 8byte DATA_WIDTH AXI4 bus
  task init_mem_64(
    input longint unsigned addr, 
    input int byte_length);

    `INFO(("Initial address: %x", addr));
    for (int i=0; i<byte_length; i=i+8) begin
      env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(addr + i*8, i, 255);
    end
    `INFO(("Final address: %x", addr + byte_length*8));
  endtask: init_mem_64

  // Memory initialization function for a block descriptor
  task init_mem_bd(
    input longint unsigned bd_addr,
    input int flags,
    input int id,
    input longint unsigned dest_addr,
    input longint unsigned src_addr,
    input longint unsigned next_sg_addr,
    input int y_len,
    input int x_len);

    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(bd_addr+'h00, flags,'hF); //flags - irq tlast, last bd
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(bd_addr+'h04, id,'hF); //id
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(bd_addr+'h08, dest_addr,'hF); //dest_addr
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(bd_addr+'h0C, 'h0000,'hF);
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(bd_addr+'h10, src_addr,'hF); //src_addr
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(bd_addr+'h14, 'h0000,'hF);
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(bd_addr+'h18, next_sg_addr,'hF); //next_sg_addr
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(bd_addr+'h1C, 'h0000,'hF);
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(bd_addr+'h20, y_len,'hF); //y_len
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(bd_addr+'h24, x_len,'hF); //x_len
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(bd_addr+'h28, 'h0000,'hF); //src_stride
    env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(bd_addr+'h2C, 'h0000,'hF); //dst_stride
  endtask: init_mem_bd

  // Initialize and start a scatter-gather transfer
  task do_sg_transfer(
    input bit [31:0] dma_addr,
    input bit [31:0] control,
    input bit [31:0] flags,
    input bit [31:0] irq_mask,
    input bit [31:0] bd_addr);

    env.mng.RegWrite32(dma_addr + GetAddrs(DMAC_CONTROL), control); //Enable DMA and set HWDESC
    env.mng.RegWrite32(dma_addr + GetAddrs(DMAC_FLAGS), flags); //Disable all flags
    env.mng.RegWrite32(dma_addr + GetAddrs(DMAC_IRQ_MASK), irq_mask); //mask sot irq
    env.mng.RegWrite32(dma_addr + GetAddrs(DMAC_SG_ADDRESS), bd_addr); //RX descriptor first address
    env.mng.RegWrite32(dma_addr + GetAddrs(DMAC_TRANSFER_SUBMIT), 1'b1);
  endtask: do_sg_transfer

endprogram
