# NEXUS Behavioral Scenario — Self-Execution Protocol
*Version: 1.0.0 | Date: 2026-06-03 | Sprint: 096*

How a **fresh-session LLM** runs a behavioral scenario from `scenarios/` and records actual-vs-expected results. This is the runtime analogue of "execute the test suite" — the executor IS a Claude instance reading a spec and driving the workflow, then diffing observed behavior + state against the spec's assertions.

Read this together with `README.md` (spec format + expected/actual template + overlap statement).

---

## When to run

- After a framework change that touches a workflow a scenario covers (regression check).
- During a maintenance / verification cycle, as the runtime complement to `subsystem-verification`'s static pass.
- When re-baselining specs after intentional framework evolution (DRIFT resolution).

**Do not** run these as a substitute for static subsystem-verification — see the overlap statement in `README.md`. These earn their place only by *executing* behavior.

---

## Protocol

### Step 1 — Select a scenario
Pick one file from `scenarios/`. Read its `Targets:` line and confirm the named skill/file **versions still match** what is on disk. If versions differ, expect possible DRIFT and plan to re-baseline rather than "fix" the framework.

### Step 2 — Classify mutation risk (one-way-door gate)
Before triggering anything, classify the scenario:

| Class | Examples | Required execution mode |
|---|---|---|
| **Read-only / non-mutating** | boot (display only), checkpoint-continuity read path | **Live** — safe to execute directly. |
| **Mutating, reversible via sandbox** | issue-lifecycle (create→work→close) | **Live with a sandbox ID** — use a throwaway issue ID (e.g. `ISS-T01`), and **clean up** (delete the sandbox issue + revert any registry/state rows) at the end. |
| **Mutating, destructive / hard-to-reverse** | sprint-lifecycle close, anything rewriting real sprint-state/registries | **Dry-run narrated** — do NOT execute live. Walk the workflow step-by-step and narrate the *expected* state transitions; record them as the "Actual (narrated)" column. |

**Rule:** never mutate real framework state to satisfy a test. A test that can only be verified by corrupting live state is a dry-run-narrated test.

### Step 3 — Establish the "Given"
Confirm (or set up, in a sandbox) the scenario's preconditions. Record the actual starting state of each artifact named in **State Assertions** — this is the baseline you will diff against.

### Step 4 — Fire the trigger
Issue the exact trigger from the spec (the user input or simulated event). For dry-run-narrated scenarios, state the trigger and then narrate rather than execute.

### Step 5 — Observe behavior
Record the observable LLM actions in order (skills loaded, gates presented, displays emitted) against **Expected Behavior**. Note any missing, extra, or reordered actions.

### Step 6 — Diff state assertions
For each row in the spec's **State Assertions** table, read the actual artifact value (the anchor) and compare to expected. Assign each a verdict:

- **✓ PASS** — actual matches the expected anchor.
- **✗ FAIL** — actual contradicts expected. Triage in Step 7.
- **⚠ DRIFT** — framework behavior legitimately changed; the spec is stale.

### Step 7 — Triage FAIL vs DRIFT
For every non-PASS:
- If the framework's current behavior is **wrong** (contradicts its own skill/protocol contract) → **FAIL** = a real regression. Surface as a finding / candidate issue.
- If the framework's current behavior is **correct and intended** but differs from the spec → **DRIFT**. The spec is stale: re-baseline the assertion + bump the spec's `Last baselined` date and `Targets:` versions. Do **not** "fix" the framework to match a stale spec.

### Step 8 — Record the run
Append a Run Result to the scenario's `## Run Results` section using the **Expected / Actual Result Template** in `README.md`. Fill: mode (live | dry-run-narrated), targets-at-run-time, the assertion table, the Drift line, and the Cleanup line.

### Step 9 — Clean up (mutating-live only)
Reverse every mutation made for the test: delete the sandbox issue file, revert any registry/state rows touched, remove sandbox artifacts. Confirm the framework is back to its pre-test state and record this on the Cleanup line. Dry-run-narrated and read-only runs record `Cleanup: dry-run — no mutation` / `n/a`.

---

## Worked-run expectations (ISS-086 P3)

Phase 1 records **1–2 worked runs** as proof-of-protocol:
- At least one **read-only / live** run (boot or checkpoint-continuity) executed for real with actuals captured.
- The **destructive** scenarios (sprint-lifecycle close) recorded **dry-run narrated** only — never live.
- The **issue-lifecycle** run, if executed live, uses a sandbox issue ID and cleans up per Step 9.

These worked runs are the evidence that the protocol is executable, not just documented.
