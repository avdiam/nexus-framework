*Version: 1.0.1 | Date: 2026-04-01 | Sprint: 066*

# Analysis Thinking Toolkit (Complexity 3+)

Loaded by SKILL.md Router for complexity ≥ 3 issues. Executed in **two phases** with the type file's Investigate section in between:

**Phase 1 (§1-2)**: Tools + Preferences → *then type file Investigate runs* →
**Phase 2 (§3-5)**: Patterns + Strategy + Synthesis (now informed by investigation findings)

This ordering ensures pattern matching and strategy selection have research context — matching patterns before investigation produces poor relevance scores.

**Precedence rule**: The trigger tables below are compact references for quick assessment. When a full cognitive tool or strategic approach is loaded into memory via its skill, the loaded version's complete process takes precedence over the inline summary.

---

## 1. Tools Assessment

Recommend cognitive tools based on issue characteristics. Scan against trigger table, recommend top 1–2 matching tools.

### Cognitive Tool Trigger Table

| Tool | Skill invocation | When to Suggest | Benefit |
|---|---|---|---|
| First Principles | /nexus-mental-models first-principles | Novel domain, existing solutions inadequate, many assumptions | Break to fundamentals |
| Systems Thinking | /nexus-mental-models systems-thinking | Multiple components interacting, unexpected side effects | Map relationships, leverage points |
| Inversion | /nexus-mental-models inversion | Optimization needed, obstacles blocking, traditional approaches failing | Remove barriers |
| Decision Trees | /nexus-mental-models decision-trees | Sequential decisions, multi-step branching, complex dependencies | Map decision paths |
| Probabilistic | /nexus-mental-models probabilistic | Significant uncertainty, risk assessment, effort estimation | Outcome ranges |
| Analogical Reasoning | /nexus-mental-models analogical-reasoning | Novel domain, parallel solutions in other domains | Cross-domain mapping |
| Blind Spot | /nexus-problem-solving blind-spot | High confidence (>85%), high-stakes decision | Surface biases |
| Hypothesis-Driven | /nexus-problem-solving hypothesis | Multiple causes, debugging, structured investigation | Testable predictions |
| Root Cause | /nexus-problem-solving root-cause | Recurring problems, system failures | Trace to fundamentals |
| Counterfactual | /nexus-problem-solving counterfactual | Feeling constrained, path-dependent decisions, tech debt | Fresh perspectives |
| Mental Simulation | /nexus-problem-solving mental-simulation | Before finalizing designs, complex system changes | Surface execution issues |

### Presentation

> 🧠 Tool Assessment
>
> Complexity: {X}/5
> Issue characteristics: {key traits matching triggers}
>
> Recommended: {Tool_Name}
> Why: {matching trigger}
> Benefit: {from table}
>
> Load? [Y/n/defer]

On approval: invoke the skill (e.g., `/nexus-mental-models first-principles`). Proceed with tool loaded.
On decline or defer: note preference, proceed without.

> **Mental note**: Tools loaded: {list or none}. If checkpoint → continue_with only.

---

## 2. Preferences

Before research commits tokens to a direction, identify gray areas and capture user preferences. This is the last moment before investigation explores based on assumptions.

**[T3: Full ask | Balanced: notify | Streamlined: check for standards/preference files, apply silently]**

### A — Gray Area Identification

Generate 3–6 domain-specific gray areas based on issue type and description:

| Issue Type | Example Gray Areas |
|---|---|
| Feature | Integration approach, UX edge cases, performance expectations, data handling |
| Bug | Fix approach (minimal vs comprehensive), acceptable side effects, testing scope |
| Improvement/Refactor | Quality dimensions to prioritize, breaking change tolerance, migration path |
| Documentation | Audience level, depth, format, example density, cross-referencing |
| Research | What makes findings actionable? Decision timeline? Comparison criteria? |
| Creative | Audience, tone, format constraints, visual style, reference material |
| Question | Confidence threshold, evidence standard, scope of investigation |

### B — Capture Preferences

Use AskUserQuestion (multi-select): "Which areas would benefit from your input before I research?" Include "All look good — proceed" option.

For each selected area: ask 1–3 focused questions with "Claude decides" option. Batch by area.

### C — Check Standards Files

Regardless of user input: check if relevant standards/preference files exist in the project (e.g., `.nexus/supporting-files/project-context/`, coding standards, style guides). If found, read and integrate — locked standards override gray areas.

### D — Record in ISS

Write preferences to ISS [Section: Solution-Design] ### Implementation Preferences:

```
### Implementation Preferences
Locked (user decided):
- {area}: {decision}

Standards Applied:
- {standard}: {from file}

Claude's Discretion:
- {area}: {context for judgment}

Deferred:
- {idea}: captured for future consideration
```

### E — Research Guidance

The type file's Investigate section reads ### Implementation Preferences. Locked decisions constrain research direction (don't explore alternatives). Claude's Discretion areas allow exploration.

**Role separation**:

| User Decides | Claude Decides |
|---|---|
| How features should look/feel/behave | Architecture patterns and optimization |
| Specific behaviors and interactions | Code structure and testing approach |
| What's essential vs nice-to-have | Performance trade-offs, technical details |

> **Mental note**: Preferences: {locked} locked, {discretion} discretion, {deferred} deferred. If checkpoint → write preferences to ISS Solution-Design.

---

---

## ⏸️ PAUSE — Execute Type File Investigate Section Now

Return to the type file and execute its **§1 Investigate** section. Investigation findings will inform the pattern matching and strategy selection below.

**Now executing: types/{type}.md §1 Investigate**

Resume here after Investigate completes.
**Now executing: complex.md §3 Pattern Discovery** (orientation anchor for return from type file)

---

## 3. Pattern Discovery

**[T2: Balanced+Full ask | Streamlined: auto-invoke /nexus-match-pattern if C>2 or novel, notify]**

Find applicable patterns from the pattern registry. Comes after preferences (we need context) and before strategy (patterns inform approach).

> 🔍 Pattern Matching
>
> Want to find applicable patterns for this work?
> Recommended: Yes — complexity {X}/5, {reason matching would help}
> [Y/n]

If yes: invoke `/nexus-match-pattern`. It handles everything — loads registry, scores patterns (4 dimensions, 40% threshold), presents top 5, loads accepted pattern files, adapts guidance. Returns with pattern guidance integrated.

If no: continue without patterns.

**Zone awareness**: Pattern matching may load several pattern files (~2-4KB each). Check zone after completion.

> **Mental note**: Patterns matched: {list or none}. Guidance: {key insights}. If checkpoint → continue_with captures pattern decisions.

---

## 4. Strategic Approach Selection

**[T2: Balanced+Full ask | Streamlined: auto-select by type/complexity/novelty, notify]**

Select the execution methodology — HOW to implement. Requires problem understanding from Orient and any loaded preferences to choose well.

### Strategic Approach Trigger Table

| Approach | When to Suggest | Methodology |
|---|---|---|
| Analytical Decomposition (SA-001) | Multi-component, overwhelming scope, C>3 | Break into MECE components, solve individually, integrate |
| Iterative Refinement (SA-002) | Optimization, enhancement, performance | Start minimal, measure, improve (Pareto: 20% → 80%) |
| Proof-of-Concept (SA-003) | High technical risk, novel approach, uncertain feasibility | Minimal test → validate → full implementation |
| Foundation-First (SA-004) | New system, major refactoring, architecture | Core → basic ops → error handling → tests → features |
| Risk-Forward (SA-005) | Technical unknowns, external deps, integration complexity | High-risk items early, fail fast |
| Tech Debt Paydown (SA-006) | Maintenance burden high, quality issues | Fix debt → refactor → add tests → document → build new |
| Divergent-Convergent (SA-007) | Innovation needed, creative solutions | Generate many options, then select best |
| Constraint Relaxation (SA-008) | Over-constrained, legacy blocking | Design ideal without constraints, then adapt to reality |
| Test-Driven (SA-009) | Feature implementation, quality-critical code | Red → Green → Refactor |

### Presentation

> 🎯 Strategic Approach
>
> Issue characteristics: {key traits from research}
> Recommended: {SA_name}
> Why: {matching trigger}
> Methodology: {brief}
>
> Accept? [Y/n/alternative]

On approval: invoke `/nexus-strategic {approach-name}` to load full approach guidance.
On decline: ask preference. On "alternative": show other applicable approaches.

**Constitution check** (conditional): If `[PROJECT_CONSTITUTION]` exists in project-state.md, verify selected approach doesn't violate principles. If conflict: "Approach {SA} may conflict with '{principle}': {reason}. Adjust, override, or pick different?"

Select max 1 primary + 2 supporting approaches.

> **Mental note**: SA selected: {name or none}. Constitution: {checked/N/A}. If checkpoint → continue_with captures SA decision.

---

## 5. Contextual Synthesis

The bridge between gathering inputs (sections 1–4) and generating proposals (type file). Adapt all loaded tools, selected approach, and matched patterns to THIS specific problem.

**Skip if nothing to adapt**: If no tools loaded, no patterns matched, no SA selected — proceed directly to type file. (Unusual for C:3+ but possible if user declined everything.)

### A — Apply Cognitive Tools

If tools were loaded, apply them to the specific issue:

| Loaded Tool | Apply | Output |
|---|---|---|
| First Principles | Break problem to fundamentals | Core constraints, rebuilt approach |
| Systems Thinking | Map component relationships | Component map, feedback loops, leverage points |
| Inversion | Identify failure factors | Obstacles list, removal strategy |
| Decision Trees | Map decision paths | Branching paths with consequences |
| Probabilistic | Assess outcome ranges | Best/likely/worst scenarios |
| Analogical Reasoning | Find parallel solutions | Source domain mapping, what transfers, where it breaks |
| Blind Spot | Check biases and assumptions | Validated or concerns surfaced |
| Mental Simulation | Walk through execution | Friction points, gaps, failure modes |
| Root Cause | Trace causal chain | Root cause identified, fix strategy |
| Counterfactual | Reverse assumptions, shift time frames | Alternative solution spaces |

### B — Adapt Strategic Approach

If SA selected: contextualize for this issue. What does the methodology mean for THIS problem? Map abstract approach steps to concrete issue-specific actions.

### C — Adapt Pattern Guidance

If patterns matched: contextualize for this issue. What transfers directly? What needs modification? What doesn't apply? If multiple patterns: synthesize — resolve overlaps, combine complementary guidance.

### D — Synthesis

Combine all inputs into coherent analytical foundation:
- **Converging themes** → strengthen confidence
- **Legitimate divergences** → different contexts may need different handling
- **Hierarchical insights** → primary drivers vs supporting detail

**Distill, don't concatenate** — the synthesis should be shorter than the sum of its parts.

> 🧠 Adaptation Summary
>
> Key insights:
> - {insight_1 from tool/pattern/research}
> - {insight_2}
> - {insight_3}
>
> Strategic approach: {SA_name} adapted to {how it applies}
> Pattern guidance: {key adapted principles}
>
> These insights drive the design options in the type-specific workflow.

---

> **Mental note**: Adaptation complete. Key insights: {list}. SA: {name}. Patterns: {list}. If checkpoint → write decided subsections to ISS Solution-Design with marker "*Analysis in progress — adaptation complete, design pending*".

**After completing §3-5**: Return to the type file and continue from §2 Design onward. The type file's Design step has access to everything captured here — tools, preferences, investigation findings, patterns, strategy, synthesis.
