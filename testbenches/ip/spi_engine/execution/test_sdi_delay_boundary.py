"""SDI capture at instruction boundaries under SDI_DELAY.

A delayed SDI capture strobe can still be in flight when the next instruction
starts. These tests run short instruction programs back to back (zero-gap
command stream, chip-select held) and check what the module hands to the SDI
and SYNC consumers: word count, word values, and SDI-before-SYNC ordering.

Oracle (independent of the RTL): the golden model applies each instruction;
every read-enabled Transfer contributes its response words, in program order,
to the expected SDI stream. The external device is a bare `SPISlaveModel`
(shifts on SCLK edges only, output latency = SDI_DELAY core clocks, started
when the read transfer becomes active and stopped when the next instruction
is accepted). Read words are nonzero, so a spurious word sampled from the idle
line (0) is distinguishable from a real one. SDI and SYNC sinks accept
immediately unless a test applies backpressure.

Checks per program, all on boundary signals:
  * the command stream drains and the module returns to idle;
  * SDI word count and values equal the expected stream;
  * the SYNC ids equal the issued ids, and every SDI word of the reads issued
    before a SYNC was accepted by the SDI sink no later than the cycle that
    SYNC was first presented (`sync_valid`).
"""

import itertools
import os

import cocotb
from cocotb.triggers import RisingEdge, ClockCycles

from framework.reset import apply_reset
from framework.spi import instructions as ins
from framework.spi.slave_model import SPISlaveModel
from tb_env import ExecutionTB

_ECHO_SCLK = int(os.environ.get("PARAM_ECHO_SCLK", 0))

_ALT_WL = 4  # shorter word length used by mid-program word_length changes


def _plan(tb, program, rng):
    """Apply `program` to the golden model; return commands and expectations."""
    lanes = tb.num_sdio
    steps = []        # (cmd, read_words | None, word_length)
    sdo = []
    expected = []
    masks = []
    syncs = []        # (sync_id, SDI beats expected before it)
    beats = 0
    work = 0
    for op in program:
        kind = op[0]
        wl = tb.model.word_length
        if kind in ("write", "read", "rw"):
            n = op[1]
            write = kind in ("write", "rw")
            read = kind in ("read", "rw")
            cmd = ins.transfer(n - 1, write=write, read=read)
            sdo_chunk = ([rng.randrange(1 << wl) for _ in range(n * lanes)]
                         if write else None)
            sdi_chunk = ([rng.randrange(1, 1 << wl) for _ in range(n * lanes)]
                         if read else None)
            res = tb.apply_cmd(cmd, sdo_data=sdo_chunk, sdi_data=sdi_chunk)
            if write:
                sdo += res.sdo_words
            words = None
            if read:
                words = res.sdi_words
                expected += words
                masks += [(1 << wl) - 1] * len(words)
                beats += n
            steps.append((cmd, words, wl))
            work += n * (wl * tb.model.sclk_period
                         + tb.params["SDI_DELAY"] + 8) + 20
        else:
            if kind == "cs":
                cmd = ins.chipselect(0, delay=0)
            elif kind == "sync":
                cmd = ins.sync(op[1])
                syncs.append((op[1], beats))
            elif kind == "wl":
                cmd = ins.config_word_length(op[1])
            else:
                raise ValueError(f"unknown program op {op!r}")
            tb.apply_cmd(cmd)
            steps.append((cmd, None, wl))
            work += 30
    return steps, sdo, expected, masks, syncs, 3 * work + 300


async def _execute(tb, steps, budget):
    """Issue `steps` back to back; return True if the module did not drain."""
    dut = tb.dut
    latency = tb.params["SDI_DELAY"]
    live = {"slave": None, "starter": None}

    def stop_slave():
        if live["starter"] is not None:
            live["starter"].cancel()
            live["starter"] = None
        if live["slave"] is not None:
            live["slave"].stop()
            live["slave"] = None

    async def start_slave_when_active(words, wl):
        await tb.wait_read_transfer_active()
        slave = SPISlaveModel(
            dut, cpol=tb.model.cpol, cpha=tb.model.cpha,
            word_length=wl, num_sdio=tb.num_sdio,
            output_latency_clks=latency)
        slave.load(words)
        slave.start()
        live["slave"] = slave

    async def sender():
        for cmd, words, wl in steps:
            # Acceptance means the previous instruction has finished.
            await tb.send_cmd(cmd)
            stop_slave()
            if words is not None:
                live["starter"] = cocotb.start_soon(
                    start_slave_when_active(words, wl))

    task = cocotb.start_soon(sender())
    hang = True
    for _ in range(budget):
        await RisingEdge(dut.clk)
        if task.done():
            try:
                await tb.wait_idle(timeout_cycles=budget)
                hang = False
            except TimeoutError:
                pass
            break
    if hang:
        task.kill()
        dut.cmd_valid.value = 0
    stop_slave()
    # Let any late (spurious) SDI word or SYNC surface before checking.
    await ClockCycles(dut.clk, 40 + 4 * (latency + 3))
    return hang


async def run_program(tb, program, *, k, init_wl=None, label):
    """Reset, configure, run `program`, and score it (all mismatches kept)."""
    dut = tb.dut
    await apply_reset(dut, cycles_before=0, hold=3)
    tb.after_reset()
    tb.sync_mon.received.clear()

    await tb.issue(ins.config_clk_div(k))
    await tb.wait_idle()
    if init_wl is not None and init_wl != tb.params["DATA_WIDTH"]:
        await tb.issue(ins.config_word_length(init_wl))
        await tb.wait_idle()
    await tb.issue(ins.chipselect(0, delay=0))
    await tb.wait_idle()

    rng = tb.rc.derive(f"sdi_boundary_{label}")
    steps, sdo, expected, masks, syncs, budget = _plan(tb, program, rng)
    if sdo:
        tb.start_sdo_stream(sdo)
    hang = await _execute(tb, steps, budget)

    sb = tb.sb
    sb.compare(0, f"{label}.drains", 0, int(hang),
               note="module did not return to idle")
    if hang:
        return

    actual = [v & masks[i] if i < len(masks) else v
              for i, v in enumerate(tb.sdi_values)]
    sb.compare_sequences(expected, actual, field=f"{label}.sdi")

    sb.compare_sequences([s for s, _ in syncs], tb.sync_mon.values,
                         field=f"{label}.sync_id")
    received = tb.sdi_mon.received
    sync_rx = tb.sync_mon.received
    for j, (_, beats_before) in enumerate(syncs):
        if beats_before == 0 or j >= len(sync_rx):
            continue
        ok = (len(received) >= beats_before
              and received[beats_before - 1].timestamp
              <= sync_rx[j].valid_timestamp)
        sb.compare(j, f"{label}.sdi_before_sync", 1, int(ok))


def _full_wl(tb):
    return tb.params["DATA_WIDTH"]


@cocotb.test(skip=_ECHO_SCLK == 1)
async def test_sdi_no_spurious_word_after_write(dut):
    """A read that follows a write-only Transfer yields exactly its own words.

    Programs: write then read, write / chip-select / read, and write then a
    two-word read, at each of clk_div 0..2. The delayed capture strobe of the
    write is still in flight when the read starts whenever SDI_DELAY exceeds
    clk_div; the read's SDI stream must still be exactly its own words.
    """
    tb = ExecutionTB(dut)
    await tb.start()
    programs = {
        "w_r": [("write", 1), ("read", 1)],
        "w_cs_r": [("write", 1), ("cs",), ("read", 1)],
        "w_r2": [("write", 1), ("read", 2)],
    }
    for k in range(3):
        for name, program in programs.items():
            # REQ: EXEC-SDI-03 - exactly n+1 SDI words per read Transfer
            await run_program(tb, program, k=k, label=f"{name}_k{k}")
    tb.sb.assert_no_errors()


@cocotb.test(skip=_ECHO_SCLK == 1)
async def test_sdi_word_delivered_next_to_write_or_sync(dut):
    """The read word is intact, and precedes SYNC, next to a write or a SYNC.

    Single-word reads (word_length 1 and the full width) at clk_div 0, with a
    write before it, a write or a SYNC after it, or both. The word value is
    checked (nonzero, so an idle-line sample cannot pass) and, when a SYNC
    follows, the word must be accepted no later than the SYNC.
    """
    tb = ExecutionTB(dut)
    await tb.start()
    programs = {
        "w_r": [("write", 1), ("read", 1)],
        "w_r_w": [("write", 1), ("read", 1), ("write", 1)],
        "w_r_s": [("write", 1), ("read", 1), ("sync", 0x5A)],
        "r_w": [("read", 1), ("write", 1)],
        "r_s": [("read", 1), ("sync", 0x5A)],
    }
    for init_wl in (1, _full_wl(tb)):
        for name, program in programs.items():
            label = f"{name}_wl{init_wl}"
            # REQ: EXEC-SDI-01 - the read word is assembled intact
            # REQ: EXEC-SDI-09 - the read word is accepted before SYNC is presented
            await run_program(tb, program, k=0, init_wl=init_wl, label=label)
    tb.sb.assert_no_errors()


@cocotb.test(skip=_ECHO_SCLK == 1)
async def test_sdi_read_after_word_length_change(dut):
    """A read after a word_length change completes with its own words.

    Write at the full width, shorten word_length, then read one or two words
    (and a SYNC after them). The module must drain the command stream and
    deliver the short words.
    """
    tb = ExecutionTB(dut)
    await tb.start()
    programs = {
        "w_wl_r": [("write", 1), ("wl", _ALT_WL), ("read", 1)],
        "w_wl_r2": [("write", 1), ("wl", _ALT_WL), ("read", 2)],
        "w_wl_r_r": [("write", 1), ("wl", _ALT_WL), ("read", 1), ("read", 1)],
        "w_wl_r_s": [("write", 1), ("wl", _ALT_WL), ("read", 1),
                     ("sync", 0xA5)],
    }
    for name, program in programs.items():
        # REQ: EXEC-CC-02 - the program terminates and the module returns to idle
        # REQ: EXEC-SDI-03 - exactly n+1 SDI words per read Transfer
        await run_program(tb, program, k=0, label=name)
    tb.sb.assert_no_errors()


def _sequences(max_len=3):
    """All instruction sequences up to `max_len` that contain a read.

    Symbols: W write, R read, X read+write (one word each), C chip-select,
    S sync, L toggle word_length between the initial and the alternate width.
    """
    for length in range(2, max_len + 1):
        for seq in itertools.product("WRXCSL", repeat=length):
            if "R" in seq or "X" in seq:
                yield "".join(seq)


def _program(seq, init_wl, alt_wl):
    program = []
    wl_is_alt = False
    for i, sym in enumerate(seq):
        if sym == "W":
            program.append(("write", 1))
        elif sym == "R":
            program.append(("read", 1))
        elif sym == "X":
            program.append(("rw", 1))
        elif sym == "C":
            program.append(("cs",))
        elif sym == "S":
            program.append(("sync", 0x10 + i))
        elif sym == "L":
            wl_is_alt = not wl_is_alt
            program.append(("wl", alt_wl if wl_is_alt else init_wl))
    return program


async def _sweep(dut, *, k, init_wl_kind):
    tb = ExecutionTB(dut)
    await tb.start()
    full = _full_wl(tb)
    init_wl, alt_wl = (full, _ALT_WL) if init_wl_kind == "full" else (1, full)
    for seq in _sequences():
        program = _program(seq, init_wl, alt_wl)
        # REQ: EXEC-SDI-03 - exactly n+1 SDI words per read Transfer
        # REQ: EXEC-SDI-09 - every read word is accepted before SYNC is presented
        # REQ: EXEC-CC-02 - the program terminates and the module returns to idle
        await run_program(tb, program, k=k, init_wl=init_wl,
                           label=f"seq_{seq}_k{k}_wl{init_wl}")
    tb.sb.assert_no_errors()


@cocotb.test(skip=_ECHO_SCLK == 1)
async def test_sdi_sequences_div0_full_width(dut):
    """Every read-containing 2-3 instruction sequence, clk_div 0, full width."""
    await _sweep(dut, k=0, init_wl_kind="full")


@cocotb.test(skip=_ECHO_SCLK == 1)
async def test_sdi_sequences_div0_width1(dut):
    """Every read-containing 2-3 instruction sequence, clk_div 0, width 1."""
    await _sweep(dut, k=0, init_wl_kind="one")


@cocotb.test(skip=_ECHO_SCLK == 1)
async def test_sdi_sequences_div1_full_width(dut):
    """Every read-containing 2-3 instruction sequence, clk_div 1, full width."""
    await _sweep(dut, k=1, init_wl_kind="full")


@cocotb.test(skip=_ECHO_SCLK == 1)
async def test_sdi_sequences_div2_full_width(dut):
    """Every read-containing 2-3 instruction sequence, clk_div 2, full width."""
    await _sweep(dut, k=2, init_wl_kind="full")
