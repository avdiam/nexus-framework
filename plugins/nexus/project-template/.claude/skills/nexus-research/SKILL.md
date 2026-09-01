---
name: nexus-research
description: NEXUS Research methodology — systematic knowledge production. 4-file architecture (SKILL.md + 3 mode files). No simple path — Research is always full power.
disable-model-invocation: true
---
*Version: 2.10.1 | Date: 2026-08-20 | Sprint: 110*

# NEXUS Research Methodology

Executing Research phase for **$ARGUMENTS[0]** (complexity: **$ARGUMENTS[1]**).

**Flow**: Orient → Router (load mode file) → Step 1: Scoping → Mode Steps 2-6 → End-of-Workflow-Checklist → Commit Protocol → Transition

---

## Operational Reminders

**Always active while this skill executes:**

- **Memory-First**: Check active context before any read. Re-reading loaded files is a violation.
- **Verify-after-write**: Confirm changes on disk after every edit/write. Unverified writes are violations.
- **Consent**: Follow gate annotations (**[T1]**/**[T2]**/**[T3]**) per active control level. Every gate presents LLM recommendation — even T1.
- **Routing discipline**: Use appropriate skills — /nexus-match-pattern for pattern matching, /nexus-create-issue for issue creation from findings, /nexus-close-issue for closure.
- **📐 Pattern deviations**: If deviating from a pattern: `📐 PAT-XXX deviation: {what changed} — {reason}`.
- **Project-agnostic language**: "Current project approach" means whatever the active project uses — not NEXUS specifically. This methodology serves any project.
- **Zone checks**: Check context usage after every step. Research is token-heavy — web searches, agent results, and source content accumulate fast. In estimated mode, tracking is imprecise — err toward earlier checkpoints.

### Research Phase Protocols (always active)

- **Source quality triage is ongoing**: Categorize every source encountered per [Section: Source-Quality]. Not just at Survey — apply throughout Investigation and Analysis.
- **Bias checking is ongoing**: Check for confirmation, anchoring, authority, availability, framing biases at every quality checkpoint. Not a one-time check — revisit as findings accumulate.
- **Evidence attribution is mandatory**: Every claim in findings, analysis, and deliverable must have a source reference. Unsourced claims are violations.
- **Zone awareness is heightened**: Web content is unpredictable in size. Agent results vary. Research button returns can be large. Check zone after every step, not just at major boundaries.

---

## Research Modes Summary

| Dimension | Adoption | Comparative | Exploratory |
|---|---|---|---|
| Core question | Should we adopt X? | How do X, Y, Z compare? | What do we know about X? |
| Investigation shape | 2-track (candidate + current) | N-track symmetric (1 per subject) | Thread-following (depth over breadth) |
| Local files? | Yes — audit current codebase | Minimal | Minimal |
| Analysis structure | Criteria evaluation grid | Dimension comparison matrix | Question-answer synthesis |
| Deliverable | Evaluation report + adaptation proposal | Comparison matrix + conclusions | Knowledge report + implications |
| Decision type | Adopt/Adapt/Defer/Skip → spawns issues | Per-question → often informational | Informational or spawn action items |

---

## Cognitive Tools for Research

| Tool | When During Research | Typical Step |
|---|---|---|
| First Principles | Framing research questions from fundamentals | Scoping |
| Hypothesis-Driven | Structuring investigation as testable hypotheses | Survey, Investigation |
| Analogical Reasoning | Finding parallel solutions in other domains | Survey, Investigation |
| Blind Spot Check | Verifying research isn't confirmation-biased | Analysis, Deliverable |
| Decision Trees | Mapping branching research decisions | Decision |
| Probabilistic Thinking | Assessing confidence in findings | Analysis |
| Counterfactual Reasoning | Exploring alternative framings | Analysis |
| Adversarial Review | Challenging deliverable quality | Deliverable (self-eval) |

---

## Research Dispatch

Agent tool available for parallel research:
- **Survey**: Dispatch agents per search axis. Each runs WebSearch/WebFetch, returns structured summary.
- **Investigation**: Mode-specific parallel dispatch (see mode file). Agent results written to Sprint report files.
- **Analysis onward**: Main context only — cross-source synthesis requires full reasoning.

Agent results stay as summaries in main context. Full detail goes to Sprint report files.

---

## Orient (Silent)

No display to user until Scoping. Load context, detect mode, verify readiness.

**Task-tracking (ISS-199)**: on entry, create a coarse phase-level task list per CLAUDE.md [Section: Phase-Management-Protocol] → *Methodology Task-Tracking Convention* (one entry per phase of this skill — e.g. Orient → Scoping → Survey → Investigate → Deliverable → Commit/Transition); `TaskUpdate` at each phase boundary; honor user opt-out.

### A — Load Issue Context

If ISS-XXX.md not in memory, read it. Extract from Research Design (Solution-Design):
- Mode, subjects, research questions
- Evaluation criteria / comparison dimensions
- Source strategy (starting point — Research expands from here)

Extract from Research Plan (Implementation-Plan):
- Phases, milestones, deliverable target

### A.1 — Phase-Entry Briefing (fresh-session only)

**Fresh-session entry**: Display this briefing only on fresh-session entry. Fresh-session = this methodology was NOT invoked as a phase Transition from a different phase methodology earlier in THIS conversation for the SAME ISS-XXX. Same-session phase transitions (typically /nexus-analyze → /nexus-research within one conversation) skip the briefing — continuity context already covers it.

**Detection**: Introspect conversation history at this step. If a prior phase methodology emitted a Transition handoff to /nexus-research for THIS SAME ISS-XXX earlier in this conversation, this is same-session → skip to §B Readiness Check. Otherwise → fire the briefing below. The Transition handoff is the methodology's phase-complete display block — examples include "✅ Phase Transition Complete / Analysis → Research", or equivalent display from /nexus-loop-back. Match the *semantic* signal (prior phase handed off to this skill for this ISS this conversation), not a single literal string.

**Render**:

> 📋 ISS-{XXX} — {title}
> Type: Research | Created: {YYYY-MM-DD} | Complexity: {N}
>
> Origin: {Notes & Context ### Origin distilled to 1-2 sentences | "not recorded"}
>
> Problem: {first paragraph of ## Description, distilled to 1-2 sentences}
>
> Research Design (from Analysis): {mode} mode | subjects: {list} | questions: {count}
>
> Success Criteria ({total}):
> - SC-01: {criterion}
> - SC-02: {criterion}
> ...
>
> Dependencies: Blocked by {list or "none"} | Blocks {list or "none"}
>
> 📄 Full ISS: .nexus/issues/ISS-{XXX}.md

Informational only — no approval gate. Orient continues silently to §B Readiness Check.

### B — Readiness Check

Verify from loaded ISS:
- Mode clear? (Adoption / Comparative / Exploratory)
- Subjects defined?
- Research questions numbered?
- Criteria or dimensions specified? (Adoption/Comparative)
- Source strategy identified?
- Success criteria measurable?

If gaps: stop and ask user. Do not proceed with assumptions on scope-affecting items.

### C — Check Existing Progress

Check ISS [Section: Implementation-Log] content (from memory if loaded).

| Condition | Action |
|---|---|
| continue_with references a mid-research analytical phase (Analysis, Deliverable) AND prior phase produced per-source/per-subject primary artifacts | **Primary-Source Verification Gate** — before proceeding to the analytical phase, enumerate all Phase 2/3 artifact files from `Sprints/{sprint}/`. Compare against `files_to_load`. For any primary artifact NOT in `files_to_load`, ask: "Load now?" or "Document deferral decision (why skip)?". Do not proceed to analytical work until every primary artifact has been either loaded or explicitly deferred with rationale. See §C.1. |
| continue_with references Research step (checkpoint recovery) | Display summary. Load Sprint report files from files_to_load. Resume at indicated step. |
| Progress marker found in ISS | Display summary. Resume at indicated step. |
| Complete content (loop-back or review) | Offer: A) Review and revise, B) Start fresh, C) Proceed to transition (if score ≥ 4) |
| continue_with says "Begin research" (Analysis handoff) | Fresh start → proceed to D |
| Placeholder, no context | Fresh start → proceed to D |

### C.1 — Primary-Source Verification Gate

Applies when resuming Research at an analytical phase (Analysis / Deliverable) AND prior phases produced primary artifacts (survey per source, investigation per subject).

**Enumerate**: `Sprints/{sprint}/` for files matching `ISS-{XXX}-{phase}-*.md` or `ISS-{XXX}-investigation-*.md` or `ISS-{XXX}-survey.md`. All such files are "primary artifacts" for this research.

**Check against files_to_load**: for each primary artifact:
- Present in files_to_load → OK, will be loaded
- Not in files_to_load → ask user:
  - Load (add to files_to_load for this session)
  - Defer (document deferral reason — e.g., "synthesized into phase3-synthesis.md, primary not needed for this phase")

**⛔ MANDATORY OUTPUT** (reproduce at verification gate):
⛔ [PRIMARY-VERIFIED] Phase {N} primary artifacts: {count_total} | loaded: {count_loaded} | deferred: {count_deferred} with rationale | ready to proceed: {yes|no}

Cannot proceed to analytical phase work until `ready to proceed: yes`.

**Rationale**: synthesis artifacts are designed to feed downstream phases and read as "complete" on their own. This completeness-appearance masks primary-evidence gaps. Explicit enumeration + deferral-with-rationale prevents Phase 4-class gaps.

**Case study reference** (ISS-159 Conv 6): Phase 4 initial run loaded 3 of 12 artifacts. Post-backfill re-analysis reversed 4 B.1 demotions and surfaced project-type-framing error. This gate is the structural mitigation.

### D — Score Gate

Check implemented score from issues-registry.yaml (`ISS-XXX.implemented:`).

| Score | Action |
|---|---|
| ≥ 4, ISS has content | Offer: A) Review existing, B) Re-research, C) Skip to Commit |
| ≥ 4, ISS empty | Warn data inconsistency. Recommend re-researching. |
| < 4 | Proceed to E |

### E — Context Artifacts (conditional)

If `.nexus/supporting-files/project-context/` exists:
- Check CONCERNS.md for entries relevant to research subjects — known project concerns that intersect research scope inform investigation priorities
- Note relevant concerns for consideration during Survey/Investigation

### F — Pattern Context

Check sprint-state [PATTERNS_IN_USE] for this issue. Note applied patterns for tracking during research.

→ Proceed to Router

---

## Router
[Section: Router]

Research always routes to a mode file (no Simple Path). Load the mode-specific workflow.

### Load Sequence

Read mode file (1 load):

`${CLAUDE_SKILL_DIR}/modes/{mode}.md`

**Mode mapping** (from Orient A — ISS Research Design):

| Mode | File |
|---|---|
| Adoption | modes/adoption.md |
| Comparative | modes/comparative.md |
| Exploratory | modes/exploratory.md |

### Execution Sequence

After loading mode file:

1. SKILL.md Step 1: Scoping (shared)
2. Mode file: Survey → Investigation → Analysis → Deliverable → Decision
3. Return to SKILL.md: [Section: End-of-Workflow-Checklist] → [Section: Commit-Protocol] → [Section: Transition]

### Zone Checks

After each step boundary: apply the Green/Yellow/Red zone actions per CLAUDE.md [Section: Memory-Context-Management] → Context Zones. Research checks more aggressively than other skills — every step, not just major phase boundaries.

[/Section: Router]

---

## Step 1: Scoping

Verify the research design from Analysis, enrich with user input, confirm plan.

### A — Scope Verification

Present research scope from ISS Research Design:

> 📋 Research Scope (from Analysis)
>
> Mode: {mode}
> Subjects: {list}
> Research questions: {numbered}
> Evaluation criteria / dimensions: {list}
> Source strategy: {sources identified}
> Deliverable target: {type}

Confirm mode: "Research mode detected: **{mode}**. Confirm or switch? [Confirm / Switch to {alternative modes}]"
If user switches: adjust scope presentation accordingly. Mode determines which mode file was loaded — if switching modes, reload the correct mode file before proceeding.

### B — User Domain Knowledge

"Do you have prior experience with {subject(s)} I should factor in?"

Integrate user knowledge as experiential evidence alongside web/document sources. Note in findings with attribution.

### C — Source Strategy Enrichment

Analysis source strategy is a starting point. Identify additional sources:
- Sources not considered during Analysis
- Recently published material
- Community discussions, real-world experience reports
- Local project files to examine (especially Adoption mode)

### D — Scope Confirmation

**[T2: Balanced+Full ask | Streamlined: approve if Analysis provided all elements, notify+log]**

> Research scope verified and enriched.
> Changes from Analysis: {list or "none"}
> Ready to begin? [Y / adjust]

### E — Plan Verification

**[T3: Full ask | Balanced: notify | Streamlined: silent if scope unchanged]**

Confirm research plan from ISS Implementation-Plan:

> Analysis planned: {phases}, {estimated conversations}, {deliverable target}
> Still valid given confirmed scope? [Y / adjust]

If scope changed in D: assess whether plan needs adjustment.

### F — Zone Check

Check context usage. If Yellow/Red → checkpoint before Survey begins.

→ Proceed to mode file Survey step

---

## Commit Protocol
[Section: Commit-Protocol]

Shared by all modes. Persists research outcomes to ISS file.

**[T3: Full ask | Balanced: notify | Streamlined: auto-write]**

### Research-Mode Scope Discipline

Applies to **all modes** (Adoption, Comparative, Exploratory).

**Rule**: Research-type Phase 5 final deliverables land at `.nexus/Sprints/{NNN}/` as concrete proposals. Framework alterations (skill edits, CLAUDE.md edits, agent-file edits, registry restructurings, template changes) are **deferred to follow-up issues at sprint closure** — they are not applied during the research sprint itself.

**Why**: Research and framework-modification are different kinds of work with different review postures. Mixing them within a single sprint couples cross-sprint timing (proposals landing prematurely while still in research) and bypasses Build/Validate phases that framework edits owe to the system.

**Mechanics**: When Decision (Adopt / Adapt / Integrate) produces concrete framework-modification proposals:
- The proposal text + adoption plan goes into the Phase 5 deliverable at `Sprints/{NNN}/`
- Issues for the actual framework modifications are spawned at sprint closure (typically via Learning-phase triage), not during this sprint
- Per [Section: Gate-Reference] "Create issues from findings" T2 gate — invoke `/nexus-create-issue` for each modification, marking `target_sprint` for a future sprint

**Exception**: small documentation updates that are not framework-behavioral (e.g., adding a reference link, fixing a typo discovered during research) may be applied inline if they pass the standard consent gate. Behavioral changes (skill protocol additions, marker definitions, methodology gates) always defer to a follow-up issue.

**Case study reference** (ISS-159 Sprint 073): proposals for F2/F3/F5/F6 + V1-V5 + S1-S4 + agent-template + op-skill-template were drafted in `Sprints/073/` as deliverables; framework edits were deferred to Sprint 075/076/077 follow-up issues (ISS-160 through ISS-166). This discipline prevented mid-research framework drift.

#### AUDIT-DEFERRED Labeling Convention

Applies to **audit-shape Research deliverables** (Research-mode audits, inventories, classifications, registry sweeps). Canonical convention for honest scope-budget gap reporting.

**Rule**: When a Research-mode audit cannot complete an SC element within its scope budget, the deliverable MUST label the gap explicitly using the canonical syntax below. Implicit deferral (omission, vague "minor", or unlabeled "deferred") is a violation — future-sprint readers cannot distinguish "no work needed" from "work needed but not done here".

**Syntax template** (use literally; do not paraphrase):

```
**AUDIT-DEFERRED to ISS-{target} Analysis** ({provenance}: {reason})
```

- `{target}` — the execution-sprint ISS that owns the deferred work (or `ISS-δ Analysis` / `ISS-{TBD} Analysis` if the target is not yet identified — flag at Decision for follow-up issue creation per Research-Mode Scope Discipline above).
- `{provenance}` — the finding/probe id that surfaced the deferral need (e.g., `P2.6 R2-M3`, `Phase 4 coverage check`) or `audit-time scope budget` for proactive labels.
- `{reason}` — one short clause naming what specifically was not completed (e.g., "full grep on hooks not completed at audit-time", "exhaustive enumeration deferred to execution-sprint Analysis").

**Trigger condition**: Audit cannot complete an SC element within Research scope budget AND the deferred work is non-trivial enough that future readers need a pointer (not "look up a typo later" — that's just a note).

**Placement guidance**: Inline at the SC element where the gap occurs, OR at the table row / list item describing the affected scope. Place at the *moment of incompleteness* — not in a separate "deferrals" appendix that future readers may miss. If multiple cells in a table row are affected, label at the row level once.

**Execution-vs-audit distinction**: This convention applies ONLY to **audit-scope deferral** (Research-mode audits hitting scope-budget limits on SC elements). It is distinct from existing execution-time "deferred" wording in this skill family:
- `subjects deferred to next conversation` (mode files: comparative, exploratory) — execution-time pacing, not audit-scope.
- `Adopt / Adapt / Defer / Skip` (Adoption mode Decision) — recommendation verdict, not audit-scope.
- `Sprints/XXX/` framework-edit deferrals to follow-up issues (Research-Mode Scope Discipline rule above) — scope-coupling discipline, not SC-completion.

When using the word "deferred" in audit context, prefer the canonical `AUDIT-DEFERRED to ISS-X Analysis` form to avoid conflation with the execution-time senses above.

**Case study reference** (ISS-184 Sprint 084 P2.6 R2-M3): audit-deliverable §3.5 (hooks) + §3.6 (templates) + §3.7 (Emergency-Reference) + agent-template L224 carried 4 unlabeled "deferred" mentions, caught only by parallel-opus adversarial review (Thorough mode, 3× nexus-reviewer dispatch). Re-labeled inline to canonical form. The MEDIUM-severity catch motivated this convention.

#### Exhaustive-Enumeration Grep Convention

Applies to the same **audit-shape Research deliverables** as AUDIT-DEFERRED above (audits, inventories, classifications, registry sweeps — any mode). Where AUDIT-DEFERRED governs honest *gap* reporting, this governs *completeness* of the enumeration itself.

**Rule**: Before declaring any §3.x-style enumeration (removal map, inventory rows, classification table) complete, run an exhaustive multi-vocab grep across the **entire in-scope file(s)/section** — not just the subsections that already hold enumerated rows. High-density blocks are easy to enumerate; the systematic miss is the long tail of single-line residuals living in non-enumerated subsections.

**Three moves** (in order):

1. **Derive target vocabulary** — list the concepts under audit *with synonyms and variants*, not a single label. Vocabulary completeness is the load-bearing step: whole-scope grep still under-catches when a residual uses a term the grep never searched for. For each concept, deliberately enumerate: the **bare form AND every qualified form** (`Desktop` *and* `Desktop Chat`), common **abbreviations/expansions** (`MCP` ↔ `nexus-mcp`), associated **tool/file/marker names** (`startMarker/endMarker`), and any **synonyms** the corpus uses elsewhere. The canonical miss is a residual that uses the bare or variant form when only the qualified form was searched. (E.g., auditing "multi-environment" content → `Desktop`, `Desktop Chat`, `MCP`, `nexus-mcp`, `terminal`, `hook-fallback`, `startMarker/endMarker`, plus individual environment names.)
2. **Whole-scope grep** — grep each vocabulary term across the entire in-scope file(s)/section, not only the enumerated subsections. Every hit is either already covered by an enumerated row or is a residual.
3. **Reconcile + converge** — for each residual, *author's choice*: absorb it into an existing enumerated row, OR list it in an explicit "residual" subsection of the §3.x block. Then re-grep the vocabulary — the only remaining hits must be ones now accounted for (PAT-098 convergence signal: grep returns proof of completeness; memory and visual scan do not).

**Patterns**: this is PAT-112 (explicit-discipline-at-authoring-time) realized via PAT-098's grep-convergence mechanism (generalized from rename-time to enumeration-time); single-home placement here — not duplicated into mode files — per PAT-113.

**Case study reference** (origin: 6 cross-sprint reproductions, Sprints 084 + 086): a Sprint 086 audit enumerated 9 high-density §3.1 rows but missed 6 single-line multi-environment residuals (Welcome Display freshness slot, Compaction Recovery fallback, BOOTSTRAP MCP dispatch, Status Line terminal-vs-Desktop, L325 startMarker/endMarker) — each living *outside* the enumerated subsections, each caught only by halt-and-repair at Build/Validate. A whole-file multi-vocab grep on the audit's own target vocabulary surfaces all six.

### A — Update Research Log

Edit ISS-XXX.md [Section: Implementation-Log] per Research Log Update Reference:

| Subsection | Content |
|---|---|
| Status | Final step, score, completion state |
| Findings Summary | Thin summary per conversation + pointers to Sprint report files |
| Quality Checks | Source quality triage, bias checks performed, coverage assessment |
| Scope Changes | Questions added/dropped during research |
| Pattern Outcomes | Per-pattern assessment with evidence |
| Research Pivots | Methodology changes during research |
| Issues Encountered | Problems and resolutions |

### B — Update Continue-With

```
WHAT: Evaluate research for ISS-XXX
WHY: Research complete — deliverable produced, decision made
DELIVERABLE: Sprints/XXX/ISS-XXX-{deliverable-name}.md
FIRST: Load deliverable, assess research quality
```

### C — Update Patterns in Use

If patterns tracked: edit sprint-state [PATTERNS_IN_USE] under ISS-XXX block.

### D — Verify on Disk

MANDATORY: Read back modified ISS sections from disk. Confirm content correct. Unverified writes are violations.

[/Section: Commit-Protocol]

---

## Transition
[Section: Transition]

Run after [Section: End-of-Workflow-Checklist] passes. Mode file Decision step returns here.

**[T3 smart logic]**

### Step 0 — Readiness Gate

Compute verdict from three inputs, render, and route.

**Inputs:**
- Research score (I:X) from checklist
- End-of-Workflow checklist results
- One-way doors from research decisions (e.g., irreversible adoption recommendations)

**Research-specific checklist:**

```
Core:
- [ ] Research score calculated (I:4 or I:5)
- [ ] Two-place score update: registry + sprint-state
- [ ] Sprint-state continue_with set with evaluation context
- [ ] Patterns in use updated (if applicable)
- [ ] Context zone checked

Research-specific:
- [ ] Deliverable written to Sprints/XXX/ and verified on disk
- [ ] Source quality: ≥2 primary sources per subject
- [ ] Bias checks performed at ≥2 quality checkpoints
- [ ] Decision captured (Adopt/Adapt/Defer/Skip or equivalent)
- [ ] Issues created from findings (if Decision produced action items)
```

**Verdict logic:**

| Verdict | Condition |
|---|---|
| **PASS** | Score ≥4 AND checklist 100% AND (no one-way doors OR all mitigated) |
| **CONCERNS** | Score ≥4 AND checklist mostly passes AND any: one-way door without mitigation, low source quality on key subject, bias flag unresolved |
| **FAIL** | Score <4 OR hard checklist failures (deliverable missing, decision not captured) |

**Display:**

```
✅ PASS — Research ready for evaluation
• Score: {X}/5
• Checklist: {N}/{N} items passed
• One-way doors: {none or "all mitigated"}

⚠️ CONCERNS — Research mostly ready, {N} concern(s)
• Score: {X}/5
• Concerns: {list}
• Options: [A] Acknowledge & proceed [F] Fix [D] Decompose

❌ FAIL — Research not ready
• Score: {X}/5
• Blockers: {list}
• Options: [Continue from {step}] [Decompose]
```

| Verdict | Behavior |
|---|---|
| **PASS** | Render verdict, proceed to Score Calculation |
| **CONCERNS** | Render + suggested fixes. `[A] Acknowledge & proceed [F] Fix [D] Decompose` |
| **FAIL** | Block transition. `[Continue from {step}] [Decompose]` |

### Score Calculation

Research uses `implemented` score field (I:X):
- 4 = research complete, deliverable produced, decision made, minor gaps acceptable
- 5 = comprehensive, high-quality deliverable, all questions answered, no gaps, quality checks thorough

### If Score < 4 — Recovery Path

Do NOT transition. Gaps remain. Mode file is still in memory — no reload needed. Return to the relevant mode file step:
- Missing investigation depth: return to Investigation
- Deliverable incomplete: return to Deliverable
- Decision not captured: return to Decision

After addressing gaps: re-run checklist, recalculate score.

### Smart Logic per Control Level

| Level | Behavior |
|---|---|
| Full Control | Display full transition summary, wait for explicit approval |
| Balanced | Display summary + "Transitioning to evaluation...", proceed after brief pause |
| Streamlined | Silent: verify checklist → two-place score update → set focus → load /nexus-validate |

### Transition Summary (Full + Balanced)

```
📊 Research Phase Complete
• Score: {4 or 5}/5
• Mode: {mode}
• Subjects: {list}
• Deliverable: Sprints/XXX/{filename}
• Decision: {outcome}
• Issues created: {count or "none"}
• Patterns: {list with outcomes or "none applied"}

[Transitioning to Evaluation — /nexus-validate]
```

**Two-place score update** → issues-registry.yaml (ISS-XXX.implemented = {score}) + sprint-state.md [OBJECTIVES] (I:{score})

**On decline** (Full Control only): ask what needs attention. Loop-back offer if research direction needs rethinking → invoke /nexus-loop-back.

**User override**: If user says "evaluate now" with score < 4, warn that research gaps remain but proceed if insisted.

[/Section: Transition]

---

## Gate Reference
[Section: Gate-Reference]

All gates present LLM recommendation regardless of tier or control level.

| Gate | Tier | Full | Balanced | Streamlined | Conditional? |
|---|---|---|---|---|---|
| Scope confirmation | **T2** | Ask + rec | Ask + rec | Approve if Analysis complete, notify+log | Always |
| Plan verification | T3 | Ask | Notify | Silent if scope unchanged | Always |
| Survey sufficiency | T3 | Ask | Notify | Continue if adequate sources | Always |
| Scope adjustment | T2 | Ask + rec | Ask + rec | Auto-adjust minor, notify+log | **Only if triggered** |
| Loop-back suggestion | T2 | Ask + rec | Ask + rec | Notify+log | **Only if triggered** |
| Save agent reports | **T2** | Ask + rec | Ask + rec | Save synthesized only, notify+log | Always |
| Investigation continuation | T3 | Ask | Notify | Continue when coverage complete | Always |
| Analysis sufficiency | T3 | Ask | Notify | Proceed if criteria covered | Always |
| Deliverable write | T3 | Ask | Notify | Auto-write, silent | Always |
| **Decision on findings** | **T1** | Ask + rec | Ask + rec | Ask + rec | Always |
| Create issues from findings | **T2** | Ask + rec | Ask + rec | Notify+log | **Only if Decision produces action items** |
| Transition | T3 | Ask (audit) | Notify action taken | Silent: checklist → checkpoint → load/defer | Always |

**Stop points**: Full Control: up to 14. Balanced: 3 always + 3 conditional. Streamlined: 1 (Decision only).

[/Section: Gate-Reference]

---

## Checkpoint Reference
[Section: Checkpoint-Reference]

When [Section: Checkpoint-Protocol] fires during research, persist based on progress:

| After | Persist | Where |
|---|---|---|
| Orient | Mode, ISS loaded | continue_with only |
| Scoping | Scope confirmed, plan verified, user domain knowledge | ISS Research Design enrichments + continue_with |
| Survey | Landscape findings, source triage | ISS Findings Summary + continue_with. Sprint report if substantial. |
| Investigation (per session) | Deep findings per subject/track | Sprint report files. ISS thin summary + pointers. continue_with tracks remaining subjects. |
| Analysis | Synthesis complete, conclusions | ISS Findings Summary updated. continue_with captures key conclusions. |
| Deliverable | Report written | Sprint report file on disk. ISS pointer. Verify on disk. |
| Decision | User decision captured | ISS Research Log. Scores updated if complete. |
| Commit done | Already on disk | Verify only |

**Progress marker protocol**: Place as first line in [Section: Implementation-Log]:
`*Research in progress — {last completed step}*`
Orient C detects it on resumption. Commit removes it.

**Resumption reload mandate** (MANDATORY): When Orient detects a resumption (progress marker found, or continue_with references a mid-Research step), ALWAYS route through [Section: Router]. Router reloads the mode file unconditionally. Do NOT attempt to re-enter a mode file directly without reloading — mode files are not persisted across conversations. Resume at the specific step indicated in continue_with after the mode file is loaded.

**files_to_load management**: As reports get consumed by later steps, drop from files_to_load.

| Step | Add to files_to_load | Drop from files_to_load |
|---|---|---|
| Survey | Survey report (if external) | — |
| Investigation | Investigation reports | Survey report (consumed) |
| Analysis | — | — |
| Deliverable | Deliverable file | Investigation reports (synthesized) |
| Post-commit | — | Only deliverable remains |

[/Section: Checkpoint-Reference]

---

## Research Log Update Reference
[Section: Research-Log-Reference]

ISS [Section: Implementation-Log] subsection mapping. Update relevant subsections at each checkpoint.

| Subsection | Content | Updated At |
|---|---|---|
| Status | `Step: {name} | Subject: {current} | Progress: {description}` | Every checkpoint |
| Findings Summary | Thin summary per conversation + pointers to Sprint report files | Survey, Investigation, Analysis |
| Quality Checks | Source triage, coverage, bias checks | Survey, Investigation, Analysis (ongoing), Deliverable (final) |
| Scope Changes | Questions added/dropped, subjects shifted, reasoning | When scope changes |
| Pattern Outcomes | `PAT-XXX ({name}): {outcome} — {evidence}` | Deliverable step |
| Research Pivots | Focus shifts, source changes, approach changes | When approach changes |
| Issues Encountered | Problems and resolutions | As encountered |

[/Section: Research-Log-Reference]

---

## End-of-Workflow Checklist
[Section: End-of-Workflow-Checklist]

MANDATORY before transition. All must pass.

```
- [ ] Deliverable written to Sprints/XXX/ and verified on disk
- [ ] Audit-deferral labeling — any deliverable SC element not completable within scope budget carries explicit "AUDIT-DEFERRED to ISS-X Analysis" label (not implicit deferral) per [Section: Commit-Protocol] Research-Mode Scope Discipline → AUDIT-DEFERRED Labeling Convention
- [ ] Enumeration completeness — for any §3.x-style enumeration in an audit-shape deliverable, exhaustive multi-vocab whole-scope grep run + every hit reconciled (absorbed or listed as residual) per [Section: Commit-Protocol] Research-Mode Scope Discipline → Exhaustive-Enumeration Grep Convention
- [ ] ISS Research Log updated (Status, Findings Summary, Quality Checks, Pattern Outcomes)
- [ ] ISS pointers to Sprint report files correct
- [ ] Research score calculated (I:4 or I:5)
- [ ] Two-place score update: registry + sprint-state [OBJECTIVES]
- [ ] Sprint-state continue_with set with evaluation context
- [ ] Patterns in use updated (if applicable)
- [ ] Issues created from findings (if Decision produced action items)
- [ ] Context zone checked — checkpoint if crossing boundary
```

If any item fails: fix before transitioning. Do not proceed with incomplete checklist.

[/Section: End-of-Workflow-Checklist]

---

## Source Quality Standards
[Section: Source-Quality]

Categorize sources during survey and investigation to calibrate confidence.

| Tier | Signal | Trust Level | Examples |
|---|---|---|---|
| Primary | Official docs, source code, peer-reviewed papers, specs | High — verify claims against these | GitHub repos, RFCs, official API docs, published research |
| Secondary | Reputable articles, tutorials, conference talks, expert blogs | Medium — cross-check key claims | Quality tech blogs, conference proceedings |
| Tertiary | Forums, opinions, marketing material, social media | Low — note sentiment only, never rely for facts | Reddit threads, product pages, tweets, SO opinions |

**Minimum for confident conclusions**: At least 2 primary sources per subject. If only secondary/tertiary available, state as confidence limitation in deliverable.

**Staleness check**: Technology research older than 2 years may be outdated. Flag when most sources are old.

[/Section: Source-Quality]

---

## Bias Avoidance
[Section: Bias-Avoidance]

Check at every quality checkpoint (Survey, Investigation, Analysis, Deliverable).

| Bias | Check Question | Mitigation |
|---|---|---|
| Confirmation | Only finding evidence supporting initial hypothesis? | Search for criticism, limitations, failure cases |
| Anchoring | Over-weighted toward first thing found? | Compare later findings on equal footing |
| Authority | Trusting source because of who, not what? | Evaluate claims on evidence, not reputation |
| Availability | Favoring easiest-to-find info? | Check if hard-to-find primary sources contradict |
| Framing | Research question limiting findings? | Revisit scope. Different search terms = different landscape? |

**Escalate**: If 2+ biases present at a quality check, flag to user and propose corrective action (broader search, alternative sources, scope adjustment).

[/Section: Bias-Avoidance]

---

## Pattern Tracking
[Section: Pattern-Tracking]

**During research** (Survey through Deliverable): When a pattern's guidance influences a research decision, display: `📐 PAT-XXX: {how influencing}`.

**At Deliverable**: Assess each applied pattern's outcome. Record in ISS ### Pattern Outcomes with evidence. Verdict: helped / neutral / hindered / not yet clear (NOT auto-success). Taxonomy: pattern-specification.md → Outcome Verdicts; close-issue STEP 2A applies the dedup hard-gate at authoritative capture.

**Deferred to closure**: Actual effectiveness score updates and registry changes happen at issue closure, not during research. Research captures data; closure processes it.

[/Section: Pattern-Tracking]

---

## Sub-Agent Contracts
[Section: Agent-Contracts]

Shared contracts, constraints, and handling rules. Mode files provide task-specific prompts.

Agent file: `.claude/agents/nexus-researcher.md` — carries output templates and behavioral DNA. If output format changes here, update agent file to match (this section is authoritative).

### Agent Constraints (all dispatch types)

| Constraint | Rule |
|---|---|
| Read-only | Agent must not modify any project files |
| One-pass | No iterative refinement — read, extract, return |
| No questions | Agent cannot ask user for clarification |
| No analysis | Return findings/evidence only — synthesis in main context |
| Token budget | Agent return ≤2000 words (~2700 tokens) |

### Sub-Agent Tier Selection

Canonical policy mapping research phase → sub-agent model tier. Authoritative for `/nexus-research` dispatch decisions.

| Research phase | Tier | Rationale |
|---|---|---|
| Survey (landscape mapping) | haiku | Broad, shallow — collect sources, no judgment needed |
| Investigation (deep extraction) | sonnet (default) | Nuance, per-criterion evaluation |
| Codebase audit (Adoption) | sonnet (default) | Code comprehension needed |
| Synthesis / Phase 4 Analysis | Main context only | Cross-source reasoning requires full conversation — never sub-agent |

#### Override Triggers

Deviate from the default tier when the dispatch context fires one of these conditions:

| Default | Upgrade to | When |
|---|---|---|
| Survey (haiku) | sonnet | Per-source scope exceeds ~3 large files OR sources are paywalled / JS-heavy / require deeper extraction than landscape mapping |
| Investigation (sonnet) | haiku | Per-source criterion set is shallow (≤2 simple Y/N questions) AND source is plain text — investigation is in name only |
| Codebase audit (sonnet) | Main context (skip dispatch) | Cross-file reasoning spans ≥5 files — this is synthesis territory, not audit |
| Synthesis | (never delegate) | Synthesis is main-context only by definition; if you feel the urge to dispatch, split the synthesis into independent sub-questions and dispatch each as Investigation |

Dispatch mechanism: pass `model: {tier}` per invocation to the Agent tool. The agent's frontmatter is `model: inherit` — see `.claude/agents/nexus-researcher.md` §Dispatching conventions for the bidirectional contract.

**Cross-reference**: For batch-mode tier selection (signal-based — complexity, playbook length, prior fit:partial signals), see `.claude/skills/nexus-build/batch.md` §Tier Selection. The two policies are complementary: this section governs research-phase dispatch (phase-based); batch.md governs batch-execution dispatch (signal-based).

### Token Budget

Agent return should not exceed ≤2000 words (~2700 tokens). Longer returns waste main context budget. Agents must use structured format (per output templates below), not prose.

### Pattern Injection

Before dispatch, check sprint-state [PATTERNS_IN_USE]. If relevant patterns exist, append adapted guidance to the input contract `guidance:` field as an evaluation lens. Brief only — 1-3 sentences, not the full PAT file.

### Survey Agent Return Format

Every survey agent returns this structure:

```
## {Subject/Aspect}
### Sources Found
- {source name} ({URL}) — {Primary/Secondary/Tertiary}
### Key Findings
- {finding 1}
### Gaps
- {what wasn't found}
### Priority Sources for Investigation
- {source} — {why worth deep reading}
```

Scope boundary: Broad landscape only. No analysis, no recommendations.
Error: If fewer than 2 sources found, report gap explicitly.

### Investigation Agent Return Format

```
## Deep Investigation: {Subject}
### Per-{Criterion/Dimension/Question} Findings
#### {Item 1}
- Evidence: {specific finding with source}
- Assessment: {strength/weakness/neutral}
### Strengths (with source reference)
### Limitations (with source reference)
### Open Questions
### Sources Consulted
- {URL} — {what was extracted}
```

Scope boundary: This subject/source only. Do NOT compare across subjects.
Error: If primary source inaccessible, report and note secondary alternatives.

### Codebase Audit Agent Return Format (Adoption only)

```
## Current Approach Audit: {Area}
### Per-Criterion Findings
#### {Criterion 1}
- Implementation: {how it works, key files}
- Strengths / Pain points
### Architecture Overview
### Technical Debt
### Integration Points
```

Scope boundary: Current codebase only. No web searches. Use Glob, Grep, Read.

### Agent Result Handling

1. Quick quality check — structured format returned? Gaps flagged?
2. User prompt for report saving **[T2]**
3. Write full reports to Sprints/XXX/ if user requests
4. Synthesize key findings for main context — feeds next step
5. Update ISS Findings Summary with thin summary + pointers
6. Unstructured returns: extract useful parts, note quality gap
7. Agent failure/timeout: retry once, fall back to main context WebSearch

[/Section: Agent-Contracts]

---

## Agent Dispatch Protocol
[Section: Agent-Dispatch]

Shared dispatch pattern for survey and investigation agent passes. Mode files invoke by reference at their dispatch points.

### Dispatch Offer

**[T2: Balanced+Full ask | Streamlined: auto-recommend, notify]**

```
🤖 Dispatch research agent? {brief value prop}
Mode: {N}× {model tier} agent(s) ({focus — survey or investigation})
[Y / Skip — continue in main context]
```

### On Accept

1. Construct input contract per `.claude/agents/nexus-researcher.md` §Input Contract (the agent file carries the input-contract and output templates; [Section: Agent-Contracts] above is authoritative for constraints, tier selection, and return formats)
2. Check [PATTERNS_IN_USE] — if relevant, add adapted guidance to `guidance:` field
3. Override model tier per routing table: survey → `model: haiku`, investigation → `model: sonnet`
4. Dispatch via Agent tool with `.claude/agents/nexus-researcher.md`
5. Read `<usage>` total_tokens → add to agent running total (per Sub-Agent Token Tracking in CLAUDE.md)
6. Process results per [Section: Agent-Contracts] Agent Result Handling

### On Skip

Continue in main context — use WebSearch/WebFetch directly. Primary path is always viable.

[/Section: Agent-Dispatch]

---

## Step Display Guidance

Vary presentation naturally. Spirits to channel and styles to render in — not scripts to repeat. Spirit captures the *attitude* you bring; Style captures the *form* and *cadence* of the output.

| Step | Spirit | Style |
|---|---|---|
| Orient | Curiosity — confirm understanding | Silent until scope verified |
| Scoping | Clarity — defining the quest | Present scope from ISS; confirm with user; compact |
| Survey | Discovery — casting the net wide | Source lists with quality tiers; landscape summary; flag gaps |
| Investigation | Depth — going to the source | Per-source findings with evidence attribution; structured by criterion |
| Analysis | Synthesis — connecting the dots | Cross-source themes; convergence/divergence tables; confidence levels |
| Deliverable | Craft — producing the output | Formal report structure; evidence-backed; no unsourced claims |
| Decision | Resolution — what we do with this | Options with recommendation; clear consequences; stop and wait |
