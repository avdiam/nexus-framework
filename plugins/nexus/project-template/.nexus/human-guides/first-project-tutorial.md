# Your First NEXUS Project
*Version: 1.2.2 | Date: 2026-08-31 | Sprint: 112 | Category: getting-started*

*From fresh installation to organized first sprint — a guided walkthrough.*

**Source files:** nexus-setup-project/SKILL.md v5.2.0, nexus-generate-mvp/SKILL.md v3.1.1, nexus-organize-sprint/SKILL.md v2.11.0, nexus-start/SKILL.md v2.9.2

---

## What You'll Build in This Tutorial
[Section: What-Youll-Build]

By the end of this tutorial, you'll have:

- A fully defined project with vision, scope, deliverables, and phases
- A backlog of tracked issues with priorities, dependencies, and sprint allocations
- An organized first sprint ready to begin work
- A working understanding of the NEXUS conversation cycle

**Time**: One conversation for setup (~30-45 minutes), one more to see the payoff.

**Prerequisites**: NEXUS installed and your project folder opened in Claude Code, per the [Installation Guide](installation-guide.md). If you haven't done that yet, start there — it takes about 10 minutes.

This tutorial uses a **software project** as the primary walkthrough, with variations for Research, Operations, and Creative projects shown in callout boxes at key decision points. The shared steps (most of them) work identically regardless of domain.

**A few terms you'll see throughout:**
- **Sprint** — a focused batch of work, typically spanning several conversations. Think of it as a short cycle: plan some work, do it, close the sprint, learn from it, repeat.
- **Issue** (ISS-001, ISS-002, ...) — a tracked unit of work. Each issue has its own file (e.g., `ISS-001.md`) with a description, success criteria, and sections that fill in as you analyze, implement, and evaluate.
- **Complexity** — a 1-5 rating per issue reflecting effort and difficulty. NEXUS targets ~9 complexity points per sprint as a comfortable capacity. So a sprint might hold three complexity-3 issues, or one complexity-5 plus a complexity-3, and so on.
- **Control Level** — how much NEXUS asks before acting, set once per conversation at boot. See [The Three Unbreakable Principles](nexus-framework-guide.md#the-three-unbreakable-principles) for the full consent model — the "you approve" language throughout this tutorial describes the default (Balanced) level.

Everything in NEXUS can be revised as you learn more — wizard answers, project scope, sprint plans, even the framework files themselves.

---

[/Section: What-Youll-Build]

## Part 1: First Boot — Meeting NEXUS
[Section: Part-1-First-Boot]

Open your project folder in Claude Code, start a new conversation, and type "start":

```
You: start
```

NEXUS detects there's no project defined yet and moves straight into the setup wizard — no boot log, no ceremony, just the first question.

**What just happened**: NEXUS created its internal state files — the working memory that will persist across all your future conversations. Think of it as NEXUS setting up its desk before starting work with you.

> **🎯 First payoff moment**: This automatic detection and setup is NEXUS already working for you. No manual file editing, no configuration — it saw a fresh install and handled initialization on its own.

> **Not ready to dive into a project yet?** You don't have to follow the setup wizard right away. In a new conversation, type **"brainstorm"** to explore ideas in a parallel, non-restrictive phase without committing to project setup. Or type **"learning path"** for a personalized reading order through the framework documentation. Other discovery commands: **"show menu"** (browse all operations), **"browse docs"** (see all available guides), **"help"** (context-aware assistance). When you're ready to set up your project, start a fresh conversation and type "start."

The setup wizard starts immediately. Let's walk through it.

---

[/Section: Part-1-First-Boot]

## Part 2: Defining Your Project (The Setup Wizard)
[Section: Part-2-Setup-Wizard]

The setup wizard has 8 steps — a silent STEP 0 that checks for a partial setup to resume, plus the seven below. It's a conversation, not a form — NEXUS proposes, you refine. Each answer is saved to disk as you go, so if your conversation runs long, you can pick up where you left off.

### Step 1: Project Identity

NEXUS asks three things: a working title, your project type, and your domain.

**Project type** is selected through clickable widgets — first a broad category (Technical, Research, Business, Creative), then specific types within that category. NEXUS ships with domain-specific templates that adapt the entire wizard to your field.

> **📦 What You're Choosing**
>
> | If you pick... | The wizard adapts with... |
> |---|---|
> | **Software/Product Dev** | Component-oriented phases, feature/infrastructure issue types, technical deliverables |
> | **Research & Analysis** | Methodology-oriented phases, literature review → data collection → analysis flow |
> | **Operations/Process** | Improvement-cycle phases, assessment → design → pilot → rollout structure |
> | **Creative/Content** | Production-oriented phases, pre-production → production → post-production flow |
>
> Don't worry about picking perfectly — you can change this later if the fit feels wrong, and NEXUS will reload the right template.

After type selection, NEXUS loads a domain-specific template that shapes every remaining step — the questions it asks, the deliverables it proposes, the phases it suggests, even the vocabulary it uses.

You'll also be asked about existing documents (specs, briefs, references). If you have them, upload or point NEXUS to them — it extracts vision, scope, and deliverables automatically and presents what it found for your review.

### Step 2: Vision & Purpose

The most important step. NEXUS frames the question in your domain's language:

> **How NEXUS asks, by domain:**
>
> - **Software**: "What are we building, and what problem does it solve for users?"
> - **Research**: "What question are we trying to answer, and why does it matter?"
> - **Operations**: "What problem are we tackling, and what would success look like?"
> - **Creative**: "What are we creating, and what impact should it have?"

NEXUS guides you to cover three elements: a **concrete outcome** (what), a **purpose** (why), and **observable success** (how you'd know it worked). If your answer is missing one, it'll ask a follow-up — not to be difficult, but because a clear vision prevents false starts later.

After you answer, NEXUS reflects back a one-sentence synthesis: *"So we're building X because Y, and we'll know it works when Z. Does that capture it?"* This catches misunderstandings immediately.

### Step 3: Scope & Constraints

NEXUS asks about constraints first (timeline, resources, technical limits) because they frame what's realistic. Then it helps you define what's in scope and — just as important — what's explicitly out.

A key part of this step: **success constraints**. NEXUS asks:

- **MVP Minimum**: What's the absolute smallest version that would still be valuable?
- **Sufficiency Threshold**: Where do diminishing returns start?
- **Completion Criteria**: When do we declare "done"?

These questions prevent two common project failures: delivering too little to matter, and never finishing because "there's always one more thing."

If you have non-negotiable principles (security requirements, ethical constraints, accessibility standards), NEXUS captures those as a project constitution — rules that get checked during analysis and evaluation.

### Step 4: Deliverables

Here's where the domain template really shines. Instead of asking "what are your deliverables?" and waiting for a blank-page answer, **NEXUS proposes deliverables based on your project type and vision**, then you adjust.

> **What NEXUS proposes, by domain:**
>
> - **Software**: User authentication, API endpoints, admin dashboard, deployment pipeline, documentation...
> - **Research**: Literature review, methodology document, data collection instrument, analysis results, final report...
> - **Operations**: Current state assessment, process redesign document, pilot program, training materials, monitoring dashboard...
> - **Creative**: Creative brief, content calendar, asset library, production deliverables, distribution plan...
>
> These are starting points — you accept, remove, modify, and add your own.

NEXUS helps you sort deliverables into three tiers:

- **MVP** — must-have for the first valuable version (drives your initial sprints)
- **Enhanced** — valuable but not essential for first release
- **Future** — aspirational goals that inform architecture but don't drive immediate work

Then comes the priority pressure test: *"If you could only deliver half of your MVP items, which ones?"* This forces honest prioritization — and NEXUS uses the answer to plan smarter sprints later.

### Step 5: Phases & Effort

NEXUS proposes a phase structure from your domain template, using your project's natural language:

> **Phase naming, by domain:**
>
> | Software | Research | Operations | Creative |
> |---|---|---|---|
> | Foundation | Literature Review | Assessment | Pre-Production |
> | Core Features | Methodology Design | Process Design | Production |
> | Integration | Data Collection | Pilot Implementation | Post-Production |
> | Polish & Deploy | Analysis & Writing | Rollout & Monitoring | Distribution |

Each phase gets allocated deliverables and an effort estimate. NEXUS checks whether your scope fits your timeline — and tells you honestly if it doesn't: *"These deliverables estimate ~8 sprints but your timeline suggests ~5. We could reduce MVP scope, simplify some deliverables, or extend the timeline."*

### Step 6: Risks & Validation

NEXUS proposes risks from its domain template catalog, combined with project-specific risks it noticed during the conversation. For each risk, it prompts you to assess likelihood, impact, and a concrete mitigation — *"'Be careful' isn't a mitigation."*

Then it derives success metrics from your vision and deliverables, performs a cross-step coherence check (does everything connect?), and gives you an elevator pitch synthesis: your entire project in two sentences.

If the synthesis feels wrong, something upstream needs adjusting — this is the most powerful single validation in the wizard.

### Step 7: Review & Finalize

NEXUS reads back the complete project definition from disk (not memory — it verifies what was actually saved). You see everything in one view: vision, scope, deliverables, phases, risks, metrics. Thin sections are flagged for revisit. The project title is reconsidered now that the full picture is clear.

On approval, NEXUS finalizes the project and sets your installation to "active." Then it offers the natural next step:

```
✅ PROJECT CREATED
════════════════════════════════════════
Project: {project_name}
Type: {project_type} | Domain: {project_domain}
Location: .nexus/active/states/project-state.md
Status: Planning | Phase 1: {phase_name}
Phases: {N} | MVP Deliverables: {N}
════════════════════════════════════════
```

You're asked: Generate MVP issues from deliverables (recommended), or Done for now.

---

[/Section: Part-2-Setup-Wizard]

## Part 3: From Deliverables to Issues
[Section: Part-3-Deliverables-To-Issues]

Select "Generate MVP issues" and NEXUS analyzes your deliverables to create a complete issue backlog.

### How Deliverables Become Issues

Each deliverable gets broken down into trackable issues — the actual units of work. NEXUS uses your domain template's breakdown patterns:

> **How breakdown works, by domain:**
>
> - **Software** (component-oriented): A "User Authentication" deliverable might become: Auth System Analysis → Database Schema → Auth API Implementation → Frontend Login Flow → Integration Testing
> - **Research** (methodology-oriented): A "Data Collection" deliverable might become: Instrument Design → Pilot Study → Data Collection Protocol → Collection Execution
> - **Operations** (improvement-cycle): A "Process Redesign" deliverable might become: Current State Mapping → Gap Analysis → New Process Design → Stakeholder Review
> - **Creative** (production-oriented): A "Video Series" deliverable might become: Script Development → Pre-Production Planning → Filming → Post-Production → Distribution Setup

For each issue, NEXUS prepares a full specification: what it achieves, why it matters, how you'd know it's done, its type, and what it depends on. You review and adjust before anything is created.

### Assessment & Planning

After breakdown, NEXUS assesses each issue's priority, impact, and complexity. It maps dependencies (which issues block which) and identifies the critical path — the longest dependency chain that determines your minimum timeline.

Then it allocates issues to project phases and estimates sprint needs. You see the full plan before any issues are created:

```
📋 ISSUE SPECS FOR REVIEW — 14 issues from 5 deliverables
════════════════════════════════════════

PHASE 1: Foundation — 5 issues, 12 points
─────────────────────────────────────────
  ▸ {Issue title} ({type}, C:{complexity}, {priority})
    ...

PHASE 2: Core Features — 6 issues, 18 points
─────────────────────────────────────────
  ...

PHASE 3: Integration — 3 issues, 8 points
─────────────────────────────────────────
  ...

────────────────────────────────────────
COVERAGE: 5/5 deliverables fully covered
CONSTITUTION: 14/14 issues compliant
TOTAL: 38 points | ~4 sprints
════════════════════════════════════════
```

### Phase-Batched Creation

NEXUS creates issues one phase at a time, with checkpoints between batches. This means if your conversation runs long, no work is lost — the next conversation picks up at the next phase.

Each created issue gets:
- An ISS file (e.g., `ISS-001.md`) with description, success criteria, and scaffolded sections for analysis, implementation, and evaluation
- A registry entry tracking its status, scores, priority, and dependencies
- Links back to its parent deliverable in your project state

After all issues are created, NEXUS links cross-phase dependencies and updates your project state with issue references.

---

[/Section: Part-3-Deliverables-To-Issues]

## Part 4: Organizing Your First Sprint
[Section: Part-4-First-Sprint]

With issues created, NEXUS offers to organize your first sprint. Accept, and it assesses the landscape:

### How Sprint Planning Works

NEXUS evaluates candidate issues using a tiered selection system:

- **Tier 1 (Must do)**: Critical priority, in-progress work, high unblocking value, critical path issues
- **Tier 2 (Should do)**: High impact / low complexity (best ROI), MVP-linked, phase-aligned
- **Tier 3 (Could do)**: Medium priority improvements, future-proofing

It proposes a sprint with a mode that fits the work:

- **THEMED**: 2-3 tightly related issues sharing a domain or theme — complete each phase together
- **MIXED**: 2-3 diverse issues — complete each issue end-to-end before moving to the next
- **DEDICATED**: One complex issue gets full focus

```
📋 Sprint 001 Proposal
Mode: THEMED — Foundation & Architecture

Issues:
  • ISS-001: Project Architecture Design (P:Critical, C:3) — foundation for everything
  • ISS-002: Database Schema (P:High, C:2) — blocks 3 other issues
  • ISS-003: Dev Environment Setup (P:High, C:1) — enables all implementation

Total Complexity: 6/~9
Rationale: tightly related foundation work — same theme, sequenced dependencies
```

You approve, adjust, or ask for different selections. NEXUS also plans 1-2 future sprints as a queue — giving you visibility into what's coming without over-committing.

On approval, NEXUS creates the sprint state and you're ready.

---

[/Section: Part-4-First-Sprint]

## Part 5: Your First Real Conversation
[Section: Part-5-First-Conversation]

Start a new conversation. Type "start":

```
You: start

NEXUS · Sprint #001 · Conv #1
Analysis (/nexus-analyze) · Control: Balanced · Sonnet 5 [1M]
Focus → Analyze ISS-001 — Project Architecture Design
Context: — (awaiting first hook) · 💡 "show menu" for operations
```

> **🎯 This is the moment.** Claude knows your sprint, your issue, your phase, and exactly what to do next — without you explaining anything. Every future conversation starts this way.

Say **"work on ISS-001"** and NEXUS loads your issue, checks for applicable patterns, and guides you through structured analysis:

1. **Understanding** — What does this issue really need? What are the constraints?
2. **Pattern matching** — NEXUS searches its pattern library for proven approaches that fit your problem. Matched patterns appear with a 📐 symbol and adapt to your specific context — they're guidance, not rigid templates, and you can accept, modify, or reject any of them
3. **Research** — Are there existing solutions, patterns, or prior art?
4. **Options** — Generate 2-3 approaches with tradeoffs
5. **Design** — Detail the chosen approach: solution design, implementation plan, success criteria
6. **Transition** — When analysis is complete, NEXUS detects it and proposes moving to implementation

For complex issues (complexity 3+), NEXUS may also suggest **cognitive tools** — structured thinking frameworks like First Principles analysis, Decision Trees, Inversion Thinking, or Root Cause Analysis. These are optional power tools that help break down hard problems; they're offered when the complexity warrants it and available on request anytime via "cognitive tools menu."

At any point, say **"save checkpoint"** to preserve progress. At 70% context, NEXUS recommends saving. At 80%, it saves automatically. Your next conversation picks up exactly where this one left off.

---

[/Section: Part-5-First-Conversation]

## Part 6: Your Daily Workflow
[Section: Part-6-Daily-Workflow]

Once your project is rolling, every work session follows a natural rhythm:

```
1. Start conversation → NEXUS boots
2. See where you left off → continue_with tells you exactly what's next
3. Work on your issue → guided methodology adapts to the phase
4. Save checkpoint → progress preserved for next time
5. Repeat
```

### Commands You'll Use Most

| Command | What it does |
|---------|-------------|
| `work on ISS-XXX` | Focus on a specific issue with phase-appropriate guidance |
| `save checkpoint` | Preserve progress for the next conversation |
| `show menu` | Browse all available operations |
| `create issue` | Add new work to the backlog |
| `sprint status` | See current sprint progress |
| `organize sprint` | Plan the next sprint when the current one completes |
| `help` | Context-aware help on any topic |

### The Phase Cycle

Each issue flows through phases, and NEXUS loads the right methodology for each:

**The standard path** (most issues):
> Analysis → Implementation → Evaluation → Issue closed

**The research path** (when the deliverable is knowledge, not code or process changes):
> Analysis → Research → Evaluation → Issue closed

**Batch sub-mode** can activate during implementation when NEXUS detects a repeating pattern — the same procedure applied to multiple targets. It formalizes a playbook and tracks batch execution, then returns to the normal flow.

| Phase | Methodology | What happens |
|-------|-------------|-------------|
| Analysis | nexus-analyze | Understand the problem, research approaches, design a solution, plan implementation |
| Research | nexus-research | Deep investigation, literature survey, synthesis, knowledge production |
| Implementation | nexus-build | Execute the plan, test changes, verify, document |
| Implementation (batch sub-mode) | nexus-build (batch mode) | Batch-execute a repeating procedure across multiple targets |
| Evaluation | nexus-validate | Validate results, assess quality, extract lessons learned |

**Analysis** is always first — every issue starts by understanding the problem and designing an approach. From there, the path depends on the work. NEXUS detects which path fits based on the issue type and scores.

Phase transitions happen when scores reach threshold (≥4/5). NEXUS tracks scores and prompts you when it's time to move on — you confirm, and it loads the next methodology automatically.

### Sprint Lifecycle

```
Sprint opens → work issues through phases → all issues complete
    ↓
Sprint closes → lessons extracted → patterns captured
    ↓
Next sprint organized from queue → cycle continues
```

Sprint closure extracts everything learned — successful patterns, system improvements, behavioral insights — and feeds them into the next sprint. Your project literally gets smarter with each cycle.

---

[/Section: Part-6-Daily-Workflow]

## Troubleshooting
[Section: Troubleshooting]

### "Context feels tight during work"

NEXUS uses context for management and methodology. To maximize working room:
- Say "save checkpoint" before context reaches 70% if you're doing heavy work
- NEXUS loads methodology files just-in-time and reads specific sections, not full files

### "The wizard feels slow"

The setup wizard is thorough because good project definition prevents wasted sprints. If you want to move faster, give brief answers — NEXUS accepts thin answers and fills gaps with template defaults (clearly marked so you know what was defaulted). You can always refine later.

### "I picked the wrong project type"

Tell NEXUS mid-wizard: "Actually, this is more of a research project." It reloads the correct template and offers to revisit earlier steps with the new framing.

### "Setup was interrupted"

Start a new conversation. NEXUS detects the partial state and offers to resume where you left off. Every wizard step saves to disk, so nothing is lost.

### "I want to change my project after setup"

Say "update project parameters" — NEXUS has a dedicated operation for modifying vision, scope, deliverables, or phases after initial setup.

For more troubleshooting, see the [Troubleshooting Guide](troubleshooting-guide.md).

---

[/Section: Troubleshooting]

## What You've Learned
[Section: What-Youve-Learned]

In this tutorial, you've seen the complete NEXUS lifecycle:

1. **First boot** → automatic detection and initialization
2. **Project definition** → guided wizard adapted to your domain
3. **Issue generation** → deliverables broken into trackable work
4. **Sprint planning** → intelligent issue selection and sequencing
5. **Daily workflow** → boot → work → save → repeat
6. **Phase methodology** → analysis → implementation → evaluation per issue
7. **Sprint lifecycle** → work → close → learn → next sprint

The framework handles the process; you focus on the decisions. Every conversation picks up where the last one left off. Your project accumulates knowledge. And the system evolves with you.

---

[/Section: What-Youve-Learned]

## Going Deeper
[Section: Going-Deeper]

| Guide | What you'll learn |
|-------|-------------------|
| [Installation Guide](installation-guide.md) | Step-by-step setup instructions |
| [Quick Start Guide](quick-start-guide.md) | Core concepts and essential commands in 5 minutes |
| [NEXUS Framework Guide](nexus-framework-guide.md) | Complete system reference — architecture, methodology, patterns |
| [Troubleshooting Guide](troubleshooting-guide.md) | Comprehensive problem-solving reference |

---

[/Section: Going-Deeper]

*NEXUS — Your AI collaborator remembers everything, guides every step, and gets smarter with each sprint.*
