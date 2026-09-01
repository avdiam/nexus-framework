*Version: 1.1.0 | Date: 2026-06-11 | Sprint: 101*

# Validate — Creative Type

Loaded by SKILL.md Router for complexity ≥ 3 creative issues.

**Key differences from default**:
- Graduated criteria instead of binary pass/fail
- 5 creative quality dimensions instead of 4 standard
- "Refinement opportunities" framing, not "bugs"
- Subjective quality acknowledged — present reasoning, invite user input
- Audience proxy: mentally model the intended audience

**Flow**: §1 Criteria Assessment → §2 Quality Review → return to SKILL.md Step 5 (Pattern Finalization)

---

## §1 Criteria Assessment

### A — Graduated Dimensions (replaces forward mapping)

| Dimension | Checks |
|---|---|
| Audience-fit | Does content speak to the intended audience? Right complexity level? |
| Message clarity | Core message clear? No ambiguity on key points? |
| Tone consistency | Tone consistent throughout? Matches brief? |

For each dimension: assess with reasoning, not binary. "Would a {audience} find this {clear/compelling/actionable}?"

### B — Reverse Traceability

Each content section → traces to brief requirement or outline item. Untraced sections = scope creep or organic growth (acceptable in creative work if justified).

### C — Known Concerns Check (conditional)

If `.nexus/supporting-files/project-context/CONCERNS.md` exists: check intersection with creative deliverable scope.

### C2 — Convention Compliance Check (conditional)

If `.nexus/supporting-files/project-context/CONVENTIONS.md` exists: check creative output against brand/voice/format conventions. For creative work, convention deviations may be intentional artistic choices — ask rather than flag as errors.

### D — Gap Analysis

For unmet dimensions: refinement opportunity, not failure. Frame constructively.

### E — Write

Patch ISS [Section: Evaluation-Results] ### Criteria Verification. Update progress marker: `*Evaluation in progress — criteria assessed*`

---

## §2 Quality Review

### A — Brief vs Deliverable Comparison

Sections completed, refinement iterations, user feedback incorporated.

### B — Deviation Analysis

For each deviation in ISS ### Deviations: beneficial (improved outcome), necessary (required by circumstances), or avoidable (planning gap)? What learning does each provide? Here "deviations" are creative scope changes, not implementation changes.

### C — Quality Dimensions (5 creative dimensions)

| Dimension | Checks | Verdict |
|---|---|---|
| Audience-fit | Speaks to intended audience, right complexity | PASS/PARTIAL/FAIL |
| Message clarity | Core message clear, no ambiguity | PASS/PARTIAL/FAIL |
| Tone consistency | Consistent throughout, matches brief | PASS/PARTIAL/FAIL |
| Structural flow | Logical progression, smooth transitions | PASS/PARTIAL/FAIL |
| Polish | Grammar, formatting, presentation quality | PASS/PARTIAL/FAIL |

### D — Technical Debt / Open Items

Refinement opportunities, not defects. Frame constructively — "what would make it stronger."

### E — Adversarial Pass (C:3+)

Focus: Would audience find this compelling? Tone drift end-to-end? Does content serve original purpose? Narrative coherence?

Must-find mandate — at least one genuine issue must be surfaced. HIGH findings must be addressed before proceeding.

### F — Constitution Compliance

If `[PROJECT_CONSTITUTION]` exists in project-state.md, verify no violations. Always check regardless of complexity.

### G — Write Results

Patch ISS ### Quality Assessment. Update progress marker: `*Evaluation in progress — quality reviewed*`

> After §2 complete: return to SKILL.md Step 5 (Pattern Finalization).
