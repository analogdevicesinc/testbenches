# cocotb Verification Framework

Simulator-agnostic cocotb testbenches for ADI IP unit verification.

## Layout

```
cocotb/
├── framework/              # Reusable across ALL IPs
│   ├── paths.py            # repo path anchors (REPO_ROOT, COCOTB_DIR)
│   ├── axi_stream.py       # valid/ready stream driver & monitor
│   ├── backpressure.py     # random *ready toggling strategies
│   ├── reset.py            # random reset injection + reset-value checks
│   ├── scoreboard.py       # expected-vs-actual comparison
│   ├── random_ctx.py       # single-seed reproducible randomness
│   ├── wave_marker.py      # record failure-time waveform anchors + GTKWave Tcl
│   ├── view_waveform.py    # browse PASS/FAIL runs, open a failure's waveform
│   ├── sweep/              # multi-config build→run→report harness (any IP/sim)
│   │   ├── layout.py       # SweepLayout: build/run/coverage dir addressing + flags
│   │   ├── dispatch.py     # parallel job runner with process-group teardown
│   │   ├── results.py      # cocotb JUnit XML parse + TEST ANALYSIS reporting
│   │   └── coverage.py     # merge per-run Verilator coverage into one dataset
│   └── spi/                # SPI-specific (reusable for any SPI IP)
│       ├── instructions.py # 16-bit SPI Engine command encoder
│       ├── bus_monitor.py  # passive SPI bus watcher (SDO/SCLK/CS)
│       └── slave_model.py  # SPI slave BFM (drives SDI)
├── pyproject.toml          # `framework` as an installable package; `view_waveform` script
└── requirements.txt
```

Per-IP tests live under `../testbenches/ip/<ip>/<module>/`, each with its own
README covering how to run and sweep that module. An IP's `runner.py` supplies
only the DUT-specific parts — sources, toplevel, test modules, generics, per-run
env — and drives the `framework.sweep` helpers for everything else.

`framework` is pip-installed editable (`pip install -e cocotb/`) into the
venv used to run tests, so `import framework` and the `view_waveform` command
both work with no manual `sys.path`/`PYTHONPATH` setup.

## Waveform failure markers

Tests use plain `@cocotb.test()`. `framework.scoreboard` (at every mismatch)
and each TB's `wait_idle()`-style timeout path call
`framework.wave_marker.record_anchor(sim_time)` from inside
the running test. This appends to a per-test list of anchors in
`wave_markers.json` (written next to that run's `results.xml`), so a test with
several mismatches gets a marker for *every* occurrence, not just the first:

```json
{
  "test_name": {"anchors": [141204, 189532], "steps_per_ns": 10}
}
```

`write_gtkwave_tcl` turns one test's anchor list into a Tcl script that, run
via `gtkwave dump.fst -S script.tcl`:
- parks GTKWave's primary (unnamed) cursor at the first anchor — this one
  moves if you click in the waveform pane;
- drops a **named marker** (`A`, `B`, ... up to `Z`) at every anchor — these
  are click-proof, so they stay put while you explore the trace;
- zooms to a window spanning all the anchors (with padding before the first
  and after the last).

### Browsing runs: `view_waveform`

From an IP's testbench dir (where its `runner.py` lives, after running it):

```sh
view_waveform            # list every run: stable index, PASS/FAIL, failing tests
view_waveform F003       # open that run's waveform, pre-marked at its failure(s)
```

PASS/FAIL comes from the run's actual parsed JUnit results, not from
`wave_markers.json` presence — a test can fail without ever touching the
scoreboard (a hang, a crash). If a failing test never recorded an anchor, the
waveform still opens, just without the marker script.
