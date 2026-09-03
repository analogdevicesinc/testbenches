// SPDX-License-Identifier: BSD-2-Clause-Views
/*
 * Copyright (c) 2026 Analog Devices, Inc. All rights reserved
 */
/*
 * Thin wrappers for the shim's PTP cells -- increment 5 of the Corundum
 * re-introduction into the MRMAC-only bench.
 *
 * WHAT INCREMENT 5 PUTS BACK (mrmac_gty_wrapper.v instance -> wrapper here)
 * ------------------------------------------------------------------------
 *   mrmac_ptp_ts_cvt  x4    tx_ts_cvt_i (:453), rx_ts_cvt_i (:501),
 *                           tx_time_cvt_i (:700), rx_time_cvt_i (:712)
 *   mrmac_ptp_sync    x2    tx_ptp_sync_i (:722), rx_ptp_sync_i (:734)
 *   mac_ts_insert     x1    rx_ts_insert_i (:524)
 *
 * mrmac_ptp_ts_cvt needs NO wrapper and is instantiated in the block design directly:
 * four ports, no clock, no reset, no body localparam that affects a port width, and
 * every pin has a producer or is deliberately open. That is the same test sync_reset
 * passed in increment 2. mrmac_ptp_sync and mac_ts_insert do need wrappers, for the
 * reasons this bench has already established twice (mrmac_shim_fifo.v,
 * mrmac_shim_widthconv.v): expression-valued port widths, a body localparam with a
 * $clog2, and pins with no producer/consumer that no GND sweep here would cover --
 * the sweeps only touch mrmac_versal_glue, mrmac_0 and gtwiz_versal.
 *
 * THIS INCREMENT REVERSES ONE OF THE FOUR *** EXDES *** DELTAS -- SAY SO PLAINLY
 * -----------------------------------------------------------------------------
 * The baseline PASS was reached with MRMAC timestamping OFF, matching the passing AMD
 * example design:
 *     CONFIG.MAC_PORT0_ENABLE_TIME_STAMPING_C0 {0}     *** EXDES ***
 *     CONFIG.PORT0_1588v2_Operation_MODE_C0 {No operation}  *** EXDES ***
 * With those settings the generated mrmac_0 has NO PTP pins at all -- its only
 * timestamp-related ports are the ts clocks (rx_ts_clk / tx_ts_clk [3:0]). PTP cells
 * therefore cannot be wired to it, so increment 5 must flip both settings back on.
 * That is a REAL divergence from the exdes config the baseline was validated against,
 * not a cosmetic one, and it is the increment most likely to disturb a passing run. If
 * this build regresses and the previous one passed, these two config lines are the
 * first thing to revert.
 *
 * The failure mode if the flip is forgotten is loud, not silent: connect_bd_net on
 * mrmac_0/rx_ptp_tstamp_out_0 errors out because the pin does not exist.
 *
 * WHERE THE CORUNDUM TIME COMES FROM IN THIS BENCH
 * ------------------------------------------------
 * In the shim, tx_ptp_time / rx_ptp_time come from Corundum's ptp_clock inside
 * fpga_core -- the PHC that Corundum owns and that this bench does not have (no
 * fpga_core, no PCIe, no host). So the two DISCIPLINE converters (tx_time_cvt /
 * rx_time_cvt) are driven from a local free-running counter instead: see
 * mrmac_shim_ptp_timegen below.
 *
 * That is a substitution, and it is worth being precise about what it does and does
 * not test. It DOES exercise everything structural: the 80->55 bit format conversion,
 * mrmac_ptp_sync's PG314 st_sync/st_overwrite handshake, the axi_clk -> ts_clk
 * crossing, MRMAC accepting the load, MRMAC returning RX and TX timestamps, and
 * mac_ts_insert threading a stamp through the RX tuser field and the 81-bit-wide FIFO
 * and adapters. It does NOT test time ACCURACY: a locally generated timebase has
 * nothing to be accurate against. This bench's verdict stays byte-exactness; the
 * timestamp values ride along and are not compared (see mrmac_flat512_pkt_gen_chk.v).
 *
 * CLOCKING: WHY ts_clk IS A SEPARATE 250 MHz DOMAIN
 * ------------------------------------------------
 * MRMAC caps its PTP timestamp clock at 50-350 MHz (PG314), so the ts clock CANNOT be
 * the 390.625 MHz AXIS clock. The reference runs it at 250 MHz, and the bench's
 * clk_wizard already generates exactly that on clk_out2 -- kept enabled through
 * increments 1-4 specifically so the MMCM solution matched the sibling's, and unused
 * until now (ts_clk_in was GND'd). Increment 5 is what finally consumes it.
 *
 * mrmac_ptp_sync itself runs in the AXIS domain (like the wrapper, which clocks it
 * from tx_axi_clk / rx_axi_clk), and the crossing into MRMAC's ts_clk domain is safe
 * by construction: the systemtimer bus is held stable for a whole SYNC_CYCLES window
 * and st_sync only TOGGLES once per window, which is PG314's DDR-phase handshake. At
 * SYNC_CYCLES=32 that is 81.9 ns between edges = ~20 ts_clk cycles at 250 MHz, twice
 * the required 10. See mrmac_ptp_sync.v's own header for the full argument.
 */

`timescale 1ns/100ps

// ---------------------------------------------------------------------------
// Local PTP timebase generator -- BENCH FIXTURE, no counterpart in the shim.
//
// Stands in for Corundum's ptp_clock (fpga_core), which does not exist in this bench.
// Emits a monotonically increasing 80-bit value in Corundum's {ns[..], fns[15:0]}
// fixed-point layout, so the downstream mrmac_ptp_ts_cvt sees exactly the format it
// expects and its >> 8 conversion is exercised on real changing data rather than on a
// constant.
//
// The increment per clock is the parameter INC_FNS, in Corundum fractional-ns units
// (LSB = 2^-16 ns). At the 390.625 MHz AXIS clock one period is 2.56 ns =
// 2.56 * 65536 = 167772.16, so INC_FNS defaults to 167772 -- the truncation is a
// ~1 ppm rate error, which is irrelevant here (nothing measures the rate) and keeps
// the value a plain integer.
//
// One counter feeds BOTH the TX and RX discipline paths, as in the shim: Corundum is a
// single PHC and both MRMAC timers are disciplined to that one timebase.
// ---------------------------------------------------------------------------
module mrmac_shim_ptp_timegen #(
  // Corundum fns increment per clk. 2.56 ns at 2^-16 ns/LSB (390.625 MHz).
  parameter INC_FNS = 167772
) (
  input  wire        clk,
  input  wire        rst,

  output reg  [79:0] ptp_time      // Corundum {ns, fns16} fixed-point, wraps
);

  always @(posedge clk) begin
    if (rst) ptp_time <= 80'd0;
    else     ptp_time <= ptp_time + INC_FNS;
  end

endmodule


// ---------------------------------------------------------------------------
// MRMAC PTP system-timer discipline FSM.
// mrmac_gty_wrapper.v: tx_ptp_sync_i / rx_ptp_sync_i (two instances, TX and RX).
//
// Wrapped because every port width is an expression over TS_WIDTH and because CW (the
// counter width) is a body localparam with a $clog2. SYNC_CYCLES stays a CONFIG.*
// parameter: it is an integer that affects no port width, so the BD can carry it (the
// same reason sync_reset's N could).
// ---------------------------------------------------------------------------
module mrmac_shim_ptp_sync #(
  // mrmac_gty_wrapper.v localparam PTP_SYNC_CYCLES = 32. PG314 requires >= 10.
  parameter SYNC_CYCLES = 32
) (
  input  wire        clk,           // AXIS domain, as in the wrapper
  input  wire        rst,           // active-high, from sync_reset

  // Corundum time already in MRMAC {ns,fns8} units (from mrmac_ptp_ts_cvt).
  input  wire [54:0] systemtime_in,

  // To the glue's shim_{tx,rx}_ptp_* inputs -> MRMAC ctl_*_ptp_*.
  output wire [54:0] systemtimer,
  output wire        st_sync,
  output wire        st_overwrite
);

  mrmac_ptp_sync #(
    .TS_WIDTH    (55),
    .SYNC_CYCLES (SYNC_CYCLES)
    // OFFSET_ADJ left at its default 0 -- the wrapper does not set it either
    // (CMAC-faithful: CMAC's own capture pipeline is uncompensated).
  ) i_sync (
    .clk (clk),
    .rst (rst),

    .systemtime_in (systemtime_in),

    .systemtimer   (systemtimer),
    .st_sync       (st_sync),
    .st_overwrite  (st_overwrite)
  );

endmodule


// ---------------------------------------------------------------------------
// RX timestamp insertion into tuser, at NARROW (384b) width.
// mrmac_gty_wrapper.v: rx_ts_insert_i, between mrmac_rx_adapt and the RX frame FIFO.
//
// NOTE THE WIDTH: 384, not 512. The shim stamps on the MRMAC side of the FIFO, BEFORE
// the width up-convert, deliberately -- so the timestamp rides with the frame and
// survives the FIFO's frame drops and the width conversion, rather than being stamped
// at the fpga_core boundary where a dropped frame would take its stamp with it. (CMAC
// stamps at the MAC output because it has no FIFO in between.)
//
// tuser widens here: 1 bit in (the error bit from mrmac_rx_adapt) -> 81 bits out
// ({ptp_ts[79:0], error}). This is the module that makes the RX chain's 81-bit tuser
// necessary, and therefore what forces mrmac_shim_rx_fifo and the two RX adapters to
// USER_WIDTH=81 in this increment.
//
// No s_axis_tready PORT: mac_ts_insert drives s_axis_tready = m_axis_tready, and its
// source (mrmac_rx_adapt) has no tready input at all, so the wrapper leaves it open
// (mrmac_gty_wrapper.v:531) and so does this. m_axis_tready is tied 1 inside for the
// same reason it is in the wrapper: the downstream FIFO is DROP_WHEN_FULL, so its
// s_axis_tready is always high and MRMAC RX beats are never lost to back-pressure.
// ---------------------------------------------------------------------------
module mrmac_shim_ts_insert (
  input  wire         clk,
  input  wire         rst,

  // Converted MRMAC RX timestamp in Corundum 80-bit format (from mrmac_ptp_ts_cvt).
  input  wire [79:0]  ptp_ts,

  input  wire [383:0] s_axis_tdata,
  input  wire [47:0]  s_axis_tkeep,
  input  wire         s_axis_tvalid,
  input  wire         s_axis_tlast,
  input  wire         s_axis_tuser,   // ERR only

  output wire [383:0] m_axis_tdata,
  output wire [47:0]  m_axis_tkeep,
  output wire         m_axis_tvalid,
  output wire         m_axis_tlast,
  output wire [80:0]  m_axis_tuser    // {ptp_ts[79:0], err}
);

  mac_ts_insert #(
    .PTP_TS_WIDTH (80),
    .DATA_WIDTH   (384),
    .KEEP_WIDTH   (48),
    .S_USER_WIDTH (1),
    .M_USER_WIDTH (81)
  ) i_ins (
    .clk (clk),
    .rst (rst),

    .ptp_ts (ptp_ts),

    .s_axis_tdata  (s_axis_tdata),
    .s_axis_tkeep  (s_axis_tkeep),
    .s_axis_tvalid (s_axis_tvalid),
    .s_axis_tready (),                // valid-only source; ready == m_axis_tready
    .s_axis_tlast  (s_axis_tlast),
    .s_axis_tuser  (s_axis_tuser),

    .m_axis_tdata  (m_axis_tdata),
    .m_axis_tkeep  (m_axis_tkeep),
    .m_axis_tvalid (m_axis_tvalid),
    .m_axis_tready (1'b1),            // FIFO (DROP_WHEN_FULL) is always ready
    .m_axis_tlast  (m_axis_tlast),
    .m_axis_tuser  (m_axis_tuser)
  );

endmodule
