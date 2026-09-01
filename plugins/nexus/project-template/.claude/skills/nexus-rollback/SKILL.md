---
name: nexus-rollback
description: Rollback files to previous versions — git-wrapper for Claude Code (binary deliverables via .nexus/backups/)
disable-model-invocation: true
---
*Version: 2.1.0 | Date: 2026-05-26 | Sprint: 088*

# Rollback

**Flow**: Select workflow → Find version → Preview → [T1: confirm] → Restore → Update registry → Report

Claude Code git-wrapper for file restoration. Text/code files restore from git history (commits, tags); binary deliverables (.docx, .pptx, .jpg, .pdf, etc.) restore from `.nexus/backups/` timestamped copies. Five workflows differ by scope and risk.

---

### STEP 0: Load Context and Select Workflow

**A — Verify restore sources.** Confirm git history exists: `git log --oneline -1 -- .nexus/`. If no commits: warn user — Workflows 1-4 unavailable. Check `.nexus/backups/` exists for binary restore capability (Workflow 5).

**B — Load changelog registry** (memory-first): Read `.nexus/active/registries/changelog-registry.yaml`. Extract current_versions and snapshots. If missing: Workflows 1, 3, 4 are limited. Only Quick Undo (Workflow 2) works without the registry.

**C — Select workflow.** If the user's command clearly maps to a workflow, proceed directly. Otherwise present via AskUserQuestion:

| Workflow | Trigger | Risk |
|----------|---------|------|
| 1. Version Rollback | "rollback {file} to version {X.Y.Z}" | Medium — single file |
| 2. Quick Undo | "undo last change to {file}" | Low — single file, recent |
| 3. Checkpoint Rollback | "restore to checkpoint Conv {N}" or "restore to sprint {NNN}" | **Critical** — all .nexus/ files |
| 4. Known Good State | "rollback to known good" or "last sprint close" | Variable |
| 5. Binary Restore | "restore {file}.docx" or "undo deliverable" | Low — single binary file |

> **Mental note**: Workflow: {selected}. If checkpoint → save to continue_with.

---

### Workflow 1: Single File Version Rollback

Restore a specific file to a specific semantic version.

1. Search changelog-registry snapshots for target version → note snapshot date/sprint.
2. `git log --all --oneline -- {filepath}` → match commit closest to snapshot date.
3. Preview: `git diff {commit} -- {filepath}` → display diff.
4. **[T1: all levels ask]** "Proceed with rollback? [Y/n]"
5. `git checkout {commit} -- {filepath}`. Verify by reading file. Fallback: `git show {commit}:{filepath} > {filepath}`.
6. Update changelog-registry current_versions. Report.

---

### Workflow 2: Quick Undo

Undo a recent change — most common rollback scenario.

1. `git log --oneline -10 -- {filepath}` → display commits with hash, date, message.
2. User selects commit. Preview: `git diff {commit} -- {filepath}`.
3. **[T1: all levels ask]** "Undo to this version? [Y/n]"
4. `git checkout {commit} -- {filepath}`. Verify.
5. Read restored file header for version. Update changelog-registry. If unparseable: mark "UNKNOWN-{commit}", recommend `/nexus-changelog-scan`.

---

### Workflow 3: Checkpoint Rollback

Restore `.nexus/` to a checkpoint or sprint baseline. **Critical** — all changes after that point will be lost.

1. Search git for checkpoint commits:
   ```bash
   git log --oneline --grep="nexus:" -- .nexus/
   ```
   Filter by user's target (sprint number, conversation, date). Display matches.

2. Analyze impact:
   ```bash
   git diff {commit} --stat -- .nexus/
   ```
   Display: checkpoint info, files changed count, affected files list.
   **⚠️ "All changes after this checkpoint will be lost."**

3. **[T1: all levels ask]** Strong confirmation: "Type 'ROLLBACK {commit_short}' to confirm." Must match exactly. Mismatch cancels.

4. Batch restore:
   ```bash
   git checkout {commit} -- .nexus/
   ```
   Verify key files (sprint-state.md, issues-registry.yaml) readable.

5. Reload changelog-registry from restored state. Verify system can bootstrap. If issues: recommend `/nexus-health-diagnostic`.

6. Report: checkpoint restored, files affected, verification status.

---

### Workflow 4: Known Good State

Find and restore from sprint closure commits (stable baselines).

1. List stable points via sprint tags:
   ```bash
   git tag -l "sprint-*" --sort=-version:refname
   ```
   Display each with `git log -1 --format="%ai %s" {tag}`.
   If no tags: fall back to `git log --oneline --grep="sprint-close:" -- .nexus/`.

2. **[T1: all levels ask]** Choose scope via AskUserQuestion:
   - Single file from stable baseline → continues as Workflow 1
   - Full checkpoint restore → continues as Workflow 3

**Sprint-tag dependency**: sprint-tag creation happens at `/nexus-close-sprint` (Sprint closure pipeline). This workflow consumes those tags — if `/nexus-close-sprint` tagging is skipped or removed, Workflow 4 degrades to the `git log --grep="sprint-close:"` fallback.

---

### Workflow 5: Binary Restore

Restore a binary deliverable from `.nexus/backups/`.

1. List available backups for the target file:
   ```bash
   ls -la .nexus/backups/{filename_pattern}*
   ```
   Display each with date, size. If none: "No backups found for this file."

2. User selects version. If the file is small enough to compare sizes, show:
   ```
   Current: {size} | Selected backup: {size} | Date: {backup_date}
   ```

3. **[T1: all levels ask]** "Restore {filename} from backup dated {date}? Current version will be backed up first. [Y/n]"

4. Backup current version first (safety):
   ```bash
   cp "{filepath}" ".nexus/backups/{name}-{timestamp}.{ext}"
   ```
   Then restore:
   ```bash
   cp ".nexus/backups/{selected_backup}" "{filepath}"
   ```
   Verify file exists and size matches backup.

5. Report: file restored, previous version backed up, backup count for this file.

---

## Gate Reference

| Gate | Workflow | Tier | Rationale |
|---|---|---|---|
| Single file restore confirm | 1, 2, 5 | **T1** | File content changes — could break things |
| Checkpoint restore confirm | 3 | **T1** | Destructive — loses all changes after checkpoint |
| Known good scope choice | 4 | **T1** | Determines scope of restore |

All rollback actions are T1 — restoring files always carries risk of losing current state.

---

## Error Recovery

| Problem | Recovery |
|---------|----------|
| Git not available | Cannot use Workflows 1-4. Only Workflow 5 (`.nexus/backups/`) available. |
| No commits for target file | File was never committed. Cannot rollback via git. |
| No backups for binary file | File was never backed up. Cannot restore. |
| Changelog registry missing | Only Quick Undo available (direct git). Recommend `/nexus-changelog-scan`. |
| Git restore fails | Try `git show {commit}:{filepath} > {filepath}`. If that fails: manual copy. |
| Binary restore fails | Check permissions. Try with absolute paths. |
| Batch restore partially fails | `git checkout` is atomic — shouldn't happen. If it does: `git status` to check state. |
| Version unknown after undo | Read file header. If unparseable: mark UNKNOWN, recommend `/nexus-changelog-scan`. |
