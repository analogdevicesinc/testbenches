"""Flow control / backpressure, and EXEC-CC-06.

Exercises independent random backpressure on each stream that has a ready the DUT
must honour (SDO, SDI, SYNC, CMD), and verifies stall-without-loss-or-reordering.
Includes the last-word continue-gate characterization (EXEC-FLOW-04), SDI
payload stability under sub-word backpressure at clk_div=0 (EXEC-FLOW-05), and
sdo_data_ready staying low after reset with no write in flight (EXEC-SDO-04).
"""

import os

import cocotb
from cocotb.triggers import RisingEdge, ClockCycles, ReadOnly

from framework.reset import apply_reset
from framework.spi import instructions as ins
from framework.spi.slave_model import SPISlaveModel
from tb_env import ExecutionTB

_ECHO_SCLK = int(os.environ.get("PARAM_ECHO_SCLK", 0))


@cocotb.test()
async def test_sdo_backpressure(dut):
    """Random gaps in the SDO data stream during a write transfer."""
    tb = ExecutionTB(dut)
    await tb.start()
    wl = tb.params["DATA_WIDTH"]
    n = 6
    data = [tb.rc.derive("sdo_bp").randrange(1 << wl)
            for _ in range(n * tb.num_sdio)]
    res = await tb.run_transfer(n=n, write=True, read=False, sdo_words=data,
                                sdo_gap=(0, 3))
    # REQ: EXEC-FLOW-01 - write transfer stalls until the outbound word is ready
    tb.sb.compare_sequences(res.sdo_words, tb.bus_mon.sdo_words, field="sdo")
    tb.sb.assert_no_errors()


@cocotb.test()
async def test_sdi_backpressure(dut):
    """Random sdi_data_ready toggling during a read transfer (bounded stalls).

    Uses a non-zero clk_div so a ready-stall stays within one SCLK word period;
    the div=0 sub-word corner is test_sdi_handshake_stability below.
    """
    tb = ExecutionTB(dut)
    await tb.start()
    wl = tb.params["DATA_WIDTH"]
    n = 6
    resp = [tb.rc.derive("sdi_bp").randrange(1 << wl)
            for _ in range(n * tb.num_sdio)]

    await tb.issue(ins.config_clk_div(2))
    await tb.wait_idle()
    tb.bp_sdi.start_burst(min_on=2, max_on=6, min_off=1, max_off=2)
    res = await tb.run_transfer(n=n, write=False, read=True, sdi_words=resp)
    await ClockCycles(dut.clk, 40)
    # REQ: EXEC-FLOW-02 - read transfer stalls until the SDI sink can accept
    tb.sb.compare_sequences(res.sdi_words, tb.sdi_values, field="sdi")
    tb.sb.assert_no_errors()


# EXEC-FLOW-02 (sustained, multi-word stall): test_sdi_backpressure above only
# exercises brief (1-2 cycle) gaps in sdi_data_ready at a non-zero divisor --
# comfortably inside the two-word capture buffer's slack (EXEC-SDI-06) and
# never close to forcing the module to actually gate/stall capture. This test
# instead withholds sdi_data_ready for several whole word periods at a time --
# far longer than the buffer can absorb -- and releases it for exactly one
# accepted beat at a time, so a transfer with more words than buffer capacity
# can only complete losslessly if the module genuinely stops advancing (no
# further capture) once the sink has stopped accepting: the behaviour
# EXEC-FLOW-02 describes, not just "short gaps are tolerated".
#
# Deliberately distinct from EXEC-SDI-07/08 (test_sdi.py): those characterize
# the sanctioned discard-on-full escape valve under backpressure that is never
# released. Here the sink *does* eventually accept every word -- just slowly --
# so a compliant module must deliver all of them losslessly with zero
# sdi_data_overflow pulses; any pulse, loss, or reordering here is a genuine
# EXEC-FLOW-02 violation, not a documented capacity boundary.
_SUSTAINED_STALL_N_WORDS = (
    3,    # one word beyond the two-word buffer capacity
    5,    # solidly multi-word beyond capacity
    8,    # longest sweep point
)


async def _drain_one_beat_or_timeout(dut, timeout_cycles):
    """Assert sdi_data_ready until exactly one beat is accepted, or give up.

    Returns True if a beat was accepted (valid && ready on some clock edge
    within the budget), else False. A bounded wait (rather than an unbounded
    one) lets the caller distinguish "no more words are ever coming" (the
    lossy failure mode under test) from a genuine testbench hang.
    """
    dut.sdi_data_ready.value = 1
    for _ in range(timeout_cycles):
        await ReadOnly()
        accepted = (int(dut.sdi_data_valid.value) == 1
                    and int(dut.sdi_data_ready.value) == 1)
        await RisingEdge(dut.clk)
        if accepted:
            dut.sdi_data_ready.value = 0
            return True
    dut.sdi_data_ready.value = 0
    return False


@cocotb.test()
async def test_sdi_sustained_multiword_stall(dut):
    """EXEC-FLOW-02 under a sustained, multi-word sdi_data_ready stall.

    For each `n` in `_SUSTAINED_STALL_N_WORDS` (word counts spanning one to
    several words beyond the two-word capture buffer's capacity,
    EXEC-SDI-06), holds sdi_data_ready low for several whole word periods at a
    time, then releases it just long enough to accept exactly one word,
    repeating until the sink has had the chance to drain every word the
    transfer will ever produce. DATA_WIDTH itself (and so word_length, held at
    its reset default here) is already swept across runner.py's CONFIGS, so
    this test varies only the stall-duration-relevant axis (word count beyond
    capacity) directly. A module that correctly implements EXEC-FLOW-02 stops
    advancing (no further SDI capture) once the buffer is full and the sink is
    not accepting, so every one of the n words arrives losslessly and in
    order, with sdi_data_overflow never pulsing -- regardless of how long or
    how many times the stall recurs. Losing any word (the discard-on-full path
    firing when it need not have) or presenting them out of order is a
    flow-control violation, not a capacity boundary.
    """
    tb = ExecutionTB(dut)
    await tb.start()
    wl = tb.params["DATA_WIDTH"]

    for n in _SUSTAINED_STALL_N_WORDS:
        tb.slave.stop()
        await apply_reset(dut, cycles_before=0, hold=3)
        tb.after_reset()

        await tb.issue(ins.chipselect(0, delay=1))
        await tb.wait_idle()

        rng = tb.rc.derive(f"sustained_stall_n{n}")
        resp = [rng.randrange(1 << wl) for _ in range(n * tb.num_sdio)]

        tb.bp_sdi.stop(final_value=0)
        cmd = ins.transfer(n - 1, write=False, read=True)
        res = tb.apply_cmd(cmd, sdi_data=resp)
        await tb.send_cmd(cmd)
        tb.slave.start()

        word_period = wl * tb.model.sclk_period
        hold_cycles = 3 * word_period + 20

        overflow_pulses = [0]

        async def _watch_overflow():
            while True:
                await RisingEdge(dut.clk)
                if int(dut.sdi_data_overflow.value) == 1:
                    overflow_pulses[0] += 1

        watcher = cocotb.start_soon(_watch_overflow())

        for _ in range(n):
            await ClockCycles(dut.clk, hold_cycles)
            accepted = await _drain_one_beat_or_timeout(dut, hold_cycles)
            if not accepted:
                # No more words will ever arrive (transfer already finished,
                # correctly or otherwise) - stop trickling rather than waiting
                # out the full schedule for nothing.
                break

        # Flush anything still pending, then let the transfer finish.
        tb.bp_sdi.start_always_ready()
        await tb.wait_idle(timeout_cycles=hold_cycles + 1000)
        await ClockCycles(dut.clk, 10)
        watcher.kill()

        label = f"sustained_stall_n{n}"
        # REQ: EXEC-FLOW-02 - every word arrives losslessly and in order under
        # a sustained, multi-word sink stall, not just a brief one
        tb.sb.compare_sequences(res.sdi_words, tb.sdi_values, field=label)
        # REQ: EXEC-FLOW-02 - a sink that eventually accepts every word must
        # never force the module to discard one; an overflow pulse here means
        # the module advanced past a word instead of stalling for the sink
        tb.sb.compare(0, f"{label}_overflow_pulses", 0, overflow_pulses[0])

        tb.sdi_mon.received.clear()

    tb.sb.assert_no_errors()


async def _finishes_within(dut, cycles):
    """Poll cmd_ready for up to `cycles` core clocks; True the first time it
    asserts, False if it never does within the window."""
    for _ in range(cycles):
        await RisingEdge(dut.clk)
        if int(dut.cmd_ready.value) == 1:
            return True
    return False


def _sustained_bp_combos(wl_full):
    """(n words, word_length, stall_mandatory) sweep for the sustained-
    backpressure EXEC-FLOW-02 test below.

    `stall_mandatory` marks whether `n` exceeds the documented 2-word SDI
    capture buffer (EXEC-SDI-06): at or under that capacity every captured
    word still fits, so the engine legitimately may finish the transfer
    promptly even though the sink never asserted `sdi_data_ready` - that is
    not a flow-control violation (the data sits safely buffered). Only past
    that capacity does EXEC-FLOW-02 make the mid-transfer stall mandatory.
    Both word-count and word_length are varied, not a single hardcoded point.
    """
    wl_half = max(2, wl_full // 2)
    return [
        (2, wl_full, False),   # at buffer capacity: prompt finish is legal
        (4, wl_full, True),    # safely past capacity
        (8, wl_full, True),    # longer sustained stall
        (4, wl_half, True),    # shorter word_length, same word count
    ]


@cocotb.test()
async def test_sdi_sustained_backpressure_no_loss(dut):
    """`sdi_data_ready` held low for an entire multi-word read (EXEC-FLOW-02).

    EXEC-FLOW-02: a read-enabled Transfer does not start/advance past a word
    until the SDI sink can accept the previously captured word; otherwise it
    stalls with no captured data lost. Past the 2-word capture buffer
    (EXEC-SDI-06) that makes a mid-transfer stall mandatory: the engine MUST
    NOT return to idle while `sdi_data_ready` has been held low the entire
    transfer, and once the sink is finally released every captured word MUST
    still arrive, intact and in order - none silently lost or overwritten.

    `test_sdi_backpressure` above only ever withholds `sdi_data_ready` for
    1-2 cycles at a time (a bursty, bit/word-level stall bounded well under
    one SCLK word period) - it cannot tell a datapath that tolerates a brief
    gap but not a sustained one apart from a fully compliant one. This test
    instead withholds `sdi_data_ready` continuously (`stop(final_value=0)`)
    across several captured words, so the stall is unambiguous and
    deterministic rather than relying on a random pattern happening to hold
    long enough. Swept over word count and word_length (see
    `_sustained_bp_combos`) and run across the whole CONFIGS sweep, including
    both ECHO_SCLK values - the requirement's validity domain is all
    parameters.

    Only boundary signals are used for the pass/fail check: `cmd_ready`,
    `sdi_data_valid`/`sdi_data_ready`/`sdi_data` via the monitor.
    """
    tb = ExecutionTB(dut)
    await tb.start()
    wl_full = tb.params["DATA_WIDTH"]

    for n, wl, stall_mandatory in _sustained_bp_combos(wl_full):
        tb.slave.stop()
        await apply_reset(dut, cycles_before=0, hold=3)
        tb.after_reset()

        if wl != wl_full:
            await tb.issue(ins.config_word_length(wl))
            await tb.wait_idle()
        await tb.issue(ins.chipselect(0, delay=1))
        await tb.wait_idle()

        # Withhold the SDI sink before the first word can even complete, and
        # keep it withheld for the whole transfer.
        tb.bp_sdi.stop(final_value=0)

        rng = tb.rc.derive(f"flow02_sustained_n{n}_wl{wl}")
        resp = [rng.randrange(1 << wl) for _ in range(n * tb.num_sdio)]
        cmd = ins.transfer(n - 1, write=False, read=True)
        res = tb.apply_cmd(cmd, sdi_data=resp)
        await tb.send_cmd(cmd)
        tb.slave.start()

        # Generous (2x + margin) multiple of the universal (EXEC-SCLK-01 +
        # EXEC-XFER-01, both "all parameters") minimum SCLK-generation time -
        # a lower bound on transfer duration valid under both ECHO_SCLK
        # values, used only to detect "finished anyway", not as an exact
        # completion-time claim.
        nominal = tb.model.shift_time(n)
        window = 2 * nominal + 300
        finished_early = await _finishes_within(dut, window)

        if stall_mandatory:
            # REQ: EXEC-FLOW-02 - must not advance past the buffer's capacity
            # while the sink has never accepted a single captured word
            tb.sb.compare(
                0, f"flow02_stall_n{n}_wl{wl}", False, finished_early,
                note="transfer returned to idle despite sdi_data_ready held "
                     "low the entire transfer - advanced past word "
                     "boundaries without the sink ever accepting a word")

        # Release the sink; let the engine (if still mid-transfer) drain.
        tb.bp_sdi.start_always_ready()
        await tb.wait_idle()
        await ClockCycles(dut.clk, 2 * wl * tb.model.sclk_period + 50)

        # Only the low `wl` bits of each captured word are specified
        # (EXEC-SDI-01 commits to the assembled word being presented on the
        # lane slice; it makes no claim about bits above word_length within
        # a DATA_WIDTH-wide slice when word_length < DATA_WIDTH - EXEC-FLOW-02
        # is a loss/ordering guarantee, not a masking one), so mask the
        # captured values the same way the golden model already masks its
        # expectation before comparing.
        wl_mask = (1 << wl) - 1
        actual = [v & wl_mask for v in tb.sdi_values]
        # REQ: EXEC-FLOW-02 - once the sink accepts, every captured word
        # arrives intact and in order - none lost or overwritten by the stall
        tb.sb.compare_sequences(res.sdi_words, actual,
                                field=f"flow02_sustained_n{n}_wl{wl}")
        tb.sdi_mon.received.clear()

    tb.sb.assert_no_errors()


@cocotb.test()
async def test_sync_backpressure(dut):
    """Holding sync_ready low stalls the engine until released."""
    tb = ExecutionTB(dut)
    await tb.start()

    tb.bp_sync.stop(final_value=0)
    sync_id = tb.rc.derive("sync_bp_id").randint(0, 0xFF)
    await tb.issue(ins.sync(sync_id))
    for _ in range(30):
        await RisingEdge(dut.clk)
    # REQ: EXEC-FLOW-03 - backpressure suspends progress; resumes losslessly
    assert int(dut.cmd_ready.value) == 0, "engine retired sync without ready"
    assert int(dut.sync_valid.value) == 1, "sync_valid should be held high"
    tb.sb.compare(0, "sync.id", sync_id, int(dut.sync.value))
    dut.sync_ready.value = 1
    await tb.wait_idle()
    tb.sb.assert_no_errors()


@cocotb.test()
async def test_cmd_backpressure(dut):
    """Gaps before commands; engine resumes correctly each time."""
    tb = ExecutionTB(dut)
    await tb.start()
    wl = tb.params["DATA_WIDTH"]
    rng = tb.rc.derive("cmd_bp")
    await tb.issue(ins.chipselect(0, delay=1))
    await tb.wait_idle()

    expected, captured_field = [], "cmd_bp"
    tb.bus_mon.words.clear()
    for k in range(4):
        await ClockCycles(dut.clk, rng.randint(0, 5))
        data = [rng.randrange(1 << wl) for _ in range(tb.num_sdio)]
        res = await tb.issue(ins.transfer(0, write=True, read=False),
                             sdo_data=data)
        expected += res.sdo_words
        cocotb.start_soon(tb.stream_sdo(res.sdo_words))
        await tb.wait_idle()
        await ClockCycles(dut.clk, 3)
    # REQ: EXEC-CC-06 - back-to-back transfers with backpressure keep order+data
    tb.sb.compare_sequences(expected, tb.bus_mon.sdo_words, field=captured_field)
    tb.sb.assert_no_errors()


@cocotb.test()
async def test_combined_backpressure(dut):
    """All streams under random backpressure simultaneously (read+write)."""
    tb = ExecutionTB(dut)
    await tb.start()
    wl = tb.params["DATA_WIDTH"]
    n = 8
    nwords = n * tb.num_sdio
    wdata = [tb.rc.derive("comb_w").randrange(1 << wl) for _ in range(nwords)]
    rdata = [tb.rc.derive("comb_r").randrange(1 << wl) for _ in range(nwords)]

    await tb.issue(ins.config_clk_div(2))
    await tb.wait_idle()
    tb.bp_sdi.start_burst(min_on=2, max_on=5, min_off=1, max_off=2)
    res = await tb.run_transfer(n=n, write=True, read=True, sdo_words=wdata,
                                sdi_words=rdata, sdo_gap=(0, 2))
    await ClockCycles(dut.clk, 40)
    # REQ: EXEC-FLOW-03 - simultaneous backpressure on all streams stays lossless
    tb.sb.compare_sequences(res.sdo_words, tb.bus_mon.sdo_words, field="sdo")
    tb.sb.compare_sequences(res.sdi_words, tb.sdi_values, field="sdi")
    tb.sb.assert_no_errors()


@cocotb.test()
async def test_last_word_no_extra_fetch(dut):
    """The last word does not require a further outbound word (FLOW-04).

    RTL-CHARACTERIZED optimization with a boundary-visible effect: a write
    transfer completes cleanly when exactly n+1 words are supplied and no more —
    the continue-gate on the last word does not wait for an (n+2)th word.
    """
    tb = ExecutionTB(dut)
    await tb.start()
    wl = tb.params["DATA_WIDTH"]
    n = tb.rc.derive("lastword_n").randint(2, 6)
    data = [tb.rc.derive("lastword").randrange(1 << wl)
            for _ in range(n * tb.num_sdio)]
    # Supply exactly n words (no trailing extra); transfer must still finish.
    res = await tb.run_transfer(n=n, write=True, read=False, sdo_words=data)
    # REQ: EXEC-FLOW-04 - last word does not require fetching a further word
    assert int(dut.cmd_ready.value) == 1, "engine hung waiting past last word"
    tb.sb.compare_sequences(res.sdo_words, tb.bus_mon.sdo_words, field="lastword")
    tb.sb.assert_no_errors()


def _sdi_stall_phase_pattern(wl, phase):
    """Single-accept-per-period ready pattern, with the accept cycle rotated to
    `phase` (0..wl-1) instead of pinned at position 0.

    Rotating the single accept cycle across every position covers every stall
    phase within the word period, not only phase 0 (`[1] + [0]*(wl-1)`).
    """
    return [1 if i == phase else 0 for i in range(wl)]


def _sdi_multi_gap_pattern(rng, wl, *, min_gaps=2, max_tries=50):
    """A seeded ready pattern with several separate withheld (ready=0) stretches
    in one word period, rather than the single contiguous gap the phase sweep
    above uses.

    Retries (deterministically, from the same seeded `rng`) until the generated
    pattern actually contains at least `min_gaps` separate withheld runs, so a
    lucky draw cannot silently degenerate into the single-gap case the phase
    sweep already covers. `rng` must come from a stable, seeded label (see
    `RandomContext.derive`) so the pattern replays bit-for-bit under a given
    RANDOM_SEED.
    """
    n_accepts = max(2, wl // 3)
    pattern = None
    for _ in range(max_tries):
        idx = set(rng.sample(range(wl), min(n_accepts, wl)))
        pattern = [1 if i in idx else 0 for i in range(wl)]
        gaps = sum(1 for i in range(wl)
                   if pattern[i] == 0 and pattern[i - 1] == 1)
        if gaps >= min_gaps:
            return pattern
    return pattern  # best effort after max_tries - still seeded/deterministic


async def _scan_sdi_stability(dut, ready_pattern, iterations):
    """Drive `ready_pattern` cyclically on sdi_data_ready for `iterations` core
    clocks, watching for sdi_data changing while valid & unaccepted.

    Returns True the first time a beat's payload changes across a cycle where
    the previous beat was valid-but-not-accepted (an AXI-Stream TDATA-hold
    violation), else False once `iterations` clocks elapse with no violation.
    """
    held = None
    prev_accept = True
    violation = False
    for i in range(iterations):
        dut.sdi_data_ready.value = ready_pattern[i % len(ready_pattern)]
        await RisingEdge(dut.clk)
        v = int(dut.sdi_data_valid.value)
        r = int(dut.sdi_data_ready.value)
        d = int(dut.sdi_data.value)
        if v == 1:
            if held is not None and not prev_accept and d != held:
                violation = True
                break
            held = d
        else:
            held = None
        prev_accept = (v == 1 and r == 1)
    dut.sdi_data_ready.value = 0
    return violation


@cocotb.test()
async def test_sdi_handshake_stability(dut):
    """SDI payload must stay stable while valid & unaccepted (EXEC-FLOW-05).

    AXI-Stream requires TDATA hold once VALID is asserted until VALID && READY.
    Accepting one beat every `wl` core clocks at clk_div=0 drains slower than the
    engine produces, so the next word shifts in before the previous is accepted.
    This is a property of the whole class of sub-word stalls, not one stall
    phase, so this sweeps every accept-phase within the word period (rotating
    which single cycle grants sdi_data_ready) plus seeded multi-gap patterns
    (several withheld stretches per period). clk_div stays at 0: only there
    does one accept every `wl` core clocks drain slower than words arrive.
    """
    tb = ExecutionTB(dut)
    await tb.start()
    wl = tb.params["DATA_WIDTH"]
    n = 6
    resp = [(0x11 * (k + 1)) & ((1 << wl) - 1) for k in range(n)]
    iterations = n * wl * 4 + 80

    tb.bp_sdi.stop(final_value=0)

    async def run_pattern(ready_pattern, label):
        await tb.issue(ins.chipselect(0, delay=1))
        await tb.wait_idle()
        await tb.issue(ins.transfer(n - 1, write=False, read=True), sdi_data=resp)
        tb.slave.start()
        violation = await _scan_sdi_stability(dut, ready_pattern, iterations)
        await ClockCycles(dut.clk, 5)
        # Clean, deterministic DUT state before the next phase/pattern - a
        # violation can break the scan mid-transfer, so start each point fresh
        # rather than risk stale in-flight state leaking into the next one.
        await apply_reset(dut, cycles_before=0, hold=3)
        tb.after_reset()
        # REQ: EXEC-FLOW-05 - sdi_data must stay stable under unaccepted valid
        assert not violation, (
            f"sdi_data changed under unaccepted valid (handshake) - {label}")

    # Sweep every accept-phase within the word period: a full word shifts in
    # every word period regardless of where the one accept cycle lands.
    for phase in range(wl):
        await run_pattern(_sdi_stall_phase_pattern(wl, phase), f"phase={phase}")

    # Plus seeded multi-gap patterns: several withheld stretches per period
    # instead of one contiguous gap, so a fix shaped around "one gap" cannot
    # pass while a scattered-stall shape still corrupts sdi_data.
    rng = tb.rc.derive("sdi_handshake_multigap")
    for k in range(3):
        pattern = _sdi_multi_gap_pattern(rng, wl)
        await run_pattern(pattern, f"multigap#{k}={pattern}")


def _sdi_delay_combos(wl_full):
    """(clk_div, word_length, chain, label) sweep for SDI_DELAY matched-latency
    capture correctness (EXEC-SDI-05).

    `chain` is a tuple of per-transfer word counts issued back-to-back (zero
    gap between commands, chip-select asserted once and held for the whole
    chain - EXEC-CMD-01, EXEC-XFER-08), so a transfer's last word and the next transfer's
    first word can be immediately adjacent: the tightest version of a
    word-to-word boundary, covering both a mid-transfer word-to-word boundary
    (`chain` of one multi-word transfer) and a transfer-to-transfer command
    boundary (`chain` of several single-word transfers).

    clk_div=0 is the tightest sampling window (one core clock per bit before
    any SDI_DELAY cost); clk_div=1 is included so the sweep does not only
    ever exercise div=0. word_length=1 is the minimum legal word (ECHO_SCLK is 0
    throughout every SDI_DELAY-swept config in runner.py's CONFIGS, so the
    documented word_length=1/ECHO_SCLK=1 hang does not apply here); combined
    with a single-word chain, every word boundary is also a transfer
    boundary, the tightest combination available.
    """
    return [
        (0, wl_full, (4,), "div0_wlfull_mid"),
        (0, 1, (4,), "div0_wlmin_mid"),
        (0, wl_full, (1, 1, 1, 1), "div0_wlfull_b2b"),
        (0, 1, (1, 1, 1, 1), "div0_wlmin_b2b"),
        (1, wl_full, (4,), "div1_wlfull_mid"),
    ]


# SDI_DELAY has no effect on the ECHO_SCLK=1 capture path (EXEC-SDI-05's own
# validity domain): echo mode samples off the device's echoed clock directly.
@cocotb.test(skip=_ECHO_SCLK == 1)
async def test_sdi_delayed_capture_survives_sclk_advance(dut):
    """EXEC-SDI-05: SDI capture must be correct at the SDI_DELAY-delayed
    sampling point, for an external device whose output latency the delay
    is meant to absorb.

    SDI_DELAY delays the sampling point of every SDI bit by SDI_DELAY core
    clocks to tolerate a real device's round-trip propagation delay at high
    SCLK rates. The DUT's delayed strobe is pipelined, so several bits can be
    in flight and capture stays correct at full SCLK rate. At clk_div=0 the
    correct device latencies L are SDI_DELAY and SDI_DELAY+1 (window
    [SDI_DELAY-clk_div, SDI_DELAY+clk_div+1] in core clocks); both are
    driven, so each edge of the window at clk_div=0 is covered.

    Driven with a plain edge-timed external SDI source (a bare
    `SPISlaveModel` with no sample-strobe hook, configured with
    `output_latency_clks`) rather than this testbench's usual whitebox
    `tb.slave`: the whitebox slave advances bits on the DUT's own internal
    capture strobe, which makes any capture-timing mismatch physically
    unobservable. A real external SPI slave just keeps shifting on every SCLK
    edge it sees, with its own latency - so this is the only way to exercise
    SDI_DELAY's real contract from outside the module.

    Swept over clk_div, word_length (minimum legal value and the full
    configured width) and whether the stressed boundary is mid-transfer or
    a back-to-back transfer-command boundary - see `_sdi_delay_combos`.
    SDI_DELAY itself is a build-time generic swept across runner.py's
    CONFIGS (0..3). At SDI_DELAY=0 this still checks the bare slave against
    every SPI mode.

    Pass/fail is on the externally observed sdi_data/sdi_data_valid/
    sdi_data_ready AXI stream only, compared against the golden model's
    expected words - no internal DUT state is used in the assertion.
    """
    tb = ExecutionTB(dut)
    await tb.start()
    wl_full = tb.params["DATA_WIDTH"]
    sdi_delay = tb.params["SDI_DELAY"]

    for clk_div, wl, chain, label in _sdi_delay_combos(wl_full):
        for latency in (sdi_delay, sdi_delay + 1):
            await apply_reset(dut, cycles_before=0, hold=3)
            tb.after_reset()

            await tb.issue(ins.config_clk_div(clk_div))
            await tb.wait_idle()
            if wl != wl_full:
                await tb.issue(ins.config_word_length(wl))
                await tb.wait_idle()
            await tb.issue(ins.chipselect(0, delay=1))
            await tb.wait_idle()

            rng = tb.rc.derive(
                f"sdi_delay_{label}_sdel{sdi_delay}_lat{latency}")
            expected = []
            cmds = []
            for n in chain:
                chunk = [rng.randrange(1 << wl)
                         for _ in range(n * tb.num_sdio)]
                cmd = ins.transfer(n - 1, write=False, read=True)
                res = tb.model.apply(cmd, sdi_data=chunk)
                tb._sync_agents_from_model()
                expected += res.sdi_words
                cmds.append(cmd)

            # Bare, non-whitebox slave: shifts on raw SCLK edges only, exactly
            # like a real external SPI device - see the docstring above for
            # why this (and not tb.slave) is required.
            ext_slave = SPISlaveModel(
                dut, cpol=tb.model.cpol, cpha=tb.model.cpha,
                word_length=wl, num_sdio=tb.num_sdio,
                output_latency_clks=latency)
            ext_slave.load(expected)
            ext_slave.start()

            for cmd in cmds:
                await tb.send_cmd(cmd)
            await tb.wait_idle()
            await ClockCycles(dut.clk, 2 * wl * tb.model.sclk_period + 50)

            ext_slave.stop()

            # Only the low `wl` bits of each captured word are specified
            # (EXEC-SDI-01 commits to the assembled word on the lane slice,
            # not to bits above word_length within a wider DATA_WIDTH slice),
            # so mask both sides the same way before comparing.
            wl_mask = (1 << wl) - 1
            actual = [v & wl_mask for v in tb.sdi_values]
            # REQ: EXEC-SDI-05 - with device latency inside the SDI_DELAY
            # window, every word (across mid-transfer and back-to-back
            # transfer boundaries) must be captured uncorrupted
            tb.sb.compare_sequences(
                expected, actual, field=f"sdi_delay_{label}_lat{latency}")
            tb.sdi_mon.received.clear()

    tb.sb.assert_no_errors()


@cocotb.test()
async def test_sdo_ready_cleared_by_reset(dut):
    """After a transfer and a reset, sdo_data_ready stays low with no command (EXEC-SDO-04)."""
    tb = ExecutionTB(dut)
    await tb.start()
    wl = tb.params["DATA_WIDTH"]
    rng = tb.rc.derive("sticky_ready")

    # Run a write transfer so exec_transfer_cmd_reg gets set to 1.
    n = rng.randint(2, 6)
    data = [rng.randrange(1 << wl) for _ in range(n * tb.num_sdio)]
    await tb.run_transfer(n=n, write=True, read=False, sdo_words=data)

    # Reset the engine. A clean reset should return the SDO request handshake to
    # its idle state (no data requested until a write instruction is in flight).
    await apply_reset(dut, cycles_before=0, hold=3)
    tb.after_reset()

    # FIFO mode, no command issued: drive sdo_data_valid and watch sdo_data_ready.
    tb.set_offload_active(False)
    dut.sdo_data_valid.value = 1
    dut.sdo_data.value = 0xA5 & ((1 << wl) - 1)
    asserted = False
    for _ in range(20):
        await RisingEdge(dut.clk)
        if int(dut.sdo_data_ready.value) == 1:
            asserted = True
            break
    dut.sdo_data_valid.value = 0
    # REQ: EXEC-SDO-04 - engine must not request SDO with no write instruction
    assert not asserted, "sdo_data_ready asserted post-reset with no command"


# Delays (in core clocks) between a back-to-back transfer's command being
# accepted and its own first SDO word becoming valid. 0 = already valid at
# acceptance; 1 = the tightest/most dangerous single-cycle staleness window;
# the rest sweep further into the gap so no single timing instant is special.
B2B_SDO_DELAYS = (0, 1, 2, 5)


async def _delay_then_stream(tb, dut, words, delay, poison):
    """Hold/poison the SDO bus for `delay` cycles after a back-to-back
    transfer's command is accepted, then hand off to the real word stream.

    Encodes EXEC-FLOW-01 directly from its text at the point most likely to
    expose a violation: the engine must not start a word (no SCLK advance, no
    data consumed) until its own outbound word is available, regardless of
    whether the command was itself accepted back-to-back with the previous
    transfer (EXEC-CMD-01, EXEC-XFER-08). EXEC-FLOW-04's "no further word needed" exception
    is scoped only to the *same* transfer's last word, so it exempts nothing
    here - this is a different (the next) transfer's first word.
    """
    wl = tb.params["DATA_WIDTH"]
    dut.sdo_data_valid.value = 0
    dut.sdo_data.value = poison & ((1 << wl) - 1)
    for _ in range(delay):
        await RisingEdge(dut.clk)
        # REQ: EXEC-FLOW-01 - transfer stalls (no word shift starts) while its
        # own first word is not yet valid on the SDO stream.
        #
        # Checked via transfer_active rather than the sclk output pin:
        # sclk is sclk_int registered an extra cycle behind transfer_active
        # (two flip-flops of pipeline lag in the clock-output path), so it
        # shows one legitimate transitional toggle at every transfer
        # boundary (the tail of the previous transfer's last sclk_int value
        # draining through) even when the module is correctly stalled.
        # transfer_active is the actual gating state with no such output
        # register lag.
        assert int(dut.transfer_active.value) == 0, (
            f"Transfer went active before the new transfer's first SDO word "
            f"was valid (delay={delay} cycles) at a back-to-back boundary")
    cocotb.start_soon(tb.stream_sdo(words))


# A back-to-back Transfer's first word waits for its own SDO data (EXEC-FLOW-01).
@cocotb.test()
async def test_b2b_transfer_sdo_not_ready(dut):
    """EXEC-FLOW-01 at a back-to-back transfer boundary.

    Existing coverage exercises EXEC-FLOW-01 mid-transfer (test_sdo_backpressure,
    above) and back-to-back completion in isolation (EXEC-CMD-01 + EXEC-XFER-08, see
    test_transfer.py/test_completion_bound_back_to_back), but not their
    intersection: a Transfer command accepted in the very cycle the previous
    Transfer's cmd_ready reasserts (the tightest possible zero-gap reissue),
    where the new transfer's own first SDO word is not yet valid at that
    instant. EXEC-FLOW-01 must still hold at this boundary - the transfer
    stalls until its own data is ready rather than starting with stale/invalid
    data left over from the previous transfer.

    Sweeps the SDO-availability delay (0 cycles, 1 cycle - the tightest/most
    dangerous window, and several cycles beyond, see B2B_SDO_DELAYS) across a
    chain of 4 back-to-back write transfers (3 consecutive boundaries), so the
    check covers the bug CLASS rather than one timing instant. While a
    boundary's data is withheld, the bus is poisoned with a sentinel word so
    any premature consumption is caught unambiguously; the final data/order
    check also covers the positive path (data ready in time -> correct,
    uncorrupted word ordering), catching a word-slip class of failure as well
    as an outright stall violation.
    """
    tb = ExecutionTB(dut)
    await tb.start()
    wl = tb.params["DATA_WIDTH"]
    mask = (1 << wl) - 1
    poison = mask
    chain_len = 4

    for delay in B2B_SDO_DELAYS:
        await apply_reset(dut, cycles_before=0, hold=3)
        tb.after_reset()
        await tb.issue(ins.chipselect(0, delay=1))
        await tb.wait_idle()

        rng = tb.rc.derive(f"b2b_sdo_delay{delay}")
        chain = []
        for _ in range(chain_len):
            nper = rng.randint(2, 4)
            data = [rng.randrange(1 << wl) for _ in range(nper * tb.num_sdio)]
            # Keep every word distinct from the poison sentinel so a premature
            # read of the poisoned bus can never be mistaken for real data.
            data = [d if d != poison else (d ^ 1) for d in data]
            chain.append((ins.transfer(nper - 1, write=True, read=False), data))

        expected = []
        tb.bus_mon.words.clear()

        cmd0, data0 = chain[0]
        res0 = tb.apply_cmd(cmd0, sdo_data=data0)
        await tb.send_cmd(cmd0)
        expected += res0.sdo_words
        cocotb.start_soon(tb.stream_sdo(res0.sdo_words))

        for cmd, data in chain[1:]:
            res = tb.apply_cmd(cmd, sdo_data=data)
            # Zero-gap reissue (EXEC-CMD-01): cmd_valid is asserted from the
            # instant this coroutine resumes (no intervening await) while the
            # previous transfer is still executing, so acceptance lands on
            # the exact edge cmd_ready reasserts.
            await tb.send_cmd(cmd)
            expected += res.sdo_words
            await _delay_then_stream(tb, dut, res.sdo_words, delay, poison)

        await tb.wait_idle()
        await ClockCycles(dut.clk, 3)
        # REQ: EXEC-FLOW-01 - word data/order stays correct at every
        # back-to-back boundary once each transfer's own data is available
        tb.sb.compare_sequences(expected, tb.bus_mon.sdo_words,
                                field=f"b2b_sdo_delay{delay}")
    tb.sb.assert_no_errors()
