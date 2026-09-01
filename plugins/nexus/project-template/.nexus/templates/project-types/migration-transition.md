# Migration / Transition
*Domain Profile v1.0.0 | Sprint: 060*

[Section: Profile]
type_name: "Migration / Transition"
category: "Technical"
description: "Moving from one system, platform, process, or architecture to another. Choose when the challenge is getting from a known current state to a defined target state while maintaining continuity — replacing the engine while the plane is flying."
wizard_emphasis: "Current state analysis, target state design, migration strategy, data integrity, rollback planning, cutover coordination"
phase_character: "Assess-plan-build-migrate-validate-cutover — methodical and risk-conscious. Parallel operation during transition. Every step must be reversible until final cutover."
typical_deliverables: "Migration plans, data migration scripts, compatibility layers, cutover runbooks, validation reports, rollback procedures"
wizard_depth: "thorough"

spec_version: "1.0.0"
template_version: "1.0.0"
[/Section: Profile]

[Section: Framing-Hints]
vision_question: "What are we migrating from and to, and what does a successful transition look like with zero data loss and minimal disruption?"
scope_emphasis: "Migration boundaries — which systems, data, users, and processes move, which stay, what's the coexistence period"
deliverable_framing: "Working migration with verified integrity — the target system works at least as well as the source, and nothing was lost in transit"
risk_framing: "Data loss, extended downtime, incomplete migration, feature regression, user disruption, rollback failure"
effort_framing: "Sprints map to migration layers — each layer migrated, validated, and confirmed before the next. Parallel operation extends timeline."
constraint_emphasis: "Downtime windows, data volume, backward compatibility requirements, user retraining needs, regulatory constraints on data handling"
[/Section: Framing-Hints]

[Section: Deliverable-Templates]
### MVP Examples
- name: "Current State Assessment"
  description: "Complete inventory of what's being migrated: systems, data, integrations, users, processes"
  quality_criteria: "Nothing discovered during migration that wasn't in the assessment, dependencies mapped"
- name: "Migration Plan & Strategy"
  description: "Detailed plan: what moves when, in what order, with what validation, and how to roll back"
  quality_criteria: "Sequencing reflects dependencies, each step has validation criteria, rollback tested"
- name: "Migrated System"
  description: "Target system operational with all data, integrations, and functionality migrated"
  quality_criteria: "Data integrity verified, all functions working, performance meets or exceeds source system"

### Enhanced Examples
- name: "Data Migration & Validation Toolkit"
  description: "Automated scripts for data extraction, transformation, loading, and integrity verification"
  quality_criteria: "Handles full data volume, validates integrity post-migration, idempotent and rerunnable"
- name: "Compatibility / Bridge Layer"
  description: "Temporary interface allowing old and new systems to coexist during transition"
  quality_criteria: "Both systems functional during coexistence, data synchronized, no user confusion"
- name: "User Transition Package"
  description: "Training materials, mapping guides, and support resources for users moving to the new system"
  quality_criteria: "Users can perform all previous tasks in the new system, common workflows documented"

### Future Examples
- name: "Decommission Plan"
  description: "Plan for shutting down the source system after migration is confirmed successful"
  quality_criteria: "Data archived, dependencies severed cleanly, rollback window defined, decommission reversible"
- name: "Migration Playbook"
  description: "Reusable framework for similar future migrations based on lessons learned"
  quality_criteria: "Generalizes from this specific migration, captures decision points and validation approaches"

### Categorization Guidance
"MVP = data and functionality successfully migrated with verified integrity. Enhanced = the transition is smooth for users and the tooling is robust. Future = the old system is safely decommissioned and the approach is reusable."
[/Section: Deliverable-Templates]

[Section: Phase-Templates]
### Simple (2-3 phases)
- phase: "Assessment & Planning"
  objective: "Inventory current state, design target state mapping, plan migration sequence"
  typical_deliverables: "Current state assessment, migration plan, data mapping"
  milestone: "Migration plan approved with validated data mapping"
- phase: "Migration & Validation"
  objective: "Execute migration, validate integrity, confirm target system operational"
  typical_deliverables: "Migrated system, validation report, cutover confirmation"
  milestone: "Migration complete with verified data integrity and functional parity"

### Standard (3-4 phases)
- phase: "Discovery & Assessment"
  objective: "Inventory everything being migrated: data, integrations, configurations, dependencies"
  typical_deliverables: "System inventory, data profiling, dependency map, risk assessment"
  milestone: "Complete picture of what's migrating with no unknown dependencies"
- phase: "Design & Pilot"
  objective: "Design migration approach, build tooling, pilot with a representative subset"
  typical_deliverables: "Migration design, data transformation rules, pilot results, refined approach"
  milestone: "Pilot migration successful with validated data integrity"
- phase: "Full Migration"
  objective: "Execute migration at full scale with validation at each stage"
  typical_deliverables: "Migrated data and systems, validation results, issue resolution log"
  milestone: "All data and systems migrated with integrity confirmed"
- phase: "Cutover & Stabilization"
  objective: "Switch users to new system, monitor, resolve issues, confirm stability"
  typical_deliverables: "Cutover execution, monitoring results, user transition support, stabilization report"
  milestone: "Users operating on new system with stable performance for defined period"

### Complex (5-6 phases)
- phase: "Current State Deep Dive"
  objective: "Comprehensive inventory: data volumes, schemas, integrations, undocumented dependencies, tribal knowledge"
  typical_deliverables: "Detailed system inventory, data profiling report, integration catalog, risk register"
  milestone: "Current state fully documented including undocumented dependencies"
- phase: "Target State Design"
  objective: "Design how everything maps to the target, define transformation rules, plan coexistence"
  typical_deliverables: "Target architecture, data mapping rules, coexistence strategy, migration sequencing"
  milestone: "Target state design approved with clear mapping from current state"
- phase: "Tooling & Pilot"
  objective: "Build migration tooling, test with representative subset, validate approach"
  typical_deliverables: "Migration scripts, validation tools, pilot results, approach refinements"
  milestone: "Tooling handles pilot data correctly, approach validated"
- phase: "Phased Migration"
  objective: "Migrate in planned waves, validate each wave, maintain coexistence"
  typical_deliverables: "Wave-by-wave migration results, integrity reports, issue log"
  milestone: "All waves complete with integrity verified at each stage"
- phase: "Cutover & Parallel Run"
  objective: "Switch to target system, run parallel validation, resolve discrepancies"
  typical_deliverables: "Cutover execution, parallel run comparison, discrepancy resolution"
  milestone: "Target system primary with parallel validation confirming parity"
- phase: "Stabilization & Decommission"
  objective: "Confirm stability, transition users, archive source system, decommission"
  typical_deliverables: "Stabilization report, user transition completion, decommission plan execution"
  milestone: "Source system decommissioned, target system stable and fully owned by operations"

### Phase Naming Guidance
"Use migration lifecycle language: Assessment, Design, Pilot, Migration, Cutover, Parallel Run, Stabilization, Decommission. Emphasize the systematic, reversible nature of the transition. Avoid generic software terms (Foundation, Hardening) and business terms (Strategy, Alignment)."
[/Section: Phase-Templates]

[Section: Risk-Catalog]
- risk: "Data loss or corruption during migration"
  probability: "Medium"
  impact: "High"
  mitigation_hint: "Validate integrity at every stage, maintain source system until migration confirmed, checksums on all transfers"
- risk: "Undocumented dependencies discovered during migration"
  probability: "High"
  impact: "High"
  mitigation_hint: "Invest heavily in discovery phase, trace all integrations and data flows, interview system users not just documentation"
- risk: "Extended downtime during cutover exceeding acceptable window"
  probability: "Medium"
  impact: "High"
  mitigation_hint: "Rehearse cutover procedure, optimize for speed, have abort criteria and rollback tested"
- risk: "Feature regression — target system missing functionality that users depend on"
  probability: "Medium"
  impact: "Medium"
  mitigation_hint: "Map all features during assessment (including undocumented ones), validate feature parity before cutover"
- risk: "Rollback failure — can't revert to source system if migration fails"
  probability: "Low"
  impact: "High"
  mitigation_hint: "Test rollback procedure before starting migration, maintain source system integrity throughout, define point of no return clearly"
- risk: "User resistance or confusion during transition"
  probability: "Medium"
  impact: "Medium"
  mitigation_hint: "Communicate timeline clearly, provide training and mapping guides, offer support period after cutover"
[/Section: Risk-Catalog]

[Section: Metrics]
quantitative:
  - "Data integrity rate (records migrated correctly vs total)"
  - "Feature parity coverage (functions verified in target vs source)"
  - "Migration throughput (data volume processed per time unit)"
  - "Downtime duration vs planned window"
qualitative:
  - "User confidence in the new system (would they trust it with real work?)"
  - "Rollback readiness (how confidently could we revert if needed?)"
  - "Operational handoff quality (can ops team support the new system?)"
milestone_examples:
  - "Current state fully assessed with dependency map complete"
  - "Pilot migration successful with data integrity confirmed"
  - "Full migration complete with all validation checks passing"
  - "Cutover executed and system stable for defined stabilization period"
[/Section: Metrics]

[Section: Issue-Breakdown]
breakdown_pattern: "migration-layer-oriented"
pattern_description: "Issues follow migration layers or data domains. Each issue covers a specific system component, data domain, or integration that can be migrated and validated independently."
typical_structure:
  - type: "Assessment & Inventory"
    description: "Document a specific system, data domain, or integration in detail"
    typical_complexity: "2-3"
  - type: "Data Migration"
    description: "Migrate a specific data domain with transformation, validation, and integrity checks"
    typical_complexity: "3-4"
  - type: "Integration Migration"
    description: "Migrate a specific integration point, rebuild connections in the target system"
    typical_complexity: "3-4"
  - type: "Compatibility Layer"
    description: "Build temporary bridge between old and new systems for coexistence period"
    typical_complexity: "3"
  - type: "Cutover & Validation"
    description: "Plan and execute cutover for a specific component with rollback procedure"
    typical_complexity: "3"
example_titles:
  - "Assess and document legacy database schema and data quality"
  - "Migrate customer data with address normalization and deduplication"
  - "Rebuild payment gateway integration for new platform"
  - "Build API compatibility layer for third-party consumers during transition"
  - "Plan and execute user cutover with parallel run validation"

### Cross-Cutting Patterns
"Rollback procedures and data integrity validation span all migration layers — establish the rollback strategy and validation framework as foundational issues before any data moves."
[/Section: Issue-Breakdown]
