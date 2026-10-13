"""Cross-cutting corner cases: interleaved sequences & parameter space.

Recombines validated features into ordered sequences: a full interleaved
transaction (EXEC-CC-05), a randomised valid-instruction fuzz stream, and a
data-width / lane / CS parameter-space smoke (EXEC-CC-09; the full multi-compile
sweep lives in runner.py).
"""

import cocotb
from cocotb.triggers import RisingEdge, ClockCycles

from framework.spi import instructions as ins
from tb_env import ExecutionTB


@cocotb.test()
async def test_interleaved_transaction(dut):
    """CS-assert -> config -> transfer -> sleep -> sync -> CS-deselect in order."""
    tb = ExecutionTB(dut)
    await tb.start()
    wl = tb.params["DATA_WIDTH"]
    rng = tb.rc.derive("interleave")

    await tb.issue(ins.chipselect(0, delay=1))
    await tb.wait_idle()
    await tb.issue(ins.config_clk_div(1))
    await tb.wait_idle()

    nper = 3
    data = [rng.randrange(1 << wl) for _ in range(nper * tb.num_sdio)]
    res = await tb.issue(ins.transfer(nper - 1, write=True, read=False),
                         sdo_data=data)
    cocotb.start_soon(tb.stream_sdo(res.sdo_words))
    await tb.wait_idle()
    await ClockCycles(dut.clk, 3)
    tb.sb.compare_sequences(res.sdo_words, tb.bus_mon.sdo_words, field="seq_sdo")

    await tb.issue(ins.sleep(3))
    await tb.wait_idle()

    sid = 0x7
    await tb.issue(ins.sync(sid))
    await tb.wait_idle()
    tb.sb.compare(0, "seq.sync", sid, int(dut.sync.value))

    allcs = (1 << tb.params["NUM_OF_CS"]) - 1
    await tb.issue(ins.chipselect(allcs, delay=1))
    await tb.wait_idle()
    await ClockCycles(dut.clk, 2)
    # REQ: EXEC-CC-05 - interleaved sequence executes in order with correct idle
    tb.sb.compare(0, "seq.deassert", allcs, int(dut.cs.value))
    tb.sb.assert_no_errors()


@cocotb.test()
async def test_random_instruction_stream(dut):
    """Fuzz: a random but valid instruction sequence; data transfers checked."""
    tb = ExecutionTB(dut)
    await tb.start()
    wl = tb.params["DATA_WIDTH"]
    rng = tb.rc.derive("fuzz")

    await tb.issue(ins.chipselect(0, delay=1))
    await tb.wait_idle()

    for _ in range(25):
        choice = rng.random()
        if choice < 0.5:
            nper = rng.randint(1, 3)
            data = [rng.randrange(1 << wl) for _ in range(nper * tb.num_sdio)]
            tb.bus_mon.words.clear()
            res = await tb.issue(ins.transfer(nper - 1, write=True,
                                              read=False), sdo_data=data)
            cocotb.start_soon(tb.stream_sdo(res.sdo_words))
            await tb.wait_idle()
            await ClockCycles(dut.clk, 2)
            # REQ: EXEC-CC-09 - representative instruction/data mix exercised
            tb.sb.compare_sequences(res.sdo_words, tb.bus_mon.sdo_words,
                                    field="fuzz_sdo")
        elif choice < 0.7:
            await tb.issue(ins.config_clk_div(rng.randint(0, 3)))
            await tb.wait_idle()
        elif choice < 0.85:
            await tb.issue(ins.sleep(rng.randint(0, 4)))
            await tb.wait_idle()
        else:
            sid = rng.randint(0, 255)
            await tb.issue(ins.sync(sid))
            await tb.wait_idle()
            tb.sb.compare(0, "fuzz_sync", sid, int(dut.sync.value))
    tb.sb.assert_no_errors()


@cocotb.test()
async def test_back_to_back_transfers(dut):
    """Back-to-back transfers of varying length all produce correct data."""
    tb = ExecutionTB(dut)
    await tb.start()
    wl = tb.params["DATA_WIDTH"]
    rng = tb.rc.derive("b2b")

    await tb.issue(ins.chipselect(0, delay=1))
    await tb.wait_idle()

    expected = []
    tb.bus_mon.words.clear()
    for _ in range(5):
        nper = rng.randint(1, 4)
        data = [rng.randrange(1 << wl) for _ in range(nper * tb.num_sdio)]
        res = await tb.issue(ins.transfer(nper - 1, write=True, read=False),
                             sdo_data=data)
        expected += res.sdo_words
        cocotb.start_soon(tb.stream_sdo(res.sdo_words))
        await tb.wait_idle()
        await ClockCycles(dut.clk, 3)
    # REQ: EXEC-CC-06 - back-to-back transfers keep order+data (no-backpressure baseline)
    tb.sb.compare_sequences(expected, tb.bus_mon.sdo_words, field="b2b")
    tb.sb.assert_no_errors()
