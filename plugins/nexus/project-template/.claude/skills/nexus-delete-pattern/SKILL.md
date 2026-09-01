---
name: nexus-delete-pattern
description: Delete or archive stale patterns with safety checks
disable-model-invocation: true
---
*Version: 2.2.0 | Date: 2026-08-20 | Sprint: 110*

# Delete Pattern

**Flow**: Detect mode → Protection check → [T2: learning capture] → [T1: confirm] → Clean references → **Archive** (record + move file) → Remove entry → Report

**Retire = archive, not hard-delete.** Retirement MOVES a pattern to `.nexus/archived/patterns/` and records its full registry block in `.nexus/archived/patterns/retired-registry.yaml` — fully reversible. Hard-delete (permanent) is retained only as a justified exception (STEP 3 §Hard-delete exception). Captures optional lessons before removal.

*(Origin: ISS-223 Sprint 105 — the value/dedup consolidation required reversible retirement; Phase A hand-piloted the archive substrate, Phase B codified it here.)*

---

### STEP 0: Detect Mode

Determine mode from context:

**Merge backend**: Called from `/nexus-merge-patterns` STEP 4D with `reason='merged'` and `merged_into={keeper_id}`. Skip candidate identification and learning capture (merge-patterns already preserved wisdom in the keeper). Proceed directly to STEP 3 with the provided pattern ID.

**Backend**: Called from `/nexus-pattern-maintenance` (a list of pattern IDs and reasons) or from `/nexus-list-patterns` STEP 4 (a single pattern ID from the detail view). Skip candidate identification. Proceed to STEP 2 (learning capture) for each pattern.

**User interactive**: User typed "delete pattern" as standalone command. Proceed to STEP 1 to identify candidates.

---

### STEP 1: Identify Candidates (User Mode Only)

`Read .nexus/active/registries/patterns-registry.yaml` (memory-first). Scan all patterns for deletion criteria:

**Protection checks** (apply before any criteria):
- `PAT-XXX.type == 'principle'`: SKIP — never delete principles. They are foundational wisdom.
- `PAT-XXX.maturity == 'established'`: Flag for strong warning if matched by criteria below.

**Deletion criteria**:
- Low effectiveness: `effectiveness < 0.50` for patterns with meaningful usage (total applications ≥ 3). Note: `0.50` is the default *seed* effectiveness a pattern is born with — low effectiveness alone is not a weakness signal without meaningful usage.
- Unused: `last_used == null` or unused for 10+ sprints — **age-gate exemption**: patterns created within the last ~2 sprints are exempt from retire-for-non-use (judged on wisdom + overlap only, not usage). See `/nexus-pattern-maintenance` Tier 1 for the canonical age-gate rule.
- Superseded: manual review — functionality has been embedded in system files (a CLAUDE.md principle/preference/trait, or a skill step) or replaced by a better pattern. This *framework-redundancy* signal is the strongest retire driver (ISS-223 finding: ~half a bloated library can be framework-subsumed regardless of usage).

If no candidates found, inform the user and return — system is in healthy state.

Display candidates:

```
🗑️ PATTERN DELETION CANDIDATES
════════════════════════════════════════════

Found {count} pattern(s) meeting deletion criteria:

{N}. [{id}] {name}
    Reason: {reason}
    Effectiveness: {eff}% | Applications: {total}
    {if established}: ⚠️ ESTABLISHED — confirm carefully

────────────────────────────────────────────
```

**[T1: all levels ask]** Offer via `AskUserQuestion tool`: "Delete all" / "Select specific" / "Cancel."

If select specific, ask the user which ones. Proceed with confirmed list.

---

### STEP 2: Learning Capture

For each pattern about to be deleted (skip this step in merge backend mode — wisdom already preserved in keeper):

**[T2: Balanced+Full ask | Streamlined: skip capture, notify]** Ask the user via `AskUserQuestion tool`: "Capture lessons before deleting {id} {name}?" — "Yes" / "No" / "Skip all remaining."

If yes, ask: "What did we learn? (1-2 sentences)"

`UPDATE: .nexus/active/states/sprint-state.md [DISCOVERIES] insights APPEND {entry}` — capture as a sprint insight (schema: sprint-state-template `[DISCOVERIES]` `insights:` list, `- Conv {N}: …`); `/nexus-index-sprint` carries it to `discoveries.jsonl` at close-sprint. `[SYSTEM_ISSUES]` is for defects, not retirement lessons:
```
Edit tool(
  filepath=".nexus/active/states/sprint-state.md",
  patches=[{
    find: "insights:",          # the [DISCOVERIES] sub-list header — unique in sprint-state; grep to confirm before patching
    replace: "insights:\n- Conv {N}: Pattern retired — {id} {name}: {lesson} (eff: {eff}%, apps: {total})"
  }]
)
```

---

### STEP 3: Retire Pattern (Archive by default)

Retirement **archives** the pattern — fully reversible — rather than hard-deleting it. The active registry block + PAT file are moved to the archive; nothing is destroyed. (Hard-delete is the justified exception below.)

For each pattern in the confirmed list (`Read .nexus/active/registries/patterns-registry.yaml` if not already in memory — STEP 1 loads it in user mode; in backend/merge modes, verify loaded here):

**A. Capture the full registry block.** Read all `PAT-XXX.*` lines (from `PAT-XXX.name` through `PAT-XXX.conflicts`) plus the `# --- PAT-XXX ---` comment header. This exact block is needed twice — for the archive record (C) and as the removal find-string (E) — so capture it before changing anything.

**B. Clean stale references from other patterns.** Search the registry for any `synergies` or `conflicts` fields that contain this pattern ID. If found, patch those fields to remove the stale ID from the array.

**Tool guidance** — find stale references, then patch:
```
Use Grep to find "PAT-XXX" in .nexus/active/registries/patterns-registry.yaml
# For each hit in synergies/conflicts arrays:
Use Edit tool to replace the array with the stale ID removed.
# Example:
#   old_string: 'PAT-029.synergies: ["PAT-042", "PAT-051"]'
#   new_string: 'PAT-029.synergies: ["PAT-051"]'
# If only entry: replace with empty array []
```

**C. Archive the record.** Append the pattern to `.nexus/archived/patterns/retired-registry.yaml`: four annotation lines, then the `# --- PAT-XXX ---` header + the full block captured in A. Then increment `meta.retired_count`.

```
# ─────────── PAT-XXX (RETIRED) ───────────
PAT-XXX.retired_in_sprint: {current_sprint}
PAT-XXX.retired_date: "{YYYY-MM-DD}"          # current date
PAT-XXX.tier: "{tier}"                         # redundant | mediocre | merged | other; "merged" in merge backend mode
PAT-XXX.retired_reason: "{why}"                # in merge mode: "Merged into {merged_into}: {wisdom preserved in keeper}"
# --- PAT-XXX ---
{full PAT-XXX.* block captured in A — name through conflicts, verbatim}
```

If `.nexus/archived/patterns/retired-registry.yaml` does not exist (first-ever retirement), create it with the `meta.*` header before appending (mirror the existing file's preamble; start `meta.retired_count: 0`). Create `.nexus/archived/patterns/` if missing.

**D. Move the PAT file to the archive.**
```
git mv .nexus/patterns/PAT-XXX.md .nexus/archived/patterns/PAT-XXX.md
# (plain mv if the file is not git-tracked; the original `PAT-XXX.file` path is preserved verbatim in the archived block for reversibility)
```

**E. Remove the active registry entry.** All fields use the prefixed format `PAT-XXX.fieldname`, so remove all lines starting with `PAT-XXX.` plus the `# --- PAT-XXX ---` comment header. Use `Edit tool` with multiline matching to remove the entire block (the find-string is the block captured in A). Then decrement `meta.active`.

```
Edit tool(
  filepath=".nexus/active/registries/patterns-registry.yaml",
  patches=[
    {find: "# --- PAT-XXX ---\n...all PAT-XXX.* lines...\n",
     replace: "", multiline: true},
    {find: "meta.active: {old}", replace: "meta.active: {old - 1}"}
  ]
)
```

**F. Verify.** Search the active registry for `PAT-XXX.` → confirm 0 lines remain. Confirm the archived block is present in `retired-registry.yaml` and the PAT file now lives under `.nexus/archived/patterns/`. If the active-registry removal fails, skip this pattern and continue with the next; report the failure. If the move (D) fails after the archive record (C) was written, warn the user — the record exists but the file did not move; suggest manual `mv`.

#### Hard-delete exception

Permanent removal (no archive) only when **justified** — e.g., a pattern created in error with no salvageable wisdom, or an accidental duplicate. Requires explicit rationale (logged in the report / sprint-state). When hard-deleting: run B (clean refs) and E (remove active entry), **skip C and D**, then `Delete .nexus/patterns/PAT-XXX.md`. Default to archive whenever uncertain — archiving costs nothing and is reversible.

---

### STEP 4: Report Results

**User mode:**

```
════════════════════════════════════════════
🗃️ RETIREMENT COMPLETE
════════════════════════════════════════════

Archived: {count} pattern(s)  → .nexus/archived/patterns/
{for each}: ✅ {id} — {name}

{if hard-deleted}: 🗑️ Hard-deleted: {count} (justified)
{for each}: ✅ {id} — {name} — reason: {rationale}

{if failed}:
Failed: {count}
{for each}: ❌ {id} — {reason}

{if learning captured}: 📝 Lessons captured: {count}
{if references cleaned}: 🔗 Cleaned stale references in: {pattern_ids}

Registry: meta.active {old} → {new} | retired-registry meta.retired_count {old} → {new}
🔄 Reversible — restore the PAT file + block from .nexus/archived/patterns/
════════════════════════════════════════════
```

**Backend mode** (return to caller):

```yaml
archived_count: {N}
hard_deleted_count: {N}
failed_count: {N}
successful: ["{PAT-IDs}"]
failed: ["{PAT-IDs}"]
references_cleaned: ["{PAT-IDs where synergies/conflicts were updated}"]
```
