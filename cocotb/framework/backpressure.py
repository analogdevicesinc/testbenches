"""Random *ready toggling to exercise flow control / backpressure.

A :class:`RandomBackpressure` coroutine drives a single ``ready`` handle with a
chosen pattern. All randomness comes from an injected ``random.Random`` so runs
are reproducible from the master seed (see :mod:`framework.random_ctx`).

Applied to the consumer-side ready signals of spi_engine_execution:
``sdi_data_ready`` and ``sync_ready``. (``sdo_data_ready`` and ``cmd_ready`` are
DUT *outputs*; backpressure on those streams is applied by gating the driver's
valid instead — see ``AXIStreamDriver`` gaps.)
"""

from __future__ import annotations

import cocotb
from cocotb.triggers import RisingEdge


class RandomBackpressure:
    def __init__(self, clk, ready, rng, *, name="bp"):
        self.clk = clk
        self.ready = ready
        self.rng = rng
        self.name = name
        self._task = None
        self.ready.value = 1

    # ---- strategies (each is a long-running coroutine) ------------------
    async def _uniform(self, duty_cycle):
        while True:
            self.ready.value = 1 if self.rng.random() < duty_cycle else 0
            await RisingEdge(self.clk)

    async def _burst(self, min_on, max_on, min_off, max_off):
        while True:
            on = self.rng.randint(min_on, max_on)
            for _ in range(on):
                self.ready.value = 1
                await RisingEdge(self.clk)
            off = self.rng.randint(min_off, max_off)
            for _ in range(off):
                self.ready.value = 0
                await RisingEdge(self.clk)

    async def _always(self):
        self.ready.value = 1
        while True:
            await RisingEdge(self.clk)

    # ---- control --------------------------------------------------------
    def start_uniform(self, duty_cycle=0.5):
        return self._start(self._uniform(duty_cycle))

    def start_burst(self, min_on=1, max_on=4, min_off=1, max_off=4):
        return self._start(self._burst(min_on, max_on, min_off, max_off))

    def start_always_ready(self):
        return self._start(self._always())

    def _start(self, coro):
        self.stop()
        self._task = cocotb.start_soon(coro)
        return self._task

    def stop(self, *, final_value=1):
        if self._task is not None:
            self._task.kill()
            self._task = None
        self.ready.value = final_value
