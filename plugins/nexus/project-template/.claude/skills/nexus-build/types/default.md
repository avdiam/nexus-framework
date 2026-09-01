*Version: 1.0.0 | Date: 2026-03-30 | Sprint: 066*

# Build — Default Type (Feature / Improvement / Refactor / Documentation / Question)

Loaded by SKILL.md Router for complexity ≥ 3. Execute after complex.md §PRE-TYPE completes.

**Flow**: §1 Implementation (phase-by-phase) → return to complex.md §POST-TYPE

> *Question type at Build: Analysis resolved the question to a concrete implementation task.
> Apply the adaptations for whatever that task is (Feature/Improvement/Refactor) as recorded
> in ISS Solution-Design → Approach.*

---

## §1 Implementation

Phase-by-phase execution for C:3+ issues.

### For Each Phase in Implementation-Plan

#### A — Execute Phase Steps

Step by step. Verify each change after applying. Create phase tests as work progresses. Check flagged standards from preflight.

> === Phase N: {name} ({steps} steps) ===
> Objective: {what this achieves}
>
> Step N.1: {name}
> • Files: {modified}. Changes: {what}. Verification: {outcome}. ✓

**[T3: Full ask | Balanced: notify | Streamlined: silent]** Per-file modification gate.

> **Refactor:** Atomic state constraint — system must pass existing tests after EACH file
> touched, not just at the end of the phase. Run quick regression check after each file.
> Track before/after quality dimensions (complexity, coupling, readability estimates).

> **Documentation:** Unit of work = section, not file. After each section: verify accuracy
> against source (does doc match actual system behavior?). Track sections-complete/total.

#### B — Update ISS and Checkpoint

After each phase:

1. Patch ISS [Section: Implementation-Log]:
   - ### Status: `Phase: N | Step: X | Progress: %`
   - ### Changes Made: append rows `| Conv {N} | {file} | {change} |`
   - ### Tests Created: append rows
   - ### Deviations: append if plan differs from actual
2. Update Implementation-Plan: ⬜ → ✅ for completed steps
3. Place progress marker: `*Implementation in progress — Phase N complete*`
4. Follow [Section: Checkpoint-Protocol] in CLAUDE.md

**[T3: Full ask | Balanced: notify | Streamlined: auto]** ISS write + checkpoint.

#### B2 — Scope Escalation

After each phase: invoke [Section: Scope-Escalation-Check] in SKILL.md.

#### B3 — Decision Drift Check (mid-implementation)

Trigger at 50%+ of implementation phases complete. Re-read ISS ### Key Decisions and ### Implementation Preferences. Compare against work done so far — are we still aligned with Analysis decisions?

If drift detected: surface immediately **[T2]** before remaining phases lock in the deviation. Options: [Realign / Update decision with rationale / Accept drift]. This is the mid-implementation steering check — complex.md §POST-TYPE runs the final comprehensive drift detection after all phases complete.

#### C — Batch Transition Detection

After 2+ implementation targets (phases), invoke [Section: Batch-Transition-Detection] in SKILL.md.

#### D — Pause Point

**[T3: Full ask | Balanced: notify | Streamlined: silent]**

> Next: Phase N+1 — {name}
> [Continue / Pause / Adjust]

---

After all phases complete:
> ✅ All phases complete. Return to complex.md §POST-TYPE.
