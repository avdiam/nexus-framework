---
name: nexus-init-project
description: First-run initialization of an existing NEXUS installation — instantiate missing state files and registries from templates, then delegate to setup-project
disable-model-invocation: true
---
*Version: 3.0.0 | Date: 2026-08-28 | Sprint: 112*

# Initialize Project

**Flow**: `Confirm first-run → Validate environment → Instantiate templates → Verify → Handoff`

Initialize NEXUS inside an installation that already carries the framework files: create the state
files and registries that are missing, then hand off to `/nexus-setup-project`.

---

## STEP 0: Confirm First-Run and Load Context

This skill has ONE mode. It runs when `/nexus-start` finds `_project_lifecycle: not-defined`, or
when the user invokes it manually against an installation whose state files are missing.

> ⛔ **Creating a NEXUS installation in a NEW folder is not this skill's job.**
> **Single source of truth: the plugin `setup` skill, invoked `/nexus:setup`** (PAT-113). It copies
> `project-template/` out of the installed plugin, and what ships is declared in one place —
> `.nexus/tools/dist-manifest.txt`. One manifest, one copier.
>
> This skill's former `new-project` mode was a second, drifted copy of that manifest: it omitted
> `.claude/agents/`, `derivations.yaml` and `.nexus/tests/`, copied the raw self-hosting
> `settings.json`, and shipped all 57 patterns instead of the curated set. Retired at ISS-101
> step 3.4 (Sprint 112) rather than repaired, because two copiers is the defect, not one stale
> copier. If a user asks to "create a new project", point them at `/nexus:setup` run inside the
> target folder — do not reconstruct a copier here.

Check which state files and registries already exist under `.nexus/active/states/` and
`.nexus/active/registries/`.

---

## STEP 1: Validate Environment

### A. Git Availability

Check if git is available:

```bash
git --version && git status
```

| Finding | Action |
|---|---|
| git not installed | "Git is recommended for checkpoint backup. Install it?" Options via AskUserQuestion: [Guide me / Skip for now]. If guide: suggest platform-appropriate install command. |
| git installed, no repo | "Initialize git repository?" via AskUserQuestion: [Yes / Skip]. If yes: `git init && git add -A && git commit -m "initial: NEXUS project setup"`. |
| git installed, repo exists | ✅ Proceed. |
| Skip chosen | Warn: "Checkpoints will save to files but git backup/rollback won't work." No state field is written — `/nexus-start` STEP 1E re-detects git every Conv 1 and surfaces it on the startup header. |

### B. Orphan Detection

Check `.nexus/issues/` for existing ISS-*.md files. Do not check `patterns/` — patterns ship pre-populated.

| Finding | Action |
|---|---|
| Empty or doesn't exist | Clean install — proceed. |
| ISS-*.md files found | **[T2: Balanced+Full ask \| Streamlined: notify+log]** "Existing issues found ({N} files). Files will be preserved but won't appear in the fresh registry." Options: [Proceed (files preserved, registry fresh) / Cancel — investigate first]. |

**STOP. Wait for user decision if orphans found.**

### C. State File Inventory

Check which files need creation vs already exist:

**Create from templates if missing:**

| File | Template Source |
|---|---|
| `states/project-state.md` | `project-state-template.md` |
| `states/system-state.md` | `system-state-template.md` |
| `states/sprint-queue.md` | `sprint-queue-template.md` |
| `registries/issues-registry.yaml` | `issues-registry-template.yaml` |

**Shipped with installation (no template needed):**
- `states/sprint-state.md` — shipped with `_project_lifecycle: not-defined`
- `registries/patterns-registry.yaml` — shipped pre-populated
- `registries/changelog-registry.yaml` — shipped with framework entries
- `registries/documentation-registry.yaml` — shipped with doc entries

If any shipped file is unexpectedly missing, create from template if one exists, otherwise report the gap.

**Memory layer scaffolding** (CLAUDE.md [Section: Memory-Layer]): create `.nexus/memory/` with 7 cold-start JSONL files, each containing only its safety-marker line `{"type":"_nexus_memory","source":"nexus-memory-layer","version":"1.0","file":"{name}"}` — for `decisions`, `discoveries`, `work_debt`, `rejected_patterns`, `issues_learnings`, `sprints_summaries`, `sprint_index`. `.nexus/memory/SCHEMA.md` ships with the framework — confirm it is present rather than copying it, and report the gap if it is absent. These are derived caches: they populate going forward from the first close-sprint.

Display: "Initializing — {N} files to create, {M} already exist."

---

## STEP 2: Execute

For each missing file from STEP 1C, read the template and write to the target path. Verify each file was created.

```
✅ Template Instantiation Complete
═══════════════════════════════════
Created: {N} files from templates
Already existed: {M} files (preserved)
Failed: {F} files (if any — list them)
═══════════════════════════════════
```

If any files failed: report which ones and why. The next boot will re-enter init-project (lifecycle stays `not-defined` until STEP 3 updates it) — self-healing by design.

---

## STEP 3: Verification Gate and Handoff

### A. Verify Completeness

⛔ GATE: All required files verified before proceeding.

Verify all files from STEP 1C table exist. Confirm shipped files present (sprint-state.md, patterns-registry.yaml, changelog-registry.yaml, documentation-registry.yaml).

| Result | Action |
|---|---|
| All verified | Proceed to handoff. |
| Any missing | Report which files are missing. Lifecycle stays `not-defined`, so the next boot retries. |

### B. Handoff

1. Patch sprint-state.md: set `_project_lifecycle: defining`
2. Verify the patch applied

```
🚀 NEXUS First-Run Initialization Complete
════════════════════════════════════════════
State files: ✓ Created from templates
Registries: ✓ Ready
Lifecycle: not-defined → defining

Next: Project setup wizard will guide you through
defining your project vision, scope, and first sprint.
════════════════════════════════════════════
```

3. Invoke `/nexus-setup-project` — control transfers permanently. setup-project handles the full wizard, sets lifecycle to `active`, and offers to continue (→ /nexus-generate-mvp → /nexus-organize-sprint).

---

## Gate Reference

| Gate | Step | Tier | Full | Balanced | Streamlined |
|---|---|---|---|---|---|
| Orphan handling | 1B | **T2** | Ask | Ask | Notify+log |
| Verification gate | 3A | ⛔ | Hard gate — must pass | Must pass | Must pass |

---

## Error Recovery

| Problem | Recovery |
|---|---|
| Template file missing | Report which template. Check `.nexus/templates/` for the file. If git available: `git checkout -- .nexus/templates/{file}`. If not: alert user to restore from backup or source. |
| Directory creation fails | Check permissions. On Windows: verify path length < 260 chars. Retry with explicit path. |
| Partial creation interrupted | Safe to re-run — only missing files are created. Lifecycle stays `not-defined` until STEP 3 succeeds. |
| Git init fails | Proceed without git. Warn user about limited backup capability. |
| sprint-state shipped file missing | Create from sprint-state-template.md. Ensure `_project_lifecycle: not-defined` is set. |
