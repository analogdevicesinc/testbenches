# Testbench Elaboration Guideline (for LLM implementers)

**Audience:** an LLM (or engineer) turning behavioral requirements into test cases.
**Purpose:** define *how* a requirement-driven, clean-room testbench MUST be composed,
with a short *why* per rule. Normative guideline, not a tutorial. IP-agnostic: it
applies to any IP whose requirements were authored per the requirement-writing
guideline.

Keywords **MUST**, **MUST NOT**, **SHOULD** follow RFC-2119.

---

## 0. Philosophy

The RTL predates the testbench, so an LLM asked to test it tends to mirror the RTL —
which bakes the RTL's bugs into the check and ties the two together so neither can
change alone. The clean-room answer:

- **Requirements are the ground truth**, not the RTL. Behavioral, black-box
  requirements are derived first (separate guideline); the TB is written from *them*.
- **What / Why / How:** requirements state the *what* and *why*; the RTL is the *how*.
  The TB checks the *what* at the boundary — never the *how*.
- **Atomic → one test per requirement.** A small requirement maps to one focused test,
  keeping context windows small and letting an LLM validate its own work and loop.
- **Bidirectional traceability:** greppable `REQ:` tags link requirement ↔ test (↔ RTL),
  so coverage closure is a `grep`, not a reading exercise.

The rest of this document makes these concrete.

---

## 1. Foundational principle — two independent implementations

- **1.1 — MUST** treat every test as *two independent implementations of a requirement,
  compared at the boundary*: the RTL vs a golden model, reconciled by a scoreboard.
  *Why:* a single implementation checked against itself proves nothing.
- **1.2 — MUST** write the golden model from the **requirements**, never by transcribing
  RTL logic. *Why:* a model that mirrors the RTL inherits its bugs and the comparison
  becomes circular.
- **1.3 — MUST** assert pass/fail only on **observable boundary signals** (the ports and
  streams named in the requirements' boundary vocabulary). *Why:* internal state is not
  the contract; checking it re-couples the TB to the RTL and breaks on legal refactors.
- **1.4 — MUST NOT** reference internal DUT signals (counters, pipeline regs, FSM state)
  in any **pass/fail assertion**. *Why:* same as 1.3.
- **1.5 — MAY** read internal signals for **debug/logging** and for **stimulus/sampling
  timing** where a pure black-box view would be ambiguous (e.g. gating a monitor so it
  stays in lock-step under backpressure). *Why:* generating *correct* stimulus is not
  the same as *asserting* on internals; the pass/fail check still lives on boundary
  signals.
- **1.6 — MUST**, whenever 1.5 is used, confine the access to the single coupling layer
  (§4.1, never in `test_*`) and comment *why* the black-box view is insufficient.
  *Why:* keeps white-box coupling in one file, so a signal rename breaks one place and
  is flagged for review on refactor.
- **1.7 — MUST** write **real** tests that drive the DUT and assert on its actual output.
  A test **MUST NOT** be a placeholder or stub — no `assert True`/`assert False`, no
  hard-coded pass, no assertion on a value the test itself just computed without involving
  the DUT. Every test MUST be able to fail for a real behavioral reason. *Why:* a mock
  test reports green while verifying nothing — worse than no test, because it hides the
  gap. If a behavior cannot be driven yet, leave it untested and record the hole (§6.4,
  §11.3), do not fake it.

---

## 2. Tiered structure — dependencies point inward

Place new code in the correct tier:

- **2.1 — MUST** keep the **generic tier** protocol- and DUT-agnostic: stream
  driver/monitor, backpressure, reset, scoreboard, RNG. *Why:* reused by every IP.
- **2.2 — MUST** keep the **protocol tier** protocol-aware but DUT-agnostic: the
  encoding codec, passive bus monitor, protocol BFM. It MUST NOT hard-code this DUT's
  parameters or pinout. *Why:* reused across all IPs of that protocol.
- **2.3 — MUST** confine everything specific to this DUT to the **DUT tier**: harness,
  golden model, tests. *Why:* isolates DUT knowledge to one place.
- **2.4 — MUST NOT** import an outer tier from an inner one. Dependencies point only
  inward. *Why:* an inward-pointing import graph is what makes inner tiers reusable.
- **2.5 — MUST** add new reusable capability to the innermost tier where it is still
  general. *Why:* prevents DUT-specific leakage into shared code.

---

## 3. The encoding is a shared contract

- **3.1 — MUST** encode commands/transactions — in **both** stimulus and golden model —
  through a single shared codec. *Why:* if both share one encoder, a mis-encoded input
  cannot silently agree with itself.
- **3.2 — MUST NOT** hand-assemble raw command/register words inline in a test.
  *Why:* bypasses the contract and drifts from the RTL decoder.
- **3.3 — MUST** update the codec (and only the codec) when the encoding changes, then
  re-run the suite. *Why:* one source of truth for the encoding.

---

## 4. Single coupling point & one-way parameters

- **4.1 — MUST** make one harness the *only* place that maps transactions ↔ DUT signals.
  Tests speak transactions; the framework speaks signals; the harness translates.
  *Why:* a pinout change touches exactly one file.
- **4.2 — MUST** flow parameters one way only: build config → env → **both** RTL generics
  **and** the golden model. *Why:* keeps model and silicon in lockstep; a value set in
  one place only would desync them.
- **4.3 — MUST NOT** duplicate a parameter's default independently in the model and the
  RTL. Derive both from the single source. *Why:* silent model/DUT divergence is the
  hardest bug class to spot.

---

## 5. Reproducibility (seeded randomness)

- **5.1 — MUST** derive every random event (stimulus, backpressure, slave data, reset
  timing) from one master seed. *Why:* hardware bugs are often intermittent; an
  unreproducible failure is nearly useless.
- **5.2 — MUST** log the seed each run and support replay from it. *Why:* turns a flaky
  discovery into a deterministic repro.
- **5.3 — MUST NOT** call any unseeded/global RNG. Request a labelled child RNG from the
  seeded context. *Why:* an unseeded call is invisible to replay.
- **5.4 — MUST**, when a seed exposes a bug, promote that scenario to a permanent
  **directed** test. *Why:* random coverage is probabilistic; a directed test guarantees
  the corner stays covered.

---

## 6. Golden-model fidelity (hybrid)

- **6.1 — MUST** model **data** at transaction level and check it **exactly** (no
  tolerance): given inputs, predict the exact output words/bits/states. *Why:* data
  correctness is exact by nature.
- **6.2 — MUST** model **timing** by the requirement's closed-form formula and check with
  a small **±1-cycle tolerance**. Derive the formula from the requirement by ID; never
  copy a magic number, make it parametric with explicit names. *Why:* pipeline stages
  add fixed small offsets that are legal, not bugs — and a copied constant silently
  drifts when the requirement changes.
- **6.3 — MUST NOT** model pipeline register contents or internal counters/latencies.
  *Why:* re-couples the model to RTL internals (violates 1.2) and makes it brittle.
- **6.4 — MUST** document, at the top of the model, any behavior it deliberately does not
  cover. *Why:* an undocumented gap reads as coverage that does not exist.

---

## 7. Composing a test case

- **7.1 — MUST** trace every test to at least one requirement ID with a **greppable,
  punctual tag** on the line closest to the code that exercises it (the assertion or the
  provoking stimulus), **not** in the docstring:

  ```
  # REQ: <requirement-id> - <optional brief comment>
  ```

  - **Exactly one ID per tag** — no commas, ranges, or wildcards. Two requirements near
    the same code get two separate `# REQ:` lines.
  - **Every testcase MUST carry a tag; a requirement MAY have many test homes.** There is
    **no cap** on how many tests cite one ID. Ideally each requirement maps to a single
    focused test (§0); nuance or specific conditions may split it across a few. A test
    that exercises a requirement without its own tag is invisible to the coverage grep, so
    tag it rather than cross-referencing in prose.
  - The ID MUST exist in the requirements document.

  *Why:* a machine-checkable trace lets a script prove coverage closure by grepping, which
  prose cannot. Every test carrying a tag keeps that index complete — the grep finds all
  coverage, not a hand-picked "canonical" subset. (The two-citation-max cap is an **RTL**
  rule, §7.1.1 — it does not apply to tests.)
- **7.1.1 — MUST**, for the **RTL** side of the trace, keep at most **two** `REQ:`
  citations per requirement: the core always-block/logic that implements it, plus at most
  one secondary site. Never scatter one ID across every module the signal touches. *Why:* a
  requirement's signal may thread through many RTL modules while its heart is one small
  block; capping RTL citations points the index at that heart instead of diffusing it.
  Tests have no such cap — a testcase is a coverage point, not a signal path.
- **7.2 — MUST** structure each test as *arrange* (config + build inputs via codec) →
  *act* (drive through the harness) → *assert* (scoreboard compares monitor vs model).
  *Why:* a uniform shape is reviewable and diffable.
- **7.3 — MUST** let the scoreboard decide pass/fail and accumulate **all** mismatches
  before failing. *Why:* one run should reveal every discrepancy, not just the first.
- **7.4 — MUST** keep one test focused on one behavior; recombine behaviors only in
  explicit *sequence* or *fuzz* tests. *Why:* a focused failure localizes the bug.
- **7.5 — MUST** cover the boundary values each requirement names (zero/max length,
  minimum/maximum, empty/full, sparse patterns, …). *Why:* bugs cluster at boundaries.
- **7.6 — SHOULD** add a randomized/fuzz variant recombining validated behaviors under
  random backpressure and ordering. *Why:* finds interaction bugs directed tests miss.
- **7.7 — MUST** verify documented reset/idle values on every boundary output after any
  reset, including resets injected mid-operation. *Why:* clean recovery from arbitrary
  state is a core guarantee.
- **7.8 — MUST**, when a bug is found, encode it as a test whose assertion checks the
  **correct** (requirement-mandated) behavior, so it **fails hard on the current RTL** and
  passes once the RTL is fixed. *Why:* a bug is a real defect; the suite MUST report it as
  a failure, not as an expected/green result. A test that passes while the bug is present
  hides the defect behind a wall of green.
  - **7.8.1 — MUST NOT** use `expect_fail` (or any inverted/xfail assertion) to make a
    known bug report as passing. The failing test stays red until the RTL is fixed; track
    the open defect in `bug_log.md` (§7.8.2), not by flipping the test's polarity. *Why:*
    an xfail'd bug is invisible in a green run and silently rots; a hard failure keeps the
    defect in view until it is actually resolved.
  - **7.8.2 — SHOULD** make that test catch the whole *class* of bug, not the single
    observed instance — one parametric test over the failing dimension (e.g. all widths /
    all divisors / any stall offset) rather than the one value that first tripped. *Why:*
    a fix for the exact instance that leaves siblings broken must still fail the test.
  - **7.8.3 — MUST** log every found bug in `bug_log.md`, one entry per bug, in the format
    below. *Why:* a bug needs a durable, reproducible record that outlives the test.

    ```
    # <short class name> - <one-line symptom> (<flag id if any>)
    - code revision: <repo + commit hash + branch/date the bug was characterized against>
    - Requirement: <req-id> - <what the requirement guarantees>
    - Test: <file::testcase> (fails on current RTL)
    - Symptom: <observable failure, and the conditions under which it does/doesn't occur>
    - Root cause: (<rtl file>) <mechanism>
    - Decision needed: <RTL fix vs documented constraint, etc.>
    - Run Command: <exact command to reproduce, incl. any params/env>
    - Wave signals:
      - <signal paths worth inspecting>
    ```

    The `code revision` line records the RTL each bug was characterized against, per
    entry — the HDL revision moves, so a bug may reproduce on one revision and not
    another; the per-entry stamp keeps each finding pinned to where it was seen.
- **7.9 — SHOULD** push coverage through **input variation** — many stimuli/small cases —
  rather than one monolith. Varying inputs needs no recompile; only DUT **generics** force
  a rebuild. Keep generics fixed within a test and vary inputs freely. *Why:* input-space
  coverage iterates far faster than anything requiring a rebuild.
- **7.10 — SHOULD** split input variation across several independent test cases rather
  than one large loop. *Why:* each case fails independently, so a failure localizes and
  one bad scenario does not mask the rest.
- **7.11 — MUST**, when a test is only meaningful under certain build/compile-time
  configuration (DUT **generics** — e.g. a minimum `NUM_OF_SDIO`, a specific data width),
  **skip** it on builds where it cannot be exercised, using the framework's test-skip
  facility ("skip test" methods). **MUST NOT** substitute an `assert True`/`assert False`
  (or any hard-coded pass/fail) to paper over a configuration in which the test does not
  apply. *Why:* a skip is honestly reported as "not run in this configuration" and keeps
  coverage accounting truthful, whereas a forced pass hides the gap and a forced fail
  reports a spurious defect — either way it re-introduces the stub assertion §1.7 forbids.
  Do **not** document *how* the skip is performed here: the mechanism is
  framework-version-dependent and may change at any time; call the framework's current
  skip method instead.
- **7.12 — MUST NOT** reference this guideline from the testbench — no citation by name,
  path, section, or rule number in any comment, docstring, or identifier. *Why:* this
  guideline is a living, ever-evolving document; citing it creates an unnecessary
  maintenance burden.

---

## 8. Backpressure & flow control

- **8.1 — MUST** exercise independent random backpressure on each stream with a ready
  signal the DUT must honor. *Why:* stalls are where handshake/flow-control bugs live.
- **8.2 — MUST** verify backpressure causes **stall without data loss or reordering**,
  not just "still passes". *Why:* the DUT may paper over a dropped word; check data
  integrity, not survival.
- **8.3 — SHOULD** inject stalls at varied bit/word/transaction boundaries. *Why:*
  flow-control gates often behave differently at each.

---

## 9. Scope boundaries

- **9.1 — MUST NOT** test behavior a requirement marks out-of-scope for this module
  (belonging to a neighboring IP or the integration level). *Why:* a unit test asserting
  a downstream effect is testing code not in the DUT.
- **9.2 — MUST** honor a requirement that specifies *register-capture only* (input
  accepted here, effect observable downstream) by checking only the accept, not the
  effect. *Why:* the effect is not in this DUT's boundary.

---

## 10. Simulator portability & determinism

- **10.1 — MUST** keep tests simulator-agnostic (pure cocotb/VPI); no vendor-specific
  constructs in test logic. *Why:* the same test must run under multiple simulators.
- **10.2 — MUST** confine simulator-specific flags/lint suppressions to the build file.
  *Why:* keeps portability guarantees in one controlled place.
- **10.3 — SHOULD** treat a 2-state simulator's lack of X/Z as covered by explicit
  reset-value tests, not X-propagation checks. *Why:* a fast 2-state simulator cannot
  model X; reset testing substitutes for it.

---

## 11. Coverage closure

- **11.1 — SHOULD** give a self-contained sub-block its own small unit TB when its
  interface is cleaner than reaching its corners through the full DUT. *Why:* sharper and
  cheaper than driving those corners end-to-end.
- **11.2 — SHOULD** add functional-coverage bins crossing the key parameters, paired with
  simulator line/toggle coverage. *Why:* "ran N seeds" must become "hit every bin";
  random effort without bins cannot prove closure.
- **11.3 — SHOULD** keep IP-specific status — current coverage, known holes, next steps —
  in a living status document, not here. *Why:* this guideline is method; status drifts
  and belongs where it is maintained.

---

## 12. Definition of done (checklist for any new test)

- [ ] Real test — drives the DUT and can fail for a behavioral reason; no stub/mock
      assertion. *(1.7)*
- [ ] Every testcase carries a punctual `# REQ:` tag on the closest line; one ID per tag;
      no cap on tests per requirement (the two-citation-max is RTL-only, 7.1.1). *(7.1)*
- [ ] Inputs built via the codec; no inline raw words. *(3.1, 3.2)*
- [ ] Pass/fail on boundary signals only; no internal-signal assertions. *(1.3, 1.4)*
- [ ] All randomness seeded. *(5.1, 5.3)*
- [ ] Data checked exactly; timing checked with ±1-cycle tolerance. *(6.1, 6.2)*
- [ ] Scoreboard-driven, accumulates all mismatches. *(7.3)*
- [ ] Passes across multiple seeds and the relevant parameter sweep. *(4.2, 5.2)*
- [ ] Coverage pushed through input variation, split across small independent cases. *(7.9, 7.10)*
- [ ] Config-dependent test skips (framework skip method) on builds that cannot exercise
      it — never a hard-coded `assert True`/`assert False`. *(7.11)*
- [ ] Any found bug: captured as a class-generic test that asserts correct behavior and
      thus **fails hard** on the current RTL (no `expect_fail`), and logged in
      `bug_log.md`. *(7.8, 7.8.1, 7.8.2, 7.8.3)*
- [ ] No reference to this guideline anywhere in the TB (name/path/section/rule); only
      requirement IDs are cited. *(7.12)*
