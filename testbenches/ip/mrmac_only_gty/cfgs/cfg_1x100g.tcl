global ad_project_params

# ---------------------------------------------------------------------------
# MRMAC-ONLY 1x100G loopback configuration (VCK190 / GTY).
#
# WHY THIS BENCH EXISTS
# ---------------------
# The AMD example design (/scratch/corundum_vcu118/mrmac_0_ex) PASSES end-to-end:
# Core_Version=1, RX ALIGNED, TX/RX counters 28 pkts / 8624 bytes each, "Test PASS"
# at 208670 ns. Our sibling bench mrmac_realip_loopback_gty -- same real mrmac_0 +
# gtwiz_versal + clk_wizard + mrmac_versal_glue, but with the whole Corundum
# datapath (AXIS VIPs -> cmac_pad -> axis_adapter 512->384 -> mrmac_{tx,rx}_adapt ->
# shim FIFOs) and an AXI interconnect in front of s_axi -- does NOT.
#
# This bench removes EVERY difference that is ours, so it either passes (proving the
# MRMAC/GT/glue plane is sound and the fault is in the shim/interconnect) or it
# fails (proving the fault is in the MRMAC/GT/glue plane and the shim is innocent).
# Either outcome halves the search space, which is why it is worth a whole sibling
# directory rather than a flag on the existing one.
#
# It DID pass, byte-exact, and that stripped configuration is frozen at
# baseline_pass/ (7 sources + the evidence log + checksums). The Corundum layer is
# now being re-introduced ONE PIECE AT A TIME on top of it, the user testing each
# increment before the next is added -- so a failure is attributable to the piece
# just added.
#   Increment 1 restored mrmac_tx_adapt + mrmac_rx_adapt (and with them the glue's
#     AXIS pack/unpack path, which a BD net cannot substitute for).
#   Increment 2 restored the shim's two axis_fifo instances (TX store-and-forward
#     frame FIFO, RX elastic dropping FIFO) and its three sync_reset instances.
#   Increments 3+4+5 land TOGETHER, because they cannot be separated:
#     3 = the four axis_adapter instances (512->64->384 on TX, 384->64->512 on RX),
#     4 = cmac_pad, which asserts DATA_WIDTH==512 and $finish-es otherwise, so it can
#         only sit at a 512-bit interface -- and reaching 512 bits from the MRMAC's
#         384-bit client bus IS increment 3. Splitting them would mean landing a
#         padder with nowhere to sit.
#     5 = the PTP set (mrmac_ptp_ts_cvt x4, mrmac_ptp_sync x2, mac_ts_insert x1),
#         which forces tuser back to the shim's real 17 (TX) / 81 (RX) bits and so
#         must land with the adapters and FIFOs that carry it.
#   With those, the ENTIRE shim datapath is present. Read two consequences plainly:
#     (a) cmac_pad is a functional NO-OP at PKT_BYTES=256 -- every beat is already
#         full, so this proves it is TRANSPARENT, not that the padder works.
#         Exercising the pad needs PKT_BYTES < 60, a separate experiment.
#     (b) increment 5 REVERSES two of the seven *** EXDES *** deltas the baseline
#         PASS was built on: MAC_PORT0_ENABLE_TIME_STAMPING_C0 0->1 with
#         PORT0_1588v2_Operation_MODE_C0 {No operation}->{2-step}, and tx_ts_clk /
#         rx_ts_clk stop being GND (they now take clk_wizard/clk_out2 at 250 MHz --
#         MRMAC caps the ts clock at 50-350 MHz per PG314, so it CANNOT be the
#         390.625 MHz AXIS clock). This is the increment most likely to disturb a
#         passing run; if it regresses, those config lines in system_bd.tcl section 1
#         are the first thing to revert. They carry explicit revert instructions.
#   Corundum's PTP time source (ptp_clock inside fpga_core) does not exist here, so a
#   local free-running counter substitutes (mrmac_shim_ptp_timegen). That tests the
#   STRUCTURE -- 80<->55 format conversion, the PG314 st_sync handshake, the AXIS ->
#   ts_clk crossing, MRMAC accepting the load and returning stamps, mac_ts_insert
#   threading an 81-bit tuser -- and NOT time accuracy, which a locally generated
#   timebase has nothing to be accurate against. The verdict stays byte-exactness.
#
# STRIPPED, relative to mrmac_realip_loopback_gty (with increments 1-5 already
# re-added, marked [BACK]):
#   * the Corundum MAC shim (corundum/mrmac_gty_wrapper / mrmac_dut): its whole
#     DATAPATH is now [BACK] -- mrmac_tx_adapt + mrmac_rx_adapt as of increment 1,
#     the two axis_fifo and three sync_reset instances as of increment 2, and
#     cmac_pad + the four axis_adapter width converters + the seven PTP cells as of
#     increments 3/4/5, all real library RTL with the shim's own parameters and now
#     its real tuser widths (17 on TX, 81 on RX). What is still out is the shim as a
#     PACKAGED IP: mqnic_port_map_mac_axis, mac_rstgen, and the component.xml/
#     LIB_DEPS packaging -- the cells are instantiated individually here so that a
#     failure names one module,
#   * the glue's AXIS pack/unpack path -- [BACK] as of increment 1, and not
#     optionally: the adapters' packed 384b/66b bus cannot reach mrmac_0's
#     per-segment pins any other way, since a BD net can neither slice nor
#     concatenate,
#   * both axi4stream_vip cells + the byte scoreboard + environment.sv,
#   * the AXI interconnect / management VIP in front of s_axi (ad_cpu_interconnect)
#     -- s_axi is now driven by plain TB wires with the exdes's own axi_read/
#     axi_write tasks, so a register read cannot be mis-decoded or mis-captured,
#   * the ENTIRE base test harness (CUSTOM_HARNESS=1): no sys/dma/ddr clocks, no
#     mng/ddr VIPs, no watchdog.
# KEPT (real, encrypted, unchanged): mrmac_0, gtwiz_versal, clk_wizard, and
# mrmac_versal_glue -- the glue as the GT clock/reset plane (refclk buffer,
# MBUFG_GTs, serdes width adaptation), which is precisely the part no simpler bench
# can replace, plus its AXIS pack/unpack again since increment 1 and its PTP
# pack/unpack since increment 5. What remains GND-swept on the glue is now only the
# pause/flow-control group (shim_ctl_{tx,rx}_pause_*), whose driver
# mqnic_port_map_mac_axis is a later rung of the ladder.
#
# See memory: [[mrmac-double-reset-requirement]], [[mrmac-100g-clocking-topology]],
# [[mrmac-gtwiz-framework-derisk]], [[mrmac-mac-enable-via-axi]].
# ---------------------------------------------------------------------------

# Skip the ADI base test harness entirely (adi_sim.tcl:48). Without this,
# test_harness_system_bd.tcl builds the sys/dma/ddr clock+reset plane and the
# mng/ddr AXI VIPs, and the test program must construct test_harness_env before
# anything runs. This bench needs none of it: its only clocks are the two
# TB-generated GT clocks and the clk_wizard outputs, and its only register access
# is over plain TB wires. Precedent: testbenches/ip/data_offload_2.
set ad_project_params(CUSTOM_HARNESS) 1

# Target the VCK190 (Versal AI Core, xcvc1902, GTY) -- same part as the passing
# reference example (xcvc1902-vsva2197-2MP-e-S). Note that with CUSTOM_HARNESS=1
# this value is informational only: system_project.tcl passes the part to
# adi_sim_project_xilinx explicitly (adi_sim_project_xilinx does NOT decode
# FPGA_BOARD -- see [[adi-sim-part-must-be-explicit]]).
set ad_project_params(FPGA_BOARD) "vck190"

set ad_project_params(MODE) "1x100G"

# GT reference-clock frequency in Hz. 156.25 MHz is load-bearing: the GTY PLL is
# configured TX/RX_REFCLK_FREQUENCY 156.25, so the refclk MUST be exactly that or
# it will not lock. Generated as a plain always-toggle in system_tb.sv (a clk_vip
# truncates the period to an integer ns, turning 6.4 ns into 6 ns = 166.67 MHz).
set ad_project_params(GT_REFCLK_HZ) 156250000

# GT-wizard free-running clock (GT reset FSM, MRMAC s_axi, clk_wizard clk_in1).
#
# 100 MHz -- and this now MATCHES the passing reference rather than diverging from
# it. The reference exdes drives .gtwiz_freerun_clk(s_axi_aclk) (exdes.sv:1319) and
# its tb generates pl_clk with `forever #5000.00` at a 1ps timebase
# (exdes_tb.v:548-550) = 10 ns period = 100 MHz, while its gtwiz .xci still
# declares APB3_CLK_FREQUENCY=200. So the encrypted reset controller's
# P_FREERUN_FREQUENCY=200 assumption is evidently NOT fatal at 100 MHz -- the
# reference reaches full PASS this way. This retires the earlier "200 MHz freerun
# is REQUIRED for gtpowergood" theory (that observation was confounded with
# SIM_SPEEDUP=true).
set ad_project_params(FREERUN_HZ) 100000000

# ---------------------------------------------------------------------------
# Traffic shape. Drives the pkt_gen/pkt_chk parameters (mrmac_flat512_pkt_gen/chk
# since increment 3 -- the fixtures now sit at the 512-bit fpga_core boundary, since
# that is where cmac_pad has to be) and, via +define+, the test program's
# counter-check expectations.
#
# 256 bytes is not a multiple of the 48-byte segmented beat (6 segments x 8 B), so
# the beat that reaches mrmac_0 is PARTIAL -- which exercises the tkeep_user[7:0]
# per-byte-valid encoding on tlast rather than trivially keeping all bytes. At the
# 512-bit end it is exactly 4 full beats, so nothing is lost: the partial-beat case
# is created by the width conversion itself and is what the adapters must get right.
# 256 is also comfortably above the 60-byte Ethernet minimum, so the MAC never pads
# (padding would change the length and break a byte-exact compare for a reason
# unrelated to the link) -- which is the same reason cmac_pad is inert here.
#
# NUM_PKTS 4096 (was 16). The generator now runs at 512 bits (increment 3), so a
# 256-byte frame is 4 data beats + 4 IFG beats = 8 beats per frame; at 390.625 MHz
# that is 32768 beats = ~84 us of traffic (16 frames was well under 1 us) -- still
# small next to the GT power-up ramp that dominates this bench's wall clock, since
# SIM_SPEEDUP is false. The MRMAC-side beat count is higher (256 B / 48 B = 6 beats
# per frame) because the width conversion is what changes it; both ends see all 4096
# frames. What the longer run buys, and why it is worth having:
#   * the TX FIFO's 512-beat ring (ADDR_WIDTH = $clog2(16384/48) = 9) now WRAPS
#     tens of times instead of never reaching half full, so pointer wrap and the
#     full/empty corner get exercised at all,
#   * frame index appears in the payload as pkt*0x11 mod 256, so it repeats every
#     16 frames -- 4096 frames means the checker's per-frame seed rolls over 256
#     times, and a frame delivered out of order or duplicated one period late is
#     still caught by its byte offsets, and
#   * the MRMAC statistics counters reach 4096 / 1048576 bytes, well past any
#     single-register rollover an eight-frame run could not reach.
# It also lengthens the interval over which a rare bit error would have to stay
# absent: 16 frames passing is consistent with a link that fails 1-in-100.
#
# If a run needs to be quick again (e.g. bisecting a build problem rather than
# checking the link), drop this back to 16 -- everything downstream reads it from
# here, including the test program's expectations via +define+ and its traffic
# backstop, so no other file needs editing.
# ---------------------------------------------------------------------------
set ad_project_params(NUM_PKTS)  4096
set ad_project_params(PKT_BYTES) 256

# Inter-frame gap, in idle beats between frames at the GENERATOR's width, which is
# 512 bits since increment 3. The MAC needs idle cycles to insert the inter-packet
# gap; 4 beats of 64 bytes is generous. Note the TX frame FIFO can absorb this gap
# (see mrmac_shim_fifo.v) -- but only for frames that queued while MRMAC was
# de-asserting tready, i.e. only when the MAC was pacing the stream itself.
set ad_project_params(IFG_BEATS) 4

# Does the RX AXIS byte stream carry the 4 FCS bytes?
#
# 0 here means "FCS IS present in the RX stream", matching CONFIG_RX_REG1 =
# 0x00000033 -- the exact value the passing exdes writes (exdes_tb.v). Bit 1
# (ctl_rx_delete_fcs) is 1 in 0x33, i.e. FCS deletion IS enabled... but the
# checker's STRIP_FCS parameter is what must agree with the observed stream, and a
# disagreement is deliberately made obvious: it shows up as a LENGTH error on
# EVERY packet (got=260 exp=256, or vice versa) rather than as data corruption. So
# if the first run reports LENGTH errors on EVERY packet with a 4-byte delta and
# no data mismatches, flip this value -- that is a checker-expectation fix, not a
# link fault. Starting at 1 (expect no FCS) to match ctl_rx_delete_fcs=1.
set ad_project_params(STRIP_FCS) 1
