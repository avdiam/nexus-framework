# operation-skill-template.md
*Version: 2.9.0 | Date: 2026-08-27 | Sprint: 111*

*Guide for creating and auditing NEXUS operation skills. Complements methodology-skill-template.md (methodology skills). Evolved from skills-template.md v2.0.0 with patterns from 4 redesigned methodology skills; v2.1.0 adds the consolidated §Discipline Enforcement Layer, revised No-Placeholder Rule, and F6 marker catalog per ISS-159 3rd-pass synthesis and PAT-102.*

> **Source of standard.** The authoritative skill-structure rubric is `framework-audit-playbook.md` §9 (criterion-9 sub-rubric 9a–9e) + §10/§10.1 (SSoT taxonomy + load-isolation carve-out). This template was **scanned against criterion 9 and is current** for the §Discipline-Enforcement Layer, gate-discipline, ⛔ marker catalog, and placeholder rules — no rewrite needed (ISS-210, SCAN-then-classify). Added here: the **9a line band for operation skills — `SKILL.md` ≤ 600 lines** (over-band → run the playbook §9b externalization test; never an auto-fail — §0 audience-class caveat), plus this cross-reference to §9 as the fuller structure standard. The SSoT B/A taxonomy (§10) and load-isolation carve-out (§10.1) stay homed in the playbook — this template points, never re-homes (PAT-113).

## Purpose

Operation skills are the workhorses of NEXUS — specific tasks with clear inputs and outputs. They range from simple 3-step workflows (view-issues, sprint-status) to complex multi-phase orchestrations (close-sprint, organize-sprint, subsystem-verification). This template covers the full spectrum.

**Audience**: Use this template when creating a new operation skill or redesigning an existing one. For methodology skills (multi-file, type-adapted, complexity-scaled), use methodology-skill-template.md instead.

**What makes operation skills different from methodology skills**:

| Dimension | Methodology Skills | Operation Skills |
|---|---|---|
| File count | 2-8 (SKILL.md + companions) | 1 (SKILL.md only) |
| Complexity adaptation | C:1-2 inline, C:3+ loads companions | None — same flow always |
| Issue type adaptation | Type/mode files | None — generic (or inline callouts) |
| Duration | May span conversations | Usually single conversation |
| Invocation | Phase transitions, boot routing | User command, skill delegation, methodology call |
| State management | ISS files, progress markers | Varies — some update registries, states, or entity files |

---

## Nature of Operations

Operations are **LLM behavioral programming** — instruction sets for an intelligent agent, not code for a deterministic interpreter. The executor understands context, exercises semantic judgment, and collaborates with the user.

- **Guide the reasoning, don't script the execution.** Describe what to achieve and the important considerations, not every micro-step. The LLM can figure out how to patch a YAML field — tell it *which* field and *why*.
- **Semantic judgment over keyword matching.** When an operation says "find related patterns," the LLM reads and understands content. Describe what "related" means in context.
- **Collaborate, don't just record.** For operations that collect information (wizards, setup), the LLM should actively propose content, challenge weak input, and use Socratic questioning. The LLM is a thinking partner, not a form renderer.
- **Not a rigid template.** Not every operation needs every feature described here. Use what fits the operation's complexity and purpose. Sections marked **(selective)** or **(optional)** are included only when they apply.

---

## Skill Structure

```
.claude/skills/nexus-{name}/
└── SKILL.md          ← Single file. The complete workflow.
```

Operation skills are always single-file. No step files, no companion files. If a workflow is complex enough to need multiple files, it's likely a methodology skill — use methodology-skill-template.md.

---

## SKILL.md Structure

Every operation SKILL.md follows this structure. Sections marked are: **(required)**, **(recommended)**, **(selective)**, or **(optional)**.

```
SKILL.md
├── Frontmatter (---yaml---)                          REQUIRED
├── Version header                                     REQUIRED
├── Title + Flow summary                               REQUIRED
├── Purpose (1-2 sentences)                            REQUIRED
├── When to Use / Triggers                             REQUIRED if auto-invokable; RECOMMENDED otherwise
│
├── Steps (STEP 0 through STEP N)                      REQUIRED
│   ├── STEP 0: Load Context (silent)
│   ├── STEP 1–N: Operation-specific work
│   └── Final STEP: Report / Display results
│
├── Gate Reference table                               SELECTIVE — when 3+ gates
├── Checkpoint Integration                             SELECTIVE — maintenance ops
├── End-of-Workflow Checklist                          SELECTIVE — complex ops
├── Error Recovery table                               RECOMMENDED
├── Discipline Enforcement Layer                       REQUIRED for discipline-critical skills (tiered: Full Layer or Verification-Class Core)
└── Display Templates                                  RECOMMENDED
```

### Frontmatter (required)

```yaml
---
name: nexus-{name}
description: {one-line description for discovery}
disable-model-invocation: true
---
```

**Default**: `disable-model-invocation: true` for operation skills (45 operations × ~100 tokens ≈ 4.5KB saved on every session boot).

**Exceptions** — omit the flag or set it to `false` (both are invokable; explicit `disable-model-invocation: false` is the prevailing convention — 10 of the 11 invokable files carry it) when the skill benefits from being auto-invokable via the Skill tool. Per CLAUDE.md `## Command Recognition` (Skill Invocation Convention — an untagged heading, not a `[Section:]` block), the currently-authorized invokable operation skills are: `checkpoint`, `close-issue`, `create-issue`, `create-pattern`, `help`, `menu`, `plug-seed`, `update-issue`. Cognitive tool packs (`mental-models`, `problem-solving`, `strategic`) are also invokable.

When adding a new skill to the invokable list, update both this template and CLAUDE.md `## Command Recognition` (Skill Invocation Convention — an untagged heading, not a `[Section:]` block) together — they must stay consistent. Invokable skills rely on a strong `description` field (pushy, trigger-specific) since the Skill tool matches on description content.

**`description` field discipline** (v2.1.0, C7): The description MUST state *when to use* the skill, not *what it does*. Start with "Use when..." or "Triggers when...". The Skill tool and command-router match user intent against this string — a workflow summary ("Evaluate issue implementation and update scores") is a poor trigger signal compared to a usage condition ("Use when an issue's implementation is complete and needs quality evaluation before closure").

**Acceptable form**: `Use when {condition}. {One-line on purpose if needed}.`

**Reject**: descriptions that read as workflow summaries, pure purpose statements without trigger conditions, or duplications of the skill name.

### Version Header (required)

```markdown
*Version: X.Y.Z | Date: YYYY-MM-DD | Sprint: NNN*
```

First content line after frontmatter closing `---`. Bumped per CLAUDE.md [Section: File-Operations-Protocol] version protocol.

### Title + Flow Summary (required)

```markdown
# {Operation Name}

**Flow**: {step sequence in one line}
```

The flow line is the 5-second orientation for the LLM. It shows the complete execution path at a glance.

Examples:
- Simple: `**Flow**: Load → Validate → Display`
- Medium: `**Flow**: Load → Assess → Propose fixes → [T2: approve] → Apply → Report`
- Complex: `**Flow**: Load → Assess completion → Resolve issues → Process patterns → Experience → Admin → Finalize`

### Purpose (required)

1-2 sentences explaining what the operation does and when it's used. Not a full Quick Reference — just enough context for a fresh LLM instance to understand the operation's role.

### When to Use / Triggers (required for auto-invokable skills)

A compact list or table of triggering conditions. Answers "should I call this now?" in 5 seconds.

Format: bulleted triggers keyed to intent signals, plus explicit non-triggers when easily confused with a neighboring skill.

```markdown
## When to Use

**Trigger when**:
- User says {keyword/phrase 1}, {keyword/phrase 2}
- {Situation 1} is detected
- {Upstream event} completes

**Do NOT trigger when**:
- {Confusable situation} — use {sibling skill} instead
- {Anti-pattern} — not a fit for this skill
```

The "Do NOT trigger" line prevents routing collision with near-neighbor skills (e.g., `/nexus-validate` vs `/nexus-close-issue` vs `/nexus-archive-issue`).

---

## Step Design (required)

### General Principles

Each step has a **single responsibility**. If a step does loading AND validation AND decision-making, split it. Clean sequential numbering: STEP 0, STEP 1, STEP 2... with lettered sub-sections (A, B, C) when a step has distinct phases.

**STEP 0: Load Context** is always first. Silent — the user doesn't need to see memory checks. Load only what the operation needs.

### Step Patterns by Operation Type

| Type | Pattern | Examples |
|---|---|---|
| **CRUD** | Validate → Prepare → Confirm → Write → Report | create-issue, update-issue, close-issue |
| **Read/Display** | Load → Filter/Sort → Display | view-issues, sprint-status, list-patterns |
| **Assessment** | Load → Analyze → Score → Report | health-diagnostic, issue-validation |
| **Multi-entity** | Load all → Assess → Propose plan → Confirm → Execute → Report | organize-sprint, move-issues, merge-patterns |
| **Wizard/Collection** | Progressive steps building output → Confirm → Write | setup-project, create-issue (guided mode) |
| **Maintenance** | Load → Scan → Assess → [Scan boundary] → Present findings → Apply fixes → Update health → Report | registry-cleanup, changelog-scan |

### Step Skeleton

| Step | Purpose | Visibility |
|---|---|---|
| STEP 0 | Load Context | Silent |
| STEP 1 | Validate / Parse inputs | Silent or visible |
| STEP 2–(N-3) | Operation-specific work | Varies |
| STEP N-2 | User approval (when modifying data) | Visible |
| STEP N-1 | Write / Update / Verify | Visible |
| STEP N | Report results and next steps | Visible |

### Visibility Rules

- Loading and memory checks → silent
- Validation results → visible (user should know what was checked)
- Internal scoring/calculations → silent (show results, not math)
- Write operations → always visible (user must see what changed)
- User choices and confirmations → always visible

### Inline Constraint Placement (v2.1.0, C6)

Consolidating all constraints in a top-of-file §Constraints block is efficient for authoring but fails at read time — by STEP 5, the reader (LLM or human) has forgotten the STEP 1 prohibition. For constraints that bear on a *specific* step's temptation path, restate the prohibition **inline at that step**.

Pattern:

```markdown
### STEP 4 — Apply fixes

(step body)

⚠️ Do NOT modify files outside the identified fix set. If STEP 3 flagged 4 files, only those 4 get patched here — no opportunistic cleanup. (Repeat of Constraint #3; placed here because STEP 4 is where drift happens.)
```

This is **complementary** to (not a replacement for) the top-block §Constraints section. The top block is the exhaustive list; inline mentions are at-risk-step reminders.

When to inline-repeat: only constraints that have an observed failure mode at that step. Don't inline-repeat every constraint at every step — that's noise.

---

## Gate Annotations (required for operations with approval gates)

### Format

Inline with behavior hints — placed at the start of the instruction containing the gate:

```markdown
✓ **[T1: all levels ask]**
✓ **[T2: Balanced+Full ask | Streamlined: notify+log]**
✓ **[T3: Full ask | Balanced: notify | Streamlined: silent]**
```

Never use the minimal tier-only form (`✗ **[T2]**`). Inline hints work at any recall depth; minimal codes force the LLM to cross-reference CLAUDE.md [Section: Control-Levels] on every gate, which fails reliably at high context or after many exchanges.

### Hard vs Soft Gate Phrasing (v2.1.0, C3)

Gates use canonical hard phrasing. Never soften:

| Good (hard) | Bad (soft) |
|---|---|
| "Do NOT X until Y approved" | "You should probably wait for Y" |
| "Halt. User approval required." | "It's a good idea to ask the user" |
| "Cannot proceed without Z" | "It would be helpful to have Z" |
| "⛔ GATE: {condition}" | "Check: {condition}" |

Softened phrasing is an anti-pattern. "Should" / "probably" / "it would be helpful" are loopholes — they let an LLM self-justify skipping the gate at context pressure. Templates enforce discipline when context degrades; soft phrasing removes the enforcement.

**Rule**: every gate's instruction contains an imperative verb (Halt, Stop, Ask, Request) **or** a prohibition ("Do NOT", "Cannot", "Must not"). No conditional wording.

### Tier Classification Guide

| Tier | Criteria | Examples |
|---|---|---|
| **T1** | Irreversible or hard-to-restore actions | Delete/archive entities, rollback, closure decisions, destructive overwrites |
| **T2** | Direction/approach decisions, scope changes | Plan approval, fix proposals, entity creation, mode selection |
| **T3** | Routine administrative actions | ISS updates, registry patches, display choices |

### When to Annotate

- **Simple read-only operations** (view, list, status): No gates needed — nothing to approve.
- **Single-approval operations** (update, create): One gate, annotate inline. No Gate Reference table needed.
- **Multi-gate operations** (close-sprint, organize-sprint, maintenance ops): Annotate each gate inline AND include a consolidated Gate Reference table.

### Verification Gates (at critical boundaries)

Gates are hard stops that prevent proceeding with incomplete or invalid state. Include at critical boundaries — not every step.

**When to include**:
- After loading/validation (STEP 0-1) — ensure context is complete
- Before write operations — ensure data is ready and user has approved
- After write operations — ensure changes applied correctly
- Before returning to caller — ensure the operation's contract is fulfilled

**When to skip**:
- Simple sequential steps with no failure modes
- Display-only steps
- Steps where the next step inherently validates the previous

**Format** (generic structural gate):
```
⛔ GATE: {What must be true to proceed.}
- [ ] {Specific, verifiable criterion}
- [ ] {Another criterion}
```

Good: `⛔ GATE: Registry updated AND sprint-state patched AND both verified.`
Bad: `⛔ GATE: Everything looks correct.`

**Format** (mandatory-output gate — reproduce CLAUDE.md markers at the write point) (v2.1.0, C4):

When CLAUDE.md defines a mandatory output marker (e.g., `[WRITE-VERIFIED]`, `[TPU-VERIFIED]`, `[CP-1]/[CP-2]/[CP-3]`), the skill MUST reproduce the exact marker in-file at the step where the write occurs. Cross-referencing CLAUDE.md alone is insufficient — the marker's visibility **at the write point** is what triggers the LLM to emit it.

```markdown
### STEP 5 — Write and verify sprint-state

After Edit:

⛔ MANDATORY OUTPUT (reproduce this marker literally in the response):
⛔ [WRITE-VERIFIED] {file_path} | anchor: "{anchor}" | status: {present|missing}

The anchor must be a literal substring from the just-written content. Without this marker appearing in the response, the verification protocol is skipped — which is a CRITICAL violation per CLAUDE.md [Section: Violation-Reference].
```

**Why in-file**: LLMs at high context can reliably follow imperatives that are co-located with the triggering action. Cross-references to CLAUDE.md rely on memory-first compliance, which degrades under token pressure. In-file reproduction makes the gate visually unavoidable.

### Canonical ⛔ Marker Catalog (v2.1.0, F6)

Authoritative enumeration of defined verification markers across NEXUS. When a skill reaches a write point governed by one of these markers, reproduce the marker literally at that step (per the mandatory-output rule above).

| Marker | Defined in | Fires at |
|---|---|---|
| `[WRITE-VERIFIED]` | CLAUDE.md [Section: File-Operations-Protocol] | Write/Edit to high-stakes files (sprint-state, registries, ISS structural edits, CLAUDE.md, skills) |
| `[TPU-VERIFIED]` | CLAUDE.md [Section: Two-Place-Update-Protocol] | Every issue phase score update (registry + sprint-state [OBJECTIVES]) |
| `[CP-1]` / `[CP-2]` / `[CP-3]` | `/nexus-checkpoint` SKILL.md | Checkpoint workflow gate outputs (sprint-state prep, verification, save confirmation) |
| `[PRIMARY-VERIFIED]` | `/nexus-research` SKILL.md §C.1 Primary-Source Verification Gate | Resuming Research at an analytical phase (Analysis / Deliverable) when prior phases produced primary artifacts |
| `[SKILL-INVOKED]` | `/nexus-close-sprint` SKILL.md invoke-required steps | At a closure step that mandates invoking an owning skill (proves the skill was routed through, not inlined) |

**Catalog is authoritative for ⛔ marker names.** Additions land with new gate-bearing skills — new markers MUST be added to this catalog when their skill ships, not renamed or repositioned. (Example: `[PRIMARY-VERIFIED]` lands with ISS-162 `/nexus-research` F2+F3+F6 polish; when ISS-162 ships, this catalog gets a new row for it, not a rename of existing markers.)

Skills that use a catalog marker reproduce it in-file at the write point per the Verification Gates rule above; skills that introduce a *new* discipline-critical marker must simultaneously propose its addition to this catalog before shipping.

### Gate Reference Table (selective — when 3+ gates)

```markdown
## Gate Reference

| Gate | Tier | Full | Balanced | Streamlined |
|---|---|---|---|---|
| {gate name} | T{N} | {behavior} | {behavior} | {behavior} |
```

---

## Maintenance Operation Conventions (selective — maintenance domain only)

Operations orchestrated by /nexus-maintain have additional interface requirements.

### Scan Boundary Convention

Every maintenance operation that can be parallelized in Mode B must have a clear **scan boundary** — the step after which all assessment is complete but no fixes have been applied.

Mark the boundary in the skill file:

```markdown
### STEP {N}: Initial Score Assessment
<!-- SCAN BOUNDARY — Agent contract stops here in Mode B -->
```

Everything before this step = read-only scan (safe for agent dispatch).
Everything after = user interaction + writes (main context only).

### Initial Score Output

Maintenance operations that track health must calculate and output an initial score BEFORE applying fixes:

```markdown
Calculate initial health score: `initial_score = {formula}`
Persist to system-state [Health-Operations].{operation}: score = {initial_score}, last_run_sprint = {current}
Output: `initial_score: {value}`
```

This captures the actual degraded state before fixes. Used by Maintain Phase 3E for degradation rate calibration.

### System-State Health Update

After fixes are applied, calculate final score and update system-state:

```markdown
Calculate final health score: `final_score = {formula}`
Update system-state [Health-Operations].{operation}: score = {final_score}, last_run_sprint = {current}
```

### Agent Contract Compatibility

When run as a scan agent (Mode B), the operation must be able to return structured results:

```
## {Operation Name} Scan Results
### Initial Score: {X}/100
### Findings ({total_count})
#### CRITICAL ({count})
- {finding}: proposed fix — {action}
#### IMPORTANT ({count})
- {finding}: proposed fix — {action}
#### MINOR ({count})
- {finding}: proposed fix — {action}
### Files Examined: {count}
```

### Mode B Agent Write Rules

Agents can write their operation's own `initial_score` to system-state [Health-Operations] — this is safe, self-contained health tracking. Agents must NOT write to project data files (registries, ISS files, project-state, sprint-state). All project data fixes happen in main context after user approval.

### Mode B Fix Phase — Re-Read Requirement

When findings come from scan agents (Mode B parallel dispatch), the agents read files in their own context — not the main conversation's. Before applying fixes in the main context, **read each file that needs patching**. The Edit tool requires the file to have been Read in the current conversation. This is a Claude Code tool constraint.

Add a note at the fix application step:
```markdown
**Mode B note**: If findings came from scan agents, read each file section you need
to patch before applying fixes.
```

### Report Export (optional)

Maintenance operations may offer to export a report to `Maintenance-cycles/{sprint}/`:

```markdown
> Save report to Maintenance-cycles/{sprint}/{operation}-report.md? [Y/n]
```

### Mental Note Directives

When called within Maintain's execution loop, each step should end with a mental note directive that supports checkpoint continuity:

```markdown
> **Mental note**: {Step} complete. {Key state}. If checkpoint → {what to persist}.
```

---

## User Approval (required for write operations)

Operations that modify files must get explicit user approval before writing. Present what will change, wait for confirmation. This is a separate step — don't bury approval inside a larger step.

For structured choices with 2-4 options, use `AskUserQuestion` tool to present clickable options rather than asking the user to type a number.

For destructive actions (delete, archive, close), require explicit confirmation with consequences shown — these are T1 gates.

---

## Validation (recommended)

Before applying changes, validate inputs: field values in allowed sets, scores in valid ranges, related fields logically consistent, content meets minimum quality. The LLM applies semantic judgment — it doesn't need rigid validation rules for every field.

---

## Atomic Transactions (recommended for multi-file operations)

When an operation touches multiple files, all changes should succeed together or none should persist:
1. Build all patches in memory
2. Execute writes sequentially with backup
3. Verify all changes applied
4. If any write fails: reverse in order, inform user

Applies to: closing issues (entity + registry + sprint-state), archiving (move + remove), any multi-file update.

---

## Modes and Entry Points (selective — only when genuinely needed)

Some operations behave differently depending on caller:

| Mode | Behavior | Example |
|---|---|---|
| Manual | Interactive — confirmations, detailed display | User invokes directly |
| Batch | Streamlined — auto-decisions, compact display | Called by close-sprint for each issue |
| Backend | No prompts — validate and execute | Called programmatically with complete data |

If an operation is always called the same way, skip mode handling entirely. Most operations are single-mode.

---

## Checkpoint Integration (selective — for operations called within methodology loops)

Operations called by methodology skills (especially Maintain) may need checkpoint awareness.

### When to Include

- Operation is called within a loop (Maintain's execution loop)
- Operation takes significant context (>20K tokens)
- Operation spans user interactions that could be interrupted

### What to Include

Mental note directives at step boundaries:
```markdown
> **Mental note**: {Step} complete. {State summary}. If checkpoint → {persist what, where}.
```

The calling methodology skill reads these for its own checkpoint persistence.

---

## End-of-Workflow Checklist (selective — complex operations only)

For operations with multiple write targets, cross-entity effects, or closure semantics, include a checklist before the final report step.

```markdown
## End-of-Workflow Checklist

- [ ] {Primary write completed and verified}
- [ ] {Secondary write completed (registry, sprint-state)}
- [ ] {Cross-references updated}
- [ ] {Caller contract fulfilled (return value, state updates)}
```

**When to include**: close-sprint, organize-sprint, subsystem-verification, maintenance operations that write to system-state + registries, and any operation touching 3+ files. Not needed for simple CRUD or display operations. Without this checklist, system-state updates get skipped in practice — validated during live testing.

---

## Error Recovery (recommended)

Don't try to anticipate every failure. Handle only **known, common failure modes** with specific guidance:

```markdown
## Error Recovery

| Problem | Recovery |
|---|---|
| {common failure} | {specific guidance} |
```

For multi-file operations, note that partial completion creates inconsistent state — the LLM should recognize this and work with the user to resolve.

---

## Discipline Enforcement Layer (required for discipline-critical skills) (v2.1.0, PAT-102; v2.3.0 verification-class tier, ISS-204)

Skills whose correctness depends on catching LLM over-claiming, premature completion, or gate-skipping MUST include this layer. Non-discipline operations (view, status, display, list) omit it — they have no surface to protect.

### Required set by skill class (two tiers)

Discipline-critical skills divide into two classes by *what* they over-claim. Each class has its own **required set** — adopt the set that matches the skill's class:

| Skill class | Over-claiming surface | Required set | Target surfaces |
|---|---|---|---|
| **Write / close** — state-mutating, completion-declaring | Premature completion ("done" before the checklist is verified); a skipped write-point gate | **Full Layer** — all 6 components (§1–§6 below) | `/nexus-validate`, `/nexus-close-issue`, `/nexus-checkpoint` |
| **Verification** — detect-and-propose, non-mutating | A false *verdict* ("✅ clean") or false *finding-completeness* ("no findings") on under-examined input | **Verification-Class Lightweight Adversarial Core** — the 3 components in §Verification-Class Core below | `/nexus-subsystem-verification`, `/nexus-issue-validation` |

**Classifying a new discipline-critical skill**: does it mutate state / declare completion? → Full Layer. Does it detect-and-propose without mutating? → Verification-Class Core.

**"No subset" reconciled, not contradicted.** Within the Full Layer, the six components are interdependent — do not adopt a subset; scattered components read as individually optional and collective coverage goes invisible (PAT-102). The Verification-Class Core is **not a subset of the six** — it is a *distinct required set* for a different skill class, scoped to that class's narrower surface (the verdict, not a state mutation). A verification skill adopts the Core in full; a write/close skill adopts the Full Layer in full; neither cherry-picks from the other. (This is the streamlined-set philosophy PAT-102 already anticipates in its Variant B, and it answers the named risk "using the full 6-component layer where [a streamlined set] would suffice.")

### Full Layer (write/close skills) — the six components

The Full Layer has six integrated components. **Do not adopt a subset — they reinforce each other.** PAT-102 notes the interdependence: when components are scattered across checklist items, readers treat each as individually optional and the collective coverage becomes invisible.

### 1. Default Adversarial Posture

The operation runs adversarial by default. Starting assumption: the work under review has a problem. The search is for what is wrong, not confirmation that it is right.

Complexity gates depth of review (more cognitive tools at C:3+), not stance. A C:1 validation runs adversarial too — C:1 issues are exactly where validation fatigue produces rubber-stamping.

```markdown
## Posture

This operation runs adversarial by default. I assume the work under review has a problem until evidence proves otherwise. I do not confirm; I challenge.

Downgrade from adversarial to collaborative only on:
- Explicit user override ("skip adversarial") with logged rationale in [DECISIONS]
- Routine-class work with zero precedent failures (document first instance)

Never downgrade on complexity score alone.
```

### 2. Red Flags Vocabulary

Named language patterns that signal over-claiming, gate-softening, or verification shortcuts. Catch at write point.

| Red Flag | Signal | Corrective |
|---|---|---|
| "should" / "probably" / "seems to" | Soft imperative — gate about to be skipped | Replace with imperative or prohibition |
| "Great!" / "Done!" / "All set!" | Premature completion signal — checklist not verified | Require explicit checklist output before celebration vocabulary |
| "I'll assume..." / "Given that..." | Assumption insertion — evidence skipped | Halt, verify assumption from disk or user |
| "It seems correct" / "Looks good" | Verification shortcut — no anchor extracted | Require literal anchor substring from just-written content |
| "This should work" | Hypothetical completion — not tested | State what would verify it, then verify |
| "Moving on to..." before gate output | Gate output suppressed — protocol skipped | Emit gate output before transition |

**Placement rule**: Red Flags table reproduces in-file at skills that write state or close entities. The language patterns need to be visually adjacent to the write/close step to catch real-time drift — cross-referencing CLAUDE.md is not sufficient under context pressure.

### 3. Rationalizations to Watch For

Pre-refutation of common LLM excuses for skipping discipline. At token pressure LLMs generate plausible-sounding justifications; pre-committing the counter-argument to disk closes the loophole.

| Excuse (you might think this) | Reality (why the excuse is wrong) |
|---|---|
| "This issue is simple, it doesn't need full validation." | Complexity is orthogonal to validation need. Simple + subtle > complex + obvious. |
| "The build was clean — the closure checklist is redundant." | Build self-review and closure validation operate on different evidence. One doesn't substitute for the other. |
| "Context is tight, so I'll skip the adversarial round." | Context pressure is *exactly* when drift happens. Adversarial stance is the structural safeguard against context-fatigue shortcuts. |
| "The user approved the plan, so the gate is satisfied." | Plan approval ≠ execution verification. Gates fire at each write point regardless of prior plan approval. |
| "I already verified once this phase, re-verifying is redundant." | Verification is write-scoped, not phase-scoped. Each write is its own gate. |

Skills may add domain-specific rationalizations they've observed drifting.

### 4. Anti-Patterns (Named with Why-Bad)

Gate-level anti-patterns. Each entry: the pattern name, "What it looks like", "Why bad", "Corrective."

#### ❌ Gate-Dressed Conditional ("softened imperative")

**What it looks like**: A gate that uses "should", "probably", or "it's recommended to" instead of imperatives or prohibitions.

**Why bad**: The LLM interprets the softened phrasing as a suggestion, not a requirement. At context pressure, suggestions get skipped. Gate fails silently.

**Corrective**: Replace with hard-gate phrasing per §Gate Annotations. Every gate has an imperative verb or an explicit prohibition.

#### ❌ Cross-Reference-Only Gate

**What it looks like**: Skill says "per CLAUDE.md [Section: X], apply the verification gate" — no in-file reproduction of the gate marker.

**Why bad**: Cross-references rely on memory-first compliance. Under token pressure the LLM follows the literal text of the current skill, not the resolved content of CLAUDE.md. If the gate output isn't literally present in the skill at the write point, it gets skipped.

**Corrective**: Reproduce the gate marker in-file at the write point. Cross-reference for context, inline for enforcement.

#### ❌ Post-Hoc Adversarial (for validation skills)

**What it looks like**: "After the collaborative review, apply adversarial review if complexity ≥ 3."

**Why bad**: The collaborative review has already anchored the validator's perception. Adversarial review operating on a pre-accepted frame finds only surface-level issues. True adversarial stance must be the starting posture, not a post-hoc check.

**Corrective**: Validation skills default to adversarial per §1 Default Adversarial Posture above. Complexity gates depth, not stance.

#### ❌ Constraint-Wall-Only (no inline reminders)

**What it looks like**: All constraints in a top-of-file §Constraints block; no inline restatement at risky steps.

**Why bad**: By STEP 5, the reader (LLM or human) has forgotten STEP 1's prohibition. Drift happens at the tempting step, not the top of the file.

**Corrective**: Consolidated §Constraints block stays (exhaustive list), plus inline constraint restatement at steps with observed drift (per §Step Design → Inline Constraint Placement).

#### ❌ Placeholder Shipping

**What it looks like**: Skill text contains `TBD`, `{describe}`, `similar to Step N`, or `// TODO`.

**Why bad**: The LLM interprets the placeholder as a cue to improvise. Improvisation at the placeholder point defeats the skill's structuring purpose.

**Corrective**: Grep for named offenders before shipping. Zero hits required. (See §Playbook → No-Placeholder Rule.)

#### ❌ Premature-Completion Vocabulary

**What it looks like**: Skill body contains "Great!", "Done!", "All set!", "The work is complete" before the end-of-workflow checklist is verified.

**Why bad**: Celebration vocabulary signals closure to both the LLM and the user. Closure vocabulary inside the skill's reasoning path produces false-completion.

**Corrective**: Use neutral verbs ("Proceed", "Advance", "Transition"). Celebration-language only in the final Display Template after the checklist passes.

#### ❌ Silent Downgrade

**What it looks like**: Skill silently adjusts its behavior based on context usage, control level, or fatigue signals without surfacing the downgrade.

**Why bad**: The user thinks they're getting full execution; they're getting partial. Breaks Continuity + Consent principles.

**Corrective**: Any downgrade must be visible. "Proceeding with reduced scope because {reason}. Items dropped: {list}." Downgrade is a user-facing event, not an internal optimization.

#### ❌ Over-Specified Step

**What it looks like**: Step describes every micro-action: "Open file. Read line 34. Change `foo` to `bar`. Save. Close. Open second file..."

**Why bad**: The LLM treats the skill as executable code. Intelligence is traded for execution fidelity. The step can't handle edge cases the author didn't anticipate.

**Corrective**: Describe the waypoint ("Patch the score field in sprint-state [OBJECTIVES]"), let the LLM navigate. Obligatory waypoint, not execution path. (See §Nature of Operations.)

#### ❌ Under-Specified Step

**What it looks like**: Step says "Handle the analysis" or "Validate appropriately" with no criteria, targets, or outputs.

**Why bad**: Pure-prompting failure. The LLM applies judgment everywhere, including where it shouldn't. Drift inevitable.

**Corrective**: Specify WHAT must happen (criteria, outputs, waypoints), leave HOW to LLM judgment. Behavioral specification per PAT-004.

Both over- and under-specification fail; the target is behavioral specification between them.

### 5. Bounded Iteration Cap

When a discipline gate fails and requires retry (e.g., "evidence insufficient, gather more"), cap retries at **three attempts** for the same gate in the same phase. After three failures, escalate rather than continue iterating.

```markdown
## Iteration Cap

If a gate-check fails, retry up to 3 times with incremental evidence-gathering. On the 3rd consecutive failure:

ESCALATE — do not continue retrying. Return control to caller (main context) with:
- Gate name
- What was attempted (3 bullets)
- What remains missing

Rationale: iterative failure past 3 attempts signals a structural problem, not a gatherable-evidence problem. Continuing to iterate produces confabulation.
```

Scope: applies per-gate, per-phase. Three retries on the same gate in the same phase is the limit; a later phase may re-attempt the same gate fresh.

### 6. FILLED / ESCALATED / SKIP Classification

Every discipline check terminates in one of three explicit states. No silent passes, no implicit skips.

| State | Meaning | Required output |
|---|---|---|
| **FILLED** | Gate check completed with evidence. Work passes. | Evidence anchor (literal substring from artifact) + gate name confirmed |
| **ESCALATED** | Gate check failed after iteration cap OR surfaces issue main context must resolve | Escalation reason + what was attempted + what blocks |
| **SKIP (justified)** | Gate deliberately not applicable to this work | Explicit justification + reference to the rule that permits skip |

An unsatisfied gate must resolve to ESCALATED or justified SKIP — never to "proceeding anyway" or silent continuation. If the skill doesn't produce one of the three classifications at each gate, the gate is not enforced.

### Verification-Class Lightweight Adversarial Core (v2.3.0, ISS-204)

The required set for **verification skills** — detect-and-propose, non-mutating (`/nexus-subsystem-verification`, `/nexus-issue-validation`). These skills don't declare completion or mutate state; their failure mode is a **false verdict** — a "✅ clean" on a file that was only skimmed, or a "no findings" report that missed a real one. The Core targets exactly that surface with three components.

It is deliberately **not** the Full Layer: the authoring-oriented components (Red Flags table, Anti-Patterns with why-bad, Bounded Iteration Cap) protect skill *authoring* and write-point discipline, not verification *runtime*; importing them would over-fit a detect-and-propose skill (adapt-not-adopt; simplicity). **The Core is exactly three components — do not balloon it into a second full layer.**

#### VC-1. Default Adversarial Posture

Declared near the top of the skill, not complexity-conditional. Starting assumption: **the artifact under verification has a problem, and a "clean" verdict must be earned with scan evidence — not reached by the mere absence of anything that happened to catch the eye.** Same stance as Full-Layer §1; the verification skill challenges its own clean verdicts rather than confirming them.

```markdown
## Posture

This skill runs adversarial by default. I assume the artifact under verification has a problem until scan evidence proves otherwise. A "clean" verdict is earned by showing what was examined — never reached by the absence of noticed problems.
```

#### VC-2. FILLED / ESCALATED / SKIP at every verdict gate — carrying the bound/candidates pair

Every per-file / per-check / per-report verdict terminates in one of three explicit states — never a bare "✅ clean" or "no findings":

| State | Meaning (verification context) | Required output |
|---|---|---|
| **FILLED** | Checked with evidence; verdict stands | Verdict + the **bound/candidates pair** (below) |
| **ESCALATED** | Finding surfaced, check inconclusive, OR `bound < candidates` | What was found / what blocks + what was attempted |
| **SKIP (justified)** | Check deliberately N/A to this artifact | Explicit justification + the rule that permits the skip |

**The pair, not a single number.** One figure is forgeable: a finding count reads identically whether the check examined the whole class or parsed nothing at all. A FILLED verdict reports **two independent figures alongside the result**:

```
{findings} findings / {bound} bound / {candidates} candidates
```

- **candidates** — how many items the check was *supposed* to examine, derived from the corpus (registry rows, files in the class, entries in a references array).
- **bound** — how many of those it actually *resolved*: parsed, matched, opened. This is the consumption proof, and it is the figure a vacuous run cannot fake.
- **`bound < candidates` invalidates the verdict.** The instrument did not consume its input, so the finding count says nothing about the class. Terminate ESCALATED, never FILLED.
- **`candidates == 0` invalidates the verdict.** An empty candidate set is either a wrong path or a real finding, and the predicate cannot tell which — so it must not certify. `0 findings / 0 bound / 0 candidates` satisfies `bound < candidates` **on a technicality** while being the exact vacuous pass this component exists to catch. Terminate ESCALATED. *(ISS-240 IE-3, ruled contract-level at Evaluation, Sprint 111: a sabotage arm pointed a predicate at an empty corpus and got a clean verdict on a corpus that was never read. The same defect then recurred in a second edge, where the candidate counter sat one line above the file-existence check and made this floor unreachable — so the floor must be stated in the contract, not re-derived per predicate.)*
- **`findings > candidates` invalidates the verdict.** The inequality set constrains `bound` against `candidates` and, without this row, says nothing about `findings` — so `108 findings / 106 candidates` was contract-legal and shipped in two edges until a sabotage arm printed it. A finding count exceeding the candidate set is not a near-miss; it is proof the two figures were **never counted over the same corpus**, which makes the pair meaningless in both directions. Terminate ESCALATED.
- **`bound` must be INDEPENDENTLY DERIVED — it may never be assigned from `candidates`.** Increment it on the *success* path of consuming a candidate, after every guard that can skip, fail, or `continue`. Reporting the same variable for both figures, or initialising both to one shared constant and incrementing them in lockstep, makes `bound < candidates` **unsatisfiable by construction** — the inequality still appears in the output and can no longer fire.

  *(ISS-240, ruled contract-level at Evaluation, Sprint 111. Measured across that issue's 15 shipped predicates: **9 of 15** could never satisfy the inequality — 7 printed the same variable twice, 2 initialised both to a constant and incremented them together. The contract had mandated the pair and left its production unconstrained, which is ISS-248 TD-5's shape one level up: a rule that specifies the figure but not how the figure is earned. This is also the defect that let a fourth vacuous pass — edge E-07 — survive a 3× independent review pass that had already found ten others in the same artifact.)*

  **Reference shape** — `bound` incremented only after the guard, and the inequality asserted rather than merely reported:

  ```sh
  cand=0; bound=0
  for item in $set; do
    cand=$((cand+1))
    parse "$item" || continue          # <- the guard sits BETWEEN the two counters
    bound=$((bound+1))
  done
  [ "$cand" -eq 0 ] && { echo "ESCALATED: candidates 0 ({unit})"; exit 2; }
  [ "$bound" -lt "$cand" ] && { echo "ESCALATED: bound $bound < candidates $cand ({unit}) — an item did not resolve"; exit 2; }
  ```

  A denominator that is a hardcoded literal is the degenerate case and is never acceptable on its own: it must be paired with a positive check that the subject was actually located and read, or the verdict is identical on a populated corpus and an empty file.

**Name the unit, and use these two words.** Two requirements, both learned from getting them wrong:

1. **The unit is part of the figure** — `88 candidates (references)`, not `88 candidates`. A skill with more than one verdict gate counts a *different corpus* at each one, so a bare number is ambiguous exactly where two gates are compared. A denominator that does not say what it counts is the defect this component exists to fix, one level up.
2. **`bound` and `candidates` are the canonical words** — a deployment that renames them (`parsed`, `resolved`, `checked`, `total`) is invisible to any cross-file audit grepping the contract's vocabulary. Gloss freely in prose (*"bound — i.e. headers actually parsed"*); do not substitute in the reported figure.

`0 findings / 88 bound / 88 candidates` is an earned clean. `0 findings / 0 bound / 88 candidates` is the vacuous pass this component exists to catch — byte-identical to success in every respect except the one figure that gives it away.

**Coverage companion — required only where the predicate is discretionary.** 📐 PAT-135: an evidence figure proves *execution*, not *adequacy*, and a well-shaped artifact confers credibility the underlying run may not deserve. Where the candidate set is produced by a **human-authored predicate** — a grep pattern, a glob, a sample selection — the verdict additionally records the **literal predicate verbatim** and the **variants enumerated** for any name it matches (punctuation, hyphenation, spacing, casing, singular/plural). Treat a suspiciously low `bound` as a predicate defect until disproven.

Not required where the candidate set carries no author discretion — the schema or tool fixes the scope (e.g. "every row in `documentation-registry.yaml`"). This is PAT-135's own Not-When; requiring it there is ceremony, not coverage.

**Coverage applies at every verdict gate AND every early-exit path.** An early exit *is* a verdict — the skill asserts there is nothing further to report — and it is the site least likely to carry one, precisely because it does not look like a verdict gate.

Derive the exit set with an **executable predicate, never a hand-list** (📐 PAT-121 — an enumeration failure cannot be answered with another enumeration). Reference predicate, and the one this component was authored and dogfooded against:

```bash
grep -nE '(^|[^A-Za-z])[Ee]xit([^A-Za-z-]|$)|[Rr]eturn to caller|nothing more to do|[Ss]top here|[Ss]kip to STEP|[Aa]bort|[Hh]alt\b|[Dd]one —|[Tt]erminate' {skill-file}
```

Exit criterion: **every hit is fixed or classified** — never "grep returns 0" (📐 PAT-142). A zero result is itself a finding and is recorded **with the literal command that produced it**; reporting a zero as silence is this component's own failure mode committed inside the fix.

**A self-referential predicate's evidence is a CLASSIFICATION, never a count.** When the predicate is stated inline in the file it scans — the normal case, since this paragraph tells you to record the command next to its result — it matches its own documentation, so every edit that records the count falsifies it. Measured live: `0 → 6 → 8` across three successive edits, none converging. Record the hit **classes** (which are verdict-bearing, which are conformance text, which are self-reference) and require the count be **re-derived at read time**. A number committed to that file is a stale derived value inside the very file that produced it. *(ISS-248 TD-5, ruled contract-level at Evaluation.)*

#### VC-3. False-Clean / False-Empty Rationalization

Pre-refute the one excuse this skill class is prone to, co-located at the verdict step:

| Excuse (you might think this) | Reality |
|---|---|
| "Nothing jumped out, so it's clean." | Absence of *noticed* problems ≠ verified-absent. A clean verdict requires positive scan evidence (what was checked), not the failure to notice something. |
| "No findings to report — skip the evidence." | A false-empty report is the documented verification failure mode (Sprint 084 ISS-184 false-empty precedent). "No findings" must still state what was examined to reach that conclusion. |

Skills may add one or two domain-specific false-verdict rationalizations they observe.

### Layer Audit Checklist

**Full Layer** (write/close skills) — audit against:

- [ ] Default Adversarial Posture declared (not complexity-conditional)
- [ ] Red Flags table reproduced in-file (not cross-referenced only)
- [ ] Rationalization table present with ≥4 excuse/reality pairs
- [ ] Anti-Patterns section with Why-bad sub-labels (9 base entries inherit from this template; skills may add skill-specific ones)
- [ ] Bounded Iteration Cap specified (3-attempt rule)
- [ ] FILLED / ESCALATED / SKIP required at each gate
- [ ] No softened gate phrasing (per §Gate Annotations Hard vs Soft rule)

**Verification-Class Core** (verification skills) — audit against:

- [ ] VC-1 Default Adversarial Posture declared near the top (not complexity-conditional)
- [ ] VC-2 FILLED / ESCALATED / SKIP produced at every verdict gate **and every early-exit path** — no bare "✅ clean" / "no findings"; FILLED carries the **bound/candidates pair**, and `bound < candidates` terminates ESCALATED rather than passing
- [ ] VC-2 inequality set complete at every verdict gate — all three floors asserted, not just the first: `bound < candidates` → ESCALATED · `candidates == 0` → ESCALATED · `findings > candidates` → ESCALATED
- [ ] VC-2 `bound` **independently derived**, never assigned from `candidates` — incremented after the guard that can skip/fail, not in lockstep with the candidate counter and not printed as the same variable. A hardcoded denominator is paired with a positive subject-located check. *(An unsatisfiable inequality is the audit's blind spot: it reads correct in the output and can never fire.)*
- [ ] VC-2 exit set derived by the executable predicate, not hand-listed — its output recorded, and any zero-hit result recorded **with the literal command that produced it**, never as silence
- [ ] VC-2 self-referential predicate (inline in the file it scans) records hit **classes** with a re-derive-at-read-time instruction — never a committed count, which its own recording edit falsifies
- [ ] VC-2 coverage companion present wherever the candidate set rests on a discretionary predicate (literal predicate + enumerated variants) — or explicitly recorded N/A because the schema fixes the scope
- [ ] VC-3 False-clean / false-empty Rationalization present at the verdict step (≥1 excuse/reality pair)
- [ ] Core capped at the 3 components — no authoring-oriented components (Red Flags table, Anti-Patterns, Iteration Cap) imported
- [ ] No softened gate phrasing (per §Gate Annotations Hard vs Soft rule)

---

## State and Registry Interactions (required for write operations)

Be explicit about what is read, what is written, where, and when.

### Reading

Prefer minimal loading:
- **Registry fields**: Grep for specific entity fields (not full registry load)
- **Entity files**: Read specific sections when possible
- **Sprint-state**: Usually in memory from boot

### Writing

- **Two-place updates**: When changing issue scores/status → BOTH registry AND sprint-state [OBJECTIVES]. Per [Section: Two-Place-Update-Protocol].
- **Entity file content**: Update entity file only. No metadata in entity files.
- **Always verify after writing**: Read back to confirm.

---

## Display Templates (recommended)

User-facing output should have consistent format:

```
✅ {Operation} Complete
════════════════════════════════════════
{Summary line}
{Key outcome 1}
{Key outcome 2}
════════════════════════════════════════
{Next steps or options}
```

Use `═══` for major dividers, `───` for minor. Symbols: ✓ success, ⚠️ warning, ❌ error, 📊 data, 💡 suggestion.

---

## Format Selection (recommended)

| Content Type | Use | Why |
|---|---|---|
| Behavioral rules, principles | Prose | Captures reasoning for edge cases |
| Sequential steps without branching | Prose | Direct, no overhead |
| Field updates, calculations | YAML | Unambiguous field→value |
| Conditional logic, multiple paths | Table or decision tree | All paths visible |
| Parallel items with same fields | Table | Dense, scannable |
| Display output for user | Code block template | Exact layout control |

---

## Playbook: Design Principles (recommended reading)

When creating or revising operation skills, apply these principles:

**Write for an intelligent reader, not a code interpreter.** Describe what to achieve and what matters, not every mechanical step. Avoid defensive coding patterns — exhaustive exception handling, keyword-based matching, rigid branching for unlikely scenarios.

**Clarity over compression.** The goal is not smaller files but clearer instructions for a fresh LLM instance. Every change should pass: "Will a fresh instance follow this more clearly?"

**Single responsibility per step.** If a step does two things, split it. User approval gates deserve their own steps.

**Don't restate CLAUDE.md protocols.** Memory-first, verification discipline, user consent, file operations protocol — these are defined in CLAUDE.md and always active. Reference them, don't re-teach them. Example: write "Update scores per two-place protocol" and provide the specific field values.

**Preserve operational specifics.** While avoiding CLAUDE.md duplication, keep skill-specific details: which registry fields to read, which sprint-state sections to update, exact display formats, specific validation rules. These make the operation deterministic.

**YAML only when structure IS the information.** Use YAML for field mappings, registry patches, search patterns. Use prose for procedures. Use tables for parallel data with shared fields.

**Inline vs delegate for cascade effects.** When an operation discovers follow-up work (orphaned issues, new issues, queue reorg), decide by cost: inline lightweight actions the user can approve on the spot; suggest heavy operations as a next step. Don't call a 30K-token operation from inside another without explicit need.

**Loop-back for edit operations.** Operations supporting multiple edit cycles need: a return-to-selection step after completion, and a re-read of edited sections from disk on loop-back — memory content is stale after patching.

**Backend operations stay focused.** If primarily called by another operation (e.g., close-sprint calling project-state update), don't add manual interactive modes. Stay lean for the primary caller.

**Validation after rewriting.** Walk through as a fresh instance: Can I find what to DO in under 5 seconds per step? Are all steps numbered sequentially? Would I get this right without improvising? Does removing any sentence lose actionable guidance?

**Domain-level assessment.** After completing rewrites across a domain (3+ operations changed), run subsystem-verification to catch inter-operation issues: shared state format mismatches, broken delegation chains, stale references.

**Keep the system map current.** After renaming, merging, or creating operations: update routing map, menu entries, changelog-registry, and subsystem-verification domain definitions.

### No-Placeholder Rule (v2.1.0, C5 generalized)

Skill drafts must not ship with placeholder text. The rule is domain-neutral; the offenders vary by project type.

**Framing** (per obra writing-plans raw source, verified): placeholders are **plan failures — never ship them**. Zero-tolerance list; any draft containing these is not ready to commit.

#### Universal offenders (all project types)

- `TBD` / `TODO` / `FIXME` — if the content isn't decided, the skill isn't ready to ship
- `{describe this}` / `{example here}` / `{placeholder}` — draft scaffolds that survived
- `similar to {other step}` — forces the reader to reconstruct; be explicit
- `// TODO` / `<!-- placeholder -->` / `NOTE: expand later` — comment leakage
- `"Write tests for the above"` (without actual test code) — test stub in text, not a test
- Bare `{variable}` without defined substitution (outside the canonical placeholder standard below)

#### Project-type-specific offenders

| Project type | Domain-specific offenders |
|---|---|
| software-product-dev / system-integration | "add error handling", "handle edge cases", "refactor later", "optimize if needed" |
| creative-content | "expand this scene later", "flesh out dialogue", "revise for voice", "TK" (journalistic placeholder) |
| compliance-audit | "verify control Y", "confirm with legal", "TBD — finding severity", "pending evidence" |
| operations-process | "detail later", "copy from procedure N", "adapt from template", "verify with ops team" |
| research-analysis | "sources to add", "pending literature review", "needs citation", "draft hypothesis" |
| educational-training | "add learning objective", "add assessment", "expand explanation", "example TBD" |

The project-type-specific lists should live in the corresponding `project-types/{type}.md` profile, not all in this template — the template references; profiles extend.

#### Authoring protocol

Before committing a new skill or skill revision, grep for each offender. Zero hits required. Suggested pre-commit check:

```bash
# Universal offenders
grep -nE '\b(TBD|TODO|FIXME|TK)\b|\{[a-z_ ]+\}|similar to (Step|Task) [A-Z0-9]+' {skill-file}

# Project-type offenders (extend per detected project type)
grep -nE 'add error handling|handle edge cases|expand this scene|verify with legal|pending evidence' {skill-file}
```

If a placeholder represents a genuine unknown, document the unknown explicitly in §Error Recovery as a named failure mode, not as a placeholder in the step body.

### Canonical Placeholder Standard (v2.1.0, C10)

NEXUS uses these placeholder conventions — match when authoring new skills.

**Framing**: Canonical Placeholder Standard is **NEXUS-derived convention**, informed by spec-kit's per-tool placeholder observation but matching actual NEXUS practice. Attribution: spec-kit's insight is "standardize placeholder per template-type"; NEXUS operationalizes this with NEXUS-specific forms. Read the standard as internal NEXUS convention, not external tool inheritance.

| Form | Use for | Example |
|---|---|---|
| `{XXX}` | Entity IDs (3-digit padding: `ISS-{XXX}`, `PAT-{XXX}`) | `ISS-{XXX}` |
| `{N}` | Counts, small integers | `Conv: #{N}` |
| `{name}` | Arbitrary identifier strings | `/nexus-{name}` |
| `{path}` | File paths | `Read {path}` |
| `{field}` | Schema field names (registry keys) | `{field}:` |
| `$ARGUMENTS[N]` | CLI argument (positional) — verified NEXUS practice in 5 methodology SKILL.md routers | `$ARGUMENTS[0]` → ISS ID |

Do NOT use: `{{args}}` (TOML/Forge-specific; NEXUS does not use TOML frontmatter), `<arg>`, `[variable]`, `<<placeholder>>`, `%%X%%`. Different forms signal different things (LLM input vs template literal vs regex vs sed) — noise without distinction.

Drift in placeholder form across skills is catch-worthy at audit.

---

## Registration Requirements (required for new skills)

When creating a new operation skill:
1. Create `.claude/skills/nexus-{name}/SKILL.md` with proper frontmatter
2. Add to CLAUDE.md [Section: Routing-Map] (command triggers → `/nexus-{name}`)
3. Add to appropriate `/nexus-menu` domain page (menu entry)
4. Add to changelog-registry.yaml (version entry)

Naming: `nexus-{verb}-{noun}` (e.g., `nexus-organize-sprint`, `nexus-create-issue`).

---

## Audit Checklist

When reviewing an existing operation skill, verify:

### Structure (all operations)
- [ ] **Frontmatter present** — name, description, disable-model-invocation
- [ ] **Version header** — first content line after frontmatter
- [ ] **Flow summary** — one-line execution path overview
- [ ] **Purpose stated** — 1-2 sentences
- [ ] **STEP 0 loads only what's needed** — no full file reads when section suffices
- [ ] **Each step has single responsibility** — no multi-purpose steps
- [ ] **Clean sequential numbering** — no gaps, no orphaned sub-steps
- [ ] **Format matches content** — prose for procedures, YAML for fields, tables for parallel data
- [ ] **Line band checked (9a)** — `SKILL.md` ≤ 600 lines; over-band → playbook §9b externalization test (signal, not auto-fail)

### Gates (operations with approval points)
- [ ] **Gate annotations present** — `[T1]`/`[T2]`/`[T3]` with behavior hints
- [ ] **User approval before writes** — explicit confirmation step
- [ ] **Gate Reference table** — if 3+ gates, consolidated table present
- [ ] **T1 for destructive actions** — delete, archive, close, rollback
- [ ] **Streamlined behavior specified** — not just "silent" but actual decision logic

### State (operations that write)
- [ ] **State interactions explicit** — specific fields, paths, formats
- [ ] **Two-place updates** — issue scores update both registry AND sprint-state
- [ ] **Verify after writing** — read back to confirm
- [ ] **Atomic transactions** — multi-file writes succeed together or none persist

### Quality
- [ ] **No CLAUDE.md duplication** — references protocols, doesn't restate them
- [ ] **Display templates defined** — user-facing output has exact format with next steps
- [ ] **Error recovery** — known common failure modes addressed
- [ ] **Mental simulation passed** — walked through diverse scenarios (happy path, interrupted/resumed, thin input, edge cases)
- [ ] **No over-engineering** — only needed complexity, no defensive coding patterns
- [ ] **Read-aloud test** — instructions sound like colleague guidance, not machine code
- [ ] **Template alignment** — if skill populates a template, field names and step references match
- [ ] **Cascade effects handled** — if removing/modifying entities with shared references, checks for dependents
- [ ] **Modes only if needed** — skip mode handling if always called the same way

### Maintenance Domain (maintenance operations only)
- [ ] **Scan boundary marked** — clear step where assessment ends and fixes begin
- [ ] **Initial score calculation** — outputs score before fixes
- [ ] **System-state health update** — updates [Health-Operations] after fixes
- [ ] **Agent contract compatible** — can return structured scan results
- [ ] **Mental note directives** — checkpoint support for Maintain loop
- [ ] **Report export** — optional save to Maintenance-cycles/

### Complex Operations (selective — close-sprint, organize-sprint, etc.)
- [ ] **End-of-Workflow Checklist** — multi-write verification before final report
- [ ] **Checkpoint integration** — mental notes at step boundaries
- [ ] **Resumption detection** — STEP 0 checks for partial progress

### Template Discipline (all operations) — added v2.0.0, refined v2.1.0

- [ ] **Frontmatter description is "Use when..." form** — trigger, not workflow summary (C7)
- [ ] **When to Use / Triggers section present** — required for auto-invokable skills (C8)
- [ ] **No softened gate phrasing** — no "should" / "probably" / "recommended to" inside gate instructions (C3)
- [ ] **Gate ⛔ markers reproduced in-file at write points** — not cross-referenced only (C4)
- [ ] **No placeholders** — grep for TBD/TODO/etc. returns zero hits (C5)
- [ ] **Inline constraint restatement at drift-risk steps** — supplementing consolidated Constraints block (C6)
- [ ] **Canonical placeholder form** — `{XXX}`/`{N}`/`{name}`/`{path}`/`{field}`; no mixed conventions (C10)
- [ ] **⛔ markers referenced match the F6 Canonical Marker Catalog** — no ad-hoc marker vocabulary

### Discipline Operations only (discipline-critical skills) — added v2.1.0; tiered v2.3.0 (ISS-204)

- [ ] **§Discipline Enforcement Layer present with the required set for the skill's class** — **Full Layer** (all 6 components: adversarial posture, Red Flags, Rationalizations, Anti-Patterns, Bounded Iteration Cap, FILLED/ESCALATED/SKIP) for write/close skills, OR **Verification-Class Core** (3 components: adversarial posture, FILLED/ESCALATED/SKIP at verdict gates, false-clean/false-empty Rationalization) for detect-and-propose verification skills
- [ ] **Layer Audit Checklist for the skill's tier passes** (at end of §Discipline Enforcement Layer)
- [ ] **FILLED / ESCALATED / SKIP terminal states produced at each discipline gate** — no silent passes (Full Layer); no bare "✅ clean" / "no findings" verdict (Verification-Class Core)
