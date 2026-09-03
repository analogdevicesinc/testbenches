// SPDX-License-Identifier: BSD-2-Clause-Views
/*
 * Copyright (c) 2026 Analog Devices, Inc. All rights reserved
 */
/*
 * FLAT-AXIS wrappers around the proven segmented generator/checker.
 *
 * WHY THIS FILE EXISTS (increment 1 of the Corundum re-introduction)
 * -----------------------------------------------------------------
 * The MRMAC-only baseline drove mrmac_0's six 64-bit segment pins DIRECTLY from
 * mrmac_seg_pkt_gen and checked them with mrmac_seg_pkt_chk. Increment 1 puts the
 * first two Corundum shim modules back into that path:
 *
 *   pkt_gen -> mrmac_tx_adapt -> glue pack   -> mrmac_0
 *   mrmac_0 -> glue unpack    -> mrmac_rx_adapt -> pkt_chk
 *
 * mrmac_tx_adapt / mrmac_rx_adapt speak a PACKED bus (384b tdata, 66b tkeep_user)
 * on their MRMAC side and a FLAT PLAIN-AXIS bus (384b tdata, 48b tkeep, 1b tuser)
 * on their client side. A block-design net can neither slice nor concatenate a
 * vector, so:
 *   - the adapters' MRMAC side can only reach mrmac_0's per-segment pins THROUGH
 *     mrmac_versal_glue (whose entire reason for existing is that pack/unpack), and
 *   - the adapters' client side needs a producer/consumer with flat plain-AXIS
 *     ports -- which the segmented generator/checker, by design, do not have
 *     (they expose six separate ports precisely to mirror mrmac_0's pins).
 *
 * Hence these two wrappers. They are pure re-slicing: no state, no FSM, no
 * decisions. mrmac_seg_pkt_gen_chk.v is left BYTE-IDENTICAL to the frozen
 * baseline_pass copy and instantiated unchanged, so the stimulus arriving at the
 * MRMAC pins is bit-exact with the passing run and any failure is attributable to
 * the adapters or to the glue's pack/unpack path -- which is the whole point of
 * adding one piece at a time.
 *
 * The wrappers keep the baseline's cell-level port names for clk/rst/enable and
 * the four status outputs, so the block design's TB boundary ports and the test
 * program need no change.
 *
 * ROUND-TRIP FIDELITY, spelled out (this is what makes the increment a clean
 * experiment rather than a rewrite):
 *
 *  TX. The generator emits, per 64-bit word, tkeep_user = {2'b00, ERR, keep[7:0]}
 *      with ERR tied 0 and TSN preempt/resume tied 0. This wrapper forwards
 *      keep[7:0] of each word into the flat tkeep[47:0] and word 0's ERR bit into
 *      tuser. mrmac_tx_adapt then rebuilds exactly {{2'b00}, tlast & tuser, keep}
 *      on word 0 and {3'b000, keep} on words 1..5 -- the identical 66 bits the
 *      generator drove directly in the baseline.
 *
 *  RX. mrmac_rx_adapt collapses the received tkeep_user into a flat tkeep, forcing
 *      all-ones on non-last beats and passing MRMAC's keep pattern through verbatim
 *      on the tlast beat; ERR becomes a single tuser bit. mrmac_seg_pkt_chk only
 *      consults tkeep_user[7:0] and only when rx_axis_tlast is set, so it sees
 *      exactly the same information it saw in the baseline. This wrapper puts tuser
 *      back on word 0 bit 8 for faithfulness even though the checker ignores it.
 */

`timescale 1ns/100ps

// ---------------------------------------------------------------------------
// Generator wrapper: segmented pins in, one flat plain-AXIS master out.
// ---------------------------------------------------------------------------
module mrmac_flat_pkt_gen #(
  parameter NUM_PKTS  = 16,
  parameter PKT_BYTES = 256,
  parameter IFG_BEATS = 4,
  parameter [47:0] DEST_ADDR = 48'h00_0A_35_02_9D_E5,
  parameter [47:0] SRC_ADDR  = 48'h00_0A_35_02_9D_E6,
  parameter [15:0] ETH_TYPE  = 16'h88B5
) (
  input  wire         clk,
  input  wire         rst,          // active-high, sync
  input  wire         enable,

  // Flat AXI4-Stream master -> mrmac_tx_adapt/s_axis_*.
  // Widths are fixed numerals, not expressions: these ports face a block-design
  // net, and the width has to be unambiguous to Vivado's BD elaborator.
  output wire [383:0] m_axis_tdata,
  output wire [47:0]  m_axis_tkeep,
  output wire         m_axis_tvalid,
  input  wire         m_axis_tready,
  output wire         m_axis_tlast,
  output wire [0:0]   m_axis_tuser,   // [0:0], matching mrmac_tx_adapt's USER_WIDTH=1 port

  output wire [31:0]  sent_pkts,
  output wire         done
);

  wire [63:0] d0, d1, d2, d3, d4, d5;
  wire [10:0] k0, k1, k2, k3, k4, k5;

  mrmac_seg_pkt_gen #(
    .NUM_PKTS  (NUM_PKTS),
    .PKT_BYTES (PKT_BYTES),
    .IFG_BEATS (IFG_BEATS),
    .DEST_ADDR (DEST_ADDR),
    .SRC_ADDR  (SRC_ADDR),
    .ETH_TYPE  (ETH_TYPE)
  ) i_gen (
    .clk    (clk),
    .rst    (rst),
    .enable (enable),

    .tx_axis_tdata0 (d0),
    .tx_axis_tdata1 (d1),
    .tx_axis_tdata2 (d2),
    .tx_axis_tdata3 (d3),
    .tx_axis_tdata4 (d4),
    .tx_axis_tdata5 (d5),
    .tx_axis_tkeep_user0 (k0),
    .tx_axis_tkeep_user1 (k1),
    .tx_axis_tkeep_user2 (k2),
    .tx_axis_tkeep_user3 (k3),
    .tx_axis_tkeep_user4 (k4),
    .tx_axis_tkeep_user5 (k5),
    .tx_axis_tvalid (m_axis_tvalid),
    // Back-pressure comes from mrmac_tx_adapt, which passes mrmac_0's
    // tx_axis_tready_0 straight through (via the glue). The generator's stall-hold
    // behaviour is therefore driven by the same signal as in the baseline.
    .tx_axis_tready (m_axis_tready),
    .tx_axis_tlast  (m_axis_tlast),

    .sent_pkts (sent_pkts),
    .done      (done)
  );

  // Word 0 in the low bytes -- the flat AXIS convention both adapters use.
  assign m_axis_tdata = {d5, d4, d3, d2, d1, d0};

  // tkeep_user[7:0] of each word is the per-byte keep; the flat bus carries only
  // those 48 bits.
  assign m_axis_tkeep = {k5[7:0], k4[7:0], k3[7:0], k2[7:0], k1[7:0], k0[7:0]};

  // Packet-level ERR lives on word 0 bit 8 (the generator drives it 0; no error
  // injection in this bench). Forwarded rather than hardwired so that adding error
  // injection to the generator later needs no change here.
  assign m_axis_tuser = k0[8];

endmodule


// ---------------------------------------------------------------------------
// Checker wrapper: one flat plain-AXIS slave in, segmented pins to the checker.
// No tready -- mrmac_rx_adapt has none (MRMAC RX cannot be back-pressured), and
// the checker consumes every beat unconditionally.
// ---------------------------------------------------------------------------
module mrmac_flat_pkt_chk #(
  parameter NUM_PKTS  = 16,
  parameter PKT_BYTES = 256,
  parameter STRIP_FCS = 1,
  parameter [47:0] DEST_ADDR = 48'h00_0A_35_02_9D_E5,
  parameter [47:0] SRC_ADDR  = 48'h00_0A_35_02_9D_E6,
  parameter [15:0] ETH_TYPE  = 16'h88B5
) (
  input  wire         clk,
  input  wire         rst,

  // Flat AXI4-Stream slave <- mrmac_rx_adapt/m_axis_*. tuser is a plain scalar
  // here because mrmac_rx_adapt's m_axis_tuser is declared as one (unlike
  // mrmac_tx_adapt's [USER_WIDTH-1:0] input) -- matching each side exactly keeps
  // the BD nets 1:1 with no width coercion.
  input  wire [383:0] s_axis_tdata,
  input  wire [47:0]  s_axis_tkeep,
  input  wire         s_axis_tvalid,
  input  wire         s_axis_tlast,
  input  wire         s_axis_tuser,

  output wire [31:0]  matched_pkts,
  output wire [31:0]  mismatched_pkts,
  output wire [31:0]  rx_bytes,
  output wire         all_done
);

  mrmac_seg_pkt_chk #(
    .NUM_PKTS  (NUM_PKTS),
    .PKT_BYTES (PKT_BYTES),
    .STRIP_FCS (STRIP_FCS),
    .DEST_ADDR (DEST_ADDR),
    .SRC_ADDR  (SRC_ADDR),
    .ETH_TYPE  (ETH_TYPE)
  ) i_chk (
    .clk (clk),
    .rst (rst),

    .rx_axis_tdata0 (s_axis_tdata[0*64 +: 64]),
    .rx_axis_tdata1 (s_axis_tdata[1*64 +: 64]),
    .rx_axis_tdata2 (s_axis_tdata[2*64 +: 64]),
    .rx_axis_tdata3 (s_axis_tdata[3*64 +: 64]),
    .rx_axis_tdata4 (s_axis_tdata[4*64 +: 64]),
    .rx_axis_tdata5 (s_axis_tdata[5*64 +: 64]),

    // Rebuild the 11-bit-per-word encoding the checker expects: keep in [7:0],
    // ERR on word 0 bit 8 (checker ignores it), TSN preempt/resume 0.
    .rx_axis_tkeep_user0 ({2'b00, s_axis_tuser, s_axis_tkeep[0*8 +: 8]}),
    .rx_axis_tkeep_user1 ({3'b000,              s_axis_tkeep[1*8 +: 8]}),
    .rx_axis_tkeep_user2 ({3'b000,              s_axis_tkeep[2*8 +: 8]}),
    .rx_axis_tkeep_user3 ({3'b000,              s_axis_tkeep[3*8 +: 8]}),
    .rx_axis_tkeep_user4 ({3'b000,              s_axis_tkeep[4*8 +: 8]}),
    .rx_axis_tkeep_user5 ({3'b000,              s_axis_tkeep[5*8 +: 8]}),

    .rx_axis_tvalid (s_axis_tvalid),
    .rx_axis_tlast  (s_axis_tlast),

    .matched_pkts    (matched_pkts),
    .mismatched_pkts (mismatched_pkts),
    .rx_bytes        (rx_bytes),
    .all_done        (all_done)
  );

endmodule
