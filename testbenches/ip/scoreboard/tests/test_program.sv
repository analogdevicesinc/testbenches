// ***************************************************************************
// ***************************************************************************
// Copyright (C) 2024 - 2025 Analog Devices, Inc. All rights reserved.
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
//      https://github.com/analogdevicesinc/hdl/blob/main/LICENSE_ADIBSD
//      This will allow to generate bit files and not release the source code,
//      as long as it attaches to an ADI device.
//
// ***************************************************************************
// ***************************************************************************

`include "utils.svh"
`include "axi_definitions.svh"
`include "axis_definitions.svh"

import logger_pkg::*;
import test_harness_env_pkg::*;
import environment_pkg::*;
import adi_axi_agent_pkg::*;
import adi_axis_agent_pkg::*;
import dmac_api_pkg::*;
import data_offload_api_pkg::*;

import `PKGIFY(test_harness, mng_axi_vip)::*;
import `PKGIFY(test_harness, ddr_axi_vip)::*;

import `PKGIFY(test_harness, adc_src_axis_0)::*;
import `PKGIFY(test_harness, dac_dst_axis_0)::*;
import `PKGIFY(test_harness, adc_dst_axi_pt_0)::*;
import `PKGIFY(test_harness, dac_src_axi_pt_0)::*;

import `PKGIFY(test_harness, adc_src_axis_1)::*;
import `PKGIFY(test_harness, dac_dst_axis_1)::*;
import `PKGIFY(test_harness, adc_dst_axi_pt_1)::*;
import `PKGIFY(test_harness, dac_src_axi_pt_1)::*;

`define ADC_TRANSFER_LENGTH 32'h600

program test_program();

  // declare the class instances
  test_harness_env base_env;
  
  adi_axi_master_agent #(`AXI_VIP_PARAMS(test_harness, mng_axi_vip)) mng;
  adi_axi_slave_mem_agent #(`AXI_VIP_PARAMS(test_harness, ddr_axi_vip)) ddr;

  scoreboard_environment scb_env_0;

  adi_axis_master_agent #(`AXIS_VIP_PARAMS(test_harness, adc_src_axis_0)) adc_src_axis_agent_0;
  adi_axis_slave_agent #(`AXIS_VIP_PARAMS(test_harness, dac_dst_axis_0)) dac_dst_axis_agent_0;
  adi_axi_passthrough_mem_agent #(`AXI_VIP_PARAMS(test_harness, adc_dst_axi_pt_0)) adc_dst_axi_pt_agent_0;
  adi_axi_passthrough_mem_agent #(`AXI_VIP_PARAMS(test_harness, dac_src_axi_pt_0)) dac_src_axi_pt_agent_0;

  scoreboard_environment scb_env_1;

  adi_axis_master_agent #(`AXIS_VIP_PARAMS(test_harness, adc_src_axis_1)) adc_src_axis_agent_1;
  adi_axis_slave_agent #(`AXIS_VIP_PARAMS(test_harness, dac_dst_axis_1)) dac_dst_axis_agent_1;
  adi_axi_passthrough_mem_agent #(`AXI_VIP_PARAMS(test_harness, adc_dst_axi_pt_1)) adc_dst_axi_pt_agent_1;
  adi_axi_passthrough_mem_agent #(`AXI_VIP_PARAMS(test_harness, dac_src_axi_pt_1)) dac_src_axi_pt_agent_1;

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
    base_env = new("Base Environment",
                    `TH.`SYS_CLK.inst.IF,
                    `TH.`DMA_CLK.inst.IF,
                    `TH.`DDR_CLK.inst.IF,
                    `TH.`SYS_RST.inst.IF);

    mng = new("", `TH.`MNG_AXI.inst.IF);
    ddr = new("", `TH.`DDR_AXI.inst.IF);
    
    mng.pre_link_agent(base_env.mng);
    ddr.pre_link_agent(base_env.ddr);
    base_env.mng = mng;
    base_env.ddr = ddr;
    mng.post_link_agent(base_env.mng);
    ddr.post_link_agent(base_env.ddr);

    scb_env_0 = new("Scoreboard Environment 0");

    adc_src_axis_agent_0 = new("", `TH.`ADC_SRC_AXIS_0.inst.IF);
    dac_dst_axis_agent_0 = new("", `TH.`DAC_DST_AXIS_0.inst.IF);
    adc_dst_axi_pt_agent_0 = new("", `TH.`ADC_DST_AXI_PT_0.inst.IF);
    dac_src_axi_pt_agent_0 = new("", `TH.`DAC_SRC_AXI_PT_0.inst.IF);

    adc_src_axis_agent_0.pre_link_agent(scb_env_0.adc_src_axis_agent);
    dac_dst_axis_agent_0.pre_link_agent(scb_env_0.dac_dst_axis_agent);
    adc_dst_axi_pt_agent_0.pre_link_agent(scb_env_0.adc_dst_axi_pt_agent);
    dac_src_axi_pt_agent_0.pre_link_agent(scb_env_0.dac_src_axi_pt_agent);
    scb_env_0.adc_src_axis_agent = adc_src_axis_agent_0;
    scb_env_0.dac_dst_axis_agent = dac_dst_axis_agent_0;
    scb_env_0.adc_dst_axi_pt_agent = adc_dst_axi_pt_agent_0;
    scb_env_0.dac_src_axi_pt_agent = dac_src_axi_pt_agent_0;
    adc_src_axis_agent_0.post_link_agent(scb_env_0.adc_src_axis_agent);
    dac_dst_axis_agent_0.post_link_agent(scb_env_0.dac_dst_axis_agent);
    adc_dst_axi_pt_agent_0.post_link_agent(scb_env_0.adc_dst_axi_pt_agent);
    dac_src_axi_pt_agent_0.post_link_agent(scb_env_0.dac_src_axi_pt_agent);

    scb_env_1 = new("Scoreboard Environment 1");

    adc_src_axis_agent_1 = new("", `TH.`ADC_SRC_AXIS_1.inst.IF);
    dac_dst_axis_agent_1 = new("", `TH.`DAC_DST_AXIS_1.inst.IF);
    adc_dst_axi_pt_agent_1 = new("", `TH.`ADC_DST_AXI_PT_1.inst.IF);
    dac_src_axi_pt_agent_1 = new("", `TH.`DAC_SRC_AXI_PT_1.inst.IF);

    adc_src_axis_agent_1.pre_link_agent(scb_env_1.adc_src_axis_agent);
    dac_dst_axis_agent_1.pre_link_agent(scb_env_1.dac_dst_axis_agent);
    adc_dst_axi_pt_agent_1.pre_link_agent(scb_env_1.adc_dst_axi_pt_agent);
    dac_src_axi_pt_agent_1.pre_link_agent(scb_env_1.dac_src_axi_pt_agent);
    scb_env_1.adc_src_axis_agent = adc_src_axis_agent_1;
    scb_env_1.dac_dst_axis_agent = dac_dst_axis_agent_1;
    scb_env_1.adc_dst_axi_pt_agent = adc_dst_axi_pt_agent_1;
    scb_env_1.dac_src_axi_pt_agent = dac_src_axi_pt_agent_1;
    adc_src_axis_agent_1.post_link_agent(scb_env_1.adc_src_axis_agent);
    dac_dst_axis_agent_1.post_link_agent(scb_env_1.dac_dst_axis_agent);
    adc_dst_axi_pt_agent_1.post_link_agent(scb_env_1.adc_dst_axi_pt_agent);
    dac_src_axi_pt_agent_1.post_link_agent(scb_env_1.dac_src_axi_pt_agent);

    dmac_tx_0 = new("DMAC TX 0", base_env.mng.master_sequencer, `TX_DMA_BA_0);
    dmac_rx_0 = new("DMAC RX 0", base_env.mng.master_sequencer, `RX_DMA_BA_0);
    dmac_tx_1 = new("DMAC TX 1", base_env.mng.master_sequencer, `TX_DMA_BA_1);
    dmac_rx_1 = new("DMAC RX 1", base_env.mng.master_sequencer, `RX_DMA_BA_1);

    do_tx_0 = new("Data Offload TX 0", base_env.mng.master_sequencer, `TX_DOFF_BA_0);
    do_rx_0 = new("Data Offload RX 0", base_env.mng.master_sequencer, `RX_DOFF_BA_0);
    do_tx_1 = new("Data Offload TX 1", base_env.mng.master_sequencer, `TX_DOFF_BA_1);
    do_rx_1 = new("Data Offload RX 1", base_env.mng.master_sequencer, `RX_DOFF_BA_1);

    //=========================================================================
    // Setup generator/monitor stubs
    //=========================================================================

    //=========================================================================

    setLoggerVerbosity(ADI_VERBOSITY_NONE);
    
    base_env.start();
    scb_env_0.start();
    scb_env_1.start();

    base_env.sys_reset();

    // configure environment sequencers
    scb_env_0.configure(`ADC_TRANSFER_LENGTH);
    scb_env_1.configure(`ADC_TRANSFER_LENGTH);

    `INFO(("Bring up IP from reset."), ADI_VERBOSITY_LOW);
    systemBringUp();

    //do_set_transfer_length(`ADC_TRANSFER_LENGTH);
    do_set_transfer_length(`ADC_TRANSFER_LENGTH/64);
    
    // Start the ADC/DAC stubs
    `INFO(("Start the sequencer"), ADI_VERBOSITY_LOW);
    scb_env_0.adc_src_axis_agent.master_sequencer.start();
    scb_env_1.adc_src_axis_agent.master_sequencer.start();

    // Generate DMA transfers
    `INFO(("Start RX DMA"), ADI_VERBOSITY_LOW);
    rx_dma_transfer(dmac_rx_0, 32'h80000000, `ADC_TRANSFER_LENGTH);
    rx_dma_transfer(dmac_rx_1, 32'h80000000, `ADC_TRANSFER_LENGTH);

    fork
      scb_env_0.scoreboard_rx.wait_until_complete();
      scb_env_1.scoreboard_rx.wait_until_complete();
    join

    `INFO(("Initialize the memory"), ADI_VERBOSITY_LOW);
    init_mem_64(32'h80000000, 1024);

    `INFO(("Start TX DMA"), ADI_VERBOSITY_LOW);
    tx_dma_transfer(dmac_tx_0, 32'h80000000, 1024);
    tx_dma_transfer(dmac_tx_1, 32'h80000000, 1024);

    #1us;
    fork
      scb_env_0.scoreboard_tx.wait_until_complete();
      scb_env_1.scoreboard_tx.wait_until_complete();
    join

    scb_env_0.stop();
    scb_env_1.stop();
    base_env.stop();
    
    `INFO(("Test bench done!"), ADI_VERBOSITY_NONE);
    $finish();

  end

  task systemBringUp();
    // bring up the Data Offload instances from reset
    `INFO(("Bring up RX Data Offload 0"), ADI_VERBOSITY_LOW);
    do_rx_0.deassert_reset();
    `INFO(("Bring up TX Data Offload 0"), ADI_VERBOSITY_LOW);
    do_tx_0.deassert_reset();

    `INFO(("Bring up RX Data Offload 1"), ADI_VERBOSITY_LOW);
    do_rx_1.deassert_reset();
    `INFO(("Bring up TX Data Offload 1"), ADI_VERBOSITY_LOW);
    do_tx_1.deassert_reset();

    // Enable tx oneshot mode
    do_tx_0.enable_oneshot_mode();
    do_tx_1.enable_oneshot_mode();

    // bring up the DMAC instances from reset
    `INFO(("Bring up RX DMAC 0"), ADI_VERBOSITY_LOW);
    dmac_rx_0.enable_dma();
    `INFO(("Bring up TX DMAC 0"), ADI_VERBOSITY_LOW);
    dmac_tx_0.enable_dma();

    `INFO(("Bring up RX DMAC 1"), ADI_VERBOSITY_LOW);
    dmac_rx_1.enable_dma();
    `INFO(("Bring up TX DMAC 1"), ADI_VERBOSITY_LOW);
    dmac_tx_1.enable_dma();
  endtask

  task do_set_transfer_length(input int length);
    do_rx_0.set_transfer_length(length);
    do_rx_1.set_transfer_length(length);
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

  // TX DMA transfer generator
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
    `INFO(("Initial address: %x", addr), ADI_VERBOSITY_LOW);
    for (int i=0; i<byte_length; i=i+8) begin
      // base_env.ddr.agent.mem_model.backdoor_memory_write_4byte(addr + i*8, i, 255);
      ddr.agent.mem_model.backdoor_memory_write_4byte(addr + i*8, i, 255);
    end
    `INFO(("Final address: %x", addr + byte_length*8), ADI_VERBOSITY_LOW);
  endtask

endprogram
