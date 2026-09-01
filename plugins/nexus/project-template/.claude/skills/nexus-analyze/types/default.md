*Version: 1.5.1 | Date: 2026-08-20 | Sprint: 110*

# Analysis — Default Type (Feature / Improvement / Refactor / Documentation)

Loaded by SKILL.md Router for complexity ≥ 3. Execute after complex.md completes.

**Flow**: Investigate → Design → **[T1] Choice** → Plan → **[T1] Plan Approval** → [Section: Commit-Protocol] → Transition

---

## 1. Investigate

Comprehensive investigation informed by the thinking toolkit (complex.md outputs). Read Implementation Preferences if captured — locked decisions constrain direction.

### A — Context Artifacts (conditional)

Check if `.nexus/supporting-files/project-context/` exists:

| Artifact | If exists | Use for |
|---|---|---|
| CONTEXT.md | Read `## Overview` + relevant sections | Prior work, dependencies, integrations |
| STRUCTURE.md | Read `## Overview` + relevant sections | Organization, module boundaries, data flow |
| CONCERNS.md | Read full file | Flag entries relevant to current scope |

If CONCERNS.md has relevant entries: "⚠️ Known concern: {concern} — consider in design."

### B — Archaeological Discovery (MANDATORY)

Search existing before creating new. 80–95% of "new" features already exist dormant. Use Grep/Glob to find similar features, dormant solutions, adaptable implementations. Evaluate adapting existing vs building new.

**Audit-type issues**: initial grep should default to `.claude/skills/` (broader than the ISS-described directories); narrow at the Choice gate after surveying surface area. Insurance against canonical sources outside the described scope (SEED-024, origin ISS-182).

### B2 — Scope Discovery (Conditional)

Run [Section: Scope-Discovery] in references/scope-investigation.md. The trigger condition is checked there — if the registry `ISS-XXX.scope_files` and ISS `### Files Affected` are both empty/broad AND `_project_type: code`, the discovery loop runs (LLM-extracted seed → user adjusts → autonomous loop with safety valve → sync to registry + ISS). Otherwise this sub-step is a no-op.

### B3 — Scanner Offer (Conditional)

After Scope-Discovery completes, run [Section: Scanner-Offer] in references/scope-investigation.md. The trigger conditions are checked there — the scanner is offered only when complexity ≥ 3 AND inline output is thin/safety-valve/low-confidence. Otherwise the offer is suppressed. Always opt-in.

### B4 — Cross-Cutting Checklist (Conditional)

Run [Section: Cross-Cutting-Checklist] in references/scope-investigation.md. The trigger is checked there — for issues that retire/rename/add a cross-cutting concept (a named token recurring across file-classes), it adds 4 non-skill file-classes (hooks, supporting-files/architecture, Emergency-Reference, templates) to the Files Affected enumeration. No-op for simple single-file additive work. Complementary to Scope-Discovery (concept-shape grep vs empty-scope keyword convergence).

### C — File State Verification (MANDATORY)

Verify actual file states. Confirm described changes don't already exist. Validate current names, signatures, structures. Note discrepancies between description and reality.

### D — Research Approach

If Hypothesis-Driven Framework was loaded (complex.md § Tools):

> Analysis approach:
> A) Standard exploration (open-ended)
> B) Hypothesis-driven (structured testing) 🧪
>
> Given {context}, I recommend: {A or B}

If hypothesis-driven: formulate hypothesis with test procedure, execute, evaluate.

### E — External Research (when triggers match)

Check: novel technology? Need best practices? Documentation beyond loaded files? If so: use WebSearch. If unavailable, prompt user for information.

### F — Gap Identification

> 📊 Gap Analysis
>
> Current state: {what exists}
> Required state: {what we need}
> Gaps: {list}
> Dependencies: {blockers discovered}

**Type-specific notes:**
- **Refactor**: Include quality metrics (maintainability, readability, performance). Map current-state → target-state with before/after dimensions.
- **Documentation**: Scope mapping — which docs exist, what's outdated, what's missing.

---

## 2. Design & Options

Generate solution options informed by complex.md synthesis. Present with recommendation.

### A — Topic Enumeration

Enumerate all decision topics:

> For this {issue_type}, we need to decide:
> 1. {Topic_A} — {brief}
> 2. {Topic_B} — {brief}

### B — Per-Topic Resolution

For each topic, two stages:

**Stage A (Architecture)**: High-level direction options with recommendation. Wait for user choice.
**Stage B (Implementation)**: Specific implementation suggestions for chosen direction. Wait for user choice.

**[T2: Balanced+Full ask | Streamlined: auto-select best-fit per topic, notify]** Design sub-decisions.

Track progress:
> 📋 Progress:
> ✓ Topic 1: {decision}
> → Topic 2: (discussing now)

### C — Synthesis

After all topics resolved:

> 🎯 Design Complete — Summary
>
> Decisions made:
> 1. {topic}: {decision}
> 2. {topic}: {decision}
>
> Strategic approach: {SA_name or "standard"}
> Patterns applied: {PAT list or "none"}

### D — Strategic Reflection

Validate through dual-perspective thinking. Use /nexus-strategic strategic-reflection if loaded, otherwise:

- What am I optimizing for? What am I sacrificing?
- What could go wrong? 10% failure scenario?
- Does this create technical debt?
- Is this the simplest approach that works?

If confidence >85%: run blind spot check (confirmation, anchoring, authority, recency bias).

### E — Post-Generation Elicitation

Before user commits, offer one re-examination pass through an unused cognitive lens:

| If unused | Suggest when |
|---|---|
| Systems Thinking | Options with different integration implications |
| Inversion | High confidence (>85%) — check what could fail |
| Pre-mortem | High-stakes or hard-to-reverse decision |
| Analogical Reasoning | Novel domain |
| Blind Spot Check | Strong anchoring risk |
| Mental Simulation | Complex workflows or multi-file changes |

> 🔄 Challenge these options before deciding?
>
> Suggested lens: {tool} — {one-line reason}
> [Apply suggested / Pick different / Proceed to choice]

If applied: focused pass (~2-3 paragraphs) on the *options*, not the original problem. Re-display with insights.

### F — Recommendation

Every option set MUST include "My recommendation: Option X" with strategic reasoning. "Simpler" is too vague. "Addresses core issue with 70% less complexity while maintaining extensibility" is adequate.

**Type-specific notes:**
- **Refactor**: Include quality dimensions in options. Track before/after metrics.
- **Documentation**: Skip Architecture subsection. Options focus on structure/organization.

---

## 3. Choice Selection

**[T1: all levels ask]** Present options with LLM recommendation. Wait for explicit user selection. Never proceed without user choice.

On selection: "✓ Selected: Option {X}". Record choice.

---

## 4. Planning & Feasibility

### A — Impact Mapping

> 📋 Impact Analysis
>
> Direct changes: {file list with what changes}
> Cascade effects: {what triggers what}
> Breaking changes: {yes/no with details}
> Estimated effort: {estimate}
> Risk: {Low/Medium/High with reasoning}

**Calibration — size/effort estimates for SKILL.md sections**: Conditional-read blocks, derivation tables, and new SKILL.md / complex.md sections routinely run **+100–200% over initial line estimates**. Budget accordingly. Evidence: ISS-146 Phase 1 estimated ~140 lines, actual ~261 (+88%); Phase 2 estimated ~36 lines, actual ~128 (+260%). Rule of thumb: for any conditional/derived content, multiply naive estimates by 2–3× before committing to effort projections.

### B — Complexity Adjustment

If cascade is larger than expected: inform user, offer options — continue current approach, reconsider simpler option, or break into smaller issues.

### C — Implementation Sequencing

1. Map file relationships — identify producers and consumers. Which MUST change first?
2. Determine order — upstream/foundation first.
3. Define phases — each with objective, files, verification, "complete when" condition.
4. Verify sequence — each phase's dependencies satisfied by previous phases.

### D — Plan Validation

Challenge the plan before presenting:

- **Dependency check**: Producers before consumers?
- **Effort realism**: Add ~10% margin. What if hardest phase takes 2x?
- **Risk concentration**: Highest risk phase — does failure collapse the plan?
- **Blind spot check**: Anchored to first sequencing? Would different ordering be more resilient?
- **Pre-mortem check**: Assume this plan has already failed — what are the 3 most likely causes? (Invoke /nexus-problem-solving pre-mortem-analysis for full structure when stakes warrant it.)

If issues found: adjust directly.

### E — Feasibility & Scope Assessment

**E1 — Structural feasibility**: Verify files exist. Check section markers if editing sections. Verify producer→consumer ordering.

**E2 — Scope feasibility**:

| Check | Concern | Action |
|---|---|---|
| Phases span 3+ conversations | Context budget risk | Flag — unless repetitive → Build batch mode territory |
| Plan complexity > issue complexity × 2 | Underestimated scope | Flag |
| Multiple methodology transitions | Coordination overhead | Flag |

**E3 — Decompose signal scan** per [Section: Decompose-Signals]:
3+ signals → strongly suggest. 2 → mention. 1 → don't suggest.

**E4 — Present findings** (only if issues found):

| Finding | Options |
|---|---|
| Structural issues | [Adjust plan / Verify manually / Proceed anyway] |
| Scope concerns | [Adjust plan / Accept risk / Proceed anyway] |
| Strong decompose signals | [Decompose now / Continue / Adjust plan] |
| Repetitive work detected | [Continue with Build / Switch to Apply / Adjust] |

If "Decompose now": invoke /nexus-decompose-issue — control transfers.
If "Switch to Apply": note in plan, Apply transition during Build.

### F — Present Validated Plan

> 📋 Implementation Sequence
>
> Phase 1: {name} ({estimate})
> Objective: {what this achieves}
> Steps: {numbered list}
> Verify: {how to confirm}
>
> Phase 2: ...
>
> Critical path: {bottlenecks}
> Feasibility: {passed / adjusted — what changed}

---

## 5. Plan Approval

**[T1: all levels ask]** Present complete plan with LLM recommendation.

> Plan ready:
> - Approach: {from Choice}
> - Strategic approach: {SA_name or "standard"}
> - Phases: {count} | Files: {count}
> - Risks: {key risks}
>
> Approve? [Y/n/adjust]

On approval: → execute [Section: Commit-Protocol] in SKILL.md, then return here for Transition.
On decline: ask what needs adjustment. On adjust: modify specifics, re-present.

---

## 6. Transition

**[T3: Full ask | Balanced: notify action taken | Streamlined: silent]**

After [Section: Commit-Protocol] completes:

Run [Section: End-of-Workflow-Checklist]. Calculate score (4 = well analyzed, 5 = comprehensive).

**Step 0 — Readiness Gate**: Run [Section: Readiness-Gate] in references/readiness-gate.md with branch `default`. On PASS, proceed to step 1 below. On CONCERNS, follow the gate's branching (Acknowledge / Fix / Decompose). On FAIL, do not execute steps 1+ — return to the routed step per gate output.

Then execute:

1. Two-place score update per [Section: Two-Place-Update-Protocol]
2. Update sprint-state current_focus to 'implementation'
3. Context-aware loading:
   - < 70%: checkpoint, load /nexus-build
   - 70–80%: checkpoint, load if viable
   - > 80%: final checkpoint, defer to next conversation

> ✅ Phase Transition Complete
> Analysis → Implementation
> • Score: {X}/5 (updated in 2 places)
> • Next: /nexus-build {loaded or deferred}

**On decline**: Ask what needs attention. Offer: revisit decisions, additional research, change approach. User can say "go back" to return to earlier steps.

**User override**: If user says "implement now" with score < 4, warn about gaps but proceed if insisted.
