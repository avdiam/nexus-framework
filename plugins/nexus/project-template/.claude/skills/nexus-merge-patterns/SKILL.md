---
name: nexus-merge-patterns
description: Find and merge overlapping or similar patterns
disable-model-invocation: true
---
*Version: 2.1.0 | Date: 2026-08-20 | Sprint: 110*

# Merge Patterns

**Flow**: Load registry → Similarity analysis → Deep comparison → [T1: approve] → Enhance keeper → Archive merged → Report

Find and merge overlapping or similar patterns. Preserves wisdom by enhancing the keeper.

---

**Critical rule**: Principle-type patterns are NEVER merged.


### STEP 0: Mode Detection & Load Registry

**Mode detection:**

- **Backend mode**: Called from pattern-maintenance with a candidate pair (`id_a`, `id_b`). Caller identified the pair from registry metadata; no keeper decided yet. Skip STEP 1 — proceed to STEP 2 for deep analysis. All remaining steps (presentation, user decision, execution) run normally.
- **User interactive**: User typed "merge patterns" or similar. Full interactive flow — find pairs, analyze, present, execute.

`Read .nexus/active/registries/patterns-registry.yaml` (memory-first). Extract all active patterns except principles (never merge principles). If fewer than 2 non-principle patterns exist, inform user and return — no merge possible.

---

### STEP 1: Find Similar Pairs

Compare patterns across the registry to find merge candidates. For each unique pair of non-principle patterns, assess similarity using semantic judgment.

**What to compare:**
- `description`: Do they describe the same core concept or approach?
- `use_when`: Do they apply in overlapping situations?
- `domain`: Same or closely related domains?
- `type`: Same type suggests higher overlap potential.

**How to judge**: Ask yourself for each pair — do these patterns solve the same problem class with a similar approach? Could one absorb the other's wisdom without losing its own identity? Surface-level word overlap isn't enough — two patterns might use different terminology but address the same underlying concern.

**Reach a conclusion** for each pair:
- Below ~50% similar: too different, keep separate.
- 50-70%: moderate overlap, merge candidate.
- Above 70%: strong overlap, likely should merge.

Collect pairs above threshold. If none found, inform the user — patterns are sufficiently distinct, system is healthy. Return.

---

### STEP 2: Deep Analysis

For each candidate pair (or the single `candidate_pair` handed over by `/nexus-pattern-maintenance` in backend mode), load both PAT files: `Read .nexus/patterns/PAT-XXX.md` (memory-first) for each.

**Read both patterns fully.** Understand each pattern's problem class, solution approach, rationale, implementation guidance, examples, and anti-patterns.

**Determine the keeper.** Consider:
- **Effectiveness and usage**: Higher effectiveness with more applications suggests a more battle-tested pattern.
- **Maturity**: Established or proven patterns have earned their status.
- **Content quality**: Which has clearer problem framing, more actionable guidance, better rationale, more useful examples?
- **Unique wisdom**: What does each pattern have that the other lacks? Even a "weaker" pattern may contain insights, examples, anti-patterns, or context scenarios worth preserving.

The keeper is the pattern that provides a stronger foundation. The merge-from pattern contributes its unique wisdom to enhance the keeper.

**Identify what to merge**: List the specific content from the merge-from pattern that would enhance the keeper — additional use_when scenarios, rationale insights, anti-patterns, examples, implementation variations. If the merge-from has nothing unique to contribute (pure duplicate), note that — the merge is just a deletion.

**Confirm merge value**: If both patterns are strong with distinct perspectives that would lose nuance by combining, recommend keeping both separate. Not every similar pair should merge.

---

### STEP 3: Present Recommendation & Decide

**Backend mode**: Runs the same as interactive — user must approve the merge and keeper selection.

**User interactive**: For each candidate pair, present the analysis:

```
════════════════════════════════════════════
📐 MERGE CANDIDATE {N}
════════════════════════════════════════════

Similarity: {assessment}

PAT-{A}: {name_a}
  Effectiveness: {eff}% | Maturity: {level} | Applications: {total}

PAT-{B}: {name_b}
  Effectiveness: {eff}% | Maturity: {level} | Applications: {total}

Recommendation: Keep PAT-{keeper}, merge from PAT-{merge_from}

Keeper strengths: {brief}
Wisdom to preserve from PAT-{merge_from}: {brief list}

{if recommend keeping both}: ℹ️ Both patterns have distinct value — recommend keeping separate.
════════════════════════════════════════════
```

**[T1: all levels ask]** Offer via `AskUserQuestion tool`: "Merge (enhance {keeper}, delete {merge_from})" / "Swap keeper" / "Keep both" / "Cancel."

- **Merge**: Proceed to STEP 4.
- **Swap**: Reverse keeper and merge-from, proceed to STEP 4.
- **Keep both**: Skip this pair, continue to next candidate.
- **Cancel**: Exit operation.

If user wants to view full pattern files before deciding, display them and re-present the choice.

---

### STEP 4: Execute Merge

**A. Confirm action.** **[T1: all levels ask]** Display what will happen: PAT-{keeper} will be enhanced with specific additions, PAT-{merge_from} will be deleted. Ask for final confirmation. (In both modes — user approval is always required before destructive operations.)

**B. Enhance keeper.** Patch the keeper's PAT file to incorporate the unique wisdom from merge-from. Depending on what needs adding:

- Solution section: additional guidance or variations
- Context: additional use_when or not_when scenarios
- Examples: additional before/after or application examples
- Anti-Patterns: additional mistakes to avoid
- Rationale: additional insights
- Relationships: add "Supersedes: PAT-{merge_from}"
- Evolution: add version note "v{X}: Merged wisdom from PAT-{merge_from} (Sprint {N})"

If the enhancements are complex, present the proposed additions to the user for review before patching. For simple additions, proceed with user's initial approval.

Verify the keeper file after patching.

**Registry sync**: After enhancing the keeper's PAT file, sync the registry to reflect the broader scope:
- If new `use_when` scenarios were added to the keeper's Context section, update the registry `use_when` array to include the new matching triggers.
- If the keeper's problem scope broadened (absorbed a related problem class), revise the registry `description` to reflect the combined scope — follow the pattern-specification description guidance (action verb + core principle + benefit, 1-3 sentences).
The registry is what match-pattern scans — stale registry = missed matches.

**C. Absorb usage statistics.** Transfer merge-from's usage data to the keeper's registry entry:

1. **Successes/failures/neutral**: Add merge-from's counts to keeper's counts — all three counters
2. **by_issue_type**: Merge entries — sum counts for shared issue types, add new types
3. **Effectiveness**: Recompute from the combined `successes`/`failures` with the pattern-specification.md Effectiveness Formula (`neutral` excluded) — never hand-set or qualitatively adjusted; a stored value that disagrees with the formula is exactly the drift `/nexus-registry-cleanup` flags
4. **last_used**: Use the more recent date of the two patterns
5. **Synergies**: Add any of merge-from's synergies not already in keeper's list (excluding the merge-from's own ID and the keeper's own ID)

Verify after patching: search registry for keeper ID and confirm stats reflect combined data.

**D. Retire merge-from.** Invoke `/nexus-delete-pattern` with `reason='merged'` and `merged_into=PAT-{keeper}`. delete-pattern archives the merge-from (registry removal, file move → `.nexus/archived/patterns/`, full block recorded in `retired-registry.yaml` with tier `merged`, stale reference cleanup) — reversible, not a hard-delete.

**Critical**: Never call delete before the keeper enhancement succeeds. If the enhance step fails, abort the merge — do NOT delete merge-from. Both patterns remain unchanged.

**E. Report per-pair result:**

```
════════════════════════════════════════════
✅ MERGE COMPLETE
════════════════════════════════════════════

Kept: PAT-{keeper} ({name})
Merged from: PAT-{merge_from} ({name})

Enhancements added:
• {enhancement_1}
• {enhancement_2}

Registry: Updated (1 pattern archived → .nexus/archived/patterns/)
════════════════════════════════════════════
```

If more candidate pairs remain, offer to continue or stop.

---

### STEP 5: Session Summary

After all pairs are processed (or user stops early):

**Backend mode**: Return results to caller: `{status, keeper_id, merge_from_id, enhancements_added, success: true/false}`.

**User interactive**:

```
════════════════════════════════════════════
📐 MERGE SESSION SUMMARY
════════════════════════════════════════════

Patterns analyzed: {count}
Merge candidates found: {pairs_count}
Merges executed: {merged_count}
Patterns archived: {archived_count}
Kept separate: {kept_count}

{for each merge}:
• PAT-{merge_from} → merged into PAT-{keeper}

════════════════════════════════════════════
```
