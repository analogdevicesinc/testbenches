# SPI Engine Execution Module — Driver Usage Reference (no-OS + Linux)

> **This is NOT the specification.** Like its RTL sibling[^rtl], this file holds
> *usage evidence*, not requirements. It records how the two **reference drivers
> actually program** the execution module, so a designer resolving a flag — or a
> verification engineer judging how much a test result matters — can see the concrete
> software evidence behind a `(no-OS)`, `(Linux)`, or `(drivers)` tag in the spec. Both
> drivers are non-independent (each SW team wrote its code from the same HDL-team docs).
> The requirement-strength classification lives in the spec[^spec]; the code
> mechanics behind it live here.

**Structure:** Part A = no-OS reference driver; Part B = Linux mainline driver; Part C =
the no-OS vs Linux divergence table (what one drives that the other does not).

Drivers under study:

- **no-OS** — paths relative to `no-os-repo/drivers/axi_core/spi_engine/`:
  - `spi_engine.c` — command compilation, transfer/offload flow, FIFO drain
  - `spi_engine.h` — public transfer macros (`WRITE`/`READ`/`WRITE_READ`, `CS_*`)
  - `spi_engine_private.h` — register map, opcode/config constants, `SPI_ENGINE_CMD` encoder
- **Linux** — `linux-repo-shallow-main/drivers/spi/spi-axi-spi-engine.c` (mainline; the
  *modern* driver, not the separate `spi-axi-legacy-spi-engine.c`). Feature set is
  version-gated on the IP core `ADI_AXI_REG_VERSION` (see L.3).

Line references are from the revisions read on 2026-07-03; re-verify before quoting.

---

# Part A — no-OS reference driver

---

## D.1 The command sequence a `write_and_read` transfer emits

`spi_engine_write_and_read` → `spi_engine_compile_message` build one command list.
Config is *prepended* (`spi_engine_queue_append_cmd`, adds to front) and the sync is
*appended* (`spi_engine_queue_add_cmd`, adds to end); the CS/transfer skeleton is set
up in `write_and_read` itself. The net order written to the CMD FIFO is:

| # | Instruction (boundary opcode) | Encoder / arguments |
|---|-------------------------------|---------------------|
| 1 | Configuration-Write `010`, reg `000` (prescaler) | `clk_div` from `ref_clk_hz / (2*max_speed_hz) - 1` (`spi_engine_init` / `spi_engine_set_speed`) |
| 2 | Configuration-Write `010`, reg `010` (dyn. length) | `data_width`, clamped ≤ `max_data_width` in `spi_engine_set_transfer_width` |
| 3 | Configuration-Write `010`, reg `001` (SPI config) | `desc->mode` OR `SPI_ENGINE_CONFIG_SDO_IDLE` when `sdo_idle_state != 0` |
| 4 | Chip-Select `001`, `s=0xFF` (all deselected) | `CS_HIGH` = `SPI_ENGINE_CMD_ASSERT(0x03, 0xFF)` |
| 5 | Chip-Select `001`, `s` = one bit cleared (select) | `spi_engine_set_cs(false)`: `mask ^= NO_OS_BIT(chip_select)`, delay = `cs_delay` |
| 6 | Transfer `000`, `rw=11` (full-duplex), `n = words-1` | `WRITE_READ(bytes)` → `spi_engine_transfer` encodes `words_number - 1` |
| 7 | Chip-Select `001`, `s=0xFF` (deselect) | `CS_HIGH` |
| 8 | MISC `011`, `cmd[8]=0` (Sync), id `_sync_id` | `SPI_ENGINE_CMD_SYNC(_sync_id)` |

After queuing, `spi_engine_transfer_message`:
1. writes each SDO word to `SPI_ENGINE_REG_SDO_DATA_FIFO`,
2. **busy-polls `SPI_ENGINE_REG_SYNC_ID` until it equals `_sync_id`, then `_sync_id++`**
   — this poll is the driver's *sole* transfer-completion signal,
3. drains `msg->length` words from `SPI_ENGINE_REG_SDI_DATA_FIFO`.

Offload mode (`spi_engine_offload_transfer`) writes the **same** compiled command
list to `SPI_ENGINE_REG_OFFLOAD_CMD_MEM(0)` instead of the CMD FIFO and moves data by
DMA rather than register polling — same commands, different transport (spec basis for
EXEC-OFF-03).

---

## D.2 Per-requirement code evidence (`(no-OS)` tags)

For traceability of each spec item the driver corroborates:

| Spec ID | Class | Driver evidence (`spi_engine.c` unless noted) |
|---------|-------|-----------------------------------------------|
| EXEC-SCLK-01 / EXEC-CFG-01 (`(div+1)*2` divisor) | **load-bearing** | `clk_div = ref_clk_hz / (2*speed_hz) - 1` — inverts the SCLK formula; wrong ⇒ wrong bus clock |
| EXEC-SYNC-01 (sync id round-trip) | **load-bearing** | `SPI_ENGINE_CMD_SYNC(_sync_id)` appended per message; polled at `SPI_ENGINE_REG_SYNC_ID` |
| EXEC-CFG-02 (config bit layout) | **load-bearing** | `spi_engine_private.h`: `CONFIG_CPHA/CPOL/3WIRE/SDO_IDLE` = `NO_OS_BIT(0..3)` |
| EXEC-XFER-01 (`n` zero-based) | **load-bearing** | `spi_engine_transfer` encodes `words_number - 1` |
| EXEC-CFG-06 (width ≤ DATA_WIDTH) | **load-bearing** | `spi_engine_set_transfer_width` clamps to `max_data_width` (read from `SPI_ENGINE_REG_DATA_WIDTH` at init) |
| EXEC-SDO-02 / EXEC-SDI-01 (MSB align) | **load-bearing** | pack `data[i] << (data_width - (i%word_len + 1)*8)`; unpack symmetric in `write_and_read` |
| EXEC-CS-01/02 (active-low, prescaled delay) | **load-bearing** | select clears one bit (field-bit-0 = selected); `cs_delay` in the `t` field of `SPI_ENGINE_CMD_ASSERT` |
| EXEC-SLEEP-01 (`(t+1)` form) | **load-bearing** | `spi_get_sleep_div`: `sleep_div = …/((clk_div+1)*2) - 1` (pre-`-1` ⇒ HW adds it back) |
| EXEC-XFER-05 (full-duplex) | load-bearing (core) | core `write_and_read` emits only `WRITE_READ` (`rw=11`) |
| EXEC-XFER-05 (write-only / read-only) | driven elsewhere | `WRITE`/`READ` macros defined in `spi_engine.h`, used by device drivers, not the core path |
| EXEC-OFF-03 (same cmds / diff transport) | load-bearing (offload) | `spi_engine_offload_transfer` reuses the compiled list via `OFFLOAD_CMD_MEM` + DMA |
| EXEC-CSINV-* (CS-invert) | not driven — see D.3 / FLAG F8 | no macro; opcode unreachable by encoder |
| EXEC-CFG-04/05, EXEC-LANE-*, EXEC-CC-08 (lane masks) | not driven — see D.3 / FLAG F9 | neither lane-mask register ever written |
| EXEC-CS-05 (sparse multi-select) | not driven | driver only single-selects or fully deselects (`0xFF`) |

---

## D.3 Encoder / doc gaps surfaced by the driver

- **2-bit opcode encoder (FLAG F8).** `spi_engine_private.h` `SPI_ENGINE_CMD(inst,
  arg1, arg2)` masks the opcode with `((inst & 0x03) << 12)` — only 2 bits — yet the
  instruction set defines a 3-bit `cmd[14:12]` opcode with `100` = CS-Invert-Mask.
  Opcode `100` aliases to `000` (Transfer) under this mask, so the driver cannot
  encode CS-invert; it also defines no macro for it and never emits it. Any software
  needing CS-invert must bypass `SPI_ENGINE_CMD`. See F8 in the spec for the
  expected-SW-lag framing.
- **Lane-mask registers never written (FLAG F9).** `spi_engine_compile_message`
  emits exactly three Configuration-Writes — prescaler `000`, dyn-length `010`, SPI
  config `001`. Neither the SDI lane mask (`011`) nor the SDO lane mask (`100`) is
  written by the core driver, so both stay at their reset default (all lanes active)
  for a stock transfer. Consistent with multilane being a recent HDL addition the
  reference SW has not yet caught up to.
- **Sleep-formula tie-break (FLAG F3).** `spi_get_sleep_div`'s `-1` pre-decrement
  matches `instruction-format.rst`'s `(t+1)` formula, not `pipeline-delays.rst`'s `t`
  formula — a second (non-independent) vote for `(t+1)`. Still needs direct RTL
  measurement to be authoritative.
- **`SDI_DELAY` / `ECHO_SCLK` absent from the driver.** The driver exposes neither
  (consistent with FLAG F5 — they are build-time-only RTL parameters). `sdo_idle_state`
  *is* a driver-level concept (`spi_engine_desc.sdo_idle_state`, folded into the SPI
  config byte), consistent with EXEC-PARAM-06 / EXEC-XFER-06.

---

---

# Part B — Linux mainline driver

The Linux `spi-axi-spi-engine` driver is a *fuller* user of the module than the no-OS
core path: it drives CS-invert and lane masks, emits half-duplex transfers, and uses an
interrupt (not a busy-poll) for message completion. Crucially, most of its extra reach
is **version-gated** on the IP core version (L.3) — which is why the older-style no-OS
core path does not exercise the same features. This is the concrete evidence that closes
the previously-open FLAG F8 and FLAG F9 as *no-OS lag*, not spec problems.

## L.1 How the Linux driver generates a command program

`spi_engine_optimize_message` compiles each `spi_message` **once** (a dry pass sizes the
buffer, then a real pass fills it — `spi_engine_compile_message`, lines 804–844) and
caches it in `msg->opt_state`. `spi_engine_transfer_one_message` then streams that
program to the CMD FIFO. For a simple single-transfer message the emitted order is:

| # | Instruction (boundary opcode) | Encoder / arguments |
|---|-------------------------------|---------------------|
| 1 | Configuration-Write `010`, reg `001` (SPI config) | `spi_engine_get_config`: CPOL/CPHA/3WIRE/SDO_IDLE from `spi->mode` (lines 210–226) |
| 2 | Chip-Select `001`, `s` = one bit cleared (assert) | `spi_engine_gen_cs`: `mask=0xff ^ BIT(cs)`, **delay `t`=0** always (lines 281–290) |
| 3 | Configuration-Write `010`, reg `000` (prescaler) | only if `clk_div` changed: writes `clk_div-1`, "actual divider = reg+1" (lines 434–441) |
| 4 | Configuration-Write `010`, reg `010` (xfer bits) | only if `bits_per_word` changed (lines 443–448) |
| 5 | Transfer `000`, flags from tx/rx presence, `n = words-1` | `spi_engine_gen_xfer`: `WRITE` if `tx_buf`, `READ` if `rx_buf`; splits into ≤256-word chunks (lines 228–256) |
| 6 | MISC `011` Sleep (`cmd[8]=1`), `t = periods-1` | only if `xfer->delay` exceeds one instruction time (lines 258–279) |
| 7 | Chip-Select `001`, `s=0xFF` (deselect) | `spi_engine_gen_cs(assert=false)` unless `keep_cs` (lines 454–475) |
| 8 | MISC `011` Sync (`cmd[8]=0`), id `AXI_SPI_ENGINE_CUR_MSG_SYNC_ID` (=1) | appended in `optimize_message` for non-offload (lines 828–830) |

Completion is **interrupt-driven**: `spi_engine_irq` handles `INT_SYNC`, reads
`SPI_ENGINE_REG_SYNC_ID`, and only completes the message when the id matches
`AXI_SPI_ENGINE_CUR_MSG_SYNC_ID` (lines 658–711). The same handler refills the CMD/SDO
FIFOs and drains the SDI FIFO on the `*_ALMOST_*` interrupts. (The synchronous
`spi_engine_setup`/`spi_engine_trigger_enable` paths *do* busy-poll `SYNC_ID`, lines
925–926, 1030–1031 — the same round-trip, different transport.)

**`spi_engine_setup` (IP v1.2+)** runs once per device and emits, framed by Sync(0)/Sync(1):
a **CS-Invert-Mask** write `SPI_ENGINE_CMD_CS_INV(cs_inv)` (line 899), optionally the
initial lane masks when `num_data_lanes>1` (lines 902–913), then a CS-assert to latch the
inversion (lines 919–920). `cs_inv` is a shadow of the per-device `SPI_CS_HIGH` mode bit
(lines 891–894).

**Offload** (`spi_engine_offload_prepare`, lines 713–789) writes the *same* compiled
`p->instructions[]` list to `OFFLOAD_CMD_FIFO` and the tx words to `OFFLOAD_SDO_FIFO`,
then execution is trigger-driven with DMA streaming — same commands, different transport
(spec EXEC-OFF-03). Config/xfer-bits/lane-masks for offload are set once in
`spi_engine_trigger_enable` rather than per message (lines 999–1041).

## L.2 Per-requirement code evidence (`(Linux)` / `(drivers)` tags)

| Spec ID | Class | Linux evidence (`spi-axi-spi-engine.c`) |
|---------|-------|------------------------------------------|
| EXEC-CMD-03 (3-bit opcode) | **load-bearing (Linux)** | `SPI_ENGINE_CMD(inst,a1,a2)=(inst<<12)|…` — **no opcode mask**; `INST_CS_INV=0x4` defined and emitted (lines 76, 93, 899). Full opcode reach — contrast no-OS's 2-bit mask. |
| EXEC-CSINV-* (CS-invert `100`) | **load-bearing (Linux)** | `SPI_ENGINE_CMD_CS_INV(cs_inv)` in `setup()`; `cs_inv` tracks `SPI_CS_HIGH` (lines 76, 106–107, 885–927). This is the mechanism behind active-high CS. |
| EXEC-CFG-04/05 & EXEC-LANE-* (lane masks) | **load-bearing (Linux), v2.0+** | `REG_SDI_MASK=0x3`, `REG_SDO_MASK=0x4`; masks from `rx_lane_map[]`/`tx_lane_map[]` written per-message (414–430), in `setup()` (902–913), and offload (1018–1025). Gated on `num_data_lanes` (IP major ≥2). |
| EXEC-SCLK-01 / EXEC-CFG-01 (`(div+1)*2`) | **load-bearing (drivers)** | `clk_div = max_speed_hz/effective_speed_hz`, writes `clk_div-1`, comment "actual divider = register value + 1"; `max_speed_hz = ref_clk/2` (434–441, 1220). |
| EXEC-CFG-02 (config bit layout) | **load-bearing (drivers)** | `CONFIG_CPHA/CPOL/3WIRE/SDO_IDLE_HIGH = BIT(0..3)` (lines 67–70). Identical to no-OS. |
| EXEC-XFER-01 (`n` zero-based) | **load-bearing (drivers)** | `CMD_TRANSFER(flags, n-1)`, `n=min(len,256)` (lines 244–253). |
| EXEC-XFER-05 (all `{r,w}` combos) | **load-bearing (Linux), core path** | flags set from `tx_buf`/`rx_buf` per transfer → emits write-only, read-only, and full-duplex directly in the core path (lines 245–250). no-OS core emits only `11`. |
| EXEC-SDO-02 / EXEC-SDI-01 (MSB align) | **load-bearing (drivers)** | Linux writes native-width words to the FIFO and relies on HW left-alignment (lines 574–656); corroborates the alignment is a *hardware* behavior. |
| EXEC-CS-01 (active-low select) | **load-bearing (drivers)** | `mask = 0xff ^ BIT(cs)` (lines 284–289). Field bit 0 = selected. |
| EXEC-CS-03 (`t=0` CS, no pre/post wait) | **load-bearing (Linux)** | `gen_cs` always emits `ASSERT(0, mask)` — Linux never uses the ASSERT delay field. |
| EXEC-SYNC-01 (sync id round-trip) | **load-bearing (drivers)** | id round-trip is the completion signal in both; Linux via **IRQ** (658–711), no-OS via poll. |
| EXEC-SLEEP-01 (`(t+1)` form) | **load-bearing (drivers)** | `gen_sleep` encodes `SLEEP(n-1)` after subtracting one instruction time (`inst_ns`) — same `-1` pre-decrement as no-OS; votes `(t+1)` and the `2+` overhead (lines 258–279, 384). |
| EXEC-OFF-03 (same cmds / diff transport) | **load-bearing (Linux), offload** | `offload_prepare` reuses `p->instructions[]` via `OFFLOAD_CMD_FIFO` + DMA (lines 763–789). |
| EXEC-CFG-06 (width ≤ DATA_WIDTH) | **not enforced by Linux** — see L.3 / FLAG F6 | Linux hardcodes `bits_per_word_mask = 1..32` and does not clamp to the HW DATA_WIDTH field (lines 1219, 1185). |
| EXEC-CS-02 (prescaled pre/post CS delay, `t>0`) | not driven by Linux | Linux uses separate Sleep commands for `cs_change_delay`; the ASSERT `t` field stays 0. Driven by no-OS only. |
| EXEC-CS-05 (sparse multi-select) | not driven | Linux single-selects (`0xff ^ BIT(cs)`) or fully deselects (`0xff`) only, like no-OS. |

## L.3 Encoder / version gating surfaced by the Linux driver

- **Full 3-bit opcode encoder (resolves FLAG F8).** Linux's `SPI_ENGINE_CMD` applies
  **no opcode mask**, so it reaches all five opcodes including `100`=CS-Invert-Mask,
  which it *actively emits* from `spi_engine_setup` to implement `SPI_CS_HIGH`. This
  makes the no-OS `(inst & 0x03)<<12` mask (Part A / D.3) a **no-OS encoder limitation**,
  not a spec gap or a universal SW lag: CS-invert is a real, driven, documented feature.
- **Lane masks are driven, and version-gated (resolves FLAG F9).** Linux writes both
  `REG_SDI_MASK` (`011`) and `REG_SDO_MASK` (`100`) from the device's lane maps. The
  multi-lane (`STRIPE`) path is enabled only when `host->num_data_lanes` is read from the
  DATA_WIDTH register on **IP core major version ≥ 2** (lines 1237–1239). So multi-lane
  is literally a v2.0 capability — corroborating that it is a recent HDL addition the
  no-OS core has not caught up to, exactly as F9 framed it.
- **Feature/version gating explains the no-OS↔Linux gap.** From `spi_engine_probe`:
  CS-invert + `setup()` require IP **v1.2+** (lines 1230–1233); `SPI_MOSI_IDLE_*`
  (sdo_idle) require **v1.3+** (lines 1234–1235); multi-lane requires **v2.0+**
  (1237–1239); offload memory sizing and the "SYNC no longer required for offload" relax
  are **v1.1+ / v1.5+** (lines 1187–1201). Version gating is the reason two ADI drivers
  legitimately drive different feature subsets.
- **Word length not clamped to DATA_WIDTH (strengthens FLAG F6).** Unlike no-OS, Linux
  advertises `bits_per_word_mask = SPI_BPW_RANGE_MASK(1, 32)` and reads the DATA_WIDTH
  register only for the *lane-count* field — it never clamps `bits_per_word` to the HW
  transfer-width field. On a `DATA_WIDTH<32` build a client could request a `bits_per_word`
  the module treats as out-of-range (FLAG F6's underflow region). Neither driver *defines*
  behavior there; no-OS avoids it by clamping, Linux does not guard it at all.
- **Completion by interrupt, not poll.** Linux completes messages from `spi_engine_irq`
  on `INT_SYNC` with a matching `SYNC_ID` (lines 658–711); it busy-polls `SYNC_ID` only in
  the synchronous `setup`/`trigger_enable` paths. This is a *transport* difference from
  no-OS's universal busy-poll; the boundary contract (EXEC-SYNC-01: id round-trip gates
  completion) is identical.
- **`SDI_DELAY` / `ECHO_SCLK` absent from Linux too.** Like no-OS, the Linux driver
  exposes neither — consistent with FLAG F5 (build-time-only RTL parameters). `SDO_IDLE`
  *is* a Linux mode bit (`SPI_MOSI_IDLE_HIGH`/`_LOW`, v1.3+), consistent with
  EXEC-XFER-06 / EXEC-PARAM-06.

---

# Part C — no-OS vs Linux divergence

Both drivers are non-independent and agree on the core boundary contract. Where
they *differ*, it is almost always **feature reach** (Linux drives more, gated on IP
version) or **transport** (how data/completion move), not a contradiction about what the
module does. Divergences that touch a requirement's strength:

| Aspect | no-OS | Linux | Effect on spec |
|--------|-------|-------|----------------|
| Opcode encoder width | 2-bit mask (`&0x03`) — can't emit `100` | full 3-bit, emits `100` | **F8 resolved**: no-OS encoder limit, not spec gap; EXEC-CMD-03 / CSINV-* gain `(Linux)` |
| CS-Invert-Mask (`100`) | never emitted | emitted in `setup()` for `SPI_CS_HIGH` | EXEC-CSINV-* → **load-bearing (Linux)** |
| Lane masks (`011`/`100`) | never written | written (per-msg, setup, offload), **v2.0+** | **F9 resolved**: EXEC-CFG-04/05, EXEC-LANE-* → **load-bearing (Linux)** |
| Transfer duplex in core path | full-duplex `11` only | write-only/read-only/full per `tx/rx_buf` | EXEC-XFER-05 `01`/`10` → **load-bearing (Linux)** |
| CS delay | prescaled `t` in ASSERT field | ASSERT `t`=0 + separate Sleep for `cs_change_delay` | EXEC-CS-02 driven by **no-OS only**; EXEC-CS-03 by both |
| Word-length vs DATA_WIDTH | clamps to readback | **no clamp** (`bpw_mask 1..32`) | **strengthens F6**: reference SW does not universally enforce the constraint |
| Completion transport | busy-poll `SYNC_ID` | **IRQ** on `INT_SYNC` (poll only in setup) | EXEC-SYNC-01 boundary identical; transport differs |
| SDO byte packing | explicit shift/align in SW | native words to FIFO, HW aligns | EXEC-SDO-02 confirmed as **HW** behavior |
| Sleep sizing | `-1` pre-decrement | `-1` + subtract one instruction time | **both vote `(t+1)`** (F3) |

**Net:** the two open TODO flags (F8, F9) are resolved by Linux as *no-OS lag*, not spec
problems. F6 is *strengthened* (Linux is less defensive than no-OS). F3 gains a second
`(t+1)` vote. No divergence forces a new flag: every difference is version-gated feature
reach or transport, consistent with a single boundary contract.

---

## Requirement-Strength Cross-Check

**Sources:** the **no-OS** reference driver (`no-os-repo/drivers/axi_core/spi_engine/`)
and the **Linux** mainline `spi-axi-spi-engine` driver. This section grades *how much a
verification result matters* — separating **load-bearing** behavior (a real deployment
breaks if the RTL disagrees) from behavior **not driven** by any reference SW — and
records which driver depends on each behavior and whether the dependence is
**version-gated**. The code-level evidence is Part A (no-OS), Part B (Linux), and
Part C (divergence) above.

Driver key: **✓** driven, **—** not driven, **(gate)** version-gated.

| Behavior (requirement) | no-OS | Linux | Strength | Note |
|------------------------|:-----:|:-----:|----------|------|
| SCLK divisor `(div+1)*2` (EXEC-SCLK-01/CFG-01) | ✓ | ✓ | **load-bearing (drivers)** | both invert the formula to set the bus clock |
| Sync id round-trip (EXEC-SYNC-01) | ✓ | ✓ | **load-bearing (drivers)** | sole transfer-done signal; no-OS polls, Linux IRQ |
| SPI-config bit layout (EXEC-CFG-02) | ✓ | ✓ | **load-bearing (drivers)** | CPHA/CPOL/3WIRE/SDO_IDLE = 0/1/2/3 |
| Transfer `n` zero-based (EXEC-XFER-01) | ✓ | ✓ | **load-bearing (drivers)** | encodes `words - 1`, ≤256/instr |
| MSB-first / MSB-aligned (EXEC-SDO-02, EXEC-SDI-01) | ✓ | ✓ | **load-bearing (drivers)** | no-OS aligns in SW; Linux relies on HW alignment |
| Active-low CS (EXEC-CS-01), `t=0` CS (EXEC-CS-03) | ✓ | ✓ | **load-bearing (drivers)** | field bit 0 = selected |
| Sleep `(t+1)` prescaler form (EXEC-SLEEP-01) | ✓ | ✓ | **load-bearing (drivers)** | both pre-decrement; see FLAG F3 |
| Offload same-cmds/diff-transport (EXEC-OFF-03) | ✓ | ✓ | **load-bearing (drivers), offload** | reuse compiled list via cmd-mem + DMA |
| Full 3-bit opcode / CS-Invert-Mask (EXEC-CMD-03, EXEC-CSINV-*) | — | ✓ | **load-bearing (Linux)** | Linux drives `SPI_CS_HIGH` (v1.2+); no-OS encoder is 2-bit → **FLAG F8 resolved** |
| SDI/SDO lane masks + multi-lane (EXEC-CFG-04/05, EXEC-LANE-*, EXEC-CC-08) | — | ✓ (gate) | **load-bearing (Linux), v2.0+** | Linux drives from `lane_map`; no-OS targets earlier cores → **FLAG F9 resolved** |
| Write-only / read-only Transfer in core path (EXEC-XFER-05 `01`/`10`) | dev | ✓ | **load-bearing (Linux) core; device-driver (no-OS)** | Linux core sets flags from tx/rx presence |
| Prescaled CS pre/post delay via ASSERT `t` (EXEC-CS-02) | ✓ | Sleep | **(no-OS) only** | Linux uses separate Sleep commands instead |
| Word length ≤ `DATA_WIDTH` (EXEC-CFG-06) | ✓ clamp | — | **(no-OS) enforces; Linux does not** | Linux `bpw_mask 1..32`, no clamp → **strengthens FLAG F6** |
| Full-duplex Transfer `rw=11` (EXEC-XFER-05) | ✓ | ✓ | **load-bearing (drivers)** | both emit it |
| Clock-only/dummy Transfer `rw=00` (EXEC-XFER-05) | — | — | **not driven** | neither driver emits it |
| Sparse multi-CS select (EXEC-CS-05) | — | — | **not driven** | both single-select or fully deselect only |

Legend: **dev** = driven by device drivers, not the core path; **Sleep** = Linux expresses
the same *effect* via a separate Sleep instruction rather than this field.

**Interpreting the strengths after the Linux pass:** the two previously "not yet driven"
rows (CS-Invert-Mask, lane masks) are now **load-bearing under Linux** — the earlier
reading was an artifact of looking only at no-OS. A TB mismatch on them is now a
*conformance* signal for real Linux deployments, not a bare regression lock. What is
still driven by **neither** driver — clock-only `rw=00`, sparse multi-CS, and the
ASSERT-`t` CS delay under Linux — remains characterization-only: exercising it in the TB
locks the RTL ahead of the SW, but a mismatch has no field consequence today. The one
place the drivers *disagree in defensiveness* is EXEC-CFG-06: no-OS clamps, Linux does
not — so the module's undefined >`DATA_WIDTH` region (FLAG F6) is reachable through the
Linux path and deserves either an RTL guard or an explicit documented constraint.

---

## Cross-references

- Behavioral spec[^spec] — the authority for the golden model; the `(no-OS)`/`(Linux)`/
  `(drivers)` tags and the requirement-strength classification point here.
- RTL implementation reference[^rtl] — the sibling holding RTL-level evidence.
- Memory: `finding-sleep-formula-doc-contradiction`, `project-exec-spec-status`

[^spec]: `doc/spi_execution.spec.md`
[^rtl]: `doc/spi_execution.rtl.md`
