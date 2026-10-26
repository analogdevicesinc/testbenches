"""Directed regression test for the lane-reconfig stale-SDO-word bug.

Reproduces the exact cycle alignment that exposes the bug (fixed in
spi_engine_execution_shiftreg_data_assemble.v):

  T    : lane-config-write command (new SDO lane mask) accepted.
  T+1  : (earliest possible - cmd_ready/idle never drops across a CMD_WRITE)
         a new TRANSFER command accepted, with lane_cfg_valid
         (exec_sdo_lane_cmd) asserted during this same cycle (it is the
         registered, one-cycle-delayed pulse from T's acceptance).

Precondition (word_ready_aligned_int held '1' right before the reconfig):
manufactured deterministically via OFFLOAD surplus prefetch - with
s_offload_active=1 and sdo_data_valid held high, the assembler prefetches
exactly one word beyond what any transfer consumed, and nothing clears
word_ready_int/word_ready_aligned_int while idle, so the "word completed, never
consumed" condition holds steady (not just a 1-cycle pulse) right up to and
through the reconfigure - a superset of the precise single-cycle
timing, and the literal mechanism EXEC-LANE-05's RTL comment calls out
("over-fetched/surplus prefetch").

On RTL without the fix this test FAILS: the new transfer loads lane 0's shift
register from the stale prev_mask word with zero new-mask sdo_data handshakes
consumed. On fixed RTL it PASSES: the lane_cfg_ready/word_ready_aligned gating
forces the transfer to wait for a fresh word instead of consuming the stale
one.

Run with NUM_OF_SDIO=2 (need 2 distinguishable lane masks with lane 0 common
to both, so a leaked old-mask word is unambiguous):

    python3 runner.py --testcase test_lane_reconfig_t1_directed \
        --num-of-sdio 2 --default-clk-div 0
"""

import os

import cocotb
from cocotb.triggers import RisingEdge, ClockCycles, ReadOnly, NextTimeStep

from framework.reset import apply_reset
from framework.spi import instructions as ins
from tb_env import ExecutionTB

STALE_LO = 0xAA  # lane 0 word under prev_mask (dual-lane)
STALE_HI = 0xBB  # lane 1 word under prev_mask

_NSD = int(os.environ.get("PARAM_NUM_OF_SDIO", 1))


@cocotb.test(skip=_NSD < 2)
async def test_lane_reconfig_t1_directed(dut):
    tb = ExecutionTB(dut)
    await tb.start()

    allcs = (1 << tb.params["NUM_OF_CS"]) - 1
    prev_mask = 0b11   # lanes 0,1 active
    next_mask = 0b01   # lane 0 only (lane 0 stays active across the reconfig)

    da = dut.shiftreg.sdo_data_assemble

    # ---- settle prev_mask -------------------------------------------------
    await tb.issue(ins.chipselect(allcs, delay=1))
    await tb.wait_idle()
    await tb.issue(ins.config_sdo_lane_mask(prev_mask))
    await tb.wait_idle()
    await ClockCycles(dut.clk, tb.num_sdio + 4)  # lane_lookup scan settle margin

    # ---- manufacture a steady "surplus prefetched, unconsumed" word -------
    # Note: `sdo_data_ready` sampled right after an edge predicts the *next*
    # edge's handshake (data_ready&&data_valid is evaluated going into a
    # posedge), it does not confirm one *just* happened - so completion is
    # detected via word_ready_int itself, not by counting ready pulses.
    tb.set_offload_active(True)
    dut.sdo_data_valid.value = 1
    dut.sdo_data.value = STALE_LO
    swapped_to_hi = False
    for _ in range(500):
        await RisingEdge(dut.clk)
        await ReadOnly()
        if not swapped_to_hi and int(dut.sdo_data_ready.value) == 1:
            await NextTimeStep()
            dut.sdo_data.value = STALE_HI
            swapped_to_hi = True
            continue
        if int(da.word_ready_int.value) == 1:
            break
    else:
        raise TimeoutError("surplus word never completed assembly")
    assert swapped_to_hi, "never observed the first prefetch handshake"
    await NextTimeStep()
    dut.sdo_data_valid.value = 0
    tb.set_offload_active(False)

    # Confirm the word is "ready" and STUCK (not a transient pulse) - this is
    # the precondition: word_ready_aligned_int steadily 1 right before the
    # reconfig.
    await ClockCycles(dut.clk, 3)
    await ReadOnly()
    assert int(da.word_ready_int.value) == 1, "surplus word never latched ready"
    # (reads only below until the next write; ReadOnly is fine for reads)
    assert int(da.word_ready_aligned_int.value) == 1, "word_ready_aligned_int never set"
    stale_aligned = int(dut.shiftreg.aligned_sdo_data.value)
    tb.log.info(f"[T1-DIRECTED] pre-reconfig steady state: word_ready_int=1 "
                 f"word_ready_aligned_int={int(da.word_ready_aligned_int.value)} "
                 f"aligned_sdo_data=0x{stale_aligned:04x} "
                 f"(expect 0x{(STALE_HI<<8)|STALE_LO:04x})")

    # ---- T: reconfig accepted; T+1: transfer accepted (zero-gap) ----------
    cmd_cfg = ins.config_sdo_lane_mask(next_mask)
    cmd_xfer = ins.transfer(0, write=True, read=False)  # single word, write-only

    await NextTimeStep()
    dut.cmd_valid.value = 1
    dut.cmd.value = cmd_cfg
    while True:
        await RisingEdge(dut.clk)
        await ReadOnly()
        if int(dut.cmd_ready.value) == 1:
            break
    t_cycle = tb.now_cycles()

    # IMPORTANT: cmd must stay == cmd_cfg for the *entire* cycle T interval
    # (up to and including the next edge), because exec_cmd/exec_write_cmd
    # are combinational on the live `cmd` bus - the registered
    # exec_sdo_lane_config_reg pulse latches at the NEXT edge using cmd's
    # value sampled right before that edge. Swapping cmd to the transfer
    # opcode before that edge (as an earlier version of this test did)
    # corrupts the handshake it is trying to observe: the transfer opcode
    # would race in and get accepted ONE EDGE EARLY, stealing the slot
    # meant for the lane-config write instead of following it.
    await RisingEdge(dut.clk)
    await ReadOnly()
    t1_cycle = tb.now_cycles()
    lane_cfg_valid_t1 = int(dut.shiftreg.exec_sdo_lane_cmd.value)
    idle_t1 = int(dut.cmd_ready.value)
    lane_cfg_ready_t1 = int(da.lane_cfg_ready.value)
    sdo_io_ready_t1 = int(dut.shiftreg.sdo_io_ready.value)
    word_ready_aligned_int_t1 = int(da.word_ready_aligned_int.value)

    # Now, within cycle T+1 (between this edge and the next), present the
    # transfer command - the earliest possible next command, back-to-back
    # with the lane-config write that just landed.
    await NextTimeStep()
    dut.cmd.value = cmd_xfer

    await RisingEdge(dut.clk)
    await ReadOnly()
    t2_cycle = tb.now_cycles()
    idle_t2 = int(dut.cmd_ready.value)
    lane_cfg_valid_t2 = int(dut.shiftreg.exec_sdo_lane_cmd.value)
    t1_accepted = (idle_t1 == 1) and (idle_t2 == 0)

    tb.log.info(f"[T1-DIRECTED] T={t_cycle} T+1={t1_cycle} T+2={t2_cycle} "
                 f"idle@T+1={idle_t1} idle@T+2={idle_t2} "
                 f"transfer_accepted_during_T+1={t1_accepted} "
                 f"lane_cfg_valid@T+1={lane_cfg_valid_t1} "
                 f"lane_cfg_valid@T+2={lane_cfg_valid_t2} "
                 f"lane_cfg_ready@T+1={lane_cfg_ready_t1} "
                 f"sdo_io_ready@T+1={sdo_io_ready_t1} "
                 f"word_ready_aligned_int@T+1={word_ready_aligned_int_t1}")

    assert idle_t1 == 1, "idle dropped before T+1 - CMD_WRITE unexpectedly cleared idle"
    assert t1_cycle == t_cycle + 1, "not back-to-back"
    assert lane_cfg_valid_t1 == 1, "lane_cfg_valid not asserted at T+1 as expected"
    assert t1_accepted, "transfer command was not accepted during T+1 - precondition broken"

    # ---- Do NOT supply any new sdo_data. Watch whether the engine drives
    # the stale word onto sdo anyway (transfer_active goes high with zero
    # new handshakes under next_mask). transfer_active/first_bit can both
    # already be true on THIS very edge (T+2, the edge that registers the
    # transfer's acceptance) since clk_div=0 and first_bit/trigger carry
    # over from the idle state - so the check must include this edge, not
    # start one edge later (an earlier version of this test missed the
    # load event entirely by starting its watch loop one cycle too late).
    new_handshakes = 0
    leaked = None

    def _check_leak(cycle):
        if int(dut.transfer_active.value) == 1 and int(dut.trigger_tx.value) == 1 \
                and int(dut.first_bit.value) == 1:
            # data_sdo_shift[0] is loaded combinationally from this source on
            # this edge; read the source value directly rather than the
            # register (which only reflects it after the edge completes).
            v = int(dut.shiftreg.aligned_sdo_data.value) & 0xFF
            tb.log.info(f"[T1-DIRECTED] first_bit loaded at cycle {cycle} "
                         f"with ZERO new-mask handshakes observed so far "
                         f"(new_handshakes={new_handshakes}); "
                         f"lane0 load source aligned_sdo_data[7:0]=0x{v:02x} "
                         f"(stale lane0 value was 0x{STALE_LO:02x})")
            return v
        return None

    leaked = _check_leak(t2_cycle)
    await NextTimeStep()
    dut.cmd_valid.value = 0
    dut.sdo_data_valid.value = 0

    if leaked is None:
        for cyc in range(200):
            await RisingEdge(dut.clk)
            await ReadOnly()
            if int(dut.sdo_data_ready.value) == 1 and int(dut.sdo_data_valid.value) == 1:
                new_handshakes += 1
            leaked = _check_leak(tb.now_cycles())
            if leaked is not None:
                break

    tb.log.info(f"[T1-DIRECTED] RESULT: leaked_lane0_source={leaked!r} "
                 f"new_handshakes_before_load={new_handshakes} "
                 f"stale_match={leaked == STALE_LO if leaked is not None else None}")

    # The leak verdict: on baseline RTL the stale word is loaded with zero
    # new-mask handshakes consumed (leak); on fixed RTL either no load is
    # observed within the window (transfer stalls waiting for fresh data)
    # or a new handshake occurs first.
    if leaked is not None and new_handshakes == 0:
        assert leaked != STALE_LO, (
            f"STALE DATA LEAK CONFIRMED: new transfer drove lane0 from "
            f"aligned_sdo_data=0x{leaked:02x} (== old-mask stale value "
            f"0x{STALE_LO:02x}) at T+1, with zero new-mask sdo_data "
            f"handshakes consumed.")


@cocotb.test()
async def test_lane_reconfig_inflight_word_flushed(dut):
    """EXEC-LANE-05/06: a word whose SDO handshake completes just before a
    lane-mask write takes effect is discarded, not driven under the new mask.

    Offload mode with the SDO source under TB control: one SDO word is
    handshaken `off` cycles around the cycle the lane-mask write is presented
    (off = -1..2 relative to that cycle; the write takes effect one cycle
    later, so off=-1 and off=0 land one and two cycles before it, i.e. the word
    is still in the assembler's readiness pipeline when the mask changes; off=1
    and off=2 are refused by the engine). After the change no SDO data is
    offered; the following transfer must not start (SCLK stays idle) until a
    fresh word is supplied, and then must drive exactly the fresh words.
    """
    tb = ExecutionTB(dut)
    await tb.start()

    wl = tb.params["DATA_WIDTH"]
    nsd = tb.num_sdio
    allcs = (1 << tb.params["NUM_OF_CS"]) - 1
    prev_mask = 0b1
    next_mask = 1 << (nsd - 1)
    cmd_cfg = ins.config_sdo_lane_mask(next_mask)
    rng = tb.rc.derive("inflight_flush")

    for off in (-1, 0, 1, 2):
        # Fresh reset per point: a failed point cannot corrupt the next.
        await apply_reset(dut, cycles_before=0, hold=3)
        tb.after_reset()

        await tb.issue(ins.chipselect(allcs, delay=1))
        await tb.wait_idle()
        await tb.issue(ins.config_sdo_lane_mask(prev_mask))
        await tb.wait_idle()
        await ClockCycles(dut.clk, nsd + 4)  # lane scan settle margin

        # ---- present the write at cycle 0, one SDO beat at cycle `off` ----
        tb.apply_cmd(cmd_cfg)  # golden model only
        tb.set_offload_active(True)
        stale = rng.randrange(1, 1 << wl)
        dut.sdo_data.value = stale
        handshaken = False
        await RisingEdge(dut.clk)
        for c in range(-1, 4):
            dut.cmd_valid.value = 1 if c == 0 else 0
            dut.cmd.value = cmd_cfg
            dut.sdo_data_valid.value = 1 if c == off else 0
            await ReadOnly()
            if c == off and int(dut.sdo_data_ready.value) == 1:
                handshaken = True
            await RisingEdge(dut.clk)
        dut.cmd_valid.value = 0
        dut.sdo_data_valid.value = 0
        tb.set_offload_active(False)
        if off <= 0:
            assert handshaken, f"off={off}: in-flight word was not handshaken"
        await tb.wait_idle()
        await ClockCycles(dut.clk, nsd + 8)  # lane scan + pipeline drain

        # ---- following transfer, no fresh data yet ----
        tb.bus_mon.words.clear()
        fresh = [rng.randrange(1 << wl) for _ in range(1)]
        res = await tb.issue(ins.transfer(0, write=True, read=False),
                             sdo_data=fresh)
        sclk0 = int(dut.sclk.value)
        for _ in range(40):
            await RisingEdge(dut.clk)
            # REQ: EXEC-LANE-05 - the pre-change word is not driven; engine waits
            assert int(dut.sclk.value) == sclk0, (
                f"off={off}: transfer started on the pre-change word "
                f"(0x{stale:02x}) with no fresh SDO word offered")
        tb.start_sdo_stream(res.sdo_words)
        await tb.wait_idle()
        await ClockCycles(dut.clk, 3)
        # REQ: EXEC-LANE-06 - only fresh words are driven under the new mask
        tb.sb.compare_sequences(res.sdo_words, tb.bus_mon.sdo_words,
                                field=f"inflight_flush_off{off}")
        tb.abort_streams()
    tb.sb.assert_no_errors()
