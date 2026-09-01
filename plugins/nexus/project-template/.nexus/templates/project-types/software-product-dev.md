# Software / Product Development
*Domain Profile v1.0.0 | Sprint: 060*

[Section: Profile]
type_name: "Software / Product Development"
category: "Technical"
description: "Building software products — applications, APIs, tools, platforms. Choose when the primary output is working, tested, deployable code."
wizard_emphasis: "Iterative delivery, testing strategy, user feedback loops, technical architecture"
phase_character: "Build-heavy with feedback loops — prototype early, validate often, ship incrementally"
typical_deliverables: "Working software, APIs, UIs, CLIs, documentation, test suites"
wizard_depth: "light"

spec_version: "1.0.0"
template_version: "1.0.0"
[/Section: Profile]

[Section: Framing-Hints]
vision_question: "What are we building, and what problem does it solve for users?"
scope_emphasis: "Feature boundaries, platform targets, performance requirements, integration surface"
deliverable_framing: "Working, testable components — features users interact with, not internal tasks"
risk_framing: "Technical debt, integration complexity, dependency management, scale assumptions"
effort_framing: "Sprints map to build cycles — each should produce something testable"
constraint_emphasis: "Platform requirements, deployment environment, backward compatibility, API contracts"
[/Section: Framing-Hints]

[Section: Deliverable-Templates]
### MVP Examples
- name: "Core Application"
  description: "Primary functionality that solves the central user problem"
  quality_criteria: "Runs without critical bugs, handles happy path, basic error handling"
- name: "API / Integration Layer"
  description: "Programmatic interface for external consumers or internal components"
  quality_criteria: "Documented endpoints, validated inputs, consistent error responses"
- name: "User Documentation"
  description: "Setup guide, basic usage instructions, API reference if applicable"
  quality_criteria: "New user can install and use core features without external help"

### Enhanced Examples
- name: "Advanced Features"
  description: "Power-user capabilities, customization, automation, bulk operations"
  quality_criteria: "Consistent with core UX, tested, documented"
- name: "Performance & Reliability"
  description: "Caching, monitoring, graceful degradation, load handling"
  quality_criteria: "Defined SLAs met under expected load"
- name: "Developer Tooling"
  description: "CLI tools, debugging aids, migration scripts, development environment setup"
  quality_criteria: "Reduces common development tasks measurably"

### Future Examples
- name: "Platform Extensibility"
  description: "Plugin system, public API, SDK, third-party integration framework"
  quality_criteria: "External developers can extend without modifying core"
- name: "Analytics & Insights"
  description: "Usage tracking, performance dashboards, business intelligence"
  quality_criteria: "Actionable metrics accessible to relevant stakeholders"

### Categorization Guidance
"MVP = users can accomplish the core task end-to-end. Enhanced = users accomplish it better, faster, or more reliably. Future = the ecosystem grows beyond the core use case."
[/Section: Deliverable-Templates]

[Section: Phase-Templates]
### Simple (2-3 phases)
- phase: "Foundation & Core Build"
  objective: "Architecture, core features, basic deployment"
  typical_deliverables: "Core application, initial documentation"
  milestone: "Core functionality deployed and usable"
- phase: "Polish & Ship"
  objective: "Bug fixes, UX refinement, documentation completion"
  typical_deliverables: "Refined application, complete documentation"
  milestone: "Production-ready release"

### Standard (3-4 phases)
- phase: "Architecture & Setup"
  objective: "Technical decisions, project scaffolding, CI/CD, development environment"
  typical_deliverables: "Project structure, build pipeline, architecture documentation"
  milestone: "Development environment operational, architecture validated"
- phase: "Core Implementation"
  objective: "Build primary features iteratively, test continuously"
  typical_deliverables: "Core application, API layer, unit/integration tests"
  milestone: "MVP features functional and tested"
- phase: "Integration & Hardening"
  objective: "Connect components, performance tuning, edge cases, security"
  typical_deliverables: "Integrated system, performance benchmarks, security review"
  milestone: "System stable under realistic conditions"
- phase: "Release & Documentation"
  objective: "Final testing, documentation, deployment, handoff"
  typical_deliverables: "Production deployment, user documentation, developer guide"
  milestone: "Successful production deployment"

### Complex (5-6 phases)
- phase: "Discovery & Proof of Concept"
  objective: "Evaluate technical feasibility, prototype risky components"
  typical_deliverables: "Prototypes, feasibility report, refined architecture"
  milestone: "Key technical risks validated or mitigated"
- phase: "Foundation"
  objective: "Core infrastructure, data layer, authentication, CI/CD"
  typical_deliverables: "Project scaffolding, data models, build pipeline"
  milestone: "Foundation supports feature development"
- phase: "Core Features"
  objective: "Build MVP functionality iteratively"
  typical_deliverables: "Core application features, API, test suite"
  milestone: "MVP feature-complete"
- phase: "Advanced Features & Integration"
  objective: "Enhanced capabilities, third-party integrations, performance"
  typical_deliverables: "Enhanced features, integrations, monitoring"
  milestone: "Full feature set operational"
- phase: "Hardening & Scale"
  objective: "Load testing, security audit, reliability engineering"
  typical_deliverables: "Performance benchmarks, security report, SLA documentation"
  milestone: "Production-grade quality achieved"
- phase: "Launch & Stabilize"
  objective: "Deployment, documentation, monitoring, initial support"
  typical_deliverables: "Production deployment, complete documentation, runbooks"
  milestone: "Stable production operation"

### Phase Naming Guidance
"Use software lifecycle terms: Foundation, Implementation, Integration, Hardening, Release. Avoid generic business terms (Discovery, Strategy) unless genuinely applicable."
[/Section: Phase-Templates]

[Section: Risk-Catalog]
- risk: "Technical debt accumulation from rapid feature delivery"
  probability: "High"
  impact: "Medium"
  mitigation_hint: "Allocate refactoring time each sprint, track debt explicitly"
- risk: "Scope creep through incremental feature additions"
  probability: "High"
  impact: "Medium"
  mitigation_hint: "Strict MVP boundary, defer enhancements to later phases"
- risk: "Integration complexity between components or external services"
  probability: "Medium"
  impact: "High"
  mitigation_hint: "Prototype integrations early, define API contracts upfront"
- risk: "Performance issues discovered late under realistic load"
  probability: "Medium"
  impact: "High"
  mitigation_hint: "Load test early with representative data, set performance budgets"
- risk: "Dependency on external libraries or services with breaking changes"
  probability: "Medium"
  impact: "Medium"
  mitigation_hint: "Pin versions, abstract external dependencies, monitor changelogs"
- risk: "Architecture decisions that don't scale with growing requirements"
  probability: "Low"
  impact: "High"
  mitigation_hint: "Validate architecture with proof of concept before full build"
[/Section: Risk-Catalog]

[Section: Metrics]
quantitative:
  - "Feature completion rate (delivered vs planned per sprint)"
  - "Test coverage percentage on critical paths"
  - "Bug count by severity (critical/major/minor)"
  - "Build/deploy success rate"
qualitative:
  - "Code maintainability (would a new developer understand this?)"
  - "User experience coherence across features"
  - "Documentation completeness and accuracy"
milestone_examples:
  - "Architecture validated with proof of concept"
  - "MVP features functional and passing tests"
  - "Successful deployment to production environment"
  - "User documentation covers all core workflows"
[/Section: Metrics]

[Section: Issue-Breakdown]
breakdown_pattern: "component-oriented"
pattern_description: "Deliverables break into components or feature areas. Each issue covers a coherent unit of functionality that can be analyzed, built, and tested independently."
typical_structure:
  - type: "Feature Implementation"
    description: "Build a specific user-facing feature or capability end-to-end"
    typical_complexity: "3-4"
  - type: "Infrastructure / Foundation"
    description: "Non-user-facing systems: data layer, auth, CI/CD, monitoring"
    typical_complexity: "2-3"
  - type: "Integration"
    description: "Connect components or external services, validate data flow"
    typical_complexity: "3-4"
  - type: "Documentation"
    description: "User guides, API reference, developer onboarding, architecture docs"
    typical_complexity: "2"
  - type: "Quality & Testing"
    description: "Test suite creation, performance benchmarking, security review"
    typical_complexity: "2-3"
example_titles:
  - "Implement user authentication and session management"
  - "Build REST API for core data operations"
  - "Create deployment pipeline with staging environment"
  - "Design and implement dashboard UI"
  - "Write user documentation and setup guide"

### Cross-Cutting Patterns
"Error handling strategy, logging conventions, and configuration management typically span all components — consider a foundational issue that establishes these patterns before feature work begins."
[/Section: Issue-Breakdown]
