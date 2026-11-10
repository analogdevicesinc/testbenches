"""Reset behaviour (boundary-observable), plus EXEC-CC-07.

Verifies the documented idle/reset values on every boundary output after reset
(including resets injected mid-instruction), and that receive state is cleared so
the first read after reset returns only freshly-sampled bits.

Only boundary outputs are asserted (ctrl streams + spi bus); internal state is
out of scope.
"""

import cocotb
from cocotb.triggers import RisingEdge, ClockCycles

from framework.spi import instructions as ins
from framework.reset import apply_reset, check_reset_values

from tb_env import ExecutionTB


@cocotb.test()
async def test_reset_values_after_release(dut):
    """All documented reset values hold after resetn is released."""
    tb = ExecutionTB(dut)
    await tb.start()

    # DEFAULT_SPI_CFG/NUM_OF_CS/SDO_DEFAULT are DUT generics (compile-time),
    # not per-test inputs, so they are kept fixed within
    # this test and varied across build configs by the runner instead; every
    # expected value below is derived from tb.params rather than a literal,
    # so the check is already correct for whichever generic values this
    # particular build was compiled with.

    # cmd_ready high (ready to accept), cs=all-ones, sclk=cpol, sdo_t=1.
    errs = tb.check_reset_values()          # REQ: EXEC-RST-02 - cmd_ready asserted
    errs += tb.check_reset_values_extra()   # REQ: EXEC-RST-06 - three_wire + sdi_data_valid low
    assert not errs, f"reset value mismatches: {errs}"

    cpol = (tb.params["DEFAULT_SPI_CFG"] >> 1) & 1
    all_cs = (1 << tb.params["NUM_OF_CS"]) - 1
    # REQ: EXEC-RST-03 - cs reads all-ones (every CS inactive) after reset
    tb.sb.compare(0, "reset.cs_all_ones", all_cs, int(dut.cs.value))
    # REQ: EXEC-RST-04 - sclk idles at CPOL from DEFAULT_SPI_CFG[1]
    tb.sb.compare(0, "reset.sclk_cpol", cpol, int(dut.sclk.value))
    idle = tb.params.get("SDO_DEFAULT", 0)
    # REQ: EXEC-RST-05 - every sdo lane idles at sdo_idle_state, sdo_t tristated
    # REQ: EXEC-PARAM-06 - SDO_DEFAULT is the reset/idle sdo level
    tb.sb.compare(0, "reset.sdo_idle",
                  idle * ((1 << tb.num_sdio) - 1), int(dut.sdo.value))
    # REQ: EXEC-BUS-04 - cs reset value is all-inactive
    tb.sb.compare(0, "reset.bus_cs", all_cs, int(dut.cs.value))
    # REQ: EXEC-PARAM-04 - DEFAULT_SPI_CFG observed at reset (three_wire, cpol)
    tb.sb.compare(0, "reset.cfg_three_wire",
                  (tb.params["DEFAULT_SPI_CFG"] >> 2) & 1,
                  int(dut.three_wire.value))
    tb.sb.assert_no_errors()


@cocotb.test()
async def test_reset_module_idle(dut):
    """After reset the module is idle and accepts no in-flight command."""
    tb = ExecutionTB(dut)
    await tb.start()
    # REQ: EXEC-RST-01 - module idle and at defined idle values after reset
    assert int(dut.cmd_ready.value) == 1, "engine not idle after reset"
    assert int(dut.sync_valid.value) == 0, "sync_valid high after reset"
    tb.sb.assert_no_errors()


@cocotb.test()
async def test_reset_during_transfer(dut):
    """Reset mid-transfer returns all outputs to their reset values and recovers."""
    tb = ExecutionTB(dut)
    await tb.start()
    wl = tb.params["DATA_WIDTH"]
    rng = tb.rc.derive("rst_xfer")

    # div is randomized but kept >=1: a long enough SCLK period is needed so
    # that the fixed 5-cycle wait past transfer_active still lands mid-word
    # regardless of DATA_WIDTH/nper; div=0 on a short transfer risks the
    # whole thing completing before that wait elapses.
    div = rng.randint(1, 7)
    await tb.issue(ins.config_clk_div(div))  # slow it so we land mid-transfer
    await tb.wait_idle()
    await tb.issue(ins.chipselect(0, delay=1))
    await tb.wait_idle()

    nper = rng.randint(2, 6)
    data = [rng.randrange(1 << wl) for _ in range(nper * tb.num_sdio)]
    # write=True/read=False: read-direction reset interaction (stale-capture
    # state surviving reset) is already swept exhaustively, across the whole
    # in-flight-trigger window, by test_reset_clears_receive_state
    # (EXEC-RST-07) below; duplicating a read sweep here would just re-run
    # that same corner under EXEC-CC-07's tag.
    res = await tb.issue(ins.transfer(nper - 1, write=True, read=False),
                         sdo_data=data)
    tb.start_sdo_stream(res.sdo_words)
    for _ in range(30):
        await RisingEdge(dut.clk)
        if int(dut.transfer_active.value) == 1:
            break
    await ClockCycles(dut.clk, 5)
    await apply_reset(dut, cycles_before=0, hold=3)
    tb.after_reset()

    # REQ: EXEC-CC-07 - reset asserted mid-transfer restores reset values
    errs = check_reset_values(dut, tb.params, scoreboard=tb.sb)
    assert not errs, f"post-reset values wrong: {errs}"

    # A fresh transfer must work after recovery. The SDO data-assembler's lane
    # table auto-rebuilds after reset (reset clears lane_scan_idx and the scan
    # reruns over the reset-default all-lanes sdo_lane_mask), so no post-reset
    # lane-mask reprogram is needed for multi-lane distribution to be correct.
    await tb.issue(ins.chipselect(0, delay=1))
    await tb.wait_idle()
    nper2 = rng.randint(1, 3)
    d2 = [rng.randrange(1 << wl) for _ in range(nper2 * tb.num_sdio)]
    res = await tb.issue(ins.transfer(nper2 - 1, write=True, read=False),
                         sdo_data=d2)
    cocotb.start_soon(tb.stream_sdo(res.sdo_words))
    await tb.wait_idle()
    await ClockCycles(dut.clk, 3)
    tb.sb.compare_sequences(res.sdo_words, tb.bus_mon.sdo_words, field="post_rst")
    tb.sb.assert_no_errors()


@cocotb.test()
async def test_reset_during_sleep(dut):
    """Reset during a sleep instruction; clean recovery to idle, and the next
    accepted Sleep after recovery still stalls for its full formula-predicted
    duration (EXEC-SLEEP-01) - no truncation or early-complete carried over
    from the aborted stall.

    The reset-injection offset is swept across the whole predicted stall
    window (early/mid/late, derived from the window's own randomized extent
    rather than a fixed cycle count) instead of landing at a single point.
    """
    tb = ExecutionTB(dut)
    await tb.start()
    rng = tb.rc.derive("rst_sleep")
    div = rng.randint(0, 15)
    await tb.issue(ins.config_clk_div(div))
    await tb.wait_idle()

    # t is randomized; duration is the formula-predicted stall window for it,
    # and the reset-injection offsets are derived from that window itself
    # (early/mid/last-cycle-before-completion) rather than any fixed literal.
    t = rng.randint(4, 255)
    duration = tb.model.sleep_duration(t)
    offsets = sorted({1, max(1, duration // 2), duration - 1})

    for offset in offsets:
        await tb.issue(ins.sleep(t))
        await ClockCycles(dut.clk, offset)
        await apply_reset(dut, cycles_before=0, hold=3)
        tb.after_reset()
        # REQ: EXEC-CC-07 - reset mid-sleep also restores reset values (recovers to idle)
        errs = check_reset_values(dut, tb.params, scoreboard=tb.sb)
        assert not errs, f"post-reset values wrong: {errs}"
        assert int(dut.cmd_ready.value) == 1, "engine not idle after reset"

        # Reset restores clk_div to its generic default, which the fresh
        # golden model instance from after_reset() above already reflects;
        # re-apply the same divider so the post-recovery duration check below
        # exercises the same (t, div) pair at every swept offset.
        await tb.issue(ins.config_clk_div(div))
        await tb.wait_idle()

        predicted = tb.model.sleep_duration(t)
        start = tb.now_cycles()
        await tb.issue(ins.sleep(t))
        await tb.wait_idle()
        elapsed = tb.now_cycles() - start
        tb.log.info(f"post-reset(off={offset}) sleep t={t} div={div} "
                    f"predicted~{predicted} elapsed={elapsed}")
        # REQ: EXEC-SLEEP-01 - after reset aborts an in-flight sleep stall at
        # any point in its window, the next accepted Sleep still stalls for
        # its full formula-predicted duration (no instant-complete/truncation)
        tb.sb.compare_within(offset, "sleep_duration_post_reset", predicted,
                             elapsed, 1, note=f"t={t} div={div} reset_off={offset}")
    tb.sb.assert_no_errors()


@cocotb.test()
async def test_sleep_full_duration_after_reset_pending_reissue(dut):
    """EXEC-SLEEP-01: a Sleep accepted the instant reset releases - with no
    gap at all since the reset that aborted a prior in-flight Sleep - must
    still stall for its own full formula-predicted duration.

    A compliant manager is free to hold a command pending so it lands on the
    very first cycle the module could possibly accept it (the same zero-gap
    reissue already exercised busy-period-to-busy-period elsewhere in this
    suite, here spanning a reset pulse instead of a busy period). That is the
    most adversarial ordering available at the boundary, and a prior
    in-flight Sleep is only ever aborted by resetting partway through its
    stall - so the reset-injection offset is swept EXHAUSTIVELY across every
    cycle of that stall window rather than a few representative samples: any
    single cycle in that window could be the one a leftover internal
    condition from the aborted Sleep happens to still be sitting on, and a
    sparse sample could walk straight past it. t is kept small purely so an
    exhaustive sweep of the whole window stays cheap.
    """
    tb = ExecutionTB(dut)
    await tb.start()
    rng = tb.rc.derive("rst_sleep_pending_reissue")

    t = rng.randint(1, 6)
    duration = tb.model.sleep_duration(t)

    for offset in range(1, duration + 1):
        await tb.issue(ins.sleep(t))
        await ClockCycles(dut.clk, offset)

        t2 = rng.randint(1, 6)
        cmd2 = ins.sleep(t2)
        start = await tb.hold_cmd_through_reset(cmd2, hold=3)
        tb.after_reset()
        tb.model.apply(cmd2)

        predicted = tb.model.sleep_duration(t2)
        await tb.wait_idle()
        elapsed = tb.now_cycles() - start
        tb.log.info(f"pending_reissue(off={offset}) t={t} t2={t2} "
                    f"predicted~{predicted} elapsed={elapsed}")
        # REQ: EXEC-SLEEP-01 - a Sleep accepted with zero gap on the first
        # post-reset cycle, after reset aborted a different in-flight Sleep
        # at any cycle of its stall, still stalls for its own full
        # formula-predicted duration - no instant-complete/truncation carried
        # over from the aborted instruction, at every swept reset offset
        tb.sb.compare_within(offset, "sleep_duration_pending_reissue",
                             predicted, elapsed, 1,
                             note=f"t={t} t2={t2} reset_off={offset}")
    tb.sb.assert_no_errors()


@cocotb.test()
async def test_reset_clears_receive_state(dut):
    """First read after reset returns only newly-sampled bits (no stale SDI).

    A capture already in flight in the SDI_DELAY pipeline when reset lands
    must not reach the post-reset read (EXEC-RST-07). The reset-injection
    offset sweeps the whole span where such a capture can be in flight (0 up
    through ``SDI_DELAY+1`` cycles after ``transfer_active``), using the
    build's ``SDI_DELAY`` at runtime.
    """
    tb = ExecutionTB(dut)
    await tb.start()
    wl = tb.params["DATA_WIDTH"]
    rng = tb.rc.derive("rst_rx")

    await tb.issue(ins.config_clk_div(3))  # slow it so we land mid-transfer
    await tb.wait_idle()

    # trigger_rx_d is SDI_DELAY+2 bits wide ([SDI_DELAY+1:0]), so a pulse
    # queued in it can still be in flight anywhere from 0 up through
    # SDI_DELAY+1 cycles after the transfer starts. Sweep the whole span.
    sdi_delay = tb.params["SDI_DELAY"]
    for offset in range(sdi_delay + 2):
        # Start a read transfer and reset partway through so some bits are
        # shifted in.
        await tb.issue(ins.chipselect(0, delay=1))
        await tb.wait_idle()
        stale = [rng.randrange(1 << wl) for _ in range(4 * tb.num_sdio)]
        await tb.issue(ins.transfer(3, write=False, read=True), sdi_data=stale)
        tb.slave.start()
        for _ in range(30):
            await RisingEdge(dut.clk)
            if int(dut.transfer_active.value) == 1:
                break
        await ClockCycles(dut.clk, offset)
        # Stop the slave (and release sdi) before asserting reset so it is not
        # mid drive when the transfer is torn down, then reset.
        tb.slave.stop()
        await apply_reset(dut, cycles_before=0, hold=3)
        tb.after_reset()

        # Clean read after reset must return exactly the fresh responses. The
        # lane tables auto-rebuild after reset (see test_reset_during_transfer),
        # so no post-reset lane-mask reprogram is required.
        await tb.issue(ins.chipselect(0, delay=1))
        await tb.wait_idle()
        fresh = [rng.randrange(1 << wl) for _ in range(2 * tb.num_sdio)]
        res = await tb.issue(ins.transfer(1, write=False, read=True),
                             sdi_data=fresh)
        tb.slave.start()
        await tb.wait_idle()
        await ClockCycles(dut.clk, 10)
        # REQ: EXEC-RST-07 - receive state cleared by reset; only fresh bits
        # returned, for every reset-injection offset in the swept range.
        tb.sb.compare_sequences(res.sdi_words, tb.sdi_values,
                                field=f"fresh_sdi[off={offset}]")
        tb.slave.stop()
    tb.sb.assert_no_errors()
