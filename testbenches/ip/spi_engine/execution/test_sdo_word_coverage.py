"""SDO word framing, word count and word-length range, over the full domain.

Targets (all unconditional: every word_length 1..DATA_WIDTH, every clk_div,
every SPI mode, every lane count and active-lane mask):

  * EXEC-SDO-01 - each word appears on sdo MSB-first, word_length bits
  * EXEC-SDO-04 - exactly n+1 words are consumed from the SDO stream
  * EXEC-CC-03  - minimum and maximum word_length both work

Method. The expected wire stream is derived from the words fed into the SDO
stream and the requirement alone: active lanes take stream words in ascending
physical-lane order (EXEC-LANE-01), each word contributes its bits MSB-first
(bit word_length-1 first). The observed stream is captured by
`WireSampler` below: it samples every physical lane of `sdo` on each active
SCLK edge of the configured SPI mode, with no transfer gate and independently
of `framework.spi.bus_monitor`, so both a wrong bit count and wrong bits are
visible. The handshake count comes from a passive monitor on
`sdo_data_valid`/`sdo_data_ready`; tests supply exactly the expected words
(next-transfer fetch boundary: see test_sdo_fetch_boundary.py).

A hang (engine never returns to idle) is recorded as a mismatch and the DUT is
reset so the remaining parameter points still run.

Words are random multi-bit values (never periodic patterns), so a duplicated,
skipped or reordered word changes the compared sequence.

Not driven by this module (TB limitation, see README): none of ECHO_SCLK,
NUM_OF_SDIO, DATA_WIDTH, DEFAULT_SPI_CFG, SDO_DEFAULT is runtime-selectable;
they come from the build config, so run runner.py with the `--echo-sclk`,
`--num-of-sdio`, `--data-width` flags (or the full sweep) to cover them.
"""

import cocotb
from cocotb.triggers import (RisingEdge, ReadOnly, ClockCycles, with_timeout,
                             SimTimeoutError)

from framework.axi_stream import AXIStreamMonitor
from framework.reset import apply_reset
from framework.spi import instructions as ins
from tb_env import ExecutionTB, CLK_PERIOD_NS

MAX_CLK_DIV = 255          # clk_div register is 8 bits wide


# ---------------------------------------------------------------------------
# Wire-level observation, independent of the bus monitor
# ---------------------------------------------------------------------------
class WireSampler:
    """Raw `sdo` samples taken on each active SCLK edge while armed.

    Samples once per core clock (after the clock edge has settled) and detects
    SCLK edges by comparing consecutive samples. Collects the whole `sdo`
    vector per sample edge; the caller splits it into lanes. There is no
    transfer-active gate: the armed window is the caller's responsibility
    (armed after configuration has settled, disarmed after the engine is
    idle), and SCLK idles at CPOL outside transfers.
    """

    def __init__(self, dut):
        self.dut = dut
        self.cpol = 0
        self.cpha = 0
        self.armed = False
        self.samples = []
        self._task = None

    def start(self):
        if self._task is None:
            self._task = cocotb.start_soon(self._run())

    def arm(self, cpol, cpha):
        self.cpol, self.cpha = cpol, cpha
        self.samples = []
        self.armed = True

    def disarm(self):
        self.armed = False

    async def _run(self):
        dut = self.dut
        prev = None
        while True:
            await RisingEdge(dut.clk)
            await ReadOnly()
            try:
                cur = int(dut.sclk.value)
            except ValueError:
                continue
            if prev is not None and cur != prev:
                rising = cur == 1
                leading_rising = self.cpol == 0
                sample_rising = leading_rising if self.cpha == 0 else not leading_rising
                if self.armed and rising == sample_rising:
                    try:
                        self.samples.append(int(dut.sdo.value))
                    except ValueError:
                        self.samples.append(-1)
            prev = cur


# ---------------------------------------------------------------------------
# Domain helpers
# ---------------------------------------------------------------------------
def wl_points(dw):
    """word_length: minimum, small, mid, DATA_WIDTH-1 and maximum."""
    return sorted(w for w in {1, 2, 3, 5, dw // 2, dw - 1, dw} if 1 <= w <= dw)


DIV_POINTS = (0, 1, 2, 3, 7)


def active_lanes(mask, nsd):
    return [l for l in range(nsd) if (mask >> l) & 1]


def make_words(tb, tag, count, wl):
    """Random wl-bit words; never all-equal when more than one word."""
    rng = tb.rc.derive(tag)
    words = [rng.randrange(1 << wl) for _ in range(count)]
    if count > 1 and len(set(words)) == 1:
        words[-1] ^= 1
    return words


def words_from_samples(samples, wl, lanes):
    """Rebuild words from per-edge sdo vectors: period-major, lane-minor,
    first sampled bit = MSB. A trailing partial word is dropped."""
    out = []
    for p in range(len(samples) // wl):
        for l in lanes:
            v = 0
            for b in range(wl):
                smp = samples[p * wl + b]
                v = (v << 1) | (((smp >> l) & 1) if smp >= 0 else 0)
            out.append(v)
    return out


class Harness:
    """Per-test bundle: TB + wire sampler + SDO handshake counter."""

    def __init__(self, dut):
        self.tb = ExecutionTB(dut)
        self.dut = dut
        self.sampler = WireSampler(dut)
        self.hs = AXIStreamMonitor.from_dut(dut, "sdo_data")
        self._err_mark = 0
        self.spi_cfg = self.tb.params["DEFAULT_SPI_CFG"]
        self.nsd = self.tb.num_sdio
        self.dw = self.tb.params["DATA_WIDTH"]

    async def start(self):
        await self.tb.start()
        self.sampler.start()
        self.hs.start()

    async def recover(self):
        """Reset the DUT after a hang; the next point reprograms everything."""
        tb = self.tb
        self.sampler.disarm()
        tb.after_reset()
        await apply_reset(self.dut)
        tb.bp_sdi.start_always_ready()
        tb.bp_sync.start_always_ready()

    async def prepare(self, *, div, wl, mode=None, mask=None):
        """Program clk_div, SPI mode, word_length, SDO lane mask, assert CS.

        ``mode`` is (cpol, cpha); default is the build's DEFAULT_SPI_CFG mode.
        Returns (cpol, cpha, lanes) as programmed.
        """
        tb = self.tb
        # Isolate a failed point: reset, so one fault cannot corrupt the
        # points that follow (each point is judged on its own).
        if len(tb.sb.mismatches) > self._err_mark:
            await self.recover()
        self._err_mark = len(tb.sb.mismatches)
        cfg = self.spi_cfg
        cpol, cpha = mode if mode is not None else ((cfg >> 1) & 1, cfg & 1)
        await tb.issue(ins.config_clk_div(div))
        await tb.wait_idle()
        await tb.issue(ins.config_spi_mode(
            cpha=cpha, cpol=cpol, three_wire=(cfg >> 2) & 1,
            sdo_idle_state=tb.params["SDO_DEFAULT"]))
        await tb.wait_idle()
        await tb.issue(ins.config_word_length(wl))
        await tb.wait_idle()
        if self.nsd > 1:
            m = (1 << self.nsd) - 1 if mask is None else mask
            await tb.issue(ins.config_sdo_lane_mask(m))
            await tb.wait_idle()
        else:
            m = 1
        await tb.issue(ins.chipselect(0, delay=1))
        await tb.wait_idle()
        await ClockCycles(self.dut.clk, 4)
        return cpol, cpha, active_lanes(m, self.nsd)

    async def write_transfers(self, tag, *, div, wl, mode=None, mask=None,
                              n_list, read=False, offload=False,
                              sdo_gap=(0, 0), offload_phase=0):
        """Program the config, run ``len(n_list)`` back-to-back write
        transfers of ``n+1`` words each (n_list holds the n+1 values), and
        check wire bits, SCLK-edge count and SDO handshake count.

        Returns True when the point completed (even with mismatches), False
        on a hang.
        """
        tb, sb, dut = self.tb, self.tb.sb, self.dut
        cpol, cpha, lanes = await self.prepare(div=div, wl=wl, mode=mode,
                                               mask=mask)
        la = len(lanes)
        phases = [list(n_list)]
        words = [make_words(tb, f"{tag}_p{k}", sum(ph) * la, wl)
                 for k, ph in enumerate(phases)]
        stream = [w for ws in words for w in ws]
        note = (f"{tag} wl={wl} div={div} cpol={cpol} cpha={cpha} "
                f"lanes={lanes} n+1={n_list} read={int(read)} "
                f"offload={int(offload)}")

        def check_phase(k):
            exp = words[k]
            periods = sum(phases[k])
            nt = f"{note} phase={k}"
            samples = list(self.sampler.samples)
            # REQ: EXEC-SDO-01 - one bit per SCLK bit-period, word_length bits/word
            sb.compare(0, f"{tag}.sclk_sample_edges", periods * wl,
                       len(samples), note=nt)
            obs = words_from_samples(samples, wl, lanes)
            # REQ: EXEC-SDO-01 - each word MSB-first on its lane
            # REQ: EXEC-CC-03 - word_length extremes shift out the right word
            sb.compare_sequences(exp, obs, field=nt)
            if obs != exp:
                tb.log.warning(f"WIRE-DIFF {nt}: expected words "
                               f"{[hex(w) for w in exp]} observed "
                               f"{[hex(w) for w in obs]}")
            # REQ: EXEC-SDO-04 - exactly n+1 words per transfer consumed (one
            # per active lane per period)
            sb.compare(0, f"{tag}.sdo_handshakes", len(exp),
                       len(self.hs.received), note=nt)

        async def drive():
            started = False
            if offload:
                # Stream is present before the write instruction (prefetch).
                tb.start_sdo_stream(stream, min_gap=sdo_gap[0],
                                    max_gap=sdo_gap[1])
                started = True
                if offload_phase:
                    await ClockCycles(dut.clk, offload_phase)
            for k, ph in enumerate(phases):
                if k:
                    # phase 0 keeps the count from the outer clear, which also
                    # holds any offload prefetch handshake before the command
                    self.hs.received.clear()
                self.sampler.arm(cpol, cpha)
                for n_words in ph:
                    cmd = ins.transfer(n_words - 1, write=True, read=read)
                    sdi = (make_words(tb, tag + "_sdi", n_words * self.nsd, wl)
                           if read else None)
                    tb.apply_cmd(cmd, sdi_data=sdi)
                    await tb.send_cmd(cmd)
                    if not started:
                        tb.start_sdo_stream(stream, min_gap=sdo_gap[0],
                                            max_gap=sdo_gap[1])
                        started = True
                    if read:
                        tb.slave.start()
                await tb.wait_idle(timeout_cycles=10 ** 9)
                await ClockCycles(dut.clk, 6)
                self.sampler.disarm()
                check_phase(k)

        self.hs.received.clear()
        if offload:
            tb.set_offload_active(True)
        total_periods = sum(sum(ph) for ph in phases)
        bound_cycles = total_periods * (wl * 2 * (div + 1) + 8 * la + 10) \
            * (1 + sdo_gap[1]) + 4000
        task = cocotb.start_soon(drive())
        hung = False
        try:
            await with_timeout(task, bound_cycles * CLK_PERIOD_NS, "ns")
        except SimTimeoutError:
            hung = True
            task.cancel()
        self.sampler.disarm()
        tb.abort_streams()
        if offload:
            tb.set_offload_active(False)
        if hung:
            sb.compare(0, f"{tag}.completes", "idle", "hang", note=note)
            await self.recover()
            return False
        return True


def _tail(tb):
    tb.sb.assert_no_errors()


# ---------------------------------------------------------------------------
# Tests
# ---------------------------------------------------------------------------
@cocotb.test()
async def test_sdo_wordlen_x_clkdiv_cross(dut):
    """Full word_length x clk_div cross-product, several transfer lengths.

    word_length from 1 to DATA_WIDTH (extremes, small, mid), clk_div 0..7, and
    n+1 in {1, 3, 8}. Includes the min x min corner (word_length=1, clk_div=0).
    """
    h = Harness(dut)
    await h.start()
    for div in DIV_POINTS:
        for wl in wl_points(h.dw):
            for n_words in (1, 3, 8):
                await h.write_transfers(f"cross_d{div}_w{wl}_n{n_words}",
                                        div=div, wl=wl, n_list=[n_words])
    _tail(h.tb)


@cocotb.test()
async def test_sdo_min_wordlength_spi_modes(dut):
    """word_length 1 and 2 in all four SPI modes at several clk_div values."""
    h = Harness(dut)
    await h.start()
    for cpol in (0, 1):
        for cpha in (0, 1):
            for div in (0, 1, 2, 5):
                for wl in (1, 2):
                    await h.write_transfers(
                        f"minwl_m{cpol}{cpha}_d{div}_w{wl}", div=div, wl=wl,
                        mode=(cpol, cpha), n_list=[6])
    _tail(h.tb)


@cocotb.test()
async def test_sdo_max_wordlength_spi_modes(dut):
    """word_length = DATA_WIDTH in all four SPI modes at several clk_div."""
    h = Harness(dut)
    await h.start()
    for cpol in (0, 1):
        for cpha in (0, 1):
            for div in (0, 1, 3):
                for n_words in (1, 4):
                    await h.write_transfers(
                        f"maxwl_m{cpol}{cpha}_d{div}_n{n_words}", div=div,
                        wl=h.dw, mode=(cpol, cpha), n_list=[n_words])
    _tail(h.tb)


@cocotb.test()
async def test_sdo_clkdiv_max(dut):
    """Largest clk_div (255) with minimum, 2 and maximum word_length."""
    h = Harness(dut)
    await h.start()
    for wl in sorted({1, 2, h.dw}):
        await h.write_transfers(f"divmax_w{wl}", div=MAX_CLK_DIV, wl=wl,
                                n_list=[2])
    _tail(h.tb)


@cocotb.test()
async def test_sdo_transfer_length_sweep(dut):
    """n+1 from 1 up to 256 words (max) at word_length 1 and 2; up to 64
    words at DATA_WIDTH (runtime cap on wide builds)."""
    h = Harness(dut)
    await h.start()
    for div in (0, 1):
        for wl in sorted({1, 2, h.dw}):
            lengths = (1, 2, 3, 16, 256) if wl <= 2 else (1, 2, 3, 16, 64)
            for n_words in lengths:
                await h.write_transfers(f"len_d{div}_w{wl}_n{n_words}",
                                        div=div, wl=wl, n_list=[n_words])
    _tail(h.tb)


@cocotb.test()
async def test_sdo_back_to_back_transfers(dut):
    """Zero-gap consecutive write transfers: no word lost, repeated or merged.

    Mixed lengths per batch, plain and with random gaps in the SDO stream.
    """
    h = Harness(dut)
    await h.start()
    rng = h.tb.rc.derive("b2b_lengths")
    for gap in ((0, 0), (0, 3)):
        for div in (0, 1, 3):
            for wl in wl_points(h.dw):
                n_list = [rng.choice((1, 2, 3, 5)) for _ in range(4)]
                await h.write_transfers(
                    f"b2b_g{gap[1]}_d{div}_w{wl}", div=div, wl=wl,
                    n_list=n_list, sdo_gap=gap)
    _tail(h.tb)


@cocotb.test()
async def test_sdo_full_duplex(dut):
    """Read-enabled (w=1 r=1) transfers: SDO framing/count unchanged."""
    h = Harness(dut)
    await h.start()
    for div in (0, 1, 2):
        for wl in wl_points(h.dw):
            for n_words in (1, 4):
                await h.write_transfers(f"duplex_d{div}_w{wl}_n{n_words}",
                                        div=div, wl=wl, n_list=[n_words],
                                        read=True)
    _tail(h.tb)


@cocotb.test()
async def test_sdo_offload_mode(dut):
    """s_offload_active=1 (SDO prefetch): framing/count unchanged.

    Stream is presented before the write instruction, at several arrival
    phases relative to the command.
    """
    h = Harness(dut)
    await h.start()
    for div in (0, 1, 2):
        for wl in wl_points(h.dw):
            for phase in (0, 2):
                await h.write_transfers(
                    f"offload_d{div}_w{wl}_ph{phase}", div=div, wl=wl,
                    n_list=[1, 4], offload=True, offload_phase=phase)
    _tail(h.tb)


@cocotb.test()
async def test_sdo_partial_lane_masks(dut):
    """Every non-empty SDO lane mask: per-lane framing and word count.

    Active lanes take stream words in ascending lane order; handshake count
    is (n+1) x active lanes. Single-lane builds exercise the only mask (1).
    """
    h = Harness(dut)
    await h.start()
    full = (1 << h.nsd) - 1
    rng = h.tb.rc.derive("mask_pick")
    masks = list(range(1, full + 1))
    if len(masks) > 20:
        masks = sorted({1, full, 1 << (h.nsd - 1), full ^ 1,
                        *rng.sample(masks, 14)})
    for mask in masks:
        for div, wl in ((0, 1), (1, 1), (0, 2), (0, h.dw), (1, 3)):
            if wl > h.dw:
                continue
            await h.write_transfers(f"mask{mask:#x}_d{div}_w{wl}", div=div,
                                    wl=wl, mask=mask, n_list=[3])
    _tail(h.tb)


@cocotb.test()
async def test_sdo_busmon_agrees_with_wire(dut):
    """The bus monitor reports the same words as the raw wire sampler.

    Guards the monitor helper itself (every word_length incl. 1, every
    clk_div): the number of words it reports must equal the SCLK sample
    edges on the wire divided by word_length, and the values must match the
    words rebuilt from the raw samples. Independent of what the DUT should
    send, so a failure here is a helper defect, not a DUT one.
    """
    h = Harness(dut)
    await h.start()
    tb = h.tb
    n_words = 5
    for div in DIV_POINTS:
        for wl in wl_points(h.dw):
            tag = f"mon_d{div}_w{wl}"
            cpol, cpha, lanes = await h.prepare(div=div, wl=wl)
            words = make_words(tb, tag, n_words * len(lanes), wl)
            tb.bus_mon.words.clear()
            h.sampler.arm(cpol, cpha)
            await tb.run_transfer(n=n_words, write=True, read=False,
                                  sdo_words=words)
            h.sampler.disarm()
            wire = words_from_samples(h.sampler.samples, wl, lanes)
            # REQ: EXEC-SDO-01 - monitor sees every word the wire carries
            tb.sb.compare(0, f"{tag}.monitor_word_count", len(wire),
                          len(tb.bus_mon.sdo_words))
            tb.sb.compare_sequences(wire, tb.bus_mon.sdo_words, field=tag)
    _tail(tb)
