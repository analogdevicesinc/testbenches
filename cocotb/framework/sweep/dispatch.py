"""Parallel job dispatch with clean process-group teardown.

:func:`dispatch` runs a function over a list of jobs, yielding results as they
finish, and guarantees that on any exit — Ctrl+C, ``break``, exception — the
worker processes and the simulator children they spawn are all killed by process
group so nothing leaks. It is simulator- and IP-agnostic: give it a callable and
a list of argument tuples.
"""

from __future__ import annotations

import os
import signal
import sys
from concurrent.futures import ProcessPoolExecutor, as_completed
from contextlib import suppress


def _new_process_group() -> None:
    # Worker becomes its own group leader so we can signal it AND the simulator
    # child it spawns with one killpg — nothing survives an interrupt.
    os.setpgrp()


def _kill_pool(ex: ProcessPoolExecutor) -> None:
    for proc in ex._processes.values():
        with suppress(ProcessLookupError, PermissionError):
            os.killpg(proc.pid, signal.SIGKILL)


def dispatch(fn, jobs, *, max_jobs, label=None):
    """Yield ``fn(*job)`` results as they finish; parallel when ``max_jobs`` > 1.

    A generator so callers can show progress live. On any exit — Ctrl+C, break,
    exception — the workers and the simulator children they spawned are killed
    by process group, so nothing leaks. shutdown(wait=False) because a hung sim
    must not block teardown. ``label(job)`` names the in-flight jobs on interrupt.
    """
    if max_jobs <= 1:
        for job in jobs:
            yield fn(*job)
        return
    ex = ProcessPoolExecutor(max_workers=max_jobs, initializer=_new_process_group)
    pending = {}  # future -> job, dropped as each result is yielded
    try:
        for job in jobs:
            pending[ex.submit(fn, *job)] = job
        for fut in as_completed(list(pending)):
            del pending[fut]
            yield fut.result()
    finally:
        if label:
            for fut, job in pending.items():
                if fut.running():
                    print(f"Aborting {label(job)}...", file=sys.stderr)
        _kill_pool(ex)
        ex.shutdown(wait=False, cancel_futures=True)
