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
    """cmd_ready is high when idle and low while an instruction executes.

    Swept over several prescalers and over write/read/full-duplex transfers so
    the gating is shown to hold across the decoder's transfer-type space, not
    just one fixed (div=3, write-only) scenario.
    """
    tb = ExecutionTB(dut)
    await tb.start()

    # REQ: EXEC-CMD-01 - cmd_ready asserted only when idle
    assert int(dut.cmd_ready.value) == 1, "cmd_ready not high when idle"

    wl = tb.params["DATA_WIDTH"]
    rng = tb.rc.derive("cmd_gate")

    for div in (0, 1, 3):
        await tb.issue(ins.config_clk_div(div))
        await tb.wait_idle()
        await tb.issue(ins.chipselect(0, delay=1))
        await tb.wait_idle()

        for write, read in ((True, False), (False, True), (True, True)):
            data = ([rng.randrange(1 << wl) for _ in range(2 * tb.num_sdio)]
                    if write else None)
            resp = ([rng.randrange(1 << wl) for _ in range(2 * tb.num_sdio)]
                    if read else None)
            res = await tb.issue(ins.transfer(1, write=write, read=read),
                                 sdo_data=data, sdi_data=resp)
            if write:
                tb.start_sdo_stream(res.sdo_words)
            if read:
                tb.slave.start()
            for _ in range(40):
                await RisingEdge(dut.clk)
                if int(dut.transfer_active.value) == 1:
                    break
            note = f"div={div} w={write} r={read}"
            # REQ: EXEC-CMD-02 - cmd_ready deasserted while executing (upstream stalls)
            assert int(dut.cmd_ready.value) == 0, f"cmd_ready high mid-instruction ({note})"
            await tb.wait_idle()
            assert int(dut.cmd_ready.value) == 1, f"cmd_ready not restored after exec ({note})"
    tb.sb.assert_no_errors()


@cocotb.test()
async def test_cmd_handshake_single_beat(dut):
    """A command transfers on exactly the cmd_valid && cmd_ready cycle.

    Repeated across one representative command per decoder opcode (cmd[14:12])
    so the single-beat handshake is shown to hold decoder-wide, not just for
    the sync opcode.
    """
    tb = ExecutionTB(dut)
    await tb.start()
    rng = tb.rc.derive("cmd_handshake")
    allcs = (1 << tb.params["NUM_OF_CS"]) - 1

    # The 5 opcodes below are the decoder's complete cmd[14:12] space (a full
    # enumeration, not a sample), so the opcode selection itself stays a
    # literal; each command's payload field is randomized since its value is
    # incidental to the handshake-timing property under test.
    cmds = [
        ("transfer", ins.transfer(rng.randint(0, 3), write=False, read=False)),  # CMD_TRANSFER
        ("chipselect", ins.chipselect(rng.randint(0, allcs), delay=1)),          # CMD_CHIPSELECT
        ("write_reg", ins.config_clk_div(rng.randint(0, 15))),                   # CMD_WRITE
        ("sync", ins.sync(rng.randint(0, 0xFF))),                                # CMD_MISC
        ("cs_invert", ins.cs_invert(rng.randint(0, allcs))),                     # CMD_CS_INV
    ]

    for name, cmd in cmds:
        # Hold cmd back manually: drive valid, wait for the accept cycle.
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
        # REQ: EXEC-CMD-03 - opcode taken from cmd[14:12] (every opcode accepted this way)
        assert accepted == 1, (
            f"{name} command accepted {accepted} times, expected 1")
        await tb.wait_idle()
    tb.sb.assert_no_errors()


@cocotb.test()
async def test_cmd_in_order_execution(dut):
    """Commands execute strictly in the order accepted.

    Swept over several prescalers and a mix of write/read/full-duplex
    single-word transfers, so in-order completion is checked across the
    decoder's transfer-type space rather than one fixed write-only scenario.

    At SDI_DELAY>0 with clk_div=0, a read at a back-to-back transfer boundary
    must still deliver its last bit intact, although that bit is captured
    SDI_DELAY+1 clocks after its SCLK edge (EXEC-SDI-05). runner.py's CONFIGS
    sweep covers SDI_DELAY 0..3.
    """
    tb = ExecutionTB(dut)
    await tb.start()
    wl = tb.params["DATA_WIDTH"]
    rng = tb.rc.derive("cmd_order")

    # A run of distinct transfers mixing all three {write, read} combinations.
    kinds = [(True, False), (False, True), (True, True),
             (True, False), (False, True)]

    # The passive bus monitor samples one word per *active* SPI period
    # regardless of the write flag (it watches the wire, not the instruction) -
    # outside a write the wire simply holds the idle level for that period. So
    # a non-write period still contributes one constant "idle word" per active
    # lane to bus_mon.sdo_words, and the expected sequence must include it to
    # stay aligned with the issue order.
    idle_mask = (1 << wl) - 1
    idle_word = idle_mask if tb.model.sdo_idle_state else 0
    n_lanes_sdo = max(1, bin(tb.model.sdo_lane_mask
                             & ((1 << tb.num_sdio) - 1)).count("1"))

    for div in (0, 2):
        await tb.issue(ins.config_clk_div(div))
        await tb.wait_idle()
        await tb.issue(ins.chipselect(0, delay=1))
        await tb.wait_idle()

        # The captured bus order must match the issue order exactly (no
        # reordering, no loss), checked independently on each direction.
        expected_sdo = []
        expected_sdi = []
        tb.bus_mon.words.clear()
        tb.sdi_mon.received.clear()
        for write, read in kinds:
            d = [rng.randrange(1 << wl) for _ in range(tb.num_sdio)] if write else None
            r = [rng.randrange(1 << wl) for _ in range(tb.num_sdio)] if read else None
            res = await tb.issue(ins.transfer(0, write=write, read=read),
                                 sdo_data=d, sdi_data=r)
            if write:
                expected_sdo += res.sdo_words
                await tb.stream_sdo(res.sdo_words)
            else:
                expected_sdo += [idle_word] * n_lanes_sdo
            if read:
                expected_sdi += res.sdi_words
                # start()/stop() (not a bare start()) so each read transfer's
                # slave task freshly fetches its just-loaded response queue
                # instead of a prior task's stale look-ahead prefetch bleeding
                # into this transfer (see test_reset.py/test_chipselect.py for
                # the same start/stop-per-transfer idiom).
                tb.slave.start()
            await tb.wait_idle()
            if read:
                tb.slave.stop()
            await ClockCycles(dut.clk, 2)
        # REQ: EXEC-CMD-04 - commands complete in order, one before the next
        tb.sb.compare_sequences(expected_sdo, tb.bus_mon.sdo_words,
                                field=f"order_sdo_div{div}")
        tb.sb.compare_sequences(expected_sdi, tb.sdi_values,
                                field=f"order_sdi_div{div}")
    tb.sb.assert_no_errors()
