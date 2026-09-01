*Version: 1.5.0 | Date: 2026-06-11 | Sprint: 101*

# Analysis — Bug Type

Loaded by SKILL.md Router for bug-type issues, complexity ≥ 3.

**Flow**: Investigate → Design → **[T1] Choice** → Plan → **[T1] Plan Approval** → [Section: Commit-Protocol] → Transition

**Key difference from default**: Investigate prioritizes reproduction and root cause. Design often produces single recommended fix.

---

## 1. Investigate

Focus: reproduction and root cause identification.

### A — Context Artifacts (conditional)

Same as default — check `.nexus/supporting-files/project-context/` for CONTEXT.md, STRUCTURE.md, CONCERNS.md.

### B — Reproduction Focus

Priority: reproduce the bug or understand trigger conditions.
- Exact steps to trigger?
- Expected behavior vs actual behavior?
- Consistent or intermittent?
- Environment/conditions required?

If complexity ≥ 3: suggest `/nexus-problem-solving root-cause` for structured investigation.

### C — Root Cause Investigation

Trace the bug to its fundamental cause:
- Follow execution path from trigger to symptom
- Identify where behavior diverges from expected
- Check for related issues or similar bugs (use Grep)
- Determine if this is a symptom of a deeper systemic issue

### C2 — Scope Discovery (Conditional)

Run [Section: Scope-Discovery] in references/scope-investigation.md. The trigger condition is checked there — if the registry `ISS-XXX.scope_files` and ISS `### Files Affected` are both empty/broad AND `_project_type: code`, the discovery loop runs. Bug context is particularly suited to scope discovery because root cause investigation often surfaces the *symptom* file, but the *consumers* and *related call sites* may not be obvious without the loop.

### C3 — Scanner Offer (Conditional)

After Scope-Discovery completes, run [Section: Scanner-Offer] in references/scope-investigation.md. For bugs at complexity ≥ 3, the scanner can be especially valuable — root cause sometimes touches files the inline grep doesn't surface (e.g., where a bad value originates vs where it manifests). Always opt-in.

### C4 — Cross-Cutting Checklist (Conditional)

Run [Section: Cross-Cutting-Checklist] in references/scope-investigation.md. The trigger is checked there — when a bug fix retires/renames/adds a cross-cutting concept (a named token recurring across file-classes), it adds 4 non-skill file-classes (hooks, supporting-files/architecture, Emergency-Reference, templates) to the Files Affected enumeration. No-op for a localized single-file fix. Complementary to Scope-Discovery (concept-shape grep vs empty-scope keyword convergence).

### D — File State Verification (MANDATORY)

Verify actual file states. Confirm the bug exists as described. Check if a fix already exists but wasn't applied.

### E — Gap Identification

> 📊 Bug Analysis
>
> Symptom: {what the user sees}
> Root cause: {identified or hypothesized}
> Affected files: {list}
> Fix approach: {initial assessment}
> Regression risk: {what could the fix break?}

---

## 2. Design & Options

Bug fixes often have a single clear fix. Still present alternatives when viable.

### A — Fix Options

> **Option A**: {targeted fix — address root cause directly}
> Files: {list}. Approach: {what changes}. Risk: {regression potential}.
>
> **Option B**: {alternative — e.g., comprehensive fix, workaround, or different approach}
> Files: {list}. Approach: {what changes}. Risk: {regression potential}.
>
> **My recommendation: Option {X}**
> **Reasoning**: {root cause vs symptom fix analysis}

For single clear fix: present it with confidence, but mention "Alternative considered: {why rejected}."

### B — Strategic Reflection

- Is this truly the root cause or just a symptom?
- Could this fix introduce new bugs?
- Is there a pattern of similar bugs suggesting a systemic issue?

### C — Post-Generation Elicitation (complexity ≥ 3)

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

---

## 3. Choice Selection

**[T1: all levels ask]** Present fix options with recommendation. Wait for user choice.

---

## 4. Planning & Feasibility

Self-contained planning flow: Impact Mapping → Regression Risk → Sequencing → Plan Validation → Feasibility. Bug-specific emphasis: regression safety and reproduction-driven sequencing.

### A — Impact Mapping

> 📋 Impact Analysis
> Direct changes: {file list with what changes}
> Cascade effects: {what triggers what}
> Breaking changes: {yes/no with details}
> Estimated effort: {estimate}
> Risk: {Low/Medium/High with reasoning}

**Calibration — size/effort estimates for SKILL.md sections**: Conditional-read blocks, derivation tables, and new SKILL.md / complex.md sections routinely run **+100–200% over initial line estimates**. Budget accordingly. Evidence: ISS-146 Phase 1 estimated ~140 lines, actual ~261 (+88%); Phase 2 estimated ~36 lines, actual ~128 (+260%). Rule of thumb: for any conditional/derived content, multiply naive estimates by 2–3× before committing to effort projections.

### B — Regression Risk (bug-specific focus)

Explicitly address:
- What could the fix break? Map all consumers of changed code.
- What test coverage exists? What tests need adding?
- Is there a safe rollback path?

### C — Sequencing

Bug fixes often follow: understand → fix → test → verify regression safety. Map producers before consumers — upstream/foundation first. Phases should reflect this.

### D — Plan Validation

Challenge the plan before presenting:
- **Dependency check**: Producers before consumers?
- **Effort realism**: Add ~10% margin. What if the hardest phase takes 2×?
- **Risk concentration**: Highest-risk phase — does its failure collapse the plan?
- **Blind spot check**: Anchored to first sequencing? Would different ordering be more resilient?
- **Pre-mortem check**: Assume the plan already failed — 3 most likely causes? (Invoke /nexus-problem-solving pre-mortem-analysis when stakes warrant.)

If issues found: adjust directly.

### E — Feasibility & Scope Assessment

**E1 — Structural feasibility**: Verify files exist. Check section markers if editing sections. Verify producer→consumer ordering.

**E2 — Scope feasibility**:

| Check | Concern | Action |
|---|---|---|
| Phases span 3+ conversations | Context budget risk | Flag — unless repetitive → Build batch mode territory |
| Plan complexity > issue complexity × 2 | Underestimated scope | Flag |
| Multiple methodology transitions | Coordination overhead | Flag |

**E3 — Decompose signal scan** per CLAUDE.md [Section: Decompose-Signals]: 3+ signals → strongly suggest. 2 → mention. 1 → don't suggest.

**E4 — Present findings** (only if issues found):

| Finding | Options |
|---|---|
| Structural issues | [Adjust plan / Verify manually / Proceed anyway] |
| Scope concerns | [Adjust plan / Accept risk / Proceed anyway] |
| Strong decompose signals | [Decompose now / Continue / Adjust plan] |
| Repetitive work detected | [Continue with Build / Switch to Apply / Adjust] |

If "Decompose now": invoke /nexus-decompose-issue — control transfers. If "Switch to Apply": note in plan, Apply transition during Build.

---

## 5. Plan Approval

**[T1: all levels ask]** Same as default — present plan with recommendation.

On approval: → [Section: Commit-Protocol], then Transition.

---

## 6. Transition

**[T3: Full ask | Balanced: notify | Streamlined: silent]**

Same as default — run checklist, score, two-place update, load /nexus-build or defer.

**Step 0 — Readiness Gate**: Run [Section: Readiness-Gate] in references/readiness-gate.md with branch `bug`. The bug branch adds explicit checks for regression risk addressed in Risks & Mitigations and reproduction steps documented. On PASS, proceed with the standard transition (two-place update, focus update, context-aware loading). On CONCERNS, follow the gate's branching. On FAIL, do not transition — return to the routed step per gate output.

> ✅ Analysis → Implementation (Bug Fix)
> • Root cause: {identified}
> • Regression risk: {assessed}
> • Score: {X}/5

**On decline**: Ask what needs attention. Offer: revisit root cause analysis, additional investigation, alternative fix approach.

**User override**: If user says "fix now" with score < 4, warn about incomplete root cause analysis but proceed if insisted.
