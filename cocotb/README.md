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
│   ├── sweep/              # multi-config build→run→report harness (any IP/sim)
│   │   ├── layout.py       # SweepLayout: build/run/coverage dir addressing + flags
│   │   ├── dispatch.py     # parallel job runner with process-group teardown
│   │   ├── results.py      # cocotb JUnit XML parse + TEST ANALYSIS reporting
│   │   └── coverage.py     # merge per-run Verilator coverage into one dataset
│   └── spi/                # SPI-specific (reusable for any SPI IP)
│       ├── instructions.py # 16-bit SPI Engine command encoder
│       ├── bus_monitor.py  # passive SPI bus watcher (SDO/SCLK/CS)
│       └── slave_model.py  # SPI slave BFM (drives SDI)
└── requirements.txt
```

Per-IP tests live under `../testbenches/ip/<ip>/<module>/`, each with its own
README covering how to run and sweep that module. An IP's `runner.py` supplies
only the DUT-specific parts — sources, toplevel, test modules, generics, per-run
env — and drives the `framework.sweep` helpers for everything else.
