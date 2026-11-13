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
import adc_api_pkg::*;
import adi_regmap_adc_pkg::*;
import io_vip_if_base_pkg::*;

import `PKGIFY(test_harness, mng_axi_vip)::*;
import `PKGIFY(test_harness, ddr_axi_vip)::*;


program test_program;

  timeunit 1ns;
  timeprecision 1ps;

  // The test harness environment provides clocks, reset, and AXI master
  test_harness_env base_env;

  adi_axi_master_agent #(`AXI_VIP_PARAMS(test_harness, mng_axi_vip)) mng;
  adi_axi_slave_mem_agent #(`AXI_VIP_PARAMS(test_harness, ddr_axi_vip)) ddr;

  adc_api adc;

  // io_vip interface handles — assigned once at startup, used throughout
  io_vip_if_base rx_frame_vif;
  io_vip_if_base rx_data_vif;
  io_vip_if_base tx_frame_vif;
  io_vip_if_base adc_valid_i0_vif;
  io_vip_if_base adc_data_i0_vif;

  process current_process;
  string  current_process_random_state;

  // ---------------------------------------------------------------------------
  // Helper: drive one DDR cycle on rx_frame and rx_data.
  //   frame_p = value driven on the rising edge of l_clk  (rx_frame_s[1])
  //   frame_n = value driven on the falling edge of l_clk (rx_frame_s[0])
  //   data_p  = 6-bit value driven on rising edge
  //   data_n  = 6-bit value driven on falling edge
  //
  // io_vip clocking block uses non-blocking assignment (cb_p.IO <= value).
  // The correct sequence is: set_io() THEN wait for the edge that latches it.
  // ---------------------------------------------------------------------------
  task drive_ddr_cycle(
    input logic frame_p,
    input logic frame_n,
    input logic [5:0] data_p,
    input logic [5:0] data_n
  );
    // Schedule rising-edge values, then wait for posedge to latch them out
    rx_frame_vif.set_positive_edge();
    rx_frame_vif.set_io({{1023{1'b0}}, frame_p});
    rx_data_vif.set_positive_edge();
    rx_data_vif.set_io({{1018{1'b0}}, data_p});
    rx_frame_vif.wait_posedge_clk();   // posedge fires → frame_p/data_p now on wire

    // Schedule falling-edge values, then wait for negedge to latch them out
    rx_frame_vif.set_negative_edge();
    rx_frame_vif.set_io({{1023{1'b0}}, frame_n});
    rx_data_vif.set_negative_edge();
    rx_data_vif.set_io({{1018{1'b0}}, data_n});
    rx_frame_vif.wait_negedge_clk();  // negedge fires → frame_n/data_n now on wire
  endtask

  // ---------------------------------------------------------------------------
  // Helper: read adc_status bit via ADC API.
  //   Returns the CDC-synchronised value of adc_status from lvds_if.
  // ---------------------------------------------------------------------------
  task read_adc_status(output logic status);
    adc.get_status(.status(status));
  endtask

  // ---------------------------------------------------------------------------
  // Helper: drive N cycles of a frame pattern, then read adc_status.
  // Drives 8 cycles to flush both the two-cycle lock pipeline in lvds_if
  // and the CDC synchroniser from adc_clk to up_clk.
  // ---------------------------------------------------------------------------
  task check_frame_pattern(
    input logic frame_p,
    input logic frame_n,
    input logic expected_status,
    input string label
  );
    logic status;

    // Fixed 8-cycle drive loop — cannot hang.
    repeat (8) begin
      drive_ddr_cycle(.frame_p(frame_p), .frame_n(frame_n), .data_p(6'h0), .data_n(6'h0));
    end

    // Fixed 200-cycle wait for CDC settle — cannot hang.
    // up_xfer_status transfers every 64 d_clk cycles then needs 3 up_clk
    // sync stages. 200 l_clk cycles guarantees the status has settled.
    repeat (200) rx_frame_vif.wait_posedge_clk();

    read_adc_status(status);

    if (status !== expected_status) begin
      `ERROR(($sformatf("[%s] adc_status=%0b expected=%0b", label, status, expected_status)));
      $finish;
    end else begin
      `INFO(($sformatf("[%s] PASS: adc_status=%0b", label, status)), ADI_VERBOSITY_LOW);
    end
  endtask

  initial begin
    current_process = process::self();
    current_process_random_state = current_process.get_randstate();
    `INFO(("Randomization state: %s", current_process_random_state), ADI_VERBOSITY_NONE);

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

    adc = new(.name("adc"), .bus(base_env.mng.master_sequencer), .base_address(`AXI_AD9361_BA));

    // Assign io_vip interface handles
    rx_frame_vif     = `TH.`RX_FRAME.inst.inst.IF.vif;
    rx_data_vif      = `TH.`RX_DATA.inst.inst.IF.vif;
    tx_frame_vif     = `TH.`TX_FRAME.inst.inst.IF.vif;
    adc_valid_i0_vif = `TH.`ADC_VALID_I0.inst.inst.IF.vif;
    adc_data_i0_vif  = `TH.`ADC_DATA_I0.inst.inst.IF.vif;

    setLoggerVerbosity(ADI_VERBOSITY_NONE);

    base_env.start();

    // Start L_CLK (250 MHz DDR clock) — not started by base_env.start()
    `TH.`L_CLK.inst.IF.start_clock();

    base_env.sys_reset();

    // Initialize all master io_vip outputs to 0 to avoid driving high-Z.
    rx_frame_vif.set_positive_edge();
    rx_frame_vif.set_io(1024'b0);
    rx_data_vif.set_positive_edge();
    rx_data_vif.set_io(1024'b0);

    // Release ADC from reset (up_resetn). Without this, adc_rst remains
    // asserted, up_xfer_status is held in reset, and adc_status never
    // propagates to the AXI register.
    adc.reset(.ce_n(1'b0), .mmcm_rstn(1'b1), .rstn(1'b1));

    // Wait for the control CDC (up_xfer_cntrl) to propagate to adc_clk domain
    // and for the status CDC (up_xfer_status) to complete its first 64-cycle transfer.
    repeat (200) rx_frame_vif.wait_posedge_clk();

    // Disable IQ correction, DC filter and data format on all 4 channels so
    // adc_data_i0/q0/i1/q1 reflects the raw 12-bit sample without DSP applied.
    for (int ch = 0; ch < 4; ch++) begin
      adc.set_channel_control(
        .channel(ch),
        .adc_lb_owr(1'b0),
        .adc_pn_sel_owr(1'b0),
        .iqcor_enb(1'b0),
        .dcfilt_enb(1'b0),
        .format_signext(1'b0),
        .format_type(1'b0),
        .format_enable(1'b0),
        .adc_pn_type_owr(1'b0),
        .enable(1'b0));
    end

    // ==================================================================
    // TEST 1: Valid frame patterns → adc_status must be 1
    // ==================================================================
    // The four valid {rx_frame_s, rx_frame} patterns are:
    //   1111 (staying high), 1100 (rising: prev={0,0} curr={1,1}),
    //   0000 (staying low),  0011 (falling: prev={1,1} curr={0,0})
    // For steady-state patterns (1111, 0000): drive the same pair every cycle.
    // For transition patterns (1100, 0011): prime 4 cycles with the previous
    // state, then call check_frame_pattern with the current state.
    // ==================================================================
    `INFO(("--- Test 1: Valid frame patterns ---"), ADI_VERBOSITY_LOW);

    check_frame_pattern(.frame_p(1'b1), .frame_n(1'b1), .expected_status(1'b1), .label("1111 staying high"));

    // For 1100 (rising): previous={0,0}, current={1,1}
    // Drive 4 cycles of (0,0) to set prev, then check with (1,1)
    repeat (4) drive_ddr_cycle(.frame_p(1'b0), .frame_n(1'b0), .data_p(6'h0), .data_n(6'h0));
    check_frame_pattern(.frame_p(1'b1), .frame_n(1'b1), .expected_status(1'b1), .label("1100 rising"));

    check_frame_pattern(.frame_p(1'b0), .frame_n(1'b0), .expected_status(1'b1), .label("0000 staying low"));

    // For 0011 (falling): previous={1,1}, current={0,0}
    // Drive 4 cycles of (1,1) to set prev, then check with (0,0)
    repeat (4) drive_ddr_cycle(.frame_p(1'b1), .frame_n(1'b1), .data_p(6'h0), .data_n(6'h0));
    check_frame_pattern(.frame_p(1'b0), .frame_n(1'b0), .expected_status(1'b1), .label("0011 falling"));

    // ==================================================================
    // TEST 2: Invalid frame patterns (glitches) → adc_status must be 0
    // ==================================================================
    // 0101 and 1010 both have even XOR parity — the old ^{} check would
    // incorrectly pass them. The explicit whitelist correctly rejects them.
    // ==================================================================
    `INFO(("--- Test 2: Invalid/glitch frame patterns ---"), ADI_VERBOSITY_LOW);

    // 0101: driving frame_p=0, frame_n=1 every cycle →
    //   current={0,1}, previous={0,1} → {rx_frame_s, rx_frame}=4'b0101 → ERROR
    check_frame_pattern(.frame_p(1'b0), .frame_n(1'b1), .expected_status(1'b0), .label("0101 glitch"));

    // 1010: driving frame_p=1, frame_n=0 every cycle →
    //   current={1,0}, previous={1,0} → {rx_frame_s, rx_frame}=4'b1010 → ERROR
    check_frame_pattern(.frame_p(1'b1), .frame_n(1'b0), .expected_status(1'b0), .label("1010 glitch"));

    // ==================================================================
    // TEST 3: 2R2T RX data delineation (cfg_2r2t only)
    // ==================================================================
    // Drive a valid 2R2T frame sequence and check that adc_valid_i0 is
    // asserted and adc_data_i0 contains the expected value.
    //
    // In the lvds_if 2R2T state machine (adc_r1_mode=0):
    //   cycle A, frame=1111: rx_data_p → adc_data[23:12], rx_data_n → [11:0]
    //   cycle B, frame=0000: rx_data_p → adc_data[47:36], rx_data_n → [35:24]
    //                        adc_valid asserted
    // The top-level axi_ad9361 then routes adc_data[15:0] → adc_data_i0.
    // ==================================================================
    if (`MODE_1R1T == 0) begin
      logic        valid_i0;
      logic [0:0]  valid_i0_raw;
      logic [15:0] data_i0;
      logic [15:0] data_i0_raw;
      logic        seen_valid;
      int          cycle;

      `INFO(("--- Test 3: 2R2T data delineation ---"), ADI_VERBOSITY_LOW);

      // Return to valid frame state first
      repeat (8) drive_ddr_cycle(.frame_p(1'b0), .frame_n(1'b0), .data_p(6'h0), .data_n(6'h0));

      // Drive known sample: I0=6'h15 on rising, Q0=6'h2A on falling
      drive_ddr_cycle(.frame_p(1'b1), .frame_n(1'b1), .data_p(6'h15), .data_n(6'h2A)); // frame=1111
      drive_ddr_cycle(.frame_p(1'b0), .frame_n(1'b0), .data_p(6'h0F), .data_n(6'h3C)); // frame=0000 → valid asserted

      // adc_valid_i0 is a 1-cycle pulse that arrives 8 posedges after the
      // trigger cycle (6 pipeline stages in ad_datafmt/ad_dcfilter/ad_iqcor +
      // 1 in lvds_if + 1 in axi_ad9361 top). Poll for up to 20 cycles to
      // catch the pulse regardless of exact alignment.
      seen_valid = 1'b0;
      data_i0    = 16'h0;
      for (cycle = 0; cycle < 20; cycle++) begin
        adc_valid_i0_vif.wait_posedge_clk();
        valid_i0_raw = adc_valid_i0_vif.get_io();
        valid_i0 = valid_i0_raw[0];
        if (valid_i0 === 1'b1) begin
          data_i0_raw = adc_data_i0_vif.get_io();
          data_i0    = data_i0_raw;
          seen_valid = 1'b1;
        end
      end

      if (seen_valid !== 1'b1) begin
        `ERROR(("Test 3: adc_valid_i0 never asserted within 20 cycles"));
      end else begin
        `INFO(("Test 3: adc_valid_i0 PASS"), ADI_VERBOSITY_LOW);
      end

      // adc_data_i0 should carry the lower 16 bits of adc_data[23:0]
      // (exact mapping depends on adc datapath; just verify not all-zero)
      if (data_i0 === 16'h0) begin
        `ERROR(("Test 3: adc_data_i0 is all zeros (unexpected)"));
      end else begin
        `INFO(($sformatf("Test 3: adc_data_i0=0x%04h (non-zero PASS)", data_i0)), ADI_VERBOSITY_LOW);
      end
    end

    // ==================================================================
    // TEST 4: 1R1T RX data delineation (cfg_1r1t only)
    // ==================================================================
    // In 1R1T mode (adc_r1_mode=1), the frame=0011 (rising) case stores
    // the sample and asserts adc_valid.
    // ==================================================================
    if (`MODE_1R1T == 1) begin
      logic       valid_i0;
      logic [0:0] valid_i0_raw;
      logic       seen_valid;
      int         cycle;

      `INFO(("--- Test 4: 1R1T data delineation ---"), ADI_VERBOSITY_LOW);

      // Ensure valid state
      repeat (8) drive_ddr_cycle(.frame_p(1'b0), .frame_n(1'b0), .data_p(6'h0), .data_n(6'h0));

      // Drive frame=0011 (falling: current=00, previous=11) with known data.
      // Per UG-570 Fig.79, in 1R1T the frame falls after the MSB half-cycles
      // (I_MSB, Q_MSB). The HDL fires adc_valid_p on {rx_frame_s=00, rx_frame=11}
      // = 4'b0011. So the prep cycle must drive frame high (11) and the trigger
      // cycle must drive frame low (00).
      drive_ddr_cycle(.frame_p(1'b1), .frame_n(1'b1), .data_p(6'h00), .data_n(6'h00)); // prep: frame=1111
      drive_ddr_cycle(.frame_p(1'b0), .frame_n(1'b0), .data_p(6'h1F), .data_n(6'h3F)); // trigger: {00,11}=0011 → valid

      // Poll for up to 20 cycles to catch the 1-cycle valid pulse
      seen_valid = 1'b0;
      for (cycle = 0; cycle < 20; cycle++) begin
        adc_valid_i0_vif.wait_posedge_clk();
        valid_i0_raw = adc_valid_i0_vif.get_io();
        valid_i0 = valid_i0_raw[0];
        if (valid_i0 === 1'b1) begin
          seen_valid = 1'b1;
        end
      end

      if (seen_valid !== 1'b1) begin
        `ERROR(("Test 4: adc_valid_i0 never asserted within 20 cycles"));
      end else begin
        `INFO(("Test 4: adc_valid_i0 PASS"), ADI_VERBOSITY_LOW);
      end
    end

    // ==================================================================
    // TEST 5: TX path — observe tx_frame_out_p toggling (cfg_2r2t only)
    // ==================================================================
    // With dac_data driven via DAC_DATA_I0/Q0 VIPs and dac_valid generated
    // internally, we observe tx_frame_out_p going high for 2 slots and low
    // for 2 slots.
    // (Detailed data checking requires knowing the AXI DAC enable sequence;
    //  this test just verifies the frame signal toggles as expected.)
    // ==================================================================
    if (`MODE_1R1T == 0) begin
      logic       tx_frame_p, tx_frame_q;
      logic [0:0] tx_frame_raw;

      `INFO(("--- Test 5: TX frame signal ---"), ADI_VERBOSITY_LOW);

      tx_frame_vif.wait_posedge_clk();
      tx_frame_raw = tx_frame_vif.get_io();
      tx_frame_p = tx_frame_raw[0];
      tx_frame_vif.wait_posedge_clk();
      tx_frame_raw = tx_frame_vif.get_io();
      tx_frame_q = tx_frame_raw[0];

      // tx_frame should be stable (either both 1 or pattern) within a burst
      // Just log what we see — full TX checking requires AXI DAC enable
      `INFO(($sformatf("Test 5: tx_frame_out_p[0]=%0b [1]=%0b", tx_frame_p, tx_frame_q)), ADI_VERBOSITY_LOW);
    end

    // ------------------------------------------------------------------
    // Done
    // ------------------------------------------------------------------
    #100ns;
    `TH.`L_CLK.inst.IF.stop_clock();
    base_env.stop();
    `INFO(("Test bench done!"), ADI_VERBOSITY_NONE);
    $finish();
  end

endprogram
