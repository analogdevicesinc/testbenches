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
// MRMAC-ONLY 1x100G loopback test bench top (VCK190 / GTY).
//
// This is the exdes test bench's role, expressed in the ADI framework: it owns the
// two GT clocks, the board reset, the s_axi register wires and the register access
// tasks, and it closes the GT serial loop. The test program drives the SEQUENCE;
// this module owns the SIGNALS.
//
// Differences from the sibling mrmac_realip_loopback_gty/system_tb.sv, all of them
// consequences of stripping the harness and the datapath:
//   * s_axi is driven from PLAIN REGS here, with exdes-verbatim axi_write/axi_read
//     tasks -- no management VIP, no AXI interconnect, no address decode. In the
//     sibling every register access crossed ad_cpu_interconnect into the framework
//     mng VIP, which is exactly where reads were seen returning rresp=SLVERR and
//     zero payload while the MRMAC's own pins carried the right value. That entire
//     path is gone, so a wrong register value here can only be the MRMAC's answer.
//   * pl_resetn is a plain TB reg, so the reset is driven directly
//     (pl_resetn=0 -> 400 clks -> pl_resetn=1) instead of through a proc_sys_reset
//     pulse. The test program does this ONCE at power-up (step 0). The exdes's
//     SECOND reset after GT lock (the "double reset") is deliberately not
//     reproduced -- see the note at step 3./4. in tests/test_program.sv.
//   * no base harness (CUSTOM_HARNESS=1): no sys/dma/ddr clk_vips, no mng/ddr AXI
//     VIPs, no watchdog. The library still COMPILES test_harness_env/watchdog
//     (sp_include_common.tcl sources them unconditionally); nothing instantiates
//     them.
//   * no AXIS VIPs and no scoreboard: traffic comes from mrmac_seg_pkt_gen inside
//     the BD and is checked by mrmac_seg_pkt_chk, also inside the BD.
//
// UNCHANGED from the sibling (deliberately -- these are the validated parts):
//   * both GT clocks are plain always-toggles, NOT clk_vips (clk_vip_if.set_clk_frq
//     stores an INTEGER-ns period, so 156.25 MHz = 6.4 ns truncates to 6 ns =
//     166.67 MHz and the GTY PLL mis-locks);
//   * the GT serial loop is a PLAIN WIRE ALIAS. This is the crux of the GTM->GTY
//     pivot: the GTY sim model drives REAL data on its boolean p/n pins, so tying
//     gt_txp->gt_rxp / gt_txn->gt_rxn on a shared wire IS the serial line. No
//     hierarchical *_integer force into the encrypted quad.
// ---------------------------------------------------------------------------

`timescale 1ps/1ps

`include "utils.svh"

module system_tb();

  // ---- GT reference clock, 156.25 MHz differential pair ---------------------
  // 3.2 ns (3200 ps) half-period, exact at this 1ps timebase. Generated here and
  // not by a clk_vip for the integer-ns truncation reason in the header.
  reg gt_ref_clk = 1'b0;
  always #(3.2ns) gt_ref_clk = ~gt_ref_clk;

  wire gt_ref_clk_p = gt_ref_clk;
  wire gt_ref_clk_n = ~gt_ref_clk;

  // ---- Free-running clock, 100 MHz (5 ns half-period) -----------------------
  // Feeds the GT bring-up FSM (gtwiz_freerun_clk), the clk_wizard input
  // (-> 390.625 MHz AXIS client clock), and MRMAC s_axi_aclk.
  //
  // 100 MHz MATCHES the PASSING reference: the exdes drives
  // .gtwiz_freerun_clk(s_axi_aclk) (exdes.sv:1319) and its tb generates pl_clk with
  // `forever #5000.00` at a 1ps timebase (exdes_tb.v:548-550) = 10 ns = 100 MHz,
  // while its gtwiz .xci still declares APB3_CLK_FREQUENCY=200. So the encrypted
  // reset controller's P_FREERUN_FREQUENCY=200 assumption is NOT fatal at 100 MHz --
  // the reference reaches full PASS this way, which retires the earlier "200 MHz is
  // required for gtpowergood" theory. Kept in lock-step with cfg FREERUN_HZ (the
  // single source of truth, which also sets clk_wizard PRIM_IN_FREQ).
  reg gt_freerun_clk = 1'b0;
  always #(5ns) gt_freerun_clk = ~gt_freerun_clk;

  // s_axi runs on the freerun clock (as in the exdes, where pl_clk IS s_axi_aclk),
  // so one period constant serves both the register tasks and the "repeat(400)
  // @(posedge pl_clk)" style settling waits.
  localparam PCLK_PERIOD = 10ns;

  // ---- Board reset, active-low (the exdes's pl_resetn) ----------------------
  // Initialized DEASSERTED (1'b1) as the exdes does (exdes_tb.v:344). The test
  // program is therefore responsible for the power-on assert/release: it does that
  // first thing, at step 0. THAT STEP IS NOT OPTIONAL -- with pl_resetn left high
  // from time zero, shim_axi_reset (= ~pl_resetn) never fires and every
  // reset-initialized register downstream stays X for the whole run, which shows up
  // as the packet generators driving X rather than as any kind of link failure.
  // Fans out in the BD to the glue (which derives gt_rst_all / shim_axi_reset /
  // mrmac_flexif_reset), gtwiz QUAD0_s_axi_lite_resetn, and mrmac_0/s_axi_aresetn.
  reg pl_resetn = 1'b1;

  // ---- GT serial loopback nets (boolean p/n; carry REAL data for GTY) -------
  // Shared wires ARE the analog line: gt_txp/txn (O) alias gt_rxp/rxn (I) in the
  // port map below, closing the fibre with zero hierarchical force. Straight
  // p->p / n->n mirrors an external loopback fibre, matching gt_loopback=3'b000.
  wire [3:0] gt_serial_p;
  wire [3:0] gt_serial_n;

  // ---- GT status (observed by the test program) ----------------------------
  // rx_reset_done is the SAME signal the exdes gates on: exdes.sv:2056
  // `assign stat_mst_reset_done = gt_rx_reset_done_out;`, and exdes_tb.v waits
  // `@(posedge stat_mst_reset_done[0])` before and after its double reset.
  wire rx_reset_done;
  wire tx_reset_done;
  wire gtpowergood;

  // ---- MRMAC s_axi (AXI4-Lite), driven by the tasks below ------------------
  // MRMAC's s_axi has NO wstrb and NO awprot/arprot (18 pins total including clock
  // and reset), so the full channel set fits in these few regs.
  reg  [31:0] s_axi_awaddr  = 32'h0;
  reg         s_axi_awvalid = 1'b0;
  wire        s_axi_awready;
  reg  [31:0] s_axi_wdata   = 32'h0;
  reg         s_axi_wvalid  = 1'b0;
  wire        s_axi_wready;
  wire [1:0]  s_axi_bresp;
  wire        s_axi_bvalid;
  reg         s_axi_bready  = 1'b0;
  reg  [31:0] s_axi_araddr  = 32'h0;
  reg         s_axi_arvalid = 1'b0;
  wire        s_axi_arready;
  wire [31:0] s_axi_rdata;
  wire [1:0]  s_axi_rresp;
  wire        s_axi_rvalid;
  reg         s_axi_rready  = 1'b0;

  // ---- generator / checker control + results -------------------------------
  // gen_enable is raised by the test program only AFTER RX has aligned, so no frame
  // is launched into an unaligned link (the exdes gates its generator the same way,
  // via c0_trig_in after its RX-align check).
  reg         gen_enable = 1'b0;
  wire [31:0] gen_sent_pkts;
  wire        gen_done;
  wire [31:0] chk_matched_pkts;
  wire [31:0] chk_mismatched_pkts;
  wire [31:0] chk_rx_bytes;
  wire        chk_all_done;

  // ---- PTP observation -----------------------------------------------------
  // RX: latched by the checker from tuser[80:1] at each frame's SOP.
  wire [79:0] chk_rx_ptp_ts_first;
  wire [79:0] chk_rx_ptp_ts_last;
  wire [31:0] chk_rx_ptp_nonzero_pkts;
  wire [31:0] chk_rx_ptp_stuck_pkts;

  // TX: MRMAC's 2-step timestamp completion, straight off the glue. Nothing in this
  // bench consumes it (in the shim it returns to fpga_core), so it is collected here.
  wire [79:0] tx_ptp_ts;
  wire [15:0] tx_ptp_ts_tag;
  wire        tx_ptp_ts_valid;

  // THE TAG IS WHAT MAKES THIS A REAL CHECK, not just a liveness poke. pkt_gen sets
  // tx tuser[16:1] = the packet index, that field is driven into MRMAC's
  // tx_ptp_tag_field_in, and MRMAC echoes it on tx_ptp_tstamp_tag_out beside the
  // stamp. So a completion arriving tagged N is provably MRMAC's response to frame N:
  // it demonstrates the 1588 request/response round trip matched up per frame, which
  // a bare "did any stamp appear" check cannot show.
  integer tx_ptp_completions   = 0;   // total valid pulses
  integer tx_ptp_nonzero       = 0;   // completions with a non-zero stamp
  integer tx_ptp_tag_ok        = 0;   // tag < NUM_PKTS and matches the expected order
  integer tx_ptp_tag_bad       = 0;
  integer tx_ptp_nonmono       = 0;   // stamp not advancing vs the previous completion
  reg [79:0] tx_ptp_ts_first_r = 80'd0;
  reg [79:0] tx_ptp_ts_last_r  = 80'd0;
  reg [79:0] tx_ptp_prev_r     = 80'd0;
  integer    tx_ptp_next_tag   = 0;

  // The 390.625 MHz AXIS client clock, brought out by the BD (axis_clk_out) purely so
  // this collector has a real edge to sample on.
  wire axis_clk_out;

  // Sampled in the AXIS domain the completion is produced in. tx_ptp_ts_valid is a
  // single-cycle pulse per completion, so this must be edge-driven, not polled from
  // the test program.
  always @(posedge axis_clk_out) begin
    if (!pl_resetn) begin
      tx_ptp_completions = 0;
      tx_ptp_nonzero     = 0;
      tx_ptp_tag_ok      = 0;
      tx_ptp_tag_bad     = 0;
      tx_ptp_nonmono     = 0;
      tx_ptp_next_tag    = 0;
      tx_ptp_ts_first_r  = 80'd0;
      tx_ptp_ts_last_r   = 80'd0;
      tx_ptp_prev_r      = 80'd0;
    end else if (tx_ptp_ts_valid === 1'b1) begin
      if (tx_ptp_completions == 0) tx_ptp_ts_first_r = tx_ptp_ts;
      else if (!(tx_ptp_ts > tx_ptp_prev_r))
        tx_ptp_nonmono = tx_ptp_nonmono + 1;
      tx_ptp_ts_last_r  = tx_ptp_ts;
      tx_ptp_prev_r     = tx_ptp_ts;
      tx_ptp_completions = tx_ptp_completions + 1;
      if (tx_ptp_ts !== 80'd0) tx_ptp_nonzero = tx_ptp_nonzero + 1;
      // Frames are submitted in order and MRMAC returns 2-step completions in order,
      // so the tag sequence should be 0,1,2,... Anything else is reported rather than
      // silently tolerated.
      if (tx_ptp_ts_tag === tx_ptp_next_tag[15:0]) tx_ptp_tag_ok  = tx_ptp_tag_ok  + 1;
      else                                         tx_ptp_tag_bad = tx_ptp_tag_bad + 1;
      tx_ptp_next_tag = tx_ptp_next_tag + 1;
    end
  end

  `TEST_PROGRAM test();

  test_harness `TH (
    // GT reference clock, exact 156.25 MHz diff pair (TB-generated, see above)
    .gt_ref_clk_p (gt_ref_clk_p),
    .gt_ref_clk_n (gt_ref_clk_n),

    // 100 MHz free-running clock (TB-generated, see above)
    .gt_freerun_clk (gt_freerun_clk),

    // board reset (the exdes's pl_resetn), active-low
    .pl_resetn (pl_resetn),

    // serial loop: tx (O) and rx (I) tied to the same wires
    .gt_txp (gt_serial_p),
    .gt_txn (gt_serial_n),
    .gt_rxp (gt_serial_p),
    .gt_rxn (gt_serial_n),

    // (no gt_reset_all port: INTF0_rst_all_in = ~gtpowergood, driven in the BD)

    // GT status
    .rx_reset_done (rx_reset_done),
    .tx_reset_done (tx_reset_done),
    .gtpowergood   (gtpowergood),

    // MRMAC AXI4-Lite register interface, straight to the IP pins
    .s_axi_awaddr  (s_axi_awaddr),
    .s_axi_awvalid (s_axi_awvalid),
    .s_axi_awready (s_axi_awready),
    .s_axi_wdata   (s_axi_wdata),
    .s_axi_wvalid  (s_axi_wvalid),
    .s_axi_wready  (s_axi_wready),
    .s_axi_bresp   (s_axi_bresp),
    .s_axi_bvalid  (s_axi_bvalid),
    .s_axi_bready  (s_axi_bready),
    .s_axi_araddr  (s_axi_araddr),
    .s_axi_arvalid (s_axi_arvalid),
    .s_axi_arready (s_axi_arready),
    .s_axi_rdata   (s_axi_rdata),
    .s_axi_rresp   (s_axi_rresp),
    .s_axi_rvalid  (s_axi_rvalid),
    .s_axi_rready  (s_axi_rready),

    // traffic generator / checker
    .gen_enable          (gen_enable),
    .gen_sent_pkts       (gen_sent_pkts),
    .gen_done            (gen_done),
    .chk_matched_pkts    (chk_matched_pkts),
    .chk_mismatched_pkts (chk_mismatched_pkts),
    .chk_rx_bytes        (chk_rx_bytes),
    .chk_all_done        (chk_all_done),

    // AXIS client clock, for the TX PTP completion collector above
    .axis_clk_out (axis_clk_out),

    // RX PTP: latched by the checker at each frame's SOP
    .chk_rx_ptp_ts_first     (chk_rx_ptp_ts_first),
    .chk_rx_ptp_ts_last      (chk_rx_ptp_ts_last),
    .chk_rx_ptp_nonzero_pkts (chk_rx_ptp_nonzero_pkts),
    .chk_rx_ptp_stuck_pkts   (chk_rx_ptp_stuck_pkts),

    // TX PTP: MRMAC's 2-step timestamp completion (stamp + echoed tag + valid pulse)
    .tx_ptp_ts       (tx_ptp_ts),
    .tx_ptp_ts_tag   (tx_ptp_ts_tag),
    .tx_ptp_ts_valid (tx_ptp_ts_valid)
  );

  // -------------------------------------------------------------------------
  // AXI4-Lite register access, TRANSCRIBED from the passing exdes tb
  // (mrmac_0_exdes_tb.v:551-604). Deliberately kept as a literal transcription
  // rather than "improved": the whole point of this bench is that the register path
  // behaves as it does in the reference, so the access protocol must not be a new
  // variable. Both tasks live in this module (not the program) so their waits run in
  // the Active region alongside the DUT, and the test program calls them
  // hierarchically as system_tb.axi_write/axi_read.
  //
  // One ADDITION over the exdes, which reports resp errors but does not stop:
  // bresp/rresp are checked and reported here. In the sibling bench, RegRead32 was
  // silently swallowing rresp=10 (SLVERR) on some reads, which cost real debugging
  // time -- so a non-OKAY response is now always visible in the log.
  // -------------------------------------------------------------------------
  task automatic axi_write(input [31:0] addr, input [31:0] data);
    begin
      @(posedge gt_freerun_clk);
      s_axi_awaddr  = addr;
      s_axi_wdata   = data;
      s_axi_awvalid = 1'b1;
      s_axi_wvalid  = 1'b1;
      // Wait for BOTH channels to be accepted. The exdes waits on wready alone;
      // waiting on each channel independently is protocol-correct for a slave that
      // may accept them on different cycles, and degenerates to the exdes behaviour
      // when it accepts them together.
      fork
        begin
          while (!s_axi_awready) @(posedge gt_freerun_clk);
          @(posedge gt_freerun_clk);
          s_axi_awvalid = 1'b0;
        end
        begin
          while (!s_axi_wready) @(posedge gt_freerun_clk);
          @(posedge gt_freerun_clk);
          s_axi_wvalid = 1'b0;
        end
      join
      // Write response.
      s_axi_bready = 1'b1;
      while (!s_axi_bvalid) @(posedge gt_freerun_clk);
      if (s_axi_bresp !== 2'b00)
        $display("[MRMAC-ONLY][AXI] WRITE RESP ERROR addr=0x%08h bresp=%b t=%0t",
                 addr, s_axi_bresp, $time);
      @(posedge gt_freerun_clk);
      s_axi_bready = 1'b0;
    end
  endtask

  task automatic axi_read(input [31:0] addr, output [31:0] data);
    begin
      @(posedge gt_freerun_clk);
      s_axi_araddr  = addr;
      s_axi_arvalid = 1'b1;
      while (!s_axi_arready) @(posedge gt_freerun_clk);
      @(posedge gt_freerun_clk);
      s_axi_arvalid = 1'b0;
      // Read data. Capture rdata in the SAME cycle rvalid is high, before rready
      // drops -- sampling it later is how a read silently returns stale data.
      s_axi_rready = 1'b1;
      while (!s_axi_rvalid) @(posedge gt_freerun_clk);
      data = s_axi_rdata;
      if (s_axi_rresp !== 2'b00)
        $display("[MRMAC-ONLY][AXI] READ RESP ERROR addr=0x%08h rresp=%b rdata=0x%08h t=%0t",
                 addr, s_axi_rresp, data, $time);
      @(posedge gt_freerun_clk);
      s_axi_rready = 1'b0;
    end
  endtask

  // Settle for N s_axi clocks -- the exdes's `repeat (N) @(posedge pl_clk)`.
  task automatic wait_pclks(input integer n);
    begin
      repeat (n) @(posedge gt_freerun_clk);
    end
  endtask

  // -------------------------------------------------------------------------
  // Serial-line activity monitor (READ-ONLY diagnostic).
  //
  // Counts transitions on the real CH0 TX serial pin, so ONE long run yields a
  // definitive diagnosis of a stuck rx_reset_done: zero transitions => the GT is not
  // driving the line at all (TX-side reset/config); many transitions while
  // rx_reset_done stays 0 => the line IS toggling and the fault is RX-side, not the
  // loopback. Purely observational -- it reads the boundary wire and drives nothing.
  // -------------------------------------------------------------------------
  reg     gt_serial_p0_prev = 1'b0;
  integer serial_edge_cnt   = 0;
  always @(gt_serial_p[0]) begin
    if (gt_serial_p[0] !== gt_serial_p0_prev) begin
      serial_edge_cnt   = serial_edge_cnt + 1;
      gt_serial_p0_prev = gt_serial_p[0];
    end
  end

  // Heartbeat: GT status + serial activity + traffic progress every 50 us. With
  // SIM_SPEEDUP=false the GT power-up ramp takes many ms of sim time (tens of
  // minutes wall clock), so a periodic line is the difference between "progressing"
  // and "hung".
  initial begin
    forever begin
      #(50us);
      $display("[MRMAC-ONLY][HB] t=%0t  CH0 TX edges=%0d  gtpowergood=%b tx_done=%b rx_done=%b  sent=%0d matched=%0d mismatched=%0d rx_bytes=%0d",
               $time, serial_edge_cnt, gtpowergood, tx_reset_done, rx_reset_done,
               gen_sent_pkts, chk_matched_pkts, chk_mismatched_pkts, chk_rx_bytes);
    end
  end

endmodule
