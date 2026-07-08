#!/usr/bin/env python3
"""Build + run entry point for the spi_engine_execution cocotb TB.

Single entry point, no arguments: ``./runner.py``. It builds and runs a
curated list of DUT-generic configurations (``CONFIGS``), each against the full
test suite over ``N_SEEDS`` random seeds, and prints one PASS/FAIL summary.

DUT generics are compile-time, so each config is a separate compile. Build and
run use separate directories keyed differently:
  * build dir is keyed by (sim, generics, instrumentation) so an unchanged
    config reuses its binary and differing generics never share a stale one;
  * run dir is keyed by (runid, config, seed) so no two runs write the same
    results/coverage file — the basis for safe parallel and multi-agent use.

Each config feeds its generics through BOTH channels the TB needs:
  * ``build(parameters=...)``   -> simulator generic overrides (the RTL);
  * ``test(extra_env=PARAM_*)`` -> env vars read by ``tb_env.get_params()`` (the
    Python golden model). These must agree.

Everything a user edits lives in the CONFIGURATION block below.
"""

from __future__ import annotations

import os
import random
import sys
import time
from dataclasses import dataclass
from pathlib import Path

from cocotb_tools.runner import get_runner

# ============================ CONFIGURATION ============================
# Everything a user edits lives in this block.

SIM = "icarus"           # "verilator" (fast, default) or "icarus"
WHITEBOX = "require"     # "require" internal-signal checks, or "off" (black-box)
WAVES = False            # dump dump.vcd per run (GTKWave / Surfer)
COVERAGE = False         # Verilator RTL line coverage -> one merged report
N_SEEDS = 5              # random seeds per config (each is logged for replay)
MAX_JOBS = 4             # parallel config-runs; 1 = serial with live output

# Reproduce one run: set SEED to a seed the summary logged, and optionally pin
# TESTCASE to a single test name. Leave both None for the normal random sweep.
SEED = None                # int, e.g. 1587325506
TESTCASE = None            # str, e.g. "test_sdi_handshake_stability"

# Label for this invocation's run/coverage dirs. Give concurrent agents distinct
# ids to keep their runs apart; None -> "run".
RUN_ID = None

# Extra compile flags (generics and --coverage are added automatically).
VERILATOR_BUILD_ARGS = ["--timing", "-Wno-fatal"]
ICARUS_BUILD_ARGS = []

# Configs to be executed are defined after the "class Config"
# ========================== END CONFIGURATION ==========================


HERE = Path(__file__).resolve().parent
# Bootstrap: put <repo>/cocotb on sys.path so `framework.*` imports resolve.
# This is the one unavoidable relative hop — every path anchor beyond it
# (REPO_ROOT, COCOTB_DIR) is derived once in framework.paths.
_COCOTB_DIR = (HERE / "../../../../cocotb").resolve()
if str(_COCOTB_DIR) not in sys.path:
    sys.path.insert(0, str(_COCOTB_DIR))

from framework.sweep import (  # noqa: E402
    SweepLayout,
    dispatch,
    merge_and_report_coverage,
    parse_results,
    print_analysis,
)

_adi_hdl_dir = os.environ.get("ADI_HDL_DIR")
if not _adi_hdl_dir:
    sys.exit("ADI_HDL_DIR export missing\n  Example: export ADI_HDL_DIR=/path/to/hdl")
HDL_DIR = Path(_adi_hdl_dir).resolve()
EXEC_DIR = HDL_DIR / "library/spi_engine/spi_engine_execution"

# The runner exports PYTHONPATH from this process's sys.path (it ignores an
# extra_env PYTHONPATH), so the test modules import `framework` and the local
# `model_execution`/`tb_env` only if those dirs are on sys.path here. COCOTB_DIR
# is already on sys.path (added above for the framework import); add the TB dir.
if str(HERE) not in sys.path:
    sys.path.insert(0, str(HERE))

TOPLEVEL = "spi_engine_execution"
VERILOG_SOURCES = [
    EXEC_DIR / "spi_engine_execution.v",
    EXEC_DIR / "spi_engine_execution_shiftreg.v",
    EXEC_DIR / "spi_engine_execution_shiftreg_data_assemble.v",
]
for src in VERILOG_SOURCES:
    assert src.exists(), f"src file not found {src}"

# Every test module. cocotb runs them all unless TESTCASE pins a single test.
TEST_MODULES = [
    "test_reset", "test_command", "test_transfer", "test_chipselect",
    "test_config", "test_misc", "test_waveform", "test_flow_control",
    "test_lanes", "test_offload", "test_sequences",
]

# Short tags for compact config names (dw8_cs1_sd1_cfg0_div0_echo0).
_TAGS = {
    "DATA_WIDTH": "dw", "NUM_OF_CS": "cs", "NUM_OF_SDIO": "sd",
    "DEFAULT_SPI_CFG": "cfg", "DEFAULT_CLK_DIV": "div", "ECHO_SCLK": "echo",
}


@dataclass
class Config:
    """One generic combination (the VUnit ``add_config`` analogue).

    Fields default to the DUT's own generic defaults; a config only overrides
    what it exercises. ``name`` is derived from the generics for the build dir
    and the report.
    """
    data_width: int = 8
    num_of_cs: int = 1
    num_of_sdio: int = 1
    spi_cfg: int = 0
    default_clk_div: int = 0
    echo_sclk: int = 0
    # TODO: the RTL also has SDO_DEFAULT and SDI_DELAY generics; add fields for
    # them here (and in generics/_TAGS below) so they can be swept. They are
    # pinned at their RTL defaults today — see the TODOs under CONFIGS.

    @property
    def generics(self) -> dict:
        return {
            "DATA_WIDTH": self.data_width,
            "NUM_OF_CS": self.num_of_cs,
            "NUM_OF_SDIO": self.num_of_sdio,
            "DEFAULT_SPI_CFG": self.spi_cfg,
            "DEFAULT_CLK_DIV": self.default_clk_div,
            "ECHO_SCLK": self.echo_sclk,
        }

    @property
    def name(self) -> str:
        return "_".join(f"{_TAGS[k]}{v}" for k, v in self.generics.items())


# Configs to build + run: the baseline, one variation per generic, then a
# combined stress config. Exercises every generic's interesting values without
# the full cartesian blow-up.
#
# To run a single custom config, comment out the sweep and add your own, e.g.:
#   CONFIGS = [Config(data_width=32, num_of_sdio=4, default_clk_div=2)]
CONFIGS = [
    Config(),                                       # baseline: 8-bit, 1 CS, 1 lane, mode 0
    Config(data_width=24),                          # non-power-of-2 word
    Config(data_width=32),                          # widest typical word
    Config(num_of_cs=2),                            # multiple chip selects
    Config(num_of_cs=4),
    Config(num_of_sdio=2),                          # multi-lane (dual)
    Config(num_of_sdio=3),                          # multi-lane (odd; non-contiguous sub-mask)
    Config(num_of_sdio=4),                          # multi-lane (quad)
    Config(spi_cfg=3),                              # CPOL+CPHA reset defaults
    Config(default_clk_div=2),                      # slower SCLK
    Config(data_width=32, num_of_cs=2, num_of_sdio=4, spi_cfg=3),  # combined stress
]
# TODO: add Config(echo_sclk=1). The current TB does not support it: tb_env ties
# the echo_sclk input to a constant 0, but ECHO_SCLK=1 clocks the entire SDI
# capture path off that port, so every read transfer hangs. Once the TB drives
# echo_sclk (loop sclk back to it) this becomes a real config. NOTE: spi_cfg=1/2
# (DEFAULT_SPI_CFG[1:0] == 01/10) subtly change the ECHO branch too — they select
# a neg- vs pos-edge MISO latch — so echo_sclk is interesting to sweep together
# with spi_cfg=1 and spi_cfg=2.
# TODO: add Config(spi_cfg=1) and Config(spi_cfg=2).
# TODO: add Config(data_width=16).
# TODO: add a Config(sdi_delay=...) sweep over SDI_DELAY (0..3).
# TODO: add a Config(sdo_default=1) sweep over SDO_DEFAULT.
# ======================================================================

_RUNID = RUN_ID or "run"

SIM_BUILD = HERE / "sim_build"

# The reusable directory-layout / build-flag rules live in the framework; this
# runner only supplies the values from the CONFIGURATION block above.
LAYOUT = SweepLayout(
    sim=SIM,
    build_root=SIM_BUILD / "build",
    runs_root=SIM_BUILD / "runs" / _RUNID,
    coverage_dir=SIM_BUILD / "coverage" / _RUNID,
    coverage=COVERAGE,
    waves=WAVES,
    verilator_build_args=tuple(VERILATOR_BUILD_ARGS),
    icarus_build_args=tuple(ICARUS_BUILD_ARGS),
)
RUNS_ROOT = LAYOUT.runs_root


def build_config(cfg: Config) -> tuple[Config, bool, Path]:
    """Compile one config into its build dir. Returns (cfg, ok, log).

    Output goes to build.log, never the terminal — a full sweep is too noisy.
    """
    bdir = LAYOUT.build_dir(cfg.name)
    log = bdir / "build.log"
    try:
        get_runner(SIM).build(
            sources=VERILOG_SOURCES,
            hdl_toplevel=TOPLEVEL,
            parameters=cfg.generics,          # -> simulator generic overrides
            build_args=LAYOUT.build_args(),
            build_dir=bdir,
            waves=WAVES,
            log_file=log,
        )
        return (cfg, True, log)
    except (SystemExit, RuntimeError):
        return (cfg, False, log)


def run_config(cfg: Config, seed: int):
    """Run one built config for one seed in its own run dir.

    Returns (tag, rows, secs); rows is [(name, ran, failed)] parsed from the
    JUnit XML, or None if the sim crashed (no results file). Output goes to
    run.log, never the terminal. Verilator writes coverage.dat into the run dir
    (its cwd), so no per-seed copy is needed.
    """
    tag = f"{cfg.name}_seed{seed}"
    tdir = LAYOUT.run_dir(cfg.name, seed)
    log = tdir / "run.log"
    t0 = time.perf_counter()

    # tb_env.get_params() reads PARAM_<NAME> from the environment, so mirror the
    # generics there too (build parameters alone don't reach the Python model).
    extra_env = {f"PARAM_{name}": str(val) for name, val in cfg.generics.items()}
    extra_env["WHITEBOX"] = WHITEBOX
    # The TB RNG reads RANDOM_SEED (random_ctx.from_env); the runner's seed= only
    # sets COCOTB_RANDOM_SEED. Set both so the logged seed actually reproduces.
    extra_env["RANDOM_SEED"] = str(seed)

    try:
        # A fresh runner never saw build()'s sources, so pin the language rather
        # than let test() infer it from unset source attributes.
        results_xml = get_runner(SIM).test(
            hdl_toplevel=TOPLEVEL,
            hdl_toplevel_lang="verilog",
            test_module=TEST_MODULES,
            seed=seed,
            extra_env=extra_env,
            build_dir=LAYOUT.build_dir(cfg.name),
            test_dir=tdir,
            waves=WAVES,
            testcase=TESTCASE,
            log_file=log,
        )
        return (tag, parse_results(results_xml), time.perf_counter() - t0)
    except (SystemExit, RuntimeError):
        return (tag, None, time.perf_counter() - t0)


def main() -> int:
    if COVERAGE and SIM != "verilator":
        print(f"coverage: ignored (only supported on verilator, SIM={SIM}).", file=sys.stderr)

    seeds = (
        [SEED] if SEED is not None else [random.randrange(1, 1 << 31) for _ in range(N_SEEDS)]
    )

    print(f"SIM={SIM} WHITEBOX={WHITEBOX} WAVES={WAVES} COVERAGE={COVERAGE} "
          f"MAX_JOBS={MAX_JOBS} RUN_ID={_RUNID}")
    print(f"Running {len(CONFIGS)} config(s) x {len(seeds)} seed(s); "
          f"seeds = {seeds}"
          + (f"; TESTCASE={TESTCASE}" if TESTCASE else ""))

    # Build phase: one compile per config into distinct dirs (parallel-safe,
    # no shared-dir race), so the run phase only ever reads finished binaries.
    print("Building...")
    t0 = time.perf_counter()
    built = {}
    for cfg, ok, log in dispatch(build_config, [(cfg,) for cfg in CONFIGS],
                                 max_jobs=MAX_JOBS):
        built[cfg.name] = ok
        mark = "" if ok else " FAILED"
        print(f"  build complete{mark} - {log}")
    print(f"All builds complete! (took {time.perf_counter() - t0:.1f}s)")

    results = []                        # (status, tag, ntests, nfailed, nskipped)
    counts: dict[str, int] = {}         # per-test execution tally across the sweep
    failures: dict[str, list[str]] = {}  # test name -> run tags where it failed
    skips: dict[str, list[str]] = {}     # test name -> run tags where it skipped

    for cfg in CONFIGS:
        if not built[cfg.name]:
            for seed in seeds:
                results.append(("FAIL", f"{cfg.name}_seed{seed}", 0, 0, 0))

    print("\n" + "=" * 18 + " RUN RESULTS " + "=" * 18)
    # Align the "(tests=...)" column: tags vary in width across configs.
    align = max(len(f"{cfg.name}_seed{seed}") for seed in seeds for cfg in CONFIGS) + 2
    # Run phase: unique run dir per (config, seed), so workers never clash on
    # results/coverage files. Ctrl+C still reports the runs that did finish.
    jobs = [(cfg, seed) for seed in seeds for cfg in CONFIGS if built[cfg.name]]
    run_tag = lambda job: f"{job[0].name}_seed{job[1]}"
    try:
        for tag, rows, secs in dispatch(run_config, jobs, max_jobs=MAX_JOBS,
                                        label=run_tag):
            if rows is None:
                results.append(("FAIL", tag, 0, 0, 0))
                print(f"FAIL  {tag:<{align}}(aborted, no results file)")
                continue
            for name, ran, failed in rows:
                counts[name] = counts.get(name, 0) + (1 if ran else 0)
                if failed:
                    failures.setdefault(name, []).append(tag)
                elif not ran:
                    skips.setdefault(name, []).append(tag)
            ntests = len(rows)
            nfailed = sum(1 for _, _, f in rows if f)
            nskipped = sum(1 for _, ran, _ in rows if not ran)
            status = "PASS" if nfailed == 0 else "FAIL"
            results.append((status, tag, ntests, nfailed, nskipped))
            print(f"{status}  {tag:<{align}}"
                  f"(tests={ntests} fail={nfailed} skip={nskipped} in {secs:.1f}s)")
    except KeyboardInterrupt:
        print("\n^C — interrupted; reporting the runs that finished.", file=sys.stderr)

    print_analysis(counts, failures, skips, RUNS_ROOT)

    if COVERAGE and SIM == "verilator":
        merge_and_report_coverage(LAYOUT.runs_root, LAYOUT.coverage_dir)

    fail_total = sum(1 for status, *_ in results if status == "FAIL")
    if fail_total:
        print(f"\nSWEEP RESULT: {fail_total} config-run(s) FAILED")
        return 1
    print(f"\nSWEEP RESULT: all {len(results)} config-run(s) PASSED")
    return 0


if __name__ == "__main__":
    sys.exit(main())
