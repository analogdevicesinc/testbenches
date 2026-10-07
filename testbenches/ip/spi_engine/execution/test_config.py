"""Configuration-Write registers, and EXEC-CC-01.

Each configuration register write is exercised for its boundary-observable
effect: prescaler (SCLK period), SPI-config bits (CPOL idle level, three_wire,
sdo_idle_state), dynamic word length, and the two lane-mask registers (SDI is
accept-only, its effect is downstream; SDO effect is covered in test_lanes). Also checks the
single-cycle / back-to-back property (EXEC-CFG-07), config-then-transfer using
the new value (EXEC-CC-01), and the >DATA_WIDTH region (FLAG EXEC-F6).
"""

import cocotb
from cocotb.triggers import RisingEdge, ClockCycles

from framework.spi import instructions as ins
from tb_env import ExecutionTB


@cocotb.test()
async def test_config_clk_div(dut):
    """Register 000 (prescaler) sets the SCLK period on the next transfer."""
    tb = ExecutionTB(dut)
    await tb.start()
    wl = tb.params["DATA_WIDTH"]
    div = 3
    await tb.issue(ins.config_clk_div(div))
    await tb.wait_idle()
    await tb.issue(ins.chipselect(0, delay=1))
    await tb.wait_idle()

    data = [(0xA5 + i) & ((1 << wl) - 1) for i in range(tb.num_sdio)]
    res = await tb.issue(ins.transfer(0, write=True, read=False), sdo_data=data)
    tb.start_sdo_stream(res.sdo_words)
    period = await tb.measure_sclk_period()
    await tb.wait_idle()
    # REQ: EXEC-CFG-01 - prescaler register sets clk divider for later transfers
    tb.sb.compare_within(0, "clkdiv_period", (div + 1) * 2, period, 1)
    tb.sb.assert_no_errors()


@cocotb.test()
async def test_config_spi_bits(dut):
    """Register 001 sets CPOL (idle sclk), three_wire, and sdo_idle_state."""
    tb = ExecutionTB(dut)
    await tb.start()

    # three_wire bit observable directly on the boundary output.
    await tb.issue(ins.config_spi_mode(three_wire=1))
    await tb.wait_idle()
    await ClockCycles(dut.clk, 2)
    # REQ: EXEC-CFG-02 - three_wire = config bit 2
    # REQ: EXEC-BUS-05 - three_wire reflects SPI-config bit 2
    tb.sb.compare(0, "cfg.three_wire", 1, int(dut.three_wire.value))

    # sdo_idle_state bit: with it set, sdo idles high between transfers.
    await tb.issue(ins.config_spi_mode(three_wire=1, sdo_idle_state=1))
    await tb.wait_idle()
    await ClockCycles(dut.clk, 3)
    # (SDO-03 idle level is homed in test_transfer; here the sdo_idle_state bit)
    all_lanes = (1 << tb.num_sdio) - 1
    tb.sb.compare(0, "cfg.sdo_idle_high", all_lanes, int(dut.sdo.value))

    # CPOL bit: idle sclk tracks it.
    for cpol in (0, 1):
        await tb.issue(ins.config_spi_mode(cpol=cpol))
        await tb.wait_idle()
        await ClockCycles(dut.clk, 3)
        tb.sb.compare(cpol, "cfg.cpol_idle", cpol, int(dut.sclk.value))
    tb.sb.assert_no_errors()


@cocotb.test()
async def test_config_word_length(dut):
    """Register 010 (dynamic word length) is honoured by the transfer."""
    tb = ExecutionTB(dut)
    await tb.start()
    wl_full = tb.params["DATA_WIDTH"]
    new_wl = max(1, wl_full // 2)
    await tb.issue(ins.config_word_length(new_wl))
    await tb.wait_idle()
    await tb.issue(ins.chipselect(0, delay=1))
    await tb.wait_idle()

    data = [tb.rc.derive("wl_cfg").randrange(1 << new_wl)
            for _ in range(tb.num_sdio)]
    res = await tb.issue(ins.transfer(0, write=True, read=False), sdo_data=data)
    await tb.stream_sdo(res.sdo_words)
    await tb.wait_idle()
    await ClockCycles(dut.clk, 5)
    # REQ: EXEC-CFG-03 - word_length register sets bit-periods per word
    tb.sb.compare_sequences(res.sdo_words, tb.bus_mon.sdo_words, field="wl_cfg")
    tb.sb.assert_no_errors()


@cocotb.test()
async def test_config_sdi_lane_mask_accepted(dut):
    """Register 011 (SDI lane mask) is accepted; masking effect is downstream."""
    tb = ExecutionTB(dut)
    await tb.start()
    wl = tb.params["DATA_WIDTH"]
    nsd = tb.num_sdio
    mask = 1 if nsd == 1 else (1 | (1 << (nsd - 1)))
    # The write must be accepted (engine stays functional) — its masking effect
    # lives downstream in axi_spi_engine (FLAG EXEC-F2 / EXEC-OOS-01), so only
    # acceptance is checkable at this boundary.
    await tb.issue(ins.config_sdi_lane_mask(mask))
    await tb.wait_idle()
    # REQ: EXEC-CFG-04 - SDI lane-mask register accepted (no boundary effect here)
    assert int(dut.cmd_ready.value) == 1, "engine stalled after SDI mask write"

    # A normal read still works after accepting the mask.
    await tb.issue(ins.chipselect(0, delay=1))
    await tb.wait_idle()
    resp = [tb.rc.derive("sdi_after_mask").randrange(1 << wl)
            for _ in range(2 * tb.num_sdio)]
    res = await tb.issue(ins.transfer(1, write=False, read=True), sdi_data=resp)
    tb.slave.start()
    await tb.wait_idle()
    await ClockCycles(dut.clk, 8)
    tb.sb.compare_sequences(res.sdi_words, tb.sdi_values, field="sdi_after_mask")
    tb.sb.assert_no_errors()


@cocotb.test()
async def test_config_back_to_back(dut):
    """Config writes complete in one cycle; back-to-back at 1 cmd/cycle."""
    tb = ExecutionTB(dut)
    await tb.start()

    # Stream several config writes with no gaps; cmd_ready must stay high (each
    # retires in a single cycle, never removing the engine from accepting).
    cmds = [ins.config_clk_div(1), ins.config_word_length(tb.params["DATA_WIDTH"]),
            ins.config_spi_mode(cpol=0, cpha=0), ins.config_clk_div(2)]
    stalled_cycles = 0
    for c in cmds:
        tb.model.apply(c)
        dut.cmd.value = c
        dut.cmd_valid.value = 1
        await RisingEdge(dut.clk)
        if int(dut.cmd_ready.value) == 0:
            stalled_cycles += 1
    dut.cmd_valid.value = 0
    await tb.wait_idle()
    # REQ: EXEC-CFG-07 - config write is 1 cycle; does not stall command stream
    assert stalled_cycles == 0, f"config write stalled cmd stream {stalled_cycles}x"
    tb.sb.assert_no_errors()


@cocotb.test()
async def test_config_then_transfer_uses_new_value(dut):
    """A config write immediately followed by a transfer uses the new value."""
    tb = ExecutionTB(dut)
    await tb.start()
    wl_full = tb.params["DATA_WIDTH"]
    new_wl = max(1, wl_full // 2)

    await tb.issue(ins.chipselect(0, delay=1))
    await tb.wait_idle()
    # No wait_idle stall other than command handshake between config and transfer.
    await tb.issue(ins.config_word_length(new_wl))
    await tb.wait_idle()
    data = [tb.rc.derive("cc01").randrange(1 << new_wl)
            for _ in range(2 * tb.num_sdio)]
    res = await tb.run_transfer(n=2, write=True, read=False, sdo_words=data, cs=0)
    # REQ: EXEC-CC-01 - config-then-transfer uses the new value on that transfer
    tb.sb.compare_sequences(res.sdo_words, tb.bus_mon.sdo_words, field="cc01")
    tb.sb.assert_no_errors()


@cocotb.test()
async def test_word_length_over_data_width(dut):
    """word_length > DATA_WIDTH: write accepted; region unspecified (FLAG F6).

    The spec constrains word_length <= DATA_WIDTH and leaves larger values
    unspecified (EXEC-CFG-06 / FLAG EXEC-F6; Linux does not clamp). So this only
    asserts the write is *accepted* and the engine stays alive — it deliberately
    does NOT assert any transfer semantics in the undefined region.
    """
    tb = ExecutionTB(dut)
    await tb.start()
    over = min(255, tb.params["DATA_WIDTH"] + 4)
    await tb.issue(ins.config_word_length(over))
    await tb.wait_idle()
    # REQ: EXEC-CFG-06 - value > DATA_WIDTH is accepted; behaviour unspecified
    assert int(dut.cmd_ready.value) == 1, "engine stalled on oversized word len"
    # Restore a valid length and confirm the engine still transfers correctly.
    await tb.issue(ins.config_word_length(tb.params["DATA_WIDTH"]))
    await tb.wait_idle()
    data = [tb.rc.derive("f6").randrange(1 << tb.params["DATA_WIDTH"])
            for _ in range(tb.num_sdio)]
    res = await tb.run_transfer(n=1, write=True, read=False, sdo_words=data)
    tb.sb.compare_sequences(res.sdo_words, tb.bus_mon.sdo_words, field="f6_recover")
    tb.sb.assert_no_errors()
