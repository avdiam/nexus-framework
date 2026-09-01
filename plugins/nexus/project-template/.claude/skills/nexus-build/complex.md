*Version: 2.2.0 | Date: 2026-08-18 | Sprint: 108*

# Build Thinking Toolkit (Complexity 3+)

Loaded by SKILL.md Router for complexity ≥ 3 issues. Executed in **two phases** with the type file's §1 Implementation section in between:

**Phase 1 (§PRE-TYPE)**: Pattern Matching → Plan Verification → *then type file §1 Implementation runs* →
**Phase 2 (§POST-TYPE)**: Test Execution → Decision Drift → Deferral-Target Validity → Pattern Assessment → Quality Review [A-H: Simulation → Diff → Adversarial → Resolution → Agent Review (opt) → Unified Findings → Standards → Elicitation]

This ordering ensures pattern matching informs implementation, and post-type checks have full implementation context.

**Precedence rule**: When a full cognitive tool or strategic approach is loaded into memory via its skill, the loaded version's complete process takes precedence over inline summaries.

---

## §PRE-TYPE: Pattern Matching

**[T2: Balanced+Full ask | Streamlined: auto-match if C>2 or novel, notify]**

Implementation-phase-oriented pattern matching. Prefer patterns tagged with implementation-phase applicability:

> 📐 Check for implementation patterns?
> Note: prefer patterns applicable to implementation phase (coding patterns, testing patterns,
> integration patterns, refactoring patterns). [Y/n]

If yes: invoke `/nexus-match-pattern`. On return: update sprint-state [PATTERNS_IN_USE].

Zone awareness: pattern matching loads pattern files. Check zone after completion.

> **Mental note**: Patterns: {list or none}. If checkpoint → continue_with captures decisions.

---

## §PRE-TYPE: Plan Verification

**[T2: Balanced+Full ask | Streamlined: auto-proceed if no gaps found, notify]**

"Is the analysis plan still valid?" — plan was T1-approved during Analysis; this is the pre-execution freshness check.

**Bug-type pre-check** (run BEFORE A-G for Bug issues): Before investing in full plan verification, confirm the reproduction environment is still valid. Can you trigger the bug? If yes — proceed with A-G normally. If cannot reproduce — surface immediately **[T2]**: "Cannot reproduce bug in current environment. Options: [Investigate environment / Loop back to Analysis / Mark as cannot-reproduce]." Do NOT complete plan verification on an unreproducible bug — the plan may be invalid.

**A — Integrate pattern guidance**: If patterns loaded, adapt plan to incorporate recommendations.

**B — Verify plan integrity**: File states match plan assumptions? Steps unambiguous? Dependencies correct (producers before consumers)? No outdated structures/paths?

**C — Verify completeness**: Any files affected but not listed? Integration points missing? Run `nexus-build/SKILL.md` [Section: Completeness-Checks] sub-check A — Touchpoint Census, or record its suppression line if not triggered.

**D — Success Criteria Coverage** (goal-backward):
Forward: every criterion → at least one step.
Reverse: every step → at least one criterion.
**Measurability echo**: every criterion → at least one concrete test in the test strategy defined during Orient step D (SKILL.md). A criterion lacking a test that can *measure* it is untestable by the current plan.
Uncovered criteria = plan gap. Uncovered steps = potential gold-plating. Untestable criteria = **loop-back signal**.

**On untestable criterion detected** **[T2: Balanced+Full ask | Streamlined: surface + auto-recommend loop-back, notify]**:

```
⚠️ Criterion not measurable by planned test strategy:
  "{criterion}"
  No test in strategy validates this.

Loop back to Analyze for refinement? [Y / Proceed anyway / Add test to strategy]
```

Rationale: mirrors the create-issue testability gate at the Build contract-negotiation boundary (generator/evaluator contract negotiation — catches untestable criteria that slipped past create-issue OR were added during Analyze refinement without a matching test).

- **Y (loop back)** → invoke `/nexus-loop-back` to Analysis with reason "untestable success criterion — needs measurable rewrite"
- **Proceed anyway** → user accepts the gap; note in ISS ### Deviations: "Criterion '{text}' proceeding without measurable test per user override"
- **Add test to strategy** → user defines concrete test now; append to test strategy, recheck measurability

**E — Key Links Check**: For each component, trace consumer-producer relationships. Verify every created/modified component is wired to its consumers.

**F — Preference Compliance** (conditional — if ### Implementation Preferences exists in ISS): Cross-check plan against locked user decisions from Analysis. Conflicts are blockers.

**G — Present**:
> 📋 Execution Plan Verified
> Plan: N phases, M steps
> Coverage: {all criteria covered / N gaps}
> Key links: {all wired / N missing}
> Preferences: {compliant / N conflicts / N/A}
> Pattern adjustments: {list or "none"}
>
> Ready to execute? [Y/adjust/n]

---

## ⏸️ PAUSE — Execute Type File §1 Implementation Now

Return to type file and execute its §1 Implementation section. The type file will call [Section: Scope-Escalation-Check] (in SKILL.md) after each phase, and [Section: Batch-Transition-Detection] (in SKILL.md) after 2+ repetitive targets.

**Now executing: types/{type}.md §1 Implementation**

Resume here (§POST-TYPE) when type file signals "all phases/sections complete."
**Now executing: complex.md §POST-TYPE** (orientation anchor for return from type file)

---

## §POST-TYPE: Test Execution

Execute all tests defined in Orient test strategy, created during type file implementation. Validate against ISS ## Success Criteria.

**A — Run tests**:
> 🧪 Running Tests
> Test N: {name} — Result: ✓ PASS / ❌ FAIL — Evidence: {description}

**B — Validate against Success Criteria**:
> ✅ Validation Results
> - [x] {Criterion} ✓
> Tests: {passing}/{total} | Overall: {SUCCESS / PARTIAL / FAILURE}

**C — Handle failures** **[T2: Balanced+Full ask | Streamlined: auto-recommend best option, notify]**:
> Options: [Debug and fix (return to type file) / Adjust test expectations (document) /
>           Document as known limitation]
If failures suggest approach is flawed → offer /nexus-loop-back.

**D — Update ISS**: Patch Implementation-Log ### Tests Created — executed column with results.

**E — Relocation-Citation Check**: Run `nexus-build/SKILL.md` [Section: Completeness-Checks] sub-check B — Relocation-Citation Resolution for any relocate-with-citation edits made this issue; skip silently if none.

**Creative-type adaptation**: Test execution = audience-fit review + coherence scan across all sections + accuracy vs creative brief. No automated tests.

**Bug-type structure**: Two distinct passes are mandatory (not optional):
1. Bug test: reproduce original scenario → confirm bug is gone
2. Regression pass: broader test → confirm fix didn't break existing behavior

---

## §POST-TYPE: Decision Drift Detection

**[T2: Balanced+Full ask | Streamlined: auto-realign if clear, notify]**

Timing: runs once here, after all implementation phases complete. (Not per-phase — the per-phase trigger is [Section: Scope-Escalation-Check] in SKILL.md.)

Re-read ISS ### Key Decisions and ### Implementation Preferences (if exists). Compare against completed implementation.

> 🔍 Decision Alignment Check
> Key Decisions from Analysis:
> ✓ {decision_1}: aligned
> ⚠️ {decision_2}: drifted — {evidence}
>
> Options: [Realign to original / Update decision with rationale / Accept drift with deviation]

**Creative-type adaptation**: Check against ISS ### Approach (creative brief). Did tone, audience, or purpose drift? "Content drifted from original brief: [Realign / Update brief / Accept]"

If no drift: silent pass — note in mental note only.

---

## §POST-TYPE: Deferral-Target Validity

**[T3: Full ask on warning | Balanced: surface + notify | Streamlined: surface + log]**

Timing: runs once here, after Decision Drift Detection, before Pattern Assessment.

**Scope note**: relocate-with-citation sub-anchor resolution is `nexus-build/SKILL.md` [Section: Completeness-Checks] sub-check B's job (§POST-TYPE Test Execution E), not duplicated here — this check covers dangling deferrals to a *phase/conversation/sprint/issue* target, a distinct failure mode from a citation's sub-anchor not resolving.

Scan ISS Implementation-Log ### Deviations and ### Issues Encountered for entries that **defer work to a named target** (a later phase, conversation, sprint, or issue). **No deferrals logged → silent pass** (one-line "No deferrals to validate"). Origin: ISS-189 SI-2 dangling-deferral anti-pattern (Sprint 094) — a deferral named "Phase D," but Phase D rebuilt a *different* file, so the deferred cleanup was silently lost until Validate caught it.

For each deferral that names a target:

1. **Identify** the deferred artifact (file/section) and the named target.
2. **Resolve the target's scope**:
   - *Intra-plan phase target* (e.g., "Phase D") → read that phase's Files-Affected / objectives from ISS Implementation-Plan.
   - *Forward target with no enumerable scope* (e.g., "Validate", "next sprint", a not-yet-planned issue) → scope cannot be resolved here.
3. **Verdict**:

| Condition | Verdict |
|---|---|
| Target scope resolved AND includes the deferred artifact | ✓ valid (one-line confirm) |
| Target scope resolved AND excludes the deferred artifact | ⚠️ dangling deferral (warn) |
| Target scope not enumerable | ⓘ cannot verify — "{target} scope not enumerable; ensure the deferred artifact is tracked where it lands" |

⚠️ Warning format (surface, do **not** block):

> ⚠️ Dangling deferral
>    Deferred artifact: {file/section}
>    Named target: {target} — actual scope: {what the target covers}
>    Mismatch: target scope does not include the deferred artifact.
>    → Deferred work may be silently lost. Re-target the deferral, fold the
>      artifact into {target}'s scope, or track it explicitly (new ISS /
>      Validate hand-off).

This is a warning, not a hard block — surfacing it satisfies the check; resolution is the user's call (consistent with the notify-tier §POST-TYPE checks above).

---

## §POST-TYPE: Pattern Assessment

**[T3: Full ask | Balanced: notify | Streamlined: auto-assess, log]**

Skip if no patterns applied (check sprint-state [PATTERNS_IN_USE] for this issue).

For each applied pattern: assess implementation outcome — verdict {helped / neutral / hindered / not yet clear} with a one-line evidence note (NOT auto-success). If clear: update sprint-state [PATTERNS_IN_USE] status + ISS ### Pattern Outcomes with evidence. If not clear: leave as "applied" — /nexus-validate makes final assessment. (Verdict taxonomy: pattern-specification.md → Outcome Verdicts; close-issue STEP 2A applies the dedup hard-gate at authoritative capture.)

---

## §POST-TYPE: Quality Review

**[T3 smart logic with T2 escalation on HIGH findings]**

### A — Mental Simulation (always)

Walk through implementation as a fresh Claude instance. Does it work correctly in the broader system? Interaction effects? Data flow correct?

### B — Git Diff Summary

Run `git diff` (or `git diff --stat` for overview + targeted `git diff {file}` for details). This produces the change summary used by both the self-adversarial review (C) and the optional independent agent review (E).

> 📋 Changes Summary
> Files modified: {count}
> {file list with +/- line counts}

### C — Adversarial Review (mandatory C:3+)

Apply must-find mandate — at least one genuine issue must be surfaced. Use /nexus-problem-solving adversarial-review if not already loaded. Use the git diff from step B to focus attention on actual changes.

Focus dimensions:
- Correctness against ISS Solution Design intent
- Completeness of integration points (consumers reference producers correctly?)
- Consistency with existing conventions
- Robustness under edge cases (optional sections absent, fields empty, thresholds at boundaries)
- Confirmation bias: did we only verify happy paths?
- Anchoring: attached to approach when evidence suggests better?
- Tool/schema constraints: AskUserQuestion widgets have option count within [2, 4] bounds (maxItems constraint — F-V1 regression in ISS-146 was a 5-option widget); other tool schemas within documented limits

**Bug-type mandatory dimensions**: (1) Root cause vs symptom — did we fix the root cause or patch a symptom? (2) Regression — did the fix introduce new breakage?

**Creative-type dimensions**: Tone consistency end-to-end, audience-fit, does content serve the original purpose, narrative coherence.

### D — Findings Resolution

Walk through each finding from the adversarial review. Structured resolution per severity:

| Severity | Gate behavior |
|---|---|
| HIGH | Must Walk, Fix-downstream, or Source-fix — no Skip **[T2 — all control levels]** |
| MEDIUM | Walk / Fix-downstream / Source-fix / Skip **[T3: Full ask, Balanced notify+auto-recommend, Streamlined auto-resolve+log]** |
| LOW | Walk / Fix-downstream / Source-fix / Skip **[T3: Full ask, Balanced notify, Streamlined silent+log]** |

For each finding: **[W] Walk** (explain why it's not an issue — false alarm), **[F] Fix downstream** (patch the consumer of the rule, re-verify the specific change), **[SF] Source-fix at {location}** (extend the canonical rule/registry/skill-table at its source per PAT-103 — name the location and the one-line addition), **[S] Skip** (defer with documented reasoning in ISS Issues Encountered).

Fix HIGH before proceeding. After fixes, re-verify the specific changes only — do not re-run the full adversarial review.

### E — Independent Agent Review (Optional)

**Trigger**: Offer when C:4+ AND changes touch core/structural/architectural files. Skip offer for C:3 or routine changes.

**[T2: Balanced+Full ask | Streamlined: auto-recommend if C:4+ structural, notify]**

```
🤖 Dispatch independent reviewer? Fresh perspective on your changes.
Mode: 1× sonnet agent (Quick) | 3× opus agents (Thorough)
[Quick / Thorough / Skip]
```

**Diff refresh** (conditional): If any fixes were applied during Step D (Findings Resolution), re-run `git diff` to capture post-fix state. Use this updated diff for agent input. If no fixes in D, use original diff from Step B.

**Quick mode**: Dispatch 1 agent with full scope. Input: ISS (requirements + criteria), git diff (refreshed if fixes applied, otherwise from step B), applied patterns. NO build reasoning per PAT-095.

**Thorough mode**: Dispatch 3 agents, each with a focus lens:

| Agent | Focus Lens | Looks for |
|---|---|---|
| 1 | Spec Compliance | Missing criteria, incomplete implementation, spec drift |
| 2 | Edge Cases | Boundary conditions, empty inputs, error paths |
| 3 | Architectural Fit | Convention violations, integration issues, dependency direction |

On dispatch: override model to opus for Thorough. Read `<usage>` total_tokens from each → add to agent running total.

On skip: proceed to step G.

### F — Unified Findings (if agent ran)

Merge self-adversarial findings (unresolved from D) with agent findings:

1. Agent finding matches already-resolved self-adversarial finding → `(confirmed — already resolved)`
2. Agent finding matches unresolved self-adversarial finding → merge, note both sources
3. Agent-only findings → new entries (the isolation wins — what main context missed)

```
📋 Unified Findings
═══════════════════════════════════════
Self-review findings (unresolved): {N}
Agent-only findings (new): {N}
Confirmed (already resolved): {N}
───────────────────────────────────────
1. [{severity}] {description} — source: {self|agent|both}
   Suggestion: {fix}

Resolution: [Walk / Fix-downstream / Source-fix / Skip] per finding
═══════════════════════════════════════
```

Agent-only findings count is the concrete measure of isolation's benefit (PAT-095 effectiveness tracking).

### G — Standards Verification

Review standards flagged in preflight. Verify each followed.

### H — Post-Implementation Elicitation (C:3+)

One additional perspective before transition.

| Context signal | Suggest |
|---|---|
| Many files modified (>5) | Systems Thinking |
| Deviations from plan | Blind Spot Check |
| Implementation went smoothly/fast | Inversion — what are we not seeing? |
| Architectural decisions made during build | Pre-mortem |

> 🔄 One more perspective before transition?
> Suggested: {tool} — {reason}
> [Apply / Proceed]

---

After §POST-TYPE completes: return to SKILL.md → [Section: End-of-Workflow-Checklist] → [Section: Commit-Protocol] → [Section: Transition].
**Now executing: SKILL.md finalization** (orientation anchor for return from §POST-TYPE)
