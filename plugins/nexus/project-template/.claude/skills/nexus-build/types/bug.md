*Version: 1.1.0 | Date: 2026-06-11 | Sprint: 101*

# Build — Bug Type

Loaded by SKILL.md Router for bug-type issues, complexity ≥ 3. Execute after complex.md §PRE-TYPE completes.

**Flow**: §1 Implementation (reproduce → fix root cause → verify gone → regression) → return to complex.md §POST-TYPE

**Key difference from default**: Different execution loop shape. Reproduction verification is mandatory first step. Per-step verification checks reproduction scenario, not just file state.

**Note**: Simple C:1-2 bugs are handled inline in SKILL.md [Section: Simple-Path]. This file executes for C:3+ bugs only.

---

## §1 Implementation

### A — Reproduction Verification (MANDATORY first step)

Before touching any file, confirm you can trigger the bug:

> 🐛 Reproducing bug: {description}
> Steps: {from ISS}
> Result: {reproduced ✓ / cannot reproduce}

If cannot reproduce: STOP. Do not proceed with implementation. This is a re-analysis signal.

*Skip if already confirmed during Plan Verification bug pre-check (complex.md §PRE-TYPE). Required if entering bug.md directly (e.g., checkpoint resumption mid-implementation).*

> ⚠️ Cannot reproduce bug. Options:
> [Investigate reproduction environment / Loop back to Analysis / Mark as cannot-reproduce]

**[T2]** gate if cannot reproduce — do not auto-proceed.

### B — Root Cause Verification

Before fixing: confirm the fix targets the root cause from ISS Solution-Design, not a symptom.

> 📋 Root Cause Verification
> ISS root cause: {from Solution-Design}
> Fix approach: {from Implementation-Plan}
> Targets root cause: ✓ / ⚠️ {concern}

If targeting symptom: surface to user **[T2]**.

### C — Phase-by-Phase Fix Execution

ISS update + checkpoint structure follows the standard phase loop (§B below); the bug-specific difference is per-step verification: "Reproduction scenario: {still triggers / no longer triggers}?"

After each file: verify reproduction scenario is not triggered by intermediate state (don't leave the system in a broken-differently state).

For each phase in Implementation-Plan:

#### A — Execute Phase Steps

> === Phase N: {name} ({steps} steps) ===
> Objective: {what this achieves}
>
> Step N.1: {name}
> • Files: {modified}. Changes: {what}.
> • Reproduction check: {still triggers / no longer triggers / N/A}
> • Verification: {outcome}. ✓

**[T3: Full ask | Balanced: notify | Streamlined: silent]** Per-file modification gate.

#### B — Update ISS and Checkpoint

After each phase:
1. Patch ISS [Section: Implementation-Log]:
   - ### Status: `Phase: N | Step: X | Progress: %`
   - ### Changes Made: append rows `| Conv {N} | {file} | {change} |`
   - ### Tests Created: append rows
   - ### Deviations: append if plan differs from actual
2. Update Implementation-Plan: ⬜ → ✅
3. Place progress marker: `*Implementation in progress — Phase N complete*`
4. Follow [Section: Checkpoint-Protocol] in CLAUDE.md

**[T3: Full ask | Balanced: notify | Streamlined: auto]** ISS write + checkpoint.

#### B2 — Scope Escalation

Invoke [Section: Scope-Escalation-Check] in SKILL.md after each phase.

**Additional bug signal**: "Root cause is elsewhere than Analysis concluded" → loop-back signal, not just scope escalation. Surface separately with loop-back offer **[T2]**.

#### B3 — Decision Drift Check (mid-implementation)

Trigger at 50%+ of fix phases complete. Re-read ISS ### Key Decisions and ### Implementation Preferences. Compare against work done so far — are we still aligned with Analysis decisions? For bugs: additionally verify the fix still targets root cause (not drifting toward symptom patching).

If drift detected: surface immediately **[T2]** before remaining phases lock in the deviation. Options: [Realign / Update decision with rationale / Accept drift]. complex.md §POST-TYPE runs the final comprehensive drift detection after all phases complete.

#### D — Pause Points

**[T3: Full ask | Balanced: notify | Streamlined: silent]**

> Next: Phase N+1 — {name}
> [Continue / Pause / Adjust]

---

After all phases complete:
> ✅ All fix phases complete. Return to complex.md §POST-TYPE.

**§POST-TYPE note**: Test Execution for bugs must run BOTH passes:
1. Bug test: reproduce original scenario → confirm gone
2. Regression: broader pass → confirm nothing else broken
This is handled in complex.md §POST-TYPE Test Execution (bug-type structure).
