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

// AD9910 parallel-interface (PAR_IF) data-path testbench.
//
// Path under test: DDR (VIP mem) -> TX axi_dmac (MM->AXI-Stream) -> axi_ad9910
// s_axis -> async FIFO -> parallel output db_o[15:0] / tx_enable, with f_o[1:0]
// driven statically from the F_CFG register.
//
// The IP has no transfer-status register (the old 0x44/0x45 debug counters were
// removed in the PWM rework), so every transfer is verified by capturing db_o on
// tx_enable at the pd_clk output boundary - a black-box monitor - rather than by
// polling a count. The transfer engine emits exactly ONE 16-bit word per trigger;
// there is no "words per config" concept anymore.
//
// Width note: the TX DMA is configured SRC=32 / DEST=16 (see cfgs/cfg2_par_if.tcl),
// so each 32-bit DDR word is unpacked into two 16-bit stream beats. ddr_write_samples
// owns that packing and TC2 pins the byte/endianness mapping empirically; every data
// check is expressed in 16-bit samples and so is independent of the packing detail.

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
  localparam REG_VERSION         = 7'h00;
  localparam REG_ID              = 7'h01;
  localparam REG_SCRATCH         = 7'h02;
  localparam REG_CONFIG          = 7'h03;   // [0] = MEASURE_CLKS_EN (read-only)
  localparam REG_RESET_CTRL      = 7'h10;   // [0] = core reset (defaults 1)
  localparam REG_EXT_TRIG_CFG    = 7'h15;   // {ext_sync_disarm, ext_sync_arm}
  localparam REG_PD_CLK_CNT      = 7'h40;   // pd_clk monitor
  localparam REG_UPDATE_CTRL     = 7'h41;
  localparam REG_PAR_UPDATE_RATE = 7'h42;
  localparam REG_F_CFG           = 7'h43;   // [1:0] driven onto f_o
  // 0x44 / 0x45 (old DEBUG_SENT_CONFIGS / DEBUG_LAST_SENT_CFG) are removed.

  // UPDATE_CTRL (0x41) bit positions
  localparam CTRL_LOAD_NEW_RATE      = 0;
  localparam CTRL_ENABLE_P_IF        = 1;
  localparam CTRL_TRANSFER_TRIG_MODE = 2;

  // EXT_TRIG_CFG (0x15) bit positions
  localparam EXT_SYNC_ARM    = 0;
  localparam EXT_SYNC_DISARM = 1;

  // --------------------------
  // Timing constants (timeunit is 1ns, so these are nanoseconds)
  // --------------------------
  // Worst-case up_clk -> pd_clk control-word latency. i_xfer_cntrl_pd is a 39-bit
  // up_xfer_cntrl (axi_ad9910_reg.v:409) and up_xfer_cntrl initiates a transfer
  // only when its free-running 6-bit up_clk counter reads 1
  // (common/up_xfer_cntrl.v:97), so a register write is held at the crossing for
  // up to 64 up_clk cycles = 640 ns at 100 MHz, plus the 2-stage pd_clk
  // synchroniser (~12 ns). 2 us is ~3x that window.
  //
  // This is the ONLY place a blind wait is unavoidable: the pd-domain control
  // word exposes no readable done bit, so there is nothing to poll. Every other
  // wait in this file is an event wait on the DUT's own output - see
  // wait_tx_idle / wait_captures.
  localparam int unsigned CDC_SETTLE_NS = 2000;

  // Safety net for wait_tx_idle. Draining a full 16-entry FIFO at the slowest
  // rate used here (200, i.e. a 201-cycle period) takes 16*201 pd_clk = 12.9 us
  // at 250 MHz, so this only ever expires if the output is genuinely stuck.
  localparam int unsigned TX_IDLE_TIMEOUT_NS = 50000;

  // DDR source base for the DMA. The generated DDR_BASE macro expands to the bare
  // decimal 2147483648 (0x8000_0000), which overflows a 32-bit *signed* integer
  // literal - Vivado warns "overflow of 32 bit signed integer" wherever it is used
  // (e.g. the ddr_write_samples / start_dma_samples call sites). A sized unsigned
  // hex constant of the same value is warning-clean.
  localparam bit [31:0] DDR_BASE = 32'h8000_0000;

  // --------------------------
  // Test environment
  // --------------------------
  test_harness_env base_env;
  adi_axi_master_agent #(`AXI_VIP_PARAMS(test_harness, mng_axi_vip)) mng;
  adi_axi_slave_mem_agent #(`AXI_VIP_PARAMS(test_harness, ddr_axi_vip)) ddr;
  dmac_api tx_dma;

  bit [31:0] read_data;
  bit        test_passed = 1;
  int        current_test = 0;   // waveform navigation aid

  // --------------------------
  // AXI-Lite register access
  // --------------------------
  task axi_write(input [31:0] waddr, input [31:0] wdata);
    base_env.mng.master_sequencer.RegWrite32(waddr, wdata);
  endtask

  task axi_read(input [31:0] raddr, output [31:0] data);
    base_env.mng.master_sequencer.RegRead32(raddr, data);
  endtask

  task axi_read_v(input [31:0] raddr, input [31:0] vdata);
    base_env.mng.master_sequencer.RegReadVerify32(raddr, vdata);
  endtask

  function [31:0] reg_addr(input [6:0] offset);
    return `AXI_AD9910_BA + (offset << 2);
  endfunction

  // --------------------------
  // DDR backdoor helpers
  // --------------------------
  task ddr_write_word(input [31:0] addr, input [31:0] data);
    base_env.ddr.slave_sequencer.BackdoorWrite32(xil_axi_uint'(addr), data, 4'hF);
  endtask

  // Pack an array of 16-bit samples into DDR, two per 32-bit word. The DMA
  // (SRC=32/DEST=16) unpacks each 32-bit word into two 16-bit beats; AXI is
  // little-endian, so the low half is emitted first. This helper owns the
  // packing - if TC2 shows the mapping is reversed, flipping {hi,lo} here fixes
  // every data test at once.
  task automatic ddr_write_samples(input [31:0] base_addr, input logic [15:0] s[]);
    int unsigned nwords;
    logic [15:0] lo, hi;
    nwords = (s.size() + 1) / 2;
    for (int i = 0; i < nwords; i++) begin
      lo = s[2*i];
      hi = ((2*i + 1) < s.size()) ? s[2*i + 1] : 16'h0;
      ddr_write_word(base_addr + i*4, {hi, lo});
    end
  endtask

  // --------------------------
  // db_o / tx_enable output monitor
  // --------------------------
  // tx_enable marks one valid db_o word per pd_clk, so capturing db_o whenever
  // tx_enable is high yields one entry per emitted sample - the only way to
  // observe transfers now that the debug counters are gone.
  logic [15:0] captured [$];
  bit          monitor_enabled = 0;

  initial begin : db_o_monitor
    forever begin
      @(posedge pd_clk_tp);
      if (monitor_enabled && tx_enable_tp)
        captured.push_back(db_o_tp);
    end
  end

  task enable_monitor();
    captured.delete();
    monitor_enabled = 1;
  endtask

  task disable_monitor();
    monitor_enabled = 0;
  endtask

  // Poll the capture queue until it holds `target` samples or the timeout
  // (microseconds) elapses. Replaces the old wait-on-debug-counter polling.
  //
  // Polls on pd_clk (4 ns) rather than in 1 us steps: the coarse poll overshot
  // the true completion by up to 1 us on every call, which both padded the run
  // and quantized TC6's transfer-time measurement.
  task automatic wait_captures(input int unsigned target, input int unsigned timeout_us);
    time deadline;
    deadline = $time + (timeout_us * 1000);
    while ((captured.size() < target) && ($time < deadline))
      @(posedge pd_clk_tp);
    if (captured.size() < target) begin
      `ERROR(("  wait_captures: got %0d of %0d samples after %0d us",
              captured.size(), target, timeout_us));
      test_passed = 0;
    end
  endtask

  // Number of consecutive idle pd_clk cycles that mean "the output has stopped".
  // It must exceed one full update interval, or the gap *between* two words of the
  // same transfer would read as idle.
  //
  // PAR_UPDATE_RATE is a down-counter reload, not a frequency: transfer_rate_cnt
  // walks R -> 0 and transfer_init pulses on the cycle it reads 0
  // (axi_ad9910_if.v:288-296), so the emission period is R+1 pd_clk cycles and a
  // larger R is SLOWER. R=0 is therefore the fastest setting (a word every
  // pd_clk), not "off". The +64 clears the R+1 gap with 63 cycles of margin and
  // gives rate 0 a floor of 64 cycles (256 ns at 250 MHz).
  function automatic int unsigned tx_idle_quiet(input [31:0] rate);
    return rate + 64;
  endfunction

  // Wait until tx_enable has been low for `quiet` consecutive pd_clk cycles.
  //
  // This replaces the fixed drain/settle waits. Those were sized for rate 0 (a
  // word per pd_clk) and so were both far too long there and, in principle, too
  // short at slow rates - at rate 200 a single word takes 200 pd_clk, so a 2 us
  // drain covers only ~2 words of a possible 16-entry residual. Gating on the
  // DUT's own output scales correctly at every rate and costs only what the
  // drain actually needs.
  task automatic wait_tx_idle(input [31:0] rate);
    int unsigned quiet, run;
    time         deadline;
    quiet    = tx_idle_quiet(rate);
    run      = 0;
    deadline = $time + TX_IDLE_TIMEOUT_NS;
    while (run < quiet) begin
      @(posedge pd_clk_tp);
      run = tx_enable_tp ? 0 : (run + 1);
      if ($time >= deadline) begin
        `ERROR(("  wait_tx_idle: output still active after %0d ns (rate=%0d)",
                TX_IDLE_TIMEOUT_NS, rate));
        test_passed = 0;
        return;
      end
    end
  endtask

  // --------------------------
  // TX DMA + interface control
  // --------------------------
  // Start a TX DMA of `nsamples` 16-bit samples from DDR (2 bytes each, packed
  // two per 32-bit source word, so the byte length is nsamples*2).
  task automatic start_dma_samples(input [31:0] src_addr, input int unsigned nsamples);
    dma_segment seg;
    int tid;
    tx_dma.enable_dma();
    tx_dma.set_flags(.cyclic(1'b0), .tlast(1'b0), .partial_reporting_en(1'b0));
    seg = new(tx_dma.get_params());
    seg.length   = nsamples * 2;
    seg.src_addr = src_addr;
    tx_dma.submit_transfer(seg, tid);
  endtask

  // Enable the parallel interface at the given internal update rate (0 = fastest,
  // one word per pd_clk). trig_mode 0 = internal rate counter, 1 = external ext_sync.
  task automatic enable_par_if(input [31:0] update_rate, input bit trig_mode = 0);
    axi_write(reg_addr(REG_PAR_UPDATE_RATE), update_rate);
    axi_write(reg_addr(REG_UPDATE_CTRL),
      (trig_mode << CTRL_TRANSFER_TRIG_MODE) |
      (1 << CTRL_ENABLE_P_IF) |
      (1 << CTRL_LOAD_NEW_RATE));
    #CDC_SETTLE_NS;   // CDC of the control word into the pd_clk domain
  endtask

  task automatic disable_par_if();
    axi_write(reg_addr(REG_UPDATE_CTRL), 32'h0);
    #CDC_SETTLE_NS;
  endtask

  // Run one internal-rate transfer with clean separation from any prior one:
  // enable the interface and let any residual drain with the monitor OFF, then
  // clear the monitor and push the fresh DMA so the capture starts empty. The
  // trailing idle wait lets the transfer fully finish before the interface is
  // disabled, so nothing is left in the FIFO for the next transfer. Leaves the
  // fresh samples in `captured`.
  //
  // Both separation waits are gated on tx_enable going quiet rather than on a
  // fixed delay - see wait_tx_idle for why. Skipping either side is what produced
  // the 18-sample offset seen while this suite was being brought up.
  task automatic run_transfer(input [31:0] src, input int unsigned nsamples,
                              input [31:0] rate, input int unsigned timeout_us);
    enable_par_if(rate);
    wait_tx_idle(rate);   // drain any residual from a prior transfer (monitor off)
    enable_monitor();     // clear and begin capturing the fresh transfer
    start_dma_samples(src, nsamples);
    wait_captures(nsamples, timeout_us);
    wait_tx_idle(rate);   // let the transfer fully finish before disabling
    disable_monitor();
    disable_par_if();
    `INFO(("  (%0d samples captured)", captured.size()), ADI_VERBOSITY_LOW);
  endtask

  // --------------------------
  // Stream comparison
  // --------------------------
  // Compare the captured samples against an expected array (order and value).
  task automatic check_stream(input logic [15:0] expected[], input string label);
    int unsigned mism;
    mism = 0;
    if (captured.size() < expected.size()) begin
      `ERROR(("  %s: captured %0d of %0d samples", label, captured.size(), expected.size()));
      test_passed = 0;
      return;
    end
    foreach (expected[i]) begin
      if (captured[i] !== expected[i]) begin
        if (mism < 10)
          `ERROR(("  %s: sample %0d = 0x%04x, expected 0x%04x",
                  label, i, captured[i], expected[i]));
        mism++;
      end
    end
    if (mism == 0)
      `INFO(("  %s: %0d samples verified - PASSED", label, expected.size()),
            ADI_VERBOSITY_NONE);
    else begin
      `ERROR(("  %s: %0d mismatches", label, mism));
      test_passed = 0;
    end
  endtask

  // --------------------------
  // Ramp sample generation
  // --------------------------
  typedef enum logic [1:0] {
    RAMP_SAW_UP,
    RAMP_SAW_DOWN,
    RAMP_TRIANGLE
  } ramp_mode_e;

  // Build a 16-bit ramp into `s` (length n). Same sequence is written to DDR and
  // used as the expected stream, so the check is inherently consistent.
  task automatic build_ramp(output logic [15:0] s[],
                            input int unsigned n,
                            input logic [15:0] lo,
                            input logic [15:0] hi,
                            input int unsigned step,
                            input ramp_mode_e  mode);
    logic [15:0] v;
    bit          going_up;
    s = new[n];
    v        = (mode == RAMP_SAW_DOWN) ? hi : lo;
    going_up = (mode != RAMP_SAW_DOWN);
    for (int i = 0; i < n; i++) begin
      s[i] = v;
      if (going_up) begin
        if (hi - v < step[15:0]) begin
          if (mode == RAMP_TRIANGLE) begin v = hi; going_up = 0; end
          else                             v = lo;                  // saw up wraps
        end else v = v + step[15:0];
      end else begin
        if (v - lo < step[15:0]) begin
          if (mode == RAMP_TRIANGLE) begin v = lo; going_up = 1; end
          else                             v = hi;                  // saw down wraps
        end else v = v - step[15:0];
      end
    end
  endtask

  // --------------------------
  // Main test sequence
  // --------------------------
  initial begin
    setLoggerVerbosity(ADI_VERBOSITY_LOW);

    // Unused DRG-side outputs held quiet.
    ext_sync_tp    = 1'b0;
    drover_tp      = 1'b0;
    ram_swp_ovr_tp = 1'b0;

    base_env = new(
      .name("Base Environment"),
      .sys_clk_vip_if(`TH.`SYS_CLK.inst.IF),
      .dma_clk_vip_if(`TH.`DMA_CLK.inst.IF),
      .ddr_clk_vip_if(`TH.`DDR_CLK.inst.IF),
      .sys_rst_vip_if(`TH.`SYS_RST.inst.IF),
      .irq_base_address(0),
      .irq_vip_if(null));

    mng = new(.name(""), .master_vip_if(`TH.`MNG_AXI.inst.IF));
    ddr = new(.name(""), .slave_vip_if(`TH.`DDR_AXI.inst.IF));

    `LINK(mng, base_env, mng)
    `LINK(ddr, base_env, ddr)

    base_env.start();
    base_env.sys_reset();

    // DMA driver over the manager sequencer.
    tx_dma = new("TX_DMA", base_env.mng.master_sequencer, `TX_DMA_BA);
    tx_dma.probe();

    // Ramp and backpressure TCs run long; widen the default 1 ms watchdog.
    base_env.simulation_watchdog.update_timer(32'd5_000_000);
    base_env.simulation_watchdog.reset();

    `INFO(("==== AD9910 Parallel Interface Testbench (PAR_IF) ===="), ADI_VERBOSITY_NONE);

    // Release the core reset (up_reset defaults to 1, holding both clock domains).
    axi_write(reg_addr(REG_RESET_CTRL), 32'h0);
    #CDC_SETTLE_NS;

    // ----------------------------------------
    // TC1: Register sanity
    // ----------------------------------------
    // Reads identity registers, round-trips SCRATCH and the PAR_IF RW registers
    // with distinct patterns, checks CONFIG.MEASURE_CLKS_EN, and confirms the
    // removed 0x44/0x45 read 0 - the map shifted in the PWM rework, so a stale
    // address produces no bus error, only a readback mismatch.
    current_test = 1;
    `INFO(("TC1: Register sanity"), ADI_VERBOSITY_NONE);
    begin
      bit [31:0] pd_cnt;

      axi_read(reg_addr(REG_VERSION), read_data);
      `INFO(("  VERSION = 0x%08x", read_data), ADI_VERBOSITY_LOW);
      axi_read(reg_addr(REG_ID), read_data);
      `INFO(("  ID = 0x%08x", read_data), ADI_VERBOSITY_LOW);

      axi_write(reg_addr(REG_SCRATCH), 32'hCAFE_BABE);
      axi_read_v(reg_addr(REG_SCRATCH), 32'hCAFE_BABE);

      axi_read(reg_addr(REG_CONFIG), read_data);
      if (read_data[0])
        `INFO(("  CONFIG.MEASURE_CLKS_EN = 1 - PASSED"), ADI_VERBOSITY_NONE);
      else begin
        `ERROR(("  CONFIG.MEASURE_CLKS_EN = 0, expected 1"));
        test_passed = 0;
      end

      axi_write(reg_addr(REG_PAR_UPDATE_RATE), 32'h1234_5678);
      axi_read_v(reg_addr(REG_PAR_UPDATE_RATE), 32'h1234_5678);

      axi_write(reg_addr(REG_F_CFG), 32'h3);
      axi_read_v(reg_addr(REG_F_CFG), 32'h3);
      axi_write(reg_addr(REG_F_CFG), 32'h0);

      // enable_p_if (bit 1) is a plain RW bit; load_new_rate (bit 0) self-clears,
      // so it is not part of the readback check.
      axi_write(reg_addr(REG_UPDATE_CTRL), (1 << CTRL_ENABLE_P_IF));
      axi_read(reg_addr(REG_UPDATE_CTRL), read_data);
      if (read_data[CTRL_ENABLE_P_IF])
        `INFO(("  UPDATE_CTRL readback - PASSED"), ADI_VERBOSITY_NONE);
      else begin
        `ERROR(("  UPDATE_CTRL readback = 0x%08x", read_data));
        test_passed = 0;
      end
      axi_write(reg_addr(REG_UPDATE_CTRL), 32'h0);

      axi_read(reg_addr(7'h44), read_data);
      if (read_data != 0) begin
        `ERROR(("  removed reg 0x44 read 0x%08x, expected 0", read_data));
        test_passed = 0;
      end
      axi_read(reg_addr(7'h45), read_data);
      if (read_data != 0) begin
        `ERROR(("  removed reg 0x45 read 0x%08x, expected 0", read_data));
        test_passed = 0;
      end

      axi_read(reg_addr(REG_PD_CLK_CNT), pd_cnt);
      `INFO(("  PD_CLK_COUNT = %0d (monitor needs ~655 us to update)", pd_cnt),
            ADI_VERBOSITY_LOW);
      `INFO(("  Register sanity - PASSED"), ADI_VERBOSITY_NONE);
    end

    // ----------------------------------------
    // TC2: Single-word transfer + width mapping
    // ----------------------------------------
    // One 32-bit DDR word carrying two known 16-bit samples. Pins the SRC=32 ->
    // DEST=16 byte/endianness mapping that every later data test relies on.
    current_test = 2;
    `INFO(("TC2: Single transfer + width mapping"), ADI_VERBOSITY_NONE);
    begin
      logic [15:0] samples[];
      samples = '{16'h1111, 16'h2222};   // DDR word 0 = 0x2222_1111

      ddr_write_samples(DDR_BASE, samples);
      run_transfer(DDR_BASE, 2, 32'd100, 200);

      if (captured.size() >= 2)
        `INFO(("  captured = 0x%04x, 0x%04x (DDR word 0x2222_1111)",
               captured[0], captured[1]), ADI_VERBOSITY_LOW);
      check_stream(samples, "Single transfer / mapping");
    end

    // ----------------------------------------
    // TC3: Multi-word stream (in order)
    // ----------------------------------------
    // Several distinct samples streamed at the internal rate; all must appear in
    // order. Replaces the old "3 words per config packet" (the RTL now emits one
    // word per trigger, so a packet is just a stream).
    current_test = 3;
    `INFO(("TC3: Multi-word stream"), ADI_VERBOSITY_NONE);
    begin
      logic [15:0] samples[];
      samples = '{16'hAAAA, 16'hBBBB, 16'hCCCC, 16'hDDDD, 16'h0001, 16'hFFFE};

      ddr_write_samples(DDR_BASE, samples);
      run_transfer(DDR_BASE, samples.size(), 32'd50, 200);
      check_stream(samples, "Multi-word stream");
    end

    // ----------------------------------------
    // TC4: Continuous streaming
    // ----------------------------------------
    // A longer contiguous run at a fast rate; verifies sustained ordered delivery.
    current_test = 4;
    `INFO(("TC4: Continuous streaming"), ADI_VERBOSITY_NONE);
    begin
      localparam int N = 32;
      logic [15:0] samples[];
      samples = new[N];
      foreach (samples[i]) samples[i] = 16'h1000 + i[15:0];

      ddr_write_samples(DDR_BASE, samples);
      run_transfer(DDR_BASE, N, 32'd10, 500);
      check_stream(samples, "Continuous streaming");
    end

    // ----------------------------------------
    // TC5: Backpressure (deeper than the FIFO)
    // ----------------------------------------
    // Transfer far more than the 16-entry FIFO at a slow drain rate, so the FIFO
    // fills and s_axis_tready backpressures the DMA. No sample may be lost.
    current_test = 5;
    `INFO(("TC5: Backpressure"), ADI_VERBOSITY_NONE);
    begin
      localparam int N = 64;   // 4x FIFO depth
      logic [15:0] samples[];
      samples = new[N];
      foreach (samples[i]) samples[i] = 16'h5000 + i[15:0];

      ddr_write_samples(DDR_BASE, samples);
      run_transfer(DDR_BASE, N, 32'd200, 2000);   // slow drain -> FIFO fills
      check_stream(samples, "Backpressure");
    end

    // ----------------------------------------
    // TC6: Update-rate change
    // ----------------------------------------
    // Time a full N-sample transfer at a slow vs fast internal rate: the faster
    // rate must complete the same transfer at least ~2x quicker. Each transfer is
    // followed by wait_tx_idle, so both drain fully and TC7 starts with an empty
    // FIFO - its "nothing emitted before a trigger" check depends on that.
    current_test = 6;
    `INFO(("TC6: Update-rate change"), ADI_VERBOSITY_NONE);
    begin
      localparam int N = 128;
      logic [15:0] samples[];
      time t0, t_slow, t_fast;
      samples = new[N];
      foreach (samples[i]) samples[i] = 16'h6000 + i[15:0];

      ddr_write_samples(DDR_BASE, samples);
      enable_par_if(.update_rate(32'd200));
      wait_tx_idle(32'd200); enable_monitor();
      t0 = $time;
      start_dma_samples(DDR_BASE, N);
      wait_captures(N, 4000);
      t_slow = $time - t0;
      wait_tx_idle(32'd200);   // full drain, so TC7 starts with an empty FIFO
      disable_monitor(); disable_par_if();

      ddr_write_samples(DDR_BASE, samples);
      enable_par_if(.update_rate(32'd20));
      wait_tx_idle(32'd20); enable_monitor();
      t0 = $time;
      start_dma_samples(DDR_BASE, N);
      wait_captures(N, 4000);
      t_fast = $time - t0;
      wait_tx_idle(32'd20);
      disable_monitor(); disable_par_if();

      `INFO(("  %0d-sample transfer: slow(rate=200)=%0t fast(rate=20)=%0t",
             N, t_slow, t_fast), ADI_VERBOSITY_LOW);
      if (t_slow > (t_fast * 2))
        `INFO(("  Faster rate transfers >2x quicker - PASSED"), ADI_VERBOSITY_NONE);
      else begin
        `ERROR(("  Rate change ineffective: slow=%0t fast=%0t", t_slow, t_fast));
        test_passed = 0;
      end
    end

    // ----------------------------------------
    // TC7: External trigger (ext_sync)
    // ----------------------------------------
    // In external-trigger mode the DUT emits one word per ext_sync event (armed
    // via EXT_TRIG_CFG). Preload the FIFO, then pulse ext_sync and confirm words
    // come out only when triggered.
    current_test = 7;
    `INFO(("TC7: External trigger (ext_sync)"), ADI_VERBOSITY_NONE);
    begin
      localparam int N = 4;
      logic [15:0] samples[];
      samples = new[N];
      foreach (samples[i]) samples[i] = 16'h7000 + i[15:0];

      ddr_write_samples(DDR_BASE, samples);
      enable_monitor();
      // External trigger mode; internal rate irrelevant.
      enable_par_if(.update_rate(32'd0), .trig_mode(1'b1));
      // Load the samples into the FIFO (they wait for triggers).
      start_dma_samples(DDR_BASE, N);
      // Deliberately a blind wait, and deliberately generous: this one has to let
      // the DMA actually land samples in the FIFO, because the check below is
      // negative. Shortening it would let the check pass vacuously - with an empty
      // FIFO there is nothing to wrongly emit. No FIFO level is readable, so there
      // is nothing to gate on.
      #5us;

      // Nothing should have come out yet without a trigger.
      if (captured.size() != 0) begin
        `ERROR(("  %0d samples emitted before any ext_sync trigger", captured.size()));
        test_passed = 0;
      end

      // util_ext_sync arms on a RISING edge of ext_sync_arm and fires (sync_armed
      // falls -> start_transfer) on a rising edge of sync_in. ext_sync_arm is a
      // level register, so each word needs the arm level cleared then re-asserted
      // (a fresh rising edge), with enough settle for the up->pd CDC to carry each
      // level distinctly.
      for (int i = 0; i < N; i++) begin
        axi_write(reg_addr(REG_EXT_TRIG_CFG), 32'h0);                // clear arm level
        #CDC_SETTLE_NS;
        axi_write(reg_addr(REG_EXT_TRIG_CFG), (1 << EXT_SYNC_ARM));  // rising edge -> armed
        #CDC_SETTLE_NS;
        ext_sync_tp = 1'b1; #200ns; ext_sync_tp = 1'b0;             // sync_in rising -> fire
        // Wait for THIS trigger's word instead of a blind settle. Stronger as well
        // as shorter: it asserts every individual trigger produces exactly one
        // word, where the old fixed wait only checked the total at the end.
        wait_captures(i + 1, 10);
      end
      disable_par_if();
      disable_monitor();
      check_stream(samples, "External trigger");
    end

    // ----------------------------------------
    // TC8: F_CFG drives f_o
    // ----------------------------------------
    // 0x43 is a static 2-bit function-select value routed straight to the f_o pins.
    current_test = 8;
    `INFO(("TC8: F_CFG -> f_o"), ADI_VERBOSITY_NONE);
    begin
      bit ok = 1;
      for (int v = 0; v < 4; v++) begin
        axi_write(reg_addr(REG_F_CFG), v[31:0]);
        #CDC_SETTLE_NS;   // CDC into pd domain
        if (f_o_tp !== v[1:0]) begin
          `ERROR(("  F_CFG=%0d -> f_o=0x%01x, expected 0x%01x", v, f_o_tp, v[1:0]));
          ok = 0;
        end
      end
      axi_write(reg_addr(REG_F_CFG), 32'h0);
      #CDC_SETTLE_NS;
      if (ok) `INFO(("  All 4 F_CFG values reflected on f_o - PASSED"), ADI_VERBOSITY_NONE);
      else    test_passed = 0;
    end

    // ----------------------------------------
    // TC9: Ramp data integrity
    // ----------------------------------------
    // 16-bit sawtooth-up / triangle / sawtooth-down streamed from DDR and checked
    // sample-for-sample at the output.
    current_test = 9;
    `INFO(("TC9: Ramp data integrity"), ADI_VERBOSITY_NONE);
    begin
      localparam int N = 256;
      localparam int STEP = 512;
      logic [15:0] samples[];

      build_ramp(samples, N, 16'h0000, 16'hFF00, STEP, RAMP_SAW_UP);
      ddr_write_samples(DDR_BASE, samples);
      run_transfer(DDR_BASE, N, 32'd0, 2000);
      check_stream(samples, "Ramp sawtooth-up");

      build_ramp(samples, N, 16'h0000, 16'hFF00, STEP, RAMP_TRIANGLE);
      ddr_write_samples(DDR_BASE, samples);
      run_transfer(DDR_BASE, N, 32'd0, 2000);
      check_stream(samples, "Ramp triangle");

      build_ramp(samples, N, 16'h0000, 16'hFF00, STEP, RAMP_SAW_DOWN);
      ddr_write_samples(DDR_BASE, samples);
      run_transfer(DDR_BASE, N, 32'd0, 2000);
      check_stream(samples, "Ramp sawtooth-down");
    end

    // ----------------------------------------
    // Final report
    // ----------------------------------------
    #1us;
    base_env.stop();

    if (test_passed)
      `INFO(("==== ALL TESTS PASSED ===="), ADI_VERBOSITY_NONE);
    else
      `ERROR(("==== SOME TESTS FAILED ===="));

    `INFO(("Testbench done!"), ADI_VERBOSITY_NONE);
    $finish();
  end

endprogram
