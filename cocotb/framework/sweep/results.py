"""Parse cocotb JUnit XML and print the sweep's TEST ANALYSIS block.

All IP-agnostic: a test is identified only by its name, a run only by its tag.
:func:`parse_results` turns one results file into ``(name, ran, failed)`` rows;
the ``print_*`` helpers render the cross-run tally the runner accumulates.
"""

from __future__ import annotations
from collections import defaultdict

import xml.etree.ElementTree as ET


def parse_results(xml_path) -> list[tuple[str, bool, bool]]:
    """Return [(name, ran, failed)] from a cocotb JUnit XML.

    cocotb emits one <testcase> per test with no aggregate counts, so tally them
    here: skipped tests carry a <skipped/> child, failed ones a <failure/>.
    """
    rows = []
    for tc in ET.parse(xml_path).getroot().iter("testcase"):
        skipped = tc.find("skipped") is not None
        failed = tc.find("failure") is not None
        rows.append((tc.get("name"), not skipped, failed))
    return rows


def print_execution_counts(counts: dict[str, int]) -> None:
    """Per-test run tally, most-run first; flag tests skipped in every run."""
    if not counts:
        return
    print("EXECUTION COUNTS")
    for name, n in sorted(counts.items(), key=lambda kv: kv[1], reverse=True):
        flag = "   NEVER EXECUTED" if n == 0 else ""
        print(f"  {name:<48} {n}{flag}")


def print_tests_with_runs(title: str, tests: dict[str, list[str]]) -> None:
    """Print 'test on runs:' blocks — used for both FAILURES and SKIPPED TESTS."""
    if not tests:
        return
    print(f"\n{title}")
    for name in sorted(tests):
        print(f"  {name} on runs:")
        # group each tag by its run prefix, collecting the seeds
        seeds_by_run = defaultdict(list)
        for tag in tests[name]:
            run, seed = tag.split("_seed")
            seeds_by_run[run].append(int(seed))
        for run in sorted(seeds_by_run):
            seeds = sorted(seeds_by_run[run])
            print(f"    {run} on seeds {seeds}")


def print_analysis(counts, failures, skips, runs_root) -> None:
    """The TEST ANALYSIS block: counts, then which tests failed/skipped where."""
    print("\n" + "=" * 17 + " TEST ANALYSIS " + "=" * 17)
    print_execution_counts(counts)
    print_tests_with_runs("FAILURES", failures)
    print_tests_with_runs("SKIPPED TESTS", skips)
    print(f"\nPer-run logs and results under: {runs_root}")
