---
name: nexus-work-issue
description: Set an issue as active focus — brings into sprint, detects phase, starts methodology
disable-model-invocation: true
---
*Version: 2.1.0 | Date: 2026-08-20 | Sprint: 110*

# Work Issue

**Flow**: Parse issue → Check sprint context → [T2: bring in if needed] → Transition safety → Set focus → Detect phase → Load methodology

Set an issue as active focus, bringing it into the current sprint if needed. Detects the appropriate phase from scores and loads the corresponding methodology skill.

---

### STEP 0: Parse Issue

If ISS-XXX specified in user request: extract ID, proceed to STEP 1.

If no specific issue: `load /nexus-view-issues` to let user select, then proceed with selected ID.

---

### STEP 1: Check Sprint Context

Search sprint-state.md [OBJECTIVES] (always in memory from bootstrap) for ISS-{XXX} in `in_progress` or `planned` lists.

**If issue IS in current sprint**: Proceed to STEP 2.

**If issue is NOT in current sprint**: Offer to bring it in.

```
ISS-{XXX} is not in current sprint objectives.

1. Bring it into current sprint and work on it
2. Cancel
```

**[T2: Balanced+Full ask | Streamlined: auto-bring-in, notify]**

If cancel: exit.

If bring in, execute sub-steps:

**A. Verify issue exists**: `Read .nexus/active/registries/issues-registry.yaml` (targeted search) for ISS-{XXX}. Extract title, status, complexity, target_sprint, and scores (A/I/E). If not found:

```
❌ ISS-{XXX} not found in registry.

Try: "list issues" to browse active issues, or check the ID and try again.
```

Exit.

**B. Status check**: Issue must be `Open` or `In-Progress` (Registry-Schema status enum: Open | In-Progress | Resolved | Rejected | Superseded | Decomposed — there is no Planned status; "planned" is a sprint-state [OBJECTIVES] list, not a registry value). If Resolved, Rejected, Superseded, or Decomposed:

```
❌ Cannot work on ISS-{XXX} — status: {status}.

Closed issues (Resolved/Rejected/Superseded/Decomposed) are read-only. To reopen, use "update issue ISS-{XXX}" to change status first.
```

Exit.

**C. Capacity warning**: Sum complexity of all issues in current sprint [OBJECTIVES] plus the new issue's complexity. If over 9: "⚠️ Sprint complexity will be {total} (guideline: ≤9). Proceed anyway? [Y/n]"

**D. Update registry**: Patch target_sprint and status to current sprint number.

```
Edit tool(
  filepath: "issues-registry.yaml",
  patches: [
    { find: "ISS-{XXX}.target_sprint: {old}", replace: "ISS-{XXX}.target_sprint: \"{current_sprint}\"" },
    { find: "ISS-{XXX}.status: \"Open\"", replace: "ISS-{XXX}.status: \"In-Progress\"" }
  ]
)
```

Note: Only patch status if currently "Open". If already "In-Progress" (returning to an issue), skip the status patch.

**E. Update sprint-state**: Add to in_progress in [OBJECTIVES]. Use scores from registry if issue had prior work, default A:1 I:1 E:1 if new.

```
Edit tool(
  filepath: "sprint-state.md",
  patches: [{ find: "in_progress:", replace: "in_progress:\n- ISS-{XXX}: {title} ({priority}, {complexity}) - A:{a} I:{i} E:{e}" }]
)
```

**F. Update sprint-queue**: Check the issue's original `target_sprint` (extracted in STEP 1A).

- If target_sprint was TBD or empty: no sprint-queue update needed — the issue wasn't in any planned sprint.
- If target_sprint was a sprint number (current through N+2): load sprint-queue.md, remove ISS-{XXX} from the old sprint's `planned_work`, and add it to the current sprint's `planned_work`. Update `total_complexity` for both sprints accordingly. Patch.
- If target_sprint was beyond N+2 (not tracked in sprint-queue): no sprint-queue update needed.

Display: "✅ ISS-{XXX} brought into Sprint {current} — registry, sprint-state, and sprint-queue updated."

On any patch failure: report which file failed and which were already patched (text state files are recoverable from the last git checkpoint — `git checkout HEAD -- {path}`; there is no file-level backup for .md/.yaml), then exit — let the user decide on rollback.

⛔ GATE: Cannot proceed to STEP 2 unless issue is in current sprint objectives.

---

### STEP 2: Transition Safety

Before switching focus, check if there's active work in progress.

**A. Detect active work**: Is `current_focus` set to a work phase (analysis/research/implementation/application/evaluation) with an issue different from ISS-{XXX}?

| Condition | Action |
|---|---|
| No active work (planning, learning, or same issue) | Skip to STEP 3 |
| Active work on different issue | Prompt: "You have active work on ISS-{current}. Save progress first? [Save + switch / Switch without saving / Cancel]" |

If save: follow [Section: Checkpoint-Protocol], then continue to STEP 3.
If switch without saving: note "⚠️ Unsaved progress on ISS-{current}" in continue_with context, continue to STEP 3.
If cancel: exit.

---

### STEP 3: Set as Active Focus

**A. Reorder objectives**: Move ISS-{XXX} to top of `in_progress` (if currently in `planned`, move to `in_progress` first).

**B. Detect phase** from scores:

| Condition | Phase | Methodology |
|---|---|---|
| analyzed < 4 | analysis | /nexus-analyze |
| analyzed ≥ 4, implemented < 4, issue type = Research | research | /nexus-research |
| analyzed ≥ 4, implemented < 4 | implementation | /nexus-build |
| implemented ≥ 4, evaluated < 4 | evaluation | /nexus-validate |

**C. Set focus**: Patch sprint-state.md `current_focus` to detected phase.

**D. Load ISS**: Read `.nexus/issues/ISS-{XXX}.md` if not already in memory. This gives immediate problem context — the methodology's context step will find it already loaded (📌).

**E. Methodology alignment**: Check if the currently loaded methodology matches the detected phase. If mismatch (e.g., /nexus-analyze loaded but issue needs /nexus-build):
- Context < 75%: load the correct methodology skill now.
- Context ≥ 75%: save checkpoint with continue_with set for this issue + detected phase. Display: "💾 Context too high to load methodology. Checkpoint saved — next conversation starts on ISS-{XXX} in {phase}."

Display:

```
✅ Active Focus Set

ISS-{XXX}: {title}
Phase: {detected_phase} (A:{a} I:{i} E:{e})
Methodology: /nexus-{skill} {loaded | already active}
```
