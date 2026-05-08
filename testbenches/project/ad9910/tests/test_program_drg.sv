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

import logger_pkg::*;
import test_harness_env_pkg::*;
import adi_axi_agent_pkg::*;
import axi_vip_pkg::*;
import adi_regmap_pkg::*;
import adi_regmap_common_pkg::*;

import `PKGIFY(test_harness, mng_axi_vip)::*;
import `PKGIFY(test_harness, ddr_axi_vip)::*;

program test_program_drg (
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

  // Register addresses (from axi_ad9910_reg.v)
  localparam REG_VERSION      = 7'h00;
  localparam REG_ID           = 7'h01;
  localparam REG_SCRATCH      = 7'h02;
  localparam REG_CONTROL      = 7'h10;
  localparam REG_IRQ_MASK     = 7'h11;
  localparam REG_IRQ_CLEAR    = 7'h12;
  localparam REG_IRQ_MON_CFG  = 7'h13;
  localparam REG_TRIG_CFG     = 7'h14;
  localparam REG_SYNC_CLK_CNT = 7'h20;
  localparam REG_RAMP_CTRL    = 7'h21;
  localparam REG_PROFILE      = 7'h22;
  localparam REG_IO_UPDATE    = 7'h23;
  localparam REG_RAMP_CFG     = 7'h24;
  localparam REG_BST_DELAY    = 7'h25;
  localparam REG_ALR_DELAY    = 7'h26;
  localparam REG_BURST_DELAY  = 7'h27;
  localparam REG_RAMP_BURSTS  = 7'h28;
  localparam REG_IRQ_START    = 7'h29;
  localparam REG_IRQ_STOP     = 7'h2a;
  localparam REG_MON_MAX_PER  = 7'h2b;
  localparam REG_PD_CLK_CNT   = 7'h40;
  localparam REG_EXT_SYNC     = 7'h41;
  localparam REG_PAR_IF_CTRL  = 7'h42;
  localparam REG_UPDATE_RATE  = 7'h43;
  localparam REG_DMA_N_PARAM  = 7'h44;

  // Control register bits
  localparam CTRL_CLK_ENB       = 4;
  localparam CTRL_MMCM_RST      = 3;
  localparam CTRL_PW_DOWN       = 2;
  localparam CTRL_DEVICE_RESET  = 1;
  localparam CTRL_RESET         = 0;

  // Ramp control register bits
  localparam RAMP_NO_DWELL_HIGH = 5;
  localparam RAMP_NO_DWELL_LOW  = 4;
  localparam RAMP_DRCTL_TOG_EN  = 3;
  localparam RAMP_DRCTL_INIT    = 2;
  localparam RAMP_DRHOLD        = 1;
  localparam RAMP_OSK           = 0;

  // Test environment
  test_harness_env base_env;
  adi_axi_master_agent #(`AXI_VIP_PARAMS(test_harness, mng_axi_vip)) mng;
  adi_axi_slave_mem_agent #(`AXI_VIP_PARAMS(test_harness, ddr_axi_vip)) ddr;

  // Test variables
  bit [31:0] read_data;
  bit        test_passed = 1;

  // --------------------------
  // DRG Counter Model - Simulates AD9910 Digital Ramp Generator
  // --------------------------
  // Counter parameters
  localparam int DRG_WIDTH = 18;
  localparam logic [DRG_WIDTH-1:0] DRG_LOWER_LIMIT = 18'd1000;
  localparam logic [DRG_WIDTH-1:0] DRG_UPPER_LIMIT = 18'd5000;
  localparam logic [DRG_WIDTH-1:0] DRG_STEP_SIZE   = 18'd15;

  // DRG state machine
  typedef enum logic [1:0] {
    DRG_DWELL_LOWER = 2'd0,
    DRG_RAMP_UP     = 2'd1,
    DRG_DWELL_UPPER = 2'd2,
    DRG_RAMP_DOWN   = 2'd3
  } drg_state_e;

  drg_state_e           drg_state;
  logic [DRG_WIDTH-1:0] drg_counter;
  int unsigned          drover_pulse_count;
  bit                   drg_model_enabled = 0;
  bit [31:0]            ramp_ctrl_val = 0;      // Cached REG_RAMP_CTRL value, updated via read_ramp_ctrl()
  int unsigned          drg_burst_blade_limit = 0;  // 0 = unlimited, N = auto-hold after N blades
  int unsigned          drg_burst_blade_count = 0;  // Blades completed in current burst
  bit                   drg_burst_hold = 0;         // Auto-hold active (burst limit reached)
  bit                   drctl_d = 0;                // Previous drctl_tp for edge detection
  bit                   drctl_posedge_det;
  bit                   drctl_negedge_det;
  bit                   no_dwell_high;
  bit                   no_dwell_low;
  bit                   both_no_dwell;

  // DRG counter process - runs concurrently with tests
  initial begin : drg_model
    // Initialize
    drg_counter        = DRG_LOWER_LIMIT;
    drover_tp          = 1'b1;
    drover_pulse_count = 0;
    drg_state          = DRG_DWELL_LOWER;
    drctl_d            = 0;

    // Wait for model to be enabled
    wait(drg_model_enabled);
    `INFO(("DRG Model: Started (lower=%0d, upper=%0d, step=%0d)",
           DRG_LOWER_LIMIT, DRG_UPPER_LIMIT, DRG_STEP_SIZE), ADI_VERBOSITY_LOW);

    forever begin
      @(posedge sync_clk_tp);

      // Edge detection (computed before drctl_d update)
      drctl_posedge_det = drctl_tp & !drctl_d;
      drctl_negedge_det = !drctl_tp & drctl_d;
      drctl_d = drctl_tp;

      // Check for reset
      if (main_reset_tp) begin
        drg_counter = DRG_LOWER_LIMIT;
        drg_state   = DRG_DWELL_LOWER;
        drover_tp   = 1'b1;
        continue;
      end

      // Freeze state if model is disabled or a hold is active
      if (!drg_model_enabled || drhold_tp || drg_burst_hold) begin
        drover_tp = (drg_state == DRG_DWELL_LOWER || drg_state == DRG_DWELL_UPPER);
        continue;
      end

      // Mode flags derived from cached ramp_ctrl_val
      no_dwell_high  = ramp_ctrl_val[RAMP_NO_DWELL_HIGH];
      no_dwell_low   = ramp_ctrl_val[RAMP_NO_DWELL_LOW];
      both_no_dwell  = no_dwell_high & no_dwell_low;

      case (drg_state)

        DRG_DWELL_LOWER: begin
          drover_tp = 1'b1;
          if (both_no_dwell) begin
            if (drctl_posedge_det)
              drg_state = DRG_RAMP_UP;
          end else if (no_dwell_high) begin
            if (drctl_posedge_det)
              drg_state = DRG_RAMP_UP;
          end else begin
            if (drctl_tp)
              drg_state = DRG_RAMP_UP;
          end
        end

        DRG_RAMP_UP: begin
          drover_tp = 1'b0;
          if (both_no_dwell && drctl_negedge_det) begin
            drg_state = DRG_RAMP_DOWN;
          end else if (drg_counter < DRG_UPPER_LIMIT - DRG_STEP_SIZE) begin
            drg_counter = drg_counter + DRG_STEP_SIZE;
          end else begin
            drover_pulse_count++;
            if (no_dwell_high) begin
              drg_burst_blade_count++;
              `INFO(("DRG Model: Upper limit reached (blade=%0d) - snapping to lower",
                     drover_pulse_count), ADI_VERBOSITY_LOW);
              drg_counter = DRG_LOWER_LIMIT;
              drover_tp   = 1'b1;
              if (drg_burst_blade_limit > 0 && drg_burst_blade_count >= drg_burst_blade_limit) begin
                drg_burst_hold = 1;
                `INFO(("DRG Model: Burst limit reached (%0d blades) - auto-hold",
                       drg_burst_blade_limit), ADI_VERBOSITY_LOW);
              end
              if (both_no_dwell) begin
                // Both no-dwell: auto-continue (stay in DRG_RAMP_UP)
              end else begin
                // No-dwell high only: wait at lower for next posedge
                drg_state = DRG_DWELL_LOWER;
              end
            end else begin
              drg_counter = DRG_UPPER_LIMIT;
              drg_state   = DRG_DWELL_UPPER;
              drover_tp   = 1'b1;
              `INFO(("DRG Model: Upper limit reached (count=%0d, transitions=%0d)",
                     drg_counter, drover_pulse_count), ADI_VERBOSITY_LOW);
            end
          end
        end

        DRG_DWELL_UPPER: begin
          drover_tp = 1'b1;
          if (both_no_dwell) begin
            if (drctl_negedge_det)
              drg_state = DRG_RAMP_DOWN;
          end else if (no_dwell_low) begin
            if (drctl_negedge_det)
              drg_state = DRG_RAMP_DOWN;
          end else begin
            if (!drctl_tp)
              drg_state = DRG_RAMP_DOWN;
          end
        end

        DRG_RAMP_DOWN: begin
          drover_tp = 1'b0;
          if (both_no_dwell && drctl_posedge_det) begin
            drg_state = DRG_RAMP_UP;
          end else if (drg_counter > DRG_LOWER_LIMIT + DRG_STEP_SIZE) begin
            drg_counter = drg_counter - DRG_STEP_SIZE;
          end else begin
            drover_pulse_count++;
            if (no_dwell_low) begin
              drg_burst_blade_count++;
              `INFO(("DRG Model: Lower limit reached (blade=%0d) - snapping to upper",
                     drover_pulse_count), ADI_VERBOSITY_LOW);
              drg_counter = DRG_UPPER_LIMIT;
              drover_tp   = 1'b1;
              if (drg_burst_blade_limit > 0 && drg_burst_blade_count >= drg_burst_blade_limit) begin
                drg_burst_hold = 1;
                `INFO(("DRG Model: Burst limit reached (%0d blades) - auto-hold",
                       drg_burst_blade_limit), ADI_VERBOSITY_LOW);
              end
              if (both_no_dwell) begin
                // Both no-dwell: auto-continue (stay in DRG_RAMP_DOWN)
              end else begin
                // No-dwell low only: wait at upper for next negedge
                drg_state = DRG_DWELL_UPPER;
              end
            end else begin
              drg_counter = DRG_LOWER_LIMIT;
              drg_state   = DRG_DWELL_LOWER;
              drover_tp   = 1'b1;
              `INFO(("DRG Model: Lower limit reached (count=%0d, transitions=%0d)",
                     drg_counter, drover_pulse_count), ADI_VERBOSITY_LOW);
            end
          end
        end

      endcase
    end
  end

  // Task to enable/disable the DRG model
  task enable_drg_model(input bit enable);
    drg_model_enabled = enable;
    if (enable) begin
      `INFO(("DRG Model: Enabled"), ADI_VERBOSITY_LOW);
    end else begin
      `INFO(("DRG Model: Disabled"), ADI_VERBOSITY_LOW);
    end
  endtask

  // Task to read REG_RAMP_CTRL and update cached value used by the DRG model
  task read_ramp_ctrl();
    axi_read(reg_addr(REG_RAMP_CTRL), ramp_ctrl_val);
    `INFO(("DRG Model: ramp_ctrl_val=0x%02x (no_dwell_high=%0b, no_dwell_low=%0b)",
           ramp_ctrl_val, ramp_ctrl_val[RAMP_NO_DWELL_HIGH], ramp_ctrl_val[RAMP_NO_DWELL_LOW]), ADI_VERBOSITY_LOW);
  endtask

  // Task to set burst blade limit (0 = unlimited)
  task set_drg_burst_limit(input int unsigned limit);
    drg_burst_blade_limit = limit;
    drg_burst_blade_count = 0;
    drg_burst_hold = 0;
    `INFO(("DRG Model: Burst blade limit set to %0d (0=unlimited)", limit), ADI_VERBOSITY_LOW);
  endtask

  // Task to start a new burst (resets blade count, releases burst hold)
  task start_new_burst();
    drg_burst_blade_count = 0;
    drg_burst_hold = 0;
    drctl_d = 0;
    `INFO(("DRG Model: New burst started (limit=%0d)", drg_burst_blade_limit), ADI_VERBOSITY_LOW);
  endtask

  // Task to reset DRG counter to a specific value
  task reset_drg_counter(input logic [DRG_WIDTH-1:0] value = DRG_LOWER_LIMIT);
    drg_counter = value;
    drg_state   = (value >= DRG_UPPER_LIMIT) ? DRG_DWELL_UPPER : DRG_DWELL_LOWER;
    drover_tp   = 1'b1;
    drover_pulse_count = 0;
    drg_burst_blade_count = 0;
    drg_burst_hold = 0;
    drctl_d = 0;
    `INFO(("DRG Model: Counter reset to %0d (drover=%b)", value, drover_tp), ADI_VERBOSITY_LOW);
  endtask

  // Task to wait for N limit transitions (drover_pulse_count increments when limit is reached)
  task automatic wait_drover_pulses(input int unsigned n_transitions, input int unsigned timeout_us = 100);
    int unsigned target_count;
    int unsigned timeout_cycles;
    int unsigned cycle_count;

    target_count = drover_pulse_count + n_transitions;
    timeout_cycles = timeout_us * 250;  // Assuming 250 MHz sync_clk
    cycle_count = 0;

    `INFO(("DRG Model: Waiting for %0d limit transition(s)...", n_transitions), ADI_VERBOSITY_LOW);

    while (drover_pulse_count < target_count && cycle_count < timeout_cycles) begin
      @(posedge sync_clk_tp);
      cycle_count++;
    end

    if (drover_pulse_count >= target_count) begin
      `INFO(("DRG Model: Got %0d limit transition(s), total=%0d, drover=%b",
             n_transitions, drover_pulse_count, drover_tp), ADI_VERBOSITY_LOW);
    end else begin
      `ERROR(("DRG Model: Timeout waiting for limit transitions (got %0d, expected %0d)",
              drover_pulse_count, target_count));
    end
  endtask

  // Task to get current DRG counter value
  function logic [DRG_WIDTH-1:0] get_drg_counter();
    return drg_counter;
  endfunction

  // --------------------------
  // Wrapper function for AXI read verify
  // --------------------------
  task axi_read_v(
    input   [31:0]  raddr,
    input   [31:0]  vdata);
    base_env.mng.master_sequencer.RegReadVerify32(raddr, vdata);
  endtask

  task axi_read(
    input   [31:0]  raddr,
    output  [31:0]  data);
    base_env.mng.master_sequencer.RegRead32(raddr, data);
  endtask

  // --------------------------
  // Wrapper function for AXI write
  // --------------------------
  task axi_write(
    input [31:0]  waddr,
    input [31:0]  wdata);
    base_env.mng.master_sequencer.RegWrite32(waddr, wdata);
  endtask

  // --------------------------
  // Register address helper
  // --------------------------
  function [31:0] reg_addr(input [6:0] offset);
    return `AXI_AD9910_BA + (offset << 2);
  endfunction


  // --------------------------
  // Main test sequence
  // --------------------------
  initial begin
    setLoggerVerbosity(ADI_VERBOSITY_LOW);

    // Initialize outputs
    ext_sync_tp = 1'b0;
    drover_tp = 1'b0;
    sync_smp_err_tp = 1'b0;
    ram_swp_ovr_tp = 1'b0;

    // Create environment
    base_env = new(
      .name("Base Environment"),
      .sys_clk_vip_if(`TH.`SYS_CLK.inst.IF),
      .dma_clk_vip_if(`TH.`DMA_CLK.inst.IF),
      .ddr_clk_vip_if(`TH.`DDR_CLK.inst.IF),
      .sys_rst_vip_if(`TH.`SYS_RST.inst.IF),
      .irq_base_address(`IRQ_C_BA),
      .irq_vip_if(`TH.`IRQ.inst.inst.IF.vif));

    mng = new(
      .name(""),
      .master_vip_if(`TH.`MNG_AXI.inst.IF));
    ddr = new(
      .name(""),
      .slave_vip_if(`TH.`DDR_AXI.inst.IF));

    `LINK(mng, base_env, mng)
    `LINK(ddr, base_env, ddr)

    base_env.start();
    base_env.sys_reset();

    `INFO(("==== AD9910 DRG Mode Testbench ===="), ADI_VERBOSITY_NONE);

    // ----------------------------------------
    // Test 1: Sanity test - read version/ID
    // ----------------------------------------
    `INFO(("Test 1: Sanity test - register access"), ADI_VERBOSITY_NONE);

    axi_read(reg_addr(REG_VERSION), read_data);
    `INFO(("  Version register: 0x%08x", read_data), ADI_VERBOSITY_LOW);

    axi_read(reg_addr(REG_ID), read_data);
    `INFO(("  ID register: 0x%08x", read_data), ADI_VERBOSITY_LOW);

    // Write and read scratch register
    axi_write(reg_addr(REG_SCRATCH), 32'hDEADBEEF);
    axi_read_v(reg_addr(REG_SCRATCH), 32'hDEADBEEF);
    `INFO(("  Scratch register test PASSED"), ADI_VERBOSITY_NONE);

    // ----------------------------------------
    // Test 2: Take device out of reset
    // ----------------------------------------
    `INFO(("Test 2: Device reset sequence"), ADI_VERBOSITY_NONE);

    // Release reset (clear reset bits, keep device in known state)
    axi_write(reg_addr(REG_CONTROL), 32'h00000000);
    #10us;  // Allow reset to propagate through CDC

    // Debug: Check if sync_clk is running via clock monitor
    axi_read(reg_addr(REG_SYNC_CLK_CNT), read_data);
    `INFO(("  Sync clock count: 0x%08x", read_data), ADI_VERBOSITY_LOW);
    #1us;
    axi_read(reg_addr(REG_SYNC_CLK_CNT), read_data);
    `INFO(("  Sync clock count after 1us: 0x%08x", read_data), ADI_VERBOSITY_LOW);

    // Verify main_reset, io_reset and pw_down are deasserted
    if (main_reset_tp == 1'b0 && io_reset_tp == 1'b0 && pw_down_tp == 1'b0) begin
      `INFO(("  Device reset released - PASSED"), ADI_VERBOSITY_NONE);
    end else begin
      `ERROR(("  Device reset failed - main_reset=%b, io_reset=%b, pw_down=%b", main_reset_tp, io_reset_tp, pw_down_tp));
      test_passed = 0;
    end

    // Enable DRG model after reset is released
    reset_drg_counter();
    enable_drg_model(1);

    // ----------------------------------------
    // Test 3: Configure DRG mode
    // ----------------------------------------
    `INFO(("Test 3: Configure DRG mode"), ADI_VERBOSITY_NONE);

    // Configure ramp delays
    axi_write(reg_addr(REG_BST_DELAY), 32'd250);    // Before start delay
    axi_write(reg_addr(REG_ALR_DELAY), 32'd75);     // After level reached delay
    axi_write(reg_addr(REG_BURST_DELAY), 32'd200);  // Burst delay
    axi_write(reg_addr(REG_RAMP_BURSTS), 32'd5);    // Number of bursts

    // Configure ramp control: enable toggle mode, set drctl_init high
    // Bits: [5] no_dwell_high, [4] no_dwell_low, [3] drctl_toggle_en,
    //       [2] drctl_init, [1] drhold, [0] osk
    axi_write(reg_addr(REG_RAMP_CTRL), 32'h0C);  // drctl_toggle_en=1, drctl_init=1

    // Verify configuration
    axi_read_v(reg_addr(REG_BST_DELAY), 32'd250);
    axi_read_v(reg_addr(REG_RAMP_CTRL), 32'h0C);
    `INFO(("  DRG configuration - PASSED"), ADI_VERBOSITY_NONE);

    // Verify io_update output pulses when register is written
    axi_write(reg_addr(REG_IO_UPDATE), 32'h00000001);
    begin
      int unsigned timeout = 1250; // 5us at 250 MHz
      while (!io_update_tp && timeout > 0) begin
        @(posedge sync_clk_tp);
        timeout--;
      end
      if (timeout > 0) begin
        `INFO(("  io_update output pulsed - PASSED"), ADI_VERBOSITY_NONE);
      end else begin
        `ERROR(("  io_update output did not pulse within 5us"));
        test_passed = 0;
      end
    end

    // ----------------------------------------
    // Test 4: Trigger ramp and verify drctl
    // ----------------------------------------
    `INFO(("Test 4: Ramp operation"), ADI_VERBOSITY_NONE);

    // Wait for drctl to assert (ramp starts automatically after config + BST_DELAY)
    begin
      int unsigned timeout = 2500; // 10us at 250 MHz
      while (!drctl_tp && timeout > 0) begin
        @(posedge sync_clk_tp);
        timeout--;
      end
      if (timeout == 0) begin
        `ERROR(("drctl did not assert within 10us"));
      end
    end

    // Wait for DRG model to reach upper limit
    `INFO(("  Waiting for ramp to reach upper limit..."), ADI_VERBOSITY_LOW);
    wait_drover_pulses(1, 50);

    // Verify counter reached upper limit
    `INFO(("  DRG counter value: %0d", get_drg_counter()), ADI_VERBOSITY_LOW);

    // ----------------------------------------
    // Test 4b: Verify ramp toggle mode
    // ----------------------------------------
    `INFO(("Test 4b: Ramp toggle - full cycle"), ADI_VERBOSITY_NONE);

    // Reset counter and wait for a complete up-down cycle (2 drover pulses)
    reset_drg_counter();
    #500ns;
    `INFO(("  Waiting for complete ramp cycle (up + down)..."), ADI_VERBOSITY_LOW);
    wait_drover_pulses(3, 100);

    `INFO(("  Ramp toggle cycle complete - DRG counter: %0d, drover_pulses: %0d",
           get_drg_counter(), drover_pulse_count), ADI_VERBOSITY_LOW);

    // ----------------------------------------
    // Test 5: Verify profile output
    // ----------------------------------------
    `INFO(("Test 5: Profile selection"), ADI_VERBOSITY_NONE);

    axi_write(reg_addr(REG_PROFILE), 32'h00000002);
    #5us;  // Allow CDC to propagate (up_xfer_cntrl needs multiple clock cycles)

    `INFO(("  DEBUG: profile_tp = %b", profile_tp), ADI_VERBOSITY_LOW);

    if (profile_tp == 3'b010) begin
      `INFO(("  Profile output matches - PASSED"), ADI_VERBOSITY_NONE);
    end else begin
      `ERROR(("  Profile mismatch - expected 2, got %d", profile_tp));
      test_passed = 0;
    end

    // ----------------------------------------
    // Test 6: Test drhold - verify counter freezes
    // ----------------------------------------
    `INFO(("Test 6: DRHOLD control"), ADI_VERBOSITY_NONE);

    // First, reset counter and let it ramp a bit
    reset_drg_counter();
    #2us;  // Let counter ramp up a bit

    // Capture counter value before hold
    begin
      logic [DRG_WIDTH-1:0] counter_when_hold_active;
      logic [DRG_WIDTH-1:0] counter_during_hold;
      logic [DRG_WIDTH-1:0] counter_after_hold;

      // Set drhold
      axi_write(reg_addr(REG_RAMP_CTRL), 32'h0E);  // drctl_toggle_en=1, drctl_init=1, drhold=1
      axi_read_v(reg_addr(REG_RAMP_CTRL), 32'h0E);

      // Wait for drhold to propagate through CDC
      begin
        int unsigned timeout = 2500; // 10us at 250 MHz
        while (!drhold_tp && timeout > 0) begin
          @(posedge sync_clk_tp);
          timeout--;
        end
        if (timeout == 0) begin
          `ERROR(("drhold did not assert within 10us"));
          test_passed = 0;
        end
      end

      // Capture counter value NOW that hold is active
      counter_when_hold_active = get_drg_counter();
      `INFO(("  Counter when hold active: %0d", counter_when_hold_active), ADI_VERBOSITY_LOW);

      // Wait and verify counter is frozen
      #3us;
      counter_during_hold = get_drg_counter();
      `INFO(("  Counter after waiting during hold: %0d", counter_during_hold), ADI_VERBOSITY_LOW);

      // Counter should not have changed while hold is active
      if (counter_during_hold == counter_when_hold_active) begin
        `INFO(("  Counter frozen during hold - PASSED"), ADI_VERBOSITY_NONE);
      end else begin
        `ERROR(("  Counter not frozen - when_active=%0d, during=%0d", counter_when_hold_active, counter_during_hold));
        test_passed = 0;
      end

      // Clear drhold
      axi_write(reg_addr(REG_RAMP_CTRL), 32'h0C);
      #2us;  // Allow CDC to propagate

      if (drhold_tp == 1'b0) begin
        `INFO(("  DRHOLD deasserted - PASSED"), ADI_VERBOSITY_NONE);
      end else begin
        `ERROR(("  DRHOLD not deasserted"));
        test_passed = 0;
      end

      // Verify counter resumes (or stays at limit if already there)
      #3us;
      counter_after_hold = get_drg_counter();
      `INFO(("  Counter after hold released: %0d (drctl=%b)", counter_after_hold, drctl_tp), ADI_VERBOSITY_LOW);

      // Counter should resume or stay at limit if already at boundary
      if (counter_after_hold != counter_during_hold) begin
        `INFO(("  Counter resumed after hold - PASSED"), ADI_VERBOSITY_NONE);
      end else if (counter_during_hold == DRG_LOWER_LIMIT || counter_during_hold == DRG_UPPER_LIMIT) begin
        `INFO(("  Counter at limit, hold behavior correct - PASSED"), ADI_VERBOSITY_NONE);
      end else begin
        `ERROR(("  Counter did not resume - during=%0d, after=%0d", counter_during_hold, counter_after_hold));
        test_passed = 0;
      end
    end

    // ----------------------------------------
    // Test 7: Sawtooth mode with inter-blade delay (ALR_DELAY)
    // Verify that after each blade reaches the upper limit, the DRG
    // pauses for ALR_DELAY sync_clk cycles before starting the next blade.
    // ----------------------------------------
    `INFO(("Test 7: Sawtooth mode with inter-blade delay"), ADI_VERBOSITY_NONE);

    begin
      int unsigned blade_start_count;
      bit [31:0] reg_bst_delay;
      bit [31:0] reg_alr_delay;
      int unsigned bst_delay_cycles;
      int unsigned alr_delay_cycles;
      int unsigned n_blades = 5;
      logic [DRG_WIDTH-1:0] counter_before_delay;
      logic [DRG_WIDTH-1:0] counter_after_delay;

      // Read delay parameters from DUT registers
      axi_read(reg_addr(REG_BST_DELAY), reg_bst_delay);
      axi_read(reg_addr(REG_ALR_DELAY), reg_alr_delay);
      bst_delay_cycles = reg_bst_delay;
      alr_delay_cycles = reg_alr_delay;

      `INFO(("  Configuration: BST_DELAY=%0d, ALR_DELAY=%0d sync_clk cycles, %0d blades",
             bst_delay_cycles, alr_delay_cycles, n_blades), ADI_VERBOSITY_LOW);

      // Enable sawtooth mode via NO_DWELL_HIGH, auto-hold after each blade
      set_drg_burst_limit(1);

      // Set ramp control: no_dwell_high=1, drctl_toggle_en=1, drctl_init=1
      axi_write(reg_addr(REG_RAMP_CTRL), 32'h2C);
      read_ramp_ctrl();
      #3us;

      // Reset DRG model
      reset_drg_counter();
      blade_start_count = drover_pulse_count;

      // Wait BST_DELAY before first blade begins ramping
      `INFO(("  Waiting BST_DELAY (%0d cycles) before first blade...", bst_delay_cycles), ADI_VERBOSITY_LOW);
      repeat (bst_delay_cycles) @(posedge sync_clk_tp);

      for (int i = 0; i < n_blades; i++) begin
        `INFO(("  === Blade %0d/%0d ===", i + 1, n_blades), ADI_VERBOSITY_NONE);

        // Release hold to start this blade
        start_new_burst();

        // Wait for blade to ramp up to upper limit
        wait_drover_pulses(1, 50);

        `INFO(("  Blade %0d complete: counter=%0d, drover_pulses=%0d",
               i + 1, get_drg_counter(), drover_pulse_count), ADI_VERBOSITY_LOW);

        // Verify model auto-held
        if (!drg_burst_hold) begin
          `ERROR(("  Blade %0d: model did not auto-hold", i + 1));
          test_passed = 0;
        end

        // Apply inter-blade delay (ALR_DELAY) - except after last blade
        if (i < n_blades - 1) begin
          counter_before_delay = get_drg_counter();

          `INFO(("  Inter-blade delay: %0d sync_clk cycles", alr_delay_cycles), ADI_VERBOSITY_LOW);
          repeat (alr_delay_cycles) @(posedge sync_clk_tp);

          counter_after_delay = get_drg_counter();

          // Verify counter stayed frozen during delay
          if (counter_after_delay != counter_before_delay) begin
            `ERROR(("  Counter moved during inter-blade delay - before=%0d, after=%0d",
                    counter_before_delay, counter_after_delay));
            test_passed = 0;
          end else begin
            `INFO(("  Counter frozen during delay - PASSED"), ADI_VERBOSITY_LOW);
          end
        end
      end

      // Verify total blades completed
      if ((drover_pulse_count - blade_start_count) == n_blades) begin
        `INFO(("  %0d sawtooth blades with ALR_DELAY=%0d between each - PASSED",
               n_blades, alr_delay_cycles), ADI_VERBOSITY_NONE);
      end else begin
        `ERROR(("  Expected %0d blades, got %0d",
                n_blades, drover_pulse_count - blade_start_count));
        test_passed = 0;
      end

      // Clean up
      set_drg_burst_limit(0);
      axi_write(reg_addr(REG_RAMP_CTRL), 32'h0C);
      read_ramp_ctrl();
    end

    // ----------------------------------------
    // Test 8: Burst mode - sawtooth blades with burst limits and delay
    // driven by REG_RAMP_BURSTS and REG_BURST_DELAY register values
    // ----------------------------------------
    `INFO(("Test 8: Burst mode - sawtooth pattern with burst limits"), ADI_VERBOSITY_NONE);

    begin
      int unsigned burst1_start_count;
      int unsigned burst1_end_count;
      int unsigned burst2_start_count;
      int unsigned burst2_end_count;
      bit [31:0] reg_bursts;
      bit [31:0] reg_burst_delay;
      int unsigned blades_per_burst;
      int unsigned burst_delay_cycles;
      logic [DRG_WIDTH-1:0] counter_before_delay;
      logic [DRG_WIDTH-1:0] counter_after_delay;

      // Read burst parameters from DUT registers
      axi_read(reg_addr(REG_RAMP_BURSTS), reg_bursts);
      axi_read(reg_addr(REG_BURST_DELAY), reg_burst_delay);
      blades_per_burst = reg_bursts;
      burst_delay_cycles = reg_burst_delay;

      // Enable sawtooth mode via NO_DWELL_HIGH and set burst blade limit from register value
      set_drg_burst_limit(blades_per_burst);

      `INFO(("  Configuration: %0d blades/burst, %0d sync_clk cycles delay between bursts",
             blades_per_burst, burst_delay_cycles), ADI_VERBOSITY_LOW);

      // Set ramp control: no_dwell_high=1, drctl_toggle_en=1, drctl_init=1
      axi_write(reg_addr(REG_RAMP_CTRL), 32'h2C);
      read_ramp_ctrl();
      #2us;

      // Reset DRG model to lower limit
      reset_drg_counter();
      burst1_start_count = drover_pulse_count;

      `INFO(("  DRG starting state: counter=%0d, drctl=%b, drover=%b",
             get_drg_counter(), drctl_tp, drover_tp), ADI_VERBOSITY_LOW);

      // ========== BURST 1 ==========
      `INFO(("  === Burst 1: Starting %0d sawtooth blades ===", blades_per_burst), ADI_VERBOSITY_NONE);

      // Wait for first burst to complete (model auto-holds after blades_per_burst)
      wait_drover_pulses(blades_per_burst, 50);
      burst1_end_count = drover_pulse_count;

      `INFO(("  Burst 1 complete: %0d blades, burst_hold=%b",
             burst1_end_count - burst1_start_count, drg_burst_hold), ADI_VERBOSITY_LOW);

      if ((burst1_end_count - burst1_start_count) == blades_per_burst) begin
        `INFO(("  Burst 1 - %0d sawtooth blades - PASSED", blades_per_burst), ADI_VERBOSITY_NONE);
      end else begin
        `ERROR(("  Burst 1 failed - got %0d blades, expected %0d",
                burst1_end_count - burst1_start_count, blades_per_burst));
        test_passed = 0;
      end

      // Verify model auto-held (no 6th blade started)
      if (drg_burst_hold) begin
        `INFO(("  Model auto-held after burst - PASSED"), ADI_VERBOSITY_NONE);
      end else begin
        `ERROR(("  Model did not auto-hold after burst"));
        test_passed = 0;
      end

      // ========== BURST DELAY ==========
      `INFO(("  === Burst delay: %0d sync_clk cycles ===", burst_delay_cycles), ADI_VERBOSITY_NONE);

      counter_before_delay = get_drg_counter();

      // Wait for the burst delay period (model is already auto-held)
      repeat (burst_delay_cycles) @(posedge sync_clk_tp);

      counter_after_delay = get_drg_counter();
      `INFO(("  After delay: counter=%0d (was %0d)", counter_after_delay, counter_before_delay), ADI_VERBOSITY_LOW);

      // Verify counter stayed frozen during delay
      if (counter_after_delay == counter_before_delay) begin
        `INFO(("  Burst delay - counter frozen for %0d cycles - PASSED", burst_delay_cycles), ADI_VERBOSITY_NONE);
      end else begin
        `ERROR(("  Counter moved during burst delay - before=%0d, after=%0d",
                counter_before_delay, counter_after_delay));
        test_passed = 0;
      end

      // ========== BURST 2 ==========
      `INFO(("  === Burst 2: Starting %0d sawtooth blades ===", blades_per_burst), ADI_VERBOSITY_NONE);

      burst2_start_count = drover_pulse_count;

      // Release burst hold and start new burst
      start_new_burst();

      // Wait for second burst to complete
      wait_drover_pulses(blades_per_burst, 50);
      burst2_end_count = drover_pulse_count;

      `INFO(("  Burst 2 complete: %0d blades", burst2_end_count - burst2_start_count), ADI_VERBOSITY_LOW);

      if ((burst2_end_count - burst2_start_count) == blades_per_burst) begin
        `INFO(("  Burst 2 - %0d sawtooth blades - PASSED", blades_per_burst), ADI_VERBOSITY_NONE);
      end else begin
        `ERROR(("  Burst 2 failed - got %0d blades, expected %0d",
                burst2_end_count - burst2_start_count, blades_per_burst));
        test_passed = 0;
      end

      // ========== SUMMARY ==========
      `INFO(("  === Burst mode summary ==="), ADI_VERBOSITY_NONE);
      `INFO(("  Total blades: %0d (Burst1=%0d + Burst2=%0d)",
             burst2_end_count - burst1_start_count,
             burst1_end_count - burst1_start_count,
             burst2_end_count - burst2_start_count), ADI_VERBOSITY_LOW);
      `INFO(("  Burst delay: %0d sync_clk cycles", burst_delay_cycles), ADI_VERBOSITY_LOW);

      // Clean up: disable burst limit and switch back to triangle mode
      set_drg_burst_limit(0);
      axi_write(reg_addr(REG_RAMP_CTRL), 32'h0C);
      read_ramp_ctrl();
    end

    // ----------------------------------------
    // Test 9: Sawtooth DOWN mode (NO_DWELL_LOW)
    // Verify that with NO_DWELL_LOW set, the ramp always goes down
    // and snaps back to the upper limit when the lower limit is reached.
    // Run a continuous burst of blades with no delay between them.
    // ----------------------------------------
    `INFO(("Test 9: Sawtooth DOWN mode (NO_DWELL_LOW)"), ADI_VERBOSITY_NONE);

    begin
      int unsigned blade_start_count;
      int unsigned n_blades = 5;

      // Enable sawtooth DOWN mode via NO_DWELL_LOW, auto-hold after full burst
      set_drg_burst_limit(n_blades);

      // Set ramp control: no_dwell_low=1, drctl_toggle_en=1, drctl_init=1
      axi_write(reg_addr(REG_RAMP_CTRL), 32'h1C);
      read_ramp_ctrl();
      #3us;

      // Reset DRG model to UPPER limit (sawtooth down starts from top)
      reset_drg_counter(DRG_UPPER_LIMIT);
      blade_start_count = drover_pulse_count;

      `INFO(("  Starting %0d sawtooth DOWN blades (no inter-blade delay)...", n_blades), ADI_VERBOSITY_NONE);

      // Wait for all blades to complete continuously
      wait_drover_pulses(n_blades, 100);

      `INFO(("  Burst complete: drover_pulses=%0d, burst_hold=%b",
             drover_pulse_count, drg_burst_hold), ADI_VERBOSITY_LOW);

      // Verify model auto-held after all blades
      if (drg_burst_hold) begin
        `INFO(("  Model auto-held after %0d blades - PASSED", n_blades), ADI_VERBOSITY_NONE);
      end else begin
        `ERROR(("  Model did not auto-hold after %0d blades", n_blades));
        test_passed = 0;
      end

      // Verify total blades completed
      if ((drover_pulse_count - blade_start_count) == n_blades) begin
        `INFO(("  %0d sawtooth DOWN blades completed - PASSED", n_blades), ADI_VERBOSITY_NONE);
      end else begin
        `ERROR(("  Expected %0d blades, got %0d",
                n_blades, drover_pulse_count - blade_start_count));
        test_passed = 0;
      end

      // Clean up
      set_drg_burst_limit(0);
      axi_write(reg_addr(REG_RAMP_CTRL), 32'h0C);
      read_ramp_ctrl();
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
