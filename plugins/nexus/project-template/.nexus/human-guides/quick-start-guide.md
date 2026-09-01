# NEXUS Quick Start Guide
*Version: 1.3.1 | Date: 2026-08-25 | Sprint: 110*
*First contact with NEXUS — what it is, how it works, and getting started*

**Category**: getting-started
**Level**: beginner
**Description**: First contact with NEXUS — what it is, 3 core principles, essential commands, starting your first sprint.

**Source files**:
- CLAUDE.md v5.16.0 (Core Principles, Control Levels, System Nature, Routing Map, Display Templates)
- .claude/skills/nexus-start/SKILL.md v2.9.2 (startup sequence)

---

## What Is NEXUS?
[Section: What-Is-NEXUS]

NEXUS is a project management framework built entirely in markdown. It runs inside Claude conversations — when Claude loads the NEXUS files at the start of a conversation, they establish working rules, processes, and standards for your project.

Here's the key idea: **markdown files define how work happens**. There's no external tool, no database, no UI beyond the chat. Everything lives in files that Claude reads, follows, and updates.

**The work flow**:

```
PROJECT (your vision)
  → SPRINTS (batches of work)
    → ISSUES (3 phases: analyze → implement → evaluate)
      → PATTERNS (knowledge extracted from experience)
        → EVOLUTION (system improves itself)
```

You define a project. NEXUS organizes it into sprints. Each sprint contains issues that move through three phases. Along the way, the system captures what works as patterns and uses them to get better over time.

[/Section: What-Is-NEXUS]

---

## Three Core Principles
[Section: Three-Core-Principles]

NEXUS is built on three unbreakable rules. Everything else flows from these.

### 1. Continuity

Work is never lost between conversations. When you close a chat and start a new one, NEXUS picks up exactly where you left off. It does this through sprint-state.md — a file that tracks your current focus, progress, decisions, and what to do next.

At 70% context usage, Claude will offer to save a checkpoint. At 80%, it saves automatically. This isn't optional — continuity is the foundation. Saving a checkpoint never ends the conversation; it just writes your progress to disk so the next one can pick it up.

### 2. Verification

Check before acting, verify after acting. Before modifying any file, Claude checks its current state. After modifying, it verifies the changes applied correctly. This prevents corruption and catches errors early.

### 3. Consent

Nothing significant happens without your say-so — and you decide at the start of every conversation how much "significant" covers. That setting is called your **Control Level**:

| Level | Claude asks before… |
|-------|---------------------|
| **Streamlined** | Critical things only — closing issues or sprints, archiving, deleting, large refactors |
| **Balanced** *(default)* | Critical things, plus decisions — approving a plan, changing phase, creating or merging |
| **Full Control** | All of the above, plus routine writes — every file update, every registry patch |

You pick one at boot; NEXUS tells you which gates it will skip. Critical actions always ask, at every level. When Claude does ask, you'll see what will be modified and why, and then it stops and waits.

These three principles mean: your work persists, your files stay correct, and you set how tightly you hold the wheel.

The full treatment — what each gate tier actually covers, how skipped gates get logged, and how the context zones work — is in the [NEXUS Framework Guide](nexus-framework-guide.md#the-three-unbreakable-principles).

[/Section: Three-Core-Principles]

---

## Your First Conversation
[Section: Your-First-Conversation]

### What Happens at Startup

Every conversation begins with an automatic bootstrap sequence. You don't need to do anything — just send your first message and NEXUS initializes:

1. **Loads your sprint state** — where you left off, what's in progress
2. **Detects your work phase** — analysis, implementation, or evaluation
3. **Asks you to confirm** — a widget lets you verify or override the detected phase, and set your Control Level for the session
4. **Loads the right methodology** — the instruction set for your current phase
5. **Shows the startup header** — your sprint, focus, and what's next

```
NEXUS · Sprint #042 · Conv #3
Implementation (/nexus-build) · Control: Balanced · Opus 5 [1M]
Focus → Implement login validation for ISS-087
Context: 53K [29% ■■■□□□□□□□] · 💡 "show menu" for operations
```

Four lines, and that's the whole boot. A fifth line starting with `⚠` appears only when something actually needs your attention — a stale file, a recovered state. No news is genuinely no news.

### First-Time Setup

If this is a brand new NEXUS installation, the bootstrap detects it and walks you through project initialization — defining your project's vision, scope, deliverables, and creating your first sprint. Just follow the prompts.

[/Section: Your-First-Conversation]

---

## Essential Commands
[Section: Essential-Commands]

You can say these in natural language — NEXUS recognizes intent, not exact phrasing.

### Getting Oriented

| Say | What happens |
|-----|-------------|
| **"show menu"** | Opens the command center — browse all operations |
| **"sprint status"** | See your current sprint progress |
| **"list issues"** | View all open issues |
| **"help"** | Context-aware help on any topic |
| **"dashboard"** | Visual overview of project state |

### Doing Work

| Say | What happens |
|-----|-------------|
| **"work on ISS-042"** | Start or resume work on an issue |
| **"create issue"** | Create a new issue (guided wizard) |
| **"save checkpoint"** | Save your progress for next conversation |

### Managing Sprints

| Say | What happens |
|-----|-------------|
| **"organize sprint"** | Plan your next sprint from the issue queue |
| **"close sprint"** | Wrap up the current sprint with knowledge capture |

That's enough to get started. Say **"show menu"** anytime to discover more operations, or check the Navigation & Commands Guide for the full reference.

[/Section: Essential-Commands]

---

## How Issues Work
[Section: How-Issues-Work]

Every piece of work in NEXUS is an issue (ISS-001, ISS-002, ...). Issues move through three mandatory phases:

```
Analysis (A)  →  Implementation (I)  →  Evaluation (E)
understand       build it               verify it
the problem                             worked
```

Each phase has a score from 1 to 5. When a phase reaches 4 ("well advanced, ready to proceed"), Claude proposes moving to the next phase. Whether it waits for your approval is set by your Control Level — a phase transition is a T2 gate, so Balanced and Full Control ask, Streamlined proceeds with a notification.

**During Analysis**, Claude helps you understand the problem, research existing solutions, design an approach, and plan the implementation. The output is a Solution Design and Implementation Plan written to the issue file.

**During Implementation**, Claude executes the plan — modifying files, running tests, tracking progress. How often it stops to ask depends on your Control Level.

**During Evaluation**, Claude tests the implementation against success criteria, assesses quality, captures lessons learned, and closes the issue.

You don't need to manage the methodology — Claude loads the right one for each phase and guides you through it. Just focus on the decisions.

[/Section: How-Issues-Work]

---

## Key Concepts
[Section: Key-Concepts]

**Sprint-state.md** — The heartbeat of the system. Tracks your current sprint, active issues, decisions, patterns, and everything needed for continuity. Updated at every checkpoint.

**Issues (ISS-XXX.md)** — Individual work items stored in `.nexus/issues/`. Each has sections for description, solution design, implementation log, and evaluation results.

**Patterns (PAT-XXX)** — Reusable knowledge extracted from completed work. "When facing X, approach Y works because Z." Applied automatically when relevant patterns match new issues.

**Methodology skills** — Phase-specific instruction sets in `.claude/skills/` (`/nexus-analyze`, `/nexus-research`, `/nexus-build`, `/nexus-validate`, `/nexus-maintain`) that guide Claude through each phase's workflow. Loaded automatically based on your current phase.

**Registries** — YAML files tracking metadata for issues, patterns, documentation, and file versions. The source of truth for scores, statuses, and cross-references.

**Checkpoints** — Saved snapshots of your progress. Happen at your request, at 70% context (optional), and at 80% context (automatic). Enable seamless multi-conversation work.

[/Section: Key-Concepts]

---

## What To Do Next
[Section: What-To-Do-Next]

Once NEXUS is set up with a project and sprint:

1. **"work on ISS-XXX"** — pick an issue and start. Claude guides you through analysis.
2. **Approve the design** — when analysis completes, review and approve the solution plan.
3. **Watch it build** — Claude implements step by step. Individual file writes are T3 (routine), so at the default Balanced level they proceed with a notification rather than a prompt; Full Control asks for each one.
4. **Validate the result** — evaluation tests, assesses quality, and captures learning.
5. **Close and continue** — issue closes, move to the next one.

When the sprint's issues are done, close the sprint. NEXUS extracts learning, archives completed work, and you organize the next sprint.

### Recommended Reading

- **Navigation & Commands Guide** — full command reference and menu system
- **Issue Lifecycle Guide** — deep dive into the three phases
- **Methodology Skills Guide** — how the step-by-step workflows work
- **Architecture Quick Guide** — 5-minute system orientation with diagrams

Say **"browse docs"** to see all available guides, or **"learning path"** for a recommended reading order — both are modes of `/nexus-help`.

[/Section: What-To-Do-Next]
