"""Multi-config build -> run -> report sweep harness (IP- and sim-agnostic).

The reusable machinery behind an IP runner: how build/run dirs are addressed
(:class:`SweepLayout`), how jobs are dispatched in parallel with clean teardown
(:func:`dispatch`), how cocotb results are parsed and reported
(:mod:`~framework.sweep.results`), and how Verilator coverage is merged
(:func:`merge_and_report_coverage`).

An IP runner supplies only the DUT-specific parts — its sources, toplevel, test
modules, generics, and per-run env — and drives these helpers.
"""

from framework.sweep.coverage import merge_and_report_coverage
from framework.sweep.dispatch import dispatch
from framework.sweep.layout import SweepLayout
from framework.sweep.results import (
    parse_results,
    print_analysis,
    print_execution_counts,
    print_tests_with_runs,
)

__all__ = [
    "SweepLayout",
    "dispatch",
    "parse_results",
    "print_analysis",
    "print_execution_counts",
    "print_tests_with_runs",
    "merge_and_report_coverage",
]
