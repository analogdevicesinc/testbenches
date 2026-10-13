# SPI Engine — `execution` unit testbench

**Important notice:** this is a POC / experiment for IP/Unit testing using CocoTB.
This branch/PR might suffer drastic changes in a short window of time.
Consider it experimental and unstable.

A cocotb testbench that drives the DUT with the real 16-bit SPI Engine command
stream and checks every SPI-bus and SDI-return transaction against an
independent Python golden model.

Layered:
- reusable, IP-agnostic framework (`cocotb/framework/`)
- reusable SPI layer (`cocotb/framework/spi/`)
- DUT-specific tier (harness + golden model + `test_*.py`)


# Running the TB
## Initial setup

Prerequisites:
- Python venv with dependencies
- Verilator ≥ 5.0 (cocotb 2.0 `--timing`; distro 4.x won't work)
- Optional: Icarus Verilog ≥ 11 (event-sim cross-check)
- Optional: `lcov` package for HTML coverage report

One-time install:

```bash
# 1. Verilator from source, to a local prefix:
cd PATH_TO_INSTALL_VERILATOR
git clone https://github.com/verilator/verilator && cd verilator
git checkout v5.026
autoconf && ./configure --prefix=$HOME/.local/verilator && make -j"$(nproc)" && make install

# 2. Python venv + deps, at the testbenches_repo/ root (holds cocotb/ and testbenches/):
cd PATH_TO_STORE_VENV
python3 -m venv .venv && . .venv/bin/activate
pip install -r cocotb/requirements.txt        # cocotb 2.0.1, cocotb-bus

# 3. Optional tools:
sudo apt install iverilog lcov                 # Icarus sim + genhtml for coverage
```

Add helper function to your `~/.bash_aliases`

```bash
# ~/.bash_aliases
function activate_cocotb() {
    local venv_path=<PATH_TO_VENV>
    local verilator_path=<PATH_TO_VERILATOR>
    export PATH="$verilator_path/bin:$PATH"
    export VERILATOR_ROOT="$verilator_path/share/verilator"
    source "$venv_path/bin/activate"
    echo "cocotb:    $(python -c 'import cocotb; print(cocotb.__version__)' 2>/dev/null || echo MISSING)"
    echo "verilator: $(verilator --version 2>/dev/null || echo MISSING)"
}
```

## Running tests

`runner.py` is the single entry point — it owns the build (sources, generics,
compile flags), the config sweep, seeds, parallelism, and result aggregation.
It takes no arguments. The full routine per shell:

```bash
activate_cocotb
export ADI_HDL_DIR=/path/to/hdl
cd testbenches/ip/spi_engine/execution   # from the testbenches_repo root
python3 runner.py
```

It builds every config once (cached, so re-runs skip unchanged builds), runs the
suite across configs × seeds in parallel, and prints a live `RUN RESULTS` list
followed by a `TEST ANALYSIS` (execution counts, and which tests failed/skipped
on which runs).
Per-run logs and results land under `sim_build/runs/<RUN_ID>/`.

### Run Configurations / Run a single Config / Reproduce one run

Everything a user changes lives in the `CONFIGURATION` block at the top of
`runner.py` (the sweep, seed count, `SIM`, `MAX_JOBS`, coverage, etc. — each
commented in place; skim it).

Comment out the default `CONFIGS` list and add your own single entry, then
optionally pin `SEED` (to a value the summary logged) and `TESTCASE`:

```python
CONFIGS = [Config(data_width=32, num_of_sdio=4, default_clk_div=2)]
SEED = 1587325506
TESTCASE = "test_sdi_handshake_stability"
```

Leave `SEED`/`TESTCASE` as `None` for the normal random sweep over the full suite.
Set `MAX_JOBS = 1` for a serial run with live simulator output (debugging);
set `RUN_ID` to keep concurrent runs (e.g. separate agents) in separate dirs.

### Simulator choice (`SIM`)

The two supported simulators trade off differently:

- **Icarus** compiles the SystemVerilog faster (lighter elaboration).
- **Verilator** executes the simulation faster — higher simulated ns per second of
  wall-clock time

So Icarus wins for a quick one-off, while Verilator wins for long runs and the
multi-seed sweep, where run time dominates the one-time compile cost.

- Changing defaults to 8 parallel jobs + 10 random seeds:
  - full-suite wall-clock time on Icarus: 0m47s (of which 0.0s compiling)
  - full-suite wall-clock time on Verilator: 1m03s (of which 29.5s compiling)

## Checking code coverage (verilator only)

Coverage is Verilator-only (no effect under `SIM=icarus`).

Set `COVERAGE = True` in `runner.py` and run it. Each run writes its own
`coverage.dat`; the runner merges them into `sim_build/coverage/<RUN_ID>/merged.dat`
— the union of RTL reached across all generics (the 4-CS and 4-lane paths only
some configs hit). The script prints the view commands at the end; the two ways
to read `merged.dat`:

```bash
DAT=sim_build/coverage/run/merged.dat

# annotated source (no extra tools): '%'-prefixed lines are under threshold
verilator_coverage --annotate cov_annotated --annotate-min 1 $DAT
grep -rn "^%" cov_annotated/

# HTML report (needs lcov): browsable per-file line coverage at cov_html/index.html
verilator_coverage --write-info coverage.info $DAT
genhtml coverage.info -o cov_html
```

`genhtml` reads absolute RTL paths from `coverage.info`, so run it on the same
machine as the sim (the `hdl_repo` sources must exist at those paths).

# TB Philosophy

## The problem

- RTL predates TB, as such LLMs tend to represent the RTL literally in the TB
- If RTL has a bug, the bug is modeled into the TB and thus isn't caught
- Literal representation of the RTL ties implementation to TB, changing one breaks the other

## Proposed solution

Propose a requirement driven clean room framework. Lets break this down...

### Requirements

- Atomic text description of each behaviour the IP should have
  - atomic: each behaviour is small and can be simply represented
    - implementation: one always block/assignment per requirement
    - testbench: one testcase per requirement
- What/Why/How methodology: helps humans and LLMs understand the codebase
  - Requirements describe the What/Why
  - RTL explains the How
- Easy bidirectional traceability (greppable comments in RTL/TB)
  - Better navigation between documentation, implementation and verification (V-model)

### Clean room

- RTL predates the testbench and often predates the docs and SW drivers
  - Hard to acquire RTL independent ground truth to produce TB/Test cases
- As such, use an LLM session to derive behavioural (black box) requirements of the IP
  - As independent from implementation as possible
  - HDL docs and SW Drivers can corroborate to the requirements
- From the requirements, a new LLM session produces the behavioural implementation-independent testcases

### Framework

- A set of guidelines were produced to guide the LLM sessions and
allow this procedure to be easily replicated for other IPs.

Proposed flow:

1. Using the [requirements guideline](./doc/guideline_for_writing_requirements.md)
have LLM produce requirements from docs, SW drivers and RTL
2. Human validation of requirements
3. With requirements, ask LLM to draft TB architecture and organization
4. Human validation of TB/TC architecture
5. Using the [testcase guideline](./doc/guideline_for_writing_testcases.md)
and the proposed architecture, have LLM produce the TB/testcases
6. Human validation of the testbench

### LLM Friendlyness

- Mixture of natural language description (requirements) with code (RTL) help
LLMs understand and implement tasks
- Atomic greppable requirements result in smaller context windows
- Test cases that target specific requirements allow LLMs to validate their
work and loop
