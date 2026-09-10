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

// AD9910 DRG mode testbench.
//
// The DRG controller is an open-loop PWM generator: drctl is produced entirely
// from DRCTL_PERIOD and DRCTL_WIDTH (sync_clk cycle counts). drover is an
// interrupt/status input only - it does not drive any DUT state machine. Every
// timing check here is therefore a direct, deterministic measurement of the
// drctl waveform at the DUT boundary.

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
  output reg    ext_sync_tp,
  input         ad9910_irq_tp,
  input         trig_out_tp,
  input         drctl_tp,
  input         drhold_tp,
  output reg    drover_tp,
  output reg    ram_swp_ovr_tp,
  input  [2:0]  profile_tp,
  input  [1:0]  f_o_tp,
  input  [15:0] db_o_tp,
  input         tx_enable_tp
);

  timeunit 1ns;
  timeprecision 1ps;

  // --------------------------
  // Register addresses (word offsets, from axi_ad9910_reg.v)
  // --------------------------
  localparam REG_VERSION        = 7'h00;
  localparam REG_ID             = 7'h01;
  localparam REG_SCRATCH        = 7'h02;
  localparam REG_CONFIG         = 7'h03;
  localparam REG_DEVICE_INFO    = 7'h07;
  localparam REG_RESET_CTRL     = 7'h10;
  localparam REG_IRQ_MASK       = 7'h11;
  localparam REG_IRQ_TABLE      = 7'h12;
  localparam REG_IRQ_MON_CFG    = 7'h13;
  localparam REG_TRIG_OUT_CTRL  = 7'h14;
  localparam REG_EXT_TRIG_CFG   = 7'h15;
  localparam REG_SYNC_CLK_CNT   = 7'h20;
  localparam REG_DRG_CTRL       = 7'h21;
  localparam REG_PROFILE        = 7'h22;
  localparam REG_DRCTL_PERIOD   = 7'h23;
  localparam REG_DRCTL_WIDTH    = 7'h24;
  localparam REG_BST_DELAY      = 7'h25;
  localparam REG_RAMP_BURSTS    = 7'h26;
  localparam REG_BURST_DELAY    = 7'h27;
  localparam REG_RAMP_CFG       = 7'h28;
  localparam REG_MON_MAX_PERIOD = 7'h29;
  localparam REG_IRQ_START      = 7'h2a;
  localparam REG_IRQ_STOP       = 7'h2b;
  localparam REG_TRIG_START     = 7'h2c;
  localparam REG_TRIG_STOP      = 7'h2d;
  // Parallel-interface group: unused in DRG mode apart from the clock monitor.
  localparam REG_PD_CLK_CNT     = 7'h40;

  // DRG_CTRL (0x21) bit positions
  localparam DRG_TOGGLE_EN      = 3;
  localparam DRG_DRCTL_INIT     = 2;
  localparam DRG_DRHOLD         = 1;

  // IRQ_MASK / IRQ_TABLE (0x11 / 0x12) bit positions
  localparam IRQ_INTERVAL_START = 5;
  localparam IRQ_INTERVAL_STOP  = 4;
  localparam IRQ_DROVER         = 2;
  localparam IRQ_BURSTS         = 1;
  localparam IRQ_RAM_SWP_OVR    = 0;

  // TRIG_OUT_CTRL (0x14): mask occupies [21:16], trig_config [1:0]
  localparam TRIG_MASK_SHIFT    = 16;

  // Interval monitor / trigger source select (IRQ_MON_CFG, TRIG_OUT_CTRL[1:0])
  localparam MON_CFG_PERIOD     = 2'd0;
  localparam MON_CFG_BURST_DLY  = 2'd1;
  localparam MON_CFG_MAX_PERIOD = 2'd2;

  // RAMP_CFG (0x28)
  localparam RAMP_CFG_FREE_RUN  = 2'd0;
  localparam RAMP_CFG_BURST_STOP = 2'd1;
  localparam RAMP_CFG_PERIOD_STOP = 2'd2;

  // sync_clk is 250 MHz (4 ns period)
  localparam int CYCLES_PER_US = 250;

  // up_xfer_cntrl initiates a control transfer only when its free-running 6-bit
  // up_clk counter reads 1 (common/up_xfer_cntrl.v:96), so a register write is
  // held at the domain crossing for anywhere between 0 and 64 up_clk cycles -
  // 160 sync_clk cycles at 100 MHz up_clk against 250 MHz sync_clk. Every
  // interval timed from an AXI write carries that quantization, and it is far
  // coarser than the synchroniser latency it is easy to mistake it for.
  localparam int CDC_XFER_JITTER = 160;

  // Settle time covering the up->sync CDC handshake, the 8 sync_clk-cycle
  // reset_overwrite pulse, and the AXI write pipeline. 4 us is 400 up_clk
  // cycles, so it always spans a whole up_xfer_cntrl transfer window.
  localparam int CFG_SETTLE_NS = 4000;

  // Base duty cycle shared by most tests: 4 us period at 250 MHz, 40% duty.
  // Sized for legibility rather than minimum runtime - a period of a few
  // hundred nanoseconds packs dozens of edges into any waveform view wide
  // enough to hold a whole test, so neither drctl nor the ramp it drives can be
  // read off the trace. The asymmetric duty makes the high and low intervals
  // distinguishable at a glance, and both are longer than DRG_RAMP_CYCLES so
  // the modelled ramp reaches its limit in each of them.
  localparam int PWM_PERIOD = 1000;
  localparam int PWM_WIDTH  = 400;

  // --------------------------
  // Test environment
  // --------------------------
  test_harness_env base_env;
  adi_axi_master_agent #(`AXI_VIP_PARAMS(test_harness, mng_axi_vip)) mng;
  adi_axi_slave_mem_agent #(`AXI_VIP_PARAMS(test_harness, ddr_axi_vip)) ddr;

  bit [31:0] read_data;
  bit        test_passed = 1;
  int        current_test = 0;   // waveform navigation aid

  // --------------------------
  // AD9910 digital ramp model
  // --------------------------
  // Level-driven integrator: drctl high ramps the counter up, drctl low ramps
  // it down, and drover is asserted whenever the counter is parked at a limit.
  // The DUT reads none of this - the model exists to produce a realistic drover
  // for the interrupt tests and to detect ramps that the programmed DRCTL_WIDTH
  // is too short to complete.
  localparam int DRG_WIDTH = 18;
  localparam logic [DRG_WIDTH-1:0] DRG_LOWER_LIMIT = 18'd1000;
  localparam logic [DRG_WIDTH-1:0] DRG_UPPER_LIMIT = 18'd5000;
  // Step chosen against PWM_WIDTH: a full ramp takes half the base high
  // interval, so a dwelling ramp shows a clear slope into a clear plateau
  // instead of a near-vertical edge, and a sawtooth fits exactly two whole
  // blades into that interval. Both limits stay exact multiples of the step.
  localparam logic [DRG_WIDTH-1:0] DRG_STEP_SIZE   = 18'd20;

  // sync_clk cycles for one full limit-to-limit ramp: (5000-1000)/20
  localparam int DRG_RAMP_CYCLES = 200;

  // Ramp shape at the limit. DWELL parks there until drctl changes direction -
  // an AD9910 with both no-dwell bits clear. SAWTOOTH is no-dwell *high* only,
  // the configuration a repeating chirp is generated with: reaching the upper
  // limit reloads the lower one so the up-ramp repeats, while the downward
  // direction still dwells. That asymmetry is what lets the ramp come to rest by
  // itself whenever drctl is parked low. Those bits live in the AD9910's CFR2
  // and are written over SPI, so this IP cannot select the shape: the model has
  // to be told which part it is driving.
  // Dwell is the starting shape because it is the one an AD9910 comes out of
  // reset in - a model that retraces before software has written CFR2 would be
  // claiming a configuration that does not exist yet.
  typedef enum {DRG_DWELL, DRG_SAWTOOTH} drg_shape_e;
  drg_shape_e drg_shape = DRG_DWELL;

  logic [DRG_WIDTH-1:0] drg_counter;
  bit                   drg_model_enabled = 0;
  bit                   check_ramp_completion = 0;
  int unsigned          ramp_truncation_count = 0;
  int unsigned          drover_rise_count = 0;
  int unsigned          drg_retrace_count = 0;
  // Held at module scope so enable_drg_model can resync it: the model only
  // samples drctl while enabled, so a stale value here would look like a level
  // change on the first sync_clk cycle after re-enabling.
  bit                   drg_drctl_prev = 0;

  initial begin : drg_model
    drg_counter = DRG_LOWER_LIMIT;
    drover_tp   = 1'b1;              // parked at the lower limit

    forever begin
      @(posedge sync_clk_tp);

      if (drg_model_enabled && !drhold_tp) begin
        // A level change means the previous ramp is over. If the counter had
        // not yet reached the limit it was heading for, the interval was too
        // short - this is the software programming error behind ramps that
        // never reach their endpoint. Only meaningful while dwelling: a
        // sawtooth retraces on its own, so no interval can cut it short.
        if (check_ramp_completion && (drg_shape == DRG_DWELL) &&
            (drctl_tp != drg_drctl_prev)) begin
          if (drctl_tp && (drg_counter != DRG_LOWER_LIMIT)) begin
            ramp_truncation_count++;
            `ERROR(("DRG Model: down-ramp truncated at %0d (needs %0d sync_clk cycles to reach %0d)",
                    drg_counter, DRG_RAMP_CYCLES, DRG_LOWER_LIMIT));
          end
          if (!drctl_tp && (drg_counter != DRG_UPPER_LIMIT)) begin
            ramp_truncation_count++;
            `ERROR(("DRG Model: up-ramp truncated at %0d (needs %0d sync_clk cycles to reach %0d)",
                    drg_counter, DRG_RAMP_CYCLES, DRG_UPPER_LIMIT));
          end
        end

        // Going down always dwells at the lower limit. Going up, a sawtooth
        // reloads the lower limit on the step that would have reached the upper
        // one, rather than landing there first - so a blade is exactly
        // DRG_RAMP_CYCLES long and a high interval that is a whole multiple of
        // it holds a whole number of blades and ends at the bottom. Landing on
        // the limit first would make a blade one sync_clk cycle longer, leaving a partial
        // blade that drctl falling turns into a descent instead of a retrace:
        // the sawtooth-then-triangle shape.
        if (!drctl_tp) begin
          drg_counter = (drg_counter <= DRG_LOWER_LIMIT + DRG_STEP_SIZE) ?
                        DRG_LOWER_LIMIT : drg_counter - DRG_STEP_SIZE;
        end else if (drg_counter + DRG_STEP_SIZE < DRG_UPPER_LIMIT) begin
          drg_counter = drg_counter + DRG_STEP_SIZE;
        end else if (drg_shape == DRG_SAWTOOTH) begin
          drg_counter = DRG_LOWER_LIMIT;
          drg_retrace_count++;
        end else begin
          drg_counter = DRG_UPPER_LIMIT;
        end

        if (!drover_tp &&
            ((drg_counter == DRG_UPPER_LIMIT) || (drg_counter == DRG_LOWER_LIMIT)))
          drover_rise_count++;

        // "The ramp is at a limit" in both shapes, but that reads as a level
        // wherever the ramp dwells and as a one sync_clk-cycle pulse per blade in a
        // sawtooth, on the sync_clk cycle the lower limit is reloaded.
        drover_tp      = (drg_counter == DRG_UPPER_LIMIT) || (drg_counter == DRG_LOWER_LIMIT);
        drg_drctl_prev = drctl_tp;
      end
    end
  end

  // check_completion is only meaningful with DRG_DWELL - see the checker in the
  // model loop.
  task enable_drg_model(input bit         enable,
                        input bit         check_completion = 0,
                        input drg_shape_e shape = DRG_DWELL);
    drg_counter           = DRG_LOWER_LIMIT;
    // While disabled the model stops driving drover, so park it low rather
    // than leaving it asserted - drover is a level source into irq_int[2] and
    // a stuck-high pin re-latches the interrupt as fast as software clears it.
    drover_tp             = enable ? 1'b1 : 1'b0;
    drover_rise_count     = 0;
    ramp_truncation_count = 0;
    drg_retrace_count     = 0;
    drg_drctl_prev        = drctl_tp;   // resync so re-enabling is not seen as an edge
    check_ramp_completion = check_completion;
    drg_shape             = shape;
    drg_model_enabled     = enable;
    `INFO(("DRG Model: %s, %s (completion check %s)",
           enable ? "enabled" : "disabled", shape.name(),
           check_completion ? "on" : "off"), ADI_VERBOSITY_LOW);
  endtask

  // --------------------------
  // AXI access helpers
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

  task axi_write(
    input [31:0]  waddr,
    input [31:0]  wdata);
    base_env.mng.master_sequencer.RegWrite32(waddr, wdata);
  endtask

  function [31:0] reg_addr(input [6:0] offset);
    return `AXI_AD9910_BA + (offset << 2);
  endfunction

  // --------------------------
  // drctl waveform measurement
  // --------------------------
  // Records, for n_periods consecutive drctl duty cycles, the high time and the
  // rising-edge-to-rising-edge period, both in sync_clk cycles. The first rising
  // edge only starts the stopwatch, so any partial period in progress when the
  // task is called is discarded.
  task automatic measure_drctl_waveform(
    input  int unsigned n_periods,
    input  int unsigned timeout_us,
    output int unsigned high_cycles[],
    output int unsigned period_cycles[]
  );
    bit          prev;
    bit          started;
    bit          is_rise;
    int unsigned cyc_since_rise;
    int unsigned cyc_high;
    int unsigned got;
    int unsigned timeout_cycles;

    high_cycles    = new[n_periods];
    period_cycles  = new[n_periods];
    got            = 0;
    started        = 0;
    cyc_since_rise = 0;
    cyc_high       = 0;
    timeout_cycles = timeout_us * CYCLES_PER_US;
    prev           = drctl_tp;

    while (got < n_periods && timeout_cycles > 0) begin
      @(posedge sync_clk_tp);
      timeout_cycles--;

      is_rise = drctl_tp && !prev;
      if (is_rise) begin
        if (started) begin
          period_cycles[got] = cyc_since_rise;
          high_cycles[got]   = cyc_high;
          got++;
        end
        started        = 1;
        cyc_since_rise = 0;
        cyc_high       = 0;
      end

      if (started) begin
        cyc_since_rise++;
        if (drctl_tp) cyc_high++;
      end

      prev = drctl_tp;
    end

    if (got < n_periods) begin
      `ERROR(("measure_drctl_waveform: timeout - got %0d of %0d periods", got, n_periods));
      test_passed = 0;
    end
  endtask

  // Count sync_clk cycles until drctl reaches the requested level.
  // Returns the timeout value if the level is never seen.
  task automatic wait_drctl_level(
    input  bit          level,
    input  int unsigned timeout_cyc,
    output int unsigned cycles
  );
    cycles = 0;
    while ((drctl_tp !== level) && (cycles < timeout_cyc)) begin
      @(posedge sync_clk_tp);
      cycles++;
    end
  endtask

  // Verify drctl holds a constant level for the whole window.
  task automatic check_drctl_static(
    input bit          level,
    input int unsigned window_cyc,
    input string       label
  );
    bit ok = 1;
    for (int unsigned k = 0; k < window_cyc; k++) begin
      @(posedge sync_clk_tp);
      if (drctl_tp !== level) ok = 0;
    end
    if (ok) begin
      `INFO(("  %s: drctl held %0b for %0d sync_clk cycles - PASSED", label, level, window_cyc),
            ADI_VERBOSITY_NONE);
    end else begin
      `ERROR(("  %s: drctl did not hold %0b for %0d sync_clk cycles", label, level, window_cyc));
      test_passed = 0;
    end
  endtask

  function automatic bit all_equal(input int unsigned a[], input int unsigned v);
    foreach (a[k]) if (a[k] != v) return 0;
    return 1;
  endfunction

  function automatic int unsigned min_of(input int unsigned a[]);
    int unsigned m = a[0];
    foreach (a[k]) if (a[k] < m) m = a[k];
    return m;
  endfunction

  function automatic int unsigned max_of(input int unsigned a[]);
    int unsigned m = a[0];
    foreach (a[k]) if (a[k] > m) m = a[k];
    return m;
  endfunction

  function automatic string fmt_array(input int unsigned a[]);
    string s = "{";
    foreach (a[k]) s = {s, $sformatf("%0d%s", a[k], (k == a.size()-1) ? "" : ",")};
    return {s, "}"};
  endfunction

  // --------------------------
  // Configuration helpers
  // --------------------------
  // Program a drctl duty cycle. Toggle mode is cleared first so that the
  // period and width writes do not each trigger their own reset_overwrite
  // (auto_ramp_mode_update watches period/width only while toggle_en is set).
  // This gives one clean restart with a coherent config instead of a restart
  // on an intermediate new-period/old-width pair.
  task automatic program_pwm(input int unsigned p, input int unsigned w);
    axi_write(reg_addr(REG_DRG_CTRL), 32'h0);
    axi_write(reg_addr(REG_DRCTL_PERIOD), p);
    axi_write(reg_addr(REG_DRCTL_WIDTH), w);
    axi_write(reg_addr(REG_DRG_CTRL), 32'h1 << DRG_TOGGLE_EN);
    #CFG_SETTLE_NS;
  endtask

  task automatic stop_pwm();
    axi_write(reg_addr(REG_DRG_CTRL), 32'h0);
    #CFG_SETTLE_NS;
  endtask

  // Time the first drctl rising edge after a restart, for a given start delay.
  //
  // delay_bst_ramp_delay_val is refreshed only on end_period_d or
  // reset_overwrite (axi_ad9910.v:773-781), so a BST_DELAY written while the
  // ramp is stopped is not necessarily the value the next start uses. The
  // priming run lets periods complete with the new value so it is latched,
  // then a clean stop/start is timed. Both call sites run the identical
  // sequence, so the fixed CDC overhead cancels in the difference.
  task automatic measure_start_delay(
    input  int unsigned dly,
    output int unsigned cycles
  );
    axi_write(reg_addr(REG_BST_DELAY), dly);
    axi_write(reg_addr(REG_DRCTL_PERIOD), PWM_PERIOD);
    axi_write(reg_addr(REG_DRCTL_WIDTH), PWM_WIDTH);
    axi_write(reg_addr(REG_DRG_CTRL), 32'h1 << DRG_TOGGLE_EN);
    // The delay plus two whole periods: end_period_d has to fire for the new
    // BST_DELAY to be latched, so the priming window must outlast a period.
    repeat (dly + 2 * PWM_PERIOD) @(posedge sync_clk_tp);

    axi_write(reg_addr(REG_DRG_CTRL), 32'h0);
    repeat (dly + 2 * PWM_PERIOD) @(posedge sync_clk_tp);

    axi_write(reg_addr(REG_DRG_CTRL), 32'h1 << DRG_TOGGLE_EN);
    wait_drctl_level(1'b1, 40000, cycles);
  endtask

  // Measure one burst-delay configuration at the base duty cycle: `bursts`
  // periods, then a gap widened by `burst_delay`. Checks that the duty cycle
  // itself is undisturbed, that the grouping is present, and that the boundary
  // gap grew by the programmed delay. Returns the leftover fixed cost of
  // entering and leaving the burst-delay state so a caller sweeping the delay
  // can compare it across values.
  task automatic check_burst_delay(
    input  int unsigned bursts,
    input  int unsigned burst_delay,
    output int unsigned overhead
  );
    int unsigned high_c[];
    int unsigned per_c[];
    int unsigned short_gap;
    int unsigned long_gap;
    int unsigned n_long;
    int unsigned n_gaps;
    int unsigned settle_cyc;

    n_gaps = 3 * bursts;

    // BURST_DELAY is not one of the registers auto_ramp_mode_update watches, so
    // it is written while stopped and picked up by the restart program_pwm does.
    stop_pwm();
    axi_write(reg_addr(REG_BURST_DELAY), burst_delay);
    program_pwm(PWM_PERIOD, PWM_WIDTH);

    // Three bursts' worth of rising edges: within a burst the gap is one
    // period, and at each burst boundary it grows by BURST_DELAY.
    measure_drctl_waveform(n_gaps, 800, high_c, per_c);

    // Two gap values occur, both in sync_clk cycles. Within a burst, successive
    // rising edges are one PWM period apart (short_gap == PWM_PERIOD). At a burst
    // boundary the gap grows by the programmed BURST_DELAY (long_gap). n_long
    // counts the boundaries.
    short_gap = min_of(per_c);
    long_gap  = max_of(per_c);
    n_long    = 0;
    foreach (per_c[k]) if (per_c[k] > (short_gap + long_gap) / 2) n_long++;

    // "overhead" is the fixed number of extra sync_clk cycles the boundary gap
    // carries ON TOP OF period + programmed delay. By definition of the two gaps:
    //
    //     long_gap  = PWM_PERIOD + BURST_DELAY + overhead
    //     short_gap = PWM_PERIOD
    //  => overhead  = long_gap - short_gap - BURST_DELAY
    //
    // It is NOT part of the programmed delay: it is the cost of the RTL entering
    // and leaving the burst-delay state at each boundary (loading burst_delay_cnt,
    // reloading n_periods_cnt, the FSM stepping across the boundary). Here it
    // measures a flat 1 sync_clk cycle - so a boundary gap of 1000+delay+1. The
    // per-point check below only bounds it (<=16) as a sanity limit; the real
    // proof is in the caller, which sweeps BURST_DELAY and asserts this overhead
    // stays CONSTANT - a fixed offset across every delay means the delay is
    // honoured additively rather than scaled somewhere.
    overhead  = long_gap - short_gap - burst_delay;

    `INFO(("  BURST_DELAY=%0d gaps=%s", burst_delay, fmt_array(per_c)),
          ADI_VERBOSITY_LOW);

    // The high time must be unaffected by the burst machinery - the delays
    // shift when drctl toggles, never the pulse shape.
    if (!all_equal(high_c, PWM_WIDTH)) begin
      `ERROR(("  BURST_DELAY=%0d disturbed the high time: %s (expected %0d)",
              burst_delay, fmt_array(high_c), PWM_WIDTH));
      test_passed = 0;
    end

    if (short_gap != PWM_PERIOD) begin
      `ERROR(("  BURST_DELAY=%0d: intra-burst gap=%0d, expected %0d",
              burst_delay, short_gap, PWM_PERIOD));
      test_passed = 0;
    end else if (n_long != 3) begin
      `ERROR(("  BURST_DELAY=%0d: expected 3 burst boundaries in %0d gaps, found %0d",
              burst_delay, n_gaps, n_long));
      test_passed = 0;
    end else if (overhead > 16) begin
      `ERROR(("  BURST_DELAY=%0d: boundary gap=%0d, expected ~%0d (overhead %0d exceeds 16 sync_clk cycles)",
              burst_delay, long_gap, PWM_PERIOD + burst_delay, overhead));
      test_passed = 0;
    end else begin
      `INFO(("  BURST_DELAY=%0d -> %0d short (%0d) / %0d long (%0d), overhead %0d sync_clk cycles - PASSED",
             burst_delay, n_gaps - n_long, short_gap, n_long, long_gap, overhead),
            ADI_VERBOSITY_NONE);
    end

    // Settle at a burst boundary so the last group shown is a whole burst, and
    // the caller's next stop_pwm() does not cut a burst mid-way (which leaves a
    // lone triangle). The burst-alignment of the measurement's closing edge is
    // not fixed - the window can end on either triangle of a burst - so advance
    // triangle by triangle and stop once drctl stays low longer than the
    // intra-burst low gap (PWM_PERIOD-PWM_WIDTH). That longer low is a burst
    // boundary, so the burst that just fell is complete. Cosmetic only: no check
    // reads this, but it keeps truncated/lone triangles out of the waveform.
    forever begin
      wait_drctl_level(1'b0, 2 * PWM_PERIOD, settle_cyc);                 // current triangle's high phase ends
      wait_drctl_level(1'b1, (PWM_PERIOD - PWM_WIDTH) + 16, settle_cyc);  // next rise within an intra-burst low?
      if (settle_cyc >= (PWM_PERIOD - PWM_WIDTH) + 16) break;             // timed out -> low is a burst boundary
    end
  endtask

  // Measure one duty cycle and check both numbers exactly. The RTL loads
  // period-1 and counts to 1, so the period is exactly P sync_clk cycles and the
  // high time exactly W sync_clk cycles - there is no tolerance to allow here.
  task automatic check_pwm(
    input int unsigned p,
    input int unsigned w,
    input int unsigned n_periods,
    input int unsigned exp_high,
    input int unsigned exp_period
  );
    int unsigned high_c[];
    int unsigned per_c[];

    program_pwm(p, w);
    measure_drctl_waveform(n_periods, 200, high_c, per_c);

    if (all_equal(high_c, exp_high) && all_equal(per_c, exp_period)) begin
      `INFO(("  P=%0d W=%0d -> high=%0d period=%0d - PASSED", p, w, exp_high, exp_period),
            ADI_VERBOSITY_NONE);
    end else begin
      `ERROR(("  P=%0d W=%0d: expected high=%0d period=%0d, measured high=%s period=%s",
              p, w, exp_high, exp_period, fmt_array(high_c), fmt_array(per_c)));
      test_passed = 0;
    end
  endtask

  // --------------------------
  // trig_out pulse measurement
  // --------------------------
  // Records the sync_clk cycle offsets of trig_out rising edges relative to the
  // first edge seen. Both the interval-start and interval-stop sources OR into
  // the same output pin, so consecutive edges within one monitor window are the
  // start pulse followed by the stop pulse.
  task automatic measure_trig_pulses(
    input  int unsigned n_pulses,
    input  int unsigned timeout_us,
    output int unsigned offsets[],
    output int unsigned got
  );
    bit          prev;
    int unsigned cyc;
    int unsigned timeout_cycles;

    offsets        = new[n_pulses];
    got            = 0;
    cyc            = 0;
    timeout_cycles = timeout_us * CYCLES_PER_US;
    prev           = trig_out_tp;

    while (got < n_pulses && timeout_cycles > 0) begin
      @(posedge sync_clk_tp);
      timeout_cycles--;
      cyc++;
      if (trig_out_tp && !prev) begin
        offsets[got] = cyc;
        got++;
      end
      prev = trig_out_tp;
    end
  endtask

  // Count trig_out rising edges over a fixed observation window.
  task automatic count_trig_pulses(
    input  int unsigned window_cyc,
    output int unsigned count
  );
    bit prev;
    count = 0;
    prev  = trig_out_tp;
    for (int unsigned k = 0; k < window_cyc; k++) begin
      @(posedge sync_clk_tp);
      if (trig_out_tp && !prev) count++;
      prev = trig_out_tp;
    end
  endtask

  // --------------------------
  // Main test sequence
  // --------------------------
  initial begin
    setLoggerVerbosity(ADI_VERBOSITY_LOW);

    ext_sync_tp    = 1'b0;
    ram_swp_ovr_tp = 1'b0;

    base_env = new(
      .name("Base Environment"),
      .sys_clk_vip_if(`TH.`SYS_CLK.inst.IF),
      .dma_clk_vip_if(`TH.`DMA_CLK.inst.IF),
      .ddr_clk_vip_if(`TH.`DDR_CLK.inst.IF),
      .sys_rst_vip_if(`TH.`SYS_RST.inst.IF),
      .irq_base_address(0),
      .irq_vip_if(null));

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

    // The default 1 ms watchdog is tight for this suite: the interval-monitor
    // tests observe multi-thousand sync_clk-cycle windows. Extended via the watchdog's
    // public API rather than by editing the shared environment.
    base_env.simulation_watchdog.update_timer(32'd3_000_000);
    base_env.simulation_watchdog.reset();

    `INFO(("==== AD9910 DRG Mode Testbench (PWM ramp controller) ===="), ADI_VERBOSITY_NONE);

    // ----------------------------------------
    // TC1: Register sanity
    // ----------------------------------------
    // Every DRG register is written with a distinct pattern and read back. The
    // register map shifted from 0x23 upward in the PWM rework, so a stale
    // address lands on a real-but-wrong register and produces no bus error -
    // only a readback mismatch catches it.
    current_test = 1;
    `INFO(("TC1: Register sanity"), ADI_VERBOSITY_NONE);

    axi_read(reg_addr(REG_VERSION), read_data);
    `INFO(("  VERSION: 0x%08x", read_data), ADI_VERBOSITY_LOW);
    axi_read(reg_addr(REG_ID), read_data);
    `INFO(("  ID: 0x%08x", read_data), ADI_VERBOSITY_LOW);
    axi_read(reg_addr(REG_DEVICE_INFO), read_data);
    `INFO(("  DEVICE_INFO: 0x%08x", read_data), ADI_VERBOSITY_LOW);

    axi_write(reg_addr(REG_SCRATCH), 32'hDEADBEEF);
    axi_read_v(reg_addr(REG_SCRATCH), 32'hDEADBEEF);

    axi_write(reg_addr(REG_DRCTL_PERIOD),   32'h0000_1234);
    axi_write(reg_addr(REG_DRCTL_WIDTH),    32'h0000_5678);
    axi_write(reg_addr(REG_BST_DELAY),      32'h0000_9abc);
    axi_write(reg_addr(REG_RAMP_BURSTS),    32'h0000_def0);
    axi_write(reg_addr(REG_BURST_DELAY),    32'h0001_1111);
    axi_write(reg_addr(REG_MON_MAX_PERIOD), 32'h0002_2222);
    axi_write(reg_addr(REG_IRQ_START),      32'h0003_3333);
    axi_write(reg_addr(REG_IRQ_STOP),       32'h0004_4444);
    axi_write(reg_addr(REG_TRIG_START),     32'h0005_5555);
    axi_write(reg_addr(REG_TRIG_STOP),      32'h0006_6666);

    axi_read_v(reg_addr(REG_DRCTL_PERIOD),   32'h0000_1234);
    axi_read_v(reg_addr(REG_DRCTL_WIDTH),    32'h0000_5678);
    axi_read_v(reg_addr(REG_BST_DELAY),      32'h0000_9abc);
    axi_read_v(reg_addr(REG_RAMP_BURSTS),    32'h0000_def0);  // 20-bit field
    axi_read_v(reg_addr(REG_BURST_DELAY),    32'h0001_1111);
    axi_read_v(reg_addr(REG_MON_MAX_PERIOD), 32'h0002_2222);
    axi_read_v(reg_addr(REG_IRQ_START),      32'h0003_3333);
    axi_read_v(reg_addr(REG_IRQ_STOP),       32'h0004_4444);
    axi_read_v(reg_addr(REG_TRIG_START),     32'h0005_5555);
    axi_read_v(reg_addr(REG_TRIG_STOP),      32'h0006_6666);
    `INFO(("  Register map readback - PASSED"), ADI_VERBOSITY_NONE);

    // Clear back to a known state before the ramp tests.
    axi_write(reg_addr(REG_DRCTL_PERIOD),   32'd0);
    axi_write(reg_addr(REG_DRCTL_WIDTH),    32'd0);
    axi_write(reg_addr(REG_BST_DELAY),      32'd0);
    axi_write(reg_addr(REG_RAMP_BURSTS),    32'd0);
    axi_write(reg_addr(REG_BURST_DELAY),    32'd0);
    axi_write(reg_addr(REG_MON_MAX_PERIOD), 32'd0);
    axi_write(reg_addr(REG_IRQ_START),      32'd0);
    axi_write(reg_addr(REG_IRQ_STOP),       32'd0);
    axi_write(reg_addr(REG_TRIG_START),     32'd0);
    axi_write(reg_addr(REG_TRIG_STOP),      32'd0);

    // ----------------------------------------
    // TC2: Reset release and clock monitor
    // ----------------------------------------
    current_test = 2;
    `INFO(("TC2: Reset release and clock monitor"), ADI_VERBOSITY_NONE);

    axi_write(reg_addr(REG_RESET_CTRL), 32'h0);
    #10us;

    // The clock monitors need a full measurement window before they report
    // anything: up_clock_mon gates on a free-running 16-bit up_clk counter, so
    // the first capture lands 65536 up_clk cycles (~655 us at 100 MHz) after
    // reset. That is longer than most of this suite, so the counts are only
    // logged here and checked at the end in TC16.
    begin
      bit [31:0] cnt_a;
      axi_read(reg_addr(REG_SYNC_CLK_CNT), cnt_a);
      `INFO(("  SYNC_CLK_CNT this early: 0x%08x (window not yet elapsed)", cnt_a),
            ADI_VERBOSITY_LOW);
      `INFO(("  Reset released - PASSED"), ADI_VERBOSITY_NONE);
    end

    // Run the ramp model for the whole suite, with the completion checker off.
    // Only TC12 and TC15 read anything out of it, but leaving it running
    // makes drg_counter track drctl everywhere, so the waveform shows the ramp
    // each duty-cycle configuration actually produces instead of a flat line.
    // Dwell is the baseline, because it is the shape an AD9910 comes out of reset
    // in: nothing is moving yet either, since no duty cycle has been programmed,
    // so the counter sits at the lower limit the way the part itself would. Only
    // TC4 and TC12's retrace check switch to sawtooth, each reverting when
    // it is done.
    // Safe because drover reaches an output only through a mask that no test
    // opens: TRIG_OUT_CTRL selects the interval bits and IRQ_MASK is set one
    // bit at a time, never IRQ_DROVER except where TC15 wants it. The
    // checker stays off so the deliberately short intervals in TC5, TC6 and
    // TC14 do not report truncations - those are the point of those tests.
    enable_drg_model(1, 0);

    // ----------------------------------------
    // TC3: Simple mode drctl control
    // ----------------------------------------
    // With toggle_en cleared the PWM machinery is bypassed and drctl follows
    // DRCTL_INIT straight through the CDC.
    current_test = 3;
    `INFO(("TC3: Simple mode (toggle_en=0)"), ADI_VERBOSITY_NONE);

    axi_write(reg_addr(REG_DRG_CTRL), 32'h1 << DRG_DRCTL_INIT);
    #CFG_SETTLE_NS;
    if (drctl_tp === 1'b1) begin
      `INFO(("  DRCTL_INIT=1 -> drctl high - PASSED"), ADI_VERBOSITY_NONE);
    end else begin
      `ERROR(("  DRCTL_INIT=1 but drctl=%b", drctl_tp));
      test_passed = 0;
    end

    axi_write(reg_addr(REG_DRG_CTRL), 32'h0);
    #CFG_SETTLE_NS;
    if (drctl_tp === 1'b0) begin
      `INFO(("  DRCTL_INIT=0 -> drctl low - PASSED"), ADI_VERBOSITY_NONE);
    end else begin
      `ERROR(("  DRCTL_INIT=0 but drctl=%b", drctl_tp));
      test_passed = 0;
    end

    // ----------------------------------------
    // TC4: PWM basic operation
    // ----------------------------------------
    current_test = 4;
    `INFO(("TC4: PWM basic (P=%0d W=%0d)", PWM_PERIOD, PWM_WIDTH), ADI_VERBOSITY_NONE);

    // The first test with a real duty cycle to ramp against, so run it in
    // sawtooth: the ramp keeps moving for as long as drctl holds a level instead
    // of reaching the limit and parking there for the rest of the interval, which
    // is what makes the trace read as a repeating chirp. Reverted below - dwell
    // is the part's reset configuration and stays the suite's baseline, so
    // sawtooth is only in force where it is being exercised.
    enable_drg_model(1, 0, DRG_SAWTOOTH);

    check_pwm(PWM_PERIOD, PWM_WIDTH, 6, PWM_WIDTH, PWM_PERIOD);

    enable_drg_model(1, 0, DRG_DWELL);

    // ----------------------------------------
    // TC5: Duty-cycle sweep
    // ----------------------------------------
    current_test = 5;
    `INFO(("TC5: Duty-cycle sweep"), ADI_VERBOSITY_NONE);

    // Duty sweep at the base period: from a 1-cycle sliver up to nearly the whole
    // period, so drctl is seen widening across the full 0..100% range at one
    // fixed, readable period. W=1 is the active_drctl_width_gt_one RTL boundary
    // and stays a single sync_clk cycle regardless of the period; the rest step
    // the high fraction from ~5% to ~99%.
    begin
      automatic int unsigned duty_w[] = '{1, 50, 200, 400, 500, 600, 800, 950, 990};
      foreach (duty_w[k])
        check_pwm(PWM_PERIOD, duty_w[k], 4, duty_w[k], PWM_PERIOD);
    end

    // Period sweep at 50% duty: from a 100-cycle period up to 4000, so the same
    // duty is stretched across a wide range of periods. The two shortest (100,
    // 250) are below DRG_RAMP_CYCLES, so the modelled ramp is truncated there -
    // deliberate, and the DUT duty check (high==W, period==P) is exact regardless.
    begin
      automatic int unsigned per_p[] = '{100, 250, 500, 1000, 2000, 4000};
      foreach (per_p[k])
        check_pwm(per_p[k], per_p[k] / 2, 4, per_p[k] / 2, per_p[k]);
    end

    // Reconfiguring live (without clearing toggle_en first) costs an extra
    // reset_overwrite per register write, but must still converge on the new
    // waveform.
    begin
      int unsigned high_c[];
      int unsigned per_c[];
      axi_write(reg_addr(REG_DRCTL_PERIOD), 32'd800);
      axi_write(reg_addr(REG_DRCTL_WIDTH),  32'd200);
      #CFG_SETTLE_NS;
      measure_drctl_waveform(4, 200, high_c, per_c);
      if (all_equal(high_c, 200) && all_equal(per_c, 800)) begin
        `INFO(("  Live reconfigure to P=800 W=200 converged - PASSED"), ADI_VERBOSITY_NONE);
      end else begin
        `ERROR(("  Live reconfigure: high=%s period=%s (expected 200 / 800)",
                fmt_array(high_c), fmt_array(per_c)));
        test_passed = 0;
      end
    end

    // ----------------------------------------
    // TC6: Width and period edge cases
    // ----------------------------------------
    // Each case selects a different RTL branch: active_drctl_width_nonzero,
    // active_drctl_width_gt_one, and active_drctl_period_one.
    current_test = 6;
    `INFO(("TC6: Width and period edge cases"), ADI_VERBOSITY_NONE);

    // Each window spans three whole periods, so a duty cycle that had not been
    // suppressed would have toggled several times inside it.
    program_pwm(PWM_PERIOD, 0);
    check_drctl_static(1'b0, 3 * PWM_PERIOD, "W=0");

    program_pwm(PWM_PERIOD, PWM_PERIOD);
    check_drctl_static(1'b1, 3 * PWM_PERIOD, "W=P");

    program_pwm(PWM_PERIOD, PWM_PERIOD + PWM_PERIOD / 2);
    check_drctl_static(1'b1, 3 * PWM_PERIOD, "W>P");

    // P=1 is special-cased: drctl toggles every sync_clk cycle and W is
    // ignored, so the observable waveform is 1 sync_clk cycle high, 1 sync_clk cycle low.
    begin
      int unsigned high_c[];
      int unsigned per_c[];
      program_pwm(1, 0);
      measure_drctl_waveform(6, 200, high_c, per_c);
      if (all_equal(high_c, 1) && all_equal(per_c, 2)) begin
        `INFO(("  P=1 -> drctl toggles every sync_clk cycle - PASSED"), ADI_VERBOSITY_NONE);
      end else begin
        `ERROR(("  P=1: high=%s period=%s (expected 1 / 2)",
                fmt_array(high_c), fmt_array(per_c)));
        test_passed = 0;
      end
    end

    stop_pwm();

    // ----------------------------------------
    // TC7: Start delay (DELAY_BST_RAMP_DELAY)
    // ----------------------------------------
    // The absolute delay from the register write to the first edge includes a
    // fixed CDC and reset_overwrite overhead, so the check compares the
    // difference between two programmed values - the overhead cancels.
    current_test = 7;
    `INFO(("TC7: Start delay"), ADI_VERBOSITY_NONE);

    begin
      int unsigned t_short;
      int unsigned t_long;
      int unsigned delta;
      // Both delays are of the same order as the duty cycles that follow them
      // (0.5 and 2.5 periods), so the gap before the first edge can be read off
      // the trace by comparing it against them.
      localparam int DLY_SHORT = 500;
      localparam int DLY_LONG  = 2500;

      stop_pwm();
      measure_start_delay(DLY_SHORT, t_short);
      stop_pwm();
      measure_start_delay(DLY_LONG, t_long);

      delta = t_long - t_short;
      `INFO(("  first edge at %0d sync_clk cycles (delay=%0d) and %0d sync_clk cycles (delay=%0d), delta=%0d",
             t_short, DLY_SHORT, t_long, DLY_LONG, delta), ADI_VERBOSITY_LOW);

      // Unlike the drctl period and width, which are measured edge-to-edge
      // entirely within sync_clk and are therefore exact, this interval is
      // timed from an AXI write and so includes however long the write sat at
      // the up_xfer_cntrl crossing. Each of the two measurements is quantized
      // independently into that 64-up_clk window, so their difference can be
      // off by a full window either way - CDC_XFER_JITTER, not the handful of
      // sync_clk cycles a synchroniser would cost. The check is still decisive: the
      // programmed step is 2000 sync_clk cycles, so a dropped delay reads about -500 and
      // a doubled one about 2500.
      if (delta >= (DLY_LONG - DLY_SHORT - CDC_XFER_JITTER) &&
          delta <= (DLY_LONG - DLY_SHORT + CDC_XFER_JITTER)) begin
        `INFO(("  Start delay scales correctly (delta=%0d, expected %0d +/-%0d) - PASSED",
               delta, DLY_LONG - DLY_SHORT, CDC_XFER_JITTER), ADI_VERBOSITY_NONE);
      end else begin
        `ERROR(("  Start delay delta=%0d, expected %0d +/-%0d",
                delta, DLY_LONG - DLY_SHORT, CDC_XFER_JITTER));
        test_passed = 0;
      end

      stop_pwm();
      axi_write(reg_addr(REG_BST_DELAY), 32'd0);
    end

    // ----------------------------------------
    // TC8: Burst grouping and burst delay
    // ----------------------------------------
    current_test = 8;
    `INFO(("TC8: Burst grouping"), ADI_VERBOSITY_NONE);

    begin
      localparam int BURSTS = 2;
      // Increasing, and spanning half a period to four periods: small enough that
      // the boundary could be mistaken for a wide period, up to unmistakable. The
      // smallest is deliberately below one period so the classification is not
      // resting on the boundary gap being an obvious outlier.
      automatic int unsigned burst_delays[] = '{500, 1000, 2000, 4000};
      int unsigned overheads[];
      bit          overhead_constant;

      overheads = new[burst_delays.size()];

      stop_pwm();
      axi_write(reg_addr(REG_RAMP_BURSTS), BURSTS);

      foreach (burst_delays[k]) begin
        check_burst_delay(BURSTS, burst_delays[k], overheads[k]);
      end

      // Entering and leaving the burst-delay state costs a fixed number of
      // sync_clk cycles on top of the programmed value. Sweeping is what makes that
      // testable: a constant offset across every delay says the register is
      // honoured additively, whereas a cost that grew with the delay would mean
      // it is being scaled somewhere. A single measurement cannot tell the two
      // apart - it just reports "close enough".
      overhead_constant = 1;
      foreach (overheads[k]) if (overheads[k] != overheads[0]) overhead_constant = 0;

      if (overhead_constant) begin
        `INFO(("  Boundary overhead constant at %0d sync_clk cycles across delays %s - PASSED",
               overheads[0], fmt_array(burst_delays)), ADI_VERBOSITY_NONE);
      end else begin
        `ERROR(("  Boundary overhead varies with the programmed delay: delays=%s overheads=%s",
                fmt_array(burst_delays), fmt_array(overheads)));
        test_passed = 0;
      end

      stop_pwm();
      axi_write(reg_addr(REG_RAMP_BURSTS), 32'd0);
      axi_write(reg_addr(REG_BURST_DELAY), 32'd0);
    end

    // ----------------------------------------
    // TC9: Stop modes (RAMP_CFG)
    // ----------------------------------------
    current_test = 9;
    `INFO(("TC9: Stop modes"), ADI_VERBOSITY_NONE);

    // Period stop: exactly one duty cycle, then drctl parks low.
    begin
      int unsigned cyc;
      stop_pwm();
      axi_write(reg_addr(REG_RAMP_CFG), RAMP_CFG_PERIOD_STOP);
      program_pwm(PWM_PERIOD, PWM_WIDTH);
      // Let the one permitted period finish before checking that drctl parks.
      // program_pwm's settle is a fixed 4 us, which is only one period long at
      // this configuration and can be consumed entirely by the config sitting
      // at the CDC, so the period is not necessarily over when it returns.
      repeat (PWM_PERIOD + CDC_XFER_JITTER) @(posedge sync_clk_tp);
      check_drctl_static(1'b0, 2 * PWM_PERIOD, "RAMP_CFG=period_stop");
      // Returning to free-run clears stop_event and the ramp resumes.
      axi_write(reg_addr(REG_RAMP_CFG), RAMP_CFG_FREE_RUN);
      wait_drctl_level(1'b1, 20000, cyc);
      if (cyc < 20000) begin
        `INFO(("  Free-run restart after period stop (%0d sync_clk cycles) - PASSED", cyc),
              ADI_VERBOSITY_NONE);
      end else begin
        `ERROR(("  Ramp did not restart after clearing RAMP_CFG"));
        test_passed = 0;
      end
    end

    // Burst stop: RAMP_BURSTS periods, then park.
    begin
      int unsigned high_c[];
      int unsigned per_c[];
      localparam int STOP_BURSTS = 3;

      stop_pwm();
      axi_write(reg_addr(REG_RAMP_BURSTS), STOP_BURSTS);
      axi_write(reg_addr(REG_RAMP_CFG), RAMP_CFG_BURST_STOP);
      program_pwm(PWM_PERIOD, PWM_WIDTH);
      // As above, but a whole burst is allowed to run before the park.
      repeat (STOP_BURSTS * PWM_PERIOD + CDC_XFER_JITTER) @(posedge sync_clk_tp);
      check_drctl_static(1'b0, 2 * PWM_PERIOD, "RAMP_CFG=burst_stop");

      axi_write(reg_addr(REG_RAMP_CFG), RAMP_CFG_FREE_RUN);
      measure_drctl_waveform(4, 200, high_c, per_c);
      if (all_equal(per_c, PWM_PERIOD)) begin
        `INFO(("  Free-run restart after burst stop - PASSED"), ADI_VERBOSITY_NONE);
      end else begin
        `ERROR(("  After burst-stop restart: period=%s (expected %0d)",
                fmt_array(per_c), PWM_PERIOD));
        test_passed = 0;
      end

      stop_pwm();
      axi_write(reg_addr(REG_RAMP_BURSTS), 32'd0);
      axi_write(reg_addr(REG_RAMP_CFG), RAMP_CFG_FREE_RUN);
    end

    // ----------------------------------------
    // TC10: DRHOLD passthrough
    // ----------------------------------------
    // drhold is a register -> CDC -> pin passthrough in the current RTL; it
    // gates nothing inside the DUT. The black-box property is that the pin
    // tracks the register.
    current_test = 10;
    `INFO(("TC10: DRHOLD passthrough"), ADI_VERBOSITY_NONE);

    axi_write(reg_addr(REG_DRG_CTRL), 32'h1 << DRG_DRHOLD);
    #CFG_SETTLE_NS;
    if (drhold_tp === 1'b1) begin
      `INFO(("  DRHOLD=1 -> drhold pin high - PASSED"), ADI_VERBOSITY_NONE);
    end else begin
      `ERROR(("  DRHOLD=1 but drhold pin=%b", drhold_tp));
      test_passed = 0;
    end

    axi_write(reg_addr(REG_DRG_CTRL), 32'h0);
    #CFG_SETTLE_NS;
    if (drhold_tp === 1'b0) begin
      `INFO(("  DRHOLD=0 -> drhold pin low - PASSED"), ADI_VERBOSITY_NONE);
    end else begin
      `ERROR(("  DRHOLD=0 but drhold pin=%b", drhold_tp));
      test_passed = 0;
    end

    // ----------------------------------------
    // TC11: Profile output
    // ----------------------------------------
    current_test = 11;
    `INFO(("TC11: Profile output"), ADI_VERBOSITY_NONE);

    for (int p = 0; p < 8; p++) begin
      axi_write(reg_addr(REG_PROFILE), p);
      #CFG_SETTLE_NS;
      if (profile_tp !== p[2:0]) begin
        `ERROR(("  PROFILE=%0d but profile pin=%0d", p, profile_tp));
        test_passed = 0;
      end
    end
    axi_write(reg_addr(REG_PROFILE), 32'd0);
    `INFO(("  All 8 profile values - PASSED"), ADI_VERBOSITY_NONE);

    // ----------------------------------------
    // TC12: Ramp model and programming checker
    // ----------------------------------------
    // A full limit-to-limit ramp takes DRG_RAMP_CYCLES. When both the high and
    // low intervals are longer than that, every ramp completes and drover
    // pulses twice per duty cycle. When an interval is shorter, the AD9910
    // never reaches its limit - the RTL is behaving correctly, the register
    // values are simply wrong. This is the failure mode behind a chirp whose
    // ramps do not match the configured sweep.
    current_test = 12;
    `INFO(("TC12: Ramp model and programming checker"), ADI_VERBOSITY_NONE);

    begin
      int unsigned rises_before;
      int unsigned rises_after;
      // Symmetric duty: both intervals are 500 sync_clk cycles, comfortably longer than
      // the 200 sync_clk cycles a full ramp needs, so every ramp reaches its limit and parks.
      localparam int GOOD_P = PWM_PERIOD;
      localparam int GOOD_W = PWM_PERIOD / 2;

      stop_pwm();
      // Dwell, not the suite's sawtooth: this test is about whether the
      // programmed interval is long enough for a ramp, which only has an
      // answer when the ramp has an endpoint to fail to reach.
      enable_drg_model(1, 1, DRG_DWELL);
      program_pwm(GOOD_P, GOOD_W);

      rises_before = drover_rise_count;
      repeat (4 * GOOD_P) @(posedge sync_clk_tp);
      rises_after = drover_rise_count;

      `INFO(("  %0d drover rising edges over 4 periods (expect ~8)",
             rises_after - rises_before), ADI_VERBOSITY_LOW);

      if (ramp_truncation_count != 0) begin
        `ERROR(("  %0d ramp truncations with W=%0d, P-W=%0d (both exceed %0d sync_clk cycles)",
                ramp_truncation_count, GOOD_W, GOOD_P - GOOD_W, DRG_RAMP_CYCLES));
        test_passed = 0;
      end else if ((rises_after - rises_before) < 6) begin
        `ERROR(("  Only %0d drover edges in 4 periods, expected ~8",
                rises_after - rises_before));
        test_passed = 0;
      end else begin
        `INFO(("  Ramps complete within both intervals - PASSED"), ADI_VERBOSITY_NONE);
      end

      // Disarm before anything stops the PWM. Clearing toggle_en drops drctl
      // wherever the ramp happens to be, so it truncates one by definition -
      // that is a stop, not the programming error the checker looks for. This
      // was previously masked by the ramp being short enough to always finish
      // inside the AXI write that stopped it.
      check_ramp_completion = 0;
    end

    // Now deliberately program a width too short for the ramp and confirm the
    // checker catches it. Errors are expected here, so the checker is read
    // directly rather than being allowed to fail the run.
    begin
      int unsigned truncations;
      localparam int BAD_P = PWM_PERIOD;
      localparam int BAD_W = 150;    // 150 < DRG_RAMP_CYCLES, so the up-ramp cannot finish

      stop_pwm();
      // Still dwelling; counted silently here, without the ERROR spam.
      enable_drg_model(1, 0, DRG_DWELL);
      program_pwm(BAD_P, BAD_W);

      // Re-arm counting without the logger noise by sampling the counter
      // ourselves over a fixed window.
      begin
        bit          drctl_prev_local;
        int unsigned bad_edges;
        bad_edges        = 0;
        drctl_prev_local = drctl_tp;
        for (int unsigned k = 0; k < 4 * BAD_P; k++) begin
          @(posedge sync_clk_tp);
          if (!drctl_tp && drctl_prev_local && (drg_counter != DRG_UPPER_LIMIT))
            bad_edges++;
          drctl_prev_local = drctl_tp;
        end
        truncations = bad_edges;
      end

      if (truncations > 0) begin
        `INFO(("  W=%0d (< %0d sync_clk ramp cycles) truncated %0d up-ramps, detected - PASSED",
               BAD_W, DRG_RAMP_CYCLES, truncations), ADI_VERBOSITY_NONE);
      end else begin
        `ERROR(("  W=%0d should truncate the ramp but no truncation was detected", BAD_W));
        test_passed = 0;
      end

      stop_pwm();
    end

    // Sawtooth retrace. With the up-ramp reloading the lower limit instead of
    // parking on the upper one, a single drctl high interval holds several
    // complete ramps rather than one ramp followed by a plateau. Nothing else in
    // the suite depends on this, so a regression to dwell would otherwise be
    // invisible: every check would still pass and only the waveform would change.
    begin
      int unsigned retraces_before;
      int unsigned retraces_after;
      // The base duty cycle, so the blades come out whole here too - a width that
      // is not a multiple of DRG_RAMP_CYCLES ends mid-blade and the last one
      // reverses into a descent.
      localparam int SAW_P = PWM_PERIOD;
      localparam int SAW_W = PWM_WIDTH;
      // A blade is DRG_RAMP_CYCLES long, so the 400 sync_clk-cycle high interval holds
      // two. Only the upward direction retraces, so that is two per period, four
      // across the window - the threshold leaves room for the window opening
      // mid-interval.
      localparam int MIN_RETRACES = 3;

      enable_drg_model(1, 0, DRG_SAWTOOTH);
      program_pwm(SAW_P, SAW_W);

      retraces_before = drg_retrace_count;
      repeat (2 * SAW_P) @(posedge sync_clk_tp);
      retraces_after = drg_retrace_count;

      if ((retraces_after - retraces_before) >= MIN_RETRACES) begin
        `INFO(("  Sawtooth retraced %0d times over 2 periods (expect 4) - PASSED",
               retraces_after - retraces_before), ADI_VERBOSITY_NONE);
      end else begin
        `ERROR(("  Sawtooth retraced %0d times over 2 periods, expected at least %0d",
                retraces_after - retraces_before, MIN_RETRACES));
        test_passed = 0;
      end

      // No-dwell low stays clear, so parking drctl has to bring the ramp to rest
      // at the lower limit by itself. Without that the counter would keep
      // retracing downwards for the rest of the simulation, asserting ramp
      // activity everywhere the DUT is idle.
      stop_pwm();
      retraces_before = drg_retrace_count;
      repeat (DRG_RAMP_CYCLES + 100) @(posedge sync_clk_tp);
      retraces_after = drg_retrace_count;

      if ((drg_counter == DRG_LOWER_LIMIT) && (retraces_after == retraces_before)) begin
        `INFO(("  Ramp came to rest at the lower limit with drctl parked - PASSED"),
              ADI_VERBOSITY_NONE);
      end else begin
        `ERROR(("  drctl parked low but the ramp is at %0d after %0d further retraces",
                drg_counter, retraces_after - retraces_before));
        test_passed = 0;
      end

      // Back to the baseline for the remaining tests, as at the end of TC4.
      enable_drg_model(1, 0, DRG_DWELL);
    end

    // ----------------------------------------
    // TC13: trig_out interval timing
    // ----------------------------------------
    // Max-period mode is used because it is the one monitor source whose
    // reference counter runs freely: in period and burst-delay modes,
    // end_period_d also resets ref_cnt (axi_ad9910.v:385-390). TC14 covers
    // the mode selection itself.
    //
    // Contract from the IP docs: the counter loads MONITOR_MAX_PERIOD and counts
    // down; a pulse is emitted when it equals the programmed match value; both
    // start and stop OR into trig_out. Pulse spacing is therefore exactly
    // START_MATCH - STOP_MATCH, independent of the fixed 3 sync_clk-cycle output latency.
    current_test = 13;
    `INFO(("TC13: trig_out interval timing (max-period mode)"), ADI_VERBOSITY_NONE);

    begin
      int unsigned offs[];
      int unsigned got;
      int unsigned spacing;
      automatic int start_match[3] = '{900, 800, 500};
      automatic int stop_match[3]  = '{800, 400, 100};
      localparam int MON_MAX = 1000;
      // In max-period mode the counter arms once per start_event. A start
      // delay pushes that event past program_pwm's settle window so the
      // measurement is already listening when the single window opens.
      localparam int ARM_DELAY = 2000;

      stop_pwm();
      axi_write(reg_addr(REG_BST_DELAY), ARM_DELAY);
      axi_write(reg_addr(REG_MON_MAX_PERIOD), MON_MAX);
      axi_write(reg_addr(REG_TRIG_OUT_CTRL),
                (32'h3 << (TRIG_MASK_SHIFT + IRQ_INTERVAL_STOP)) | MON_CFG_MAX_PERIOD);

      for (int k = 0; k < 3; k++) begin
        axi_write(reg_addr(REG_TRIG_START), start_match[k]);
        axi_write(reg_addr(REG_TRIG_STOP), stop_match[k]);
        // A start event (re-)arms the counter; restarting the PWM produces one.
        program_pwm(2000, 1000);

        measure_trig_pulses(2, 60, offs, got);
        if (got < 2) begin
          `ERROR(("  start=%0d stop=%0d: saw %0d trig_out pulses, expected 2",
                  start_match[k], stop_match[k], got));
          test_passed = 0;
        end else begin
          spacing = offs[1] - offs[0];
          if (spacing == (start_match[k] - stop_match[k])) begin
            `INFO(("  start=%0d stop=%0d -> spacing %0d - PASSED",
                   start_match[k], stop_match[k], spacing), ADI_VERBOSITY_NONE);
          end else begin
            `ERROR(("  start=%0d stop=%0d -> spacing %0d, expected %0d",
                    start_match[k], stop_match[k], spacing,
                    start_match[k] - stop_match[k]));
            test_passed = 0;
          end
        end
        stop_pwm();
      end

      // A match value of zero disables that pulse.
      begin
        int unsigned n_pulses;
        axi_write(reg_addr(REG_TRIG_START), 32'd0);
        axi_write(reg_addr(REG_TRIG_STOP), 32'd0);
        program_pwm(2000, 1000);
        count_trig_pulses(4000, n_pulses);
        if (n_pulses == 0) begin
          `INFO(("  match=0 disables both pulses - PASSED"), ADI_VERBOSITY_NONE);
        end else begin
          `ERROR(("  match=0 but %0d trig_out pulses observed", n_pulses));
          test_passed = 0;
        end
        stop_pwm();
      end

      axi_write(reg_addr(REG_TRIG_OUT_CTRL), 32'd0);
      axi_write(reg_addr(REG_MON_MAX_PERIOD), 32'd0);
      axi_write(reg_addr(REG_BST_DELAY), 32'd0);
    end

    // ----------------------------------------
    // TC14: Interval monitor source selection
    // ----------------------------------------
    // TRIG_CONFIG picks which event reloads the reference counter:
    //   0 = every duty-cycle period, 1 = every burst delay, 2 = once per start.
    // The observable consequence is the trig_out pulse rate over a fixed
    // window, so period mode should out-pulse burst mode by the burst length.
    current_test = 14;
    `INFO(("TC14: Interval monitor source selection"), ADI_VERBOSITY_NONE);

    begin
      int unsigned n_period_mode;
      int unsigned n_burst_mode;
      int unsigned n_max_mode;
      localparam int MON_MAX  = 60;    // shorter than the PWM period
      // This test compares pulse *rates*, so the observation window has to hold
      // a good number of duty cycles: the period is kept below the suite's base
      // value and the window widened to match, rather than the other way round.
      localparam int PWM_P    = 500;
      localparam int OBS_CYC  = 20 * PWM_P;
      localparam int BURSTS   = 4;
      localparam int ARM_DELAY = 1500; // see TC13: pushes start_event past the settle

      stop_pwm();
      axi_write(reg_addr(REG_BST_DELAY), ARM_DELAY);
      axi_write(reg_addr(REG_MON_MAX_PERIOD), MON_MAX);
      axi_write(reg_addr(REG_TRIG_START), 32'd50);
      axi_write(reg_addr(REG_TRIG_STOP), 32'd0);      // start pulse only
      axi_write(reg_addr(REG_RAMP_BURSTS), BURSTS);
      axi_write(reg_addr(REG_BURST_DELAY), 2 * PWM_P);

      axi_write(reg_addr(REG_TRIG_OUT_CTRL),
                (32'h3 << (TRIG_MASK_SHIFT + IRQ_INTERVAL_STOP)) | MON_CFG_PERIOD);
      program_pwm(PWM_P, PWM_P / 2);
      count_trig_pulses(OBS_CYC, n_period_mode);
      stop_pwm();

      axi_write(reg_addr(REG_TRIG_OUT_CTRL),
                (32'h3 << (TRIG_MASK_SHIFT + IRQ_INTERVAL_STOP)) | MON_CFG_BURST_DLY);
      program_pwm(PWM_P, PWM_P / 2);
      count_trig_pulses(OBS_CYC, n_burst_mode);
      stop_pwm();

      axi_write(reg_addr(REG_TRIG_OUT_CTRL),
                (32'h3 << (TRIG_MASK_SHIFT + IRQ_INTERVAL_STOP)) | MON_CFG_MAX_PERIOD);
      program_pwm(PWM_P, PWM_P / 2);
      count_trig_pulses(OBS_CYC, n_max_mode);
      stop_pwm();

      `INFO(("  pulses over %0d sync_clk cycles: period=%0d burst=%0d max_period=%0d",
             OBS_CYC, n_period_mode, n_burst_mode, n_max_mode), ADI_VERBOSITY_NONE);

      // Max-period mode arms once per start event rather than per period, so
      // the pulse count must stay far below the number of duty cycles in the
      // window (OBS_CYC/PWM_P). It is not pinned to exactly one because
      // clearing toggle_en also raises reset_overwrite, which re-arms
      // wait_for_start and can yield a second start event.
      if (n_max_mode < 1 || n_max_mode > 3) begin
        `ERROR(("  max-period mode produced %0d pulses, expected 1-3 (window holds %0d periods)",
                n_max_mode, OBS_CYC / PWM_P));
        test_passed = 0;
      end

      // Period mode should fire once per duty cycle; burst mode once per burst.
      // If either reports zero, the reference counter is not counting: in these
      // two modes end_period_d also clears trig_ref_cnt and raises
      // stop_trig_ref_cnt (axi_ad9910.v:465-470), which prevents run_trig_ref_cnt
      // from latching (axi_ad9910.v:454-462), so the counter only ever holds
      // MONITOR_MAX_PERIOD or 0 and never reaches an intermediate match value.
      if (n_period_mode == 0) begin
        `ERROR(("  period mode produced no trig_out pulses - reference counter never reaches the match value (see axi_ad9910.v:454-470)"));
        test_passed = 0;
      end else if (n_burst_mode == 0) begin
        `ERROR(("  burst-delay mode produced no trig_out pulses - reference counter never reaches the match value (see axi_ad9910.v:454-470)"));
        test_passed = 0;
      end else if (n_period_mode <= n_burst_mode) begin
        `ERROR(("  period mode (%0d) should out-pulse burst mode (%0d)",
                n_period_mode, n_burst_mode));
        test_passed = 0;
      end else begin
        `INFO(("  Monitor source selection - PASSED"), ADI_VERBOSITY_NONE);
      end

      axi_write(reg_addr(REG_TRIG_OUT_CTRL), 32'd0);
      axi_write(reg_addr(REG_MON_MAX_PERIOD), 32'd0);
      axi_write(reg_addr(REG_TRIG_START), 32'd0);
      axi_write(reg_addr(REG_RAMP_BURSTS), 32'd0);
      axi_write(reg_addr(REG_BURST_DELAY), 32'd0);
    end

    // ----------------------------------------
    // TC15: IRQ mask, table and write-1-to-clear
    // ----------------------------------------
    current_test = 15;
    `INFO(("TC15: IRQ mask / table / W1C"), ADI_VERBOSITY_NONE);

    begin
      stop_pwm();
      axi_write(reg_addr(REG_IRQ_MASK), 32'd0);
      // The clear reaches the sync domain through the control CDC and
      // up_irq_clear stays asserted until that transfer completes, so give it
      // time to land before generating the event it must not swallow.
      axi_write(reg_addr(REG_IRQ_TABLE), 32'h3f);
      #CFG_SETTLE_NS;

      // ram_swp_ovr is a plain input, the simplest source to drive.
      ram_swp_ovr_tp = 1'b1;
      repeat (50) @(posedge sync_clk_tp);
      ram_swp_ovr_tp = 1'b0;
      #CFG_SETTLE_NS;

      if (ad9910_irq_tp === 1'b0) begin
        `INFO(("  IRQ_MASK=0 keeps irq low with an active source - PASSED"),
              ADI_VERBOSITY_NONE);
      end else begin
        `ERROR(("  IRQ_MASK=0 but irq=%b", ad9910_irq_tp));
        test_passed = 0;
      end

      axi_read(reg_addr(REG_IRQ_TABLE), read_data);
      if (read_data[IRQ_RAM_SWP_OVR]) begin
        `INFO(("  IRQ_TABLE latched ram_swp_ovr (0x%02x) - PASSED", read_data),
              ADI_VERBOSITY_NONE);
      end else begin
        `ERROR(("  IRQ_TABLE=0x%02x, ram_swp_ovr bit not latched", read_data));
        test_passed = 0;
      end

      // Unmasking an already-latched source must drive irq.
      axi_write(reg_addr(REG_IRQ_MASK), 32'h1 << IRQ_RAM_SWP_OVR);
      #CFG_SETTLE_NS;
      if (ad9910_irq_tp === 1'b1) begin
        `INFO(("  Unmasking a latched source asserts irq - PASSED"), ADI_VERBOSITY_NONE);
      end else begin
        `ERROR(("  Source latched and unmasked but irq=%b", ad9910_irq_tp));
        test_passed = 0;
      end

      // W1C clears the latch. The source is no longer asserting, so the bit
      // must stay clear - a still-active level source would immediately
      // re-latch.
      axi_write(reg_addr(REG_IRQ_TABLE), 32'h1 << IRQ_RAM_SWP_OVR);
      #CFG_SETTLE_NS;
      axi_read(reg_addr(REG_IRQ_TABLE), read_data);
      if (!read_data[IRQ_RAM_SWP_OVR] && ad9910_irq_tp === 1'b0) begin
        `INFO(("  W1C cleared the latch and deasserted irq - PASSED"), ADI_VERBOSITY_NONE);
      end else begin
        `ERROR(("  After W1C: IRQ_TABLE=0x%02x irq=%b", read_data, ad9910_irq_tp));
        test_passed = 0;
      end

      // bursts_complete reaches the table through the ramp machinery.
      axi_write(reg_addr(REG_IRQ_MASK), 32'h1 << IRQ_BURSTS);
      axi_write(reg_addr(REG_IRQ_TABLE), 32'h3f);
      #CFG_SETTLE_NS;
      axi_write(reg_addr(REG_RAMP_BURSTS), 32'd2);
      axi_write(reg_addr(REG_BURST_DELAY), 2 * PWM_PERIOD);
      program_pwm(PWM_PERIOD, PWM_WIDTH);

      // White-box cross-check alongside the black-box register read, so a
      // failure says which half broke: the pulse never being generated, or the
      // pulse being generated but not latched into IRQ_TABLE.
      begin
        automatic int unsigned bc_pulses = 0;
        automatic int unsigned ep_pulses = 0;
        automatic int unsigned teb_pulses = 0;
        automatic int unsigned drctl_rises = 0;
        automatic bit          drctl_was = drctl_tp;
        // Ten periods plus the five burst delays between them, with margin.
        automatic int unsigned guard = 60000;

        // Count duty cycles rather than raw sync_clk cycles: with a burst delay
        // in play the wall-clock length of a burst depends on three registers
        // at once, so a fixed window can easily contain no burst boundary at
        // all. Ten rising edges guarantee five completions at RAMP_BURSTS=2.
        while (drctl_rises < 10 && guard > 0) begin
          @(posedge sync_clk_tp);
          guard--;
          if (drctl_tp && !drctl_was) drctl_rises++;
          drctl_was = drctl_tp;
          if (system_tb.test_harness.axi_ad9910.inst.end_period)         ep_pulses++;
          if (system_tb.test_harness.axi_ad9910.inst.terminal_end_burst) teb_pulses++;
          if (system_tb.test_harness.axi_ad9910.inst.bursts_complete)    bc_pulses++;
        end
        axi_read(reg_addr(REG_IRQ_TABLE), read_data);
        // end_period should track drctl_rises one-for-one. If drctl moves
        // while end_period stays zero, the hierarchical probe is at fault
        // rather than the DUT.
        `INFO(("  over %0d duty cycles: end_period=%0d terminal_end_burst=%0d bursts_complete=%0d, IRQ_TABLE=0x%02x",
               drctl_rises, ep_pulses, teb_pulses, bc_pulses, read_data), ADI_VERBOSITY_LOW);

        if (read_data[IRQ_BURSTS]) begin
          `INFO(("  bursts_complete latched in IRQ_TABLE - PASSED"), ADI_VERBOSITY_NONE);
        end else if (bc_pulses == 0) begin
          `ERROR(("  no bursts_complete pulse generated with RAMP_BURSTS=2 (IRQ_TABLE=0x%02x)",
                  read_data));
          test_passed = 0;
        end else begin
          `ERROR(("  %0d bursts_complete pulses occurred but IRQ_TABLE=0x%02x did not latch bit %0d",
                  bc_pulses, read_data, IRQ_BURSTS));
          test_passed = 0;
        end
      end
      stop_pwm();

      // drover is driven by the ramp model and reaches irq_int[2]. Order matters
      // here: get the ramp running first and only then clear IRQ_TABLE, so that
      // whatever enabling the model or restarting the PWM latched is wiped and
      // the bit can only come back from a retrace inside the window below. The
      // check would otherwise be satisfied by the setup itself rather than by
      // the ramp - the model asserts drover the moment it is enabled, since it
      // starts sitting on the lower limit.
      axi_write(reg_addr(REG_IRQ_MASK), 32'h1 << IRQ_DROVER);
      program_pwm(PWM_PERIOD, PWM_PERIOD / 2);
      repeat (PWM_PERIOD) @(posedge sync_clk_tp);
      axi_write(reg_addr(REG_IRQ_TABLE), 32'h3f);
      repeat (3 * PWM_PERIOD) @(posedge sync_clk_tp);
      axi_read(reg_addr(REG_IRQ_TABLE), read_data);
      if (read_data[IRQ_DROVER]) begin
        `INFO(("  drover latched in IRQ_TABLE - PASSED"), ADI_VERBOSITY_NONE);
      end else begin
        `ERROR(("  IRQ_TABLE=0x%02x, drover bit not latched", read_data));
        test_passed = 0;
      end

      stop_pwm();
      axi_write(reg_addr(REG_IRQ_MASK), 32'd0);
      axi_write(reg_addr(REG_IRQ_TABLE), 32'h3f);
      axi_write(reg_addr(REG_RAMP_BURSTS), 32'd0);
      axi_write(reg_addr(REG_BURST_DELAY), 32'd0);
    end

    // ----------------------------------------
    // TC16: Clock monitors
    // ----------------------------------------
    // Deliberately last. up_clock_mon captures a count once per free-running
    // 16-bit up_clk window (65536 cycles, ~655 us at 100 MHz), so this is the
    // earliest point in the suite where a reading is available.
    current_test = 16;
    `INFO(("TC16: Clock monitors"), ADI_VERBOSITY_NONE);

    begin
      bit [31:0] sync_cnt;
      bit [31:0] pd_cnt;

      while ($time < 800us) #10us;

      axi_read(reg_addr(REG_SYNC_CLK_CNT), sync_cnt);
      axi_read(reg_addr(REG_PD_CLK_CNT), pd_cnt);
      `INFO(("  SYNC_CLK_CNT=%0d  PD_CLK_COUNT=%0d (both clocks are 250 MHz)",
             sync_cnt, pd_cnt), ADI_VERBOSITY_LOW);

      if (sync_cnt != 32'd0 && pd_cnt != 32'd0) begin
        `INFO(("  Both clock monitors report a live clock - PASSED"), ADI_VERBOSITY_NONE);
      end else begin
        `ERROR(("  Clock monitor read zero: SYNC_CLK_CNT=%0d PD_CLK_COUNT=%0d",
                sync_cnt, pd_cnt));
        test_passed = 0;
      end
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
