*Version: 1.5.1 | Date: 2026-06-11 | Sprint: 101*

# Analysis — Question Type

Loaded by SKILL.md Router for question-type issues, complexity ≥ 3.

**Flow**: Investigate → Design → **[T1] Choice** → [Plan → **[T1] Plan Approval**] → [Section: Commit-Protocol] → Transition

**Key differences from default**:
- Design produces Findings Report, not implementation options
- User decides: informational close OR proceed to implementation
- If informational-only: Plan is skipped, transition goes to /nexus-validate
- If implementation needed: reverts to standard default flow

---

## 1. Investigate

Focus: structured investigation to answer the question.

### A — Context Artifacts (conditional)

Same as default — check `.nexus/supporting-files/project-context/` for CONTEXT.md, STRUCTURE.md, CONCERNS.md.

### B — Structured Investigation

- Define the question precisely
- Identify what evidence would constitute a good answer
- Determine confidence threshold (what level of certainty is needed?)
- Map investigation scope (what to examine, what to exclude)

If Hypothesis-Driven Framework loaded: strongly recommend hypothesis-driven approach for structured investigation.

### C — Evidence Gathering

- Search codebase for relevant evidence (Grep/Glob)
- Read relevant files and documentation
- Trace execution paths if behavioral question
- Check external sources if domain knowledge needed

### C2 — Scope Discovery (Conditional)

Run [Section: Scope-Discovery] in references/scope-investigation.md. The trigger condition is checked there — if the registry `ISS-XXX.scope_files` and ISS `### Files Affected` are both empty/broad AND `_project_type: code`, the discovery loop runs. For question-type issues, scope discovery helps establish *which* files actually inform the answer, anchoring the findings to verifiable sources.

### C3 — Scanner Offer (Conditional)

After Scope-Discovery completes, run [Section: Scanner-Offer] in references/scope-investigation.md. For complex questions (C ≥ 3), the scanner can deepen the file-relevance ranking the inline grep produced. Always opt-in. If the question turns out to be informational-only, the discovered scope still serves as the evidence anchor in the Findings Report.

### C4 — Cross-Cutting Checklist (Conditional)

Run [Section: Cross-Cutting-Checklist] in references/scope-investigation.md. The trigger is checked there — when answering/implementing the question retires/renames/adds a cross-cutting concept (a named token recurring across file-classes), it adds 4 non-skill file-classes (hooks, supporting-files/architecture, Emergency-Reference, templates) to the Files Affected enumeration. No-op for a self-contained question. Complementary to Scope-Discovery (concept-shape grep vs empty-scope keyword convergence).

### D — File State Verification (MANDATORY)

Same as default — verify actual file states against assumptions.

### E — Findings Synthesis

> 📊 Investigation Summary
>
> Question: {precise formulation}
> Evidence gathered: {count sources}
> Preliminary answer: {direction}
> Confidence: {high/medium/low}
> Open gaps: {what couldn't be determined}

---

## 2. Design — Findings Report

Produce findings, not implementation options.

### A — Findings Synthesis

> 📋 Findings Report
>
> **Question**: {from ISS}
> **Answer**: {synthesized answer}
>
> **Evidence**:
> 1. {finding with source}
> 2. {finding with source}
>
> **Confidence**: {high/medium/low}
> **Limitations**: {what couldn't be determined}

### B — Implementation Assessment

| Assessment | Path |
|---|---|
| Answer is informational only | → Question-Resolved path (skip Plan) |
| Answer suggests changes needed | → Generate implementation options (standard format) |
| Answer is inconclusive | → Present findings, propose additional research |

### C — Strategic Reflection (complexity ≥ 3)

- Are findings well-supported by evidence?
- Could there be a different answer we haven't considered?
- Is confidence level appropriate given evidence?

### D — Present to User

> 🔬 Research Findings
>
> {Findings summary}
>
> Recommendation: {Informational close / Proceed to implementation / Further research}
>
> [Accept findings / Request implementation / Investigate further]

---

## 3. Choice Selection

**[T1: all levels ask]** Present findings with recommendation. Wait for user decision.

| Decision | Next |
|---|---|
| "Accept findings" (no implementation) | → Skip Plan, go to Question-Resolved Transition |
| "Request implementation" | → Plan (standard, like default type) |
| "Investigate further" | → Return to Investigate |

---

## 4. Planning (only if implementation needed)

If informational-only: this section is skipped entirely.

If user requests implementation, plan the change with a self-contained flow — impact mapping → sequencing → feasibility. The default-unique planning artifacts are inlined here so this file needs no external load:

**Calibration — size/effort estimates for SKILL.md sections**: Conditional-read blocks, derivation tables, and new SKILL.md / complex.md sections routinely run **+100–200% over initial line estimates**. Budget accordingly. Evidence: ISS-146 Phase 1 estimated ~140 lines, actual ~261 (+88%); Phase 2 estimated ~36 lines, actual ~128 (+260%). Rule of thumb: multiply naive estimates by 2–3× before committing.

**E2 — Scope feasibility**:

| Check | Concern | Action |
|---|---|---|
| Phases span 3+ conversations | Context budget risk | Flag — unless repetitive → Build batch mode territory |
| Plan complexity > issue complexity × 2 | Underestimated scope | Flag |
| Multiple methodology transitions | Coordination overhead | Flag |

**E3 — Decompose signal scan** per CLAUDE.md [Section: Decompose-Signals]: 3+ signals → strongly suggest; 2 → mention; 1 → don't suggest.

**E4 — Present findings** (only if issues found):

| Finding | Options |
|---|---|
| Structural issues | [Adjust plan / Verify manually / Proceed anyway] |
| Scope concerns | [Adjust plan / Accept risk / Proceed anyway] |
| Strong decompose signals | [Decompose now / Continue / Adjust plan] |
| Repetitive work detected | [Continue with Build / Switch to Apply / Adjust] |

If "Decompose now": invoke /nexus-decompose-issue — control transfers.

---

## 5. Plan Approval (only if implementation needed)

**[T1: all levels ask]** Same as default — present plan, wait for approval.

---

## 6. Transition

**[T3: Full ask | Balanced: notify | Streamlined: silent]**

After [Section: Commit-Protocol] completes:

### Question-Resolved Path (informational-only)

No implementation needed. Score appropriately and transition to evaluation.

**Score calculation**:
- A:4 = findings answer the question, evidence-based
- A:5 = comprehensive findings, multiple sources, high confidence
- I:5 = not applicable (question answered without implementation)

**Step 0 — Readiness Gate**: Run [Section: Readiness-Gate] in references/readiness-gate.md with branch `question/informational`. This branch checks findings recorded in Solution-Design, evidence documented with sources, and that I:5 will be set in the two-place update. **It does NOT check for Implementation-Plan** — the informational path intentionally has none. On PASS, proceed to step 1 below. On CONCERNS, follow the gate's branching. On FAIL, do not execute steps 1+ — return to the routed step per gate output.

Then execute:
1. Two-place update: A:{score} + I:5 (both registry and sprint-state)
2. Update sprint-state current_focus to 'evaluation'
3. Context-aware: load /nexus-validate or defer

> 📊 Question Resolved
>
> Analysis score: {X}/5 ✓
> Implementation: Not required — question answered
> Next: /nexus-validate (quality review of findings)

### Standard Implementation Path

Same as default transition — score, two-place update, load /nexus-build.

**Step 0 — Readiness Gate**: Run [Section: Readiness-Gate] in references/readiness-gate.md with branch `question/standard`. This branch is identical to `default` — full checklist including Implementation-Plan. On PASS, proceed with the standard transition. On CONCERNS, follow the gate's branching. On FAIL, do not transition — return to the routed step per gate output.

### On Decline

Offer: revisit findings, additional research, reconsider implementation need.
