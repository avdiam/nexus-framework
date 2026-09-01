*Version: 1.3.0 | Date: 2026-08-20 | Sprint: 110*

# Validate — Research Type

Loaded by SKILL.md Router for complexity ≥ 3 research issues.

**Key differences from default**:
- Research-specific quality dimensions replace standard 4
- Process review replaces plan-vs-actual implementation comparison
- No regression testing concept — replaced by source and coverage verification
- Objectivity and bias checking are first-class concerns

**Flow**: §1 Criteria Assessment → §2 Quality Review → return to SKILL.md Step 5 (Pattern Finalization)

---

## §1 Criteria Assessment

### A — Research Dimensions (replaces forward mapping)

| Dimension | Checks |
|---|---|
| Source Quality | Multiple independent sources? Primary sources consulted? Dates current? |
| Coverage Depth | All research questions answered? Sufficient investigation per subject? |
| Objectivity | Opposing viewpoints explored? Confirmation bias checked? Claims supported by evidence? |
| Actionability | Findings inform decisions? Recommendations concrete? Limitations stated? |

For each dimension: assess PASS/PARTIAL/FAIL with evidence.

### B — Reverse Traceability

Each finding/recommendation → traces to original research question. Untraced findings = scope expansion (may be valuable, but should be acknowledged).

### C — Known Concerns Check (conditional)

If `.nexus/supporting-files/project-context/CONCERNS.md` exists: check intersection with research scope.

### D — Gap Analysis

For incomplete dimensions: what additional investigation would be needed?

### E — Write

Patch ISS [Section: Evaluation-Results] ### Criteria Verification. Update progress marker: `*Evaluation in progress — criteria assessed*`

---

## §2 Quality Review

### A — Research Process Review

Questions vs answered, sources used, scope changes from original plan.

### B — Deviation Analysis

For each deviation in ISS ### Deviations: beneficial (improved outcome), necessary (required by circumstances), or avoidable (planning gap)? What learning does each provide? Here "deviations" are research scope changes, not implementation changes.

### C — Quality Dimensions (4 research dimensions)

| Dimension | Checks | Verdict |
|---|---|---|
| Source Quality | Primary sources used? Multiple independent? Dates current? | PASS/PARTIAL/FAIL |
| Coverage Depth | All questions answered? Sufficient per subject? No major gaps? | PASS/PARTIAL/FAIL |
| Objectivity | Opposing viewpoints explored? Bias checks? Claims evidenced? | PASS/PARTIAL/FAIL |
| Actionability | Findings inform decisions? Recommendations concrete? Limitations? | PASS/PARTIAL/FAIL |

### D — Technical Debt / Open Items

Deferred questions, incomplete investigation threads, sources not yet consulted.

### E — Adversarial Pass (C:3+)

Focus: Confirmation bias? Opposing viewpoints missed? Claims unsupported by evidence? Conclusions overreaching available data?

Must-find mandate — at least one genuine issue must be surfaced. HIGH findings must be addressed before proceeding.

### F — Tier-3 QA Audit Checklist

Structural audit gate before final Quality Assessment write. Complements §2C (semantic dimension verdicts) with mechanical evidence checks — distinct roles, both required at Tier 3.

**Tier gating**:
- Tier 1 (same-context audit): skip — accept Build's results if complete.
- Tier 2 (different-context, no risk signals): spot-check items 1, 5, 7 only.
- Tier 3 (full): all 7 items + net verdict + Issues Found surfacing for any PARTIAL/FAIL.

**Checklist** (each item is a verifiable structural check, not an open-ended prompt):

| # | Check | Verifiable evidence |
|---|---|---|
| 1 | Source tier distribution | "N Primary + M Secondary + K Tertiary" counts recorded in Evaluation-Results, traceable to Research Log entries |
| 2 | Primary-source verification | critical-source-evaluation spot-check (organize-sprint adoption-gate Step 1) applied; claim drifts caught documented inline with corrections (count + per-source listing) |
| 3 | Coverage completeness | Each research question has ≥1 documented finding with source citation AND each success criterion has evidence citation; gaps explicitly stated |
| 4 | Bias documentation | Minimum confirmation + anchoring (5-bias matrix recommended at C:3+) applied per phase and documented; opposing-viewpoint contributions logged where present |
| 5 | Deliverable structural integrity | All deliverable files exist at planned paths; each carries expected section/patch markers per Research Plan; structural inventory recorded |
| 6 | Research-log consistency | Conversation entries cross-reference deliverable sections (Pattern Outcomes / Scope Changes / Pivots / Issues Encountered) without contradiction; deviations explicitly logged |
| 7 | Self-adversarial review presence | Deliverable contains explicit self-adversarial section with named axes and verdicts; HIGH findings = NONE verified independently at §2E |

**Net Tier-3 QA verdict**: PASS / PARTIAL / FAIL. PARTIAL or FAIL items must surface in ### Issues Found before §2H Write.

### G — Constitution Compliance

If `[PROJECT_CONSTITUTION]` exists in project-state.md, verify no violations. Always check regardless of complexity.

### H — Write Results

Patch ISS ### Quality Assessment (dimensions §2C, debt §2D, adversarial §2E, constitution §2G) **and** ISS ### Deliverable Review — the Research ISS Evaluation-Results subsection (issue-specification.md [Section: Research-ISS-File-Structure]) that records the deliverable-level verdict: deliverable file(s) exist at the planned `Sprints/{NNN}/` paths, expected structure/sections present, self-adversarial section present, AUDIT-DEFERRED labels honest. At Tier 3 this is Tier-3 QA items 5–7 restated as the verdict; at Tiers 1–2 a one-paragraph structural read. Research ISS files carry no ### Test Execution — Deliverable Review is its counterpart. Update progress marker: `*Evaluation in progress — quality reviewed*`

> After §2 complete: return to SKILL.md Step 5 (Pattern Finalization).
