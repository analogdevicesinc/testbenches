"""Central seeded randomness for fully reproducible runs.

Every stochastic decision in a testbench (backpressure toggles, reset timing,
random stimulus) must derive from a single seed so that a failing run can be
replayed bit-for-bit. The seed is read from ``RANDOM_SEED`` when present, else
generated and *logged*.

Usage::

    rc = RandomContext.from_env(dut._log)
    bp_rng = rc.derive("sdo_backpressure")
    rc.log_seed()

Derived generators are independent ``random.Random`` instances seeded from the
master seed plus a stable label hash, so adding a new consumer does not perturb
the streams of existing ones.
"""

from __future__ import annotations

import os
import random
import zlib


class RandomContext:
    def __init__(self, seed: int, logger=None):
        self.seed = int(seed) & 0xFFFFFFFF
        self.logger = logger
        self.master = random.Random(self.seed)
        self._derived: dict[str, random.Random] = {}

    @classmethod
    def from_env(cls, logger=None, var="RANDOM_SEED"):
        raw = os.environ.get(var)
        if raw is not None and raw != "":
            seed = int(raw, 0)
        else:
            seed = random.SystemRandom().randrange(2 ** 32)
        return cls(seed, logger=logger)

    def derive(self, label: str) -> random.Random:
        """Return a stable, independent RNG for a named consumer."""
        if label not in self._derived:
            mixed = (self.seed ^ zlib.crc32(label.encode())) & 0xFFFFFFFF
            self._derived[label] = random.Random(mixed)
        return self._derived[label]

    def log_seed(self):
        msg = (f"RANDOM SEED = {self.seed}  "
               f"(replay with SEED = {self.seed} in runner.py)")
        if self.logger is not None:
            self.logger.info("=" * 60)
            self.logger.info(msg)
            self.logger.info("=" * 60)
        else:
            print(msg)
