# SPI Engine Execution Module — Behavioral Specification & Requirements

Requirements in this document follow the project requirement-authoring guideline.

## Module boundary

(the only vocabulary this requirement may use)

| Group | Signals |
|-------|---------|
| Clock/reset | `clk`, `resetn` (active-low) |
| CMD stream (in) | `cmd_valid`, `cmd_ready`, `cmd[15:0]` |
| SDO stream (in) | `sdo_data_valid`, `sdo_data_ready`, `sdo_data[DATA_WIDTH-1:0]` |
| SDI stream (out)| `sdi_data_valid`, `sdi_data_ready`, `sdi_data[NUM_OF_SDIO*DATA_WIDTH-1:0]` |
| SYNC stream (out)| `sync_valid`, `sync_ready`, `sync[7:0]` |
| Offload | `s_offload_active` |
| SPI bus | `sclk`, `sdo[NUM_OF_SDIO-1:0]`, `sdo_t`, `sdi[NUM_OF_SDIO-1:0]`, `cs[NUM_OF_CS-1:0]`, `three_wire`, `echo_sclk` |

All four `ctrl` streams use AXI-stream valid/ready handshaking: a beat transfers on
the cycle where valid and ready are both asserted; once valid is asserted the
payload MUST remain stable until the beat is accepted (`EXTERNAL`, AXI-Stream rule).

---

## 1. Parameters & Configuration Space (validity domains)

These define the parameter space over which every later requirement's validity
domain is stated. They are boundary-visible because they size the bus and the
streams, or set reset defaults.

#### EXEC-PARAM-01
- Description: `NUM_OF_CS` ∈ [1..8] sets the width of the `cs` bus. All requirements referencing chip-select hold for every value in this range.
- Rationale: Bounds the chip-select validity domain for every downstream requirement.
- Provenance: `DOCUMENTED`

#### EXEC-PARAM-02
- Description: `NUM_OF_SDIO` ∈ [1..8] sets the number of SDO/SDI lanes (`sdo`/`sdi` width) and the width of `sdi_data` (= `NUM_OF_SDIO*DATA_WIDTH`).
- Rationale: Sizes the lane and receive datapath domain for the multi-lane requirements.
- Provenance: `DOCUMENTED`

#### EXEC-PARAM-03
- Description: `DATA_WIDTH` ∈ {8,16,24,32} sets the parallel-word granularity: `sdo_data` width, each `sdi_data` lane slice, and the maximum transfer word length.
- Rationale: Sizes the stream words and bounds the legal word-length range.
- Provenance: `DOCUMENTED`

#### EXEC-PARAM-04
- Description: `DEFAULT_SPI_CFG` is the reset value of the SPI configuration register (CPHA=bit0, CPOL=bit1, three_wire=bit2, sdo_idle_state=bit3), observable via the reset waveform (EXEC-RST-*).
- Rationale: Defines the post-reset SPI mode a host observes before any config write.
- Provenance: `DOCUMENTED`

#### EXEC-PARAM-05
- Description: `DEFAULT_CLK_DIV` is the reset value of the prescaler; it sets the SCLK period of the first transfer issued after reset with no intervening prescaler write.
- Rationale: Fixes the bus clock of the first transfer before software programs the divider.
- Provenance: `DOCUMENTED`

#### EXEC-PARAM-06
- Description: `SDO_DEFAULT` (1 bit) is the reset/idle level presented on every `sdo` lane before any configuration write changes `sdo_idle_state`.
- Rationale: Defines the `sdo` idle level at power-on.
- Provenance: `RTL-CHARACTERIZED` — see **FLAG EXEC-F5**

#### EXEC-PARAM-07
- Description: `ECHO_SCLK` ∈ {0,1} selects the SDI capture datapath (0 = capture on the internally-generated SPI clock; 1 = capture on the looped-back `echo_sclk`). Only `ECHO_SCLK=0` is in scope for this spec revision — see the Echo-SCLK observations and **FLAG EXEC-F4** in `findings.md`.
- Rationale: Fixes the capture-path validity domain; the echo path is deferred.
- Provenance: `RTL-CHARACTERIZED` — see **FLAG EXEC-F5**

#### EXEC-PARAM-08
- Description: `SDI_DELAY` ∈ [0..3] adds a fixed number of core-clock cycles of latency between an SCLK sampling edge and the cycle on which the corresponding `sdi` bit is captured, to tolerate high-SCLK round-trip delay (`ECHO_SCLK=0` path).
- Rationale: Lets high-SCLK builds tolerate round-trip delay without misaligning captured bits.
- Provenance: `RTL-CHARACTERIZED` — see **FLAG EXEC-F5**

---

## 2. Reset Behavior (boundary-observable)

Validity domain: all parameters. Only outputs are specified; internal state is out
of scope.

#### EXEC-RST-01
- Description: While `resetn` is deasserted (0) and for the first cycle after it is released, the module accepts no command and drives its `spi` bus and `ctrl` outputs to defined idle values (EXEC-RST-02..07).
- Rationale: Guarantees a defined power-on state before any command is accepted.
- Provenance: `RTL-CHARACTERIZED`

#### EXEC-RST-02
- Description: After reset the module is ready to accept a command: `cmd_ready` is asserted.
- Rationale: The engine is immediately available to the command generator after reset.
- Provenance: `DOCUMENTED` (implied by EXEC-CMD-01)

#### EXEC-RST-03
- Description: After reset `cs` reads all-ones (every chip-select **inactive**), consistent with active-low default polarity.
- Rationale: No device is selected at power-on.
- Provenance: `RTL-CHARACTERIZED`; rationale `EXTERNAL` (SPI CS idle = deasserted)

#### EXEC-RST-04
- Description: After reset `sclk` idles at the CPOL level taken from `DEFAULT_SPI_CFG[1]`.
- Rationale: The idle bus clock matches the configured clock polarity.
- Provenance: `DOCUMENTED` (SPI config register) + `EXTERNAL` (CPOL idle semantics)

#### EXEC-RST-05
- Description: After reset every `sdo` lane idles at `sdo_idle_state` (= `SDO_DEFAULT`) and `sdo_t` is asserted (1, tri-stated).
- Rationale: Transmit lines are tri-stated and held at a defined idle after reset.
- Provenance: `RTL-CHARACTERIZED`

<!-- TODO: EXEC-RST-06 bundles two independently-testable behaviors (the three_wire
     reset value, and the sync_valid/sdi_data_valid outputs being deasserted). Per the
     atomicity smell in the authoring guideline these could fail independently and
     arguably warrant separate IDs. Splitting requires appending new IDs, so this is
     left flagged for review rather than changed here. -->
#### EXEC-RST-06
- Description: After reset `three_wire` reflects `DEFAULT_SPI_CFG[2]`; `sync_valid` and `sdi_data_valid` are deasserted. (Note: `sdo_data_ready` is *not* reliably cleared by reset in FIFO mode — see FLAG EXEC-F10 in `findings.md`.)
- Rationale: The three-wire mode line reflects its configured default and no stream output claims valid data at reset.
- Provenance: `DOCUMENTED` (config reg) / `RTL-CHARACTERIZED` (valids low)

#### EXEC-RST-07
- Description: Any receive state left over from a prior transaction is cleared by reset, so the first read transfer after reset returns only newly-sampled bits (no stale `sdi_data`).
- Rationale: Reset must not leak captured data from before the reset into the next read.
- Provenance: `RTL-CHARACTERIZED`; the instruction-format note ("Additional logic … reset counters … when CS active state is asserted") documents the *CS-driven* clear, not the reset-driven one

---

## 3. Command Stream (CMD) — acceptance & sequencing

Validity domain: all parameters.

#### EXEC-CMD-01
- Description: The module accepts a new command **only when idle**: `cmd_ready` is asserted exactly when no instruction is executing, and a command transfers on the single cycle `cmd_valid && cmd_ready`.
- Rationale: Serializes execution so no command overlaps another in flight.
- Provenance: `DOCUMENTED` (control-interface AXI handshake) / `RTL-CHARACTERIZED` (idle-gating)

#### EXEC-CMD-02
- Description: While an instruction is executing, `cmd_ready` is deasserted, so the upstream generator stalls until the instruction completes; no command is lost or reordered.
- Rationale: Backpressure to the generator prevents command loss or reordering.
- Provenance: `DOCUMENTED` (implied)

#### EXEC-CMD-03
- Description: The opcode is taken from `cmd[14:12]`: `000`=Transfer, `001`=Chip-Select, `010`=Configuration-Write, `011`=MISC (Sync/Sleep), `100`=CS-Invert-Mask. Reserved bits `cmd[15]`, `cmd[11]` are 0 (and `cmd[10]` is used only by Configuration-Write).
- Rationale: Defines how the module decodes an instruction at its boundary.
- Provenance: `DOCUMENTED` (instruction-format) **`(Linux)`** — see FLAG EXEC-F8 (`findings.md`), evidence in `driver.md`.

#### EXEC-CMD-04
- Description: Commands execute strictly in the order accepted; the module completes one instruction (returns to idle) before accepting the next, except that a Configuration-Write completes in a single cycle (EXEC-CFG-07).
- Rationale: Deterministic in-order execution is required for the command program to be meaningful.
- Provenance: `DOCUMENTED` (pipeline-delays)

---

## 4. Instruction Semantics

### 4.1 Transfer (opcode `000`) — `cmd[9]=r`, `cmd[8]=w`, `cmd[7:0]=n`

Validity domain: all parameters, `ECHO_SCLK=0`.

#### EXEC-XFER-01
- Description: A Transfer generates SCLK for `n+1` words, each `word_length` bits long (word_length per §4.3).
- Rationale: Defines the transfer-length encoding (zero-based word count).
- Provenance: `DOCUMENTED` **`(drivers)`** — evidence in `driver.md`.

#### EXEC-XFER-02
- Description: Bits are shifted **MSB-first** on both SDO and SDI.
- Rationale: SPI bit ordering convention that external devices expect.
- Provenance: `EXTERNAL` (SPI) + `DOCUMENTED`

#### EXEC-XFER-03
- Description: When `w=1` (write): each transmitted word is consumed from the SDO stream and driven onto `sdo`; `sdo_t` is deasserted (0, driven) for the duration of the transfer.
- Rationale: A write transfer must actively drive the transmit line with stream data.
- Provenance: `DOCUMENTED`

#### EXEC-XFER-04
- Description: When `r=1` (read): `sdi` is sampled for the whole word and the assembled word is presented on the SDI stream (`sdi_data` with `sdi_data_valid`).
- Rationale: A read transfer must capture the input line and deliver the received word.
- Provenance: `DOCUMENTED`

#### EXEC-XFER-05
- Description: All four `{r,w}` combinations are supported: full-duplex (`11`), write-only (`01`), read-only (`10`), and clock-only/dummy (`00`, SCLK toggles, no stream traffic).
- Rationale: The transfer instruction must cover every direction combination the protocol allows.
- Provenance: `DOCUMENTED` **`(Linux)`** — Linux core drives `01`/`10`/`11`; `00` driven by neither driver. Evidence in `driver.md`.

#### EXEC-XFER-06
- Description: During a read-only transfer (`w=0`), `sdo` is held at `sdo_idle_state`; outside a write transfer `sdo_t` is asserted (tri-stated).
- Rationale: The module must not drive spurious data on `sdo` when not writing.
- Provenance: `DOCUMENTED` (sdo_idle_state) / `EXTERNAL` (tri-state)

#### EXEC-XFER-07
- Description: A Transfer does not begin, and mid-transfer does not advance past a word boundary, until flow-control readiness is met (§6); when not ready it stalls with no data loss.
- Rationale: Flow-control gating keeps the transfer lossless under backpressure.
- Provenance: `DOCUMENTED`

#### EXEC-XFER-08
- Description: Instruction execution time = 2 core clocks + transfer time, where transfer time = `(n+1) * word_length * (div+1) * 2` core clocks. After the last bit of the last word the module returns to idle.
- Rationale: Gives a closed-form transfer duration for timing verification.
- Provenance: `DOCUMENTED (non-independent)` (pipeline-delays: "2 cycles plus transfer time") + closed form derived from EXEC-SCLK-01

### 4.2 Chip-Select (opcode `001`) — `cmd[9:8]=t`, `cmd[7:0]=s`

Validity domain: all parameters.

#### EXEC-CS-01
- Description: The instruction drives the `cs` output to the value `s` (low `NUM_OF_CS` bits), after applying the CS-invert mask (EXEC-CSINV-*). A field bit of 0 selects the corresponding device.
- Rationale: Chip-select control with active-low selection semantics.
- Provenance: `DOCUMENTED` **`(drivers)`** — active-low confirmed; sparse multi-select (EXEC-CS-05) undriven by both. Evidence in `driver.md`.

#### EXEC-CS-02
- Description: A prescaler-scaled delay `t` is inserted **both before and after** the CS change. The CS value changes at `2 + t*(div+1)*2` core clocks after the instruction starts, and the instruction completes at `2 + 2*t*(div+1)*2` core clocks.
- Rationale: Provides programmable setup/hold time around the chip-select edge.
- Provenance: `DOCUMENTED (non-independent)` (instruction-format + pipeline-delays) **`(no-OS)`** — only no-OS uses the ASSERT `t` field; Linux uses separate Sleeps. Evidence in `driver.md`.

#### EXEC-CS-03
- Description: With `t=0` the instruction applies the CS change with only the fixed internal-logic latency (no pre/post wait).
- Rationale: Allows an immediate chip-select change when no guard delay is needed.
- Provenance: `DOCUMENTED` **`(drivers)`** — both emit `t=0` chip-selects (Linux exclusively so). Evidence in `driver.md`.

#### EXEC-CS-04
- Description: Asserting a chip-select (driving at least one selected/low bit that was previously deselected) clears any residual receive state before the next transaction captures data; a pure deselect (all-inactive field) does **not** trigger this clear.
- Rationale: A new transaction must start from clean receive state, keyed on selection.
- Provenance: `DOCUMENTED` (instruction-format note, paraphrased)

#### EXEC-CS-05
- Description: Any subset of the `NUM_OF_CS` lines may be selected simultaneously.
- Rationale: Supports multi-device selection in a single instruction.
- Provenance: `DOCUMENTED`

### 4.3 Configuration-Write (opcode `010`) — register `cmd[10:8]`, value `cmd[7:0]`

Validity domain: all parameters. Each write completes in 1 core clock and does not
stall the command stream (EXEC-CFG-07).

#### EXEC-CFG-01
- Description: Register `000` (prescaler): sets the clock divider `div`; takes effect on subsequent transfers (SCLK period per EXEC-SCLK-01).
- Rationale: Runtime control of the SPI bus clock rate.
- Provenance: `DOCUMENTED`

#### EXEC-CFG-02
- Description: Register `001` (SPI config): sets CPHA=`v[0]`, CPOL=`v[1]`, three_wire=`v[2]`, sdo_idle_state=`v[3]`; observable on `sclk` idle level, `three_wire`, and `sdo` idle level respectively.
- Rationale: Runtime control of SPI mode and idle levels.
- Provenance: `DOCUMENTED` **`(drivers)`** — config bit constants match 0/1/2/3 exactly. Evidence in `driver.md`.

#### EXEC-CFG-03
- Description: Register `010` (dynamic transfer length): sets `word_length` = `v`, the number of SCLK bit-periods per word for subsequent transfers. Default (and reset) is `DATA_WIDTH`.
- Rationale: Runtime control of per-word bit length.
- Provenance: `DOCUMENTED`

#### EXEC-CFG-04
- Description: Register `011` (SDI lane mask): the value is accepted. **This module produces no boundary-visible effect from the SDI lane mask** — its masking effect is downstream in `axi_spi_engine`. Out of scope here; see **FLAG EXEC-F2** (Out-of-Scope observations in `findings.md`).
- Rationale: The register write must be accepted here even though its effect is observable only downstream.
- Provenance: `DOCUMENTED` (register) / effect out of scope **`(Linux)`** — Linux writes it (IP v2.0+); no-OS never does. See FLAG EXEC-F9 (`findings.md`), evidence in `driver.md`.

#### EXEC-CFG-05
- Description: Register `100` (SDO lane mask): selects which `sdo` lanes carry transmit data; lanes whose mask bit is 0 output `sdo_idle_state` (EXEC-LANE-*).
- Rationale: Runtime selection of active transmit lanes.
- Provenance: `DOCUMENTED` **`(Linux)`** — Linux writes it (IP v2.0+); unexercised by no-OS. See FLAG EXEC-F9 (`findings.md`), evidence in `driver.md`.

#### EXEC-CFG-06
- Description: A value written to the dynamic transfer length register MUST NOT exceed `DATA_WIDTH`; behavior for larger values is unspecified — see **FLAG EXEC-F6**.
- Rationale: The hardware word datapath is only `DATA_WIDTH` wide; larger values leave defined behavior.
- Provenance: `DOCUMENTED` (constraint stated) **`(no-OS)`** — no-OS clamps; Linux does *not*, so it can drive the out-of-range region. See FLAG EXEC-F6 (`findings.md`), evidence in `driver.md`.

#### EXEC-CFG-07
- Description: A Configuration-Write executes in 1 core clock and does not remove the module from its command-accepting state for more than that cycle (back-to-back config writes accept at 1 command/cycle).
- Rationale: Configuration must not stall the command stream, so setup sequences stay fast.
- Provenance: `DOCUMENTED` (pipeline-delays)

### 4.4 MISC — Sync (opcode `011`, `cmd[8]=0`) and Sleep (`cmd[8]=1`)

#### EXEC-SYNC-01
- Description: Sync drives `sync = cmd[7:0]` (event id) and asserts `sync_valid`; `sync_valid` holds until `sync_ready` is seen, then the module returns to idle. Execution time = 2 core clocks plus any wait for `sync_ready`.
- Rationale: Emits a host-visible event marker used to signal transfer progress/completion.
- Provenance: `DOCUMENTED` **`(drivers)` — load-bearing.** The `sync[7:0]` id round-trip is the sole transfer-completion signal in both drivers. Evidence in `driver.md`.

#### EXEC-SLEEP-01
- Description: Sleep stalls the command stream for `sleep_time = 2 + (t+1) * (div+1) * 2` core clocks (`t=cmd[7:0]`), then resumes; no `spi`/`ctrl` activity occurs during the stall.
- Rationale: Inserts a programmable inter-instruction delay without bus activity.
- Provenance: `DOCUMENTED (non-independent)` **`(drivers)`** — both pre-decrement, voting the `(t+1)` form. See FLAG EXEC-F3 (docs disagree on this formula, `findings.md`), evidence in `driver.md`.

#### EXEC-SLEEP-02
- Description: Sleep with `t=0` still produces the minimum non-zero delay given by the EXEC-SLEEP-01 formula.
- Rationale: Even the smallest sleep guarantees a defined minimum stall.
- Provenance: `DOCUMENTED`

### 4.5 CS-Invert-Mask (opcode `100`) — `cmd[7:0]=m` (low `NUM_OF_CS` bits used)

#### EXEC-CSINV-01
- Description: For each mask bit set, the corresponding `cs` pin is inverted at the output register: that pin becomes active-high; mask bit 0 leaves it active-low (default). The inversion is applied only at the output — the Chip-Select instruction's `s` field still names the same logical selection regardless of mask.
- Rationale: Supports active-high chip-select devices without changing the logical selection encoding.
- Provenance: `DOCUMENTED` **`(Linux)`** — Linux emits CS-Invert-Mask to implement `SPI_CS_HIGH`. See FLAG EXEC-F8 (`findings.md`), evidence in `driver.md`.

#### EXEC-CSINV-02
- Description: The mask persists across subsequent Chip-Select instructions until re-written or reset (reset = 0, no inversion).
- Rationale: CS polarity must remain stable across the transfers of a device without re-programming.
- Provenance: `DOCUMENTED` / `RTL-CHARACTERIZED` (reset value) **`(Linux)`** — Linux sets the mask once in setup and relies on persistence. Evidence in `driver.md`.

#### EXEC-CSINV-03
- Description: Changing the invert mask does not itself change which device the "assert a chip-select" clear logic (EXEC-CS-04) reacts to — that logic keys on the logical selection, not the inverted pin level.
- Rationale: Receive-state clearing must track the logical selection, independent of pin polarity.
- Provenance: `DOCUMENTED` (instruction-format note)

---

## 5. SPI Waveform (SCLK / CPOL / CPHA / prescaler)

Validity domain: all parameters, `ECHO_SCLK=0`.

#### EXEC-SCLK-01
- Description: The SCLK period is `(div+1) * 2` core clocks; equivalently `f_sclk = f_clk / ((div+1)*2)`. `div=0` gives the fastest SCLK (half the core-clock rate).
- Rationale: Defines the exact bus clock a slave device sees.
- Provenance: `DOCUMENTED (non-independent)` + `EXTERNAL` **`(drivers)` — load-bearing.** Both drivers invert this exact formula to pick the prescaler, so a mismatch means a wrong bus clock in the field. Evidence in `driver.md`.

#### EXEC-SCLK-02
- Description: When not transferring, `sclk` idles at the CPOL level.
- Rationale: Bus clock idles at the configured polarity between transfers.
- Provenance: `DOCUMENTED` + `EXTERNAL`

#### EXEC-SCLK-03
- Description: The CPOL/CPHA pair selects sampling/update edges per the SPI standard: CPHA=0 samples on the leading edge and updates on the trailing edge; CPHA=1 samples on the trailing edge and updates on the leading edge; CPOL sets the idle polarity. All four modes (00/01/10/11) MUST produce the standard edge relationship a compliant SPI slave expects.
- Rationale: Correct edge relationships are required for interoperability with standard SPI slaves.
- Provenance: `EXTERNAL` (SPI) + `DOCUMENTED`

#### EXEC-SCLK-04
- Description: A runtime change of CPOL/CPHA or of the prescaler (via Configuration-Write) takes effect on the next transfer, not the current one.
- Rationale: Configuration changes must be atomic at transfer boundaries.
- Provenance: `DOCUMENTED`

#### EXEC-SCLK-05
- Description: `sclk`, `sdo`, and `sdo_t` retain a fixed mutual timing alignment across all CPOL/CPHA/div settings (a slave sees data valid at the specified sampling edge).
- Rationale: Data must be valid at the sampling edge regardless of mode or clock rate.
- Provenance: `EXTERNAL` (SPI) — the *effect*; the extra output pipeline stage that produces it is implementation

---

## 6. Flow Control / Backpressure

Validity domain: all parameters, `ECHO_SCLK=0`.

#### EXEC-FLOW-01
- Description: A write-enabled Transfer does not start a word until the outbound word is available on the SDO stream; if not, the transfer stalls (SCLK does not advance) with no invalid data emitted.
- Rationale: Prevents transmitting undefined data when the source is not ready.
- Provenance: `DOCUMENTED`

#### EXEC-FLOW-02
- Description: A read-enabled Transfer does not start / advance past a word until the SDI sink can accept the previously captured word (`sdi_data_ready`); otherwise it stalls with no captured data lost.
- Rationale: Prevents overwriting a captured word the sink has not yet taken.
- Provenance: `DOCUMENTED`

#### EXEC-FLOW-03
- Description: Backpressure applied at an arbitrary bit or word boundary (on SDO, SDI, SYNC, or CMD) suspends progress and resumes correctly, preserving word ordering and data integrity across the stall.
- Rationale: The module must be lossless under backpressure applied anywhere.
- Provenance: `DOCUMENTED` (transfer instruction: "stalled until there's no longer any backpressure")

#### EXEC-FLOW-04
- Description: For the **last** word of a transfer, the continue-gate does not require a further outbound word (there is none to fetch).
- Rationale: The end of a transfer must not stall waiting for a nonexistent next word.
- Provenance: `RTL-CHARACTERIZED` (optimization; effect is boundary-visible timing)

#### EXEC-FLOW-05
- Description: Once `sdi_data_valid` is asserted, `sdi_data` MUST remain stable until the beat is accepted (`sdi_data_valid && sdi_data_ready`).
- Rationale: AXI-Stream payload-stability contract; a compliant sink relies on it.
- Provenance: `EXTERNAL` (AXI-Stream payload stability). **This is violated in the current RTL under sub-word backpressure at `div=0` — see FLAG EXEC-F1.**

---

## 7. Transmit Data Path (SDO) — boundary behavior

Validity domain: all parameters.

#### EXEC-SDO-01
- Description: Each transmitted word appears on `sdo` MSB-first, one bit per SCLK bit-period, for `word_length` bits.
- Rationale: Standard serial transmit framing.
- Provenance: `EXTERNAL` (SPI) + `DOCUMENTED`

#### EXEC-SDO-02
- Description: When `word_length < DATA_WIDTH`, the word's most-significant bit (bit `word_length-1` of the value) is transmitted first — i.e. the short word is MSB-aligned on the wire, independent of `DATA_WIDTH`.
- Rationale: Short words must be positioned deterministically on the wire regardless of build width.
- Provenance: `DOCUMENTED` (dynamic length register intent) / left-alignment detail `RTL-CHARACTERIZED` **`(drivers)`** — Linux relies on hardware left-alignment, confirming it is a module behavior. Evidence in `driver.md`.

#### EXEC-SDO-03
- Description: When no write transfer is active, or outside a command, every `sdo` lane presents `sdo_idle_state`.
- Rationale: Defined idle level on the transmit lines at all non-write times.
- Provenance: `DOCUMENTED`

#### EXEC-SDO-04
- Description: Outbound words are consumed from the SDO stream via `sdo_data_valid`/`sdo_data_ready`; exactly `n+1` words are consumed per write-enabled Transfer of length `n`.
- Rationale: The stream consumption count must match the transfer length exactly.
- Provenance: `DOCUMENTED` (control-interface)

### 7.1 Multi-lane transmit (NUM_OF_SDIO > 1)

Validity domain: `NUM_OF_SDIO ∈ [1..8]`.

#### EXEC-LANE-01
- Description: Only lanes selected by the SDO lane mask carry transmit data; the sequence of words consumed from the SDO stream is distributed across the **active** lanes in ascending physical-lane order.
- Rationale: Deterministic mapping of stream words onto physical lanes.
- Provenance: `DOCUMENTED` (SDO lane mask register) / distribution order `RTL-CHARACTERIZED` **`(Linux)`** — Linux drives the SDO mask (IP v2.0+). See FLAG EXEC-F9 (`findings.md`), evidence in `driver.md`.

#### EXEC-LANE-02
- Description: Lanes whose mask bit is 0 present `sdo_idle_state` (they carry no data).
- Rationale: Inactive lanes must present the idle level, not stale data.
- Provenance: `DOCUMENTED`

#### EXEC-LANE-03
- Description: Arbitrary masks — contiguous, sparse (e.g. `1010`), single-lane, all-lanes — MUST map words to the correct physical lanes for every `NUM_OF_SDIO ∈ [1..8]`.
- Rationale: Lane routing must be correct for any mask pattern, not just contiguous ones.
- Provenance: `DOCUMENTED` (register) / behavior `RTL-CHARACTERIZED` **`(Linux)`** — Linux drives per-lane masks, but only those its `lane_map` produces, not arbitrary sparse patterns. Evidence in `driver.md`.

#### EXEC-LANE-04
- Description: Re-writing the SDO lane mask between transfers remaps the lanes for the next transfer.
- Rationale: Per-transfer lane reconfiguration must take effect on the following transfer.
- Provenance: `RTL-CHARACTERIZED` **`(Linux)`** — Linux rewrites the masks per-message on a multi-lane-mode change and restores them afterward. Evidence in `driver.md`.

---

## 8. Receive Data Path (SDI) — standard capture (`ECHO_SCLK=0`)

Validity domain: all parameters, `ECHO_SCLK=0`.

#### EXEC-SDI-01
- Description: For each read-enabled word, `sdi` is sampled MSB-first for `word_length` bits and the assembled word is presented on the corresponding `sdi_data` lane slice (`sdi_data[i*DATA_WIDTH +: DATA_WIDTH]` for lane `i`).
- Rationale: Standard serial receive assembly into the correct lane slice.
- Provenance: `DOCUMENTED` + `EXTERNAL` (MSB-first)

#### EXEC-SDI-02
- Description: `sdi_data_valid` asserts once a word has been fully received and holds until `sdi_data_ready` accepts it (subject to EXEC-FLOW-05 / FLAG EXEC-F1).
- Rationale: Received words are handed off with a valid/ready handshake.
- Provenance: `DOCUMENTED`

#### EXEC-SDI-03
- Description: Exactly `n+1` SDI words are produced per read-enabled Transfer of length `n`.
- Rationale: The produced word count must match the transfer length exactly.
- Provenance: `DOCUMENTED`

#### EXEC-SDI-04
- Description: Each SDIO lane is captured independently into its own `DATA_WIDTH` slice of `sdi_data` (multi-lane receive).
- Rationale: Multi-lane receive must keep each lane's data in its own slice.
- Provenance: `DOCUMENTED` (interface width) / per-lane `RTL-CHARACTERIZED`

#### EXEC-SDI-05
- Description: `SDI_DELAY ∈ [0..3]` shifts the `sdi` sampling point later by that many core clocks to tolerate high-SCLK round-trip delay, without changing which bit lands in which position.
- Rationale: Round-trip delay compensation must not reorder captured bits.
- Provenance: `RTL-CHARACTERIZED` — see FLAG EXEC-F5

---

## 9. Offload Interaction (boundary view)

Validity domain: all parameters. Full offload behavior is out of scope (EXEC-OOS-02);
only the `s_offload_active` effect at this boundary is stated.

#### EXEC-OFF-01
- Description: When `s_offload_active=1`, the module may prefetch SDO data (assert `sdo_data_ready` ahead of the write instruction); when `0`, it waits for the write instruction and lane-mask processing before consuming SDO data.
- Rationale: Offload mode allows prefetch to hide DMA latency; FIFO mode does not.
- Provenance: `DOCUMENTED` (execution.rst theory-of-operation; offload prefetch)

#### EXEC-OFF-02
- Description: Offload prefetch requires **all** SDO lanes active; otherwise the module waits for the write instruction.
- Rationale: Prefetch across a sub-mask would consume stream words for lanes that carry no data.
- Provenance: `DOCUMENTED` — **not implemented in RTL** (confirmed bug, see `bug_log.md`): the prefetch gate ignores the lane mask, so a sub-mask does not suppress prefetch. Kept as a failing regression.

#### EXEC-OFF-03
- Description: The resulting `spi`-bus waveform for a given command/SDO sequence MUST be identical whether driven in FIFO mode or offload mode; only stream readiness/prefetch **timing** differs.
- Rationale: Offload must not change the wire behavior, only the transport of commands/data.
- Provenance: `DOCUMENTED` (implied) — **coverage hole:** the TB hardwires `s_offload_active=0`, so this requirement is currently unverified. **`(drivers)`** — both drivers' offload paths reuse the same compiled command list (same commands, different transport), the invariant asserted here. Evidence in `driver.md`.

---

## 10. SPI Bus Outputs (summary of boundary contract)

#### EXEC-BUS-01
- Description: `sclk` per §5.
- Rationale: Collects the SCLK contract into the bus-output summary.
- Provenance: `DOCUMENTED` + `EXTERNAL`

#### EXEC-BUS-02
- Description: `sdo[NUM_OF_SDIO-1:0]`: per-lane serial out, MSB-first, idle = `sdo_idle_state`.
- Rationale: Summarizes the transmit-line boundary contract.
- Provenance: `DOCUMENTED` + `EXTERNAL`

#### EXEC-BUS-03
- Description: `sdo_t`: 0 (driven) only during a write transfer, 1 (tri-stated) otherwise.
- Rationale: Summarizes the transmit tri-state contract.
- Provenance: `DOCUMENTED` + `EXTERNAL`

#### EXEC-BUS-04
- Description: `cs[NUM_OF_CS-1:0]`: chip-selects with invert mask applied; reset = all-inactive.
- Rationale: Summarizes the chip-select boundary contract.
- Provenance: `DOCUMENTED` (mask) / reset `RTL-CHARACTERIZED`

#### EXEC-BUS-05
- Description: `three_wire` reflects SPI-config bit 2; in three-wire mode the external top level muxes `sdi` onto MOSI.
- Rationale: Exposes the three-wire mode selection at the boundary.
- Provenance: `DOCUMENTED`

#### EXEC-BUS-06
- Description: `sdi[NUM_OF_SDIO-1:0]`: sampled input, up to 8 lanes.
- Rationale: Summarizes the receive-line boundary contract.
- Provenance: `DOCUMENTED`

#### EXEC-BUS-07
- Description: `echo_sclk`: consumed only in `ECHO_SCLK=1` builds (out of scope this revision — see the Echo-SCLK observations in `findings.md`).
- Rationale: Notes the echo-clock input exists but is out of scope here.
- Provenance: `RTL-CHARACTERIZED`

---

## 11. Cross-Cutting Corner Cases (regression focus)

Each combines base requirements above; validity domains inherited from them.

#### EXEC-CC-01
- Description: A Configuration-Write of `word_length` (or lane mask, CPOL/CPHA, div) immediately followed by a Transfer uses the **new** value on that Transfer.
- Rationale: Verifies the fragile config-then-transfer settling margin (FLAG EXEC-F7).
- Provenance: `DOCUMENTED` — see FLAG EXEC-F7

#### EXEC-CC-02
- Description: Single-word (`n=0`) and multi-word (`n>0`) transfers both terminate correctly and return to idle.
- Rationale: Exercises the transfer-termination boundary at both extremes.
- Provenance: `DOCUMENTED`

#### EXEC-CC-03
- Description: Minimum and maximum (`=DATA_WIDTH`) `word_length` both work; short words are MSB-aligned (EXEC-SDO-02).
- Rationale: Exercises the word-length range and alignment together.
- Provenance: `DOCUMENTED`

#### EXEC-CC-04
- Description: Zero-delay (`t=0`) vs non-zero CS and Sleep instructions both produce the timing of their closed-form formulas.
- Rationale: Verifies the CS/Sleep timing formulas at both `t=0` and `t>0`.
- Provenance: `DOCUMENTED`

#### EXEC-CC-05
- Description: An interleaved sequence (CS-assert → config → transfer → sleep → sync → CS-deselect) executes in order with correct idle transitions.
- Rationale: Verifies in-order execution across a mixed instruction stream.
- Provenance: `DOCUMENTED`

#### EXEC-CC-06
- Description: Back-to-back transfers with SDI/SDO backpressure inserted at arbitrary bit/word boundaries preserve data integrity and ordering (subject to FLAG EXEC-F1).
- Rationale: Verifies lossless backpressure handling across consecutive transfers.
- Provenance: `DOCUMENTED`

#### EXEC-CC-07
- Description: Reset asserted mid-transfer returns all outputs to their §2 reset values and clears receive state.
- Rationale: Verifies mid-transfer reset recovery.
- Provenance: `RTL-CHARACTERIZED`

#### EXEC-CC-08
- Description: Lane-mask reconfiguration (SDO) between transfers remaps lanes on the next transfer.
- Rationale: Verifies per-transfer lane remapping in a sequence.
- Provenance: `RTL-CHARACTERIZED` **`(Linux)`** — Linux rewrites and restores lane masks around multi-lane-mode changes. Evidence in `driver.md`.

#### EXEC-CC-09
- Description: All `DATA_WIDTH ∈ {8,16,24,32}` and representative `NUM_OF_SDIO` / `NUM_OF_CS` values are exercised.
- Rationale: Ensures the parameter space is covered, not just the default build.
- Provenance: `DOCUMENTED` (param space)

