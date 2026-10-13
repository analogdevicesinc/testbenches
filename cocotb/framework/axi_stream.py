"""AXI-Stream driver and monitor (manager/subordinate handshake helpers).

Generic over signal names so the same classes drive the CMD stream, the SDO
data stream, and monitor the SDI/SYNC streams on the spi_engine_execution DUT.

The DUT exposes several lightweight valid/ready stream interfaces:

  * CMD:  ``cmd_valid`` / ``cmd_ready`` / ``cmd``            (driven, manager)
  * SDO:  ``sdo_data_valid`` / ``sdo_data_ready`` / ``sdo_data`` (driven)
  * SDI:  ``sdi_data_valid`` / ``sdi_data_ready`` / ``sdi_data`` (monitored)
  * SYNC: ``sync_valid`` / ``sync_ready`` / ``sync``         (monitored)

These are not strictly AXI-Stream (no TLAST/TKEEP) but follow the same
valid/ready semantics, so a single pair of helpers covers them all.
"""

from __future__ import annotations

from dataclasses import dataclass, field

import cocotb
from cocotb.triggers import RisingEdge, ReadOnly
from cocotb.utils import get_sim_time


def _resolve(dut, name):
    """Return the handle for ``name`` on ``dut`` or raise a clear error."""
    if not hasattr(dut, name):
        raise AttributeError(f"DUT has no signal '{name}'")
    return getattr(dut, name)


def _as_int(handle):
    """Read a handle as int, tolerating X/Z (returns -1 if unresolvable)."""
    val = handle.value
    try:
        return int(val)
    except ValueError:
        return -1


@dataclass
class StreamTransaction:
    """One observed/sent beat on a valid/ready stream."""

    data: int
    timestamp: int  # simulation time in ns at the accepting clock edge


class AXIStreamDriver:
    """Drives a valid/data stream, respecting downstream ready (manager side).

    Parameters
    ----------
    clk        : the clock handle the stream is synchronous to
    valid      : the *valid handle this driver asserts
    ready      : the *ready handle this driver samples
    data       : the *data handle this driver writes
    rng        : optional ``random.Random`` for inter-word gap jitter
    """

    def __init__(self, clk, valid, ready, data, *, rng=None, name="axis"):
        self.clk = clk
        self.valid = valid
        self.ready = ready
        self.data = data
        self.rng = rng
        self.name = name
        self.valid.value = 0

    @classmethod
    def from_dut(cls, dut, prefix, *, ready_signal=None, data_signal=None,
                 clk=None, **kwargs):
        """Build a driver from a DUT and a signal-name ``prefix``.

        e.g. prefix='cmd' -> cmd_valid/cmd_ready/cmd ; prefix='sdo_data' ->
        sdo_data_valid/sdo_data_ready/sdo_data.
        """
        clk = clk if clk is not None else _resolve(dut, "clk")
        valid = _resolve(dut, f"{prefix}_valid")
        ready = _resolve(dut, ready_signal or f"{prefix}_ready")
        data = _resolve(dut, data_signal or prefix)
        return cls(clk, valid, ready, data, name=prefix, **kwargs)

    async def send(self, value, *, gap=0):
        """Send a single word; block until accepted (valid && ready).

        ``gap`` idle cycles (valid deasserted) are inserted *before* the beat.
        """
        for _ in range(gap):
            self.valid.value = 0
            await RisingEdge(self.clk)
        self.data.value = int(value)
        self.valid.value = 1
        # Wait for a rising edge where ready was sampled high.
        while True:
            await ReadOnly()
            if self.ready.value == 1:
                await RisingEdge(self.clk)
                break
            await RisingEdge(self.clk)
        self.valid.value = 0

    async def send_queue(self, values, *, min_gap=0, max_gap=0):
        """Send a sequence of words with random inter-word gaps in range."""
        for v in values:
            if max_gap > 0 and self.rng is not None:
                gap = self.rng.randint(min_gap, max_gap)
            else:
                gap = min_gap
            await self.send(v, gap=gap)


class AXIStreamMonitor:
    """Passively records accepted beats (valid && ready) on a stream.

    Runs as a background coroutine started via :meth:`start`. Captured
    transactions land in :attr:`received` (a list of :class:`StreamTransaction`).
    """

    def __init__(self, clk, valid, ready, data, *, name="axis", callback=None):
        self.clk = clk
        self.valid = valid
        self.ready = ready
        self.data = data
        self.name = name
        self.callback = callback
        self.received: list[StreamTransaction] = []
        self._task = None

    @classmethod
    def from_dut(cls, dut, prefix, *, ready_signal=None, data_signal=None,
                 clk=None, **kwargs):
        clk = clk if clk is not None else _resolve(dut, "clk")
        valid = _resolve(dut, f"{prefix}_valid")
        ready = _resolve(dut, ready_signal or f"{prefix}_ready")
        data = _resolve(dut, data_signal or prefix)
        return cls(clk, valid, ready, data, name=prefix, **kwargs)

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
            await RisingEdge(self.clk)
            await ReadOnly()
            if self.valid.value == 1 and self.ready.value == 1:
                txn = StreamTransaction(
                    data=_as_int(self.data),
                    timestamp=int(get_sim_time("ns")),
                )
                self.received.append(txn)
                if self.callback is not None:
                    self.callback(txn)

    @property
    def values(self):
        return [t.data for t in self.received]
