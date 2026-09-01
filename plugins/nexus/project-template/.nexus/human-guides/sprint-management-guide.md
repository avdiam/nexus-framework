# Sprint Management Guide
*Version: 1.2.0 | Date: 2026-08-24 | Sprint: 110 | Category: domain*

*How sprints work in NEXUS — planning, monitoring, closing, and everything in between.*

**Source files:**
- .claude/skills/nexus-organize-sprint/SKILL.md v2.11.0
- .claude/skills/nexus-sprint-status/SKILL.md v2.0.1
- .claude/skills/nexus-close-sprint/SKILL.md v2.10.0
- .claude/skills/nexus-move-issues/SKILL.md v2.1.0
- .claude/skills/nexus-loop-back/SKILL.md v2.0.1
- .nexus/templates/sprint-state-template.md v1.13.0
- .nexus/templates/sprint-queue-template.md v4.0.1
- .claude/skills/nexus-start/SKILL.md v2.9.2
- CLAUDE.md v5.16.0

---

## What Is Sprint Management?
[Section: Introduction]

Sprints are how NEXUS organizes work into focused batches. Each sprint contains 1–3 issues with a combined complexity target of around 9, runs across multiple conversations, and ends with a structured closure that extracts knowledge before archiving.

The sprint lifecycle follows a repeating cycle:

```
organize → work → checkpoint → ... → close → organize (next)
    ↑                                            │
    └────────────────────────────────────────────┘
```

`/nexus-start` handles the transitions automatically. When you start a new conversation, NEXUS detects whether the current sprint is active or closed, and routes you to the right place — either resuming work or planning the next sprint.

This guide covers: how sprints are planned, the three sprint modes, how to monitor progress, how to move issues around, how to go back when something isn't working, and how sprint closure preserves everything you learned.

[/Section: Introduction]

---

## Core Concepts
[Section: Core-Concepts]

### Sprint Modes

Every sprint operates in one of three modes, chosen during planning based on issue relationships:

**THEMED** — Two or three tightly related issues worked in lockstep. All issues go through analysis together before any move to implementation. Best when issues share scope, dependencies, or domain. Example: "ISS-095 path parameterization + ISS-096 starter kit" — one determines the other's structure.

**MIXED** — Two or three independent issues worked sequentially. Each issue completes end-to-end (analysis → implementation → evaluation) before the next begins. Best for diverse work with no strong coupling. Provides variety and risk distribution.

**DEDICATED** — A single complex issue gets the full sprint. Best for complexity 4–5 issues that need sustained focus, or for maintenance sprints.

### Capacity

Sprint capacity targets ~9 complexity points. This isn't a hard limit — it's guidance calibrated from experience:

| Label | Range | Signal |
|-------|-------|--------|
| LIGHT | ≤7 | Room to add more work |
| GOOD | 8–10 | Comfortable |
| HIGH | 11–12 | Acceptable if justified |
| OVERLOADED | 13+ | Recommend rebalancing |

### The Sprint Queue

The sprint queue (`sprint-queue.md`) is a forward-looking plan of upcoming sprints. It contains the active sprint, queued future sprints, a dependency map, and a backlog. The queue is evaluated and refreshed during each `organize sprint` pass — it's a living plan, not a rigid schedule.

### Phase Scores

Each issue tracks progress through three phases using scores from 1 to 5:

| Score | Meaning |
|-------|---------|
| 1 | Not started |
| 2 | Basic progress |
| 3 | Partial completion |
| 4 | Well advanced, ready to proceed |
| 5 | Fully complete |

Displayed as `A:X I:Y E:Z` (Analyzed, Implemented, Evaluated). When a phase score reaches 4, NEXUS prompts you to advance to the next phase.

[/Section: Core-Concepts]

---

## How Sprints Work
[Section: How-It-Works]

### The Sprint Lifecycle

A sprint flows through four stages, each handled by a specific operation:

```
┌─────────────┐     ┌───────────────┐     ┌──────────────┐     ┌─────────────┐
│   ORGANIZE   │────▶│     WORK      │────▶│    CLOSE     │────▶│   ORGANIZE  │
│              │     │               │     │              │     │   (next)    │
│ Plan sprint  │     │ Analyze       │     │ Close issues │     │             │
│ Select issues│     │ Implement     │     │ Extract      │     │             │
│ Choose mode  │     │ Evaluate      │     │  patterns    │     │             │
│ Create state │     │ Checkpoint    │     │ Archive      │     │             │
└─────────────┘     └───────────────┘     │ Transfer     │     └─────────────┘
                          ▲    │          │  experience  │
                          │    ▼          └──────────────┘
                    ┌──────────────┐
                    │  LOOP-BACK   │
                    │ Return to    │
                    │ earlier phase│
                    └──────────────┘
```

### `/nexus-start`: The Automatic Router

You never need to manually call `organize sprint` or figure out where you left off. `/nexus-start` handles this at the start of every conversation:

- **Sprint in progress** (`_status: in_progress`) → Loads sprint-state, increments conversation counter, detects your phase, loads the right methodology, and picks up where you left off via `continue_with`.
- **Sprint ready for closure** (`_status: closing` — set by the checkpoint that follows the last objective completing) → Runs as a dedicated Learning-phase conversation, confirms with you, and invokes `/nexus-close-sprint`.
- **Sprint complete and properly closed** (`_status: complete` with `_closure_time`) → Delegates to organize-sprint to plan the next sprint. Organize-sprint's own full path runs maintenance-scheduler as its first step.
- **Sprint complete but not formally closed** (`_status: complete`, no `_closure_time` — an interrupted-closure edge case) → No choice offered: only close-sprint is dispatched, no new work permitted until it runs.

### Phase Flow Within a Sprint

Issues progress through phases with methodology skills guiding each:

```
Analysis (/nexus-analyze) ──▶ Implementation (/nexus-build) ──▶ Evaluation (/nexus-validate)
         │                                │
         ▼                                ▼
   Research (/nexus-research)   Batch mode (/nexus-build,
   (for research issues,         _build_mode: batch —
    follows A→R→E, never         a sub-mode of Build for
    transitions to Build)        repetitive targets)

         ◀──── loop-back ◀──── loop-back ◀──────────────────────
```

In THEMED mode, all issues complete the current phase before any advance. In MIXED mode, each issue goes end-to-end independently.

[/Section: How-It-Works]

---

## Working With Sprints
[Section: Operations-Guide]

### Organize Sprint

**Command:** `organize sprint`
**What it does:** Plans the next sprint(s) by assessing the project landscape, evaluating the queue, and creating a fresh sprint-state.
**When to use:** Dispatched by `/nexus-start` after a sprint closes. You can also invoke it manually.

The operation has two paths:

**Full path** (default) — the complete planning flow:

1. **Landscape assessment** — Reads project-state for current phase and priorities, traces dependency chains across the registry, identifies candidate issues grouped into selection tiers (Must do → Should do → Could do).

2. **Queue evaluation** — If a queue exists, validates structural integrity: dependency ordering, capacity balance, data consistency with the registry, priority alignment with current project phase, and mode fit.

3. **Sprint planning** — Plans up to 3 sprints sequentially. For each: selects an anchor issue (highest value), finds natural companions (shared theme, dependencies, scope overlap), determines mode, checks capacity, and presents for your approval.

4. **Creation** — After you approve, creates sprint-state.md from template, patches issues-registry (target_sprint), updates sprint-queue (active + queued), writes the dependency map, updates project-state (current_sprint), clears any maintenance decision, and creates the sprint archive folder.

**Diagnostic path** — for queue health checks:

**Command:** `check queue` / `queue health` / `analyze queue`
Runs only the evaluation step — checks structural integrity, detects changes since last plan, and proposes fixes if needed. No new sprint creation.

---

### Sprint Status

**Command:** `sprint status`
**What it does:** Shows comprehensive sprint progress — per-issue detail, capacity, health, and recommendations. Read-only.
**When to use:** Anytime you want to see where things stand.

The display adapts to sprint mode:

- **THEMED**: Shows phase aggregation first ("All issues in implementation phase — 60% through"), then per-issue detail.
- **MIXED**: Groups issues by status (completed → in progress → queued).
- **DEDICATED**: Deep dive on the single issue with full implementation plan breakdown.

For in-progress issues, extracts real progress from ISS files: success criteria checked/total, implementation plan steps done/total, latest work log entry. Includes sprint health assessment (🟢/🟡/🔴), capacity label, and actionable recommendations.

---

### Close Sprint

**Command:** `close sprint`
**What it does:** Orchestrates the full closure sequence — resolving issues, extracting patterns, transferring experience, and archiving.
**When to use:** When all objectives are complete, or when you want to close an incomplete sprint.

This is NEXUS's most complex orchestrator. The closure sequence:

1. **Assess & approve** — Shows completion summary, gets your go-ahead.
2. **Resolve issues** — Each open issue: close as resolved, close as rejected, or move to next sprint. Each completed issue gets verified across registry, ISS file, and sprint-state. Then calls close-issue for batch closure.
3. **Pattern effectiveness** — Updates patterns-registry with usage outcomes from this sprint (verdict: helped/neutral/hindered, each with a one-line evidence note).
4. **Pattern candidates** — Collects candidates from sprint-state and ISS closure sections, applies 4Q prefilter, consolidates similar ones, and offers to create new patterns.
5. **Archive issues** — Moves closed ISS files to `archived/issues/`.
6. **Experience processing** — Processes `[SYSTEM_ISSUES]` (each becomes Issue/Fix/Seed/Skip) and `[BEHAVIORAL_INSIGHTS]` (Elevate/Add/Skip/Defer) from sprint-state inline; consumed entries are cleared, deferred insights remain.
7. **Unblock dependencies** — Removes resolved issues from any other issue's `blocked_by` list.
8. **Administrative updates** — Updates project-state, writes the cross-sprint memory layer (`.nexus/memory/*.jsonl`, via `/nexus-index-sprint` — replaced the former `work-history.md` append), marks sprint complete in queue, increments maintenance counter.
9. **Finalize** — Marks `_status: complete`, adds `_closure_time`, archives sprint-state to `.nexus/Sprints/{N}/final-sprint-state.md`, runs changelog-scan then health-diagnostic (skipped/reordered for maintenance-type sprints).

---

### Move Issues

**Command:** `move issue ISS-XXX` or `move ISS-XXX to sprint N`
**What it does:** Moves specific issues between sprints with full dependency validation.
**When to use:** When priorities shift, an issue becomes urgent, or you need to rebalance capacity.

Before moving, validates three things:

- **Status** — Only Open, Planned, In Progress, or Blocked issues can move.
- **Dependencies (bidirectional)** — Checks both what the issue depends on (would blockers still be in an earlier sprint?) and what depends on it (would dependents be stranded?). If conflicts exist, offers to move affected issues together.
- **Capacity** — Warns if the target sprint would become overloaded.

When moving TO the current sprint, the issue becomes the priority focus — it's placed in `in_progress` and `current_focus` updates immediately.

---

### Loop-Back

**Command:** `go back` / `loop back` / `return to analysis`
**What it does:** Structured return to a previous phase when the current approach isn't working.
**When to use:** When evaluation reveals the approach is flawed, or implementation hits a fundamental problem.

Valid transitions:

| From | To | What Gets Reset |
|------|-----|----------------|
| Implementation | Analysis | Implemented score → 2 |
| Evaluation | Implementation | Evaluated score → 2 |
| Evaluation | Analysis | Both evaluated and implemented → 2 |

The choice between "go back to implementation" vs "go back to analysis" depends on the nature of the problem: if the approach is sound but execution has bugs, go to implementation; if the approach itself is flawed, go to analysis.

Loop-back tracks history. After 2–4 loops on the same issue, NEXUS shows the history and asks you to consider whether the problem definition is clear enough. After 5+ loops, it recommends parking the issue.

After the transition, scores are updated in both registry and sprint-state, the appropriate methodology is loaded, and the ISS file's existing content is preserved for review and revision.

[/Section: Operations-Guide]

---

## Key Files
[Section: Data-And-Files]

### Sprint State Files

| File | Purpose | Location |
|------|---------|----------|
| sprint-state.md | Active sprint context — objectives, decisions, momentum, experience | `.nexus/active/states/` |
| sprint-queue.md | Forward-looking plan — active sprint, queued sprints, dependency map, backlog | `.nexus/active/states/` |

**sprint-state.md** is the most connected state file in NEXUS. It consolidates everything about the current sprint into one file:

- **Metadata**: sprint number, status, mode, title, project lifecycle
- **[CONVERSATION]**: conversation counter, current focus, checkpoint tracking
- **[BOOTSTRAP]**: `continue_with` (the handoff note between conversations) and `files_to_load`
- **[OBJECTIVES]**: planned, in-progress, and completed issues with scores
- **[DECISIONS]**: made decisions with reasoning, pending decisions, options for next conversation
- **[EXPERIENCE_CAPTURE]**: system issues and behavioral insights accumulated during the sprint
- **[MOMENTUM]**: discussion thread, awaiting decision, energy level, loop history

A fresh sprint-state is created by organize-sprint from the sprint-state-template at the start of each sprint. It's archived to `.nexus/Sprints/{N}/final-sprint-state.md` at closure.

**sprint-queue.md** tracks the pipeline: which sprint is active, what's planned next, and the dependency map between issues across sprints. Updated by organize-sprint (creation and planning), close-sprint (marking complete), and move-issues (reallocation).

### Data Flow

```
                    organize-sprint
                    creates fresh ──────▶ sprint-state.md
                         │                     ▲     │
                         ▼                     │     ▼
                    sprint-queue.md        Checkpoint  /nexus-start
                    (active + queued)      (saves)    (loads)
                         ▲
                         │
              close-sprint / move-issues
              (update allocations)

    issues-registry.yaml ◀──── target_sprint, scores ────▶ sprint-state [OBJECTIVES]
    (source of truth)           (two-place updates)        (working copy)
```

### Archive Structure

Each completed sprint produces an archive at `.nexus/Sprints/{NNN}/`:

| File | Created By | Purpose |
|------|-----------|---------|
| final-sprint-state.md | close-sprint | Complete sprint state at closure |

Sprint history is also indexed into the cross-sprint memory layer (`.nexus/memory/sprints_summaries.jsonl`, one entry per sprint) by `/nexus-index-sprint` during closure — this replaced the former `work-history.md` append.

[/Section: Data-And-Files]

---

## Common Issues
[Section: Troubleshooting]

### "No active sprint" at startup

**Cause:** Sprint was closed but no new sprint was organized (interrupted between close and organize), or sprint-state.md is missing.
**Fix:** `/nexus-start` will detect this and either delegate to organize-sprint automatically (if properly closed) or offer options. If sprint-state is missing entirely, use `rollback/restore file` to recover it from the last git checkpoint commit.

### Sprint feels stuck — no progress in 2+ conversations

**Cause:** Issue complexity underestimated, blocked by an unrecognized dependency, or approach needs rethinking.
**Fix:** Run `sprint status` for a health assessment. If the issue is the problem, consider `loop back` to rethink the approach. If the sprint is the problem, consider `move issue` to defer the blocker and work on something else.

### Wrong sprint mode — issues are more/less related than expected

**Cause:** Relationships between issues weren't fully apparent during planning.
**Fix:** Sprint mode is set by `/nexus-organize-sprint` at planning time — there is no mid-sprint switch command. If the mismatch matters, use `move issue` to reshape the sprint. Otherwise carry on: THEMED and MIXED differ only in whether issues advance through each phase together or run end-to-end one at a time, and DEDICATED is simply a single-issue sprint.

### Issue scores seem wrong after a loop-back

**Cause:** Loop-back correctly resets intermediate phase scores to 2. This is by design — you're returning to rework a phase, so the score should reflect that work needs to be redone.
**Fix:** No fix needed. When you complete the phase again, the methodology will re-score it based on actual quality.

### Sprint closure seems to take forever

**Cause:** Close-sprint is NEXUS's most complex operation (9 steps). It's doing a lot: closing each issue with knowledge extraction, processing patterns, archiving, processing experience, and running post-closure health diagnostics.
**Fix:** This is normal for sprints with multiple issues and pattern activity. In token-constrained situations, start sprint closure in a fresh conversation with full context budget — fewer issues means faster closure.

### Lost work after context overflow

**Cause:** Conversation hit context limits before a checkpoint saved the current state.
**Fix:** NEXUS has automatic checkpoint triggers at 70% (Yellow — prompts you to save) and 80% (Red — mandatory auto-save). If work was lost, check sprint-state.md — it reflects the last checkpoint save. ISS files on disk reflect their last patch. The gap is only unwritten analysis or decisions since the last save.

[/Section: Troubleshooting]

---

## Quick Reference
[Section: Quick-Reference]

### Commands

| Command | Operation | Type |
|---------|-----------|------|
| `organize sprint` | Plan and create next sprint | Full planning |
| `check queue` / `queue health` | Evaluate queue integrity | Diagnostic |
| `sprint status` | Show progress and health | Read-only |
| `close sprint` | Full closure sequence | Orchestrator |
| `move issue ISS-XXX` | Move issue between sprints | Reallocation |
| `go back` / `loop back` | Return to earlier phase | Phase transition |

### Sprint Modes at a Glance

| Mode | Issues | Phase Flow | Best For |
|------|--------|-----------|----------|
| THEMED | 2–3 related | All issues advance phases together | Tightly coupled work |
| MIXED | 2–3 diverse | Each issue completes end-to-end | Independent work, variety |
| DEDICATED | 1 complex | Single issue, deep focus | Complexity 4–5, maintenance |

### Phase Transition Quick Guide

| Current Phase | Score ≥ 4 | Next Phase | Methodology |
|---------------|-----------|------------|-------------|
| Analysis | Analyzed ≥ 4 | Implementation | /nexus-build |
| Analysis | Analyzed ≥ 4 | Research (research issues) | /nexus-research |
| Implementation | Implemented ≥ 4 | Evaluation | /nexus-validate |
| Evaluation | Evaluated ≥ 4 | Close Issue | /nexus-close-issue |

Batch mode (repetitive targets) is entered from within Implementation as a Build sub-mode (`_build_mode: batch`), not a separate scored phase transition.

### Key Files

| File | Path | Purpose |
|------|------|---------|
| sprint-state.md | `.nexus/active/states/` | Active sprint context |
| sprint-queue.md | `.nexus/active/states/` | Sprint pipeline and queue |
| sprint-state-template.md | `.nexus/templates/` | Sprint creation blueprint |
| sprint-queue-template.md | `.nexus/templates/` | Queue creation blueprint |

### Sprint Health Indicators

| Health | Meaning |
|--------|---------|
| 🟢 Good | Progress steady, no blockers, no pending decisions |
| 🟡 Caution | Some blockers, pending decisions, or slower than expected |
| 🔴 At Risk | Multiple blockers, stalled 2+ conversations, or critical decisions pending |

[/Section: Quick-Reference]
