"""Random reset injection and reset-value checking.

:class:`RandomResetInjector` asserts ``resetn`` at random points to verify the
DUT recovers cleanly, then checks the documented reset values once reset
deasserts. :func:`apply_reset` is the simple deterministic helper used by most
tests for the initial bring-up.

Documented reset values for spi_engine_execution (active-low resetn):
    cs        = all ones  ((1<<NUM_OF_CS)-1)
    sclk      = cpol      (DEFAULT_SPI_CFG[1] after reset)
    idle      = 1         (=> cmd_ready == 1)
    sdo_t     = 1
    sync_valid= 0
"""

from __future__ import annotations

import cocotb
from cocotb.triggers import RisingEdge, ClockCycles


async def apply_reset(dut, *, cycles_before=5, hold=5):
    """Deterministic active-low reset pulse; leaves resetn high on return."""
    dut.resetn.value = 1
    await ClockCycles(dut.clk, cycles_before)
    dut.resetn.value = 0
    await ClockCycles(dut.clk, hold)
    dut.resetn.value = 1
    await RisingEdge(dut.clk)


def check_reset_values(dut, params, *, scoreboard=None, index=-1):
    """Check DUT outputs against documented reset values. Returns list of errs."""
    cpol = (params["DEFAULT_SPI_CFG"] >> 1) & 1
    expected_cs = (1 << params["NUM_OF_CS"]) - 1
    checks = [
        ("cs", int(dut.cs.value), expected_cs),
        ("sync_valid", int(dut.sync_valid.value), 0),
        ("cmd_ready", int(dut.cmd_ready.value), 1),
        ("sdo_t", int(dut.sdo_t.value), 1),
        ("sclk", int(dut.sclk.value), cpol),
    ]
    errs = []
    for name, actual, expected in checks:
        if scoreboard is not None:
            scoreboard.compare(index, f"reset.{name}", expected, actual)
        if actual != expected:
            errs.append(f"{name}={actual} expected {expected}")
    return errs


class RandomResetInjector:
    """Periodically asserts reset at random intervals during a test.

    Parameters
    ----------
    dut, rng     : DUT handle and a seeded random.Random
    min_interval, max_interval : clock cycles between resets
    hold         : cycles to hold reset low
    on_reset     : optional callback invoked after each reset deasserts
    """

    def __init__(self, dut, rng, *, min_interval=50, max_interval=200,
                 hold=3, on_reset=None, name="reset_inj"):
        self.dut = dut
        self.rng = rng
        self.min_interval = min_interval
        self.max_interval = max_interval
        self.hold = hold
        self.on_reset = on_reset
        self.name = name
        self.count = 0
        self._task = None

    def start(self):
        if self._task is None:
            self._task = cocotb.start_soon(self._run())
        return self._task

    def stop(self):
        if self._task is not None:
            self._task.kill()
            self._task = None

    async def _run(self):
        while True:
            wait = self.rng.randint(self.min_interval, self.max_interval)
            await ClockCycles(self.dut.clk, wait)
            self.dut.resetn.value = 0
            await ClockCycles(self.dut.clk, self.hold)
            self.dut.resetn.value = 1
            await RisingEdge(self.dut.clk)
            self.count += 1
            if self.on_reset is not None:
                self.on_reset(self.count)
