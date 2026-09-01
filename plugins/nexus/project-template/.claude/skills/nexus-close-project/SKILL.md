---
name: nexus-close-project
description: Archive a completed project with final documentation
disable-model-invocation: true
---
*Version: 2.4.0 | Date: 2026-08-28 | Sprint: 112*

# Close Project

**Flow**: `Load → Validate completion → [T1: Confirm closure + dispositions] → Generate summary → Extract patterns → [T1: Archive files] → Clean up → Report`

This operation formally closes a project — validates completion, dispositions open issues, generates a self-contained archive, extracts project-level patterns, and cleans up active state so the framework is ready for the next project.

The archive must be a complete, self-contained project record. Someone reading only the archive should understand what the project was, what happened, and what was achieved.

**Scope**: This operation archives and removes project files. It does NOT modify project parameters (use /nexus-setup-project Update Mode) or update progress (use /nexus-update-state).

**Critical safety rule**: Never clean up active files without a verified complete archive. Partial archive + cleanup = data loss.

---

### STEP 0: Load Context

Silent. Load if not in memory:
- `Read .nexus/active/states/project-state.md` — phases, deliverables, progress, decisions
- `Read .nexus/active/registries/issues-registry.yaml` — issue statuses and stats
- `Read .nexus/memory/sprints_summaries.jsonl` — **complete** sprint timeline + milestones, one record per sprint from 001 onward (CLAUDE.md [Section: Memory-Layer]). This is the single source for cross-sprint history; the former `work-history.md` was backfilled into it and retired to `.nexus/archived/states/` in Sprint 107.

If project-state or issues-registry not found, abort — cannot close without them. If `sprints_summaries.jsonl` is not found, warn that the summary will be incomplete but proceed.

---

### STEP 1: Validate Completion & Confirm Intent

Check each phase in `[PROJECT_PHASES]` for completion percentage. Check issues-registry for open issues (status not Resolved; archived issues have already left the registry).

```
📊 PROJECT CLOSURE VALIDATION
════════════════════════════════════════

Project: {title}

Phase Completion:
• {phase_name}: {completion}% {✅ if 100% | ⚠️ if <100%}
...

MVP Deliverables:
• {name}: {status based on issue_refs resolution}
...

Open Issues: {count}
{for each}: • ISS-{XXX}: {title} ({status})
════════════════════════════════════════
```
**If all phases 100%**: "All phases complete — project ready for closure. Proceed? [Y/n]"

**If phases incomplete**: "Incomplete phases detected. Close anyway and document incomplete phases, or cancel and continue working?" Use `AskUserQuestion tool` widget: Close anyway / Cancel.

**If open issues exist**: Each needs a disposition before proceeding. Present options per issue:

```
{count} open issues need disposition:

{for each}:
  ISS-{XXX}: {title}
  → Archive | Reject | Export for future use
```
Use `AskUserQuestion tool` or collect dispositions conversationally.
- **Archive**: moves to archive with the rest of the project
- **Reject**: call /nexus-close-issue in batch mode with status=Rejected
- **Export for future use**: copy ISS file + registry snippet to user-chosen folder. Issue is archived with the rest — the export is a portable copy.

**[T1: all levels ask]** Cannot proceed without explicit user confirmation of closure intent and dispositions for all open issues.

---

### STEP 2: Generate Project Summary

Gather data from all loaded sources and write a self-contained summary to the archive.

Derive the archive folder name from the project title: lowercase, hyphens for spaces, no special characters. Example: "My Project — Intelligent Collaborative Assistant" → `my-project`.

Create the archive directory: `.nexus/archived/projects/{name}/`

If the directory already exists (from a previous failed closure attempt), warn the user: "Archive directory already exists — likely from an interrupted closure. Overwrite it, or cancel and investigate?" Wait for confirmation before proceeding.

Write summary to `.nexus/archived/projects/{name}/{name}-summary.md`:

```markdown
# Project Summary: {title}
*Closed: {date} | Sprint: {sprint}*

## Vision
{vision from PROJECT_DEFINITION}

## Key Statistics
- Duration: {first_sprint_date} to {closure_date}
- Total Sprints: {count from sprints_summaries.jsonl}
- Issues: {created} created, {resolved} resolved, {remaining} remaining

## Phases
{for each phase:}
### {phase_name}
- Objective: {objective}
- Status: {status} ({completion}%)
- Sprints: {sprint_list}

## Deliverables
{deliverable status summary — which delivered, which incomplete}

## Critical Decisions
{top decisions from [CRITICAL_DECISIONS], categorized}

## Milestones
{from MILESTONE_TRACKING and sprints_summaries.jsonl}
```
Verify the summary file was written.

---

### STEP 3: Extract Project-Level Patterns (Optional)

Look across the project's history for reusable wisdom — recurring approaches that worked, architectural decisions with proven value, process improvements that emerged, mistakes that recurred until addressed.

Sources: critical decisions from project-state, sprint achievements from sprint history (`sprints_summaries.jsonl`), pattern usage from patterns-registry.

If candidates found, present them:

```
🔍 PROJECT PATTERN CANDIDATES
════════════════════════════════════════
{for each}:
{N}. {description}
    Source: {where observed}
    Value: {why it matters}
════════════════════════════════════════
```
Create patterns? [Select numbers / All / Skip]
If patterns selected: call /nexus-create-pattern for each (these are framework-level — they stay in active patterns-registry, not archived). Note: pattern creation is token-intensive; if context is tight, suggest creating them in the next conversation.

If skip or defer: append the candidate list to the summary file so they're preserved in the archive for future reference. Existing patterns remain active for future projects.

---

### STEP 4: Archive Project Files

Create the archive structure and move all project files.

**A. Patch sprint-state lifecycle BEFORE moving** — this ensures the archived copy reflects closed state:

Patch `_project_lifecycle: closed` in sprint-state.md at its current active location.

**Archive structure:**
```
.nexus/archived/projects/{name}/
├── {name}-summary.md          (written in STEP 2)
├── states/
│   ├── project-state.md
│   ├── sprint-state.md
│   └── sprint-queue.md
├── registries/
│   └── issues-registry.yaml
├── issues/
│   └── ISS-XXX.md ...         (all except 'move to next project')
├── memory/
│   └── *.jsonl + SCHEMA.md    (project's cross-sprint memory layer)
└── sprints/
    └── {NNN}/ ...             (all sprint folders)
```
Use `mkdir -p` for directories, `mv` for file moves, `cp` for copies. Verify with `ls`.

Process:

1. Create all archive subdirectories
2. Move state files (project-state, sprint-state, sprint-queue)
3. If any issues were dispositioned as "export for future use": ask user for export folder path. Copy those ISS files + their registry entries (as a standalone YAML snippet) to the user's chosen folder. The user can feed these into a future project's setup if desired — no automatic carry-over mechanism needed.
4. Move issues-registry.yaml
5. Move ALL ISS files (including exported ones — they were copied, not moved)
6. Move sprint folders from `.nexus/Sprints/`
7. Move `.nexus/memory/` (all `*.jsonl` + `SCHEMA.md`) → archive `memory/` — project-specific cross-sprint knowledge; archived with the project, never carried into the next (a fresh project scaffolds its own via init-project). If `.nexus/memory/` is absent (older project), skip.
8. Execute open issue rejections from STEP 1 dispositions (invoke /nexus-close-issue batch)

**What stays active** (framework files — NOT project-specific):
- Framework: CLAUDE.md (project root)
- Supporting: .nexus/active/ (Emergency-Reference.md)
- Skills: .claude/skills/nexus-*/ (all methodology, operation, and cognitive tool skills)
- Templates: all `templates/` files
- Framework registries: patterns-registry.yaml, changelog-registry.yaml, documentation-registry.yaml
- System knowledge: system-state.md (accumulated wisdom transcends projects)

**[T1: all levels ask]** Verify archive is complete before proceeding to cleanup. List each archive subdirectory and confirm expected file counts. If any move failed, stop — do NOT clean up active with an incomplete archive.

---

### STEP 5: Clean Up Active & Record Closure

After verified archive:

- Active state files are already moved (not deleted — move_file handles this)
- Confirm `.nexus/issues/` contains only "move to next project" issues (or is empty)
- Confirm `.nexus/Sprints/` is empty

`UPDATE: system-state.md#[Section: Project-Status]` — patch to closed state:

```yaml
status: "closed"
status_changed: "{ISO_timestamp}"
closure_sprint: {sprint_number}
archive_location: ".nexus/archived/projects/{name}/"
```
Do NOT create fresh state files — `/nexus-init-project` (first-run) re-creates them from templates when the user starts a new project, then hands off to `/nexus-setup-project`. (`setup-project` alone cannot re-seed the moved sprint-state/sprint-queue.)

---

### STEP 6: Completion Report

```
✅ PROJECT CLOSED
════════════════════════════════════════

Project: {title}
Closed: {date} | Sprint: {sprint}

📊 FINAL STATISTICS:
• Phases: {total} ({complete} complete, {incomplete} incomplete)
• Sprints: {total} executed
• Duration: {first_date} → {closure_date}
• Issues: {created} created, {resolved} resolved, {remaining} remaining
• Patterns extracted: {count}

📦 ARCHIVE:
→ .nexus/archived/projects/{name}/
  {file_count} files archived

🔄 FRAMEWORK STATUS:
• Core files: Active ✓
• Operations: Active ✓
• Patterns: Active ✓ (carry forward)
• System knowledge: Active ✓

💡 NEXT:
Use 'init project' to start the next project IN THIS INSTALLATION (first-run re-creates the state files, then the setup-project wizard runs).
To install NEXUS into a DIFFERENT folder, run /nexus:setup there instead.
════════════════════════════════════════
```

---

## Gate Reference

| Gate | Step | Tier | Full | Balanced | Streamlined |
|---|---|---|---|---|---|
| Closure confirmation + dispositions | 1 | **T1** | Ask + consequences | Ask + consequences | Ask + consequences |
| Archive verification | 4 | **T1** | Verify before cleanup | Verify before cleanup | Verify before cleanup |

---

## End-of-Workflow Checklist

- [ ] All open issues dispositioned (archived / rejected / moved)
- [ ] Summary document written and verified
- [ ] All project files moved to archive
- [ ] Carried-over issues (if any) preserved in active `.nexus/issues/`
- [ ] sprint-state `_project_lifecycle: closed`
- [ ] system-state project status updated
- [ ] Active state files removed (via move, not delete)
- [ ] Archive verified complete BEFORE any cleanup

---

## Error Recovery

| Problem | Recovery |
|---|---|
| project-state or registry not found | Abort — cannot close without them. |
| Archive directory already exists | Previous failed attempt. Offer overwrite or investigate. |
| File move fails mid-archive | Stop. Do NOT clean up. Report which files moved, which didn't. User can retry. |
| Incomplete archive detected at verification | Do NOT proceed to cleanup. Report missing files. Offer retry. |
| Pattern creation fails | Candidates preserved in summary file for manual creation later. |
| system-state update fails | Project is archived. Note failure — can be fixed manually. |
