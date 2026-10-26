"""Directory layout and build flags for a multi-config simulation sweep.

``build_dir_for``/``run_dir_for``/``build_args`` in an IP runner all read the
same handful of values (simulator, dir roots, coverage/waves toggles). Bundling
them into one :class:`SweepLayout` keeps those addressing rules in one place and
spares every runner from threading the same six arguments around.

Two addressing schemes, deliberately different:
  * build dirs are *content-addressed* — same (sim, config-name, instrumentation)
    maps to the same dir, so an unchanged config reuses its binary and configs
    with differing generics never collide on a stale one;
  * run dirs are *identity-addressed* — unique per (config-name, seed), so no two
    runs write the same results/coverage file. This is what makes parallel and
    multi-agent runs safe.

``name`` is any DUT-generic string the caller uses to identify a config (e.g.
``"dw8_cs1_sd1"``); this module never interprets it.
"""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path


@dataclass(frozen=True)
class SweepLayout:
    """Where a sweep's build/run/coverage artifacts live, and how it compiles.

    Parameters
    ----------
    sim         : simulator name ("verilator" | "icarus")
    build_root  : parent of all per-config build dirs
    runs_root   : parent of all per-run dirs
    coverage_dir: destination for the merged coverage dataset
    coverage    : compile with Verilator line coverage instrumentation
    waves       : dump waveforms per run
    verilator_build_args / icarus_build_args : extra per-sim compile flags
        (generics and ``--coverage`` are added elsewhere / automatically)
    """
    sim: str
    build_root: Path
    runs_root: Path
    coverage_dir: Path
    coverage: bool = False
    waves: bool = False
    verilator_build_args: tuple[str, ...] = ()
    icarus_build_args: tuple[str, ...] = ()

    @property
    def instr(self) -> str:
        """Instrumentation suffix so instrumented builds don't reuse plain ones."""
        return ("_cov" if self.coverage else "") + ("_wave" if self.waves else "")

    def build_dir(self, name: str) -> Path:
        """Content-addressed: same (sim, name, instrumentation) -> same binary."""
        return self.build_root / f"{self.sim}_{name}{self.instr}"

    def run_dir(self, name: str, seed: int) -> Path:
        """Identity-addressed: unique per run, so parallel workers never clash."""
        return self.runs_root / f"{name}_seed{seed}"

    def build_args(self) -> list[str]:
        """Per-sim compile flags, adding ``--coverage`` when instrumenting."""
        args = list(self.verilator_build_args if self.sim == "verilator"
                    else self.icarus_build_args)
        if self.coverage and self.sim == "verilator":
            # Compile-time instrumentation; the run binary rejects --coverage.
            args.append("--coverage")
        return args
