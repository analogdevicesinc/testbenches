# Specification & Requirements Authoring Guideline

## 1. Purpose

This guideline defines **how to write behavioral requirements** for existing ADI FPGA IPs whose RTL already exists.

Unlike a traditional V-model, this project follows an **inverted V-model**:

```
Existing RTL
↓
Behavioral Requirements
↓
Golden Model
↓
Verification Environment
```

The objective is **not** to paraphrase the RTL. The objective is to reconstruct the intended behavior at the module boundary so that the golden model becomes an independent behavioral representation of the design.

Because the RTL and documentation originate from the same engineering team, we **cannot achieve author independence**, but we **can achieve representational independence** by expressing behavior at a higher abstraction level.

## 2. Guiding Principles

Requirements should satisfy the **What / Why / How** separation.

- **Requirement:** defines **what** the IP must do.
- **Rationale:** briefly explains **why** the behavior exists.
- **Design/RTL:** define **how** the behavior is implemented.

Requirements should:

- describe **externally observable behavior**;
- remain valid if the RTL is refactored;
- be suitable for direct verification;
- enable simple bidirectional traceability.

## 3. Writing Rules

Every requirement MUST:

- have a unique, stable ID;
- describe **one behavior** (atomic);
- use RFC-2119 keywords: **MUST**, **MUST NOT**, **SHOULD** and **MAY**;
- describe **what**, not **how**;
- describe behavior observable at the module boundary;
- state applicable conditions explicitly;
- define measurable behavior whenever timing or quantities are involved, expressed as a **closed-form relation to inputs** (e.g. `SCLK period = (div+1)·2 core clocks`) rather than a cycle-by-cycle trace;
- use defined project terminology;
- include a brief rationale;
- remain stable under equivalent RTL refactoring.

A requirement MAY also specify its verification method, one of:

- **`SIMULATION`** — the default; checked by a directed test, parameter sweep, or waveform assertion.
- **`FORMAL`** — reserved for small, highly-reused primitives (e.g. CDC synchronizers) where exhaustive proof is tractable.
- **`HARDWARE`** — used sparingly, only for behavior that cannot be observed in simulation or whose simulation would be prohibitively long.

Most requirements are `SIMULATION`; `FORMAL`/`HARDWARE` are the deliberate exception, which keeps the effort budget honest.

The recommended wording is:

> **When** `<condition>`, the IP **MUST** `<observable behavior>` **within** `<limit>`.

This template is guidance rather than mandatory grammar.

**Requirement format.** Each requirement is a short labeled block:

```
#### <ID>
- Description: <condition> → <observable action> [within <limit>], using only boundary signals.
- Rationale: the *why* (Description is the *what*; the RTL is the *how*).
- Provenance: where it came from — see §7.
```

Keep the block self-contained and free of inlined analysis: everything needed to write
the test belongs in the Description.

## 3.1 Document Structure

A spec document is laid out as:

1. **Module boundary** — an opening chapter listing every boundary signal and build
   parameter in a table. This is the controlled vocabulary (§9): a requirement may name
   nothing else.
2. **Requirement blocks**, grouped into sections by function (reset, command stream,
   each instruction, …), each in the format above.

Non-requirement material (flags §8, provenance analysis, RTL notes) lives in separate
documents (§10) so the spec stays small enough to grep and load one requirement at a
time.

## 4. Good Requirements

Good requirements are:

- atomic;
- unambiguous;
- testable;
- implementation-independent;
- device/protocol-facing.

For example:

❌

> The execution FSM enters WAIT_IO after asserting `cmd_valid_d1`.

✔

> When outbound data is unavailable, the IP MUST delay the SPI transfer until the data becomes available.

The same rewrite applied to more cases from the current RTL-derived draft:

| Implementation-level (avoid) | Behavioral requirement (prefer) |
|------------------------------|--------------------------------|
| "`cs_activate` is asserted for one cycle to reset the SDI shift registers." | "When a chip-select is asserted, any residual receive state from a prior transaction is cleared before the new transaction captures data." |
| "`sdo_t_int = ~sdo_enabled` during transfer; `sdo_t`=1 otherwise." | "SDO is actively driven only during a write transfer; at all other times it is tri-stated." |
| "Sleep uses `sleep_counter` compared against `cmd_d1_time`." | "A sleep instruction stalls command execution for `2+(t+1)·(div+1)·2` core clocks, then resumes." |

## 5. Requirement Code Smells

During review, ask:

- Can one test fail while another behavior still passes?
  - → Split the requirement.

- Would changing the RTL architecture require rewriting this requirement?
  - → It probably describes the implementation.

- Could two engineers interpret this differently?
  - → It is ambiguous.

- Could a verification engineer write a test from this requirement alone?
  - → If not, it is incomplete.

- Does it contain words such as *correctly*, *normally*, *efficiently*, *appropriately* or *quickly*?
  - → Replace them with measurable behavior.

These heuristics are often more valuable than rigid grammar rules.

## 6. Source Hierarchy

Behavior should be derived from sources in the following order:

1. ADI `.rst` documentation.
2. Linux / no-OS drivers.
3. SPI protocol and external device datasheets.
4. RTL (only when previous sources are silent).

The RTL is **never** the preferred specification source.

If a behavior is derived solely from the RTL, it MUST be identified as **RTL-CHARACTERIZED** rather than documented intent.

## 7. Requirement Provenance

Provenance answers one question: **where did this requirement come from?** Give the
reader enough to locate the source — a tag plus, where useful, the specific file /
driver / datasheet section. One source per requirement:

| Tag               | Source                                                        |
| ----------------- | ------------------------------------------------------------- |
| DOCUMENTED        | ADI documentation (`.rst`).                                   |
| EXTERNAL          | SPI protocol or device datasheet.                             |
| RTL-CHARACTERIZED | Observable only in the RTL — a regression lock, not intent.   |

Only an `EXTERNAL` mismatch is a genuine bug; a `RTL-CHARACTERIZED` mismatch just means
the model drifted from the RTL.

Optional qualifiers, kept terse:

- `DOCUMENTED (non-independent)` — the doc merely restates the RTL (same team wrote both).
- `(drivers)` / `(Linux)` / `(no-OS)` — a reference driver depends on this behavior.

Combine tags when several sources apply (e.g. `EXTERNAL + DOCUMENTED`).

## 8. Suspicious Behavior

The value of requirement authoring is not transcription—it is engineering judgment.

Flag behaviors that are:

- undocumented;
- inconsistent with documentation;
- inconsistent with protocol or datasheets;
- inconsistent with software usage;
- likely implementation accidents;
- correct but unusually fragile.

Do **not** silently rewrite suspicious behavior into the "expected" behavior.

Instead record:

```
Observed behavior
↓
Why it is suspicious
↓
Authority that can resolve it
↓
Proposed intended behavior (optional)
```

## 9. Scope

Specify only behavior observable at **this module's boundary**.

Define that boundary once, up front, as an explicit table of the signals (and build
parameters) a requirement is allowed to name — a **controlled vocabulary**. A
requirement that reaches for a term outside this table is almost certainly describing
the implementation, not the behavior.

Out-of-scope behavior should reference the responsible module instead of restating its requirements.

State any parameter/configuration domain over which the requirement applies.

Explicitly identify known coverage holes. The absence of a requirement is a coverage
gap, never implied coverage.

## 10. Traceability

Requirements are maintained in Markdown.

The behavioral spec and any RTL-implementation notes MUST be kept in **separate documents**. An RTL-derived, signal-level description is a useful implementation reference but is **not** the spec and MUST NOT be the golden model's source — mixing the two reintroduces the circular dependency this guideline exists to prevent.

The same applies to all non-requirement material: flags (§8), provenance analysis, and
driver evidence each live in their own document. The spec holds only requirements and
the boundary vocabulary, keeping it small enough to grep and load one requirement at a
time.

Avoid cross-document links between these companions. A link chain turns one edit into a
maintenance cascade. Prefer stable IDs a `grep` resolves over hard-coded pointers.

IDs are **append-only**: never renumber or reuse an ID. Retire a requirement by marking
it deprecated in place; only ever append new IDs.

RTL and verification contain lightweight trace comments referencing requirement IDs. A
`REQ:` trace tag MUST name fully-expanded individual IDs, not a grouped shorthand (e.g.
`FOO-01/02`), so a plain `grep` reconciles spec ↔ RTL ↔ verification exactly.

Trace comments should be placed **as close as possible** to the implementation or verification logic that satisfies the requirement.

A requirement should normally require:

- one RTL trace;
- one verification trace.

If many trace comments are required, review whether the requirement should be decomposed into smaller, more atomic requirements.

# 11. Definition of Done

A requirement is complete when all of the following are true:

- [ ] Unique ID.
- [ ] One observable behavior.
- [ ] Uses RFC-2119 terminology.
- [ ] Describes *what*, not *how*.
- [ ] Stable under RTL refactoring.
- [ ] Explicit conditions.
- [ ] Measurable and testable; timing as a closed-form relation to inputs, not a cycle trace.
- [ ] Brief rationale (describes why).
- [ ] Verification method identified (optional).
- [ ] Provenance tagged.
- [ ] Applicable parameter/configuration domain stated.
- [ ] Any uncertainty recorded as a `FLAG`.
