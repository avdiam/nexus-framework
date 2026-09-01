---
name: nexus-validate
description: Use when validating implementation quality before issue closure (per-issue scope) or sprint cohesion before sprint close (per-sprint scope). 4-file architecture (C:1-2 inline, C:3+ loads type file).
disable-model-invocation: true
---
*Version: 3.7.0 | Date: 2026-08-26 | Sprint: 111*

# NEXUS Validate Methodology

Executing Evaluation phase for **$ARGUMENTS[0]** (complexity: **$ARGUMENTS[1]**).

**Flow**: Orient → QA Verification → [C:1-2: Simple Path | C:3+: Router → type file] → Pattern Finalization → Quality Gate → User Acceptance → Documentation & Learning → Closure

---

## Purpose

Validate runs the Evaluation phase of the issue lifecycle: structured, adversarial-by-default quality review against Success Criteria + Implementation evidence, terminating in a closure-ready verdict (per-issue scope) or a sprint-set cohesion verdict (per-sprint scope). It is the load-bearing independent review pass between Build/Implementation completion and Closure — never a self-review of work the same conversation produced, and never substitutable by Build's own self-eval.

Two scopes share the same §Discipline Enforcement Layer, type-adaptation table, and gate vocabulary; they differ only in *what is being validated against what evidence*. Per-issue (`/nexus-validate ISS-XXX`) checks one ISS against its criteria; per-sprint (`/nexus-validate SPRINT-NNN`) checks the closed-issue set against cross-cutting concerns no per-issue Validate could see (theme self-prove, version stack consistency, constitution-as-aggregate, cross-skill drift).

---

## When to Use

**Trigger when**:
- An issue's Build phase has completed (Implementation score I:5) and quality must be evaluated against its Success Criteria before closure — `/nexus-validate ISS-XXX`
- A sprint is being closed and cross-cutting concerns must be validated across the closed-issue set before destructive closure operations — `/nexus-validate SPRINT-NNN` (also auto-invoked by `/nexus-close-sprint` STEP 0 when trigger signals fire)
- User says "validate", "evaluate", "QA", "quality check", or "review" against an issue or sprint
- Phase transition fires Implementation → Evaluation per CLAUDE.md [Section: Phase-Management-Protocol] (Analysis dispatches the methodology after Build completes)
- A Question-type issue (informational path) completes Analysis with Findings recorded in Solution-Design — A→V transition; Validate evaluates research quality with no Implementation-Plan

**Do NOT trigger when**:
- Issue evaluation is already complete (E:5) and only the closure write-out (resolution decision, ISS [Section: Closure] write, knowledge extraction, registry archival) remains — use `/nexus-close-issue` instead
- Closed issues need to be relocated from `.nexus/issues/` to `.nexus/archived/issues/` with no quality work — use `/nexus-archive-issue` instead
- Sprint planning, queue ordering, or wave assignment is needed — use `/nexus-organize-sprint` instead (planning, not validation)
- Closing the entire sprint with all per-issue Validates already passed — use `/nexus-close-sprint` (which itself invokes sprint-level Validate at STEP 0 when signals fire; do not call sprint Validate from outside the closure flow when closure itself is the next step)

---

## Operational Reminders

**Always active while this skill executes:**

- **Memory-First**: Check active context before any read. Re-reading loaded files is a violation.
- **Verify-after-write**: Confirm changes on disk after every edit/patch/write. Unverified writes are violations.
- **Consent**: Follow gate annotations (**[T1]**/**[T2]**/**[T3]**) per active control level. Every gate presents LLM recommendation — even T1.
- **Routing discipline**: Use appropriate skills — /nexus-loop-back for phase rollback, /nexus-close-issue for closure, /nexus-match-pattern for pattern matching. Do not improvise these workflows.
- **📐 Pattern deviations**: If deviating from a pattern: `📐 PAT-XXX deviation: {what changed} — {reason}`.
- **Vocab consistency**: When adding new severity labels, status values, or verdict terminology to any skill, first scan the full file for existing vocabulary (grep for related terms). Prevent drift: if the file uses "PASS/FAIL", don't introduce "PASSED/FAILED" elsewhere. If the file uses "CONCERNS", don't introduce "WARNING" for the same concept.

### Scope (issue/sprint)

/nexus-validate operates in two scopes. Both share §DE Layer §1-§8, type adaptations, and the gate vocabulary; they differ in *what is being validated against what evidence*.

**Per-issue scope (default)** — validates ONE ISS-XXX against ITS Success Criteria. Evidence: single ISS file (Solution-Design / Implementation-Plan / Implementation-Log) + that issue's tests + sprint-state pattern outcomes for that issue. Subject = single issue. Question = "did THIS issue meet ITS criteria?" Triggered by `ISS-XXX` first argument.

**Sprint scope** — validates the SET of closed issues within a sprint against cross-cutting concerns that no per-issue Validate could see. Evidence: sprint-state (`_mode`, `_title`, [OBJECTIVES], [FILES_MODIFIED], [PATTERNS_IN_USE]) + issues-registry (scope_files, blocks/blocked_by) + each closed ISS file in the sprint + changelog-registry (version stack) + project-state.md `[PROJECT_CONSTITUTION]`. Subject = the issue set. Question = "do these closed issues *as a set* not drift, contradict, or leave gaps that none of them owned individually?" Triggered by `SPRINT-NNN` first argument.

**Per-issue scope cannot see**: cross-issue drift between skills/files modified by ≥2 issues, theme self-prove (does the chain prove the THEMED sprint title?), version stack consistency across the sprint's modified files, constitution-as-aggregate (Elegant Minimum / Protocol Discipline / Continuity *across all issues collectively*).

**Sprint scope does not replace per-issue Validates**. Per-issue Validate runs after every Build and is load-bearing for closure. Sprint-level Validate runs once at `/nexus-close-sprint` STEP 0 (before destructive closure operations). The two are complementary; neither substitutes for the other.

Routing: SKILL.md Step 1 §E.0 (below) branches on argument prefix. ISS- → existing default/creative/research types. SPRINT- → `types/sprint-level.md`. Default-safe: existing ISS-XXX dispatch is unchanged.

---

## Type Adaptations Summary

| Dimension | Default (Feature/Improvement/Refactor/Doc/Question/Bug) | Creative | Research |
|---|---|---|---|
| Criteria approach | Forward mapping + reverse traceability (C:3+) | Graduated dimensions (audience/message/tone) | 4 research dimensions (source/coverage/objectivity/actionability) |
| Quality dimensions | 4: Functional, Integration, Standards, Holistic | 5: Audience-fit, Message clarity, Tone consistency, Structural flow, Polish | 4: Source Quality, Coverage Depth, Objectivity, Actionability |
| Plan vs actual | Scope, approach, sequence, risks | Brief vs deliverable, sections completed | Process review, questions vs answered |
| Debt framing | Technical debt, TODOs, compromises | Refinement opportunities | Deferred questions, incomplete investigation |
| Adversarial focus (C:3+) | Solution Design intent, integration, edge cases | Audience compelled? Tone drift? Purpose served? | Confirmation bias? Opposing viewpoints? Evidence? |
| QA Verification | Standard test audit + tier execution | Brief compliance check (no automated tests) | Source verification + coverage confirmation (no traditional tests) |

**Inline callout types** (use types/default.md): See **Documentation:** and **Question (informational-only):** callout boxes in types/default.md for step-level adjustments.

---

## Discipline Enforcement Layer

/nexus-validate implements the Discipline Enforcement Layer per operation-skill-template v2.1.0 and PAT-102. Applies to all complexity levels, all validation workflows. The layer's eight components reinforce each other — do not adopt a subset.

### 1. Default Adversarial Posture

Validate runs adversarial by default at every complexity.

Starting assumption: the work being validated has a problem. The validator's job is to find what's wrong, not to confirm what's right. If nothing is found after a genuine adversarial read, the work passes — but passing must be the *outcome* of the adversarial read, not its starting position.

**Complexity scales depth, not stance:**

| Complexity | Adversarial depth |
|---|---|
| C:1 | Single-pass adversarial read of the work against success criteria. ~5 minutes of scrutiny. |
| C:2 | Adversarial read + targeted edge-case inventory (what happens at boundaries?). ~15 minutes. |
| C:3 | Adversarial review + mental simulation (fresh-instance walk-through). Cognitive Tools loaded per complex.md. |
| C:4 | C:3 depth + blind spot check lens + opposing-viewpoint scan. |
| C:5 | C:4 depth + root-cause analysis for any finding. |

A C:1 adversarial read is not shallow — it's *brief*. The stance remains "what's wrong here?" The complexity gates how many tools apply, not whether critique applies.

**Never downgrade to collaborative review on complexity alone.**

Acceptable downgrades:
- **Explicit user override** ("skip adversarial, I know it's fine") — logged to ISS ### Issues Found with user's stated rationale and to sprint-state [DECISIONS]
- **Routine-class operation with zero precedent failures** (document the first instance; this is rare)

Unacceptable downgrades:
- "Complexity is low, so adversarial isn't needed"
- "Build self-reviewed, so adversarial is redundant"
- "Context is tight, so abbreviated review"
- "The user is satisfied with the approach, so why look for problems?"

### 2. Red Flags Vocabulary

Language patterns that signal validation is about to skip a gate, soften a finding, or prematurely complete. Catch them in your own output before emitting.

**Generic rows** (inherited from operation-skill-template v2.1.0; reproduced in-file per the catch-at-read placement rule):

| Red Flag | Signal | Corrective |
|---|---|---|
| "should" / "probably" / "seems to" | Soft imperative — gate about to be skipped | Replace with imperative or prohibition |
| "Great!" / "Done!" / "All set!" | Premature completion signal — checklist not verified | Require explicit checklist output before celebration vocabulary |
| "I'll assume..." / "Given that..." | Assumption insertion — evidence skipped | Halt, verify assumption from disk or user |
| "It seems correct" / "Looks good" | Verification shortcut — no anchor extracted | Require literal anchor substring from just-written content |
| "This should work" | Hypothetical completion — not tested | State what would verify it, then verify |
| "Moving on to..." before gate output | Gate output suppressed — protocol skipped | Emit gate output before transition |

**Validate-specific extensions** (unique to validation work):

| Red Flag | Signal | Corrective |
|---|---|---|
| "Minor issue, moving on" | Finding dismissed without filing | Log to ISS ### Issues Found |
| "The tests covered this" | Coverage claim without verification | Name test (number/title) + actual result |
| "Per the user's prior approval" | Plan-approval masquerading as execution-verify | Execute post-write verification anyway |
| "This is within tolerance" | Threshold invented at decision time | State tolerance BEFORE measurement |
| "The intent was clear" | Intent-based pass instead of evidence-based | Verify against documented intent in ISS Solution-Design |
| "Compared to {other issue}, this is fine" | Relative reasoning | Validate against this issue's criteria |

**Scope**: This vocabulary applies at every validate step — QA Verification, Criteria Assessment, Quality Review, Pattern Finalization, Quality Gate, User Acceptance, Closure.

### 3. Rationalizations to Watch For

Pre-refutation of common LLM excuses for skipping discipline. At token pressure LLMs generate plausible-sounding justifications; pre-committing the counter-argument to disk closes the loophole.

**Generic rows** (inherited from operation-skill-template v2.1.0):

| Excuse (you might think this) | Reality (why the excuse is wrong) |
|---|---|
| "This issue is simple, it doesn't need full validation." | Complexity is orthogonal to validation need. Simple + subtle > complex + obvious. |
| "The build was clean — the closure checklist is redundant." | Build self-review and closure validation operate on different evidence. One doesn't substitute for the other. |
| "Context is tight, so I'll skip the adversarial round." | Context pressure is *exactly* when drift happens. Adversarial stance is the structural safeguard against context-fatigue shortcuts. |
| "The user approved the plan, so the gate is satisfied." | Plan approval ≠ execution verification. Gates fire at each write point regardless of prior plan approval. |
| "I already verified once this phase, re-verifying is redundant." | Verification is write-scoped, not phase-scoped. Each write is its own gate. |

**Validate-specific additions**:

| Excuse | Reality |
|---|---|
| "Criterion 3 is met because the implementation touched the area." | Presence of work ≠ verification of outcome. The criterion states an outcome; verification means demonstrating the outcome was produced. |
| "All dimensions pass without reasoning." | Zero-evidence passes are not passes. Every dimension assessment must state what was examined. |
| "User override makes the gate advisory." | Override ≠ skip; requires explicit acknowledgment of failure and logged rationale. |
| "Pattern applied, outcome will emerge." | Every pattern must have a final verdict {helped/neutral/hindered} before closure. "Applied" is not a closing state. |

### 4. Anti-Patterns (validate-specific failure modes)

The 9 generic anti-patterns from operation-skill-template v2.1.0 §4 (Gate-Dressed Conditional, Cross-Reference-Only Gate, Post-Hoc Adversarial, Constraint-Wall-Only, Placeholder Shipping, Premature-Completion Vocabulary, Silent Downgrade, Over-Specified Step, Under-Specified Step) apply to /nexus-validate as written — see template for full Why-Bad / Corrective text.

The following extensions name validate-specific drift patterns. Generic anti-patterns deduplicated against the template (Complexity-Gated Adversarial Review → template's ❌ Post-Hoc Adversarial; Cross-Referenced Gate Without In-File Marker → template's ❌ Cross-Reference-Only Gate; Premature "Evaluation Complete" Signal → template's ❌ Premature-Completion Vocabulary).

#### ❌ Confirmation-Biased Criteria Pass

**What it looks like**: "Criterion 3 is met because the implementation touched the area it was supposed to touch."

**Why bad**: Presence of work near the criterion is not verification. The criterion states an outcome; verification means demonstrating the outcome was produced.

**Corrective**: For each criterion, state the specific evidence that demonstrates it (test output, read-back content, user-visible behavior). No evidence = criterion not verified, not "met."

#### ❌ Rubber-Stamp Quality Assessment

**What it looks like**: "Quality dimensions all pass — Functional ✓ Integration ✓ Standards ✓ Holistic ✓" with no per-dimension evidence.

**Why bad**: Quality assessment is an adversarial read, not a celebration lap. Passing every dimension without named reasoning indicates the validator didn't look.

**Corrective**: For each dimension, state what was examined and what was concluded. Zero-evidence passes are not passes.

#### ❌ Plan-Approval-Implies-Execution-Verification

**What it looks like**: "User approved the plan at Analysis, so the write step is fine — no need to verify."

**Why bad**: Plan approval and execution verification operate on different evidence. Plan says what *should* happen; verification confirms what *did* happen. Conflating them means writes ship unchecked.

**Corrective**: Every write still requires post-write verification per CLAUDE.md [Section: File-Operations-Protocol] step 5, regardless of prior plan approval.

#### ❌ Pattern Outcome Left as "Applied"

**What it looks like**: Pattern Finalization (Step 5) completes with one or more patterns stuck at status `applied` (no {helped/neutral/hindered} verdict).

**Why bad**: Undecided pattern outcomes corrupt the learning loop. Sprint closure processes pattern outcomes — "applied" tells it nothing about whether the pattern worked.

**Corrective**: Step 5 §D Validation Gate blocks on this — the failure mode is silently skipping the gate. Reality Check (§6) and FILLED/ESCALATED/SKIP classification (§7) prevent silent passes.

#### ❌ User-Override-as-Default

**What it looks like**: On Quality Gate FAIL, skill defaults to "user can override" without surfacing the quality concern first. (Overlaps with template's ❌ Silent Downgrade — extends with validate-specific override semantics.)

**Why bad**: Override is an escape hatch, not a default. Defaulting makes the gate advisory rather than load-bearing.

**Corrective**: Present the failure with full reasoning **first**. The user's choice is "accept the failure" or "fix it," not "bypass the check." Override requires explicit acknowledgment of the failure, logged to ISS ### Issues Found.

### 5. Bounded Iteration Cap

When a discipline gate fails and requires retry (e.g., "evidence insufficient, gather more"), cap retries at **three attempts** for the same gate in the same phase. After three failures, ESCALATE rather than continue iterating.

**Validate application**: if Reality Check (§6) fails to find evidence for a claim after three rounds of evidence-gathering, escalate to ESCALATED status per §7. Do not continue retrying — iterative failure past 3 attempts signals a structural problem, not a gatherable-evidence problem.

Scope: per-gate, per-phase. A later phase may re-attempt the same gate fresh.

### 6. Reality Check (3-question diagnostic + 3-state outcome)

For each "verified" claim surfacing in Quality Review, ask one of these questions:
- "What's the actual evidence this is true?"
- "What's the simplest way this claim could be wrong?"
- "If I were wrong about this, what would I see?"

Examples of claims that trigger a Reality Check:
- "All criteria met" → name each criterion's specific evidence
- "Tests pass" → state N/N pass count + verify at least one assertion per test
- "Integration intact" → name the integration points examined
- "Standards followed" → cite the specific standard and the evidence of compliance
- "No regressions" → state which files/functionalities were checked for regression
- **"No findings" / "clean" / "0 issues" / "nothing flagged"** → state the **bound/candidates pair**: how many items the check was supposed to examine, and how many it actually resolved. A zero-finding claim is the one claim whose evidence is *indistinguishable from its own absence* — a check that parsed nothing reports the same zero as a check that parsed everything and found nothing wrong. Unlike a false positive, which an implausible magnitude can betray, the vacuous pass has no tell. **`bound < candidates` → ESCALATED**, never FILLED. If the claim's own author cannot state the denominator, the check has not been Reality-Checked.

Outcome classification (per §7):
- **FILLED**: evidence produced, claim passes. Carry forward.
- **ESCALATED**: claim lacks evidence, not recoverable within 3 retries. Log to ISS ### Issues Found with escalation reason.
- **justified SKIP**: criterion legitimately can't be Reality-Checked in this context (e.g., "Standards followed" with no explicit standards doc). Log with explicit justification citing the rule that permits skip.

Reality Check is not suspicion — it's insistence on evidence. Claims in SKIP state must have the skip rationale documented; silent skips become gates that don't actually gate.

*Adapted from agency-agents Reality Checker specialist (ISS-159 Phase 3 investigation). Absorbed as a skill-level mechanism with op-skill v2.1.0 Discipline Layer integration.*

### 7. FILLED / ESCALATED / SKIP Terminal Classification

Every discipline check in /nexus-validate terminates in one of three explicit states. No silent passes, no implicit skips.

| State | Meaning | Required output |
|---|---|---|
| **FILLED** | Gate check completed with evidence. Work passes. | Evidence anchor (literal substring from ISS content or disk) + gate name confirmed |
| **ESCALATED** | Gate check failed after iteration cap OR surfaces issue main context must resolve | Escalation reason + what was attempted + what blocks |
| **justified SKIP** | Gate deliberately not applicable to this work | Explicit justification + reference to the rule that permits skip |

**Applies to**: Reality Check (§6), Criteria Verification per-criterion, Quality Review per-dimension, Pattern Finalization per-pattern, Nyquist Audit per-axis (§8).

An unsatisfied gate must resolve to ESCALATED or justified SKIP — never to "proceeding anyway" or silent continuation.

### 8. Nyquist Audit (closure-gate adversarial scan)

Before marking the End-of-Workflow Checklist complete, run a concise closure-gate adversarial scan: assume this issue's changes ship to production in the current state. What breaks?

**Named axes** (apply per relevance):
- **Integration drift**: does something downstream that depends on this assume the old behavior?
- **Silent regression**: is there a code path that works the same but for different reasons now?
- **Documentation staleness**: does a guide or CLAUDE.md section describe the old behavior?
- **Pattern mismatch**: does this contradict a pattern or convention surfaced during Build?
- **Constitution drift**: does this weaken a constitution principle?

**Token budget**: a paragraph of scrutiny — one-paragraph inventory of findings. Not an exhaustive regression scan. Last-look filter before the issue closes.

**Per-axis outcome**: apply §7 FILLED / ESCALATED / SKIP. If any axis surfaces a concern: log to ISS ### Issues Found, decide whether it's blocking (back to Build) or non-blocking (follow-up issue).

*Adapted from GSD Nyquist-style adversarial tester (ISS-159 Phase 3 investigation). Absorbed as a Discipline Layer component.*

### Layer Audit Checklist

Verify when reviewing this skill:
- [ ] Default Adversarial Posture declared (not complexity-conditional)
- [ ] Red Flags table reproduced in-file (generic + validate-specific extensions)
- [ ] Rationalizations table present (generic + validate-specific additions)
- [ ] Anti-Patterns: 9 generic referenced + 5 validate-specific extensions named
- [ ] Bounded Iteration Cap specified (3-attempt rule with validate application)
- [ ] Reality Check 3-question diagnostic + 3-state outcomes (§6)
- [ ] FILLED / ESCALATED / SKIP terminal states required at each gate (§7)
- [ ] Nyquist Audit defined with concise-scan phrasing (§8 — token-budget inventory, not clock-time)
- [ ] No softened gate phrasing in invoking steps

---

## Cognitive Tools for Validate

| Tool | When During Validate | Typical Step |
|---|---|---|
| Adversarial Review | Validate implementation completeness | Quality Review §2 (mandatory, all complexities — depth scales per §DE Layer §1 Posture) |
| Mental Simulation | Walk through changes as fresh instance | Quality Review §2 |
| Blind Spot Check | High confidence in positive evaluation | Quality Review §2 |
| Systems Thinking | Many modified files, cross-component effects | Criteria Assessment §1 |
| Root Cause Analysis | Understanding test failures or quality issues | QA Verification Step 2, Quality Gate Step 6 |

---

## Step 1: Orient (Silent)

No display to user until QA Verification. Load context, detect resumption, verify readiness.

### E.0 — Scope Detection

First action of Orient. Branch on `$ARGUMENTS[0]` prefix:

| Prefix | Scope | Effect |
|---|---|---|
| `ISS-` (or no prefix detected) | Issue scope | Default flow unchanged. Continue with §A → §B (issue branch) → §C → §D → §E → §F → §G. |
| `SPRINT-` | Sprint scope | Set `scope = sprint`. Continue with §A. §B uses the sprint-scope branch. §C resumption checks sprint-level `continue_with`. §D Score Gate is N/A (no single ISS evaluated score). §E Type Detection is bypassed — type is fixed to `sprint-level`. §F QA Tier is N/A (no Build tests to audit). §G Path Decision routes directly to `types/sprint-level.md` regardless of complexity (sprint-level Validate is always type-file driven). |

Default-safe: existing ISS-XXX invocations follow the issue path verbatim; no behavioral change for per-issue Validate.

> **Mental note**: scope = {issue | sprint}. Subsequent steps respect this branch.

**Task-tracking (ISS-199)**: on entry, create a coarse phase-level task list per CLAUDE.md [Section: Phase-Management-Protocol] → *Methodology Task-Tracking Convention* (one entry per phase of this skill — e.g. Orient → QA Verification → Review → Quality Gate → Acceptance → Closure); `TaskUpdate` at each phase boundary; honor user opt-out.

### A — Memory Check

Recite all files currently in active context. Avoid wasteful reloads.

### B — Load Issue Context (or Sprint Context)

**Issue scope (default — `scope = issue` from §E.0):**

ISS-XXX.md if not in memory. Extract (type-adapted):

**Default/Bug/Documentation/Question**: Solution-Design (approach, tools/patterns, files affected), Implementation-Plan (phases, steps, status), Implementation-Log (changes made, tests created, deviations, pattern outcomes, technical decisions, issues encountered), Success Criteria.

**Research**: Solution-Design (research approach), Implementation-Plan (research phases), Implementation-Log → Research Log (Findings Summary, Quality Checks, Scope Changes, Research Pivots), Research Questions (from Research Design ### Approach).

**Creative**: Solution-Design (creative brief/outline), Implementation-Plan (sections/drafts), Implementation-Log → Drafts & Versions (sections completed, refinement iterations, user feedback), Creative Brief requirements.

**Sprint scope (`scope = sprint` from §E.0):**

Substitute single-ISS load with the sprint-set load. Required inputs (load if not in memory):

| Input | Source | Used by |
|---|---|---|
| `_mode`, `_title`, `_sprint`, [OBJECTIVES] (completed list) | sprint-state.md | Cross-cut 1 (theme self-prove) — determines whether ALL or COHERE-ACROSS rule applies |
| [FILES_MODIFIED] (per-conversation entries across the sprint) | sprint-state.md | Cross-cut 2 (cross-skill / cross-file drift) — identifies shared modifications |
| `scope_files`, `blocks`, `blocked_by` for each sprint issue | issues-registry.yaml | Cross-cut 2 (cross-issue surface overlap) |
| changelog-registry.yaml current_versions block + recent edit_history | changelog-registry.yaml | Cross-cut 3 (version stack consistency) |
| Each closed ISS file in [OBJECTIVES] completed list | `.nexus/issues/ISS-XXX.md` | Cross-cuts 1, 2, 4 (theme contribution, surface modifications, constitution-as-aggregate) |
| `[PROJECT_CONSTITUTION]` (if present) | project-state.md | Cross-cut 4 (per-principle evidence) |
| [PATTERNS_IN_USE] (across sprint issues) | sprint-state.md | Cross-cut 4 (pattern-driven discipline evidence) |

§D Score Gate is N/A (no issue-evaluated score). §E Type Detection bypassed (`type = sprint-level`). §F QA Tier is N/A (no Build tests to audit). §G routes directly to `types/sprint-level.md`.

Display at end of Orient (sprint-scope variant):
```
📋 Sprint-Level Evaluation Context Loaded
• Sprint: #{NNN} ({mode}) — "{title}"
• Issues: {N} closed
• Trigger signals (from /nexus-close-sprint STEP 0): {list}
• Cross-cuts: 4 (theme self-prove, cross-skill drift, version stack, constitution holism)
```

### B.1 — Phase-Entry Briefing (fresh-session only, per-issue scope)

**Applies to**: `scope = issue` per §E.0. Sprint-scope evaluation retains the `📋 Sprint-Level Evaluation Context Loaded` display above; per-issue scope replaces the prior `📋 Evaluation Context Loaded` block with the user-oriented briefing below.

**Fresh-session entry**: Display this briefing only on fresh-session entry. Fresh-session = this methodology was NOT invoked as a phase Transition from a different phase methodology earlier in THIS conversation for the SAME ISS-XXX. Same-session phase transitions (typically /nexus-build → /nexus-validate or /nexus-research → /nexus-validate within one conversation) skip the briefing — continuity context already covers it.

**Detection**: Introspect conversation history at this step. If a prior phase methodology emitted a Transition handoff to /nexus-validate for THIS SAME ISS-XXX earlier in this conversation, this is same-session → skip to §C Resumption Detection. Otherwise → fire the briefing below. The Transition handoff is the methodology's phase-complete display block — examples include "📊 Implementation Phase Complete / [Transitioning to Evaluation — /nexus-validate]" (from /nexus-build) or the Research-phase equivalent (from /nexus-research). Match the *semantic* signal (prior phase handed off to this skill for this ISS this conversation), not a single literal string.

**Render**:

> 📋 ISS-{XXX} — {title}
> Type: {type} | Created: {YYYY-MM-DD} | Complexity: {N}
>
> Origin: {Notes & Context ### Origin distilled to 1-2 sentences | "not recorded"}
>
> Problem: {first paragraph of ## Description, distilled to 1-2 sentences}
>
> Prior phase summary: {one-line distillation of prior-phase content — Implementation-Log ### Status + ### Changes Made for Build-output issues; Research-Log Findings Summary for Research-output issues; Solution-Design Findings for Question-informational issues}
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

(This briefing replaces the prior `📋 Evaluation Context Loaded` LLM-confirms block — the user-anchored summary supersedes the prior internal-confirm display, which was redundant with what the methodology already had in active context.)

### C — Resumption Detection

Read ISS [Section: Evaluation-Results] content.

| Condition | Action |
|---|---|
| continue_with references "Loop-back to evaluation" | Loop-back arrival — show reason and implementation findings. Ask what needs re-evaluating. |
| Progress marker found (partial from previous conv) | Display summary. Resume at indicated step. |
| Complete content, no marker | Offer: A) Review existing, B) Re-evaluate, C) Proceed to Step 9 closure. |
| Placeholder + continue_with has step context | Resume from indicated step. |
| Placeholder, no context | Fresh start → proceed to D. |

### D — Score Gate

Check current evaluated score from issues-registry.yaml.

| Score | Action |
|---|---|
| ≥ 4, ISS has content | Offer: A) Review existing, B) Re-evaluate, C) Skip to Step 9. |
| ≥ 4, ISS empty | Warn data inconsistency. Recommend re-evaluating. |
| < 4 | Proceed to E. |

### E — Type Detection

**Issue scope**: extract issue type from ISS header. Map to type file:

| Issue Type | Type File |
|---|---|
| Feature, Improvement, Refactor, Documentation, Question, Bug | types/default.md |
| Creative | types/creative.md |
| Research | types/research.md |

**Sprint scope**: skip type detection — type is fixed to `sprint-level` per §E.0. Type file: `types/sprint-level.md`.

### F — QA Tier Assessment

Determine QA Verification scope based on risk signals.

**Primary signal**: Is Build's work in active context (same conversation) or loaded from ISS (different conversation)?

| Signal | Effect |
|---|---|
| Same conversation as Build (active context) | Tier 1 baseline |
| Different conversation (loaded from ISS) | Tier 2 baseline |
| C:3+ or multi-file changes | → Tier 3 |
| Sprint has interconnected issues (shared files across issues) | → Tier 3 |
| Build documented test gaps/limitations in ISS ### Issues Encountered | Escalate +1 |
| User requests thorough evaluation | → Tier 3 |

Multiple signals stack — highest tier wins.

### G — Path Decision

| Scope | Complexity | Path |
|---|---|---|
| issue | 1–2 | → [Section: Simple-Path] |
| issue | 3+ | → [Section: Router] |
| sprint | (any) | → [Section: Router] (sprint-level Validate is always type-file driven) |

> **Mental note**: Context loaded. Type: {type}. Tier: {N}. Resuming at: {step or "Simple/Complex Path"}.
> If checkpoint fires → continue_with only (no ISS write yet).

---

## Step 2: QA Verification (all paths)

Replaces blind test re-execution. Verify Build's test work, then scale QA effort based on tier.

### A — Audit Build's Test Work (always runs)

- Confirm ISS ### Tests Created exists and has execution results
- Confirm tests map to Success Criteria (coverage check)
- Identify gaps — any criteria without test coverage?
- If Build didn't run tests or left gaps → execute missing tests now, regardless of tier

> 📋 Test Audit
> Tests documented: {count}
> Tests executed by Build: {count} ({pass_rate}%)
> Coverage gaps: {list or "none"}

### B — Tier-Based Execution

| Tier | What to execute |
|---|---|
| Tier 1 (same context, low risk) | Audit only. Accept Build's results if complete. Execute only missing tests. |
| Tier 2 (different context, or risk signals) | Re-run tests on files that may have been affected since Build. Targeted regression on shared files. |
| Tier 3 (complex, interconnected) | Full re-execution of all tests. Integration-level system verification. Cross-component flow validation. |

Per-test display format (Tier 2/3 execution):
> 🧪 Test {N}: {name} — {purpose}
> Expected: {expected}. Actual: {observed}.
> Result: ✓ PASS / ❌ FAIL

**Bug-type note**: Always re-verify reproduction scenario is gone, even at Tier 1. Bugs can resurface.

**Research-type note**: No traditional tests. QA verification = "are quality checks documented and complete?" — source verification, coverage confirmation.

**Creative-type note**: No automated tests. QA verification = "brief compliance check" — does deliverable match brief's requirements?

### C — Regression Check (Tier 2+ only)

For Tier 2: check files modified by this issue against other sprint work. Verify cross-references still resolve.

For Tier 3: broader system-level flow verification, not just individual file consumers.

> 🔄 Regression Check
> Files modified by this issue: {list}
> Overlap with other sprint issues: {list or "none"}
> Cross-references: {intact / broken: list}
> System-level verification: {results}

### D — Results Analysis and Failure Handling

Calculate pass rate, group failures by severity (critical/major/minor).

If failures:
**[T2: Balanced+Full ask | Streamlined: auto-recommend best option, notify]**
> Options: [Loop back to Build / Adjust test expectations (document reasoning) / Document as known limitation]

If approach fundamentally flawed → propose loop to Analysis via /nexus-loop-back.

### E — Write to ISS

Patch ISS [Section: Evaluation-Results] ### Test Execution. Place progress marker: `*Evaluation in progress — QA verification complete*`

**[T3: Full ask | Balanced: notify | Streamlined: auto-write]**

---

## Simple Path (C:1-2)
[Section: Simple-Path]

Complete inline evaluation for simple issues. Zero external file loads. Type-aware guidance via callout boxes per step.

### Step 3: Criteria Assessment (inline)

**A — Forward mapping**: Each success criterion → evidence → met/partial/not met.

> 📋 Success Criteria Verification
> - [x] {Criterion 1}: ✓ Met — {evidence}
> - [ ] {Criterion 2}: ❌ Not met — {gap}
> Result: {X}/{total} criteria met

**B — Gap analysis**: For unmet criteria: critical or acceptable? Address now or track?

**C — Write**: Patch ISS ### Criteria Verification.

### Step 4: Quality Review (inline)

**A — Plan vs actual**: Scope match, approach followed, deviations noted.

**B — Quality dimensions** (type-dependent):

Default 4 dimensions: Functional, Integration, Standards, Holistic.

> **Documentation callout**: Replace 4 default dimensions with: Accuracy (matches source), Completeness (topics covered), Clarity (audience-appropriate), Structure (logical, findable).

> **Question (informational-only) callout**: No implementation to evaluate. Dimensions: Accuracy, Completeness, Clarity, Actionability. QA Verification: verify sources cited, check contradictions.

> **Bug callout**: Same 4 default dimensions, plus verify reproduction scenario is definitively resolved.

> **Creative C:1-2 callout**: Use graduated criteria (audience-fit, message clarity, tone consistency) and 5 creative dimensions (audience-fit, message clarity, tone consistency, structural flow, polish). Refinement framing, not defects.

**C — Known concerns check** (conditional): If `.nexus/supporting-files/project-context/CONCERNS.md` exists, check implementation against project concerns intersecting this issue's scope.

**C2 — Convention compliance check** (conditional): If `.nexus/supporting-files/project-context/CONVENTIONS.md` exists, read relevant sections and verify implementation follows established conventions. Flag deviations: "Convention deviation: {convention} — {what was done instead}. Intentional? [Accept deviation / Fix]."

**D — Technical debt / open items**: Surface shortcuts, TODOs, compromises.

**E — Constitution compliance**: If `[PROJECT_CONSTITUTION]` exists in project-state.md, verify no violations. Always check regardless of complexity.

**F — Write**: Patch ISS ### Quality Assessment.

**Scope Reality Check** (after Step 3): If criteria assessment reveals broader scope than C:1-2 anticipated, surface: "Scope appears broader than planned. Options: [Escalate to complex path / Continue as-is]." **[T2: Balanced+Full ask | Streamlined: auto-recommend, notify]**

After Steps 3-4: proceed to Step 5 (Pattern Finalization) → Step 6 → Step 7 → Step 8 → Step 9.

After all steps:
- Run [Section: End-of-Workflow-Checklist]
- Execute [Section: Commit-Protocol] **[T3: Full ask | Balanced: notify | Streamlined: auto-write]**
- Closure is handled by Step 9 — Validate doesn't transition to another methodology, it closes the issue.

[/Section: Simple-Path]

---

## Router (C:3+ or sprint scope)
[Section: Router]

Reached when Orient §G routes here — either issue scope at complexity ≥ 3, or sprint scope (any complexity). Load the type-specific evaluation workflow.

### Load Sequence

Read type file (1 load — no further loads after this):

`${CLAUDE_SKILL_DIR}/types/{type}.md`

**Type mapping:**

| Scope | Issue Type | File |
|---|---|---|
| issue | Feature, Improvement, Refactor, Documentation, Question, Bug | types/default.md |
| issue | Creative | types/creative.md |
| issue | Research | types/research.md |
| sprint | (N/A — fixed) | types/sprint-level.md |

### Execution Sequence

After loading type file, execute in this order:

1. Type file §1 Criteria Assessment → §2 Quality Review
2. Return to SKILL.md Step 5 (Pattern Finalization)
3. Step 6 (Quality Gate) → Step 7 (User Acceptance) → Step 8 (Documentation & Learning) → Step 9 (Closure)
4. [Section: End-of-Workflow-Checklist] → [Section: Commit-Protocol]

### Zone Checks

After type file returns: apply the Green/Yellow/Red zone actions per CLAUDE.md [Section: Memory-Context-Management] → Context Zones.

[/Section: Router]

---

## Step 5: Pattern Finalization (shared, conditional)

**Condition**: Check sprint-state [PATTERNS_IN_USE] for this issue. If no patterns → skip entirely (silent).

### A — Check Patterns

Read [PATTERNS_IN_USE] for this issue. If empty: skip to Step 6.

### B — Assess Each Pattern

For each pattern with any status:

| Current Status | Action |
|---|---|
| "applied" (no outcome yet from Build) | Must assess now with evaluation evidence |
| helped/neutral/hindered (Build's verdict) | Review — does evaluation evidence confirm or override? |

> 📐 PAT-{XXX}: {name}
> Build's verdict: {status}
> Evaluation evidence: {what we now see}
> Final outcome: {helped / neutral / hindered}
> {If overriding Build: "OVERRIDE — {reason}"}

**Verdict taxonomy + dedup gate**: outcomes use {helped/neutral/hindered} — NOT auto-success. Before recording `helped`, apply the dedup hard-gate (SC-04): a pattern that merely restates an always-on CLAUDE.md core rule/preference/trait or a skill step caps at `neutral`. Each verdict needs a one-line evidence note. close-issue STEP 2A is the authoritative capture point; this finalization feeds it. (Canonical taxonomy: pattern-specification.md → Outcome Verdicts; rule: CLAUDE.md Pattern Governance.)

### C — Update Records

Patch sprint-state [PATTERNS_IN_USE] with final outcomes.
Patch ISS ### Pattern Outcomes (especially if overriding Build).

⛔ MANDATORY OUTPUT after writing pattern outcomes (must appear in response):
⛔ [WRITE-VERIFIED] .nexus/issues/ISS-XXX.md [Section: Evaluation-Results] ### Pattern Outcomes | anchor: "{exact substring from disk showing final outcomes per PAT-XXX}" | status: {present|missing}

Values must be read from disk after the write — not the values you intended to write. If status: missing, retry the write and re-emit the gate. Cannot proceed to Step 5 §D until status: present.

### D — Validation Gate

**[T3: Full ask | Balanced: notify | Streamlined: auto-assess, log]**

No pattern may remain "applied." All must have final outcomes.

If any remain "applied":
> ⚠️ Cannot proceed — patterns without outcomes: {list}

### E — Write to ISS

Update ISS [Section: Evaluation-Results] pattern section.

---

## Step 6: Quality Gate [T2]

**[T2: Balanced+Full ask | Streamlined: auto-assess, notify]**

Decision point aggregating Steps 2-5. Not a review — assessment already happened.

### A — Readiness Checklist

Aggregate all gate criteria with explicit per-criterion verdict:

| Criterion | Threshold | Actual | Verdict | Type Notes |
|---|---|---|---|---|
| QA Verification | Passed per tier | {result} | PASS / CONCERNS / FAIL | Tier level noted |
| Critical failures | 0 | {count} | PASS / FAIL | Research: bias/source. Creative: fundamental misalignment. |
| Success criteria met | Majority met | {met}/{total} | PASS / CONCERNS / FAIL | Research: questions answered. Creative: dimensions assessed. |
| Quality dimensions | No FAIL | {results} | PASS / CONCERNS / FAIL | Standard: 4 dims. Research: 4. Creative: 5. |
| Regressions | None critical | {count} | PASS / FAIL | Research/Creative: N/A — skip row. |
| Patterns assessed | All have outcomes | {yes/no/N/A} | PASS / CONCERNS / N/A | N/A if no patterns used. |
| Constitution | No violations | {result} | PASS / FAIL / N/A | N/A if no constitution exists. |

Reality Check per §DE Layer §6 fires per-criterion above; per-criterion verdict reflects FILLED / ESCALATED / justified-SKIP per §DE Layer §7.

### B — Gate Verdict

Derive overall verdict from per-criterion results:

| Verdict | Condition | Action |
|---|---|---|
| **PASS** | All criteria PASS | Proceed to User Acceptance. Score: 4 or 5. |
| **CONCERNS** | No FAIL verdicts, but one or more CONCERNS | Document gaps in `continue_with` before proceeding. Proceed to User Acceptance with gaps visible. Score: 4. |
| **FAIL** | Any criterion has FAIL verdict | Loop back required — do not proceed. |

**PASS display:**
> 🚦 Quality Gate: PASS
> Evaluation score: {4 or 5}/5

Score guidance:

| Score | Criteria |
|---|---|
| 4 | All gate thresholds met, minor gaps documented, no FAIL dimensions |
| 5 | All thresholds met, all criteria fully met, no gaps, no debt, adversarial clean |

**CONCERNS display:**
> 🚦 Quality Gate: CONCERNS
> Evaluation score: 4/5
> Gaps:
> • {criterion}: {what's not fully met}
> Action: Gaps documented in continue_with for next conversation visibility.

CONCERNS allows "proceed with documented gaps" — quality signals are never silently suppressed. Gaps must be recorded in `continue_with` so the next conversation inherits full context.

**Handling CONCERNS — guidance:**

| Gap Severity | Action | When |
|---|---|---|
| Minor (cosmetic, non-functional) | Note in ISS ### Issues Found. No follow-up needed. | Proceed to closure normally. |
| Moderate (functional but non-blocking) | Create follow-up issue via /nexus-create-issue. Link as related to current issue. | Proceed to closure. Follow-up tracked in backlog. |
| Significant (affects usability but not correctness) | Document in `continue_with` + create follow-up issue. Flag at sprint closure for prioritization. | Proceed to closure with explicit sprint-closure flag. |

Decision aid: "If this gap shipped to a user, would they notice?" Minor = no. Moderate = yes, but workaround exists. Significant = yes, and it degrades the experience. If the answer is "yes, and it breaks things" → that's a FAIL, not CONCERNS.

**FAIL display:**
> 🚦 Quality Gate: FAIL
> Issues: {list of FAIL criteria}
> Options: [Loop back to Build / Loop back to Analysis / Document as known limitations / Adjust criteria]

Loop-back targeting: fixable implementation bugs → loop to Build. Fundamental approach problems → loop to Analysis. Present reasoning with target to user. If accepted: invoke /nexus-loop-back, end Validate execution.

**User override**: If user says "pass" with FAIL verdicts, warn that quality gaps remain but proceed if insisted. Document override in ISS ### Issues Found.

### C — Two-Place Score Update

On gate pass or concerns:
1. issues-registry.yaml: ISS-XXX.evaluated = {score}
2. sprint-state.md [OBJECTIVES]: E:{score}

Display: "🔄 Updated Evaluation score in 2 locations (verified)"

⛔ MANDATORY OUTPUT after evaluation-score two-place update (must appear in response):
⛔ [TPU-VERIFIED] ISS-XXX → registry: E:{X} | sprint-state: E:{X} | match: {yes|no}

Per CLAUDE.md [Section: Two-Place-Update-Protocol]. Values must be read from both files after the writes — not the values you intended to write. If match: no, retry the failing write and re-emit the gate. Cannot proceed to Step 7 until match: yes.

---

## Step 7: User Acceptance [T1]

**[T1: all levels ask]**

Tests verify correctness. Criteria verify goals. Quality review verifies standards. This step verifies *satisfaction*.

### A — Present for Acceptance

**Use AskUserQuestion widget** for this gate — it's a bounded decision with discrete options. Present type-adapted summary as context, then widget with [Accept / Revise / Reject].

Type-adapted presentation:

| Type | What to present |
|---|---|
| Default | What was built, key changes the user will experience |
| Creative | The deliverable, refinement summary. "Good enough" is valid. |
| Research | Findings summary, recommendations. "Findings are useful and actionable?" |
| Bug | Bug fix confirmed, regression clear. "Issue resolved to your satisfaction?" |
| Documentation | Updated docs, accuracy verified. "Documentation meets your needs?" |

> 👤 User Acceptance
> {type-adapted summary}
> Does it meet your expectations? [Accept / Revise / Reject]

### B — Handle Response

| Response | Action |
|---|---|
| Accept | Proceed to Step 8 |
| Revise | Ask what needs changing. Propose /nexus-loop-back to Build with specific feedback. |
| Reject | Document rejection reason. Confirm: "Close as rejected?" If yes → set rejection flag, skip to Step 9. |

### C — Rollback Readiness

Before proceeding, confirm recovery path via git history (`git log --oneline -- .nexus/`).

> 🔄 Rollback readiness: {recovery path confirmed}

---

## Step 8: Documentation & Learning [T3]

**[T3: Full ask | Balanced: notify | Streamlined: auto]**

Finalize evaluation record and capture knowledge.

**Skip or abbreviate if Step 7 resulted in rejection** — offer abbreviated capture ("Any lessons from this rejection worth recording?") but don't force full documentation workflow.

### A — Finalize ISS Evaluation-Results

Verify all subsections complete:
- ### Test Execution (from Step 2)
- ### Criteria Verification (from Step 3)
- ### Quality Assessment (from Step 4)
- ### Issues Found (accumulated from Steps 2-7)
- ### Lessons Learned (section B below)
- ### Deliverable Review (Research type only — written at types/research.md §2H; the Research ISS structure carries no ### Test Execution)

Remove progress markers.

### B — Capture Lessons Learned

> 📝 Lessons Learned
> **What worked well**: {list}
> **Challenges**: {list}
> **For next time**: {actionable insights}
> **Pattern effectiveness**: {PAT-XXX: evidence}

### C — Capture System Learning

Sprint-state experience sections:
- [SYSTEM_ISSUES]: protocol gaps, methodology issues, technical problems
- [BEHAVIORAL_INSIGHTS]: user preferences, working patterns
- [CANDIDATES_PATTERNS]: novel solutions that might generalize
- [DISCOVERIES]/insights: significant findings

### D — Documentation Impact

**D1 — NEXUS system docs** (only if system files were modified):
Check ISS ### Changes Made — do any files live under `.nexus/active/` or `.claude/skills/`?
If yes: load documentation-registry.yaml, search for guides referencing modified files. Stale guides → offer update via /nexus-guide-creator, defer to sprint closure, or skip.
If no system files modified: silent pass.

**D2 — Project deliverable docs** (if project files modified):

| Project type | Action |
|---|---|
| IT/Software | Prompt: "Update project documentation? [Yes / No / Later]" |
| Research / Creative / Educational | Silent pass — deliverable IS the documentation |

If neither branch applies: skip entirely, no display.

### E — Technical Debt

Minor debt → note in ### Issues Found.
Significant debt → offer /nexus-create-issue for follow-up.

---

## Step 9: Closure [T2]

**[T2: Balanced+Full ask | Streamlined: auto-proceed after acceptance, notify]**

Formal close gate. Delegates heavy lifting to /nexus-close-issue.

**Note on T2**: CLAUDE.md [Section: Control-Levels] lists "Issue/sprint closure" as a T1 example. This is an intentional override — the T1 protection is moved upstream to Step 7 (User Acceptance), where the real human judgment happens. Closure is the administrative consequence of acceptance. The user already made the consequential decision.

### A — Final Score Verification

> 📊 Final Scores
> Analyzed: {X}/5
> Implemented: {Y}/5
> Evaluated: {Z}/5

### B — Propose Closure

**Standard (accepted):**
> 📋 Issue Closure Proposal
> ISS-XXX: {title}
> • Scores: A:{X} I:{Y} E:{Z}
> • QA: {tier} — {result}
> • Quality: {assessment}
> • User acceptance: ✓
> • Patterns: {count} assessed ({outcomes})
>
> Proceed with closure? [Y/n]

**Rejection path (from Step 7):**
> 📋 Issue Closure — Rejected
> ISS-XXX: {title}
> Rejection reason: {from Step 7}
>
> Close as rejected? [Y/n]

### C — Delegate

On approval: invoke `/nexus-close-issue ISS-XXX`.
/nexus-close-issue handles: knowledge extraction, resolution recording, two-place status update, archive preparation.

### D — Confirm

> ✅ Issue Closed
> ISS-XXX: {title}
> Resolution: {Resolved / Rejected}
> Final Scores: A:{X} I:{Y} E:{Z}

---

## Post-Closure Routing

Check sprint-state [OBJECTIVES] for remaining issues.

| Condition | Action |
|---|---|
| Remaining planned/in_progress issues | Select next issue per selection rule below. → /nexus-work-issue |
| No remaining issues | "✅ All objectives complete! Close Sprint? [Y/n]" → If yes AND context < 60%: invoke /nexus-close-sprint directly (same conversation). If yes AND context ≥ 60%: next checkpoint sets _status: closing, continue_with → close-sprint (next conversation). |

### Next-Issue Selection Rule

**THEMED mode**: Select the next issue in the current phase group (all issues advance through the same phase together).

**MIXED / DEDICATED mode**: Filter and sort [OBJECTIVES] planned issues:
1. **Filter**: Only issues with all dependencies satisfied (check `blocked_by` in issues-registry — all blockers must be completed/resolved)
2. **Sort by priority**: Critical > High > Medium > Low
3. **Tiebreak by complexity**: Higher complexity first (more impactful work prioritized)

Present the top candidate:
> "Next available: ISS-{YYY} ({title}, {priority}). Work on it? [Y / pick different / n]"

If user picks different: show remaining eligible issues sorted by the same rule.

---

## Commit Protocol
[Section: Commit-Protocol]

**[T3: Full ask | Balanced: notify | Streamlined: auto-write]**

### A — Write/Update Evaluation-Results

Ensure all subsections current and verified on disk:

| Subsection | Content |
|---|---|
| ### Test Execution | QA results, pass rate, tier used (from Step 2) |
| ### Criteria Verification | Success criteria mapping (from Step 3) |
| ### Quality Assessment | Quality dimensions, debt, adversarial (from Step 4) |
| ### Issues Found | Problems and resolutions (accumulated Steps 2-7) |
| ### Lessons Learned | Knowledge captured (from Step 8) |
| ### Deliverable Review | Research type only — deliverable-level verdict (files at planned paths, structure, self-adversarial presence) from types/research.md §2H; stands in for ### Test Execution, which the Research ISS structure does not carry |

Remove progress markers. Verify on disk (MANDATORY).

### B — Update continue_with

```
WHAT: ISS-XXX evaluation complete — {resolved/rejected}
WHY: {key evaluation finding}
NEXT: Post-closure routing — {next issue or close sprint}
```

### C — Update Patterns in Use

If patterns assessed (Step 5), ensure sprint-state [PATTERNS_IN_USE] has final outcomes.

### D — Verify All Writes on Disk

Per CLAUDE.md [Section: File-Operations-Protocol] step 5. Read back each modified section from disk after every write. Unverified writes are violations.

⛔ MANDATORY OUTPUT per Evaluation-Results subsection written (must appear in response):
⛔ [WRITE-VERIFIED] .nexus/issues/ISS-XXX.md [Section: Evaluation-Results] ### {Subsection} | anchor: "{exact substring from disk}" | status: {present|missing}

Enumerate one [WRITE-VERIFIED] per subsection actually updated this Validate run:
- ### Test Execution
- ### Criteria Verification
- ### Quality Assessment
- ### Issues Found
- ### Lessons Learned
- ### Deliverable Review (Research type)

Plus high-stakes files when modified by Validate:
- `.nexus/active/states/sprint-state.md` (PATTERNS_IN_USE updates) — emit [WRITE-VERIFIED] with anchor from updated block
- `.nexus/active/registries/issues-registry.yaml` (status/score fields) — emit [WRITE-VERIFIED] with anchor from updated key
- `.nexus/issues/ISS-XXX.md` Closure section (when /nexus-close-issue runs in-flow) — emit [WRITE-VERIFIED] with anchor from Resolution line

Cannot complete Commit Protocol until every required marker has status: present.

[/Section: Commit-Protocol]

---

## Gate Reference
[Section: Gate-Reference]

All gates present LLM recommendation regardless of tier or control level.

| Gate | Tier | Full Control | Balanced | Streamlined |
|---|---|---|---|---|
| QA failure handling | T2 | Ask + rec | Ask + rec | Auto-recommend, notify |
| Quality Gate decision | T2 | Ask + rec | Ask + rec | Auto-assess, notify |
| User Acceptance | **T1** | Ask + wait | Ask + wait | Ask + wait |
| Pattern validation gate | T3 | Ask | Notify | Auto-assess, log |
| Documentation writes | T3 | Ask | Notify | Auto-write |
| Issue Closure | T2 | Ask + rec | Ask + rec | Auto-proceed after acceptance, notify |
| Post-closure routing | T3 | Ask | Notify | Auto-suggest, notify |
| Loop-back proposal | T2 | Ask + rec | Ask + rec | Ask + rec (significant) |
| Scope Reality Check (Simple) | T2 | Ask + rec | Ask + rec | Auto-recommend, notify |

**Note on T1/T2 swap**: User Acceptance is T1 (the human judgment). Closure is T2 (administrative consequence). This is an intentional override of CLAUDE.md's general T1 example "Issue/sprint closure." Rationale: the consequential decision is "Is this good enough?" not "Do you want to close the ticket?"

[/Section: Gate-Reference]

---

## Checkpoint Reference
[Section: Checkpoint-Reference]

When [Section: Checkpoint-Protocol] fires during evaluation, persist based on progress:

| After | Persist | Where |
|---|---|---|
| Orient (A–G) | Context, type, tier, complexity | continue_with only |
| QA Verification | Test results, tier, pass rate | ISS ### Test Execution with marker |
| Type file: Criteria (§1) | Criteria verdicts | ISS ### Criteria Verification |
| Type file: Quality Review (§2) | Quality assessment | ISS ### Quality Assessment |
| Pattern Finalization | Pattern outcomes | ISS + sprint-state (already updated) |
| Quality Gate | Score, gate decision | Scores already updated — verify only |
| User Acceptance | Acceptance status | continue_with |
| Documentation & Learning | Finalized record | ISS already on disk — verify only |
| Closure | Closure complete | Already processed — verify only |

**Progress marker protocol**: Place as first line in [Section: Evaluation-Results]:
`*Evaluation in progress — {last completed milestone}*`
Milestones: QA verified, criteria assessed, quality reviewed, patterns finalized, gate passed, accepted.
Step 8A removes the marker when finalizing. Orient C detects it on resumption.

**Resumption after type-file interruption**: When Orient detects a progress marker placed during type file execution (criteria assessed, quality reviewed), Router reloads the type file. Resume at the specific substep indicated in continue_with. Type files are not persisted across conversations — reload is mandatory.

[/Section: Checkpoint-Reference]

---

## End-of-Workflow Checklist
[Section: End-of-Workflow-Checklist]

MANDATORY before closure. Run after Step 8 (Documentation & Learning) completes.

```
Core (all issues):
- [ ] ISS Evaluation-Results written and verified on disk
- [ ] Progress markers removed from ISS
- [ ] QA Verification completed (tier documented)
- [ ] Criteria Assessment completed (met/total documented)
- [ ] Quality Review completed (dimensions assessed)
- [ ] Evaluation score calculated (4 or 5)
- [ ] Two-place score update: registry + sprint-state [OBJECTIVES]
- [ ] Sprint-state continue_with set with closure/post-closure context
- [ ] Nyquist Audit completed per §DE Layer §8 (concise closure-gate adversarial scan; per-axis FILLED / ESCALATED / SKIP)
- [ ] Context zone checked — checkpoint if crossing boundary

Conditional additions:
- [ ] Pattern Finalization completed — all patterns have final outcomes (if patterns used)
- [ ] Constitution compliance verified (if constitution exists)
- [ ] Adversarial review passed — HIGH findings resolved (if C:3+)
- [ ] Documentation impact checked — stale guides noted (if system files modified)
- [ ] Technical debt tracked — follow-up issues created (if significant debt found)
```

If any item fails: fix before proceeding to Step 9. Do not close with incomplete checklist.

[/Section: End-of-Workflow-Checklist]

---

## Step Display Guidance

Vary presentation naturally. Spirits to channel, not scripts to repeat:

| Step | Spirit | Style |
|---|---|---|
| Orient | Preparation — understanding the handoff | Brief, factual — context summary |
| QA Verification | Thoroughness — confirming everything works | Structured results — pass/fail per item |
| Criteria | Accountability — checking against goals | Checklist — criterion-by-criterion |
| Quality Review | Honest judgment — assessing craftsmanship | Analytical — evidence-based assessment |
| Pattern Finalization | Reflection — what helped, what didn't | Conversational — narrative outcomes |
| Quality Gate | Decision — making the call | Formal — verdict with rationale |
| User Acceptance | Invitation — seeking satisfaction | Collaborative — open-ended feedback |
| Documentation | Wisdom — capturing what was learned | Concise — distilled insights |
| Closure | Accomplishment — completing the cycle | Celebratory — summary with momentum |
