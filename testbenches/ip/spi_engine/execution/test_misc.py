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
    """Sync asserts sync_valid carrying cmd[7:0] and retires on sync_ready."""
    tb = ExecutionTB(dut)
    await tb.start()

    sync_id = 0x5A
    res = await tb.issue(ins.sync(sync_id))
    for _ in range(50):
        await RisingEdge(dut.clk)
        if int(dut.sync_valid.value) == 1:
            break
    # REQ: EXEC-SYNC-01 - sync drives sync=id, asserts sync_valid, retires on ready
    tb.sb.compare(0, "sync.id", res.sync_id, int(dut.sync.value))
    tb.sb.compare(0, "sync.valid", 1, int(dut.sync_valid.value))
    await tb.wait_idle()
    tb.sb.assert_no_errors()


@cocotb.test()
async def test_sleep_duration(dut):
    """Sleep idles for the formula-predicted duration (±tolerance)."""
    tb = ExecutionTB(dut)
    await tb.start()

    div = 1
    await tb.issue(ins.config_clk_div(div))
    await tb.wait_idle()

    t = 4
    predicted = tb.model.sleep_duration(t)
    start = tb.now_cycles()
    await tb.issue(ins.sleep(t))
    await tb.wait_idle()
    elapsed = tb.now_cycles() - start
    tb.log.info(f"sleep t={t} div={div} predicted~{predicted} elapsed={elapsed}")
    # REQ: EXEC-SLEEP-01 - sleep stalls for 2 + (t+1)*(div+1)*2 core clocks
    tb.sb.compare_within(0, "sleep_duration", predicted, elapsed, 4)
    tb.sb.assert_no_errors()


@cocotb.test()
async def test_sleep_t_zero(dut):
    """Sleep with t=0 still produces the minimum non-zero delay."""
    tb = ExecutionTB(dut)
    await tb.start()
    div = 1
    await tb.issue(ins.config_clk_div(div))
    await tb.wait_idle()

    predicted = tb.model.sleep_duration(0)
    start = tb.now_cycles()
    await tb.issue(ins.sleep(0))
    await tb.wait_idle()
    elapsed = tb.now_cycles() - start
    # REQ: EXEC-SLEEP-02 - t=0 still yields the minimum non-zero sleep delay
    assert elapsed > 0, "sleep t=0 produced zero delay"
    tb.sb.compare_within(0, "sleep_t0", predicted, elapsed, 4)
    tb.sb.assert_no_errors()
