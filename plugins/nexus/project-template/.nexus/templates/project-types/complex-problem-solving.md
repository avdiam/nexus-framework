# Complex Problem Solving
*Domain Profile v1.0.0 | Sprint: 060*

[Section: Profile]
type_name: "Complex Problem Solving"
category: "Research"
description: "Tackling multifaceted problems requiring deep analysis, hypothesis testing, and validated solutions. Choose when the challenge is understanding and solving a hard problem — not building a predefined product."
wizard_emphasis: "Problem framing, hypothesis generation, validation rigor, solution feasibility"
phase_character: "Analyze-heavy — hypothesize, test, validate, iterate. May pivot based on findings. Solutions emerge from investigation, not from a spec."
typical_deliverables: "Solutions, frameworks, decision models, validated recommendations, feasibility assessments"
wizard_depth: "thorough"

spec_version: "1.0.0"
template_version: "1.0.0"
[/Section: Profile]

[Section: Framing-Hints]
vision_question: "What problem are we tackling, and what would a successful solution look like?"
scope_emphasis: "Problem boundaries — what aspects are in scope to solve vs accepted constraints or givens"
deliverable_framing: "Validated solutions and decision frameworks, not features — what will the stakeholder be able to decide or do?"
risk_framing: "Wrong problem framing, confirmation bias, solution doesn't generalize, unforeseen constraints"
effort_framing: "Sprints map to investigation cycles — analysis phases may take longer than expected if hypotheses fail"
constraint_emphasis: "Problem constraints vs solution constraints — what's fixed in the environment vs what we can change"
[/Section: Framing-Hints]

[Section: Deliverable-Templates]
### MVP Examples
- name: "Problem Analysis & Framing"
  description: "Structured decomposition of the problem: root causes, contributing factors, constraints, stakeholders affected"
  quality_criteria: "Stakeholders agree this captures the real problem, not just symptoms"
- name: "Solution Framework"
  description: "Validated approach to solving the problem with evidence of feasibility"
  quality_criteria: "Solution addresses root causes, tested against edge cases, implementation path clear"
- name: "Decision Model"
  description: "Structured framework for evaluating options and making trade-off decisions"
  quality_criteria: "Criteria weighted, options compared systematically, sensitivity to assumptions documented"

### Enhanced Examples
- name: "Implementation Roadmap"
  description: "Phased plan for deploying the solution with risk mitigation and rollback points"
  quality_criteria: "Actionable steps, dependencies mapped, success criteria per phase"
- name: "Validation Report"
  description: "Evidence from testing, simulation, or pilot that the solution works as expected"
  quality_criteria: "Test conditions documented, results reproducible, limitations acknowledged"
- name: "Generalization Analysis"
  description: "Assessment of whether the solution applies to related problems or contexts"
  quality_criteria: "Boundary conditions defined, adaptation guidance for similar problems"

### Future Examples
- name: "Prevention Framework"
  description: "Systemic changes that prevent the problem class from recurring"
  quality_criteria: "Addresses structural causes, monitoring mechanisms defined"
- name: "Knowledge Base"
  description: "Documented problem-solving methodology and lessons for organizational learning"
  quality_criteria: "Reusable by others facing similar problems without original team"

### Categorization Guidance
"MVP = the problem is understood and a validated solution exists. Enhanced = the solution is implementable and proven. Future = the organization learns from the problem-solving process itself."
[/Section: Deliverable-Templates]

[Section: Phase-Templates]
### Simple (2-3 phases)
- phase: "Problem Analysis"
  objective: "Decompose the problem, identify root causes, generate candidate solutions"
  typical_deliverables: "Problem framing, root cause analysis, solution candidates"
  milestone: "Root causes identified and at least two viable solution approaches defined"
- phase: "Solution Development & Validation"
  objective: "Develop preferred solution, test against edge cases, document implementation path"
  typical_deliverables: "Solution framework, validation results, decision model"
  milestone: "Solution validated and ready for implementation"

### Standard (3-4 phases)
- phase: "Problem Framing"
  objective: "Understand the problem space, identify stakeholders, decompose into sub-problems"
  typical_deliverables: "Problem decomposition, stakeholder impact map, constraint inventory"
  milestone: "Problem precisely defined with agreement on what 'solved' looks like"
- phase: "Hypothesis & Investigation"
  objective: "Generate hypotheses about causes and solutions, gather evidence, test assumptions"
  typical_deliverables: "Hypothesis inventory, evidence collection, initial findings"
  milestone: "Key hypotheses tested with supporting or refuting evidence"
- phase: "Solution Design"
  objective: "Develop solution based on validated hypotheses, model trade-offs, assess feasibility"
  typical_deliverables: "Solution framework, decision model, feasibility assessment"
  milestone: "Solution designed with evidence of viability"
- phase: "Validation & Recommendation"
  objective: "Stress-test the solution, document limitations, produce actionable recommendation"
  typical_deliverables: "Validation report, implementation roadmap, final recommendation"
  milestone: "Solution validated and stakeholders aligned on recommendation"

### Complex (5-6 phases)
- phase: "Discovery & Scoping"
  objective: "Map the problem landscape, identify what's known vs unknown, define investigation boundaries"
  typical_deliverables: "Problem landscape map, knowledge gap analysis, investigation plan"
  milestone: "Investigation scope agreed, key unknowns prioritized"
- phase: "Deep Analysis"
  objective: "Root cause analysis, systems mapping, quantitative and qualitative investigation"
  typical_deliverables: "Root cause analysis, systems model, data analysis"
  milestone: "Root causes identified with supporting evidence"
- phase: "Hypothesis Testing"
  objective: "Formulate and test hypotheses about solutions, run experiments or simulations"
  typical_deliverables: "Hypothesis results, experiment logs, emerging solution candidates"
  milestone: "At least one hypothesis validated as viable solution direction"
- phase: "Solution Architecture"
  objective: "Design comprehensive solution, model interactions, assess implementation complexity"
  typical_deliverables: "Solution framework, interaction model, complexity assessment"
  milestone: "Solution architecture withstands adversarial review"
- phase: "Validation & Stress Testing"
  objective: "Test solution against edge cases, failure modes, and adversarial scenarios"
  typical_deliverables: "Validation report, failure mode analysis, boundary conditions"
  milestone: "Solution robust under realistic conditions"
- phase: "Synthesis & Handoff"
  objective: "Consolidate findings, produce implementation guidance, transfer knowledge"
  typical_deliverables: "Final recommendation, implementation roadmap, knowledge base"
  milestone: "Solution accepted and implementation path clear"

### Phase Naming Guidance
"Use investigation and reasoning language: Framing, Analysis, Hypothesis Testing, Solution Design, Validation, Synthesis. Avoid software terms (Sprint, Deploy) and pure research terms (Literature Review) unless the problem is academic."
[/Section: Phase-Templates]

[Section: Risk-Catalog]
- risk: "Wrong problem framing — solving the symptom instead of the root cause"
  probability: "Medium"
  impact: "High"
  mitigation_hint: "Use '5 Whys' or systems thinking to validate you're at the right level. Get stakeholder confirmation on framing before investing in solutions."
- risk: "Confirmation bias — finding evidence for the preferred hypothesis while ignoring alternatives"
  probability: "High"
  impact: "High"
  mitigation_hint: "Pre-register hypotheses, actively seek disconfirming evidence, use adversarial review on proposed solutions"
- risk: "Solution doesn't generalize beyond the specific case studied"
  probability: "Medium"
  impact: "Medium"
  mitigation_hint: "Test solution against boundary conditions early, define applicability limits explicitly"
- risk: "Analysis paralysis — continuous investigation without converging on a solution"
  probability: "Medium"
  impact: "Medium"
  mitigation_hint: "Set decision points with criteria: 'If we know X by sprint N, proceed with Y. Otherwise, pivot.'"
- risk: "Unforeseen constraints discovered late that invalidate the solution approach"
  probability: "Low"
  impact: "High"
  mitigation_hint: "Map constraints comprehensively during framing, prototype solution against hardest constraints first"
- risk: "Stakeholder disagreement on what constitutes a valid solution"
  probability: "Medium"
  impact: "Medium"
  mitigation_hint: "Define acceptance criteria during framing, not after solution design. Get written agreement on what 'solved' means."
[/Section: Risk-Catalog]

[Section: Metrics]
quantitative:
  - "Hypotheses tested vs validated (convergence rate)"
  - "Solution coverage of identified root causes"
  - "Edge cases tested and passing"
qualitative:
  - "Stakeholder confidence in the solution (would they bet on it?)"
  - "Solution elegance (simplest approach that addresses root causes)"
  - "Transferability (could someone else implement this from the documentation?)"
milestone_examples:
  - "Problem framing validated by stakeholders"
  - "Key hypotheses tested with evidence"
  - "Solution validated against edge cases and failure modes"
  - "Implementation roadmap accepted"
[/Section: Metrics]

[Section: Issue-Breakdown]
breakdown_pattern: "investigation-oriented"
pattern_description: "Issues follow the investigation cycle: frame → hypothesize → test → design → validate. Each issue covers a distinct investigation thread or solution component that produces verifiable output."
typical_structure:
  - type: "Problem Analysis"
    description: "Investigate a specific aspect of the problem — root cause analysis, stakeholder impact, constraint mapping"
    typical_complexity: "3-4"
  - type: "Hypothesis Testing"
    description: "Formulate and test a specific hypothesis about the problem or solution"
    typical_complexity: "3"
  - type: "Solution Design"
    description: "Design a solution component or framework based on validated hypotheses"
    typical_complexity: "3-4"
  - type: "Validation"
    description: "Stress-test a solution against edge cases, failure modes, or adversarial scenarios"
    typical_complexity: "3"
  - type: "Synthesis & Documentation"
    description: "Consolidate findings into actionable recommendations and implementation guidance"
    typical_complexity: "2-3"
example_titles:
  - "Root cause analysis of system performance degradation"
  - "Test hypothesis: bottleneck is in data serialization layer"
  - "Design adaptive caching strategy based on usage patterns"
  - "Validate solution under peak load and failure conditions"
  - "Produce implementation roadmap with phased rollout plan"

### Cross-Cutting Patterns
"Assumption tracking and evidence logging span all investigation threads — consider a foundational issue that establishes the hypothesis registry and evidence standards before deep analysis begins."
[/Section: Issue-Breakdown]
