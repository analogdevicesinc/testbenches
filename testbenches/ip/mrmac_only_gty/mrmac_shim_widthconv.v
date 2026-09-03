// SPDX-License-Identifier: BSD-2-Clause-Views
/*
 * Copyright (c) 2026 Analog Devices, Inc. All rights reserved
 */
/*
 * Thin wrappers around the REAL Corundum cmac_pad and axis_adapter, as instantiated
 * by mrmac_gty_wrapper.v -- increments 3 and 4 of the Corundum re-introduction.
 *
 * WHY 3 AND 4 ARE ONE INCREMENT AND NOT TWO
 * -----------------------------------------
 * cmac_pad.v opens with a hard assertion:
 *
 *     if (DATA_WIDTH != 512) begin $error(...); $finish; end
 *
 * It is the Ethernet 60-byte-minimum padder for the 512-bit fpga_core boundary and is
 * written for that width alone -- mrmac_gty_wrapper.v's own 25G branch omits it with
 * the comment "cmac_pad is 512b-only". So cmac_pad can only be placed at a 512-bit
 * interface, and reaching 512 bits from the MRMAC's 384-bit client bus IS increment 3
 * (this file's four adapters). Splitting them would mean landing a padder with
 * nowhere to sit, or a width-conversion chain whose 512-bit end has no producer.
 * They go in together.
 *
 * WHY WRAPPERS RATHER THAN DIRECT `create_bd_cell -type module -reference`
 * -----------------------------------------------------------------------
 * The same two reasons documented at length in mrmac_shim_fifo.v, which established
 * this idiom in this bench:
 *
 *  1. axis_adapter declares every data/keep/user port width as an EXPRESSION over its
 *     parameters, and derives S_BYTE_LANES / SEG_COUNT / SEG_DATA_WIDTH as body
 *     localparams (including a $clog2). A module-ref cell surfaces parameters as
 *     CONFIG.* properties and lets the BD elaborator infer widths; presenting FIXED
 *     NUMERAL widths at the BD boundary and keeping every derived value inside RTL is
 *     what has worked here (mrmac_flat_pkt_gen_chk.v, then mrmac_shim_fifo.v).
 *
 *  2. axis_adapter has inputs this bench has no producer for (s_axis_tid, s_axis_tdest
 *     -- present as pins even with ID_ENABLE/DEST_ENABLE=0) and outputs with no
 *     consumer (m_axis_tid, m_axis_tdest). The block design's GND sweeps only cover
 *     mrmac_versal_glue, mrmac_0 and gtwiz_versal, so a NEW cell's unused inputs would
 *     float to X in simulation. Tying them here is both less BD plumbing and
 *     impossible to forget.
 *
 * FOUR SEPARATE MODULES RATHER THAN ONE PARAMETERIZED ONE
 * ------------------------------------------------------
 * Point 1 above forbids passing the widths in as CONFIG.*, so each of the wrapper's
 * four axis_adapter instances gets its own module with its numerals baked in. Each
 * maps 1:1 onto a named instance in mrmac_gty_wrapper.v, so the correspondence is
 * checkable by eye:
 *
 *     mrmac_shim_axis_512_1536   <- tx_512_neck_i  (mrmac_gty_wrapper.v)
 *     mrmac_shim_axis_1536_384   <- tx_neck_384_i
 *     mrmac_shim_axis_384_1536   <- rx_384_neck_i
 *     mrmac_shim_axis_1536_512   <- rx_neck_512_i
 *     mrmac_shim_tx_pad        <- cmac_pad_i    (:276)
 *
 * All four ratios are integral (1536/512=3, 1536/384=4), so each instance lands in
 * axis_adapter's `upsize` or `downsize` branch cleanly -- none hits `bypass`.
 *
 * THE NECK MUST BE A COMMON MULTIPLE OF 512 AND 384
 * -------------------------------------------------
 * 512->384 is not an integral ratio, so the conversion cannot be done in one step;
 * the shim goes 512->1536->384 through a 1536-bit "neck" (NECK/NECK_KEEP in the
 * wrapper). That is the wrapper's actual structure and is reproduced exactly, neck
 * bus included, rather than collapsed -- the point of the ladder is that what is
 * under test is the shim as it will ship.
 *
 * These four numerals must be kept in step with the wrapper's NECK parameter, and the
 * value is NOT free: axis_adapter computes SEG_COUNT with a truncating integer divide
 * and never asserts on the S/M ratio, so a non-multiple neck elaborates and passes a
 * byte-exact test while silently wasting a fraction of the bus (measured at 768).
 * lcm(512,384) = 1536 is the only value that clears 100G line rate; gcd = 128 is the
 * only other legal choice and gives half. See the long note at mrmac_gty_wrapper.v
 * g_tx_100g for the measured rate table.
 *
 * tuser WIDTHS
 * ------------
 * TX carries 17 bits {tag[15:0], error} and RX carries 81 bits {ptp_ts[79:0], error}
 * (mrmac_gty_wrapper.v localparams TX_USER_WIDTH / RX_USER_WIDTH). Those are the
 * PTP-carrying widths, which is why increment 5 lands with these: increments 1 and 2
 * ran USER_WIDTH=1 because timestamping was off in the MRMAC IP config, and increment
 * 5 turns it back on. axis_adapter passes tuser through per beat unchanged, so on a
 * downsize every output beat of a frame repeats the frame's tuser -- which is exactly
 * what the wrapper relies on and what the downstream consumers assume.
 */

`timescale 1ns/100ps

// ---------------------------------------------------------------------------
// TX runt padder, 512-bit (cmac_pad's only legal width).
// mrmac_gty_wrapper.v: cmac_pad_i, the first module the fpga_core TX stream meets.
// Here: between pkt_gen512 and the 512->1536 up-converter.
//
// WHAT IT DOES: zeroes data bytes whose tkeep was 0, and forces the low 60 byte lanes
// valid on a frame's FIRST beat, so any frame shorter than Ethernet's 60-byte minimum
// leaves padded to 60. At PKT_BYTES=256 every beat is already full, so it is a
// functional NO-OP here -- deliberately so: this increment proves it is transparent to
// a well-formed stream and does not perturb the byte-exact round trip. Exercising the
// pad itself needs PKT_BYTES < 60, which is a separate experiment.
// ---------------------------------------------------------------------------
module mrmac_shim_tx_pad (
  input  wire         clk,
  input  wire         rst,          // active-high, synchronized by sync_reset

  // Fixed numeral widths: these ports face block-design nets.
  input  wire [511:0] s_axis_tdata,
  input  wire [63:0]  s_axis_tkeep,
  input  wire         s_axis_tvalid,
  output wire         s_axis_tready,
  input  wire         s_axis_tlast,
  input  wire [16:0]  s_axis_tuser,   // {tag[15:0], err}

  output wire [511:0] m_axis_tdata,
  output wire [63:0]  m_axis_tkeep,
  output wire         m_axis_tvalid,
  input  wire         m_axis_tready,
  output wire         m_axis_tlast,
  output wire [16:0]  m_axis_tuser
);

  cmac_pad #(
    .DATA_WIDTH (512),
    .KEEP_WIDTH (64),
    .USER_WIDTH (17)
  ) i_pad (
    .clk (clk),
    .rst (rst),

    .s_axis_tdata  (s_axis_tdata),
    .s_axis_tkeep  (s_axis_tkeep),
    .s_axis_tvalid (s_axis_tvalid),
    .s_axis_tready (s_axis_tready),
    .s_axis_tlast  (s_axis_tlast),
    .s_axis_tuser  (s_axis_tuser),

    .m_axis_tdata  (m_axis_tdata),
    .m_axis_tkeep  (m_axis_tkeep),
    .m_axis_tvalid (m_axis_tvalid),
    .m_axis_tready (m_axis_tready),
    .m_axis_tlast  (m_axis_tlast),
    .m_axis_tuser  (m_axis_tuser)
  );

endmodule


// ---------------------------------------------------------------------------
// TX stage 1: 512 -> 1536 (upsize, SEG_COUNT 3). tuser 17.
// mrmac_gty_wrapper.v: tx_512_neck_i.
// ---------------------------------------------------------------------------
module mrmac_shim_axis_512_1536 (
  input  wire         clk,
  input  wire         rst,

  input  wire [511:0] s_axis_tdata,
  input  wire [63:0]  s_axis_tkeep,
  input  wire         s_axis_tvalid,
  output wire         s_axis_tready,
  input  wire         s_axis_tlast,
  input  wire [16:0]  s_axis_tuser,

  output wire [1535:0] m_axis_tdata,
  output wire [191:0] m_axis_tkeep,
  output wire         m_axis_tvalid,
  input  wire         m_axis_tready,
  output wire         m_axis_tlast,
  output wire [16:0]  m_axis_tuser
);

  axis_adapter #(
    .S_DATA_WIDTH  (512),
    .S_KEEP_ENABLE (1),
    .S_KEEP_WIDTH  (64),
    .M_DATA_WIDTH  (1536),
    .M_KEEP_ENABLE (1),
    .M_KEEP_WIDTH  (192),
    .ID_ENABLE     (0),
    .DEST_ENABLE   (0),
    .USER_ENABLE   (1),
    .USER_WIDTH    (17)
  ) i_adapt (
    .clk (clk),
    .rst (rst),

    .s_axis_tdata  (s_axis_tdata),
    .s_axis_tkeep  (s_axis_tkeep),
    .s_axis_tvalid (s_axis_tvalid),
    .s_axis_tready (s_axis_tready),
    .s_axis_tlast  (s_axis_tlast),
    // ID/DEST are disabled, so these are read only under a dead `if` -- but the input
    // pins exist and would float if left open. Same values the wrapper passes.
    .s_axis_tid    (8'd0),
    .s_axis_tdest  (8'd0),
    .s_axis_tuser  (s_axis_tuser),

    .m_axis_tdata  (m_axis_tdata),
    .m_axis_tkeep  (m_axis_tkeep),
    .m_axis_tvalid (m_axis_tvalid),
    .m_axis_tready (m_axis_tready),
    .m_axis_tlast  (m_axis_tlast),
    .m_axis_tid    (),
    .m_axis_tdest  (),
    .m_axis_tuser  (m_axis_tuser)
  );

endmodule


// ---------------------------------------------------------------------------
// TX stage 2: 1536 -> 384 (downsize, SEG_COUNT 4). tuser 17.
// mrmac_gty_wrapper.v: tx_neck_384_i. Its master side is the TX frame FIFO.
// ---------------------------------------------------------------------------
module mrmac_shim_axis_1536_384 (
  input  wire         clk,
  input  wire         rst,

  input  wire [1535:0] s_axis_tdata,
  input  wire [191:0] s_axis_tkeep,
  input  wire         s_axis_tvalid,
  output wire         s_axis_tready,
  input  wire         s_axis_tlast,
  input  wire [16:0]  s_axis_tuser,

  output wire [383:0] m_axis_tdata,
  output wire [47:0]  m_axis_tkeep,
  output wire         m_axis_tvalid,
  input  wire         m_axis_tready,
  output wire         m_axis_tlast,
  output wire [16:0]  m_axis_tuser
);

  axis_adapter #(
    .S_DATA_WIDTH  (1536),
    .S_KEEP_ENABLE (1),
    .S_KEEP_WIDTH  (192),
    .M_DATA_WIDTH  (384),
    .M_KEEP_ENABLE (1),
    .M_KEEP_WIDTH  (48),
    .ID_ENABLE     (0),
    .DEST_ENABLE   (0),
    .USER_ENABLE   (1),
    .USER_WIDTH    (17)
  ) i_adapt (
    .clk (clk),
    .rst (rst),

    .s_axis_tdata  (s_axis_tdata),
    .s_axis_tkeep  (s_axis_tkeep),
    .s_axis_tvalid (s_axis_tvalid),
    .s_axis_tready (s_axis_tready),
    .s_axis_tlast  (s_axis_tlast),
    .s_axis_tid    (8'd0),
    .s_axis_tdest  (8'd0),
    .s_axis_tuser  (s_axis_tuser),

    .m_axis_tdata  (m_axis_tdata),
    .m_axis_tkeep  (m_axis_tkeep),
    .m_axis_tvalid (m_axis_tvalid),
    .m_axis_tready (m_axis_tready),
    .m_axis_tlast  (m_axis_tlast),
    .m_axis_tid    (),
    .m_axis_tdest  (),
    .m_axis_tuser  (m_axis_tuser)
  );

endmodule


// ---------------------------------------------------------------------------
// RX stage 1: 384 -> 1536 (upsize, SEG_COUNT 4). tuser 81.
// mrmac_gty_wrapper.v: rx_384_neck_i. THIS is the converter the RX frame FIFO exists to
// shock-absorb: it back-pressures, and MRMAC RX cannot be back-pressured. Increment 2
// deliberately put the FIFO in first, tied always-ready, so this converter arrives
// with its absorber already proven not to disturb the byte-exact stream. The FIFO's
// m_axis_tready stops being a constant with this increment.
// ---------------------------------------------------------------------------
module mrmac_shim_axis_384_1536 (
  input  wire         clk,
  input  wire         rst,

  input  wire [383:0] s_axis_tdata,
  input  wire [47:0]  s_axis_tkeep,
  input  wire         s_axis_tvalid,
  output wire         s_axis_tready,
  input  wire         s_axis_tlast,
  input  wire [80:0]  s_axis_tuser,   // {ptp_ts[79:0], err}

  output wire [1535:0] m_axis_tdata,
  output wire [191:0] m_axis_tkeep,
  output wire         m_axis_tvalid,
  input  wire         m_axis_tready,
  output wire         m_axis_tlast,
  output wire [80:0]  m_axis_tuser
);

  axis_adapter #(
    .S_DATA_WIDTH  (384),
    .S_KEEP_ENABLE (1),
    .S_KEEP_WIDTH  (48),
    .M_DATA_WIDTH  (1536),
    .M_KEEP_ENABLE (1),
    .M_KEEP_WIDTH  (192),
    .ID_ENABLE     (0),
    .DEST_ENABLE   (0),
    .USER_ENABLE   (1),
    .USER_WIDTH    (81)
  ) i_adapt (
    .clk (clk),
    .rst (rst),

    .s_axis_tdata  (s_axis_tdata),
    .s_axis_tkeep  (s_axis_tkeep),
    .s_axis_tvalid (s_axis_tvalid),
    .s_axis_tready (s_axis_tready),
    .s_axis_tlast  (s_axis_tlast),
    .s_axis_tid    (8'd0),
    .s_axis_tdest  (8'd0),
    .s_axis_tuser  (s_axis_tuser),

    .m_axis_tdata  (m_axis_tdata),
    .m_axis_tkeep  (m_axis_tkeep),
    .m_axis_tvalid (m_axis_tvalid),
    .m_axis_tready (m_axis_tready),
    .m_axis_tlast  (m_axis_tlast),
    .m_axis_tid    (),
    .m_axis_tdest  (),
    .m_axis_tuser  (m_axis_tuser)
  );

endmodule


// ---------------------------------------------------------------------------
// RX stage 2: 1536 -> 512 (downsize, SEG_COUNT 3). tuser 81.
// mrmac_gty_wrapper.v: rx_neck_512_i, whose master side is fpga_core.
//
// No m_axis_tready PORT: the wrapper ties it to 1'b1 with the comment "fpga_core RX
// has no tready" (mrmac_gty_wrapper.v:659), and this bench's 512-bit checker likewise
// consumes every beat. Tied inside for the same reason the other unused inputs are:
// no BD sweep covers a new cell.
// ---------------------------------------------------------------------------
module mrmac_shim_axis_1536_512 (
  input  wire         clk,
  input  wire         rst,

  input  wire [1535:0] s_axis_tdata,
  input  wire [191:0] s_axis_tkeep,
  input  wire         s_axis_tvalid,
  output wire         s_axis_tready,
  input  wire         s_axis_tlast,
  input  wire [80:0]  s_axis_tuser,

  output wire [511:0] m_axis_tdata,
  output wire [63:0]  m_axis_tkeep,
  output wire         m_axis_tvalid,
  output wire         m_axis_tlast,
  output wire [80:0]  m_axis_tuser
);

  axis_adapter #(
    .S_DATA_WIDTH  (1536),
    .S_KEEP_ENABLE (1),
    .S_KEEP_WIDTH  (192),
    .M_DATA_WIDTH  (512),
    .M_KEEP_ENABLE (1),
    .M_KEEP_WIDTH  (64),
    .ID_ENABLE     (0),
    .DEST_ENABLE   (0),
    .USER_ENABLE   (1),
    .USER_WIDTH    (81)
  ) i_adapt (
    .clk (clk),
    .rst (rst),

    .s_axis_tdata  (s_axis_tdata),
    .s_axis_tkeep  (s_axis_tkeep),
    .s_axis_tvalid (s_axis_tvalid),
    .s_axis_tready (s_axis_tready),
    .s_axis_tlast  (s_axis_tlast),
    .s_axis_tid    (8'd0),
    .s_axis_tdest  (8'd0),
    .s_axis_tuser  (s_axis_tuser),

    .m_axis_tdata  (m_axis_tdata),
    .m_axis_tkeep  (m_axis_tkeep),
    .m_axis_tvalid (m_axis_tvalid),
    .m_axis_tready (1'b1),             // fpga_core / pkt_chk512 is always ready
    .m_axis_tlast  (m_axis_tlast),
    .m_axis_tid    (),
    .m_axis_tdest  (),
    .m_axis_tuser  (m_axis_tuser)
  );

endmodule
