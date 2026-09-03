// SPDX-License-Identifier: BSD-2-Clause-Views
/*
 * Copyright (c) 2026 Analog Devices, Inc. All rights reserved
 */
/*
 * Thin wrappers around the REAL Corundum axis_fifo, as instantiated by
 * mrmac_gty_wrapper.v -- increment 2 of the Corundum re-introduction.
 *
 * WHY WRAPPERS RATHER THAN A DIRECT `create_bd_cell -type module -reference axis_fifo`
 * ------------------------------------------------------------------------------------
 * Two reasons, both about the block-design elaborator rather than about the FIFO:
 *
 *  1. axis_fifo declares port widths as EXPRESSIONS over its parameters, including
 *     `output wire [$clog2(DEPTH):0] status_depth` and the KEEP/USER buses. It also
 *     declares ADDR_WIDTH / OUTPUT_FIFO_ADDR_WIDTH as BODY parameters (axis_fifo.v:137,
 *     139) derived from DEPTH/KEEP_WIDTH. A module-ref cell exposes parameters as
 *     CONFIG.* properties, and the safe thing -- established in this bench already by
 *     mrmac_flat_pkt_gen_chk.v -- is to present the BD with FIXED NUMERAL widths and
 *     keep every derived parameter inside RTL where the Verilog elaborator computes it.
 *
 *  2. axis_fifo has inputs this bench has no producer for (s_axis_tid, s_axis_tdest,
 *     pause_req) and outputs it has no consumer for (status_depth*, status_bad_frame,
 *     status_good_frame). The block design's GND sweeps only cover mrmac_versal_glue,
 *     mrmac_0 and gtwiz_versal, so a new cell's unused inputs would FLOAT (X in sim).
 *     Tying them here is both less BD plumbing and impossible to forget.
 *
 * The axis_fifo instances themselves are the unmodified library module with the exact
 * parameter sets mrmac_gty_wrapper.v uses (mrmac_gty_wrapper.v:384-411 for TX,
 * :554-583 for RX), so a failure implicates the real FIFO, which is the point of
 * adding one piece at a time.
 *
 * USER_WIDTH: NOW THE WRAPPER'S OWN WIDTHS (changed by increment 5)
 * ----------------------------------------------------------------
 * These FIFOs ran at USER_WIDTH=1 through increments 1-4. That was not a simplification
 * for its own sake: MRMAC timestamping was switched OFF in the IP config to match the
 * passing exdes (MAC_PORT0_ENABLE_TIME_STAMPING_C0 {0}), so there was no PTP tag to
 * carry on TX and no receive timestamp on RX, and fabricating 16 or 80 dead bits would
 * only have invented a discrepancy to debug later.
 *
 * Increment 5 turns timestamping back on, so the widths are now the wrapper's:
 * TX_USER_WIDTH=17 = {tag[15:0], error} and RX_USER_WIDTH=81 = {ptp_ts[79:0], error}
 * (mrmac_gty_wrapper.v:206-207). The error bit stays at tuser[0] in both, which is what
 * keeps the RX FIFO's USER_BAD_FRAME_VALUE/MASK correct unchanged: 1'b1 zero-extends to
 * 81 bits, so the mask still selects bit 0 alone -- exactly as in the wrapper.
 *
 * ONE STRUCTURAL CONSEQUENCE, on TX. mrmac_tx_adapt takes only the ERROR bit
 * (parameter USER_WIDTH = 1; it reads s_axis_tuser[0] and nothing else), while the
 * 16-bit tag goes to a different destination entirely -- mrmac_versal_glue's
 * shim_tx_ptp_tag_field. The wrapper splits them with two plain assigns. A block-design
 * net cannot slice a vector, so the split has to happen inside RTL: the TX wrapper below
 * exposes the master-side tuser as TWO ports, m_axis_tuser_err and m_axis_tuser_tag.
 * That is the same constraint that forced mrmac_versal_glue to exist at all.
 *
 * WHAT THE FIFOS CHANGE ABOUT THE TRAFFIC (both are benign, but neither is a no-op)
 * --------------------------------------------------------------------------------
 *  TX is STORE-AND-FORWARD (FRAME_FIFO=1): m_axis_tvalid does not rise until a whole
 *  frame is committed, and does not fall inside a frame. It removes the generator's
 *  mid-frame stalls, which is strictly better for the MAC. It can also ABSORB the
 *  generator's IFG_BEATS idle gap: MEASURED standalone, the FIFO's master side shows
 *  gap=4 idle beats between frames when the sink is always ready (the generator's gap
 *  passes straight through), but gap=0 -- frames strictly back-to-back -- for every
 *  frame that had queued up while the sink was stalled.
 *
 *  That is self-limiting, and worth spelling out because it looks like a risk and is
 *  not one: the FIFO can only accumulate frames while m_axis_tready is LOW, i.e. while
 *  MRMAC is de-asserting tx_axis_tready_0. So the only way to get a zero-gap burst is
 *  for the MAC to have been pacing the stream itself, and a MAC that paces the stream
 *  is a MAC managing its own inter-packet gap. If instead MRMAC holds tready high
 *  throughout -- as it may well do at this frame rate -- the FIFO never accumulates
 *  and the generator's 4-beat gap arrives unmodified. Either way the MAC gets an IPG
 *  it is satisfied with. The back-pressure path itself is real and unchanged:
 *  mrmac_0 -> glue -> mrmac_tx_adapt -> here -> pkt_gen.
 *
 *  RX is a DROPPING frame FIFO (DROP_OVERSIZE_FRAME=1, DROP_WHEN_FULL=1) because MRMAC
 *  RX cannot be back-pressured. It can therefore silently swallow whole frames, which
 *  in this bench would surface only as a low matched_pkts count with no mismatch. To
 *  keep that from looking like a link fault, status_overflow is reported by $display
 *  right here rather than being left to inference. (Routing it to a TB boundary port
 *  would mean touching system_tb.sv, which is byte-identical to the frozen baseline.)
 */

`timescale 1ns/100ps

// ---------------------------------------------------------------------------
// TX store-and-forward frame FIFO, NARROW (384b) width.
// mrmac_gty_wrapper.v: tx_frame_fifo_i, between the pad/width-convert chain and
// mrmac_tx_adapt. Here: between pkt_gen and mrmac_tx_adapt.
// ---------------------------------------------------------------------------
module mrmac_shim_tx_fifo #(
  // mrmac_gty_wrapper.v localparam TX_FIFO_DEPTH = 16384.
  // ADDR_WIDTH inside axis_fifo works out to $clog2(16384/48) = 9, i.e. 512 beats
  // of 48 bytes = 24576 bytes of storage -- 96 of this bench's 256-byte frames, so at
  // NUM_PKTS=4096 the ring wraps ~72 times rather than never filling.
  parameter DEPTH = 16384
) (
  input  wire         clk,
  input  wire         rst,          // active-high, synchronized by sync_reset

  // Widths are fixed numerals, not expressions: these ports face block-design nets.
  input  wire [383:0] s_axis_tdata,
  input  wire [47:0]  s_axis_tkeep,
  input  wire         s_axis_tvalid,
  output wire         s_axis_tready,
  input  wire         s_axis_tlast,
  input  wire [16:0]  s_axis_tuser,     // {tag[15:0], err}, whole -- a BD net cannot concat

  output wire [383:0] m_axis_tdata,
  output wire [47:0]  m_axis_tkeep,
  output wire         m_axis_tvalid,
  input  wire         m_axis_tready,
  output wire         m_axis_tlast,
  // Master side is SPLIT because its two halves have different destinations:
  //   err -> mrmac_tx_adapt/s_axis_tuser        (its USER_WIDTH is 1)
  //   tag -> mrmac_versal_glue/shim_tx_ptp_tag_field
  // mrmac_gty_wrapper.v does this with two assigns off tx_n_tuser (:451 and :456);
  // here it must be RTL because a BD net cannot slice.
  output wire         m_axis_tuser_err,
  output wire [15:0]  m_axis_tuser_tag
);

  wire [16:0] m_axis_tuser;
  assign m_axis_tuser_err = m_axis_tuser[0];
  assign m_axis_tuser_tag = m_axis_tuser[16:1];

  wire status_overflow;
  wire status_bad_frame;
  wire status_good_frame;

  axis_fifo #(
    .DEPTH               (DEPTH),
    .DATA_WIDTH          (384),
    .KEEP_ENABLE         (1),
    .KEEP_WIDTH          (48),
    .LAST_ENABLE         (1),
    .USER_ENABLE         (1),
    .USER_WIDTH          (17),         // {tag[15:0], err}, same as the wrapper
    .FRAME_FIFO          (1),
    .DROP_OVERSIZE_FRAME (0),
    .DROP_BAD_FRAME      (0),
    .DROP_WHEN_FULL      (0)
  ) i_fifo (
    .clk (clk),
    .rst (rst),

    .s_axis_tdata  (s_axis_tdata),
    .s_axis_tkeep  (s_axis_tkeep),
    .s_axis_tvalid (s_axis_tvalid),
    .s_axis_tready (s_axis_tready),
    .s_axis_tlast  (s_axis_tlast),
    // ID/DEST are disabled (ID_ENABLE/DEST_ENABLE default 0), so these are read only
    // under a dead `if` -- but the input pins exist and would float if left open.
    .s_axis_tid    (8'h00),
    .s_axis_tdest  (8'h00),
    .s_axis_tuser  (s_axis_tuser),

    .m_axis_tdata  (m_axis_tdata),
    .m_axis_tkeep  (m_axis_tkeep),
    .m_axis_tvalid (m_axis_tvalid),
    .m_axis_tready (m_axis_tready),
    .m_axis_tlast  (m_axis_tlast),
    .m_axis_tid    (),
    .m_axis_tdest  (),
    .m_axis_tuser  (m_axis_tuser),

    // PAUSE_ENABLE defaults to 0, so pause_req is unused logic -- still an input pin.
    .pause_req     (1'b0),
    .pause_ack     (),

    .status_depth        (),
    .status_depth_commit (),
    .status_overflow     (status_overflow),
    .status_bad_frame    (status_bad_frame),
    .status_good_frame   (status_good_frame)
  );

  // With DROP_WHEN_FULL=0 and DROP_OVERSIZE_FRAME=0 the TX FIFO back-pressures instead
  // of dropping, so overflow here would mean a frame larger than the FIFO -- impossible
  // at PKT_BYTES=256. Reported anyway: if it ever fires, the traffic shape changed and
  // that is worth knowing before chasing the link.
  //
  // Capped: status_overflow pulses once per event, and at NUM_PKTS=4096 a systematic
  // fault would print thousands of identical lines and bury the verdict. First 10
  // individually, then a running total every 100 -- so the log stays bounded but the
  // magnitude is always visible. (A running total rather than a `final` block: this is
  // a .v file compiled as plain Verilog, where `final` is not available.)
  integer tx_ovf_cnt = 0;
  always @(posedge clk) begin
    if (!rst && status_overflow) begin
      tx_ovf_cnt = tx_ovf_cnt + 1;
      if (tx_ovf_cnt <= 10)
        $display("[MRMAC-ONLY][TXFIFO] OVERFLOW (frame exceeds FIFO depth) t=%0t", $time);
      else if (tx_ovf_cnt == 11)
        $display("[MRMAC-ONLY][TXFIFO] ...individual overflow lines suppressed; totals every 100 follow.");
      else if ((tx_ovf_cnt % 100) == 0)
        $display("[MRMAC-ONLY][TXFIFO] OVERFLOWS so far = %0d t=%0t", tx_ovf_cnt, $time);
    end
  end

endmodule


// ---------------------------------------------------------------------------
// RX elastic frame FIFO, NARROW (384b) width.
// mrmac_gty_wrapper.v: rx_fifo_i, absorbing the valid-only MRMAC RX stream ahead of
// the back-pressuring width down-convert. Its source is mac_ts_insert (increment 5),
// which is what widens tuser from the rx_adapt error bit to the full 81 bits.
// ---------------------------------------------------------------------------
module mrmac_shim_rx_fifo #(
  // mrmac_gty_wrapper.v localparam RX_FIFO_DEPTH = 4096.
  // ADDR_WIDTH works out to $clog2(4096/48) = 7, i.e. 128 beats x 48 bytes = 6144
  // bytes -- 24 frames at PKT_BYTES=256.
  parameter DEPTH = 4096
) (
  input  wire         clk,
  input  wire         rst,

  // No s_axis_tready port: the source (mac_ts_insert, whose own s_axis_tready is open
  // because MRMAC RX is valid-only) cannot be back-pressured, exactly as the wrapper
  // leaves .s_axis_tready() open.
  input  wire [383:0] s_axis_tdata,
  input  wire [47:0]  s_axis_tkeep,
  input  wire         s_axis_tvalid,
  input  wire         s_axis_tlast,
  input  wire [80:0]  s_axis_tuser,     // {ptp_ts[79:0], err}

  // m_axis_tready IS a port now. Through increments 1-4 the FIFO's master side was tied
  // permanently ready because pkt_chk consumed every beat, which meant the FIFO could
  // never actually fill. Increment 3 puts the back-pressuring 384->64 down-converter
  // here instead, so the FIFO finally does the job it exists for -- absorbing the
  // valid-only MRMAC RX stream against a sink that stalls. This is the increment where
  // DROP_WHEN_FULL stops being unreachable, which is why the overflow report below
  // matters more from here on.
  output wire [383:0] m_axis_tdata,
  output wire [47:0]  m_axis_tkeep,
  output wire         m_axis_tvalid,
  input  wire         m_axis_tready,
  output wire         m_axis_tlast,
  output wire [80:0]  m_axis_tuser
);

  wire status_overflow;
  wire status_bad_frame;
  wire status_good_frame;

  axis_fifo #(
    .DEPTH                (DEPTH),
    .DATA_WIDTH           (384),
    .KEEP_ENABLE          (1),
    .KEEP_WIDTH           (48),
    .LAST_ENABLE          (1),
    .USER_ENABLE          (1),
    .USER_WIDTH           (81),        // {ptp_ts[79:0], err}, same as the wrapper
    .FRAME_FIFO           (1),
    .DROP_OVERSIZE_FRAME  (1),
    .DROP_WHEN_FULL       (1),
    .DROP_BAD_FRAME       (0),
    // 1'b1 zero-extends to 81 bits, so the mask selects tuser[0] -- the error bit -- and
    // nothing else, leaving the PTP timestamp in [80:1] out of the comparison. Same
    // literals as the wrapper, and correct for the same reason.
    .USER_BAD_FRAME_VALUE (1'b1),
    .USER_BAD_FRAME_MASK  (1'b1)
  ) i_fifo (
    .clk (clk),
    .rst (rst),

    .s_axis_tdata  (s_axis_tdata),
    .s_axis_tkeep  (s_axis_tkeep),
    .s_axis_tvalid (s_axis_tvalid),
    .s_axis_tready (),                 // valid-only source
    .s_axis_tlast  (s_axis_tlast),
    .s_axis_tid    (8'h00),
    .s_axis_tdest  (8'h00),
    .s_axis_tuser  (s_axis_tuser),

    .m_axis_tdata  (m_axis_tdata),
    .m_axis_tkeep  (m_axis_tkeep),
    .m_axis_tvalid (m_axis_tvalid),
    .m_axis_tready (m_axis_tready),    // the 384->64 down-converter; it DOES stall
    .m_axis_tlast  (m_axis_tlast),
    .m_axis_tid    (),
    .m_axis_tdest  (),
    .m_axis_tuser  (m_axis_tuser),

    .pause_req     (1'b0),
    .pause_ack     (),

    .status_depth        (),
    .status_depth_commit (),
    .status_overflow     (status_overflow),
    .status_bad_frame    (status_bad_frame),
    .status_good_frame   (status_good_frame)
  );

  // DROP_WHEN_FULL=1 means an overrun costs a WHOLE FRAME, silently. That would show up
  // downstream only as matched_pkts short of NUM_PKTS with mismatched_pkts still 0 --
  // indistinguishable, from the verdict alone, from frames never arriving at all. So say
  // so here.
  //
  // Increment 3 makes this reachable for the first time (m_axis_tready is now the
  // down-converter's, not a constant 1), so read a hit as a real capacity question:
  // 4096 bytes of FIFO is 24 frames at PKT_BYTES=256, against a sink that consumes 64
  // bytes per beat where the source delivers 48 -- so the sink is faster on average and
  // steady-state overflow should not occur. A burst of drops would point at the
  // converter stalling longer than 24 frames, not at a link fault.
  //
  // The COUNT is the number that matters here, more than for TX: it should exactly
  // account for the shortfall in matched_pkts, which is what distinguishes "the FIFO
  // dropped them" from "they never arrived". Same bounded-log scheme as TX above.
  integer rx_ovf_cnt = 0;
  always @(posedge clk) begin
    if (!rst && status_overflow) begin
      rx_ovf_cnt = rx_ovf_cnt + 1;
      if (rx_ovf_cnt <= 10)
        $display("[MRMAC-ONLY][RXFIFO] OVERFLOW -- whole frame DROPPED t=%0t", $time);
      else if (rx_ovf_cnt == 11)
        $display("[MRMAC-ONLY][RXFIFO] ...individual drop lines suppressed; totals every 100 follow.");
      else if ((rx_ovf_cnt % 100) == 0)
        $display("[MRMAC-ONLY][RXFIFO] FRAMES DROPPED so far = %0d t=%0t", rx_ovf_cnt, $time);
    end
  end

endmodule
