# Project Management Guide
*Version: 2.3.0 | Date: 2026-08-28 | Sprint: 112*
*Category: domain | Level: intermediate*

> **Purpose**: Complete guide to project-level work in NEXUS — from first-run initialization through project closure. Covers the full project lifecycle, all 7 operations, the domain-specific template system, and the project-state.md data model.

**Source files:**
- .claude/skills/nexus-init-project/SKILL.md v3.0.0
- .claude/skills/nexus-setup-project/SKILL.md v5.2.0 (includes Update Mode)
- .claude/skills/nexus-generate-mvp/SKILL.md v3.1.1
- .claude/skills/nexus-project-status/SKILL.md v2.0.1
- .claude/skills/nexus-update-state/SKILL.md v2.1.0
- .claude/skills/nexus-close-project/SKILL.md v2.4.0
- .nexus/templates/project-state-template.md v2.10.1
- .nexus/templates/project-type-template.md v1.0.1
- .nexus/active/NEXUS-Architecture.md v4.1.0

---

## Overview
[Section: Overview]

The Project domain manages the highest level of work in NEXUS. While sprints batch issues and issues track individual tasks, the *project* defines what you're building, why it matters, and how you'll know when it's done.

Seven operations handle the full project lifecycle:

```
/nexus-init-project → /nexus-setup-project → /nexus-generate-mvp
                                       ↓
              /nexus-setup-project (Update Mode, anytime)
              /nexus-project-status (anytime, read-only)
                                       ↓
              /nexus-update-state ← (called by close-sprint)
                                       ↓
                            /nexus-close-project
```

Everything revolves around one central file: **project-state.md** — a 13-section document that holds your project's vision, scope, deliverables, phases, constraints, risks, metrics, decisions, and progress. Operations progressively build and update this file throughout the project's life.

Starting with v4.0.0, the setup wizard and issue generator are driven by **domain-specific templates** — 13 project-type profiles that provide domain-native language, deliverable patterns, phase structures, risk catalogs, and issue breakdown guidance. A research project gets methodology-oriented phases and literature-review issue archetypes; a creative project gets production-oriented phases and content-focused deliverables. The wizard adapts to your domain rather than forcing everything through a generic software lens.

[/Section: Overview]

---

## Project Lifecycle
[Section: Project-Lifecycle]

Every project passes through a lifecycle tracked by the `_project_lifecycle` field in sprint-state.md:

```
not-defined → defining → active → closed
     │            │          │         │
 init-project  setup-project │    close-project
                             │
                     normal work happens here
                     (sprints, issues, patterns)
```

**not-defined** — Fresh NEXUS installation. `/nexus-start` detects this at STEP 5 (Lifecycle Check) and invokes `/nexus-init-project`. No manual action needed — just type "start" in a new conversation.

**defining** — State files exist but the project isn't configured yet. `/nexus-start` invokes `/nexus-setup-project` to continue the wizard. This state exists to handle interruptions — if context runs out mid-wizard, the next conversation picks up where you left off.

**active** — Normal operation. `/nexus-start` proceeds to sprint loading, phase detection, and work. This is where you spend most of your time.

**closed** — Project archived. Framework files stay active for the next project. Use "setup project" to begin a new one.

[/Section: Project-Lifecycle]

---

## The Project Type System
[Section: Project-Type-System]

NEXUS ships with 13 domain-specific project-type profiles that drive the setup wizard and issue generator. Each profile is a markdown file under `.nexus/templates/project-types/` containing domain-native content organized in 7 standard sections.

### Available Types

| Category | Types |
|----------|-------|
| Technical | Software / Product Dev, System Integration, Data & Analytics, Migration / Transition |
| Research | Research & Analysis, Complex Problem Solving |
| Business | Strategic / Business Planning, Operations / Process, Event / Campaign, Compliance / Audit |
| Creative | Product Design, Educational / Training, Creative / Content |

### What a Profile Provides

Each profile contains sections consumed at specific points during the project setup wizard and issue generation:

**Profile** — Behavioral frame: wizard emphasis, phase character, typical deliverables, and depth setting (light/standard/thorough) that controls how detailed the wizard's questions get.

**Framing-Hints** — Per-step guidance: how to phrase the vision question, what scope boundaries matter, how to frame deliverables, risks, effort, and constraints in domain-native language.

**Deliverable-Templates** — Concrete examples of MVP, Enhanced, and Future deliverables with quality criteria. The wizard proposes from these, and you validate and extend. Includes categorization guidance for what makes something MVP vs Enhanced vs Future in that domain.

**Phase-Templates** — Domain-native phase structures at three complexity levels (Simple: 2-3 phases, Standard: 3-4, Complex: 5-6). A documentary project gets Concept Development → Research → Pre-Production → Production → Post-Production, not generic "Foundation → Implementation → Testing."

**Risk-Catalog** — Domain-specific risks (5-8 per type) with probability, impact, and mitigation hints. Generic project risks are handled by the wizard engine; profiles add domain-specific concerns.

**Metrics** — Quantitative and qualitative metrics relevant to the domain, plus typical milestone examples.

**Issue-Breakdown** — Breakdown patterns for `/nexus-generate-mvp`: how deliverables naturally decompose (component-oriented, methodology-oriented, improvement-cycle-oriented), issue archetypes with typical complexity, and example titles in domain-native language.

### Hybrid and Custom Types

If your project blends types ("research project that will produce a software tool"), the wizard captures primary and secondary types. The primary type's template is loaded; secondary aspects are noted and influence proposals where relevant. If no template matches, the meta-template (`.nexus/templates/project-type-template.md`) provides structural reference while the wizard draws on general domain knowledge.

[/Section: Project-Type-System]

---

## First-Run Initialization
[Section: First-Run]

**Command**: Automatic (`/nexus-start` detects it) or `init project`

When you start NEXUS for the first time, `/nexus-start` detects `_project_lifecycle: not-defined` and invokes `/nexus-init-project`. This operation:

1. **Checks for orphans** — looks in `.nexus/issues/` for leftover ISS files from a previous installation. If found, warns you and offers options: proceed with a fresh registry (files preserved but unregistered), or cancel to investigate first.

2. **Inventories state files** — determines which of 4 files need creation from templates (project-state.md, system-state.md, sprint-queue.md, issues-registry.yaml). Files that ship ready (sprint-state.md, patterns-registry.yaml, changelog-registry.yaml, documentation-registry.yaml) are left untouched.

3. **Instantiates from templates** — creates each missing file, verifies creation, and reports results.

4. **Sets lifecycle to `defining`** and invokes `/nexus-setup-project`.

The entire flow is automatic — you just start a conversation and the framework guides you through.

### Starting a Second Project

If you already have a working NEXUS installation and want to start another project, **install NEXUS into the new folder with the plugin's `setup` skill** — open Claude Code in the target folder and run `/nexus:setup`. It copies the framework from the installed plugin, writes `settings.local.json`, checks prerequisites, and offers `git init`. Then say "start": boot detects first-run and guides you through setup.

> **Changed at Sprint 112.** `init project` used to carry a second "new-project" mode that copied the framework into a new folder. It was retired: it was a second, drifted copy of the distribution manifest — it omitted `.claude/agents/`, `derivations.yaml` and `.nexus/tests/`, copied the raw development `settings.json`, and shipped the whole pattern library rather than the curated set. There is now one copier and one manifest. `init project` still handles first-run initialisation of an installation that already has the framework files.

[/Section: First-Run]

---

## Project Setup Wizard
[Section: Setup-Wizard]

**Command**: `setup project` or `define project`

The setup wizard is an 8-step collaboration (STEP 0-7) that creates your project definition. It's not a form — NEXUS proposes content based on your project type's domain template, challenges thin answers, and enriches your inputs with domain knowledge.

### The 8 Steps

| Step | What It Collects | Key Features |
|------|-----------------|--------------|
| 0 — Context Setup | Resume detection, template copy | Detects interrupted wizards and offers to resume |
| 1 — Identity | Name, type, domain, documents, resources | Loads domain template after type selection; extracts from uploaded docs |
| 2 — Vision & Purpose | Vision (what, why, observable success) | Type-specific framing; synthesis reflection to catch misunderstanding |
| 3 — Scope & Constraints | Constraints first, then scope shaped by them; success constraints; optional constitution | Metron Ariston principle: MVP minimum, sufficiency threshold, completion criteria |
| 4 — Deliverables | MVP/Enhanced/Future with quality criteria | Template-proposed deliverables; priority pressure test; effort preview |
| 5 — Phases & Effort | Phase structure, deliverable allocation, scope-effort calibration | Template-driven domain-native phase names; complexity-scaled depth |
| 6 — Risks & Validation | Risks, metrics, stakeholders, coherence check, elevator pitch | Cross-step validation catches misalignment; template risk catalog |
| 7 — Review & Finalize | Full review, thin section flagging, name revisit, finalization | Reads from disk to verify; cleans runtime sections; sets lifecycle active |

### How the Wizard Uses Templates

After you select a project type in STEP 1, the wizard loads the matching domain profile from `.nexus/templates/project-types/`. From that point, every step draws on the template:

- STEP 2 uses `Framing-Hints.vision_question` to ask about your vision in domain-native language
- STEP 3 uses `Framing-Hints.constraint_emphasis` and `scope_emphasis`
- STEP 4 proposes deliverables from `Deliverable-Templates` examples
- STEP 5 proposes phases from `Phase-Templates` at the assessed complexity level
- STEP 6 proposes risks from `Risk-Catalog` and metrics from `Metrics`

### Key Features

**Progressive writes**: project-state.md is patched after each step, not held in memory until the end. If context runs out mid-wizard, the next conversation detects where you left off and offers to resume. STEP 0 reads the partially populated file and determines exactly which step to resume at.

**Document extraction**: Upload existing specs, requirements, or briefs at STEP 1. NEXUS extracts vision, scope, deliverables, and constraints adapted to your project type — a PRD yields features and user stories, a research brief yields questions and methodology, a technical spec yields components and architecture. Contradictions between multiple documents are flagged explicitly.

**Project Constitution** (optional): Non-negotiable principles captured at STEP 3 that get checked during analysis and evaluation. For example, "all data stays client-side" or "no vendor lock-in." If you don't have any, skip it — the checks are automatically bypassed.

**Success constraints** (STEP 3) — three questions that prevent scope creep:
- **MVP Minimum**: What's the absolute minimum that would be valuable?
- **Sufficiency Threshold**: Where do diminishing returns start?
- **Completion Criteria**: When do we declare the project done?

**Priority pressure test** (STEP 4): "If you could only deliver half of your MVP items, which ones?" Forces honest prioritization before effort estimation.

**Elevator pitch synthesis** (STEP 6): The wizard distills your project into two sentences. If the synthesis feels wrong, something upstream needs revisiting — this is the most powerful single validation.

**Thin answer handling**: If you give persistently brief answers, the wizard fills gaps with reasonable defaults from the template marked as `{inferred from project type}` and flags them for revisit at STEP 7.

**Type changes mid-wizard**: If you realize the project type is wrong, the wizard updates the definition, reloads the correct template, and offers to revisit steps that would have been framed differently.

### After Setup

You're offered three options: generate MVP issues from deliverables (recommended), organize your first sprint, or stop for now.

[/Section: Setup-Wizard]

---

## Generating Issues from Deliverables
[Section: Issue-Generation]

**Command**: `generate mvp issues` or `create issues from deliverables`

After project setup, this operation analyzes your deliverables and generates a complete issue backlog — broken down using domain-native patterns, assessed, dependency-mapped, and allocated to phases.

### How It Works

**STEP 0 — Load Context**: Loads project-state, issues-registry, issue-specification, and the domain template. Detects partial completion from interrupted sessions and offers to resume — it matches existing issues against the plan to identify exactly what remains.

**STEP 1 — Analyze & Break Down**: The creative core. For each deliverable, the operation proposes a breakdown guided by the template's `Issue-Breakdown` section:

- The template's `breakdown_pattern` determines HOW deliverables decompose (component-oriented for software, methodology-oriented for research, improvement-cycle-oriented for operations)
- `typical_structure` provides issue archetypes with typical complexity as starting points
- `example_titles` demonstrate domain-native naming to match
- `Cross-Cutting Patterns` flag common cross-deliverable issues

Each proposed issue includes a rich description connecting it to its parent deliverable, verifiable success criteria derived from the deliverable's quality criteria, a domain-appropriate type, and dependency mapping. For deliverables with significant uncertainty, a dedicated exploration/feasibility issue is proposed before committing to full implementation.

Breakdown complexity scales with the deliverable: simple deliverables get 1-2 issues, moderate 3-4, complex 5-7. The summary is presented grouped by deliverable with full specs available on request.

**STEP 2 — Assess Issues**: Each issue gets priority (Critical/High/Medium/Low), impact, complexity (1-5), and dependency mapping. Template `typical_complexity` values provide baselines adjusted for specific context.

**STEP 3 — Plan Phase Allocation**: Issues are mapped to project phases based on their parent deliverable's target phase, ordered by dependency level, with sprint estimates (~9 complexity points per sprint). Mismatches between the plan and the phase's estimated sprint count are flagged.

**STEP 4 — User Approval**: The complete plan is presented with options to create all, review by deliverable (showing full specs per group), adjust assessments, or cancel.

**STEP 5 — Phase-Batched Creation**: Issues are created one phase at a time via create-issue backend mode. After each phase batch, project-state is updated (deliverable `issue_refs` and phase `issues_planned`) and a checkpoint is offered. For phases with 8+ issues, sub-batches with intermediate checkpoints prevent context exhaustion. Cross-phase dependency linking uses a title→ID mapping that resolves forward references after all phases are created.

**STEP 6 — Completion Report**: Summary of what was created, with an offer to organize the first sprint if context allows.

### Why Phase-Batched?

Each issue creation involves multiple operations (file write + registry entry + verification). For a project with a large issue backlog, creation alone can consume significant tokens. Phase batching with checkpoints between batches ensures no work is lost if context runs out. On resumption, the operation detects completion state from project-state's `issue_refs` and the issues-registry, distinguishes clean between-phase boundaries from messy mid-batch interruptions, and picks up exactly where it left off.

### After Generation

You're offered to organize your first sprint immediately, or defer to the next conversation.

[/Section: Issue-Generation]

---

## Updating Project Parameters
[Section: Parameter-Updates]

**Command**: `update project parameters` or `modify project scope`

This is **Update Mode** of `/nexus-setup-project` — the same skill that runs the initial wizard, entered directly by this command (or offered automatically when the wizard detects a fully-populated project-state.md and you decline a fresh overwrite). It lets you edit any project parameter after initial setup — vision, scope, deliverables, phases, constraints, resources, stakeholders. It includes impact analysis on affected issues and cascade updates.

### The Edit Cycle

1. **Category menu** — choose what to update (Identity, Scope, Deliverables, Structure, Execution, Metrics, Stakeholders, or Review All)
2. **Edit** — current values are presented; changes collected through conversation
3. **Impact analysis** — cascade effects identified before writing:
   - Deliverable removed → orphaned issues detected (only truly orphaned — issues linked to multiple deliverables survive if any parent remains)
   - Deliverable added → suggests running `/nexus-generate-mvp`
   - Phase structure changed → flags reallocation needs
   - Priority implications from recategorization (MVP ↔ Enhanced ↔ Future)
4. **Apply** — patches project-state, cascades to registry if issues affected
5. **Report** — summary with next-step suggestions
6. **Loop** — return to category menu for another edit, or exit

### What It Doesn't Do

This operation modifies the project *definition*. It does not update progress data (that's `/nexus-update-state`, called automatically by close-sprint) or generate issues (that's `/nexus-generate-mvp`).

[/Section: Parameter-Updates]

---

## Checking Project Status
[Section: Project-Status]

**Command**: `project status` or `show project`

A read-only report that draws from 11 of 13 project-state sections plus the issues registry. It presents:

- Phase progress with visual bars and issue counts per phase
- Deliverable completion status grouped by tier (MVP/Enhanced/Future)
- Issue statistics (created, open, closed, blocked)
- Success tracking against your defined metrics, milestones, and success constraints
- Recent sprint activity and key decisions
- Risk alerts and watch items
- Suggested next actions tailored to the current project state

The report adapts to your project's actual state — early projects focus on setup completeness, mid-project shows full progress, near-completion emphasizes success criteria. Sections that aren't configured show "Not configured" with a suggestion for how to populate them.

No files are modified by this operation.

### Visual Dashboard

For an interactive visual view, use `dashboard` and select **Project**. The dashboard generates a live React artifact with phase progress bars, deliverable completion, milestone timeline, and open issues with filtering.

[/Section: Project-Status]

---

## Sprint Closure Feedback
[Section: Sprint-Closure-Feedback]

**Command**: `update project state` (usually called automatically by close-sprint)

This backend operation feeds sprint results into project-state.md at each sprint closure. It calculates phase completion from resolved issues, logs the sprint's achievements, captures key decisions and learnings, assesses project health, and updates milestones.

### What It Updates

| Section | What Changes |
|---------|-------------|
| Metadata | `_updated`, `_current_phase`, `_completion_percentage`, `_health_status` |
| `[PROJECT_PHASES]` | Per-phase completion %, status, sprint list |
| `[PROGRESS_OVERVIEW]` | Sprint log entry, issue counters, blocked count |
| `[CRITICAL_DECISIONS]` | Architecturally significant decisions from the sprint |
| `[NEXT_PHASE_NOTES]` | Priorities, learnings, watch items, opportunities |
| `[MILESTONE_TRACKING]` | Milestone completion when phases reach 100% |

### The Update Flow

1. **Calculate phase completion** — counts resolved vs planned issues per phase, determines current phase, detects phase transitions
2. **Prepare sprint data** — derives achievements in user-meaningful terms, scans sprint-state for key decisions and learnings, proposes what to capture at project level
3. **User approval** — presents everything in one pass (Accept all / Select items / Skip)
4. **Apply patches** — updates all affected sections with backup, assesses health (Green/Yellow/Red based on progress, blocked issues, and MVP deliverable status)
5. **Report** — shows updated phase progress, flags phase transitions, celebrates project completion

### What It Never Touches

`[PROJECT_DEFINITION]`, `[SCOPE_AND_BOUNDARIES]`, `[DELIVERABLES]`, `[STAKEHOLDERS]`, `[CONSTRAINTS_AND_RISKS]`, `[SUCCESS_METRICS]`, `[KEY_RESOURCES]` — these are definition sections owned by setup-project and update-project-parameters.

[/Section: Sprint-Closure-Feedback]

---

## Project Closure
[Section: Project-Closure]

**Command**: `close project` or `archive project`

Formal closure validates completion, archives project files, extracts patterns, and cleans up active state.

### The Closure Process

1. **Validate completion** — checks phase completion percentages and open issues. Incomplete projects can still close with explicit confirmation.

2. **Disposition open issues** — each open issue needs a decision:
   - **Archive** — moves with the project
   - **Reject** — closed via close-issue batch
   - **Export for future use** — a copy of the ISS file + its registry entry is saved to a folder you choose, for reuse in a future project; the issue itself is still archived with the rest (this is a copy, not a carve-out)

3. **Generate project summary** — a self-contained archive document with vision, statistics, phases, deliverables, critical decisions, and milestones.

4. **Extract project-level patterns** (optional) — scans the project's history for reusable wisdom. Created patterns stay in active patterns-registry for future projects.

5. **Archive** — moves project-specific files to `.nexus/archived/projects/{name}/`:
   - State files (project-state, sprint-state, sprint-queue)
   - issues-registry.yaml and all ISS files
   - The project's cross-sprint memory layer (`.nexus/memory/*.jsonl` + SCHEMA.md)
   - Sprint folders

   Framework files stay active: CLAUDE.md, `.claude/skills/nexus-*/` (all skills), `.nexus/templates/`, patterns-registry.yaml, changelog-registry.yaml, documentation-registry.yaml, system-state.md.

6. **Record closure** — updates system-state with closure record.

### Safety Rule

The archive must be verified complete before any cleanup of active files. Partial archive + cleanup = data loss. The operation enforces this with a verification gate.

[/Section: Project-Closure]

---

## The project-state.md Data Model
[Section: Data-Model]

project-state.md has 13 sections organized in three groups:

### Definition Sections
*Set by setup-project, edited by update-project-parameters*

| Section | Purpose |
|---------|---------|
| `[PROJECT_DEFINITION]` | Title, vision, problem domain, project type (from 13 types), project domain |
| `[SCOPE_AND_BOUNDARIES]` | In/out scope, boundaries, success constraints (MVP minimum, sufficiency, completion) |
| `[PROJECT_CONSTITUTION]` | Optional non-negotiable principles with enforcement points |
| `[DELIVERABLES]` | MVP/Enhanced/Future deliverables with quality criteria, target phases, and issue refs |
| `[STAKEHOLDERS]` | Users, decision makers, communication plan |
| `[CONSTRAINTS_AND_RISKS]` | Timeline, resources, technical/methodological constraints, risks with mitigations, dependencies, preliminary technology |
| `[SUCCESS_METRICS]` | Quantitative/qualitative metrics, milestones and checkpoints |
| `[KEY_RESOURCES]` | Specifications, external resources (captured at STEP 1 of wizard) |

### Progress Sections
*Updated by update-project-state at sprint closure*

| Section | Purpose |
|---------|---------|
| `[PROJECT_PHASES]` | Phase definitions with completion %, status, sprint lists, issue allocations, estimated sprints |
| `[PROGRESS_OVERVIEW]` | Sprint log, issue counters, health, at-risk items |
| `[CRITICAL_DECISIONS]` | Recent, architectural, and technical decisions with rationale |
| `[MILESTONE_TRACKING]` | Milestone targets, actuals, phase associations, and completion status |
| `[NEXT_PHASE_NOTES]` | Priorities, learnings, watch items, opportunities |

### Metadata
*Top of file*: `_updated`, `_project_status`, `_current_phase`, `_completion_percentage`, `_health_status`.

### Writer Separation

This clean separation means no operation conflicts:
- **setup-project** creates all sections (progressive patches through 8 steps)
- **setup-project (Update Mode)** edits definition sections
- **update-project-state** edits progress sections
- **project-status** reads everything, writes nothing

[/Section: Data-Model]

---

## Quick Command Reference
[Section: Commands]

| What You Want | Command | Operation |
|--------------|---------|-----------|
| Initialize NEXUS (first time) | Automatic at boot | `/nexus-init-project` |
| Install NEXUS into another folder | `/nexus:setup` (run there) | plugin `setup` skill |
| Define a new project | `setup project` | `/nexus-setup-project` |
| Generate issues from deliverables | `generate mvp issues` | `/nexus-generate-mvp` |
| Change project scope/vision/deliverables | `update project parameters` | `/nexus-setup-project` (Update Mode) |
| See project progress | `project status` | `/nexus-project-status` |
| Update progress after sprint | `update project state` | `/nexus-update-state` |
| Archive and close project | `close project` | `/nexus-close-project` |

[/Section: Commands]

---

## Common Workflows
[Section: Workflows]

**Starting a brand-new project**: Just open a fresh NEXUS installation and type "start." `/nexus-start` detects first-run → `/nexus-init-project` creates state files → `/nexus-setup-project` walks you through defining the project (with domain-specific guidance from your project type's template) → `/nexus-generate-mvp` breaks deliverables into domain-native issues → `/nexus-organize-sprint` plans your first batch.

**Starting a second project**: Open Claude Code in the new folder and run `/nexus:setup` — the plugin's installer copies the framework there (all 13 project-type profiles included), writes `settings.local.json`, and offers `git init`. Then say "start": boot detects first-run and guides you through setup.

**Changing direction mid-project**: Use `update project parameters` → select the relevant category (Scope, Deliverables, Structure) → impact analysis shows which issues are affected → approve cascades → run `reorganize queue` if major changes.

**Checking if you're on track**: `project status` gives the full picture — phase bars, deliverable completion, risk alerts, milestone tracking, and suggested next actions adapted to your project's current state.

**Closing a completed project**: `close project` → validate completion → disposition any open issues → archive generates a self-contained project record → patterns extracted → framework ready for the next project.

[/Section: Workflows]
