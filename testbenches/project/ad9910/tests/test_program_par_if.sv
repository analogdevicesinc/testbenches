// ***************************************************************************
// ***************************************************************************
// Copyright (C) 2026 Analog Devices, Inc. All rights reserved.
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

import logger_pkg::*;
import adi_environment_pkg::*;
import adi_axi_agent_pkg::*;
import axi_vip_pkg::*;
import test_harness_env_pkg::*;
import adi_regmap_pkg::*;
import adi_regmap_common_pkg::*;
import adi_regmap_dmac_pkg::*;
import dmac_api_pkg::*;
import dma_trans_pkg::*;

import `PKGIFY(test_harness, mng_axi_vip)::*;
import `PKGIFY(test_harness, ddr_axi_vip)::*;

program test_program_par_if (
  input         pd_clk_tp,
  input         sync_clk_tp,
  input         main_reset_tp,
  input         io_reset_tp,
  input         pw_down_tp,
  output reg    ext_sync_tp,
  input         ad9910_irq_tp,
  input         trig_out_tp,
  input         osk_tp,
  input         drctl_tp,
  input         drhold_tp,
  output reg    drover_tp,
  output reg    sync_smp_err_tp,
  output reg    ram_swp_ovr_tp,
  input  [2:0]  profile_tp,
  input         io_update_tp,
  input  [17:0] db_o_tp,
  input         tx_enable_tp
);

  timeunit 1ns;
  timeprecision 1ps;

  // --------------------------
  // Register addresses (from axi_ad9910_reg.v)
  // --------------------------
  localparam REG_VERSION         = 7'h00;
  localparam REG_ID              = 7'h01;
  localparam REG_SCRATCH         = 7'h02;
  localparam REG_CONTROL         = 7'h10;
  localparam REG_PD_CLK_CNT      = 7'h40;
  localparam REG_UPDATE_CTRL     = 7'h41;
  localparam REG_PAR_UPDATE_RATE = 7'h42;
  localparam REG_DMA_CFG         = 7'h43;
  localparam REG_DEBUG_SENT_CFGS = 7'h44;
  localparam REG_DEBUG_LAST_CFG  = 7'h45;

  // UPDATE_CTRL bit positions
  localparam CTRL_LOAD_NEW_RATE       = 0;
  localparam CTRL_ENABLE_P_IF         = 1;
  localparam CTRL_TRANSFER_TRIG_MODE  = 2;

  // --------------------------
  // Environment and agents
  // --------------------------
  test_harness_env #(
    `AXI_VIP_PARAMS(test_harness, mng_axi_vip),
    `AXI_VIP_PARAMS(test_harness, ddr_axi_vip)
  ) base_env;

  dmac_api tx_dma;

  // --------------------------
  // Test state
  // --------------------------
  bit [31:0] read_data;
  bit        test_passed = 1;

  // --------------------------
  // AXI helper tasks
  // --------------------------
  task axi_write(input [31:0] waddr, input [31:0] wdata);
    base_env.mng.sequencer.RegWrite32(waddr, wdata);
  endtask

  task axi_read(input [31:0] raddr, output [31:0] data);
    base_env.mng.sequencer.RegRead32(raddr, data);
  endtask

  task axi_read_v(input [31:0] raddr, input [31:0] vdata);
    base_env.mng.sequencer.RegReadVerify32(raddr, vdata);
  endtask

  function [31:0] reg_addr(input [6:0] offset);
    return `AXI_AD9910_BA + (offset << 2);
  endfunction

  // --------------------------
  // DDR helper tasks
  // --------------------------
  task ddr_write_word(input [31:0] addr, input [31:0] data);
    base_env.ddr.agent.mem_model.backdoor_memory_write_4byte(
      xil_axi_uint'(addr), data, 4'hF);
  endtask

  task ddr_write_words(input [31:0] base_addr, input int num_words,
                       input logic [31:0] data[]);
    for (int i = 0; i < num_words; i++)
      ddr_write_word(base_addr + i*4, data[i]);
  endtask

  // --------------------------
  // DMA transfer helper
  // --------------------------
  task start_dma_transfer(input [31:0] src_addr, input [31:0] length);
    dma_segment seg;
    int tid;

    tx_dma.enable_dma();
    tx_dma.set_flags(
      .cyclic(1'b0),
      .tlast(1'b0),
      .partial_reporting_en(1'b0));

    seg = new(tx_dma.get_params());
    seg.length = length;
    seg.src_addr = src_addr;

    tx_dma.submit_transfer(seg, tid);
  endtask

  // --------------------------
  // Parallel interface configuration helper
  // --------------------------
  task configure_par_if(
    input [31:0] update_rate,
    input [ 1:0] words_per_cfg,
    input        trig_mode = 0,
    input int    cdc_wait_ns = 10000
  );
    // Set DMA config (words per config packet - 1)
    axi_write(reg_addr(REG_DMA_CFG), {30'd0, words_per_cfg});

    // Set update rate
    axi_write(reg_addr(REG_PAR_UPDATE_RATE), update_rate);

    // Enable parallel interface with load_new_rate
    axi_write(reg_addr(REG_UPDATE_CTRL),
      (trig_mode << CTRL_TRANSFER_TRIG_MODE) |
      (1 << CTRL_ENABLE_P_IF) |
      (1 << CTRL_LOAD_NEW_RATE));

    // Wait for CDC propagation to pd_clk domain
    #(cdc_wait_ns * 1ns);
  endtask

  // --------------------------
  // Wait for debug_sent_configs to reach target value
  // --------------------------
  task automatic wait_sent_configs(
    input int unsigned target,
    input int unsigned timeout_us = 100
  );
    int unsigned elapsed_ns = 0;
    bit [31:0] current_count;

    while (elapsed_ns < timeout_us * 1000) begin
      axi_read(reg_addr(REG_DEBUG_SENT_CFGS), current_count);
      if (current_count >= target) return;
      #1us;
      elapsed_ns += 1000;
    end

    `ERROR(("Timeout waiting for sent_configs >= %0d (current: %0d)",
            target, current_count));
    test_passed = 0;
  endtask

  // --------------------------
  // Monitor: capture db_o values on tx_enable rising edges
  // --------------------------
  logic [17:0] captured_data [$];
  bit          monitor_enabled = 0;

  initial begin : db_o_monitor
    forever begin
      @(posedge pd_clk_tp);
      if (monitor_enabled && tx_enable_tp) begin
        captured_data.push_back(db_o_tp);
      end
    end
  end

  task enable_monitor();
    captured_data.delete();
    monitor_enabled = 1;
  endtask

  task disable_monitor();
    monitor_enabled = 0;
  endtask

  // --------------------------
  // Ramp data types
  // --------------------------
  typedef enum logic [1:0] {
    RAMP_MODE_SAW_UP,
    RAMP_MODE_SAW_DOWN,
    RAMP_MODE_TRIANGLE
  } ramp_mode_e;

  typedef enum logic [1:0] {
    RAMP_IDLE,
    RAMP_UP,
    RAMP_DOWN
  } ramp_state_e;

  // --------------------------
  // Generate ramp data into DDR memory
  // --------------------------
  task automatic generate_ramp_to_ddr(
    input [31:0]       base_addr,
    input logic [17:0] lower,
    input logic [17:0] upper,
    input logic [17:0] step,
    input ramp_mode_e  mode,
    input int unsigned word_count
  );
    logic [17:0]  counter;
    ramp_state_e  state;

    counter = (mode == RAMP_MODE_SAW_DOWN) ? upper : lower;
    state   = (mode == RAMP_MODE_SAW_DOWN) ? RAMP_DOWN : RAMP_UP;

    for (int i = 0; i < word_count; i++) begin
      ddr_write_word(base_addr + i*4, {14'd0, counter});

      // Advance counter (mirrors original ramp controller logic)
      case (state)
        RAMP_UP: begin
          if (upper - counter < step) begin
            case (mode)
              RAMP_MODE_SAW_UP:  counter = lower;
              RAMP_MODE_TRIANGLE: begin
                counter = upper;
                state = RAMP_DOWN;
              end
              default: counter = lower;
            endcase
          end else begin
            counter = counter + step;
          end
        end

        RAMP_DOWN: begin
          if (counter - lower < step) begin
            case (mode)
              RAMP_MODE_SAW_DOWN: counter = upper;
              RAMP_MODE_TRIANGLE: begin
                counter = lower;
                state = RAMP_UP;
              end
              default: counter = upper;
            endcase
          end else begin
            counter = counter - step;
          end
        end

        default: state = RAMP_UP;
      endcase
    end

    `INFO(("Ramp: Generated %0d words to DDR at 0x%08x (mode=%0d, lower=0x%05x, upper=0x%05x, step=%0d)",
           word_count, base_addr, mode, lower, upper, step), ADI_VERBOSITY_LOW);
  endtask

  // --------------------------
  // Ramp capture verification
  // --------------------------
  task automatic verify_ramp_capture(
    input int unsigned    len,
    input logic [17:0]    lower,
    input logic [17:0]    upper,
    input int unsigned    step,
    input ramp_mode_e     mode,
    input string          label
  );
    logic [17:0]  expected_val;
    ramp_state_e  state;
    int unsigned  mismatches = 0;

    if (captured_data.size() < len) begin
      `ERROR(("  %s: Expected >= %0d captures, got %0d",
              label, len, captured_data.size()));
      test_passed = 0;
      return;
    end

    expected_val = (mode == RAMP_MODE_SAW_DOWN) ? upper : lower;
    state        = (mode == RAMP_MODE_SAW_DOWN) ? RAMP_DOWN : RAMP_UP;

    for (int i = 0; i < len; i++) begin
      if (captured_data[i] !== expected_val) begin
        if (mismatches < 10)
          `ERROR(("  %s: Mismatch at index %0d: got 0x%05x, expected 0x%05x",
                  label, i, captured_data[i], expected_val));
        mismatches++;
      end

      // Advance expected value matching ramp logic
      case (state)
        RAMP_UP: begin
          if (upper - expected_val < step[17:0]) begin
            case (mode)
              RAMP_MODE_SAW_UP:   expected_val = lower;
              RAMP_MODE_TRIANGLE: begin
                expected_val = upper;
                state = RAMP_DOWN;
              end
              default: expected_val = lower;
            endcase
          end else begin
            expected_val = expected_val + step[17:0];
          end
        end
        RAMP_DOWN: begin
          if (expected_val - lower < step[17:0]) begin
            case (mode)
              RAMP_MODE_SAW_DOWN: expected_val = upper;
              RAMP_MODE_TRIANGLE: begin
                expected_val = lower;
                state = RAMP_UP;
              end
              default: expected_val = upper;
            endcase
          end else begin
            expected_val = expected_val - step[17:0];
          end
        end
        default: state = RAMP_UP;
      endcase
    end

    if (mismatches == 0) begin
      `INFO(("  %s: Ramp data verified (%0d words) - PASSED",
             label, len), ADI_VERBOSITY_NONE);
    end else begin
      `ERROR(("  %s: %0d mismatches in ramp data", label, mismatches));
      test_passed = 0;
    end
  endtask

  // --------------------------
  // Main test sequence
  // --------------------------
  initial begin
    setLoggerVerbosity(ADI_VERBOSITY_LOW);

    // Initialize unused DRG outputs
    ext_sync_tp     = 1'b0;
    drover_tp       = 1'b0;
    sync_smp_err_tp = 1'b0;
    ram_swp_ovr_tp  = 1'b0;

    // Create and start environment (mng + ddr agents, clocks, reset)
    base_env = new("PAR_IF Environment",
      `TH.`SYS_CLK.inst.IF,
      `TH.`DMA_CLK.inst.IF,
      `TH.`DDR_CLK.inst.IF,
      `TH.`SYS_RST.inst.IF,
      `TH.`MNG_AXI.inst.IF,
      `TH.`DDR_AXI.inst.IF);

    base_env.start();
    base_env.sys_reset();

    // Create DMA API object
    tx_dma = new("TX_DMA", base_env.mng.sequencer, `TX_DMA_BA);
    tx_dma.probe();

    `INFO(("==== AD9910 Parallel Interface Testbench (DMA mode) ===="), ADI_VERBOSITY_NONE);

    // Release device reset (up_reset defaults to 1, holding pd_clk domain in reset)
    axi_write(reg_addr(REG_CONTROL), 32'h0000_0000);
    #10us;

    // ----------------------------------------
    // TC1: Register sanity
    // ----------------------------------------
    `INFO(("TC1: Register sanity"), ADI_VERBOSITY_NONE);
    begin
      bit [31:0] pd_clk_count_1;

      axi_read(reg_addr(REG_VERSION), read_data);
      `INFO(("  Version: 0x%08x", read_data), ADI_VERBOSITY_LOW);

      axi_read(reg_addr(REG_ID), read_data);
      `INFO(("  ID: 0x%08x", read_data), ADI_VERBOSITY_LOW);

      // Scratch register write/read
      axi_write(reg_addr(REG_SCRATCH), 32'hCAFEBABE);
      axi_read_v(reg_addr(REG_SCRATCH), 32'hCAFEBABE);
      `INFO(("  Scratch register - PASSED"), ADI_VERBOSITY_NONE);

      // Read pd_clk monitor (informational)
      axi_read(reg_addr(REG_PD_CLK_CNT), pd_clk_count_1);
      `INFO(("  pd_clk count: %0d (monitor needs ~655us to update)",
             pd_clk_count_1), ADI_VERBOSITY_LOW);
    end

    // ----------------------------------------
    // TC2: Single-word transfer (internal rate)
    // ----------------------------------------
    `INFO(("TC2: Single-word transfer (internal rate)"), ADI_VERBOSITY_NONE);
    begin
      automatic bit [31:0] test_word = 32'h0001_2345;
      bit [31:0] sent_count_before, sent_count_after;
      bit [31:0] last_cfg;

      // Read baseline debug counter
      axi_read(reg_addr(REG_DEBUG_SENT_CFGS), sent_count_before);
      `INFO(("  Baseline sent_configs: %0d", sent_count_before), ADI_VERBOSITY_LOW);

      // Write one word into DDR and start DMA transfer
      ddr_write_word(`DDR_BA, test_word);
      `INFO(("  Word 0x%08x written to DDR", test_word), ADI_VERBOSITY_LOW);

      // Configure parallel interface: 1 word/cfg, update_rate=100
      configure_par_if(
        .update_rate(32'd100),
        .words_per_cfg(2'd0)
      );

      // Start DMA transfer (1 word = 4 bytes)
      start_dma_transfer(`DDR_BA, 4);

      // Wait for at least one transfer to complete
      wait_sent_configs(sent_count_before + 1, 50);

      // Read debug registers
      axi_read(reg_addr(REG_DEBUG_SENT_CFGS), sent_count_after);
      axi_read(reg_addr(REG_DEBUG_LAST_CFG), last_cfg);

      `INFO(("  sent_configs: %0d -> %0d", sent_count_before, sent_count_after), ADI_VERBOSITY_LOW);
      `INFO(("  last_sent_cfg: 0x%05x (expected 0x%05x)",
             last_cfg[17:0], test_word[17:0]), ADI_VERBOSITY_LOW);

      if (sent_count_after > sent_count_before) begin
        `INFO(("  Transfer occurred - PASSED"), ADI_VERBOSITY_NONE);
      end else begin
        `ERROR(("  No transfer detected"));
        test_passed = 0;
      end

      if (last_cfg[17:0] == test_word[17:0]) begin
        `INFO(("  Data integrity - PASSED"), ADI_VERBOSITY_NONE);
      end else begin
        `ERROR(("  Data mismatch: got 0x%05x, expected 0x%05x",
                last_cfg[17:0], test_word[17:0]));
        test_passed = 0;
      end

      // Disable parallel interface before next test
      axi_write(reg_addr(REG_UPDATE_CTRL), 32'h0000_0000);
      #5us;
    end

    // ----------------------------------------
    // TC3: Multi-word transfer (3 words per config packet)
    // ----------------------------------------
    `INFO(("TC3: Multi-word transfer (3 words/packet)"), ADI_VERBOSITY_NONE);
    begin
      logic [31:0] test_data [3];
      bit [31:0] sent_count_before, sent_count_after;
      bit [31:0] last_cfg;

      test_data[0] = 32'h0000_AAAA;
      test_data[1] = 32'h0001_BBBB;
      test_data[2] = 32'h0002_CCCC;

      axi_read(reg_addr(REG_DEBUG_SENT_CFGS), sent_count_before);

      // Write 3 words to DDR
      ddr_write_words(`DDR_BA, 3, test_data);
      `INFO(("  Wrote 3-word config packet to DDR"), ADI_VERBOSITY_LOW);

      // Configure: 3 words per cfg (dma_n_param_per_cfg=2), rate=200
      configure_par_if(
        .update_rate(32'd200),
        .words_per_cfg(2'd2)
      );

      // Start DMA transfer (3 words = 12 bytes)
      start_dma_transfer(`DDR_BA, 12);

      // Wait for all 3 words to be sent
      wait_sent_configs(sent_count_before + 3, 50);

      axi_read(reg_addr(REG_DEBUG_SENT_CFGS), sent_count_after);
      axi_read(reg_addr(REG_DEBUG_LAST_CFG), last_cfg);

      `INFO(("  sent_configs: %0d -> %0d (delta=%0d)",
             sent_count_before, sent_count_after,
             sent_count_after - sent_count_before), ADI_VERBOSITY_LOW);

      // Verify at least 3 words were sent
      if ((sent_count_after - sent_count_before) >= 3) begin
        `INFO(("  Multi-word transfer count - PASSED"), ADI_VERBOSITY_NONE);
      end else begin
        `ERROR(("  Expected >= 3 words sent, got %0d",
                sent_count_after - sent_count_before));
        test_passed = 0;
      end

      // Last word should be test_data[2]
      if (last_cfg[17:0] == test_data[2][17:0]) begin
        `INFO(("  Last word data integrity - PASSED"), ADI_VERBOSITY_NONE);
      end else begin
        `ERROR(("  Last word mismatch: got 0x%05x, expected 0x%05x",
                last_cfg[17:0], test_data[2][17:0]));
        test_passed = 0;
      end

      axi_write(reg_addr(REG_UPDATE_CTRL), 32'h0000_0000);
      #5us;
    end

    // ----------------------------------------
    // TC4: Continuous streaming (multiple packets)
    // ----------------------------------------
    `INFO(("TC4: Continuous streaming"), ADI_VERBOSITY_NONE);
    begin
      automatic int unsigned total_words = 8;
      bit [31:0] sent_count_before, sent_count_after;

      axi_read(reg_addr(REG_DEBUG_SENT_CFGS), sent_count_before);

      // Write 8 words with incrementing data to DDR
      for (int i = 0; i < total_words; i++) begin
        ddr_write_word(`DDR_BA + i*4, 32'h0003_0000 + i);
      end
      `INFO(("  Wrote %0d words to DDR", total_words), ADI_VERBOSITY_LOW);

      // Configure: 1 word per cfg, fast rate
      configure_par_if(
        .update_rate(32'd50),
        .words_per_cfg(2'd0)
      );

      // Start DMA transfer (8 words = 32 bytes)
      start_dma_transfer(`DDR_BA, total_words * 4);

      // Wait for all transfers
      wait_sent_configs(sent_count_before + total_words, 100);

      axi_read(reg_addr(REG_DEBUG_SENT_CFGS), sent_count_after);

      if ((sent_count_after - sent_count_before) >= total_words) begin
        `INFO(("  %0d words streamed - PASSED",
               sent_count_after - sent_count_before), ADI_VERBOSITY_NONE);
      end else begin
        `ERROR(("  Expected >= %0d words, got %0d",
                total_words, sent_count_after - sent_count_before));
        test_passed = 0;
      end

      axi_write(reg_addr(REG_UPDATE_CTRL), 32'h0000_0000);
      #5us;
    end

    // ----------------------------------------
    // TC5: DMA-to-FIFO backpressure (overflow test)
    // ----------------------------------------
    // Load a large block into DDR, start DMA with fast transfer but
    // slow update_rate so the DUT FIFO fills up. The DMA must pause
    // via backpressure when the FIFO is full. Verify no data loss by
    // checking that all words are eventually sent.
    `INFO(("TC5: DMA-to-FIFO backpressure"), ADI_VERBOSITY_NONE);
    begin
      automatic int unsigned total_words = 64;
      bit [31:0] sent_count_before, sent_count_after;

      axi_read(reg_addr(REG_DEBUG_SENT_CFGS), sent_count_before);

      // Write 64 words to DDR (4x FIFO depth of 16)
      for (int i = 0; i < total_words; i++) begin
        ddr_write_word(`DDR_BA + i*4, 32'h0004_0000 + i);
      end
      `INFO(("  Wrote %0d words to DDR (4x FIFO depth)", total_words), ADI_VERBOSITY_LOW);

      // Configure with slow update_rate so FIFO fills up,
      // then DMA must wait via backpressure
      configure_par_if(
        .update_rate(32'd500),
        .words_per_cfg(2'd0)
      );

      // Start DMA: transfers all 64 words (256 bytes)
      // DMA will push faster than the DUT can consume at rate=500,
      // forcing the FIFO to fill and backpressure the DMA
      start_dma_transfer(`DDR_BA, total_words * 4);

      // Wait for all words to be sent through the parallel interface.
      // 64 words at rate 500 (2us/word) = 128us + DMA startup latency.
      wait_sent_configs(sent_count_before + total_words, 2000);

      // Extra drain time for any words still in DMA/FIFO pipeline
      #20us;
      axi_read(reg_addr(REG_DEBUG_SENT_CFGS), sent_count_after);

      if ((sent_count_after - sent_count_before) >= total_words) begin
        `INFO(("  All %0d words transferred despite backpressure - PASSED",
               sent_count_after - sent_count_before), ADI_VERBOSITY_NONE);
      end else begin
        `ERROR(("  Data loss under backpressure: expected >= %0d, got %0d",
                total_words, sent_count_after - sent_count_before));
        test_passed = 0;
      end

      axi_write(reg_addr(REG_UPDATE_CTRL), 32'h0000_0000);
      #5us;
    end

    // ----------------------------------------
    // TC6: Update rate change
    // ----------------------------------------
    `INFO(("TC6: Update rate change"), ADI_VERBOSITY_NONE);
    begin
      bit [31:0] sent_before_slow, sent_after_slow;
      bit [31:0] sent_before_fast, sent_after_fast;
      int unsigned slow_delta, fast_delta;
      automatic int unsigned measurement_window_us = 10;
      automatic int unsigned num_words = 16;

      // --- Slow rate measurement ---
      axi_write(reg_addr(REG_UPDATE_CTRL), 32'h0000_0000);
      #5us;

      // Load data into DDR for slow rate test
      for (int i = 0; i < num_words; i++) begin
        ddr_write_word(`DDR_BA + i*4, 32'h0005_0000 + i);
      end

      // Configure with slow rate, short CDC wait to preserve timing
      configure_par_if(
        .update_rate(32'd500),
        .words_per_cfg(2'd0),
        .cdc_wait_ns(500)
      );

      // Start DMA transfer
      start_dma_transfer(`DDR_BA, num_words * 4);

      axi_read(reg_addr(REG_DEBUG_SENT_CFGS), sent_before_slow);
      repeat (measurement_window_us) #1us;
      axi_read(reg_addr(REG_DEBUG_SENT_CFGS), sent_after_slow);
      slow_delta = sent_after_slow - sent_before_slow;

      // Wait for transfer to complete and disable
      #40us;
      axi_write(reg_addr(REG_UPDATE_CTRL), 32'h0000_0000);
      #5us;

      // --- Fast rate measurement ---
      // Load data into DDR for fast rate test
      for (int i = 0; i < num_words; i++) begin
        ddr_write_word(`DDR_BA + i*4, 32'h0006_0000 + i);
      end

      configure_par_if(
        .update_rate(32'd50),
        .words_per_cfg(2'd0),
        .cdc_wait_ns(500)
      );

      start_dma_transfer(`DDR_BA, num_words * 4);

      axi_read(reg_addr(REG_DEBUG_SENT_CFGS), sent_before_fast);
      repeat (measurement_window_us) #1us;
      axi_read(reg_addr(REG_DEBUG_SENT_CFGS), sent_after_fast);
      fast_delta = sent_after_fast - sent_before_fast;

      `INFO(("  Slow rate (500): %0d transfers in %0d us",
             slow_delta, measurement_window_us), ADI_VERBOSITY_LOW);
      `INFO(("  Fast rate (50):  %0d transfers in %0d us",
             fast_delta, measurement_window_us), ADI_VERBOSITY_LOW);

      // Fast rate should produce significantly more transfers
      if (fast_delta > slow_delta * 2) begin
        `INFO(("  Rate change effective (fast/slow ratio ~%0dx) - PASSED",
               fast_delta / (slow_delta > 0 ? slow_delta : 1)), ADI_VERBOSITY_NONE);
      end else begin
        `ERROR(("  Rate change not effective: slow=%0d, fast=%0d",
                slow_delta, fast_delta));
        test_passed = 0;
      end

      axi_write(reg_addr(REG_UPDATE_CTRL), 32'h0000_0000);
      #5us;
    end

    // ----------------------------------------
    // TC7: Ramp data integrity — sawtooth up
    // ----------------------------------------
    `INFO(("TC7: Ramp data integrity (sawtooth up)"), ADI_VERBOSITY_NONE);
    begin
      automatic int unsigned ramp_len = 8192;
      automatic int unsigned ramp_step = 64;
      bit [31:0] sent_count_before;

      axi_read(reg_addr(REG_DEBUG_SENT_CFGS), sent_count_before);

      // Pre-generate ramp data into DDR
      generate_ramp_to_ddr(`DDR_BA, 18'd0, 18'h3FFFF, 18'(ramp_step),
                           RAMP_MODE_SAW_UP, ramp_len);

      enable_monitor();
      configure_par_if(
        .update_rate(32'd0),
        .words_per_cfg(2'd0),
        .cdc_wait_ns(500)
      );

      // Start DMA transfer of all ramp data
      start_dma_transfer(`DDR_BA, ramp_len * 4);

      wait_sent_configs(sent_count_before + ramp_len, 5000);
      #5us;
      disable_monitor();

      verify_ramp_capture(ramp_len, 18'd0, 18'h3FFFF, ramp_step, RAMP_MODE_SAW_UP,
                          "Sawtooth up");

      axi_write(reg_addr(REG_UPDATE_CTRL), 32'h0000_0000);
      #5us;
    end

    // ----------------------------------------
    // TC8: Ramp data integrity — triangle
    // ----------------------------------------
    `INFO(("TC8: Ramp data integrity (triangle)"), ADI_VERBOSITY_NONE);
    begin
      automatic int unsigned ramp_len = 16384;
      automatic int unsigned ramp_step = 64;
      bit [31:0] sent_count_before;

      axi_read(reg_addr(REG_DEBUG_SENT_CFGS), sent_count_before);

      generate_ramp_to_ddr(`DDR_BA, 18'd0, 18'h3FFFF, 18'(ramp_step),
                           RAMP_MODE_TRIANGLE, ramp_len);

      enable_monitor();
      configure_par_if(
        .update_rate(32'd0),
        .words_per_cfg(2'd0),
        .cdc_wait_ns(500)
      );

      start_dma_transfer(`DDR_BA, ramp_len * 4);

      wait_sent_configs(sent_count_before + ramp_len, 5000);
      #5us;
      disable_monitor();

      verify_ramp_capture(ramp_len, 18'd0, 18'h3FFFF, ramp_step, RAMP_MODE_TRIANGLE,
                          "Triangle");

      axi_write(reg_addr(REG_UPDATE_CTRL), 32'h0000_0000);
      #5us;
    end

    // ----------------------------------------
    // TC9: Ramp data integrity — sawtooth down
    // ----------------------------------------
    `INFO(("TC9: Ramp data integrity (sawtooth down)"), ADI_VERBOSITY_NONE);
    begin
      automatic int unsigned ramp_len = 8192;
      automatic int unsigned ramp_step = 64;
      bit [31:0] sent_count_before;

      axi_read(reg_addr(REG_DEBUG_SENT_CFGS), sent_count_before);

      generate_ramp_to_ddr(`DDR_BA, 18'd0, 18'h3FFFF, 18'(ramp_step),
                           RAMP_MODE_SAW_DOWN, ramp_len);

      enable_monitor();
      configure_par_if(
        .update_rate(32'd0),
        .words_per_cfg(2'd0),
        .cdc_wait_ns(500)
      );

      start_dma_transfer(`DDR_BA, ramp_len * 4);

      wait_sent_configs(sent_count_before + ramp_len, 5000);
      #5us;
      disable_monitor();

      verify_ramp_capture(ramp_len, 18'd0, 18'h3FFFF, ramp_step, RAMP_MODE_SAW_DOWN,
                          "Sawtooth down");

      axi_write(reg_addr(REG_UPDATE_CTRL), 32'h0000_0000);
      #5us;
    end

    // ----------------------------------------
    // Final report
    // ----------------------------------------
    #1us;

    base_env.stop();

    if (test_passed) begin
      `INFO(("==== ALL TESTS PASSED ===="), ADI_VERBOSITY_NONE);
    end else begin
      `ERROR(("==== SOME TESTS FAILED ===="));
    end

    `INFO(("Testbench done!"), ADI_VERBOSITY_NONE);
    $finish();
  end

endprogram
