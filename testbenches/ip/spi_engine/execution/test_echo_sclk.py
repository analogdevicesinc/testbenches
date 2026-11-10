"""ECHO_SCLK=1 datapath (RTL-CHARACTERIZED locks), plus EXEC-CS-04/EXEC-RST-07.

The echo-clock SDI capture path is out of the formal spec's conformance domain
(see requirements.md §12 Out of Scope: no EXEC-ECHO-* conformance requirements are
asserted until this path is documented and modeled). These tests pin the RTL's
current, characterized behaviour as regression locks (EXEC-ECHO-C1/C2) rather
than conformance claims — same posture as EXEC-CS-05 in test_chipselect.py.
Two genuinely domain-unrestricted requirements (EXEC-CS-04, EXEC-RST-07) are
also exercised here since their validity domain is "all parameters", not just
ECHO_SCLK=0.

Only meaningful when the build sets ECHO_SCLK=1; every test below skips
otherwise (see test_offload.py for the same per-build skip pattern).

Assertions are on the boundary cmd_ready/sdi_data path only.

TODO: none vary word_length; echo completion timing has no golden model.
"""

import os

import cocotb
from cocotb.triggers import RisingEdge, ClockCycles

from framework.spi import instructions as ins
from framework.reset import apply_reset

from tb_env import ExecutionTB

_ECHO = int(os.environ.get("PARAM_ECHO_SCLK", 0))

# The echo latch's generate-time edge groups (spi_engine_execution_shiftreg.v):
# cfg[1:0] in {01,10} -> negedge branch, else -> posedge branch.
_GROUP_NEGEDGE = (0b01, 0b10)
_GROUP_POSEDGE = (0b00, 0b11)


def _same_group_alt(cfg01):
    """Return the other DEFAULT_SPI_CFG[1:0] value in cfg01's echo edge group."""
    group = _GROUP_NEGEDGE if cfg01 in _GROUP_NEGEDGE else _GROUP_POSEDGE
    return group[1] if cfg01 == group[0] else group[0]


@cocotb.test(skip=_ECHO != 1)
async def test_echo_read_multi_word(dut):
    """Multi-word read completes and captures correctly via the echo path.

    RTL-CHARACTERIZED lock (EXEC-ECHO-C2, not conformance): transfer
    completion here comes from the edge-detected, core-clock-synchronized
    echo_last_bit/echo_last_transfer mechanism, a different path from
    ECHO_SCLK=0's end_of_word/io_ready1. This locks that the common (n>0)
    case still terminates and captures exactly the driven data.

    REQ: EXEC-PARAM-07 - this whole module only builds the echo capture
    datapath (vs. the internally-clocked one) when ECHO_SCLK=1; every test in
    this file running to completion against such a build exercises that
    path-selection claim.
    """
    tb = ExecutionTB(dut)
    await tb.start()
    wl = tb.params["DATA_WIDTH"]
    rng = tb.rc.derive("echo_multi")
    # n=1 (single-word) is its own dedicated lock below
    # (test_echo_read_single_word / cmd_d1_time_is_zero); this exercises the
    # general multi-word-counted branch, so n is drawn from >=2.
    n = rng.randint(2, 6)
    resp = [rng.randrange(1 << wl) for _ in range(n * tb.num_sdio)]

    res = await tb.run_transfer(n=n, write=False, read=True, sdi_words=resp)
    assert int(dut.cmd_ready.value) == 1, "engine not idle after echo read"
    # REQ: EXEC-ECHO-C2 - multi-word read completes via the echo completion path; data matches
    tb.sb.compare_sequences(res.sdi_words, tb.sdi_values, field="echo_multi")
    tb.sb.assert_no_errors()


@cocotb.test(skip=_ECHO != 1)
async def test_echo_read_single_word(dut):
    """n=0 single-word read exercises the echo path's cmd_d1_time_is_zero case.

    RTL-CHARACTERIZED lock (EXEC-ECHO-C2, not conformance): echo_last_transfer
    special-cases a zero-length command (cmd_d1_time_is_zero) separately from
    the general echo_last_bit-counted case.
    """
    tb = ExecutionTB(dut)
    await tb.start()
    wl = tb.params["DATA_WIDTH"]
    resp = [tb.rc.derive("echo_single").randrange(1 << wl)
            for _ in range(tb.num_sdio)]

    res = await tb.run_transfer(n=1, write=False, read=True, sdi_words=resp)
    assert int(dut.cmd_ready.value) == 1, "engine not idle after single-word echo read"
    # REQ: EXEC-ECHO-C2 - n=0 read completes via the cmd_d1_time_is_zero special case
    tb.sb.compare_sequences(res.sdi_words, tb.sdi_values, field="echo_single")
    tb.sb.assert_no_errors()


@cocotb.test(skip=_ECHO != 1)
async def test_echo_runtime_cfg_change_same_edge_group(dut):
    """A runtime CPOL/CPHA change within the build's echo edge group still works.

    RTL-CHARACTERIZED lock (EXEC-ECHO-C1, not conformance): the echo latch's
    negedge/posedge selection is a build-time `generate if` on
    DEFAULT_SPI_CFG[1:0], never re-evaluated at runtime. This locks the safe
    half of that finding: a REG_CONFIG write that keeps cfg[1:0] in the same
    edge group (e.g. mode 1 -> mode 2, both negedge) does not disturb capture,
    since the shift register's clock edge was never going to change anyway.
    The complementary, riskier claim — that crossing edge groups at runtime
    corrupts capture — is exactly what EXEC-ECHO-C1 predicts but is
    deliberately NOT asserted here: modelling the resulting mismatched-edge
    bit pattern would mean restating that RTL logic in the golden model, which
    is out of the model's stated scope (ECHO_SCLK is out of scope; see
    model_execution.py).
    """
    tb = ExecutionTB(dut)
    await tb.start()
    wl = tb.params["DATA_WIDTH"]
    cfg01 = tb.params["DEFAULT_SPI_CFG"] & 0b11
    alt = _same_group_alt(cfg01)
    await tb.issue(ins.config_spi_mode(cpha=alt & 1, cpol=(alt >> 1) & 1,
                                        three_wire=tb.model.three_wire,
                                        sdo_idle_state=tb.model.sdo_idle_state))
    await tb.wait_idle()

    resp = [tb.rc.derive("echo_samegrp").randrange(1 << wl)
            for _ in range(2 * tb.num_sdio)]
    res = await tb.run_transfer(n=2, write=False, read=True, sdi_words=resp)
    assert int(dut.cmd_ready.value) == 1, "engine not idle after cfg-change echo read"
    # REQ: EXEC-ECHO-C1 - runtime cfg change within the build's echo edge group does not disturb capture
    tb.sb.compare_sequences(res.sdi_words, tb.sdi_values, field="echo_samegrp")
    tb.sb.assert_no_errors()


@cocotb.test(skip=_ECHO != 1)
async def test_echo_cs_assert_clears_receive_state(dut):
    """CS assert clears residual echo-path receive state before capture.

    Echo-build analogue of test_chipselect.test_cs_assert_clears_receive_state:
    cs_activate resets the echo branch's own shift register, bit counter and
    last-bit latch (g_echo_sclk_miso_latch), so two reads separated by a
    re-assert both return exactly their fresh responses.
    """
    tb = ExecutionTB(dut)
    await tb.start()
    wl = tb.params["DATA_WIDTH"]
    rng = tb.rc.derive("echo_cs_rxclear")

    allcs = (1 << tb.params["NUM_OF_CS"]) - 1
    for k in range(2):
        await tb.issue(ins.chipselect(0, delay=1))  # assert -> clears rx state
        await tb.wait_idle()
        resp = [rng.randrange(1 << wl) for _ in range(2 * tb.num_sdio)]
        tb.sdi_mon.received.clear()
        res = await tb.issue(ins.transfer(1, write=False, read=True),
                             sdi_data=resp)
        tb.slave.start()
        await tb.wait_idle()
        await ClockCycles(dut.clk, 8)
        # REQ: EXEC-CS-04 - CS assert clears residual rx state in the echo datapath too
        tb.sb.compare_sequences(res.sdi_words, tb.sdi_values, field=f"echo_rx[{k}]")
        tb.slave.stop()
        await tb.issue(ins.chipselect(allcs, delay=1))  # deselect between reads
        await tb.wait_idle()
    tb.sb.assert_no_errors()


@cocotb.test(skip=_ECHO != 1)
async def test_echo_reset_clears_receive_state(dut):
    """First read after reset returns only freshly-sampled bits in the echo path.

    Echo-build analogue of test_reset.test_reset_clears_receive_state.
    """
    tb = ExecutionTB(dut)
    await tb.start()
    wl = tb.params["DATA_WIDTH"]
    rng = tb.rc.derive("echo_rst_rx")

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
    tb.slave.stop()
    await apply_reset(dut, cycles_before=0, hold=3)
    tb.after_reset()

    await tb.issue(ins.chipselect(0, delay=1))
    await tb.wait_idle()
    fresh = [rng.randrange(1 << wl) for _ in range(2 * tb.num_sdio)]
    res = await tb.issue(ins.transfer(1, write=False, read=True), sdi_data=fresh)
    tb.slave.start()
    await tb.wait_idle()
    await ClockCycles(dut.clk, 10)
    # REQ: EXEC-RST-07 - receive state cleared by reset in the echo datapath too
    tb.sb.compare_sequences(res.sdi_words, tb.sdi_values, field="echo_fresh_sdi")
    tb.sb.assert_no_errors()
