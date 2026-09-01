*Version: 1.3.0 | Date: 2026-06-11 | Sprint: 101*

# Analysis — Research Type

Loaded by SKILL.md Router for research-type issues, complexity ≥ 3.

**Flow**: Investigate → Design → **[T1] Choice** → Plan → **[T1] Plan Approval** → [Section: Commit-Protocol] → Transition

**Key differences from default**:
- Investigate is restricted to preliminary source collection — full investigation happens in /nexus-research
- Design presents research approach (mode/depth/strategy), not implementation options
- Plan produces Research Plan with milestones, not file-change sequences
- Transition targets /nexus-research, not /nexus-build

---

## 1. Investigate (Restricted Scope)

⚠️ **Preliminary source collection only.** Full investigation happens in /nexus-research. Do NOT conduct substantive investigation, synthesize findings, draw conclusions, or produce gap analysis here.

### A — Define Research Questions

From the issue description and understanding, formulate clear research questions:
- What specific questions need answering?
- What would "good enough" answers look like?
- What's the decision these findings will inform?

### B — Map Research Subjects

Identify what we're researching — technologies, approaches, tools, concepts, domains.

### C — Source Strategy Assessment

Map available sources and accessibility:
- Primary: official docs, source code, academic papers
- Secondary: articles, tutorials, expert blogs
- Tertiary: forums, community (note sentiment only)

Assess: Are key sources accessible? Any paywalled or restricted content?

### D — Research Mode Confirmation

Confirm mode based on issue context:

| Mode | When | Focus | Outcome |
|---|---|---|---|
| **Adoption** | Evaluating whether to adopt something specific | Criteria-based evaluation vs current approach | Adopt/Adapt/Defer/Skip → may spawn new Feature/Improvement issues |
| **Comparative** | Comparing multiple options | Dimension-based comparison across subjects | Comparative analysis matrix → informational report |
| **Exploratory** | Open investigation into a domain/topic | Question-driven deep exploration | Knowledge report → informational / action items |

### E — Depth Estimation

Estimate conversations needed based on subject count, source availability, and mode complexity.

---

## 2. Design — Research Approach

Present the research approach for approval:

> **Research Mode**: {Adoption / Comparative / Exploratory}
> **Rationale**: {why this mode}
>
> **Core Research Questions**:
> 1. {question}
> 2. {question}
>
> **Subjects**: {list}
>
> **Evaluation Criteria** (Adoption): {criteria for adopt/reject}
> **Comparison Dimensions** (Comparative): {dimensions}
> **Depth Boundaries** (Exploratory): {what "thorough enough" looks like}
>
> **Source Strategy**:
> - Primary: {sources}
> - Secondary: {sources}
>
> **Estimated Depth**: {conversations}
>
> **My recommendation**: {mode} because {reasoning}

### Strategic Reflection

- Are the research questions well-scoped?
- Is the estimated depth realistic?
- Are we researching the right thing to answer the underlying decision?

### Post-Generation Elicitation (complexity ≥ 3)

Before commitment, offer one re-examination pass through an unused cognitive lens:

| If unused | Suggest when |
|---|---|
| Systems Thinking | Options with different integration implications |
| Inversion | High confidence (>85%) — check what could fail |
| Pre-mortem | High-stakes or hard-to-reverse decision |
| Analogical Reasoning | Novel domain |
| Blind Spot Check | Strong anchoring risk |
| Mental Simulation | Complex workflows or multi-file changes |

> 🔄 Challenge this research approach before deciding?
>
> Suggested lens: {tool} — {one-line reason}
> [Apply suggested / Pick different / Proceed to choice]

If applied: focused pass (~2-3 paragraphs) on the *research approach*, not the original problem. Re-display with insights.

---

## 3. Choice Selection

**[T1: all levels ask]** Present research approach with recommendation. Wait for user approval.

On selection: "✓ Research approach accepted: {mode} mode"

---

## 4. Planning — Research Plan

Produce knowledge milestones, not file-change sequences:

> 📋 Research Plan
>
> **Phase 1: Scoping** (Conv {N})
> - Confirm mode and subjects
> - Define research questions
> - Map source strategy
>
> **Phase 2: Survey** (Conv {N})
> - Broad information gathering per subject
> - Source quality triage
> - Identify priority sources for deep investigation
>
> **Phase 3: Deep Investigation** (Conv {N}–{M})
> - Subject-by-subject examination
> - Evidence capture with source attribution
> - Quality checks per session
>
> **Phase 4: Analysis** (Conv {M})
> - Cross-source synthesis
> - Mode-specific analysis:
>   - Adoption: criteria evaluation
>   - Comparative: dimension matrix
>   - Exploratory: question answers
>
> **Phase 5: Deliverable** (Conv {M+1})
> - Produce research output (inline in ISS or external at Sprints/{NNN}/)
> - Self-evaluation and pattern assessment
>
> **Phase 6: Decision** (Conv {M+1})
> - Present conclusions
> - User decision on findings
> - Transition to evaluation
>
> **Estimated total**: {N} conversations
> **Deliverable target**: {inline / external path}

### Feasibility

- Are sources accessible?
- Is conversation count realistic given context constraints?
- Scope risks: too broad? too narrow?

---

## 5. Plan Approval

**[T1: all levels ask]** Present research plan with recommendation.

On approval: → [Section: Commit-Protocol], then Transition.

---

## 6. Transition

**[T3: Full ask | Balanced: notify | Streamlined: silent]**

After [Section: Commit-Protocol] completes:

Run [Section: End-of-Workflow-Checklist]. Calculate score.

**Step 0 — Readiness Gate**: Run [Section: Readiness-Gate] in references/readiness-gate.md with branch `research`. The research branch checks Research Design (mode/subjects/questions/criteria), Research Plan (phases/milestones/deliverable target), source strategy mapped, and mode confirmed. On PASS, proceed to step 1 below. On CONCERNS, follow the gate's branching. On FAIL, do not execute steps 1+ — return to the routed step per gate output.

Then execute:

1. Two-place score update per [Section: Two-Place-Update-Protocol]
2. Update sprint-state current_focus to 'research'
3. Context-aware loading:
   - < 70%: checkpoint, load /nexus-research
   - 70–80%: checkpoint, load if viable
   - > 80%: final checkpoint, defer to next conversation

> ✅ Phase Transition Complete
> Analysis → Research
> • Mode: {Adoption/Comparative/Exploratory}
> • Subjects: {count}
> • Score: {X}/5
> • Next: /nexus-research {loaded or deferred}

**On decline**: Ask what needs attention. Offer: refine research questions, adjust scope, change mode.

**User override**: If user says "start researching" with score < 4, warn about incomplete research design but proceed if insisted.

**Handoff verification**: Before loading /nexus-research, confirm ISS contains: Research Design (mode, subjects, questions, criteria, source strategy) in Solution-Design + Research Plan (phases, milestones, deliverable target) in Implementation-Plan. These are what /nexus-research reads on entry.
