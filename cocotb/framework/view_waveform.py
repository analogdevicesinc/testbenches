"""Browse a sweep's PASS/FAIL runs and jump straight to a failure's waveform.

Run with no arguments from an IP's testbench dir (where its ``runner.py``
lives) to list every run under ``sim_build/runs`` with a stable index
(``P001``, ``F002``, ...) and its PASS/FAIL status -- taken from the run's
parsed JUnit results, *not* from ``wave_markers.json`` presence, since a test
can fail without ever touching the scoreboard (a hang, a crash). Run again
with one of those indices, *or* with the literal ``--run-id`` string given to
``runner.py`` (e.g. ``bug01_d88d9cacd``), to open that run's waveform dump in
GTKWave -- the run-id form is stable across invocations (unlike P.../F...,
which are reassigned fresh each run based on what else is under
``sim_build/runs``), so it's the form to use in docs/scripts that reference a
specific run. If any
of the run's failing tests recorded anchors (see :mod:`framework.wave_marker`),
they're combined into a throwaway Tcl script and passed via ``-S`` so GTKWave
opens already zoomed and marked at the failure(s); otherwise the dump opens
bare. Pass ``--post-markers-tcl <path>`` to append a user-authored Tcl file
after the generated markers/zoom commands (e.g. to pre-add signals); this
still applies even on a markerless run.

IP-agnostic: relies only on the ``sim_build/runs/<run_id>/<tag>/`` layout that
:class:`framework.sweep.layout.SweepLayout` already imposes, plus whatever
``results.xml``/``dump.fst``/``wave_markers.json`` a run directory happens to
contain.
"""

from __future__ import annotations

import argparse
import json
import re
import subprocess
import sys
from pathlib import Path

from framework.sweep.results import parse_results
from framework.wave_marker import MARKERS_FILE, write_gtkwave_tcl

RUNS_GLOB = "sim_build/runs/*/*"
INDEX_RE = re.compile(r"^[PF]\d+$", re.IGNORECASE)


def _discover_runs(root: Path) -> list[tuple[Path, str, list[str]]]:
    """Return (run_dir, status, failed_test_names) for every run under root.

    A run with no ``results.xml`` (sim crashed or timed out before writing
    it) counts as FAIL with no known failing test names.
    """
    runs = []
    for run_dir in sorted(root.glob(RUNS_GLOB)):
        if not run_dir.is_dir():
            continue
        results_xml = run_dir / "results.xml"
        if not results_xml.exists():
            runs.append((run_dir, "FAIL", []))
            continue
        rows = parse_results(results_xml)
        failed = [name for name, _ran, failed in rows if failed]
        runs.append((run_dir, "FAIL" if failed else "PASS", failed))
    return runs


def _assign_indices(runs) -> dict[str, tuple[Path, str, list[str]]]:
    """Stable P.../F... indices, numbered separately in run_dir sort order."""
    indexed = {}
    counters = {"PASS": 0, "FAIL": 0}
    for run_dir, status, failed in runs:
        counters[status] += 1
        idx = f"{status[0]}{counters[status]:03d}"
        indexed[idx] = (run_dir, status, failed)
    return indexed


def _print_index(indexed) -> None:
    for idx in sorted(indexed, key=lambda k: (k[0], int(k[1:]))):
        run_dir, status, failed = indexed[idx]
        detail = f"  ({', '.join(failed)})" if failed else ""
        print(f"{idx}  {status}  {run_dir.name}{detail}")


def _runs_for_run_id(runs, run_id: str):
    """Runs whose runner.py --run-id (the sim_build/runs/<run_id>/ level)
    matches literally. A run-id can have more than one tag dir under it (e.g.
    separate seeds/configs run under the same --run-id)."""
    return [r for r in runs if r[0].parent.name == run_id]


def _fst_path(run_dir: Path) -> Path:
    """Locate the run's waveform dump.

    Some simulators (e.g. Icarus via this framework) dump into the *build*
    dir rather than the run dir, since the dump file lives relative to the
    simulator's cwd and build dirs are content- (not identity-) addressed --
    see the WAVES/MAX_JOBS note in an IP's ``runner.py``. Fall back to
    searching ``sim_build/build`` for the dir matching this run's config name
    when nothing turns up alongside ``results.xml``.
    """
    dumps = sorted(run_dir.glob("*.fst"))
    if dumps:
        return dumps[0]
    config_name = run_dir.name.rsplit("_seed", 1)[0]
    build_root = run_dir.parent.parent.parent / "build"
    if build_root.is_dir():
        for build_dir in sorted(build_root.iterdir()):
            if config_name in build_dir.name:
                dumps = sorted(build_dir.glob("*.fst"))
                if dumps:
                    return dumps[0]
    raise FileNotFoundError(f"no .fst waveform dump for {run_dir}")


def _anchors_for(run_dir: Path, failed_tests: list[str]):
    """Combined (sorted) anchors + steps_per_ns for every failing test that
    recorded one, or (None, None) if none did."""
    markers_path = run_dir / MARKERS_FILE
    if not markers_path.exists():
        return None, None
    with open(markers_path) as f:
        markers = json.load(f)
    anchors: list[int] = []
    steps_per_ns = None
    for name in failed_tests:
        entry = markers.get(name) or {}
        entry_anchors = entry.get("anchors")
        if entry_anchors:
            anchors.extend(entry_anchors)
            steps_per_ns = entry.get("steps_per_ns")
    if not anchors:
        return None, None
    return sorted(anchors), steps_per_ns


def _open_run(run_dir: Path, failed_tests: list[str],
              post_markers_tcl: Path | None = None) -> None:
    fst = _fst_path(run_dir)
    anchors, steps_per_ns = _anchors_for(run_dir, failed_tests)
    if anchors is None and post_markers_tcl is None:
        subprocess.run(["gtkwave", str(fst)], check=False)
        return
    tcl_path = run_dir / "_view_waveform.tcl"
    write_gtkwave_tcl(tcl_path, anchors, steps_per_ns=steps_per_ns,
                       extra_tcl_path=post_markers_tcl)
    subprocess.run(["gtkwave", str(fst), "-S", str(tcl_path)], check=False)


def main(argv: list[str] | None = None) -> int:
    argv = sys.argv[1:] if argv is None else argv
    parser = argparse.ArgumentParser(
        description="List or open a sweep's PASS/FAIL runs in GTKWave.")
    parser.add_argument(
        "run_id", nargs="?", default=None,
        help="Run index (e.g. F001) or the literal --run-id string given to "
             "runner.py (e.g. bug01_d88d9cacd); omit to list all runs.")
    parser.add_argument(
        "--post-markers-tcl", type=Path, default=None,
        help="Tcl file appended after the auto-generated markers/zoom "
             "commands. Applied even on markerless runs.")
    args = parser.parse_args(argv)

    if args.post_markers_tcl is not None and not args.post_markers_tcl.exists():
        print(f"--post-markers-tcl file not found: {args.post_markers_tcl}",
              file=sys.stderr)
        return 1

    root = Path.cwd()
    runs = _discover_runs(root)
    if not runs:
        print(f"No runs found under {root / 'sim_build' / 'runs'} "
              f"-- run this from the testbench dir after running its runner.py.",
              file=sys.stderr)
        return 1
    indexed = _assign_indices(runs)

    if args.run_id is None:
        _print_index(indexed)
        return 0

    if INDEX_RE.match(args.run_id):
        idx = args.run_id.upper()
        entry = indexed.get(idx)
        if entry is None:
            print(f"Unknown run index {args.run_id!r}. Run with no arguments to "
                  f"list valid indices.", file=sys.stderr)
            return 1
        run_dir, _status, failed_tests = entry
    else:
        matches = _runs_for_run_id(runs, args.run_id)
        if not matches:
            known_ids = sorted({r[0].parent.name for r in runs})
            print(f"Unknown run-id {args.run_id!r}. Known run-ids: "
                  f"{', '.join(known_ids) or '(none)'}. Run with no arguments "
                  f"to list indices instead.", file=sys.stderr)
            return 1
        if len(matches) > 1:
            matches = sorted(matches, key=lambda r: r[0].stat().st_mtime,
                              reverse=True)
            others = ", ".join(m[0].name for m in matches[1:])
            print(f"Multiple tags under run-id {args.run_id!r}; using most "
                  f"recent ({matches[0][0].name}). Others: {others}",
                  file=sys.stderr)
        run_dir, _status, failed_tests = matches[0]

    _open_run(run_dir, failed_tests, post_markers_tcl=args.post_markers_tcl)
    return 0


if __name__ == "__main__":
    sys.exit(main())
