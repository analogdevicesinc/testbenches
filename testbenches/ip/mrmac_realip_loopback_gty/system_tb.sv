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

// ---------------------------------------------------------------------------
// Milestone-2 REAL-IP MRMAC loopback test bench top.
//
// The fpga_core-facing AXIS datapath + byte scoreboard are wired entirely INSIDE
// the block design (AXI4-Stream master/slave VIPs on mrmac_dut), and the
// flow-control sideband is GND-tied in the BD (M2 does not exercise pause), so
// -- unlike the behavioral mrmac_loopback -- this top has NO fpga_core-side
// boundary ports. What it DOES carry is exactly the M1 gtwiz de-risk boundary:
//
//   * GT serial breakout (gt_txp/txn/rxp/rxn[3:0]) closed in loopback with a
//     PLAIN WIRE ALIAS. This is the crux of the GTM->GTY pivot: the GTY sim model
//     drives REAL data on its boolean p/n pins, so tying gt_txp->gt_rxp /
//     gt_txn->gt_rxn on a shared wire IS the serial line -- no hierarchical
//     *_integer force into the encrypted quad (the GTM p/n floated Z and forced
//     a fragile two-step force that still never locked rx_reset_done);
//   * GT status (rx_reset_done / tx_reset_done / gtpowergood) observed by the
//     test program via hierarchical reference (system_tb.<name>).
//
// The GT reference clock (156.25 MHz diff) and the free-running clock (200 MHz)
// are TB-generated plain always-toggles (NOT clk_vips) -- see their decls below.
// INTF0_rst_all_in is driven INSIDE the BD by a ~gtpowergood inverter (mxfe-exact,
// self-sequences reset off the power-up ramp) -- it is NOT a TB port; see the GT
// reset-all comment below and system_bd.tcl.
// ---------------------------------------------------------------------------

`timescale 1ps/1ps

`include "utils.svh"

module system_tb();

  // ---- GT reference clock, 156.25 MHz differential pair ---------------------
  // Generated here (NOT by a clk_vip): clk_vip_if.set_clk_frq stores the period
  // as an INTEGER number of ns, so 156.25 MHz = 6.4 ns truncates to 6 ns =
  // 166.67 MHz and the GTY PLL mis-locks. At this bench's 1ps timebase a plain
  // always-toggle represents the 3.2 ns (3200 ps) half-period exactly.
  //
  // Half-period in ps, derived from the cfg define so the cfg stays the single
  // source of truth: 1e12 / (2*156_250_000) = 3200 exactly (integer-exact, no
  // rounding). If GT_REFCLK_HZ is ever set to a value that does not divide 1e12
  // evenly this localparam truncates -- fine for the 156.25 MHz plan.

  reg gt_ref_clk = 1'b0;
  always #(3.2ns) gt_ref_clk = ~gt_ref_clk;

  wire gt_ref_clk_p = gt_ref_clk;
  wire gt_ref_clk_n = ~gt_ref_clk;

  // ---- Free-running clock, 100 MHz (5 ns half-period) -----------------------
  // User override 2026-07-28 (was 200 MHz / 2.5 ns). Also a plain always-toggle
  // (no clk_vip) so both GT-side clocks share one idiom. Feeds the GT bring-up FSM
  // (gtwiz_freerun_clk), the clk_wizard input (-> 390.625 MHz AXIS clock), and the
  // reset-gen slowest_sync_clk inside the BD.
  //
  // WARNING - KNOWN RISK, accepted by the user: the encrypted gtwiz reset
  // controller scales its PLL-reset / CDR-timeout counters by a hardcoded
  // P_FREERUN_FREQUENCY = 200 (mrmac_0_gtwiz_versal_reset_ip.v:52), and the proven
  // exdes gtwiz declares APB3_CLK_FREQUENCY = 200 on this same net. A prior 100 MHz
  // attempt made every reset timer count 2x the intended wall-time and gtpowergood
  // never asserted (stuck 0 past 1 ms sim). This 5 ns half-period is kept in
  // lock-step with cfg_1x100g.tcl FREERUN_HZ = 100000000 (the single source of
  // truth) and the clk_wizard PRIM_IN_FREQ / boundary -freq_hz that system_bd.tcl
  // derives from it, so the 390.625/250 MHz MMCM outputs re-solve correctly for a
  // 100 MHz clk_in1. The gtwiz reset-timer skew above is the risk being accepted.
  reg gt_freerun_clk = 1'b0;
  always #(5ns) gt_freerun_clk = ~gt_freerun_clk;

  // ---- GT serial loopback nets (boolean p/n; carry REAL data for GTY) -------
  // On GTY the sim model drives the boolean p/n serial pins with real data, so
  // these shared wires ARE the analog line: gt_txp/txn (O) alias gt_rxp/rxn (I)
  // below, closing the fibre with zero hierarchical force. (Under GTM these pins
  // floated Z and a fragile *_integer force was needed -- gone now, the whole
  // point of the pivot.) Straight p->p / n->n mirrors an external loopback fibre.
  wire [3:0] gt_serial_p;
  wire [3:0] gt_serial_n;

  // ---- GT reset-all --------------------------------------------------------
  // INTF0_rst_all_in is NO LONGER a TB port: it is driven INSIDE the BD by a
  // ~gtpowergood inverter (util_vector_logic), exactly as the proven mxfe
  // reference does (mxfe/system_tb.sv:50 `gt_reset = ~gt_powergood` -> direct
  // wrapper passthrough into INTF0_rst_all_in, no sequencer). See system_bd.tcl
  // "INTF0_rst_all_in = ~gtpowergood" for the full root-cause correction: a
  // fixed-width TB power-on pulse released rst_all before the SIM_SPEEDUP=false
  // GT power-up ramp finished, so gtpowergood stalled. ~gtpowergood self-sequences
  // the release off the power-up ramp and works for both speedup settings and
  // both GT families (the reset idiom is GT-type-agnostic).

  // ---- GT status (observed by the test program) ----------------------------
  wire rx_reset_done;
  wire tx_reset_done;
  wire gtpowergood;

  `TEST_PROGRAM test();

  test_harness `TH (
    // GT reference clock, exact 156.25 MHz diff pair (TB-generated, see above)
    .gt_ref_clk_p (gt_ref_clk_p),
    .gt_ref_clk_n (gt_ref_clk_n),

    // 200 MHz free-running clock (TB-generated, see above)
    .gt_freerun_clk (gt_freerun_clk),

    // serial loop: tx (O) and rx (I) tied to the same wires
    .gt_txp (gt_serial_p),
    .gt_txn (gt_serial_n),
    .gt_rxp (gt_serial_p),
    .gt_rxn (gt_serial_n),

    // (no gt_reset_all port: INTF0_rst_all_in = ~gtpowergood, driven in the BD)

    // status
    .rx_reset_done (rx_reset_done),
    .tx_reset_done (tx_reset_done),
    .gtpowergood   (gtpowergood)
  );

  // ---- GTY serial loopback: PLAIN WIRE ALIAS (no force) ---------------------
  // The GTY sim model drives real data on the boolean gt_txp/txn pins, so the
  // loop is already closed by the port map above (.gt_rxp(gt_serial_p) shares
  // the same wire as .gt_txp(gt_serial_p), likewise n). There is NOTHING to
  // force -- this is the entire reason for the GTM->GTY pivot: GTM's boolean p/n
  // floated Z (data only lived on encrypted *_integer nets, reachable solely via
  // a fragile two-step hierarchical force that still never locked rx_reset_done),
  // whereas GTY carries the line on the public p/n pins the BD already exposes.
  // The user's VCK190/GTY exdes_tb closes the loop the same way (a shared wire
  // across gt_txp_out<->gt_rxp_in). No `GTM_QUAD hierarchical path is referenced.

  // ---- Serial-line activity monitor (READ-ONLY diagnostic) ------------------
  // Counts transitions on the REAL CH0 TX serial pin (gt_serial_p[0]). Purpose:
  // make ONE long run yield a definitive diagnosis of a stuck rx_reset_done --
  // zero transitions => the GT is not driving the line (TX-side reset/config);
  // many transitions while rx_reset_done stays 0 => the line IS toggling and the
  // fault is RX-side config/reset, not the loopback. Purely observational: it
  // reads the boundary wire, drives nothing.
  reg     gt_serial_p0_prev = 1'b0;
  integer serial_edge_cnt   = 0;
  always @(gt_serial_p[0]) begin
    if (gt_serial_p[0] !== gt_serial_p0_prev) begin
      serial_edge_cnt   = serial_edge_cnt + 1;
      gt_serial_p0_prev = gt_serial_p[0];
    end
  end
  // Heartbeat: report the running edge count alongside the GT status every 50 us
  // (aligned with the test_program status heartbeat cadence).
  initial begin
    forever begin
      #(50us);
      $display("[MRMAC realip][SERIAL] t=%0t  CH0 TX edges=%0d  gtpowergood=%b tx_done=%b rx_done=%b",
               $time, serial_edge_cnt, gtpowergood, tx_reset_done, rx_reset_done);
    end
  end

endmodule
