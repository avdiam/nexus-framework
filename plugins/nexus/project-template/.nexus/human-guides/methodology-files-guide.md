# Methodology Skills Guide
*Version: 2.0.0 | Date: 2026-08-24 | Sprint: 110*
*How NEXUS methodology skills guide work through each phase*

**Category**: system-reference
**Level**: intermediate
**Description**: How methodology skills work — the five phase skills plus Build's batch sub-mode, their shared step structure, simple vs complex paths, phase routing and loading, checkpoint continuity, and how behavioral preferences shape interpretation.

**Source files**:
- `.claude/skills/nexus-analyze/SKILL.md` v4.5.0
- `.claude/skills/nexus-research/SKILL.md` v2.10.1
- `.claude/skills/nexus-build/SKILL.md` v3.2.0 (+ `batch.md` v1.4.0)
- `.claude/skills/nexus-validate/SKILL.md` v3.7.0
- `.claude/skills/nexus-maintain/SKILL.md` v2.4.0
- `.claude/skills/nexus-start/SKILL.md` v2.9.2 (phase detection and loading)
- `CLAUDE.md` v5.16.0 (Phase-Management-Protocol, Control-Levels, Behavioral-Preferences)

> This guide covers **how methodology skills are built and how they behave**. For what each one is *for*,
> read [Methodology Skills — Phase-Specific Intelligence](nexus-framework-guide.md#methodology-skills--phase-specific-intelligence)
> in the framework guide.

---

## What Are Methodology Skills?
[Section: What-Are-Methodology-Skills]

Methodology skills are phase-specific instruction sets that tell Claude *how* to work through each stage of
an issue. When you start analyzing a bug, `/nexus-analyze` loads. When you transition to implementation, it
swaps to `/nexus-build`. Each skill defines a step-by-step workflow tailored to that phase's goals.

Think of them as playbooks: `/nexus-analyze` is the playbook for understanding problems and designing
solutions; `/nexus-build` is the playbook for implementing them. They share a common structure but differ in
what they optimize for.

Each one lives in its own folder under `.claude/skills/`, with a `SKILL.md` as the entry point and optional
sub-files loaded on demand — `complex.md` for the complexity 3+ path, `types/*.md` for issue-type variations,
`modes/*.md` for research modes, `batch.md` for Build's batch sub-mode.

There are **five** methodology skills covering four issue phases plus maintenance:

| Skill | Phase | Flow | Paths and sub-files |
|-------|-------|------|---------------------|
| `/nexus-analyze` | Analysis (A) | Orient → [Simple Path \| Router → `complex.md` + type file] → Commit → Transition | C:1–2 Simple · C:3+ Router · 5 type files |
| `/nexus-research` | Research (R) | Orient → Router (load mode file) → Scoping → mode steps → checklist → Commit → Transition | 3 mode files: adoption, comparative, exploratory |
| `/nexus-build` | Implementation (I) | Orient → [Simple Path \| Router → `complex.md` + type file → §POST-TYPE] → checklist → Commit → Transition | C:1–2 Simple · C:3+ Router · 3 type files · **batch sub-mode** |
| `/nexus-validate` | Evaluation (E) | Orient → QA Verification → [Simple Path \| Router → type file] → Pattern Finalization → Quality Gate → User Acceptance → Documentation & Learning → Closure | C:1–2 Simple · C:3+ or sprint scope Router · 4 type files |
| `/nexus-maintain` | Maintenance (L4) | Orient → Planning → Execution → Verification → Report & Closure | 3 tiers: Quick, Standard, Comprehensive |

The standard issue flow is **A → I → E**. Research issues follow **A → R → E** and never transition to Build
— research informs; implementation is separate work. `/nexus-maintain` runs independently, for maintenance
sprints rather than issue phases.

**Batch is a sub-mode, not a sixth methodology.** When Build detects a repeating procedure across multiple
targets, it formalizes a playbook, sets `_build_mode: batch` in sprint-state, and loads `batch.md` — which
executes the playbook target by target, optionally dispatching them in parallel to sub-agents. Escalating a
target that doesn't fit returns it to the full Build path. `/nexus-brainstorm` sits outside the A/I/E
lifecycle entirely as a parallel phase.

[/Section: What-Are-Methodology-Skills]

---

## How Methodologies Get Loaded
[Section: How-Methodologies-Get-Loaded]

### At Conversation Start

Every conversation begins with `/nexus-start` detecting which phase you're in. The detection follows a
priority chain, first match wins:

1. **`current_focus`** set to `maintenance` or `brainstorm` — routes straight to that skill
2. **Your explicit intent** — "let's implement", "analyze ISS-042"
3. **The stored `current_focus`** in sprint-state — what you were doing last
4. **Issue scores** — A < 4 means analysis; A ≥ 4 and I < 4 means implementation (or research); I ≥ 4 and
   E < 4 means evaluation
5. **Operations mentioned** in context, then a fallback to Analysis

`/nexus-start` then presents a widget asking you to confirm or override the detected phase, alongside the
session's Control Level. **Only after your answer does it load the methodology skill.** This is the safety
net — if detection is wrong, you pick the right one there.

### At Phase Transitions

When a phase completes (score reaches 4 or 5), the current methodology proposes a transition. The handoff
follows a consistent pattern:

1. **Score check** — the methodology calculates a score (4 = ready to proceed, 5 = comprehensive)
2. **Confirmation** — governed by the session's Control Level, not unconditional (see Mandatory Gates below)
3. **Two-place update** — scores update in both `issues-registry.yaml` and sprint-state `[OBJECTIVES]`
4. **Focus patch** — sprint-state `current_focus` updates to the new phase
5. **Load next** — the next methodology skill loads

The transition map:

```
Analysis ──→ /nexus-build      (standard issues)
         ──→ /nexus-research   (Research-type issues)
Research ──→ /nexus-validate
Build    ──→ /nexus-validate
         ──→ batch sub-mode    (repetitive targets — stays inside /nexus-build)
Validate ──→ /nexus-close-issue
Any      ←─→ /nexus-brainstorm (parallel phase — enter and exit from anywhere)
```

### On Demand

You can also force a methodology load at any time: "analyze", "build", "research", "validate", or "batch"
all resolve through the routing map in `CLAUDE.md`.

[/Section: How-Methodologies-Get-Loaded]

---

## Shared Structural Patterns
[Section: Shared-Structural-Patterns]

All methodology skills share a common architecture, making them predictable once you understand one.

### Step Structure

Every methodology uses named, ordered steps that must execute in sequence. Skipping steps is a violation.
Each step has a single responsibility — a step doing two distinct things is a bug.

**The first step is always Orient** — silent, invisible to you. It checks what is already in context, loads
the ISS file, detects whether there is prior progress to resume from, and verifies readiness before any work
begins.

**The last step is always Transition** — proposes moving to the next phase and handles the two-place score
update.

### Simple vs Complex Paths

Analyze, Build, and Validate each define two paths based on issue complexity (assessed at boot):

**Simple path (complexity 1–2)**: everything runs inline, with **zero external file loads**. Optional
machinery — pattern matching, cognitive tools, adversarial review — is skipped. Typical for small bugs,
documentation fixes, and straightforward features.

**Complex path (complexity 3+)**: a Router loads two files — the skill's `complex.md` thinking toolkit and
the issue-type file (`types/default.md`, `types/bug.md`, `types/creative.md`, …). The type file carries the
implementation loop; `complex.md` wraps it with pre-work (pattern matching, plan verification) and post-work
(test execution, drift detection, quality review).

The other two skills branch differently: `/nexus-research` routes on **mode** rather than complexity
(adoption, comparative, exploratory), and `/nexus-maintain` routes on **tier** (Quick, Standard,
Comprehensive) computed from system health scores.

### Mandatory Gates

Every methodology marks its decision points with a gate tier — **[T1]** critical, **[T2]** decision,
**[T3]** routine — and each skill carries a `## Gate Reference` table saying what each tier does at each
Control Level. Whether a gate stops and asks you is therefore a function of **both** the tier and the
Control Level you chose at boot:

| Gate tier | Streamlined | Balanced | Full Control |
|---|---|---|---|
| T1 — issue/sprint closure, destructive overwrites, bulk rewrites | Always asks | Always asks | Always asks |
| T2 — plan approval, design choices, phase transitions | Proceeds, notifies | Asks | Asks |
| T3 — ISS updates, registry patches, progress saves | Proceeds silently | Proceeds, notifies | Asks |

T1 always asks, at every level. When a T2 or T3 gate is bypassed, the skill logs the decision to sprint-state
`[DECISIONS]` with an `[AUTO]` prefix, so a skipped gate leaves a record rather than a silence. The full
model is in [The Three Unbreakable Principles](nexus-framework-guide.md#the-three-unbreakable-principles).

### Checkpoint Handshake

Every methodology carries a `## Checkpoint Reference` table mapping step ranges to what must be persisted and
where. `/nexus-checkpoint` never has to guess — it consults the active methodology's table. Build, Validate,
and Maintain additionally place inline `> **Mental note**:` directives at step boundaries, restating what to
carry if a checkpoint fires mid-step.

[/Section: Shared-Structural-Patterns]

---

## Checkpoint Continuity
[Section: Checkpoint-Continuity]

Methodology skills are designed for multi-conversation work. The continuity system has three parts.

### Progress Markers

When partial work is written to an ISS file mid-phase, the methodology places a marker as the first line of
the relevant section:

```
*Analysis in progress — research complete*
```

```
*Implementation in progress — {last completed milestone}*
```

```
*Research in progress — {last completed step}*
```

```
*Evaluation in progress — QA verification complete*
```

These markers serve two purposes: they tell the next conversation exactly where to resume, and they prevent
the section from being read as complete. The Commit Protocol removes them when the phase finishes.

### Checkpoint Continuity Tables

Each methodology's `## Checkpoint Reference` maps progress to persistence target:

| After | What to Persist | Where |
|-------|-----------------|-------|
| Orient / early steps | Context only | sprint-state `continue_with` |
| Mid-phase (research, design, implementation) | Partial work product | ISS file with progress marker |
| Phase complete (approved plan, results) | Full content | ISS file, finalized, no marker |
| Commit / Transition done | Already on disk | Verify only |

### Resumption Protocol

When a new conversation starts and `/nexus-start` detects an in-progress phase:

1. Orient loads the ISS file
2. Orient checks for progress markers and for mode flags such as `_build_mode: batch`
3. If a marker is found, it displays a summary of prior work and resumes at the indicated step
4. `continue_with` in sprint-state supplies the rest — decisions made, tools loaded, what to do first

This is why `continue_with` must be specific. "Continue analyzing ISS-042" is useless; "Resume Analyze design
step, topics 1–2 decided, topic 3 pending, First Principles loaded" lets the next conversation pick up
seamlessly.

**One rule that is easy to miss**: a complex-path interruption always resumes through the skill's Router,
which reloads `complex.md` and the type file unconditionally. Those files were in memory, not on disk — a
resumption that tries to re-enter them directly is resuming into nothing.

[/Section: Checkpoint-Continuity]

---

## How Preferences Shape Behavior
[Section: How-Preferences-Shape-Behavior]

The same methodology step produces different results depending on active behavioral preferences. The
methodology skills never reference preferences directly — the relationship is implicit, through
interpretation.

Preferences live in `CLAUDE.md` [Section: Behavioral-Preferences] and are graded by importance, which
determines how loudly they act:

| Importance | Enforcement |
|---|---|
| **core** | Always applied, silently. Violations are self-corrected and noted |
| **high** | Mentioned when they significantly shape a decision; you can override |
| **medium** | Applied when the context matches, without mention |
| **low** | Considered only; surfaced if you ask |

For example, when Analyze generates solution options:

- With **quality_over_speed** (core): thorough systematic analysis over a quick answer — comprehensive
  options with full trade-off analysis
- With **elegant_minimum** (core): prefer the simplest viable option, resist over-engineering the
  alternatives
- With **ask_dont_assume** (medium): lead with a single reasoned recommendation plus its justification
  rather than a neutral option-list

Other interactions:

- **thorough_understanding_first** shapes how much tracing happens before a structural change is proposed
- **pause_before_major_changes** adds reflection at transition gates ahead of complex or structural work
- **adapt_not_adopt** governs how pattern guidance is applied — principles adapted to context, never copied
- **file_by_file_implementation** determines whether Build processes files individually or in batches
- **validate_is_load_bearing** is why Validate is never skipped on the grounds that Build self-reviewed

Preferences are earned, not guessed: the learning loop amends them at sprint closure from what actually
happened. You don't need to think about this — but it is why two projects running the same methodology can
feel different.

[/Section: How-Preferences-Shape-Behavior]

---

## Common Workflows
[Section: Common-Workflows]

### Starting Work on an Issue

```
You: "work on ISS-042"
→ /nexus-work-issue routes to the right methodology based on phase scores
→ Methodology Orient loads the ISS, checks for progress
→ If resuming: picks up where you left off
→ If fresh: begins the phase workflow
```

### Mid-Work Checkpoint

```
Context hits 70% → Claude offers to save
You: "save now"
→ /nexus-checkpoint consults the methodology's Checkpoint Reference
→ Writes partial work to the ISS with a progress marker
→ Saves sprint-state with a specific continue_with, commits to git
→ Continues working
```

### Phase Transition

```
Analysis score reaches 4 → the methodology proposes the transition
You: "yes, proceed"    (asked at Balanced and Full Control; notified at Streamlined)
→ Scores update in 2 places (registry + sprint-state)
→ current_focus updates to the new phase
→ The next methodology skill loads
→ Its Orient reads the ISS, finds the completed work, begins the new phase
```

### Loop-Back

```
During evaluation, tests reveal a design flaw
You: "loop back to analysis"
→ /nexus-loop-back handles the mechanics and preserves what was learned
→ Returns to /nexus-analyze with the reason attached
→ Orient detects existing content and offers review / revise / fresh
```

### Switching to Batch

```
During Build, after the same procedure lands on 2+ targets
Claude: "Repetitive execution pattern detected. Switch to batch mode?"
You: "yes"
→ Playbook formalized in the ISS Implementation-Log
→ _build_mode set to batch in sprint-state
→ batch.md loads and works the remaining targets, sequentially or dispatched in parallel
→ A target the playbook doesn't fit escalates back to the full Build path
```

[/Section: Common-Workflows]

---

## Quick Reference Card
[Section: Quick-Reference-Card]

| Question | Answer |
|----------|--------|
| How many methodologies? | 5 skills covering 4 issue phases + maintenance. Batch is a sub-mode of Build |
| Where do they live? | `.claude/skills/nexus-{analyze,research,build,validate,maintain}/SKILL.md` |
| When do they load? | At conversation start via `/nexus-start`, or at a phase transition |
| Can I override the detected phase? | Yes — the boot widget lets you pick any phase |
| What triggers a phase transition? | Score ≥ 4, then confirmation per your Control Level |
| Can I skip phases? | No — A→I→E is mandatory. You can loop back |
| What's the simple path? | Complexity 1–2 runs inline with zero external loads; 3+ routes through `complex.md` + a type file |
| How is progress preserved? | Progress markers in the ISS + each skill's Checkpoint Reference table |
| Can I force a methodology load? | Yes — "analyze", "build", "research", "validate", "batch" |
| Where do methodologies write? | ISS file sections (Solution-Design, Implementation-Log, Evaluation-Results) and sprint-state |
| What about Research issues? | A→R→E, and `/nexus-research` uses the `implemented` score field — there is no separate research score |

[/Section: Quick-Reference-Card]
