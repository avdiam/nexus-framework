*Version: 1.4.0 | Date: 2026-05-18 | Sprint: 083*

# Validate — Default Type (Feature / Improvement / Refactor / Documentation / Question / Bug)

Loaded by SKILL.md Router for complexity ≥ 3. Execute after SKILL.md Step 2 (QA Verification) completes.

**Flow**: §1 Criteria Assessment → §2 Quality Review → return to SKILL.md Step 5 (Pattern Finalization)

---

## §1 Criteria Assessment

### A — Forward Mapping

Each success criterion → evidence → met/partial/not met.

> 📋 Success Criteria Verification
> - [x] {Criterion 1}: ✓ Met — {evidence}
> - [ ] {Criterion 2}: ❌ Not met — {gap}
> - [x] {Criterion 3}: ⚠️ Partially met — {what's missing}
> Result: {X}/{total} criteria met

### B — Reverse Traceability

For each change in ISS ### Changes Made, verify it maps to at least one success criterion. Flag untraced changes.

> 🔄 Reverse Traceability
> | Change | Traces to Criterion | Status |
> |--------|---------------------|--------|
> | {change_1} | {criterion or "infrastructure"} | ✓ |
> | {change_2} | None | ⚠️ Untraced |

Acceptable untraced: infrastructure work (version bumps, registry maintenance) supporting traced changes. Flag anything else.

### C — Known Concerns Check (conditional)

If `.nexus/supporting-files/project-context/CONCERNS.md` exists:
- Check implementation against known project concerns that intersect this issue's scope
- Note addressed concerns for marking as resolved
- Flag worsened concerns or new concerns introduced

### C2 — Convention Compliance Check (conditional)

If `.nexus/supporting-files/project-context/CONVENTIONS.md` exists:
- Read conventions relevant to this issue's scope (e.g., naming, code style, testing patterns for software)
- Check implementation against each applicable convention
- Flag deviations with context: "Convention: {rule}. Implementation: {what was done}. Deviation: {intentional/unintentional}."
- Minor deviations (cosmetic): note but don't block
- Major deviations (structural patterns, naming, testing approach): flag for user decision

### D — Gap Analysis

For unmet criteria or untraced changes:
- Critical or acceptable?
- Address now or track as follow-up?
- Does partial achievement satisfy the issue's intent?
- Do untraced changes indicate scope creep?

### E — Write

Patch ISS [Section: Evaluation-Results] ### Criteria Verification. Update progress marker: `*Evaluation in progress — criteria assessed*`

> **Documentation callout**: Success criteria for documentation are accuracy, completeness, clarity, structure. Forward mapping checks doc accuracy against source. Reverse traceability checks each documented section traces to a real feature/behavior.

> **Question (informational-only) callout**: No implementation to evaluate. Criteria = research questions answered with evidence. Forward mapping: each question → answer + evidence. Reverse: each finding → originating question. Dimensions: Accuracy, Completeness, Clarity, Actionability.

---

## §2 Quality Review

### A — Plan vs Actual Comparison

Compare ISS Solution-Design + Implementation-Plan against Implementation-Log.

> 📊 Plan vs Actual
> Scope: Planned {X} files → Modified {Y}. Match: {yes/diverged}
> Approach: {followed / deviated — details}
> Sequence: {as planned / reordered — reason}
> Risks: {identified} identified, {materialized} materialized, {new} new

### B — Deviation Analysis

For each deviation in ISS ### Deviations:
- Beneficial (improved outcome), necessary (required by circumstances), or avoidable (planning gap)?
- What learning does each deviation provide?

### C — Quality Dimensions (4 dimensions)

| Dimension | Checks | Verdict |
|---|---|---|
| Functional | Core functionality works, features present, tests passing | PASS/PARTIAL/FAIL |
| Integration | Components interact correctly, no breaking changes, dependencies handled, cross-references valid | PASS/PARTIAL/FAIL |
| Standards | Project conventions followed, naming clarity, documentation adequate, section tags if system file | PASS/PARTIAL/FAIL |
| Holistic | System coherence maintained, no regression, ready for use, user can access feature | PASS/PARTIAL/FAIL |

> **Documentation callout**: Replace 4 dimensions with: Accuracy (matches source behavior), Completeness (all topics covered), Clarity (understandable by target audience), Structure (logical organization, findable).

> **Question (informational-only) callout**: No implementation quality to assess. Dimensions: Accuracy (facts correct, sources valid), Completeness (all questions answered), Clarity (findings understandable), Actionability (recommendations concrete, limitations stated).

### D — Technical Debt Check

> 📋 Technical Debt
> {None / List with impact and action: accept / log as issue / fix now}

If significant debt: offer /nexus-create-issue.

### E — Adversarial Pass

Per /nexus-validate §DE Layer §1 Default Adversarial Posture: mandatory at all complexities; depth scales per the per-complexity table in SKILL.md §DE Layer §1.

Invoke /nexus-problem-solving adversarial-review on the implementation as a whole. Focus on:
- Does the combined implementation achieve the Solution Design intent?
- Emergent issues from interaction of changes across files?
- Failure modes that per-file testing wouldn't catch?
- Edge cases: optional sections absent, fields empty, thresholds at boundaries
- Widget compliance: any AskUserQuestion calls have 2-4 options (maxItems constraint)? Option labels concise? No missing "Other" path handling?

Must-find mandate — at least one genuine issue must be surfaced. HIGH findings must be addressed before proceeding.

### E1.5 — Findings Resolution (C:4+ only)

After adversarial pass produces findings, apply structured resolution:

| Severity | Gate behavior |
|---|---|
| HIGH | Must Walk, Fix-downstream, or Source-fix — no Skip **[T2 — all control levels]** |
| MEDIUM | Walk / Fix-downstream / Source-fix / Skip **[T3: Full ask, Balanced notify, Streamlined auto]** |
| LOW | Walk / Fix-downstream / Source-fix / Skip **[T3: same as MEDIUM]** |

For each finding: **[W] Walk** (false alarm), **[F] Fix downstream** (patch the consumer of the rule, re-verify), **[SF] Source-fix at {location}** (extend the canonical rule/registry/skill-table at its source per PAT-103), **[S] Skip** (defer with reasoning).

For C:1-3: existing flow unchanged — findings go directly to Quality Assessment write.

### E2 — Full-File Mental Simulation (C:4+ only)

**Mandatory for complexity ≥ 4.** Mental-simulation-only validation is insufficient for complex multi-file changes.

1. **Load all modified files**: Read each file listed in ISS ### Changes Made (full file, not sections). This ensures the complete current state is in context.
2. **End-to-end mental simulation**: Walk through the system as a fresh instance encountering these files for the first time. Trace the execution path across all modified files. Check: do the changes interact correctly? Are there assumptions in file A that file B doesn't satisfy?
3. **Report findings**: Surface any issues the adversarial pass missed because it operated on sections rather than full files.

This step catches integration issues that per-section review misses — especially when changes span methodology skills, state files, and configuration.

### F — Constitution Compliance

If `[PROJECT_CONSTITUTION]` exists in project-state.md, verify no changes introduced a violation. Report: "Constitution: {all principles respected / violation found: '{principle}' — {evidence}}". Violations are HIGH findings.

### G — Write Results

Patch ISS ### Quality Assessment. Update progress marker: `*Evaluation in progress — quality reviewed*`

> After §2 complete: return to SKILL.md Step 5 (Pattern Finalization).
