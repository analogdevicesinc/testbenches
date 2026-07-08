"""Passive SPI bus watcher.

Observes the SPI side of the DUT (SCLK / SDO / CS / SDI) and reconstructs the
words shifted out on SDO, sampling on the active SCLK edge implied by CPOL/CPHA.
Purely observational — it never drives a signal.

SPI mode -> sampling edge convention (mode = {CPOL, CPHA}):

  * CPHA=0: data sampled on the *leading* SCLK edge
  * CPHA=1: data sampled on the *trailing* SCLK edge

  with leading edge = rising when CPOL=0, falling when CPOL=1.

The DUT drives ``sdo`` one bit at a time, MSB first, and clocks ``word_length``
bits per word. Because the execution module registers sclk/sdo together, the
monitor follows the *output* SCLK rather than reconstructing it from the core
clock, which keeps it correct across prescaler settings.
"""

from __future__ import annotations

from dataclasses import dataclass, field

import cocotb
from cocotb.triggers import Edge, RisingEdge, FallingEdge
from cocotb.utils import get_sim_time


@dataclass
class SPIWord:
    sdo: int            # MOSI word on lane 0 (back-compat single-lane view)
    sdi_lanes: list     # captured SDI bit-stream per lane (ints), index = lane
    word_length: int
    timestamp: int
    sdo_lanes: list = None  # captured SDO bit-stream per lane (ints), index = lane


def _bit(handle, idx=None):
    try:
        v = handle.value
        if idx is None:
            return int(v)
        return (int(v) >> idx) & 1
    except ValueError:
        return -1


class SPIBusMonitor:
    """Reconstructs SDO words by sampling on the active SCLK edge.

    Parameters
    ----------
    dut          : DUT handle (uses dut.sclk, dut.sdo, dut.cs, dut.sdi)
    cpol, cpha   : SPI mode for choosing the sampling edge
    word_length  : bits per word (can be updated between transfers via attr)
    num_sdio     : number of SDIO lanes
    """

    def __init__(self, dut, *, cpol=0, cpha=0, word_length=8, num_sdio=1,
                 sdo_lane_mask=None, sdi_lane_mask=None,
                 gate_signal=None, name="spi_mon"):
        self.dut = dut
        self.log = dut._log
        self.clk = dut.clk
        self.sclk = dut.sclk
        self.sdo = dut.sdo
        self.cs = dut.cs
        self.sdi = dut.sdi
        # Warn-once guard so an X/Z coercion is flagged but does not flood the
        # log on every sampling edge of a persistently-unresolved signal.
        self._warned_x = set()
        # Optional activity gate: when provided, SCLK edges are only counted
        # while this signal is high. ``transfer_active`` precisely brackets the
        # bit-valid window and avoids phantom edges from CPOL idle settling.
        self.gate = gate_signal
        self.cpol = cpol
        self.cpha = cpha
        self.word_length = word_length
        self.num_sdio = num_sdio
        # Lane masks select which physical lanes carry data. Default: all lanes.
        all_lanes = (1 << num_sdio) - 1
        self.sdo_lane_mask = all_lanes if sdo_lane_mask is None else sdo_lane_mask
        self.sdi_lane_mask = all_lanes if sdi_lane_mask is None else sdi_lane_mask
        self.name = name
        self.words: list[SPIWord] = []
        self._task = None

    def configure(self, *, cpol=None, cpha=None, word_length=None,
                  sdo_lane_mask=None, sdi_lane_mask=None):
        if cpol is not None:
            self.cpol = cpol
        if cpha is not None:
            self.cpha = cpha
        if word_length is not None:
            self.word_length = word_length
        if sdo_lane_mask is not None:
            self.sdo_lane_mask = sdo_lane_mask
        if sdi_lane_mask is not None:
            self.sdi_lane_mask = sdi_lane_mask

    def _warn_x(self, what):
        """Warn once per (signal, lane) that an X/Z read was coerced to 0."""
        if what not in self._warned_x:
            self._warned_x.add(what)
            self.log.warning(
                f"{self.name}: {what} read X/Z during an active transfer; "
                f"coercing to 0 (further occurrences suppressed)")

    def _active_lanes(self, mask):
        """Physical lane indices set in ``mask``, ascending (= shift order)."""
        return [l for l in range(self.num_sdio) if (mask >> l) & 1]

    def start(self):
        if self._task is None:
            self._task = cocotb.start_soon(self._run())
        return self._task

    def stop(self):
        if self._task is not None:
            self._task.kill()
            self._task = None

    def flush(self):
        """Discard any partially-accumulated word and restart sampling.

        Call after an injected DUT reset so bits captured before the reset do
        not bleed into the next word.
        """
        was_running = self._task is not None
        self.stop()
        if was_running:
            self.start()

    def _sample_edge_is_rising(self):
        # leading edge rises when CPOL=0; CPHA=1 samples on the trailing edge.
        leading_is_rising = (self.cpol == 0)
        if self.cpha == 0:
            return leading_is_rising
        return not leading_is_rising

    def _active(self):
        """True if a transfer is in progress (gate high, or no gate set)."""
        if self.gate is None:
            return True
        try:
            return int(self.gate.value) == 1
        except ValueError:
            return False

    async def _run(self):
        # Clock-synchronous sampling: on every *core* clock edge all registered
        # DUT outputs (sclk, sdo) are settled, so we detect SCLK edges by
        # comparing successive samples. Awaiting RisingEdge(sclk) directly races
        # with the co-registered sdo update (both are clocked in the same always
        # block) and can latch the previous bit — this avoids that delta race.
        bits_sdo = [0] * self.num_sdio
        bits_sdi = [0] * self.num_sdio
        count = 0
        prev_sclk = _bit(self.sclk)
        if prev_sclk < 0:
            prev_sclk = self.cpol
        while True:
            await RisingEdge(self.clk)
            cur_sclk = _bit(self.sclk)
            if cur_sclk < 0:
                continue
            rising = (prev_sclk == 0 and cur_sclk == 1)
            falling = (prev_sclk == 1 and cur_sclk == 0)
            prev_sclk = cur_sclk

            is_sample_edge = rising if self._sample_edge_is_rising() else falling
            if not is_sample_edge:
                continue

            # A new word only *starts* while the gate is active, rejecting
            # phantom edges from CPOL idle settling between transfers; a word
            # already in progress always finishes.
            if count == 0 and not self._active():
                continue

            # Latch the word length at the *start* of each word so a length
            # change between transfers does not truncate the accumulator.
            if count == 0:
                wl = self.word_length
                mask = (1 << wl) - 1
            # Capture every physical lane on both SDO and SDI. Single-bit
            # signals (num_sdio==1) are read whole; vectors are indexed per lane.
            for lane in range(self.num_sdio):
                so = _bit(self.sdo, lane if self.num_sdio > 1 else None)
                if so < 0:
                    self._warn_x(f"sdo[{lane}]" if self.num_sdio > 1 else "sdo")
                    so = 0
                bits_sdo[lane] = ((bits_sdo[lane] << 1) | so) & mask
                si = _bit(self.sdi, lane if self.num_sdio > 1 else None)
                if si < 0:
                    self._warn_x(f"sdi[{lane}]" if self.num_sdio > 1 else "sdi")
                    si = 0
                bits_sdi[lane] = ((bits_sdi[lane] << 1) | si) & mask
            count += 1

            if count == wl:
                self.words.append(SPIWord(
                    sdo=bits_sdo[0],
                    sdi_lanes=list(bits_sdi),
                    sdo_lanes=list(bits_sdo),
                    word_length=wl,
                    timestamp=int(get_sim_time("ns")),
                ))
                bits_sdo = [0] * self.num_sdio
                bits_sdi = [0] * self.num_sdio
                count = 0

    @property
    def sdo_words(self):
        """Captured SDO words flattened period-major, active-lane-minor.

        For each captured SPI period, emit one word per *active* SDO lane in
        ascending lane order — matching the golden model's round-robin layout.
        At a single active lane this is just one word per period (the previous
        single-lane behaviour).
        """
        lanes = self._active_lanes(self.sdo_lane_mask)
        if self.num_sdio == 1 or not lanes:
            return [w.sdo for w in self.words]
        out = []
        for w in self.words:
            src = w.sdo_lanes if w.sdo_lanes is not None else [w.sdo]
            for l in lanes:
                out.append(src[l] if l < len(src) else 0)
        return out

    @property
    def sdi_words(self):
        """Captured SDI words flattened period-major, active-lane-minor."""
        lanes = self._active_lanes(self.sdi_lane_mask)
        if self.num_sdio == 1 or not lanes:
            return [w.sdi_lanes[0] for w in self.words]
        out = []
        for w in self.words:
            for l in lanes:
                out.append(w.sdi_lanes[l] if l < len(w.sdi_lanes) else 0)
        return out
