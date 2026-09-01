---
name: nexus-archive-issue
description: Archive closed issues — move to archived/issues/ and clean registry
disable-model-invocation: true
---
*Version: 2.0.1 | Date: 2026-06-15 | Sprint: 104*

# Archive Issue

**Flow**: Detect mode → Load context → Validate targets → Cascade check → [T1: confirm] → Move file → Remove from registry → Verify → Report

Archive closed issues by moving to `archived/issues/` with slug-based filename and cleaning registry entry. Supports single, scan (all closed), and backend (from close-sprint) modes.

---

### STEP 0: Detect Mode & Load Context

**Mode detection:**

| Signal | Mode | Load Strategy |
|---|---|---|
| Specific ISS-XXX in request | Single | Grep for 7 fields (~0.3KB) |
| General "archive closed issues" or menu selection | Scan | Full registry load |
| Called by /nexus-close-sprint with issue list | Backend | Memory check first, full registry if needed |
**Single mode load**: Search registry for `ISS-{XXX}.(status|analyzed|implemented|evaluated|title|blocks|blocked_by):` — extract 7 field values. If not found: "❌ ISS-{XXX} not found in registry." Exit. The `blocks` field is needed to identify issues that may become unblocked after archival.

**Scan mode load**: Load full issues-registry.yaml. Needed to find all closed issues.

**Backend mode load**: Registry likely cached from close-sprint. Check memory first.

---

### STEP 1: Identify & Validate Targets

**Identify targets:**
- Single mode: the specified ISS-XXX
- Scan mode: all issues with status IN [Resolved, Rejected, Superseded, Decomposed]
- Backend mode: issues from caller context

If scan finds no closed issues: "ℹ️ No closed issues to archive." Exit.

**Validate each target:**

| Status | Score Requirement | Rationale |
|---|---|---|
| Resolved | A ≥ 4 AND I ≥ 4 AND E ≥ 4 | Completed work must be fully done |
| Rejected | Any scores OK | Explicitly abandoned |
| Superseded | Any scores OK | Replaced by another issue |
| Decomposed | Any scores OK | Split into focused sub-issues |
| Open / In-Progress | ❌ Cannot archive | Must be closed first |

Store each target as valid or invalid with reason (wrong status or incomplete scores).

**Generate archive filename** for each valid target:

Format: `ISS-XXX-{slug}.md` where slug is extracted from the title — first 4-5 words, lowercase, special characters removed, spaces replaced with hyphens, max 40 characters.

Example: title "System Consolidation & Optimization" → `ISS-091-system-consolidation-optimization.md`

**Cascade check**: For each target, check two directions:

1. **Dependents that reference this issue**: Search registry for any active issue with ISS-{XXX} in its `blocked_by` array. These issues may become unblocked after archival — offer to clean up their `blocked_by` references.

2. **Issues this target blocks**: Read the target's `blocks` field. For each listed issue, check if it's still active and still has ISS-{XXX} in `blocked_by`. Same cleanup applies.

If stale references found:

```
⚠️ ISS-{XXX} is referenced in dependency chains:

Blocked by ISS-{XXX} (may now be unblocked):
• ISS-{YYY}.blocked_by includes ISS-{XXX}

1. Clean up references and archive (recommended)
2. Archive without cleanup (references become stale)
3. Skip this issue

Choice:
```

If "clean up": patch each referencing issue's `blocked_by` array to remove ISS-{XXX}, then proceed with archival.

---

### STEP 2: Preview & Confirm

*Backend mode skips this step.*

**Single mode:**

If valid:
```
📦 Archive ISS-{XXX}?

Title: {title}
Status: {status} | Scores: A:{a} I:{i} E:{e} ✓

Will move to: archived/issues/ISS-{XXX}-{slug}.md

Proceed? [Y/n]
```

**[T1: all levels ask]**

If invalid (wrong status): Offer close-issue first, override to Resolved (skip closure), override to Rejected, or cancel.

If invalid (incomplete scores): Offer to complete phases first, change status to Rejected, or cancel.

**Scan mode:**

```
📦 Archivable Issues

VALID ({valid_count}):
{for each: [x] {n}. ISS-{XXX} {status} A:{a} I:{i} E:{e} ✓}

{if invalid_count > 0:}
INVALID ({invalid_count}):
{for each: [ ] {n}. ISS-{XXX} {status} A:{a} I:{i} E:{e} ⚠️ {reason}}
```

**[T1: all levels ask]** Use `AskUserQuestion tool`: Archive all valid / Select specific / Cancel.

**Handling invalid issues in single mode:**

If status is wrong (Open/In-Progress):
1. `invoke /nexus-close-issue` (proper closure with knowledge capture) → re-validate on return
2. Override to Resolved (skip closure — warn "no knowledge capture") → re-validate scores
3. Override to Rejected → proceed (any scores OK)
4. Cancel

If scores incomplete (Resolved but scores < 4):
1. Complete remaining phases first → exit
2. Change status to Rejected → proceed
3. Cancel

---

### STEP 3: Execute (Per Issue)

For each validated target, execute in sequence:

**A. Move file**

```
Move .nexus/issues/ISS-{XXX}.md → .nexus/archived/issues/ISS-{XXX}-{slug}.md
(Bash: mv for Claude Code. Ensure archived/issues/ directory exists.)
```

On failure: add to failed list, continue to next issue.

**B. Remove from registry**

Since the entry's field values are already loaded, construct the exact block text (comment header + all 18 prefixed fields + trailing blank line) and remove it with a single multiline patch:

```
Edit tool(
  filepath: "issues-registry.yaml",
  patches: [{
    find: "# --- ISS-{XXX} ---\nISS-{XXX}.title: ...\n...ISS-{XXX}.notes: \"...\"\n",
    replace: "",
    multiline: true
  }]
)
```

The v7.0.0 prefixed format makes the block globally unique — no risk of matching the wrong entry. Construct the `find` text from the actual loaded field values (exact quotes, exact spacing). Include the trailing blank line if present so no orphaned whitespace remains.

Then decrement total_active:

```
Edit tool(
  filepath: "issues-registry.yaml",
  patches: [{ find: "total_active: {n}", replace: "total_active: {n-1}" }]
)
```

On failure: add to warning list (file moved but registry needs manual cleanup). Continue to next issue.

**C. Verify**

- Check destination file exists: `Read tool(".nexus/archived/issues/ISS-{XXX}-{slug}.md")`
- Check registry entry removed: search for `ISS-{XXX}.title:` — expect no match

Add to success list if both pass, warning list if any fail.

---

### STEP 4: Report

**Single mode:**

```
✅ Archived: ISS-{XXX}-{slug}.md
```

Or warning/failure message if issues occurred.

**Scan mode:**

```
✅ Archived: {success_count}/{total_count} issues

{for each success: • ISS-{XXX}-{slug}.md}

{if warnings: "⚠️ Warnings:" + list}
{if failures: "❌ Failed:" + list with reasons}

Registry: {old_count} → {new_count} active
```

**Backend mode return:**

```
{ status: "complete", archived: [...], warnings: [...], failed: [...] }
```
