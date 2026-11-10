"""SDO lane-mask reconfiguration boundary (EXEC-LANE-05..09).

These requirements govern what happens to SDO word *assembly* and *consumption*
around a lane-mask reconfigure command, as distinct from test_lanes.py's
EXEC-LANE-01..04 (routing correctness for a settled, unchanging mask):

  * EXEC-LANE-05: a word assembled under a mask that is no longer active must
    be discarded, not driven.
  * EXEC-LANE-06: a mask change mid-assembly discards that partial word.
  * EXEC-LANE-07: a fully-assembled word is driven onto sdo exactly once.
  * EXEC-LANE-08: a command that changes the active SDO lane mask must not
    consume any SDO data word while executing.
  * EXEC-LANE-09: once the active mask is *fully configured*, assembly uses
    that mask.

All of this is tested black-box, purely from these statements: the golden
model (model_execution.py) always predicts a transfer's words as assembled
under that transfer's own currently-active mask, consumed exactly once, in
order - which is exactly what EXEC-LANE-05/06/07/09 jointly guarantee when the
RTL is compliant. A stale-mask leak, a dropped/duplicated word, or assembly
under an unsettled mask all show up as a scoreboard mismatch against that
prediction; no internal pipeline/signal knowledge is needed to catch the
violation, only to decide how aggressively to race the boundary (the `phase`
sweep below).

This testbench exposes no standalone "pipeline depth" parameter (data
assembly is modelled at the transaction level - see model_execution.py's
module docstring). The relationship between active lane count and internal
latency is instead probed by sweeping the timing phase relative to
NUM_OF_SDIO, reusing the margin convention test_offload.py already
established black-box for its lane-scan-rebuild settle window
(NUM_OF_SDIO + 4 cycles).
"""

import os

import cocotb
from cocotb.triggers import RisingEdge, ClockCycles, ReadOnly

from framework.spi import instructions as ins
from framework.reset import apply_reset
from tb_env import ExecutionTB

# Slack beyond NUM_OF_SDIO's ~nsd-cycle lane-scan rebuild window, matching
# test_offload.py's settle_cycles/_OFF_PHASES margin.
_PHASE_MARGIN = 4

# Read at import time (module-level skip condition must be decidable before
# the DUT exists).
_NSD = int(os.environ.get("PARAM_NUM_OF_SDIO", 1))


async def _count_sdo_consumed_during(dut, awaitable):
    """Count accepted SDO-data beats (valid && ready) while ``awaitable`` runs."""
    count = 0

    async def _watch():
        nonlocal count
        while True:
            await RisingEdge(dut.clk)
            await ReadOnly()
            if int(dut.sdo_data_valid.value) == 1 and int(dut.sdo_data_ready.value) == 1:
                count += 1

    watcher = cocotb.start_soon(_watch())
    await awaitable
    watcher.kill()
    return count


def _lane_reconfig_pairs(nsd):
    """A handful of SDO lane-mask (prev, next) transitions to race the
    reconfigure boundary with: full<->single-lane always; a genuinely
    non-contiguous sparse mask added once one exists (nsd>=3)."""
    full = (1 << nsd) - 1
    single_lo, single_hi = 1, 1 << (nsd - 1)
    pairs = [(full, single_lo), (single_lo, full)]
    if nsd >= 3:
        pairs.append((full, 1 | single_hi))
    return pairs


def _all_sdo_masks(nsd, *, rng=None, cap=12):
    """Every SDO lane mask for ``nsd`` lanes (full plus every partial
    sub-mask). Capped with a seeded sample (keeping the sparsest/densest
    extremes) for large nsd, mirroring test_offload.py's _all_masks."""
    full = (1 << nsd) - 1
    cand = sorted({full, *range(1, full)})
    if rng is None or len(cand) <= cap:
        return cand
    lo = min(cand, key=lambda m: bin(m).count("1"))
    hi = max(cand, key=lambda m: bin(m).count("1"))
    rest = [m for m in cand if m not in (lo, hi)]
    return sorted({lo, hi, *rng.sample(rest, cap - 2)})


@cocotb.test()
async def test_lane_reconfig_boundary_sdo_integrity(dut):
    """EXEC-LANE-05/06/07/09: no stale-mask word leaks, drops or duplicates
    across a lane-mask reconfigure, including the tightest back-to-back case.

    For each (prev_mask -> next_mask) transition: settle prev_mask with a
    completed transfer (a warm assembler - NOT a reset right before the
    reconfigure, which would give a cold lane map that trivially hides a
    stale-mask leak), then reconfigure to next_mask and issue the following
    transfer `phase` cycles later. phase=0 relies on ExecutionTB.send_cmd's
    documented zero-gap reissue (cmd_valid held through the busy period,
    accepted on the exact edge cmd_ready reasserts) for the tightest possible
    back-to-back reconfigure-then-transfer. Swept over offload/FIFO mode since
    EXEC-OFF-01 makes prefetch (and therefore the overlap window) mode-
    dependent.
    """
    tb = ExecutionTB(dut)
    await tb.start()
    wl = tb.params["DATA_WIDTH"]
    nsd = tb.num_sdio
    rng = tb.rc.derive("lane_reconfig_boundary")

    pairs = _lane_reconfig_pairs(nsd) if nsd >= 2 else [(1, 1)]
    phases = sorted({0, 1, nsd, nsd + _PHASE_MARGIN})
    allcs = (1 << tb.params["NUM_OF_CS"]) - 1

    for offload in (False, True):
        for prev_mask, next_mask in pairs:
            for phase in phases:
                await apply_reset(dut, cycles_before=0, hold=3)
                tb.after_reset()
                tb.set_offload_active(offload)

                await tb.issue(ins.chipselect(allcs, delay=1))
                await tb.wait_idle()
                await tb.issue(ins.config_sdo_lane_mask(prev_mask))
                await tb.wait_idle()
                n_prev = bin(prev_mask).count("1")
                d0 = [rng.randrange(1 << wl) for _ in range(2 * n_prev)]
                await tb.run_transfer(n=2, write=True, read=False, sdo_words=d0)

                # Reconfigure to next_mask, then the following transfer
                # `phase` cycles later (phase=0: immediately, back-to-back).
                tb.bus_mon.words.clear()
                cmd_cfg = ins.config_sdo_lane_mask(next_mask)
                tb.apply_cmd(cmd_cfg)
                await tb.send_cmd(cmd_cfg)
                if phase:
                    await ClockCycles(dut.clk, phase)

                n_next = bin(next_mask).count("1")
                d1 = [rng.randrange(1 << wl) for _ in range(2 * n_next)]
                res = await tb.issue(ins.transfer(1, write=True, read=False),
                                     sdo_data=d1)
                tb.start_sdo_stream(res.sdo_words)
                await tb.wait_idle()
                await ClockCycles(dut.clk, 3)

                # REQ: EXEC-LANE-05 - word assembled under a no-longer-active
                # mask must be discarded, not driven
                # REQ: EXEC-LANE-06 - mask change mid-assembly discards the
                # partial word
                # REQ: EXEC-LANE-07 - a fully-assembled word is driven exactly
                # once
                # REQ: EXEC-LANE-09 - once fully configured, assembly uses the
                # new mask
                tb.sb.compare_sequences(
                    res.sdo_words, tb.bus_mon.sdo_words,
                    field=f"lane_reconfig_off{int(offload)}_"
                          f"{prev_mask:#04x}to{next_mask:#04x}_ph{phase}")
                tb.abort_streams()
                tb.set_offload_active(False)

    tb.sb.assert_no_errors()


@cocotb.test()
async def test_lane_reconfig_no_sdo_consumed(dut):
    """EXEC-LANE-08: a command that changes the active SDO lane mask must not
    consume any SDO data word while executing that command.

    Sentinel SDO data is held valid for the whole duration of the lane-mask
    reconfigure command (issue through completion); any accepted beat
    (valid && ready) during that window is a violation. Checked in both FIFO
    and offload mode, since offload's prefetch (EXEC-OFF-01) is the mechanism
    most likely to pull a word early. A sanity transfer immediately after each
    iteration confirms the engine still consumes data normally afterwards
    (ruling out a stuck-low ready masking the real check). The sanity
    transfer completing also covers offload mode combined with a reconfigure
    to or through a single-lane mask while sdo_data_valid is held asserted.
    """
    tb = ExecutionTB(dut)
    await tb.start()
    wl = tb.params["DATA_WIDTH"]
    nsd = tb.num_sdio
    rng = tb.rc.derive("lane_reconfig_no_consume")

    full = (1 << nsd) - 1
    masks = sorted({full, 1} | ({1 | (1 << (nsd - 1))} if nsd >= 3 else set()))

    for offload in (False, True):
        for mask in masks:
            # Reset between iterations so latched word_ready/prefetch state
            # from a prior iteration cannot mask a fresh result (see
            # test_offload.py's identical caution).
            await apply_reset(dut, cycles_before=0, hold=3)
            tb.after_reset()
            await tb.issue(ins.config_clk_div(0))
            await tb.wait_idle()

            tb.set_offload_active(offload)
            dut.sdo_data_valid.value = 1
            dut.sdo_data.value = rng.randrange(1 << wl)

            cmd_cfg = ins.config_sdo_lane_mask(mask)
            tb.apply_cmd(cmd_cfg)
            consumed = await _count_sdo_consumed_during(dut, tb.send_cmd(cmd_cfg))
            consumed += await _count_sdo_consumed_during(dut, tb.wait_idle())

            dut.sdo_data_valid.value = 0
            tb.set_offload_active(False)

            # REQ: EXEC-LANE-08 - no SDO data word consumed while executing a
            # command that changes the active SDO lane mask
            tb.sb.compare(0, f"lane08_off{int(offload)}_mask{mask:#04x}",
                         0, consumed)

            # Sanity: the engine still functions afterwards under the newly
            # configured mask.
            n_active = bin(mask).count("1")
            data = [rng.randrange(1 << wl) for _ in range(2 * n_active)]
            res = await tb.run_transfer(n=2, write=True, read=False, sdo_words=data)
            tb.sb.compare_sequences(
                res.sdo_words, tb.bus_mon.sdo_words,
                field=f"lane08_sanity_off{int(offload)}_mask{mask:#04x}")
            tb.bus_mon.words.clear()

    tb.sb.assert_no_errors()


@cocotb.test()
async def test_lane_mask_fully_configured_assembly(dut):
    """EXEC-LANE-09: once the active SDO lane mask is fully configured, word
    assembly uses that mask - swept over every mask value (full and every
    partial sub-mask), in both FIFO and offload mode.

    Waits the same settle margin test_offload.py's mask-configuration-gating
    test established black-box (NUM_OF_SDIO + 4 cycles) past the reconfigure
    before issuing the transfer, isolating "the mask is settled" from the
    reconfigure-boundary race already covered by
    test_lane_reconfig_boundary_sdo_integrity above.
    """
    tb = ExecutionTB(dut)
    await tb.start()
    wl = tb.params["DATA_WIDTH"]
    nsd = tb.num_sdio
    rng = tb.rc.derive("lane_mask_fully_configured")
    settle_cycles = nsd + _PHASE_MARGIN
    allcs = (1 << tb.params["NUM_OF_CS"]) - 1

    for offload in (False, True):
        for mask in _all_sdo_masks(nsd, rng=rng):
            await apply_reset(dut, cycles_before=0, hold=3)
            tb.after_reset()
            tb.set_offload_active(offload)

            await tb.issue(ins.chipselect(allcs, delay=1))
            await tb.wait_idle()
            await tb.issue(ins.config_sdo_lane_mask(mask))
            await tb.wait_idle()
            await ClockCycles(dut.clk, settle_cycles)

            n_active = bin(mask).count("1")
            data = [rng.randrange(1 << wl) for _ in range(2 * n_active)]
            res = await tb.run_transfer(n=2, write=True, read=False, sdo_words=data)
            # REQ: EXEC-LANE-09 - fully configured mask: assembly uses that mask
            tb.sb.compare_sequences(
                res.sdo_words, tb.bus_mon.sdo_words,
                field=f"lane09_off{int(offload)}_mask{mask:#04x}")
            tb.bus_mon.words.clear()
            tb.set_offload_active(False)

    tb.sb.assert_no_errors()


@cocotb.test(skip=_NSD < 2)
async def test_lane_mask_reset_during_reconfigure(dut):
    """EXEC-LANE-09: reset asserted while an SDO lane-mask reconfigure is
    still settling must not leave the post-reset mask needing any extra
    settle/rescan delay. Once reset deasserts with no further reconfigure
    command issued, the active mask is back at its reset-default (nothing is
    left in flight to settle), so it is already *fully configured*: assembly
    must use it starting with the very next transfer, in no more time than an
    ordinary reset recovery with no reconfigure involved at all needs.

    The reset-injection offset is swept EXHAUSTIVELY across the whole settle
    window a completed (uninterrupted) reconfigure would need - as
    established black-box by test_lane_mask_fully_configured_assembly above -
    from the cycle the reconfigure command is accepted through the last
    cycle before that window would have elapsed. A sparse early/mid/late
    sample could walk straight past a one-cycle-wide trigger hiding anywhere
    in that span; the window is small enough (NUM_OF_SDIO-bounded) that
    covering every cycle in it costs nothing.
    """
    tb = ExecutionTB(dut)
    await tb.start()
    wl = tb.params["DATA_WIDTH"]
    nsd = tb.num_sdio
    rng = tb.rc.derive("lane_reset_mid_reconfig")
    allcs = (1 << tb.params["NUM_OF_CS"]) - 1
    settle_window = nsd + _PHASE_MARGIN

    # A mask that actually differs from the reset-default (all-lanes) mask,
    # so an aborted reconfigure is observable; nsd>=2 is guaranteed by the
    # skip condition above.
    new_mask = 1
    offsets = range(settle_window)

    # Baseline: an ordinary reset recovery with no reconfigure command in the
    # picture at all - same zero-extra-margin access pattern (reset, then
    # immediately chipselect + transfer, no settle wait) - establishes how
    # long a clean post-reset transfer legitimately takes, so the
    # offset-swept cases below are judged against that instead of an
    # arbitrary hardcoded cycle count.
    await apply_reset(dut, cycles_before=0, hold=3)
    tb.after_reset()
    await tb.issue(ins.chipselect(allcs, delay=1))
    await tb.wait_idle()
    base_mask = tb.model.sdo_lane_mask
    n_base = bin(base_mask).count("1")
    base_data = [rng.randrange(1 << wl) for _ in range(2 * n_base)]
    base_start = tb.now_cycles()
    await tb.run_transfer(n=2, write=True, read=False, sdo_words=base_data)
    baseline_elapsed = tb.now_cycles() - base_start
    tb.bus_mon.words.clear()

    for offset in offsets:
        await apply_reset(dut, cycles_before=0, hold=3)
        tb.after_reset()
        await tb.issue(ins.chipselect(allcs, delay=1))
        await tb.wait_idle()

        # Start reconfiguring to new_mask, then interrupt it with reset
        # `offset` cycles after the command is accepted - before the settle
        # window a genuine, uninterrupted reconfigure would need has elapsed.
        cmd_cfg = ins.config_sdo_lane_mask(new_mask)
        tb.apply_cmd(cmd_cfg)
        await tb.send_cmd(cmd_cfg)
        if offset:
            await ClockCycles(dut.clk, offset)
        await apply_reset(dut, cycles_before=0, hold=3)
        tb.after_reset()

        # No reconfigure command follows reset: the active mask is the
        # reset-default, already fully configured. Same zero-extra-margin
        # access pattern as the baseline above (chipselect immediately,
        # straight into the transfer, no settle wait added here).
        await tb.issue(ins.chipselect(allcs, delay=1))
        await tb.wait_idle()
        mask_now = tb.model.sdo_lane_mask
        n_active = bin(mask_now).count("1")
        data = [rng.randrange(1 << wl) for _ in range(2 * n_active)]
        start = tb.now_cycles()
        res = await tb.run_transfer(n=2, write=True, read=False, sdo_words=data)
        elapsed = tb.now_cycles() - start

        # REQ: EXEC-LANE-09 - after reset clears an in-flight reconfigure,
        # the resulting (reset-default) mask is fully configured immediately;
        # assembly must use it with no spurious extra settle delay
        tb.sb.compare_sequences(
            res.sdo_words, tb.bus_mon.sdo_words,
            field=f"lane09_rst_mid_reconfig_off{offset}")
        # REQ: EXEC-LANE-09 - no extra settle/rescan latency vs an ordinary
        # reset recovery with no reconfigure in flight
        tb.sb.compare_within(offset, "lane09_rst_mid_reconfig_timing",
                             baseline_elapsed, elapsed, 1,
                             note=f"reset_off={offset}")
        tb.bus_mon.words.clear()

    tb.sb.assert_no_errors()
