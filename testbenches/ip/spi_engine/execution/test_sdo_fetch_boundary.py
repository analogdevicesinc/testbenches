"""SDO fetch boundary: a transfer consumes exactly its own n+1 words.

Requirement: EXEC-SDO-04 (exactly n+1 words are consumed from the SDO stream).

INTENTIONALLY NOT REGISTERED in runner.py TEST_MODULES. On current RTL this
fails for a defect separate from the wl=1/clk_div=0 one: the engine pops the
next transfer's first SDO word early. Add "test_sdo_fetch_boundary" to
TEST_MODULES when that fix lands.

Run standalone: the runner takes the module list from TEST_MODULES and
`--testcase` only filters by function name within it, so an unregistered
module cannot be selected. Temporarily add the module to TEST_MODULES (or
set it as the only entry) and run, e.g.
  python3 runner.py --testcase test_sdo_no_extra_word_consumed

Method. Words for transfer A and the next transfer B are both supplied on one
continuous SDO stream before A starts, so B's first word is valid while A
runs. The handshake counter is never cleared between phases (only at point
start): after A it must equal A's words, after B the cumulative total, and B's
wire bits must be B's own words.
"""

import cocotb
from cocotb.triggers import ClockCycles, with_timeout, SimTimeoutError

from framework.spi import instructions as ins
from tb_env import CLK_PERIOD_NS
from test_sdo_word_coverage import (Harness, DIV_POINTS, wl_points,
                                    make_words, words_from_samples)


async def _run_point(h, tag, *, div, wl, n_a, n_b):
    tb, sb, dut = h.tb, h.tb.sb, h.dut
    cpol, cpha, lanes = await h.prepare(div=div, wl=wl)
    la = len(lanes)
    words_a = make_words(tb, tag + "_a", n_a * la, wl)
    words_b = make_words(tb, tag + "_b", n_b * la, wl)
    note = (f"{tag} wl={wl} div={div} lanes={lanes} n+1_a={n_a} n+1_b={n_b}")

    async def drive():
        h.hs.received.clear()               # once per point, not per phase
        # B's words are queued behind A's on purpose (continuous stream)
        tb.start_sdo_stream(words_a + words_b)
        for k, (n, exp) in enumerate(((n_a, words_a), (n_b, words_b))):
            h.sampler.arm(cpol, cpha)
            cmd = ins.transfer(n - 1, write=True, read=False)
            tb.apply_cmd(cmd)
            await tb.send_cmd(cmd)
            await tb.wait_idle(timeout_cycles=10 ** 9)
            await ClockCycles(dut.clk, 6)
            h.sampler.disarm()
            nt = f"{note} phase={k}"
            obs = words_from_samples(h.sampler.samples, wl, lanes)
            sb.compare(0, f"{tag}.sclk_sample_edges", n * wl,
                       len(h.sampler.samples), note=nt)
            sb.compare_sequences(exp, obs, field=nt)
            # REQ: EXEC-SDO-04 - cumulative handshakes == words supplied so far
            # by the transfers that have run; nothing of the next one taken
            done = len(words_a) + (len(words_b) if k else 0)
            sb.compare(0, f"{tag}.cum_handshakes", done,
                       len(h.hs.received), note=nt)

    bound = (n_a + n_b) * (wl * 2 * (div + 1) + 8 * la + 10) + 4000
    task = cocotb.start_soon(drive())
    hung = False
    try:
        await with_timeout(task, bound * CLK_PERIOD_NS, "ns")
    except SimTimeoutError:
        hung = True
        task.cancel()
    h.sampler.disarm()
    tb.abort_streams()
    if hung:
        sb.compare(0, f"{tag}.completes", "idle", "hang", note=note)
        await h.recover()


@cocotb.test()
async def test_sdo_no_extra_word_consumed(dut):
    """Next transfer's words are queued; transfer A takes only its own."""
    h = Harness(dut)
    await h.start()
    for div in DIV_POINTS:
        for wl in wl_points(h.dw):
            for n_a in (1, 3):
                await _run_point(h, f"fetch_d{div}_w{wl}_n{n_a}", div=div,
                                 wl=wl, n_a=n_a, n_b=2)
    h.tb.sb.assert_no_errors()
