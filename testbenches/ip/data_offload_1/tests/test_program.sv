// ***************************************************************************
// ***************************************************************************
// Copyright (C) 2021-2026 Analog Devices, Inc. All rights reserved.
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
import adi_axi_agent_pkg::*;
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

  // Declare the class instances
  test_harness_env base_env;
  environment #(
    `AXIS_VIP_PARAMS(test_harness, adc_src_axis), `AXI_VIP_PARAMS(test_harness, adc_dst_axi),
    `AXI_VIP_PARAMS(test_harness, dac_src_axi), `AXIS_VIP_PARAMS(test_harness, dac_dst_axis)) test_env;
  adi_axi_master_agent #(`AXI_VIP_PARAMS(test_harness, mng_axi_vip)) mng;
  adi_axi_slave_mem_agent #(`AXI_VIP_PARAMS(test_harness, ddr_axi_vip)) ddr;

  dmac_api dmac_tx;
  dmac_api dmac_rx;

  data_offload_api do_tx;
  data_offload_api do_rx;

  initial begin

    // Create environment
    base_env = new(
      .name("Base Environment"),
      .sys_clk_vip_if(`TH.`SYS_CLK.inst.IF),
      .dma_clk_vip_if(`TH.`DMA_CLK.inst.IF),
      .ddr_clk_vip_if(`TH.`DDR_CLK.inst.IF),
      .sys_rst_vip_if(`TH.`SYS_RST.inst.IF),
      .irq_base_address(`IRQ_C_BA),
      .irq_vip_if(`TH.`IRQ.inst.inst.IF.vif));

    mng = new(.name(""), .master_vip_if(`TH.`MNG_AXI.inst.IF));
    ddr = new(.name(""), .slave_vip_if(`TH.`DDR_AXI.inst.IF));

    `LINK(mng, base_env, mng)
    `LINK(ddr, base_env, ddr)

    test_env = new(
      .name("Test Environment"),
      .adc_src_axis_vip_if(`TH.`ADC_SRC_AXIS.inst.IF),
      .adc_dst_if(`TH.`ADC_DST_AXI.inst.IF),
      .dac_src_if(`TH.`DAC_SRC_AXI.inst.IF),
      .dac_dst_axis_vip_if(`TH.`DAC_DST_AXIS.inst.IF));

    dmac_tx = new(
      .name("DMAC TX"),
      .bus(base_env.mng.master_sequencer),
      .base_address(`TX_DMA_BA));

    dmac_rx = new(
      .name("DMAC RX"),
      .bus(base_env.mng.master_sequencer),
      .base_address(`RX_DMA_BA));

    do_tx = new(
      .name("Data Offload TX"),
      .bus(base_env.mng.master_sequencer),
      .base_address(`TX_DOFF_BA));

    do_rx = new(
      .name("Data Offload RX"),
      .bus(base_env.mng.master_sequencer),
      .base_address(`RX_DOFF_BA));

    setLoggerVerbosity(ADI_VERBOSITY_NONE);

    base_env.start();
    test_env.start();

    base_env.sys_reset();

    // Configure environment sequencers
    test_env.configure(`ADC_TRANSFER_LENGTH);

    `INFO(("Bring up IP from reset."), ADI_VERBOSITY_LOW);
    systemBringUp();

    do_set_transfer_length(`ADC_TRANSFER_LENGTH/64);

    // Start the ADC/DAC stubs
    `INFO(("Call the run()"), ADI_VERBOSITY_LOW);
    test_env.run();

    test_env.adc_src_axis_agent.master_sequencer.start();

    // Generate DMA transfers
    `INFO(("Start RX DMA"), ADI_VERBOSITY_LOW);
    rx_dma_transfer(dmac_rx, 32'h80000000, `ADC_TRANSFER_LENGTH);

    test_env.scoreboard_rx.wait_until_complete();

    `INFO(("Initialize the memory"), ADI_VERBOSITY_LOW);
    init_mem_64(32'h80000000, 1024);

    `INFO(("Start TX DMA"), ADI_VERBOSITY_LOW);
    tx_dma_transfer(dmac_tx, 32'h80000000, 1024);

    #1us;
    test_env.scoreboard_tx.wait_until_complete();

    test_env.stop();
    base_env.stop();

    `INFO(("Test bench done!"), ADI_VERBOSITY_NONE);
    $finish();

  end

  task systemBringUp();
    // Bring up the Data Offload instances from reset
    `INFO(("Bring up RX Data Offload"), ADI_VERBOSITY_LOW);
    do_rx.deassert_reset();
    `INFO(("Bring up TX Data Offload"), ADI_VERBOSITY_LOW);
    do_tx.deassert_reset();

    // Enable tx oneshot mode
    do_tx.enable_oneshot_mode();

    // Bring up the DMAC instances from reset
    `INFO(("Bring up RX DMAC"), ADI_VERBOSITY_LOW);
    dmac_rx.enable_dma();
    `INFO(("Bring up TX DMAC"), ADI_VERBOSITY_LOW);
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
