---
name: nexus-close-issue
description: Close an issue as Resolved or Rejected with knowledge extraction
disable-model-invocation: false
---
*Version: 3.1.0 | Date: 2026-06-16 | Sprint: 105*

# Close Issue

**Flow**: Detect mode → Load context → [T1: resolution type] → Extract knowledge or capture reason → Atomic 3-file update → Verify → Report

Close an issue as Resolved or Rejected with knowledge extraction. Supports manual (interactive) and batch (from close-sprint) modes. Pattern processing deferred to close-sprint.

---

**Pattern handling note**: All pattern processing (effectiveness updates, candidate creation) is deferred to close-sprint, which processes patterns in batch with full sprint context. close-issue captures knowledge in [Section: Closure] for close-sprint to read.

### STEP 0: Detect Mode & Load Context

**Mode detection:**

| Signal | Mode | Behavior |
|---|---|---|
| User calls "close issue ISS-XXX" directly | Manual | Interactive with confirmations |
| Called by close-sprint with issue list | Batch | Streamlined, auto-decisions where safe |


Load registry metadata via regex search for `ISS-{XXX}.(status|analyzed|implemented|evaluated|title):` (~0.3KB). Parse the 5 values.

If not found: "❌ ISS-{XXX} not found in registry." Exit.

`Read .nexus/issues/ISS-{XXX}.md` if not in memory — needed for knowledge extraction in STEP 2.

Validate: status must be Open or In-Progress. If already Resolved/Rejected/Superseded: "ℹ️ ISS-{XXX} already {status}." Exit.

**Manual mode confirmation:**

```
📋 Close Issue: ISS-{XXX}
════════════════════════════════════

Title: {title}
Scores: A:{analyzed}/5 I:{implemented}/5 E:{evaluated}/5
Status: {status}

Close this issue? [Y/n]:
```

**Batch mode**: Skip confirmation (caller validated).

---

### STEP 1: Resolution Type

**[T1: all levels ask]**

**Batch mode**: If all scores ≥ 4, auto-resolve and proceed to STEP 2A. If scores incomplete, stop and ask — use `AskUserQuestion tool` widget: Close as Resolved anyway / Close as Rejected / Skip this issue.

**Manual mode**: Use `AskUserQuestion tool` widget: Resolved (successfully completed) / Rejected (won't fix) / Cancel.

Route: Resolved → STEP 2A. Rejected → STEP 2B. Skip/Cancel → exit.

---

### STEP 2A: Resolved — Extract Knowledge

**Extract from ISS file** (both modes):

| Source | Section | Content |
|---|---|---|
| Primary | [Section: Solution-Design] → ### Approach | Key strategy taken |
| Secondary | [Section: Implementation-Log] → ### Technical Decisions | What worked technically |
| Tertiary | [Section: Evaluation-Results] → ### Quality Assessment | Overall quality outcome |
| Patterns | [Section: Solution-Design] → ### Tools & Patterns | Patterns chosen |
| Outcomes | [Section: Implementation-Log] → ### Pattern Outcomes | Pattern results |
| Fallback | ## Description | Problem context if sections are sparse |

Synthesize into resolution summary (what was done, what made it successful) and knowledge captured (what worked, lessons learned, candidate patterns if any).

**Manual mode enhancement**: Display extracted summary, let user add details or accept as-is.

**Batch mode**: Use extracted summary directly.

**Pattern Verdict Capture (consolidated)** — for each pattern in sprint-state [PATTERNS_IN_USE] for this issue (and any in ISS ### Pattern Outcomes), assign exactly one **verdict** from {helped, neutral, hindered} with a one-line evidence note. This is the single consolidated verdict pass; close-sprint STEP 3 → update-pattern consumes it. **No verdict captured here → no `successes++` there.**

| Verdict | When | Counter effect (applied at close-sprint) |
|---|---|---|
| **helped** | Genuinely contributed *beyond* what the framework already enforces | `successes += 1` |
| **neutral** | Applied but no value beyond an always-on CLAUDE.md rule/preference or skill step (echo), or contribution indeterminate | `neutral += 1` (neither numerator nor volume-confidence) |
| **hindered** | Misled, added friction, or caused rework | `failures += 1` |

⛔ **Dedup hard-gate (SC-04)**: before writing `helped`, ask "did this add value beyond what the framework already enforces?" If the pattern merely restates an always-on CLAUDE.md core rule/preference/trait or a skill step, **cap the verdict at `neutral`** — it cannot be `helped` no matter how cleanly it applied. High application count is not value. Each verdict requires its evidence note; a verdict with no grounding evidence is the detectable form of the auto-success anti-pattern. (Canonical taxonomy: pattern-specification.md → Outcome Verdicts; rule: CLAUDE.md Pattern Governance.)

**Manual mode**: present the verdict table for confirmation/adjustment. **Batch mode**: assign verdicts from ISS Pattern Outcomes evidence; a pattern lacking evidence of genuine contribution defaults to `neutral`, never `helped`.

Build closure content:

```markdown
### Resolution

{resolution_summary}

### Knowledge Captured

**What Worked**:
{techniques, decisions, approaches worth remembering}

**Lessons Learned**:
{what went well, challenges, for next time}

{if candidate_patterns:}
**Candidate Patterns**:
{for each: - "{brief}" — {principle}}

{if patterns_used:}
**Pattern Outcome Verdicts** (verdict + evidence per applied pattern — consumed by close-sprint STEP 3 → update-pattern):

| Pattern | Verdict | Evidence (1 line) |
|---|---|---|
| PAT-XXX | {helped / neutral / hindered} | {what it concretely contributed, or why no value beyond what the framework enforces} |
```

Proceed to STEP 3.

---

### STEP 2B: Rejected — Capture Reason

Ask for rejection reason (required, both modes, minimum 5 characters):

```
📝 Why is ISS-{XXX} being rejected?

Common reasons: Out of scope, Duplicate, No longer relevant,
Blocked indefinitely, Superseded by different approach

Reason:
```

**Manual mode only**: Offer optional learning capture — "Any lessons from this attempt? (Enter to skip)"

Build closure content:

```markdown
### Resolution

*Rejected: {YYYY-MM-DD}*

**Reason**: {rejection_reason}

### Knowledge Captured

{if lessons: lessons_learned}
{else: "None — rejected before significant work."}
```

Proceed to STEP 3.

---

### STEP 3: Apply Updates (Atomic)

All changes succeed together or all rollback. Build all patches in memory first, then execute in sequence.

**Operation 1 — ISS file**: Write closure content into scaffolded markers:

```
Edit tool(
  filepath: "ISS-{XXX}.md",
  startMarker: "[Section: Closure]",
  endMarker: "[/Section: Closure]",
  newContent: "[Section: Closure]\n\n{closure_content}\n\n[/Section: Closure]",
  includeMarkers: true,

)
```
On failure: abort (no changes made yet).

**Operation 2 — Registry**: Patch status; **preserve** the evaluated score:

- `ISS-{XXX}.status: "{old}" → "{Resolved|Rejected}"`
- `ISS-{XXX}.evaluated`: **leave as-is** — do NOT force `→ 5`. The Validate phase already set this score; a legitimate Resolved@E:4 (CONCERNS) closure must keep its 4 (Resolved ≠ perfect — 2 instances Sprint 091: ISS-200, ISS-199, both deliberately closed E:4). Force-5 belongs only to the explicit score-override path, which **close-sprint STEP 2C already handles** (it patches scores<4→5 *before* invoking close-issue). By the time close-issue runs, the registry evaluated score is already correct — close-issue must not overwrite it.

On failure: restore Operation 1 backup. Abort.

**Operation 3 — Sprint-state** (conditional — skip if ISS-{XXX} not in current sprint [OBJECTIVES]): Move ISS-{XXX} from `in_progress:` to `completed:` in [OBJECTIVES]. The two lists use different line formats:
- `in_progress` format: `- ISS-XXX: {title} ({priority}, {complexity}) - A:{a} I:{i} E:{e}`
- `completed` format: `- ISS-XXX: {title} - {Resolved|Rejected}`

When moving: drop the `({priority}, {complexity}) - A:{a} I:{i} E:{e}` suffix, append `- {Resolved|Rejected}` as the outcome.

On failure: restore Operation 2 and Operation 1 backups. Abort.

**Operation 4 — Downstream dependency clearing** (atomic, both Resolved and Rejected paths):

Scan the registry for all entries where `ISS-YYY.blocked_by` contains the closing `ISS-XXX`. For each downstream entry found:

- Patch the registry: remove `ISS-XXX` from the target's `blocked_by` list (preserving remaining entries, preserving YAML structure).
- If `blocked_by` becomes empty after removal, write it as `blocked_by: []`.

**Scope limit** (user-locked preference): clear ONLY references to the closing `ISS-XXX`. Do NOT opportunistically remove other orphan references encountered during the scan — orphan detection is `/nexus-issue-validation`'s responsibility (its STEP 3b missing-ref check).

**Fires on both Resolved and Rejected closure paths** — downstream issues that were waiting on this work must stop waiting regardless of outcome. A rejected blocker releases its dependents just as a resolved one does.

**No-op case**: If no downstream entries reference `ISS-XXX`, Operation 4 succeeds silently with zero patches. Do not fail or warn.

**On failure**: restore Operation 3, 2, and 1 backups. Abort with the full 4-operation rollback. The transaction is all-or-nothing — Op 4 failure cannot leave downstream `blocked_by` entries partially cleared while the closure completes.

**Transaction failure display:**

```
❌ CLOSURE FAILED - Changes Rolled Back

Error at: {operation_name}
Reason: {error_message}

All files restored to previous state.
No partial changes exist.

1. Retry closure
2. Cancel (investigate manually)
```

**Verify** after all operations succeed:
- ISS closure section has `### Resolution`
- Registry status updated
- Sprint-state shows issue in completed
- Each downstream entry touched by Op 4 no longer contains ISS-XXX in `blocked_by` (spot-check by reading back affected entries)

If verification fails: warn but continue (operations succeeded, verification is confirmation).

**Staleness advisory**: If sprint-state [FILES_MODIFIED] includes framework files (CLAUDE.md, skills, templates), check whether those files appear in documentation-registry.yaml. If they do, flag affected documentation entries as potentially stale: "📋 Documentation may need review: {list of affected guide/doc names}. Run 'check staleness' for details." This is advisory only — it does not block closure or require action.

---

### STEP 4: Report

**Manual mode:**

```
✅ Issue ISS-{XXX} Closed
════════════════════════════════════

Resolution: {Resolved|Rejected}
Final Scores: A:{analyzed} I:{implemented} E:{evaluated}

Pattern processing: Deferred to sprint closure
Ready for archive: true
════════════════════════════════════
```

**Batch mode:** `✓ ISS-{XXX}: {Resolved|Rejected}`

Return: `{ issue_id, status, ready_for_archive: true }`

---

## Discipline Enforcement Layer
[Section: Discipline-Enforcement-Layer]

Full Layer (write/close class) per operation-skill-template §Discipline Enforcement Layer — close-issue declares an issue *complete* and mutates three files atomically. Its over-claiming surface: closing as **Resolved** when criteria aren't actually met, force-completing scores, or rubber-stamping a batch closure without reading the evidence.

### 1. Default Adversarial Posture

This operation runs adversarial by default. I assume the issue is **not** ready to close until evidence proves it is — closure is earned, not granted. I do not confirm a requested closure; I challenge it: are the scores real, and is the closure content grounded in the ISS rather than invented?

Not complexity-conditional, and **not relaxed in batch mode** — batch closures are exactly where rubber-stamping happens. Downgrade only on explicit user override with logged rationale in [DECISIONS].

### 2. Red Flags Vocabulary

| Red Flag | Signal | Corrective |
|---|---|---|
| "scores are basically 4" / "close enough to resolved" | Premature closure — criteria not actually met | Read the real registry scores; Resolved needs A/I/E ≥ 4 with evidence, else route to Rejected or keep Open |
| "I'll set evaluated to 5 on close" | Score inflation at the gate | Preserve the Validate-set score (STEP 3 Op 2 — do NOT force →5) |
| "batch mode — just resolve them all" | Rubber-stamp | Each batch issue is still validated; incomplete scores stop and ask |
| "knowledge extraction is obvious, skip it" | Hollow closure | Extract from the named ISS sections; "None" only when genuinely sparse |
| "pattern applied, so it's a success" / auto-`helped` | Auto-success — every applied pattern scored helped | Assign {helped/neutral/hindered} with evidence per STEP 2A; apply the dedup hard-gate (echo→neutral). No `successes++` without a grounded `helped` (ISS-224) |
| "Done!" / "All set!" before the 3-file verify | Premature completion | Emit the STEP 3 verify output first |

### 3. Rationalizations to Watch For

| Excuse (you might think this) | Reality (why the excuse is wrong) |
|---|---|
| "Build was clean, so closure is a formality." | Build self-review ≠ closure verification. Closure checks the whole closed-issue contract (scores, closure content, downstream clearing). |
| "It's a Rejected, so I can skip the reason." | Rejected requires a reason ≥5 chars (STEP 2B). An unreasoned rejection loses the why. |
| "The user asked to close, so the gate is satisfied." | A close request ≠ verified-ready. The resolution-type gate (T1) and the score check still fire. |
| "Scores < 4 but it's effectively done." | Either complete the phases, or close Resolved@CONCERNS with the real score preserved, or Reject. Do not fabricate readiness. |

### 4. Anti-Patterns

The 9 base anti-patterns inherit from operation-skill-template §Discipline Enforcement Layer §4 (Gate-Dressed Conditional, Cross-Reference-Only Gate, Post-Hoc Adversarial, Constraint-Wall-Only, Placeholder Shipping, Premature-Completion Vocabulary, Silent Downgrade, Over-Specified Step, Under-Specified Step). close-issue-specific additions:

#### ❌ Score-Force on Close

**What it looks like**: Setting `evaluated → 5` inside close-issue.
**Why bad**: Overwrites the Validate verdict; a legitimate Resolved@E:4 (CONCERNS) loses its real score. Score-override is close-sprint STEP 2C's job, *before* close-issue runs.
**Corrective**: STEP 3 Op 2 preserves the evaluated score as-is.

#### ❌ Hollow Closure

**What it looks like**: ### Resolution / ### Knowledge Captured filled with generic text not traceable to the ISS.
**Why bad**: The closure record is the durable knowledge artifact close-sprint reads. Invented content corrupts pattern processing.
**Corrective**: Extract from the named sections (STEP 2A table); cite what was actually done.

#### ❌ Auto-Success Verdict

**What it looks like**: Recording every applied pattern as `helped` (or the pre-ISS-224 `success`), or assigning a verdict with no evidence note.
**Why bad**: Corrupts the learning loop close-sprint depends on — match-pattern surfacing, pattern-maintenance scoring, and retire/keep decisions all read this telemetry. An echo-pattern that merely restates a core rule inflates toward 1.00 and looks valuable when it is not.
**Corrective**: Assign {helped/neutral/hindered} per the STEP 2A verdict table with a one-line evidence note; apply the dedup hard-gate (echo → cap at `neutral`).

### 5. Bounded Iteration Cap

If the readiness check fails (scores incomplete, closure content ungrounded), retry up to **3 times** with incremental evidence-gathering. On the 3rd consecutive failure:

ESCALATE — do not continue retrying. Return control with: the gate name, what was attempted (3 bullets), what blocks (e.g. "E:2, no Evaluation-Results content — not closeable; route to Validate or keep Open").

### 6. FILLED / ESCALATED / SKIP Classification

The closure decision terminates in one explicit state:

| State | Meaning | Required output |
|---|---|---|
| **FILLED** | Closure verified — scores meet the resolution type, closure content grounded, 3-file atomic update applied | Evidence anchor: registry scores read back + "### Resolution" present on disk |
| **ESCALATED** | Issue not closeable as requested (scores short, evidence missing) after iteration cap | What blocks + what was attempted |
| **SKIP (justified)** | Closure deliberately not applied (user cancel, already-closed) | Reason + the rule permitting it (STEP 0 / STEP 1) |

No closure proceeds to STEP 4 Report without one of these three states assigned.

### Layer Audit Checklist

- [ ] Default Adversarial Posture declared (not complexity-conditional, not batch-relaxed)
- [ ] Red Flags table reproduced in-file
- [ ] Rationalization table present with ≥4 excuse/reality pairs
- [ ] Anti-Patterns: 9 base inherited + close-issue-specific (Score-Force on Close, Hollow Closure, Auto-Success Verdict)
- [ ] Bounded Iteration Cap specified (3-attempt rule)
- [ ] FILLED / ESCALATED / SKIP required at the closure gate
- [ ] No softened gate phrasing

[/Section: Discipline-Enforcement-Layer]
