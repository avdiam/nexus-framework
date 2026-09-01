# NEXUS Integration Test Suite
*Version: 1.0.0 | Date: 2026-06-03 | Sprint: 096*

The **runtime/behavioral** layer of NEXUS integration testing — the dynamic counterpart to the static `nexus-subsystem-verification` campaign. Created by ISS-086 (Phase 1). Phase 2 expansion → ISS-087.

NEXUS is a markdown/LLM-behavioral harness with no conventional runtime. So an "integration test" here takes one of two natures:

1. **Behavioral scenario** (`scenarios/`) — a repeatable `given → trigger → expected` spec executed by a fresh-session LLM and diffed against expected behavior **and expected state artifacts**. The state-assertion field is load-bearing: without concrete file/field expectations, "actual-vs-expected" is not checkable.
2. **Hook test** (`hooks/`) — the hook shell scripts are genuinely code-testable, so they get a real bash runner + fixtures asserting on stable behavioral anchors.

---

## Static-vs-Runtime Overlap Statement (standing anti-duplication guardrail)

> **This suite tests the RUNTIME/behavioral layer. It does NOT re-do static verification.**

The `nexus-subsystem-verification` campaign (see `.nexus/Sprints/*/Maintenance-cycles/*/verification-*.md`) already covers the **static** half of integration testing:

| Dimension | Owned by `subsystem-verification` (STATIC) | Owned by this suite (RUNTIME) |
|---|---|---|
| Workflow wiring | three-source triangulation + per-file connection/target/compliance checks | — |
| Workflow execution | **mental** execution traces (A→I→E, create→work→close, sprint lifecycle) — never run live | **live or recorded** execution with *actual* results captured + diffed |
| Hook scripts | static read of the `.sh` source | **executable** bash runner + fixtures + pass/fail assertions |
| Docs | documents the *expected* behavior | captures the *actual* behavior from runs |

**Rule of thumb when adding a test here:** if the check can be satisfied by *reading* files and reasoning about wiring, it belongs in `subsystem-verification`, not here. This suite earns its place only when it requires **execution** — a live/recorded behavioral run, or a hook script actually invoked against a fixture. Surface this statement before expanding the suite (ISS-087) to prevent re-duplicating the static campaign.

---

## Layout

```
.nexus/tests/
├── README.md                      # this file — index, spec format, expected/actual template, overlap statement, Phase-2 baseline
├── SELF-EXECUTION-PROTOCOL.md     # how a fresh-session LLM selects, runs, and records a scenario
├── scenarios/                     # Part A — behavioral scenario specs (LLM-executed)
│   ├── boot.md
│   ├── sprint-lifecycle.md        # organize → close
│   ├── issue-lifecycle.md         # create → work → close
│   ├── methodology-cycle.md       # analyze → build → validate
│   └── checkpoint-continuity.md
└── hooks/                         # Part B — executable hook tests
    ├── run.sh                     # bash runner; feeds fixtures to each hook, asserts on anchors
    ├── fixtures/                  # stdin JSON / transcript fixtures per hook
    └── expected/                  # expected-output anchors per hook
```

---

## Behavioral Scenario Spec Format

Every file in `scenarios/` MUST conform to this format. A spec missing the **State Assertions** block is invalid (not runnable as a test).

```markdown
# Scenario: {name}
*Targets: {skill/file} v{version} | Suite: ISS-086 | Last baselined: {YYYY-MM-DD}*

## Given (preconditions)
- {state of the world before the trigger — files present, sprint-state fields, control level}

## Trigger
- {the exact user input or event that starts the workflow, e.g. "start", "close sprint", a checkpoint at 80%}

## Expected Behavior
- {observable LLM actions in order — skills loaded, gates presented, displays emitted}

## State Assertions (MANDATORY — the load-bearing field)
| Artifact | Field / Anchor | Expected value after run |
|---|---|---|
| {file path} | {YAML key / section / regex} | {concrete expected value} |

## Out of Scope
- {what this scenario deliberately does NOT assert — deferred to ISS-087 or owned by subsystem-verification}

## Run Results
*(appended by SELF-EXECUTION-PROTOCOL; empty until a worked run is recorded)*
```

**Anchor discipline:** State Assertions reference **stable anchors** (a YAML key + value, a section tag, a regex presence) — never brittle exact-string transcripts. Output evolves; anchors resist rot.

---

## Expected / Actual Result Template

When a scenario is executed (per `SELF-EXECUTION-PROTOCOL.md`), append a Run Result using this template:

```markdown
### Run {N} — {YYYY-MM-DD} — executor: {fresh-session LLM | named conv}
Mode: {live | dry-run-narrated}
Targets at run time: {skill versions actually present}

| # | Assertion | Expected | Actual | Verdict |
|---|---|---|---|---|
| 1 | {anchor} | {expected} | {observed} | ✓ PASS / ✗ FAIL / ⚠ DRIFT |

Drift flagged: {none | description — spec assertion vs current framework behavior}
Cleanup: {sandbox issue ID removed / dry-run — no mutation / n/a}
```

- **PASS** — actual matches expected anchor.
- **FAIL** — actual contradicts expected (real regression OR stale spec — triage via Drift line).
- **DRIFT** — framework behavior legitimately changed; the **spec** is stale and must be re-baselined, not the framework "fixed".

---

## Hook Test Harness (Part B)

`hooks/run.sh` is a self-contained, CI-able bash runner. For each of the 6 hook scripts it feeds a fixture (`fixtures/`) to the hook and asserts the output contains the expected anchor (`expected/`). Run it directly:

```bash
bash .nexus/tests/hooks/run.sh
```

Exit 0 = all green. Non-zero = at least one assertion failed; the runner prints which hook + which anchor. Assertions target **stable behavioral anchors** (e.g. the context-window denominator, the status-line corrective-reminder text), never exact transcripts.

---

## Phase-2 Baseline (SC-08 — what Phase 1 covers vs. deliberately defers)

Finalized by ISS-086 P5. The expansion contract is **ISS-087** (Phase 2). Cross-references: `issues-registry.yaml` records `ISS-086.blocks: [ISS-087]`.

**Delivered by Phase 1 (this suite) — 2026-06-03, Sprint 096:**
- `README.md` (this file) + `SELF-EXECUTION-PROTOCOL.md` — spec format, expected/actual template, overlap statement.
- 5 behavioral scenario specs (`scenarios/`), all conforming to the format.
- 2 worked runs recorded: `boot.md` LIVE (read-only, 6/6 PASS) + `sprint-lifecycle.md` dry-run-narrated.
- `hooks/run.sh` + fixtures + expected anchors — **12–13 assertions across all 6 hooks, exit 0 green** against current scripts (the validate-yaml hook adds one block-path assertion when both `jq` and PyYAML are present; in a degraded env it asserts the fail-open contract instead — count is environment-honest, never red on a correct hook).

**Covered by Phase 1 (this suite):**
- 5 curated core workflows, **happy path only** (boot, sprint organize→close, issue create→work→close, methodology A→I→E, checkpoint/continuity).
- All 6 hook scripts, **stable-anchor** assertions on current behavior.

**Deliberately deferred to ISS-087 (Phase 2):**
- THEMED/MIXED/DEDICATED mode matrix; multi-issue sprints.
- Edge cases, stress, and error paths (malformed state, missing files, compaction recovery loops, degraded mode).
- Loop-back / decompose / batch-mode workflows.
- Hook negative-path fixtures (malformed stdin, missing transcript).
```