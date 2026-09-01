---
name: nexus-sprint-status
description: Show current sprint progress, objectives, capacity, and momentum
disable-model-invocation: true
---
*Version: 2.0.1 | Date: 2026-06-14 | Sprint: 103*

# Sprint Status

**Flow**: Load sprint-state + ISS files → Assess health/capacity/progress → Display mode-adapted report

Display comprehensive sprint progress with per-issue detail, capacity analysis, health assessment, and actionable recommendations. Read-only operation.

---

### STEP 0: Load Context (silent)

`Read .nexus/active/states/sprint-state.md` (memory-first). If not found: display "❌ No active sprint — use 'organize sprint' to create one" and stop.

For each issue in `[OBJECTIVES]` that is `in_progress`: `Read .nexus/issues/ISS-XXX.md` (memory-first) to extract progress detail. Don't load ISS files for `planned` or `completed` issues — scores from `[OBJECTIVES]` are sufficient for those.

---

### STEP 1: Assess Sprint

**Per-issue progress** (for each in-progress issue, extract from ISS file):

| Source | What to Extract |
|--------|----------------|
| Success Criteria | Checked vs unchecked items — the real measure of "done" |
| Implementation-Plan | Step statuses (✅/🔄/⬜), items done vs total |
| Implementation-Log | Current phase, what's been accomplished |
| Dependencies `blocks` | What completing this issue unlocks downstream |
| Work Log (latest entry) | Most recent activity and when |
| A:I:E scores | From `[OBJECTIVES]` in sprint-state |

For planned issues: use scores from `[OBJECTIVES]` only.
For completed issues: show as done with final outcome.

**Sprint-level context** (from sprint-state):

| Source | What to Extract |
|--------|----------------|
| `conversation_number` + `last_checkpoint` | Sprint timeline — how long we've been working, when last saved |
| `[DECISIONS] pending` | Open questions blocking progress — directly actionable |
| `[DECISIONS] options_for_next` | Choices queued for next conversation |
| `[MOMENTUM] loop_history` | Phase regressions, if any occurred |

**Sprint health** — assess overall:

| Health | Condition |
|--------|-----------|
| 🟢 Good | Progress steady, no blockers, no pending decisions |
| 🟡 Caution | Some issues blocked, pending decisions, progress slower than expected, or phase regression occurred |
| 🔴 At risk | Multiple blockers, stalled progress (no movement in 2+ conversations), or critical decisions pending |

**Capacity** — sum complexity of all sprint issues vs ~9 target:

| Label | Range | Signal |
|-------|-------|--------|
| LIGHT | ≤7 | Could add more work |
| GOOD | 8-10 | Comfortable |
| HIGH | 11-12 | Acceptable if justified |
| OVERLOADED | 13+ | Recommend rebalancing |

**Recommendations** — only if actionable issues exist:
- Overloaded → suggest moving an issue to next sprint
- Blocked issues → note blocker, suggest resolution path
- Pending decisions → highlight what needs deciding to unblock progress
- Stalled (no movement in 2+ conversations) → suggest reassessment or pause
- All high-complexity → suggest adding a quick win for momentum

---

### STEP 2: Display Status

**Unified display template:**

```
🚀 SPRINT {N} STATUS
═══════════════════════════════════════════════
{title} | Mode: {MODE} | Health: {🟢/🟡/🔴}
Conv: {N} | Last save: {last_checkpoint}

📋 ISSUES:

{for each issue, adapted by mode — see mode notes below}

{issue_display_block}

📊 SPRINT OVERALL
───────────────────────────────────────────────
Capacity:  {sum_complexity}/~9 ({LIGHT|GOOD|HIGH|OVERLOADED})
Progress:  ~{X}% complete
Focus:     {current_issue_or_phase}
Remaining: {summary of pending work}

{if pending_decisions:}
⏳ PENDING DECISIONS:
• {decision description}

{if loop_history:}
⚠️ PHASE REGRESSIONS:
• {from} → {to} (Conv {N}): {reason}

{if recommendations:}
💡 RECOMMENDATIONS:
• {actionable recommendation}
═══════════════════════════════════════════════
```

**Per-issue display block** (used for each issue):
```
ISS-{XXX}: {title} (A:{X} I:{Y} E:{Z}) {status_icon}

  {if has Success Criteria:}
  🎯 Criteria: {checked}/{total} met
     ✅ {met criterion}
     ☐ {unmet criterion}

  {if has Implementation-Plan with trackable steps:}
  📋 Plan:
  ✅ Step 1: {description}
  🔄 Step 2: {description}  ← current
  ⬜ Step 3: {description}
  Progress: {done}/{total} steps

  {else:}
  Analysis: {A}/5 | Implementation: {I}/5 | Evaluation: {E}/5

  {if blocks other issues:}
  🔓 Unlocks: {ISS-YYY, ISS-ZZZ}

  {if has recent Work Log entry:}
  📝 Last activity: {date} — {brief description}
```
Status icons: ✅ completed, 🔄 in progress, ⏳ planned/queued, ⚠️ blocked.

**Mode adaptation** — how to organize the issues section:

| Mode | Primary View | Issue Order | Emphasis |
|------|-------------|-------------|----------|
| THEMED | Phase aggregation first — show which phase all issues are in collectively, then per-issue detail | All issues together, grouped by current phase | "All issues in implementation phase — 60% through" |
| MIXED | Issue sequence — completed first, then in-progress, then queued | ✅ → 🔄 → ⏳ | "2/4 issues complete, working on ISS-XXX" |
| DEDICATED | Single issue deep dive — maximum detail on the one issue | One issue, full Implementation-Plan breakdown | "ISS-XXX: 22/58 items complete (38%)" |

For THEMED mode, add a phase aggregation line before the per-issue blocks:
```
📊 Sprint Phase: {phase_name} — {issues_in_phase}/{total_issues} issues active
```

For MIXED mode, group issues under status headers (✅ COMPLETED / 🔄 IN PROGRESS / ⏳ QUEUED).

For DEDICATED mode, expand the single issue's Implementation-Plan to show all phases/stages if available, not just current steps.
