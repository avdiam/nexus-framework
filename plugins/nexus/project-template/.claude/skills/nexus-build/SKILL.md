---
name: nexus-build
description: NEXUS Build methodology — structured implementation. 3-load architecture (C:1-2 inline, C:3+ loads complex.md + type file).
disable-model-invocation: true
---
*Version: 3.2.0 | Date: 2026-08-19 | Sprint: 108*

# NEXUS Build Methodology

Executing Implementation phase for **$ARGUMENTS[0]** (complexity: **$ARGUMENTS[1]**).

**Flow**: Orient → [C:1-2: Simple Path | C:3+: Router → complex.md + type file → §POST-TYPE] → End-of-Workflow-Checklist → Commit → Transition

---

## Operational Reminders

**Always active while this skill executes:**

- **Memory-First**: Check active context before any read. Re-reading loaded files is a violation.
- **Verify-after-write**: Confirm changes on disk after every edit/patch/write. Unverified writes are violations.
- **Consent**: Follow gate annotations (**[T1]**/**[T2]**/**[T3]**) per active control level. Every gate presents LLM recommendation — even T1.
- **Routing discipline**: Use appropriate skills — /nexus-match-pattern for pattern matching, /nexus-loop-back for phase rollback, /nexus-decompose-issue for decomposition. Batch execution is handled internally via [Section: Batch-Transition-Detection] + batch.md. Do not improvise these workflows.

### Reference Loading Conditions

| Trigger | Load from references/implementation-reference.md |
|---|---|
| Creating/modifying LLM behavior files | [Section: LLM-Behavioral-Programming] |
| Writing or modifying code | [Section: Code-Creation-Rules] |
| Multi-file changes with producers+consumers | [Section: Atomic-Implementation] |
| Creating/modifying/removing NEXUS system files | [Section: NEXUS-Framework-Standards] |

### Implementation Phase Protocols (always active)

File operations — choose verification depth based on context:

| Depth | When | Action |
|---|---|---|
| Minimal | Simple change, high confidence | verify_file only |
| Targeted | Need to find match, medium confidence | search with context |
| Section | Complex structure, surrounding context needed | read_file with markers |
| Comprehensive | Critical file, major change | Full read + analysis |

File criticality minimums: CRITICAL files (registries, methodology) → section depth minimum. IMPORTANT files (operations, states) → targeted. STANDARD files (issues, patterns) → minimal.

Routine decisions: Follow existing patterns, note the choice. Reserve questions for scope/architecture/behavior decisions. This keeps implementation momentum.

Pattern tracking: Display 📐 when applying pattern guidance. Record outcomes in ISS ### Pattern Outcomes. If deviating from a pattern: `📐 PAT-XXX deviation: {what changed} — {reason}`. Effectiveness score updates happen at closure, not during build.

Atomic implementation: After each change, system must be in working state. Producers before consumers. After modifying a producer: verify at least one consumer still works.

---

## Type Adaptations Summary

| Dimension | Standard (Feature/Improvement/Refactor/Doc/Question) | Bug | Creative |
|---|---|---|---|
| Unit of work | Implementation phase (multi-file) | Fix phase (root-cause targeted) | Content section (draft) |
| Verification approach | Per-file verification + phase tests | Reproduction scenario check per file | Coherence + audience-fit review |
| Progress tracking | Phase N / Step X / Progress % | Reproduction status per fix step | Draft N, done/total sections |
| Pause points | After each phase [T3] | After each fix phase [T3] | Every 2-3 sections [T3] |
| Quality gate | Tests passing, criteria met | Bug gone + regression clear | Audience-fit + coherence |
| Batch Transition trigger | 2+ repetitive phases | Rarely fires (fixes are unique) | 3+ sections with repeating template |
| Implementation style | Plan → execute → verify per file | Reproduce → fix root cause → verify gone | Draft → review → refine per section |
| Deliverable location | Modified project files | Modified project files | `sprints/XXX/` for standalone artifacts, or target location if specified |
| Checkpoint focus | Files modified, tests passing | Reproduction status, fix progress | Current draft version, refinement status, open feedback items |

**Inline callout types** (use types/default.md): See **Refactor:** and **Documentation:** callout boxes in types/default.md for step-level adjustments within the default execution flow.

---

## Cognitive Tools for Build

| Tool | When During Build | Typical Step |
|---|---|---|
| Mental Simulation | Walk through changes as fresh instance | Quality Review (mandatory C:3+) |
| Adversarial Review | Validate implementation completeness | Quality Review (mandatory C:3+) |
| Systems Thinking | Cascading effects across many modified files | Post-implementation if >5 files |
| Blind Spot Check | High confidence in implementation, deviations present | Post-implementation elicitation |
| Root Cause Analysis | Test failures with unclear cause | Test execution failure debugging |
| Inversion | Implementation went too smoothly | Post-implementation elicitation |

---

## Orient (Phase 1 — always runs, silent)

Silent — no display to user until complexity assessment (Step F). Load context, detect resumption, verify readiness.

**Task-tracking (ISS-199)**: on entry, create a coarse phase-level task list per CLAUDE.md [Section: Phase-Management-Protocol] → *Methodology Task-Tracking Convention* (one entry per phase of this skill — e.g. Orient → §PRE-TYPE → Phase 1..N → §POST-TYPE → Commit/Transition); `TaskUpdate` at each phase boundary; honor user opt-out.

### A — Memory Check

Recite all files currently in active context. Avoid wasteful reloads.

### B — Load Issue Context

ISS-XXX.md if not in memory. Extract:
- Solution-Design: approach, tools/patterns chosen, files affected, risks
- Implementation-Plan: phases, steps, sequence, status column
- Success Criteria: for test strategy definition

### B.1 — Phase-Entry Briefing (fresh-session only)

**Fresh-session entry**: Display this briefing only on fresh-session entry. Fresh-session = this methodology was NOT invoked as a phase Transition from a different phase methodology earlier in THIS conversation for the SAME ISS-XXX. Same-session phase transitions (typically /nexus-analyze → /nexus-build within one conversation) skip the briefing — continuity context already covers it.

**Detection**: Introspect conversation history at this step. If a prior phase methodology emitted a Transition handoff to /nexus-build for THIS SAME ISS-XXX earlier in this conversation, this is same-session → skip to §C Resumption Detection. Otherwise → fire the briefing below. The Transition handoff is the methodology's phase-complete display block — examples include "✅ Phase Transition Complete / Analysis → Implementation", or the loop-back dispatch from /nexus-validate via /nexus-loop-back. Match the *semantic* signal (prior phase handed off to this skill for this ISS this conversation), not a single literal string.

**Render**:

> 📋 ISS-{XXX} — {title}
> Type: {type} | Created: {YYYY-MM-DD} | Complexity: {N}
>
> Origin: {Notes & Context ### Origin distilled to 1-2 sentences | "not recorded"}
>
> Problem: {first paragraph of ## Description, distilled to 1-2 sentences}
>
> Approach (from Analysis): {one-line distillation of Solution-Design ### Approach}
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

(This briefing replaces the prior `📋 Implementation Context Loaded` LLM-confirms block — the user-anchored summary supersedes the prior internal-confirm display, which was redundant with what the methodology already had in active context.)

### C — Resumption Detection

Read ISS [Section: Implementation-Log] content.

| Condition | Action |
|---|---|
| continue_with references "Loop-back to implementation" | Loop-back arrival — show loop reason and evaluation findings. Ask: "What needs fixing?" Start from plan-verify or implement based on scope. |
| `_build_mode: batch` in sprint-state | **Batch resumption** — load `${CLAUDE_SKILL_DIR}/batch.md` (1 load). Execute Batch Orient. Do NOT load complex.md or type file yet — batch.md handles its own flow and loads complex.md for §POST-TYPE when batch completes. |
| continue_with references "Apply fallback — target X" | Batch fallback arrival — display target and novel problem. Set `_build_mode: full`. Work on that target only via normal Build path. After resolving, offer: "Re-enter batch mode?" If yes: set `_build_mode: batch`, load batch.md, resume loop. |
| Progress marker found | Display summary. Reload patterns/tools from continue_with. Resume at indicated step. |
| Complete content, no marker, no special continue_with | All implementation done — verify and proceed to transition. |
| Placeholder only, continue_with references Build step | Resume that step (mid-Build checkpoint recovery). |
| Placeholder only, continue_with references "Implement..." | Fresh start from Analysis handoff. |
| Placeholder only, no continue_with context | Fresh start. |

**If any resumption condition matches (batch, fallback, loop-back, or progress marker): remaining Orient steps (D–F) are skipped.** These steps apply only to fresh starts or Analysis handoffs.

### D — Test Strategy

Define tests BEFORE implementing — tests define what success looks like.

Simple (C:1-2): 2-3 key validation tests from Success Criteria.
Complex (C:3+): map tests to implementation phases. Plan when created (during type file) and executed (§POST-TYPE).

> 📝 Test Strategy
> Tests: {list or phase-mapped}
> Approach: {manual/automated/hybrid}

### E — Preflight

**E1 — File verification**: confirm files from Solution-Design ### Files Affected exist.
**E2 — Dependency check**: required libraries, tools, templates available.
**E3 — Context artifacts** (conditional): if `.nexus/supporting-files/project-context/` exists:
  - CONVENTIONS.md → read relevant sections, note conventions to follow
  - STRUCTURE.md → read Overview, understand file placement
**E4 — Standards check**: scan plan against reference loading conditions table. Flag which reference sections apply. Display: "Standards applicable: {list}"
**E5 — Blockers**: review ISS Risks & Mitigations. Check if any materialized.

> ✅ Pre-Flight Complete
> • Files: ✓ / ⚠️ {issues}
> • Standards flagged: {list}
> • Blockers: ✓ None / ⚠️ {issues}

### F — Complexity Assessment + Path Decision

| Complexity | Path |
|---|---|
| 1–2 | → [Section: Simple-Path] |
| 3+ | → [Section: Router] |

> **Mental note**: Context loaded. Type: {type}. Resuming at: {step or "Simple/Complex Path"}.
> Standards flagged: {list}. If checkpoint fires → continue_with only (no ISS write yet).

---

## Simple Path (C:1-2)
[Section: Simple-Path]

Complete inline implementation for simple issues. Zero external file loads. Both standard and creative types handled with type-aware inline adjustments.

**Before step execution**: Run [Section: Completeness-Checks] sub-check A — Touchpoint Census (or record the mandatory suppression line if not triggered).

**Standard types** (Feature/Improvement/Refactor/Documentation/Bug/Question):

Execute all steps in sequence. Per step:
```
🔨 Step N: {description}
• Files: {modified}
• Changes: {what changed}
• Verification: {outcome} ✓
```

After all steps: run tests (inline), progress-doc (inline).

**Bug type inline adjustment** (simple C:1-2 bugs):
- Reproduce first: confirm you can trigger the bug before touching anything
- Fix: apply the fix
- Verify: confirm reproduction scenario no longer triggers
- Regression: quick check that adjacent functionality still works

**Refactor inline adjustment**: System must pass existing tests after EACH file touched. Capture baseline metrics before first file (complexity/coupling notes). Track before/after.

**Documentation inline adjustment**: Unit = section. Verify accuracy against source after each section (does doc match actual behavior?).

**Creative type** (simple C:1-2): Direct production from brief. Single mid-process steering check. Brief alignment check at end vs creative brief.

**Scope Reality Check** (after first implementation step): Evaluate whether the actual issue complexity and scope match what was planned. If the work reveals broader impact than C:1-2 anticipated (more files affected, unexpected dependencies, design decisions needed), surface to user: "Scope appears broader than planned. Options: [Escalate to complex path / Invoke Scope-Escalation-Check / Continue as-is]."

After all steps:
- Run [Section: Completeness-Checks] sub-check B — Relocation-Citation Resolution (for any relocate-with-citation edits made this issue; skip silently if none)
- Run [Section: End-of-Workflow-Checklist]
- Execute [Section: Commit-Protocol] **[T3: Full ask | Balanced: notify | Streamlined: auto-write]**
- Execute [Section: Transition] **[T3 smart logic]**

[/Section: Simple-Path]

---

## Router (C:3+)
[Section: Router]

Orient determined complexity ≥ 3. Load the thinking toolkit and type-specific workflow together.

### Load Sequence

Read both files (2 loads total — no further loads after this):

1. `${CLAUDE_SKILL_DIR}/complex.md` — thinking toolkit (§PRE-TYPE + §POST-TYPE)
2. `${CLAUDE_SKILL_DIR}/types/{type}.md` — type-specific implementation

**Type mapping:**

| Issue Type | File |
|---|---|
| Feature, Improvement, Refactor, Documentation, Question | types/default.md |
| Bug | types/bug.md |
| Creative | types/creative.md |
| Research | Does not reach Build — Analysis routes to /nexus-research |

### Execution Sequence

After loading both files, execute in this order:

**Analysis-Lock Check** (run before step 1): Detect whether §PRE-TYPE can be compressed.

Analysis-locked = BOTH of the following visible in this conversation's history:
- A 🚦 Readiness Gate: PASS block for THIS ISS (Analysis completed with PASS verdict this conversation)
- A "✅ Phase Transition Complete / Analysis → Implementation" handoff for THIS ISS this conversation

If Analysis-locked → skip step 1. Display:
> ⚡ §PRE-TYPE compressed — Analysis-locked: pattern matching and plan verification completed this conversation.
> Proceeding directly to implementation.
Then continue from step 2.

If fresh-session (no Analysis handoff in this conversation for this ISS) → execute step 1 normally.

**Fresh-session always re-runs both gates**: registry [PATTERNS_IN_USE] populated ≠ Analysis-locked. Fast-pass requires in-conversation evidence only.

1. complex.md §PRE-TYPE: Pattern Matching **[T2]** → Plan Verification **[T2]**
2. ⏸️ PAUSE anchor in complex.md — execute type file §1 Implementation
3. Type file: execute all phases → "Return to complex.md §POST-TYPE"
4. complex.md §POST-TYPE: Test Execution → Drift Detection **[T2]** → Deferral-Target Validity **[T3]** → Pattern Assessment **[T3]** → Quality Review [A-H] **[T3 smart / T2 escalation on HIGH]**
5. Return to SKILL.md: [Section: End-of-Workflow-Checklist] → [Section: Commit-Protocol] → [Section: Transition] **[T3 smart logic]**

*(Batch-Transition-Detection is NOT re-run after §POST-TYPE — type file already ran it during the implementation loop. By §POST-TYPE, all implementation is complete.)*

### Zone Checks

After each major phase boundary (§PRE-TYPE done, type file phase done, §POST-TYPE done): apply the Green/Yellow/Red zone actions per CLAUDE.md [Section: Memory-Context-Management] → Context Zones.

[/Section: Router]

---

## Batch-Transition-Detection
[Section: Batch-Transition-Detection]

Invoked by type files (C:3+) during the implementation loop after 2+ repetitive targets. Not used in Simple Path — C:1-2 issues rarely have enough targets to justify batch mode. Does NOT run after §POST-TYPE — by that point all implementation is done, there are no remaining targets to hand to batch mode.

### Signal Detection (all must be present)

| Signal | Meaning |
|---|---|
| Same procedure applied to 2+ implementation targets (files, sections, or phases) | Playbook is established |
| Remaining targets follow the same pattern | Repetitive execution ahead |
| No novel design decisions expected for remaining targets | Build methodology is overhead |

If all signals present AND implementation score ≥ 2:

**Step 1 — Formalize Playbook**: Extract repeating procedure into ISS Implementation-Log:
```
### Playbook
Proven on: {targets completed so far}
Steps:
1. {step with expected inputs/outputs}
2. {step}
...
Remaining targets: {list from Implementation-Plan}
```

**Step 2 — Present playbook to user for review and approval** **[T2: Balanced+Full ask | Streamlined: auto-present if playbook solid, notify]**:
> 📐 Repetitive execution pattern detected.
> Playbook proven on {N} targets.
> {playbook summary}
> Remaining targets: {list}
> Switch to batch mode? [Y / Continue with Build / Adjust playbook]

**Step 3 — On approval**: Initialize batch tracking table in ISS Implementation-Log:
```
### Batch Progress
| # | Target | Status | Conv | Notes |
|---|--------|--------|------|-------|
| 1 | {completed} | ✅ | Conv N | Playbook source |
| 2 | {completed} | ✅ | Conv N | Confirmed pattern |
| 3 | {next} | ⬜ | — | — |
Progress: N/total | Next: {target}
```

**Step 4**: Set `_build_mode: batch` in sprint-state metadata. Checkpoint with batch-focused continue_with:
```
WHAT: Batch playbook for ISS-XXX — N/total complete
NEXT TARGET: {name}
PLAYBOOK: {1-line summary}
```

**Step 5**: Load `${CLAUDE_SKILL_DIR}/batch.md` (1 load). Execute Batch Orient → Execution Loop.

After batch completes: batch.md signals return to SKILL.md. Load complex.md for §POST-TYPE if not in context. Continue normal flow: §POST-TYPE → End-of-Workflow-Checklist → Commit Protocol (clears `_build_mode`) → Transition.

**On decline**: Continue with Build normally. Check again after each subsequent phase.

**Batch → Build fallback** (handled in Orient C resumption detection):
When batch.md escalates a target and user picks "Escalate to full Build", `_build_mode` is set to `full`, and Build's Orient gets continue_with: "Apply fallback — target X: {novel problem}." Orient surfaces the context, works on that target only, then offers to re-enter batch mode.

[/Section: Batch-Transition-Detection]

---

## Scope-Escalation-Check
[Section: Scope-Escalation-Check]

Logic lives here once. Type files trigger this section by reference after each phase.

### Trigger (type file calls this after each phase completion — complex path only)

| Signal | Detection |
|---|---|
| More files than planned | Files modified > Files Affected count in Solution Design |
| New dependencies appeared | Unplanned cross-file changes or prerequisite work needed |
| Phase took longer than estimated | Conversation count exceeds phase estimate |

If 2+ signals: additionally scan [Section: Decompose-Signals] in CLAUDE.md.

> ⚠️ Scope escalation detected
> • {signal_1}: {evidence}
> Decompose signals: {strong/medium/none}
>
> Options: [Continue as-is / Re-scope remaining phases / Split into follow-up issue /
>           Decompose issue (if medium/strong signals) / Switch to batch mode (if repetitive)]

Wait for user decision **[T2: Balanced+Full ask | Streamlined: auto-select best option, notify]**. On re-scope: adjust Implementation-Plan, document deviation. On split: create follow-up via /nexus-create-issue, trim current plan, document in Deviations.

**Bug-type additional signal**: "Root cause is elsewhere than Analysis concluded" → this is a loop-back signal, not just scope escalation. Surface separately: "Root cause appears to be in {different area}. Loop back to Analysis? [Y/n]"

**Creative-type adapted signals**: Brief growing beyond original scope / new deliverables emerging / sections substantially deeper than estimated.

[/Section: Scope-Escalation-Check]

---

## Completeness Checks
[Section: Completeness-Checks]

Single-source home for two touchpoint-completeness sub-checks, called by reference from both complexity paths — [Section: Simple-Path] (C:1-2, before/after step execution) and `complex.md` §PRE-TYPE/§POST-TYPE (C:3+). Origin: ISS-230 — four historical reproductions (ISS-203 F1, ISS-202 L1108, ISS-213 Conv 8, ISS-216 Conv 6) where a completeness fix stopped short of every internal surface it should have touched, always caught at Validate instead of here.

### A — Touchpoint Census (pre-execution)

**Trigger** (any one fires the check):

| Signal | Detection |
|---|---|
| Multi-file change | Solution-Design Files Affected lists ≥2 files |
| Multi-section change | A single file's plan touches ≥2 distinct sections |
| SC-named glob | A Success Criterion names an explicit file-class glob or enumeration |
| Named-token add/rename/retire | The change adds, renames, or retires a concept/token referenced elsewhere in the codebase |

**Suppression** (mandatory when NOT triggered): record one line — `Touchpoint census: N/A — {reason, e.g. "single file, single section, no named-token change"}`. Silent skip is not permitted; an unconsidered census is indistinguishable from a skipped one.

**Procedure** (run when triggered):

1. **Enumerate the surface-set** — list every file/section the plan currently names as affected.
2. **Derive predicate vocabulary** — the concept name, its variants, and the concept's **container term** (the broader category the concept belongs to — e.g. for a renamed field, both the field name and "registry field" as container).
3. **Run the predicate over the whole file-class** — grep the vocabulary across the file-class the change belongs to (not just the enumerated surface-set from step 1). Enumeration is the artifact that failed in all four historical reproductions; a predicate run over the class is the completeness authority.

   **Choosing the class** — the one place this check can be quietly defeated: an under-scoped class returns a clean predicate over the wrong ground, and reads exactly like a pass.
   - The class is the unit that **owns the concept**, not the set of files you planned to edit. It must contain every file listed in step 1 — if step 1 spans two skill folders, one skill folder is not the class.
   - Default units: one skill's whole folder (`SKILL.md` + `complex.md` + `batch.md` + `types/*` + `references/*`) for a skill-local concept · `.claude/skills/**/*.md` for a cross-skill convention · plus the non-skill classes (hooks, supporting-files/architecture, Emergency-Reference, templates) when the token is known to recur outside skill files.
   - **When a Success Criterion names a glob, that glob IS the class — run it verbatim; do not re-derive or narrow it.**
   - When in doubt, widen. A class one level too broad costs a few extra hits to reconcile; one level too narrow costs the check its entire purpose.

   Same discipline as `nexus-analyze` [Section: Cross-Cutting-Checklist] (`references/scope-investigation.md`), which fixes four non-skill classes at Analysis — restated inline here because Simple Path loads no external files, not because it is a second authority.
4. **Reconcile every hit** — for each hit outside the enumerated surface-set, add it to the plan or explicitly justify its exclusion.
5. **Record evidence** — literal command + hit count, **per term × class**, including zero-hit combinations. Every term derived at step 2 runs against every class chosen at step 3: the declared vocabulary is a **contract**, and a per-class-only evidence line cannot reveal that a declared term was never run. Name the class boundary chosen and why — an eyeballed class classification does not satisfy this step.

   Origin: ISS-233 Conv 8 (Sprint 108) — a census declared `discoveries.jsonl` in its vocabulary and ran only the `seed` token against the CLAUDE.md class. The per-class evidence line read clean, and the two surfaces the dropped term owned surfaced a phase later at Validate. Class-choice is step 3's job; **term-coverage is this step's**.

**Output**:
> 🔍 Touchpoint Census
> Vocabulary: {concept + variants + container term}
> Term × Class: {term} × {file-class} — Command: `{literal grep}` — Hits: {N}
>   ↳ one row per term per class — zero-hit rows included, never collapsed
> Reconciled: {all in-plan / N added / N excluded with reason}

📐 Carriers: PAT-098 (Grep-Before-Rename), PAT-121 (Match Remedy Form to Failure Cause), PAT-113 (Canonical-Pointer Pattern).

### B — Relocation-Citation Resolution (post-edit)

For each **relocate-with-citation** disposition (content moved to another file, cited by a specific sub-anchor): grep the **literal cited sub-anchor** in the target file and require ≥1 hit. Confirming the target *file* exists without confirming the sub-anchor resolves is an explicit **fail**, not a pass — this is precisely the gap ISS-216 Conv 6 exposed (target file existed; cited sub-anchor "Phase 4 Part I.9" did not).

Pre-commit target verification (does the target file exist and look correct before the move) is PAT-124's job — this check does not duplicate it. This check runs **after** the edit, confirming the citation resolves in the file as actually written.

**Output**:
> 🔗 Relocation-Citation Check
> Target: {file} — Cited anchor: `{literal text}` — Command: `{literal grep}` — Hits: {N}
> Verdict: {resolved / FAIL — file exists but anchor does not resolve}

**Call sites**: C:1-2 → [Section: Simple-Path] runs A before step execution, B after. C:3+ → `complex.md` §PRE-TYPE Plan Verification C calls A; §POST-TYPE calls B; Deferral-Target Validity carries a one-line pointer here rather than a duplicated check.

[/Section: Completeness-Checks]

---

## Commit Protocol
[Section: Commit-Protocol]

**[T3: Full ask | Balanced: notify | Streamlined: auto-write]**

### A — Write/Update Implementation-Log

Ensure all subsections are current:

| Subsection | Content |
|---|---|
| ### Status | Final progress snapshot |
| ### Changes Made | Complete audit trail (file / change / conv) |
| ### Tests Created | All tests with execution results |
| ### Deviations | All plan changes with reasons |
| ### Pattern Outcomes | Evidence for each applied pattern |
| ### Technical Decisions | Implementation-time choices and rationale |
| ### Issues Encountered | Problems and resolutions |

Remove any progress markers. Verify on disk (MANDATORY).

### B — Update Implementation-Plan Status

All completed steps ⬜ → ✅.

### C — Update continue_with

```
WHAT: Evaluate ISS-XXX — implementation complete
WHY: {key insight from build}
PLAN: ISS-XXX.md [Section: Evaluation-Results]
FIRST: Load /nexus-validate
```

### D — Update Patterns in Use

If patterns applied, update sprint-state [PATTERNS_IN_USE].

### E — Clear Build Mode

Set `_build_mode: none` in sprint-state metadata. (Clears both `full` and `batch` states.)

### F — Verify All Writes on Disk

MANDATORY: Read back each modified section. Unverified writes are violations.

[/Section: Commit-Protocol]

---

## Gate Reference
[Section: Gate-Reference]

All gates present LLM recommendation regardless of tier or control level.

| Gate | Tier | Full Control | Balanced | Streamlined |
|---|---|---|---|---|
| Pattern matching offer | T2 | Ask + rec | Ask + rec | Auto-match if C>2 or novel, notify |
| Plan verification approval | T2 | Ask + rec | Ask + rec | Auto-proceed if no gaps, notify |
| Per-phase pause points | T3 | Ask | Notify | Silent |
| Scope escalation decision | T2 | Ask + rec | Ask + rec | Auto-select best option, notify |
| Batch Transition offer | T2 | Ask + rec | Ask + rec | Auto-present if playbook solid, notify |
| Test failure handling | T2 | Ask + rec | Ask + rec | Auto-recommend best option, notify |
| Decision Drift resolution | T2 | Ask + rec | Ask + rec | Auto-realign if clear, notify |
| Self-eval HIGH findings | T2 (escalated) | Ask + rec | Ask + rec | Ask + rec (always surface HIGH) |
| Self-eval MED findings | T3 smart | Ask | Notify + auto-rec | Auto-resolve, log [AUTO] |
| Self-eval LOW findings | T3 smart | Ask | Notify | Silent, note in ISS |
| Loop-back proposal | T2 | Ask + rec | Ask + rec | Ask + rec (significant) |
| Phase Transition | T3 smart | Ask (audit) | Notify action taken | Silent: checklist → checkpoint → load |

**Note on T1 in Build**: No T1 gates exist in the methodology steps themselves. However, if a specific Build execution involves large-scale irreversible or hard-to-restore changes (e.g., a 50-file codebase refactor), the skill executing that work may annotate it as T1 at the plan approval step. The methodology does not mandate this — it is a judgment call at annotation time.

[/Section: Gate-Reference]

---

## Checkpoint Reference
[Section: Checkpoint-Reference]

When [Section: Checkpoint-Protocol] fires during build, persist based on progress:

| After | Persist | Where |
|---|---|---|
| Orient A–F | Context, test strategy, preflight, standards flagged | continue_with only |
| §PRE-TYPE: Patterns | Pattern decisions | continue_with |
| §PRE-TYPE: Plan Verification | Verified plan, adjustments | continue_with |
| Type file: mid-phase | Partial phase progress, changes made, tests created | ISS with progress marker + checkpoint |
| Type file: phase complete | Full phase record | ISS already updated (type file step B) |
| §POST-TYPE: Test Execution | Test results | ISS ### Tests Created (executed column) |
| §POST-TYPE: Drift Detection | Alignment status or drift resolution | continue_with |
| §POST-TYPE: Deferral Validity | Dangling-deferral warnings or clean pass | continue_with |
| §POST-TYPE: Quality Review | Results, findings | continue_with |
| Commit done | Already on disk | Verify only |
| Transition done | Scores updated | Verify only |
| Batch: mid-loop | Batch Progress table, current target | ISS ### Batch Progress + continue_with (with `_build_mode: batch`) |
| Batch: complete | All targets done | ISS ### Batch Progress (verified), then §POST-TYPE follows |

**Progress marker protocol**: Place as first line in [Section: Implementation-Log]:
`*Implementation in progress — {last completed milestone}*`
Commit Protocol removes it. Orient C detects it on resumption.

**Resumption after complex-path interruption** (MANDATORY): When Orient detects a resumption mid-complex-path (marker found, or continue_with references a §PRE-TYPE / §POST-TYPE step), ALWAYS route through [Section: Router] in SKILL.md. Router reloads both complex.md + type file unconditionally. Do NOT attempt to re-enter complex.md or type file directly without reloading — they were not persisted across conversations. Resume at the specific sub-step indicated in continue_with after files are loaded.

[/Section: Checkpoint-Reference]

---

## End-of-Workflow Checklist
[Section: End-of-Workflow-Checklist]

MANDATORY before phase transition. Run after §POST-TYPE completes (C:3+) or after all simple path steps complete (C:1-2).

```
Core (all issues):
- [ ] ISS Implementation-Log written and verified on disk
- [ ] ISS Implementation-Plan status updated (completed steps ✅)
- [ ] Progress markers removed from ISS
- [ ] All tests defined in test strategy have been executed
- [ ] Test failures documented (or all passing)
- [ ] Implementation score calculated (4 or 5)
- [ ] Two-place score update: registry + sprint-state [OBJECTIVES]
- [ ] Sprint-state continue_with set with evaluation context
- [ ] Standards compliance verified (all preflight-flagged standards followed)
- [ ] Version headers bumped on all modified system files (per CLAUDE.md File-Operations-Protocol Version Protocol — Major for structural SKILL.md/complex.md section add/remove, Minor for content/rule changes, Patch for cosmetic)
- [ ] Context zone checked — checkpoint if crossing boundary
- [ ] Touchpoint census evidence recorded, or suppression line recorded if not triggered ([Section: Completeness-Checks] sub-check A)
- [ ] Relocation citations resolved for any relocate-with-citation edits, or none made this issue ([Section: Completeness-Checks] sub-check B)

C:3+ additions:
- [ ] Pattern Assessment completed (outcomes in ISS + sprint-state if patterns applied)
- [ ] Decision Drift check completed (realigned or deviation documented)
- [ ] Deferral-Target Validity check ran (dangling-deferral warnings surfaced, or clean pass)
- [ ] Git diff ran before adversarial review
- [ ] Adversarial review passed (all HIGH findings resolved or explicitly documented)
- [ ] Findings resolution completed (Walk / Fix-downstream / Source-fix / Skip per finding)
- [ ] Independent agent review offered if C:4+ structural (dispatched, skipped, or env N/A)
- [ ] If agent ran: unified findings presented and resolved
- [ ] Batch Transition Detection ran during implementation loop (switched to batch, or consciously declined — triggered from type file, not from SKILL.md post-§POST-TYPE)
- [ ] If batch mode was used: `_build_mode` cleared to `none` in sprint-state
- [ ] Post-implementation elicitation offered (applied or declined)
```

If any item fails: fix before transitioning. Do not proceed with incomplete checklist.

[/Section: End-of-Workflow-Checklist]

---

## Transition
[Section: Transition]

Run after End-of-Workflow-Checklist passes.

**[T3 smart logic]**

### Readiness Checklist

Aggregate implementation results with per-criterion verdict:

| Criterion | Threshold | Actual | Verdict |
|---|---|---|---|
| Planned changes | All implemented | {done}/{total} | PASS / CONCERNS / FAIL |
| Tests | Created and executed | {pass}/{total} | PASS / CONCERNS / FAIL |
| Implementation-Log | Current on disk | {yes/no} | PASS / FAIL |
| Quality Review (C:3+) | Passed | {result} | PASS / CONCERNS / FAIL / N/A |
| Standards compliance | Preflight standards followed | {result} | PASS / CONCERNS / FAIL |

### Readiness Verdict

| Verdict | Condition | Action |
|---|---|---|
| **PASS** | All criteria PASS | Transition to evaluation. Score: 4 or 5. |
| **CONCERNS** | No FAIL verdicts, but one or more CONCERNS | Document gaps in `continue_with`. Transition to evaluation with gaps visible — let Validate assess whether they matter. Score: 4. |
| **FAIL** | Any criterion has FAIL verdict | Recovery path required — do not transition. |

**CONCERNS guidance**: Implementation gaps that don't block evaluation. Examples: a test covers the happy path but not edge cases, a planned step was simplified, documentation is thin. The gap is real but Validate can assess its impact. Document what's incomplete and why.

**Score Calculation:**

4 = implemented, tests passing, minor gaps acceptable.
5 = fully implemented, comprehensive validation, no gaps.

### If FAIL — Explicit Recovery Path

Do NOT transition. Gaps remain. Both complex.md and type file are still in memory — no reload needed. Re-enter the type file at the relevant phase/step to address gaps:
- Specific phase failed: return to type file §1, resume at that phase
- Tests failing: return to type file §1 for affected files, then re-run §POST-TYPE Test Execution
- Adversarial review surfaced major issues: return to type file §1 for affected files

After addressing gaps: re-run §POST-TYPE from Test Execution onward, re-run checklist, recalculate score.

### Smart Logic Execution by Control Level

| Level | Behavior |
|---|---|
| Full Control | Display full transition summary, wait for explicit approval |
| Balanced | Display summary + "Transitioning to evaluation...", proceed after brief pause |
| Streamlined | Silent: verify checklist → two-place score update → set focus → load /nexus-validate |

### Transition Summary (Full + Balanced)

```
📊 Implementation Phase Complete
• Score: {4 or 5}/5
• Phases completed: {count}
• Files modified: {count}
• Tests: {passing}/{total} passing
• Patterns applied: {list with outcomes}
• Deviations: {count} documented

[Transitioning to Evaluation — /nexus-validate]
```

**Two-place score update** → issues-registry.yaml (ISS-XXX.implemented = {score}) + sprint-state.md [OBJECTIVES] (I:{score})

**On decline** (Full Control only): ask what needs attention. Loop-back offer if approach needs rethinking → invoke /nexus-loop-back.

**User override**: If user says "evaluate now" with score < 4, warn that implementation gaps remain but proceed if insisted.

[/Section: Transition]

---

## Step Display Guidance

Vary presentation naturally. Spirits to channel and styles to render in — not scripts to repeat. Spirit captures the *attitude* you bring; Style captures the *form* and *cadence* of the output.

| Phase | Spirit | Style |
|---|---|---|
| Orient | Preparation — confirm understanding | Silent until preflight complete; display readiness summary |
| Implement | Progress — showing work happening | Per-file: show change + verify; mark steps ✓/❌; surface friction immediately |
| Test | Confidence — verifying quality | Test results with evidence; criteria checklist; findings with severity |
| Transition | Accomplishment — proposing next phase | Brief summary; two-place score update; clean handoff |
