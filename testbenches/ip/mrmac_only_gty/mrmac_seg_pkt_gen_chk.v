// SPDX-License-Identifier: BSD-2-Clause-Views
/*
 * Copyright (c) 2026 Analog Devices, Inc. All rights reserved
 */
/*
 * MRMAC-ONLY segmented traffic generator + checker (1x100G, 6x64 = 384b).
 *
 * PURPOSE / WHY THIS EXISTS
 * -------------------------
 * This pair replaces the ENTIRE Corundum datapath (AXIS VIPs -> cmac_pad ->
 * axis_adapter 512->384 -> mrmac_tx_adapt / mrmac_rx_adapt -> shim FIFOs) with a
 * minimal driver+checker that speaks the MRMAC user interface DIRECTLY, on the
 * SAME per-segment pins the AMD example design drives. It is the traffic source
 * for the MRMAC-only bring-up bench, whose whole point is to reproduce the
 * PASSING AMD example design (mrmac_0_ex) with nothing of ours in the datapath,
 * so a failure can only be the MRMAC/GT/glue plane and not our shim.
 *
 * It plays the role of mrmac_0_prbs_gen_crc_check_async_all in the example
 * design, but is written from scratch rather than copied: that module (plus its
 * 15 support modules, ~9200 lines) is AMD example-design source carrying an
 * explicit "confidential and proprietary ... MUST BE RETAINED" header, and it
 * drags in PRBS/CRC/FIFO/gearbox infrastructure sized for all four ports and
 * every rate. What this bench needs is far smaller: emit N well-formed frames on
 * the six 64-bit segment pins and confirm the same bytes come back.
 *
 * PORT SHAPE: the six segments are exposed as SEPARATE ports (tdata0..5,
 * tkeep_user0..5) rather than one packed 384b/66b bus, deliberately -- that is
 * exactly how mrmac_0 exposes them, so the block design binds them with plain 1:1
 * connect_bd_net calls (a BD net cannot slice a packed vector, which is the very
 * reason mrmac_versal_glue has to exist for the packed shim bus). This bench
 * therefore does NOT use the glue's AXIS pack/unpack path at all, removing it
 * from the suspect list.
 *
 * MRMAC NON-SEGMENTED USER INTERFACE (PG314), per 64-bit segment word:
 *   tx_axis_tdata{0..5}      : segment 0 is transmitted first
 *   tx_axis_tkeep_user{0..5} : 11 bits per segment:
 *        [7:0]  tkeep   - per-byte valid for THAT word (meaningful on the tlast beat)
 *        [8]    ERR     - packet error / bad FCS (packet-level, WORD 0, at tlast)
 *        [9]    Preempt - TSN, driven 0
 *        [10]   Resume  - TSN, driven 0
 *   tx_axis_tvalid / tx_axis_tready / tx_axis_tlast : ordinary AXIS framing;
 *        only the tlast beat may be partial.
 * This encoding is the same source of truth mrmac_tx_adapt.v documents and
 * implements (hdl/library/corundum/versal/mrmac_tx_adapt.v header + its
 * tkeep_user block), so the bus-level contract is identical to the one the real
 * shim drives -- only the PRODUCER of the bytes differs.
 *
 * FRAME FORMAT (Ethernet-plausible, not just a byte ramp -- a real MAC will drop
 * or mis-count an illegal frame):
 *     [0:5]   destination MAC
 *     [6:11]  source MAC
 *     [12:13] EtherType (0x88B5, local-experimental)
 *     [14:..] payload = per-packet-seeded byte ramp
 * No FCS is generated: MRMAC computes and appends it in MAC+PCS mode (which is
 * why the checker's STRIP_FCS controls whether it expects those 4 bytes back).
 *
 * The checker regenerates the expected frame independently and compares per byte
 * lane, so a mismatch localizes to a packet index and byte offset rather than
 * just a counter delta.
 */

`timescale 1ns/100ps

// ---------------------------------------------------------------------------
// Generator: emits NUM_PKTS frames on the MRMAC segmented TX interface.
// ---------------------------------------------------------------------------
module mrmac_seg_pkt_gen #(
  parameter NUM_PKTS  = 16,
  parameter PKT_BYTES = 256,                       // frame length on the wire, no FCS
  parameter IFG_BEATS = 4,                         // idle beats between frames
  parameter [47:0] DEST_ADDR = 48'h00_0A_35_02_9D_E5,
  parameter [47:0] SRC_ADDR  = 48'h00_0A_35_02_9D_E6,
  parameter [15:0] ETH_TYPE  = 16'h88B5
) (
  input  wire        clk,
  input  wire        rst,          // active-high, sync
  input  wire        enable,       // hold high to run (asserted once RX has aligned)

  output wire [63:0] tx_axis_tdata0,
  output wire [63:0] tx_axis_tdata1,
  output wire [63:0] tx_axis_tdata2,
  output wire [63:0] tx_axis_tdata3,
  output wire [63:0] tx_axis_tdata4,
  output wire [63:0] tx_axis_tdata5,
  output wire [10:0] tx_axis_tkeep_user0,
  output wire [10:0] tx_axis_tkeep_user1,
  output wire [10:0] tx_axis_tkeep_user2,
  output wire [10:0] tx_axis_tkeep_user3,
  output wire [10:0] tx_axis_tkeep_user4,
  output wire [10:0] tx_axis_tkeep_user5,
  output reg         tx_axis_tvalid,
  input  wire        tx_axis_tready,
  output reg         tx_axis_tlast,

  output reg  [31:0] sent_pkts,
  output reg         done
);

  localparam SEG_COUNT = 6;
  localparam BUS_BYTES = SEG_COUNT*8;                              // 48 bytes/beat
  localparam BEATS     = (PKT_BYTES + BUS_BYTES - 1) / BUS_BYTES;  // final beat may be partial

  // Packed internal state, fanned out to the per-segment ports below.
  reg [SEG_COUNT*64-1:0] tdata;
  reg [SEG_COUNT*11-1:0] tkeep_user;

  assign tx_axis_tdata0 = tdata[0*64 +: 64];
  assign tx_axis_tdata1 = tdata[1*64 +: 64];
  assign tx_axis_tdata2 = tdata[2*64 +: 64];
  assign tx_axis_tdata3 = tdata[3*64 +: 64];
  assign tx_axis_tdata4 = tdata[4*64 +: 64];
  assign tx_axis_tdata5 = tdata[5*64 +: 64];

  assign tx_axis_tkeep_user0 = tkeep_user[0*11 +: 11];
  assign tx_axis_tkeep_user1 = tkeep_user[1*11 +: 11];
  assign tx_axis_tkeep_user2 = tkeep_user[2*11 +: 11];
  assign tx_axis_tkeep_user3 = tkeep_user[3*11 +: 11];
  assign tx_axis_tkeep_user4 = tkeep_user[4*11 +: 11];
  assign tx_axis_tkeep_user5 = tkeep_user[5*11 +: 11];

  // Byte at absolute offset `off` of packet `pkt`. Header first, then a ramp
  // seeded by the packet index so every frame differs -- a stuck or duplicated
  // frame is then visible, which a constant payload would hide.
  function [7:0] frame_byte;
    input [31:0] pkt;
    input [31:0] off;
    begin
      if      (off < 6)  frame_byte = DEST_ADDR[8*(5  - off) +: 8];
      else if (off < 12) frame_byte = SRC_ADDR [8*(11 - off) +: 8];
      else if (off < 14) frame_byte = ETH_TYPE [8*(13 - off) +: 8];
      else               frame_byte = (off - 14) + pkt*8'h11 + 8'h5A;
    end
  endfunction

  reg [31:0] beat;   // beat index within the current frame
  reg [31:0] gap;    // remaining idle beats before the next frame

  integer w, b;
  reg [31:0] off;
  reg [63:0] word_d;
  reg [7:0]  word_k;

  always @(posedge clk) begin
    if (rst) begin
      tdata          <= {SEG_COUNT*64{1'b0}};
      tkeep_user     <= {SEG_COUNT*11{1'b0}};
      tx_axis_tvalid <= 1'b0;
      tx_axis_tlast  <= 1'b0;
      sent_pkts      <= 32'd0;
      done           <= 1'b0;
      beat           <= 32'd0;
      gap            <= 32'd0;
    end else if (tx_axis_tvalid && !tx_axis_tready) begin
      // Stalled: hold data / keep / valid / last exactly as-is.
    end else if (!enable || done) begin
      tx_axis_tvalid <= 1'b0;
      tx_axis_tlast  <= 1'b0;
    end else if (gap != 0) begin
      // Inter-frame gap: the MAC needs idle cycles between frames.
      tx_axis_tvalid <= 1'b0;
      tx_axis_tlast  <= 1'b0;
      gap            <= gap - 1'b1;
    end else begin
      // Build the next beat.
      for (w = 0; w < SEG_COUNT; w = w + 1) begin
        word_d = 64'd0;
        word_k = 8'd0;
        for (b = 0; b < 8; b = b + 1) begin
          off = beat*BUS_BYTES + w*8 + b;
          if (off < PKT_BYTES) begin
            // Little-endian byte lanes within the 64-bit word (byte 0 = [7:0]),
            // the same flat AXIS convention the shim's adapters use.
            word_d[8*b +: 8] = frame_byte(sent_pkts, off);
            word_k[b]        = 1'b1;
          end
        end
        tdata[w*64 +: 64] <= word_d;
        // [7:0] tkeep, [8] ERR = 0 (no error injection), [10:9] TSN preempt/resume = 0
        tkeep_user[w*11 +: 11] <= {2'b00, 1'b0, word_k};
      end

      tx_axis_tvalid <= 1'b1;
      tx_axis_tlast  <= (beat == BEATS-1);

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
// Checker: byte-exact compare of the received segmented RX stream against the
// same frames the generator above produces.
//
// STRIP_FCS controls whether the trailing 4 FCS bytes are expected in the RX
// byte stream; it must match the CONFIG_RX setting actually written over s_axi.
// Getting it wrong shows up as a LENGTH mismatch on every packet rather than a
// data mismatch -- deliberately easy to tell apart from real corruption.
// ---------------------------------------------------------------------------
module mrmac_seg_pkt_chk #(
  parameter NUM_PKTS  = 16,
  parameter PKT_BYTES = 256,
  parameter STRIP_FCS = 1,                         // 1 = RX stream carries no FCS
  parameter [47:0] DEST_ADDR = 48'h00_0A_35_02_9D_E5,
  parameter [47:0] SRC_ADDR  = 48'h00_0A_35_02_9D_E6,
  parameter [15:0] ETH_TYPE  = 16'h88B5
) (
  input  wire        clk,
  input  wire        rst,

  input  wire [63:0] rx_axis_tdata0,
  input  wire [63:0] rx_axis_tdata1,
  input  wire [63:0] rx_axis_tdata2,
  input  wire [63:0] rx_axis_tdata3,
  input  wire [63:0] rx_axis_tdata4,
  input  wire [63:0] rx_axis_tdata5,
  input  wire [10:0] rx_axis_tkeep_user0,
  input  wire [10:0] rx_axis_tkeep_user1,
  input  wire [10:0] rx_axis_tkeep_user2,
  input  wire [10:0] rx_axis_tkeep_user3,
  input  wire [10:0] rx_axis_tkeep_user4,
  input  wire [10:0] rx_axis_tkeep_user5,
  input  wire        rx_axis_tvalid,
  input  wire        rx_axis_tlast,

  output reg  [31:0] matched_pkts,
  output reg  [31:0] mismatched_pkts,
  output reg  [31:0] rx_bytes,
  output reg         all_done
);

  localparam SEG_COUNT = 6;
  localparam EXP_BYTES = PKT_BYTES + (STRIP_FCS ? 0 : 4);

  wire [SEG_COUNT*64-1:0] tdata = { rx_axis_tdata5, rx_axis_tdata4, rx_axis_tdata3,
                                    rx_axis_tdata2, rx_axis_tdata1, rx_axis_tdata0 };
  wire [SEG_COUNT*11-1:0] tkeep_user = { rx_axis_tkeep_user5, rx_axis_tkeep_user4,
                                         rx_axis_tkeep_user3, rx_axis_tkeep_user2,
                                         rx_axis_tkeep_user1, rx_axis_tkeep_user0 };

  function [7:0] frame_byte;
    input [31:0] pkt;
    input [31:0] off;
    begin
      if      (off < 6)  frame_byte = DEST_ADDR[8*(5  - off) +: 8];
      else if (off < 12) frame_byte = SRC_ADDR [8*(11 - off) +: 8];
      else if (off < 14) frame_byte = ETH_TYPE [8*(13 - off) +: 8];
      else               frame_byte = (off - 14) + pkt*8'h11 + 8'h5A;
    end
  endfunction

  reg [31:0] byte_off;   // byte offset within the frame being received
  reg        pkt_bad;    // sticky per-packet mismatch flag
  reg [31:0] pkt_idx;    // index of the frame being received

  // Diagnostic print budget. Both reports below fire at most once per FRAME, which was
  // 16 lines when NUM_PKTS was 16 but is up to 4096 now -- and a wrong STRIP_FCS makes
  // the LENGTH line fire on every single frame. The first few reports carry all the
  // diagnostic value (first bad byte, offset, expected-vs-got); the rest bury the
  // counters and the verdict. So cap them and say so once. Reporting only -- the
  // matched/mismatched counters below are NOT capped, so the verdict is unaffected.
  localparam MAX_REPORTS = 20;
  integer n_reports = 0;

  // Static (not automatic): it updates the module-level counter, and plain Verilog-2001
  // is what the rest of this file is written in.
  task report_budget;
    begin
      n_reports = n_reports + 1;
      if (n_reports == MAX_REPORTS)
        $display("[MRMAC-ONLY][CHK] ...further per-frame reports suppressed (%0d shown). Counters remain exact.",
                 MAX_REPORTS);
    end
  endtask

  integer w, b;
  reg [31:0] off;
  reg [7:0]  got, exp;
  reg [7:0]  word_k;
  // Byte tally accumulates with a BLOCKING assignment inside the lane loops and is
  // committed to the rx_bytes output once per beat. `rx_bytes <= rx_bytes + 1` inside
  // the loop would be wrong: all 48 nonblocking updates schedule against the SAME
  // pre-beat value, so only the last survives and the counter advances by 1 per beat
  // instead of by the number of valid lanes -- it silently reports BEATS as bytes.
  // (Byte-exactness itself was never affected: the verdict comes from the per-lane
  // compare and from the blocking `off`, which is what the LENGTH check uses. Only the
  // reported byte total was wrong, and this counter is informational.)
  reg [31:0] nbytes;

  always @(posedge clk) begin
    if (rst) begin
      matched_pkts    <= 32'd0;
      mismatched_pkts <= 32'd0;
      rx_bytes        <= 32'd0;
      all_done        <= 1'b0;
      byte_off        <= 32'd0;
      pkt_bad         <= 1'b0;
      pkt_idx         <= 32'd0;
    end else if (rx_axis_tvalid) begin
      off    = byte_off;
      nbytes = 32'd0;
      for (w = 0; w < SEG_COUNT; w = w + 1) begin
        word_k = tkeep_user[w*11 +: 8];
        for (b = 0; b < 8; b = b + 1) begin
          // On non-last beats every byte lane is valid; on the last beat only the
          // lanes tkeep marks. Comparing per-lane (not whole words) is what makes a
          // mismatch report an exact byte offset.
          if (!rx_axis_tlast || word_k[b]) begin
            got = tdata[w*64 + 8*b +: 8];
            // Only the first PKT_BYTES are ours; anything beyond is the FCS the MAC
            // appended (when STRIP_FCS=0) and is not compared byte-wise.
            if (off < PKT_BYTES) begin
              exp = frame_byte(pkt_idx, off);
              if (got !== exp) begin
                if (!pkt_bad) begin
                  if (n_reports < MAX_REPORTS)
                    $display("[MRMAC-ONLY][CHK] MISMATCH pkt=%0d byte=%0d got=0x%02h exp=0x%02h t=%0t",
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
      end
      rx_bytes <= rx_bytes + nbytes;

      if (rx_axis_tlast) begin
        // Length is part of correctness: a frame of the wrong length is a failure
        // even if every compared byte matched.
        if (off !== EXP_BYTES) begin
          if (n_reports < MAX_REPORTS)
            $display("[MRMAC-ONLY][CHK] LENGTH pkt=%0d got=%0d exp=%0d t=%0t",
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
