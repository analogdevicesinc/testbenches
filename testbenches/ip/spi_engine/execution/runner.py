#!/usr/bin/env python3
"""Build + run entry point for the spi_engine_execution cocotb TB.

Single entry point: ``./runner.py`` builds and runs a curated list of
DUT-generic configurations (``CONFIGS``), each against the full test suite
over ``N_SEEDS`` random seeds, and prints one PASS/FAIL summary.

Pass CLI flags to pin one reproducible run instead (config + seed + test),
e.g. ``./runner.py --testcase test_sdi_handshake_stability --seed 123``.
Run ``./runner.py --help`` for the full flag list. With no flags, behavior
is unchanged (the CONFIGURATION block below drives the full sweep).

DUT generics are compile-time, so each config is a separate compile. Build and
run use separate directories keyed differently:
  * build dir is keyed by (sim, generics, instrumentation) so differing
    generics never share a binary (BUILD_ALWAYS_* below set whether an
    existing build dir is reused);
  * run dir is keyed by (runid, config, seed) so no two runs write the same
    results/coverage file — the basis for safe parallel and multi-agent use.

Each config feeds its generics through BOTH channels the TB needs:
  * ``build(parameters=...)``   -> simulator generic overrides (the RTL);
  * ``test(extra_env=PARAM_*)`` -> env vars read by ``tb_env.get_params()`` (the
    Python golden model). These must agree.

Everything a user edits lives in the CONFIGURATION block below.
"""

from __future__ import annotations

import argparse
import os
import random
import signal
import sys
import time
from dataclasses import dataclass
from pathlib import Path

from cocotb_tools.runner import get_runner

# ============================ CONFIGURATION ============================
# Everything a user edits lives in this block.

SIM = "icarus"           # "verilator" or "icarus"
WHITEBOX = "require"     # "require" internal-signal checks, or "off" (black-box)
WAVES = True             # dump dump.vcd per run (GTKWave / Surfer)
COVERAGE = False         # Verilator RTL line coverage -> one merged report
N_SEEDS = 1              # random seeds per config (each is logged for replay)
MAX_JOBS = 8             # parallel config-runs; 1 = serial with live output
# Wall-clock watchdog: guards against runs where sim time doesn't advance.
TIMEOUT_S = 180          # run-phase wall-clock budget; aborts a hung sim (e.g.
                         # a deadlocked DUT) instead of blocking forever

# Reproduce one run: set SEED to a seed the summary logged, and optionally pin
# TESTCASE to a single test name. Leave both None for the normal random sweep.
SEED = None                # int, e.g. 1587325506
TESTCASE = None            # str, e.g. "test_sdi_handshake_stability"

# Label for this invocation's run/coverage dirs.
# Useful for running different HDL commits without clearing the repo or
# to give concurrent agents distinct ids to keep their runs apart
RUN_ID = "run"

# Build-dir reuse. cocotb only compares source mtimes (Icarus), so a different
# ADI_HDL_DIR checkout can look up to date and run stale RTL.
BUILD_ALWAYS_RECOMPILE = True   # recompile every run
BUILD_ALWAYS_CLEAR = False      # delete the build dir first (implies a recompile);
                                # opt-in: the dir also holds the per-config
                                # waveform (.fst), kept across builds of
                                # different commits

# Extra compile flags (generics and --coverage are added automatically).
VERILATOR_BUILD_ARGS = ["--timing", "-Wno-fatal"]
ICARUS_BUILD_ARGS = []

# Configs to be executed are defined after the "class Config"
# ========================== END CONFIGURATION ==========================


HERE = Path(__file__).resolve().parent

# `framework` is pip-installed editable into the active venv (see
# cocotb/pyproject.toml), so no sys.path bootstrap is needed for it here or in
# the spawned simulation subprocess — both use the same venv's interpreter.
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
# extra_env PYTHONPATH), so the test modules import the local
# `model_execution`/`tb_env` only if this dir is on sys.path here.
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
    "test_lanes", "test_lane_reconfig", "test_lane_reconfig_t1_directed",
    "test_offload", "test_sequences",
    "test_echo_sclk", "test_sdi", "test_sdi_delay_boundary", "test_sdo_word_coverage",
    "test_sdi_backpressure_stress",
]

# Short tags for compact config names (dw8_cs1_sd1_cfg0_div0_echo0_sdel0).
_TAGS = {
    "DATA_WIDTH": "dw", "NUM_OF_CS": "cs", "NUM_OF_SDIO": "sd",
    "DEFAULT_SPI_CFG": "cfg", "DEFAULT_CLK_DIV": "div", "ECHO_SCLK": "echo",
    "SDI_DELAY": "sdel", "SDO_DEFAULT": "sdod",
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
    sdi_delay: int = 0
    sdo_default: int = 0

    @property
    def generics(self) -> dict:
        return {
            "DATA_WIDTH": self.data_width,
            "NUM_OF_CS": self.num_of_cs,
            "NUM_OF_SDIO": self.num_of_sdio,
            "DEFAULT_SPI_CFG": self.spi_cfg,
            "DEFAULT_CLK_DIV": self.default_clk_div,
            "ECHO_SCLK": self.echo_sclk,
            "SDI_DELAY": self.sdi_delay,
            "SDO_DEFAULT": self.sdo_default,
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
    Config(echo_sclk=1),                          # echo SDI capture, posedge latch group
    Config(echo_sclk=1, spi_cfg=1),               # echo SDI capture, negedge latch group
    Config(echo_sclk=1, num_of_sdio=4),           # echo capture, per-lane replication
    Config(echo_sclk=1, data_width=32),           # echo capture, wide sdi_counter/last_bit_count
    Config(sdi_delay=1),                          # SDI capture delayed 1 core clock
    Config(sdi_delay=2),
    Config(sdi_delay=3),
    Config(data_width=16),                        # non-power-of-2-adjacent word
    Config(sdo_default=1),                        # SDO idle/default level inverted
]
# ======================================================================

# CLI override: pin a single reproducible run (config + seed + test) without
# editing the CONFIGURATION block. Any flag collapses CONFIGS to one Config;
# flags left unset keep that Config's dataclass default. No flags -> the
# hardcoded CONFIGS/SEED/TESTCASE above are used unchanged.
# --run-id is independent of this: it overrides RUN_ID whenever passed,
# regardless of single-run or full-sweep mode.
_CONFIG_FIELDS = (
    "data_width", "num_of_cs", "num_of_sdio", "spi_cfg",
    "default_clk_div", "echo_sclk", "sdi_delay", "sdo_default",
)


def _parse_cli_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Pin a single reproducible run (config + seed + test). "
                     "With no flags, runs the full CONFIGS sweep from the "
                     "CONFIGURATION block above instead (view source).")
    for field in _CONFIG_FIELDS:
        parser.add_argument(f"--{field.replace('_', '-')}", type=int, default=None)
    parser.add_argument("--seed", type=int, default=None)
    parser.add_argument("--testcase", type=str, default=None)
    parser.add_argument("--run-id", type=str, default=None)
    return parser.parse_args()


_cli_args = _parse_cli_args()
_cli_config_kwargs = {
    field: getattr(_cli_args, field)
    for field in _CONFIG_FIELDS
    if getattr(_cli_args, field) is not None
}
if _cli_config_kwargs or _cli_args.seed is not None or _cli_args.testcase is not None:
    CONFIGS = [Config(**_cli_config_kwargs)]
    if _cli_args.seed is not None:
        SEED = _cli_args.seed
    if _cli_args.testcase is not None:
        TESTCASE = _cli_args.testcase
# --run-id overrides independently of single-run/sweep mode.
if _cli_args.run_id is not None:
    RUN_ID = _cli_args.run_id

SIM_BUILD = HERE / "sim_build"

# The reusable directory-layout / build-flag rules live in the framework; this
# runner only supplies the values from the CONFIGURATION block above.
LAYOUT = SweepLayout(
    sim=SIM,
    build_root=SIM_BUILD / "build",
    runs_root=SIM_BUILD / "runs" / RUN_ID,
    coverage_dir=SIM_BUILD / "coverage" / RUN_ID,
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
            always=BUILD_ALWAYS_RECOMPILE,
            clean=BUILD_ALWAYS_CLEAR,
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
        rows = parse_results(results_xml)
        return (tag, rows, time.perf_counter() - t0)
    except (SystemExit, RuntimeError):
        return (tag, None, time.perf_counter() - t0)


class _RunTimeout(Exception):
    """Raised by _on_alarm when the run phase exceeds TIMEOUT_S."""


def _on_alarm(signum, frame):
    raise _RunTimeout()


def main() -> int:
    if COVERAGE and SIM != "verilator":
        print(f"coverage: ignored (only supported on verilator, SIM={SIM}).", file=sys.stderr)

    if (BUILD_ALWAYS_RECOMPILE or BUILD_ALWAYS_CLEAR) and SIM != "icarus":
        print("build: BUILD_ALWAYS_RECOMPILE/BUILD_ALWAYS_CLEAR recompile every run; "
              f"only known to be cheap on icarus (~10 ms), may be slow on SIM={SIM}.",
              file=sys.stderr)

    seeds = (
        [SEED] if SEED is not None else [random.randrange(1, 1 << 31) for _ in range(N_SEEDS)]
    )
    if WAVES and MAX_JOBS > 1 and len(seeds) > 1:
        raise AssertionError(
            "WAVES=True with MAX_JOBS>1 and multiple seeds: parallel seeds of "
            "the same config share one build dir, so their waveform dumps "
            "overwrite each other. Set MAX_JOBS=1 or use a single seed.")

    print(f"SIM={SIM} WHITEBOX={WHITEBOX} WAVES={WAVES} COVERAGE={COVERAGE} "
          f"MAX_JOBS={MAX_JOBS} RUN_ID={RUN_ID}")
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
    completed_tags: set[str] = set()
    timed_out = False
    # SIGALRM (not a per-yield elapsed check) so the deadline fires even if
    # every job hangs and dispatch() never yields a single result. Letting the
    # exception unwind out of the for-loop drops dispatch()'s generator, which
    # runs its own finally (kills worker process groups by PID) — same
    # teardown path already relied on below for KeyboardInterrupt.
    signal.signal(signal.SIGALRM, _on_alarm)
    signal.alarm(TIMEOUT_S)
    try:
        for tag, rows, secs in dispatch(run_config, jobs, max_jobs=MAX_JOBS,
                                        label=run_tag):
            completed_tags.add(tag)
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
    except _RunTimeout:
        timed_out = True
    finally:
        signal.alarm(0)

    if timed_out:
        print(
            "\nTest suite timed out. Before increasing the timeout, double "
            "check you're not hitting a stall (e.g. a hung simulator "
            "process) rather than genuinely needing more time.",
            file=sys.stderr,
        )
        for job in jobs:
            tag = run_tag(job)
            if tag not in completed_tags:
                results.append(("FAIL", tag, 0, 0, 0))
                print(f"FAIL  {tag:<{align}}(timed out)")

    print_analysis(counts, failures, skips, RUNS_ROOT)

    if COVERAGE and SIM == "verilator":
        merge_and_report_coverage(LAYOUT.runs_root, LAYOUT.coverage_dir)

    fail_total = sum(1 for status, *_ in results if status == "FAIL")
    if fail_total:
        print(f"\nSWEEP RESULT: {fail_total} config-run(s) FAILED")
    else:
        print(f"\nSWEEP RESULT: all {len(results)} config-run(s) PASSED")

    total_tests = sum(ntests for _, _, ntests, _, _ in results)
    total_failed = sum(nfailed for _, _, _, nfailed, _ in results)
    total_skipped = sum(nskipped for _, _, _, _, nskipped in results)
    total_passed = total_tests - total_failed - total_skipped
    skip_note = f" ({total_skipped} skipped)" if total_skipped else ""
    print(f"\nSummary: {total_passed} tests passed, {total_failed} tests "
          f"failed{skip_note}. Hint: run 'view_waveform' from this directory "
          f"to browse PASS/FAIL runs and jump straight to a failure's "
          f"waveform marker.")

    return 1 if fail_total else 0


if __name__ == "__main__":
    sys.exit(main())
