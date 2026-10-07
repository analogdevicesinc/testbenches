"""Expected-vs-actual comparison with rich mismatch reporting.

The golden model enqueues *expected* items; monitors enqueue *actual* items.
The scoreboard compares them in order and accumulates failures, so a single
test can report every mismatch instead of dying on the first one.

Two comparison styles are provided:

  * exact data comparison (``add_expected`` / ``add_actual`` queues)
  * timing comparison with a tolerance window (``check_timing``) for the
    cycle-count checks in the hybrid golden model.
"""

from __future__ import annotations

from dataclasses import dataclass, field


@dataclass
class Mismatch:
    index: int
    field: str
    expected: object
    actual: object
    note: str = ""

    def __str__(self):
        s = (f"[#{self.index}] {self.field}: "
             f"expected={self._fmt(self.expected)} actual={self._fmt(self.actual)}")
        if self.note:
            s += f"  ({self.note})"
        return s

    @staticmethod
    def _fmt(v):
        return f"0x{v:x}" if isinstance(v, int) and v >= 0 else repr(v)


class Scoreboard:
    def __init__(self, name="scoreboard", logger=None):
        self.name = name
        self.logger = logger
        self.mismatches: list[Mismatch] = []
        self.compared = 0

    # ---- order-preserving item comparison -------------------------------
    def compare(self, index, field, expected, actual, *, note=""):
        """Compare one field; record a mismatch if unequal. Returns bool ok."""
        self.compared += 1
        if expected != actual:
            m = Mismatch(index, field, expected, actual, note)
            self.mismatches.append(m)
            if self.logger:
                self.logger.error(f"{self.name} MISMATCH {m}")
            return False
        return True

    def compare_within(self, index, field, expected, actual, tol, *, note=""):
        """Compare a numeric field allowing |expected-actual| <= tol."""
        self.compared += 1
        if abs(int(expected) - int(actual)) > tol:
            m = Mismatch(index, field, expected, actual,
                         note=(note + f" tol=±{tol}").strip())
            self.mismatches.append(m)
            if self.logger:
                self.logger.error(f"{self.name} MISMATCH {m}")
            return False
        return True

    def compare_sequences(self, expected, actual, *, field="data"):
        """Compare two ordered sequences element-by-element (and length)."""
        if len(expected) != len(actual):
            m = Mismatch(-1, f"{field}.length", len(expected), len(actual),
                         "sequence length differs")
            self.mismatches.append(m)
            if self.logger:
                self.logger.error(f"{self.name} MISMATCH {m}")
        for i, (e, a) in enumerate(zip(expected, actual)):
            self.compare(i, field, e, a)

    # ---- result ----------------------------------------------------------
    @property
    def passed(self):
        return not self.mismatches

    def assert_no_errors(self):
        if self.mismatches:
            lines = "\n  ".join(str(m) for m in self.mismatches)
            raise AssertionError(
                f"{self.name}: {len(self.mismatches)} mismatch(es) "
                f"out of {self.compared} comparisons:\n  {lines}")
        if self.logger:
            self.logger.info(
                f"{self.name}: all {self.compared} comparisons passed")
