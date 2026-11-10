"""Transfer instruction: SDO/SDI datapaths, and EXEC-CC-02/03.

Covers the Transfer instruction end-to-end at the module boundary: word count
(n+1), MSB-first shifting on both directions, the four {r,w} combinations
(including the clock-only 00 characterization lock), sdo_t polarity, sdo idle
level, short (MSB-aligned) words, single/multi-word termination, and the
transfer completion bound (EXEC-XFER-08).

Data is checked exactly; completion time against an upper bound.
"""

import os

import cocotb
from cocotb.triggers import RisingEdge, ClockCycles

from framework.reset import apply_reset
from framework.spi import instructions as ins
from tb_env import ExecutionTB, distinct_bits

_ECHO_SCLK = int(os.environ.get("PARAM_ECHO_SCLK", 0))


@cocotb.test()
async def test_write_only(dut):
    """w=1 r=0: SDO words shifted out match the streamed data, sdo_t driven."""
    tb = ExecutionTB(dut)
    await tb.start()
    wl = tb.params["DATA_WIDTH"]
    n = 4
    data = [tb.rc.derive("wdata").randrange(1 << wl)
            for _ in range(n * tb.num_sdio)]

    await tb.issue(ins.chipselect(0, delay=1))
    await tb.wait_idle()

    res = await tb.issue(ins.transfer(n - 1, write=True, read=False),
                         sdo_data=data)
    tb.start_sdo_stream(res.sdo_words)
    # REQ: EXEC-XFER-03 - during a write sdo_t is driven (0)
    sdo_t = await tb.sample_sdo_t_during_transfer()
    # REQ: EXEC-BUS-03 - sdo_t is 0 (driven) only during a write transfer
    tb.sb.compare(0, "sdo_t.write", 0, sdo_t)
    await tb.wait_idle()
    await ClockCycles(dut.clk, 5)

    # REQ: EXEC-XFER-01 - n+1 words generated for the transfer
    # REQ: EXEC-XFER-02 - bits shifted MSB-first (monitor reconstructs from wire)
    # REQ: EXEC-SDO-01 - each word MSB-first, one bit per SCLK bit-period
    # REQ: EXEC-SDO-04 - exactly n+1 words consumed from the SDO stream
    tb.sb.compare_sequences(res.sdo_words, tb.bus_mon.sdo_words, field="sdo")
    tb.sb.assert_no_errors()


@cocotb.test()
async def test_read_only(dut):
    """w=0 r=1: SDI words captured match the slave; sdo tristated/idle."""
    tb = ExecutionTB(dut)
    await tb.start()
    wl = tb.params["DATA_WIDTH"]
    n = 4
    resp = [tb.rc.derive("rdata").randrange(1 << wl)
            for _ in range(n * tb.num_sdio)]

    await tb.issue(ins.chipselect(0, delay=1))
    await tb.wait_idle()

    res = await tb.issue(ins.transfer(n - 1, write=False, read=True),
                         sdi_data=resp)
    tb.slave.start()
    # REQ: EXEC-XFER-06 - during a read (w=0) sdo_t is tristated (1)
    sdo_t = await tb.sample_sdo_t_during_transfer()
    tb.sb.compare(0, "sdo_t.read", 1, sdo_t)
    await tb.wait_idle()
    await ClockCycles(dut.clk, 5)

    # REQ: EXEC-XFER-04 - sdi sampled and assembled word presented on SDI stream
    # REQ: EXEC-SDI-01 - sdi sampled MSB-first into the lane slice
    # REQ: EXEC-SDI-02 - sdi_data_valid asserts once a word is received, held to ready
    # REQ: EXEC-SDI-03 - exactly n+1 SDI words produced
    tb.sb.compare_sequences(res.sdi_words, tb.sdi_values, field="sdi")
    tb.sb.assert_no_errors()


@cocotb.test()
async def test_read_write_full_duplex(dut):
    """w=1 r=1: both directions exercised simultaneously."""
    tb = ExecutionTB(dut)
    await tb.start()
    wl = tb.params["DATA_WIDTH"]
    n = 3
    nwords = n * tb.num_sdio
    wdata = [tb.rc.derive("rw_w").randrange(1 << wl) for _ in range(nwords)]
    rdata = [tb.rc.derive("rw_r").randrange(1 << wl) for _ in range(nwords)]

    await tb.issue(ins.chipselect(0, delay=1))
    await tb.wait_idle()

    res = await tb.issue(ins.transfer(n - 1, write=True, read=True),
                         sdo_data=wdata, sdi_data=rdata)
    tb.slave.start()
    await tb.stream_sdo(res.sdo_words)
    await tb.wait_idle()
    await ClockCycles(dut.clk, 5)

    # (XFER-05 all-four-{r,w} is homed in test_clock_only_transfer; rw=11 here)
    # REQ: EXEC-SDI-04 - each SDIO lane captured into its own DATA_WIDTH slice
    tb.sb.compare_sequences(res.sdo_words, tb.bus_mon.sdo_words, field="sdo")
    tb.sb.compare_sequences(res.sdi_words, tb.sdi_values, field="sdi")
    tb.sb.assert_no_errors()


@cocotb.test()
async def test_full_duplex_last_repeat_no_deadlock(dut):
    """A full-duplex, multi-word transfer's LAST repeat must not deadlock.

    On the last word there is no further SDO word to fetch, so the transfer
    must complete without one (EXEC-FLOW-04), also while that word's
    SDI_DELAY-delayed capture is still in flight (worst case `SDI_DELAY>0`,
    `clk_div=0`).

    Unlike other tests, this asserts completion within a small explicit cycle
    bound instead of `tb.wait_idle()`'s generous 100000-cycle default, so a
    regression here fails fast with a named, attributable timeout rather than
    silently inflating (or hanging) the whole suite's runtime.
    """
    tb = ExecutionTB(dut)
    await tb.start()
    wl = tb.params["DATA_WIDTH"]
    clk_div = tb.params["DEFAULT_CLK_DIV"]
    sdi_delay = tb.params["SDI_DELAY"]
    n = 3
    nwords = n * tb.num_sdio
    wdata = [tb.rc.derive("deadlock_w").randrange(1 << wl) for _ in range(nwords)]
    rdata = [tb.rc.derive("deadlock_r").randrange(1 << wl) for _ in range(nwords)]

    await tb.issue(ins.chipselect(0, delay=1))
    await tb.wait_idle()

    res = await tb.issue(ins.transfer(n - 1, write=True, read=True),
                         sdo_data=wdata, sdi_data=rdata)
    tb.slave.start()
    await tb.stream_sdo(res.sdo_words)

    # Generous-but-bounded: n words at wl bits/word, 2 core clocks per SCLK
    # half-period times (clk_div+1), plus the SDI_DELAY pipeline drain and a
    # fixed margin for command/handshake overhead - comfortably above the
    # worst case across the CONFIGS sweep, but two orders of magnitude below
    # wait_idle's default so a real deadlock is reported promptly.
    bound = n * wl * 2 * (clk_div + 1) + sdi_delay * 4 + 500
    # REQ: EXEC-FLOW-04 - the last word completes without a further SDO word
    await tb.wait_idle(timeout_cycles=bound)
    await ClockCycles(dut.clk, 5)

    tb.sb.compare_sequences(res.sdo_words, tb.bus_mon.sdo_words, field="sdo")
    tb.sb.compare_sequences(res.sdi_words, tb.sdi_values, field="sdi")
    tb.sb.assert_no_errors()


@cocotb.test()
async def test_clock_only_transfer(dut):
    """rw=00: SCLK toggles with no stream traffic (RTL-CHARACTERIZED lock).

    Neither reference driver emits a clock-only transfer (spec Appendix C), so
    this is a regression lock, not a conformance check: it pins the current RTL
    behaviour (SCLK runs, no SDO/SDI words move) ahead of any driver need.
    """
    tb = ExecutionTB(dut)
    await tb.start()
    await tb.issue(ins.config_clk_div(1))
    await tb.wait_idle()
    await tb.issue(ins.chipselect(0, delay=1))
    await tb.wait_idle()

    tb.bus_mon.words.clear()
    # No sdo_data streamed, no slave started: a dummy transfer.
    await tb.issue(ins.transfer(2, write=False, read=False))
    saw_sclk = await tb.measure_sclk_period()
    await tb.wait_idle()
    await ClockCycles(dut.clk, 5)
    # REQ: EXEC-XFER-05 - clock-only/dummy (rw=00) toggles SCLK, no stream traffic
    assert saw_sclk > 0, "SCLK did not toggle during a clock-only transfer"
    assert len(tb.sdi_mon.received) == 0, "SDI words produced on a rw=00 transfer"
    tb.sb.assert_no_errors()


@cocotb.test()
async def test_sdo_idle_outside_transfer(dut):
    """Outside a write transfer every sdo lane presents sdo_idle_state."""
    tb = ExecutionTB(dut)
    await tb.start()
    await tb.issue(ins.chipselect(0, delay=1))
    await tb.wait_idle()
    await ClockCycles(dut.clk, 5)
    idle = tb.params.get("SDO_DEFAULT", 0)
    # REQ: EXEC-SDO-03 - sdo presents sdo_idle_state when no write is active
    tb.sb.compare(0, "sdo_idle",
                  idle * ((1 << tb.num_sdio) - 1), int(dut.sdo.value))
    tb.sb.assert_no_errors()


@cocotb.test()
async def test_single_and_multi_word(dut):
    """n=0 (single), n>0 (multi) and a long (max) transfer all terminate to idle.

    The long case caps its word count on wide DATA_WIDTH builds to keep runtime
    reasonable under Verilator; 256 words at wl=8 is fast.
    """
    tb = ExecutionTB(dut)
    await tb.start()
    wl = tb.params["DATA_WIDTH"]
    rng = tb.rc.derive("nwords")
    long_n = 256 if wl <= 8 else 64

    await tb.issue(ins.chipselect(0, delay=1))
    await tb.wait_idle()

    for nper in (1, 5, long_n):
        data = [rng.randrange(1 << wl) for _ in range(nper * tb.num_sdio)]
        tb.bus_mon.words.clear()
        res = await tb.run_transfer(n=nper, write=True, read=False,
                                    sdo_words=data)
        # REQ: EXEC-CC-02 - single, multi and max-length transfers all terminate
        tb.sb.compare_sequences(res.sdo_words, tb.bus_mon.sdo_words,
                                field=f"n{nper}")
        assert int(dut.cmd_ready.value) == 1, "engine not idle after transfer"
    tb.sb.assert_no_errors()


@cocotb.test()
async def test_short_word_msb_aligned(dut):
    """word_length < DATA_WIDTH: short words are MSB-aligned on the wire."""
    tb = ExecutionTB(dut)
    await tb.start()
    wl_full = tb.params["DATA_WIDTH"]
    new_wl = max(1, wl_full // 2)
    await tb.issue(ins.config_word_length(new_wl))
    await tb.wait_idle()
    await tb.issue(ins.chipselect(0, delay=1))
    await tb.wait_idle()

    data = [tb.rc.derive("shortwl").randrange(1 << new_wl)
            for _ in range(2 * tb.num_sdio)]
    res = await tb.run_transfer(n=2, write=True, read=False, sdo_words=data)
    # REQ: EXEC-SDO-02 - short word MSB-aligned (bit word_length-1 first)
    # REQ: EXEC-CC-03 - min/short word length works, MSB-aligned
    # REQ: EXEC-PARAM-03 - DATA_WIDTH sizes the word granularity
    tb.sb.compare_sequences(res.sdo_words, tb.bus_mon.sdo_words, field="short")
    tb.sb.assert_no_errors()


def _data(tb, tag, n_words, wl):
    rng = tb.rc.derive(tag)
    return [rng.randrange(1 << wl) for _ in range(n_words * tb.num_sdio)]


async def _prep(tb, div, wl):
    """Program clk_div / word_length and assert chip-select."""
    await tb.issue(ins.config_clk_div(div))
    await tb.wait_idle()
    await tb.issue(ins.config_word_length(wl))
    await tb.wait_idle()
    await tb.issue(ins.chipselect(0, delay=1))
    await tb.wait_idle()


_MODES = [(True, False), (False, True), (True, True), (False, False)]
_MODE_NAME = {(True, False): "w", (False, True): "r",
              (True, True): "rw", (False, False): "clk"}


def _lanes(tb, mask=None):
    mask = tb.model.sdo_lane_mask if mask is None else mask
    return max(1, bin(mask & ((1 << tb.num_sdio) - 1)).count("1"))


class _Margin:
    """Tracks the largest overhead (CORE_CLK_CNT - shifting term) seen."""

    def __init__(self):
        self.max_instr = 0     # overhead per instruction
        self.max_word = 0.0    # overhead per word (overhead / (n+1))
        self.min_margin = None
        self.points = 0

    def add(self, tb, elapsed, n_words, wl, div, note):
        shift = n_words * wl * (div + 1) * 2
        bound = tb.model.completion_bound(n_words, wl, div)
        over = elapsed - shift
        self.max_instr = max(self.max_instr, over)
        self.max_word = max(self.max_word, over / n_words)
        margin = bound - elapsed
        self.min_margin = margin if self.min_margin is None \
            else min(self.min_margin, margin)
        self.points += 1
        # REQ: EXEC-XFER-08 - CORE_CLK_CNT <= (n+1)*wl*(div+1)*2 + 16*(n+2)
        ok = tb.sb.compare(self.points, "completion<=bound", True,
                           elapsed <= bound,
                           note=f"{note}: elapsed={elapsed} bound={bound} "
                                f"overhead={over} ({over / n_words:.1f}/word)")
        if not ok:
            tb.log.error(f"BOUND VIOLATION {note} elapsed={elapsed} "
                         f"bound={bound} overhead={over}")

    def log(self, tb, label):
        tb.log.info(f"{label}: points={self.points} "
                    f"max_overhead_per_instruction={self.max_instr} "
                    f"max_overhead_per_word={self.max_word:.2f} "
                    f"min_margin_to_bound={self.min_margin}")


async def _bounded_transfer(tb, n_words, write, read, tag):
    """One Transfer with SDO source valid and SDI sink ready throughout.

    The SDO stream is started before the command so words are already offered
    when the engine first asks; the SDI sink is always ready (tb default).
    Returns CORE_CLK_CNT (accept -> idle).
    """
    wl = tb.model.word_length
    sdo = _data(tb, tag + "o", n_words * _lanes(tb) // tb.num_sdio + 1, wl)
    sdo = sdo[:n_words * _lanes(tb)]
    sdi = _data(tb, tag + "i", n_words, wl)
    cmd = ins.transfer(n_words - 1, write=write, read=read)
    res = tb.apply_cmd(cmd, sdo_data=sdo if write else None,
                       sdi_data=sdi if read else None)
    if write:
        tb.start_sdo_stream(res.sdo_words)
    t_accept = await tb.send_cmd(cmd)
    if read:
        tb.slave.start()
    await tb.wait_idle()
    return tb.now_cycles() - t_accept


@cocotb.test(skip=_ECHO_SCLK == 1)
async def test_completion_bound(dut):
    """Transfer CORE_CLK_CNT stays within the EXEC-XFER-08 bound.

    {w, r, rw, clock-only} x word_length {1, 2, mid, DATA_WIDTH} x
    div {0, 1, 2, 5} x n+1 {1, 2, 3, 8}, at the build's SDI_DELAY and
    NUM_OF_SDIO. The measured overhead is logged.
    """
    tb = ExecutionTB(dut)
    await tb.start()
    dw = tb.params["DATA_WIDTH"]
    wls = sorted({1, 2, max(1, dw // 2), dw})
    m = _Margin()
    for div in (0, 1, 2, 5):
        for wl in wls:
            await _prep(tb, div, wl)
            for write, read in _MODES:
                mm = _Margin()
                for n_words in (1, 2, 3, 8):
                    await ClockCycles(dut.clk, 3)
                    note = (f"{_MODE_NAME[(write, read)]} div={div} wl={wl} "
                            f"words={n_words}")
                    el = await _bounded_transfer(
                        tb, n_words, write, read,
                        f"cb{div}_{wl}_{write}{read}_{n_words}")
                    m.add(tb, el, n_words, wl, div, note)
                    mm.add(tb, el, n_words, wl, div, note)
                mm.log(tb, f"bound {_MODE_NAME[(write, read)]} div={div} wl={wl}")
    m.log(tb, "bound ALL")
    tb.sb.assert_no_errors()


@cocotb.test(skip=_ECHO_SCLK == 1)
async def test_completion_bound_lane_masks(dut):
    """EXEC-XFER-08 bound holds with partial SDO lane masks (write, rw)."""
    tb = ExecutionTB(dut)
    await tb.start()
    dw = tb.params["DATA_WIDTH"]
    nsd = tb.num_sdio
    masks = {1, 1 | (1 << (nsd - 1)), (1 << nsd) - 1}
    if nsd > 2:
        masks.add(0b10)
    m = _Margin()
    for mask in sorted(masks):
        await tb.issue(ins.config_sdo_lane_mask(mask))
        await tb.wait_idle()
        for div in (0, 1):
            for wl in sorted({1, 2, dw}):
                await _prep(tb, div, wl)
                for write, read in ((True, False), (True, True)):
                    for n_words in (1, 3):
                        await ClockCycles(dut.clk, 3)
                        note = (f"mask=0x{mask:x} {_MODE_NAME[(write, read)]} "
                                f"div={div} wl={wl} words={n_words}")
                        el = await _bounded_transfer(
                            tb, n_words, write, read,
                            f"cm{mask}_{div}_{wl}_{read}_{n_words}")
                        m.add(tb, el, n_words, wl, div, note)
    m.log(tb, "bound lane masks")
    tb.sb.assert_no_errors()


async def _run_chain(tb, links, tag):
    """Zero-gap back-to-back chain; returns per-link CORE_CLK_CNT.

    ``links``: list of (n_words, write, read). The SDO source is streamed from
    before the first command. Each link is measured accept-to-accept; the last
    link accept-to-idle.
    """
    wl = tb.model.word_length
    lanes = _lanes(tb)
    cmds = [ins.transfer(n - 1, write=w, read=r) for n, w, r in links]
    stream = []
    for i, (n, w, r) in enumerate(links):
        if w:
            stream += _data(tb, f"{tag}o{i}", n * lanes, wl)[:n * lanes]
    if stream:
        tb.start_sdo_stream(stream)
    times = []
    for i, (n, w, r) in enumerate(links):
        sdi = _data(tb, f"{tag}i{i}", n, wl) if r else None
        if i == 0:
            tb.apply_cmd(cmds[0], sdo_data=stream if w else None, sdi_data=sdi)
            times.append(await tb.send_cmd(cmds[0]))
            tb.slave.start()
        else:
            times.append(await tb.send_cmd(cmds[i]))
            tb.apply_cmd(cmds[i], sdo_data=stream if w else None, sdi_data=sdi)
    await tb.wait_idle()
    times.append(tb.now_cycles())
    return [times[i + 1] - times[i] for i in range(len(links))]


@cocotb.test(skip=_ECHO_SCLK == 1)
async def test_completion_bound_back_to_back(dut):
    """EXEC-XFER-08 bound holds for every link of a zero-gap chain.

    Chains of 4 with mixed {w, r, rw, clock-only} and uniform-mode chains,
    word_length {1, 2, DATA_WIDTH}, div {0, 2}, n+1 in {1, 2, 3, 8}. Each link
    is measured individually (accept-to-accept).
    """
    tb = ExecutionTB(dut)
    await tb.start()
    dw = tb.params["DATA_WIDTH"]
    ns = (1, 2, 3, 8)
    m = _Margin()
    for div in (0, 2):
        for wl in sorted({1, 2, dw}):
            await _prep(tb, div, wl)
            chains = []
            for s in range(4):
                chains.append([(ns[(s + i) % 4],) + _MODES[(s + i) % 4]
                               for i in range(4)])
            for mode in _MODES:
                chains.append([(ns[(k + 1) % 4],) + mode for k in range(3)])
            for ci, links in enumerate(chains):
                await ClockCycles(dut.clk, 5)
                els = await _run_chain(tb, links, f"b2b{div}_{wl}_{ci}")
                for i, ((n, w, r), el) in enumerate(zip(links, els)):
                    m.add(tb, el, n, wl, div,
                          f"chain{ci} link{i} {_MODE_NAME[(w, r)]} div={div} "
                          f"wl={wl} words={n}")
    m.log(tb, "bound back-to-back")
    tb.sb.assert_no_errors()


@cocotb.test()
async def test_min_word_length(dut):
    """word_length=1: single-bit words shift out correctly at every clk_div.

    Swept over clk_div 0, 1, 2 and 5 (word_length=1 x clk_div=0 included).
    Data is a fixed aperiodic, unequal bit sequence (n x lanes words), so a
    shift of the stream by any number of slots, or a repeated/dropped bit,
    is always visible. Each point starts from a reset if an earlier point
    failed, so one fault cannot corrupt the following points.
    Runs at ECHO_SCLK=0 and 1. At ECHO_SCLK=1 the echo path must detect the
    end of every 1-bit word, so the multi-word transfer completes;
    `test_min_word_length_above_one_no_hang` covers word_length=2. The full
    word_length x clk_div x mode cross is in test_sdo_word_coverage.
    """
    tb = ExecutionTB(dut)
    await tb.start()
    n = 4
    data = distinct_bits(n * tb.num_sdio)
    seen = 0
    for div in (0, 1, 2, 5):
        if len(tb.sb.mismatches) > seen:
            # Isolate a failed point: reset so later points are judged alone.
            await apply_reset(dut, cycles_before=0, hold=3)
            tb.after_reset()
        seen = len(tb.sb.mismatches)
        await tb.issue(ins.config_word_length(1))
        await tb.wait_idle()
        await tb.issue(ins.config_clk_div(div))
        await tb.wait_idle()
        tb.bus_mon.words.clear()
        res = await tb.run_transfer(n=n, write=True, read=False,
                                    sdo_words=data)
        # REQ: EXEC-CC-03 - minimum word_length (wl=1 extreme) shifts out correctly
        tb.sb.compare_sequences(res.sdo_words, tb.bus_mon.sdo_words,
                                field=f"minwl_div{div}")
    tb.sb.assert_no_errors()


@cocotb.test()
async def test_min_word_length_above_one_no_hang(dut):
    """word_length=2 (smallest word_length>1): multi-word transfer completes.

    Companion to test_min_word_length: same n/direction and clk_div sweep
    (0, 1, 2, 5), only word_length differs. The transfer completes and
    `run_transfer`'s `wait_idle()` returns, at ECHO_SCLK=0 and 1. Each point
    starts from a reset if an earlier point failed, so one fault cannot
    corrupt the following points.
    """
    tb = ExecutionTB(dut)
    await tb.start()
    wl = 2
    n = 4
    seen = 0
    for div in (0, 1, 2, 5):
        if len(tb.sb.mismatches) > seen:
            # Isolate a failed point: reset so later points are judged alone.
            await apply_reset(dut, cycles_before=0, hold=3)
            tb.after_reset()
        seen = len(tb.sb.mismatches)
        await tb.issue(ins.config_word_length(wl))
        await tb.wait_idle()
        await tb.issue(ins.config_clk_div(div))
        await tb.wait_idle()
        tb.bus_mon.words.clear()
        data = [tb.rc.derive(f"minwl_above1_div{div}").randrange(1 << wl)
                for _ in range(n * tb.num_sdio)]
        res = await tb.run_transfer(n=n, write=True, read=False, sdo_words=data)
        # REQ: EXEC-XFER-01 - an N-word transfer completes at word_length=2
        tb.sb.compare_sequences(res.sdo_words, tb.bus_mon.sdo_words,
                                field=f"minwl_above1_div{div}")
        assert int(dut.cmd_ready.value) == 1, \
            f"engine not idle after word_length=2 transfer (div={div})"
    tb.sb.assert_no_errors()


@cocotb.test()
async def test_transfer_stalls_on_backpressure(dut):
    """A transfer does not advance past a word boundary until flow-ready."""
    tb = ExecutionTB(dut)
    await tb.start()
    wl = tb.params["DATA_WIDTH"]
    n = 5
    data = [tb.rc.derive("xfer_bp").randrange(1 << wl)
            for _ in range(n * tb.num_sdio)]
    # Random gaps in the SDO producer: engine must stall losslessly.
    res = await tb.run_transfer(n=n, write=True, read=False, sdo_words=data,
                                sdo_gap=(1, 3))
    # REQ: EXEC-XFER-07 - transfer stalls until flow-control readiness, no loss
    tb.sb.compare_sequences(res.sdo_words, tb.bus_mon.sdo_words, field="sdo")
    tb.sb.assert_no_errors()
