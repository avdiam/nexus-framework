*Version: 1.5.0 | Date: 2026-06-11 | Sprint: 101*

# Research — Exploratory Mode

**Flow**: Survey → Investigation (thread-following) → Analysis → Deliverable → Decision → return to SKILL.md [Section: Commit-Protocol]

Open investigation into a domain, topic, or question.
Core question: "What do we know about X?" → Knowledge report + implications.

**Key differences from other modes**:
- **Thread-following investigation** — depth over breadth, chains of discovery (finding A leads to thread B)
- **Question-answer synthesis** — answers individual research questions with evidence and confidence levels
- **Decision is often informational** — knowledge captured; action items emerge organically rather than from structured evaluation

## Step 2: Survey

Broad sweep of topic area.

### A — Topic Mapping

Run [Section: Agent-Dispatch] in SKILL.md. On accept, dispatch 1 agent per question area (haiku, survey focus):

  Agent N: "Research {sub-topic/question area} broadly. Map what exists:
    key resources, state of the art, major perspectives, knowledge gaps.
    Return: structured summary per Survey output format."

On skip: sequential WebSearch per question area.

### B — Source Quality Triage + Thread Identification

Per [Section: Source-Quality]. Identify threads worth following deeper.

### C — Landscape Summary

Present topic map.
⟳ **Loop-back check**: Are we asking the right questions? Is the topic scoped correctly?
If signal fires: **[T2: only if triggered]**

**[T3: Survey sufficiency]** — Landscape mapped with ≥2 sources per question?

### D — Zone Check

> **Mental note**: Survey complete. Topic mapped. {N} sources found. Threads identified: {list}. If checkpoint → update ISS Findings Summary.

---

## Step 3: Investigation

Thread-following — depth over breadth. May chain (finding A leads to thread B).

> 📋 Investigation Plan
> This conversation: {threads/sources to investigate this session}
> Remaining: {threads deferred to next conversation, if any}
> Priority threads: {from Survey}

### A — Initial Dispatch

Run [Section: Agent-Dispatch] in SKILL.md. On accept, dispatch agents per key source or sub-topic (sonnet, investigation focus):

  Agent N: "Investigate {source/topic} deeply:
    - Extract specific evidence relevant to: {research questions}
    - Note methodology, design decisions, architecture
    - Capture capabilities, limitations, trade-offs
    - Flag threads worth following deeper
    Return: findings per Investigation output format + suggested follow-up threads."

Follow-up agents for emerging threads as needed (sequential chaining).

### B — Save Reports

**[T2: Balanced+Full ask | Streamlined: save synthesized only, notify+log]**

If full: write ISS-XXX-investigation-{topic}.md. May have multiple report files.
Always: synthesized summary to main context.

### C — Scope Reality Check (after first thread followed)

After first investigation results, assess: Is the topic deeper/broader than anticipated? Are the right questions being asked?

### D — Quality Check

Multiple independent sources? Opposing viewpoints checked? Per [Section: Bias-Avoidance].

### E — Loop-Back Check

⟳ Wrong questions entirely? Topic fundamentally misunderstood at Analysis?
If signal fires: **[T2: only if triggered]**

### F — Zone Check + Continuation

**[T3: Investigation continuation]** — All questions have evidence? All threads followed?

> **Mental note**: Investigation complete. Questions covered: {N}/{total}. Threads followed: {list}. Reports: {paths}. If checkpoint → verify reports on disk, update ISS.

---

## Step 4: Analysis

Synthesize findings into answers.

### A — Load Investigation Data

Load Sprint report files if not in context.

### B — Question-Answer Synthesis

For each research question:
- Answer with supporting evidence from multiple sources
- Confidence level (high/medium/low)
- Caveats and limitations

### C — Identify Themes and Implications

Cross-question patterns. Connections to existing knowledge. Practical implications.

### D — Quality Check + Loop-Back Check

Per [Section: Bias-Avoidance]. ⟳ Problem misframed?

### E — Post-Analysis Elicitation

| Context signal | Suggest |
|---|---|
| High confidence in synthesis | Blind Spot Check — what are we not seeing? |
| Findings converge on single narrative | Counterfactual — alternative framings? |
| Complex topic with many threads | Systems Thinking — how do findings interact? |

> 🔄 One more perspective before writing the deliverable?
> [Apply / Proceed]

### F — Present Analysis

> 🔬 Exploratory Analysis
> Per-question answers: {summary}
> Themes: {cross-cutting patterns}
> Implications: {what this means for the project}
> Confidence: {high/medium/low}
> Open questions remaining: {list}

**[T3: Analysis sufficiency]**

### G — Zone Check

> **Mental note**: Analysis complete. Per-question answers: {summary}. Themes: {list}. Confidence: {level}. If checkpoint → update ISS Findings Summary.

---

## Step 5: Deliverable

Write knowledge report to Sprint folder.

> 📝 **Audit-shape deliverable conventions** — for audit-shape deliverables (audits, inventories, classifications, registry sweeps), two canonical disciplines apply: **(1) AUDIT-DEFERRED labeling** and **(2) Exhaustive-Enumeration Grep**. Single source of truth: `nexus-research/SKILL.md` [Section: Commit-Protocol] → Research-Mode Scope Discipline — load there for the full convention (both disciplines spelled out, with the execution-time-wording distinction).

### A — Produce Report

Write to `Sprints/XXX/ISS-XXX-research-report.md`:

Structure:
1. Summary (key findings + implications)
2. Background (why this research, what prompted it)
3. Per-Question Findings (evidence-based answers)
4. Themes & Patterns (cross-cutting insights)
5. Implications (what this means, how it connects)
6. Open Questions (what couldn't be determined)
7. Sources Consulted

**[T3: Deliverable write]**

### B — Self-Evaluation

Validate deliverable AND research process:
- Does it answer the research questions from Scoping?
- Is every claim supported by investigation evidence?
- Are sources attributed? Limitations stated? Confidence levels clear?
- Did we check for confirmation bias?
- Is this our own synthesis, or a restatement of sources?

### C — Pattern Assessment + Zone Check

Per [Section: Pattern-Tracking]. Record in ISS ### Pattern Outcomes.

> **Mental note**: Deliverable written: Sprints/XXX/ISS-XXX-research-report.md. Patterns assessed: {list}. If checkpoint → verify on disk, update ISS pointer.

---

## Step 6: Decision

Present findings and facilitate decision on implications.

### A — Present Findings

"Key findings: {summary}. This means: {implications}."

### B — User Decision

**[T1: all levels ask]**

| Outcome | Action |
|---|---|
| Action items identified | Spawn implementation/improvement issues. |
| Informational | Knowledge captured. Close as informational. |
| Inconclusive | Document gaps. May need further investigation. |

### C — Create Issues from Findings

**[T2: only if Decision produces action items]**
User steers. Invoke /nexus-create-issue.

### D — User Override

If user says "evaluate now" with insufficient research: warn about gaps, note concerns, proceed if insisted.

→ Return to SKILL.md [Section: Commit-Protocol]
