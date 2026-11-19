"""Waveform failure-marker (Tier 1): auto-park GTKWave at every failure moment.

Hooked from :mod:`framework.scoreboard` (at each mismatch) and
``tb_env.wait_idle`` (on timeout) via :func:`record_anchor`, called from
inside the running test with no decorator involved -- tests stay plain
``@cocotb.test()``. Each call appends to a list of anchors for the
currently-running test in ``wave_markers.json`` (cwd), so a test with several
mismatches gets a marker for every one of them, not just the first.
``write_gtkwave_tcl`` turns that list into a small Tcl script that, run via
``gtkwave dump.fst -S script.tcl``, parks GTKWave's primary cursor at the
first anchor and drops a click-proof named marker (A-Z) at every anchor
(capped at 26 -- GTKWave has no more), zoomed to a window spanning all of
them.

Generic: nothing here knows about any particular DUT or testbench.

``write_gtkwave_tcl`` deliberately does no cocotb import and needs no live
simulator: it is called from a later, separate Python process (well after the
simulator has exited -- see ``framework.view_waveform``), and
``cocotb.utils.get_sim_steps`` silently returns nonsense outside a running
simulation (it falls back to an assumed 1fs precision instead of the DUT's
real one). So the ns-per-step conversion factor is captured once, inside the
simulation where the real precision is known (:func:`record_anchor`, at
marker-write time), and stored in ``wave_markers.json`` alongside the
anchors -- ``write_gtkwave_tcl`` then only does plain arithmetic with it.
"""

from __future__ import annotations

import json
import os
import string
from pathlib import Path

MARKERS_FILE = "wave_markers.json"


def record_anchor(sim_time):
    """Append one waveform-marker anchor for the currently-running test.

    Called at the moment something interesting happens (a scoreboard
    mismatch, a wait timeout) -- *before* any exception necessarily exists --
    so the marker lands at the real bug time rather than wherever a later
    ``raise`` happens to unwind to.

    Test name comes from ``cocotb.task.current_task().get_name()`` (public
    API, ``versionadded 2.0``), which cocotb sets to ``"Test <name>"`` for the
    top-level test coroutine -- strip the prefix. cwd is the run's
    ``test_dir`` under cocotb's runner, so ``wave_markers.json`` lands next to
    ``results.xml`` and ``dump.fst`` with no path plumbing needed.
    Read-modify-write is safe here: one vvp process, one asyncio loop, tests
    run sequentially within it -- no concurrent writers.
    """
    import cocotb
    from cocotb.utils import get_sim_steps

    name = cocotb.task.current_task().get_name()
    if name.startswith("Test "):
        name = name[len("Test "):]

    markers = {}
    if os.path.exists(MARKERS_FILE):
        try:
            with open(MARKERS_FILE) as f:
                markers = json.load(f)
        except (json.JSONDecodeError, OSError):
            markers = {}
    entry = markers.setdefault(name, {"anchors": [], "steps_per_ns": None})
    entry["anchors"].append(int(sim_time))
    # Steps-per-ns while the simulator's real time precision is known (see
    # module docstring) -- lets write_gtkwave_tcl convert its before/after
    # window to native steps with no simulator involved. Same value every
    # call within one run; cheap to just re-store it.
    entry["steps_per_ns"] = get_sim_steps(1, "ns", round_mode="round")
    markers[name] = entry
    with open(MARKERS_FILE, "w") as f:
        json.dump(markers, f, indent=2)


def write_gtkwave_tcl(out_path, anchors, *, steps_per_ns=None, before_us=5,
                       after_us=1, signals=None, extra_tcl_path=None):
    """Write a Tcl script that, run via ``gtkwave dump.fst -S <out_path>``,
    parks GTKWave's primary cursor at the first anchor, drops a click-proof
    named marker (A-Z) at every anchor (up to 26), and zooms to
    ``[anchors[0] - before_us, anchors[-1] + after_us]``.

    ``anchors`` and ``steps_per_ns`` are the dump's native simulator time
    steps and steps-per-nanosecond ratio (both as recorded by
    :func:`record_anchor` while the simulator's real time precision was known
    -- see module docstring for why this can't be recomputed here). Both may
    be falsy/``None`` (a markerless run) as long as ``extra_tcl_path`` is
    given -- the marker/zoom commands are then just skipped.

    GTKWave's Tcl marker/zoom commands (``setMarker``, ``setNamedMarker``,
    ``setZoomRangeTimes``) always take picoseconds, regardless of the dump's
    own native tick resolution (confirmed empirically via
    ``gtkwave::signalChangeList`` against a real FST) -- so ``anchors`` must
    be converted from simulator steps to picoseconds using ``steps_per_ns``
    before being written out.

    ``extra_tcl_path``, if given, is a user-authored Tcl file whose contents
    are appended verbatim as the last lines of the script -- after markers
    and zoom, so it can freely override the auto-generated zoom range or add
    its own signals/formatting. Raises if the path doesn't exist.
    """
    lines = []
    if anchors:
        ps_per_step = 1000 / steps_per_ns
        before_ps = round(before_us * 1_000_000)
        after_ps = round(after_us * 1_000_000)
        anchors_ps = [round(int(a) * ps_per_step) for a in anchors]
        first, last = anchors_ps[0], anchors_ps[-1]

        if signals:
            sig_list = " ".join(signals)
            lines.append(f"gtkwave::addSignalsFromList {{{sig_list}}}")
        lines.append(f"gtkwave::setMarker {first}")
        for letter, t in zip(string.ascii_uppercase, anchors_ps):
            lines.append(f"gtkwave::setNamedMarker {letter} {t}")
        lines.append(
            f"gtkwave::setZoomRangeTimes {max(first - before_ps, 0)} "
            f"{last + after_ps}")

    if extra_tcl_path is not None:
        extra_tcl_path = Path(extra_tcl_path)
        if not extra_tcl_path.exists():
            raise FileNotFoundError(
                f"--post-markers-tcl file not found: {extra_tcl_path}")
        lines.append(extra_tcl_path.read_text().rstrip("\n"))

    if not lines:
        raise ValueError("nothing to write: no anchors and no extra_tcl_path")
    with open(out_path, "w") as f:
        f.write("\n".join(lines) + "\n")
