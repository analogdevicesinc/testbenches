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
import test_harness_env_pkg::*;
import adi_axi_agent_pkg::*;

import `PKGIFY(test_harness, mng_axi_vip)::*;
import `PKGIFY(test_harness, ddr_axi_vip)::*;

// ---------------------------------------------------------------------------
// Shorthand macros to access io_vip interfaces through the test harness
// ---------------------------------------------------------------------------
`define RX_FRAME_VIF     `TH.`RX_FRAME.inst.inst.IF.vif
`define RX_DATA_VIF      `TH.`RX_DATA.inst.inst.IF.vif
`define ADC_VALID_I0_VIF `TH.`ADC_VALID_I0.inst.inst.IF.vif
`define ADC_DATA_I0_VIF  `TH.`ADC_DATA_I0.inst.inst.IF.vif

// ---------------------------------------------------------------------------
// AXI base address and register offset
// ---------------------------------------------------------------------------
`define AXI_AD9361_BASE   32'h44A00000
`define REG_ADC_STATUS    (`AXI_AD9361_BASE + 32'h005C)
`define REG_CHAN_CTRL_I0  (`AXI_AD9361_BASE + 32'h0400)  // channel 0 (R1 I)
`define REG_CHAN_CTRL_Q0  (`AXI_AD9361_BASE + 32'h0440)  // channel 1 (R1 Q)
`define REG_CHAN_CTRL_I1  (`AXI_AD9361_BASE + 32'h0480)  // channel 2 (R2 I)
`define REG_CHAN_CTRL_Q1  (`AXI_AD9361_BASE + 32'h04C0)  // channel 3 (R2 Q)

// ---------------------------------------------------------------------------
// Frame Sweep Test Program
//
// Drives clean AD9361 LVDS frame sequences and observes adc_status,
// adc_valid_i0, and adc_data_i0 in the waveform.
//
// All signals are driven via the posedge clocking block only (drive_cycle),
// so the frame wire is always a clean 0 or 1 — no X, no glitches.
//
// Section 1: Each of the 4 valid steady-state frame patterns driven for
//            12 cycles to verify adc_status=1 and check valid/data.
//
// Section 2: Realistic repeating frame bursts (10 transfers) matching the
//            AD9361 LVDS protocol (UG-570 Figure 79).
//
// Background (UG-570, Figure 79):
//   RX_FRAME_P high → MSB DDR clock cycle
//   RX_FRAME_P low  → LSB DDR clock cycle
//
//   Four valid {curr, prev} patterns in axi_ad9361_lvds_if.v:
//     4'b1111 — frame stays high  (steady-state MSB)
//     4'b1100 — frame just rose   (start of MSB slot)
//     4'b0000 — frame stays low   (steady-state LSB)
//     4'b0011 — frame just fell   (start of LSB slot; 1R1T valid trigger)
//
//   2R2T delineation: frame=1111 → store MSB; frame=0000 → store LSB + valid
//   1R1T delineation: frame=0011 → store all words + valid
// ---------------------------------------------------------------------------

program frame_sweep;

  timeunit 1ns;
  timeprecision 1ps;

  test_harness_env base_env;

  adi_axi_master_agent #(`AXI_VIP_PARAMS(test_harness, mng_axi_vip)) mng;
  adi_axi_slave_mem_agent #(`AXI_VIP_PARAMS(test_harness, ddr_axi_vip)) ddr;

  // -------------------------------------------------------------------------
  // drive_cycle: drives one clock cycle using only the posedge clocking block.
  //
  // Schedules the new value once via cb_p (output #1ps after posedge) and
  // waits for the next posedge. The wire is driven to a stable level for the
  // full clock period — both the IDDRE1 posedge and negedge captures see the
  // same clean value with no contention and no glitches.
  // -------------------------------------------------------------------------
  task drive_cycle(
    input logic frame,
    input logic [5:0] data
  );
    `RX_FRAME_VIF.set_positive_edge();
    `RX_FRAME_VIF.set_io({{1023{1'b0}}, frame});
    `RX_DATA_VIF.set_positive_edge();
    `RX_DATA_VIF.set_io({{1018{1'b0}}, data});
    `RX_FRAME_VIF.wait_posedge_clk();
  endtask

  // -------------------------------------------------------------------------
  // read_status: read adc_status bit[0] via AXI after waiting for CDC settle.
  // -------------------------------------------------------------------------
  task read_status(output logic status);
    logic [31:0] rdata;
    repeat (200) `RX_FRAME_VIF.wait_posedge_clk();
    base_env.mng.master_sequencer.RegRead32(`REG_ADC_STATUS, rdata);
    status = rdata[0];
  endtask

  // -------------------------------------------------------------------------
  // poll_valid: poll adc_valid_i0 on every posedge for up to 20 cycles and
  // capture adc_data_i0 at the cycle the pulse is seen.
  // adc_valid_i0 is a 1-cycle pulse (8 pipeline stages deep) so a one-shot
  // read after a long wait will always miss it.
  // -------------------------------------------------------------------------
  task poll_valid(output logic seen, output logic [15:0] data_out);
    logic valid;
    seen     = 1'b0;
    data_out = 16'h0;
    for (int c = 0; c < 30; c++) begin
      `ADC_VALID_I0_VIF.wait_posedge_clk();
      valid = `ADC_VALID_I0_VIF.get_io()[0];
      if (valid === 1'b1) begin
        data_out = `ADC_DATA_I0_VIF.get_io()[15:0];
        seen     = 1'b1;
      end
    end
  endtask

  initial begin
    // ------------------------------------------------------------------
    // Environment setup
    // ------------------------------------------------------------------
    base_env = new(
      .name("Base Environment"),
      .sys_clk_vip_if(`TH.`SYS_CLK.inst.IF),
      .dma_clk_vip_if(`TH.`DMA_CLK.inst.IF),
      .ddr_clk_vip_if(`TH.`DDR_CLK.inst.IF),
      .sys_rst_vip_if(`TH.`SYS_RST.inst.IF),
      .irq_base_address(`IRQ_C_BA),
      .irq_vip_if(`TH.`IRQ.inst.inst.IF.vif));

    mng = new("AXI Manager agent", `TH.`MNG_AXI.inst.IF);
    ddr = new("AXI DDR stub agent", `TH.`DDR_AXI.inst.IF);

    `LINK(mng, base_env, mng)
    `LINK(ddr, base_env, ddr)

    setLoggerVerbosity(ADI_VERBOSITY_NONE);

    base_env.start();
    `TH.`L_CLK.inst.IF.start_clock();
    base_env.sys_reset();

    `RX_FRAME_VIF.set_positive_edge();
    `RX_FRAME_VIF.set_io(1024'b0);
    `RX_DATA_VIF.set_positive_edge();
    `RX_DATA_VIF.set_io(1024'b0);

    // Release ADC from reset (write 1 to up_resetn, reg offset 0x40 bit 0)
    base_env.mng.master_sequencer.RegWrite32(`AXI_AD9361_BASE + 32'h0040, 32'h1);
    repeat (200) `RX_FRAME_VIF.wait_posedge_clk();

    // Disable IQ correction and DC filter on all 4 channels so that
    // adc_data_i0/q0/i1/q1 reflects the raw 12-bit sample (zero-padded
    // to 16 bits) without any DSP processing applied.
    // Writing 0 clears: bit[9]=iqcor_enb, bit[8]=dcfilt_enb, bit[4]=dfmt_enable.
    base_env.mng.master_sequencer.RegWrite32(`REG_CHAN_CTRL_I0, 32'h0);
    base_env.mng.master_sequencer.RegWrite32(`REG_CHAN_CTRL_Q0, 32'h0);
    base_env.mng.master_sequencer.RegWrite32(`REG_CHAN_CTRL_I1, 32'h0);
    base_env.mng.master_sequencer.RegWrite32(`REG_CHAN_CTRL_Q1, 32'h0);

    // ==================================================================
    // SECTION 1: Steady-state valid patterns
    //
    // Drive each valid steady-state frame pattern for 12 consecutive DDR
    // cycles so {rx_frame_s, rx_frame} fully settles to the same value
    // on every posedge (12 >> 2-cycle lock pipeline + 1 rx_frame delay).
    //
    // Data values chosen from UG-570: maximum positive sample = 0x7FF,
    // encoded as MSB word 0x1F, LSB word 0x3F (two's complement).
    // We drive I-channel=0x1F/0x3F and Q-channel=0x2A/0x15 so each
    // channel has a distinct, non-zero value in the waveform.
    //
    // Expected: adc_status=1 for all four patterns.
    // adc_valid_i0 pulses once per trigger cycle (polled over 20 cycles).
    // ==================================================================
    `INFO((""), ADI_VERBOSITY_NONE);
    `INFO(("=== SECTION 1: Valid steady-state frame patterns ==="), ADI_VERBOSITY_NONE);

    // ------------------------------------------------------------------
    // Pattern 4'b1111 — frame stays high (MSB slot, steady state)
    // Per UG-570 Fig.79: data_p = R1_I[11:6], data_n = R1_Q[11:6]
    // HDL action: stores into adc_data_p[23:12] and [11:0]; valid=0
    // No valid pulse expected (valid fires on the following 0000 cycle).
    // ------------------------------------------------------------------
    begin
      logic status; logic seen; logic [15:0] d;
      `INFO(("--- 4'b1111: frame stays high (MSB slot) ---"), ADI_VERBOSITY_NONE);
      repeat (12) drive_cycle(1'b1, 6'h1F);
      read_status(status);
      poll_valid(seen, d);
      `INFO(($sformatf("[SWEEP] 4'b1111 stay-high | status=%0b valid_seen=%0b data=0x%04h",
             status, seen, d)), ADI_VERBOSITY_NONE);
    end

    // ------------------------------------------------------------------
    // Pattern 4'b1100 — frame just rose (curr=11, prev=00)
    // Per UG-570 Fig.79: this is the rising edge of RX_FRAME_P, marking
    // the start of a new MSB slot after an LSB slot.
    // HDL: rx_error=0, valid=0 (MSB is stored, not yet complete).
    // Drive: 6 cycles low (to set prev=00) then 6 cycles high (curr=11).
    // ------------------------------------------------------------------
    begin
      logic status; logic seen; logic [15:0] d;
      `INFO(("--- 4'b1100: frame just rose (start of MSB slot) ---"), ADI_VERBOSITY_NONE);
      repeat (6) drive_cycle(1'b0, 6'h3F); // prev = 00
      repeat (6) drive_cycle(1'b1, 6'h1F); // curr = 11 → pattern = 1100
      read_status(status);
      poll_valid(seen, d);
      `INFO(($sformatf("[SWEEP] 4'b1100 frame-rose  | status=%0b valid_seen=%0b data=0x%04h",
             status, seen, d)), ADI_VERBOSITY_NONE);
    end

    // ------------------------------------------------------------------
    // Pattern 4'b0000 — frame stays low (LSB slot, steady state)
    // Per UG-570 Fig.79: data_p = R1_I[5:0], data_n = R1_Q[5:0]
    // HDL action: stores into adc_data_p[47:24]; asserts adc_valid_p=1.
    // adc_valid_i0 pulses once per cycle (polled).
    // ------------------------------------------------------------------
    begin
      logic status; logic seen; logic [15:0] d;
      `INFO(("--- 4'b0000: frame stays low (LSB slot, valid fires) ---"), ADI_VERBOSITY_NONE);
      repeat (12) drive_cycle(1'b0, 6'h3F);
      read_status(status);
      poll_valid(seen, d);
      `INFO(($sformatf("[SWEEP] 4'b0000 stay-low   | status=%0b valid_seen=%0b data=0x%04h",
             status, seen, d)), ADI_VERBOSITY_NONE);
    end

    // ------------------------------------------------------------------
    // Pattern 4'b0011 — frame just fell (curr=00, prev=11)
    // Per UG-570 Fig.79: this is the falling edge of RX_FRAME_P, marking
    // the transition from MSB slot to LSB slot.
    // HDL (2R2T): rx_error=0, valid fires on the 0000 steady-state that
    //             follows — not on the 0011 transition itself.
    // HDL (1R1T): THIS is the delineation trigger — valid fires here.
    // Drive: 6 cycles high (prev=11) then 6 cycles low (curr=00 → 0011).
    // ------------------------------------------------------------------
    begin
      logic status; logic seen; logic [15:0] d;
      `INFO(("--- 4'b0011: frame just fell (start of LSB slot; 1R1T valid trigger) ---"), ADI_VERBOSITY_NONE);
      repeat (6) drive_cycle(1'b1, 6'h1F); // prev = 11
      repeat (6) drive_cycle(1'b0, 6'h3F); // curr = 00 → pattern = 0011
      read_status(status);
      poll_valid(seen, d);
      `INFO(($sformatf("[SWEEP] 4'b0011 frame-fell  | status=%0b valid_seen=%0b data=0x%04h",
             status, seen, d)), ADI_VERBOSITY_NONE);
    end

    // ==================================================================
    // SECTION 2: Complete frame sequences (as the AD9361 actually sends)
    //
    // Per UG-570 Figure 79, a real frame is a repeating burst:
    //
    //   2R2T: DDR clock 0 (frame=1): R1_I[11:6] / R1_Q[11:6]  (MSB)
    //         DDR clock 1 (frame=0): R1_I[5:0]  / R1_Q[5:0]   (LSB) → valid
    //         (R2 data occupies the second LVDS data pair in parallel)
    //
    //   1R1T: DDR clock 0 (frame=1): R_I[11:6] / R_Q[11:6]    (MSB)
    //         DDR clock 1 (frame=0): R_I[5:0]  / R_Q[5:0]     (LSB) → valid
    //
    // Repeated 10 times so 10 data transfers are visible in the waveform.
    // Data value 0x15 for MSB cycles, 0x2A for LSB cycles — distinct,
    // non-zero values that are easy to identify in the waveform viewer.
    // ==================================================================
    `INFO((""), ADI_VERBOSITY_NONE);
    `INFO(("=== SECTION 2: Complete frame bursts ==="), ADI_VERBOSITY_NONE);

    if (`MODE_1R1T == 0) begin
      logic seen; logic [15:0] d;
      // 2R2T burst: 1 MSB cycle (frame high) + 1 LSB cycle (frame low)
      // (R2 data would come from the second LVDS pair; data_p/data_n here
      //  are R1 only — R2 is 0 since only one io_vip drives rx_data_in_p)
      `INFO(("--- 2R2T burst x10: MSB(frame=1111) + LSB(frame=0000) ---"), ADI_VERBOSITY_NONE);
      // drive_cycle drives posedge only; IDDRE1 SAME_EDGE mode captures the same
      // stable value at both posedge (I) and negedge (Q) within the full period.
      repeat (10) begin
        drive_cycle(1'b1, 6'h15); // MSB: data=0x15 → both I_MSB and Q_MSB = 0x15
        drive_cycle(1'b0, 6'h2A); // LSB: data=0x2A → both I_LSB and Q_LSB = 0x2A; valid fires
      end
      poll_valid(seen, d);
      `INFO(($sformatf("[SWEEP] 2R2T burst | valid_seen=%0b data_i0=0x%04h", seen, d)),
            ADI_VERBOSITY_NONE);
    end

    if (`MODE_1R1T == 1) begin
      logic seen; logic [15:0] d;
      // 1R1T burst: 1 MSB cycle (frame high) + 1 LSB cycle (frame low → 0011 trigger)
      `INFO(("--- 1R1T burst x10: MSB(frame=1111) + LSB-trigger(frame=0000→0011) ---"), ADI_VERBOSITY_NONE);
      // Prime with one MSB cycle first so the very first 0011 transition has
      // a valid previous state (prev=11).
      drive_cycle(1'b1, 6'h15);
      repeat (10) begin
        drive_cycle(1'b0, 6'h2A); // falling: {curr=00,prev=11}=0011 → valid
        drive_cycle(1'b1, 6'h15); // rising:  {curr=11,prev=00}=1100
      end
      poll_valid(seen, d);
      `INFO(($sformatf("[SWEEP] 1R1T burst | valid_seen=%0b data_i0=0x%04h", seen, d)),
            ADI_VERBOSITY_NONE);
    end



    // ------------------------------------------------------------------
    // Done
    // ------------------------------------------------------------------
    `INFO((""), ADI_VERBOSITY_NONE);
    `INFO(("Frame sweep complete."), ADI_VERBOSITY_NONE);
    #100ns;
    `TH.`L_CLK.inst.IF.stop_clock();
    base_env.stop();
    `INFO(("Test bench done!"), ADI_VERBOSITY_NONE);
    $finish();
  end

endprogram
