"""Chip-Select and CS-Invert-Mask, and EXEC-CC-04.

Covers driving cs to the selected value (active-low), the prescaled CS pre/post
delay timing (EXEC-CS-02), the t=0 early-exit path, sparse multi-select
(RTL-CHARACTERIZED lock), receive-state clear on assert, and the CS-invert mask
(polarity flip, persistence, and that the clear keys on the logical selection).

Assertions are on the boundary cs output and command timing only.
"""

import cocotb
from cocotb.triggers import RisingEdge, ClockCycles

from framework.spi import instructions as ins
from tb_env import ExecutionTB


@cocotb.test()
async def test_cs_select_deselect(dut):
    """CS drives the selected value (active-low) and fully deselects."""
    tb = ExecutionTB(dut)
    await tb.start()

    res = await tb.issue(ins.chipselect(0, delay=1))
    await tb.wait_idle()
    await ClockCycles(dut.clk, 2)
    # REQ: EXEC-CS-01 - cs driven to s (field bit 0 selects device, active-low)
    # REQ: EXEC-PARAM-01 - NUM_OF_CS sizes the cs bus
    tb.sb.compare(0, "cs.asserted", res.cs_value, int(dut.cs.value))

    allcs = (1 << tb.params["NUM_OF_CS"]) - 1
    res2 = await tb.issue(ins.chipselect(allcs, delay=1))
    await tb.wait_idle()
    await ClockCycles(dut.clk, 2)
    tb.sb.compare(1, "cs.deasserted", res2.cs_value, int(dut.cs.value))
    tb.sb.assert_no_errors()


@cocotb.test()
async def test_cs_no_delay(dut):
    """CS with t=0 applies the change via the early-exit path (no pre/post wait)."""
    tb = ExecutionTB(dut)
    await tb.start()
    # delay=0 is the point of this test (the dedicated early-exit path, t=1..3
    # covered separately by test_cs_delay_timing's closed-form sweep), so it is
    # deliberately a literal, not a sample of the delay-field range.
    res = await tb.issue(ins.chipselect(0, delay=0))
    await tb.wait_idle()
    await ClockCycles(dut.clk, 2)
    # REQ: EXEC-CS-03 - t=0 applies CS with only fixed internal latency
    tb.sb.compare(0, "cs.nodelay", res.cs_value, int(dut.cs.value))
    tb.sb.assert_no_errors()


@cocotb.test()
async def test_cs_delay_timing(dut):
    """CS change and completion times match the closed-form formulas (±tol).

    Swept across several (div, t) pairs spanning the legal range of each
    parameter -- div in (0, 1, 3) mirrors the prescaler spread used by
    test_waveform.py::test_sclk_period_across_div, and t in (1, 2, 3) is the
    full non-zero range of the 2-bit delay field (t=0 is the early-exit path
    already covered by test_cs_no_delay) -- so a formula bug isolated to one
    corner of either parameter cannot hide behind a single hardcoded pair.
    """
    tb = ExecutionTB(dut)
    await tb.start()
    allcs = (1 << tb.params["NUM_OF_CS"]) - 1

    i = 0
    for div in (0, 1, 3):
        await tb.issue(ins.config_clk_div(div))
        await tb.wait_idle()
        for t in (1, 2, 3):
            note = f"div={div} t={t}"
            # Ensure a known starting cs (all deselected) so the change is
            # observable.
            await tb.issue(ins.chipselect(allcs, delay=0))
            await tb.wait_idle()
            await ClockCycles(dut.clk, 3)

            before_val = int(dut.cs.value)
            start = tb.now_cycles()
            res = await tb.issue(ins.chipselect(0, delay=t))
            # Time until cs actually changes.
            change_at = None
            for _ in range(400):
                await RisingEdge(dut.clk)
                if int(dut.cs.value) != before_val:
                    change_at = tb.now_cycles() - start
                    break
            await tb.wait_idle()
            total = tb.now_cycles() - start

            tb.sb.compare(i, "cs.delay_value", res.cs_value, int(dut.cs.value),
                         note=note)
            # REQ: EXEC-CS-02 - cs changes at 2 + t*(div+1)*2 core clocks
            tb.sb.compare_within(i, "cs_delay_before",
                                 tb.model.cs_delay_before(t), change_at, 3,
                                 note=note)
            # REQ: EXEC-CC-04 - non-zero CS delay produces its closed-form timing
            total_expected = 2 + 2 * t * tb.model.sclk_period
            tb.sb.compare_within(i, "cs_delay_total", total_expected, total, 4,
                                 note=note)
            i += 1
    tb.sb.assert_no_errors()


@cocotb.test()
async def test_cs_sparse_multi_select(dut):
    """Sparse multi-CS select (RTL-CHARACTERIZED lock; NUM_OF_CS>1 only).

    Neither reference driver ever selects a sparse subset (spec Appendix C: both
    single-select or fully deselect), so this pins the RTL's documented
    "any subset may be selected" behaviour as a regression lock, not conformance.
    """
    tb = ExecutionTB(dut)
    await tb.start()
    ncs = tb.params["NUM_OF_CS"]
    if ncs < 2:
        # Degenerates to the single-line case, already covered elsewhere.
        return
    allcs = (1 << ncs) - 1
    rng = tb.rc.derive("cs_sparse")
    # low&high always driven to 0 (selected) with the middle left deselected
    # anchors the "ends selected, middle not" shape; a random subset (excluding
    # the two boundary patterns all-select/all-deselect, already covered by
    # test_cs_select_deselect) fills out the rest of the field bits for
    # ncs > 2.
    fixed = allcs & ~1 & ~(1 << (ncs - 1))
    patterns = {fixed}
    if ncs > 2:
        patterns.add(rng.randint(1, allcs - 1))

    for i, sel in enumerate(sorted(patterns)):
        res = await tb.issue(ins.chipselect(sel, delay=1))
        await tb.wait_idle()
        await ClockCycles(dut.clk, 2)
        # REQ: EXEC-CS-05 - any subset of cs lines may be selected simultaneously
        tb.sb.compare(i, "cs.sparse", res.cs_value, int(dut.cs.value),
                      note=f"sel=0x{sel:X}")
        await tb.issue(ins.chipselect(allcs, delay=1))
        await tb.wait_idle()
    tb.sb.assert_no_errors()


@cocotb.test()
async def test_cs_assert_clears_receive_state(dut):
    """Asserting a chip-select clears residual receive state before capture.

    Two reads separated by a CS re-assert both return exactly their fresh
    responses; the assert-driven clear (EXEC-CS-04) guarantees no bleed-through
    from the previous transfer. The pure-deselect *non*-trigger is an internal
    gating detail (RTL-CHARACTERIZED) not independently boundary-observable, so
    only the assert-clears half is asserted here.
    """
    tb = ExecutionTB(dut)
    await tb.start()
    wl = tb.params["DATA_WIDTH"]
    rng = tb.rc.derive("cs_rxclear")

    allcs = (1 << tb.params["NUM_OF_CS"]) - 1
    for k in range(2):
        await tb.issue(ins.chipselect(0, delay=1))  # assert -> clears rx state
        await tb.wait_idle()
        resp = [rng.randrange(1 << wl) for _ in range(2 * tb.num_sdio)]
        tb.sdi_mon.received.clear()
        res = await tb.issue(ins.transfer(1, write=False, read=True),
                             sdi_data=resp)
        tb.slave.start()
        await tb.wait_idle()
        await ClockCycles(dut.clk, 8)
        # REQ: EXEC-CS-04 - CS assert clears residual rx state; capture is clean
        tb.sb.compare_sequences(res.sdi_words, tb.sdi_values, field=f"rx[{k}]")
        tb.slave.stop()
        await tb.issue(ins.chipselect(allcs, delay=1))  # deselect between reads
        await tb.wait_idle()
    tb.sb.assert_no_errors()


@cocotb.test()
async def test_cs_invert_mask(dut):
    """CS-invert mask flips polarity of the driven cs bits."""
    tb = ExecutionTB(dut)
    await tb.start()
    ncs = tb.params["NUM_OF_CS"]
    all_mask = (1 << ncs) - 1
    rng = tb.rc.derive("cs_inv_mask")
    # all_mask is the full-invert boundary; a random partial mask (only when
    # there's more than one bit to be partial about) confirms per-bit
    # independence rather than only ever inverting every line at once.
    masks = {all_mask} if ncs < 2 else {all_mask, rng.randint(1, all_mask - 1)}

    for i, mask in enumerate(sorted(masks)):
        await tb.issue(ins.cs_invert(mask))
        await tb.wait_idle()

        sel = rng.randint(0, all_mask)
        res = await tb.issue(ins.chipselect(sel, delay=1))
        await tb.wait_idle()
        await ClockCycles(dut.clk, 2)
        # REQ: EXEC-CSINV-01 - masked cs pins inverted at the output register
        tb.sb.compare(i, "cs.inverted", res.cs_value, int(dut.cs.value),
                      note=f"mask=0x{mask:X} sel=0x{sel:X}")
        await tb.issue(ins.cs_invert(0))  # restore before the next iteration
        await tb.wait_idle()
    tb.sb.assert_no_errors()


@cocotb.test()
async def test_cs_invert_persists(dut):
    """The invert mask persists across subsequent CS instructions."""
    tb = ExecutionTB(dut)
    await tb.start()
    mask = (1 << tb.params["NUM_OF_CS"]) - 1
    await tb.issue(ins.cs_invert(mask))
    await tb.wait_idle()

    # Several CS instructions after a single mask write: all see the inversion.
    for k, sel in enumerate((0, mask, 0)):
        res = await tb.issue(ins.chipselect(sel, delay=1))
        await tb.wait_idle()
        await ClockCycles(dut.clk, 2)
        # REQ: EXEC-CSINV-02 - mask persists across CS instructions until rewrite
        tb.sb.compare(k, "cs.inv_persist", res.cs_value, int(dut.cs.value))
    tb.sb.assert_no_errors()


@cocotb.test()
async def test_cs_invert_clear_keys_on_logical(dut):
    """The rx-clear keys on the logical selection, not the inverted pin level.

    With a full invert mask, selecting logical device 0 drives cs high (inverted)
    yet must still perform the assert-clear so the following read is clean —
    proving the clear logic keys on the logical selection (EXEC-CSINV-03), not on
    the physical pin level.
    """
    tb = ExecutionTB(dut)
    await tb.start()
    wl = tb.params["DATA_WIDTH"]
    rng = tb.rc.derive("cs_inv_clear")
    mask = (1 << tb.params["NUM_OF_CS"]) - 1
    await tb.issue(ins.cs_invert(mask))
    await tb.wait_idle()

    await tb.issue(ins.chipselect(0, delay=1))  # logical select, pins go high
    await tb.wait_idle()
    resp = [rng.randrange(1 << wl) for _ in range(2 * tb.num_sdio)]
    tb.sdi_mon.received.clear()
    res = await tb.issue(ins.transfer(1, write=False, read=True), sdi_data=resp)
    tb.slave.start()
    await tb.wait_idle()
    await ClockCycles(dut.clk, 8)
    # REQ: EXEC-CSINV-03 - clear logic keys on logical selection, not pin level
    tb.sb.compare_sequences(res.sdi_words, tb.sdi_values, field="inv_clear")
    tb.sb.assert_no_errors()
