---
name: nexus-problem-solving
description: "Investigation and validation tools (complexity ≥ 3). Use when: reviewing complex proposals — mandatory for Build self-eval ≥3 (adversarial-review), validating designs before finalizing (mental-simulation), plan validation by assuming failure and backtracking causes (pre-mortem-analysis), high confidence needs checking (blind-spot), multiple possible causes (hypothesis), recurring failures (root-cause), feeling stuck/constrained (counterfactual). Pass tool name or 'all'."
disable-model-invocation: false
---
*Version: 3.3.4 | Date: 2026-06-15 | Sprint: 104*

# Problem Solving Tools

**Flow**: Route by argument → Present framework(s)

Advanced investigation tools — META-LAYER tools that validate and enhance any analysis stage. All tools included inline — no sub-file loading needed.

## Usage

- `/nexus-problem-solving adversarial-review` → use Adversarial Review section
- `/nexus-problem-solving all` → present all 7 tools
- `/nexus-problem-solving` → show available and let user choose

## Tool Combination

These are META-LAYER tools — they validate and enhance, not compete. Common effective pairings:

| Pairing | When |
|---|---|
| Blind Spot → Adversarial Review | High confidence first → structured challenge after |
| Hypothesis → Root Cause | Multiple symptoms → structured trace to fundamental cause |
| Mental Simulation → Blind Spot | Execution walkthrough → check what you missed |
| Counterfactual → Hypothesis | Imagine alternatives → test the most promising |

Avoid: Running 3+ tools on the same artifact — diminishing returns, analysis paralysis.

Deactivate tools after: presenting investigation results, resolving the problem, switching to a different work phase, or starting fresh investigation.

---

## Adversarial Review
**Effectiveness**: 0.50 (new) — **Purpose**: Structured critical review with a must-find mandate.

**Triggers**:
- After generating complex proposals, designs, or recommendations (complexity ≥ 3)
- Build self-eval step (mandatory for complexity ≥ 3)
- Validate review step (mandatory for complexity ≥ 4)
- Confidence exceeds 85%
- On request: "run adversarial review", "challenge this", "what could go wrong"

**Mandate**: Find at least one genuine issue. Every review has something to improve. If first pass surfaces zero findings — halt. Re-examine from a different perspective.

### Review Process

1. **Shift perspective**: You are now a critical reviewer, not the author.
2. **Scan for issues**:
   - Correctness: errors, wrong assumptions, broken logic
   - Completeness: missing cases, gaps, unhandled scenarios
   - Consistency: contradictions, internal conflicts
   - Robustness: fragile assumptions, single points of failure, edge cases

3. **Classify findings**:

| Severity | Meaning | Action |
|---|---|---|
| HIGH | Blocks correctness or causes failure | Must fix before proceeding |
| MEDIUM | Degrades quality or creates risk | Should fix, justify if deferred |
| LOW | Improvement opportunity | Fix if convenient |

4. **Resolve each**: [W] Walk through (false alarm) / [F] Fix downstream (patch the consumer) / [SF] Source-fix at {location} (extend the canonical rule per PAT-103) / [S] Skip with reason

5. **Report**:

> 📐 Adversarial Review — {context}
>
> Findings ({N} total):
> 1. [{severity}] {description}
>    Resolution: [{code}] {action}
>
> Summary: {N} HIGH, {N} MEDIUM, {N} LOW
> Verdict: {proceed / fix required / needs rethink}

### Post-Generation Elicitation

After complex outputs, pause before presenting. Apply one unused cognitive lens — quick 2-3 minute pass. If concern surfaces, escalate to full review.

---

## Pre-mortem Analysis
**Effectiveness**: 0.50 (new) — **Purpose**: Assume failure has already happened; work backward to identify the 3 most likely causes; pair each with a concrete preventive action. A debiasing move — treating failure as an established fact activates different cognitive pathways than forward-planning optimism.

**Triggers**:
- Plan validation before implementation commitment (primary invocation — nexus-analyze §4.D)
- High-stakes or hard-to-reverse design choices
- Post-build sanity check on architectural decisions (nexus-build §POST-TYPE)
- "What if this fails?" or "Pre-mortem this plan" requests

### Distinction from Inversion

Inversion (in nexus-mental-models) reasons forward: "what could go wrong with this plan?" — an obstacle check anchored on the current plan. Pre-mortem treats failure as a given fact and reasons backward: "it failed — why?" The failure-certainty framing surfaces causes that forward-planning optimism suppresses. The two tools are complementary; use Inversion to stress-test obstacles, Pre-mortem to stress-test causes.

### Process

1. **State the failure assumption explicitly**: "This plan/design/implementation has failed." Name the failure state. Do not qualify ("could fail", "might fail") — the framing only works if failure is taken as given.
2. **Identify the top 3 most likely causes** working backward from the assumed failure state. Avoid surface symptoms; aim for causal factors.
3. **Rank by likelihood** — HIGH / MEDIUM / LOW. Ranking forces prioritization and surfaces which causes warrant hardest attention.
4. **Specify a concrete preventive action** for each cause. Actions must be implementable now, not aspirational ("monitor better" is not a preventive action; "add timeout + alarm at 30s" is).

### Output Format

> 💭 Pre-mortem: {plan/design/implementation}
>
> Assumed failure: {stated failure condition}
>
> 1. [HIGH] {cause} — Preventive action: {concrete step}
> 2. [MEDIUM] {cause} — Preventive action: {concrete step}
> 3. [LOW] {cause} — Preventive action: {concrete step}
>
> Decision: {accept / mitigate N causes / reconsider plan}

### Synergies

- **Pairs with Blind Spot Identification**: Pre-mortem surfaces causes; Blind Spot checks what assumptions enabled each cause.
- **Pairs with Mental Simulation**: Simulation walks through execution forward; Pre-mortem runs the result backward. Together they cover both directions.
- **Follows naturally from plan drafting**: Run Pre-mortem after a plan is complete but before approval — it's cheapest to rework at that stage.

**Anti-patterns**:
- Hedging ("it probably won't fail, but...") — defeats the framing
- Surface causes ("the code has a bug") — not actionable, keep asking why
- Vague preventive actions ("be more careful") — must be concrete and implementable

---

## Mental Simulation
**Effectiveness**: 0.82 — **Purpose**: Mentally execute a process step-by-step to surface issues before implementation.

**Triggers**:
- Before finalizing designs or restructuring
- Validating behavioral programming files
- Complex system changes with many touchpoints
- "Will this actually work in practice?"
- New workflows or process definitions

**Process**:
1. Define the actor and scenario (e.g., "fresh Claude instance loading this file")
2. Walk through execution step by step, following actual flow
3. At each step: "What happens here? What could go wrong? What's missing?"
4. Note friction points, gaps, missing information, failure modes
5. Compile findings and prioritize by impact

**Display**:
> 🧪 Mental Simulation: {scenario}
> Actor: {who}
>
> Step 1: {action} → {expected} → Issue: {problem or none}
> Step 2: {action} → {expected} → Issue: {problem or none}
>
> Findings: {list with impact}
> Recommendations: {fixes}

**Synergy**: Pairs with Blind Spot Identification — simulation surfaces execution issues, blind spots surface cognitive issues.

---

## Blind Spot Identification
**Effectiveness**: 0.85 — **Purpose**: Systematic bias detection and assumption checking.

**Triggers**:
- High confidence (>85%) on approach
- High-stakes decision
- Want to verify assumptions
- "What am I missing?"

**Transparency**: Always display 🔍 symbol.

### Cognitive Biases

**Confirmation bias**: "Am I seeking evidence that supports my existing belief?"
> 🔍 Current approach assumes: {assumption}
> Contradicting evidence: {list}
> What would change my mind?

**Anchoring effect**: "Is this anchored to the first information I encountered?"
> 🔍 Initial framing: {first_approach}
> Alternative starting points: {list}

**Recency bias**: "Am I over-weighting recent experience?"
> 🔍 Recent: {data}. Historical: {pattern}. Balance: {assessment}

**Authority bias**: "Accepting because of source, not evidence?"
> 🔍 Source credibility: {level}. Independent merit: {evaluation}

### Assumption Surfacing

1. Identify all assumptions in current reasoning
2. For each: "What must be true for this to work?"
3. Test necessity, assign confidence (0-100%)
4. Develop contingencies for uncertain assumptions

### Perspective Check

Whose perspective are we missing? What stakeholders haven't we considered? Expertise boundaries?

### Temporal Check

Short-term benefits vs medium-term (6-18mo) vs long-term (18mo+) consequences. Where does assessment flip?

### Scope-Framing Check

Applies whenever reasoning involves a system/project in transition (meta-to-production, prototype-to-scale, single-user-to-multi-tenant, alpha-to-GA, migration-in-progress).

**Question**: "Is this analysis reasoning against the project's *stated target state* or its *current transitional phase*? If different, which is the correct denominator for the verdicts being produced?"

> 🔍 Stated target: {what the project is SUPPOSED to become}
> Current phase: {where the project IS right now}
> Analysis is anchored to: {target | current | unclear}
> Forward-looking verdicts (adoption, architecture, scope) MUST reason against target, not current.
> Operational/tactical verdicts MAY reason against current (e.g., "what should we ship this sprint").

**When to apply**:

| Condition | Apply? |
|---|---|
| Project is NOT in transition (stable state, fixed-scope) | Skip — axis not applicable |
| Project IS in transition AND verdicts are forward-looking (architecture, adoption, specialist gap analysis) | **Apply — required** |
| Project IS in transition AND verdicts are tactical (this sprint's issue prioritization) | Apply — optional, depends on horizon |
| Multi-stakeholder project with different parties at different scopes | **Apply — required** (denominators may differ) |

**Red flags suggesting misalignment**:

- Findings cite "NEXUS meta" / "this prototype" / "current system" as default when project vision is larger
- Specialist/capability gap analysis returns "defer" verdicts on roles that are mainstream at target scale
- Architecture choices reason from "how many users / projects / sprints today" rather than "at the target state, how many"
- Verdicts that hold only under the current transitional phase, not under the stated target

**Corrective protocol**:

1. Surface the target state explicitly (quote the project vision / mission / constitution)
2. Restate the current transitional phase explicitly
3. For each verdict, mark which frame it implicitly uses
4. Re-evaluate verdicts that used the wrong frame
5. Log the re-evaluation as a Research Pivot / Scope Change in the governing ISS

**Case study reference**: the Scope-Framing axis was added as the structural mitigation after a Blind Spot pass cleared a Phase-4 review on its other axes but missed scope-framing, requiring later user correction (full case: archived `ISS-159`, ### Phase 4: Analysis → Scope Changes).

### Integration with Mental Models

Blind spot checking is a META-LAYER on mental model conclusions. If model confidence >85%: trigger check on the conclusion. Surface unchecked assumptions. Present: validated OR concerns found.

**Note**: Mental models frame their own denominator (First Principles: fundamentals; Systems Thinking: interacting components; Inversion: failure modes). Blind Spot's Scope-Framing axis audits whether that denominator matches the project's stated target state — mental models don't self-detect this drift.

---

## Hypothesis-Driven Framework
**Effectiveness**: 0.80 — **Purpose**: Structure complex problems as testable hypotheses for faster convergence.

**Triggers**:
- Multiple possible causes
- Debugging with unclear root cause
- Need structured investigation
- Complexity >3 with multiple causes
- Performance optimization

### Three Hypothesis Types

**Issue hypotheses** — Root cause: "Problem caused by {specific_cause} rather than {alternative}."

**Solution hypotheses** — Predicted outcomes: "{Solution} will {measurable_result} under {conditions}."

**Implementation hypotheses** — Approach predictions: "{Approach} will work because {reasoning} with {effort}."

### Process

1. Frame the problem — gap between current and desired state
2. Generate 2-3 competing hypotheses
3. Prioritize by impact × testability
4. Define tests: what to measure, accept/reject thresholds
5. Execute tests and gather evidence
6. Evaluate: validated / refuted / partial / inconclusive

### Display Formats

**Single hypothesis**:
> 🧪 Hypothesis: {statement}
> If true: {evidence}. If false: {evidence}.
> Test: {procedure}. Accept if: {condition}. Reject if: {condition}.

**Competing hypotheses**:
> 🧪 Problem: {problem}
> A: {cause_1} — Test: {test_1} — Priority: {score}
> B: {cause_2} — Test: {test_2} — Priority: {score}
> Recommendation: Test {letter} first because {reasoning}

**Evaluation**:
> 🧪 Results: {summary}. Evidence: {measurements}
> Conclusion: {VALIDATED / REFUTED / PARTIAL / INCONCLUSIVE}

---

## Root Cause Analysis (Five Whys)
**Effectiveness**: 0.85 — **Purpose**: Trace symptoms to fundamental causes.

**Triggers**: Recurring problems, debugging, system failures, symptoms vs causes unclear.

**Process**:
1. State the problem precisely
2. Ask: Why does this symptom occur?
3. Each answer becomes the next question
4. Repeat until fundamental cause reached (3-7 levels)
5. Map complete causal chain
6. Address root cause, not symptom

**Example**:
> Symptom: Authentication fails intermittently
> Why 1? → Token validation fails
> Why 2? → Expiry check uses wrong timezone
> Why 3? → Server timezone not configured
> Why 4? → Missing from deployment checklist
> ROOT: Process gap in deployment checklist
> FIX: Add timezone to checklist + startup validation

**Variations**:
- **Why Tree**: Multiple contributing factors → build tree, fix highest-impact branches
- **Why-How Bridge**: WHY down to root, verify HOW back up. Does fix prevent ALL symptoms?

**Anti-patterns**:
- Stopping early: "Code has bug" is not actionable
- Human error as root: Human error is a symptom — what allowed it?
- Correlation as causation: Temporal sequence ≠ causation

---

## Counterfactual Reasoning
**Effectiveness**: 0.78 — **Purpose**: Generate fresh perspectives by reversing assumptions, exploring alternative paths, shifting time horizons.

**Triggers**:
- Feeling stuck or constrained
- Path-dependent decisions
- Technical debt evaluation
- Existing approaches feel like dead ends

**Distinction from First Principles**: First Principles asks "is this true?" and deconstructs. Counterfactual asks "what if different?" and imagines.

### Assumption Reversal

> 💭 Current assumption: {assumption}
> Reversed: "What if {opposite}?"
> In that world: {possibilities}
> Applicable to reality: {what transfers}

### Alternative History

> 💭 Past decision: {decision} (made because {reasoning})
> Alternative: "What if {alternative_choice}?"
> Current state would be: {projected}
> Reveals: {genuine constraint vs sunk cost}
> Action: {continue / pivot / hybrid}

### Time-Frame Shifting

> 💭 Decision: {tradeoff}
> At 1 month: {assessment} — favors {option}
> At 1 year: {assessment} — favors {option}
> At 3 years: {assessment} — favors {option}
> Flip point: {where and why}
> Calibrated decision: {recommendation}
