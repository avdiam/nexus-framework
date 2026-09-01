---
name: nexus-move-issues
description: Move issues between sprints with dependency validation and capacity checks
disable-model-invocation: true
---
*Version: 2.1.0 | Date: 2026-08-20 | Sprint: 110*

# Move Issues

**Flow**: Load → Validate → Check dependencies → Check capacity → [T2: resolve conflicts] → Present impact → [T1: approve] → Apply → Verify → Report

Move specific issues between sprints with dependency validation and capacity checks. Handles both single and multi-issue moves with cascade detection.

---

### STEP 0: Load Context (silent)

Load these files (memory-first):

| File | Load | What You Need |
|------|-----|---------------|
| issues-registry.yaml | `Read .nexus/active/registries/issues-registry.yaml` | Allocations, status, dependencies, complexity for each issue being moved |
| sprint-queue.md | `Read .nexus/active/states/sprint-queue.md` | Sprint contents and capacity totals |
| sprint-state.md | `Read .nexus/active/states/sprint-state.md` | Conditional: only if source or target is current sprint (from `_sprint`); [OBJECTIVES] |

If target sprint not specified by user, display available sprints from sprint-queue.md and ask which one.

### STEP 1: Parse and Validate

Extract from the user's request: issue IDs (single or multiple) and target sprint number.

For each issue, extract from registry: current sprint (source), status, complexity, `blocks`, `blocked_by`.

If an issue has no `target_sprint` (empty or "TBD"), treat it as an assignment rather than a move — skip source sprint updates in STEP 3, just add to target.

**A. Status check**

Only `Open` or `In-Progress` issues can move (Registry-Schema status enum: Open | In-Progress | Resolved | Rejected | Superseded | Decomposed — there is no Planned/Blocked/Archived status; "blocked" is a `blocked_by` condition, not a status). If an issue is Resolved, Rejected, Superseded, or Decomposed, report and stop for that issue.

**B. Dependency check — bidirectional**

For each issue being moved, check BOTH directions:

*What it depends on* (`blocked_by`): Will all blockers still be in the target sprint or earlier? If a blocker is in a later sprint than the target, the moved issue would be waiting.

*What depends on it* (`blocks`): Are any dependents in the source sprint or earlier sprints that would now be AFTER the moved issue? Moving a blocker forward can break its dependents' schedule.

If conflicts found, display them clearly:

```
⚠️ Dependency Conflict

{issue_id} → Sprint {source} → {target} (requested move)

Upstream: {issue_id} depends on {blocker_id} (Sprint {N}) — blocker is AFTER target
Downstream: {dependent_id} (Sprint {N}) depends on {issue_id} — dependent left behind

Options:
1. Move {issue_id} + affected issues together
2. Choose a different target sprint
3. Cancel
```

**[T2: Balanced+Full ask | Streamlined: auto-resolve by moving together, notify]** Use `AskUserQuestion tool` for resolution. If the user chooses to move affected issues together, add them to the move set and re-validate the expanded set.

**C. Capacity check**

Only applies if the target sprint exists in the queue. Calculate target sprint complexity after the move. Guidance: ~9 comfortable, 10-11 acceptable, 12+ overloaded.

If overloaded, **[T2: Balanced+Full ask | Streamlined: warn and proceed, notify]** offer: proceed anyway, choose different target, or cancel. Use `AskUserQuestion tool`.

### STEP 2: Approve

Display the move impact:

```
📊 Move Impact

MOVING:
  • {issue_id}: {title} (P:{priority}, I:{impact}, C:{complexity})

From Sprint {source} → Sprint {target}

{if both sprints are in queue:}
Sprint {source}: {before} → {after} issues, {before_c} → {after_c} complexity
Sprint {target}: {before} → {after} issues, {before_c} → {after_c} complexity

{if target not in queue:}
Sprint {target} is not yet queued — registry will be updated, organize-sprint will pick this up when planning.

{if current sprint affected:}
⚡ Current sprint objectives will be updated
{if moving TO current sprint:}
⚡ {issue_id} will become the priority focus in current sprint
{if active issue being moved FROM current sprint:}
⚡ {issue_id} is the current focus — sprint focus will update to next issue
{if source sprint becomes empty:}
⚠️ Sprint {source} will have no remaining issues

Proceed?
```

**[T1: all levels ask]** Use `AskUserQuestion tool`: Approve | Cancel.

⛔ GATE: User has explicitly approved before any writes.

### STEP 3: Execute Updates

All writes. Build all patches first, then execute sequentially.

**Which files to update:**

| File | When | What |
|------|------|------|
| issues-registry.yaml | Always | Patch `target_sprint` for each moved issue |
| sprint-queue.md | Source or target sprint exists in queue | Remove from source `planned_work`, add to target `planned_work`, update `total_complexity` for both. Format: `- ISS-XXX: Title (priority, complexity)` |
| sprint-state.md | Source or target is current sprint | See below |

**Sprint-state updates when current sprint is involved:**

Moving FROM current sprint: remove issue from `[OBJECTIVES]` (in_progress or planned). If it was `current_focus`, update to the next in-progress issue, or first planned issue if none in progress.

Moving TO current sprint: first check if the issue is already in `[OBJECTIVES]` (it may be in `planned` if the current sprint was pre-planned with it). If found in `planned`, remove it from there. Then add to `in_progress` with scores from registry, update `current_focus` to this issue, and update `continue_with` to reflect the new priority. This is the primary use case: the user wants to address this issue immediately.

If any write fails: report which file failed, note which files were already modified (text state files are recoverable from the last git checkpoint — `git checkout HEAD -- {path}`; there is no file-level backup for .md/.yaml). Don't auto-rollback — let the user decide.

### STEP 4: Verify and Report

Quick verification: search registry for each moved issue — confirms new `target_sprint`. If queue was updated, check sprint-queue for correct lists.

```
✅ Move Complete

  • {issue_id}: Sprint {source} → {target}

Updated:
  ✓ issues-registry.yaml
  {✓ sprint-queue.md} (if applicable)
  {✓ sprint-state.md} (if applicable)

{if queue updated:}
Sprint {source}: {count} issues, {complexity} complexity
Sprint {target}: {count} issues, {complexity} complexity

{if moved to current sprint:}
Current focus updated to {issue_id}.
```

---

## Gate Reference

| Gate | Step | Tier | Full | Balanced | Streamlined |
|---|---|---|---|---|---|
| Dependency conflict resolution | STEP 1 | T2 | Ask | Ask | Auto-resolve, notify |
| Capacity overload warning | STEP 1 | T2 | Ask | Ask | Warn and proceed, notify |
| Move approval | STEP 2 | T1 | Ask | Ask | Ask |

---

## Error Recovery

| Problem | Recovery |
|---|---|
| Registry patch fails | Retry with broader context. If still fails, report which issues need manual target_sprint update. |
| Sprint-queue patch fails | Rebuild queue entries from registry state. Retry. |
| Sprint-state patch fails | Report which objectives need manual adjustment. |
| Dependency creates cycle | Block the move. Inform user of the cycle and suggest alternative. |
