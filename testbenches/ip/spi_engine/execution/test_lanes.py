"""Multi-lane transmit (NUM_OF_SDIO>1), and EXEC-CC-08.

Only SDO lanes are boundary-visible in this module (the SDI lane mask's effect is
downstream — its acceptance is covered in test_config). These tests drive
the SDO lane-mask register and confirm words map to the correct physical lanes:
all-active, sparse (e.g. 1010), single-lane, and re-masking between transfers.

At NUM_OF_SDIO=1 the mask cases degenerate to the single-lane write path, which
still exercises the all-active mask and the register-accept path.

Each test sweeps word_length over {1, DATA_WIDTH//2, DATA_WIDTH}; clk_div stays at
its reset default (swept in test_config.py and test_waveform.py).
"""

import cocotb
from cocotb.triggers import RisingEdge, ClockCycles

from framework.spi import instructions as ins
from tb_env import ExecutionTB


def _wl_sweep(dw):
    """Word lengths swept by every test: min, mid, full."""
    return sorted({1, max(1, dw // 2), dw})


async def _set_wl_and_deselect(tb, wl):
    """Deselect CS (clears any previous transfer) and program word_length."""
    allcs = (1 << tb.params["NUM_OF_CS"]) - 1
    await tb.issue(ins.chipselect(allcs, delay=1))
    await tb.wait_idle()
    await tb.issue(ins.config_word_length(wl))
    await tb.wait_idle()
    tb.bus_mon.words.clear()


@cocotb.test()
async def test_all_lanes_active(dut):
    """Default all-active mask distributes words across every lane."""
    tb = ExecutionTB(dut)
    await tb.start()
    nsd = tb.num_sdio
    rng = tb.rc.derive("lanes_all")

    all_mask = (1 << nsd) - 1
    await tb.issue(ins.config_sdo_lane_mask(all_mask))
    await tb.wait_idle()
    for wl in _wl_sweep(tb.params["DATA_WIDTH"]):
        await _set_wl_and_deselect(tb, wl)
        nper = rng.randint(2, 6)
        data = [rng.randrange(1 << wl) for _ in range(nper * nsd)]
        res = await tb.run_transfer(n=nper, write=True, read=False, sdo_words=data)
        # REQ: EXEC-LANE-01 - active lanes carry data in ascending physical order
        # REQ: EXEC-CFG-05 - SDO lane-mask register selects transmit lanes
        # REQ: EXEC-PARAM-02 - NUM_OF_SDIO sizes the sdo/sdi lanes
        tb.sb.compare_sequences(res.sdo_words, tb.bus_mon.sdo_words,
                                field=f"sdo_all_wl{wl}")
    tb.sb.assert_no_errors()


@cocotb.test()
async def test_sparse_and_single_lane_masks(dut):
    """Sparse (1010-style) and single-lane masks map to the right lanes.

    RTL-CHARACTERIZED for the exact distribution order; Linux drives only the
    masks its lane_map produces, not arbitrary sparse patterns (spec Appendix C),
    so the sparse case is a characterization lock. Inactive lanes carry
    sdo_idle_state (EXEC-LANE-02).
    """
    tb = ExecutionTB(dut)
    await tb.start()
    nsd = tb.num_sdio
    rng = tb.rc.derive("lanes_sparse")

    if nsd < 2:
        # Single physical lane: only the trivial mask exists; verify it accepts
        # and transfers, which is the degenerate LANE case.
        await tb.issue(ins.config_sdo_lane_mask(1))
        await tb.wait_idle()
        for wl in _wl_sweep(tb.params["DATA_WIDTH"]):
            await _set_wl_and_deselect(tb, wl)
            data = [rng.randrange(1 << wl) for _ in range(2)]
            res = await tb.run_transfer(n=2, write=True, read=False, sdo_words=data)
            # (LANE-03 single-lane degenerate case; tag lives on the sparse path below)
            tb.sb.compare_sequences(res.sdo_words, tb.bus_mon.sdo_words,
                                    field=f"sdo_1lane_wl{wl}")
        tb.sb.assert_no_errors()
        return

    # Sparse mask: lane 0 and the top lane (10..01). Interior lanes idle only for
    # nsd>=3; at nsd=2 it degenerates to 0b11 (all-active), which harmlessly
    # re-covers the all-active routing path here.
    sparse = 1 | (1 << (nsd - 1))
    n_active = bin(sparse).count("1")
    await tb.issue(ins.config_sdo_lane_mask(sparse))
    await tb.wait_idle()
    for wl in _wl_sweep(tb.params["DATA_WIDTH"]):
        await _set_wl_and_deselect(tb, wl)
        nper = rng.randint(2, 6)
        data = [rng.randrange(1 << wl) for _ in range(nper * n_active)]
        res = await tb.run_transfer(n=nper, write=True, read=False, sdo_words=data)
        # REQ: EXEC-LANE-03 - sparse mask maps words to correct physical lanes
        tb.sb.compare_sequences(res.sdo_words, tb.bus_mon.sdo_words,
                                field=f"sdo_sparse_0x{sparse:x}_wl{wl}")

        # Idle lanes present sdo_idle_state (checked between transfers on the bus).
        idle = tb.params.get("SDO_DEFAULT", 0)
        await ClockCycles(dut.clk, 3)
        # REQ: EXEC-LANE-02 - lanes with mask bit 0 present sdo_idle_state
        idle_lanes_ok = True
        val = int(dut.sdo.value)
        for l in range(nsd):
            if not ((sparse >> l) & 1):
                if ((val >> l) & 1) != idle:
                    idle_lanes_ok = False
        tb.sb.compare(0, f"sdo_idle_lanes_wl{wl}", True, idle_lanes_ok)
    tb.sb.assert_no_errors()


@cocotb.test()
async def test_lane_remask_between_transfers(dut):
    """Re-writing the SDO lane mask remaps lanes on the next transfer."""
    tb = ExecutionTB(dut)
    await tb.start()
    nsd = tb.num_sdio
    rng = tb.rc.derive("lanes_remask")

    if nsd < 2:
        return  # remasking is only meaningful with more than one lane

    all_mask = (1 << nsd) - 1
    # At nsd=2 this is 0b11 (== all_mask): the re-mask step below then re-applies
    # the same all-active set, so remapping is only genuinely exercised for
    # nsd>=3. Harmless (the compare still holds), but the remap is a no-op at nsd=2.
    sparse = 1 | (1 << (nsd - 1))
    n_active = bin(sparse).count("1")

    for wl in _wl_sweep(tb.params["DATA_WIDTH"]):
        # First transfer: all lanes.
        await tb.issue(ins.config_sdo_lane_mask(all_mask))
        await tb.wait_idle()
        await _set_wl_and_deselect(tb, wl)
        d1 = [rng.randrange(1 << wl) for _ in range(2 * nsd)]
        res1 = await tb.run_transfer(n=2, write=True, read=False, sdo_words=d1)
        tb.sb.compare_sequences(res1.sdo_words, tb.bus_mon.sdo_words,
                                field=f"remask_all_wl{wl}")

        # Re-mask to sparse; next transfer must use the new lane set.
        await _set_wl_and_deselect(tb, wl)
        await tb.issue(ins.config_sdo_lane_mask(sparse))
        await tb.wait_idle()
        d2 = [rng.randrange(1 << wl) for _ in range(2 * n_active)]
        res2 = await tb.run_transfer(n=2, write=True, read=False, sdo_words=d2)
        # REQ: EXEC-LANE-04 - re-writing the SDO mask remaps lanes next transfer
        # REQ: EXEC-CC-08 - lane-mask reconfiguration remaps lanes on next transfer
        tb.sb.compare_sequences(res2.sdo_words, tb.bus_mon.sdo_words,
                                field=f"remask_sparse_wl{wl}")
    tb.sb.assert_no_errors()
