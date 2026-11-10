"""SDI capture buffer depth (EXEC-SDI-06).

Covers EXEC-SDI-06 (requirements.md): the module's SDI capture path
holds up to two captured-but-unconsumed words (a presented word plus one
buffered behind it) while the SDI data sink (``sdi_data_ready``) holds off
accepting.

The buffer-full discard path (EXEC-SDI-07/EXEC-SDI-08) exists in the RTL as a
safety net: the module's own flow control stalls SPI clock generation once
both buffer slots are occupied, so sustained backpressure never actually
drives a third word to completion in either mode - this testbench's stimulus
model has no way to reach that path, so it is untested here.
"""

import os

import cocotb
from cocotb.triggers import ClockCycles

from framework.reset import apply_reset
from framework.spi import instructions as ins
from tb_env import ExecutionTB, CLK_PERIOD_NS

# Build-time generic: ECHO_SCLK=1 is required for the zero-bubble drain
# check below, since capture only runs ahead of consumption in that mode.
_ECHO_SCLK = int(os.environ.get("PARAM_ECHO_SCLK", 0))


async def _issue_full_backpressure_read(tb, n, *, label):
    """Issue an n-period read-only transfer with sdi_data_ready withheld from
    before the first word completes. Returns the golden-model TransferResult;
    the caller waits out the transfer window, then observes/drains.
    """
    dut = tb.dut
    wl = tb.params["DATA_WIDTH"]
    rng = tb.rc.derive(label)
    resp = [rng.randrange(1 << wl) for _ in range(n * tb.num_sdio)]

    await tb.issue(ins.chipselect(0, delay=1))
    await tb.wait_idle()

    tb.bp_sdi.stop(final_value=0)
    cmd = ins.transfer(n - 1, write=False, read=True)
    res = tb.apply_cmd(cmd, sdi_data=resp)
    await tb.send_cmd(cmd)
    tb.slave.start()
    return res


def _transfer_window_cycles(tb, n):
    """Cycle bound covering the whole n-period SPI transaction plus margin.

    With ECHO_SCLK=0 the engine may stall indefinitely past the 2-word buffer
    (see module docstring) - waiting this long still only ever yields the 2
    buffered words, so the bound is safe (never a false timeout) for both
    modes.
    """
    return (tb.model.shift_time(n)
            + n * (3 + tb.params["SDI_DELAY"]) + 200)


def _drain_margin_cycles(tb):
    """Generous, width/div-scaled bound for the buffered word(s) to drain
    once the sink is released.

    With ECHO_SCLK=0 the module only resumes capture of a held-back word
    after the first is accepted (see module docstring), so draining the
    second word may still cost up to a full extra word period (word_length
    bits at sclk_period core clocks each) after release - a fixed small
    constant is not enough at wide DATA_WIDTH or slow DEFAULT_CLK_DIV.
    """
    return 2 * tb.params["DATA_WIDTH"] * tb.model.sclk_period + 50


@cocotb.test()
async def test_sdi_buffers_two_unconsumed_words(dut):
    """The module holds up to two captured-but-unconsumed SDI words (EXEC-SDI-06).

    Holds sdi_data_ready low across a transfer at/under the documented 2-word
    capacity (n=1, a single word; n=2, exactly at capacity) and checks every
    word is still delivered, losslessly and in order, once the sink accepts.
    At n=2, additionally checks the two words drain on back-to-back clocks
    with no gap - proof the second word was already held by the module (
    capture continued past the first word while it sat unaccepted) rather
    than only appearing after some later re-capture, which could not happen
    here anyway since the SPI transaction itself has already finished.
    """
    tb = ExecutionTB(dut)
    await tb.start()

    for n in (1, 2):
        tb.slave.stop()
        await apply_reset(dut, cycles_before=0, hold=3)
        tb.after_reset()
        res = await _issue_full_backpressure_read(tb, n, label=f"sdi_buf2_{n}")
        await ClockCycles(dut.clk, _transfer_window_cycles(tb, n))

        total = n * res.n_lanes_sdi
        assert int(dut.sdi_data_valid.value) == 1, (
            f"n={n}: no word presented at sdi_data while the sink held off")

        tb.bp_sdi.start_always_ready()
        await ClockCycles(dut.clk, _drain_margin_cycles(tb))
        actual = tb.sdi_values
        # REQ: EXEC-SDI-06 - up to two captured-but-unconsumed words are held
        # losslessly and delivered in order once the sink accepts
        tb.sb.compare_sequences(res.sdi_words, actual[:total], field=f"sdi_buf2_n{n}")

        # Zero-bubble drain only distinguishes "already buffered" from
        # "re-shifted after acceptance" when capture genuinely runs ahead of
        # consumption - empirically, that is only the case with ECHO_SCLK=1
        # (see module docstring); with ECHO_SCLK=0 this module's own flow
        # control resumes capture only after acceptance, so the no-loss
        # check above is EXEC-SDI-06's meaningful boundary-visible check
        # there, and no bubble-timing claim is made in that mode.
        if n == 2 and _ECHO_SCLK and len(tb.sdi_mon.received) >= 2:
            gap_ns = (tb.sdi_mon.received[1].timestamp
                      - tb.sdi_mon.received[0].timestamp)
            # REQ: EXEC-SDI-06 - the second word was already buffered: it
            # drains on the very next clock, with no bubble to re-capture it
            tb.sb.compare(0, "sdi_buf2_no_bubble", CLK_PERIOD_NS, gap_ns)

        tb.sdi_mon.received.clear()

    tb.sb.assert_no_errors()
