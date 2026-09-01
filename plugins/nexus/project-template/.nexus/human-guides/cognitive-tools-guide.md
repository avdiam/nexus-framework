# Cognitive Tools Guide
*Version: 1.3.0 | Date: 2026-08-24 | Sprint: 110*
*Thinking tools for complex problems — when and how to use them*

**Category**: system-reference
**Level**: intermediate
**Description**: Thinking tools — 6 mental models, 7 problem-solving tools, 9 strategic approaches + strategic reflection protocol, offered automatically at complexity ≥ 3.

**Source files**:
- `.claude/skills/nexus-mental-models/SKILL.md` v3.2.1 (6 mental models)
- `.claude/skills/nexus-problem-solving/SKILL.md` v3.3.4 (7 problem-solving tools, incl. Adversarial Review)
- `.claude/skills/nexus-strategic/SKILL.md` v3.1.3 (9 strategic approaches + Strategic Reflection protocol)
- `CLAUDE.md` v5.16.0 (routing map, complexity gating, control levels)

---

## What Are Cognitive Tools?
[Section: What-Are-Cognitive-Tools]

Cognitive tools are structured thinking frameworks that Claude can invoke on demand to tackle complex problems. They live in three independent skill packs — `/nexus-mental-models` (6 mental models), `/nexus-problem-solving` (7 problem-solving tools), `/nexus-strategic` (9 strategic approaches + the Strategic Reflection protocol) — each with every tool included inline, no sub-file loading needed.

You don't always need them. For simple work (complexity 1–2), standard methodology is sufficient. For complex work (3–5), the right tool can dramatically improve analysis quality by providing a structured lens for thinking through the problem.

Invoke a tool by name (e.g. `/nexus-mental-models first-principles`) or an entire pack at once (`/nexus-mental-models all`).

[/Section: What-Are-Cognitive-Tools]

---

## When Tools Get Suggested
[Section: When-Tools-Get-Suggested]

### At Conversation Start (Automatic)

Cognitive tools auto-invoke when active-issue complexity is **≥ 3** (CLAUDE.md routing map `# === COGNITIVE TOOLS ===`). The boot widget offers **Load recommended / Skip / Show all**.

| Complexity | What Happens |
|------------|-------------|
| 1–2 | No tools suggested. Available on request. |
| 3+ | Widget offers: Load recommended / Skip / Show all |

### During Analysis

`/nexus-analyze` has two integration points for cognitive tools, both on its complexity 3+ path:

**Tool assessment** — matches issue characteristics to individual tools. For example, a debugging issue with multiple possible causes triggers a Hypothesis-Driven Framework suggestion. A high-stakes decision triggers Blind Spot Check.

**Strategic approach selection** — matches issue characteristics to strategic approaches. These are execution methodologies like Analytical Decomposition, Proof-of-Concept, or Test-Driven Development.

### On Demand (Anytime)

You can load any tool at any point by saying its name. Tools aren't restricted to analysis — you might load Adversarial Review during implementation, or Systems Thinking during evaluation.

[/Section: When-Tools-Get-Suggested]

---

## The Tool Catalog
[Section: The-Tool-Catalog]

### Mental Models

Mental models provide structured lenses for understanding problems.

| Tool | Command | Best For |
|------|---------|----------|
| **First Principles** | "load first principles" | Novel domains, unfamiliar territory, too many assumptions. Breaks problems to fundamentals and rebuilds from basics. |
| **Systems Thinking** | "load systems thinking" | Multiple interacting components, integration issues, unexpected side effects. Maps relationships and finds leverage points. |
| **Inversion** | "load inversion thinking" | Optimization needed, obstacles blocking progress, prevention focus. Removes barriers rather than adding features. |
| **Decision Trees** | "load decision trees" | Sequential decisions where early choices constrain later ones, multi-step branching, complex dependencies. Maps decision paths and evaluates consequences. |
| **Probabilistic Thinking** | "load probabilistic thinking" | Significant uncertainty, risk assessment, effort estimation. Produces outcome ranges, not point predictions. |
| **Analogical Reasoning** | "load analogical reasoning" | Novel domains without direct experience, problems resembling something solved elsewhere. Maps solutions across from known domains. |

### Problem-Solving Tools

Targeted tools for specific investigation and validation needs.

| Tool | Command | Best For |
|------|---------|----------|
| **Adversarial Review** | "load adversarial review" / "challenge this" | Validating implementations, finding weaknesses. Mandatory in Build's self-eval at complexity ≥ 3; in Validate it applies at **every** complexity — complexity scales the depth, not the stance. Must-find-something mandate ensures genuine critique. |
| **Pre-mortem Analysis** | `/nexus-problem-solving pre-mortem-analysis` | Plan validation before implementation commitment. Assumes failure already happened, works backward to the 3 most likely causes with concrete preventive actions. |
| **Mental Simulation** | `/nexus-problem-solving mental-simulation` | Validating designs or behavioral files before finalizing. Walks execution step by step to surface friction points and gaps. |
| **Blind Spot Identification** | "load blind spot check" | High confidence on an approach, high-stakes decisions, verifying assumptions. Surfaces biases and tests assumptions. |
| **Hypothesis-Driven Framework** | "load hypothesis testing" | Multiple possible causes, debugging with unclear root cause, structured investigation. Creates testable predictions for faster convergence. |
| **Root Cause Analysis** | "load root cause analysis" | Recurring problems, system failures, symptoms vs causes unclear. Traces to fundamentals rather than treating symptoms. |
| **Counterfactual Reasoning** | "load counterfactual reasoning" | Feeling constrained by current framing, path-dependent decisions, technical debt evaluation. Reverses assumptions and shifts time frames for fresh perspectives. |

### Strategic Reflection

Higher-order thinking tool for validating and challenging your own reasoning — part of `/nexus-strategic`, alongside the 9 strategic approaches below (not a separate standalone tool; Adversarial Review above is a problem-solving tool, not strategic reflection).

| Tool | Command | Best For |
|------|---------|----------|
| **Strategic Reflection** | "strategic reflection" | Critical decisions, dual-perspective thinking, confidence calibration. Validates through "What am I optimizing for? What am I sacrificing?" |

### Strategic Approaches

Execution methodologies selected during Analysis for complexity 3+ issues.

| Approach | When Suggested |
|----------|---------------|
| **SA-001 Analytical Decomposition** | Multi-component system, overwhelming scope |
| **SA-002 Iterative Refinement** | Optimization, enhancement, performance improvement |
| **SA-003 Proof-of-Concept** | High technical risk, novel approach, uncertain feasibility |
| **SA-004 Foundation-First** | New system from scratch, major refactoring |
| **SA-005 Risk-Forward** | Technical unknowns, external dependencies |
| **SA-006 Tech Debt Paydown** | High maintenance burden, before major features |
| **SA-007 Divergent-Convergent** | Innovation needed, creative solutions |
| **SA-008 Constraint Relaxation** | Over-constrained problem, legacy blocking |
| **SA-009 Test-Driven Development** | Feature implementation, bug fixes, quality-critical |

[/Section: The-Tool-Catalog]

---

## Invoking Tools
[Section: Loading-And-Unloading]

Each pack has every tool included inline — no sub-file loading needed:

```
You: "first principles"
→ /nexus-mental-models first-principles
→ First Principles framework presented inline, ready to apply
```

You can also load an entire pack at once:

| Command | What Loads |
|---------|-----------|
| "load mental models" / `/nexus-mental-models all` | All 6 mental models |
| "load problem solving tools" / `/nexus-problem-solving all` | All 7 problem-solving tools |
| "load strategic approaches" / `/nexus-strategic all` | All 9 strategic approaches + the Strategic Reflection protocol |

There is no single command spanning all three packs.

### Deactivating

There's no separate "unload" command — a tool applies for the exchange you invoke it in; invoking a different tool or moving to the next work phase supersedes it.

[/Section: Loading-And-Unloading]

---

## How Tools Integrate with Methodology
[Section: How-Tools-Integrate-With-Methodology]

Cognitive tools aren't standalone — they weave into the methodology workflow at specific points.

### During Analysis

| `/nexus-analyze` stage | Tool Integration |
|-------------|-----------------|
| Tool assessment | Tool recommended based on issue characteristics. You choose to load or skip. |
| Strategic approach selection | Strategic Approach selected. Loaded from the `/nexus-strategic` pack if accepted. |
| Design | All loaded tools applied to the specific problem. Outputs synthesized. |
| Challenge lens | Post-generation pass — one unused tool offered to stress-test the options. |

### During Implementation

| `/nexus-build` stage | Tool Integration |
|-----------|-----------------|
| §PRE-TYPE | Pattern matching (not cognitive tools, but the same offer structure) |
| §POST-TYPE Quality Review | Mental Simulation and Adversarial Review, both mandatory for complexity ≥ 3. Post-implementation elicitation offers one additional lens. |

### During Evaluation

| `/nexus-validate` stage | Tool Integration |
|--------------|-----------------|
| Quality assessment | Adversarial by default **at every complexity** — depth scales with complexity, it is never skipped |

### Key Principle

When a tool is invoked, its full process and display format (from the owning pack's SKILL.md) take precedence over any compact trigger table. Trigger tables are quick references for selection; the invoked tool's process is the complete instruction set.

[/Section: How-Tools-Integrate-With-Methodology]

---

## Choosing the Right Tool
[Section: Choosing-The-Right-Tool]

A quick decision guide based on what you're facing:

| Situation | Recommended Tool |
|-----------|-----------------|
| "I don't understand this domain" | First Principles or Analogical Reasoning |
| "Too many moving parts" | Systems Thinking |
| "Something's blocking us" | Inversion |
| "Which path should we take?" | Decision Trees |
| "How risky is this?" | Probabilistic Thinking |
| "This worked elsewhere, will it work here?" | Analogical Reasoning |
| "I'm very confident — should I be?" | Blind Spot Identification |
| "Multiple things could be causing this" | Hypothesis-Driven Framework |
| "This keeps happening" | Root Cause Analysis |
| "We're stuck in a box" | Counterfactual Reasoning |
| "Assume this plan already failed — why?" | Pre-mortem Analysis |
| "Will this actually work in practice?" | Mental Simulation |
| "Is this implementation solid?" | Adversarial Review |
| "Am I thinking about this right?" | Strategic Reflection |

You can also combine tools. Systems Thinking to map the landscape, then Inversion to find what to remove, then Decision Trees to choose between remaining options. Claude will synthesize outputs from multiple loaded tools during the design stage of Analysis.

[/Section: Choosing-The-Right-Tool]

---

## Quick Reference
[Section: Quick-Reference-Card]

| Question | Answer |
|----------|--------|
| How many tools? | 6 mental models + 7 problem-solving tools + 9 strategic approaches + the strategic reflection protocol |
| When are they suggested? | Automatically at complexity ≥ 3 (conversation start), during Analysis/Build/Validate, or on demand |
| How to invoke? | Say the tool name ("first principles", "adversarial review") or use the pack's slash command, e.g. `/nexus-mental-models first-principles` |
| Can I use during implementation? | Yes — Adversarial Review is mandatory for Build self-eval at complexity ≥ 3 |
| Do I need to manage them? | No — Claude offers Load recommended / Skip / Show all; you choose. |

[/Section: Quick-Reference-Card]
