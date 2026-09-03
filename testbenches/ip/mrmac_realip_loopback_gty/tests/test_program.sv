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
// Milestone-2 REAL-IP MRMAC loopback test.
//
// End-to-end sequence:
//   1. base harness up (sys/dma/ddr clocks + reset + mng/ddr VIPs),
//   2. pin + start the two GT clocks EXACTLY (156.25 MHz refclk, 100 MHz
//      freerun) via set_clk_frq -- the jesd_loopback REF_CLK idiom; the AXIS
//      client clock is the REAL clk_wizard (390.625 MHz off the freerun), no VIP,
//   3. stop the framework watchdog (the encrypted GTY power-up ramp needs many ms
//      of sim time = tens of minutes wall clock), sys_reset,
//   4. block on GT rx/tx reset-done over the serial loopback (heartbeat + generous
//      backstop) -- INTF0_rst_all_in = ~gtpowergood, driven by a util_vector_logic
//      inverter INSIDE the BD (mxfe-exact: mxfe/system_tb.sv:50 gt_reset=~gtpowergood
//      -> direct wrapper passthrough, reaches rx_reset_done@59us). This self-sequences
//      the reset release off the GT power-up ramp; the earlier fixed-width TB pulse
//      released rst_all too early (before the SIM_SPEEDUP=false ramp finished) so
//      powergood stalled at 0,
//   5. MRMAC MAC bring-up over s_axi (RegWrite32; MRMAC has NO hardware enable
//      pin): RESET -> MODE 1x100GE -> CONFIG_RX/TX -> FEC off -> RESET clear ->
//      PM TICK, exactly the register writes/values of the proven exdes tb_orig.v,
//   6. poll STAT_RX_STATUS bit0 until RX is aligned (write-1-to-clear the sticky
//      status, then read; robust whether or not SIM_SPEED_UP reached the IP),
//   7. run the byte-exact data loopback: AXIS master VIP -> shim -> real MRMAC+GT
//      serial loop -> real MRMAC RX -> shim -> AXIS slave VIP, scoreboard checks
//      the fpga_core RX byte stream == TX byte stream (ONESHOT),
//   8. report + finish.
// ---------------------------------------------------------------------------

`include "utils.svh"
`include "axi_definitions.svh"

import logger_pkg::*;
import test_harness_env_pkg::*;
import environment_pkg::*;
import watchdog_pkg::*;
import axi_vip_pkg::*;

// The auto-generated per-VIP packages declare the `*_VIP_PROTOCOL` localparams
// that `AXI_VIP_PARAMS(test_harness, mng_axi_vip)` / (..., ddr_axi_vip) expand to.
// The parameterized test_harness_env #(...) declaration below cannot elaborate
// without them (VRFC 10-2989 'test_harness_mng_axi_vip_0_VIP_PROTOCOL' not
// declared). dma_loopback imports these two -- M2 was missing them.
import `PKGIFY(test_harness, mng_axi_vip)::*;
import `PKGIFY(test_harness, ddr_axi_vip)::*;

import `PKGIFY(test_harness, eth_tx_axis)::*;
import `PKGIFY(test_harness, eth_rx_axis)::*;

program test_program ();

  timeunit 1ps;
  timeprecision 1ps;

  // REAL-IP MRMAC + Corundum MAC-shim loopback environment (no AXIS clk_vip: the
  // AXIS client clock is the real clk_wizard clk_out1).
  mrmac_loopback_environment #(`AXIS_VIP_PARAMS(test_harness, eth_tx_axis), `AXIS_VIP_PARAMS(test_harness, eth_rx_axis)) env;

  // base test-harness environment (clocks + reset + mng/ddr VIPs). The library's
  // test_harness_env is a parameterized class keyed on the mng + ddr AXI VIP
  // params (test_harness_env.sv); the older irq_vip_if constructor was removed, so
  // declare it typed and construct it with the mng/ddr VIP interfaces (the current
  // idiom shared by dma_loopback/axis_sequencers).
  test_harness_env #(`AXI_VIP_PARAMS(test_harness, mng_axi_vip), `AXI_VIP_PARAMS(test_harness, ddr_axi_vip)) base_env;

  watchdog send_data_wd;

  // fpga_core AXIS datapath is 512b = 64 bytes/beat. Send whole beats (keep_all)
  // so frames are exact multiples of 64B, always >= 64B, so the shim's cmac_pad
  // 60-byte minimum never lengthens a frame => byte-exact round-trip.
  localparam int BEAT_BYTES = `DATA_WIDTH / 8;

  // ------------------------------------------------------------------------
  // MRMAC s_axi register map (port-0 bank; offsets from the proven exdes
  // tb_orig.v). MRMAC_BA is the ABSOLUTE base address of mrmac_0/s_axi in the
  // management VIP address space, exported (decimal) from system_bd.tcl.
  // ------------------------------------------------------------------------
  localparam bit [31:0] ADDR_CORE_VERSION      = 32'h0000_0000;
  localparam bit [31:0] ADDR_RESET_REG_0       = 32'h0000_0004;
  localparam bit [31:0] ADDR_MODE_REG_0        = 32'h0000_0008;
  localparam bit [31:0] ADDR_CONFIG_TX_REG1_0  = 32'h0000_000C;
  localparam bit [31:0] ADDR_CONFIG_RX_REG1_0  = 32'h0000_0010;
  localparam bit [31:0] ADDR_TICK_REG_0        = 32'h0000_002C;
  localparam bit [31:0] ADDR_FEC_CFG_REG1_0    = 32'h0000_00D0;
  localparam bit [31:0] ADDR_STAT_RX_STATUS_0  = 32'h0000_0744;

  // ------------------------------------------------------------------------
  // MRMAC MAC bring-up over s_axi (values verbatim from tb_orig.v). No hardware
  // enable pin -> this register sequence is what turns the MAC on.
  // ------------------------------------------------------------------------
  // ------------------------------------------------------------------------
  // s_axi PIN-LEVEL probe + write/readback self-test.
  //
  // The AXI method comparison vs the proven exdes showed our RegWrite32/RegRead32
  // (ADI m_axi_sequencer -> Xilinx VIP driver send/wait_rsp/get_data_beat) and the
  // address path are both sound: MRMAC's s_axi_araddr is a full 32 bits, its internal
  // AXI->APB bridge is instantiated with C_APB_NUM_SLAVES=1 (so pselect is
  // unconditional, never a range miss), and the wrapper masks the address down with
  // .apb3_paddr(m_apb_paddr[15:0]) -- so our absolute 0x44A00744 reaches the CSR block
  // as 0x0744, exactly the offset the exdes drives. The generated wrapper's whole
  // APB/CSR hookup diffs byte-identical against the exdes wrapper.
  //
  // What that leaves is: does the read return 0 because the MRMAC CSR block is not
  // responding, or because something between the VIP and the pins mangles it? These
  // two probes discriminate that WITHOUT a waveform:
  //   * dump_axi_pins prints the actual MRMAC s_axi pins (rdata/rresp/handshake), so
  //     if the pins carry a nonzero rdata while RegRead32 returns 0 the fault is on
  //     OUR master side; if the pins themselves read 0 the CSR block returned 0.
  //   * axi_selftest writes a known pattern to a R/W config register and reads it
  //     back. CORE_VERSION is read-only, so a 0 there is ambiguous (dead path vs
  //     genuinely-0 register); a readback mismatch on a WRITABLE register is
  //     unambiguous proof the register path is dead, and a match proves it is alive
  //     and the version/status 0 is the MRMAC's own answer.
  // ------------------------------------------------------------------------
  task automatic dump_axi_pins(string tag);
    `INFO(("[AXI %s] araddr=0x%08h arvalid=%b arready=%b | rdata=0x%08h rresp=%b rvalid=%b rready=%b | awaddr=0x%08h awvalid=%b awready=%b wdata=0x%08h wvalid=%b wready=%b bresp=%b bvalid=%b",
           tag,
           system_tb.test_harness.mrmac_0.inst.s_axi_araddr,
           system_tb.test_harness.mrmac_0.inst.s_axi_arvalid,
           system_tb.test_harness.mrmac_0.inst.s_axi_arready,
           system_tb.test_harness.mrmac_0.inst.s_axi_rdata,
           system_tb.test_harness.mrmac_0.inst.s_axi_rresp,
           system_tb.test_harness.mrmac_0.inst.s_axi_rvalid,
           system_tb.test_harness.mrmac_0.inst.s_axi_rready,
           system_tb.test_harness.mrmac_0.inst.s_axi_awaddr,
           system_tb.test_harness.mrmac_0.inst.s_axi_awvalid,
           system_tb.test_harness.mrmac_0.inst.s_axi_awready,
           system_tb.test_harness.mrmac_0.inst.s_axi_wdata,
           system_tb.test_harness.mrmac_0.inst.s_axi_wvalid,
           system_tb.test_harness.mrmac_0.inst.s_axi_wready,
           system_tb.test_harness.mrmac_0.inst.s_axi_bresp,
           system_tb.test_harness.mrmac_0.inst.s_axi_bvalid),
          ADI_VERBOSITY_LOW);
  endtask

  // Continuous pin-level watcher: print every s_axi read data phase and every write
  // response as they happen on the MRMAC pins. This is the ground truth the VIP-level
  // log cannot give -- it sits directly on the IP boundary.
  //
  // THE DISCRIMINATOR (added 2026-07-29): every probe above sits on the SLAVE side, so
  // it can prove the MRMAC drives correct rdata but cannot say where that payload is
  // lost on the way back to RegRead32. `mng_axi_vip_M_AXI_RDATA` is the MASTER-side
  // read-data net inside test_harness -- and per generated test_harness.v it is the
  // SAME net as the interconnect's S00_AXI_rdata (:443 and :1064 both bind it), so one
  // probe covers both ends of the return path:
  //   * master net carries 0x00010007 while RegRead32 returns 0
  //       => payload reaches the VIP; loss is INSIDE the VIP/sequencer capture
  //          (PAYLOAD_RETURN / get_data_beat).
  //   * master net reads 0 while the MRMAC pin shows 0x00010007
  //       => the interconnect never delivers the read return to S00.
  // Sampled on the same posedge as the slave print so the two values in the log are
  // directly comparable at one timestamp.
  task automatic start_axi_pin_monitor();
    fork
      forever begin
        @(posedge system_tb.test_harness.mrmac_0.inst.s_axi_aclk);
        if (system_tb.test_harness.mrmac_0.inst.s_axi_rvalid === 1'b1)
          `INFO(("[AXI-PIN RD] t=%0t araddr=0x%08h rdata=0x%08h rresp=%b rready=%b | MASTER-SIDE rdata=0x%08h rvalid=%b rready=%b",
                 $time,
                 system_tb.test_harness.mrmac_0.inst.s_axi_araddr,
                 system_tb.test_harness.mrmac_0.inst.s_axi_rdata,
                 system_tb.test_harness.mrmac_0.inst.s_axi_rresp,
                 system_tb.test_harness.mrmac_0.inst.s_axi_rready,
                 system_tb.test_harness.mng_axi_vip_M_AXI_RDATA,
                 system_tb.test_harness.mng_axi_vip_M_AXI_RVALID,
                 system_tb.test_harness.mng_axi_vip_M_AXI_RREADY),
                ADI_VERBOSITY_LOW);
        if (system_tb.test_harness.mrmac_0.inst.s_axi_bvalid === 1'b1)
          `INFO(("[AXI-PIN WR] t=%0t awaddr=0x%08h wdata=0x%08h bresp=%b",
                 $time,
                 system_tb.test_harness.mrmac_0.inst.s_axi_awaddr,
                 system_tb.test_harness.mrmac_0.inst.s_axi_wdata,
                 system_tb.test_harness.mrmac_0.inst.s_axi_bresp),
                ADI_VERBOSITY_LOW);
      end
    join_none

    // Second, INDEPENDENT watcher triggered on the MASTER's own read-data handshake.
    // The slave-triggered print above samples the master net on the SLAVE's rvalid
    // edge; if the interconnect adds latency the master beat has simply not arrived
    // yet at that instant, which would look identical to a dropped payload. This
    // watcher fires on the master's own rvalid/rready, so a beat that DOES arrive is
    // always logged with its real value and timestamp. Absence of [AXI-MST RD] lines
    // while [AXI-PIN RD] lines appear is then hard proof the return never reached S00.
    fork
      forever begin
        @(posedge system_tb.test_harness.mrmac_0.inst.s_axi_aclk);
        if (system_tb.test_harness.mng_axi_vip_M_AXI_RVALID === 1'b1 &&
            system_tb.test_harness.mng_axi_vip_M_AXI_RREADY === 1'b1)
          `INFO(("[AXI-MST RD] t=%0t araddr=0x%08h rdata=0x%08h rresp=%b (master-side beat ACCEPTED)",
                 $time,
                 system_tb.test_harness.mng_axi_vip_M_AXI_ARADDR,
                 system_tb.test_harness.mng_axi_vip_M_AXI_RDATA,
                 system_tb.test_harness.mng_axi_vip_M_AXI_RRESP),
                ADI_VERBOSITY_LOW);
      end
    join_none
  endtask

  // Write a known pattern to a WRITABLE MRMAC register and read it back. MODE_REG_0
  // is used because it is a plain R/W config register that the bring-up rewrites
  // immediately afterwards anyway, so probing it cannot disturb the final config.
  task automatic axi_selftest();
    bit [31:0] rb;
    `INFO(("[AXI-SELFTEST] writing 0x%08h to MODE_REG_0 (0x%03h) then reading back",
           32'h4000_0A64, ADDR_MODE_REG_0), ADI_VERBOSITY_LOW);
    base_env.mng.sequencer.RegWrite32(`MRMAC_BA + ADDR_MODE_REG_0, 32'h4000_0A64);
    dump_axi_pins("after-selftest-write");
    base_env.mng.sequencer.RegRead32(`MRMAC_BA + ADDR_MODE_REG_0, rb);
    dump_axi_pins("after-selftest-read");
    if (rb === 32'h4000_0A64)
      `INFO(("[AXI-SELFTEST] PASS - readback 0x%08h matches. The s_axi/APB register path is ALIVE, so CORE_VERSION=0 / STAT_RX_STATUS=0 are the MRMAC's own answers, NOT a broken AXI path.", rb),
            ADI_VERBOSITY_LOW);
    else
      // NOTE (2026-07-29): this branch FIRED and its original wording ("the register
      // path is BROKEN") was WRONG. The [AXI-PIN RD] monitor proved the MRMAC drove the
      // correct 0x40000A64 back on its own s_axi_rdata pins in the very same
      // transaction. So a mismatch here does NOT mean the MRMAC/APB side is dead -- it
      // means OUR MASTER-SIDE READ CAPTURE lost the payload between the pins and
      // RegRead32's return value. Always cross-read the [AXI-PIN RD] line at the same
      // timestamp before drawing a conclusion from this message.
      `INFO(("[AXI-SELFTEST] MISMATCH - wrote 0x%08h read 0x%08h. Compare against the [AXI-PIN RD] line at this timestamp: if the pins carry the written value, the MRMAC/APB path is ALIVE and the fault is in our master-side read-data capture (VIP/sequencer or interconnect read return); only if the pins ALSO read 0 is the register path itself dead.", 32'h4000_0A64, rb),
            ADI_VERBOSITY_LOW);
  endtask

  task automatic mrmac_bringup();
    bit [31:0] rd;

    `INFO(("MRMAC bring-up: reading core version"), ADI_VERBOSITY_LOW);
    dump_mrmac_pins("pre-version");
    start_axi_pin_monitor();
    base_env.mng.sequencer.RegRead32(`MRMAC_BA + ADDR_CORE_VERSION, rd);
    dump_axi_pins("after-version-read");
    `INFO(("MRMAC core version = 0x%08h", rd), ADI_VERBOSITY_LOW);

    // Decisive discriminator: is the register path alive at all?
    axi_selftest();

    `INFO(("MRMAC bring-up: configuring 1x100GE"), ADI_VERBOSITY_LOW);
    base_env.mng.sequencer.RegWrite32(`MRMAC_BA + ADDR_RESET_REG_0,      32'h0000_0FFF);
    base_env.mng.sequencer.RegWrite32(`MRMAC_BA + ADDR_MODE_REG_0,       32'h4000_0A64); // 1x100GE
    base_env.mng.sequencer.RegWrite32(`MRMAC_BA + ADDR_CONFIG_RX_REG1_0, 32'h0000_0033);
    base_env.mng.sequencer.RegWrite32(`MRMAC_BA + ADDR_CONFIG_TX_REG1_0, 32'h0000_0C03);
    // FEC off on all four register banks (bank stride 0x1000), mirroring tb_orig.
    base_env.mng.sequencer.RegWrite32(`MRMAC_BA + ADDR_FEC_CFG_REG1_0 + 32'h0000, 32'h0);
    base_env.mng.sequencer.RegWrite32(`MRMAC_BA + ADDR_FEC_CFG_REG1_0 + 32'h1000, 32'h0);
    base_env.mng.sequencer.RegWrite32(`MRMAC_BA + ADDR_FEC_CFG_REG1_0 + 32'h2000, 32'h0);
    base_env.mng.sequencer.RegWrite32(`MRMAC_BA + ADDR_FEC_CFG_REG1_0 + 32'h3000, 32'h0);
    // release config reset, then a PM tick (latches the mode/config).
    base_env.mng.sequencer.RegWrite32(`MRMAC_BA + ADDR_RESET_REG_0, 32'h0000_0000);
    base_env.mng.sequencer.RegWrite32(`MRMAC_BA + ADDR_TICK_REG_0,  32'h0000_0001);

    `INFO(("MRMAC bring-up: config written, waiting for RX alignment"), ADI_VERBOSITY_LOW);
  endtask

  // ------------------------------------------------------------------------
  // Poll STAT_RX_STATUS bit0 (RX aligned). The register latches low, so
  // write-1-to-clear the sticky bits first, THEN read (exactly tb_orig.v). Poll
  // with a bounded number of attempts spaced on the free-running clock; robust
  // whether or not SIM_SPEED_UP shortened the internal align time.
  // ------------------------------------------------------------------------
  // Hierarchical probe of the MRMAC's HARDWARE status pins. Path confirmed from
  // the elaborated design: system_tb.test_harness.mrmac_0.inst.<pin> (BD cell
  // `mrmac_0` = test_harness_mrmac_0_0, whose sub-instance is `inst` =
  // test_harness_mrmac_0_0_wrapper). Printing these next to the s_axi register
  // value is what discriminates the two competing root causes:
  //   * pins say aligned but the REGISTER reads 0  -> s_axi/APB CSR read path bug
  //     (same path that returns CORE_VERSION=0),
  //   * pins say aligned=1 + local_fault=1 -> link-fault/sequencing, RX is fine.
  // The log IS the export -- no GUI/waveform round-trip needed.
  task automatic dump_mrmac_pins(string tag);
    `INFO(("[PINS %s] aligned=%b status=%b local_fault=%b recv_local_fault=%b remote_fault=%b internal_local_fault=%b hi_ber=%b tx_local_fault=%b block_lock=0x%05h",
           tag,
           system_tb.test_harness.mrmac_0.inst.stat_rx_aligned_0,
           system_tb.test_harness.mrmac_0.inst.stat_rx_status_0,
           system_tb.test_harness.mrmac_0.inst.stat_rx_local_fault_0,
           system_tb.test_harness.mrmac_0.inst.stat_rx_received_local_fault_0,
           system_tb.test_harness.mrmac_0.inst.stat_rx_remote_fault_0,
           system_tb.test_harness.mrmac_0.inst.stat_rx_internal_local_fault_0,
           system_tb.test_harness.mrmac_0.inst.stat_rx_hi_ber_0,
           system_tb.test_harness.mrmac_0.inst.stat_tx_local_fault_0,
           system_tb.test_harness.mrmac_0.inst.stat_rx_block_lock_0),
          ADI_VERBOSITY_LOW);
    `INFO(("[PINS %s] s_axi_aresetn=%b tx_core_reset=%b rx_core_reset=%b tx_core_clk=%b rx_core_clk=%b",
           tag,
           system_tb.test_harness.mrmac_0.inst.s_axi_aresetn,
           system_tb.test_harness.mrmac_0.inst.tx_core_reset,
           system_tb.test_harness.mrmac_0.inst.rx_core_reset,
           system_tb.test_harness.mrmac_0.inst.tx_core_clk,
           system_tb.test_harness.mrmac_0.inst.rx_core_clk),
          ADI_VERBOSITY_LOW);
  endtask

  // Wait for RX alignment.
  //
  // GATING SIGNAL (changed 2026-07-29): the loop now breaks on the MRMAC's HARDWARE
  // status pins, not on the s_axi register read. Reason, measured in the 2026-07-29 run
  // at one timestamp (t=168115ns):
  //     [POLL 50]     STAT_RX_STATUS reg = 0x00000000     <- what RegRead32 returned
  //     [PINS poll50] aligned=1 status=1 local_fault=0 ... block_lock=0xfffff
  //     [AXI-PIN RD]  rdata=0x00010007                    <- what the MRMAC drove
  // The MAC was fully up (all 20 PCS lanes locked, zero faults) while the register read
  // returned 0, so the register-gated loop could never break and always marched to the
  // FATAL below -- blocking the datapath scoreboard behind an unrelated master-side AXI
  // read-capture bug. 0x00010007 = bits{0,1,2,16} = status|block_lock|aligned|synced,
  // per the STAT_RX_STATUS_REG1_0 field map in mrmac_v3_1/component.xml.
  //
  // This is a DELIBERATE, TEMPORARY workaround, not a fix for that bug: the [AXI-MST RD]
  // probe added in start_axi_pin_monitor is what will localize it. Revert this to the
  // register poll once reads return real payload, because only the register path proves
  // the CSR plane works on real hardware where no hierarchical pin probe exists.
  //
  // The W1C write is KEPT: STAT_RX_STATUS bit0 is the sticky "aligned & no fault" latch,
  // and clearing it each pass preserves the exdes' clear-then-sample semantics so the
  // register value logged beside the pins stays meaningful for the AXI hunt.
  task automatic wait_rx_aligned();
    bit [31:0] rd;
    int        tries;
    tries = 0;
    forever begin
      base_env.mng.sequencer.RegWrite32(`MRMAC_BA + ADDR_STAT_RX_STATUS_0, 32'hFFFF_FFFF);
      base_env.mng.sequencer.RegRead32 (`MRMAC_BA + ADDR_STAT_RX_STATUS_0, rd);

      // Break on the pins. Require aligned AND status AND all-20-lanes block_lock, and
      // require the fault bits CLEAR, so this is strictly stronger than the old
      // rd[0] test (which was bit0/status alone) and cannot pass on a half-up link.
      if (system_tb.test_harness.mrmac_0.inst.stat_rx_aligned_0            === 1'b1 &&
          system_tb.test_harness.mrmac_0.inst.stat_rx_status_0             === 1'b1 &&
          system_tb.test_harness.mrmac_0.inst.stat_rx_block_lock_0         === 20'hFFFFF &&
          system_tb.test_harness.mrmac_0.inst.stat_rx_local_fault_0        === 1'b0 &&
          system_tb.test_harness.mrmac_0.inst.stat_rx_internal_local_fault_0 === 1'b0) begin
        `INFO(("MRMAC RX ALIGNED on HARDWARE PINS after %0d poll attempts (aligned=1 status=1 block_lock=0xfffff, faults clear). NOTE: s_axi STAT_RX_STATUS still read 0x%08h -- the master-side AXI read-capture bug is STILL OPEN; see [AXI-MST RD] lines to localize it.", tries, rd),
               ADI_VERBOSITY_LOW);
        dump_mrmac_pins("aligned");
        dump_axi_pins("aligned");
        break;
      end

      // Print the hardware pins beside the register value. Sparse (first few, then
      // every 50th) so a long poll cannot flood the log.
      if (tries < 5 || (tries % 50) == 0) begin
        `INFO(("[POLL %0d] STAT_RX_STATUS reg = 0x%08h", tries, rd), ADI_VERBOSITY_LOW);
        dump_mrmac_pins($sformatf("poll%0d", tries));
        dump_axi_pins($sformatf("poll%0d", tries));
      end
      tries++;
      if (tries > 2000)
        `FATAL(("MRMAC RX did not align after %0d poll attempts (pins: aligned=%b status=%b block_lock=0x%05h; last STAT_RX_STATUS reg=0x%08h)",
                tries,
                system_tb.test_harness.mrmac_0.inst.stat_rx_aligned_0,
                system_tb.test_harness.mrmac_0.inst.stat_rx_status_0,
                system_tb.test_harness.mrmac_0.inst.stat_rx_block_lock_0,
                rd));
      #1us;
    end
  endtask

  initial begin

    // ---- base harness ----------------------------------------------------
    // Current test_harness_env constructor (test_harness_env.sv): clocks + reset
    // + mng + ddr AXI VIP interfaces. There is no irq_vip in today's base harness
    // (test_harness_system_bd.tcl instantiates axi_intc + an external irq port but
    // no irq_vip, and emits no `IRQ/`IRQ_C_BA defines), so the old irq_vip_if args
    // are gone. Positional order matches dma_loopback/axis_sequencers.
    base_env = new("Base Environment",
                   `TH.`SYS_CLK.inst.IF,
                   `TH.`DMA_CLK.inst.IF,
                   `TH.`DDR_CLK.inst.IF,
                   `TH.`SYS_RST.inst.IF,
                   `TH.`MNG_AXI.inst.IF,
                   `TH.`DDR_AXI.inst.IF);

    env = new("MRMAC Real-IP Loopback Environment",
              `TH.`ETH_TX_AXIS.inst.IF,
              `TH.`ETH_RX_AXIS.inst.IF);

    setLoggerVerbosity(ADI_VERBOSITY_MEDIUM);

    // ---- GT clocks -------------------------------------------------------
    // Both GT-side clocks are generated by exact always-toggles in system_tb.sv
    // (NOT clk_vips: clk_vip_if.set_clk_frq stores an INTEGER-ns period, so the
    // 156.25 MHz refclk = 6.4 ns would truncate to 6 ns = 166.67 MHz and the GTY
    // PLL mis-locks). They are already free-running from t=0 -- nothing to pin or
    // start here. The 200 MHz freerun feeds the clk_wizard, which produces the
    // 390.625 MHz AXIS client clock, so there is no separate AXIS clk_vip either.

    base_env.start();
    env.start();

    // ---- neutralize the framework simulation watchdog --------------------
    // The encrypted Versal GTY power-up ramp (gtpowergood) needs far more SIM
    // time than the framework 1 ms watchdog allows (and its timer is bit[31:0]
    // ns, hard ceiling ~4.29 ms). Stop it; a heartbeat + a generous backstop in
    // the reset-done wait give progress visibility and a genuine-hang guard.
    base_env.simulation_watchdog.stop();

    base_env.sys_reset();

    // ---- wait for GT reset-done (heartbeat + generous backstop) ----------
    // INTF0_rst_all_in = ~gtpowergood, driven by a BD-internal inverter (mxfe-exact):
    // rst_all is held asserted from t=0 (gtpowergood=X/0) and releases the instant
    // powergood rises, self-sequencing the release off the power-up ramp. Terminate the
    // moment BOTH reset-done bits assert. Named fork so `disable gt_wait tears down
    // ONLY these three threads (not the VIP agents base_env.start()/env.start() forked).
    `INFO(("GT: rst_all = ~gtpowergood (BD inverter, self-sequenced); waiting for reset-done over serial loopback"), ADI_VERBOSITY_LOW);
    fork : gt_wait
      begin : heartbeat
        forever begin
          #50us;
          `INFO(("[MRMAC realip] t=%0t  gtpowergood=%b tx_reset_done=%b rx_reset_done=%b",
                 $time, system_tb.gtpowergood, system_tb.tx_reset_done, system_tb.rx_reset_done),
                ADI_VERBOSITY_LOW);
        end
      end
      begin : backstop
        #20ms;
        `FATAL(("[MRMAC realip] 20 ms SIM backstop reached without reset-done: gtpowergood=%b tx_reset_done=%b rx_reset_done=%b",
                system_tb.gtpowergood, system_tb.tx_reset_done, system_tb.rx_reset_done));
      end
      begin : wait_done
        // Match the validated ADI Versal reference bring-up order
        // (testbenches/project/mxfe/tests/test_program.sv:122-125): wait for
        // gtpowergood to toggle FIRST -- its comment reads "wait until gt_powergood
        // toggles ... otherwise it doesn't work" -- THEN reset-done. rst_all is
        // ~gtpowergood, so reset-done cannot precede powergood anyway, but this
        // mirrors the proven sequence and makes the power-up ramp observable.
        wait (system_tb.gtpowergood === 1'b1);
        `INFO(("GT: gtpowergood asserted @ %0t", $time), ADI_VERBOSITY_LOW);
        wait (system_tb.tx_reset_done === 1'b1);
        `INFO(("GT: tx_reset_done asserted @ %0t", $time), ADI_VERBOSITY_LOW);
        wait (system_tb.rx_reset_done === 1'b1);
        `INFO(("GT: rx_reset_done asserted @ %0t", $time), ADI_VERBOSITY_LOW);
      end
    join_any
    disable gt_wait;

    if (system_tb.gtpowergood !== 1'b1)
      `ERROR(("GT: gtpowergood not asserted (got %b)", system_tb.gtpowergood));

    // ---- exdes-EXACT double reset: re-reset the MRMAC core against a STABLE GT
    // ---------------------------------------------------------------------
    // ROOT CAUSE (confirmed 2026-07-28): our core version read returned
    // 0x00000000, while the Xilinx exdes -- running the SAME encrypted MRMAC IP
    // -- reads Core_Version=1 (mrmac_0_ex/.../simulate.log:16). The difference is
    // the exdes does a DOUBLE reset (mrmac_0_exdes_tb.v:405-434): it waits for the
    // FIRST GT lock, then RE-asserts pl_resetn + gt_reset_all together, waits for a
    // SECOND `@(posedge stat_mst_reset_done)` (== gt_rx_reset_done, exdes.sv:2056),
    // and only THEN reads the version. The MRMAC core latches its config/version
    // init off the GT core clocks, which are only stable AFTER lock; releasing the
    // core reset DURING the first power-up ramp (as our single-reset flow did)
    // leaves the register block uninitialized -> version 0, no RX alignment, AXIS X.
    //
    // A first attempt at this re-sync READ THE VERSION TOO EARLY: it waited on
    // (tx_done && rx_done) which were still stale-HIGH from the first lock, so the
    // wait returned instantly and version was sampled mid-re-lock (still 0). This
    // version watches the FALLING edge first (reset actually took -> reset_done
    // drops) and only then the RISING edge (genuine 2nd lock), exactly mirroring
    // the exdes `@(posedge stat_mst_reset_done)`.
    //
    // Handle mapping: our BD ties gt_reset_all = ~gtpowergood (a BD inverter, NOT a
    // TB reg), so we cannot drive gt_reset_all directly. base_env.sys_reset() pulses
    // sys_rst_vip, which the BD fans out to BOTH sys_rstgen -> mrmac_0/s_axi_aresetn
    // AND mac_rstgen -> pl_resetn + gtwiz/QUAD0_s_axi_lite_resetn. The gtwiz
    // s_axi_lite_resetn pulse is what drops reset_done (proven by the prior run:
    // sys_reset@34405ns -> reset_done=0 by 50us -> re-locked by 100us). gtpowergood /
    // INTF0_rst_all_in are untouched, so the GT PMA stays powered and re-lock is fast.
    `INFO(("GT locked once; applying exdes-exact double reset (re-reset MRMAC/gtwiz-axil against stable GT PMA)"), ADI_VERBOSITY_LOW);
    base_env.sys_reset();

    // (1) wait for reset_done to actually DROP (reset took hold), THEN rise again.
    //     The drop-detect bound is GENEROUS on purpose: the prior run measured the
    //     drop within ~15.6 us of sys_reset (fired @34405ns, reset_done=0 by the
    //     50000ns heartbeat), so a short bound would fire BEFORE the drop and
    //     re-introduce the read-too-early race. 60 us >> 15.6 us observed; it only
    //     falls through if the drop is genuinely never observable. gtpowergood is
    //     NOT disturbed by this reset (prior run: gtpowergood stayed 1 throughout),
    //     so this is a reset-controller re-sequence, not a full PMA power-up.
    fork : rst_drop
      begin wait (system_tb.rx_reset_done === 1'b0 || system_tb.tx_reset_done === 1'b0);
            `INFO(("GT reset-done dropped after re-reset @ %0t (tx=%b rx=%b)", $time,
                   system_tb.tx_reset_done, system_tb.rx_reset_done), ADI_VERBOSITY_LOW); end
      begin #60us;
            `INFO(("GT reset-done did not drop within 60us of re-reset (unexpected: last run dropped @~15.6us); proceeding"),
                  ADI_VERBOSITY_LOW); end
    join_any
    disable rst_drop;

    // (2) wait for the genuine SECOND lock (reset_done back HIGH on both), with a
    //     backstop so a failed re-lock FATALs instead of hanging (the outer gt_wait
    //     backstop was already disabled above).
    fork : rst_rise
      begin wait (system_tb.tx_reset_done === 1'b1 && system_tb.rx_reset_done === 1'b1);
            `INFO(("GT re-locked (2nd lock) @ %0t: gtpowergood=%b tx=%b rx=%b; settling before version read",
                   $time, system_tb.gtpowergood, system_tb.tx_reset_done, system_tb.rx_reset_done), ADI_VERBOSITY_LOW); end
      begin #5ms;
            `FATAL(("GT did not re-lock within 5ms after double-reset: gtpowergood=%b tx=%b rx=%b",
                    system_tb.gtpowergood, system_tb.tx_reset_done, system_tb.rx_reset_done)); end
    join_any
    disable rst_rise;
    #4us; // ~400 s_axi cycles @ 100 MHz, matching exdes `repeat(400) @(posedge pl_clk)`

    // ---- MRMAC MAC bring-up over s_axi + RX alignment --------------------
    mrmac_bringup();
    wait_rx_aligned();

    // ---- byte-exact data loopback ----------------------------------------
    env.configure();
    env.run();

    // Per-batch inactivity watchdog. Generous (2 ms) to cover the real MAC+PCS+GT
    // round-trip latency on top of the AXIS transfer time.
    send_data_wd = new("MRMAC Real-IP Loopback Watchdog", 2000000, "Send data");
    send_data_wd.start();

    env.eth_tx_axis_agent.sequencer.start();

    repeat (10) begin
      send_data_wd.reset();

      // 1..5 frames per burst, each 1..24 beats (64B..1536B).
      repeat ($urandom_range(1,5)) begin
        env.eth_tx_axis_agent.sequencer.add_xfer_descriptor_byte_count(
          $urandom_range(1,24) * BEAT_BYTES, 1 /*gen_last*/, 0 /*gen_sync=0 => tuser/error held 0*/);
      end

      #($urandom_range(1,10)*1us);

      env.eth_tx_axis_agent.sequencer.clear_descriptor_queue();
      env.eth_tx_axis_agent.sequencer.wait_empty_descriptor_queue();

      // Byte-exact check: block until every transmitted byte has been matched by
      // a received byte (scoreboard fires byte_streams_empty when balanced). Any
      // mismatch is flagged by the scoreboard's compare_transaction() -> error().
      env.scoreboard_inst.wait_until_complete();

      `INFO(("Packet batch finished."), ADI_VERBOSITY_LOW);
    end

    send_data_wd.stop();

    #100ns;

    `INFO(("========================================"), ADI_VERBOSITY_NONE);
    `INFO(("  MRMAC REAL-IP LOOPBACK PASS: byte-exact round trip through real MRMAC+GT"), ADI_VERBOSITY_NONE);
    `INFO(("========================================"), ADI_VERBOSITY_NONE);

    env.stop();
    base_env.stop();
    // Both GT-side clocks are TB always-toggles (no VIP) -- they run until $finish.

    `INFO(("Test bench done!"), ADI_VERBOSITY_NONE);
    $finish();

  end

endprogram
