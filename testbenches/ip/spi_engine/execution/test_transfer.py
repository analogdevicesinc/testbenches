"""Transfer instruction: SDO/SDI datapaths, and EXEC-CC-02/03.

Covers the Transfer instruction end-to-end at the module boundary: word count
(n+1), MSB-first shifting on both directions, the four {r,w} combinations
(including the clock-only 00 characterization lock), sdo_t polarity, sdo idle
level, short (MSB-aligned) words, single/multi-word termination, and the
closed-form transfer-duration timing (EXEC-XFER-08).

Data is checked exactly; timing with a small ±cycle tolerance.
"""

import cocotb
from cocotb.triggers import RisingEdge, ClockCycles

from framework.spi import instructions as ins
from tb_env import ExecutionTB


@cocotb.test()
async def test_write_only(dut):
    """w=1 r=0: SDO words shifted out match the streamed data, sdo_t driven."""
    tb = ExecutionTB(dut)
    await tb.start()
    wl = tb.params["DATA_WIDTH"]
    n = 4
    data = [tb.rc.derive("wdata").randrange(1 << wl)
            for _ in range(n * tb.num_sdio)]

    await tb.issue(ins.chipselect(0, delay=1))
    await tb.wait_idle()

    res = await tb.issue(ins.transfer(n - 1, write=True, read=False),
                         sdo_data=data)
    tb.start_sdo_stream(res.sdo_words)
    # REQ: EXEC-XFER-03 - during a write sdo_t is driven (0)
    sdo_t = await tb.sample_sdo_t_during_transfer()
    # REQ: EXEC-BUS-03 - sdo_t is 0 (driven) only during a write transfer
    tb.sb.compare(0, "sdo_t.write", 0, sdo_t)
    await tb.wait_idle()
    await ClockCycles(dut.clk, 5)

    # REQ: EXEC-XFER-01 - n+1 words generated for the transfer
    # REQ: EXEC-XFER-02 - bits shifted MSB-first (monitor reconstructs from wire)
    # REQ: EXEC-SDO-01 - each word MSB-first, one bit per SCLK bit-period
    # REQ: EXEC-SDO-04 - exactly n+1 words consumed from the SDO stream
    tb.sb.compare_sequences(res.sdo_words, tb.bus_mon.sdo_words, field="sdo")
    tb.sb.assert_no_errors()


@cocotb.test()
async def test_read_only(dut):
    """w=0 r=1: SDI words captured match the slave; sdo tristated/idle."""
    tb = ExecutionTB(dut)
    await tb.start()
    wl = tb.params["DATA_WIDTH"]
    n = 4
    resp = [tb.rc.derive("rdata").randrange(1 << wl)
            for _ in range(n * tb.num_sdio)]

    await tb.issue(ins.chipselect(0, delay=1))
    await tb.wait_idle()

    res = await tb.issue(ins.transfer(n - 1, write=False, read=True),
                         sdi_data=resp)
    tb.slave.start()
    # REQ: EXEC-XFER-06 - during a read (w=0) sdo_t is tristated (1)
    sdo_t = await tb.sample_sdo_t_during_transfer()
    tb.sb.compare(0, "sdo_t.read", 1, sdo_t)
    await tb.wait_idle()
    await ClockCycles(dut.clk, 5)

    # REQ: EXEC-XFER-04 - sdi sampled and assembled word presented on SDI stream
    # REQ: EXEC-SDI-01 - sdi sampled MSB-first into the lane slice
    # REQ: EXEC-SDI-02 - sdi_data_valid asserts once a word is received, held to ready
    # REQ: EXEC-SDI-03 - exactly n+1 SDI words produced
    tb.sb.compare_sequences(res.sdi_words, tb.sdi_values, field="sdi")
    tb.sb.assert_no_errors()


@cocotb.test()
async def test_read_write_full_duplex(dut):
    """w=1 r=1: both directions exercised simultaneously."""
    tb = ExecutionTB(dut)
    await tb.start()
    wl = tb.params["DATA_WIDTH"]
    n = 3
    nwords = n * tb.num_sdio
    wdata = [tb.rc.derive("rw_w").randrange(1 << wl) for _ in range(nwords)]
    rdata = [tb.rc.derive("rw_r").randrange(1 << wl) for _ in range(nwords)]

    await tb.issue(ins.chipselect(0, delay=1))
    await tb.wait_idle()

    res = await tb.issue(ins.transfer(n - 1, write=True, read=True),
                         sdo_data=wdata, sdi_data=rdata)
    tb.slave.start()
    await tb.stream_sdo(res.sdo_words)
    await tb.wait_idle()
    await ClockCycles(dut.clk, 5)

    # (XFER-05 all-four-{r,w} is homed in test_clock_only_transfer; rw=11 here)
    # REQ: EXEC-SDI-04 - each SDIO lane captured into its own DATA_WIDTH slice
    tb.sb.compare_sequences(res.sdo_words, tb.bus_mon.sdo_words, field="sdo")
    tb.sb.compare_sequences(res.sdi_words, tb.sdi_values, field="sdi")
    tb.sb.assert_no_errors()


@cocotb.test()
async def test_clock_only_transfer(dut):
    """rw=00: SCLK toggles with no stream traffic (RTL-CHARACTERIZED lock).

    Neither reference driver emits a clock-only transfer (spec Appendix C), so
    this is a regression lock, not a conformance check: it pins the current RTL
    behaviour (SCLK runs, no SDO/SDI words move) ahead of any driver need.
    """
    tb = ExecutionTB(dut)
    await tb.start()
    await tb.issue(ins.config_clk_div(1))
    await tb.wait_idle()
    await tb.issue(ins.chipselect(0, delay=1))
    await tb.wait_idle()

    tb.bus_mon.words.clear()
    # No sdo_data streamed, no slave started: a dummy transfer.
    await tb.issue(ins.transfer(2, write=False, read=False))
    saw_sclk = await tb.measure_sclk_period()
    await tb.wait_idle()
    await ClockCycles(dut.clk, 5)
    # REQ: EXEC-XFER-05 - clock-only/dummy (rw=00) toggles SCLK, no stream traffic
    assert saw_sclk > 0, "SCLK did not toggle during a clock-only transfer"
    assert len(tb.sdi_mon.received) == 0, "SDI words produced on a rw=00 transfer"
    tb.sb.assert_no_errors()


@cocotb.test()
async def test_sdo_idle_outside_transfer(dut):
    """Outside a write transfer every sdo lane presents sdo_idle_state."""
    tb = ExecutionTB(dut)
    await tb.start()
    await tb.issue(ins.chipselect(0, delay=1))
    await tb.wait_idle()
    await ClockCycles(dut.clk, 5)
    idle = tb.params.get("SDO_DEFAULT", 0)
    # REQ: EXEC-SDO-03 - sdo presents sdo_idle_state when no write is active
    tb.sb.compare(0, "sdo_idle",
                  idle * ((1 << tb.num_sdio) - 1), int(dut.sdo.value))
    tb.sb.assert_no_errors()


@cocotb.test()
async def test_single_and_multi_word(dut):
    """n=0 (single), n>0 (multi) and a long (max) transfer all terminate to idle.

    The long case caps its word count on wide DATA_WIDTH builds to keep runtime
    reasonable under Verilator; 256 words at wl=8 is fast.
    """
    tb = ExecutionTB(dut)
    await tb.start()
    wl = tb.params["DATA_WIDTH"]
    rng = tb.rc.derive("nwords")
    long_n = 256 if wl <= 8 else 64

    await tb.issue(ins.chipselect(0, delay=1))
    await tb.wait_idle()

    for nper in (1, 5, long_n):
        data = [rng.randrange(1 << wl) for _ in range(nper * tb.num_sdio)]
        tb.bus_mon.words.clear()
        res = await tb.run_transfer(n=nper, write=True, read=False,
                                    sdo_words=data)
        # REQ: EXEC-CC-02 - single, multi and max-length transfers all terminate
        tb.sb.compare_sequences(res.sdo_words, tb.bus_mon.sdo_words,
                                field=f"n{nper}")
        assert int(dut.cmd_ready.value) == 1, "engine not idle after transfer"
    tb.sb.assert_no_errors()


@cocotb.test()
async def test_short_word_msb_aligned(dut):
    """word_length < DATA_WIDTH: short words are MSB-aligned on the wire."""
    tb = ExecutionTB(dut)
    await tb.start()
    wl_full = tb.params["DATA_WIDTH"]
    new_wl = max(1, wl_full // 2)
    await tb.issue(ins.config_word_length(new_wl))
    await tb.wait_idle()
    await tb.issue(ins.chipselect(0, delay=1))
    await tb.wait_idle()

    data = [tb.rc.derive("shortwl").randrange(1 << new_wl)
            for _ in range(2 * tb.num_sdio)]
    res = await tb.run_transfer(n=2, write=True, read=False, sdo_words=data)
    # REQ: EXEC-SDO-02 - short word MSB-aligned (bit word_length-1 first)
    # REQ: EXEC-CC-03 - min/short word length works, MSB-aligned
    # REQ: EXEC-PARAM-03 - DATA_WIDTH sizes the word granularity
    tb.sb.compare_sequences(res.sdo_words, tb.bus_mon.sdo_words, field="short")
    tb.sb.assert_no_errors()


# Startup latency between the CMD handshake and SCLK starting, on top of the
# closed-form transfer time: offset = 3 + n_lanes (measured across lane counts,
# constant over div). The n_lanes term is a transaction quantity — the SDO
# assembler gathers one word per active lane before the first shift — so it lives
# in the expected value; the fixed command/registration latency rides the ±tol.
TRANSFER_STARTUP_FIXED = 3       # command handshake + output registration
TRANSFER_DURATION_TOL = 2        # residual pipeline jitter (±)


@cocotb.test()
async def test_transfer_duration_timing(dut):
    """Transfer execution time matches the closed-form formula + lane startup."""
    tb = ExecutionTB(dut)
    await tb.start()
    wl = tb.params["DATA_WIDTH"]
    # Active SDO lanes drive the assembler fill startup (see module note).
    n_lanes = bin(tb.model.sdo_lane_mask & ((1 << tb.num_sdio) - 1)).count("1")

    for div in (0, 1, 3):
        await tb.issue(ins.config_clk_div(div))
        await tb.wait_idle()
        await tb.issue(ins.chipselect(0, delay=1))
        await tb.wait_idle()

        nper = 3
        data = [tb.rc.derive(f"dur{div}").randrange(1 << wl)
                for _ in range(nper * tb.num_sdio)]
        res = await tb.issue(ins.transfer(nper - 1, write=True, read=False),
                             sdo_data=data)
        tb.start_sdo_stream(res.sdo_words)
        start = tb.now_cycles()
        await tb.wait_idle()
        elapsed = tb.now_cycles() - start
        # Closed-form transfer time plus the lane-scaled fill startup.
        predicted = (tb.model.transfer_duration(nper)
                     + TRANSFER_STARTUP_FIXED + n_lanes)
        tb.log.info(f"div={div} lanes={n_lanes} transfer dur predicted~"
                    f"{predicted} elapsed={elapsed}")
        # REQ: EXEC-XFER-08 - transfer time = 2 + (n+1)*word_length*(div+1)*2
        tb.sb.compare_within(div, "transfer_duration", predicted, elapsed,
                             TRANSFER_DURATION_TOL, note=f"div={div}")
        await ClockCycles(dut.clk, 3)
    tb.sb.assert_no_errors()


@cocotb.test()
async def test_min_word_length(dut):
    """word_length=1: single-bit words shift out correctly.

    A non-zero clk_div keeps the SDO stream able to keep pace (at wl=1/div=0 the
    period is just 2 core clocks, a stimulus-rate limit not a DUT behaviour).
    """
    tb = ExecutionTB(dut)
    await tb.start()
    await tb.issue(ins.config_clk_div(2))
    await tb.wait_idle()
    await tb.issue(ins.config_word_length(1))
    await tb.wait_idle()
    n = 4
    data = [tb.rc.derive("minwl").randint(0, 1) for _ in range(n * tb.num_sdio)]
    res = await tb.run_transfer(n=n, write=True, read=False, sdo_words=data)
    # REQ: EXEC-CC-03 - minimum word_length (wl=1 extreme) shifts out correctly
    tb.sb.compare_sequences(res.sdo_words, tb.bus_mon.sdo_words, field="minwl")
    tb.sb.assert_no_errors()


@cocotb.test()
async def test_transfer_stalls_on_backpressure(dut):
    """A transfer does not advance past a word boundary until flow-ready."""
    tb = ExecutionTB(dut)
    await tb.start()
    wl = tb.params["DATA_WIDTH"]
    n = 5
    data = [tb.rc.derive("xfer_bp").randrange(1 << wl)
            for _ in range(n * tb.num_sdio)]
    # Random gaps in the SDO producer: engine must stall losslessly.
    res = await tb.run_transfer(n=n, write=True, read=False, sdo_words=data,
                                sdo_gap=(1, 3))
    # REQ: EXEC-XFER-07 - transfer stalls until flow-control readiness, no loss
    tb.sb.compare_sequences(res.sdo_words, tb.bus_mon.sdo_words, field="sdo")
    tb.sb.assert_no_errors()
