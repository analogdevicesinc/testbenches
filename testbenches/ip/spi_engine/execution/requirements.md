# SPI Engine Execution Module — Behavioral Specification & Requirements

Requirements in this document follow the project requirement format.

## Module boundary

(the only vocabulary this requirement may use)

| Group | Signals |
|-------|---------|
| Clock/reset | `clk`, `resetn` (active-low) |
| CMD stream (in) | `cmd_valid`, `cmd_ready`, `cmd[15:0]` |
| SDO stream (in) | `sdo_data_valid`, `sdo_data_ready`, `sdo_data[DATA_WIDTH-1:0]` |
| SDI stream (out)| `sdi_data_valid`, `sdi_data_ready`, `sdi_data[NUM_OF_SDIO*DATA_WIDTH-1:0]`, `sdi_data_overflow` |
| SYNC stream (out)| `sync_valid`, `sync_ready`, `sync[7:0]` |
| Offload | `s_offload_active` |
| SPI bus | `sclk`, `sdo[NUM_OF_SDIO-1:0]`, `sdo_t`, `sdi[NUM_OF_SDIO-1:0]`, `cs[NUM_OF_CS-1:0]`, `three_wire`, `echo_sclk` |

All four `ctrl` streams use AXI-stream valid/ready handshaking: a beat transfers on
the cycle where valid and ready are both asserted; once valid is asserted the
payload MUST remain stable until the beat is accepted (`EXTERNAL`, AXI-Stream rule).

---

## Definitions

Terms defined here may be used by any later requirement. A
defined term's use in a requirement's Description or Rationale MUST be emphasized
with single asterisks, e.g. `*fully configured*`.

- **fully configured** (of the active SDO lane mask): the active SDO lane mask is
  fully configured once the module has finished applying that mask to its internal
  lane sequencing, such that every subsequent SDO prefetch or per-lane data movement
  uses that mask's lane assignment rather than the mask that was active before it
  changed. Before that point, the mask is **not yet fully configured**.

- **CORE_CLK_CNT**: the number of core clocks from the cycle the module accepts an
  instruction (`cmd_valid` and `cmd_ready` both asserted) to the cycle it returns to
  idle and accepts the next instruction.

- **full** (of the SDI capture buffer): the SDI capture buffer is full when it
  cannot hold any additional SDI word until the SDI data sink consumes one of the
  words it currently holds.

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
- Provenance: `RTL-CHARACTERIZED`
- Note: absent from the current `spi_engine_execution.rst` parameter table; characterized from RTL only pending a documentation update.

#### EXEC-PARAM-07
- Description: `ECHO_SCLK` ∈ {0,1} selects the SDI capture datapath (0 = capture on the internally-generated SPI clock; 1 = capture on the looped-back `echo_sclk`). Most requirements in this spec hold for both values; a requirement restricted to one value states that domain explicitly. The echo-specific capture-edge-selection and completion-timing mechanisms remain deferred — see §12 (EXEC-ECHO-C1/C2).
- Rationale: Defines the capture-path selector and scopes which behaviors are mode-independent versus mode-specific.
- Provenance: `RTL-CHARACTERIZED`
- Note: absent from the current `spi_engine_execution.rst` parameter table; characterized from RTL only pending a documentation update.

#### EXEC-PARAM-08
- Description: `SDI_DELAY` ∈ [0..3] makes the module capture each `sdi` bit `SDI_DELAY`+1 core-clock cycles after the SCLK sampling edge at the `sclk` pin, to tolerate high-SCLK round-trip delay (`ECHO_SCLK=0` path).
- Rationale: Lets high-SCLK builds tolerate round-trip delay without misaligning captured bits.
- Provenance: `RTL-CHARACTERIZED`
- Note: absent from the current `spi_engine_execution.rst` parameter table; characterized from RTL only pending a documentation update.

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

<!-- Reviewed: EXEC-RST-06 bundles two independently-testable behaviors (three_wire reset value; sync_valid/sdi_data_valid deassertion). Left as one ID per the append-only ID policy rather than split — not a TODO. -->
#### EXEC-RST-06
- Description: After reset `three_wire` reflects `DEFAULT_SPI_CFG[2]`; `sync_valid` and `sdi_data_valid` are deasserted.
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
- Provenance: `DOCUMENTED` (instruction-format) **`(Linux)`**.

#### EXEC-CMD-04
- Description: Commands execute strictly in the order accepted; the module completes one instruction (returns to idle) before accepting the next, except that a Configuration-Write completes in a single cycle (EXEC-CFG-07).
- Rationale: Deterministic in-order execution is required for the command program to be meaningful.
- Provenance: `DOCUMENTED` (pipeline-delays)

#### EXEC-CMD-05
- Description: Deprecated. Merged into EXEC-XFER-08.
- Rationale: The completion bound of EXEC-XFER-08 applies to every accepted Transfer, including back-to-back ones.
- Provenance: N/A.

---

## 4. Instruction Semantics

### 4.1 Transfer (opcode `000`) — `cmd[9]=r`, `cmd[8]=w`, `cmd[7:0]=n`

Validity domain: all parameters.

#### EXEC-XFER-01
- Description: A Transfer generates SCLK for `n+1` words, each `word_length` bits long (word_length per §4.3).
- Rationale: Defines the transfer-length encoding (zero-based word count).
- Provenance: `DOCUMENTED` **`(drivers)`**.

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
- Provenance: `DOCUMENTED` **`(Linux)`** — Linux core drives `01`/`10`/`11`; `00` driven by neither driver.

#### EXEC-XFER-06
- Description: During a read-only transfer (`w=0`), `sdo` is held at `sdo_idle_state`; outside a write transfer `sdo_t` is asserted (tri-stated).
- Rationale: The module must not drive spurious data on `sdo` when not writing.
- Provenance: `DOCUMENTED` (sdo_idle_state) / `EXTERNAL` (tri-state)

#### EXEC-XFER-07
- Description: A Transfer does not begin, and mid-transfer does not advance past a word boundary, until flow-control readiness is met (§6); when not ready it stalls with no data loss.
- Rationale: Flow-control gating keeps the transfer lossless under backpressure.
- Provenance: `DOCUMENTED`

#### EXEC-XFER-08
- Description: If a Transfer is accepted and `sdo_data_valid` and `sdi_data_ready` are asserted throughout it, *CORE_CLK_CNT* MUST be at most `(n+1) * word_length * (div+1) * 2 + 16 * (n+2)` (`n+1` is the number of words, EXEC-XFER-01; `word_length` per §4.3; `div` per EXEC-CFG-01).
- Validity domain: `ECHO_SCLK=0` (see EXEC-XFER-10); all `{r,w}` combinations.
- Rationale: A hung or runaway stalled Transfer fails this bound. The first term is the shifting time (EXEC-XFER-01, EXEC-SCLK-01). The second term is a per-instruction and per-word allowance of 16 core clocks each, sized above the overheads measured in the largest legal builds, including full-duplex (ticket 11).
- Provenance: `DOCUMENTED (non-independent)` (pipeline-delays: "2 cycles plus transfer time") for the shifting-time term; `RTL-CHARACTERIZED` for the sizing of the 16-clock allowances.

#### EXEC-XFER-09
- Description: Deprecated. Merged into EXEC-XFER-08.
- Rationale: One duration requirement lists every software-set case.
- Provenance: N/A.

#### EXEC-XFER-10
- Description: If `ECHO_SCLK=1`, the completion bound of EXEC-XFER-08 is not specified by this document.
- Rationale: Completion timing in `ECHO_SCLK=1` builds is out of scope (EXEC-ECHO-C2, §12).
- Provenance: N/A — scope statement.

### 4.2 Chip-Select (opcode `001`) — `cmd[9:8]=t`, `cmd[7:0]=s`

Validity domain: all parameters.

#### EXEC-CS-01
- Description: The instruction drives the `cs` output to the value `s` (low `NUM_OF_CS` bits), after applying the CS-invert mask (EXEC-CSINV-*). A field bit of 0 selects the corresponding device.
- Rationale: Chip-select control with active-low selection semantics.
- Provenance: `DOCUMENTED` **`(drivers)`** — active-low confirmed; sparse multi-select (EXEC-CS-05) undriven by both.

#### EXEC-CS-02
- Description: The module MUST insert a prescaler-scaled delay `t` **both before and after** the CS change. The CS value MUST change at exactly `2 + t*(div+1)*2` core clocks after the instruction starts, and the instruction MUST complete at exactly `2 + 2*t*(div+1)*2` core clocks.
- Rationale: Provides programmable setup/hold time around the chip-select edge.
- Provenance: `DOCUMENTED (non-independent)` (instruction-format + pipeline-delays) **`(no-OS)`** — only no-OS uses the ASSERT `t` field; Linux uses separate Sleeps.

#### EXEC-CS-03
- Description: With `t=0` the instruction applies the CS change with only the fixed internal-logic latency (no pre/post wait).
- Rationale: Allows an immediate chip-select change when no guard delay is needed.
- Provenance: `DOCUMENTED` **`(drivers)`** — both emit `t=0` chip-selects (Linux exclusively so).

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
- Provenance: `DOCUMENTED` **`(drivers)`** — config bit constants match 0/1/2/3 exactly.

#### EXEC-CFG-03
- Description: Register `010` (dynamic transfer length): sets `word_length` = `v`, the number of SCLK bit-periods per word for subsequent transfers. Default (and reset) is `DATA_WIDTH`.
- Rationale: Runtime control of per-word bit length.
- Provenance: `DOCUMENTED`

#### EXEC-CFG-04
- Description: Register `011` (SDI lane mask): the value is accepted. **This module produces no boundary-visible effect from the SDI lane mask** — its masking effect is downstream in `axi_spi_engine`. Out of scope here — see EXEC-OOS-01 (§12).
- Rationale: The register write must be accepted here even though its effect is observable only downstream.
- Provenance: `DOCUMENTED` (register) / effect out of scope **`(Linux)`** — Linux writes it (IP v2.0+); no-OS never does.

#### EXEC-CFG-05
- Description: Register `100` (SDO lane mask): selects which `sdo` lanes carry transmit data; lanes whose mask bit is 0 output `sdo_idle_state` (EXEC-LANE-*).
- Rationale: Runtime selection of active transmit lanes.
- Provenance: `DOCUMENTED` **`(Linux)`** — Linux writes it (IP v2.0+); unexercised by no-OS.

#### EXEC-CFG-06
- Description: A value written to the dynamic transfer length register MUST NOT exceed `DATA_WIDTH`; behavior for larger values is unspecified.
- Rationale: The hardware word datapath is only `DATA_WIDTH` wide; larger values leave defined behavior.
- Provenance: `DOCUMENTED` (constraint stated) **`(no-OS)`** — no-OS clamps; Linux does *not*, so it can drive the out-of-range region.
- Note: no-OS clamps requested transfer width to the `DATA_WIDTH` readback, but the Linux driver does not (`bits_per_word_mask` allows 1..32) — so this constraint is not universally enforced by reference software, and a narrow-`DATA_WIDTH` build can be driven above `DATA_WIDTH` by real SW.

#### EXEC-CFG-07
- Description: A Configuration-Write executes in 1 core clock and does not remove the module from its command-accepting state for more than that cycle (back-to-back config writes accept at 1 command/cycle).
- Rationale: Configuration must not stall the command stream, so setup sequences stay fast.
- Provenance: `DOCUMENTED` (pipeline-delays)

### 4.4 MISC — Sync (opcode `011`, `cmd[8]=0`) and Sleep (`cmd[8]=1`)

#### EXEC-SYNC-01
- Description: Sync drives `sync = cmd[7:0]` (event id) and asserts `sync_valid`; `sync_valid` holds until `sync_ready` is seen, then the module returns to idle. Execution time = 2 core clocks plus any wait for `sync_ready`.
- Rationale: Emits a host-visible event marker used to signal transfer progress/completion.
- Provenance: `DOCUMENTED` **`(drivers)` — load-bearing.** The `sync[7:0]` id round-trip is the sole transfer-completion signal in both drivers.

#### EXEC-SLEEP-01
- Description: Sleep MUST stall the command stream for exactly `sleep_time = 2 + (t+1) * (div+1) * 2` core clocks (`t=cmd[7:0]`), then MUST resume; `spi`/`ctrl` activity MUST NOT occur during the stall.
- Rationale: Inserts a programmable inter-instruction delay without bus activity.
- Provenance: `DOCUMENTED (non-independent)` **`(drivers)`** — both pre-decrement, voting the `(t+1)` form.
- Note: `instruction-format.rst` and `pipeline-delays.rst` state two different formulas for this delay (with vs. without a `+1` term); this spec follows the `instruction-format.rst` reading, corroborated by both reference drivers pre-decrementing their sleep parameter (`SLEEP(n-1)`) to compensate for a `(t+1)` hardware form. Direct RTL/simulation measurement would make this authoritative.

#### EXEC-SLEEP-02
- Description: Sleep with `t=0` still produces the minimum non-zero delay given by the EXEC-SLEEP-01 formula.
- Rationale: Even the smallest sleep guarantees a defined minimum stall.
- Provenance: `DOCUMENTED`

### 4.5 CS-Invert-Mask (opcode `100`) — `cmd[7:0]=m` (low `NUM_OF_CS` bits used)

#### EXEC-CSINV-01
- Description: For each mask bit set, the corresponding `cs` pin is inverted at the output register: that pin becomes active-high; mask bit 0 leaves it active-low (default). The inversion is applied only at the output — the Chip-Select instruction's `s` field still names the same logical selection regardless of mask.
- Rationale: Supports active-high chip-select devices without changing the logical selection encoding.
- Provenance: `DOCUMENTED` **`(Linux)`** — Linux emits CS-Invert-Mask to implement `SPI_CS_HIGH`.

#### EXEC-CSINV-02
- Description: The mask persists across subsequent Chip-Select instructions until re-written or reset (reset = 0, no inversion).
- Rationale: CS polarity must remain stable across the transfers of a device without re-programming.
- Provenance: `DOCUMENTED` / `RTL-CHARACTERIZED` (reset value) **`(Linux)`** — Linux sets the mask once in setup and relies on persistence.

#### EXEC-CSINV-03
- Description: Changing the invert mask does not itself change which device the "assert a chip-select" clear logic (EXEC-CS-04) reacts to — that logic keys on the logical selection, not the inverted pin level.
- Rationale: Receive-state clearing must track the logical selection, independent of pin polarity.
- Provenance: `DOCUMENTED` (instruction-format note)

---

## 5. SPI Waveform (SCLK / CPOL / CPHA / prescaler)

Validity domain: all parameters.

#### EXEC-SCLK-01
- Description: The SCLK period is `(div+1) * 2` core clocks; equivalently `f_sclk = f_clk / ((div+1)*2)`. `div=0` gives the fastest SCLK (half the core-clock rate).
- Rationale: Defines the exact bus clock a slave device sees.
- Provenance: `DOCUMENTED (non-independent)` + `EXTERNAL` **`(drivers)` — load-bearing.** Both drivers invert this exact formula to pick the prescaler, so a mismatch means a wrong bus clock in the field.

#### EXEC-SCLK-02
- Description: When not transferring, `sclk` idles at the CPOL level.
- Rationale: Bus clock idles at the configured polarity between transfers.
- Provenance: `DOCUMENTED` + `EXTERNAL`

#### EXEC-SCLK-03
- Description: The CPOL/CPHA pair selects sampling/update edges per the SPI standard: CPHA=0 samples on the leading edge and updates on the trailing edge; CPHA=1 samples on the trailing edge and updates on the leading edge; CPOL sets the idle polarity. All four modes (00/01/10/11) MUST produce the standard edge relationship a compliant SPI slave expects.
- Rationale: Correct edge relationships are required for interoperability with standard SPI slaves.
- Provenance: `EXTERNAL` (SPI) + `DOCUMENTED`

#### EXEC-SCLK-04
- Description: A runtime change of CPOL/CPHA, the prescaler, or `word_length` (via Configuration-Write) takes effect on the next transfer, not the current one.
- Rationale: Configuration changes must be atomic at transfer boundaries.
- Provenance: `DOCUMENTED`

#### EXEC-SCLK-05
- Description: `sclk`, `sdo`, and `sdo_t` retain a fixed mutual timing alignment across all CPOL/CPHA/div settings (a slave sees data valid at the specified sampling edge).
- Rationale: Data must be valid at the sampling edge regardless of mode or clock rate.
- Provenance: `EXTERNAL` (SPI) — the *effect*; the extra output pipeline stage that produces it is implementation

#### EXEC-SCLK-06
- Description: Deprecated. Merged into EXEC-SCLK-04.
- Rationale: EXEC-SCLK-04 already states that a runtime `word_length` change governs the next transfer; the number of SCLK periods per word follows from EXEC-XFER-01.
- Provenance: N/A.

---

## 6. Flow Control / Backpressure

Validity domain: all parameters.

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
- Provenance: `EXTERNAL` (AXI-Stream payload stability).

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
- Provenance: `DOCUMENTED` (dynamic length register intent) / left-alignment detail `RTL-CHARACTERIZED` **`(drivers)`** — Linux relies on hardware left-alignment, confirming it is a module behavior.

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
- Provenance: `DOCUMENTED` (SDO lane mask register) / distribution order `RTL-CHARACTERIZED` **`(Linux)`** — Linux drives the SDO mask (IP v2.0+).

#### EXEC-LANE-02
- Description: Lanes whose mask bit is 0 present `sdo_idle_state` (they carry no data).
- Rationale: Inactive lanes must present the idle level, not stale data.
- Provenance: `DOCUMENTED`

#### EXEC-LANE-03
- Description: Arbitrary masks — contiguous, sparse (e.g. `1010`), single-lane, all-lanes — MUST map words to the correct physical lanes for every `NUM_OF_SDIO ∈ [1..8]`.
- Rationale: Lane routing must be correct for any mask pattern, not just contiguous ones.
- Provenance: `DOCUMENTED` (register) / behavior `RTL-CHARACTERIZED` **`(Linux)`** — Linux drives per-lane masks, but only those its `lane_map` produces, not arbitrary sparse patterns.

#### EXEC-LANE-04
- Description: Re-writing the SDO lane mask between transfers remaps the lanes for the next transfer.
- Rationale: Per-transfer lane reconfiguration must take effect on the following transfer.
- Provenance: `RTL-CHARACTERIZED` **`(Linux)`** — Linux rewrites the masks per-message on a multi-lane-mode change and restores them afterward.

#### EXEC-LANE-05
- Description: If a transmit word was assembled under the SDO lane mask that is currently active, the module MAY drive that word onto `sdo`. Otherwise, the module MUST discard that word.
- Rationale: A word is only ever driven when its lane assignment matches the mask in effect right now; a word assembled under a mask that is no longer active no longer corresponds to any lane configuration the module will transmit under, so discarding it closes the stale-data window regardless of how many pipeline stages separate assembly from the `sdo` output, and regardless of how the active lane count relates to that pipeline depth.
- Provenance: `RTL-CHARACTERIZED` — observed on `hdl_repo` branch `bugfix_spiengine_execution`.

#### EXEC-LANE-06
- Description: If the active SDO lane mask changes while a transmit word is partially assembled, the module MUST discard that partial assembly.
- Rationale: Continuing a partially-assembled word with lane positions chosen under the previous mask would mix old- and new-configuration lane assignments within a single word, producing data that matches neither mask.
- Provenance: `RTL-CHARACTERIZED` — observed on `hdl_repo` branch `bugfix_spiengine_execution`.

#### EXEC-LANE-09
- Description: If the active SDO lane mask is *fully configured*, the module MUST assemble SDO words using that mask.
- Rationale: Ensures word assembly always proceeds under the currently settled lane configuration, so a word is never built using lane positions left over from a mask that is no longer in effect.
- Provenance: `RTL-CHARACTERIZED` — observed on `hdl_repo` branch `bugfix_spiengine_execution`.

#### EXEC-LANE-07
- Description: If a transmit word has been fully assembled, the module MUST drive that word onto `sdo` exactly once.
- Rationale: A readiness indication that remains valid after its word has already been shifted out can cause the same assembled data to be driven onto `sdo` a second time while a different stream word is silently skipped, corrupting both the duplicated and the dropped word's place in the transmitted sequence.
- Provenance: `RTL-CHARACTERIZED` — observed on `hdl_repo` branch `bugfix_spiengine_execution`.

#### EXEC-LANE-08
- Description: If a command changes the active SDO lane mask, the module MUST NOT consume any SDO data word while executing that command.
- Rationale: The reconfiguration command only changes which lanes are active; treating it as a data-consuming transfer would pop a stream word that is never transmitted under the configuration it was popped for, desynchronizing the stream from the lanes before the new mapping even takes effect.
- Provenance: `RTL-CHARACTERIZED` — observed on `hdl_repo` branch `bugfix_spiengine_execution`.

---

## 8. Receive Data Path (SDI)

Validity domain: all parameters.

#### EXEC-SDI-01
- Description: For each read-enabled word, `sdi` is sampled MSB-first for `word_length` bits and the assembled word is presented on the corresponding `sdi_data` lane slice (`sdi_data[i*DATA_WIDTH +: DATA_WIDTH]` for lane `i`).
- Rationale: Standard serial receive assembly into the correct lane slice.
- Provenance: `DOCUMENTED` + `EXTERNAL` (MSB-first)

#### EXEC-SDI-02
- Description: `sdi_data_valid` asserts once a word has been fully received and holds until `sdi_data_ready` accepts it (subject to EXEC-FLOW-05).
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
- Validity domain: `ECHO_SCLK=0` (`SDI_DELAY` has no effect on the `ECHO_SCLK=1` capture path — see EXEC-PARAM-08).
- Rationale: Round-trip delay compensation must not reorder captured bits.
- Provenance: `RTL-CHARACTERIZED`

#### EXEC-SDI-06
- Description: The module MUST buffer up to two captured SDI words that have not yet been consumed by the SDI data sink.
- Rationale: Buffering one word beyond the one presented at `sdi_data`/`sdi_data_valid` lets capture continue while the sink has not yet accepted it, before the module must drop further words.
- Provenance: `RTL-CHARACTERIZED` — this buffering depth is observable only in RTL, not documented intent.

#### EXEC-SDI-07
- Description: If a new SDI word arrives while the SDI capture buffer is *full*, the module MUST discard that word.
- Rationale: Discarding the new word instead of displacing a buffered one preserves all previously captured, not-yet-consumed data; overwriting would silently lose data the module already accepted.
- Provenance: `RTL-CHARACTERIZED` — capacity and drop-on-full behavior are observable only in RTL, not documented intent.

#### EXEC-SDI-08
- Description: If the module discards a new SDI word because the SDI capture buffer is *full*, the module MUST pulse `sdi_data_overflow` for one clock cycle.
- Rationale: Without an observable signal, a dropped word is indistinguishable from normal operation; pulsing `sdi_data_overflow` makes the loss visible to whatever consumes the module's status/interrupt outputs.
- Provenance: `RTL-CHARACTERIZED` — same.

#### EXEC-SDI-09
- Description: If a Sync instruction is issued after a read-enabled Transfer, the module MUST complete the `sdi_data` handshake (`sdi_data_valid && sdi_data_ready`) of that Transfer's last SDI word no later than the cycle on which it asserts `sync_valid`.
- Validity domain: `ECHO_SCLK=0`.
- Rationale: Sync is the host-visible transfer-completion marker (EXEC-SYNC-01); a host that sees the marker reads the transfer's data next, so the data must already have reached the SDI sink. A word that is presented but not yet accepted, because the sink is backpressuring, is still inside the module when the marker arrives.
- Provenance: `DOCUMENTED` **`(drivers)`** — same dependency as EXEC-SYNC-01.

#### EXEC-SDI-10
- Description: If the SDI device drives each `sdi` bit `L` core clocks after the SCLK shift edge, with `SDI_DELAY - div <= L <= SDI_DELAY + div + 1`, the module MUST capture that bit at its correct position in the word.
- Validity domain: `ECHO_SCLK=0`.
- Rationale: The capture point trails the SCLK pin edge by `SDI_DELAY`+1 clocks (EXEC-PARAM-08) and `sdi` is sampled live; the window states which device latencies that capture point tolerates.
- Provenance: `RTL-CHARACTERIZED`
- Note: simulated at `div=0` (`L` ∈ {`SDI_DELAY`, `SDI_DELAY`+1} captured, `L` = `SDI_DELAY`+2 and `SDI_DELAY`-1 corrupt); the `div>0` bounds follow from the RTL timing and are not simulated.

---

## 9. Offload Interaction (boundary view)

Validity domain: all parameters. Full offload behavior is out of scope (EXEC-OOS-02);
only the `s_offload_active` effect at this boundary is stated.

#### EXEC-OFF-01
- Description: When `s_offload_active=1`, the module may prefetch SDO data (assert `sdo_data_ready` ahead of the write instruction); when `0`, it waits for the write instruction and lane-mask processing before consuming SDO data.
- Rationale: Offload mode allows prefetch to hide DMA latency; FIFO mode does not.
- Provenance: `DOCUMENTED` (execution.rst theory-of-operation; offload prefetch)

#### EXEC-OFF-02
- Description: If the active SDO lane mask is *fully configured*, the offload SDO prefetch MUST be enabled for that mask.
- Rationale: Gating prefetch on whether the mask is *fully configured* — rather than on how many lanes it addresses — allows full prefetch throughput under any valid sub-mask, not only when all SDO lanes are active.
- Provenance: `RTL-CHARACTERIZED` — the configuration-completeness gate (rather than a lane-count gate) is observable only in RTL, not documented intent.

#### EXEC-OFF-04
- Description: If the active SDO lane mask is not yet *fully configured*, the module MUST source SDO data only via the write instruction.
- Rationale: While the active SDO lane mask is not yet *fully configured*, offload prefetch has no valid lane mapping to consume stream words against; restricting SDO data sourcing to the write instruction during this window avoids consuming/corrupting stream data under an incomplete mapping.
- Provenance: `RTL-CHARACTERIZED` — the configuration-completeness gate (rather than a lane-count gate) is observable only in RTL, not documented intent.

#### EXEC-OFF-03
- Description: The resulting `spi`-bus waveform for a given command/SDO sequence MUST be identical whether driven in FIFO mode or offload mode; only stream readiness/prefetch **timing** differs.
- Rationale: Offload must not change the wire behavior, only the transport of commands/data.
- Provenance: `DOCUMENTED` (implied) — **coverage hole:** the TB hardwires `s_offload_active=0`, so this requirement is currently unverified. **`(drivers)`** — both drivers' offload paths reuse the same compiled command list (same commands, different transport), the invariant asserted here.

---

## 10. SPI Bus Outputs (summary of boundary contract)

Note: this section collects the SPI-bus-facing signals into one boundary
summary; each ID either restates a claim already under test elsewhere (BUS-01
sclk -> §5/EXEC-SCLK-*, BUS-02 sdo/idle -> §6/EXEC-SDO-*, BUS-06 sdi -> §7/
EXEC-SDI-*) or documents an out-of-scope input (BUS-07 -> §12). Only
BUS-03/04/05 carry a claim narrow enough to warrant their own dedicated `REQ:`
tag; BUS-01/02/06/07 are intentionally untagged - traceability for them lives
on the sections they summarize, not here.

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
- Description: `echo_sclk`: consumed only in `ECHO_SCLK=1` builds (out of scope this revision — see §12, EXEC-ECHO-C1/C2).
- Rationale: Notes the echo-clock input exists but is out of scope here.
- Provenance: `RTL-CHARACTERIZED`

---

## 11. Cross-Cutting Corner Cases (regression focus)

Each combines base requirements above; validity domains inherited from them.

#### EXEC-CC-01
- Description: A Configuration-Write of `word_length` (or lane mask, CPOL/CPHA, div) immediately followed by a Transfer uses the **new** value on that Transfer.
- Rationale: Verifies the fragile config-then-transfer settling margin.
- Provenance: `DOCUMENTED`
- Note: an RTL comment warns of required settling margin between a `word_length`/lane-mask Configuration-Write and an immediately-following Transfer; correct today under the fixed inter-instruction latency, but margin-dependent rather than structurally guaranteed — a pipeline refactor that shortens the gap could break it.

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
- Description: Back-to-back transfers with SDI/SDO backpressure inserted at arbitrary bit/word boundaries preserve data integrity and ordering.
- Rationale: Verifies lossless backpressure handling across consecutive transfers.
- Provenance: `DOCUMENTED`

#### EXEC-CC-07
- Description: Reset asserted mid-transfer returns all outputs to their §2 reset values and clears receive state.
- Rationale: Verifies mid-transfer reset recovery.
- Provenance: `RTL-CHARACTERIZED`

#### EXEC-CC-08
- Description: Lane-mask reconfiguration (SDO) between transfers remaps lanes on the next transfer.
- Rationale: Verifies per-transfer lane remapping in a sequence.
- Provenance: `RTL-CHARACTERIZED` **`(Linux)`** — Linux rewrites and restores lane masks around multi-lane-mode changes.

#### EXEC-CC-09
- Description: All `DATA_WIDTH ∈ {8,16,24,32}` and representative `NUM_OF_SDIO` / `NUM_OF_CS` values are exercised.
- Rationale: Ensures the parameter space is covered, not just the default build.
- Provenance: `DOCUMENTED` (param space)

---

## 12. Out of Scope

Behavior whose effect lives in another IP, or a datapath deferred to a future revision, is
recorded here with a pointer rather than specified as a conformance requirement of this
module. Verification method is N/A for all entries in this section — there is nothing to
check at this module's boundary.

#### EXEC-OOS-01
- Description: SDI lane mask **masking effect** (which lanes reach the host) is not boundary-visible in this module.
- Rationale: The masking is applied downstream, so no requirement on `sdi_data` masking can be stated here. The register write itself IS boundary-visible and accepted — see EXEC-CFG-04.
- Provenance: N/A — behavior lives in `axi_spi_engine`'s asymmetric SDI FIFO.

#### EXEC-OOS-02
- Description: Offload command/SDO prefetch from RAM, trigger-driven execution, and `enable`/`enabled` are not specified here; this module only exposes `s_offload_active` (§9).
- Rationale: The offload control datapath is a separate module; only its boundary effect is in scope here.
- Provenance: N/A — behavior lives in `spi_engine_offload` + the offload control interface.

#### EXEC-OOS-03
- Description: Multi-manager arbitration and CDC/FIFO latencies are not specified here.
- Rationale: These are interconnect/CDC concerns outside this module's boundary.
- Provenance: N/A — behavior lives in `spi_engine_interconnect`, `axi_spi_engine`.

#### EXEC-ECHO-C1
- Description: In `ECHO_SCLK=1` builds the SDI capture edge is selected **at build time** from `DEFAULT_SPI_CFG[1:0]` (modes `01`/`10` use the negedge datapath, others posedge); a **runtime** CPOL/CPHA change does *not* re-select the echo latch edge.
- Rationale: Recorded because it is surprising — a user who changes CPOL at runtime in an echo build gets a mismatched capture edge. No conformance requirement is asserted for the `ECHO_SCLK=1` datapath in this spec revision (it is undocumented in the official `.rst` and unmodeled by the golden model); this is a regression-lock observation pending a designer/datasheet-backed conformance spec.
- Provenance: `RTL-CHARACTERIZED`.

#### EXEC-ECHO-C2
- Description: In `ECHO_SCLK=1` builds transfer completion is derived from an edge-detected, clock-synchronized "last bit received," a different mechanism than the `ECHO_SCLK=0` path.
- Rationale: Recorded because its timing (and single-word `n=0` handling) should be independently characterized before being specified. No conformance requirement is asserted for this path in this spec revision — see EXEC-ECHO-C1.
- Provenance: `RTL-CHARACTERIZED`.

