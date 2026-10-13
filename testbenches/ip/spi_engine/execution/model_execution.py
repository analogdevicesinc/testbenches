"""Python golden model for spi_engine_execution (hybrid fidelity).

This model is an *independent* reimplementation of the SPI Engine execution
semantics from the specification / RTL behaviour, deliberately expressed at the
transaction level (words, not pipeline registers) so it does not merely restate
the Verilog. It predicts:

  * data correctness: SDO words shifted out, SDI words captured, CS state,
    SYNC events, configuration register state
  * cycle-count timing for the timing-sensitive features, via closed-form
    formulas checked with a ±tolerance to absorb pipeline latency

What it intentionally does NOT model: internal pipeline register values, exact
bit_counter / clk_div_counter states, data-assembler pipeline stages. ECHO_SCLK
is out of scope (ECHO_SCLK=0 only), as is SDI_DELAY (fixed 0 this revision; see
EXEC-SDI-05 / FLAG EXEC-F5). The ``s_offload_active`` input changes only SDO
prefetch *readiness timing*, not data or waveform (EXEC-OFF-03), so it needs no
model branch — offload and FIFO mode share this same prediction.

Timing formulas (sclk_period = (clk_div+1)*2 core clocks):

  * SCLK period           : (div+1)*2
  * transfer duration     : ~ 2 + n_words * word_length * (div+1)*2
  * CS delay (before)     : 2 + t * (div+1)*2   (t = cmd[9:8])
  * CS delay (after)      :     t * (div+1)*2
  * sleep duration        : 2 + (t+1) * (div+1)*2   (t = cmd[7:0])
"""

from __future__ import annotations

from dataclasses import dataclass, field

from framework.spi import instructions as ins


# ----------------------------------------------------------------------------
# Predicted output records
# ----------------------------------------------------------------------------
@dataclass
class TransferResult:
    # Multi-lane note (NUM_OF_SDIO > 1): SDO/SDI words are flat lists in
    # *period-major, lane-minor* order. With L active lanes and n SPI periods,
    # each list holds n*L words: index (p*L + l) is the word on lane l during
    # period p. At L=1 this is just one word per period, identical to the
    # single-lane case, so the same tests cover both. The single input stream is
    # distributed round-robin across the active lanes (default mask = all lanes).
    sdo_words: list           # words the DUT should drive on SDO (write side)
    sdi_words: list           # words the DUT should capture on SDI (read side)
    n_words: int              # number of SPI periods (cmd[7:0]+1)
    word_length: int
    write: bool
    read: bool
    n_lanes_sdo: int = 1      # active SDO lanes (popcount of sdo_lane_mask)
    n_lanes_sdi: int = 1      # active SDI lanes (popcount of sdi_lane_mask)


@dataclass
class SyncEvent:
    sync_id: int


@dataclass
class CSEvent:
    cs_value: int             # value driven onto cs[] (post inv-mask XOR)


@dataclass
class ModelOutputs:
    transfers: list = field(default_factory=list)
    syncs: list = field(default_factory=list)
    cs_events: list = field(default_factory=list)
    sleeps: list = field(default_factory=list)        # predicted durations
    cs_delays: list = field(default_factory=list)     # predicted durations


class ExecutionModel:
    """Mirrors the engine's configuration state and predicts I/O per command."""

    def __init__(self, params):
        self.data_width = params["DATA_WIDTH"]
        self.num_cs = params["NUM_OF_CS"]
        self.num_sdio = params["NUM_OF_SDIO"]
        cfg = params["DEFAULT_SPI_CFG"]
        self.cpha = cfg & 1
        self.cpol = (cfg >> 1) & 1
        self.three_wire = (cfg >> 2) & 1
        self.sdo_idle_state = params.get("SDO_DEFAULT", 0)
        self.clk_div = params["DEFAULT_CLK_DIV"]
        self.word_length = self.data_width
        all_lanes = (1 << self.num_sdio) - 1
        self.sdi_lane_mask = all_lanes
        self.sdo_lane_mask = all_lanes
        self.cs_inv_mask = 0
        self.cs_state = (1 << self.num_cs) - 1   # reset: all deasserted

        self.outputs = ModelOutputs()

    # ---- timing helpers -------------------------------------------------
    @property
    def sclk_period(self):
        return (self.clk_div + 1) * 2

    def transfer_duration(self, n_words):
        return 2 + n_words * self.word_length * self.sclk_period

    def sleep_duration(self, t):
        return 2 + (t + 1) * self.sclk_period

    def cs_delay_before(self, t):
        return 2 + t * self.sclk_period

    def cs_delay_after(self, t):
        return t * self.sclk_period

    # ---- command application -------------------------------------------
    def apply(self, cmd, *, sdo_data=None, sdi_data=None):
        """Apply one 16-bit command, updating state and predicted outputs.

        ``sdo_data`` : list of words supplied on the SDO stream (write side)
        ``sdi_data`` : list of words the slave will return (read side)
        """
        inst = (cmd >> 12) & 0b111
        if inst == ins.CMD_TRANSFER:
            return self._transfer(cmd, sdo_data or [], sdi_data or [])
        if inst == ins.CMD_CHIPSELECT:
            return self._chipselect(cmd)
        if inst == ins.CMD_WRITE:
            return self._write_reg(cmd)
        if inst == ins.CMD_MISC:
            return self._misc(cmd)
        if inst == ins.CMD_CS_INV:
            self.cs_inv_mask = cmd & ((1 << self.num_cs) - 1)
            return None
        raise ValueError(f"unknown instruction in cmd 0x{cmd:04x}")

    @staticmethod
    def _popcount(mask):
        return bin(mask).count("1")

    def _transfer(self, cmd, sdo_data, sdi_data):
        write = bool((cmd >> 8) & 1)
        read = bool((cmd >> 9) & 1)
        n_periods = (cmd & 0xFF) + 1
        mask = (1 << self.word_length) - 1

        # Active lane counts come from the lane masks (default: all lanes). The
        # engine drives/captures one word per active lane each SPI period, so a
        # transfer of n_periods moves n_periods * n_lanes words on that side.
        n_lanes_sdo = max(1, self._popcount(self.sdo_lane_mask & ((1 << self.num_sdio) - 1)))
        n_lanes_sdi = max(1, self._popcount(self.sdi_lane_mask & ((1 << self.num_sdio) - 1)))

        # Flat period-major, lane-minor expectations (see TransferResult docs).
        # The single sdo_data stream is consumed in order and distributed
        # round-robin across active lanes; SDI is supplied the same way.
        sdo_words = []
        if write:
            total = n_periods * n_lanes_sdo
            for i in range(total):
                w = sdo_data[i] if i < len(sdo_data) else 0
                sdo_words.append(w & mask)

        sdi_words = []
        if read:
            total = n_periods * n_lanes_sdi
            for i in range(total):
                w = sdi_data[i] if i < len(sdi_data) else 0
                sdi_words.append(w & mask)

        res = TransferResult(sdo_words, sdi_words, n_periods,
                             self.word_length, write, read,
                             n_lanes_sdo=n_lanes_sdo, n_lanes_sdi=n_lanes_sdi)
        self.outputs.transfers.append(res)
        return res

    def _chipselect(self, cmd):
        delay = (cmd >> 8) & 0b11
        cs_bits = cmd & ((1 << self.num_cs) - 1)
        # cs <= cmd[NUM_OF_CS-1:0] ^ cs_inv_mask
        self.cs_state = cs_bits ^ self.cs_inv_mask
        ev = CSEvent(self.cs_state)
        self.outputs.cs_events.append(ev)
        if delay == 0:
            self.outputs.cs_delays.append(0)          # early-exit, no delay
        else:
            self.outputs.cs_delays.append(self.cs_delay_before(delay))
        return ev

    def _write_reg(self, cmd):
        reg = (cmd >> 8) & 0b111
        val = cmd & 0xFF
        if reg == ins.REG_CLK_DIV:
            self.clk_div = val
        elif reg == ins.REG_CONFIG:
            self.cpha = val & 1
            self.cpol = (val >> 1) & 1
            self.three_wire = (val >> 2) & 1
            self.sdo_idle_state = (val >> 3) & 1
        elif reg == ins.REG_WORD_LENGTH:
            self.word_length = val
        elif reg == ins.REG_SDI_LANE_CONFIG:
            self.sdi_lane_mask = val
        elif reg == ins.REG_SDO_LANE_CONFIG:
            self.sdo_lane_mask = val
        return None

    def _misc(self, cmd):
        sub = (cmd >> 8) & 1
        t = cmd & 0xFF
        if sub == ins.MISC_SYNC:
            ev = SyncEvent(t)
            self.outputs.syncs.append(ev)
            return ev
        # MISC_SLEEP
        self.outputs.sleeps.append(self.sleep_duration(t))
        return self.outputs.sleeps[-1]
