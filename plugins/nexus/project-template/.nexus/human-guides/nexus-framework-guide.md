# NEXUS Framework — Complete System Guide
*Version: 2.3.1 | Date: 2026-08-31 | Sprint: 112*
*A Markdown-Based Project Management & Development Framework for AI-Assisted Work*

**Category**: getting-started
**Level**: all
**Description**: Complete system reference — what NEXUS is, how it works, all domains, flows, methodologies, cognitive tools, and the self-maintaining health system. The canonical explanation of context zones, Control Levels, and the framework's architecture.

**Source files**:
- `CLAUDE.md` v5.16.0 (Core Principles, Control Levels, Context Zones, System Nature, Routing Map, Display Templates, Phase Management, Memory Layer)
- `.claude/skills/nexus-*/SKILL.md` (54 skills — the operational protocols)
- `.nexus/active/NEXUS-Architecture.md` v4.1.0 (system relationship map)
- `.nexus/templates/issue-specification.md` (ISS structure and types)

---

## The Problem

You're 3 conversations into a complex project with Claude. You re-explain the architecture, the decisions you made, where you left off. By conversation 10, you're spending half your time on re-orientation. By conversation 20, critical decisions are lost forever. You can't build anything meaningful because your AI assistant has amnesia between every conversation.

Static project context helps a little. But it doesn't track what you decided in conversation 12, what phase your work is in, which files you changed, what patterns you've learned, or where to pick up next. It gives Claude background knowledge — not working memory.

**NEXUS solves this.** It externalizes the entire project state into structured markdown files that Claude loads at each conversation start. Sprint context, issue progress, design decisions, learned patterns, system health — everything persists. The result: perfect continuity across any number of conversations, with an AI that remembers every decision, tracks every file change, and knows exactly where to resume.

The NEXUS project itself has closed 109 sprints across hundreds of conversations with zero context loss.

---

## What Is NEXUS?

NEXUS is a project management and development framework where **markdown files define operational protocols** that Claude follows throughout a project's lifecycle. When Claude loads these files at the start of a conversation, they establish working rules, processes, and standards — creating a persistent working environment despite the LLM having no built-in memory.

Think of it as an operating system for AI-assisted development: the files are the program, the LLM is the processor, and the project deliverables are the output. Every instruction, pattern, and protocol Claude reads becomes an active operational guideline.

---

## It's Open, It's Free, It's Plain English

NEXUS is free and open. There's no proprietary format, no compiled code, no black box — the entire framework is markdown files written in plain English. You don't need to be a programmer or a specialist to read, understand, and modify how it works. Open any file and you'll find clear instructions that both you and Claude can follow.

This also means you can make it yours. Fork it, adapt the methodology to your workflow, add new operations, change the behavioral preferences, expand the pattern library. NEXUS is a starting point, not a locked product. The system was designed to evolve — and that includes evolving in your direction.

---

## What Makes NEXUS Different

**It's not a chatbot prompt** — it's a complete operational framework: one always-loaded harness file, 54 skills, four registries, four state files, and a cross-sprint memory layer. The markdown files ARE the software.

**It preserves continuity across any number of conversations** — sprint-state, ISS files, and the checkpoint protocol ensure every conversation picks up exactly where the last one left off. No re-explanation, no lost decisions, no context drift.

**It learns from experience** — patterns extracted from successful work guide future decisions. Behavioral preferences evolve through validated pipelines. The system captures what works, discards what doesn't, and gets better over time.

**It scales with complexity** — simple tasks skip tools, patterns, and deep analysis. Complex issues get the full methodology with cognitive tools, strategic approaches, adversarial review, and multi-topic design sessions. You get exactly the rigor you need — no more, no less.

**It maintains itself** — predictive health monitoring, 10 maintenance operations, tiered validation of all registries, and automated snapshot management. The system knows when it needs maintenance before problems emerge.

**It's project-agnostic** — the setup wizard adapts to any domain: software development, academic research, creative projects, strategic planning, educational content, data analytics. Phase structures, deliverable types, and issue breakdowns use the project's natural language, not generic software terminology.

**It runs inside Claude Code** — NEXUS adds the dynamic layer on top of your working environment: project tracking, sprint management, methodology guidance, pattern learning, and cross-conversation continuity that a code assistant alone doesn't provide.

---

## Who NEXUS Is For (and Who It Isn't)

**NEXUS is built for complex projects that need structure:**

- Projects spanning many conversations (10+) where continuity is essential
- Work that benefits from methodology — analysis before implementation, evaluation after
- Teams of one (you + Claude) where you want a true AI collaborator, not just a chat assistant
- Projects where decisions matter and you need to track outcomes across sprints
- Any domain where accumulated knowledge should improve future work

**NEXUS is probably not what you're looking for if:**

- You want fast "vibe coding" of quick demos or prototypes — NEXUS adds methodology overhead that pays off over time, not in a single session
- Your task fits in one or two conversations — the framework shines when continuity matters
- You prefer a completely freeform working style with no process structure
- You're on a free Claude plan — NEXUS invests a portion of each conversation's context in management and methodology, so you need enough room for both the framework and meaningful work

**NEXUS works for any domain** — not just software. The setup wizard adapts to your project type with domain-specific phases, deliverables, and language:

| Domain | Example phases |
|--------|---------------|
| Software development | Foundation → Core Features → Integration → Polish |
| Academic research | Literature Review → Methodology → Data Collection → Analysis → Writing |
| Operations & process | Assessment → Design → Implementation → Monitoring |
| Creative projects | Pre-Production → Production → Post-Production → Distribution |

The system uses your domain's natural language, not generic software terminology. Thirteen domain profiles ship in `.nexus/templates/project-types/`.

---

## Getting Started

### What You Need

- **Claude Code** — the CLI, desktop app, an IDE extension, or the web app. The [Installation Guide](installation-guide.md) is authoritative on host requirements, including the caveats that apply to the web app and the Python prerequisites the hooks need
- **The three NEXUS artifacts**, copied into your project directory: `CLAUDE.md` (the harness), `.claude/` (the skills and hooks), and `.nexus/` (state, registries, issues, patterns). A `.gitignore` ships alongside them — useful, not required

All three are required. `CLAUDE.md` without `.claude/skills/` gives Claude the rules but none of the operations; `.claude/` without `.nexus/` gives it the operations but nothing to operate on. Full instructions are in the [Installation Guide](installation-guide.md).

### First Conversation

When you start your first conversation with NEXUS installed, the startup protocol detects a fresh installation (`_project_lifecycle: not-defined`) and walks you through setup:

1. **`/nexus-init-project`** creates state files and registries from templates
2. **`/nexus-setup-project`** guides you through defining your project — vision, scope, deliverables, phases, constraints, success metrics
3. **`/nexus-generate-mvp`** breaks your deliverables into a tracked issue backlog with dependencies
4. **`/nexus-organize-sprint`** plans your first sprint from the issue pool

After setup, every subsequent conversation starts by saying `start`. NEXUS loads your sprint state, detects what phase you're in, asks you to confirm the phase and set your Control Level, and loads the right methodology.

### What It Looks Like

Here's a conversation start after setup is complete:

```
NEXUS · Sprint #042 · Conv #3
Implementation (/nexus-build) · Control: Balanced · Opus 5 [1M]
Focus → Implement login validation for ISS-087
Context: 53K [29% ■■■□□□□□□□] · 💡 "show menu" for operations
```

Four lines, and that's the whole boot. A fifth line starting with `⚠` appears only when something needs your attention — a stale file, a recovered state. No news is genuinely no news.

Commands are natural language — "create issue about X," "show patterns," "save checkpoint," "organize sprint." A menu system (`show menu`) provides guided navigation if you prefer browsing over typing.

### Multi-Project Support

Each project gets its own complete, self-contained NEXUS installation — `CLAUDE.md` plus `.claude/` plus `.nexus/` in the project directory. Switching projects is just opening a different directory in Claude Code; nothing is shared, so nothing can leak between them.

---

## The Three Unbreakable Principles

Everything in NEXUS is built on three non-negotiable principles.

### 1. Continuity

Perfect handoffs between conversations. When work progresses, the system records the exact task and context so the next conversation resumes seamlessly. Lost work means system failure.

Context usage is tracked continuously against three zones:

| Zone | Range | What happens |
|------|-------|--------------|
| **Green** | 0–70% | Work normally |
| **Yellow** | 70–80% | NEXUS prompts you to save a checkpoint; your choice |
| **Red** | 80%+ | Mandatory save — the checkpoint runs automatically |

Saving does not mean stopping. After a checkpoint NEXUS keeps working at full rigor; it just prefers reads over writes from there.

### 2. Verification

Check before acting, verify after acting. Before modifying any file, verify its current state. After modifications, re-read from disk to confirm the change landed. An unverified operation is a failed operation — and on high-stakes files (state, registries, the harness, skills) NEXUS must print a verification marker quoting the exact string it read back.

### 3. Consent

Nothing significant happens without your say-so — and **you** decide at the start of every conversation how much "significant" covers. That setting is your **Control Level**, and NEXUS asks for it in the boot widget every session.

Operations are sorted into three tiers:

| Tier | Covers |
|------|--------|
| **T1 — Critical** | Closing an issue or sprint, archiving, deleting, destructive overwrites, rollbacks, large refactors, bulk rewrites |
| **T2 — Decision** | Approving a plan, design choices, phase transitions, create / merge / move operations |
| **T3 — Routine** | Issue file updates, registry patches, documentation writes, progress saves |

Your Control Level decides which tiers stop and ask:

| Level | T1 Critical | T2 Decision | T3 Routine |
|-------|-------------|-------------|------------|
| **Streamlined** | Always asks | Proceeds, tells you | Proceeds silently |
| **Balanced** *(default)* | Always asks | Asks | Proceeds, tells you |
| **Full Control** | Always asks | Asks | Asks |

**T1 always asks, at every level** — there is no setting that lets NEXUS close a sprint or delete a file without you. When a gate is skipped because of your level, it is logged to the sprint record with an `[AUTO]` prefix, so the audit trail shows what was decided on your behalf.

When Claude does ask, the format is fixed: it states what file it will change and how, then stops and waits. No response is not approval.

---

## System Architecture

### The Three Layers

NEXUS has exactly three moving parts, and knowing which is which explains most of the system:

| Layer | Where | What it is |
|-------|-------|------------|
| **The harness** | `CLAUDE.md` | Always loaded, every conversation. Identity, the three principles, Control Levels, context zones, the routing map, file-operation protocols, behavioral preferences. Nothing else needs loading for NEXUS to behave correctly. |
| **The skills** | `.claude/skills/nexus-*/` | 54 skills, each a folder with a `SKILL.md`. Loaded on demand when a command triggers them. This is where every operation actually lives. |
| **The data** | `.nexus/` | State, registries, issues, patterns, seeds, memory, archives. The thing being operated on. |

The split matters: the harness is the constitution, the skills are the statutes, and `.nexus/` is the record. You can read any of the three in a text editor and understand it.

### Physical Structure

```
CLAUDE.md                            # The harness — always loaded
.claude/
├── skills/                          # 54 skills, one folder each
│   ├── nexus-start/SKILL.md         #   boot sequence
│   ├── nexus-analyze/               #   5 methodology skills
│   ├── nexus-build/                 #   (build carries batch.md + types/)
│   ├── nexus-validate/
│   ├── nexus-research/
│   ├── nexus-maintain/
│   ├── nexus-mental-models/         #   3 cognitive tool packs
│   ├── nexus-problem-solving/
│   ├── nexus-strategic/
│   ├── nexus-brainstorm/            #   parallel phase
│   └── nexus-*/                     #   45 operation skills
├── agents/                          # Sub-agent definitions
└── hooks/                           # Token tracking, YAML validation, backups
.nexus/
├── active/
│   ├── NEXUS-Architecture.md        # System relationship map
│   ├── Emergency-Reference.md       # Recovery and degraded-mode procedures
│   ├── states/                      # Live project state — 4 files
│   │   ├── sprint-state.md          #   current sprint context (the lifeline)
│   │   ├── project-state.md         #   project definition and progress
│   │   ├── system-state.md          #   health tracking and maintenance cycles
│   │   └── sprint-queue.md          #   planned sprint pipeline
│   └── registries/                  # YAML metadata stores — 4 files
│       ├── issues-registry.yaml     #   issue metadata and phase scores
│       ├── patterns-registry.yaml   #   pattern metadata and effectiveness
│       ├── changelog-registry.yaml  #   version history for system files
│       └── documentation-registry.yaml
├── templates/                       # 13 structural blueprints + project-types/
├── issues/                          # Active ISS-XXX.md files
├── patterns/                        # Active PAT-XXX.md files
├── seeds/                           # Parked ideas with trigger conditions
├── memory/                          # 7 JSONL files — cross-sprint knowledge
├── Sprints/                         # Per-sprint archived state
├── archived/                        # Closed issues, patterns, projects
└── human-guides/                    # Documentation for humans
```

### How Files Work Together

`CLAUDE.md` is always loaded — it holds the routing map, core protocols, behavioral preferences, and the foundational rules. The `/nexus-start` skill runs once at conversation start to detect the current sprint, work phase, and context. Methodology skills load based on the detected phase. Operation skills load when a command is recognized in what you type — even embedded in ordinary sentences.

Two loading disciplines keep this affordable. **Memory-first**: before any read, check whether the file is already in context — re-reading a loaded file is a protocol violation, not just waste. **Section loading**: files mark named regions with `[Section: Name]` markers, so a skill can pull the 2 KB it needs out of a 40 KB file instead of the whole thing.

---

## The Work Flow

```
PROJECT → SPRINTS → ISSUES → PATTERNS → EVOLUTION
```

### Projects

A project is the top-level container — vision, scope, deliverables, phases, constraints, risks, and success metrics. NEXUS supports the full project lifecycle:

- **`/nexus-init-project`**: First-run setup for an installation that already has the framework files. Detects a fresh install via the `_project_lifecycle` field and bootstraps state files from templates. It does **not** install NEXUS into another folder — that is `/nexus:setup`'s job (see the [Installation Guide](installation-guide.md)).
- **`/nexus-setup-project`**: Interactive wizard that progressively builds `project-state.md` through collaborative steps — from project type and vision through deliverables, phases, constraints, and success metrics. Adapts to any project type.
- **`/nexus-generate-mvp`**: Analyzes deliverables and generates a complete issue backlog with dependencies, phase-batched for cross-conversation safety.
- **`/nexus-close-project`**: Formal closure with archival, pattern extraction, and cleanup.

Projects define **phases** (discovery, foundation, implementation, polish — or whatever fits the domain) and **deliverables** categorized as MVP, Enhanced, or Future. Success constraints follow the *Metron Ariston* principle — "just enough structure organized right."

### Sprints

Sprints are batches of work organized by theme and mode:

- **THEMED**: High coherence — same domain, all issues complete each phase before any advances.
- **MIXED**: Diverse work — different domains, each issue completed end-to-end before the next.
- **DEDICATED**: Single complex issue — full attention on one thing.

`/nexus-organize-sprint` handles the full planning workflow: landscape assessment (project context, dependency chains, candidate issues), queue evaluation (structural validation, change detection, fix proposals), sprint composition (anchor selection, companion grouping, mode determination, capacity balancing), and creation (sprint-state from template, registry updates, queue management).

Sprint capacity targets ~9 complexity points. The system tracks a **sprint queue** with up to 3 planned future sprints and a dependency map showing critical chains.

### Issues

Issues are the unit of work, following a three-phase lifecycle:

```
Create → Analyze → Implement (or Research) → Evaluate → Close → Archive
```

Each issue gets an **ISS-XXX.md** file with scaffolded sections (simple for complexity 1–2, comprehensive for 3–5) and a registry entry with 18 prefixed YAML fields for reliable patching.

**Issue types**: Bug, Feature, Improvement, Refactor, Documentation, Question, Research, Creative. Each type adapts the methodology — bugs prioritize root cause analysis and require a reproduction check, research issues follow the A→R→E lifecycle, creative issues track drafts instead of files.

**Phase scores** (1–5) track progress: Analysis (A), Implementation (I), Evaluation (E). Score ≥ 4 triggers a phase transition prompt. All scores use a **two-place update protocol** — written to both the registry and sprint-state, and read back from both to confirm they match. ISS files carry content only; the registry is the single source of truth for scores.

**`/nexus-create-issue`** offers three modes: Full (interactive wizard), Quick (auto-fill from brief input), and Backend (called by other operations with complete data). It auto-generates titles, detects duplicates, assesses complexity across 5 dimensions, and scaffolds ISS files against `issue-specification.md` as the authoritative template.

### Patterns

Patterns are the system's knowledge layer — reusable strategic wisdom extracted from successful work. They are NOT documentation of what happened, but guidance for what to do next time.

Every pattern must pass a **4Q validation gate** before creation:
1. **Strategic** — guides future decisions, not documents past?
2. **Non-obvious** — would someone NOT do this without being told?
3. **Generalizable** — applies to multiple contexts?
4. **Wisdom** — what principle makes this worth remembering?

Patterns have types (principle, methodology, practice, solution), maturity levels (emerging → validated → proven → established), and tracked effectiveness. When Claude applies one, it must say so with a `📐` marker at the moment of application — silent use is a violation, because it corrupts the effectiveness data.

At closure each applied pattern gets an honest verdict, never an automatic success: **helped** (contributed beyond what the framework already enforces), **neutral** (applied, but added nothing a standing rule didn't already cover), or **hindered** (misled or caused rework). A pattern that merely restates a rule already in `CLAUDE.md` is capped at neutral by design. The system currently maintains 52 active patterns under this scoring.

---

## Methodology Skills — Phase-Specific Intelligence

Each work phase loads a dedicated methodology skill that provides step-by-step guidance. These are not rigid scripts — they're adaptive workflows that scale with issue complexity. Every one of them uses a **3-load architecture**: complexity 1–2 runs inline from `SKILL.md`, complexity 3+ additionally loads a thinking toolkit (`complex.md`) and an issue-type file (`types/*.md`).

### `/nexus-analyze` — Strategic Thinking (Phase A)

Gather → Select → Think → Propose → Plan → Persist.

Issue understanding with 5-dimension complexity assessment, cognitive tool recommendation (complexity ≥ 3), search-before-create discovery, pattern matching via `/nexus-match-pattern`, strategic approach selection, cross-cutting scope investigation, multi-topic design with progressive clarification, adversarial self-review, and a mandatory user approval gate on the plan.

**Simple path** (complexity 1–2): skips tools, patterns, and approaches — straight from understanding to design to plan.

### `/nexus-research` — Knowledge Production (Phase R)

Setup → Scope → Survey → Deep Investigation → Analysis → Deliverable → Decision.

For Research-type issues, which run A→R→E and never reach Build. Three modes — **Adoption** (evaluate something for use), **Comparative** (compare alternatives), **Exploratory** (investigate a question) — one workflow adapted per-step. Produces structured deliverables with source quality tiers and bias checks, and enforces a primary-source gate before any analytical verdict: research summaries are feedstock, not substitutes for the artifacts they summarize.

### `/nexus-build` — Execution (Phase I)

Orient → pattern matching → plan verification → phase-by-phase implementation → test execution → drift detection → quality review → commit → transition.

Test strategy is defined before implementation, because tests define what success looks like. Each phase ends with an ISS update and a checkpoint. Includes a touchpoint census that greps the whole file-class a change belongs to rather than trusting the plan's enumeration, scope-escalation detection, mandatory adversarial self-evaluation at complexity 3+, and an optional independent agent review pass.

**Batch sub-mode**: when the same procedure applies to 2+ remaining targets with no novel design decisions left, Build formalizes a playbook and switches to batch execution via an internal `_build_mode` flag. Each target is assessed for fit, executed against the playbook, and checked for conformance; anything that diverges escalates back to full Build.

### `/nexus-validate` — Assessment (Phase E)

Setup → Test → Assess → Gate → Accept → Document & Close.

Comprehensive test execution distinct from Build's incremental verification, bidirectional success-criteria mapping (forward: every criterion has evidence; reverse: every change traces to a criterion), plan-vs-actual implementation review, quality assessment, a pattern validation gate (no "applied" pattern may remain unassessed), user acceptance, lessons-learned capture, and closure delegation.

Validate also runs at **sprint level**: per-issue Validate asks "did this issue meet its criteria?", while `/nexus-validate SPRINT-NNN` asks whether the closed issues *as a set* drift, contradict, or leave gaps no single issue owned.

### `/nexus-maintain` — System Governance (Maintenance Sprints)

Orient → Planning → Execution → Verification → Report & Closure.

Orchestrates the maintenance operations in dependency order with checkpointing after each, supports multi-conversation resumption via system-state tracking, calculates health improvement, and recalibrates degradation rates for predictive scheduling. (Stable snapshots are `/nexus-changelog-scan`'s job, not this one's.)

### `/nexus-brainstorm` — Parallel Phase

Not part of the A→I→E lifecycle at all. You can enter it from any phase and leave to any phase. Brainstorm doesn't execute issue phases or run sprint operations — it's for thinking out loud, with the continuous protocols (context tracking, zone monitoring, pattern transparency) still active.

---

## Cognitive Tools — A Thinking Toolkit

Three loadable tool packs, pulled in on demand when complexity warrants it (auto-suggested at complexity ≥ 3). Phase-independent.

### Mental Models — `/nexus-mental-models` (6)
- **First Principles** — Break to fundamentals, question assumptions, rebuild from basics
- **Systems Thinking** — Map component relationships, feedback loops, leverage points
- **Inversion Thinking** — What makes it fail? Remove barriers rather than add features
- **Decision Trees** — Map multi-step decision paths where early choices constrain later options
- **Probabilistic Thinking** — Outcome ranges, not point predictions
- **Analogical Reasoning** — Map solutions across from known domains

### Problem-Solving Tools — `/nexus-problem-solving` (7)
- **Adversarial Review** — Structured critical review with a must-find mandate: every review surfaces at least one genuine issue, classified HIGH / MEDIUM / LOW. Mandatory for Build self-evaluation at complexity ≥ 3
- **Mental Simulation** — Walk through execution step-by-step before implementing
- **Pre-Mortem Analysis** — Assume the plan failed, then backtrack the causes
- **Blind Spot Identification** — Cognitive-bias checks, assumption surfacing, perspective and temporal checks
- **Hypothesis-Driven Framework** — Structure problems as testable hypotheses
- **Root Cause Analysis** — Five Whys, with Why Tree and Why-How Bridge variants
- **Counterfactual Reasoning** — Reverse assumptions, explore alternative histories, shift time frames

### Strategic Approaches — `/nexus-strategic` (9 + a protocol)
Nine execution methodologies selected during analysis: Analytical Decomposition, Iterative Refinement, Proof-of-Concept, Foundation-First, Risk-Forward, Tech Debt Paydown, Divergent-Convergent, Constraint Relaxation, and Test-Driven Development. The pack also carries **Strategic Reflection** — not a tenth approach but a separate protocol: a dual-perspective check that generates a proposal in tactical mode, then validates it in strategic mode by challenging its own assumptions.

---

## Self-Maintaining System Health

NEXUS doesn't just manage projects — it maintains itself through a predictive health system.

### 10 Maintenance Operations

| Operation | Purpose |
|-----------|---------|
| **`/nexus-health-diagnostic`** | Aggregates operation scores with staleness penalties into a unified health dashboard |
| **`/nexus-pattern-maintenance`** | Three-tier pattern health: registry scan → deep 4Q re-qualification → similarity analysis and merge |
| **`/nexus-registry-cleanup`** | Three-tier validation of all 4 YAML registries against authoritative specifications |
| **`/nexus-issue-validation`** | Semantic validation of issues — phase evidence, status consistency, deliverable coverage, project alignment |
| **`/nexus-backup-optimization`** | Content-aware backup lifecycle management with milestone preservation |
| **`/nexus-maintenance-scheduler`** | Predictive scheduling using calibrated per-operation degradation rates and adaptive cycles |
| **`/nexus-changelog-scan`** | Regenerates the version registry from system file headers |
| **`/nexus-subsystem-verification`** | Deep domain verification — source triangulation, per-file connection alignment, mental execution traces |
| **`/nexus-rebuild-architecture`** | Regenerates `NEXUS-Architecture.md` from the live skill and file set |
| **`/nexus-rollback`** | Version-aware rollback using git history and changelog snapshots |

Two more sit outside the maintenance cycle but do the same kind of work: `/nexus-staleness-checker` compares guide references against current source versions, and `/nexus-prune-memory` consolidates the cross-sprint memory layer.

### Predictive Maintenance

The system learns its own degradation patterns. After each maintenance cycle, it recalibrates per-operation degradation rates using a blended formula (70% historical + 30% observed). The scheduler uses these rates to predict when each operation will breach its threshold, calculates an adaptive maintenance cycle, and writes a decision that `/nexus-organize-sprint` reads during planning.

Operations are classified by urgency: **quick_trigger** operations can drive a standalone maintenance recommendation on their own; **cycle_only** operations only feed the scheduled cycle. The prediction system tracks its own accuracy and recalibrates confidence based on data depth and velocity stability.

### Resilience & Recovery

Things go wrong — files get corrupted, patches fail, context overflows mid-work. NEXUS handles this:

- **Git commits at checkpoints**, phase transitions, and sprint closure — the durable undo layer for everything text
- **Binary backups** to `.nexus/backups/` before any binary deliverable is overwritten, with retention managed by `/nexus-backup-optimization`
- **Rollback** to any previous version or stable sprint snapshot — single file or system-wide
- **Degraded mode** — if components are unavailable, the system continues with reduced capability rather than failing entirely, following `Emergency-Reference.md`
- **Checkpoint recovery** — if a conversation ends unexpectedly or is compacted mid-work, the last checkpoint preserves progress and the next conversation detects and resumes from it
- **Registry rebuilds** — `/nexus-changelog-scan` reconstructs the version registry from file headers alone, no manual tracking needed

### The Evolution Pipeline

NEXUS captures learning continuously and processes it in cycles:

```
Capture → Preserve → Transfer → Index → Feedback
```

1. **During work**: insights land in sprint-state `[EXPERIENCE_CAPTURE]` — system issues (violations, gaps, bugs) and behavioral insights (preferences, corrections)
2. **At checkpoints**: preserved to sprint-state on disk
3. **At sprint closure**: patterns are created or updated, issues archived, and preferences amended
4. **Indexed**: `/nexus-index-sprint` writes the sprint's decisions, discoveries, unresolved debt, rejected pattern candidates, and closure learnings into the cross-sprint **memory layer** — seven JSONL files under `.nexus/memory/`
5. **Feedback**: later sprints read that memory during analysis and planning — "what did we decide about X" is answered from the record, not from re-derivation

The memory layer has no database and no embeddings: the LLM reads flat files and does the semantic search itself. The files are derived caches — NEXUS works identically without them.

### Behavioral Preferences

Rather than rigid rules, NEXUS uses a flat preference system with 4 importance levels, all declared in `CLAUDE.md`:

- **Core** (always apply, silently): elegant minimum, honest feedback, quality over speed
- **High** (mentioned when they shape a decision): adapt-not-adopt, verify external claims, complete integration, pause before major changes, fresh context at boundaries, thorough understanding first
- **Medium** (applied when the context matches): file-by-file implementation, realistic planning, ask-don't-assume, one topic at a time, mental simulation at gates, and several rules about how findings and scope changes must be surfaced rather than absorbed
- **Low** (considered, not prioritized)

Preferences shape how methodology steps are interpreted — the same step produces different behavior depending on which preferences are active. They are earned, not guessed: each one was added because a real conversation went wrong without it, and they evolve through the learning loop at sprint closure.

---

## Context & Token Management

Working within an LLM's context window is a fundamental constraint. NEXUS manages this actively:

**Memory-First Protocol**: before every read, check what's already in context. Re-reading a file already loaded is a protocol violation — memory costs nothing, a re-read costs thousands of tokens.

**Section-Based Loading**: files mark named regions with `[Section: Name]` markers, enabling partial reads that save 70–90% of tokens versus full file loads. Sprint-state's bootstrap list can name a section directly, so the boot loads only what the next phase actually needs.

**Token Tracking**: a hook injects the real numbers into every turn — used tokens, percentage, and a bar — so NEXUS reads them rather than estimating. Zone thresholds are Green 0–70%, Yellow 70–80%, Red 80%+, as described under Continuity above.

**Absolute-token awareness**: percentage is not the whole picture. Attention quality degrades past roughly 300K tokens regardless of window size, so NEXUS prefers a fresh conversation at phase boundaries — especially before adversarial review, where anchoring on the previous phase's choices is the specific risk.

**Checkpoint Protocol**: `/nexus-checkpoint` manages state preservation with ISS verification, experience capture, structure enforcement, and a git commit. It supports incremental patches (changed sections only) and full writes (when structural drift is detected). Every checkpoint verifies ISS content is persisted on disk before saving sprint-state, and prints gate markers proving each step ran.

---

## Navigation & Commands

You interact with NEXUS in natural language. The routing map in `CLAUDE.md` maps what you say to the skill that handles it:

```
"create issue about X"     → /nexus-create-issue
"work on ISS-042"          → /nexus-work-issue
"organize sprint"          → /nexus-organize-sprint
"show patterns"            → /nexus-list-patterns
"system health"            → /nexus-health-diagnostic
"save checkpoint"          → /nexus-checkpoint
"help with patterns"       → /nexus-help
"recall what we decided"   → memory layer read
"dashboard"                → /nexus-dashboard
```

You don't need to memorize commands. `show menu` provides guided navigation for discovery, and `help with X` answers questions with progressive depth — from memory first, then guides, then system files. Triggers are matched even when embedded in an ordinary sentence: "let's close this sprint" works as well as "close sprint."

---

## Documentation System

NEXUS generates and maintains its own documentation:

- **`/nexus-guide-creator`**: introspects the live system and generates human-readable guides with version tracking
- **`/nexus-help`**: the documentation front door. Progressive disclosure — answers from memory first (free), then guides (cheap), then system files (expensive). It also carries two browsing modes: say **"browse docs"** for the registry-driven catalog with status and categories, or **"learning path"** for a reading sequence based on your role and goals
- **`/nexus-staleness-checker`**: detects outdated guides by comparing source file versions against each guide's declared references
- **`/nexus-dashboard`**: on-demand visual data exploration across issues, patterns, project, sprint, maintenance, and documentation scopes

All of these read `documentation-registry.yaml` dynamically, so adding or archiving a guide updates every consumer at once.

---

## Common Questions

**"Isn't this massive overhead for simple tasks?"**
NEXUS scales down. Simple issues (complexity 1–2) skip cognitive tools, pattern matching, strategic approaches, and deep analysis — the workflow goes straight from understanding to design to implementation. And if you just want to think without committing to a phase, `/nexus-brainstorm` sits outside the lifecycle entirely. The full methodology only activates when complexity warrants it.

**"Do I need to learn a whole framework?"**
No. The menu system guides discovery, natural language commands work without memorization, and the help system provides progressive answers at any depth. Most users start with "create issue," "work on ISS-XXX," and "save checkpoint" — everything else is discoverable as you need it.

**"What if something breaks?"**
Every checkpoint commits to git, so you can roll back any file to any previous state. Binary deliverables get timestamped backups before being overwritten. If a component is unavailable, the system operates in degraded mode while you fix things, and the checkpoint protocol means even an unexpected conversation end loses at most the work since the last save.

**"Does this work for non-software projects?"**
Yes. The setup wizard adapts to any project type — research, creative, strategic, educational, data analytics. Phase structures and issue breakdowns use domain-native language. A documentary project gets "Pre-Production → Production → Post-Production," not "Foundation → Implementation → Testing."

---

*NEXUS — Because AI-assisted work shouldn't lose context between conversations.*
