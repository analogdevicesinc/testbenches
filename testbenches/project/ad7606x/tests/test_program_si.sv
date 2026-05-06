// ***************************************************************************
// ***************************************************************************
// Copyright (C) 2022-2026 Analog Devices, Inc. All rights reserved.
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
//
//

`include "utils.svh"

import axi_vip_pkg::*;
import axi4stream_vip_pkg::*;
import logger_pkg::*;
import test_harness_env_pkg::*;
import adi_axi_agent_pkg::*;
import spi_environment_pkg::*;
import spi_engine_api_pkg::*;
import spi_engine_instr_pkg::*;
import dmac_api_pkg::*;
import pwm_gen_api_pkg::*;
import clk_gen_api_pkg::*;
import adi_spi_vip_pkg::*;

import `PKGIFY(test_harness, mng_axi_vip)::*;
import `PKGIFY(test_harness, ddr_axi_vip)::*;

program test_program_si (
  input  spi_clk,
  input  ad7606_irq);

  timeunit 1ns;
  timeprecision 1ps;

  test_harness_env base_env;

  adi_axi_master_agent #(`AXI_VIP_PARAMS(test_harness, mng_axi_vip)) mng;
  adi_axi_slave_mem_agent #(`AXI_VIP_PARAMS(test_harness, ddr_axi_vip)) ddr;

  spi_environment spi_env;
  spi_engine_api spi_api;
  dmac_api dma_api;
  pwm_gen_api pwm_api;
  clk_gen_api clkgen_api;

  // --------------------------
  // Wrapper function for SPI receive (from DUT via MOSI)
  // --------------------------
  task automatic spi_receive(
      ref int unsigned data[]);
    spi_env.spi_agent.sequencer.receive_data(data);
  endtask

  // --------------------------
  // Wrapper function for SPI send (to DUT via MISO)
  // --------------------------
  task spi_send(
      input [`DATA_DLENGTH-1:0] data[]);
    spi_env.spi_agent.sequencer.send_data(data);
  endtask

  // --------------------------
  // Wrapper function for waiting for all SPI TX to complete
  // --------------------------
  task spi_wait_send();
    spi_env.spi_agent.sequencer.flush_send();
  endtask

  // --------------------------
  // Main procedure
  // --------------------------
  initial begin

    //creating environment
    base_env = new(
      .name("Base Environment"),
      .sys_clk_vip_if(`TH.`SYS_CLK.inst.IF),
      .dma_clk_vip_if(`TH.`DMA_CLK.inst.IF),
      .ddr_clk_vip_if(`TH.`DDR_CLK.inst.IF),
      .sys_rst_vip_if(`TH.`SYS_RST.inst.IF),
      .irq_base_address(`IRQ_C_BA),
      .irq_vip_if(`TH.`IRQ.inst.inst.IF.vif));

    mng = new("", `TH.`MNG_AXI.inst.IF);
    ddr = new("", `TH.`DDR_AXI.inst.IF);

    `LINK(mng, base_env, mng)
    `LINK(ddr, base_env, ddr)

    spi_env = new("SPI Engine Environment",
                  `TH.`SPI_S.inst.IF.vif);

    spi_api = new("SPI Engine API",
                  base_env.mng.master_sequencer,
                  `SPI_AD7606_REGMAP_BA);

    dma_api = new("RX DMA API",
                  base_env.mng.master_sequencer,
                  `AD7606X_DMA_BA);

    clkgen_api = new("CLKGEN API",
                     base_env.mng.master_sequencer,
                     `AD7606X_AXI_CLKGEN_BA);

    pwm_api = new("PWM API",
                  base_env.mng.master_sequencer,
                  `AXI_PWMGEN_BA);

    setLoggerVerbosity(ADI_VERBOSITY_NONE);

    base_env.start();
    spi_env.start();

    base_env.sys_reset();

    // Set default MISO data
    spi_env.spi_agent.sequencer.set_default_miso_data('hAA55AA55);

    sanity_tests();

    init();

    fifo_spi_test();

    offload_spi_test();

    spi_env.stop();
    base_env.stop();

    `INFO(("Test Done"), ADI_VERBOSITY_NONE);
    $finish();

  end

  //---------------------------------------------------------------------------
  // Sanity test reg interface
  //---------------------------------------------------------------------------

  task sanity_tests();
    spi_api.sanity_test();
    dma_api.sanity_test();
    pwm_api.sanity_test();
  endtask

  //---------------------------------------------------------------------------
  // Test initialization
  //---------------------------------------------------------------------------

  task init();
    // Start spi clk generator
    `ifdef AD7606X_AXI_CLKGEN_BA
      clkgen_api.enable_clkgen();
    `endif

    // Config pwm
    pwm_api.reset();
    pwm_api.pulse_period_config(0, 'h64);
    pwm_api.load_config();
    pwm_api.start();
    `INFO(("axi_pwm_gen started."), ADI_VERBOSITY_LOW);

    // Enable SPI Engine
    spi_api.enable_spi_engine();

    // Configure the execution module
    spi_api.fifo_command(`INST_CFG);
    spi_api.fifo_command(`INST_PRESCALE);
    spi_api.fifo_command(`INST_DLENGTH);
    spi_api.fifo_command(`INST_SDI_LANE_MASK);
    spi_api.fifo_command(`INST_SDO_LANE_MASK);

    // Set up the interrupts
    spi_api.set_interrup_mask(.sync_event(1'b1), .offload_sync_id_pending(1'b1));
  endtask

  //---------------------------------------------------------------------------
  // SPI Engine generate transfer
  //---------------------------------------------------------------------------

  task generate_transfer_cmd(
   input [7:0] sync_id);

    // Configure lane masks
    spi_api.fifo_command(`INST_SDI_LANE_MASK);
    spi_api.fifo_command(`INST_SDO_LANE_MASK);
    // assert CSN
    spi_api.fifo_command(`SET_CS(8'hFE));
    // transfer data
    spi_api.fifo_command(`INST_WRD);
    // de-assert CSN
    spi_api.fifo_command(`SET_CS(8'hFF));
    // SYNC command to generate interrupt
    spi_api.fifo_command(`INST_SYNC | sync_id);
    `INFO(("Transfer generation finished."), ADI_VERBOSITY_LOW);
  endtask

  //---------------------------------------------------------------------------
  // IRQ callback
  //---------------------------------------------------------------------------

  reg [4:0] irq_pending = 5'b0;
  reg [7:0] sync_id = 8'b0;

  initial begin
    forever begin
      @(posedge ad7606_irq);
      // read pending IRQs
      spi_api.get_irq_pending(irq_pending);
      // IRQ launched by Offload SYNC command
      if (spi_api.check_irq_offload_sync_id_pending(irq_pending)) begin
        spi_api.get_sync_id(sync_id);
        `INFO(("Offload SYNC %0d IRQ. An offload transfer just finished.", sync_id), ADI_VERBOSITY_LOW);
      end
      // IRQ launched by SYNC command
      if (spi_api.check_irq_sync_event(irq_pending)) begin
        spi_api.get_sync_id(sync_id);
        `INFO(("SYNC %0d IRQ. FIFO transfer just finished.", sync_id), ADI_VERBOSITY_LOW);
      end
      // IRQ launched by SDI FIFO
      if (spi_api.check_irq_sdi_almost_full(irq_pending)) begin
        `INFO(("SDI FIFO IRQ."), ADI_VERBOSITY_LOW);
      end
      // IRQ launched by SDO FIFO
      if (spi_api.check_irq_sdo_almost_empty(irq_pending)) begin
        `INFO(("SDO FIFO IRQ."), ADI_VERBOSITY_LOW);
      end
      // IRQ launched by CMD FIFO
      if (spi_api.check_irq_cmd_almost_empty(irq_pending)) begin
        `INFO(("CMD FIFO IRQ."), ADI_VERBOSITY_LOW);
      end
      // Clear all pending IRQs
      spi_api.clear_irq_pending(irq_pending);
    end
  end

  //---------------------------------------------------------------------------
  // Offload SPI Test
  //---------------------------------------------------------------------------

  task offload_spi_test();
    bit offload_test_passed;
    int unsigned tx_data_cast [];
    bit [`DATA_DLENGTH-1:0] tx_data [];
    int unsigned sdo_offload_data [];
    int unsigned offload_sdo_captured [];
    bit [`DATA_DLENGTH-1:0] rx_data [];
    bit [`DATA_DLENGTH-1:0] offload_captured_word_arr [];
    bit [`DATA_DLENGTH-1:0] offload_sdi_data_store_arr [];
    bit [`DATA_DLENGTH-1:0] offload_sdo_data_store_arr [];

    offload_test_passed         = 1'b1;
    tx_data_cast                = new[`NUM_OF_MOSI];
    tx_data                     = new[`NUM_OF_MOSI];
    sdo_offload_data            = new[`NUM_OF_MOSI];
    offload_sdo_captured        = new[`NUM_OF_MOSI];
    rx_data                     = new[`NUM_OF_MISO];
    offload_captured_word_arr   = new[`NUM_OF_TRANSFERS * `NUM_OF_WORDS * `NUM_OF_MISO];
    offload_sdi_data_store_arr  = new[`NUM_OF_TRANSFERS * `NUM_OF_WORDS * `NUM_OF_MISO];
    offload_sdo_data_store_arr  = new[`NUM_OF_WORDS * `NUM_OF_MOSI];

    // Configure DMA
    dma_api.enable_dma();
    dma_api.set_flags(
      .cyclic(1'b0),
      .tlast(1'b1),
      .partial_reporting_en(1'b1));
    dma_api.set_lengths((`NUM_OF_TRANSFERS * `NUM_OF_WORDS * `NUM_OF_MISO * (`DATA_WIDTH/8))-1, 0);
    dma_api.set_dest_addr(`DDR_BA);
    dma_api.transfer_start();

    // Configure the Offload module
    spi_api.fifo_offload_command(`INST_CFG);
    spi_api.fifo_offload_command(`INST_PRESCALE);
    spi_api.fifo_offload_command(`INST_DLENGTH);
    spi_api.fifo_offload_command(`SET_CS(8'hFE));
    spi_api.fifo_offload_command(`INST_WRD);
    spi_api.fifo_offload_command(`SET_CS(8'hFF));
    spi_api.fifo_offload_command(`INST_SYNC | 2);

    // Enqueue transfers to DUT
    for (int i = 0; i < (`NUM_OF_TRANSFERS * `NUM_OF_WORDS); i++) begin
      // Generate random SDI data for each lane
      for (int j = 0; j < `NUM_OF_MISO; j++) begin
        rx_data[j] = $urandom;
        offload_sdi_data_store_arr[i * `NUM_OF_MISO + j] = rx_data[j];
      end
      spi_send(rx_data);

      // Generate random SDO data for each lane
      for (int j = 0; j < `NUM_OF_MOSI; j++) begin
        tx_data[j] = $urandom;
        tx_data_cast[j] = tx_data[j];
      end

      // Only write to offload FIFO for first NUM_OF_WORDS (it cycles)
      if (i < `NUM_OF_WORDS) begin
        for (int j = 0; j < `NUM_OF_MOSI; j++) begin
          offload_sdo_data_store_arr[i * `NUM_OF_MOSI + j] = tx_data[j];
        end
        spi_api.sdo_offload_fifo_write(tx_data_cast);
      end
    end

    // Start the offload
    spi_api.start_offload();
    `INFO(("Offload started."), ADI_VERBOSITY_LOW);

    // Wait for VIP to complete all sends (all transfers done)
    spi_wait_send();

    spi_api.stop_offload();
    `INFO(("Offload stopped."), ADI_VERBOSITY_LOW);

    #2000ns;

    // Compare SDI data (read from DMA destination in DDR memory)
    // DMA packing note: DMA_DATA_WIDTH_SRC = DATA_WIDTH × NUM_OF_SDIO.
    // When DATA_WIDTH < 32, multiple lane values are packed into each 32-bit memory word.
    // For ad7616 (DATA_WIDTH=16, NUM_OF_SDIO=2): 32-bit DMA, 2 lanes packed per memory word.
    // For ad7606x (DATA_WIDTH=32): 64-bit DMA, 1 lane per memory word (no packing).
    begin
      int num_mem_words = (`NUM_OF_TRANSFERS * `NUM_OF_WORDS * `NUM_OF_MISO * `DATA_WIDTH) / 32;
      int lanes_per_word = 32 / `DATA_WIDTH;
      int lane_idx = 0;
      logic [31:0] mem_word;

      for (int i = 0; i < num_mem_words; i++) begin
        mem_word = base_env.ddr.slave_sequencer.BackdoorRead32(xil_axi_uint'(`DDR_BA + 4*i));
        for (int j = 0; j < lanes_per_word; j++) begin
          offload_captured_word_arr[lane_idx] = mem_word[j*`DATA_WIDTH +: `DATA_WIDTH];
          if (offload_captured_word_arr[lane_idx] != offload_sdi_data_store_arr[lane_idx]) begin
            `INFO(("offload_captured_word_arr[%0d]: %x; offload_sdi_data_store_arr[%0d]: %x",
                   lane_idx, offload_captured_word_arr[lane_idx],
                   lane_idx, offload_sdi_data_store_arr[lane_idx]), ADI_VERBOSITY_LOW);
            offload_test_passed = 1'b0;
          end
          lane_idx++;
        end
      end
    end
    if (offload_test_passed) begin
      `INFO(("Offload Read Test PASSED"), ADI_VERBOSITY_LOW);
    end else begin
      `ERROR(("Offload Read Test FAILED"));
    end

    // Reset flag for SDO comparison
    offload_test_passed = 1'b1;

    // Compare SDO data (received by VIP, cycles through NUM_OF_WORDS)
    for (int i = 0; i < (`NUM_OF_TRANSFERS * `NUM_OF_WORDS); i++) begin
      spi_receive(offload_sdo_captured);
      for (int j = 0; j < `NUM_OF_MOSI; j++) begin
        if (offload_sdo_captured[j] != offload_sdo_data_store_arr[(i * `NUM_OF_MOSI + j) % (`NUM_OF_WORDS * `NUM_OF_MOSI)]) begin
          `INFO(("offload_sdo_captured[%0d]: %x; offload_sdo_data_store_arr[%0d]: %x",
                 j, offload_sdo_captured[j],
                 (i * `NUM_OF_MOSI + j) % (`NUM_OF_WORDS * `NUM_OF_MOSI),
                 offload_sdo_data_store_arr[(i * `NUM_OF_MOSI + j) % (`NUM_OF_WORDS * `NUM_OF_MOSI)]), ADI_VERBOSITY_LOW);
          offload_test_passed = 1'b0;
        end
      end
    end
    if (offload_test_passed) begin
      `INFO(("Offload Write Test PASSED"), ADI_VERBOSITY_LOW);
    end else begin
      `ERROR(("Offload Write Test FAILED"));
    end
  endtask

  //---------------------------------------------------------------------------
  // FIFO SPI Test
  //---------------------------------------------------------------------------

  task fifo_spi_test();
    bit fifo_test_passed;
    bit [7:0] sdi_lane_mask;
    bit [7:0] sdo_lane_mask;
    int num_of_active_sdo_lanes;
    logic [31:0] rx_data_cast [];
    bit [`DATA_DLENGTH-1:0] rx_data [];
    bit [`DATA_DLENGTH-1:0] sdi_fifo_data [];
    bit [`DATA_DLENGTH-1:0] sdi_fifo_data_store [];
    bit [`DATA_DLENGTH-1:0] tx_data [];
    int unsigned tx_data_cast [];
    int unsigned receive_data [];
    bit [`DATA_DLENGTH-1:0] sdo_fifo_data [];
    bit [`DATA_DLENGTH-1:0] sdo_fifo_data_store [];

    fifo_test_passed    = 1'b1;
    sdi_lane_mask       = (2**`NUM_OF_MISO)-1;
    sdo_lane_mask       = (2**`NUM_OF_MOSI)-1;
    num_of_active_sdo_lanes = $countones(sdo_lane_mask);

    rx_data_cast        = new[`NUM_OF_MISO];
    rx_data             = new[`NUM_OF_MISO];
    sdi_fifo_data       = new[`NUM_OF_MISO * `NUM_OF_WORDS];
    sdi_fifo_data_store = new[`NUM_OF_MISO * `NUM_OF_WORDS];
    tx_data             = new[num_of_active_sdo_lanes];
    tx_data_cast        = new[num_of_active_sdo_lanes];
    receive_data        = new[`NUM_OF_MOSI];
    sdo_fifo_data       = new[`NUM_OF_MOSI * `NUM_OF_WORDS];
    sdo_fifo_data_store = new[`NUM_OF_MOSI * `NUM_OF_WORDS];

    // Generate a FIFO transaction
    for (int i = 0; i < `NUM_OF_WORDS; i++) begin
      // Generate random SDI data for each lane
      for (int j = 0; j < `NUM_OF_MISO; j++) begin
        rx_data[j] = sdi_lane_mask[j] ? $urandom : `SDO_IDLE_STATE;
        sdi_fifo_data_store[i * `NUM_OF_MISO + j] = rx_data[j];
      end

      // Generate random SDO data for active lanes only
      for (int j = 0; j < num_of_active_sdo_lanes; j++) begin
        tx_data[j] = $urandom;
        tx_data_cast[j] = tx_data[j];
      end

      // Store SDO data accounting for lane mask
      for (int j = 0, k = 0; j < `NUM_OF_MOSI; j++) begin
        if (sdo_lane_mask[j]) begin
          sdo_fifo_data_store[i * `NUM_OF_MOSI + j] = tx_data[k];
          k++;
        end else begin
          sdo_fifo_data_store[i * `NUM_OF_MOSI + j] = `SDO_IDLE_STATE;
        end
      end

      spi_api.sdo_fifo_write(tx_data_cast);
      spi_send(rx_data);
    end

    generate_transfer_cmd(1);

    // Wait for VIP to complete send
    spi_wait_send();

    // Read SDI FIFO and receive SDO data
    for (int i = 0; i < `NUM_OF_WORDS; i++) begin
      spi_api.sdi_fifo_read(rx_data_cast);
      spi_receive(receive_data);
      for (int j = 0; j < `NUM_OF_MISO; j++) begin
        sdi_fifo_data[i * `NUM_OF_MISO + j] = rx_data_cast[j];
      end
      for (int j = 0; j < `NUM_OF_MOSI; j++) begin
        sdo_fifo_data[i * `NUM_OF_MOSI + j] = receive_data[j];
      end
    end

    // Compare SDI data
    foreach (sdi_fifo_data[i]) begin
      if (sdi_fifo_data[i] !== sdi_fifo_data_store[i]) begin
        `INFO(("sdi_fifo_data[%0d]: %x; sdi_fifo_data_store[%0d]: %x",
               i, sdi_fifo_data[i], i, sdi_fifo_data_store[i]), ADI_VERBOSITY_LOW);
        fifo_test_passed = 1'b0;
      end
    end
    if (fifo_test_passed) begin
      `INFO(("Fifo Read Test PASSED"), ADI_VERBOSITY_LOW);
    end else begin
      `ERROR(("Fifo Read Test FAILED"));
    end

    // Reset flag for SDO comparison
    fifo_test_passed = 1'b1;

    // Compare SDO data
    foreach (sdo_fifo_data[i]) begin
      if (sdo_fifo_data[i] !== sdo_fifo_data_store[i]) begin
        `INFO(("sdo_fifo_data[%0d]: %x; sdo_fifo_data_store[%0d]: %x",
               i, sdo_fifo_data[i], i, sdo_fifo_data_store[i]), ADI_VERBOSITY_LOW);
        fifo_test_passed = 1'b0;
      end
    end
    if (fifo_test_passed) begin
      `INFO(("Fifo Write Test PASSED"), ADI_VERBOSITY_LOW);
    end else begin
      `ERROR(("Fifo Write Test FAILED"));
    end
  endtask

endprogram
