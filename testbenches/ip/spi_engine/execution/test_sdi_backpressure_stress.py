"""Multi-word reads under SDI sink backpressure, back to back with SYNC.

Short instruction programs (read, read-read, write/read/write/sync,
read/sync/read, read+write then read) run through the program runner of
`test_sdi_delay_boundary` at every clk_div 0..4 and word_length 1/2/4/8
(capped at DATA_WIDTH), while the SDI sink applies one backpressure pattern
per test case (SYNC sink stays ready). Each (clk_div, word_length) pair runs
every program once, with the read length n rotating through 1/2/4/8, so every
n meets every program and every pair. SDI_STRESS_EXHAUSTIVE=1 runs every n for
every program instead (4x longer).

Oracle (independent of the RTL): the golden model's expected SDI stream per
program. Checks per program: the command stream drains, SDI word count and
values equal the expected stream, SYNC ids match, and every read word issued
before a SYNC is accepted by the SDI sink no later than the cycle that SYNC is
presented (`sync_valid`). Across the whole test, `sdi_data_overflow` never
pulses.
"""

import os

import cocotb
from cocotb.triggers import RisingEdge

from tb_env import ExecutionTB
from test_sdi_delay_boundary import run_program

_ECHO_SCLK = int(os.environ.get("PARAM_ECHO_SCLK", 0))
_EXHAUSTIVE = int(os.environ.get("SDI_STRESS_EXHAUSTIVE", 0))

_CLK_DIVS = range(5)
_WORD_LENGTHS = (1, 2, 4, 8)
_WORD_COUNTS = (1, 2, 4, 8)
_PROGRAMS = ("R", "RR", "WRWS", "RS", "XR")


def _program(name, n):
    return {
        "R": [("read", n)],
        "RR": [("read", n), ("read", n)],
        "WRWS": [("write", 1), ("read", n), ("write", 1), ("sync", 0x31)],
        "RS": [("read", n), ("sync", 0x32), ("read", 1)],
        "XR": [("rw", n), ("read", n)],
    }[name]


def _cases(data_width):
    """(clk_div, word_length, n, program name) tuples to run."""
    wls = sorted({min(wl, data_width) for wl in _WORD_LENGTHS})
    for i, k in enumerate(_CLK_DIVS):
        for j, wl in enumerate(wls):
            for p, name in enumerate(_PROGRAMS):
                if _EXHAUSTIVE:
                    ns = _WORD_COUNTS
                else:
                    ns = (_WORD_COUNTS[(i + j + p) % len(_WORD_COUNTS)],)
                for n in ns:
                    yield k, wl, n, name


def _apply_sink(tb, pattern):
    if pattern == "always":
        tb.bp_sdi.start_always_ready()
    elif pattern == "burst":
        tb.bp_sdi.start_burst(min_on=1, max_on=3, min_off=1, max_off=3)
    elif pattern == "uniform":
        tb.bp_sdi.start_uniform(duty_cycle=0.5)
    elif pattern == "slow":
        tb.bp_sdi.start_burst(min_on=1, max_on=1, min_off=4, max_off=9)
    else:
        raise ValueError(f"unknown sink pattern {pattern!r}")


async def _count_overflow(dut, hits):
    while True:
        await RisingEdge(dut.clk)
        if dut.sdi_data_overflow.value == 1:
            hits[0] += 1


async def _stress(dut, pattern):
    tb = ExecutionTB(dut)
    await tb.start()
    D = tb.params["SDI_DELAY"]
    hits = [0]
    watcher = cocotb.start_soon(_count_overflow(dut, hits))
    for k, wl, n, name in _cases(tb.params["DATA_WIDTH"]):
        _apply_sink(tb, pattern)
        label = f"st_D{D}_k{k}_wl{wl}_{pattern}_n{n}_{name}"
        # REQ: EXEC-FLOW-03 - word values and order survive SDI backpressure
        # REQ: EXEC-SDI-03 - exactly n+1 SDI words per read Transfer
        # REQ: EXEC-SDI-09 - every read word is accepted before SYNC is presented
        # REQ: EXEC-CC-02 - the program terminates and the module returns to idle
        await run_program(tb, _program(name, n), k=k, init_wl=wl, label=label)
        tb.bp_sdi.start_always_ready()
    watcher.kill()
    # REQ: EXEC-FLOW-02 - a stalled read loses no captured word (no discard)
    tb.sb.compare(0, f"{pattern}.overflow_pulses", 0, hits[0])
    tb.sb.assert_no_errors()


@cocotb.test(skip=_ECHO_SCLK == 1)
async def test_sdi_stress_sink_always_ready(dut):
    """Reference pattern: SDI sink always ready."""
    await _stress(dut, "always")


@cocotb.test(skip=_ECHO_SCLK == 1)
async def test_sdi_stress_sink_burst(dut):
    """SDI sink ready/not-ready in bursts of 1..3 cycles each."""
    await _stress(dut, "burst")


@cocotb.test(skip=_ECHO_SCLK == 1)
async def test_sdi_stress_sink_uniform(dut):
    """SDI sink ready on each cycle with probability 0.5."""
    await _stress(dut, "uniform")


@cocotb.test(skip=_ECHO_SCLK == 1)
async def test_sdi_stress_sink_slow(dut):
    """SDI sink ready 1 cycle in every 5..10."""
    await _stress(dut, "slow")
