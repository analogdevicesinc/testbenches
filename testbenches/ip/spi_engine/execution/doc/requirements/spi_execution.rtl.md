# SPI Engine Execution Module — Implementation Reference (RTL evidence)

> **This is NOT the specification.** This file holds RTL-level evidence to help a
> designer resolving a flag; the behavioral spec is `doc/spi_execution.spec.md`.

RTL under study (paths relative to `hdl_repo/library/spi_engine/spi_engine_execution/`):

- `spi_engine_execution.v` — top FSM, decoder, timing/counters, SPI outputs
- `spi_engine_execution_shiftreg.v` — SDO/SDI shift registers, SDI latch, ECHO path
- `spi_engine_execution_shiftreg_data_assemble.v` — multi-lane SDO assembly

Line numbers are from the revision read on 2026-07-01; re-verify before quoting.

---

## Flag → RTL evidence

### FLAG EXEC-F1 — `sdi_data` mutates while valid & unaccepted (`div=0`, sub-word backpressure)

Confirmed AXI-Stream payload-stability violation (spec EXEC-FLOW-05). Full root
cause already in memory finding `finding-sdi-handshake-violation`; summarized here:

- `spi_engine_execution_shiftreg.v`, `g_sclk_miso_latch` branch:
  - `sdi_data` is the combinational output of `data_sdi_shift`, which shifts on
    **every** `trigger_rx_s` (~lines 283–293) — ignores valid/ready.
  - `sdi_data_valid` sets on `last_sdi_bit && trigger_rx_s`, clears only on
    `sdi_data_ready` (~lines 308–315).
- `spi_engine_execution.v`: `pending_sdi_data_valid` (~lines 366–372) is driven from
  the **early** `trigger_rx`, while the port output uses the 2-cycle-delayed
  `trigger_rx_s`. The delay mismatch lets the next word shift into `sdi_data` before
  the held beat is accepted.
- **Masked in production:** downstream asymmetric SDI FIFO always asserts ready
  within a word-period.
- **Regression:** `test_backpressure.py::test_sdi_handshake_stability` (`expect_fail`).

### FLAG EXEC-F2 — SDI lane mask has no boundary-visible effect in this module

- `spi_engine_execution.v` ~lines 123–127 (comment) and ~lines 285–287: a
  `REG_SDI_LANE_CONFIG` write only latches `sdi_lane_mask`; the register is **not
  read anywhere** in the execution datapath.
- The comment states the masking effect is downstream: `axi_spi_engine` intercepts
  the same command to configure `sdi_fifo_tkeep_int` on the asymmetric SDI FIFO
  (`util_axis_fifo_asym`).
- Contrast SDO lane mask, which IS used here — see F-none / EXEC-LANE-* evidence
  below.

### FLAG EXEC-F4 — `ECHO_SCLK=1` datapath: build-time-fixed capture edge

- `spi_engine_execution_shiftreg.v`, `g_echo_sclk_miso_latch` generate block
  (~lines 176–275):
  - Edge selection is a **generate-time** decision on `DEFAULT_SPI_CFG[1:0]`:
    modes `2'b01`/`2'b10` → `g_echo_miso_nshift_reg` (negedge `echo_sclk`, ~line
    183); else `g_echo_miso_pshift_reg` (posedge, ~line 217).
  - Because it is `generate`/`if`, a **runtime** CPOL/CPHA change (via
    `REG_CONFIG`) does not re-select the latch edge — EXEC-ECHO-C1.
- Completion path (EXEC-ECHO-C2): `last_sdi_bit` is synchronized to core clock via
  `last_sdi_bit_m` (2FF+edge, ~lines 254–265); `echo_last_bit` is the rising-edge
  detect (~line 265). `transfer_done` uses this echo path when `ECHO_SCLK=1`
  (`spi_engine_execution.v` ~lines 510–511), a different mechanism than the
  `end_of_word` path used when `ECHO_SCLK=0` (~line 513).
- Single-word `n=0` handling: `echo_last_transfer` special-cases
  `cmd_d1_time_is_zero` (`spi_engine_execution.v` ~lines 456–470).
- **Untested:** TB never sets `ECHO_SCLK=1`.

### FLAG EXEC-F6 — dynamic transfer length > DATA_WIDTH unspecified

- `spi_engine_execution.v` ~lines 279–284: `REG_WORD_LENGTH` writes
  `word_length <= cmd[7:0]` and `left_aligned <= DATA_WIDTH - cmd[7:0]` with only a
  comment ("the max value of this reg must be DATA_WIDTH") — **no clamp/guard**.
- If `cmd[7:0] > DATA_WIDTH`, `left_aligned` underflows (unsigned wrap) and the
  bit/latch counts (`last_bit_count = word_length-1`, ~line 300) exceed the shift
  register width. Behavior undefined; constraint is by convention only.

### FLAG EXEC-F7 — word_length/lane-mask-then-transfer relies on settling margin

- `spi_engine_execution.v` ~lines 297–302: `last_bit_count`/`latch_last_bit_count`
  are recomputed from `word_length` with a **one-cycle delay** (comment: "even in
  the worst case (transfer after config), we still have another cycle before using
  it").
- `spi_engine_execution_shiftreg.v` ~lines 210 & 242 (comments): "these paths would
  be unsafe if there wasn't a guarantee of some settling time between word_length
  changing and a transfer starting."
- Correct today because a Configuration-Write (1 cycle) plus the Transfer's fixed
  2-cycle prologue provides the margin; a refactor shortening that gap would break
  it. Covered by spec EXEC-CC-01.

---

## Supporting evidence for RTL-CHARACTERIZED requirements (non-flag)

For traceability of spec items whose only authority is the RTL:

| Spec ID | RTL evidence (`spi_engine_execution.v` unless noted) |
|---------|------------------------------------------------------|
| EXEC-RST-03 (`cs`=all-ones) | ~line 419 `cs <= 'hff` |
| EXEC-RST-05 (`sdo_t`=1, sdo idle) | ~lines 522–523; shiftreg ~line 140 `{DATA_WIDTH{sdo_idle_state}}` |
| EXEC-RST-07 / EXEC-CS-04 (clear on CS activate) | `cs_activate` ~lines 527–533; shiftreg clears `data_sdi_shift` on `cs_activate` ~line 284 |
| EXEC-CMD-01 (idle-gate) | `assign cmd_ready = idle;` ~line 226 |
| EXEC-FLOW-04 (last-word gate relax) | `io_ready2` includes `last_transfer` ~lines 445–446 |
| EXEC-SDO-02 (MSB alignment) | `left_aligned` shift; assemble `data_reg << left_shift_count` (assemble ~line 143) |
| EXEC-LANE-01/03 (SDO lane distribution) | assemble `lane_lookup[]` scan ~lines 167–193; `active_lane_idx` ~lines 209–221 |
| EXEC-SDI-05 (`SDI_DELAY`) | shiftreg `trigger_rx_d`/`trigger_rx_s` ~lines 161–164 |
| EXEC-OFF-01/02 (prefetch gating) | shiftreg `sdo_data_ready_int` = `... && (s_offload_active \|\| (exec_cmd & index_ready))` ~line 106 |

---

## Cross-references

- Behavioral spec[^spec] — the authority for the golden model.
- Driver usage reference[^driver] — the *software* sibling of this doc: how the
  no-OS driver programs the module (evidence behind the spec's `(no-OS)` tags).
- Memory: `finding-sdi-handshake-violation`, `finding-sleep-formula-doc-contradiction`,
  `project-exec-spec-status`

[^spec]: `doc/spi_execution.spec.md`
[^driver]: `doc/spi_execution.driver.md`
