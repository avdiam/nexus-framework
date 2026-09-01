---
name: nexus-mental-models
description: "Strategic thinking frameworks for complex problems (complexity ≥ 3). Use when: novel domain (first-principles), interacting components (systems-thinking), optimization/obstacles (inversion), branching decisions (decision-trees), uncertainty (probabilistic), parallel solutions exist elsewhere (analogical-reasoning). Pass model name or 'all'."
disable-model-invocation: false
---
*Version: 3.2.1 | Date: 2026-06-15 | Sprint: 104*

# Mental Models

**Flow**: Route by argument → Present framework(s)

Strategic thinking tools for complex problem understanding. All models included inline — no sub-file loading needed.

## Usage

- `/nexus-mental-models first-principles` → use First Principles section
- `/nexus-mental-models all` → present all 6 models
- `/nexus-mental-models` (no args) → show available and let user choose

## Multi-Model Coordination

When one model scores >0.90 and others <0.80, use the winner alone. When two score >0.85 and are complementary, apply sequentially with clear transitions. Avoid combining three or more — creates analysis paralysis.

Deactivate after presenting analysis, when switching to implementation, or starting fresh analysis.

---

## First Principles Thinking
**Effectiveness**: 0.87 — **Purpose**: Break complex problems to fundamental truths, question all assumptions, rebuild from basics.

**Triggers**:
- Novel domain or unfamiliar territory
- Existing solutions feel inadequate
- Complex problem with many assumptions
- Need to challenge conventional thinking

**Process**:
1. Identify and list all assumptions. Tag each by source: `convention` / `competitor` / `industry-norm` / `fear` / `internal-bias`
2. Question each: "Must this be true?"
3. Break down to fundamental constraints and objectives
4. Rebuild: generate **3 distinct reconstructions** starting from the same irreducible truths — not a single rebuilt approach. Different starting assumptions yield different architectures.

**Output**: Present fundamental constraints, questioned assumptions, and 3 rebuilt approaches with reasoning.

**Optional enhancements** (use when the analysis warrants depth):
- **Assumption→Truth map**: Table showing `Original assumption → Replacing truth → Where conventional thinking leads vs. where new foundation leads`
- **Highest-leverage move**: After presenting 3 reconstructions, force convergence to one immediately-executable recommendation

**Scope-Framing aware**: First Principles rebuilds from fundamentals — but "fundamental for what?" depends on project scope. If reasoning against the *current transitional phase* rather than the *stated target state*, the rebuild can ossify the wrong denominator. For projects in transition, run `/nexus-problem-solving` Blind Spot §Scope-Framing Check before locking the reconstruction.

---

## Systems Thinking
**Effectiveness**: 0.85 — **Purpose**: Analyze component relationships, identify feedback loops, understand cascading effects.

**Triggers**:
- Multiple components interacting
- Integration or performance issues
- Unexpected side effects observed
- Need to understand dependencies

**Process**:
1. Map all component relationships
2. Identify feedback loops (positive and negative)
3. Trace cascading effects of changes
4. Find leverage points for intervention

**Output**: Present component map, feedback loops, cascading effects, and identified leverage points.

**Scope-Framing aware**: Systems Thinking maps components within the system boundary you draw. When the project is in transition, the boundary at *current phase* differs from the boundary at *stated target* (different actors, components, feedback loops). Run `/nexus-problem-solving` Blind Spot §Scope-Framing Check before locking the boundary.

---

## Inversion Thinking
**Effectiveness**: 0.83 — **Purpose**: Consider opposite perspective to identify obstacles, focus on removing barriers rather than adding features.

**Triggers**:
- Optimization needed
- Obstacles blocking progress
- Prevention focus
- Traditional approaches not working

**Process**:
1. Invert the question (how to make it fail vs succeed)
2. Identify all factors that cause failure
3. Remove or mitigate these obstacles systematically
4. Verify success through obstacle removal

**Distinction from Counterfactual**: Inversion asks "how would this FAIL?" and removes those factors. Counterfactual asks "what if things were DIFFERENT?" and imagines alternatives. Use Inversion to optimize/prevent. Use Counterfactual to escape constraints and explore fresh paths.

**Output**: Present inverted question, identified obstacles with impact, and systematic removal strategy.

---

## Decision Trees
**Effectiveness**: 0.81 — **Purpose**: Map multi-step decision paths where early choices constrain later options.

**Triggers**:
- Sequential decisions where early choices constrain later options
- Need to map cascading consequences of each path
- Multi-step decision chain (not a single choice point)
- Complex dependencies between decisions

**Distinction**: Use Decision Trees for branching decision chains. For a single choice between 2-3 options, standard option comparison suffices.

**Process**:
1. Map all decision paths as tree branches
2. Identify dependencies at each node
3. Evaluate consequences for each path
4. Trace optimal path considering tradeoffs

**Output**: Present branching paths with consequences, trade-offs per path, and recommended path with strategic reasoning.

---

## Probabilistic Thinking
**Effectiveness**: 0.79 — **Purpose**: Consider outcome ranges rather than single predictions, assess likelihoods, account for uncertainty.

**Triggers**:
- Significant uncertainty in key variables
- Risk assessment needed
- Resource or effort estimation
- Predictions with wide outcome ranges

**Process**:
1. Identify uncertainty ranges for key variables
2. Assess likelihood of different outcomes
3. Calculate expected values and risks
4. Plan for uncertainty rather than single outcome

**Output**: Present best/likely/worst scenarios with probabilities, expected values, and recommendation accounting for uncertainty.

---

## Analogical Reasoning
**Effectiveness**: 0.80 — **Purpose**: Map solutions from known domains to novel problems by identifying structural similarities.

**Triggers**:
- Novel domain where direct experience is lacking
- Problem resembles something solved in another context
- Need to transfer established solutions across domains
- Existing approaches within the domain have failed

**Distinction**: First Principles breaks problems DOWN to fundamentals. Analogical Reasoning maps ACROSS from known domains. Use First Principles when you need to question assumptions from scratch; use Analogical Reasoning when a parallel solution likely exists elsewhere.

**Process**:
1. Identify the core structure of the current problem (abstract away domain specifics)
2. Search for analogous problems in other domains with similar structure
3. Map the source solution to the target domain — identify what transfers and what doesn't
4. Adapt the mapped solution to fit domain-specific constraints
5. Validate that the analogy holds under stress (where does it break?)

**Output**: Present source domain analogy, what transfers directly, what needs adaptation, where the analogy breaks, and proposed adapted solution.
