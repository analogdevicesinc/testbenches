"""Flow control / backpressure, and EXEC-CC-06.

Exercises independent random backpressure on each stream that has a ready the DUT
must honour (SDO, SDI, SYNC, CMD), and verifies stall-without-loss-or-reordering.
Includes the last-word continue-gate characterization (EXEC-FLOW-04) and two
regressions that assert correct behaviour against open RTL defects: the FLAG
EXEC-F1 handshake-stability violation (second home of EXEC-FLOW-05) and the FLAG
EXEC-F10 sticky-sdo_data_ready-after-reset gap (second home of EXEC-SDO-04).
"""

import cocotb
from cocotb.triggers import RisingEdge, ClockCycles

from framework.reset import apply_reset
from framework.spi import instructions as ins
from tb_env import ExecutionTB


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
    the div=0 sub-word corner is the FLAG EXEC-F1 case exercised separately below.
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


@cocotb.test()
async def test_sync_backpressure(dut):
    """Holding sync_ready low stalls the engine until released."""
    tb = ExecutionTB(dut)
    await tb.start()

    tb.bp_sync.stop(final_value=0)
    sync_id = 0x33
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
    n = 4
    data = [tb.rc.derive("lastword").randrange(1 << wl)
            for _ in range(n * tb.num_sdio)]
    # Supply exactly n words (no trailing extra); transfer must still finish.
    res = await tb.run_transfer(n=n, write=True, read=False, sdo_words=data)
    # REQ: EXEC-FLOW-04 - last word does not require fetching a further word
    assert int(dut.cmd_ready.value) == 1, "engine hung waiting past last word"
    tb.sb.compare_sequences(res.sdo_words, tb.bus_mon.sdo_words, field="lastword")
    tb.sb.assert_no_errors()


# FLAG EXEC-F1: at clk_div=0 with sub-word backpressure on sdi_data_ready, the RTL
# mutates sdi_data while sdi_data_valid=1 before the beat is accepted, violating
# AXI-Stream payload stability. Fails on current RTL (see bug_log.md).
@cocotb.test()
async def test_sdi_handshake_stability(dut):
    """SDI payload must stay stable while valid & unaccepted (fails on current RTL).

    AXI-Stream requires TDATA hold once VALID is asserted until VALID && READY.
    Accepting one beat every `wl` core clocks at clk_div=0 drains slower than the
    engine produces, so the next word shifts in before the previous is accepted.
    """
    tb = ExecutionTB(dut)
    await tb.start()
    wl = tb.params["DATA_WIDTH"]
    n = 6
    resp = [(0x11 * (k + 1)) & ((1 << wl) - 1) for k in range(n)]

    tb.bp_sdi.stop(final_value=0)
    await tb.issue(ins.chipselect(0, delay=1))
    await tb.wait_idle()
    await tb.issue(ins.transfer(n - 1, write=False, read=True), sdi_data=resp)
    tb.slave.start()

    ready_pattern = [1] + [0] * (wl - 1)
    held = None
    prev_accept = True
    violation = False
    for i in range(n * wl * 4 + 80):
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
    # REQ: EXEC-FLOW-05 - sdi_data must stay stable under unaccepted valid
    assert not violation, "sdi_data changed under unaccepted valid (handshake)"


# FLAG EXEC-F10: exec_transfer_cmd_reg has no reset branch, so after a transfer it
# stays 1 across a resetn pulse and the prefetch gate asserts sdo_data_ready in
# FIFO mode with no command in flight. Fails on current RTL (see bug_log.md).
@cocotb.test()
async def test_sdo_ready_cleared_by_reset(dut):
    """sdo_data_ready must not assert after reset with no command (fails on current RTL)."""
    tb = ExecutionTB(dut)
    await tb.start()
    wl = tb.params["DATA_WIDTH"]
    rng = tb.rc.derive("sticky_ready")

    # Run a write transfer so exec_transfer_cmd_reg gets set to 1.
    n = 3
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
