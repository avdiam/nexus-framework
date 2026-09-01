*Version: 1.5.1 | Date: 2026-06-21 | Sprint: 106*

# Research — Adoption Mode

**Flow**: Survey → Investigation (dual-track) → Analysis → Deliverable → Decision → return to SKILL.md [Section: Commit-Protocol]

Evaluating whether to adopt a specific technology, framework, approach, or practice.
Core question: "Should we adopt X?" → Adopt / Adapt / Defer / Skip.

**Key differences from other modes**:
- **Dual-track investigation** — candidate (external web research) AND current approach (local codebase audit) investigated in parallel
- **Criteria-based evaluation grid** — candidate vs current approach, per criterion
- **Decision produces action items** — Adopt/Adapt typically spawns implementation issues

## Step 2: Survey

Map the landscape around the adoption candidate.

### A — External Search

Run [Section: Agent-Dispatch] in SKILL.md. On accept, dispatch up to 3 agents (haiku, survey focus) in parallel:

Agent 1 — Candidate profile:
  "Research {candidate} broadly. Find official docs, community reception,
   maturity, adoption status, key capabilities and limitations.
   Return: structured summary per Survey output format."

Agent 2 — Alternatives landscape:
  "Search for alternatives to {candidate} in the {domain} space.
   What else exists? How do they compare at a high level?
   Return: structured summary per Survey output format."

Agent 3 (if candidate is external tech) — Current approach equivalent:
  "Research {current approach technology} broadly. Official docs,
   community status, known strengths/weaknesses.
   Return: structured summary per Survey output format."

On skip: sequential WebSearch calls for each axis above.

### B — Local Codebase Search

Regardless of environment:
- Glob/Grep for current approach implementation files
- Identify: architecture, patterns used, integration points
- Map what would be affected by adoption

### C — Source Quality Triage

Categorize per [Section: Source-Quality]. Flag primary sources for Investigation.

### D — Landscape Summary

Present findings. Check for loop-back signals:
⟳ **Loop-back check**: Is the candidate viable? Does it exist as described? Is the evaluation target correct?
If signal fires: suggest loop-back to Analysis. **[T2: only if triggered]**

**[T3: Survey sufficiency]** — Continue to Investigation?

### E — Zone Check

Check context usage. Yellow/Red → checkpoint.

> **Mental note**: Survey complete. {N} sources found for candidate, {M} for current approach. Key: {top findings}. Priority sources: {list}. If checkpoint → update ISS Findings Summary, write survey report if substantial.

---

## Step 3: Investigation

Two parallel tracks — candidate (external) vs current approach (internal).

> 📋 Investigation Plan
> This conversation: {candidate investigation + current approach audit}
> Remaining: {what's left for subsequent conversations, if any}
> Tracks: 2 (candidate external, current approach internal)

### A — Candidate Investigation (External)

Run [Section: Agent-Dispatch] in SKILL.md. On accept, dispatch 1 agent (sonnet, investigation focus):

  Prompt: "Deep dive {candidate} on these evaluation criteria:
    {criterion 1}: {what to evaluate}
    {criterion 2}: {what to evaluate}
    Read primary sources via WebFetch. Extract specific evidence.
    Return: structured findings per Investigation output format."

On skip: WebFetch for deep candidate investigation.

### B — Current Approach Audit (Internal)

Run [Section: Agent-Dispatch] in SKILL.md. On accept, dispatch 1 agent (sonnet, investigation focus):

  Prompt: "Audit current project's approach to {area}:
    Search codebase for: {patterns, files, functions}
    Read key implementation files.
    Assess per these criteria: {same criteria as candidate agent}
    Return: structured findings per Codebase Audit output format."

### C — Save Reports

**[T2: Balanced+Full ask | Streamlined: save synthesized only, notify+log]**

"Agent reports ready. Save full reports to Sprints/XXX/ for manual reading,
 or only the synthesized summary?"

If full: write ISS-XXX-investigation-candidate.md and ISS-XXX-investigation-current.md
Always: write synthesized summary to main context for Analysis.
Update ISS Findings Summary with thin summary + pointers to Sprint files.

### D — Scope Reality Check (after first track completes)

After first investigation results return, assess: Is the scope still right given actual depth?
If topic is far deeper/broader than anticipated: surface before investing more conversations.
> "Investigation reveals {signal}. Scope adjustment needed? [Adjust / Continue as planned]"

### E — Quality Check

- Comparable depth on both tracks? (Adoption requires fair comparison)
- Primary sources on both sides?
- Checked opposing viewpoints?
Per [Section: Bias-Avoidance].

### F — Loop-Back Check

⟳ Do evaluation criteria apply to this technology? Is the candidate fundamentally different than assumed?
If signal fires: **[T2: only if triggered]** — suggest loop-back to Analysis.

### G — Zone Check + Continuation

**[T3: Investigation continuation]** — Both tracks complete? Proceed to Analysis.
Check context. Yellow/Red → checkpoint. Multi-conv: each track can be a separate conversation.

> **Mental note**: Investigation complete. Candidate: {key findings}. Current approach: {key findings}. Reports: {Sprint file paths}. If checkpoint → verify reports on disk, update ISS thin summary + pointers.

---

## Step 4: Analysis

Build criteria-based evaluation. Cross-reference candidate vs current approach.

### A — Load Investigation Data

Load Sprint report files if not in context (multi-conv resumption).

If Research methodology is resumed mid-phase (Phase 4 Analysis after Phase 3 Investigation completed in prior conversation): Orient §C.1 Primary-Source Verification Gate MUST have cleared before this step. If Orient was skipped or the gate was not emitted, halt Phase 4 and return to Orient.

**Enumeration specific to Adoption mode**:
- `Sprints/{sprint}/ISS-{XXX}-survey.md` (Phase 2)
- `Sprints/{sprint}/ISS-{XXX}-investigation-{source}.md` (Phase 3, one per source)
- `Sprints/{sprint}/ISS-{XXX}-phase3-synthesis.md` (if synthesis was separated — is feedstock, NOT a substitute for primaries)
- `Sprints/{sprint}/ISS-{XXX}-template-candidates.md` or similar extraction annexes (also feedstock)

Synthesis files + annexes are NOT substitutes for primaries. They encode the synthesizing author's framing — analytical verdicts reasoning from synthesis alone can ossify that framing.

### B — Build Evaluation Grid

For Adoption mode, Evaluation Grid has TWO dimensions:

**B1. Criterion × Candidate/Current grid** (existing):

| Criterion | Candidate | Current Approach | Gap | Verdict |
|---|---|---|---|---|
| {criterion 1} | {evidence} | {evidence} | {what changes} | {better/worse/neutral} |

**B2. Deliverable-Component Roster** (new — required if Adoption produces template/deliverable outputs):

When the Adoption's output includes concrete deliverables (templates, skill revisions, new files), build an explicit **deliverable-component roster**:

| # | Component | Source(s) | Target slot in NEXUS | Adoption verdict | Rationale |
|---|---|---|---|---|---|
| 1 | {element from external source} | {source name} | {where it lands in the deliverable} | Extract / Adapt / Reference / Discard | {NEXUS-gap citation} |

**Distinction from B1**: B1 answers "should we adopt?" at the mode level. B2 answers "which specific elements go where?" at the deliverable level. Both required for Adoption when templates/skills are in scope.

**Failure mode prevented**: Phase 3 synthesis organized around themes (research-output frame) rather than components (deliverable frame). Thematic synthesis reads "complete" but under-specifies what actually lands in the deliverable. B2 prevents this failure.

**Writing B2**: Use the NEXUS baseline denominators (Phase 2 Q2 — the structural commonalities of current NEXUS files in scope) as the row structure. Each external-source element evaluated against those denominators. This is the archaeological-discovery lens applied structurally, not just as context.

**Case study reference** (ISS-159 Conv 5): synthesis produced ~6 components; deliverable-component annex (post-hoc) produced 33. B2 prevents the gap.

### C — Assess Adoption Dimensions

Beyond criteria: fit gaps, integration effort, migration risk, learning curve, adaptation path.
What adapts cleanly from candidate to current architecture?
What needs significant rework?

### D — Quality Check

Per [Section: Bias-Avoidance]. Every claim supported by evidence? Confirmation bias checked?

### E — Loop-Back Check

⟳ Problem fundamentally misframed? Criteria invalid given what we learned?
If signal fires: **[T2: only if triggered]**.

### F — Post-Analysis Elicitation

Before writing deliverable, offer one more cognitive lens:

| Context signal | Suggest |
|---|---|
| High confidence in recommendation | Blind Spot Check — are we missing something? |
| Single-framing (only evaluated against current) | Counterfactual — what if we framed differently? |
| Complex multi-criteria evaluation | Systems Thinking — interaction effects between criteria? |

> 🔄 One more perspective before writing the deliverable?
> Suggested: {tool} — {reason}
> [Apply / Proceed]

### G — Present Analysis

> 🔬 Adoption Analysis
> {Evaluation grid}
> Fit assessment: {how well candidate fits}
> Migration risk: {assessment}
> Adaptation path: {what would need to change}
> Confidence: {high/medium/low}

**[T3: Analysis sufficiency]** — Proceed to Deliverable?

### H — Zone Check

> **Mental note**: Analysis complete. Recommendation: {Adopt/Adapt/Defer/Skip}. Key: {evaluation summary}. Confidence: {level}. If checkpoint → update ISS Findings Summary with analysis conclusions.

---

## Step 5: Deliverable

Write evaluation report to Sprint folder.

> 📝 **Audit-shape deliverable conventions** — for audit-shape deliverables (audits, inventories, classifications, registry sweeps), two canonical disciplines apply: **(1) AUDIT-DEFERRED labeling** and **(2) Exhaustive-Enumeration Grep**. Single source of truth: `nexus-research/SKILL.md` [Section: Commit-Protocol] → Research-Mode Scope Discipline — load there for the full convention (both disciplines spelled out, with the execution-time-wording distinction).

### A — Produce Report

Write to `Sprints/XXX/ISS-XXX-adoption-evaluation.md`:

Structure:
1. Executive Summary (recommendation + key reasoning)
2. Evaluation Criteria (what was assessed)
3. Candidate Analysis (per-criterion findings)
4. Current Approach Analysis (per-criterion findings)
5. Comparison (evaluation grid — both B1 criterion matrix AND B2 deliverable-component roster if applicable)
6. Adoption Assessment (fit, migration, risk, adaptation path)
7. Recommendation (Adopt / Adapt / Defer / Skip + reasoning)
8. Adaptation Proposal (if Adopt/Adapt — how to integrate)
9. **Deliverable-component resolution** (if templates/skills in scope): explicit mapping from roster components → target file → patch or section
10. Sources Consulted

**If Adopt/Adapt produces deliverables**: the Sprint folder should contain the deliverable drafts as separate files (templates, skill proposals, etc.), with the report indexing them.

**[T3: Deliverable write]**

### B — Self-Evaluation

Validate deliverable AND research process:
- Does it answer the research questions from Scoping?
- Is every claim supported by investigation evidence?
- Are sources attributed? Limitations stated? Confidence levels clear?
- Did we check for confirmation bias?
- Is candidate vs current comparison fair and balanced?

### C — Pattern Assessment

Per [Section: Pattern-Tracking]. Record in ISS ### Pattern Outcomes.

### D — Zone Check

> **Mental note**: Deliverable written: Sprints/XXX/ISS-XXX-adoption-evaluation.md. Patterns assessed: {list}. If checkpoint → verify deliverable on disk, update ISS pointer.

---

## Step 6: Decision

Present recommendation and facilitate user decision.

### A — Present Recommendation

"Based on the evaluation of {candidate}:
 Recommendation: **{Adopt / Adapt / Defer / Skip}**
 Key reasoning: {from analysis}"

### B — User Decision

**[T1: all levels ask]** — User MUST decide on findings.

| Outcome | Action |
|---|---|
| Adopt | Note implementation scope. Will need Feature/Improvement issues. |
| Adapt | Note adaptation scope — what to take, what to modify, what to skip. |
| Defer | Document conditions for re-evaluation. Close as informational. |
| Skip | Document reasoning. Close as informational. |
| Inconclusive | Document what was found, what's missing, conditions for re-investigation. |

### C — Create Issues from Findings

**[T2: Balanced+Full ask | Streamlined: notify+log]** (only if Decision produces action items)

If Adopt or Adapt: suggest issues for implementation.
User steers scope and description. Invoke /nexus-create-issue for each.
Note spawned issues in deliverable + ISS.

### D — User Override

If user says "evaluate now" with insufficient research: warn about gaps, note concerns, proceed if insisted.

→ Return to SKILL.md [Section: Commit-Protocol]
