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
import data_offload_api_pkg::*;

`define ADC_TRANSFER_LENGTH 32'h600

program test_program;

  // declare the class instances
  environment env;

  dmac_api dmac_tx_0;
  dmac_api dmac_rx_0;
  dmac_api dmac_tx_1;
  dmac_api dmac_rx_1;

  data_offload_api do_tx_0;
  data_offload_api do_rx_0;
  data_offload_api do_tx_1;
  data_offload_api do_rx_1;

  initial begin

    // create environment
    env = new(`TH.`SYS_CLK.inst.IF,
              `TH.`DMA_CLK.inst.IF,
              `TH.`DDR_CLK.inst.IF,
              `TH.`SYS_RST.inst.IF,
              `TH.`MNG_AXI.inst.IF,
              `TH.`DDR_AXI.inst.IF,

              `TH.`ADC_SRC_AXIS_0.inst.IF,
              `TH.`DAC_DST_AXIS_0.inst.IF,
              `TH.`ADC_DST_AXI_PT_0.inst.IF,
              `TH.`DAC_SRC_AXI_PT_0.inst.IF

              // `TH.`ADC_SRC_AXIS_1.inst.IF,
              // `TH.`DAC_DST_AXIS_1.inst.IF,
              // `TH.`ADC_DST_AXI_PT_1.inst.IF,
              // `TH.`DAC_SRC_AXI_PT_1.inst.IF
             );

    dmac_tx_0 = new("DMAC TX 0", env.mng, `TX_DMA_BA_0);
    dmac_rx_0 = new("DMAC RX 0", env.mng, `RX_DMA_BA_0);
    // dmac_tx_1 = new("DMAC TX 1", env.mng, `TX_DMA_BA_1);
    // dmac_rx_1 = new("DMAC RX 1", env.mng, `RX_DMA_BA_1);

    do_tx_0 = new("Data Offload TX 0", env.mng, `TX_DOFF_BA_0);
    do_rx_0 = new("Data Offload RX 0", env.mng, `RX_DOFF_BA_0);
    // do_tx_1 = new("Data Offload TX 1", env.mng, `TX_DOFF_BA_1);
    // do_rx_1 = new("Data Offload RX 1", env.mng, `RX_DOFF_BA_1);

    #1step;

    //=========================================================================
    // Setup generator/monitor stubs
    //=========================================================================

    // configure environment sequencers
    env.configure(`ADC_TRANSFER_LENGTH);

    //=========================================================================

    setLoggerVerbosity(250);
    
    env.start();
    env.sys_reset();

    // configure environment sequencers
    env.configure(`ADC_TRANSFER_LENGTH);

    `INFO(("Bring up IP from reset."));
    systemBringUp();

    //do_set_transfer_length(`ADC_TRANSFER_LENGTH);
    do_set_transfer_length(`ADC_TRANSFER_LENGTH/64);
    
    // Start the ADC/DAC stubs
    `INFO(("Call the run() ..."));
    env.run();

    env.adc_src_axis_seq_0.start();
    // env.adc_src_axis_seq_1.start();

    // Generate DMA transfers
    #100
    `INFO(("Start RX DMA ..."));
    rx_dma_transfer(dmac_rx_0, 32'h80000000, `ADC_TRANSFER_LENGTH);
    // rx_dma_transfer(dmac_rx_1, 32'h80000000, `ADC_TRANSFER_LENGTH);

    #10000
    `INFO(("Initialize the memory ..."));
    init_mem_64(32'h80000000, 1024);

    `INFO(("Start TX DMA ..."));
    tx_dma_transfer(dmac_tx_0, 32'h80000000, 1024);
    // tx_dma_transfer(dmac_tx_1, 32'h80000000, 1024);

    #10000;
        
    env.stop();
    
    `INFO(("Test bench done!"));
    $finish();

  end

  task systemBringUp();

    // bring up the Data Offload instances from reset

    `INFO(("Bring up RX Data Offload 0"));
    do_rx_0.deassert_reset();
    `INFO(("Bring up TX Data Offload 0"));
    do_tx_0.deassert_reset();

    // `INFO(("Bring up RX Data Offload 1"));
    // do_rx_1.deassert_reset();
    // `INFO(("Bring up TX Data Offload 1"));
    // do_tx_1.deassert_reset();

    // Enable tx oneshot mode
    do_tx_0.enable_oneshot_mode();

    // do_tx_1.enable_oneshot_mode();

    // bring up the DMAC instances from reset

    `INFO(("Bring up RX DMAC 0"));
    dmac_rx_0.enable_dma();
    `INFO(("Bring up TX DMAC 0"));
    dmac_tx_0.enable_dma();

    // `INFO(("Bring up RX DMAC 1"));
    // dmac_rx_1.enable_dma();
    // `INFO(("Bring up TX DMAC 1"));
    // dmac_tx_1.enable_dma();

  endtask

  task do_set_transfer_length(input int length);
    do_rx_0.set_transfer_length(length);

    // do_rx_1.set_transfer_length(length);
  endtask

  // RX DMA transfer generator

  task rx_dma_transfer(
    input dmac_api dmac, 
    input int xfer_addr, 
    input int xfer_length);
    dmac.set_flags('b110);
    dmac.set_dest_addr(xfer_addr);
    dmac.set_lengths(xfer_length - 1, 0);
    dmac.transfer_start();
  endtask

  task tx_dma_transfer(
    input dmac_api dmac, 
    input int xfer_addr, 
    input int xfer_length);
    dmac.set_flags('b010); // enable TLAST, CYCLIC
    dmac.set_src_addr(xfer_addr);
    dmac.set_lengths(xfer_length - 1, 0);
    dmac.transfer_start();
  endtask

  // Memory initialization function for a 8byte DATA_WIDTH AXI4 bus
  task init_mem_64(
    input longint unsigned addr, 
    input int byte_length);
    `INFO(("Initial address: %x", addr));
    for (int i=0; i<byte_length; i=i+8) begin
      env.ddr_axi_agent.mem_model.backdoor_memory_write_4byte(addr + i*8, i, 255);
    end
    `INFO(("Final address: %x", addr + byte_length*8));
  endtask

endprogram
