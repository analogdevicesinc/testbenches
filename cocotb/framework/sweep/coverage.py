"""Merge per-run Verilator coverage into one dataset and print how to view it.

Merging across configs is deliberate: each generic combo reaches different RTL
(e.g. the 4-CS or 4-lane paths), so the union over the whole sweep is the
meaningful coverage number. Verilator-specific but IP-agnostic; skips cleanly
if the tools or ``.dat`` files are missing.
"""

from __future__ import annotations

import shutil
import subprocess
import sys
from pathlib import Path


def merge_and_report_coverage(runs_root: Path, coverage_dir: Path) -> None:
    """Merge every ``<runs_root>/*/coverage.dat`` and print viewing instructions.

    Collects each run's ``coverage.dat`` under ``runs_root``, merges them into
    ``coverage_dir/merged.dat`` with ``verilator_coverage``, and prints the
    commands to annotate/export the result. No-op with a note if there is
    nothing to merge or the tool is absent.
    """
    dats = sorted(runs_root.glob("*/coverage.dat"))
    if not dats:
        print("coverage: no coverage.dat collected (Verilator only) — skipping.",
              file=sys.stderr)
        return
    if not shutil.which("verilator_coverage"):
        print("coverage: verilator_coverage not on PATH; per-run .dat files are "
              f"under {runs_root} — merge them manually.", file=sys.stderr)
        return

    coverage_dir.mkdir(parents=True, exist_ok=True)
    merged = coverage_dir / "merged.dat"
    subprocess.run(["verilator_coverage", "--write", str(merged), *map(str, dats)],
                   check=True)
    print(f"\ncoverage: merged {len(dats)} run(s) -> {merged}")
    print("view it with:")
    print(f"  verilator_coverage --annotate cov_annotated --annotate-min 1 {merged}")
    print("  grep -rn '^%' cov_annotated/          # never-hit lines")
    print(f"  verilator_coverage --write-info coverage.info {merged}")
    print("  genhtml coverage.info -o cov_html     # -> cov_html/index.html (needs lcov)")
