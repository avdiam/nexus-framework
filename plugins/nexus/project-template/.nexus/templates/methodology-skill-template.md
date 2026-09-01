# methodology-skill-template.md
*Version: 1.2.0 | Date: 2026-08-20 | Sprint: 110*

*Guide for creating and auditing NEXUS methodology skills. Complements operation-skill-template.md (operation skills). Distilled from Analyze v2.1, Build v2.1, Validate v2.0, and Research design (Phase8-Research-Design.md).*

> **Source of standard.** The authoritative structure rubric for NEXUS skills/agents is `framework-audit-playbook.md` §9 (criterion-9 sub-rubric 9a–9e) + §10/§10.1 (SSoT taxonomy + load-isolation carve-out). This template **distills and points** — each rule below is stated usably in-place AND cross-references the playbook as the fuller authoritative source; it never re-homes the rubric (PAT-113 single-home, PAT-085 clarity-over-compression). For **frontmatter** specifically, the **placed gold templates** at `.nexus/supporting-files/templates/skills/_template-*` are the validated reference (primary-checked against Anthropic docs — ISS-206 F-T2/F-T3).

## Purpose

Methodology skills are the most complex NEXUS skills — they orchestrate multi-step intellectual work across conversations, manage companion files, and adapt behavior by issue type, complexity, and environment. This template captures the proven patterns from four redesigned methodology skills.

**Audience**: Use this template when creating a new methodology skill or redesigning an existing one. For simple operation skills (single-file workflows), use operation-skill-template.md instead.

**What makes methodology skills different from operations**:

| Dimension | Operation Skills | Methodology Skills |
|---|---|---|
| File count | 1 (SKILL.md only) | 2-8 (SKILL.md + companions) |
| Complexity adaptation | None — same flow always | C:1-2 inline Simple Path, C:3+ loads companions |
| Issue type adaptation | None — generic | Type/mode files with structural differences |
| Duration | Single conversation | May span multiple conversations |
| State management | Minimal | Progress markers, checkpoint continuity, files_to_load |
| Cognitive tools | None | Phase-specific tool recommendations |

---

## Architecture Decisions

The first design question: how many files does this methodology need?

### When to Use Companion Files

| Pattern | When | Examples |
|---|---|---|
| **No companions** (SKILL.md only) | Step sequence is always the same. No structural variation by type or complexity. | Simple methodology with uniform flow |
| **Type/mode files only** | Structural differences exist per type/mode, but no split execution needed. All shared logic fits in SKILL.md. | Validate (3 types), Research (3 modes) |
| **complex.md + type files** | Need split execution — some shared logic must run BEFORE type-specific work, other shared logic AFTER. | Analyze (§1-2 pre, §3-5 post), Build (§PRE-TYPE, §POST-TYPE) |
| **Reference files** | Large reference tables or standards that are consulted on-demand, not always needed. | Build's implementation-reference.md |
| **Conditional references** | Content loaded only for specific configurations (e.g., batch mode). | Build's batch.md |

### Decision Framework

Ask these questions in order:

1. **Do issue types/modes follow structurally different workflows?** (Not just different content within same steps — different step sequences, different execution shapes, different outputs.)
   - Yes → separate type/mode files
   - No → inline callout boxes within shared steps

2. **Does shared logic need to run both before AND after type-specific work?** (Pattern matching before implementation, quality checks after.)
   - Yes → complex.md with §PRE-TYPE / ⏸️ / §POST-TYPE
   - No → keep shared logic in SKILL.md (before or after Router)

3. **Is there reference material (tables, standards) that's only sometimes needed?** Route this through the **9b externalization test** (below), not a raw size threshold:
   - Conditional/heavy AND (over-band per 9a OR not load-bearing in the always-loaded body) → separate reference file, lazy load (Class A)
   - Small (<3KB) and not conditional → inline in SKILL.md (small-file overhead penalty: ~700 tok/KB)
   - Load-bearing catch-at-read content → keep in-body even if large (Class B); widen the band, don't extract
   - No → nothing to extract

4. **Can C:1-2 issues complete without ANY companion file loads?**
   - Must be yes. Simple Path in SKILL.md handles C:1-2 with zero loads.
   - If C:1-2 needs companion content, it's too complex for simple path — rethink.

### Load Budget

| Complexity | Target Loads | Rationale |
|---|---|---|
| C:1-2 | 0 | Full inline Simple Path. Zero external reads. |
| C:3+ | 1-2 | Type/mode file + optional complex.md or reference. Never more than 2. |
| Conditional | +1 max | Batch mode, special reference. Rare and justified. |

### Line Bands (9a) and the Externalization Test (9b)

Load Budget (above) governs *how many* companion files load — the progressive-disclosure **count**, and the R-3 zero-load anchor (C:1-2 = 0 loads, non-negotiable). **Line bands** govern *how large* a single file may grow before its **size** opens an externalization question. The two are orthogonal axes: a file can be within load budget yet over-band, or vice versa. Lines are a coarse proxy — **tokens are the true target**.

**9a — Tiered bands** (a *signal*, not an automatic verdict):

| File class | Band (lines) | Notes |
|---|---|---|
| Agent (`.claude/agents/*.md`) | ≤ 150 | |
| Operation skill `SKILL.md` | ≤ 600 | |
| Methodology skill `SKILL.md` | ≤ 800 | **+200 §DE allowance** → effective ≤ 1000 for the protected class (below) |
| Companion file (`types/`, `modes/`, `complex.md`, `batch.md`, `references/`) | ≤ 500 | > 300 → add a TOC |

Over-band → **run the 9b test**. Never an auto-fail — NEXUS framework files run larger than the Anthropic end-user ceiling by design (playbook §0 audience-class caveat).

**+200 §DE allowance**: methodology skills whose body embeds reproduced Discipline-Enforcement triplets (Red-Flag / Rationalization / Anti-Pattern blocks that must fire *at the action site* — adversarial-review and bulk-write classes, e.g. validate, close-sprint) are **protected-large**: the verbosity *is* the behavioral reinforcement (catch-at-read). Widen the band to ≤ 1000 for this class rather than extract (playbook §9.2, R-2).

**9b — The externalization test.** Fires on **either** trigger: (1) over-band per 9a, OR (2) **(R-3)** a conditional-heavy block in an always-loaded body *regardless of band* (e.g. a C:3+-only gate that loads on every invocation, including C:1-2 runs). Test, in order:
1. **Load-bearing in the always-loaded body?** Catch-at-read / anti-rationalization / ⛔-marker content → **protected (Class B)**, do not externalize; widen the band if over.
2. **Externalizable without breaking lazy-load / single-home?** Conditional or already-by-reference content → **Class A candidate** — move the home from `SKILL.md` body to `references/`/`types/`, preserving the single home (PAT-113); only load *timing* changes.
3. **Happy-path or conditional-branch?** Conditional = prime candidate; happy-path content rarely externalizes cleanly.

**The signal proposes; the gate disposes** — 9b *fires* on the trigger, but the externalize *disposition* is separately gated on block-heaviness OR over-band. A small conditional block in an in-band file = signal-noted, leave in place (avoids needless fragmentation — elegant_minimum).

**(R-3 directionality) Externalize the *heavier* path; protect the zero-load path.** A multi-path skill's always-loaded body carries asymmetric dead weight — the C:3+ reference-sections are dead weight for C:1-2 runs, and the Simple Path is dead weight for C:3+ runs. They are **not** symmetric externalization candidates:
- **C:3+ content externalizes freely** — C:3+ issues already load companion files, so a lazy `references/` load rides an existing trigger at near-zero marginal cost, and C:1-2 stops carrying it.
- **The Simple Path stays inline** — C:1-2 is the zero-load path by design; externalizing it converts the frequent fast path 0 → 1 load, and since C:3+ must load `SKILL.md` anyway (Orient / Router / Commit / Transition), the Simple Path's lines ride inside an *unavoidable* load. Its dead-weight lines are the **price of the zero-load guarantee** — and that price is correct.

Cross-ref: playbook §9a/§9b + §9.1 (over-band bifurcates by criterion 7 — the wave thesis) + §9.2 (R-2 §DE allowance) for the full sub-rubric and worked examples.

### SSoT Sub-Taxonomy (B/A)

When the same rule/table lives in ≥2 files (criterion-2 duplication), the fix depends on the class:

| Class | Definition | Token effect | Disposition |
|---|---|---|---|
| **B — pointer-fix** | Duplicated block has a canonical home already (e.g. a CLAUDE.md `[Section:]`) | Token-positive | Replace the copy with a thin `[Section: X]` pointer |
| **A — new-home** | Peer-to-peer dup across skills, no canonical home | Net-neutral-to-negative (adds a near-always reference-load) | New shared `references/` home — a **drift-elimination** play, not a token play; weigh per skill |

**Carve-out — reproduction-justified is NOT a defect.** A discipline block deliberately reproduced at each site it must fire (catch-at-read), or a sub-step reproduced across load-isolated variant files (§10.1, and Companion File Design below), is protected: keep it. Flag the duplication cost in the ledger if you wish, but do not dedupe. Cross-ref: playbook §10 (B/A taxonomy) + §9.3 (R-1 catch-at-read carve-out).

---

## SKILL.md Structure

Every methodology SKILL.md follows this section order. Sections marked (conditional) are included only when the methodology needs them.

```
SKILL.md
├── Frontmatter (---yaml---)
├── Version header
├── Title + Flow summary
│
├── Operational Reminders (always)
├── [Methodology]-specific Phase Protocols (conditional — Build, Research)
├── Type/Mode Adaptations Summary table (if types/modes exist)
├── Cognitive Tools table (always)
│
├── Orient (always, silent)
├── Simple Path [Section: Simple-Path] (always — C:1-2 inline)
├── Router [Section: Router] (always — C:3+ load sequence)
│
├── Shared operational sections:
│   ├── Batch-Transition-Detection (conditional — Build)
│   ├── Scope-Escalation-Check (conditional — Build)
│   ├── Completeness-Checks (conditional — Build)
│   ├── Sub-Agent Contracts (conditional — Research)
│   ├── Commit Protocol [Section: Commit-Protocol] (always)
│   ├── Transition [Section: Transition] (always — Analyze hosts it per-path: Simple-Path Step 6 / type-file §6 + references/readiness-gate.md; Validate terminates in Step 9 Closure instead of transitioning)
│   ├── Gate Reference [Section: Gate-Reference] (always)
│   ├── Checkpoint Reference [Section: Checkpoint-Reference] (always)
│   ├── End-of-Workflow Checklist [Section: End-of-Workflow-Checklist] (always)
│   └── Inlined reference tables (conditional)
│
├── Step Display Guidance (always)
```

### Frontmatter

```yaml
---
name: nexus-{name}
description: NEXUS {Name} methodology — {one-line purpose}. {Architecture summary}.
disable-model-invocation: true
---
```

Always `disable-model-invocation: true` — methodology skills are loaded via routing, not auto-invoked.

**Optional fields** (add when the skill needs them): `allowed-tools` (when tool-restriction matters), `user-invocable`, `paths`, `context: fork` (sub-agent dispatch), `isolation: worktree` (isolated working copy), and telemetry-first `maxTurns` (set from observed turn counts, not guessed). The `description` field *is* the auto-invoke trigger — third-person and "pushy", ≤1,024 chars alone / ≤1,536 combined with `when_to_use` (precision measurement is tool-backed — playbook §9e, deferred to ISS-207).

**Frontmatter gold reference**: do not copy the full frontmatter spec here — point to the placed gold templates at `.nexus/supporting-files/templates/skills/_template-*` (primary-validated against Anthropic docs — ISS-206 F-T2/F-T3). Companion files (`types/`, `complex.md`, `references/`) correctly carry **version headers and no frontmatter** — their absence of frontmatter is **not** a gap.

### Title + Flow Summary

First content line after frontmatter:

```markdown
*Version: X.Y.Z | Date: YYYY-MM-DD | Sprint: NNN*

# NEXUS {Name} Methodology

Executing {phase} phase for **$ARGUMENTS[0]** (complexity: **$ARGUMENTS[1]**).

**Flow**: Orient → [C:1-2: Simple Path | C:3+: Router → companion files] → Commit → Transition
```

The flow line is the 5-second orientation for the LLM. It shows the complete execution path at a glance.

### Operational Reminders

Always-active behavioral rules. Start with the standard block, add methodology-specific items:

```markdown
## Operational Reminders

**Always active while this skill executes:**

- **Memory-First**: Check active context before any read. Re-reading loaded files is a violation.
- **Verify-after-write**: Confirm changes on disk after every edit/write. Unverified writes are violations.
- **Consent**: Follow gate annotations (**[T1]**/**[T2]**/**[T3]**) per active control level. Every gate presents LLM recommendation — even T1.
- **Routing discipline**: Use appropriate skills — {list methodology-relevant skills}. Do not improvise these workflows.
- **📐 Pattern deviations**: If deviating from a pattern: `📐 PAT-XXX deviation: {what changed} — {reason}`.
```

**Methodology-specific additions** (add below the standard block when applicable):

| Methodology | Additional protocols |
|---|---|
| Build | Reference Loading Conditions table, Implementation Phase Protocols (file ops depth, atomic impl, routine decisions) |
| Research | Research Phase Protocols (ongoing source quality, bias checking, evidence attribution, heightened zone awareness) |
| Validate | None beyond standard |
| Analyze | None beyond standard |

### Type/Mode Adaptations Summary

Quick-reference table showing how each type/mode differs across key dimensions. Placed near top of SKILL.md for fast LLM orientation.

**Design rule**: Each row should answer "how does this type/mode differ from the default?" If a cell says "same as default" for most rows, that type doesn't warrant a separate file — use inline callout boxes instead.

```markdown
| Dimension | Default | Bug | Creative | Research |
|---|---|---|---|---|
| {dim 1} | {behavior} | {difference} | {difference} | {difference} |
| {dim 2} | ... | ... | ... | ... |
```

**Minimum dimensions to cover**: Investigation/work focus, output structure, plan structure, transition target, risk framing, checkpoint focus.

### Cognitive Tools Table

Map cognitive tools to methodology-specific steps. Each methodology has different tool-step affinities:

```markdown
| Tool | When During {Methodology} | Typical Step |
|---|---|---|
| {tool} | {trigger condition} | {step name} |
```

This table serves two purposes: (1) LLM auto-suggestion when complexity ≥ 3, (2) documentation of which tools are relevant at which points.

---

## Orient Section

Silent — no display to user until the methodology begins. Every methodology Orient follows this pattern:

### Mandatory Orient Steps

| Step | Purpose | All methodologies? |
|---|---|---|
| **Task-tracking (ISS-199)** | On entry, create the coarse phase-level task list per CLAUDE.md [Section: Phase-Management-Protocol] → Methodology Task-Tracking Convention; `TaskUpdate` at phase boundaries; honor opt-out. | Yes |
| **A — Load Issue Context** | Read ISS if not in memory. Extract methodology-relevant content. | Yes |
| **A.1 — Phase-Entry Briefing** | Fresh-session only: render the user-facing ISS briefing (title, type, origin, problem, SC, dependencies); skipped on same-session phase transitions for the same ISS. | Analyze, Build, Validate, Research (Maintain has no ISS) |
| **B — Readiness Check** | Verify loaded content is sufficient to proceed. Gaps → ask user. | Yes |
| **C — Check Existing Progress** | Resumption detection: progress markers, continue_with references. | Yes |
| **D — Score Gate** | Check current score. If ≥ 4 with content → offer review/skip. | Yes |
| **E — Context Artifacts** | Check project-context/ (CONCERNS.md, CONVENTIONS.md, etc.) | Conditional |
| **F — Pattern Context** | Check sprint-state [PATTERNS_IN_USE] for this issue. | If patterns apply |

### Resumption Detection Table

Every methodology needs explicit condition → action mapping for Orient C:

```markdown
| Condition | Action |
|---|---|
| continue_with references loop-back | Display reason. Offer options. |
| Progress marker found | Display summary. Resume at indicated step. |
| Complete content, no marker | Offer: review / start fresh / skip to commit. |
| Fresh start from previous phase handoff | Proceed to path decision. |
| Placeholder, no context | Fresh start. |
```

**Add methodology-specific conditions** (e.g., Build has batch resumption and apply fallback; Research has multi-conversation investigation resumption with Sprint report files).

### Path Decision

Always the last Orient step:

```markdown
| Complexity | Path | Loads |
|---|---|---|
| 1-2 | → [Section: Simple-Path] | Zero |
| 3+ | → [Section: Router] | {N} companion files |
```

If methodology has no Simple Path (like Research — always full power), document why and route directly to Router.

**Display at Orient end**: Show a brief context summary. This is the first thing the user sees.

---

## Simple Path (C:1-2)

Complete inline methodology for simple issues. Zero external file loads.

### Design Rules

1. **Self-contained in SKILL.md** — everything needed for C:1-2 is in this section
2. **Type-aware via callout boxes** — one-liner adjustments per type, not separate files
3. **Compressed but complete** — fewer sub-steps than C:3+, but same logical flow
4. **Scope Reality Check** — after first major step, verify C:1-2 assessment is still correct. If scope is broader: offer escalation to complex path.

```markdown
> **Bug:** {type-specific adjustment for this step}
> **Research:** ⚠️ Research has no Simple Path — simple research → Question type
> **Creative:** {type-specific adjustment}
```

### End of Simple Path

Always: End-of-Workflow Checklist → Commit Protocol → Transition. Same shared sections as complex path.

---

## Router (C:3+)

Loads companion files and defines execution sequence.

### Structure

```markdown
## Router (C:3+)
[Section: Router]

### Load Sequence

Read {N} files ({N} loads total — no further loads after this):
1. `${CLAUDE_SKILL_DIR}/{file1}` — {purpose}
2. `${CLAUDE_SKILL_DIR}/{file2}` — {purpose}

### Type/Mode Mapping

| Issue Type/Mode | File |
|---|---|
| {type/mode} | {path} |

### Execution Sequence

After loading, execute in this order:
1. {phase 1 — from which file}
2. {phase 2 — from which file}
...
N. Return to SKILL.md: Commit → Transition

### Zone Checks

After each major phase boundary:
- Green (< 70%): continue
- Yellow (70-80%): offer checkpoint
- Red (> 80%): MANDATORY checkpoint, then continue
```

### Split Execution Pattern (complex.md)

When shared logic must bracket type-specific work:

```
complex.md §PRE-TYPE (shared preparation)
  ⏸️ PAUSE — execute type file now
complex.md §POST-TYPE (shared quality assurance)
```

**Design rule**: The ⏸️ PAUSE anchor must appear explicitly in complex.md. It's the handoff contract between shared and type-specific logic. Both sides reference it.

**When NOT to use split execution**: If shared post-work (quality checks, pattern assessment) doesn't need type-specific implementation context, it can live in SKILL.md after the Router — no complex.md needed. Validate proved this: QA tiers, pattern finalization, quality gate, and acceptance all live in SKILL.md.

---

## Companion File Design

### Type/Mode Files

Each file contains the structurally-different workflow for one issue type or research mode.

**Required elements**:

```markdown
# {Methodology} — {Type/Mode} Name

*Version: X.Y.Z | Date: YYYY-MM-DD | Sprint: NNN*

**Flow**: {step sequence} → return to {parent file} [Section: {target}]

{Key differences from default — 2-3 bullet points}

---

## §1 {First Section Name}
...
```

**Design rules**:

1. **Flow header** — first content after title. Shows complete path including return point.
2. **Key differences** — immediately after flow. LLM reads this before the steps.
3. **Mental note directives** — end of every significant step. Handshake with checkpoint protocol.
   ```
   > **Mental note**: {Step} complete. {Key state}. If checkpoint → {what to persist and where}.
   ```
4. **Zone checks** — after token-heavy steps. Research checks after every step; Build/Validate check after phases.
5. **Loop-back checks** — conditional, triggered by signals. Always T2.
6. **Scope reality checks** — after first significant work unit. Verify scope assumptions.
7. **Return instruction** — explicit at end: "After all steps complete: return to {file} {section}."

**Self-containment rule (discriminator-loaded variants).** When the loader selects **one** variant from a family by a discriminator (issue type → `types/{default,bug,…}.md`; research mode → `modes/{…}.md`), sibling variants are **never co-loaded**. Each variant file must therefore be **self-contained** — never authored as a "same as default" / "follow {sibling}" delta over content the loader does not co-load. Such a delta cannot resolve at runtime: the directive content is silently absent — a **load-resolution defect**, distinct from duplication (it is *under*-reference, not over-reference). Inline the referenced content instead. The resulting verbatim reproduction across N variants is **not** an SSoT defect — it is reproduction justified by **load-isolation** (the variants never co-exist in context, so there is no live drift surface within a run). **Loader-verify before flagging**: a delta phrasing (`same as`, `follow X`, `as {sibling}`) is a *candidate*, not a confirmed defect — one pointing at always-loaded `SKILL.md` content resolves fine and is benign. Cross-ref: playbook §10.1 (load-isolation carve-out; sibling to the §9.3 catch-at-read carve-out under a different mechanism).

### complex.md Design

Split-execution shared logic. Two distinct phases with a pause between.

```markdown
§PRE-TYPE (runs before type file)
  Section 1: {preparation step}
  Section 2: {preparation step}

⏸️ PAUSE — Execute Type File Now
  {Orientation anchors for both directions}

§POST-TYPE (runs after type file returns)
  Section 3: {quality step}
  Section 4: {quality step}
```

**Design rules**:
1. **Orientation anchors** — at the ⏸️ PAUSE, include anchors for both the type file ("Now executing: types/{type}.md §1") and the return ("Now executing: complex.md §POST-TYPE"). These help the LLM maintain position across file boundaries.
2. **Precedence rule** — when cognitive tools or strategic approaches are loaded via their skill, the loaded version takes precedence over inline summaries in complex.md.

### Reference Files

On-demand reference material. Not workflow — lookup tables, standards, templates.

**Design rule**: Extract to a reference file when the **9b externalization test** (Architecture Decisions) passes — the content is conditional/heavy, not load-bearing catch-at-read (Class B), and externalizing preserves the single home (Class A). Size is a *signal* that feeds 9a banding, not a standalone threshold: tiny content (<3KB, not conditional) stays inline — the small-file overhead penalty (~700 tok/KB for reads <1KB) makes tiny separate files more expensive than inlining. Externalize toward the path that already pays loads (R-3 directionality); never convert the zero-load Simple Path into a load.

---

## Gate Annotations

### Format

Inline with behavior hints — placed at the start of the instruction containing the gate:

```markdown
**[T1: all levels ask]**
**[T2: Balanced+Full ask | Streamlined: notify+log]**
**[T3: Full ask | Balanced: notify | Streamlined: silent]**
```

### Tier Classification Guide

| Tier | Examples in Methodologies | Principle |
|---|---|---|
| **T1** | User choice/decision (Analyze), User acceptance (Validate), Decision on findings (Research) | The human makes the consequential judgment |
| **T2** | Plan verification (Build), Scope confirmation (Research), Quality gate (Validate), Pattern matching (Analyze) | Direction/approach decisions |
| **T3** | ISS writes, per-file gates, phase transitions, routine progress | Administrative, routine, auto-decidable |

### Smart T3 Defaults

T3 gates at Streamlined don't just say "silent" — they have actual decision logic:

```markdown
| Gate | Streamlined Default Logic |
|---|---|
| Phase transition | Silent: checklist passes → checkpoint → load next methodology |
| Survey sufficiency | Continue if ≥2 primary sources per subject |
| ISS write | Auto-write approved content |
| Plan verification | Approve if scope unchanged |
```

### Conditional Gates

Some gates only fire when signals are detected (loop-back, scope adjustment). Mark them:

```markdown
| Gate | Tier | Conditional? |
|---|---|---|
| Loop-back suggestion | T2 | **Only if triggered** |
| Scope adjustment | T2 | **Only if triggered** |
```

### Gate Reference Table

Consolidate all gates in one table in SKILL.md:

```markdown
## Gate Reference
[Section: Gate-Reference]

| Gate | Tier | Full | Balanced | Streamlined | Conditional? |
|---|---|---|---|---|---|
```

Include a note explaining any T1/T2 swaps from CLAUDE.md defaults (e.g., Validate's User Acceptance T1 / Closure T2 swap).

### Gate Count Targets

| Level | Guideline |
|---|---|
| Full Control | All gates fire — acceptable up to ~15 |
| Balanced | 3-6 stop points (T1 + T2 always gates) |
| Streamlined | 1-2 stop points (T1 only) |

If Streamlined has >2 stop points, reconsider tier classification — the methodology may be over-gated.

---

## Checkpoint Continuity

### Checkpoint Reference Table

Map every step to what gets persisted and where:

```markdown
| After | Persist | Where |
|---|---|---|
| Orient | Context loaded | continue_with only |
| {Step N} | {what to save} | {ISS section / continue_with / Sprint file} |
```

### Progress Marker Protocol

```markdown
Place as first line in [Section: Implementation-Log] or [Section: Evaluation-Results]:
`*{Methodology} in progress — {last completed milestone}*`
Orient C detects it on resumption. Commit Protocol removes it.
```

### Resumption Reload Mandate

**MANDATORY for all methodology skills**: When Orient detects a resumption (progress marker or continue_with reference), ALWAYS route through [Section: Router]. Router reloads companion files unconditionally. Companion files are not persisted across conversations — direct re-entry without reloading is a violation.

### Multi-Conversation Patterns

For methodologies that span conversations (Research Investigation, large Build implementations):

1. **files_to_load management** — add new artifacts, drop consumed ones
2. **continue_with specificity** — must be precise enough to resume immediately: "Resume Investigation, subject A complete, subject B next, survey report at Sprints/066/..."
3. **Sprint report files** — for large intermediate outputs that don't fit in ISS

---

## Transition Section

Every methodology needs a Transition section with consistent structure:

```markdown
## Transition
[Section: Transition]

**[T3 smart logic]**

### Completeness Verification
{What must be true before transitioning}

### Score Calculation
{Score 4 vs 5 criteria, methodology-specific}

### If Score < 4 — Recovery Path
Do NOT transition. Companion files still in memory. Return to {specific re-entry point}.
After addressing gaps: re-run checklist, recalculate score.

### Smart Logic per Control Level
| Level | Behavior |
|---|---|
| Full Control | Display summary, wait for approval |
| Balanced | Display summary, proceed after brief pause |
| Streamlined | Silent: checklist → score → two-place update → load next |

### Transition Summary
{Display format for Full + Balanced}

### On Decline / User Override
{What to offer if declined, how to handle override with score < 4}
```

**Design rule**: Transition is always T3 with smart logic. The consequential decision (plan approval, user acceptance, research decision) already happened at a T1 gate earlier. Transition is the administrative follow-through.

---

## End-of-Workflow Checklist

MANDATORY before transition. Two sections: core (all issues) + conditional additions.

```markdown
Core (all issues):
- [ ] ISS {section} written and verified on disk
- [ ] Progress markers removed
- [ ] Score calculated (4 or 5)
- [ ] Two-place score update: registry + sprint-state [OBJECTIVES]
- [ ] Sprint-state continue_with set with next-phase context
- [ ] Context zone checked — checkpoint if crossing boundary

Conditional:
- [ ] Patterns in use updated (if applicable)
- [ ] {methodology-specific items}
```

**Design rule**: If any item fails, fix before transitioning. The checklist is a hard gate, not a notification.

---

## Commit Protocol

Shared section that persists methodology work to ISS. Always T3.

```markdown
## Commit Protocol
[Section: Commit-Protocol]

**[T3: Full ask | Balanced: notify | Streamlined: auto-write]**

### A — Write/Update ISS
{Which ISS sections to update, methodology-specific}

### B — Update Continue-With
{Template for the next phase's handoff}

### C — Update Patterns in Use
{If patterns tracked}

### D — Clear Methodology State
{If methodology has state flags — e.g., Build's _build_mode}

### E — Verify on Disk
MANDATORY: Read back modified sections. Unverified writes are violations.
```

---

## Step Display Guidance

Map steps to presentation spirits:

```markdown
| Step | Spirit |
|---|---|
| Orient | {mood} — {guidance} |
| {Step N} | {mood} — {guidance} |
```

**Design rule**: "Spirits to channel, not scripts to repeat." The LLM varies its tone naturally — these are vibes, not templates.

---

## Post-Work Elicitation

After the main work but before transition, offer one more cognitive lens. Pattern from Build §POST-TYPE and Research Analysis:

```markdown
| Context signal | Suggest |
|---|---|
| High confidence | Blind Spot Check |
| Many changes | Systems Thinking |
| Went smoothly | Inversion — what are we not seeing? |
```

> 🔄 One more perspective before transition?
> Suggested: {tool} — {reason}
> [Apply / Proceed]

**When to include**: Methodologies where the main work involves generation or synthesis (Build, Research Analysis). Not needed for methodologies that are primarily assessment (Validate — adversarial review is built into the workflow).

---

## Audit Checklist (Methodology-Specific)

When reviewing a methodology skill, verify everything from operation-skill-template.md PLUS:

### Architecture
- [ ] **Load budget respected** — C:1-2 = 0 loads, C:3+ ≤ 2 loads (+1 conditional max)
- [ ] **Line bands checked (9a)** — file within its class band, or over-band consciously dispositioned via 9b (Class B protected-large within the +200 §DE allowance, or Class A externalization noted)
- [ ] **9b externalization test applied** — conditional-heavy content in an always-loaded body either externalized (heavier path) or signal-noted; zero-load Simple Path protected (R-3 directionality)
- [ ] **SSoT class identified (B/A)** — duplicated blocks classed pointer-fix (B) vs new-home (A); catch-at-read / load-isolation reproduction kept, not deduped
- [ ] **Variant files self-contained** — discriminator-loaded `types/`/`modes/` files carry no dangling "same as sibling" deltas (loader-verified)
- [ ] **Type/mode files justified** — structural differences, not just content differences
- [ ] **Small files inlined** — nothing < 3KB as a separate file
- [ ] **Split execution only if needed** — §PRE/§POST pattern has clear rationale

### SKILL.md Structure
- [ ] **Flow summary in title** — 5-second orientation
- [ ] **Operational Reminders present** — standard block + methodology-specific
- [ ] **Adaptations Summary table** — covers all types/modes with minimum dimensions
- [ ] **Cognitive Tools table** — maps tools to methodology steps
- [ ] **Orient follows pattern** — Load → Readiness → Progress → Score Gate → Path Decision
- [ ] **Resumption detection table** — all conditions mapped (including methodology-specific)
- [ ] **Simple Path complete** — full inline flow with type callouts and scope reality check
- [ ] **Router has load sequence + execution sequence + zone checks**
- [ ] **Commit Protocol present** — with ISS mapping and verify-on-disk
- [ ] **Transition present** — with smart T3, score<4 recovery, control level table
- [ ] **Gate Reference consolidated** — all gates in one table with conditional markers
- [ ] **Checkpoint Reference complete** — every step mapped to persist/where
- [ ] **End-of-Workflow Checklist** — core + conditional items, hard gate
- [ ] **Step Display Guidance** — spirits, not scripts

### Companion Files
- [ ] **Flow headers present** — first content line shows complete path + return point
- [ ] **Key differences stated** — immediately after flow, before steps
- [ ] **Mental note directives** — end of every significant step
- [ ] **Zone checks after token-heavy steps**
- [ ] **Loop-back checks** — conditional, with explicit signals and T2 gates
- [ ] **Scope reality checks** — after first major work unit
- [ ] **Return instruction explicit** — "return to {file} {section}"
- [ ] **Orientation anchors at ⏸️ PAUSE** — if split execution (both directions labeled)

### Gates
- [ ] **Gate annotations inline with behavior hints** — `**[T2: Balanced+Full ask | Streamlined: notify+log]**`
- [ ] **T1 gates ≤ 2** — the human makes 1-2 consequential decisions per methodology
- [ ] **Streamlined stop points ≤ 2** — if more, tiers need reconsideration
- [ ] **Conditional gates marked** — loop-back, scope adjustment clearly conditional
- [ ] **Smart T3 defaults specified** — actual decision logic, not just "silent"
- [ ] **T1/T2 swaps documented** — if overriding CLAUDE.md defaults, rationale stated

### Continuity
- [ ] **Resumption reload mandate** — Router reloads companion files on resume, no exceptions
- [ ] **Multi-conversation support** — files_to_load management, precise continue_with
- [ ] **Progress markers** — placed at step completion, removed at Commit
- [ ] **Score < 4 recovery** — explicit re-entry path without transition

### Cross-Skill Coherence
- [ ] **Handoff contracts verified** — what this skill writes matches what the receiving skill reads
- [ ] **ISS template alignment** — sections written match issue-specification.md template
- [ ] **Shared patterns consistent** — Operational Reminders, gate format, checkpoint format match other methodology skills
- [ ] **Cognitive Tools table unique** — no copy-paste from another skill; tools mapped to THIS methodology's steps
