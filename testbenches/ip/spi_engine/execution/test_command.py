"""Command stream (CMD) acceptance & sequencing.

Checks the AXI-stream handshake on the CMD interface: a command transfers only on
cmd_valid && cmd_ready, cmd_ready is idle-gated (deasserted while an instruction
executes), and commands execute strictly in order. All assertions are on the
boundary CMD handshake and the resulting bus data ordering.
"""

import cocotb
from cocotb.triggers import RisingEdge, ClockCycles

from framework.spi import instructions as ins
from tb_env import ExecutionTB


@cocotb.test()
async def test_cmd_ready_idle_gated(dut):
    """cmd_ready is high when idle and low while an instruction executes."""
    tb = ExecutionTB(dut)
    await tb.start()

    # REQ: EXEC-CMD-01 - cmd_ready asserted only when idle
    assert int(dut.cmd_ready.value) == 1, "cmd_ready not high when idle"

    # Issue a slow transfer and confirm cmd_ready drops during execution.
    await tb.issue(ins.config_clk_div(3))
    await tb.wait_idle()
    await tb.issue(ins.chipselect(0, delay=1))
    await tb.wait_idle()

    wl = tb.params["DATA_WIDTH"]
    data = [tb.rc.derive("cmd_gate").randrange(1 << wl)
            for _ in range(2 * tb.num_sdio)]
    res = await tb.issue(ins.transfer(1, write=True, read=False), sdo_data=data)
    tb.start_sdo_stream(res.sdo_words)
    for _ in range(40):
        await RisingEdge(dut.clk)
        if int(dut.transfer_active.value) == 1:
            break
    # REQ: EXEC-CMD-02 - cmd_ready deasserted while executing (upstream stalls)
    assert int(dut.cmd_ready.value) == 0, "cmd_ready high mid-instruction"
    await tb.wait_idle()
    assert int(dut.cmd_ready.value) == 1, "cmd_ready not restored after exec"
    tb.sb.assert_no_errors()


@cocotb.test()
async def test_cmd_handshake_single_beat(dut):
    """A command transfers on exactly the cmd_valid && cmd_ready cycle."""
    tb = ExecutionTB(dut)
    await tb.start()

    # Hold cmd back manually: drive valid, wait for the accept cycle.
    cmd = ins.sync(0x21)
    tb.model.apply(cmd)
    dut.cmd.value = cmd
    dut.cmd_valid.value = 1
    accepted = 0
    for _ in range(20):
        await RisingEdge(dut.clk)
        if int(dut.cmd_valid.value) == 1 and int(dut.cmd_ready.value) == 1:
            accepted += 1
        # deassert the cycle after the first accept
        if accepted == 1:
            dut.cmd_valid.value = 0
    # REQ: EXEC-CMD-03 - opcode taken from cmd[14:12] (sync opcode accepted here)
    assert accepted == 1, f"command accepted {accepted} times, expected 1"
    await tb.wait_idle()
    tb.sb.assert_no_errors()


@cocotb.test()
async def test_cmd_in_order_execution(dut):
    """Commands execute strictly in the order accepted."""
    tb = ExecutionTB(dut)
    await tb.start()
    wl = tb.params["DATA_WIDTH"]
    rng = tb.rc.derive("cmd_order")

    await tb.issue(ins.chipselect(0, delay=1))
    await tb.wait_idle()

    # A run of distinct single-word transfers; the captured bus order must match
    # the issue order exactly (no reordering, no loss).
    expected = []
    tb.bus_mon.words.clear()
    for _ in range(5):
        d = [rng.randrange(1 << wl) for _ in range(tb.num_sdio)]
        res = await tb.issue(ins.transfer(0, write=True, read=False),
                             sdo_data=d)
        expected += res.sdo_words
        await tb.stream_sdo(res.sdo_words)
        await tb.wait_idle()
        await ClockCycles(dut.clk, 2)
    # REQ: EXEC-CMD-04 - commands complete in order, one before the next
    tb.sb.compare_sequences(expected, tb.bus_mon.sdo_words, field="order")
    tb.sb.assert_no_errors()
