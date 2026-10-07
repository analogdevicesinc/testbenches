"""SPI slave bus-functional model: drives SDI (MISO) in response to the bus.

Shifts response words out on SDI, MSB-first. Response data can be a fixed queue,
random, or an echo of the observed SDO.

Two driving strategies are supported:

  * **SCLK-edge** (default): advance the bit on the SCLK edge *opposite* the
    master's sampling edge, so data is stable when the DUT latches it. This is
    fully black-box but assumes one SDI bit per visible SCLK period — which the
    DUT violates during a backpressure stall, where it parks transfer_active low
    yet still toggles SCLK a couple of phantom edges before resuming.

  * **strobe** (recommended for this DUT): advance the bit on the DUT's actual
    SDI sample strobe ``trigger_rx_s`` in the shiftreg submodule. The DUT shifts
    SDI on exactly this strobe, so following it keeps the slave in perfect
    lock-step across stalls and word boundaries. This is a white-box hook, which
    is appropriate for a unit testbench of this very module.
"""

from __future__ import annotations

import cocotb
from cocotb.triggers import RisingEdge, FallingEdge, Edge


class SPISlaveModel:
    MODE_QUEUE = "queue"
    MODE_RANDOM = "random"
    MODE_ECHO = "echo"

    def __init__(self, dut, *, cpol=0, cpha=0, word_length=8, num_sdio=1,
                 mode="queue", responses=None, rng=None, gate_signal=None,
                 sample_strobe=None, name="spi_slave"):
        self.dut = dut
        self.clk = dut.clk
        self.sclk = dut.sclk
        self.sdo = dut.sdo
        self.sdi = dut.sdi
        self.cs = dut.cs
        # Activity gate (transfer_active): bits only advance while a transfer is
        # in progress, so stalls/word boundaries cannot desync the slave.
        self.gate = gate_signal
        # Optional DUT SDI sample strobe (trigger_rx_s). When provided, the slave
        # advances on this strobe instead of counting SCLK edges — robust under
        # backpressure. The bit presented before the *first* strobe is the MSB.
        self.sample_strobe = sample_strobe
        self.cpol = cpol
        self.cpha = cpha
        self.word_length = word_length
        self.num_sdio = num_sdio
        self.mode = mode
        self.rng = rng
        self.name = name
        # Single flat response queue, consumed period-major / active-lane-minor:
        # for L active lanes, the first L words populate period 0 (lane order
        # ascending), the next L populate period 1, etc. At L=1 this is just one
        # word per period — identical to the original single-lane queue.
        self._responses = list(responses or [])
        # Active SDI lanes (default: all). Words map only onto these lanes;
        # inactive lanes are driven to 0.
        all_lanes = (1 << num_sdio) - 1
        self.sdi_lane_mask = all_lanes
        self._task = None
        self.sdi.value = 0

    def _active_lanes(self):
        return [l for l in range(self.num_sdio)
                if (self.sdi_lane_mask >> l) & 1]

    def configure(self, *, cpol=None, cpha=None, word_length=None,
                  sdi_lane_mask=None):
        if cpol is not None:
            self.cpol = cpol
        if cpha is not None:
            self.cpha = cpha
        if word_length is not None:
            self.word_length = word_length
        if sdi_lane_mask is not None:
            self.sdi_lane_mask = sdi_lane_mask

    def load(self, responses):
        self._responses = list(responses)

    def start(self):
        if self._task is None:
            self._task = cocotb.start_soon(self._run())
        return self._task

    def stop(self):
        if self._task is not None:
            self._task.kill()
            self._task = None
        self.sdi.value = 0

    def _sample_edge_is_rising(self):
        leading_is_rising = (self.cpol == 0)
        if self.cpha == 0:
            return leading_is_rising
        return not leading_is_rising

    def _next_word(self):
        """Pop the next response word for a single lane."""
        if self.mode == self.MODE_RANDOM and self.rng is not None:
            return self.rng.randrange(1 << self.word_length)
        if self.mode == self.MODE_ECHO:
            return None  # echo handled inline from observed SDO
        if self._responses:
            return self._responses.pop(0)
        return 0

    def _next_period_words(self):
        """Return {physical_lane: word} for one SPI period across active lanes.

        Consumes the response queue in ascending active-lane order, so the flat
        queue is laid out period-major / lane-minor (see __init__).
        """
        words = {}
        for lane in self._active_lanes():
            w = self._next_word()
            words[lane] = 0 if w is None else w
        return words

    def _drive_lanes(self, lane_words, bit_idx):
        """Present bit ``bit_idx`` (MSB-first) of each lane's word on sdi[]."""
        if self.num_sdio > 1:
            lanes = 0
            for lane, value in lane_words.items():
                bit = (value >> (self.word_length - 1 - bit_idx)) & 1
                lanes |= (bit << lane)
            self.sdi.value = lanes
        else:
            # Single lane: lane 0 word (or 0 if inactive/empty).
            value = lane_words.get(0, 0)
            bit = (value >> (self.word_length - 1 - bit_idx)) & 1
            self.sdi.value = bit

    def _active(self):
        if self.gate is None:
            return True
        try:
            return int(self.gate.value) == 1
        except ValueError:
            return False

    async def _run(self):
        if self.sample_strobe is not None:
            await self._run_strobe()
        else:
            await self._run_sclk_edge()

    async def _run_sclk_edge(self):
        # Edge-driven slave: present a bit, then advance on the master's "change"
        # edge (the edge opposite its sampling edge) so the next bit is stable
        # before the DUT samples. Awaiting the SCLK edge directly (rather than
        # polling the core clock) reacts within the same delta, which matters at
        # clk_div=0 where SCLK toggles every core clock and a one-cycle BFM lag
        # would shift the data by a full half-period.
        while True:
            lane_words = self._next_period_words()
            for bit_idx in range(self.word_length):
                self._drive_lanes(lane_words, bit_idx)
                if not self._sample_edge_is_rising():
                    await RisingEdge(self.sclk)
                else:
                    await FallingEdge(self.sclk)

    async def _run_strobe(self):
        # Strobe-driven slave: present the MSB, then on each DUT SDI sample strobe
        # (trigger_rx_s) advance to the next bit. Because the DUT shifts SDI on
        # exactly this strobe, the slave stays in lock-step regardless of stalls,
        # word boundaries or backpressure. We update SDI on the core clock edge
        # *after* the strobe so the new bit is stable before the next strobe.
        lane_words = self._next_period_words()
        bit_idx = 0
        self._drive_lanes(lane_words, bit_idx)
        while True:
            await RisingEdge(self.clk)
            try:
                strobe = int(self.sample_strobe.value)
            except ValueError:
                continue
            if strobe != 1:
                continue
            # DUT just latched the currently-presented bit; advance.
            bit_idx += 1
            if bit_idx >= self.word_length:
                lane_words = self._next_period_words()
                bit_idx = 0
            self._drive_lanes(lane_words, bit_idx)
