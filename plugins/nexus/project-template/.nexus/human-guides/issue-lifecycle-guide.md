# Issue Lifecycle Guide
*Version: 1.1.0 | Sprint: 110 | Category: domain*

*The complete journey of an issue from creation to archive — phases, operations, ISS file structure, and how methodology skills guide each phase.*

**Source files:**
- .claude/skills/nexus-create-issue/SKILL.md v2.6.0
- .claude/skills/nexus-update-issue/SKILL.md v2.0.1
- .claude/skills/nexus-close-issue/SKILL.md v3.1.0
- .claude/skills/nexus-archive-issue/SKILL.md v2.0.1
- .claude/skills/nexus-view-issues/SKILL.md v2.0.0
- .claude/skills/nexus-work-issue/SKILL.md v2.1.0
- .claude/skills/nexus-decompose-issue/SKILL.md v2.2.0
- .nexus/templates/issue-specification.md v3.10.0
- CLAUDE.md v5.16.0

---

## What Are Issues?
[Section: Introduction]

Issues are the fundamental work units of NEXUS. Every piece of work — fixing a bug, building a feature, researching a technology, refactoring a subsystem — is tracked as an issue. Issues give structure to work by flowing through a defined lifecycle: **Create → Analyze → Implement → Evaluate → Close → Archive**.

Each issue has two representations that stay in sync:

- An **ISS file** (`.nexus/issues/ISS-XXX.md`) that holds all the work content — analysis, plans, logs, results, and closure knowledge. This is the issue's datastore across conversations.
- A **registry entry** in `issues-registry.yaml` that holds queryable metadata — status, scores, priority, dependencies. This is the single source of truth for "what state is this issue in?"

This guide covers the full issue journey: how to create issues, how phases work, what the ISS file looks like, how operations manage the lifecycle, and how everything connects to sprints and patterns.

**After reading this guide you'll understand:**

- How issues flow through their lifecycle (Open → In-Progress → Resolved → Archived)
- The three phases of work (Analysis, Implementation, Evaluation) and their scoring
- What goes in ISS files vs the registry vs sprint-state
- All seven issue operations and when to use each
- How methodology skills (/nexus-analyze, /nexus-build, /nexus-validate) guide phase work
- Research issues and how they differ from standard issues

[/Section: Introduction]

---

## Core Concepts
[Section: Core-Concepts]

### The Three Phases

Every issue (except rejected ones) flows through three work phases, each guided by a methodology extension:

**Analysis** (guided by `/nexus-analyze`) — Understand the problem, design the solution, plan the implementation. Produces the Solution Design and Implementation Plan sections of the ISS file. Score tracked as `analyzed` (1-5).

**Implementation** (guided by `/nexus-build`) — Execute the plan, make changes, track deviations, create tests. Produces the Implementation Log. Score tracked as `implemented` (1-5). For Research-type issues, `/nexus-research` guides this phase instead of `/nexus-build`.

**Evaluation** (guided by `/nexus-validate`) — Run tests, verify success criteria, assess quality, extract lessons. Produces Evaluation Results. Score tracked as `evaluated` (1-5).

A phase score of **4 or higher** means the phase is ready to advance. A score of **5** means fully complete.

### Two-Place Updates

When phase scores change, NEXUS updates **two places simultaneously** — this is non-negotiable:

1. **Registry**: `ISS-XXX.analyzed: 4` in issues-registry.yaml
2. **Sprint-state**: `- ISS-XXX: Title (High, 3) - A:4 I:2 E:1` in sprint-state.md [OBJECTIVES]

ISS files never contain scores. The registry is the single source of truth for metadata. Sprint-state mirrors scores for at-a-glance sprint visibility.

### Issue Types

| Type | Purpose | Example |
|------|---------|---------|
| Bug | Something broken | Login accepts invalid emails |
| Feature | New functionality | Add dark mode toggle |
| Improvement | Enhancement to existing | Optimize search performance |
| Refactor | Internal restructuring | Reorganize module layout |
| Documentation | Doc-only changes | Update API docs |
| Question | Investigation needed | How should caching work? |
| Research | Systematic research producing structured knowledge | Evaluate framework X for adoption |
| Creative | Content/artifact production | Presentation, report, marketing copy, tutorial |

Research issues follow a modified lifecycle — see the Research Issues section below.

### Complexity Scale

Complexity (1-5) determines how the ISS file is scaffolded and how much structure the issue carries:

| Score | Meaning | ISS Scaffolding |
|-------|---------|-----------------|
| 1 | Trivial — single file, obvious fix | Simple: 5 section markers, no subsection headers |
| 2 | Simple — 1-2 files, clear approach | Simple: same as above |
| 3 | Moderate — 2-3 files, some decisions | Complex: 7 markers, subsection headers, guidance comments |
| 4 | Complex — 4+ files, significant design | Complex: same as above |
| 5 | Very Complex — system-wide, major architecture | Complex: same as above |

The boundary at complexity 3 is significant — it's where ISS files gain full structural scaffolding. If an issue's complexity changes across this boundary, update-issue offers to upgrade the scaffolding.

### Priority vs Impact

**Priority** = urgency (when should this be done?): Critical → High → Medium → Low.

**Impact** = importance (how much does this matter?): Critical → High → Medium → Low.

A High-priority/Low-impact issue gets done soon but delivers minor value. A Low-priority/High-impact issue delivers big value but can wait. Sprint planning uses both to balance the queue.

[/Section: Core-Concepts]

---

## How the Lifecycle Works
[Section: How-It-Works]

### The Full Journey

```
  CREATE ──────────────────────── OPEN (A:1 I:1 E:1)
     │                               │
     │  work-issue sets focus         │
     ▼                               ▼
  ANALYSIS ──── /nexus-analyze ──── Score A ≥ 4?
     │                                  │ yes
     ▼                                  ▼
  IMPLEMENTATION ── /nexus-build ── Score I ≥ 4?
     │            (or /nexus-research)  │ yes
     ▼                                  ▼
  EVALUATION ──── /nexus-validate ── Score E ≥ 4?
     │                                  │ yes
     ▼                                  ▼
  CLOSE ── /nexus-close-issue ──── RESOLVED
     │                                  │
     ▼                                  ▼
  ARCHIVE ── /nexus-archive-issue ── ARCHIVED
```

### Status Transitions

Issues move through these statuses:

- **Open** — Created, not yet worked on. All scores at 1.
- **In-Progress** — Actively being worked. Scores advance through phases.
- **Resolved** — Successfully completed. All scores ≥ 4. Knowledge extracted.
- **Rejected** — Won't do, invalid, or no longer relevant. Any scores.
- **Superseded** — Replaced by a different approach. Any scores.
- **Decomposed** — Split into focused sub-issues via `decompose issue ISS-XXX`. Any scores.

Valid transitions: Open → In-Progress → Resolved/Rejected/Superseded/Decomposed. There's no going back to Open once work starts, but you can loop back to a previous phase within In-Progress using the `loop-back` command.

### Phase Transitions

NEXUS monitors phase scores during work. When a score reaches 4:

```
📊 Analysis complete (score: 4/5). Ready to advance to Implementation? [Y/n]
```

If you confirm, NEXUS:
1. Updates scores in both places (registry + sprint-state)
2. Updates `current_focus` in sprint-state
3. Loads the next methodology (e.g., switches from `/nexus-analyze` to `/nexus-build`)
4. Begins the new phase

You can also override: saying "let's implement" or "evaluate now" triggers a transition even if the score is below 4 (NEXUS will warn but proceed).

### Sprint Integration

Issues live in sprints. When you say `work on ISS-XXX`:

- If the issue is already in the sprint's objectives → it becomes the active focus
- If it's not in the sprint → NEXUS offers to bring it in, checks capacity (guideline: ≤9 total complexity per sprint), updates the registry's `target_sprint`, adds it to sprint-state objectives, and adjusts the sprint-queue

Sprint modes affect how you move between issues:

| Mode | Behavior |
|------|----------|
| **Themed** | Complete all issues in current phase before any advance |
| **Mixed** | Complete one issue end-to-end before starting the next |
| **Dedicated** | Focus on a single issue exclusively |

[/Section: How-It-Works]

---

## Working With Issues
[Section: Operations-Guide]

### Creating Issues

**Command:** `create issue`, `new issue`, `new bug`, `quick issue: {text}`

Three modes for different needs:

**Full mode** (default) — Interactive wizard that walks through type, description, title, dependencies, target sprint, scope files, complexity, priority, and impact. NEXUS proposes intelligent defaults — type from keywords, priority from context, duplicate detection from existing titles. Creation is a T2 review+confirm gate — whether you're asked before creation or it proceeds with a notification depends on your session's Control Level (see nexus-framework-guide.md).

**Quick mode** — For rapid capture: `quick issue: fix the typo in messages.md`. NEXUS parses all fields from your input, suggests values for anything ambiguous, and creates the issue with minimal interaction.

**Backend mode** — Used by other operations (like `/nexus-generate-mvp`) that supply complete data programmatically. No user interaction.

What gets created:
- An ISS file at `.nexus/issues/ISS-XXX.md` scaffolded by complexity
- A registry entry with all 18 fields in prefixed YAML format
- Updated registry counters (`last_id`, `total_active`)

**Example:**
```
> create issue
📝 Next issue: ISS-116

📋 Issue Type: Bug
Description: Login form accepts emails without @ symbol
Title suggested: "Fix login validation to reject invalid emails" ✓
Complexity: 2/5 (simple — single file, clear fix)
Priority: High (Bug + user-facing)

═══ REVIEW: ISS-116 ═══
[Create issue | Modify fields | Cancel]
```

---

### Viewing Issues

**Command:** `list issues`, `view issues`, `ready issues`, `blocked issues`, `search issues`

Read-only browsing with flexible filtering:

| Preset | What it shows |
|--------|---------------|
| `list issues` | All Open and In-Progress issues |
| `ready issues` | Unblocked issues ready to work on |
| `blocked issues` | Issues with unresolved dependencies |
| `search issues` | Freeform natural language search |

Search understands NEXUS terminology: "analyzed but not implemented" finds issues with A ≥ 4 and I < 3. "Complex high priority" finds complexity ≥ 3 and priority High/Critical.

Results display in compact table or expanded card format (toggle with "cards"/"table"). From any result, you can select an issue to work on, update it, or create a new one.

---

### Working on Issues

**Command:** `work on ISS-XXX`, `analyze ISS-XXX`

Sets an issue as the active focus for the current sprint. This is the entry point to doing actual phase work.

What happens:
1. If the issue isn't in the sprint → offers to bring it in (capacity check, registry update, sprint-state update, sprint-queue adjustment)
2. Moves the issue to the top of `in_progress` in objectives
3. Detects the current phase from scores (A < 4 → analysis, A ≥ 4 and I < 4 → implementation, I ≥ 4 → evaluation)
4. Sets `current_focus` in sprint-state

After this, the loaded methodology (`/nexus-analyze`, `/nexus-build`, or `/nexus-validate`) guides the actual work.

---

### Updating Issues

**Command:** `update issue ISS-XXX`, `update ISS-XXX`

Modify any aspect of an existing issue — metadata fields, content sections, or phase scores. The operation detects what kind of update you need from your request:

**Metadata updates** (priority, complexity, status, dependencies, etc.) → patches the registry, syncs sprint-state if needed.

**Content updates** (description, solution design, implementation log, etc.) → patches the ISS file sections using `patch_between_markers`.

**Score updates** → two-place update (registry + sprint-state).

**Pattern matching** → delegates to `/nexus-match-pattern` to find relevant patterns for the issue.

Special behavior: when complexity crosses the simple→complex boundary (e.g., 2→3), NEXUS offers to upgrade the ISS file scaffolding with subsection headers and guidance comments.

---

### Closing Issues

**Command:** `close issue ISS-XXX`, `resolve issue ISS-XXX`

Closes an issue with knowledge extraction. Two resolution types:

**Resolved** — Successfully completed. NEXUS extracts knowledge from the ISS file:
- Strategy from Solution Design → Approach
- Technical decisions from Implementation Log
- Quality outcomes from Evaluation Results
- Pattern applications and outcomes

All of this is synthesized into the `[Section: Closure]` of the ISS file. Pattern effectiveness updates are deferred to sprint closure for batch processing.

**Rejected** — Won't fix. Requires a reason. Optionally captures lessons.

The close operation is atomic — three files update together:
1. ISS file: `[Section: Closure]` populated
2. Registry: status → Resolved/Rejected, evaluated → 5 (if Resolved)
3. Sprint-state: issue moves from `in_progress` to `completed`

If any write fails, all changes roll back.

---

### Archiving Issues

**Command:** `archive issue ISS-XXX`, `archive closed issues`

Moves closed issues out of the active system:

- ISS file moves from `.nexus/issues/` to `.nexus/archived/issues/ISS-XXX-{slug}.md`
- Registry entry is removed entirely (not just status-changed)
- `total_active` counter decrements

**Cascade cleanup**: If other issues reference the archived issue in their `blocked_by` or `blocks` arrays, NEXUS detects this and offers to clean up the stale references.

Can run in scan mode (`archive closed issues`) to find and archive all closed issues at once. Also called in batch by `close-sprint`.

---

### Decomposing Issues

**Command:** `decompose ISS-XXX`, `split issue`, `break down issue`

Breaks a complex issue into focused sub-issues when its scope exceeds tractable boundaries — see the Decompose Signals in the framework guide. Preserves existing analysis/design work rather than discarding it. Can be triggered manually or called from Analyze, Build, or loop-back when strong decompose signals fire.

What happens:
1. Analyzes scope and presents a decomposition plan (child issues, what each inherits)
2. On approval, creates the child ISS files and registers them
3. Closes and archives the original issue with status `Decomposed`, `[Section: Closure]` populated
4. Updates sprint objectives and transitions into analysis on the new children

[/Section: Operations-Guide]

---

## The ISS File
[Section: Data-And-Files]

### Structure Overview

Every ISS file follows the same structure regardless of complexity — what changes is the depth of content and amount of scaffolding.

```
# ISS-XXX: {Title}                          ← Header (type, created, complexity)
*Type: Feature | Created: 2026-03-01 | Complexity: 3*

## Description                               ← Problem statement and context
## Success Criteria                          ← Verifiable definition of done
## Dependencies                              ← Blocked by / Blocks / Related

## Solution Design                           ← Analysis phase output
[Section: Solution-Design]
  ### Approach                               ← Core strategy (always present)
  ### Architecture                           ← Component structure (complex only)
  ### Tools & Patterns                       ← Patterns chosen during analysis
  ### Key Decisions                          ← Non-obvious choices with rationale
  ### Risks & Mitigations                    ← Identified risks
  ### Files Affected                         ← Impact scope
[/Section: Solution-Design]

## Implementation Plan                       ← Phased step tables
[Section: Implementation-Plan]
  Step tables with status tracking (⬜→✅)
[/Section: Implementation-Plan]

## Implementation Log                        ← Build phase output
[Section: Implementation-Log]
  ### Status                                 ← Current progress
  ### Changes Made                           ← Audit trail
  ### Tests Created                          ← For Validate to execute
  ### Deviations                             ← Plan vs reality
  ### Pattern Outcomes                       ← Results of pattern applications
  ### Technical Decisions                    ← Decisions made during build
  ### Issues Encountered                     ← Problems and resolutions
[/Section: Implementation-Log]

## Evaluation Results                        ← Validate phase output
[Section: Evaluation-Results]
  ### Test Execution                         ← Results from running tests
  ### Criteria Verification                  ← Success criteria status
  ### Quality Assessment                     ← Multi-dimension quality
  ### Issues Found                           ← Problems from evaluation
  ### Lessons Learned                        ← Reflection for closure
[/Section: Evaluation-Results]

## Closure                                   ← Written by close-issue
[Section: Closure]
  ### Resolution                             ← How it was resolved
  ### Knowledge Captured                     ← Learnings, candidate patterns
[/Section: Closure]

## Notes & Context                           ← Optional (complex only)
[Section: Notes-Context]
  Flexible subsections as needed
[/Section: Notes-Context]

## Work Log                                  ← Optional (complex only)
[Section: Work-Log]
  Cross-conversation milestones only
[/Section: Work-Log]
```

### Section Markers

The 7 section markers (`[Section: X]...[/Section: X]`) are critical infrastructure — they enable reliable Edit tool patching via `patch_between_markers`. All 5 mandatory markers are scaffolded at creation so methodology skills can always write without checking if markers exist.

| Marker | Mandatory | Written By |
|--------|-----------|------------|
| Solution-Design | ✅ | /nexus-analyze |
| Implementation-Plan | ✅ | /nexus-analyze (create), /nexus-build (status updates) |
| Implementation-Log | ✅ | /nexus-build or /nexus-research |
| Evaluation-Results | ✅ | /nexus-validate |
| Closure | ✅ | /nexus-close-issue |
| Notes-Context | Complex only | Any (flexible) |
| Work-Log | Complex only | Any (milestones) |

### Simple vs Complex Scaffolding

| Aspect | Simple (1-2) | Complex (3-5) |
|--------|-------------|---------------|
| Markers | 5 mandatory | All 7 |
| Subsection headers | None | Pre-populated (###) |
| Guidance comments | None | Full `<!-- GUIDANCE -->` blocks |
| Placeholder content | `*Not started*` | Subsection headers with guidance |

### The Registry Entry

Each issue has an 18-field entry in issues-registry.yaml using prefixed YAML format:

```yaml
# --- ISS-092 ---
ISS-092.title: "Fix login validation to reject invalid emails"
ISS-092.type: "Bug"
ISS-092.file: "issues/ISS-092.md"
ISS-092.description: "Login form accepts invalid email formats"
ISS-092.priority: "High"
ISS-092.impact: "High"
ISS-092.status: "In-Progress"
ISS-092.complexity: 3
ISS-092.created: "2026-01-27"
ISS-092.created_in_sprint: "045"
ISS-092.target_sprint: "045"
ISS-092.blocks: []
ISS-092.blocked_by: []
ISS-092.scope_files: ["login.md", "validation.md"]
ISS-092.analyzed: 4
ISS-092.implemented: 2
ISS-092.evaluated: 1
ISS-092.notes: ""
```

The prefixed format (`ISS-XXX.fieldname`) makes every field globally unique — critical for reliable Edit tool patching without ambiguity.

### Where Information Lives

| Information | Location | Why |
|------------|----------|-----|
| Scores (A/I/E) | Registry + sprint-state (2 places) | Queryable metadata, sprint visibility |
| Status, priority, type | Registry only | Queryable metadata |
| Solution design, plans, logs | ISS file only | Phase work content |
| Current focus, objectives | Sprint-state only | Session orchestration |
| Dependencies | Registry (arrays) + ISS (narrative) | Both: registry for queries, ISS for context |

**Rule: never put scores in ISS files, never put content in the registry.**

[/Section: Data-And-Files]

---

## Research Issues
[Section: Research-Issues]

Research-type issues follow a modified lifecycle: **Analysis → Research → Evaluation** (instead of Analysis → Implementation → Evaluation). The research phase is guided by `/nexus-research` instead of `/nexus-build`, and the ISS file uses research-specific subsections.

### Key Differences

| Aspect | Standard | Research |
|--------|----------|---------|
| Phase flow | A → I → E | A → R → E |
| Build phase methodology | /nexus-build | /nexus-research |
| Implementation-Log subsections | Changes Made, Tests Created | Findings Summary, Quality Checks |
| Implementation-Plan focus | File changes with status | Research milestones |
| Solution-Design subsections | Architecture, Files Affected | Subjects & Scope, Evaluation Criteria, Source Strategy |
| Scaffolding | By complexity | Always complex (all 7 markers, full guidance) |

### Research ISS Subsection Mapping

| Standard Subsection | Research Equivalent | Why Different |
|---------------------|-------------------|---------------|
| Architecture | Subjects & Scope | Research has subjects, not components |
| Files Affected | Source Strategy | Research has sources, not files |
| Changes Made | Findings Summary | Knowledge, not file modifications |
| Tests Created | Quality Checks | Source verification, not test cases |
| Deviations | Scope Changes | Research scope evolution |
| Technical Decisions | Research Pivots | Methodology changes during research |

The `implemented` score field is reused for research progress — the registry doesn't have a separate `researched` field.

[/Section: Research-Issues]

---

## How Issues Connect to Other Systems
[Section: Integration-Points]

### Cross-Domain Connections

```
                    ┌─────────────────┐
                    │   Sprint Ops    │
                    │  close-sprint   │──── calls close-issue (batch)
                    │  organize-sprint│──── reads registry for planning
                    └────────┬────────┘
                             │
     ┌───────────────────────┼───────────────────────┐
     │                       │                       │
     ▼                       ▼                       ▼
┌─────────┐          ┌──────────────┐         ┌──────────┐
│ Project │          │    Issue     │         │ Pattern  │
│  Ops    │          │    Ops       │         │   Ops    │
│         │          │              │         │          │
│ gen-mvp─┼── calls ─┤ create-issue │         │ match-   │
│ update- │          │ close-issue  │── calls ┤ pattern  │
│ params ─┼── calls ─┤ update-issue │         │          │
│ close-  │          │ archive-issue│         └──────────┘
│ project─┼── calls ─┤ view-issues  │
│         │          │ work-issue   │
└─────────┘          └──────────────┘
                             │
                     writes to 3 files:
                     ┌───────┼───────┐
                     ▼       ▼       ▼
              ISS files  registry  sprint-state
```

### Inbound Callers

These operations from other domains call into Issue operations:

| Caller | Calls | When |
|--------|-------|------|
| /nexus-close-sprint | close-issue (batch) + archive-issue (batch) | Sprint closure — closes and archives all completed issues |
| /nexus-validate | close-issue | Evaluation complete (score E ≥ 4), user confirms closure |
| /nexus-generate-mvp | create-issue (backend) | Generating issues from project deliverables |
| /nexus-setup-project (Update Mode) | close-issue | Closing orphaned issues from removed deliverables |
| /nexus-close-project | close-issue (batch) | Rejecting remaining open issues at project end |
| /nexus-subsystem-verification | create-issue (backend) | Creating issues for major verification findings |

### Outbound Connections

Issue operations reach into one other domain:

| Operation | Calls | When |
|-----------|-------|------|
| update-issue | /nexus-match-pattern | User requests pattern matching for an issue |

### Methodology Extensions

Methodology skills are not called by issue operations directly — they're loaded at phase transitions (per CLAUDE.md Phase-Management-Protocol) or at boot by `/nexus-start`, based on the current phase, and guide the human+NEXUS work session:

| Phase | Methodology | Writes To |
|-------|-------------|-----------|
| Analysis | /nexus-analyze | [Section: Solution-Design] + [Section: Implementation-Plan] |
| Implementation | /nexus-build | [Section: Implementation-Log], updates [Section: Implementation-Plan] status |
| Research | /nexus-research | [Section: Implementation-Log] (findings), updates [Section: Implementation-Plan] |
| Evaluation | /nexus-validate | [Section: Evaluation-Results] |

### Pattern Lifecycle Across Phases

Patterns thread through the entire issue lifecycle:

```
Analysis:   ### Tools & Patterns      → "We chose PAT-XXX"        (selected)
Build:      ### Pattern Outcomes      → "PAT-XXX: success"        (result)
Evaluate:   ### Lessons Learned       → "PAT-XXX was effective"   (reflection)
Closure:    ### Knowledge Captured    → feeds registry tracking    (extraction)
Sprint:     close-sprint             → updates effectiveness      (aggregation)
```

[/Section: Integration-Points]

---

## Quick Reference
[Section: Quick-Reference]

### Commands

| Command | Operation | What It Does |
|---------|-----------|-------------|
| `create issue` | create-issue | Full wizard for new issue |
| `quick issue: {text}` | create-issue | Rapid capture from brief input |
| `list issues` | view-issues | Show open/in-progress issues |
| `ready issues` | view-issues | Show unblocked issues |
| `blocked issues` | view-issues | Show blocked issues |
| `search issues` | view-issues | Freeform search |
| `work on ISS-XXX` | work-issue | Set issue as active focus |
| `update ISS-XXX` | update-issue | Modify any issue field or content |
| `close issue ISS-XXX` | close-issue | Close with knowledge extraction |
| `archive closed issues` | archive-issue | Move closed issues to archive |
| `decompose ISS-XXX` | decompose-issue | Split into focused sub-issues |
| `read ISS-XXX` | direct load | Load ISS file into memory |

### Phase Score Meanings

| Score | Meaning |
|-------|---------|
| 1 | Not started |
| 2 | Basic progress |
| 3 | Partial completion |
| 4 | Well advanced — ready to proceed to next phase |
| 5 | Fully complete |

### Status Transitions

| From | To | Trigger |
|------|----|---------|
| Open | In-Progress | work-issue or phase work begins |
| In-Progress | Resolved | close-issue (all scores ≥ 4) |
| In-Progress | Rejected | close-issue (won't fix) |
| In-Progress | Superseded | close-issue (replaced) |
| In-Progress | Decomposed | decompose-issue (split into children) |
| Resolved/Rejected/Superseded/Decomposed | Archived | archive-issue |

### Key Files

| File | Location | Purpose |
|------|----------|---------|
| ISS-XXX.md | `.nexus/issues/` | Issue work content (all phases) |
| issues-registry.yaml | `.nexus/active/registries/` | Issue metadata (18 fields, prefixed YAML) |
| sprint-state.md | `.nexus/active/states/` | Current sprint objectives and scores |
| issue-specification.md | `.nexus/templates/` | Authoritative spec for ISS structure + registry schema |

### ISS Section Ownership

| Section | Owner | Phase |
|---------|-------|-------|
| Solution-Design | /nexus-analyze | Analysis |
| Implementation-Plan | /nexus-analyze → /nexus-build | Analysis (create) → Implementation (update) |
| Implementation-Log | /nexus-build / /nexus-research | Implementation / Research |
| Evaluation-Results | /nexus-validate | Evaluation |
| Closure | /nexus-close-issue | Closure |

[/Section: Quick-Reference]
