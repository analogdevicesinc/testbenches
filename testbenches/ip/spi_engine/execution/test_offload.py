"""Offload interaction (boundary view only).

Full offload semantics belong to the offload IP (EXEC-OOS-02); at this
module's boundary only the s_offload_active effect is observable: SDO prefetch
readiness. These tests drive s_offload_active and observe the sdo_data_ready
handshake timing, plus confirm the produced spi-bus waveform is identical in
offload and FIFO mode for the same command/SDO sequence (EXEC-OFF-03).
"""

import os

import cocotb
from cocotb.triggers import ClockCycles

from framework.spi import instructions as ins
from framework.reset import apply_reset
from tb_env import ExecutionTB

# Build-time lane count (DUT generic). Several tests below are only meaningful at
# certain lane counts and are skipped otherwise.
_NSD = int(os.environ.get("PARAM_NUM_OF_SDIO", 1))


def _partial_masks(nsd, *, min_active, rng=None, cap=16):
    """Lane masks that are NOT all-active (the sub-mask class), over ``nsd`` lanes.

    Returns every mask with ``min_active <= popcount < nsd``. The offload lane-mask
    bug is a property of the whole class, so a test sweeps this set rather than one
    mask. Enumerates fully when the set is small (covers the whole sweep, nsd<=4);
    above ``cap`` it returns a seeded sample keeping the sparsest and densest
    extremes, so large-``nsd`` builds stay bounded without losing the corners.
    """
    full = (1 << nsd) - 1
    cand = [m for m in range(1, full) if bin(m).count("1") >= min_active]
    if rng is None or len(cand) <= cap:
        return cand
    lo = min(cand, key=lambda m: bin(m).count("1"))
    hi = max(cand, key=lambda m: bin(m).count("1"))
    rest = [m for m in cand if m not in (lo, hi)]
    return sorted({lo, hi, *rng.sample(rest, cap - 2)})


def _all_masks(nsd, *, rng=None, cap=16):
    """Every SDO lane mask value for ``nsd`` lanes: the full mask plus every
    partial sub-mask, including each single-lane mask.

    EXEC-OFF-02/EXEC-OFF-04 gate offload prefetch on whether the active SDO
    lane mask is *fully configured*, not on how many lanes it addresses, so
    the boundary space to sweep is the full mask union every partial
    sub-mask (at ``nsd == 1`` the only possible mask is the full mask).
    """
    full = (1 << nsd) - 1
    return sorted({full, *_partial_masks(nsd, min_active=1, rng=rng, cap=cap)})


@cocotb.test()
async def test_offload_prefetch_readiness(dut):
    """With s_offload_active=1 the engine may prefetch SDO before the write cmd.

    Baseline note: the engine only requests SDO data (asserts sdo_data_ready) in
    FIFO mode *after* a write instruction has been seen; that gating latches and
    is not cleared by reset, so we first issue a non-transfer (config) command to
    establish a clean "no recent write instruction" state. Using this stimulus
    knowledge to set up the baseline is legitimate; the pass/fail check is on the
    boundary sdo_data_ready handshake in each mode.
    """
    tb = ExecutionTB(dut)
    await tb.start()
    wl = tb.params["DATA_WIDTH"]

    # Clean baseline: a non-transfer command so no write instruction is pending.
    await tb.issue(ins.config_clk_div(0))
    await tb.wait_idle()

    # FIFO mode: with no write instruction pending, the engine must NOT prefetch.
    # sdo_data's value is a placeholder for the handshake-timing check below
    # (only sdo_data_ready's timing is asserted here, never the data value
    # itself), so it is a fixed, arbitrary bit pattern rather than a sample.
    tb.set_offload_active(False)
    dut.sdo_data_valid.value = 1
    dut.sdo_data.value = 0xA5 & ((1 << wl) - 1)
    fifo_prefetch = await tb.observe_sdo_ready_before_cmd(window=20)
    # REQ: EXEC-OFF-01 - when inactive, engine waits for the write instruction
    tb.sb.compare(0, "fifo_no_prefetch", False, fifo_prefetch)

    # Offload mode: the engine may assert sdo_data_ready ahead of any command.
    tb.set_offload_active(True)
    offload_prefetch = await tb.observe_sdo_ready_before_cmd(window=40)
    # REQ: EXEC-OFF-01 - when active, engine may prefetch SDO before the write cmd
    tb.sb.compare(0, "offload_prefetch", True, offload_prefetch)
    dut.sdo_data_valid.value = 0
    tb.set_offload_active(False)
    tb.sb.assert_no_errors()


# EXEC-OFF-02/EXEC-OFF-04 (requirements.md): offload SDO prefetch is gated
# on whether the active SDO lane mask is *fully configured* - i.e. the module has
# finished applying that mask to its internal lane sequencing - not on how many
# lanes the mask addresses. Swept over the full mask AND every partial sub-mask
# (including each single-lane mask), so the whole boundary space is covered and
# an RTL fix that special-cases lane count (rather than configuration
# completeness) does not pass while the class still fails.
@cocotb.test()
async def test_offload_prefetch_gated_by_mask_configuration(dut):
    """Offload SDO prefetch tracks mask *configuration completeness*, not lane count.

    Before a just-reconfigured SDO lane mask is fully configured, the module
    must source SDO data only via the write instruction - no prefetch
    (EXEC-OFF-04). Once that mask is fully configured, prefetch must be
    enabled for it, whether it addresses all lanes, a partial sub-mask, or a
    single lane (EXEC-OFF-02).
    """
    tb = ExecutionTB(dut)
    await tb.start()
    wl = tb.params["DATA_WIDTH"]
    nsd = tb.num_sdio
    rng = tb.rc.derive("off_mask_configuration")
    # Same margin used elsewhere in this file (see test_offload_submask_no_stream_
    # corruption's _OFF_PHASES) to let the ~NUM_OF_SDIO-cycle lane-scan rebuild
    # finish before treating the mask as fully configured.
    settle_cycles = nsd + 4

    for mask in _all_masks(nsd, rng=rng):
        # Reset between masks so latched word_ready/prefetch state from the prior
        # iteration cannot hold sdo_data_ready low (or high) and mask a fresh result.
        await apply_reset(dut, cycles_before=0, hold=3)
        tb.after_reset()
        # Clean baseline (see test_offload_prefetch_readiness): a non-transfer
        # command clears any pending write-instruction / assembler state.
        await tb.issue(ins.config_clk_div(0))
        await tb.wait_idle()
        await tb.issue(ins.config_sdo_lane_mask(mask))
        await tb.wait_idle()

        # One cycle after the reconfigure instruction completes, the lane-scan
        # rebuild cannot have finished yet: the mask is still not yet fully
        # configured, regardless of how many lanes it addresses. Probe briefly,
        # then drop offload/valid back down before the settle window below -
        # racing SDO data across the rebuild is a known corruption hazard (see
        # test_offload_submask_no_stream_corruption), not something this
        # readiness-only probe should provoke.
        tb.set_offload_active(True)
        dut.sdo_data_valid.value = 1
        dut.sdo_data.value = 0x5A & ((1 << wl) - 1)
        pf_before = await tb.observe_sdo_ready_before_cmd(window=1)
        # REQ: EXEC-OFF-04 - not yet fully configured: write-instruction only, no prefetch
        tb.sb.compare(0, f"offload_prefetch_pre_cfg_mask_{mask:#04x}", False, pf_before)
        dut.sdo_data_valid.value = 0
        tb.set_offload_active(False)

        # Let the rest of the settle window elapse (offload inactive, no SDO
        # data in flight) so the mask is now cleanly fully configured, then
        # confirm prefetch is enabled for it - regardless of mask.
        remaining = settle_cycles - 1
        if remaining > 0:
            await ClockCycles(dut.clk, remaining)
        tb.set_offload_active(True)
        dut.sdo_data_valid.value = 1
        dut.sdo_data.value = 0x5A & ((1 << wl) - 1)
        pf_after = await tb.observe_sdo_ready_before_cmd(window=40)
        # REQ: EXEC-OFF-02 - fully configured: prefetch enabled for that mask
        tb.sb.compare(0, f"offload_prefetch_post_cfg_mask_{mask:#04x}", True, pf_after)

        dut.sdo_data_valid.value = 0
        tb.set_offload_active(False)

    tb.sb.assert_no_errors()


@cocotb.test()
async def test_offload_waveform_matches_fifo(dut):
    """Same command/SDO sequence yields identical bus waveform in both modes."""
    tb = ExecutionTB(dut)
    await tb.start()
    wl = tb.params["DATA_WIDTH"]
    rng = tb.rc.derive("off_wave")
    n = rng.randint(2, 6)
    data = [rng.randrange(1 << wl) for _ in range(n * tb.num_sdio)]

    # FIFO mode (offload inactive).
    tb.set_offload_active(False)
    res_fifo = await tb.run_transfer(n=n, write=True, read=False, sdo_words=data)
    fifo_words = list(tb.bus_mon.sdo_words)
    tb.sb.compare_sequences(res_fifo.sdo_words, fifo_words, field="fifo_wave")

    # Offload mode: same commands and data, s_offload_active=1.
    allcs = (1 << tb.params["NUM_OF_CS"]) - 1
    await tb.issue(ins.chipselect(allcs, delay=1))
    await tb.wait_idle()
    tb.bus_mon.words.clear()
    tb.set_offload_active(True)
    res_off = await tb.run_transfer(n=n, write=True, read=False, sdo_words=data)
    offload_words = list(tb.bus_mon.sdo_words)
    tb.set_offload_active(False)
    # REQ: EXEC-OFF-03 - bus waveform identical in offload vs FIFO mode
    tb.sb.compare_sequences(res_off.sdo_words, offload_words, field="offload_wave")
    tb.sb.compare_sequences(fifo_words, offload_words, field="fifo_vs_offload")
    tb.sb.assert_no_errors()


async def _offload_vs_fifo_sdo(tb, mask, phase, *, n=4):
    """Drive one write transfer under ``mask`` in FIFO then offload mode; compare
    the resulting SDO bus words. ``phase`` delays data arrival after the offload
    mask re-pulse, sweeping which cycle of the lane-scan rebuild consumes the
    prefetched word. Records mismatches in the scoreboard under a mask/phase-tagged
    field. Factored out so the test can sweep both the mask and the timing phase."""
    dut = tb.dut
    wl = tb.params["DATA_WIDTH"]
    nsd = tb.num_sdio
    rng = tb.rc.derive(f"off_submask_corrupt_{mask:#04x}_{phase}")
    data = [rng.randrange(1 << wl) for _ in range(n * nsd)]

    # CAUTION: do NOT add a reset here. The corruption needs a warm assembler
    # whose lane map is rebuilt while a prefetched word is in flight (the realistic
    # "reconfigure the mask mid-offload" case); a reset gives a cold map that maps
    # the early word correctly and hides the bug. Per-iteration isolation comes
    # from the FIFO leg below re-establishing the mask and clearing the bus monitor.

    # FIFO mode (offload inactive) under the mask: golden bus reference.
    tb.bus_mon.words.clear()
    tb.set_offload_active(False)
    await tb.issue(ins.config_sdo_lane_mask(mask))
    await tb.wait_idle()
    res_fifo = await tb.run_transfer(n=n, write=True, read=False, sdo_words=data)
    fifo_words = list(tb.bus_mon.sdo_words)
    laid_out = list(res_fifo.sdo_words)  # canonical period-major, active-lane-minor

    # Offload mode: same command/data/mask, but pre-stream SDO so valid data is in
    # flight DURING the lane-mask scan, exercising prefetch against a stale lane map.
    allcs = (1 << tb.params["NUM_OF_CS"]) - 1
    await tb.issue(ins.chipselect(allcs, delay=1))
    await tb.wait_idle()
    tb.bus_mon.words.clear()
    tb.set_offload_active(True)
    # Re-pulse the lane mask to (re)start the scan; do NOT wait_idle - we want data
    # racing the scan window.
    await tb.issue(ins.config_sdo_lane_mask(mask))
    # Shift data arrival by `phase` cycles so the early consumption lands at a
    # different point of the scan rebuild each iteration.
    if phase:
        await ClockCycles(dut.clk, phase)
    # Extra padding words guard against underrun if prefetch pulls more than the
    # transfer needs (surplus never reaches the bus).
    padded = laid_out + [rng.randrange(1 << wl) for _ in range(2 * nsd)]
    tb.start_sdo_stream(padded, min_gap=0, max_gap=0)
    await tb.issue(ins.transfer(n - 1, write=True, read=False), sdo_data=data)
    await tb.wait_idle()
    await ClockCycles(dut.clk, 3)
    offload_words = list(tb.bus_mon.sdo_words)
    tb.abort_streams()
    tb.set_offload_active(False)

    # REQ: EXEC-OFF-03 - offload SDO bus data must match FIFO mode
    tb.sb.compare_sequences(fifo_words, offload_words,
                            field=f"offload_sdo_mask_{mask:#04x}_ph{phase}")


# Number of timing phases swept per mask: the offset (in core clocks) between the
# offload lane-mask re-pulse and data arrival. The corruption depends on which
# cycle of the ~NUM_OF_SDIO-cycle lane-scan rebuild consumes the prefetched word,
# so a single phase can miss it (e.g. phase 0 happens to be clean for some masks).
# NUM_OF_SDIO+3 covers the whole rebuild window plus pipeline slack.
_OFF_PHASES = _NSD + 3


# EXEC-OFF-03 (spi_engine_execution.rst): the SDO bus data must be identical in
# offload and FIFO mode for the same command/data/mask. Swept over the whole
# observable partial-mask class (>=2 active lanes) AND over the timing phase, so
# neither a mask-specific RTL patch nor an incidental timing alignment can pass
# while the class still corrupts. Verilator's speed makes the full mask x phase
# sweep cheap; the sweep stops at the first failing point.
# Needs nsd>=3: only then does a partial mask leave >=2 active lanes, so a lane
# mismap is observable on the bus; at nsd<=2 the mismap is unobservable, so skip.
@cocotb.test(skip=_NSD < 3)
async def test_offload_submask_no_stream_corruption(dut):
    """Every observable partial mask x timing phase: offload SDO bus == FIFO (EXEC-OFF-03)."""
    tb = ExecutionTB(dut)
    await tb.start()
    rng = tb.rc.derive("off_submask_masks")
    # >=2 active lanes: a single active lane is an identity map, so a slide is
    # invisible - those are covered by the prefetch-readiness test above.
    for mask in _partial_masks(tb.num_sdio, min_active=2, rng=rng):
        # CAUTION: do NOT collapse this to one phase. The corruption is a timing
        # race; some (mask, phase) points are clean (mask 0b011 is clean only at
        # phase 0), so pinning a phase silently hides real failures.
        for phase in range(_OFF_PHASES):
            before = len(tb.sb.mismatches)
            # REQ: EXEC-OFF-03 - offload SDO bus data must match FIFO mode
            await _offload_vs_fifo_sdo(tb, mask, phase)
            # Fast-fail: stop the sweep at the first (mask, phase) that corrupts.
            # The failing iteration's per-word mismatches are already recorded, so
            # assert_no_errors below reports the full detail of that case.
            if len(tb.sb.mismatches) > before:
                tb.sb.assert_no_errors()
    tb.sb.assert_no_errors()
