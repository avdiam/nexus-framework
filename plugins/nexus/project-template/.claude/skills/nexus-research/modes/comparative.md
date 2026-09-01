*Version: 1.5.0 | Date: 2026-06-11 | Sprint: 101*

# Research — Comparative Mode

**Flow**: Survey → Investigation (N-track symmetric) → Analysis → Deliverable → Decision → return to SKILL.md [Section: Commit-Protocol]

Comparing multiple options across defined dimensions to inform a decision.
Core question: "How do X, Y, Z compare?" → Comparison matrix + conclusions.

**Key differences from other modes**:
- **N-track symmetric investigation** — same dimensions applied to every subject, equal depth
- **Dimension comparison matrix** — structured side-by-side comparison, not evaluation against baseline
- **Decision is often informational** — comparison informs choice rather than producing direct action items

## Step 2: Survey

Map the landscape for each subject.

### A — Search Per Subject

Run [Section: Agent-Dispatch] in SKILL.md. On accept, dispatch 1 agent per subject (haiku, survey focus, symmetric prompt):

  Agent N: "Research {subject N} broadly. Find official docs, community reception,
    maturity, key capabilities and limitations.
    Return: structured summary per Survey output format."

On skip: sequential WebSearch per subject.

### B — Source Quality Triage

Per [Section: Source-Quality]. Ensure comparable source quality across subjects.

### C — Landscape Summary

Present per-subject findings.
⟳ **Loop-back check**: Are these the right subjects to compare? Should any be swapped?
If signal fires: **[T2: only if triggered]**

**[T3: Survey sufficiency]** — Each subject has ≥2 primary sources?

### D — Zone Check

> **Mental note**: Survey complete. {N} subjects mapped. Sources per subject: {counts}. If checkpoint → update ISS Findings Summary.

---

## Step 3: Investigation

N parallel tracks — one per subject, same dimensions.

> 📋 Investigation Plan
> This conversation: {subjects to investigate this session}
> Remaining: {subjects deferred to next conversation, if any}
> Tracks: {N} (one per subject, symmetric dimensions)

### A — Per-Subject Deep Dive

Run [Section: Agent-Dispatch] in SKILL.md. On accept, dispatch 1 agent per subject (sonnet, investigation focus):

  Agent N: "Deep dive {subject N} on these dimensions:
    {dim 1}: {what to evaluate}
    {dim 2}: {what to evaluate}
    Return: structured findings per Investigation output format."

On skip: continued sequential WebSearch and WebFetch per subject.

### B — Save Reports

**[T2: Balanced+Full ask | Streamlined: save synthesized only, notify+log]**

If full: write ISS-XXX-investigation-{subject}.md per subject.
Always: synthesized summary to main context.
Update ISS with thin summary + pointers.

### C — Scope Reality Check (after first subject completes)

After first subject investigated, assess scope. If dimensions don't differentiate or subjects are more similar than expected: surface before investing in remaining subjects.

### D — Quality Check

Comparable depth across all subjects? Same source quality tier? Per [Section: Bias-Avoidance].

### E — Loop-Back Check

⟳ Wrong subjects? Dimensions don't differentiate meaningfully?
If signal fires: **[T2: only if triggered]**

### F — Zone Check + Continuation

**[T3: Investigation continuation]** — All subjects covered? Proceed to Analysis.

> **Mental note**: Investigation complete. {N} subjects investigated. Reports: {paths}. If checkpoint → verify reports on disk, update ISS.

---

## Step 4: Analysis

Build dimension comparison matrix.

### A — Load Investigation Data

Load Sprint report files if not in context.

### B — Build Comparison Matrix

| Dimension | Subject A | Subject B | Subject C | Winner |
|---|---|---|---|---|
| {dim 1} | {evidence} | {evidence} | {evidence} | {assessment} |
| ... | ... | ... | ... | ... |

### C — Identify Patterns

Where subjects excel or lag. Unexpected findings outside original dimensions.
Overall ranking if applicable — note where it's clear-cut vs context-dependent.

### D — Quality Check + Loop-Back Check

Per [Section: Bias-Avoidance]. ⟳ Problem misframed?

### E — Post-Analysis Elicitation

| Context signal | Suggest |
|---|---|
| One subject clearly dominant | Blind Spot Check — are we anchored? |
| Dimensions don't differentiate well | Counterfactual — different dimensions? |
| Many subjects, complex interactions | Systems Thinking — interaction effects? |

> 🔄 One more perspective before writing the deliverable?
> [Apply / Proceed]

### F — Present Analysis

> 🔬 Comparative Analysis
> {Comparison matrix}
> Key differentiators: {what matters most}
> Context-dependent: {where "it depends"}
> Confidence: {high/medium/low}

**[T3: Analysis sufficiency]**

### G — Zone Check

> **Mental note**: Analysis complete. Key differentiators: {list}. Confidence: {level}. If checkpoint → update ISS Findings Summary with matrix conclusions.

---

## Step 5: Deliverable

Write comparison report to Sprint folder.

> 📝 **Audit-shape deliverable conventions** — for audit-shape deliverables (audits, inventories, classifications, registry sweeps), two canonical disciplines apply: **(1) AUDIT-DEFERRED labeling** and **(2) Exhaustive-Enumeration Grep**. Single source of truth: `nexus-research/SKILL.md` [Section: Commit-Protocol] → Research-Mode Scope Discipline — load there for the full convention (both disciplines spelled out, with the execution-time-wording distinction).

### A — Produce Report

Write to `Sprints/XXX/ISS-XXX-comparison-matrix.md`:

Structure:
1. Executive Summary (key findings + clear differentiators)
2. Methodology (dimensions, sources, approach)
3. Per-Dimension Comparison (detailed with evidence)
4. Summary Matrix (consolidated table)
5. Conclusions (overall assessment, context-dependent recommendations)
6. Sources Consulted

**[T3: Deliverable write]**

### B — Self-Evaluation

Validate deliverable AND research process:
- Does it answer the research questions from Scoping?
- Is every claim supported by investigation evidence?
- Are sources attributed? Limitations stated? Confidence levels clear?
- Did we check for confirmation bias?
- Is comparison fair and balanced across all subjects?
- Is this our own synthesis, or a restatement of sources?

### C — Pattern Assessment + Zone Check

Per [Section: Pattern-Tracking]. Record in ISS ### Pattern Outcomes.

> **Mental note**: Deliverable written: Sprints/XXX/ISS-XXX-comparison-matrix.md. Patterns assessed: {list}. If checkpoint → verify on disk, update ISS pointer.

---

## Step 6: Decision

Present comparison findings and facilitate decision.

### A — Present Findings

"Here's what the comparison shows: {key findings}.
 Implications for {original research question}: {answer}."

### B — User Decision

**[T1: all levels ask]**

| Outcome | Action |
|---|---|
| Clear winner | Note implications. May spawn implementation issues. |
| Context-dependent | Document which contexts favor which option. Informational. |
| Inconclusive | Document what was found. May need more investigation. |

### C — Create Issues from Findings

**[T2: only if Decision produces action items]**
User steers. Invoke /nexus-create-issue.

### D — User Override

If user says "evaluate now" with insufficient research: warn about gaps, note concerns, proceed if insisted.

→ Return to SKILL.md [Section: Commit-Protocol]
