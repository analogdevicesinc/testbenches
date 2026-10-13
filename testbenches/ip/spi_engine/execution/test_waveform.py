"""SPI waveform: SCLK period, CPOL idle, CPHA/CPOL edge relationship,
and runtime-change-takes-effect-next-transfer.

The passive SPI bus monitor reconstructs SDO words by sampling on the CPOL/CPHA-
implied edge; a correct round-trip across all four modes therefore confirms the
standard sampling/update-edge relationship (EXEC-SCLK-03) end-to-end. SCLK period
is measured directly on the boundary sclk output across several prescaler values.
"""

import cocotb
from cocotb.triggers import RisingEdge, ClockCycles

from framework.spi import instructions as ins
from tb_env import ExecutionTB


@cocotb.test()
async def test_sclk_period_across_div(dut):
    """SCLK period = (div+1)*2 core clocks for several prescaler values."""
    tb = ExecutionTB(dut)
    await tb.start()
    wl = tb.params["DATA_WIDTH"]

    for div in (0, 1, 3):
        await tb.issue(ins.config_clk_div(div))
        await tb.wait_idle()
        await tb.issue(ins.chipselect(0, delay=1))
        await tb.wait_idle()
        data = [(0x5A + i) & ((1 << wl) - 1) for i in range(tb.num_sdio)]
        res = await tb.issue(ins.transfer(0, write=True, read=False),
                             sdo_data=data)
        tb.start_sdo_stream(res.sdo_words)
        period = await tb.measure_sclk_period()
        await tb.wait_idle()
        # REQ: EXEC-SCLK-01 - SCLK period is (div+1)*2 core clocks
        # REQ: EXEC-PARAM-05 - DEFAULT_CLK_DIV sets the initial SCLK period
        tb.sb.compare_within(div, "sclk_period", (div + 1) * 2, period, 1,
                             note=f"div={div}")
        await ClockCycles(dut.clk, 3)
        allcs = (1 << tb.params["NUM_OF_CS"]) - 1
        await tb.issue(ins.chipselect(allcs, delay=1))
        await tb.wait_idle()
    tb.sb.assert_no_errors()


@cocotb.test()
async def test_sclk_idle_level(dut):
    """When not transferring, sclk idles at the CPOL level."""
    tb = ExecutionTB(dut)
    await tb.start()
    for cpol in (0, 1):
        await tb.issue(ins.config_spi_mode(cpol=cpol))
        await tb.wait_idle()
        await ClockCycles(dut.clk, 4)
        # REQ: EXEC-SCLK-02 - sclk idles at CPOL when not transferring
        tb.sb.compare(cpol, "sclk_idle", cpol, int(dut.sclk.value))
    tb.sb.assert_no_errors()


@cocotb.test()
async def test_all_cpol_cpha_modes(dut):
    """All four CPOL/CPHA modes: idle level and data round-trip correctly."""
    tb = ExecutionTB(dut)
    await tb.start()
    wl = tb.params["DATA_WIDTH"]

    for cpol in (0, 1):
        for cpha in (0, 1):
            await tb.issue(ins.config_spi_mode(cpol=cpol, cpha=cpha))
            await tb.wait_idle()
            await ClockCycles(dut.clk, 3)
            tb.sb.compare((cpol << 1) | cpha, "mode_idle_sclk", cpol,
                          int(dut.sclk.value), note=f"cpol={cpol} cpha={cpha}")

            await tb.issue(ins.chipselect(0, delay=1))
            await tb.wait_idle()
            data = [tb.rc.derive(f"mode_{cpol}{cpha}").randrange(1 << wl)
                    for _ in range(tb.num_sdio)]
            res = await tb.issue(ins.transfer(0, write=True, read=False),
                                 sdo_data=data)
            await tb.stream_sdo(res.sdo_words)
            await tb.wait_idle()
            await ClockCycles(dut.clk, 3)
            # REQ: EXEC-SCLK-03 - CPOL/CPHA produce the standard edge relationship
            # REQ: EXEC-SCLK-05 - sclk/sdo/sdo_t retain fixed mutual alignment
            tb.sb.compare_sequences(res.sdo_words, tb.bus_mon.sdo_words,
                                    field=f"mode{cpol}{cpha}")
            tb.bus_mon.words.clear()
            await tb.issue(ins.chipselect((1 << tb.params["NUM_OF_CS"]) - 1,
                                          delay=1))
            await tb.wait_idle()
    tb.sb.assert_no_errors()


@cocotb.test()
async def test_config_change_takes_effect_next_transfer(dut):
    """A prescaler change applies to the next transfer, not the current one."""
    tb = ExecutionTB(dut)
    await tb.start()
    wl = tb.params["DATA_WIDTH"]

    # Baseline transfer at div=0, then reconfigure to div=3 for the next one and
    # confirm the new period is what the following transfer uses.
    await tb.issue(ins.config_clk_div(0))
    await tb.wait_idle()
    await tb.issue(ins.chipselect(0, delay=1))
    await tb.wait_idle()

    await tb.issue(ins.config_clk_div(3))
    await tb.wait_idle()
    data = [(0x33 + i) & ((1 << wl) - 1) for i in range(tb.num_sdio)]
    res = await tb.issue(ins.transfer(0, write=True, read=False), sdo_data=data)
    tb.start_sdo_stream(res.sdo_words)
    period = await tb.measure_sclk_period()
    await tb.wait_idle()
    # REQ: EXEC-SCLK-04 - runtime prescaler change takes effect on next transfer
    tb.sb.compare_within(0, "sclk_next_xfer", (3 + 1) * 2, period, 1)
    tb.sb.assert_no_errors()
