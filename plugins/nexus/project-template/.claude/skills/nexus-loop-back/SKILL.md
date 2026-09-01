---
name: nexus-loop-back
description: Return to a previous phase when approach needs revision
disable-model-invocation: true
---
*Version: 2.0.1 | Date: 2026-06-15 | Sprint: 104*

# Loop Back

**Flow**: Context → Validate → Determine target → [T2: choose if eval] → Capture reason → Decompose check → Loop history → [T2: approve] → Apply changes → Load methodology → Report

Return to a previous phase when the current approach isn't working. Handles score reductions, loop history tracking, and decomposition signaling for repeated failures.

---

### Valid Transitions

| From | To | Scores Reduced |
|------|-----|----------------|
| Implementation | Analysis | implemented → 2 |
| Evaluation | Implementation | evaluated → 2 |
| Evaluation | Analysis | evaluated → 2, implemented → 2 |
| Research | Analysis | implemented → 2 |

Rule: reduce scores for phases *between* current and target. Never touch the target phase score — the methodology re-scores it when work completes.

### When to Choose (eval → impl vs eval → analysis)

| Choose | Signal |
|--------|--------|
| → Implementation | Approach is sound, execution has bugs or gaps. Tests fail on implementation details. Success criteria *could* be met with fixes. |
| → Analysis | Approach itself is flawed. Correct implementation still wouldn't satisfy success criteria. Design assumptions invalidated. Fundamental rethinking needed. |



### STEP 0: Context Setup (INVISIBLE)

Silent — no display to user.

**A — Memory check**: Recite files in memory. `Read .nexus/active/states/sprint-state.md` if not in memory. `Read .nexus/issues/ISS-XXX.md` for the active issue if not in memory.

**B — Determine current phase**: Read `current_focus` from sprint-state.md `[CONVERSATION]`. Identify the active issue from `[OBJECTIVES]` (in_progress list). If no issue is in_progress: "❌ No active issue to loop back on." Exit. Extract current scores (A:X I:Y E:Z).

**C — Validate request**: If current phase is analysis, there's nowhere to loop back to:

> ℹ️ Already in Analysis Phase — nowhere to loop back.
>
> Options:
> - Try a different approach within analysis
> - Park this issue and work on something else
>
> What would you like to do?

Wait for user. Return without further steps.

---

### STEP 1: Determine Target Phase

**From implementation**: Target is always analysis. No choice needed — display and proceed.

> 🔄 Loop-Back: Implementation → Analysis
> Current scores: A:{X} I:{Y} E:{Z}

**From research**: Target is always analysis. Research uses the implemented score field, so reduction follows the same pattern as implementation.

> 🔄 Loop-Back: Research → Analysis
> Current scores: A:{X} I:{Y} E:{Z}

**From evaluation**: User chooses destination. Present with guidance:

> 🔄 Loop-Back from Evaluation
> Current scores: A:{X} I:{Y} E:{Z}
>
> Return to which phase?
>
> **Implementation** — Approach is sound, execution needs fixing. Tests fail on details, not design.
> **Analysis** — Approach itself needs rethinking. Even correct implementation wouldn't satisfy success criteria.

**[T2: Balanced+Full ask | Streamlined: auto-select based on signals, notify]** Use `AskUserQuestion tool` with options: [Implementation, Analysis]. Wait for selection.

---

### STEP 2: Capture Reason

Ask for a brief explanation to inform the target methodology's resumption:

> 📝 What isn't working with the current approach? (brief note)

Wait for user input. Store as `loop_reason`.

---

### STEP 3: Decompose Consideration

**Trigger**: Target phase is Analysis (approach was fundamentally wrong, not just execution bugs). If target is Implementation, skip to STEP 4.

When looping back to analysis, the original scope may itself be the problem. Check decompose signals per [Section: Decompose-Signals]:

Scan the 5 signals against the current issue context (ISS content, loop_reason, loop history). Assess signal strength per the Decompose-Signals strength table.

**If strong** (3+ signals fire clearly):

> 📊 Fundamental Rethink — Consider Decomposition?
>
> This loop-back suggests the original approach was flawed.
> Decompose signals detected:
> • {signal_1}: {evidence}
> • {signal_2}: {evidence}
> • {signal_3}: {evidence}
>
> [Decompose now / Continue to Analysis / Discuss scope first]

- **Decompose now**: `invoke /nexus-decompose-issue` — control transfers permanently. Loop-back ends here.
- **Continue to Analysis**: proceed to STEP 4 — revisit approach within current scope.
- **Discuss scope first**: discuss with user, then re-offer options.

**If medium** (2 signals or mix of medium-strength signals):

> 📊 Some decompose signals detected — {brief summary}.
> Proceeding to analysis. Consider decomposition if analysis reveals the scope is still too broad.

Note in continue_with for analysis resumption, then proceed to STEP 4.

**If weak or none**: Silent pass — proceed to STEP 4.

---

### STEP 4: Check Loop History

Read `[MOMENTUM]/loop_history` from sprint-state.md for previous loops on this issue.

**If 2–4 previous loops**: Show history and ask confirmation:

> ⚠️ Loop #{count} for ISS-{XXX}
>
> Previous loops:
> {for each}: • #{N}: {from} → {to} — {reason}
>
> Consider:
> - Is the problem definition clear enough?
> - Should this break into smaller issues?
> - Would external research help?
>
> Continue with loop-back? [Y/n]

If declined: return without changes.

**If 5+ previous loops**: Recommend parking:

> 🛑 Loop #{count} — this issue may need a different approach entirely.
>
> Recommend parking this issue (set to blocked) and working on something else.
>
> [Park issue / Continue anyway]

If park: move ISS-XXX from `in_progress` to `planned` in sprint-state `[OBJECTIVES]` with "(blocked)" appended to the line. Patch `current_focus` to next in_progress issue, or "none" if no other issues active. Inform user. Return without further steps.

---

### STEP 5: Apply Changes

All changes in this step. **[T2: Balanced+Full ask | Streamlined: auto-proceed, notify+log]** Get user confirmation first:

> 📋 Loop-Back Summary
>
> Transition: {current_phase} → {target_phase}
> Reason: {loop_reason}
> Score changes: {list changes per table below}
>
> Proceed? [Y/n]

Wait for explicit approval.

**A — Score adjustments** (reduce phases between current and target, never touch target):

| Transition | Changes |
|---|---|
| impl → analysis | implemented → 2 |
| research → analysis | implemented → 2 |
| eval → impl | evaluated → 2 |
| eval → analysis | evaluated → 2, implemented → 2 |

Update scores per two-place protocol:
1. `UPDATE: .nexus/active/registries/issues-registry.yaml` — patch score values
2. `UPDATE: .nexus/active/states/sprint-state.md#[OBJECTIVES]` — patch score string

**B — Update sprint-state focus and context**:

Patch `[CONVERSATION]/current_focus` → `{target_phase}` (e.g., "analysis" or "implementation").

Patch `[BOOTSTRAP]/continue_with` with loop-back context for the target methodology's resumption:

```
WHAT: Loop-back to {target_phase} for ISS-XXX
WHY: {loop_reason}
CONTEXT: Previous {target_phase} content exists in ISS — review and revise. Loop #{count}.
```

**C — Update loop history**:

Append to `[MOMENTUM]/loop_history`:

```
- loop: {N}
  from: "{current_phase}"
  to: "{target_phase}"
  conv: {conv_number}
  reason: "{loop_reason}"
```

If `loop_history` doesn't exist yet, create it after `energy_level`.

**D — Verify**: Confirm both registry and sprint-state reflect the new scores. Display: "🔄 Updated scores in 2 locations"

---

### STEP 6: Load Target Methodology

**Context check before loading**: Methodology skills are large. Check current context usage before invoking:

| Context | Action |
|---|---|
| < 60% | Invoke methodology skill directly — room to work |
| 60-75% | Invoke methodology skill but warn: "⚠️ Context at {X}% — save checkpoint early in the methodology" |
| > 75% | **Do NOT load.** Save checkpoint with continue_with set for the target methodology. Display: "💾 Context too high ({X}%) to load methodology. Checkpoint saved — next conversation will start in {target_phase}." Skip to STEP 7. |

If proceeding, invoke the target methodology skill:

| Target Phase | Skill |
|---|---|
| Analysis | Invoke `/nexus-analyze` with ISS ID and complexity |
| Implementation | Invoke `/nexus-build` with ISS ID and complexity |

---

### STEP 7: Complete

Display completion summary:

```
✅ Loop-Back Complete
════════════════════════════════════════
{current_phase} → {target_phase}
Reason: {loop_reason}
{if loop_count ≥ 2}: ⚠️ Loop #{count} — consider alternatives
Scores updated (2 places) ✓
Focus: {target_phase}
Methodology: {methodology} loaded ✓
════════════════════════════════════════

Resume {target_phase}:
{if analysis}: Review previous analysis in ISS, decide what to keep vs redo
{if implementation}: Review evaluation feedback, fix identified issues
```

Return to caller. The target methodology's STEP 0 handles resumption — it will find existing ISS content and offer review/revise/fresh options, informed by the loop reason in continue_with.
