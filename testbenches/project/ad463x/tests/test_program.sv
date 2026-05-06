// ***************************************************************************
// ***************************************************************************
// Copyright (C) 2014-2026 Analog Devices, Inc. All rights reserved.
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

import axi_vip_pkg::*;
import axi4stream_vip_pkg::*;
import logger_pkg::*;
import test_harness_env_pkg::*;
import adi_axi_agent_pkg::*;
import watchdog_pkg::*;
import spi_engine_api_pkg::*;
import dmac_api_pkg::*;
import pwm_gen_api_pkg::*;
import clk_gen_api_pkg::*;
import spi_engine_instr_pkg::*;

import `PKGIFY(test_harness, mng_axi_vip)::*;
import `PKGIFY(test_harness, ddr_axi_vip)::*;

program test_program (
  input ad463x_irq,
  input ad463x_cnv,
  output ad463x_busy,
  output reg ad463x_echo_sclk,
  output reg ad463x_ext_clk,
  input ad463x_spi_sclk,
  input ad463x_spi_cs,
  input ad463x_spi_clk,
  input ad463x_spi_sdo,
  output [(`NUM_OF_MISO - 1):0] ad463x_spi_sdi);

  timeunit 1ns;
  timeprecision 100ps;

  // declare the class instances
  test_harness_env base_env;

  adi_axi_master_agent #(`AXI_VIP_PARAMS(test_harness, mng_axi_vip)) mng;
  adi_axi_slave_mem_agent #(`AXI_VIP_PARAMS(test_harness, ddr_axi_vip)) ddr;

  spi_engine_api spi_api;
  dmac_api dma_api;
  pwm_gen_api pwm_api;
  clk_gen_api clkgen_api;
  watchdog fifo_data_rd;

  // Lane mask variables
  bit [7:0] sdi_lane_mask = `MISO_LANE_MASK;
  int num_of_active_sdi_lanes = $countones(`MISO_LANE_MASK);

  // SDO capture variables (FIFO mode - per-transfer capture)
  bit [31:0] sdo_shiftreg = 32'd0;
  bit [31:0] sdo_captured_data = 32'd0;
  bit [31:0] sdo_expected_data = 32'd0;
  bit [5:0]  sdo_capture_cnt = 6'b0;

  // SDO capture variables (Offload mode - continuous capture)
  // Buffer holds all SDO bits during entire offload period
  // Max: 2*NUM_OF_TRANSFERS * 32 bits = up to 640 bits for NUM_OF_TRANSFERS=10
  localparam SDO_OFFLOAD_BUFFER_BITS = 2 * `NUM_OF_TRANSFERS * 32;
  bit [SDO_OFFLOAD_BUFFER_BITS-1:0] sdo_offload_buffer = '0;
  int sdo_offload_bit_cnt = 0;

  // --------------------------
  // Main procedure
  // --------------------------
  initial begin

    setLoggerVerbosity(ADI_VERBOSITY_NONE);

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

    spi_api = new("SPI Engine API",
                  base_env.mng.master_sequencer,
                  `SPI_AD469X_REGMAP_BA);

    dma_api = new("RX DMA API",
                  base_env.mng.master_sequencer,
                  `AD469X_DMA_BA);

    clkgen_api = new("CLKGEN API",
                    base_env.mng.master_sequencer,
                    `AD463X_AXI_CLKGEN_BA);

    pwm_api = new("PWM API",
                  base_env.mng.master_sequencer,
                  `AD469X_PWM_GEN_BA);

    base_env.start();
    base_env.sys_reset();

    sanity_tests();

    init();

    fifo_spi_test();

    offload_spi_test();

    // Disable all IRQs before stopping to prevent race with IRQ handler
    spi_api.set_interrup_mask();

    base_env.stop();

    `INFO(("Test Done"), ADI_VERBOSITY_NONE);
    $finish();

  end

  //---------------------------------------------------------------------------
  // SPI Engine generate transfer
  //---------------------------------------------------------------------------

  task generate_transfer_cmd(
      input [7:0] sync_id,
      input [7:0] lane_mask = `MISO_LANE_MASK);
    // Set lane masks (SDO is always 1 lane for AD463x)
    spi_api.fifo_command(`SET_SDI_LANE_MASK(lane_mask));
    spi_api.fifo_command(`SET_SDO_LANE_MASK(`MOSI_LANE_MASK));
    // assert CSN
    spi_api.fifo_command(`SET_CS(8'hFE));
    // transfer data (read + write)
    spi_api.fifo_command(`INST_WRD);
    // de-assert CSN
    spi_api.fifo_command(`SET_CS(8'hFF));
    // SYNC command to generate interrupt
    spi_api.fifo_command((`INST_SYNC | sync_id));
    `INFO(("Transfer generation finished."), ADI_VERBOSITY_LOW);
  endtask

  //---------------------------------------------------------------------------
  // IRQ callback
  //---------------------------------------------------------------------------

  reg [4:0] irq_pending = 5'b0;
  reg [7:0] sync_id = 8'b0;

  initial begin
    forever begin
      @(posedge ad463x_irq);
      // read pending IRQs
      spi_api.get_irq_pending(irq_pending);
      // IRQ launched by Offload SYNC command
      if (spi_api.check_irq_offload_sync_id_pending(irq_pending)) begin
        spi_api.get_sync_id(sync_id);
        `INFO(("Offload SYNC %0d IRQ. An offload transfer just finished.",  sync_id), ADI_VERBOSITY_LOW);
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
  // Echo SCLK generation
  //---------------------------------------------------------------------------
  initial begin
    forever @(ad463x_spi_sclk) begin
      ad463x_echo_sclk <= #(18ns) ad463x_spi_sclk;
    end
  end

  //---------------------------------------------------------------------------
  // External CLK generation
  //---------------------------------------------------------------------------
  initial begin
    ad463x_ext_clk = 1'b0;
    forever #5ns ad463x_ext_clk = ~ad463x_ext_clk;
  end

  assign ad463x_busy = (`CAPTURE_ZONE == 2) ? ad463x_echo_sclk : ad463x_cnv;

  //---------------------------------------------------------------------------
  // SDO capture - captures data sent by SPI Engine on SDO pin
  //---------------------------------------------------------------------------
  // SDO capture uses spi_sclk (the clock from the SPI Engine master).
  // The SPI Engine shifts SDO on spi_sclk, so we sample on spi_sclk posedge.
  //
  // Two capture modes:
  // 1. FIFO mode (!offload_status): per-transfer capture into sdo_shiftreg
  // 2. Offload mode (offload_status): continuous capture into sdo_offload_buffer
  //
  // Note: Uses m_spi_csn_negedge_s for CSN edge detection (defined below in SDI section)
  initial forever @(posedge ad463x_spi_sclk or posedge m_spi_csn_negedge_s) begin
    if (m_spi_csn_negedge_s) begin
      // CSN negedge - reset per-transfer shiftreg
      sdo_shiftreg <= 32'd0;
      sdo_capture_cnt <= 6'b0;
    end else if (!ad463x_spi_cs) begin
      // FIFO mode: per-transfer capture
      sdo_shiftreg <= {sdo_shiftreg[30:0], ad463x_spi_sdo};
      sdo_capture_cnt <= sdo_capture_cnt + 1;
      // Offload mode: continuous capture into large buffer
      if (offload_status && sdo_offload_bit_cnt < SDO_OFFLOAD_BUFFER_BITS) begin
        sdo_offload_buffer[sdo_offload_bit_cnt] <= ad463x_spi_sdo;
        sdo_offload_bit_cnt <= sdo_offload_bit_cnt + 1;
      end
    end
  end

  //---------------------------------------------------------------------------
  // SDI data generator
  //---------------------------------------------------------------------------
  //
  // Simplified for CPOL=0, CPHA=0 only (the only mode supported by this project).
  //
  // Key timing differences:
  //   CLK_MODE=0 (SPI Engine): Hardware samples on POSEDGE of echo_sclk
  //                            => TB must shift on NEGEDGE so data stable at posedge
  //   CLK_MODE=1 (ad463x_data_capture SDR): Hardware samples on NEGEDGE of echo_sclk
  //                            => TB must shift on POSEDGE so data stable at negedge
  //
  //---------------------------------------------------------------------------

  wire          m_spi_csn_negedge_s;
  wire          m_spi_csn_posedge_s;
  logic         ad463x_spi_cs_d = 1'b0;
  bit   [31:0]  sdi_shiftreg [`NUM_OF_MISO-1:0];       // Per-lane shift registers
  bit   [ 7:0]  spi_sclk_edge_counter = 8'b0;
  bit   [31:0]  random_word [`NUM_OF_MISO-1:0];        // Per-lane random data

  // Initialize per-lane random data
  initial begin
    for (int lane = 0; lane < `NUM_OF_MISO; lane++) begin
      random_word[lane] = $urandom();
      sdi_shiftreg[lane] = 32'd0;
    end
  end

  // CSN edge detection
  initial begin
    forever begin
      @(posedge ad463x_spi_clk);
      ad463x_spi_cs_d <= ad463x_spi_cs;
    end
  end

  assign m_spi_csn_negedge_s = ~ad463x_spi_cs & ad463x_spi_cs_d;
  assign m_spi_csn_posedge_s = ad463x_spi_cs & ~ad463x_spi_cs_d;

  // Each SDI lane outputs its own data (MSB of per-lane shift register)
  genvar i;
  for (i = 0; i < `NUM_OF_MISO; i++) begin
    assign ad463x_spi_sdi[i] = sdi_shiftreg[i][31];
  end

  // Generate new random word for next transfer
  // CLOCKS_PER_WORD = number of SCLK cycles per word (always DATA_DLENGTH)
  // For DDR: SDI shifts on both edges (2x shifts per word)
  // For SDR: SDI shifts on one edge only
  localparam CLOCKS_PER_WORD = `DATA_DLENGTH;

  initial begin
    forever begin
      @(posedge ad463x_echo_sclk or posedge m_spi_csn_negedge_s);
      if (m_spi_csn_negedge_s) begin
        spi_sclk_edge_counter <= 8'b0;
      end else begin
        spi_sclk_edge_counter <= (spi_sclk_edge_counter == CLOCKS_PER_WORD) ? 0 : spi_sclk_edge_counter + 1;
        if (spi_sclk_edge_counter == CLOCKS_PER_WORD - 1) begin
          // Generate new random data for each lane
          for (int lane = 0; lane < `NUM_OF_MISO; lane++) begin
            random_word[lane] <= $urandom();
          end
        end
      end
    end
  end

  // SDI shift register update task
  // Load random_word at CSN negedge or end of word, otherwise shift left
  task sdi_shiftreg_update();
    if (m_spi_csn_negedge_s || spi_sclk_edge_counter == CLOCKS_PER_WORD) begin
      for (int lane = 0; lane < `NUM_OF_MISO; lane++) begin
        sdi_shiftreg[lane] <= random_word[lane];
      end
    end else begin
      for (int lane = 0; lane < `NUM_OF_MISO; lane++) begin
        sdi_shiftreg[lane] <= {sdi_shiftreg[lane][30:0], 1'b0};
      end
    end
  endtask

  // SDI shift register - timing depends on CLK_MODE
  // CLK_MODE=0: shift on negedge (data stable at posedge for SPI Engine)
  // CLK_MODE=1: shift on posedge (data stable at negedge for ad463x_data_capture)
  generate
    if (`CLK_MODE == 0) begin : gen_clk_mode_0_sdi
      initial forever begin
        @(negedge ad463x_echo_sclk or posedge m_spi_csn_negedge_s);
        sdi_shiftreg_update();
      end
    end else begin : gen_clk_mode_1_sdi
      if (`DDR_EN == 0) begin : gen_sdr_sdi
        // CLK_MODE=1 SDR: ad463x_data_capture captures on negedge, so shift on posedge
        initial forever begin
          @(posedge ad463x_echo_sclk or posedge m_spi_csn_negedge_s);
          sdi_shiftreg_update();
        end
      end else begin : gen_ddr_sdi
        // CLK_MODE=1 DDR: ad463x_data_capture captures on BOTH edges
        initial forever begin
          @(negedge ad463x_echo_sclk or posedge ad463x_echo_sclk or posedge m_spi_csn_negedge_s);
          sdi_shiftreg_update();
        end
      end
    end
  endgenerate

  //---------------------------------------------------------------------------
  // Expected Data Capture - mirrors what hardware actually captures
  //---------------------------------------------------------------------------
  //
  // Instead of trying to capture sdi_shiftreg at the right moment,
  // we track exactly what the hardware samples on each clock edge.
  //
  // CLK_MODE=0 (SPI Engine): captures on posedge of echo_sclk
  // CLK_MODE=1 (ad463x_data_capture SDR): captures on negedge of echo_sclk
  // CLK_MODE=1 (ad463x_data_capture DDR): captures on both edges
  //
  //---------------------------------------------------------------------------

  bit         offload_status = 1'b0;
  bit [31:0]  offload_sdi_data_store_arr [(2 * `NUM_OF_TRANSFERS) - 1:0];
  bit [31:0]  sdi_fifo_data_store;

  // Calculate effective capture clocks based on mode
  // DATA_DLENGTH is bits PER LANE (not total)
  // CAPTURE_CLOCKS = number of SCLK cycles the hardware runs (always DATA_DLENGTH)
  // For DDR: both edges capture, but we still have DATA_DLENGTH SCLK cycles
  //
  // NOTE: For DDR mode, DATA_DLENGTH=32 is inefficient - only 16 SCLK cycles would
  // be needed since ad463x_data_capture captures on both edges (32 bits from 16 cycles).
  // However, we keep DATA_DLENGTH=32 because the FIFO path uses the SPI Engine which
  // only captures SDR (posedge). With DATA_DLENGTH=16, FIFO would only get 16 bits
  // while offload would correctly get 32 bits. Using DATA_DLENGTH=32 ensures both
  // paths receive 32 bits, at the cost of running twice as many SCLK cycles for DDR
  // offload mode (the first 16 cycles' data is discarded by the hardware).
  localparam BITS_PER_LANE = `DATA_DLENGTH;
  localparam CAPTURE_CLOCKS = `DATA_DLENGTH;

  // Hardware capture simulation - tracks what each lane captures
  bit [31:0]  hw_captured_data [`NUM_OF_MISO-1:0];  // per-lane capture
  bit [31:0]  hw_captured_data_p [`NUM_OF_MISO-1:0]; // posedge capture for DDR
  bit [31:0]  hw_captured_data_n [`NUM_OF_MISO-1:0]; // negedge capture for DDR
  bit [5:0]   hw_capture_cnt = 6'b0;
  bit         hw_capture_done = 1'b0;
  bit         hw_capture_done_d = 1'b0;
  bit [15:0]  offload_store_idx = 16'b0;

  // For 1-lane interleaved mode: need to collect 2 consecutive words
  bit [31:0]  hw_captured_word0 = 32'd0;  // first word of pair
  bit [31:0]  hw_captured_word1 = 32'd0;  // second word of pair
  bit         interleave_word_idx = 1'b0;   // 0 = collecting first word, 1 = collecting second
  bit         interleave_word_idx_d = 1'b0; // delayed for edge detection
  wire        interleave_pair_done = interleave_word_idx_d && !interleave_word_idx; // falling edge = pair complete

  // Capture data as hardware does
  generate
    if (`CLK_MODE == 0) begin : gen_clk_mode_0_capture
      // CLK_MODE=0: SPI Engine captures on posedge
      // For multi-lane: CAPTURE_CLOCKS = BITS_PER_LANE (since CLK_MODE=0 is always SDR)
      initial forever @(posedge ad463x_echo_sclk or posedge m_spi_csn_negedge_s) begin
        if (m_spi_csn_negedge_s) begin
          hw_capture_cnt <= 6'b0;
          hw_capture_done <= 1'b0;
          for (int lane = 0; lane < `NUM_OF_MISO; lane++) begin
            hw_captured_data[lane] <= 32'd0;
          end
        end else if (!ad463x_spi_cs) begin
          if (hw_capture_cnt < CAPTURE_CLOCKS) begin
            // Capture current SDI value (what's on the wire right now)
            for (int lane = 0; lane < `NUM_OF_MISO; lane++) begin
              hw_captured_data[lane] <= {hw_captured_data[lane][30:0], ad463x_spi_sdi[lane]};
            end
          end
          hw_capture_cnt <= hw_capture_cnt + 1;
          hw_capture_done <= (hw_capture_cnt == CAPTURE_CLOCKS - 1);
        end
      end
    end else begin : gen_clk_mode_1_capture
      if (`DDR_EN == 0) begin : gen_sdr_capture
        // CLK_MODE=1 SDR: Two capture paths with different timing:
        // - Offload path: ad463x_data_capture samples on NEGEDGE → hw_captured_data
        // - FIFO path: SPI Engine samples on POSEDGE → hw_captured_data_p
        //
        // Negedge capture (for offload expected data)
        initial forever @(negedge ad463x_echo_sclk or posedge m_spi_csn_negedge_s) begin
          if (m_spi_csn_negedge_s) begin
            hw_capture_cnt <= 6'b0;
            hw_capture_done <= 1'b0;
            for (int lane = 0; lane < `NUM_OF_MISO; lane++) begin
              hw_captured_data[lane] <= 32'd0;
            end
          end else if (!ad463x_spi_cs) begin
            if (hw_capture_cnt < CAPTURE_CLOCKS) begin
              for (int lane = 0; lane < `NUM_OF_MISO; lane++) begin
                hw_captured_data[lane] <= {hw_captured_data[lane][30:0], ad463x_spi_sdi[lane]};
              end
            end
            hw_capture_cnt <= hw_capture_cnt + 1;
            hw_capture_done <= (hw_capture_cnt == CAPTURE_CLOCKS - 1);
          end
        end
        // Posedge capture (for FIFO expected data - SPI Engine samples on posedge)
        initial forever @(posedge ad463x_echo_sclk or posedge m_spi_csn_negedge_s) begin
          if (m_spi_csn_negedge_s) begin
            for (int lane = 0; lane < `NUM_OF_MISO; lane++) begin
              hw_captured_data_p[lane] <= 32'd0;
            end
          end else if (!ad463x_spi_cs && hw_capture_cnt < CAPTURE_CLOCKS) begin
            for (int lane = 0; lane < `NUM_OF_MISO; lane++) begin
              hw_captured_data_p[lane] <= {hw_captured_data_p[lane][30:0], ad463x_spi_sdi[lane]};
            end
          end
        end
      end else begin : gen_ddr_capture
        // CLK_MODE=1 DDR: ad463x_data_capture captures on both edges
        // Note: CAPTURE_CLOCKS = DATA_DLENGTH (32) even though DDR only needs 16 cycles.
        // This inefficiency is accepted because FIFO path uses SDR-only SPI Engine.
        // See comment at CAPTURE_CLOCKS definition for details.
        // Negedge capture (for offload expected data)
        initial forever @(negedge ad463x_echo_sclk or posedge m_spi_csn_negedge_s) begin
          // hw_data_shiftreg_update();
          if (m_spi_csn_negedge_s) begin
            hw_capture_cnt <= 6'b0;
            hw_capture_done <= 1'b0;
            for (int lane = 0; lane < `NUM_OF_MISO; lane++) begin
              hw_captured_data_n[lane] <= 32'd0;
            end
          end else if (!ad463x_spi_cs) begin
            if (hw_capture_cnt < CAPTURE_CLOCKS) begin
              for (int lane = 0; lane < `NUM_OF_MISO; lane++) begin
                hw_captured_data_n[lane] <= {hw_captured_data_n[lane][30:0], ad463x_spi_sdi[lane]};
              end
            end
            hw_capture_cnt <= hw_capture_cnt + 1;
            hw_capture_done <= (hw_capture_cnt == CAPTURE_CLOCKS - 1);
          end
        end

        // Posedge capture (for FIFO expected data)
        initial forever @(posedge ad463x_echo_sclk or posedge m_spi_csn_negedge_s) begin
          if (m_spi_csn_negedge_s) begin
            for (int lane = 0; lane < `NUM_OF_MISO; lane++) begin
              hw_captured_data_p[lane] <= 32'd0;
            end
          end else if (!ad463x_spi_cs && hw_capture_cnt < CAPTURE_CLOCKS) begin
            for (int lane = 0; lane < `NUM_OF_MISO; lane++) begin
              hw_captured_data_p[lane] <= {hw_captured_data_p[lane][30:0], ad463x_spi_sdi[lane]};
            end
          end
        end
      end
    end
  endgenerate

  // Store expected data when capture completes
  initial forever @(posedge ad463x_spi_clk) begin
    hw_capture_done_d <= hw_capture_done;
    interleave_word_idx_d <= interleave_word_idx;

    // Rising edge of hw_capture_done
    if (hw_capture_done && !hw_capture_done_d) begin
      if (`NUM_OF_MISO == 1 && `NO_REORDER == 0 && offload_status) begin
        // 1-lane interleaved mode (OFFLOAD ONLY): collect 2 words before storing
        // FIFO path doesn't use spi_axis_reorder, so no interleaving needed
        if (interleave_word_idx == 0) begin
          hw_captured_word0 <= hw_captured_data[0];
          interleave_word_idx <= 1'b1;
        end else begin
          hw_captured_word1 <= hw_captured_data[0];
          interleave_word_idx <= 1'b0;
        end
      end else begin
        // All other modes: store immediately
        if (offload_status) begin
          store_offload_expected_data();
        end else begin
          store_fifo_expected_data();
        end
      end
    end

    // For 1-lane interleaved: store when pair is complete (falling edge of interleave_word_idx)
    if (interleave_pair_done) begin
      if (offload_status) begin
        store_offload_expected_data();
      end else begin
        store_fifo_expected_data();
      end
    end
  end

  // Store FIFO expected data
  task store_fifo_expected_data();
    // FIFO path always uses SPI Engine capture (samples on POSEDGE)
    // This is different from Offload path which uses ad463x_data_capture for CLK_MODE=1
    // DDR mode only affects ad463x_data_capture, not SPI Engine FIFO
    if (`CLK_MODE == 0) begin
      // CLK_MODE=0: hw_captured_data is captured on posedge
      sdi_fifo_data_store = hw_captured_data[0];
    end else begin
      // CLK_MODE=1: use hw_captured_data_p (posedge capture for SPI Engine)
      // Note: hw_captured_data is negedge (for ad463x_data_capture offload path)
      sdi_fifo_data_store = hw_captured_data_p[0];
    end
  endtask

  // Store Offload expected data with proper packing
  task store_offload_expected_data();
    bit [31:0] packed_data_ch0;
    bit [31:0] packed_data_ch1;

    pack_captured_data(packed_data_ch0, packed_data_ch1);

    // Store based on number of lanes and reorder mode
    if (`NUM_OF_MISO == 1 && `NO_REORDER == 1) begin
      // 1-lane NO_REORDER: single word per transfer
      offload_sdi_data_store_arr[offload_store_idx] = packed_data_ch0;
      offload_store_idx = offload_store_idx + 1;
    end else begin
      // All other modes: 2 words per transfer
      // - 1-lane interleaved (NO_REORDER=0): reorder outputs 2 words from 2 input words
      // - 2+ lanes: 2 words per transfer (reorder applied for 4/8 lanes)
      offload_sdi_data_store_arr[offload_store_idx] = packed_data_ch0;
      offload_sdi_data_store_arr[offload_store_idx + 1] = packed_data_ch1;
      offload_store_idx = offload_store_idx + 2;
    end
  endtask

  // Pack captured data with spi_axis_reorder logic
  // Handles both SDR (DDR_EN=0) and DDR (DDR_EN=1) modes
  task pack_captured_data(output bit [31:0] ch0, output bit [31:0] ch1);
    bit [31:0] lane_data [7:0];
    bit [31:0] word0, word1;

    // Step 1: Prepare lane data (apply DDR interleaving if needed)
    if (`DDR_EN == 1) begin
      // DDR: interleave posedge and negedge captures
      // Hardware formula: m_axis_data[j*2 +: 2] = {data_shift_p[j], data_shift_n[j]}
      // Use only lower 16 bits of captured data (matching hardware)
      for (int lane = 0; lane < `NUM_OF_MISO; lane++) begin
        lane_data[lane] = 32'd0;
        for (int j = 0; j < 16; j++) begin
          lane_data[lane][j*2]   = hw_captured_data_n[lane][j];
          lane_data[lane][j*2+1] = hw_captured_data_p[lane][j];
        end
      end
    end else begin
      // SDR: use captured data directly
      for (int lane = 0; lane < `NUM_OF_MISO; lane++) begin
        lane_data[lane] = hw_captured_data[lane];
      end
    end

    // Step 2: Prepare word0/word1 for 1-lane interleaved mode
    if (`NUM_OF_MISO == 1 && `NO_REORDER == 0) begin
      if (`DDR_EN == 1) begin
        // DDR: apply interleaving to captured words
        for (int j = 0; j < 16; j++) begin
          word0[j*2]   = hw_captured_word0[j];
          word0[j*2+1] = hw_captured_word0[16+j];
          word1[j*2]   = hw_captured_word1[j];
          word1[j*2+1] = hw_captured_word1[16+j];
        end
      end else begin
        // SDR: use directly
        word0 = hw_captured_word0;
        word1 = hw_captured_word1;
      end
    end

    // Step 3: Apply spi_axis_reorder logic (identical for SDR and DDR)
    ch0 = 32'd0;
    ch1 = 32'd0;

    if (`NUM_OF_MISO == 1) begin
      if (`NO_REORDER == 0) begin
        // 1-lane interleaved: odd/even split across 2 words
        // ch0 gets odd bits, ch1 gets even bits
        for (int i = 0; i < 16; i++) begin
          ch0[i]    = word0[2*i+1];      // word0 odd bits
          ch0[16+i] = word1[2*i+1];      // word1 odd bits
          ch1[i]    = word0[2*i];        // word0 even bits
          ch1[16+i] = word1[2*i];        // word1 even bits
        end
      end else begin
        // NO_REORDER: pass-through
        ch0 = lane_data[0];
        ch1 = 32'd0;
      end
    end else if (`NUM_OF_MISO == 2) begin
      // 2 lanes: pass-through
      ch0 = lane_data[0];
      ch1 = lane_data[1];
    end else if (`NUM_OF_MISO == 4) begin
      // 4 lanes: reorder interleaves lane pairs
      for (int i = 0; i < 16; i++) begin
        ch0[2*i]   = lane_data[1][i];  // lane 1
        ch0[2*i+1] = lane_data[0][i];  // lane 0
        ch1[2*i]   = lane_data[3][i];  // lane 3
        ch1[2*i+1] = lane_data[2][i];  // lane 2
      end
    end else if (`NUM_OF_MISO == 8) begin
      // 8 lanes: reorder interleaves 4 lanes per channel
      for (int i = 0; i < 8; i++) begin
        ch0[4*i]   = lane_data[3][i];  // lane 3
        ch0[4*i+1] = lane_data[2][i];  // lane 2
        ch0[4*i+2] = lane_data[1][i];  // lane 1
        ch0[4*i+3] = lane_data[0][i];  // lane 0
        ch1[4*i]   = lane_data[7][i];  // lane 7
        ch1[4*i+1] = lane_data[6][i];  // lane 6
        ch1[4*i+2] = lane_data[5][i];  // lane 5
        ch1[4*i+3] = lane_data[4][i];  // lane 4
      end
    end else begin
      // Default pass-through
      ch0 = lane_data[0];
      ch1 = lane_data[1];
    end
  endtask

  //---------------------------------------------------------------------------
  // Offload Transfer Counter
  //---------------------------------------------------------------------------

  bit [31:0] offload_transfer_cnt = 0;

  // Count transfers based on mode
  // For 1-lane interleaved: count after pair is complete
  // For all other modes: count after each hw_capture_done
  initial forever @(posedge ad463x_spi_clk) begin
    if (`NUM_OF_MISO == 1 && `NO_REORDER == 0) begin
      // 1-lane interleaved: count when pair is done
      if (interleave_pair_done && offload_status) begin
        offload_transfer_cnt <= offload_transfer_cnt + 1;
      end
    end else begin
      // All other modes: count on hw_capture_done rising edge
      if (hw_capture_done && !hw_capture_done_d && offload_status) begin
        offload_transfer_cnt <= offload_transfer_cnt + 1;
      end
    end
  end

  //---------------------------------------------------------------------------
  // Sanity Tests
  //---------------------------------------------------------------------------

  task sanity_tests();
    spi_api.sanity_test();
    dma_api.sanity_test();
    pwm_api.sanity_test();
  endtask

  //---------------------------------------------------------------------------
  // Offload SPI Test
  //---------------------------------------------------------------------------

  // Fixed-size arrays - sized for max case (2*NUM_OF_TRANSFERS for interleaved mode)
  // XSIM doesn't support non-blocking assignment to dynamic arrays
  bit [31:0] offload_sdi_captured_arr [2 * `NUM_OF_TRANSFERS];
  bit [31:0] offload_sdo_captured_arr [2 * `NUM_OF_TRANSFERS];
  bit [31:0] offload_sdo_data [2 * `NUM_OF_TRANSFERS];
  bit offload_test_passed = 1'b1;

  task offload_spi_test();
    int num_hw_transfers;
    bit [31:0] extracted_word;
    logic [31:0] sdo_offload_write_data [];

    // For single-lane (NUM_OF_SDIO==1), hardware does 2*NUM_OF_TRANSFERS SPI transactions
    // to fill the DMA buffer (32 bits per transfer vs 64 bits for multi-lane).
    // For multi-lane, hardware does NUM_OF_TRANSFERS transactions.
    num_hw_transfers = (`NUM_OF_MISO == 1) ? 2*`NUM_OF_TRANSFERS : `NUM_OF_TRANSFERS;

    // Generate SDO write data
    // SDO offload memory has limited depth - only write NUM_OF_WORDS entries
    // These entries repeat for all transfers (hardware cycles through them)
    sdo_offload_write_data = new[`NUM_OF_WORDS];
    for (int i = 0; i < `NUM_OF_WORDS; i++) begin
      offload_sdo_data[i] = $urandom();
      sdo_offload_write_data[i] = offload_sdo_data[i];
    end
    spi_api.sdo_offload_fifo_write(sdo_offload_write_data);

    //Configure DMA
    dma_api.enable_dma();
    dma_api.set_flags(
      .cyclic(1'b0),
      .tlast(1'b1),
      .partial_reporting_en(1'b1));
    dma_api.set_lengths((2*`NUM_OF_TRANSFERS*(`DATA_WIDTH/8)) - 1, 0);
    dma_api.set_dest_addr(`DDR_BA);
    dma_api.transfer_start();

    // Configure the Offload module
    // Note: Lane masks are set in init() via fifo_command, not in offload sequence
    spi_api.fifo_offload_command(`INST_CFG);
    spi_api.fifo_offload_command(`INST_PRESCALE);
    spi_api.fifo_offload_command(`INST_DLENGTH);
    spi_api.fifo_offload_command(`SET_CS(8'hFE));
    spi_api.fifo_offload_command(`INST_WRD);
    spi_api.fifo_offload_command(`SET_CS(8'hFF));
    spi_api.fifo_offload_command(`INST_SYNC | 2);

    // Reset offload tracking
    offload_store_idx = 16'b0;
    offload_transfer_cnt = 32'd0;
    interleave_word_idx = 1'b0;
    interleave_word_idx_d = 1'b0;
    // Reset SDO offload buffer
    sdo_offload_buffer = '0;
    sdo_offload_bit_cnt = 0;
    offload_status = 1'b1;

    spi_api.start_offload();
    `INFO(("Offload started."), ADI_VERBOSITY_LOW);

    // Wait for all transfers to complete
    // Counter behavior:
    // - Interleaved (NUM_OF_SDIO==1 && NO_REORDER==0): counts pairs → reaches NUM_OF_TRANSFERS
    // - All other modes: counts each hw_capture_done → reaches num_hw_transfers
    if (`NUM_OF_MISO == 1 && `NO_REORDER == 0) begin
      wait(offload_transfer_cnt == `NUM_OF_TRANSFERS);
    end else begin
      wait(offload_transfer_cnt == num_hw_transfers);
    end

    spi_api.stop_offload();
    offload_status = 1'b0;
    `INFO(("Offload stopped. Captured %0d SDO bits.", sdo_offload_bit_cnt), ADI_VERBOSITY_LOW);

    // Extract captured SDO data from continuous buffer
    // Data was captured LSB-first (bit 0 is first captured bit)
    // Need to reverse to MSB-first format (matching how SDO was shifted out)
    for (int i = 0; i < num_hw_transfers; i++) begin
      extracted_word = 32'd0;
      for (int b = 0; b < 32; b++) begin
        // Bit (i*32 + b) in buffer corresponds to bit (31-b) in word
        // because SPI shifts MSB first, but we capture in order received
        extracted_word[31-b] = sdo_offload_buffer[i*32 + b];
      end
      offload_sdo_captured_arr[i] = extracted_word;
    end

    dma_api.wait_transfer_done(0);

    for (int i = 0; i < (2 * `NUM_OF_TRANSFERS); i++) begin
      offload_sdi_captured_arr[i] = base_env.ddr.slave_sequencer.BackdoorRead32(xil_axi_uint'(`DDR_BA) + 4*i);
    end

    if (irq_pending == 'h0) begin
      `FATAL(("IRQ Test FAILED"));
    end else begin
      `INFO(("IRQ Test PASSED"), ADI_VERBOSITY_LOW);
    end

    // Verify SDI read data
    for (int i = 0; i < (2 * `NUM_OF_TRANSFERS); i++) begin
      if (offload_sdi_captured_arr[i] != offload_sdi_data_store_arr[i]) begin
        `INFO(("offload_sdi_captured_arr[%d]: %x; offload_sdi_data_store_arr[%d]: %x",
          i, offload_sdi_captured_arr[i],
          i, offload_sdi_data_store_arr[i]), ADI_VERBOSITY_LOW);
          offload_test_passed = 1'b0;
        `ERROR(("Offload Read Test FAILED"));
      end
    end
    if (offload_test_passed) begin
      `INFO(("Offload Read Test PASSED"), ADI_VERBOSITY_LOW);
    end

    // Verify SDO write data
    // SDO data repeats every NUM_OF_WORDS entries
    for (int i = 0; i < num_hw_transfers; i++) begin
      if (offload_sdo_captured_arr[i] != offload_sdo_data[i % `NUM_OF_WORDS]) begin
        `INFO(("offload_sdo_captured_arr[%d]: %x; offload_sdo_data[%d]: %x",
          i, offload_sdo_captured_arr[i],
          i % `NUM_OF_WORDS, offload_sdo_data[i % `NUM_OF_WORDS]), ADI_VERBOSITY_LOW);
        offload_test_passed = 1'b0;
        `ERROR(("Offload Write Test FAILED"));
      end
    end
    if (offload_test_passed) begin
      `INFO(("Offload Write Test PASSED"), ADI_VERBOSITY_LOW);
    end
  endtask

  //---------------------------------------------------------------------------
  // FIFO SPI Test
  //---------------------------------------------------------------------------

  logic [31:0]  sdi_fifo_data [];
  logic [31:0]  sdo_write_data [];

  task fifo_spi_test();
    int fifo_transfer_cnt;
    // Reset capture tracking
    hw_capture_cnt = 6'b0;
    hw_capture_done = 1'b0;
    sdi_fifo_data_store = 32'd0;

    // For 1-lane interleaved mode (NUM_OF_SDIO==1, NO_REORDER==0), we must send
    // an even number of transfers to fill the reorder buffer and produce valid
    // output, so we run 2 transfers instead of 1
    fifo_transfer_cnt = (`NUM_OF_MISO == 1 && `NO_REORDER == 0) ? 2 : 1;
    fifo_data_rd = new("Fifo Read Watchdog", 3000 * fifo_transfer_cnt, "FIFO read is hanging!");
    fifo_data_rd.start();

    // Allocate FIFO data arrays
    sdi_fifo_data = new[1];
    sdo_write_data = new[1];

    for (int t = 0; t < fifo_transfer_cnt; t++) begin

      // Generate and write SDO data
      sdo_write_data[0] = $urandom();
      sdo_expected_data = sdo_write_data[0];
      spi_api.sdo_fifo_write(sdo_write_data);

      // Reset SDO capture
      sdo_shiftreg = 32'd0;
      sdo_capture_cnt = 6'b0;

      generate_transfer_cmd(1, sdi_lane_mask);

      wait(irq_pending[3] == 1'b1);

      spi_api.sdi_fifo_read(sdi_fifo_data);

      `INFO(("sdi_fifo_data[%0d]: %x; sdi_fifo_data_store: %x",
              t, sdi_fifo_data[0], sdi_fifo_data_store), ADI_VERBOSITY_LOW);
      if (sdi_fifo_data[0] != sdi_fifo_data_store) begin
        `FATAL(("Fifo SDI Read Test FAILED"));
      end

      // Verify SDO data
      sdo_captured_data = sdo_shiftreg;
      `INFO(("sdo_captured[%0d]: %x; sdo_expected: %x",
              t, sdo_captured_data, sdo_expected_data), ADI_VERBOSITY_LOW);
      if (sdo_captured_data != sdo_expected_data) begin
        `FATAL(("Fifo SDO Write Test FAILED"));
      end

      irq_pending[3] = 1'b0;
      sdi_fifo_data_store = 32'd0;
    end
    fifo_data_rd.stop();

    `INFO(("Fifo Read Test PASSED"), ADI_VERBOSITY_LOW);
    `INFO(("Fifo Write Test PASSED"), ADI_VERBOSITY_LOW);
  endtask

  //---------------------------------------------------------------------------
  // Test initialization
  //---------------------------------------------------------------------------

  task init();
    // Start spi clk generator
    clkgen_api.enable_clkgen();

    // Config pwm
    pwm_api.reset();
    pwm_api.pulse_period_config(0, ('h64 * 'd16) - 'h0); // set PWM 0 period
    pwm_api.pulse_period_config(1, ('h64 * 'd4) - 'h0);  // set PWM 1 period
    pwm_api.load_config();
    pwm_api.start();
    `INFO(("axi_pwm_gen started."), ADI_VERBOSITY_LOW);

    // Enable SPI Engine
    spi_api.enable_spi_engine();

    // Configure the execution module
    spi_api.fifo_command(`INST_CFG);
    spi_api.fifo_command(`INST_PRESCALE);
    spi_api.fifo_command(`INST_DLENGTH);
    spi_api.fifo_command(`SET_SDI_LANE_MASK(sdi_lane_mask));
    spi_api.fifo_command(`SET_SDO_LANE_MASK(`MOSI_LANE_MASK));

    // Set up the interrupts
    spi_api.set_interrup_mask(.sync_event(1'b1), .offload_sync_id_pending(1'b1));
  endtask

endprogram
