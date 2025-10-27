// ***************************************************************************
// ***************************************************************************
// Copyright (C) 2021-2025 Analog Devices, Inc. All rights reserved.
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
`include "axi_definitions.svh"
`include "axis_definitions.svh"

import logger_pkg::*;
import test_harness_env_pkg::*;
import environment_pkg::*;
import dmac_api_pkg::*;
import data_offload_api_pkg::*;

import `PKGIFY(test_harness, mng_axi_vip)::*;
import `PKGIFY(test_harness, ddr_axi_vip)::*;

import `PKGIFY(test_harness, adc_src_axis)::*;
import `PKGIFY(test_harness, adc_dst_axi)::*;
import `PKGIFY(test_harness, dac_src_axi)::*;
import `PKGIFY(test_harness, dac_dst_axis)::*;

`define ADC_TRANSFER_LENGTH 32'h600

program test_program;

  timeunit 1ns;
  timeprecision 1ps;

  // declare the class instances
  test_harness_env #(`AXI_VIP_PARAMS(test_harness, mng_axi_vip), `AXI_VIP_PARAMS(test_harness, ddr_axi_vip)) base_env;
  scoreboard_environment #(
    `AXIS_VIP_PARAMS(test_harness, adc_src_axis), `AXI_VIP_PARAMS(test_harness, adc_dst_axi),
    `AXI_VIP_PARAMS(test_harness, dac_src_axi), `AXIS_VIP_PARAMS(test_harness, dac_dst_axis)) scb_env;

  dmac_api dmac_tx;
  dmac_api dmac_rx;

  data_offload_api do_tx;
  data_offload_api do_rx;

  initial begin

    // create environment
    base_env = new("Base Environment",
                    `TH.`SYS_CLK.inst.IF,
                    `TH.`DMA_CLK.inst.IF,
                    `TH.`DDR_CLK.inst.IF,
                    `TH.`SYS_RST.inst.IF,
                    `TH.`MNG_AXI.inst.IF,
                    `TH.`DDR_AXI.inst.IF);

    scb_env = new("Scoreboard Environment 0",
                  `TH.`ADC_SRC_AXIS.inst.IF,
                  `TH.`ADC_DST_AXI.inst.IF,
                  `TH.`DAC_SRC_AXI.inst.IF,
                  `TH.`DAC_DST_AXIS.inst.IF);

    dmac_tx = new("DMAC TX 0", base_env.mng.master_sequencer, `TX_DMA_BA);
    dmac_rx = new("DMAC RX 0", base_env.mng.master_sequencer, `RX_DMA_BA);

    do_tx = new("Data Offload TX 0", base_env.mng.master_sequencer, `TX_DOFF_BA);
    do_rx = new("Data Offload RX 0", base_env.mng.master_sequencer, `RX_DOFF_BA);

    //=========================================================================
    // Setup generator/monitor stubs
    //=========================================================================

    //=========================================================================

    setLoggerVerbosity(ADI_VERBOSITY_NONE);

    base_env.start();
    scb_env.start();

    base_env.sys_reset();

    // configure environment sequencers
    scb_env.configure(`ADC_TRANSFER_LENGTH);

    `INFO(("Bring up IP from reset."), ADI_VERBOSITY_LOW);
    systemBringUp();

    //do_set_transfer_length(`ADC_TRANSFER_LENGTH);
    do_set_transfer_length(`ADC_TRANSFER_LENGTH/64);

    // Start the ADC/DAC stubs
    `INFO(("Call the run()"), ADI_VERBOSITY_LOW);
    scb_env.run();

    scb_env.adc_src_axis_agent.master_sequencer.start();

    // Generate DMA transfers
    `INFO(("Start RX DMA"), ADI_VERBOSITY_LOW);
    rx_dma_transfer(dmac_rx, 32'h80000000, `ADC_TRANSFER_LENGTH);

    scb_env.scoreboard_rx.wait_until_complete();

    `INFO(("Initialize the memory"), ADI_VERBOSITY_LOW);
    init_mem_64(32'h80000000, 1024);

    `INFO(("Start TX DMA"), ADI_VERBOSITY_LOW);
    tx_dma_transfer(dmac_tx, 32'h80000000, 1024);

    #1us;
    scb_env.scoreboard_tx.wait_until_complete();

    scb_env.stop();
    base_env.stop();

    `INFO(("Test bench done!"), ADI_VERBOSITY_NONE);
    $finish();

  end

  task systemBringUp();
    // bring up the Data Offload instances from reset
    `INFO(("Bring up RX Data Offload 0"), ADI_VERBOSITY_LOW);
    do_rx.deassert_reset();
    `INFO(("Bring up TX Data Offload 0"), ADI_VERBOSITY_LOW);
    do_tx.deassert_reset();

    // Enable tx oneshot mode
    do_tx.enable_oneshot_mode();

    // bring up the DMAC instances from reset
    `INFO(("Bring up RX DMAC 0"), ADI_VERBOSITY_LOW);
    dmac_rx.enable_dma();
    `INFO(("Bring up TX DMAC 0"), ADI_VERBOSITY_LOW);
    dmac_tx.enable_dma();
  endtask

  task do_set_transfer_length(input int length);
    do_rx.set_transfer_length(length);
  endtask

  // RX DMA transfer generator
  task rx_dma_transfer(
    input dmac_api dmac,
    input int xfer_addr,
    input int xfer_length);
    dmac.set_flags(
      .cyclic(1'b0),
      .tlast(1'b1),
      .partial_reporting_en(1'b1));
    dmac.set_dest_addr(xfer_addr);
    dmac.set_lengths(xfer_length - 1, 0);
    dmac.transfer_start();
  endtask

  // TX DMA transfer generator
  task tx_dma_transfer(
    input dmac_api dmac,
    input int xfer_addr,
    input int xfer_length);
    dmac.set_flags(
      .cyclic(1'b0),
      .tlast(1'b1),
      .partial_reporting_en(1'b0));
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
      base_env.ddr.slave_sequencer.BackdoorWrite32(addr + i*8, i, 255);
    end
    `INFO(("Final address: %x", addr + byte_length*8), ADI_VERBOSITY_LOW);
  endtask

endprogram
