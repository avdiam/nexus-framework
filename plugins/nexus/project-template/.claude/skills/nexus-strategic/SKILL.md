---
name: nexus-strategic
description: "Execution methodologies for HOW to implement (complexity ≥ 3). Use when: overwhelming scope (analytical-decomposition), high risk (proof-of-concept), validating architecture (strategic-reflection), new system (foundation-first), optimization (iterative-refinement), unknowns (risk-forward), quality debt (tech-debt), need innovation (divergent-convergent), over-constrained (constraint-relaxation), quality-critical code (test-driven). Pass name or 'all'."
disable-model-invocation: false
---
*Version: 3.1.3 | Date: 2026-08-20 | Sprint: 110*

# Strategic Approaches & Reflection

**Flow**: Route by argument → Present approach/framework

Execution methodologies defining HOW to implement. Plus strategic reflection for dual-perspective validation. All approaches included inline — no sub-file loading needed.

## Usage

- `/nexus-strategic proof-of-concept` → use that approach section
- `/nexus-strategic strategic-reflection` → use the reflection protocol
- `/nexus-strategic all` → present all approaches + reflection
- `/nexus-strategic` → show available

## Pre-defined Stacks

| Stack | Composition | When |
|---|---|---|
| Innovation | Divergent-Convergent + Constraint Relaxation + PoC | Innovation with risk tolerance |
| Analysis Powerhouse | Decomposition + Iterative Refinement | Deep understanding + progressive improvement |
| Quality Assurance | PoC + TDD + Risk-Forward | Quality critical, risk averse |
| Speed Optimizer | Foundation-First + Iterative Refinement | Fast delivery, core first then iterate |

## Dynamic Composition

Choose 1 primary approach, max 2 supporting (verify no conflicts), define execution sequence, document rationale.

---

## Strategic Reflection Protocol
**Purpose**: Dual-perspective validation through cognitive mode shifting.

**Triggers**:
- **Mandatory**: Architectural changes, complex issues (≥3), high-confidence proposals (>85%)
- **Optional**: Complexity 2 (ask user)
- **Skip**: Trivial (complexity 1), following patterns with no variation

**Cognitive modes**:
- **Tactical**: HOW to implement. Uses Mental Models + Strategic Approaches + Patterns → initial proposal.
- **Strategic**: SHOULD we implement this way? Strategic overlay + blind spot detection + trade-off analysis → validation.

### Reflection Process

1. **Generate proposal**: Recommendation with reasoning (tactical)
2. **Mode shift**: Review as if someone else's proposal. Challenge assumptions.
3. **Strategic questions**: What am I optimizing for? Sacrificing? 10% failure scenario? Tech debt? Simplest approach? 6-month implications?
4. **Blind spot check** (if confidence >85%): Confirmation, Anchoring, Authority, Recency biases
5. **Trade-off analysis**: Benefits, costs, alternatives, cascade effects
6. **Synthesize**: Validated → present confidently. Concerns → adjusted recommendation. Better alternative → present with comparison.

### Display Formats

**Validated** (no concerns):
> 🎯 Proposal (strategically validated)
> Approach: {proposal}. Reasoning: {why}. Validation: confirmed. Proceed? [Y/n]

**With concerns**:
> 🎯 Proposal (with strategic reflection)
> Tactical: {proposal}
> ✅ Strengths: {optimizes for}
> ⚠️ Trade-offs: {sacrifices}
> 🔍 Concerns: {issues}
> Recommendation: {adjusted}. Confidence: {%}. Proceed? [Y/n/discuss]

**With alternative**:
> 🎯 Dual-Perspective Analysis
> Option A (Tactical): {original} — Optimizes: {X}. Trade-offs: {Y}.
> Option B (Strategic): {alternative} — Optimizes: {X}. Trade-offs: {Y}.
> Recommendation: Option {choice}. Which? [A/B/discuss]

**Scope-Framing aware**: Strategic mode questions ("what am I optimizing for?", "6-month implications?") presume a target state. When the project is in transition, validate target-vs-current denominator before producing strategic verdicts — otherwise the reflection ratifies optimizations against the wrong horizon. Run `/nexus-problem-solving` Blind Spot §Scope-Framing Check at Step 3 (Strategic questions).

---

## Analytical Decomposition
**Purpose**: Break complex problems into manageable components.

**Triggers**: Multi-component system, overwhelming scope, complexity >3 with distinct parts.
**NOT when**: Problem is tightly coupled (decomposition creates more interfaces than it solves), or scope is already manageable.

**MECE principle**: Components must be Mutually Exclusive (no overlaps) and Collectively Exhaustive (nothing missing).

**Process**:
1. Identify system boundaries
2. List major components (verify MECE)
3. Map relationships and interfaces
4. Solve components individually
5. Test integration points
6. Validate complete system

**Output**: MECE component list with relationships, interfaces, and integration strategy.

---

## Proof-of-Concept First
**Purpose**: Validate feasibility before full implementation.

**Triggers**: High technical risk, novel approach, uncertain feasibility.
**NOT when**: Risk is well-understood (PoC adds delay without learning), or change is easily reversible (just implement and revert if wrong).

**Process**:
1. Identify highest risk aspect
2. Build minimal test version
3. Test core functionality ONLY
4. Measure against success criteria
5. Decision: proceed or pivot
6. Document learnings

**Risk thresholds**: >90% confidence → always PoC. 70-90% → PoC for uncertain parts. <70% → consider.

---

## Foundation-First
**Purpose**: Build infrastructure before features.

**Triggers**: New system, major refactoring, architecture work, paradigm shifts.
**NOT when**: Extending existing system with established foundations, or quick fix where infrastructure already exists.

**Build order**: (1) Core data structures → (2) Basic operations → (3) Error handling → (4) Testing infrastructure → (5) Features.

**Synergies**: CLAUDE.md "Search before create" trait (find existing foundations first), Mental Models › First Principles (identify fundamentals).

**Scope-Framing aware**: "Foundation" depends on the system you're building toward. Foundation for *current phase* (e.g., meta-project scaffolding) ≠ foundation for *stated target* (e.g., production multi-tenant). Locking infrastructure against the wrong denominator produces Foundations that block the target state. Run `/nexus-problem-solving` Blind Spot §Scope-Framing Check before locking the build order.

---

## Iterative Refinement
**Purpose**: Progressive improvement through measured cycles.

**Triggers**: Optimization, enhancement, performance improvement.
**NOT when**: Building from scratch (nothing to iterate on — use Foundation-First), or binary pass/fail criteria (iterating toward "correct" is debugging, not refinement).

**Pareto heuristic**: 20% of changes → 80% of value. Focus each iteration on highest-impact aspect.

**Process**:
1. Start with minimal viable solution
2. Measure current performance
3. Identify highest-impact improvement (Pareto)
4. Implement targeted change
5. Measure impact
6. Keep if improved, revert if worse
7. Repeat until diminishing returns

**Stop criterion**: Improvement <5% per iteration, or Pareto threshold reached.

**Synergies**: Elegant minimum (start minimal), Test-Driven Development below (measure each iteration).

---

## Risk-Forward
**Purpose**: Address high-risk items early when most flexibility exists.

**Triggers**: Technical unknowns, external dependencies, integration complexity, novel technology.
**NOT when**: All risks are well-understood and similar in severity (standard sequencing is fine), or work is purely creative (risk framing adds unnecessary anxiety).

**Priority**: (1) Highest risk → (2) External dependencies → (3) Complex integrations → (4) Standard work.

**Distinction**: Risk-Forward decides WHAT ORDER. Proof-of-Concept decides HOW to validate. Use together when multiple high-risk items need both prioritization and validation.

---

## Technical Debt Paydown
**Purpose**: Clean before building new.

**Triggers**: Maintenance burden high, code quality issues, before major features, accumulated debt.
**NOT when**: Debt is in code being replaced anyway (don't polish what you'll discard), or time pressure makes cleanup a luxury (log the debt, fix later).

**Process**: (1) Fix critical debt → (2) Refactor problem areas → (3) Add missing tests → (4) Document complex parts → (5) Build new features.

---

## Divergent-Convergent
**Purpose**: Generate many options then select best.

**Triggers**: Innovation needed, creative solutions, product design exploration.
**NOT when**: Solution is obvious or well-established (divergent phase wastes time on a solved problem), or hard constraints leave only 1-2 viable options (skip divergent, go straight to evaluation).

**Two phases**:
- **Divergent** (generate): Many ideas, no criticism, build on ideas, seek wild possibilities.
- **Convergent** (select): Group similar, evaluate against criteria, select most promising, develop chosen.

**Synergy**: Mental Models › Decision Trees for systematic convergent evaluation.

---

## Constraint Relaxation
**Purpose**: Find ideal solution then adapt to reality.

**Triggers**: Over-constrained problem, legacy blocking, need creative breakthrough.
**NOT when**: Constraints are genuine and non-negotiable (relaxing them produces fantasies, not solutions), or problem is under-constrained (adding constraints is what's needed, not removing them).

**Process**:
1. Remove constraints temporarily
2. Design ideal solution
3. Identify core value and benefits
4. Reintroduce constraints one by one
5. Adapt while preserving core benefits
6. Document compromises

**Synergy**: Mental Models › Inversion — what if we removed obstacles?

---

## Test-Driven Development
**Purpose**: Define success criteria before implementation.

**Triggers**: Feature implementation (code), bug fixes, refactoring, quality-critical work.
**NOT when**: Exploratory/creative work where "correct" is subjective (use Iterative Refinement instead), or writing behavioral programming files (tests don't apply to LLM instructions — use Mental Simulation).

**Red-Green-Refactor**:
1. **RED**: Write failing test (MUST fail first)
2. **GREEN**: Minimal code to pass
3. **REFACTOR**: Improve quality, keep tests green
4. Return to RED

**Variations**:
- **Bug-fix TDD**: Test triggers bug → fix → test passes = fixed + regression protection
- **Outside-in**: Acceptance test → unit tests → implement bottom-up → acceptance passes
- **Characterization**: Observe behavior → test asserting it → refactor with safety net

**Anti-patterns**: Test-after (biased), testing implementation (not behavior), skipping red (can't confirm test validates).
