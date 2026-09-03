// SPDX-License-Identifier: BSD-2-Clause-Views
/*
 * Copyright (c) 2026 Analog Devices, Inc. All rights reserved
 */
/*
 * 512-bit flat-AXIS traffic generator + checker -- increments 3/4/5 of the Corundum
 * re-introduction into the MRMAC-only bench.
 *
 * WHY A NEW 512-BIT PAIR RATHER THAN RE-SLICING THE 384-BIT ONE
 * -------------------------------------------------------------
 * Increments 1 and 2 could re-use the frozen baseline generator/checker verbatim
 * (mrmac_flat_pkt_gen_chk.v is a pure re-slicing shell around mrmac_seg_pkt_gen /
 * mrmac_seg_pkt_chk -- no FSM duplicated). That trick stops working here, and the
 * reason is a HARD ASSERTION in the module increment 4 adds:
 *
 *     cmac_pad.v:  if (DATA_WIDTH != 512) begin $error(...); $finish; end
 *
 * cmac_pad exists only to enforce Ethernet's 60-byte minimum on the 512-bit
 * fpga_core boundary and is written for that width alone. So increment 4 cannot be
 * placed anywhere except at a 512-bit interface, which means increment 3 (the
 * 512<->64<->384 axis_adapter chain that reaches that width) must land WITH it --
 * they are one increment, not two. And once the chain's client end is 512 bits, the
 * bench needs a 512-bit producer and consumer; the baseline pair is 384-bit-native
 * (six 64-bit segments, mirroring mrmac_0's own pins) and cannot be re-sliced up.
 *
 * WHAT IS AND IS NOT DUPLICATED
 * -----------------------------
 * The BYTE CONTRACT is duplicated between the generator and the checker in this file
 * and nowhere else. It is NO LONGER the baseline's contract: the payload was
 * `(off-14) + pkt*8'h11 + 8'h5A` (a single ramp, seeded per packet) to match
 * mrmac_seg_pkt_gen_chk.v:124-133 character-for-character, and is now a PER-LANE
 * UNSEEDED ramp, `(lane+1)*(beat+1)` -- changed so the pattern is readable in the
 * Vivado waveform viewer. See the long note at `frame_byte` for the fan-of-64-ramps
 * shape, the viewer settings, and the one thing this costs (duplicate/stuck frames are
 * caught only by the counters and the length check, not by a byte compare).
 *
 * Consequences worth stating plainly: this file is self-consistent (its generator and
 * checker share the function), but its payload NO LONGER matches the 384-bit segmented
 * pair or the frozen baseline_pass copy, which are unchanged. Beat granularity also
 * differs from those -- 64 bytes per beat instead of 48 -- inherent to moving the
 * client boundary to 512 bits and precisely what the adapter chain exists to reconcile.
 *
 * The generator/checker FSMs are re-derived rather than copied because the beat
 * arithmetic is what changed; they are deliberately written to the same shape
 * (per-byte-lane compare, sticky per-frame bad flag, capped diagnostic budget) so a
 * failure report reads the same as the baseline's.
 *
 * tuser WIDTHS: THE PTP FIELDS ARE REAL HERE
 * ------------------------------------------
 * Increment 5 puts PTP back, so tuser is no longer one error bit:
 *
 *   TX (this generator -> cmac_pad -> adapters -> tx_fifo): 17 bits = {tag[15:0], err}
 *     mrmac_gty_wrapper.v localparam TX_USER_WIDTH = 16 + 1. The wrapper's source is
 *     fpga_core, which puts the 1588 tag there; the tag is split back out at the FIFO
 *     master side and driven into mrmac_versal_glue/shim_tx_ptp_tag_field. This
 *     generator sets tag = the packet index, so the field carries a value that
 *     CHANGES per frame and can be followed through the chain (MRMAC returns it on
 *     tx_ptp_tstamp_tag_out_0, exported to a boundary port by the block design).
 *     err is held 0: no error injection.
 *
 *   RX (rx_64_512 -> this checker): 81 bits = {ptp_ts[79:0], err}
 *     mrmac_gty_wrapper.v localparam RX_USER_WIDTH = PTP_TS_WIDTH + 1. mac_ts_insert
 *     writes the converted MRMAC receive timestamp into bits [80:1] at each SOP. That
 *     stamp is now LATCHED and reported (rx_ptp_ts_first/_last/_nonzero_pkts/
 *     _stuck_pkts) -- see the port comments. It still does not affect the byte-exact
 *     verdict: with a local timebase there is no reference to be accurate against, so
 *     the checks are liveness ones (non-zero, advancing) rather than value ones. The
 *     checker consumes bit 0 (error) and IGNORES the timestamp: this bench proves
 *     byte-exactness and the PTP path's structural integrity, not time accuracy --
 *     there is no reference clock here to compare a timestamp against. Taking the
 *     whole 81-bit bus as ONE port (rather than a 1-bit slice) is forced: a block
 *     design net can neither slice nor concatenate a vector.
 *
 * A NOTE ON WHAT PKT_BYTES=256 DOES AND DOES NOT EXERCISE
 * ------------------------------------------------------
 * 256 bytes is 4 whole 512-bit beats, so on THIS side every beat has tkeep all-ones
 * and cmac_pad is a functional no-op (it only acts below 60 bytes). The partial-beat
 * paths are still exercised, just further down: 256 bytes is 5 whole 384-bit beats
 * plus a 16-byte remainder, so the 64->384 up-converter, the frame FIFO, the shim
 * adapters and MRMAC itself all see a short final beat every frame.
 */

`timescale 1ns/100ps

// ---------------------------------------------------------------------------
// Generator: NUM_PKTS frames on a 512-bit flat AXI-Stream master.
// ---------------------------------------------------------------------------
module mrmac_flat512_pkt_gen #(
  parameter NUM_PKTS  = 16,
  parameter PKT_BYTES = 256,                       // frame length on the wire, no FCS
  parameter IFG_BEATS = 4,                         // idle beats between frames
  parameter [47:0] DEST_ADDR = 48'h00_0A_35_02_9D_E5,
  parameter [47:0] SRC_ADDR  = 48'h00_0A_35_02_9D_E6,
  parameter [15:0] ETH_TYPE  = 16'h88B5
) (
  input  wire         clk,
  input  wire         rst,          // active-high, sync
  input  wire         enable,       // hold high to run (raised once RX has aligned)

  // 512-bit flat AXIS master. Fixed numeral widths: these face block-design nets.
  output reg  [511:0] m_axis_tdata,
  output reg  [63:0]  m_axis_tkeep,
  output reg          m_axis_tvalid,
  input  wire         m_axis_tready,
  output reg          m_axis_tlast,
  output reg  [16:0]  m_axis_tuser,   // {tag[15:0], err}

  output reg  [31:0]  sent_pkts,
  output reg          done
);

  localparam BUS_BYTES = 64;                                       // 512b = 64 bytes
  localparam BEATS     = (PKT_BYTES + BUS_BYTES - 1) / BUS_BYTES;  // final beat may be partial

  // The 14-byte header makes each frame Ethernet-plausible (a real MAC drops or
  // mis-counts an illegal frame). The payload is a GLOBAL MONOTONE RAMP, unseeded:
  //
  //     value = (off - 14) mod 256
  //
  // i.e. the payload counts 0,1,2,...,255,0,1,... in absolute frame byte order.
  //
  // WHY MONOTONE IN `off`. Scoping one byte lane of a W-byte bus samples every W'th
  // byte: lane b at beat k carries f(W*k + b). Monotone f makes that series ascend with
  // constant step W at every lane and every width, so the payload is unambiguous
  // everywhere in the chain. WHAT MONOTONE DOES NOT BUY, because a byte only counts to
  // 255: the per-lane sawtooth PERIOD is 256/W beats, so on a wide bus one lane wraps
  // too fast to read as a ramp. Computed lane-0 series:
  //
  //   512b taps  (W=64,  period 4 beats)   0, 50, 114, 178, 242, 50, ...   coarse
  //   1536b neck (W=192, period 1.3 beats) 0, 178, 114, 50, 242, ...       unreadable
  //   384b bus   (W=48,  period 5.3 beats) 0, 34, 82, 130, 178, 226, ...   coarse
  //   64b segment pin (W=8, period 32)     0, 0, 2, 10, 18, 26, 34, ...    clean ramp
  //
  // So for a VISUAL ramp, watch either the WHOLE tdata word in hex -- bytes ascend
  // across the word, unambiguous at any width -- or one lane of a 64-bit segment pin.
  // A single lane of a wide bus is correct data that renders as a coarse sawtooth.
  //
  // AND WHY PER-LANE AMPLITUDE IS NOT AVAILABLE AT THE SAME TIME. An earlier version of
  // this function used (lane+1)*(beat+1) with lane = off%64, to give 64 copies of one
  // ramp at 64 amplitudes when the 512-bit word is expanded into byte lanes. That is
  // NOT monotone in off -- it sawtooths within each 512-bit beat -- so every narrower
  // tap sampled every 48th byte against a 64-byte-period sawtooth and ALIASED. Measured
  // at the 384-bit segment-0 byte-0 pin: 0,49,66,51,4,196,165,102,7,87,8,153,...
  // which renders as a sinewave, not a ramp. The two goals are mutually exclusive, and
  // provably so: if f is monotone then lane b's per-beat step is W*slope, identical for
  // all b, so the amplitudes cannot differ. Per-lane amplitude only ever renders at the
  // one width it was built for. Readable-everywhere was chosen over the fan.
  //
  // NOT seeded by packet index, on purpose (originally `(off-14) + pkt*8'h11 + 8'h5A`).
  // Every frame carries the identical picture, which is what makes the pattern readable.
  // The cost is real and worth stating: a DUPLICATED or STUCK FRAME is no longer visible
  // in the payload bytes, so it is caught only by the checker's per-frame length check
  // and the matched/mismatched counters, not by a byte compare. A stuck, swapped or
  // mis-rotated BYTE LANE is easier to see than it was, at any width.
  //
  // This function was previously character-identical to mrmac_seg_pkt_gen_chk.v:124-133;
  // it is now deliberately different, and that 384-bit segmented pair is unchanged. Each
  // bench is self-consistent (its own gen paired with its own chk) but their payloads no
  // longer match byte-for-byte.
  function [7:0] frame_byte;
    input [31:0] pkt;    // retained for call-site compatibility; deliberately unused
    input [31:0] off;
    begin
      if      (off < 6)  frame_byte = DEST_ADDR[8*(5  - off) +: 8];
      else if (off < 12) frame_byte = SRC_ADDR [8*(11 - off) +: 8];
      else if (off < 14) frame_byte = ETH_TYPE [8*(13 - off) +: 8];
      else               frame_byte = off - 14;
    end
  endfunction

  reg [31:0] beat;   // beat index within the current frame
  reg [31:0] gap;    // remaining idle beats before the next frame

  integer b;
  reg [31:0] off;

  always @(posedge clk) begin
    if (rst) begin
      m_axis_tdata  <= 512'd0;
      m_axis_tkeep  <= 64'd0;
      m_axis_tvalid <= 1'b0;
      m_axis_tlast  <= 1'b0;
      m_axis_tuser  <= 17'd0;
      sent_pkts     <= 32'd0;
      done          <= 1'b0;
      beat          <= 32'd0;
      gap           <= 32'd0;
    end else if (m_axis_tvalid && !m_axis_tready) begin
      // Stalled: hold data / keep / valid / last / user exactly as-is.
    end else if (!enable || done) begin
      m_axis_tvalid <= 1'b0;
      m_axis_tlast  <= 1'b0;
    end else if (gap != 0) begin
      // Inter-frame gap. Note the chain downstream (see the header) paces this
      // stream far harder than IFG_BEATS does, so the gap is a floor, not the rate.
      m_axis_tvalid <= 1'b0;
      m_axis_tlast  <= 1'b0;
      gap           <= gap - 1'b1;
    end else begin
      for (b = 0; b < BUS_BYTES; b = b + 1) begin
        off = beat*BUS_BYTES + b;
        if (off < PKT_BYTES) begin
          // Little-endian byte lanes (byte 0 = [7:0]), the flat AXIS convention the
          // adapters and cmac_pad both assume.
          m_axis_tdata[8*b +: 8] <= frame_byte(sent_pkts, off);
          m_axis_tkeep[b]        <= 1'b1;
        end else begin
          m_axis_tdata[8*b +: 8] <= 8'd0;
          m_axis_tkeep[b]        <= 1'b0;
        end
      end

      // {tag, err}: tag = packet index so the 1588 tag field carries something that
      // changes per frame and can be followed to MRMAC's tx_ptp_tstamp_tag output.
      m_axis_tuser  <= {sent_pkts[15:0], 1'b0};

      m_axis_tvalid <= 1'b1;
      m_axis_tlast  <= (beat == BEATS-1);

      if (beat == BEATS-1) begin
        beat      <= 32'd0;
        gap       <= IFG_BEATS;
        sent_pkts <= sent_pkts + 1'b1;
        if (sent_pkts + 1 >= NUM_PKTS) done <= 1'b1;
      end else begin
        beat <= beat + 1'b1;
      end
    end
  end

endmodule


// ---------------------------------------------------------------------------
// Checker: byte-exact compare of a 512-bit flat AXIS slave stream against the same
// frames the generator above produces.
//
// STRIP_FCS controls whether the trailing 4 FCS bytes are expected; it must match the
// CONFIG_RX setting written over s_axi. Getting it wrong shows up as a LENGTH
// mismatch on every frame rather than a data mismatch -- easy to tell apart from real
// corruption.
// ---------------------------------------------------------------------------
module mrmac_flat512_pkt_chk #(
  parameter NUM_PKTS  = 16,
  parameter PKT_BYTES = 256,
  parameter STRIP_FCS = 1,                         // 1 = RX stream carries no FCS
  parameter [47:0] DEST_ADDR = 48'h00_0A_35_02_9D_E5,
  parameter [47:0] SRC_ADDR  = 48'h00_0A_35_02_9D_E6,
  parameter [15:0] ETH_TYPE  = 16'h88B5
) (
  input  wire         clk,
  input  wire         rst,

  // 512-bit flat AXIS slave. No tready: the checker consumes every beat, so the
  // 64->512 up-converter ahead of it has its master side tied permanently ready.
  input  wire [511:0] s_axis_tdata,
  input  wire [63:0]  s_axis_tkeep,
  input  wire         s_axis_tvalid,
  input  wire         s_axis_tlast,
  // 81 bits = {ptp_ts[79:0], err}. Taken whole because a BD net cannot slice; only
  // bit 0 is used (see the file header on why the timestamp is not checked).
  input  wire [80:0]  s_axis_tuser,

  output reg  [31:0]  matched_pkts,
  output reg  [31:0]  mismatched_pkts,
  output reg  [31:0]  rx_bytes,
  output reg          all_done,

  // ---- RX PTP observation ---------------------------------------------------
  // The RX timestamp mac_ts_insert wrote into tuser[80:1] at this frame's SOP,
  // latched here so the test program can check the RX PTP path actually produced
  // something. NOT part of the byte-exact verdict -- a local timebase (see
  // mrmac_shim_ptp_timegen) has nothing to be accurate against, so absolute values
  // are meaningless. What IS checkable, and what these expose:
  //   rx_ptp_ts_first / rx_ptp_ts_last : stamps of the first and last frames. If
  //     last > first, MRMAC's captured time ADVANCED across the run -- the timer is
  //     loaded and running, not stuck at 0 or at a constant.
  //   rx_ptp_ts_nonzero_pkts : frames whose stamp was non-zero. Zero here means the
  //     RX capture path is dead (MRMAC never loaded the systemtimer, or the
  //     st_sync handshake never completed) even though the bytes were perfect.
  //   rx_ptp_ts_stuck_pkts : frames whose stamp equalled the previous frame's. A
  //     nonzero-but-frozen timer is the specific failure a plain non-zero check
  //     would pass, so it is counted separately.
  output reg  [79:0]  rx_ptp_ts_first,
  output reg  [79:0]  rx_ptp_ts_last,
  output reg  [31:0]  rx_ptp_ts_nonzero_pkts,
  output reg  [31:0]  rx_ptp_ts_stuck_pkts
);

  localparam BUS_BYTES = 64;
  localparam EXP_BYTES = PKT_BYTES + (STRIP_FCS ? 0 : 4);

  // MUST stay identical to the generator's copy above (see the long note there): the
  // global monotone ramp (off-14) mod 256, which reads as a ramp at every bus width in
  // the chain. pkt is unused -- the payload no longer depends on the frame index, so a
  // duplicated frame is caught by the counters and the length check, not by this compare.
  function [7:0] frame_byte;
    input [31:0] pkt;    // retained for call-site compatibility; deliberately unused
    input [31:0] off;
    begin
      if      (off < 6)  frame_byte = DEST_ADDR[8*(5  - off) +: 8];
      else if (off < 12) frame_byte = SRC_ADDR [8*(11 - off) +: 8];
      else if (off < 14) frame_byte = ETH_TYPE [8*(13 - off) +: 8];
      else               frame_byte = off - 14;
    end
  endfunction

  reg [31:0] byte_off;   // byte offset within the frame being received
  reg        pkt_bad;    // sticky per-packet mismatch flag
  reg [31:0] pkt_idx;    // index of the frame being received

  // Same capped diagnostic budget as the baseline checker: the first few reports carry
  // all the value (first bad byte, offset, expected-vs-got); at NUM_PKTS=4096 the rest
  // would bury the counters and the verdict. Reporting only -- the counters below are
  // NOT capped, so the verdict is unaffected.
  localparam MAX_REPORTS = 20;
  integer n_reports = 0;

  // Static (not automatic): it updates a module-level counter, and this file is plain
  // Verilog-2001 like the rest of the bench's fixtures.
  task report_budget;
    begin
      n_reports = n_reports + 1;
      if (n_reports == MAX_REPORTS)
        $display("[MRMAC-ONLY][CHK512] ...further per-frame reports suppressed (%0d shown). Counters remain exact.",
                 MAX_REPORTS);
    end
  endtask

  integer b;
  reg [31:0] off;
  reg [7:0]  got, exp;
  // Byte tally accumulates with BLOCKING assignment inside the lane loop, then is
  // committed to the rx_bytes output once per beat. Doing `rx_bytes <= rx_bytes + 1`
  // inside the loop would be wrong: all 64 nonblocking updates schedule against the
  // SAME pre-beat value of rx_bytes, so only the last one survives and the counter
  // advances by 1 per beat rather than by the number of valid lanes. (That undercount
  // is cosmetic -- byte-exactness is decided by the per-lane compare and by the
  // blocking `off`, which is what the LENGTH check uses -- but a byte counter that
  // silently reports beats is worse than no counter at all.)
  reg [31:0] nbytes;

  // RX PTP: the stamp is written at SOP, so it must be sampled on the FIRST beat of
  // each frame. Sampling at tlast instead would read whatever tuser holds on the last
  // beat, which mac_ts_insert does not update.
  //
  // SOP is tracked with an explicit flag rather than by testing `byte_off == 0`.
  // byte_off is a running offset maintained for the byte compare and is only cleared
  // in the tlast branch, so keying SOP off it couples this capture to that bookkeeping
  // for no reason. sop_r cannot drift: it means exactly "the previous accepted beat
  // was a tlast", which is the definition of a start-of-packet beat.
  //
  // VERIFIED STANDALONE, not by inspection: driving 4 frames with a stamp that
  // advances 0x1000, 0x1100, 0x1200, 0x1300 gives first=0x1000, last=0x1300,
  // nonzero=4, stuck=0; repeating one frame's stamp raises stuck=1. Note the probe
  // must drive stimulus on the NEGATIVE clock edge -- driving on posedge alongside the
  // DUT races it and makes the capture look broken when it is not.
  reg [79:0] rx_ptp_ts_prev;
  reg        rx_ptp_seen;
  reg        sop_r;

  always @(posedge clk) begin
    if (rst) begin
      matched_pkts    <= 32'd0;
      mismatched_pkts <= 32'd0;
      rx_bytes        <= 32'd0;
      all_done        <= 1'b0;
      byte_off        <= 32'd0;
      pkt_bad         <= 1'b0;
      pkt_idx         <= 32'd0;
      rx_ptp_ts_first        <= 80'd0;
      rx_ptp_ts_last         <= 80'd0;
      rx_ptp_ts_nonzero_pkts <= 32'd0;
      rx_ptp_ts_stuck_pkts   <= 32'd0;
      rx_ptp_ts_prev         <= 80'd0;
      rx_ptp_seen            <= 1'b0;
      sop_r                  <= 1'b1;   // first accepted beat is a SOP
    end else if (s_axis_tvalid) begin
      // Next accepted beat starts a new frame iff this one ends the current frame.
      sop_r <= s_axis_tlast;

      // ---- RX PTP capture, at SOP ----
      if (sop_r) begin
        rx_ptp_ts_last <= s_axis_tuser[80:1];
        if (!rx_ptp_seen) begin
          rx_ptp_ts_first <= s_axis_tuser[80:1];
          rx_ptp_seen     <= 1'b1;
        end else if (s_axis_tuser[80:1] === rx_ptp_ts_prev) begin
          // Same stamp as the previous frame: the timer is not advancing. Frames are
          // separated by IFG_BEATS plus the whole MAC/serdes round trip, far more than
          // one ts_clk tick, so equal stamps mean frozen rather than merely fast.
          rx_ptp_ts_stuck_pkts <= rx_ptp_ts_stuck_pkts + 1'b1;
        end
        if (s_axis_tuser[80:1] !== 80'd0)
          rx_ptp_ts_nonzero_pkts <= rx_ptp_ts_nonzero_pkts + 1'b1;
        rx_ptp_ts_prev <= s_axis_tuser[80:1];
      end

      off    = byte_off;
      nbytes = 32'd0;
      for (b = 0; b < BUS_BYTES; b = b + 1) begin
        // On non-last beats every byte lane is valid; on the last beat only the lanes
        // tkeep marks. Comparing per-lane (not whole words) is what makes a mismatch
        // report an exact byte offset.
        if (!s_axis_tlast || s_axis_tkeep[b]) begin
          got = s_axis_tdata[8*b +: 8];
          // Only the first PKT_BYTES are ours; anything beyond is the FCS the MAC
          // appended (when STRIP_FCS=0) and is not compared byte-wise.
          if (off < PKT_BYTES) begin
            exp = frame_byte(pkt_idx, off);
            if (got !== exp) begin
              if (!pkt_bad) begin
                if (n_reports < MAX_REPORTS)
                  $display("[MRMAC-ONLY][CHK512] MISMATCH pkt=%0d byte=%0d got=0x%02h exp=0x%02h t=%0t",
                           pkt_idx, off, got, exp, $time);
                report_budget;
              end
              pkt_bad = 1'b1;
            end
          end
          off    = off    + 1;
          nbytes = nbytes + 1;
        end
      end
      rx_bytes <= rx_bytes + nbytes;

      // The MAC/FIFO error bit. In the wrapper this is what USER_BAD_FRAME_VALUE/MASK
      // target in the RX FIFO; a frame that reaches here with it set has been flagged
      // bad by MRMAC (bad FCS, truncation) and is a failure even if the bytes matched.
      if (s_axis_tlast && s_axis_tuser[0]) begin
        if (n_reports < MAX_REPORTS)
          $display("[MRMAC-ONLY][CHK512] ERRBIT pkt=%0d tuser[0]=1 (MAC flagged frame bad) t=%0t",
                   pkt_idx, $time);
        report_budget;
        pkt_bad = 1'b1;
      end

      if (s_axis_tlast) begin
        // Length is part of correctness: a frame of the wrong length is a failure even
        // if every compared byte matched.
        if (off !== EXP_BYTES) begin
          if (n_reports < MAX_REPORTS)
            $display("[MRMAC-ONLY][CHK512] LENGTH pkt=%0d got=%0d exp=%0d t=%0t",
                     pkt_idx, off, EXP_BYTES, $time);
          report_budget;
          pkt_bad = 1'b1;
        end
        if (pkt_bad) mismatched_pkts <= mismatched_pkts + 1'b1;
        else         matched_pkts    <= matched_pkts    + 1'b1;
        if (pkt_idx + 1 >= NUM_PKTS) all_done <= 1'b1;
        pkt_idx  <= pkt_idx + 1'b1;
        byte_off <= 32'd0;
        pkt_bad   = 1'b0;
      end else begin
        byte_off <= off;
      end
    end
  end

endmodule
