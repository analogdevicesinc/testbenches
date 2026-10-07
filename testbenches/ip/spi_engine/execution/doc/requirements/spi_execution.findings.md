# SPI Engine Execution Module — Findings, Flags & Analysis

This is the **engineering-analysis companion** to the normative behavioral
specification `spi_execution.spec.md`. It holds the material that is *not* a
requirement: the revision note, the suspicious-behavior flags (`EXEC-F*`), the
provenance/flag audit, the known coverage holes, and the out-of-scope / Echo-SCLK
observations. The atomic `EXEC-*` requirements themselves live in the spec; each
affected requirement carries a one-line `see FLAG EXEC-Fn` pointer back here.

The requirement-strength driver cross-check (former Appendix C) now lives in
`spi_execution.driver.md`.

The RTL these findings were characterized against is **hdl_repo @ `8ae99f4c`**
(main branch, Wed Jun 24). Line/signal references are to that revision.

---

## Revision note

**Revision note:** this revision closes the previously-owed driver cross-check
against **both** reference drivers — the no-OS driver
and the Linux mainline `spi-axi-spi-engine` driver. Requirements carry `(no-OS)`,
`(Linux)`, or `(drivers)` in-line where a driver corroborates them (see the
*Driver corroboration* convention in `spec.md`); the full analysis — grading which
behaviors are load-bearing vs not-yet-driven by the reference SW — is the driver
cross-check in `spi_execution.driver.md`. The Linux
pass **resolves** the two previously-open flags: **EXEC-F8** (CS-Invert-Mask *is*
driven — by Linux — so no-OS's inability to emit it is a no-OS encoder limitation, not
a spec gap) and **EXEC-F9** (lane masks *are* driven — by Linux, on IP core v2.0+ — so
no-OS simply has not caught up). It also strengthens **EXEC-F6** (Linux does not clamp
transfer width) and adds a second `(t+1)` vote to **EXEC-F3**.

---

## Flag detail

The consolidated flag table is in the *Provenance & Flag Audit* below; the prose
blocks here are the detailed observations relocated verbatim from the spec.

### FLAG EXEC-F1

> **FLAG EXEC-F1 (appears to violate the stream payload-stability contract):** At
> `div=0` with backpressure that accepts at most one SDI word per word-period (e.g.
> `sdi_data_ready` pulsed once every `word_length` cycles), the module drives a new
> value onto `sdi_data` while `sdi_data_valid=1` and the previously-presented beat
> has **not** yet been accepted (`sdi_data_ready=0`). This appears to conflict with
> the AXI-Stream payload-stability rule (EXEC-FLOW-05). *Why noted:* a
> strictly-compliant downstream sink could capture a corrupted word. In practice
> this is not reached because the downstream asymmetric SDI FIFO always asserts
> ready within a word-period. *Resolve via:* HDL designer — fix vs.
> accept-with-documented-constraint. *Status:* captured as the `expect_fail`
> regression `test_backpressure.py::test_sdi_handshake_stability`; reproduces across
> `DATA_WIDTH ∈ {8,16,24,32}` and seeds. If the RTL is fixed, that test flips to
> FAIL and this requirement becomes a clean conformance check.

### FLAG EXEC-F5

> **FLAG EXEC-F5 (documentation gap):** `SDO_DEFAULT`, `ECHO_SCLK`, and `SDI_DELAY`
> are build parameters of the RTL but are **absent from
> `spi_engine_execution.rst`** (which lists only NUM_OF_CS, DEFAULT_SPI_CFG,
> DEFAULT_CLK_DIV, DATA_WIDTH, NUM_OF_SDIO). *Suspect:* the parameter table is
> incomplete; a user reading the docs cannot discover the echo-SCLK feature or the
> SDI latch delay. *Resolve via:* HDL designer / doc owner — confirm intended
> defaults and semantics, then document them. Until then these are
> `RTL-CHARACTERIZED`.

### FLAG EXEC-F7

> **FLAG EXEC-F7 (fragile timing):** The internal SDO assembly pipeline
> requires "some settling time between `word_length` changing and a transfer
> starting" (RTL comment). A Configuration-Write of `word_length` (or lane mask)
> *immediately* followed by a Transfer relies on the fixed inter-instruction latency
> for correctness. *Why noted:* correct today but margin-dependent; a refactor that
> shortens the gap would break it. *Resolve via:* designer confirmation that the
> minimum instruction spacing is guaranteed. Covered by EXEC-CC-01.

### FLAG EXEC-F8

> **FLAG EXEC-F8 (RESOLVED by the Linux cross-check — driven; was "not yet driven"):**
> The CS-Invert-Mask instruction (opcode `100`) *is* driven — by the **Linux** driver,
> which builds a CS-invert mask from each device's `SPI_CS_HIGH` mode and emits
> `CS-Invert-Mask` in its per-device setup routine (IP core v1.2+). It is the mechanism
> behind active-high chip-select. The earlier "not driven" reading came only from the
> **no-OS** driver, whose command encoder truncates the opcode to two bits (aliasing
> `100`→`000`) and so *cannot* emit it. *Conclusion:* this is a **no-OS encoder
> limitation, not a spec gap or a universal SW lag** — CS-Invert-Mask is a real,
> documented, Linux-driven feature. *Impact on verification:* EXEC-CSINV-* are now
> `DOCUMENTED` **`(Linux)`**-corroborated (load-bearing for `SPI_CS_HIGH` devices under
> Linux), not a bare regression lock. *Code-level evidence:* `driver.md` L.2/L.3, Part C.
> *(Original TODO — "is CS-invert meant to be driver-programmable?" — is answered: yes,
> Linux programs it. A residual note for the no-OS maintainers: the 2-bit opcode mask in
> `SPI_ENGINE_CMD` should be widened to 3 bits if no-OS ever needs active-high CS.)*

### FLAG EXEC-F9

> **FLAG EXEC-F9 (RESOLVED by the Linux cross-check — driven on IP v2.0+; was "not yet
> driven"):** Lane masks *are* driven — by the **Linux** driver, which writes both the
> SDI (`011`) and SDO (`100`) lane-mask registers from each device's `rx_lane_map[]` /
> `tx_lane_map[]`, in three places: per-message on a multi-lane-mode change, once in
> per-device setup, and in the offload trigger path (with restoration to the primary
> lane afterward). This confirms the F9 framing exactly: multi-lane is a **recent HDL
> feature gated on IP core major version ≥ 2** (Linux enables it only when it can read
> `num_data_lanes` from the DATA_WIDTH register on a v2.0+ core), which is why the
> older-style **no-OS** core path — targeting earlier cores — never writes the masks and
> leaves them at the all-lanes-active reset default. *Conclusion:* not a suspect
> behavior and no longer "not yet driven" — it is version-gated feature reach. EXEC-CFG-
> 04/05 and EXEC-LANE-* are now **`(Linux)`**-corroborated (load-bearing on v2.0+).
> *Verification impact:* the TB's multi-lane / lane-mask coverage is now a *conformance*
> check for the Linux use case, not merely an ahead-of-SW regression lock. *Code-level
> evidence:* `driver.md` L.2/L.3, Part C.
> *(Original TODO — "where are lane masks set once SW catches up?" — is answered:
> device-`lane_map`-derived, written per-message and in setup, and once-per-enable on the
> offload path.)*

---

## Appendix A — Provenance & Flag Audit

**Requirements by provenance** (join key for triage):

- `EXTERNAL` (strongest — mismatch = genuine RTL bug): EXEC-XFER-02, EXEC-SCLK-03,
  EXEC-SCLK-05, EXEC-FLOW-05, EXEC-SDO-01, plus SPI-anchored clauses of EXEC-RST-03/04,
  EXEC-XFER-06, EXEC-SCLK-01/02, EXEC-BUS-02/03.
- `DOCUMENTED`: the bulk of §3–§5, §7 (stream/handshake), §9.
- `DOCUMENTED (non-independent)`: the timing formulas (EXEC-XFER-08, EXEC-CS-02,
  EXEC-SLEEP-01, EXEC-SCLK-01) — the docs restate the implementation; treat a
  model/RTL match as *consistency*, not independent confirmation.
- `RTL-CHARACTERIZED` (regression locks, **not** conformance): EXEC-PARAM-06/07/08,
  EXEC-RST-01/03/05/07, EXEC-CMD-01(idle-gate), EXEC-FLOW-04, EXEC-SDO-02(alignment),
  EXEC-LANE-01/03/04, EXEC-SDI-04/05, EXEC-CC-07/08, EXEC-ECHO-C1/C2, EXEC-BUS-07.
- **Driver-corroborated** (non-independent usage evidence; grades requirement
  strength — see the driver cross-check in `spi_execution.driver.md`). Tag key:
  `(drivers)` = both, `(no-OS)`/`(Linux)` = one only.
  - **`(drivers)` — both agree:** EXEC-XFER-01(n zero-based), EXEC-CS-01(active-low),
    EXEC-CS-03(`t=0` CS), EXEC-SCLK-01/EXEC-CFG-01(clk_div formula), EXEC-CFG-02(config
    bit layout), EXEC-SDO-02(MSB alignment), EXEC-SYNC-01(completion id round-trip),
    EXEC-SLEEP-01(`(t+1)` form), EXEC-OFF-03(same-commands/different-transport).
  - **`(Linux)` — Linux only (mostly IP-version-gated feature reach):** EXEC-CMD-03(full
    3-bit opcode), EXEC-CSINV-01/02(CS-invert for `SPI_CS_HIGH`), EXEC-CFG-04/05 &
    EXEC-LANE-01/03/04 & EXEC-CC-08(lane masks, v2.0+), EXEC-XFER-05(write/read-only in
    the core path).
  - **`(no-OS)` — no-OS only:** EXEC-CS-02(prescaled CS delay in the ASSERT `t` field),
    EXEC-CFG-06(width clamp — Linux does *not* clamp; see F6).

**Open flags** (each: observed → suspect → resolver):

#### Flag: EXEC-F1
- Summary: `sdi_data` mutates while valid & unaccepted at `div=0` sub-word backpressure (appears to violate AXI-Stream payload stability). Captured as an `expect_fail` regression.
- Resolver: HDL designer (fix vs accept).

#### Flag: EXEC-F2
- Summary: SDI lane mask has no boundary-visible effect in *this* module (effect is downstream in `axi_spi_engine`). **Linux does write the SDI-mask register** (from `rx_lane_map[]`, v2.0+), so the register is exercised — but its observable effect is still not at this module's boundary; no-OS never writes it. The flag stands: at this boundary the spec can require only that the write is accepted.
- Resolver: HDL designer.

#### Flag: EXEC-F3
- Summary: Sleep-time formula disagreement: `instruction-format.rst` says `2+(t+1)*(div+1)*2`; `pipeline-delays.rst` says `2+t*(div+1)*2`. Spec follows the former (matches "prescaler cycles minus one" wording); RTL should be measured to confirm. **Both drivers corroborate the `(t+1)` form** — each pre-decrements the sleep parameter by 1 (`SLEEP(n-1)`), expecting hardware to add it back. Still needs RTL measurement to be authoritative.
- Resolver: Simulation + designer/doc owner.

#### Flag: EXEC-F4
- Summary: `ECHO_SCLK=1` datapath undocumented and unverified (coverage hole); build-time-fixed capture edge is surprising.
- Resolver: Designer + datasheet.

#### Flag: EXEC-F5
- Summary: `SDO_DEFAULT`, `ECHO_SCLK`, `SDI_DELAY` parameters missing from the `.rst` parameter table.
- Resolver: Doc owner.

#### Flag: EXEC-F6
- Summary: Dynamic transfer length > `DATA_WIDTH` behavior unspecified (constraint stated, not enforced/defined). **Strengthened by Linux:** no-OS clamps width to the `DATA_WIDTH` readback, but Linux does **not** clamp (`bits_per_word_mask = 1..32`), so the reference SW does not universally enforce the constraint — a narrow-`DATA_WIDTH` build could be driven into the undefined region.
- Resolver: Designer.

#### Flag: EXEC-F7
- Summary: word_length/lane-mask-then-transfer correctness relies on fixed inter-instruction settling margin (fragile).
- Resolver: Designer.

#### Flag: EXEC-F8
- Summary: **RESOLVED (Linux):** CS-Invert-Mask (opcode `100`) *is* driven — by Linux, to implement `SPI_CS_HIGH` (IP v1.2+). The no-OS driver's inability to emit it is a **no-OS 2-bit-opcode-encoder limitation**, not a spec gap. EXEC-CSINV-* now `(Linux)`-corroborated. Residual: no-OS encoder could be widened to 3 bits if it ever needs active-high CS.
- Resolver: Closed (was HDL/SW designer).

#### Flag: EXEC-F9
- Summary: **RESOLVED (Linux):** lane-mask registers *are* written — by Linux, from device `lane_map`s, on IP core **v2.0+**. no-OS targets earlier cores and leaves the masks at reset default. Confirms multi-lane as version-gated feature reach, not a suspect behavior. EXEC-CFG-04/05 & EXEC-LANE-* now `(Linux)`-corroborated.
- Resolver: Closed (was HDL/SW designer).

#### Flag: EXEC-F10
- Summary: **Sticky `sdo_data_ready` after reset (FIFO mode).** In FIFO mode (`s_offload_active=0`) `sdo_data_ready` can assert with no command pending and no valid write instruction — but only *after* a prior transfer, and it survives an intervening `resetn` pulse. Appears rooted in `exec_transfer_cmd_reg` (fed to the shiftreg as `exec_cmd`), which is set inside `if (exec_cmd)` and has no reset branch, so a stale `1` leaves the shiftreg gate `(exec_cmd & index_ready)` satisfied post-reset. Reads as a protocol smell: the engine requests SDO with no transfer in flight. Encoded as `expect_fail` regression.
- Resolver: HDL designer (should reset clear `exec_transfer_cmd_reg`? if intended, document required power-on sequence).

#### Flag: EXEC-F11
- Summary: **Confirmed bug (see `bug_log.md`).** EXEC-OFF-02 not implemented in RTL: `execution.rst` states offload prefetch requires *all* SDO lanes active, else the module waits for the write instruction, but the prefetch gate has no lane-mask term. Under a sub-mask the engine prefetches early and corrupts the SDO bus data. Kept as a failing regression (`test_offload.py`) to guard against reintroduction.
- Resolver: HDL designer (implement all-lanes gate, or correct the `.rst`).

## Appendix B — Known Coverage Holes

Absence of a requirement here is a coverage gap, not implied coverage:

1. `ECHO_SCLK=1` datapath — no conformance requirements (FLAG EXEC-F4).
2. Offload path — now exercised at this boundary (§9): EXEC-OFF-01 prefetch
   readiness and EXEC-OFF-03 waveform-parity are verified; **EXEC-OFF-02
   (all-lanes-required prefetch) is not implemented in RTL** — a confirmed bug kept
   as a failing regression (see `bug_log.md`).
3. SDI lane-mask effect — out of scope here (FLAG EXEC-F2); must be verified at
   `axi_spi_engine`.
4. CS-delay and transfer-duration **cycle counts** (EXEC-CS-02, EXEC-XFER-08) —
   formulas stated; assert them in the TB (currently only SCLK period and sleep
   duration are checked, per README *Current state*).
5. Sleep-formula off-by-one prescaler period (FLAG EXEC-F3) — must be resolved by
   direct measurement.
6. **Behavior not driven by *any* reference software.** After the Linux cross-check this
   set has shrunk substantially: CS-Invert-Mask (was F8) and lane masks (was F9) are now
   Linux-driven, so a TB mismatch on them is a *conformance* signal for the Linux use
   case, not a bare regression lock. What remains **undriven by both** drivers:
   **sparse multi-CS select** (EXEC-CS-05 — both only single-select or fully deselect),
   **the clock-only/dummy `{r,w}=00` Transfer** (EXEC-XFER-05, neither emits it), and
   **prescaled CS pre/post delay via the ASSERT `t` field** (EXEC-CS-02 — no-OS drives it,
   Linux uses separate Sleeps). These carry no corroborating driver usage, so a TB
   mismatch there is a regression-lock signal, not a field-bug signal. See the driver
   cross-check in `spi_execution.driver.md`.

---

## Out-of-Scope & Echo-SCLK Observations

> **NOTE:** The entries below are **not conformance requirements of this module**. They
> are observations about behavior specified/verified elsewhere (Out-of-Scope pointers)
> or about a datapath deferred to a future revision (Echo-SCLK). They were relocated
> here from the former §9/§10 during the guideline refactor and are retained pending a
> decision on whether to delete them from the requirements set. Their verification
> method is `N/A` because there is nothing to check at *this* module's boundary.

### O.1 Out-of-Scope Behavior (specified elsewhere / not boundary-visible here)

Behavior whose effect lives in another IP is marked out of scope with a pointer, not
specified here.

#### EXEC-OOS-01
- Description: SDI lane mask **masking effect** (which lanes reach the host) is not boundary-visible in this module.
- Rationale: The masking is applied downstream, so no requirement on `sdi_data` masking can be stated here.
- Provenance: N/A — behavior lives in `axi_spi_engine` asymmetric SDI FIFO. See **FLAG EXEC-F2**.
- Verification method: N/A (out of scope — verified at `axi_spi_engine`)

#### EXEC-OOS-02
- Description: Offload command/SDO prefetch from RAM, trigger-driven execution, and `enable`/`enabled` are not specified here; this module only exposes `s_offload_active` (§9).
- Rationale: The offload control datapath is a separate module; only its boundary effect is in scope here.
- Provenance: N/A — behavior lives in `spi_engine_offload` + offload-control-interface.
- Verification method: N/A (out of scope — verified at the offload module)

#### EXEC-OOS-03
- Description: Multi-manager arbitration and CDC/FIFO latencies are not specified here.
- Rationale: These are interconnect/CDC concerns outside this module's boundary.
- Provenance: N/A — behavior lives in `spi_engine_interconnect`, `axi_spi_engine`; see pipeline-delays.rst.
- Verification method: N/A (out of scope — verified at the interconnect)

> **FLAG EXEC-F2 (no boundary-visible effect):** The SDI lane mask is written by a
> Configuration-Write and accepted here (EXEC-CFG-04), but its masking effect is
> downstream in `axi_spi_engine`. *Suspect:* a spec at this module's boundary can only
> require the register write to be *accepted*, not that any `sdi_data` masking occurs.
> *Resolve via:* HDL designer — confirm the execution module is meant to expose no
> observable SDI-mask effect. (Contrast the **SDO** lane mask, which IS
> boundary-visible: EXEC-LANE-*.)

### O.2 Echo-SCLK Capture (`ECHO_SCLK=1`) — OUT OF SCOPE this revision

> **FLAG EXEC-F4 (coverage hole + documentation gap):** The entire
> `ECHO_SCLK=1` datapath (SDI captured on the looped-back `echo_sclk` instead of the
> internal SPI clock) is **undocumented** in the `.rst` and **unverified** by the
> current testbench. It is called out here as an explicit coverage hole so its
> absence is not mistaken for coverage. The two `RTL-CHARACTERIZED` observations below
> are worth a designer's confirmation before any conformance spec is written for this
> path. No `EXEC-ECHO-*` conformance requirements are asserted until this path is
> documented and modeled.

#### EXEC-ECHO-C1
- Description: In `ECHO_SCLK=1` builds the SDI capture edge is selected **at build time** from `DEFAULT_SPI_CFG[1:0]` (modes `01`/`10` use the negedge datapath, others posedge); a **runtime** CPOL/CPHA change does *not* re-select the echo latch edge.
- Rationale: Recorded because it is surprising — a user who changes CPOL at runtime in an echo build gets a mismatched capture edge.
- Provenance: `RTL-CHARACTERIZED` — see **FLAG EXEC-F4**. *Resolve via:* designer + device datasheet (e.g. AD4630 echo-SCLK usage).
- Verification method: N/A (out of scope this revision)

#### EXEC-ECHO-C2
- Description: In `ECHO_SCLK=1` builds transfer completion is derived from an edge-detected, clock-synchronized "last bit received," a different mechanism than the `ECHO_SCLK=0` path.
- Rationale: Recorded because its timing (and single-word `n=0` handling) should be independently characterized before being specified.
- Provenance: `RTL-CHARACTERIZED` — see **FLAG EXEC-F4**.
- Verification method: N/A (out of scope this revision)
