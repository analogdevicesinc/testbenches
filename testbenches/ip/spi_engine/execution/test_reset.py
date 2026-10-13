"""Reset behaviour (boundary-observable), plus EXEC-CC-07.

Verifies the documented idle/reset values on every boundary output after reset
(including resets injected mid-instruction), and that receive state is cleared so
the first read after reset returns only freshly-sampled bits.

Only boundary outputs are asserted (ctrl streams + spi bus); internal state is
out of scope.
"""

import cocotb
from cocotb.triggers import RisingEdge, ClockCycles

from framework.spi import instructions as ins
from framework.reset import apply_reset, check_reset_values

from tb_env import ExecutionTB


@cocotb.test()
async def test_reset_values_after_release(dut):
    """All documented reset values hold after resetn is released."""
    tb = ExecutionTB(dut)
    await tb.start()

    # cmd_ready high (ready to accept), cs=all-ones, sclk=cpol, sdo_t=1.
    errs = tb.check_reset_values()          # REQ: EXEC-RST-02 - cmd_ready asserted
    errs += tb.check_reset_values_extra()   # REQ: EXEC-RST-06 - three_wire + sdi_data_valid low
    assert not errs, f"reset value mismatches: {errs}"

    cpol = (tb.params["DEFAULT_SPI_CFG"] >> 1) & 1
    all_cs = (1 << tb.params["NUM_OF_CS"]) - 1
    # REQ: EXEC-RST-03 - cs reads all-ones (every CS inactive) after reset
    tb.sb.compare(0, "reset.cs_all_ones", all_cs, int(dut.cs.value))
    # REQ: EXEC-RST-04 - sclk idles at CPOL from DEFAULT_SPI_CFG[1]
    tb.sb.compare(0, "reset.sclk_cpol", cpol, int(dut.sclk.value))
    idle = tb.params.get("SDO_DEFAULT", 0)
    # REQ: EXEC-RST-05 - every sdo lane idles at sdo_idle_state, sdo_t tristated
    tb.sb.compare(0, "reset.sdo_idle",
                  idle * ((1 << tb.num_sdio) - 1), int(dut.sdo.value))
    # REQ: EXEC-BUS-04 - cs reset value is all-inactive
    tb.sb.compare(0, "reset.bus_cs", all_cs, int(dut.cs.value))
    # REQ: EXEC-PARAM-04 - DEFAULT_SPI_CFG observed at reset (three_wire, cpol)
    tb.sb.compare(0, "reset.cfg_three_wire",
                  (tb.params["DEFAULT_SPI_CFG"] >> 2) & 1,
                  int(dut.three_wire.value))
    tb.sb.assert_no_errors()


@cocotb.test()
async def test_reset_module_idle(dut):
    """After reset the module is idle and accepts no in-flight command."""
    tb = ExecutionTB(dut)
    await tb.start()
    # REQ: EXEC-RST-01 - module idle and at defined idle values after reset
    assert int(dut.cmd_ready.value) == 1, "engine not idle after reset"
    assert int(dut.sync_valid.value) == 0, "sync_valid high after reset"
    tb.sb.assert_no_errors()


@cocotb.test()
async def test_reset_during_transfer(dut):
    """Reset mid-transfer returns all outputs to their reset values and recovers."""
    tb = ExecutionTB(dut)
    await tb.start()
    wl = tb.params["DATA_WIDTH"]
    rng = tb.rc.derive("rst_xfer")

    await tb.issue(ins.config_clk_div(3))  # slow it so we land mid-transfer
    await tb.wait_idle()
    await tb.issue(ins.chipselect(0, delay=1))
    await tb.wait_idle()

    nper = 4
    data = [rng.randrange(1 << wl) for _ in range(nper * tb.num_sdio)]
    res = await tb.issue(ins.transfer(nper - 1, write=True, read=False),
                         sdo_data=data)
    tb.start_sdo_stream(res.sdo_words)
    for _ in range(30):
        await RisingEdge(dut.clk)
        if int(dut.transfer_active.value) == 1:
            break
    await ClockCycles(dut.clk, 5)
    await apply_reset(dut, cycles_before=0, hold=3)
    tb.after_reset()

    # REQ: EXEC-CC-07 - reset asserted mid-transfer restores reset values
    errs = check_reset_values(dut, tb.params, scoreboard=tb.sb)
    assert not errs, f"post-reset values wrong: {errs}"

    # A fresh transfer must work after recovery. The SDO data-assembler's lane
    # table auto-rebuilds after reset (reset clears lane_scan_idx and the scan
    # reruns over the reset-default all-lanes sdo_lane_mask), so no post-reset
    # lane-mask reprogram is needed for multi-lane distribution to be correct.
    await tb.issue(ins.chipselect(0, delay=1))
    await tb.wait_idle()
    nper2 = 2
    d2 = [rng.randrange(1 << wl) for _ in range(nper2 * tb.num_sdio)]
    res = await tb.issue(ins.transfer(nper2 - 1, write=True, read=False),
                         sdo_data=d2)
    cocotb.start_soon(tb.stream_sdo(res.sdo_words))
    await tb.wait_idle()
    await ClockCycles(dut.clk, 3)
    tb.sb.compare_sequences(res.sdo_words, tb.bus_mon.sdo_words, field="post_rst")
    tb.sb.assert_no_errors()


@cocotb.test()
async def test_reset_during_sleep(dut):
    """Reset during a sleep instruction; clean recovery to idle."""
    tb = ExecutionTB(dut)
    await tb.start()
    await tb.issue(ins.config_clk_div(3))
    await tb.wait_idle()

    await tb.issue(ins.sleep(20))
    await ClockCycles(dut.clk, 10)
    await apply_reset(dut, cycles_before=0, hold=3)
    # REQ: EXEC-CC-07 - reset mid-sleep also restores reset values (recovers to idle)
    errs = check_reset_values(dut, tb.params, scoreboard=tb.sb)
    assert not errs, f"post-reset values wrong: {errs}"
    assert int(dut.cmd_ready.value) == 1, "engine not idle after reset"
    tb.sb.assert_no_errors()


@cocotb.test()
async def test_reset_clears_receive_state(dut):
    """First read after reset returns only newly-sampled bits (no stale SDI)."""
    tb = ExecutionTB(dut)
    await tb.start()
    wl = tb.params["DATA_WIDTH"]
    rng = tb.rc.derive("rst_rx")

    # Start a read transfer and reset partway through so some bits are shifted in.
    await tb.issue(ins.config_clk_div(3))
    await tb.wait_idle()
    await tb.issue(ins.chipselect(0, delay=1))
    await tb.wait_idle()
    stale = [rng.randrange(1 << wl) for _ in range(4 * tb.num_sdio)]
    await tb.issue(ins.transfer(3, write=False, read=True), sdi_data=stale)
    tb.slave.start()
    for _ in range(30):
        await RisingEdge(dut.clk)
        if int(dut.transfer_active.value) == 1:
            break
    await ClockCycles(dut.clk, 5)
    # Stop the slave (and release sdi) before asserting reset so it is not mid
    # drive when the transfer is torn down, then reset.
    tb.slave.stop()
    await apply_reset(dut, cycles_before=0, hold=3)
    tb.after_reset()

    # Clean read after reset must return exactly the fresh responses. The lane
    # tables auto-rebuild after reset (see test_reset_during_transfer), so no
    # post-reset lane-mask reprogram is required.
    await tb.issue(ins.chipselect(0, delay=1))
    await tb.wait_idle()
    fresh = [rng.randrange(1 << wl) for _ in range(2 * tb.num_sdio)]
    res = await tb.issue(ins.transfer(1, write=False, read=True), sdi_data=fresh)
    tb.slave.start()
    await tb.wait_idle()
    await ClockCycles(dut.clk, 10)
    # REQ: EXEC-RST-07 - receive state cleared by reset; only fresh bits returned
    tb.sb.compare_sequences(res.sdi_words, tb.sdi_values, field="fresh_sdi")
    tb.sb.assert_no_errors()
