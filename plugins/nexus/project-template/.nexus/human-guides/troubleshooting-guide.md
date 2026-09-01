# NEXUS Troubleshooting Guide
*Version: 2.1.1 | Date: 2026-08-31 | Sprint: 112 | Category: getting-started*

*Common issues and solutions — from installation to daily workflow.*

**Source files:** `CLAUDE.md` v5.16.0, `.claude/skills/nexus-start/SKILL.md` v2.9.2, `.claude/skills/nexus-checkpoint/SKILL.md` v2.5.0, `.nexus/active/Emergency-Reference.md`

---

## How to Use This Guide
[Section: How-To-Use]

Find your problem area below, then look for the specific symptom. Each entry includes: what you see, why it happens, and how to fix it. If your issue isn't listed, say **"help"** in any NEXUS conversation for context-aware assistance.

For how consent gates, context zones, and the framework's architecture actually work, see [The Three Unbreakable Principles](nexus-framework-guide.md#the-three-unbreakable-principles) — this guide fixes problems, that one explains the system.

---

[/Section: How-To-Use]

## Installation & Setup
[Section: Installation-And-Setup]

### NEXUS files not found when you type "start"

**What you see**: Claude can't find `CLAUDE.md` or `sprint-state.md` when you type "start."

**Why**: Claude Code is open on the wrong directory, or the three framework artifacts aren't all at the project root.

**Fix**:
1. Confirm Claude Code is open on the project folder itself, not a parent or subdirectory
2. Verify all three artifacts exist at that root: `CLAUDE.md`, `.claude/`, and `.nexus/`
3. Check specifically for `.nexus/active/states/sprint-state.md`
4. A copy that includes `.nexus/` but not `.claude/` or `CLAUDE.md` is the most common incomplete install — the framework needs all three. (A `.gitignore` also ships with the template; its absence is cosmetic, not a broken install.) For prerequisites and both install routes, see the [Installation Guide](installation-guide.md)

### `/nexus-start` says "sprint-state.md not found"

**What you see**: Boot stops with a warning that `sprint-state.md` is missing.

**Why**: The file is missing from `.nexus/active/states/sprint-state.md` — an incomplete copy, or the file was deleted or moved.

**Fix**:
1. Check whether the file exists at `.nexus/active/states/sprint-state.md`
2. If it exists but boot can't find it, confirm Claude Code is open on the project root
3. If it's genuinely missing: recover it from git — checkpoints commit project-wide, so the last checkpoint commit holds a good copy
4. If there's no git history (fresh install): re-copy the NEXUS framework files. The shipped `sprint-state.md` is pre-configured for first-run detection

### Boot doesn't detect first-run

**What you see**: Instead of the setup wizard, NEXUS tries to load an existing sprint as if you're mid-project.

**Why**: The `_project_lifecycle` field in `sprint-state.md` isn't set to `not-defined`. `/nexus-start` STEP 5 reads that field to decide whether to hand off to `/nexus-init-project`.

**Fix**:
1. Open `.nexus/active/states/sprint-state.md` in a text editor
2. Find the line `_project_lifecycle:` near the top
3. Change its value to `not-defined`
4. Save the file and start a new conversation

### The context percentage reads `—` and never updates

**What you see**: The boot header shows `Context: —` and it stays that way all conversation. No checkpoint prompt arrives at 70% or 80%.

**Why**: The hooks did not register. Claude Code reads `.claude/settings.json` **at launch**, so if `.claude/` arrived during the session — which is exactly what happens when you run `/nexus:setup` — that session has no hooks at all. Token tracking is dead and the automatic checkpoint safety net cannot fire, on what is usually the longest conversation you will have.

**Fix**:
1. Quit Claude Code and relaunch it in the project folder. This is the whole fix on a fresh install — nothing to configure
2. If it persists, you are missing Python 3: run `python3 --version || python --version`. The hooks need 3.x; Python 2 raises `SyntaxError`
3. If Python is fine and the display is still blank, check that `.claude/settings.json` exists and was not replaced by your own config during install

### Protocols seem to be missing, but nothing errors

**What you see**: NEXUS boots and responds, but gates you expect do not fire, sections it cites are not there, and behaviour feels half-present. No error message anywhere.

**Why**: `.claude/settings.local.json` is missing or lacks the read cap, so Claude Code truncated `CLAUDE.md` at roughly 10K tokens and boot loaded a partial harness. This is the most confusing failure a new install can have precisely because it is silent.

**Fix**: Create `.claude/settings.local.json` with:

```json
{
  "env": {
    "CLAUDE_CODE_FILE_READ_MAX_OUTPUT_TOKENS": "50000"
  }
}
```

If the file already exists, add the `env` key rather than replacing it. The file is git-ignored on purpose — it is per machine and per clone, so **every fresh clone needs it written again**, and it never travels with a repository. The plugin route's `/nexus:setup` writes it for you; the clone route does not.

### A staleness warning about the changelog registry on first boot

**What you see**: The `⚠` line reports the changelog registry is older than ~108 framework files, on an installation you just made.

**Why**: A directory copy stamps files in walk order, and `.nexus/active/registries/` lands before `.claude/skills/`. The warning is manufactured entirely by the copy — nothing is actually stale. The first checkpoint does not clear it.

**Fix**:

```bash
touch .nexus/active/registries/changelog-registry.yaml
```

`/nexus:setup` does this for you; the clone route needs it run by hand.

### `/nexus:setup` refuses to run

**What you see**: The installer stops and tells you NEXUS is already present.

**Why**: It found `.nexus/` in the target folder. That is the guard working — copying over a live install destroys sprint state, issues and patterns, and there is no undo.

**Fix**: Use `/nexus:upgrade`, which compares your installation against the plugin's current copy and reports what differs. If the folder really is disposable, remove `.nexus/` yourself and re-run setup.

### Verifying your installation is healthy

**What you see**: Everything seems to work, but you want to confirm NEXUS is fully operational.

**Fix**: Say **"system health status"** — NEXUS runs a diagnostic across all subsystems (state files, registries, patterns, maintenance status) and reports what's healthy, what's degraded, and what needs attention. Worth running after initial setup, after recovering from any issue, or whenever something feels off.

### Setup wizard was interrupted

**What you see**: You started project setup but the conversation ended before the wizard finished.

**Why**: Context ran out, the session was closed, or the conversation was interrupted.

**Fix**: Start a new conversation and type "start." NEXUS detects the partial state and offers to resume where you left off. Every wizard step saves to disk as it completes, so nothing is lost. You'll see something like: *"Your previous session completed through Step 4 (Deliverables). Resume from Step 5, or start fresh?"*

---

[/Section: Installation-And-Setup]

## Context & Checkpoints
[Section: Context-And-Checkpoints]

### "Context feels tight" or running out mid-work

**What you see**: NEXUS prompts for a checkpoint at 70%, saves automatically at 80%, or you feel like there isn't enough room for meaningful work.

**Why**: NEXUS uses a portion of each conversation's context window for management (state files, methodology skills, routing). That's the tradeoff for continuity — some context goes to remembering, the rest goes to working.

**Fix**:
- **Save checkpoints proactively** — say "save checkpoint" before context gets high, especially before loading large files
- **Trust the 80% auto-save** — NEXUS saves automatically and the next conversation picks up seamlessly. Running out of context is normal, not a failure. Saving does not mean stopping: work continues at full rigor after a checkpoint
- **Trim `files_to_load`** — review it in `sprint-state.md`. Are all the listed files really needed for the next conversation? Fewer files means a faster, lighter boot
- **Keep work focused** — one issue per conversation when context is tight; avoid loading files you don't need

---

[/Section: Context-And-Checkpoints]

## Working with Issues
[Section: Working-With-Issues]

### "I don't know what to work on next"

**What you see**: You've finished an issue or a phase and aren't sure what comes next.

**Why**: This is normal — especially when transitioning between phases or issues.

**Fix**:
- Say **"sprint status"** to see your current sprint objectives and progress
- Say **"show menu"** to browse all available operations
- Check the `Focus →` line in the startup header — it tells you what NEXUS recommends next
- If all sprint issues are complete, say **"close sprint"** to wrap up and plan the next batch

### Scores don't seem right

**What you see**: Phase scores (A:3 I:1 E:1) don't reflect the work you've done.

**Why**: Scores update after significant work, not after every conversation. If work was done but a checkpoint wasn't saved, scores may lag.

**Fix**:
- Say **"save checkpoint"** to trigger a full state save, which updates scores
- If scores still seem wrong, tell NEXUS: "ISS-XXX analysis score should be 4" — it will update both the registry and sprint state
- Scores are tracked in two places (`issues-registry.yaml` as source of truth, `sprint-state.md` as the mirror) — NEXUS reads both back and verifies they match after every update

### Phase transition didn't happen

**What you see**: You've completed analysis but NEXUS hasn't offered to move to implementation.

**Why**: Phase transitions trigger when scores reach ≥4. If the score hasn't been updated, or if specific criteria are still incomplete, the transition doesn't fire.

**Fix**:
- Tell NEXUS directly: "I'm ready to move to implementation" — it will check readiness and either transition or explain what's missing
- You can override: "Let's implement now" works even if the score is below threshold — NEXUS will warn but proceed
- Check your ISS file — are the Solution Design and Implementation Plan sections populated? These are prerequisites for the implementation phase

### Issue seems stuck or blocked

**What you see**: You can't make progress on your current issue because something else needs to happen first.

**Why**: The issue has dependencies that aren't resolved, or you've hit a technical or design blocker.

**Fix**:
- Tell NEXUS: "I'm blocked on ISS-XXX" — it will check dependencies and offer options
- Say **"work on ISS-YYY"** to switch to a different issue while the blocker is resolved
- If the issue needs to move to a different sprint: say **"move issue ISS-XXX"**

---

[/Section: Working-With-Issues]

## Sprint & Workflow
[Section: Sprint-And-Workflow]

### Sprint feels overloaded

**What you see**: Too many issues, not enough context per conversation, work feels rushed.

**Why**: Sprint complexity may be too high, or issues turned out harder than estimated.

**Fix**:
- Say **"sprint status"** to see current load
- Say **"move issue ISS-XXX"** to defer lower-priority work to the next sprint
- This is normal — NEXUS targets a total complexity around 9 per sprint as guidance, not a rigid rule. Adjusting mid-sprint is healthy, not a failure

### Lost progress after conversation ended

**What you see**: Your new conversation doesn't pick up where you left off — work seems missing.

**Why**: The previous conversation ended without a checkpoint save, so sprint-state still points to the previous stopping point.

**Fix**:
- This is rare if you're in the habit of saying "save checkpoint" before ending
- The automatic 80% save usually catches this, but if a conversation ended abruptly some progress may be lost
- Checkpoints commit to git — say **"rollback"** to see recoverable versions if state looks wrong
- Prevention: save checkpoints proactively, especially after significant work

### "I changed my mind about the approach"

**What you see**: Mid-implementation, you realize the analysis approach was wrong.

**Why**: This happens — implementation reveals problems that analysis couldn't predict.

**Fix**:
- Say **"go back"** or **"loop back to analysis"** — NEXUS has a formal loop-back protocol that preserves your implementation progress and returns to analysis for redesign
- You won't lose implementation work — it's documented in the ISS file and can be referenced when you re-approach

### I want to change project scope or vision after setup

**What you see**: Your project has evolved and the original definition no longer fits.

**Fix**: Say **"update project parameters"** — NEXUS has a dedicated path for modifying vision, scope, deliverables, phases, or constraints after initial setup. Changes propagate to affected sprint planning.

---

[/Section: Sprint-And-Workflow]

## File Operations & Recovery
[Section: File-Operations-And-Recovery]

### Checkpoint save failed

**What you see**: NEXUS reports an error during checkpoint save — a file write or edit failed.

**Why**: A file permission problem, disk space, or a malformed edit target. Rare.

**Fix**:
- NEXUS retries automatically with simpler operations when the first attempt fails
- If it keeps failing, check that the project folder is writable
- As a last resort, NEXUS preserves critical state (`continue_with` and objectives) so the next conversation can resume
- The previous good state stays recoverable from the last checkpoint's git commit
- Full recovery procedures live in `.nexus/active/Emergency-Reference.md`

### Sprint state seems corrupted

**What you see**: Boot shows warnings, sections are missing, or values don't make sense.

**Why**: An interrupted save or a conflicting write. NEXUS detects this at boot.

**Fix**:
1. NEXUS will report the problem in the startup header's `⚠` line and offer recovery
2. Say **"rollback"** to see recoverable versions from git history
3. Select a version from before the corruption
4. NEXUS verifies the restored file and reports any drift from current work

### Accidentally deleted or modified a system file

**What you see**: A NEXUS file is missing or its content has been manually changed in unexpected ways.

**Fix**:
- Say **"rollback file {filename}"** — recovery works from git history, which is why checkpoints commit project-wide
- Binary deliverables have a second safety net: they're copied to `.nexus/backups/` before being overwritten
- For framework files (skills, `CLAUDE.md`): they can be re-copied from the NEXUS distribution
- For state files (`sprint-state.md`, `project-state.md`): git history is essential — these hold your unique project data

---

[/Section: File-Operations-And-Recovery]

## Common Mistakes
[Section: Common-Mistakes]

### Editing NEXUS files manually

**Risk**: Manual edits can break formatting that NEXUS relies on — section markers, YAML structure, score formats.

**Better approach**: Tell NEXUS what you want to change. It modifies files with proper formatting and verification. If you must edit manually, stick to content fields (descriptions, notes) and avoid structural elements (section tags, metadata headers, score fields).

### Ignoring checkpoint prompts

**Risk**: Lost work if the conversation ends unexpectedly.

**Better approach**: When NEXUS suggests saving at 70%, say yes — it takes a few seconds and guarantees continuity. The 80% auto-save is a safety net, not a strategy.

### Starting conversations without "start"

**Risk**: NEXUS doesn't boot, so Claude works without framework context — no continuity, no methodology, no state tracking.

**Better approach**: Always begin with "start". If you forget, just say "start" mid-conversation to trigger the boot sequence.

---

[/Section: Common-Mistakes]

## Exploring & Learning NEXUS
[Section: Exploring-And-Learning]

### Brainstorm mode — think without committing

If you want to explore ideas before (or alongside) committed work, say **"brainstorm"**. Brainstorm is a parallel phase: you can enter it from any phase and exit to any phase, and it does not run the analyze/implement/evaluate lifecycle or sprint operations. Anything you decide to make real still routes through the normal skills under the normal consent gates, so nothing changes behind your back.

### Built-in discovery tools

NEXUS has several commands designed to help you explore the framework at your own pace:

| Command | What it does |
|---------|-------------|
| **"help"** | Context-aware help — NEXUS explains whatever you ask about, adapted to your current situation |
| **"show menu"** | Browse all available operations organized by category (project, sprint, issue, pattern, maintenance, documentation) |
| **"browse docs"** | Lists all available guides and documentation with descriptions — the framework's library catalog |
| **"learning path"** | Personalized reading order based on where you are — tells you what to read next and why |
| **"explain {concept}"** | Plain-language explanation of any NEXUS concept — e.g., "explain sprints", "explain patterns", "explain phases" |
| **"dashboard"** | Visual overview of your project, sprint, issues, or system health |

The **learning path** command is especially useful for newcomers — it assesses what you've done so far and recommends which guides to read in what order, so you're never wondering "what should I learn next?"

---

[/Section: Exploring-And-Learning]

## Going Deeper
[Section: Going-Deeper]

| Guide | What you'll learn |
|-------|-------------------|
| [Installation Guide](installation-guide.md) | Step-by-step setup instructions |
| [First Project Tutorial](first-project-tutorial.md) | Guided walkthrough from setup to first sprint |
| [Quick Start Guide](quick-start-guide.md) | Core concepts and essential commands in 5 minutes |
| [NEXUS Framework Guide](nexus-framework-guide.md) | Complete system reference |

---

[/Section: Going-Deeper]

*Can't find your issue here? Say "help" in any NEXUS conversation — Claude has full context of the framework and can diagnose problems in real time.*
