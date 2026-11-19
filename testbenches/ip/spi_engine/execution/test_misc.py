"""MISC instructions: Sync (opcode 011, cmd[8]=0) and Sleep (cmd[8]=1).

Sync raises sync_valid carrying the event id and holds until sync_ready; Sleep
stalls the command stream for the closed-form duration with no bus/ctrl activity.
Sleep timing is checked with a ±tolerance; the sync id is checked exactly.
"""

import cocotb
from cocotb.triggers import RisingEdge, ClockCycles

from framework.spi import instructions as ins
from tb_env import ExecutionTB


@cocotb.test()
async def test_sync_id_and_valid(dut):
    """Sync asserts sync_valid carrying cmd[7:0] and retires on sync_ready.

    cmd[7:0] is an 8-bit enumerable domain; swept at its boundaries (0x00,
    0xFF - true extremes of the field, kept as literals rather than
    randomized) plus a random mid value per seed.
    """
    tb = ExecutionTB(dut)
    await tb.start()
    mid = tb.rc.derive("sync_id_mid").randint(0x01, 0xFE)

    for sync_id in (0x00, mid, 0xFF):
        res = await tb.issue(ins.sync(sync_id))
        for _ in range(50):
            await RisingEdge(dut.clk)
            if int(dut.sync_valid.value) == 1:
                break
        note = f"sync_id=0x{sync_id:02X}"
        # REQ: EXEC-SYNC-01 - sync drives sync=id, asserts sync_valid, retires on ready
        tb.sb.compare(sync_id, "sync.id", res.sync_id, int(dut.sync.value), note=note)
        tb.sb.compare(sync_id, "sync.valid", 1, int(dut.sync_valid.value), note=note)
        await tb.wait_idle()
    tb.sb.assert_no_errors()


@cocotb.test()
async def test_sleep_duration(dut):
    """Sleep idles for the formula-predicted duration (±tolerance), across (t, div).

    Formula (instruction-format.rst reading, per EXEC-SLEEP-01's spec note):
    sleep_time = 2 + (t+1) * (div+1) * 2 core clocks, t = cmd[7:0]. Swept over
    several random (t, div) pairs per seed - t=0 is its own minimum-delay
    case, covered separately by test_sleep_t_zero/EXEC-SLEEP-02, so t is drawn
    from [1, 255]; div is capped at 15 to keep sim time bounded (div boundary
    values 0/1/3 are already directed-tested by test_waveform.py's SCLK-period
    sweep, so this sweep's job is broad (t, div) coverage, not re-anchoring
    the boundaries).
    """
    tb = ExecutionTB(dut)
    await tb.start()
    rng = tb.rc.derive("sleep_duration")

    for _ in range(4):
        t, div = rng.randint(1, 255), rng.randint(0, 15)
        await tb.issue(ins.config_clk_div(div))
        await tb.wait_idle()

        predicted = tb.model.sleep_duration(t)
        start = tb.now_cycles()
        await tb.issue(ins.sleep(t))
        await tb.wait_idle()
        elapsed = tb.now_cycles() - start
        tb.log.info(f"sleep t={t} div={div} predicted~{predicted} elapsed={elapsed}")
        # REQ: EXEC-SLEEP-01 - sleep stalls for 2 + (t+1)*(div+1)*2 core clocks
        tb.sb.compare_within(t, "sleep_duration", predicted, elapsed, 1,
                             note=f"t={t} div={div}")
    tb.sb.assert_no_errors()


@cocotb.test()
async def test_sleep_t_zero(dut):
    """Sleep with t=0 still produces the minimum non-zero delay."""
    tb = ExecutionTB(dut)
    await tb.start()
    # div's value is incidental to this check (any legal divider must still
    # yield a nonzero minimum delay at t=0), so it is randomized rather than
    # pinned to a specific one.
    div = tb.rc.derive("sleep_t0_div").randint(0, 15)
    await tb.issue(ins.config_clk_div(div))
    await tb.wait_idle()

    predicted = tb.model.sleep_duration(0)
    start = tb.now_cycles()
    await tb.issue(ins.sleep(0))
    await tb.wait_idle()
    elapsed = tb.now_cycles() - start
    # REQ: EXEC-SLEEP-02 - t=0 still yields the minimum non-zero sleep delay
    assert elapsed > 0, "sleep t=0 produced zero delay"
    tb.sb.compare_within(0, "sleep_t0", predicted, elapsed, 1)
    tb.sb.assert_no_errors()
