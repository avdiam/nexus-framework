# System Integration
*Domain Profile v1.0.0 | Sprint: 060*

[Section: Profile]
type_name: "System Integration"
category: "Technical"
description: "Connecting systems, migrating data, or unifying platforms that need to work together. Choose when the challenge is making existing things talk to each other — not building something new from scratch."
wizard_emphasis: "Dependencies, compatibility, data mapping, testing rigor, rollback planning"
phase_character: "Dependency-mapped and test-heavy — understand interfaces first, prototype connections early, test exhaustively before go-live"
typical_deliverables: "Integrated systems, adapters, migration plans, data mappings, compatibility reports, runbooks"
wizard_depth: "standard"

spec_version: "1.0.0"
template_version: "1.0.0"
[/Section: Profile]

[Section: Framing-Hints]
vision_question: "What systems need to work together, and what does successful integration look like for the people who use them?"
scope_emphasis: "Integration boundaries — which systems, which data flows, which direction, what stays untouched"
deliverable_framing: "Working connections with verified data flow, not just documentation — prove it works end-to-end"
risk_framing: "API incompatibility, data loss during migration, version drift, cascading failures across connected systems"
effort_framing: "Sprints map to integration layers — each sprint should validate a connection end-to-end before adding the next"
constraint_emphasis: "API contracts, data formats, uptime requirements, backward compatibility, change windows"
[/Section: Framing-Hints]

[Section: Deliverable-Templates]
### MVP Examples
- name: "Integration Architecture"
  description: "System map showing all connections, data flows, protocols, and failure boundaries"
  quality_criteria: "All interfaces documented, data formats specified, failure modes identified"
- name: "Core Integration"
  description: "Primary system connections implemented and verified with production-like data"
  quality_criteria: "Data flows correctly end-to-end, error handling tested, performance acceptable"
- name: "Data Mapping & Transformation"
  description: "Complete mapping between source and target schemas with transformation rules"
  quality_criteria: "All fields mapped, edge cases handled, data integrity verified with sample data"

### Enhanced Examples
- name: "Monitoring & Alerting"
  description: "Visibility into integration health: data flow rates, error rates, latency, anomalies"
  quality_criteria: "Key metrics dashboarded, alerts configured for failure conditions, runbook linked"
- name: "Migration Tooling"
  description: "Automated tools for data migration with validation, rollback, and progress tracking"
  quality_criteria: "Handles full dataset, validates integrity post-migration, rollback tested"
- name: "Integration Test Suite"
  description: "Automated tests covering all integration points, data scenarios, and failure modes"
  quality_criteria: "Runs in CI/CD, covers happy path and error cases, includes performance checks"

### Future Examples
- name: "Self-Healing Integration"
  description: "Automated recovery from common failure modes without manual intervention"
  quality_criteria: "Known failure modes handled automatically, unknown failures escalated with context"
- name: "Integration Platform"
  description: "Reusable framework for adding future integrations with consistent patterns"
  quality_criteria: "New integrations follow established patterns, onboarding time reduced measurably"

### Categorization Guidance
"MVP = systems connected and data flows correctly under normal conditions. Enhanced = integration is reliable, monitored, and maintainable. Future = the integration approach becomes a platform capability."
[/Section: Deliverable-Templates]

[Section: Phase-Templates]
### Simple (2-3 phases)
- phase: "Assessment & Design"
  objective: "Map systems, define interfaces, identify data transformations, design integration approach"
  typical_deliverables: "Integration architecture, data mapping, API contracts"
  milestone: "All interfaces documented and integration approach agreed"
- phase: "Implementation & Validation"
  objective: "Build connections, migrate data, test end-to-end, deploy"
  typical_deliverables: "Working integration, test results, deployment runbook"
  milestone: "Integration live with verified data flow"

### Standard (3-4 phases)
- phase: "Discovery & Assessment"
  objective: "Inventory systems, document APIs, assess data quality, identify risks and constraints"
  typical_deliverables: "System inventory, API documentation, data quality report, risk assessment"
  milestone: "Full picture of what connects to what, with gaps and risks identified"
- phase: "Architecture & Prototyping"
  objective: "Design integration architecture, prototype the riskiest connection, validate approach"
  typical_deliverables: "Integration architecture, proof-of-concept for critical path, data mapping"
  milestone: "Architecture validated through prototype of highest-risk integration"
- phase: "Implementation & Testing"
  objective: "Build all connections, comprehensive testing with realistic data, performance validation"
  typical_deliverables: "Working integrations, test suite, performance benchmarks"
  milestone: "All integrations passing end-to-end tests with production-like data"
- phase: "Deployment & Stabilization"
  objective: "Go-live, monitor, resolve issues, hand over to operations"
  typical_deliverables: "Production deployment, monitoring dashboards, runbooks, handover documentation"
  milestone: "Integration stable in production with operational ownership transferred"

### Complex (5-6 phases)
- phase: "Landscape Assessment"
  objective: "Complete inventory of systems, data flows, dependencies, and organizational ownership"
  typical_deliverables: "System landscape map, dependency graph, data flow catalog, stakeholder map"
  milestone: "Integration landscape fully documented with no unknown dependencies"
- phase: "Interface Analysis & Design"
  objective: "Deep analysis of each interface: protocols, data formats, rate limits, error behavior"
  typical_deliverables: "Interface specifications, data transformation rules, error handling strategy"
  milestone: "All interfaces specified with agreed contracts"
- phase: "Proof of Concept"
  objective: "Validate approach on the riskiest integration path with real data"
  typical_deliverables: "Working PoC, lessons learned, refined architecture"
  milestone: "Critical path validated, approach confirmed viable"
- phase: "Incremental Integration"
  objective: "Build connections incrementally, testing each layer before adding the next"
  typical_deliverables: "Working integrations (incremental), integration test suite"
  milestone: "All integrations functional and tested individually"
- phase: "End-to-End Validation"
  objective: "Full system testing, performance under load, failure mode testing, data integrity verification"
  typical_deliverables: "End-to-end test results, performance report, failure mode analysis"
  milestone: "System passes all integration scenarios including failure recovery"
- phase: "Cutover & Stabilization"
  objective: "Production deployment, parallel run, monitoring, issue resolution, operational handoff"
  typical_deliverables: "Production deployment, monitoring, runbooks, operational documentation"
  milestone: "Integration stable in production for defined stabilization period"

### Phase Naming Guidance
"Use integration lifecycle language: Assessment, Interface Analysis, Prototyping, Integration, Validation, Cutover, Stabilization. Emphasize the connection-building nature of the work. Avoid generic software terms (Foundation, Hardening) unless building a platform component."
[/Section: Phase-Templates]

[Section: Risk-Catalog]
- risk: "API incompatibility or undocumented behavior in external systems"
  probability: "High"
  impact: "High"
  mitigation_hint: "Prototype against real APIs early, don't trust documentation alone — test actual behavior"
- risk: "Data loss or corruption during migration or transformation"
  probability: "Medium"
  impact: "High"
  mitigation_hint: "Validate data integrity at every step, maintain rollback capability, run parallel systems during cutover"
- risk: "Cascading failures — one integration failure brings down connected systems"
  probability: "Medium"
  impact: "High"
  mitigation_hint: "Design circuit breakers and bulkheads, test failure isolation, define degradation strategy"
- risk: "Version drift — connected systems update independently and break integration"
  probability: "High"
  impact: "Medium"
  mitigation_hint: "Pin API versions, monitor changelog feeds, include version compatibility in integration tests"
- risk: "Performance degradation under realistic load (works in testing, fails in production)"
  probability: "Medium"
  impact: "High"
  mitigation_hint: "Load test with production-scale data early, identify bottlenecks before go-live"
- risk: "Change window constraints limit deployment and rollback options"
  probability: "Medium"
  impact: "Medium"
  mitigation_hint: "Plan cutover in detail including rollback, negotiate change windows early, have a no-go decision point"
[/Section: Risk-Catalog]

[Section: Metrics]
quantitative:
  - "Integration points validated end-to-end (connected vs planned)"
  - "Data integrity rate (records correctly transformed vs total)"
  - "Integration uptime and error rate in production"
  - "Latency per integration point under load"
qualitative:
  - "Operational confidence (would ops team support this without the project team?)"
  - "Documentation completeness (can a new engineer understand each integration?)"
  - "Failure recovery quality (how cleanly does the system degrade and recover?)"
milestone_examples:
  - "All interfaces documented with agreed contracts"
  - "Proof of concept validates critical integration path"
  - "End-to-end data flow verified with production-like data"
  - "Production cutover complete with stable monitoring"
[/Section: Metrics]

[Section: Issue-Breakdown]
breakdown_pattern: "interface-oriented"
pattern_description: "Issues follow integration points or data flows. Each issue covers a specific system connection or data transformation that can be designed, built, and tested independently."
typical_structure:
  - type: "Interface Analysis"
    description: "Document and validate a specific API, data format, or protocol"
    typical_complexity: "2-3"
  - type: "Data Mapping"
    description: "Define transformation rules between source and target schemas"
    typical_complexity: "3"
  - type: "Integration Implementation"
    description: "Build a specific system connection with error handling and retry logic"
    typical_complexity: "3-4"
  - type: "Integration Testing"
    description: "End-to-end validation of a specific data flow with edge cases"
    typical_complexity: "2-3"
  - type: "Migration & Cutover"
    description: "Plan and execute data migration for a specific system or dataset"
    typical_complexity: "3-4"
example_titles:
  - "Analyze and document payment gateway API behavior and constraints"
  - "Map customer data schema between CRM and analytics platform"
  - "Implement order synchronization between ERP and e-commerce system"
  - "Build end-to-end test suite for inventory data flow"
  - "Plan and execute historical data migration to new platform"

### Cross-Cutting Patterns
"Error handling strategy, retry policies, and data validation rules span all integration points — establish these as foundational issues before building individual connections."
[/Section: Issue-Breakdown]
