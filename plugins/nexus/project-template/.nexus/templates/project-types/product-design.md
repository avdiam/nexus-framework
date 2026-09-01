# Product Design
*Domain Profile v1.0.0 | Sprint: 060*

[Section: Profile]
type_name: "Product Design"
category: "Creative"
description: "Designing products, services, or experiences with a focus on user needs, prototyping, and iterative refinement. Choose when the primary output is a validated design — not yet a built product."
wizard_emphasis: "User research, prototyping, iteration cycles, design validation, stakeholder alignment"
phase_character: "Research-then-iterate — understand users deeply, concept broadly, prototype quickly, refine based on feedback"
typical_deliverables: "Prototypes, design specifications, user research findings, design systems, interaction guidelines"
wizard_depth: "standard"

spec_version: "1.0.0"
template_version: "1.0.0"
[/Section: Profile]

[Section: Framing-Hints]
vision_question: "What experience are we creating, and for whom? What should users feel or accomplish?"
scope_emphasis: "Design boundaries — which user journeys, touchpoints, and platforms are in scope"
deliverable_framing: "Design artifacts that communicate intent clearly enough for implementation — specs, prototypes, guidelines"
risk_framing: "User needs misunderstood, stakeholder misalignment, prototype-to-production gap, design debt"
effort_framing: "Sprints map to design cycles — research, concept, prototype, test, refine. Each cycle produces testable artifacts."
constraint_emphasis: "Platform constraints, brand guidelines, accessibility requirements, technical feasibility boundaries"
[/Section: Framing-Hints]

[Section: Deliverable-Templates]
### MVP Examples
- name: "User Research & Insights"
  description: "Understanding of target users: needs, pain points, behaviors, and context of use"
  quality_criteria: "Findings grounded in evidence (interviews, observation, data), actionable for design decisions"
- name: "Core Design & Prototype"
  description: "Interactive prototype of the primary user journey with key interactions defined"
  quality_criteria: "Testable with users, communicates design intent clearly, covers the core flow end-to-end"
- name: "Design Specification"
  description: "Detailed spec for implementation: components, interactions, states, edge cases"
  quality_criteria: "Developer can implement without ambiguity, all states and error conditions addressed"

### Enhanced Examples
- name: "Design System"
  description: "Reusable component library with patterns, tokens, and usage guidelines"
  quality_criteria: "Consistent across all touchpoints, documented with examples and anti-patterns"
- name: "Usability Validation"
  description: "Test results from user testing sessions with actionable findings"
  quality_criteria: "Tasks tested with representative users, issues severity-rated, recommendations prioritized"
- name: "Interaction Guidelines"
  description: "Motion, transitions, micro-interactions, and responsive behavior documentation"
  quality_criteria: "Developers can replicate intended behavior, edge cases covered"

### Future Examples
- name: "Design Evolution Roadmap"
  description: "Vision for how the design grows: future features, platform expansion, design maturity"
  quality_criteria: "Grounded in current architecture, prioritized by user impact"
- name: "Accessibility Audit & Remediation"
  description: "Comprehensive accessibility review with remediation plan"
  quality_criteria: "Meets target WCAG level, tested with assistive technologies"

### Categorization Guidance
"MVP = the core experience is designed and validated with users. Enhanced = the design is systematic, tested, and implementation-ready. Future = the design ecosystem evolves beyond the initial scope."
[/Section: Deliverable-Templates]

[Section: Phase-Templates]
### Simple (2-3 phases)
- phase: "Research & Concept"
  objective: "Understand users, define the problem space, explore design directions"
  typical_deliverables: "User insights, concept explorations, initial prototype"
  milestone: "Design direction validated with users or stakeholders"
- phase: "Design & Specification"
  objective: "Refine the chosen direction into detailed, implementable design"
  typical_deliverables: "Final prototype, design specification, component documentation"
  milestone: "Design approved and ready for implementation handoff"

### Standard (3-4 phases)
- phase: "Discovery & User Research"
  objective: "Understand users, map journeys, identify unmet needs and pain points"
  typical_deliverables: "User research findings, persona or archetype profiles, journey maps"
  milestone: "User needs validated and design opportunity clearly defined"
- phase: "Concept Development"
  objective: "Explore design directions, prototype key interactions, evaluate alternatives"
  typical_deliverables: "Concept explorations, low-fidelity prototypes, design direction recommendation"
  milestone: "Design direction selected with rationale"
- phase: "Detailed Design"
  objective: "Develop the chosen concept into full-fidelity, testable design"
  typical_deliverables: "High-fidelity prototype, interaction specifications, component library"
  milestone: "Design tested with users and refined based on feedback"
- phase: "Specification & Handoff"
  objective: "Prepare implementation-ready documentation, design system, developer handoff"
  typical_deliverables: "Design specification, design system, handoff documentation"
  milestone: "Development team can implement without design ambiguity"

### Complex (5-6 phases)
- phase: "Strategic Research"
  objective: "Landscape analysis, competitive audit, user research planning and execution"
  typical_deliverables: "Research plan, competitive analysis, user research findings"
  milestone: "Problem space mapped with evidence-based user understanding"
- phase: "Ideation & Exploration"
  objective: "Divergent thinking — explore many directions before converging"
  typical_deliverables: "Concept sketches, design principles, exploration prototypes"
  milestone: "Multiple viable directions identified with evaluation criteria"
- phase: "Concept Validation"
  objective: "Test promising concepts with users, validate assumptions, select direction"
  typical_deliverables: "Concept test results, validated direction, refined design principles"
  milestone: "Concept validated with users, direction locked"
- phase: "Detailed Design & Iteration"
  objective: "Full-fidelity design with iterative user testing and refinement"
  typical_deliverables: "High-fidelity prototype, usability test results, refined interactions"
  milestone: "Design meets usability targets through iterative testing"
- phase: "Design System & Standards"
  objective: "Systematize the design into reusable components and guidelines"
  typical_deliverables: "Design system, accessibility audit, interaction guidelines"
  milestone: "Design system complete and documented"
- phase: "Handoff & Support"
  objective: "Implementation support, design QA, knowledge transfer"
  typical_deliverables: "Implementation spec, design QA checklist, developer support documentation"
  milestone: "Implemented product matches design intent"

### Phase Naming Guidance
"Use design process language: Discovery, Research, Ideation, Concept, Prototyping, Validation, Specification, Handoff. Avoid engineering terms (Foundation, Hardening) unless the project involves design-engineering collaboration."
[/Section: Phase-Templates]

[Section: Risk-Catalog]
- risk: "User needs misunderstood — designing for assumed rather than actual behavior"
  probability: "Medium"
  impact: "High"
  mitigation_hint: "Validate assumptions with real users early and often, not just stakeholder opinions"
- risk: "Stakeholder misalignment on design direction"
  probability: "High"
  impact: "Medium"
  mitigation_hint: "Align on design principles and evaluation criteria before presenting concepts, not after"
- risk: "Prototype-to-production gap — design can't be faithfully implemented"
  probability: "Medium"
  impact: "High"
  mitigation_hint: "Involve engineering early for feasibility checks, design within known technical constraints"
- risk: "Scope creep through revision cycles — 'just one more iteration'"
  probability: "High"
  impact: "Medium"
  mitigation_hint: "Define iteration budget upfront (e.g., 2 major revision rounds), tie revisions to user test findings not opinions"
- risk: "Design debt — inconsistencies across touchpoints as design evolves"
  probability: "Medium"
  impact: "Medium"
  mitigation_hint: "Establish design system early, audit consistency before handoff"
- risk: "Accessibility overlooked until late stages"
  probability: "Medium"
  impact: "Medium"
  mitigation_hint: "Bake accessibility into design principles from the start, test with assistive technology during validation"
[/Section: Risk-Catalog]

[Section: Metrics]
quantitative:
  - "Usability test task completion rate"
  - "Design coverage (user journeys fully specified vs identified)"
  - "Component reuse rate across screens/touchpoints"
qualitative:
  - "User satisfaction and confidence during usability testing"
  - "Design-implementation fidelity (does the built product match the design?)"
  - "Stakeholder alignment on design direction"
milestone_examples:
  - "User research complete with validated insights"
  - "Design direction selected and stakeholder-approved"
  - "Usability testing shows target task completion rate"
  - "Design specification handed off to development"
[/Section: Metrics]

[Section: Issue-Breakdown]
breakdown_pattern: "journey-oriented"
pattern_description: "Issues follow user journeys or design components. Each issue covers a coherent design area that can be researched, designed, and validated independently."
typical_structure:
  - type: "User Research"
    description: "Investigate a specific user group, journey, or behavior pattern"
    typical_complexity: "2-3"
  - type: "Design Exploration"
    description: "Explore and evaluate design directions for a specific feature or interaction"
    typical_complexity: "3"
  - type: "Detailed Design"
    description: "Full-fidelity design of a user journey or component set"
    typical_complexity: "3-4"
  - type: "Design System"
    description: "Define reusable components, patterns, and guidelines"
    typical_complexity: "3"
  - type: "Usability Validation"
    description: "Test a design with users and document findings"
    typical_complexity: "2-3"
example_titles:
  - "Research onboarding experience pain points with new users"
  - "Explore navigation patterns for complex information architecture"
  - "Design complete checkout flow with error states and edge cases"
  - "Build component library for form elements and data display"
  - "Validate dashboard design with 5 representative users"

### Cross-Cutting Patterns
"Design principles and accessibility standards span all design work — establish these as a foundational issue before feature-specific design begins."
[/Section: Issue-Breakdown]
