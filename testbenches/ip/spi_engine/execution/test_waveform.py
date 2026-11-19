"""SPI waveform: SCLK period, CPOL idle, CPHA/CPOL edge relationship,
and runtime-change-takes-effect-next-transfer.

The passive SPI bus monitor reconstructs SDO words by sampling on the CPOL/CPHA-
implied edge; a correct round-trip across all four modes therefore confirms the
standard sampling/update-edge relationship (EXEC-SCLK-03) end-to-end. SCLK period
is measured directly on the boundary sclk output across several prescaler values.
"""

import cocotb
from cocotb.triggers import RisingEdge, ClockCycles, Edge

from framework.spi import instructions as ins
from tb_env import ExecutionTB


@cocotb.test()
async def test_sclk_period_across_div(dut):
    """SCLK period = (div+1)*2 core clocks for several prescaler values."""
    tb = ExecutionTB(dut)
    await tb.start()
    wl = tb.params["DATA_WIDTH"]
    rng = tb.rc.derive("sclk_div_sweep")
    # div=0 is kept as a literal (the true minimum-divider boundary, and the
    # fastest/most timing-sensitive case); the rest of the sweep is random,
    # capped at 15 to keep sim time bounded rather than walking the full
    # 8-bit field.
    divs = sorted({0, rng.randint(1, 7), rng.randint(8, 15)})

    for div in divs:
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
    # cpol is a 1-bit field: (0, 1) is its complete value space, not a sample
    # of a larger one, so both are exercised as literals rather than randomized.
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


_EDGES = [0]


async def _count_sclk_edges(dut):
    """Count SCLK edges (rising + falling) into _EDGES[0] until cancelled."""
    _EDGES[0] = 0
    while True:
        await Edge(dut.sclk)
        _EDGES[0] += 1


@cocotb.test()
async def test_config_change_takes_effect_next_transfer(dut):
    """A config-register change applies to the next transfer, not before it.

    Sweeps two independent config fields - clk_div (via the SCLK period) and
    word_length (via the SCLK edge count) - each in both directions, so a
    change that only "sticks" going one way (e.g. an initial-value coincidence
    at div=0 or wl=DATA_WIDTH) cannot pass unnoticed.
    """
    tb = ExecutionTB(dut)
    await tb.start()
    wl = tb.params["DATA_WIDTH"]
    allcs = (1 << tb.params["NUM_OF_CS"]) - 1
    rng = tb.rc.derive("cfg_next_xfer")

    # -- clk_div: reconfigure just before a transfer and confirm the SCLK
    # period it uses is the new value, in both directions (low->high and
    # high->low). The two halves of the pair are drawn from disjoint ranges so
    # "before" and "after" are never accidentally equal.
    div_lo, div_hi = rng.randint(0, 3), rng.randint(4, 15)
    for idx, (before, after) in enumerate([(div_lo, div_hi), (div_hi, div_lo)]):
        await tb.issue(ins.config_clk_div(before))
        await tb.wait_idle()
        await tb.issue(ins.chipselect(0, delay=1))
        await tb.wait_idle()

        await tb.issue(ins.config_clk_div(after))
        await tb.wait_idle()
        data = [(0x33 + i) & ((1 << wl) - 1) for i in range(tb.num_sdio)]
        res = await tb.issue(ins.transfer(0, write=True, read=False),
                             sdo_data=data)
        tb.start_sdo_stream(res.sdo_words)
        period = await tb.measure_sclk_period()
        await tb.wait_idle()
        # REQ: EXEC-SCLK-04 - runtime prescaler change takes effect on next transfer
        tb.sb.compare_within(idx, "sclk_next_xfer", (after + 1) * 2, period, 1,
                             note=f"div {before}->{after}")
        await ClockCycles(dut.clk, 3)
        await tb.issue(ins.chipselect(allcs, delay=1))
        await tb.wait_idle()

    # -- word_length: same idea, measured as the SCLK edge count of the
    # next transfer (nper * new word_length, EXEC-XFER-01), in both directions
    # (DATA_WIDTH -> short and short -> DATA_WIDTH).
    short_wls = sorted({2, rng.randint(2, wl - 1)})
    for short_wl in short_wls:
        for idx, (before, after) in enumerate([(wl, short_wl), (short_wl, wl)]):
            await tb.issue(ins.config_word_length(before))
            await tb.wait_idle()
            await tb.issue(ins.chipselect(0, delay=1))
            await tb.wait_idle()

            await tb.issue(ins.config_word_length(after))
            await tb.wait_idle()
            nper = 2
            data = [(0x11 + i) & ((1 << wl) - 1) for i in range(nper * tb.num_sdio)]
            res = await tb.issue(ins.transfer(nper - 1, write=True, read=False),
                                 sdo_data=data)
            tb.start_sdo_stream(res.sdo_words)
            counter = cocotb.start_soon(_count_sclk_edges(dut))
            await tb.wait_idle()
            await ClockCycles(dut.clk, 3)
            counter.cancel()
            edges = _EDGES[0]
            # REQ: EXEC-SCLK-04 - runtime word_length change takes effect on the next transfer
            # Every shifted bit toggles SCLK twice: edges = 2 * nper * new word_length.
            tb.sb.compare(idx, "wl_next_xfer_sclk_edges", 2 * nper * after,
                          edges, note=f"word_length {before}->{after}")
            await tb.issue(ins.chipselect(allcs, delay=1))
            await tb.wait_idle()

    tb.sb.assert_no_errors()
