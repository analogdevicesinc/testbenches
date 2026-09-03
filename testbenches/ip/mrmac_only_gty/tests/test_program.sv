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
// MRMAC-ONLY 1x100G loopback test.
//
// This is a TRANSCRIPTION of the passing AMD example-design test bench sequence
// (mrmac_0_ex/imports/mrmac_0_exdes_tb.v:340-530), not a re-derivation of it. Where
// the exdes and our sibling bench differ, this file follows the EXDES -- that is the
// entire point: if this still fails, the fault is in the MRMAC/GT/glue plane and not
// in anything of ours; if it passes, the fault is in the Corundum shim / AXI
// interconnect that this bench removed.
//
// ONE DELIBERATE DEPARTURE FROM THE EXDES: the double reset (steps 3./4. below) has
// been removed. It was a testbench-only sequence with no counterpart in the glue
// RTL, so reproducing it here proved something no board can reproduce. The bench now
// matches hardware's actual reset behaviour; see the note at step 3./4. The ordinary
// power-on reset (step 0) is KEPT -- it is a different thing, and without it nothing
// in the design is ever reset at all.
//
// Sequence, with the exdes line it mirrors:
//   0. POWER-ON RESET: pl_resetn low, 400 clks, high        (the reset hardware gets
//      from the CIPS; required because system_tb.sv starts pl_resetn deasserted)
//   1. settle, then wait for the FIRST GT lock              (:408  @(posedge stat_mst_reset_done[0]))
//   2. settle 400 clks                                      (:410  repeat (400) @(posedge pl_clk))
//   3./4. (REMOVED -- see step 3./4. in the body) the exdes double reset
//      (:419-427) is deliberately NOT performed. It existed only in this
//      testbench, never in mrmac_versal_glue.v, so keeping it made the bench pass
//      while masking a gap real hardware has. Expect CORE_VERSION = 0 until the
//      re-reset is implemented in the glue RTL.
//   5. read CORE_VERSION                                    (:429-432)
//   6. register bring-up: RESET/MODE/CONFIG_RX/CONFIG_TX/
//      FEC off x4 / RESET clear / TICK                      (:434-460)
//   7. wait the RX alignment-marker time, then W1C + read
//      STAT_RX_STATUS bit0                                  (:462-478)
//   8. run traffic (the exdes pulses c0_trig_in; we raise gen_enable)
//   9. TICK, then read the 8 TX + 8 RX statistics counters
//      and compare the [47:0] slices                        (:490-528)
//
// WHAT MAKES THIS RUN AUTHORITATIVE, vs the sibling:
//   * s_axi is driven by plain TB wires via system_tb.axi_write/axi_read -- no
//     management VIP, no AXI interconnect, no address decode, no clock crossing. In
//     the sibling, reads returned 0 (and sometimes rresp=SLVERR) while the MRMAC's
//     own pins carried the correct payload, which blocked every register-gated
//     decision. Here, a register value can only be the MRMAC's own answer.
//   * The gating signal is the register (STAT_RX_STATUS bit0), NOT a hierarchical
//     pin probe. The sibling had to fall back to pins precisely because its register
//     reads were broken; going back to the register is a deliberate part of the
//     experiment, since the register path is what real hardware has.
//   * There is no base_env / test_harness_env / watchdog: CUSTOM_HARNESS=1 removed
//     the whole base harness. (The library still COMPILES those files --
//     sp_include_common.tcl sources them unconditionally -- but nothing here
//     instantiates them, so there is no framework watchdog to stop either.)
//
// PASS CRITERIA (both must hold; two independent measures of the same round trip):
//   a. the MRMAC's own statistics counters agree, TX vs RX (the exdes's criterion:
//      "INFO : Counters matched in Loopback Mode"), and
//   b. the byte-exact checker reports NUM_PKTS matched and zero mismatched.
// ---------------------------------------------------------------------------

`include "utils.svh"

// logger_pkg supplies the `INFO/`ERROR/`FATAL macro back-ends, setLoggerVerbosity,
// and the ADI_VERBOSITY_* enum. It is the ONLY framework package this test needs:
// with CUSTOM_HARNESS=1 there is no test_harness_env, no watchdog, and no VIP
// agents, so none of the usual environment/axi/axis imports apply.
import logger_pkg::*;

program test_program ();

  timeunit 1ps;
  timeprecision 1ps;

  // ------------------------------------------------------------------------
  // MRMAC port-0 register map. Offsets verbatim from the exdes tb; there is no base
  // address to add here because s_axi is driven directly (in the sibling these were
  // offsets from `MRMAC_BA in the management VIP address space).
  // ------------------------------------------------------------------------
  localparam bit [31:0] ADDR_CORE_VERSION      = 32'h0000_0000;
  localparam bit [31:0] ADDR_RESET_REG_0       = 32'h0000_0004;
  localparam bit [31:0] ADDR_MODE_REG_0        = 32'h0000_0008;
  localparam bit [31:0] ADDR_CONFIG_TX_REG1_0  = 32'h0000_000C;
  localparam bit [31:0] ADDR_CONFIG_RX_REG1_0  = 32'h0000_0010;
  localparam bit [31:0] ADDR_TICK_REG_0        = 32'h0000_002C;
  localparam bit [31:0] ADDR_FEC_CFG_REG1_0    = 32'h0000_00D0;
  localparam bit [31:0] ADDR_STAT_RX_STATUS_0  = 32'h0000_0744;

  // Statistics counters: each is 64 bits across two 32-bit registers (LSW then MSW),
  // and only bits [47:0] are meaningful -- which is why the compare below masks to
  // 48 bits, exactly as the exdes does.
  localparam bit [31:0] ADDR_TX_TOTAL_PACKETS      = 32'h0000_0818;
  localparam bit [31:0] ADDR_TX_TOTAL_GOOD_PACKETS = 32'h0000_0820;
  localparam bit [31:0] ADDR_TX_TOTAL_BYTES        = 32'h0000_0828;
  localparam bit [31:0] ADDR_TX_TOTAL_GOOD_BYTES   = 32'h0000_0830;
  localparam bit [31:0] ADDR_RX_TOTAL_PACKETS      = 32'h0000_0E30;
  localparam bit [31:0] ADDR_RX_TOTAL_GOOD_PACKETS = 32'h0000_0E38;
  localparam bit [31:0] ADDR_RX_TOTAL_BYTES        = 32'h0000_0E40;
  localparam bit [31:0] ADDR_RX_TOTAL_GOOD_BYTES   = 32'h0000_0E48;

  // Traffic shape, exported from the cfg by system_bd.tcl so the expectations here
  // cannot drift from the generator/checker RTL parameters.
  localparam int NUM_PKTS  = `GEN_NUM_PKTS;
  localparam int PKT_BYTES = `GEN_PKT_BYTES;

  int errors = 0;

  // Read a 64-bit statistics counter (LSW at addr, MSW at addr+4) and return the
  // meaningful [47:0] slice.
  task automatic read_stat48(input bit [31:0] addr, output bit [47:0] val);
    bit [31:0] lsw, msw;
    begin
      system_tb.axi_read(addr,          lsw);
      system_tb.axi_read(addr + 32'h4, msw);
      val = {msw[15:0], lsw};
    end
  endtask

  task automatic check_stat(input string name,
                            input bit [31:0] tx_addr,
                            input bit [31:0] rx_addr);
    bit [47:0] tx_val, rx_val;
    begin
      read_stat48(tx_addr, tx_val);
      read_stat48(rx_addr, rx_val);
      if (tx_val === rx_val)
        `INFO(("[MRMAC-ONLY][STAT] %s MATCH  tx=%0d rx=%0d", name, tx_val, rx_val),
              ADI_VERBOSITY_LOW);
      else begin
        errors++;
        `ERROR(("[MRMAC-ONLY][STAT] %s MISMATCH  tx=%0d rx=%0d", name, tx_val, rx_val));
      end
    end
  endtask

  initial begin

    bit [31:0] rd;
    int        tries;

    setLoggerVerbosity(ADI_VERBOSITY_MEDIUM);

    `INFO(("========================================"), ADI_VERBOSITY_NONE);
    `INFO(("  MRMAC 1x100G loopback -- INCREMENTS 3+4+5: + axis_adapter x4 + cmac_pad + PTP"), ADI_VERBOSITY_NONE);
    `INFO(("  (1-2 already in: mrmac_{tx,rx}_adapt, glue AXIS pack/unpack, axis_fifo x2, sync_reset x3)"), ADI_VERBOSITY_NONE);
    `INFO(("  (datapath is now 512b end-to-end; tuser back to the shim's real 17 TX / 81 RX)"), ADI_VERBOSITY_NONE);
    `INFO(("  (PTP: ts_cvt x4 + ptp_sync x2 + mac_ts_insert -- MRMAC timestamping ON, ts_clk 250 MHz)"), ADI_VERBOSITY_NONE);
    `INFO(("  (still no mqnic_port_map_mac_axis, no mac_rstgen, no IP packaging, no VIPs)"), ADI_VERBOSITY_NONE);
    `INFO(("  %0d packets x %0d bytes", NUM_PKTS, PKT_BYTES), ADI_VERBOSITY_NONE);
    `INFO(("========================================"), ADI_VERBOSITY_NONE);

    // ---- 0. POWER-ON RESET -----------------------------------------------
    // A single assert/release of pl_resetn before anything else. This is NOT the
    // removed double reset (see step 3./4.): that was a SECOND reset applied after
    // the first GT lock, to re-initialize the MRMAC against an already-stable GT.
    // This is the ordinary power-on reset every design gets, and it is what real
    // hardware has -- on the board pl_resetn comes from the CIPS
    // (sys_cpu_resetn/pl0_resetn), which is asserted at configuration and released
    // once. Reproducing it here is hardware-faithful; omitting it is not.
    //
    // WHY IT HAS TO BE EXPLICIT: system_tb.sv declares `reg pl_resetn = 1'b1`
    // (:113) -- deasserted from time zero, mirroring exdes_tb.v:344. In the exdes
    // that is safe only because the exdes later pulses it low as part of its double
    // reset. With that block removed, pl_resetn would NEVER be asserted, so
    // shim_axi_reset (= ~pl_resetn, glue :654) never fires and every
    // reset-initialized register in the shim/generators/FIFOs stays X for the whole
    // run -- which presents as the packet generators driving X, not as a link fault.
    `INFO(("Power-on reset: pl_resetn low, 400 clks, high"), ADI_VERBOSITY_LOW);
    system_tb.pl_resetn = 1'b0;
    system_tb.wait_pclks(400);
    system_tb.pl_resetn = 1'b1;
    system_tb.wait_pclks(20);

    // ---- 1. initial settle + FIRST GT lock -------------------------------
    // The exdes settles 20 pl_clk cycles then releases gt_reset_all and waits for
    // stat_mst_reset_done[0] (= gt_rx_reset_done, exdes.sv:2056 -- so our
    // rx_reset_done port IS that signal). Our BD instead ties INTF0_rst_all_in to
    // ~gtpowergood, which self-sequences the release off the power-up ramp; the wait
    // is otherwise identical.
    //
    // Note the exdes ALSO waits for gtpowergood implicitly (its rst_all release is
    // unconditional and the GT holds reset_done low until powered), so watching
    // powergood first is just the observable version of the same thing -- and it is
    // the order the validated ADI mxfe reference uses ("wait until gt_powergood
    // toggles ... otherwise it doesn't work").
    system_tb.wait_pclks(20);

    `INFO(("GT: waiting for FIRST lock (rst_all = ~gtpowergood, BD inverter)"), ADI_VERBOSITY_LOW);
    fork : lock1
      begin : wait_lock1
        wait (system_tb.gtpowergood === 1'b1);
        `INFO(("GT: gtpowergood asserted @ %0t", $time), ADI_VERBOSITY_LOW);
        wait (system_tb.tx_reset_done === 1'b1);
        `INFO(("GT: tx_reset_done asserted @ %0t", $time), ADI_VERBOSITY_LOW);
        wait (system_tb.rx_reset_done === 1'b1);
        `INFO(("GT: rx_reset_done asserted @ %0t (FIRST lock)", $time), ADI_VERBOSITY_LOW);
      end
      begin : backstop1
        // Generous: with SIM_SPEEDUP=false the encrypted GTY power-up ramp needs
        // many ms of sim time (tens of minutes wall clock). This only fires on a
        // genuine hang. There is no framework watchdog to fight here -- the base
        // harness is gone.
        #20ms;
        `FATAL(("GT: 20 ms backstop reached without FIRST lock: gtpowergood=%b tx_done=%b rx_done=%b",
                system_tb.gtpowergood, system_tb.tx_reset_done, system_tb.rx_reset_done));
      end
    join_any
    disable lock1;

    // ---- 2. settle (exdes: repeat (400) @(posedge pl_clk)) ---------------
    system_tb.wait_pclks(400);

    // ---- 3./4. (REMOVED) exdes DOUBLE RESET ------------------------------
    // The exdes-exact double reset that used to sit here has been REMOVED on
    // purpose. It re-asserted pl_resetn for 400 clocks AFTER the first GT lock,
    // waited for reset_done to FALL and then RISE again, and only then read the
    // version -- and it was what made this bench read Core_Version = 1 (matching
    // the reference exdes) instead of 0.
    //
    // What remains is the SINGLE power-on reset at step 0, before the first lock.
    // The distinction is the whole point: one reset at power-up is what hardware
    // gets; a second one timed against a stable GT is what only a testbench can
    // arrange. Do not "restore" step 0 into this position -- that recreates the
    // double reset.
    //
    // WHY IT IS GONE, and what to expect: the sequence only ever existed in the
    // TESTBENCH. Nothing in mrmac_versal_glue.v performs it, so a real board never
    // gets it -- the glue does a single pass (mrmac_*_core_reset = ~gt_rst_*_done,
    // shim_axi_reset = ~pl_resetn). Keeping it here made the bench pass while
    // hiding that gap. With it removed this bench now exercises the SAME reset
    // behaviour hardware will see, so a Core_Version of 0 / RX never aligning /
    // X on AXIS is the expected, informative result rather than a regression.
    //
    // If the sequence is later moved into the glue RTL (a re-reset FSM gated on GT
    // stability), it will apply here automatically with no testbench change, and
    // the version read below should go back to 1.
    //
    // The single settle above (step 2, 400 pl_clks after the first lock) is kept.

    // ---- 5. CORE_VERSION -------------------------------------------------
    system_tb.axi_read(ADDR_CORE_VERSION, rd);
    `INFO(("MRMAC Core_Version = 0x%08h", rd), ADI_VERBOSITY_NONE);
    // The reference exdes reads 1 (mrmac_0_ex/.../simulate.log:16 "Core_Version = 1")
    // -- but it also performs the double reset that was removed above. Reading 0
    // here is therefore the EXPECTED outcome of that removal, and it is the
    // hardware-faithful one: it says the register block does not initialize from a
    // single reset pass. Reported as a warning, not an error, so the run continues
    // to the alignment/counter checks that localize the effect.
    if (rd[15:0] === 16'h0)
      `WARNING(("MRMAC Core_Version reads 0 (exdes reads 1). Expected without the double reset: the register block does not initialize from a single reset pass. This is what hardware will see until the re-reset is implemented in the glue RTL."));
    else
      `INFO(("MRMAC Core_Version is NON-ZERO: the register block initialized from a SINGLE reset pass (no double reset needed)."),
            ADI_VERBOSITY_NONE);

    // ---- 6. register bring-up (exdes :434-460, values verbatim) ----------
    // MRMAC has NO hardware enable pin: this register sequence IS the MAC enable.
    `INFO(("MRMAC bring-up: configuring 1x100GE"), ADI_VERBOSITY_LOW);
    system_tb.axi_write(ADDR_RESET_REG_0,      32'h0000_0FFF);
    system_tb.axi_write(ADDR_MODE_REG_0,       32'h4000_0A64); // 1x100GE; [11:9]=5 = Non-Segmented
    system_tb.axi_write(ADDR_CONFIG_RX_REG1_0, 32'h0000_0033);
    system_tb.axi_write(ADDR_CONFIG_TX_REG1_0, 32'h0000_0C03);
    // FEC off on all four register banks (bank stride 0x1000), as the exdes does.
    system_tb.axi_write(ADDR_FEC_CFG_REG1_0 + 32'h0000, 32'h0);
    system_tb.axi_write(ADDR_FEC_CFG_REG1_0 + 32'h1000, 32'h0);
    system_tb.axi_write(ADDR_FEC_CFG_REG1_0 + 32'h2000, 32'h0);
    system_tb.axi_write(ADDR_FEC_CFG_REG1_0 + 32'h3000, 32'h0);
    // Release the config reset, then a PM tick (latches the mode/config).
    system_tb.axi_write(ADDR_RESET_REG_0, 32'h0000_0000);
    system_tb.axi_write(ADDR_TICK_REG_0,  32'h0000_0001);

    // Read MODE_REG_0 back. MODE is plain R/W, so a readback mismatch is unambiguous
    // proof the register path is dead, and a match proves it is alive -- which is
    // what makes a CORE_VERSION of 0 interpretable as the MRMAC's own answer rather
    // than a lost payload. (CORE_VERSION is read-only, so a 0 there is ambiguous on
    // its own; this is the disambiguator.)
    system_tb.axi_read(ADDR_MODE_REG_0, rd);
    if (rd === 32'h4000_0A64)
      `INFO(("[SELFTEST] MODE_REG_0 readback 0x%08h matches -- the s_axi/APB register path is ALIVE.", rd),
            ADI_VERBOSITY_LOW);
    else
      `ERROR(("[SELFTEST] MODE_REG_0 readback 0x%08h != 0x40000A64 -- the register path itself is not returning written data.", rd));

    // ---- 7. RX alignment (exdes :462-478) --------------------------------
    // The exdes waits a FIXED time for the alignment markers (12500 pl_clk with
    // SIM_SPEED_UP, 200000 without) and then does ONE W1C + read, treating a clear
    // bit0 as fatal. We wait the same fixed time first -- so the sampling point
    // matches the reference -- and then POLL rather than one-shot, which turns a
    // marginal-timing failure into a visible "aligned late at N us" instead of a
    // hard stop. A genuinely unaligned link still fails, just after the bound.
    `INFO(("Waiting for RX alignment markers (exdes: 12500 pl_clk with SIM_SPEED_UP)"), ADI_VERBOSITY_LOW);
    system_tb.wait_pclks(12500);

    tries = 0;
    forever begin
      // W1C the sticky bits first, THEN read -- the exdes's clear-then-sample
      // semantics. bit0 latches "aligned & no fault", so reading without clearing
      // can report a stale transient.
      system_tb.axi_write(ADDR_STAT_RX_STATUS_0, 32'hFFFF_FFFF);
      system_tb.axi_read (ADDR_STAT_RX_STATUS_0, rd);
      if (rd[0] === 1'b1) begin
        `INFO(("INFO : RX ALIGNED (STAT_RX_STATUS=0x%08h) after %0d polls @ %0t", rd, tries, $time),
              ADI_VERBOSITY_NONE);
        break;
      end
      if (tries < 5 || (tries % 50) == 0)
        `INFO(("[POLL %0d] STAT_RX_STATUS = 0x%08h @ %0t", tries, rd, $time), ADI_VERBOSITY_LOW);
      tries++;
      if (tries > 2000)
        `FATAL(("ERROR : RX ALIGN FAILED -- STAT_RX_STATUS bit0 never set (last read 0x%08h after %0d polls). The exdes reports 'INFO : RX ALIGNED' at this point.",
                rd, tries));
      #1us;
    end

    // ---- 8. run traffic --------------------------------------------------
    // The exdes pulses c0_trig_in for one cycle to start its generator; ours holds
    // gen_enable high until the generator's own packet count is reached.
    `INFO(("Starting traffic: %0d packets x %0d bytes", NUM_PKTS, PKT_BYTES), ADI_VERBOSITY_LOW);
    system_tb.gen_enable = 1'b1;

    fork : traffic
      begin : wait_traffic
        wait (system_tb.gen_done === 1'b1);
        `INFO(("Generator done: %0d packets sent @ %0t", system_tb.gen_sent_pkts, $time),
              ADI_VERBOSITY_LOW);
        wait (system_tb.chk_all_done === 1'b1);
        `INFO(("Checker done @ %0t: matched=%0d mismatched=%0d rx_bytes=%0d", $time,
               system_tb.chk_matched_pkts, system_tb.chk_mismatched_pkts,
               system_tb.chk_rx_bytes), ADI_VERBOSITY_LOW);
      end
      begin : traffic_backstop
        // Must SCALE with NUM_PKTS, and the per-frame figure is MEASURED, not derived
        // from the frame's beat count. Increments 3/4/5 put the shim's 64-bit width
        // conversion neck in the path, and since every stage runs on one clock the neck
        // caps the datapath at 8 bytes/cycle: a 256-byte frame therefore costs 32 cycles
        // = 81.9 ns at 390.625 MHz, NOT the ~25.6 ns a 6-beat 384-bit frame would
        // suggest. The standalone harness measures exactly that (32 cyc/frame, neck 99%
        // occupied -- see standalone/run.sh), so 4096 frames need ~336 us of traffic.
        //
        // 200 ns per frame is ~2.4x the measured 81.9 ns, which absorbs MAC
        // back-pressure and any FIFO pacing, plus a flat 200 us for the MAC+PCS+GT
        // round-trip latency of the last frame. At NUM_PKTS=4096 that is 1019 us for
        // ~336 us of traffic; at 16 it is 203 us.
        //
        // The earlier 60 ns/frame was sized against the 25.6 ns estimate and left only
        // ~110 us of margin over the real 336 us -- enough that a slow-but-healthy run
        // could have tripped it and reported a false loss. Still a backstop, not a wait:
        // a run that is merely slow finishes early on the wait_traffic branch.
        #(NUM_PKTS * 200ns + 200us);
        `ERROR(("Traffic backstop (%0t): sent=%0d matched=%0d mismatched=%0d rx_bytes=%0d -- frames did not complete the round trip.",
                $time, system_tb.gen_sent_pkts, system_tb.chk_matched_pkts,
                system_tb.chk_mismatched_pkts, system_tb.chk_rx_bytes));
      end
    join_any
    disable traffic;

    // Let any in-flight tail drain before latching the counters.
    #10us;

    // ---- 9. statistics counters (exdes :490-528) -------------------------
    // A PM tick snapshots the counters into the readable registers; without it the
    // reads return the previous snapshot.
    system_tb.axi_write(ADDR_TICK_REG_0, 32'h0000_0001);
    system_tb.wait_pclks(100);

    `INFO(("Comparing MRMAC TX vs RX statistics counters (the exdes's pass criterion)"), ADI_VERBOSITY_LOW);
    check_stat("TOTAL_PACKETS",      ADDR_TX_TOTAL_PACKETS,      ADDR_RX_TOTAL_PACKETS);
    check_stat("TOTAL_GOOD_PACKETS", ADDR_TX_TOTAL_GOOD_PACKETS, ADDR_RX_TOTAL_GOOD_PACKETS);
    check_stat("TOTAL_BYTES",        ADDR_TX_TOTAL_BYTES,        ADDR_RX_TOTAL_BYTES);
    check_stat("TOTAL_GOOD_BYTES",   ADDR_TX_TOTAL_GOOD_BYTES,   ADDR_RX_TOTAL_GOOD_BYTES);

    // ---- byte-exact checker verdict --------------------------------------
    // Independent of the counters above: the counters can agree while the payload is
    // corrupted (same count, wrong bytes), and the checker can flag a length delta
    // the counters would show only as a byte-count difference. Both must pass.
    if (system_tb.chk_mismatched_pkts !== 32'd0) begin
      errors++;
      `ERROR(("[CHK] %0d packets MISMATCHED (see [MRMAC-ONLY][CHK] lines for the first bad byte of each).",
              system_tb.chk_mismatched_pkts));
    end
    if (system_tb.chk_matched_pkts !== NUM_PKTS) begin
      errors++;
      // Since increment 2 there is a second way to lose a packet without corrupting one:
      // the RX FIFO drops WHOLE frames when full (DROP_WHEN_FULL=1), which looks exactly
      // like a frame never arriving. mrmac_shim_rx_fifo prints [MRMAC-ONLY][RXFIFO]
      // OVERFLOW when that happens, so the log distinguishes the two cases.
      //
      // Increment 3 is when that stops being theoretical. Through increments 1-2 the RX
      // FIFO's m_axis_tready was tied constant 1 (pkt_chk consumed every beat), so it
      // could never fill and DROP_WHEN_FULL was unreachable. The 384->64 down-converter
      // now sits there and does stall, so a drop is a real possibility from here on --
      // read a hit as a capacity question, not a link fault.
      `ERROR(("[CHK] only %0d of %0d packets matched (check for [MRMAC-ONLY][RXFIFO] OVERFLOW lines: a FIFO drop looks identical here).",
              system_tb.chk_matched_pkts, NUM_PKTS));
    end

    // ---- 9b. PTP verdict -------------------------------------------------
    // WHAT IS AND IS NOT CHECKABLE HERE. The Corundum time this bench feeds the
    // discipline path comes from a LOCAL free-running counter (mrmac_shim_ptp_timegen),
    // not Corundum's ptp_clock -- there is no fpga_core here. So there is no reference
    // to be accurate against and absolute timestamp values mean nothing. What IS
    // checkable, and what these checks cover:
    //   * LIVENESS  - stamps come back non-zero. Zero everywhere means MRMAC never
    //                 loaded the systemtimer (st_sync handshake dead) or never
    //                 captured, even though the bytes were perfect.
    //   * PROGRESS  - stamps ADVANCE across the run. A non-zero but frozen timer
    //                 passes a liveness check and is still broken.
    //   * TAG MATCH - MRMAC echoes the per-frame 1588 tag beside each TX completion.
    //                 pkt_gen sets the tag to the packet index, so the returned tag
    //                 sequence proves the request/response round trip lined up per
    //                 frame. This is the strongest PTP evidence available here.
    // These are reported as ERRORs (they count toward `errors`) because a dead PTP
    // path is a real defect in the shim, not a cosmetic gap -- but they are checked
    // AFTER the byte-exact verdict so a PTP failure never masks a datapath failure.
    `INFO(("Checking PTP: RX capture, TX 2-step completion, and per-frame tag match"), ADI_VERBOSITY_LOW);
    `INFO(("  RX  stamps: first=0x%020h last=0x%020h nonzero=%0d/%0d stuck=%0d",
           system_tb.chk_rx_ptp_ts_first, system_tb.chk_rx_ptp_ts_last,
           system_tb.chk_rx_ptp_nonzero_pkts, NUM_PKTS,
           system_tb.chk_rx_ptp_stuck_pkts), ADI_VERBOSITY_NONE);
    `INFO(("  TX  completions=%0d nonzero=%0d tag_ok=%0d tag_bad=%0d nonmono=%0d first=0x%020h last=0x%020h",
           system_tb.tx_ptp_completions, system_tb.tx_ptp_nonzero,
           system_tb.tx_ptp_tag_ok, system_tb.tx_ptp_tag_bad,
           system_tb.tx_ptp_nonmono,
           system_tb.tx_ptp_ts_first_r, system_tb.tx_ptp_ts_last_r), ADI_VERBOSITY_NONE);

    // --- RX path ---
    if (system_tb.chk_rx_ptp_nonzero_pkts === 32'd0) begin
      errors++;
      `ERROR(("[PTP] RX timestamps are ALL ZERO across %0d frames. mac_ts_insert wrote nothing meaningful into tuser[80:1], which means MRMAC's RX PTP timer was never loaded (mrmac_ptp_sync st_sync/st_overwrite handshake) or never captured. The datapath is fine -- this is the PTP plane.", NUM_PKTS));
    end else if (system_tb.chk_rx_ptp_ts_last === system_tb.chk_rx_ptp_ts_first) begin
      errors++;
      `ERROR(("[PTP] RX timestamp did NOT ADVANCE: first == last == 0x%020h. The timer is loaded but frozen -- check that ts_clk is actually toggling (250 MHz, clk_wizard clk_out2) and that st_overwrite is held high.",
              system_tb.chk_rx_ptp_ts_first));
    end else if (system_tb.chk_rx_ptp_stuck_pkts !== 32'd0) begin
      errors++;
      `ERROR(("[PTP] %0d of %0d RX frames carried the SAME timestamp as the previous frame. Frames are separated by the IFG plus the whole MAC round trip, far more than one ts_clk tick, so repeats mean the capture is stale rather than merely fast.",
              system_tb.chk_rx_ptp_stuck_pkts, NUM_PKTS));
    end

    // --- TX path ---
    if (system_tb.tx_ptp_completions == 0) begin
      errors++;
      `ERROR(("[PTP] NO TX timestamp completions arrived. MRMAC was asked for a 2-step stamp on every frame (1588op = 2'b10, tx_ptp_1588op xlconstant) and returned none: tx_ptp_tstamp_valid_out_0 never pulsed. Check the 1588v2 operation mode config and that tx_ptp_tag_field_in is driven."));
    end else begin
      if (system_tb.tx_ptp_completions != NUM_PKTS)
        `WARNING(("[PTP] %0d TX completions for %0d frames. A 2-step request is issued per frame, so a shortfall means some completions were missed or coalesced; not failed outright since MRMAC may drop a request under back-pressure.",
                  system_tb.tx_ptp_completions, NUM_PKTS));
      if (system_tb.tx_ptp_nonzero == 0) begin
        errors++;
        `ERROR(("[PTP] %0d TX completions arrived but EVERY stamp was zero. The completion path pulses but MRMAC's TX PTP timer holds 0 -- the systemtimer load did not take.",
                system_tb.tx_ptp_completions));
      end
      if (system_tb.tx_ptp_tag_bad != 0) begin
        errors++;
        `ERROR(("[PTP] %0d TX completions carried an UNEXPECTED tag (%0d correct). pkt_gen tags frame N with N and MRMAC echoes the tag on tx_ptp_tstamp_tag_out, so a mismatch means the 1588 request/response pairing is broken -- stamps are not attributable to their frames.",
                system_tb.tx_ptp_tag_bad, system_tb.tx_ptp_tag_ok));
      end
      if (system_tb.tx_ptp_nonmono != 0)
        `WARNING(("[PTP] %0d TX stamps did not advance vs the previous completion. Expected zero with a monotonic timebase; a small count can also come from the 80-bit field wrapping, which is not an error.",
                  system_tb.tx_ptp_nonmono));
    end

    #100ns;

    if (errors == 0) begin
      `INFO(("========================================"), ADI_VERBOSITY_NONE);
      `INFO(("  INCREMENTS 3+4+5 PASS: counters matched + %0d/%0d packets byte-exact + PTP live",
             system_tb.chk_matched_pkts, NUM_PKTS), ADI_VERBOSITY_NONE);
      `INFO(("  => the shim's ENTIRE DATAPATH is now proven: four axis_adapter width"), ADI_VERBOSITY_NONE);
      `INFO(("     converters (512->64->384 TX, 384->64->512 RX), cmac_pad, and the PTP"), ADI_VERBOSITY_NONE);
      `INFO(("     set (ts_cvt x4, ptp_sync x2, mac_ts_insert) on top of increments 1-2."), ADI_VERBOSITY_NONE);
      `INFO(("     Read two limits plainly, so this is not over-claimed:"), ADI_VERBOSITY_NONE);
      `INFO(("       * cmac_pad is INERT at %0d-byte frames (every beat already full), so", PKT_BYTES), ADI_VERBOSITY_NONE);
      `INFO(("         this proves it is TRANSPARENT, not that the padding works. That"), ADI_VERBOSITY_NONE);
      `INFO(("         needs PKT_BYTES < 60 -- a separate experiment."), ADI_VERBOSITY_NONE);
      `INFO(("       * PTP is proven STRUCTURALLY and now also FUNCTIONALLY-LIVE:"), ADI_VERBOSITY_NONE);
      `INFO(("         format conversion, PG314 st_sync handshake, ts_clk crossing, MRMAC"), ADI_VERBOSITY_NONE);
      `INFO(("         accepting the load, RX stamps non-zero AND advancing per frame, TX"), ADI_VERBOSITY_NONE);
      `INFO(("         2-step completions returning with the CORRECT per-frame 1588 tag"), ADI_VERBOSITY_NONE);
      `INFO(("         (%0d/%0d), 81-bit tuser threaded through.", system_tb.tx_ptp_tag_ok, NUM_PKTS), ADI_VERBOSITY_NONE);
      `INFO(("         STILL NOT time ACCURACY: the timebase is a local counter, not"), ADI_VERBOSITY_NONE);
      `INFO(("         Corundum's ptp_clock, so there is nothing to be accurate against."), ADI_VERBOSITY_NONE);
      `INFO(("     Next rung: mqnic_port_map_mac_axis + mac_rstgen, then packaging the"), ADI_VERBOSITY_NONE);
      `INFO(("     shim as one library IP (mrmac_dut)."), ADI_VERBOSITY_NONE);
      `INFO(("========================================"), ADI_VERBOSITY_NONE);
    end else begin
      `INFO(("========================================"), ADI_VERBOSITY_NONE);
      `INFO(("  INCREMENTS 3+4+5 FAIL (%0d errors)", errors), ADI_VERBOSITY_NONE);
      `INFO(("  => increment 2 (adapters + FIFOs + sync_resets, no width conversion, no"), ADI_VERBOSITY_NONE);
      `INFO(("     pad, no PTP) passed byte-exact, so the fault is in what these added."), ADI_VERBOSITY_NONE);
      `INFO(("     Suspect in order of likelihood:"), ADI_VERBOSITY_NONE);
      `INFO(("       1. THE PTP CONFIG FLIP. Increment 5 REVERSES two *** EXDES *** deltas"), ADI_VERBOSITY_NONE);
      `INFO(("          the baseline PASS was built on: timestamping 0->1 with 1588v2 mode"), ADI_VERBOSITY_NONE);
      `INFO(("          {No operation}->{2-step}, and tx_ts_clk/rx_ts_clk stop being GND."), ADI_VERBOSITY_NONE);
      `INFO(("          Revert those two lines in system_bd.tcl section 1 FIRST -- they"), ADI_VERBOSITY_NONE);
      `INFO(("          carry explicit revert instructions -- to split 3+4 from 5."), ADI_VERBOSITY_NONE);
      `INFO(("       2. The width-conversion chain. A wrong tkeep on the partial beat"), ADI_VERBOSITY_NONE);
      `INFO(("          shows as a LENGTH error on every frame, not as data corruption."), ADI_VERBOSITY_NONE);
      `INFO(("       3. RX FIFO drops: the 384->64 converter now back-pressures it for the"), ADI_VERBOSITY_NONE);
      `INFO(("          first time (its m_axis_tready was a constant 1 before), so"), ADI_VERBOSITY_NONE);
      `INFO(("          DROP_WHEN_FULL is finally reachable. Check [RXFIFO] OVERFLOW lines."), ADI_VERBOSITY_NONE);
      `INFO(("     Do NOT re-debug the MRMAC/GT/clocking plane -- see baseline_pass/README.md"), ADI_VERBOSITY_NONE);
      `INFO(("     for what is already proven."), ADI_VERBOSITY_NONE);
      `INFO(("========================================"), ADI_VERBOSITY_NONE);
    end

    `INFO(("Test bench done!"), ADI_VERBOSITY_NONE);
    $finish();

  end

endprogram
