"""Test environment for spi_engine_execution: wires DUT to framework agents.

Centralises clock/reset bring-up, the CMD and SDO drivers, the SDI/SYNC
monitors, the SPI bus monitor and slave model, the golden model, and the
scoreboard so each test reads as stimulus + check rather than boilerplate.
"""

from __future__ import annotations

import os

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, ClockCycles, Timer

from framework.axi_stream import AXIStreamDriver, AXIStreamMonitor
from framework.backpressure import RandomBackpressure
from framework.scoreboard import Scoreboard
from framework.random_ctx import RandomContext
from framework.reset import apply_reset, check_reset_values
from framework.spi.bus_monitor import SPIBusMonitor
from framework.spi.slave_model import SPISlaveModel
from framework.spi import instructions as ins

from model_execution import ExecutionModel

CLK_PERIOD_NS = 10

# Verilator inlines module boundaries and prunes internal nets unless they are
# kept public; this flag exposes them so hierarchical hooks resolve. Named here
# so the whitebox failure message can point the user at it.
VERILATOR_PUBLIC_FLAG = "--public-flat-rw"


def get_params():
    return {
        "DATA_WIDTH": int(os.environ.get("PARAM_DATA_WIDTH", 8)),
        "NUM_OF_CS": int(os.environ.get("PARAM_NUM_OF_CS", 1)),
        "NUM_OF_SDIO": int(os.environ.get("PARAM_NUM_OF_SDIO", 1)),
        "DEFAULT_SPI_CFG": int(os.environ.get("PARAM_DEFAULT_SPI_CFG", 0)),
        "DEFAULT_CLK_DIV": int(os.environ.get("PARAM_DEFAULT_CLK_DIV", 0)),
        "ECHO_SCLK": int(os.environ.get("PARAM_ECHO_SCLK", 0)),
        "SDO_DEFAULT": 0,
    }


class WhiteboxSignalError(Exception):
    """An expected internal (white-box) DUT signal could not be resolved.

    Raised inside a test coroutine, so cocotb marks only that test as failed
    and continues with the rest of the suite — the TB is not halted.
    """


def _resolve_whitebox(dut, path, *, mode):
    """Resolve a hierarchical internal signal handle (e.g. "shiftreg.trigger_rx_s").

    ``mode="require"`` (default): raise :class:`WhiteboxSignalError` if any
    segment of the path is missing — the sim optimized it away or it is not
    accessible. The message is simulator-agnostic but points Verilator users at
    the flag that keeps internal nets public.

    ``mode="off"``: return ``None`` on a miss, so the caller degrades to its
    black-box strategy on purpose.
    """
    node = dut
    for seg in path.split("."):
        node = getattr(node, seg, None)
        if node is None:
            if mode == "off":
                return None
            raise WhiteboxSignalError(
                f"unable to hook into whitebox signal <{path}> - "
                f"if using verilator use flag <{VERILATOR_PUBLIC_FLAG}>")
    return node


class ExecutionTB:
    def __init__(self, dut, *, whitebox=None):
        # Default from the environment so a deliberate black-box run of the whole
        # suite is `WHITEBOX=off make`; an explicit kwarg always wins.
        if whitebox is None:
            whitebox = os.environ.get("WHITEBOX", "require")
        if whitebox not in ("require", "off"):
            raise ValueError(
                f"whitebox must be 'require' or 'off', got {whitebox!r}")
        self.dut = dut
        self.log = dut._log
        self.whitebox = whitebox
        self.params = get_params()
        self.rc = RandomContext.from_env(self.log)
        self.model = ExecutionModel(self.params)
        self.sb = Scoreboard("execution", logger=self.log)
        self._sdo_tasks = []

        # Drivers (manager side).
        self.cmd = AXIStreamDriver.from_dut(
            dut, "cmd", rng=self.rc.derive("cmd_gap"))
        self.sdo = AXIStreamDriver.from_dut(
            dut, "sdo_data", rng=self.rc.derive("sdo_gap"))

        # Monitors (passive).
        self.sdi_mon = AXIStreamMonitor.from_dut(dut, "sdi_data")
        self.sync_mon = AXIStreamMonitor.from_dut(dut, "sync")

        # SPI-side observation + stimulus.
        cfg = self.params["DEFAULT_SPI_CFG"]
        self.num_sdio = self.params["NUM_OF_SDIO"]
        # Gate sampling on transfer_active so CPOL idle-level settling between
        # transfers cannot inject phantom SCLK edges into a captured word. In
        # whitebox="require" mode a missing hook fails this test (and only this
        # test); in "off" mode it resolves to None and the agents run black-box.
        gate = _resolve_whitebox(dut, "transfer_active", mode=self.whitebox)
        # Kept so the sdo_t sampler can *time* its boundary read to the transfer
        # window; the pass/fail check is on the boundary sdo_t output.
        self.gate = gate
        self.bus_mon = SPIBusMonitor(
            dut, cpol=(cfg >> 1) & 1, cpha=cfg & 1,
            word_length=self.params["DATA_WIDTH"],
            num_sdio=self.num_sdio,
            gate_signal=gate)
        # Prefer the DUT's actual SDI sample strobe (trigger_rx_s in the shiftreg
        # submodule) to drive the slave: it stays in lock-step with the DUT's SDI
        # shift register even under backpressure stalls, where SCLK emits phantom
        # edges that a black-box edge-counting slave would miscount.
        strobe = _resolve_whitebox(
            dut, "shiftreg.trigger_rx_s", mode=self.whitebox)
        self.slave = SPISlaveModel(
            dut, cpol=(cfg >> 1) & 1, cpha=cfg & 1,
            word_length=self.params["DATA_WIDTH"],
            num_sdio=self.params["NUM_OF_SDIO"],
            rng=self.rc.derive("slave"),
            gate_signal=gate,
            sample_strobe=strobe)

        # Backpressure controllers on consumer-side ready signals.
        self.bp_sdi = RandomBackpressure(
            dut.clk, dut.sdi_data_ready, self.rc.derive("bp_sdi"), name="sdi")
        self.bp_sync = RandomBackpressure(
            dut.clk, dut.sync_ready, self.rc.derive("bp_sync"), name="sync")

    async def start(self):
        self.rc.log_seed()
        self.log.info(f"DUT params: {self.params}")
        cocotb.start_soon(Clock(self.dut.clk, CLK_PERIOD_NS, unit="ns").start())
        self._init_inputs()
        await apply_reset(self.dut)
        # Default: all consumers ready, monitors running.
        self.bp_sdi.start_always_ready()
        self.bp_sync.start_always_ready()
        self.sdi_mon.start()
        self.sync_mon.start()
        self.bus_mon.start()

    def _init_inputs(self):
        d = self.dut
        d.resetn.value = 0
        d.s_offload_active.value = 0
        d.cmd_valid.value = 0
        d.cmd.value = 0
        d.sdo_data_valid.value = 0
        d.sdo_data.value = 0
        d.sdi_data_ready.value = 0
        d.sync_ready.value = 0
        d.echo_sclk.value = 0
        d.sdi.value = 0

    # ---- convenience command issue (drives DUT + advances golden model) --
    async def issue(self, cmd, *, sdo_data=None, sdi_data=None):
        """Send a command on the CMD stream and apply it to the golden model.

        For transfers, ``sdo_data`` is streamed on the SDO data interface and
        ``sdi_data`` is loaded into the slave model.
        """
        res = self.model.apply(cmd, sdo_data=sdo_data, sdi_data=sdi_data)
        # Reconfigure SPI-side agents if this command changed mode/length.
        self._sync_agents_from_model()
        if sdi_data is not None:
            # Load the model's canonical flat layout (period-major, lane-minor)
            # so the slave drives the right word on each active lane per period.
            self.slave.load(res.sdi_words if res is not None else sdi_data)
        await self.cmd.send(cmd)
        return res

    async def stream_sdo(self, words, *, min_gap=0, max_gap=0):
        """Stream SDO data words (write transfers consume these)."""
        await self.sdo.send_queue(words, min_gap=min_gap, max_gap=max_gap)

    def start_sdo_stream(self, words, *, min_gap=0, max_gap=0):
        """Start a tracked background SDO stream (cancellable via abort())."""
        task = cocotb.start_soon(
            self.stream_sdo(words, min_gap=min_gap, max_gap=max_gap))
        self._sdo_tasks.append(task)
        return task

    def abort_streams(self):
        """Kill any in-flight SDO streams and deassert sdo_data_valid.

        Used after an injected reset aborts a transfer, so leftover words do not
        leak onto the bus during the next transfer.
        """
        for t in self._sdo_tasks:
            t.kill()
        self._sdo_tasks = []
        self.dut.sdo_data_valid.value = 0

    def after_reset(self):
        """Clean up TB-side state after an injected DUT reset.

        Aborts leftover SDO streams, flushes the bus monitor's partial word, and
        resets the golden model so its state matches the freshly-reset DUT.
        """
        self.abort_streams()
        self.bus_mon.flush()
        self.bus_mon.words.clear()
        self.sdi_mon.received.clear()
        self.model = ExecutionModel(self.params)

    async def run_transfer(self, *, n, write, read, sdo_words=None,
                           sdi_words=None, sdo_gap=(0, 0), cs=0):
        """Assert CS, run one transfer to completion, return (result).

        Streams SDO words concurrently (with optional random gaps) and starts
        the slave model for reads. Leaves CS asserted on return.
        """
        await self.issue(ins.chipselect(cs, delay=1))
        await self.wait_idle()
        res = await self.issue(ins.transfer(n - 1, write=write, read=read),
                               sdo_data=sdo_words, sdi_data=sdi_words)
        tasks = []
        if write and sdo_words is not None:
            # Stream the model's canonical flat layout (n_periods * n_lanes
            # words, masked) so multi-lane round-robin distribution is handled
            # in one place rather than at every call site.
            tasks.append(cocotb.start_soon(
                self.stream_sdo(res.sdo_words, min_gap=sdo_gap[0],
                                max_gap=sdo_gap[1])))
        if read:
            self.slave.start()
        await self.wait_idle()
        await ClockCycles(self.dut.clk, 3)
        return res

    def _sync_agents_from_model(self):
        self.bus_mon.configure(cpol=self.model.cpol, cpha=self.model.cpha,
                               word_length=self.model.word_length,
                               sdo_lane_mask=self.model.sdo_lane_mask,
                               sdi_lane_mask=self.model.sdi_lane_mask)
        self.slave.configure(cpol=self.model.cpol, cpha=self.model.cpha,
                             word_length=self.model.word_length,
                             sdi_lane_mask=self.model.sdi_lane_mask)

    @property
    def sdi_values(self):
        """Consumer-side SDI words flattened period-major, active-lane-minor.

        Each accepted ``sdi_data`` AXI beat carries NUM_OF_SDIO*DATA_WIDTH bits
        (one captured word per lane, lane l at bits [l*DW +: DW]). Split each
        beat into its active lanes in ascending order so the result lines up
        with the golden model's flat expectation. At a single lane this is just
        the raw beat values (the previous ``sdi_mon.values``).
        """
        if self.num_sdio == 1:
            return self.sdi_mon.values
        dw = self.params["DATA_WIDTH"]
        mask = (1 << dw) - 1
        lanes = [l for l in range(self.num_sdio)
                 if (self.model.sdi_lane_mask >> l) & 1]
        out = []
        for beat in self.sdi_mon.values:
            for l in lanes:
                out.append((beat >> (l * dw)) & mask)
        return out

    # ---- boundary timing utilities (shared by timing/waveform tests) -----
    def now_cycles(self):
        """Current sim time expressed in whole core-clock cycles."""
        from cocotb.utils import get_sim_time
        return int(get_sim_time("ns") / CLK_PERIOD_NS)

    async def measure_sclk_period(self, *, timeout=4000):
        """Measure the SCLK period in core-clock cycles (two rising edges).

        Observes only the boundary ``sclk`` output. Returns -1 if two edges are
        not seen within ``timeout`` core clocks.
        """
        dut = self.dut
        prev = int(dut.sclk.value)
        edges = []
        for _ in range(timeout):
            await RisingEdge(dut.clk)
            cur = int(dut.sclk.value)
            if prev == 0 and cur == 1:
                edges.append(self.now_cycles())
                if len(edges) == 2:
                    return edges[1] - edges[0]
            prev = cur
        return -1

    async def wait_idle(self, *, timeout_cycles=100000):
        """Wait until the engine returns to idle (cmd_ready high)."""
        for _ in range(timeout_cycles):
            await RisingEdge(self.dut.clk)
            if int(self.dut.cmd_ready.value) == 1:
                return
        raise TimeoutError("engine did not return to idle")

    def check_reset_values(self):
        return check_reset_values(self.dut, self.params, scoreboard=self.sb)

    def check_reset_values_extra(self, *, index=-1):
        """DUT-specific reset-value checks not in the generic reset helper.

        Covers boundary outputs the spec pins at reset that the reusable
        ``framework.reset.check_reset_values`` (kept DUT-generic) does not: the
        SPI-config-derived ``three_wire`` (EXEC-RST-06), ``sdi_data_valid`` low
        (EXEC-RST-06), and every ``sdo`` lane resting at ``sdo_idle_state``
        (EXEC-RST-05). Placed here rather than in the generic helper to avoid
        adding more DUT knowledge to Tier 1 (that file already carries some).
        Returns a list of human-readable error strings.
        """
        cfg = self.params["DEFAULT_SPI_CFG"]
        expected_three_wire = (cfg >> 2) & 1
        idle = self.params.get("SDO_DEFAULT", 0)
        expected_sdo = (idle * ((1 << self.num_sdio) - 1))  # every lane = idle
        checks = [
            ("three_wire", int(self.dut.three_wire.value), expected_three_wire),
            ("sdi_data_valid", int(self.dut.sdi_data_valid.value), 0),
            ("sdo", int(self.dut.sdo.value), expected_sdo),
        ]
        errs = []
        for name, actual, expected in checks:
            self.sb.compare(index, f"reset.{name}", expected, actual)
            if actual != expected:
                errs.append(f"{name}={actual} expected {expected}")
        return errs

    # ---- offload boundary interaction (prefetch/readiness only) -----
    def set_offload_active(self, active):
        """Drive the s_offload_active boundary input (EXEC-OFF-01/02).

        This is the only offload-related signal exposed at this module's
        boundary; full offload semantics belong to the offload IP, so the
        tests using this only observe SDO prefetch *readiness* timing, never
        RAM/trigger behaviour.
        """
        self.dut.s_offload_active.value = 1 if active else 0

    async def observe_sdo_ready_before_cmd(self, *, window=40):
        """Watch whether sdo_data_ready asserts *before* a write instruction.

        Returns True if the DUT asserts ``sdo_data_ready`` (prefetch) while idle,
        ahead of any transfer command being issued. Used to distinguish offload
        prefetch (EXEC-OFF-01) from the FIFO-mode behaviour where the engine only
        requests SDO data after the write instruction. Purely observational on a
        boundary handshake output.
        """
        prefetched = False
        for _ in range(window):
            await RisingEdge(self.dut.clk)
            if int(self.dut.sdo_data_ready.value) == 1:
                prefetched = True
                break
        return prefetched

    async def sample_sdo_t_during_transfer(self, *, settle=2, timeout=2000):
        """Return the sdo_t value sampled while a transfer is active.

        Times the boundary read to the transfer window using the transfer gate
        (a stimulus-timing use of an internal signal), waiting ``settle``
        cycles after the window opens so the registered ``sdo_t`` output has
        stabilised; the returned value is the boundary ``sdo_t`` output, which is
        what the caller asserts on. Returns None if no active window is seen
        within ``timeout`` cycles.
        """
        if self.gate is None:
            return None
        for _ in range(timeout):
            await RisingEdge(self.dut.clk)
            if int(self.gate.value) == 1:
                for _ in range(settle):
                    if int(self.gate.value) != 1:
                        break
                    await RisingEdge(self.dut.clk)
                return int(self.dut.sdo_t.value)
        return None
