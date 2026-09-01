---
name: nexus-analyze
description: NEXUS Analysis methodology — structured analysis for issues. Adaptive 3-load architecture (C:1-2 inline, C:3+ loads complex.md + type file).
disable-model-invocation: true
---
*Version: 4.5.0 | Date: 2026-08-20 | Sprint: 110*

# NEXUS Analysis Methodology

Executing Analysis phase for **$ARGUMENTS[0]** (complexity: **$ARGUMENTS[1]**).

**Flow**: Orient → [C:1-2: Simple Path | C:3+: Router → complex.md + type file] → Commit → Transition

---

## Operational Reminders

**Always active while this skill executes:**

- **Memory-First**: Check active context before any read. Re-reading loaded files is a violation.
- **Verify-after-write**: Confirm changes on disk after every edit/patch/write. Unverified writes are violations.
- **Consent**: Follow gate annotations (**[T1]**/**[T2]**/**[T3]**) per active control level. Every gate presents LLM recommendation — even T1.
- **Routing discipline**: Use appropriate skills — /nexus-match-pattern for pattern matching, /nexus-decompose-issue for decomposition, /nexus-close-issue for closure. Do not improvise these workflows.
- **📐 Pattern deviations**: If deviating from a pattern: `📐 PAT-XXX deviation: {what changed} — {reason}`.

---

## Type Adaptations Summary

| Dimension | Default (Feature/Improvement/Refactor/Doc) | Bug | Research | Creative | Question |
|---|---|---|---|---|---|
| Investigation focus | Gaps, dependencies, existing solutions | Reproduction + root cause | Preliminary source collection only | Audience, purpose, tone, format | Structured evidence gathering |
| Design output | Solution options + architecture | Fix options (root cause vs symptom) | Research approach (mode/depth/strategy) | Content outline + tone/style | Findings report → implementation or close |
| Plan structure | Phased implementation steps | Reproduce → fix → verify → regression | Knowledge milestones (scope → survey → investigate → analyze → deliverable → decision) | Draft → Content → Polish | Minimal steps or skip (informational-only) |
| Transition target | /nexus-build | /nexus-build | /nexus-research | /nexus-build | /nexus-validate (informational) or /nexus-build |
| Risk framing | Technical cascade, dependencies | Regression, symptom vs root cause | Scope creep, source accessibility | Audience misalignment | Inconclusive findings |

---

## Cognitive Tools for Analysis

| Tool | When During Analysis | Typical Step |
|---|---|---|
| First Principles | Novel domain, existing solutions inadequate | complex.md §1 Tools Assessment |
| Systems Thinking | Multiple interacting components | complex.md §5 Synthesis, type file Design |
| Inversion | Optimization needed, obstacles blocking | complex.md §5 Synthesis |
| Hypothesis-Driven | Multiple causes, debugging | type file §1 Investigate |
| Root Cause | Recurring problems, system failures | type file §1 Investigate (bug type) |
| Blind Spot Check | High confidence (>85%) | type file §2 Design (post-generation elicitation) |
| Mental Simulation | Before finalizing designs | type file §2 Design (strategic reflection) |

---

## Orient

Silent — no display to user until complexity assessment (Step H). Load context, detect resumption, verify readiness.

**Task-tracking (ISS-199)**: on entry, create a coarse phase-level task list per CLAUDE.md [Section: Phase-Management-Protocol] → *Methodology Task-Tracking Convention* (one entry per phase of this skill — e.g. Orient → §PRE-TYPE → Design → Commit/Transition); `TaskUpdate` at each phase boundary; honor user opt-out.

### A — Memory Check

Recite all files currently in active context. Avoid wasteful reloads.

### B — Load Issue Context

If ISS-XXX.md is not in memory, read it. Extract: type, scope, success criteria, dependencies, constraints. Update memory mantra.

### B.1 — Phase-Entry Briefing (fresh-session only)

**Fresh-session entry**: Display this briefing only on fresh-session entry. Fresh-session = this methodology was NOT invoked as a phase Transition from a different phase methodology earlier in THIS conversation for the SAME ISS-XXX. Same-session phase transitions (e.g., /nexus-validate → /nexus-loop-back → /nexus-analyze within one conversation) skip the briefing — continuity context already covers it.

**Detection**: Introspect conversation history at this step. If a prior phase methodology emitted a Transition handoff to /nexus-analyze for THIS SAME ISS-XXX earlier in this conversation, this is same-session → skip to §C. Otherwise → fire the briefing below. The Transition handoff is the methodology's phase-complete display block — examples include "✅ Phase Transition Complete / Analysis → Implementation", "📊 Implementation Phase Complete / [Transitioning to Evaluation]", "✅ Issue Closed" followed by a routing-back dispatch, or the loop-back skill's handoff display. Match the *semantic* signal (prior phase handed off to this skill for this ISS this conversation), not a single literal string. Note: Analyze is the entry methodology and rarely receives same-session transitions except via /nexus-loop-back; fresh-session is the common case.

**Render**:

> 📋 ISS-{XXX} — {title}
> Type: {type} | Created: {YYYY-MM-DD} | Complexity: {N}
>
> Origin: {Notes & Context ### Origin distilled to 1-2 sentences | "not recorded"}
>
> Problem: {first paragraph of ## Description, distilled to 1-2 sentences}
>
> Success Criteria ({total}):
> - SC-01: {criterion}
> - SC-02: {criterion}
> ...
>
> Dependencies: Blocked by {list or "none"} | Blocks {list or "none"}
>
> 📄 Full ISS: .nexus/issues/ISS-{XXX}.md

Informational only — no approval gate. Orient continues silently to §C.

### B.2 — Prior-Art Memory Scan (silent)

Query the cross-sprint memory layer for prior art before designing — "has this been solved/decided/discovered before?" (CLAUDE.md [Section: Memory-Layer]; skip silently if `.nexus/memory/` absent or files hold only the safety marker).

Hybrid query: `grep` `issues_learnings.jsonl` + `discoveries.jsonl` + `decisions.jsonl` by this issue's domain keywords / tags / related ISS IDs → LLM-scan the returned records → follow `archived_file` / `related_to` pointers only if a candidate looks directly relevant. Apply CLAUDE.md [Section: Memory-Read-Rule] when weighing records (importance + recency; `contradicts` → surface both sides; exclude `still_valid:false` / `superseded_by:set`).

If relevant prior art is found, fold it into Solution-Design (cite the record `id`); if a prior decision/discovery directly conflicts with the intended approach, surface it to the user rather than silently overriding.

### C — Readiness Check

Verify from loaded content:
- Issue type clear? (Bug / Feature / Improvement / Refactor / Documentation / Question / Research / Creative)
- Target/scope defined?
- Success criteria measurable?
- Enough context to proceed?

If gaps found: stop and ask user for clarification. Do not proceed with assumptions on scope-affecting items.

### D — Check Existing Progress

Check ISS-XXX.md [Section: Solution-Design] content (from memory if loaded).

| Condition | Action |
|---|---|
| continue_with references "Loop-back to analysis" | **Loop-back** — display reason, show existing Solution-Design. Offer: A) Revise, B) Start fresh, C) Decompose |
| Progress marker found | Display summary. Reload tools/patterns/SA from continue_with. Resume at indicated step. |
| Complete content, no marker | Offer: A) Review and revise, B) Start fresh, C) Proceed to transition (if score ≥ 4) |
| Placeholder only, continue_with has context | Resume from indicated step |
| Placeholder only, no context | Fresh start → proceed to E |

### E — Sprint Queue Status

If sprint-queue.md has Active Sprint as "READY", update to "ACTIVE".

### F — Score Gate

Check analyzed score from issues-registry.yaml (`ISS-XXX.analyzed:`).

| Score | Action |
|---|---|
| ≥ 4, ISS has content | Offer: A) Review existing, B) Re-analyze, C) Skip to Commit |
| ≥ 4, ISS empty | Warn data inconsistency. Recommend re-analyzing. |
| < 4 | Proceed to G |

### G — Issue Understanding

**Documentation verification**: Confirm understanding — type, scope, criteria, dependencies, constraints. Brief confirmation or flag gaps.

**Clarification triage**:

| Gap Type | Action |
|---|---|
| Routine (clear precedent, low risk) | Default, note: "Defaulting to {X} — flag if wrong" |
| High-impact (affects scope/architecture/criteria) | Ask user |

C:1-2: default liberally, ask only scope-affecting. C:3+: ask anything affecting approach or criteria.

### H — Complexity Assessment

Score 1–5 across five dimensions:

| Dimension | Low (→1) | High (→5) |
|---|---|---|
| Scope | Single file, isolated | 4+ files, system-wide |
| Dependencies | None, standalone | Multiple blocking/cascading |
| Novelty | Known patterns, routine | Novel domain, no precedent |
| Risk | Easy rollback, low impact | Hard to reverse, high stakes |
| Integration | Self-contained | Cross-component coordination |

Consider all dimensions, use judgment, assign 1–5. Can adjust ±1 based on context.

Display: "Complexity: {X}/5 ({brief reasoning})"

### I — Path Decision

| Complexity | Path | Loads |
|---|---|---|
| 1–2 | → [Section: Simple-Path] | Zero (stay in this file) |
| 3+ | → [Section: Router] | Two (complex.md + type file) |

---

## Simple Path (Complexity 1–2)
[Section: Simple-Path]

Complete inline analysis for simple issues. Zero external file loads. Type-aware guidance via one-liner adjustments per step.

### Step 1: Research & Discovery

Investigate the current situation.

**A — Context artifacts** (conditional): Check if `.nexus/supporting-files/project-context/` exists. If found, read CONTEXT.md/STRUCTURE.md/CONCERNS.md for relevant context. Flag any known concerns that intersect this issue's scope.

**B — Archaeological discovery** (MANDATORY): Search existing before creating new. 80–95% of "new" features already exist dormant. Use Grep/Glob to find similar features, dormant solutions, adaptable implementations. Evaluate adapting existing vs building new.

✗ **Don't**: Jump to designing a new solution without searching what exists.
✓ **Do**: "Let me check what's already in the codebase..." → find 70% of the solution already built.

**C — File state verification** (MANDATORY): Verify actual file states — don't trust only the issue description. Confirm described changes don't already exist, validate current names/signatures.

**D — Gap identification**: Compare current state vs required state. Identify gaps, blockers, dependencies.

**E — Cross-cutting checklist** (conditional): Run [Section: Cross-Cutting-Checklist] in references/scope-investigation.md. Trigger and suppression are checked there — it fires only for cross-cutting-concept retire/rename/add work (a named concept recurring across file-classes) and adds 4 non-skill file-classes to the Files Affected enumeration. No-op (one-line N/A) for simple single-file additive work.

**Type adjustments** (apply the matching guidance):
- **Bug**: Prioritize reproduction steps + root cause. Trace the causal chain if reproducible.
- **Question**: Structured investigation — gather evidence to answer the question. May produce findings, not options.
- **Research**: ⚠️ Restricted scope — preliminary source collection only. Do NOT conduct substantive investigation here. Identify research subjects, define research questions, map available sources, and confirm research mode:
  - **Adoption**: Evaluate whether to adopt something specific. Criteria-based → Adopt/Adapt/Defer/Skip. May spawn new Feature/Improvement issues.
  - **Comparative**: Compare multiple options across dimensions. Produces comparison matrix → informational report.
  - **Exploratory**: Open investigation into a domain/topic. Question-driven → knowledge report.
  Output must feed /nexus-research entry: mode, subjects, questions, source strategy, estimated depth.

  **SC framing surfacing — audit-shape Research deferred-SC path**: When the active ISS is Research type AND its Success Criteria are placeholder (deferred-to-Analysis state from create-issue STEP 3.5 "Defer to analysis" path or from C:1-2 audit-shape Research that bypassed STEP 3.5) AND the issue's title/description/draft-SC exhibit audit-shape signals (deliverable-class title pattern like "audit/inventory/classification/registry sweep/appendix/report" OR audit/inventory/classify/enumerate verbs in description OR visibility-phrasing like "appendix", "flagged but not classified", "visibility", "no findings" in any drafted SC), surface the SCAN-then-classify default explicitly during SC drafting:

  > 📝 SC framing — visibility-class default
  > This is an audit-shape Research issue with placeholder SC. For any SC element that
  > describes visibility-class outputs (appendices, flagged-but-not-classified lists,
  > out-of-scope contamination collections), the correct default is **SCAN exhaustively
  > first, THEN classify findings** — not "empty = no findings". Empty visibility-class
  > outputs require explicit "scan completed, no qualifying findings" evidence.
  > Precedent: Sprint 084 ISS-184 P2.6 R2-H1 (false-empty SC-08 appendix caught by
  > adversarial review). Apply SCAN-then-classify framing to relevant SC during drafting.

  Surfacing is informational — no approval gate, no AskUserQuestion. Trigger conditions read the canonical `audit_shape_signal` helper defined at `/nexus-create-issue` STEP 3.5 header (single source of truth — do not re-state the disjunct list here, follow the canonical definition to avoid drift). The single-source pointer keeps both skills aligned and avoids noise on non-audit-shape Research issues.
- **Creative**: Focus on audience, purpose, tone, format constraints, reference material.
- **Default** (Feature/Improvement/Refactor/Doc): Standard flow.

> 📊 Gap Analysis
> Current state: {what exists}
> Required state: {what we need}
> Gaps: {list}
> Dependencies: {any blockers}

### Step 2: Design & Options

Generate 2–3 solution options with recommendation.

> **Option A**: {approach}
> Files affected: {list}. Pros: {benefits}. Cons: {drawbacks}.
>
> **Option B**: {approach}
> Files affected: {list}. Pros: {benefits}. Cons: {drawbacks}.
>
> **My recommendation: Option {X}**
> **Reasoning**: {strategic rationale — not just restating the option}

**Type adjustments:**
- **Bug**: Often single recommended fix vs alternatives. Focus on root cause vs symptom fix.
- **Question**: May produce findings report instead of options. Format as "Findings." If informational-only (no implementation): skip Steps 3–4, go to [Section: Commit-Protocol] with Question-Resolved note, then transition to /nexus-validate.
- **Research**: Present research approach: mode (Adoption/Comparative/Exploratory), research questions, subjects, evaluation criteria or comparison dimensions, source strategy (primary/secondary), estimated depth in conversations. This is the Research Design that /nexus-research will execute.
- **Creative**: Content outline over architecture. Options = tone/style, format, structure.
- **Documentation**: Skip architecture. Options focus on structure/organization.
- **Refactor**: Include quality dimensions (maintainability, readability, performance).

### Step 3: Choice Selection

**[T1: all levels ask]** Present options with LLM recommendation. Wait for explicit user selection. Never proceed without user choice.

On selection: "✓ Selected: Option {X}". Proceed to Step 4.

**Scope-propagation** — If the selected option changes the scope (different methodology target, added/removed files, expanded/narrowed issue boundary), update ALL anchored-text locations atomically before writing Solution-Design:
- ISS title (`##` header in the ISS file)
- `## Description` (body)
- Every SC line (all checkboxes)
- Registry `ISS-XXX.description` and `ISS-XXX.scope_files` (if file scope changed)
- `## Dependencies` → the `**Related**:` line (including inline HTML comments — a stale cross-reference here is invisible to rendering but still misleads the next reader; issue-specification.md defines Related as a bold field line, not a `###` subsection)
- `### Risks & Mitigations` (if present — a risk framed against the old scope misleads Build/Validate on what to watch for)

**Closing predicate** (mandatory, run after the six locations above are updated): grep the ISS file and the registry for the old framing's distinctive tokens. Every surviving hit must be either updated to the new scope or explicitly marked a historical-record note (e.g. an HTML comment documenting the supersession, as at ISS-230's `### Related`). Enumeration of the six locations is necessary but not sufficient — the predicate is what catches a location this list itself omitted (ISS-230 Conv 3: the omission of `### Related` and `### Risks & Mitigations` from an earlier version of this very list is what reproduced the failure a fourth time).

Do not defer to Build or Evaluate. Scope-expansion is incomplete until all anchored-text locations reflect the new scope AND the closing predicate returns clean (updated or historical-note only).

### Step 4: Planning

Flat numbered step list. Include files, verification criteria, effort estimate.

> 📋 Implementation Steps
> 1. {step} — verify: {criteria}
> 2. {step} — verify: {criteria}
> ...
> Estimated effort: {estimate}

**Type adjustments:**
- **Research**: Research Plan with knowledge milestones (Scoping → Survey → Deep Investigation → Analysis → Deliverable → Decision), estimated conversations per phase, deliverable target. This is what /nexus-research reads from ISS Implementation-Plan on entry.
- **Creative**: Phases = Draft → Content → Polish.
- **Question** (if implementation needed): Minimal steps for the specific change.

### Step 5: Plan Approval

**[T1: all levels ask]** Present complete plan with LLM recommendation.

> Plan ready:
> - Approach: {from Step 3}
> - Steps: {count} | Files: {count}
> - Risk: {Low/Medium/High}
>
> Approve? [Y/n/adjust]

On approval: → [Section: Commit-Protocol]. On decline: revise per feedback. On adjust: modify specifics.

### Step 6: Transition

**[T3: Full ask | Balanced: notify action taken | Streamlined: silent]**

Run [Section: End-of-Workflow-Checklist]. Calculate score (4 = well analyzed, 5 = comprehensive). Execute:

1. Two-place score update per [Section: Two-Place-Update-Protocol]
2. Update sprint-state current_focus to next phase
3. Context-aware loading:
   - < 70%: checkpoint, load next methodology
   - 70–80%: checkpoint, load if context still viable
   - > 80%: final checkpoint, mark transition in continue_with for next conversation

**Type-specific transitions:**

| Type | Next methodology | Rationale |
|---|---|---|
| Research | /nexus-research | Full research phase needed |
| Question (informational-only) | /nexus-validate | Evaluate research quality, no implementation |
| All others | /nexus-build | Standard implementation |

> ✅ Phase Transition Complete
> Analysis → {next phase}
> • Score: {X}/5 (updated in 2 places)
> • Next: {methodology loaded or deferred}

**On decline**: Ask what needs attention. Offer: revisit decisions, additional research, change approach. User can say "go back" to return to earlier steps.

**User override**: If user says "implement now" with score < 4, warn about gaps but proceed if insisted.

[/Section: Simple-Path]

---

## Router (Complexity 3+)
[Section: Router]

Orient determined complexity ≥ 3. Load the thinking toolkit and type-specific workflow together.

### Load Sequence

Read both files (2 loads total — no further loads after this):

1. `${CLAUDE_SKILL_DIR}/complex.md` — thinking toolkit (tools, preferences, patterns, strategy, synthesis)
2. `${CLAUDE_SKILL_DIR}/types/{type}.md` — type-specific workflow (investigate, design, plan, transition)

**Type mapping:**

| Issue Type | File |
|---|---|
| Feature, Improvement, Refactor, Documentation | types/default.md |
| Bug | types/bug.md |
| Research | types/research.md |
| Creative | types/creative.md |
| Question | types/question.md |

### Execution Sequence

After loading both files, execute in this order:

**Phase 1 — Pre-investigation preparation** (complex.md §1-2):
Tools Assessment → Preferences

**Phase 2 — Type-specific investigation** ({type}.md § Investigate):
Investigate section only — uses preferences to constrain direction

**Phase 3 — Informed selection** (complex.md §3-5):
Pattern Discovery → Strategic Approach → Contextual Synthesis
*(Now informed by investigation findings — patterns match better with research context)*

**Phase 4 — Type-specific design through approval** ({type}.md §2-5):
Design → **[T1] Choice** → Plan + Feasibility → **[T1] Plan Approval**

**Phase 5 — Persist and transition** (return to this file):
[Section: Commit-Protocol] → Transition (per type file instructions)

### Zone Checks

After each major phase boundary (complex.md done, after Choice, after Plan approval): apply the Green/Yellow/Red zone actions per CLAUDE.md [Section: Memory-Context-Management] → Context Zones.

[/Section: Router]

---

## Commit Protocol
[Section: Commit-Protocol]

Shared by Simple Path and Complex Path. Persists analysis to ISS file.

**[T3: Full ask | Balanced: notify | Streamlined: auto-write]**

### A — Write Solution-Design

Edit ISS-XXX.md [Section: Solution-Design]:

| Analysis Output | ISS Subsection |
|---|---|
| Strategy and rationale | ### Approach |
| Component structure (C:3+ only) | ### Architecture |
| Tools, SA, patterns chosen (C:3+ only) | ### Tools & Patterns |
| Non-obvious choices with rationale | ### Key Decisions |
| Risks with mitigation | ### Risks & Mitigations |
| Files and changes | ### Files Affected |

C:1-2: Approach + Files Affected minimum. C:3+: all subsections.

**Research-type ISS**: the file is scaffolded from issue-specification.md [Section: Research-ISS-File-Structure], whose Research Design subsections differ from the table above — map instead: mode + rationale + core research questions → ### Approach · subjects, in/out boundaries, depth → ### Subjects & Scope · evaluation criteria / comparison dimensions / depth boundaries → ### Evaluation Criteria · source strategy → ### Source Strategy · scoping decisions → ### Key Decisions · research risks → ### Risks & Mitigations (no ### Architecture / ### Files Affected). The Research Plan goes to [Section: Implementation-Plan] as usual; tools/SA/patterns → ### Tools & Patterns.

### B — Write Implementation-Plan

Edit ISS-XXX.md [Section: Implementation-Plan].
C:1-2: flat step table with Status column. C:3+: phased tables with objectives, verification, rationale.

### C — Coverage Check (C:3+ only)

Verify bidirectional linkage: Success Criteria ↔ Implementation-Plan.
- Forward: every criterion → at least one step
- Reverse: every step → at least one criterion
- Steps without criterion = possible gold-plating. Criteria without step = will fail at evaluation.

### D — Update Patterns in Use

If patterns accepted: edit sprint-state.md [PATTERNS_IN_USE] under ISS-XXX block.

### E — Update Continue-With and Derive files_to_load

**E.1 — Build the continue_with text** for the next phase. Format depends on issue type:

**Research-type:**
```
WHAT: Begin research for ISS-XXX — {mode} mode
WHY: Analysis complete — research design ready
PLAN: ISS-XXX.md [Section: Implementation-Plan]
FIRST: Confirm scope and begin survey
```

**Question-type (informational path):**
```
WHAT: Validate findings for ISS-XXX
WHY: Question answered — quality review pending
PLAN: ISS-XXX.md [Section: Solution-Design] (Findings Report)
FIRST: Load /nexus-validate
```

**All other types:**
```
WHAT: Implement {approach} for ISS-XXX
WHY: Analysis complete — {key insight}
PLAN: ISS-XXX.md [Section: Implementation-Plan]
FIRST: {first implementation step from locked plan}
```

**E.2 — Derive files_to_load** (phase-aware) from the locked Implementation-Plan or Research Plan:

The next conversation needs to start fast. `files_to_load` should reflect what the next phase will *actually read or write at its first steps*, not the full discovery candidate set. This derivation runs **after** Plan Approval, with the locked plan in memory.

Procedure:

1. Identify the **first phase** of the next methodology:
   - A→I (default/bug/creative/question-standard): Implementation-Plan → Phase 1
   - A→R (research): Research Plan → Phase 1 (Scoping)
   - A→V (question-informational): Validation has no phases per se; load the ISS file only

2. Scan the first phase's steps. List the files those steps explicitly read or write.

3. Pick the **3–5 most central** files from that list (the ones that drive the phase's deliverable). Always include the active ISS file.

   Section-scoped entries: if a single bounded section of a file reliably covers the phase's first reads, emit `path [Section: Name]` rather than the bare path. Default to bare path when any doubt — backwards-compat is the anchor. Format per CLAUDE.md [Section: Checkpoint-Protocol] BOOTSTRAP format.

4. Write the chosen list to `sprint-state.md [BOOTSTRAP] files_to_load`. Keep the list under 5 entries — fewer is better.

This is not the full canonical scope. Canonical scope lives in `ISS-XXX.scope_files` (registry) and ISS `### Files Affected` — both populated upstream by [Section: Scope-Discovery] (in references/scope-investigation.md) when applicable. `files_to_load` is **phase-aware preload state**, derived fresh per transition.

If the phase changes mid-implementation (e.g., Phase 2 starts in a fresh conversation), the next checkpoint will re-derive `files_to_load` from the new active phase.

**E.3 — Remove progress markers** from ISS sections (analysis is finalized).

### F — Verify on Disk

MANDATORY: Read back modified ISS sections from disk. Confirm content correct and complete. Unverified writes are violations.

[/Section: Commit-Protocol]

---

## Gate Reference
[Section: Gate-Reference]

All gates present LLM recommendation regardless of tier or control level.

| Gate | Tier | Full | Balanced | Streamlined |
|---|---|---|---|---|
| Choice selection | **T1** | Ask + rec | Ask + rec | Ask + rec |
| Plan approval | **T1** | Ask + rec | Ask + rec | Ask + rec |
| Pattern discovery | T2 | Ask + rec | Ask + rec | Auto-invoke /nexus-match-pattern if C>2 or novel, notify |
| SA selection | T2 | Ask + rec | Ask + rec | Auto-select by type/complexity/novelty, notify |
| Design sub-decisions | T2 | Ask + rec | Ask + rec | Auto-select best-fit, notify |
| Preferences input | T3 | Ask | Notify | Check for standards/preference files, apply silently |
| ISS documentation write | T3 | Ask | Notify | Auto-write approved content |
| Phase transition | T3 | Ask (audit) | Notify action taken | Silent: checklist → checkpoint → load/defer |

**SA auto-selection guidance** (Streamlined T2 default):

| Signal | → Strategic Approach |
|---|---|
| Bug type | Risk-Forward (SA-005) or Proof-of-Concept (SA-003) |
| Refactor type | Tech Debt Paydown (SA-006) |
| Creative type | Divergent-Convergent (SA-007) |
| High novelty | First Principles via /nexus-mental-models |
| Multi-component | Analytical Decomposition (SA-001) |
| Optimization | Iterative Refinement (SA-002) |
| New system | Foundation-First (SA-004) |
| Over-constrained | Constraint Relaxation (SA-008) |
| Quality-critical code | Test-Driven Development (SA-009) |

**Research-type note**: For Research issues, SA guides the research methodology, not implementation. E.g., Proof-of-Concept means "include hands-on evaluation in research scope," not "build a PoC now." Analytical Decomposition means "break research into independent questions," not "decompose into sub-components."

[/Section: Gate-Reference]

---

## Checkpoint Reference
[Section: Checkpoint-Reference]

When [Section: Checkpoint-Protocol] fires during analysis, persist based on progress:

| After | Persist | Where |
|---|---|---|
| Orient (A–I) | Issue context, type, complexity | continue_with only |
| Complex: Tools + Preferences | Tools loaded, preferences captured | C:3+: preferences to ISS Solution-Design |
| Complex: Patterns + SA + Synthesis | Decisions, key insights | continue_with captures decisions |
| Investigate/Research | Findings, gaps | C:3+: ISS with marker "*Analysis in progress — research complete*" |
| Design (mid-topic) | Resolved topics only | ISS Solution-Design with marker "*Topics 1–N decided, M pending*" |
| Design (complete) | All options, adaptation | ISS with marker "*Design presented, awaiting choice*" |
| Choice confirmed | Approach locked | ISS Solution-Design (approach section) |
| Plan approved | Full plan | ISS Solution-Design + Implementation-Plan |
| Commit done | Already on disk | Verify only |
| Transition done | Scores updated | Verify only |

**Progress marker protocol**: Place as first line in [Section: Solution-Design]: `*Analysis in progress — {milestone}*`. Commit removes it. Orient D detects it on resumption.

**Resumption reload mandate** (MANDATORY): When Orient detects a resumption mid-complex-path (progress marker found, or continue_with references a complex.md or type file step), ALWAYS route through [Section: Router]. Router reloads both complex.md + type file unconditionally. Do NOT attempt to re-enter companion files directly without reloading — they are not persisted across conversations.

[/Section: Checkpoint-Reference]

---

## End-of-Workflow Checklist
[Section: End-of-Workflow-Checklist]

MANDATORY before phase transition. Two groups, distinguished by **when each item is true**: *Verifications* are state that must hold by the time the transition executes (and, on C:3+, by the time the Readiness Gate computes its verdict); *Transition actions* are performed afterwards, by the §6 Transition steps.

The distinction is load-bearing, not cosmetic — the C:3+ Readiness Gate computes its verdict from the **Verifications group only**. Asserting a Transition action as a completed verification would have the gate check work that has not happened yet.

### Verifications (must hold before the gate / transition executes)

- [ ] ISS Solution-Design written and verified on disk
- [ ] If scope changed at Choice: all six anchored-text locations updated (ISS title, ## Description, SC texts, registry description + scope_files, ## Dependencies `**Related**:` line, ### Risks & Mitigations) AND the closing predicate grep run with evidence recorded (Step 3 Scope-propagation)
- [ ] ISS Implementation-Plan written and verified on disk
- [ ] Analysis score calculated (4 or 5) — computed alongside this checklist; complete before Step 0
- [ ] Sprint-state continue_with set with next-phase context — written at [Section: Commit-Protocol] §E.1, which runs before §6
- [ ] Patterns in use updated (if applicable) — [Section: Commit-Protocol] §D
- [ ] Context zone checked
- [ ] [Section: Cross-Cutting-Checklist] resolved either way — **if triggered**: per-class grep evidence recorded in ISS `### Files Affected` (literal command + hit count per class, including zero-hit classes); **if suppressed**: the one-line `Cross-cutting checklist: N/A — {reason}` record that section's Trigger Condition requires. One of the two must exist. Absent evidence means the checklist was not run — an eyeballed file-class classification does not satisfy this item, and a silently-unconsidered checklist does not qualify as suppressed.

### Transition actions (performed after this checklist, by §6)

- [ ] Two-place score update: registry + sprint-state [OBJECTIVES] — §6 step 1, **after** the gate's verdict
- [ ] Checkpoint if a context-zone boundary is crossed — §6 step 3

**Per-path mapping**:

| Path | Behavior |
|---|---|
| C:3+ (type file §6) | Verifications are checked, then Step 0 invokes the Readiness Gate on that group. On PASS, §6 steps 1–3 execute the Transition actions. |
| C:1-2 ([Section: Simple-Path] Step 6) | No gate on this path. Verifications are checked, then Step 6 executes the Transition actions directly. |

If any **Verifications** item fails: fix before transitioning. Do not proceed with an incomplete Verifications group.

[/Section: End-of-Workflow-Checklist]

---

## Investigation References (lazy-loaded)
[Section: Investigation-References]

The §1 Investigate conditional sub-flows — **Scope-Discovery**, **Scanner-Offer**, **Cross-Cutting-Checklist** — are externalized to `references/scope-investigation.md` (ISS-209, Class-A). They are invoked by reference from [Section: Simple-Path] Step 1.E and the `default`/`bug`/`question` type files' §1 Investigate. Load the reference only when a trigger fires — the Simple Path's mandatory baseline loads nothing.

| Trigger | Load from references/scope-investigation.md |
|---|---|
| Registry `scope_files` + ISS `### Files Affected` both empty/broad (code project) | [Section: Scope-Discovery] |
| Candidate list thin (<3) / safety-valve (>50) / low-confidence after discovery (C≥3) | [Section: Scanner-Offer] |
| Issue retires/renames/adds a cross-cutting concept (named token across file-classes) | [Section: Cross-Cutting-Checklist] |

[/Section: Investigation-References]

---

## Readiness Gate (lazy-loaded)
[Section: Readiness-Gate-Pointer]

The **Readiness Gate** — the deterministic PASS/CONCERNS/FAIL verdict run at every **C:3+** analysis-phase transition (A→I, A→R, A→V) — is externalized to `references/readiness-gate.md` (ISS-209, Class-A). It is invoked by reference from each type file's §6 Transition (`default`/`bug`/`creative`/`question`/`research`) with a branch parameter. The C:1-2 Simple Path transition does not invoke it.

Load `references/readiness-gate.md` [Section: Readiness-Gate] when executing a C:3+ §6 Transition.

[/Section: Readiness-Gate-Pointer]

---

## Step Display Guidance

Vary presentation naturally. Spirits to channel and styles to render in — not scripts to repeat. Spirit captures the *attitude* you bring; Style captures the *form* and *cadence* of the output.

| Phase | Spirit | Style |
|---|---|---|
| Orient | Curiosity — confirm understanding | Silent until findings are complete; reveal observations only at Step H, no progress narration |
| Research/Investigate | Investigation — digging in | Concrete findings with file references; group related discoveries; surface friction and gaps explicitly |
| Design | Collaboration — presenting choices | Present options + recommendation; show trade-offs in tables; lead with strategic reasoning, not labels |
| Choice | Invitation — seeking decision | Stop and wait after presenting; never proceed without explicit user pick; restate selection on confirmation |
| Planning | Structure — mapping the path | Phased structure with verification per step; concrete file paths; bidirectional coverage check |
| Commit | Craftsmanship — documenting with care | Patch with care, verify on disk after every write; show what changed and where; never silent writes |
| Transition | Accomplishment — proposing next phase | Brief summary, two-place score update, hand off cleanly; render the readiness gate verdict explicitly |
