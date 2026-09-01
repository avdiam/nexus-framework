# project-state.md
*Version: 2.10.1 | Date: 2026-08-20 | Sprint: 110*

<!-- Instance version: copy this header's version to instances created from this template -->

<!-- 
TEMPLATE USAGE:
- /nexus-setup-project copies this template to create project-state.md at STEP 0
- The wizard (8 steps, 0-7) then progressively patches each section as answers are collected
- Section markers [SECTION] enable partial loading (70-90% token savings)
- YAML structure enables programmatic patching by operations
- Fields marked {STEP X} reference /nexus-setup-project wizard steps
-->

_updated: YYYY-MM-DD HH:MM
_project_status: Planning|Active|On-Hold|Complete
_project_type: code
# Project type: code | creative | mixed. Set during setup-project. Determines backup strategy.
# code = text/md/yaml/code files only (git handles backups)
# creative = binary deliverables (docx/pptx/jpg/pdf) — needs .nexus/backups/
# mixed = code + binary deliverables — hybrid backup strategy
_self_hosting: false
# Self-hosting flag: true ONLY when this project IS NEXUS's own meta-project (NEXUS building NEXUS).
# Gates §Architect-Pattern Activation matrix in /nexus-setup-project STEP 1E and the
# project-state read in /nexus-generate-mvp STEP 0. Default false for all user projects.
_current_phase: Phase-Name
_completion_percentage: XX%
_health_status: Green|Yellow|Red

[PROJECT_DEFINITION]
title: "{Project Name}"
vision: "{What we're building and why - STEP 2}"
problem_domain: "{What problem we're solving}"
project_type: "{Software/Product Dev|Research & Analysis|Complex Problem Solving|Product Design|System Integration|Data & Analytics|Strategic/Business Planning|Educational/Training|Creative/Content|Operations/Process|Event/Campaign|Compliance/Audit|Migration/Transition - STEP 1}"
project_domain: "{Specific domain/category - STEP 1}"
brownfield: false  # true if ongoing project with existing work, false if new project
context_mapping_skipped: false  # true if user declined context mapping at setup (can run later via "map project context")
[/PROJECT_DEFINITION]

[SCOPE_AND_BOUNDARIES]
in_scope:
  - "{Major deliverable 1 - STEP 3}"
  - "{Core feature set}"
  - "{Quality standards}"

out_of_scope:
  - "{Excluded features - STEP 3}"
  - "{Future phase items}"
  - "{Boundary limitations}"

boundaries:
  - "{Technical boundaries - STEP 3}"
  - "{Process limitations}"
  - "{Resource constraints}"

negations:
  # What this project is NOT responsible for. Populated by setup-project STEP 3.D
  # ("Scope Negation") when project-type activation is Full or Light. Distinct from
  # out_of_scope (features excluded): negations are responsibility-disclaims ("I do not...").
  # Used by downstream issue creation + phase handoffs to decide when out-of-scope work
  # escalates as a new proposal rather than expanding the current project silently.
  - "{e.g., 'not responsible for mobile app', 'not responsible for SOC 2 compliance' - STEP 3.D}"

success_constraints:
  mvp_minimum: "{Absolute minimum that would be valuable - STEP 4}"
  sufficiency_threshold: "{Good enough without over-engineering - STEP 4}"
  completion_criteria: "{When to declare project done - STEP 4}"
  note: "Metron Ariston principle - just enough structure for emergence"
[/SCOPE_AND_BOUNDARIES]

[PROJECT_CONSTITUTION]
# Optional — non-negotiable architectural principles for this project.
# Created during setup-project STEP 3 if the user identifies governing principles.
# If empty or absent, constitution checks in Analyze/Validate are skipped.
principles: []
  # - principle: "{Principle name}"
  #   rationale: "{Why this is non-negotiable}"
  #   enforced_at: ["analysis", "evaluation"]
[/PROJECT_CONSTITUTION]

[DELIVERABLES]
mvp_deliverables:
  - name: "{Core System - STEP 4}"
    description: "{Main product/output}"
    quality_criteria: "{Definition of done}"
    target_phase: "{Phase X}"
    issue_refs: []
    # disposition: OPTIONAL terminal disposition for a deliverable that legitimately has no linked
    #   issues. Set ONLY to resolve the issue-validation orphaned-deliverable flag with an explicit
    #   decision (not by ignoring it). Values:
    #     foundational-permanent — a real completion predating ISS-driven tracking; keep, never backfill.
    #     pending-backfill       — backfill ISS files intended later; still flagged until done.
    #   Unset/absent = normal: empty issue_refs flagged MINOR until linked or dispositioned (ISS-198).
    handoff_to: []
    # Populated by setup-project STEP 4.F ("Handoff Contracts Between Deliverables") when
    # project-type activation is Full or Light. Each entry references a downstream deliverable
    # by `name:` and declares PAYLOAD/SUCCESS/FAILURE/TIMEOUT for the handoff. Example:
    #   - target: "{downstream deliverable name}"
    #     payload: "{what this deliverable produces for the target}"
    #     success: "{conditions under which target can consume}"
    #     failure: "{behavior if expected payload can't be produced}"
    #     timeout: "{behavior if this deliverable runs long}"

enhanced_deliverables:
  - name: "{Supporting deliverable - STEP 4}"
    description: "{Supporting materials}"
    quality_criteria: "{Ready for use}"
    target_phase: "{Phase X}"
    issue_refs: []
    handoff_to: []

future_deliverables:
  # NOT processed by /nexus-generate-mvp — issues created only after
  # promotion to mvp/enhanced via /nexus-setup-project Update Mode
  - name: "{Future deliverable - STEP 4}"
    description: "{Aspirational output}"
    quality_criteria: "{What 'done' looks like}"
    target_phase: "{Phase X}"
    issue_refs: []
    handoff_to: []

acceptance_criteria:
  - "{All features tested - STEP 4}"
  - "{Documentation complete}"
  - "{Performance benchmarks met}"
[/DELIVERABLES]

[STAKEHOLDERS]
primary_users:
  - "{Who will use this daily - STEP 6}"

decision_makers:
  - "{Who approves key decisions - STEP 6}"

other_stakeholders:
  - "{Affected parties - STEP 6}"

communication_plan:
  - "{How we gather feedback}"
  - "{Reporting schedule}"
[/STAKEHOLDERS]

[CONSTRAINTS_AND_RISKS]
timeline_constraints:
  - "{Hard deadline: YYYY-MM-DD - STEP 3}"
  - "{Milestone dependencies}"

resource_constraints:
  - "{Token budget: XXXK tokens - STEP 3}"
  - "{Effort limitations}"

technical_constraints:
  - "{Must integrate with X - STEP 3}"
  - "{Platform compatibility}"

dependencies:
  - dependency: "{External factor}"
    impact: "{What it blocks}"
    mitigation: "{How to handle}"

identified_risks:
  - risk: "{Risk description - STEP 6 (risks)}"
    probability: "Low|Medium|High"
    impact: "Low|Medium|High"
    mitigation: "{Strategy}"

preliminary_technology:
  known_requirements:
    - "{Must use Python - STEP 3}"
  integration_requirements:
    - "{Must work with existing API - STEP 3}"
  platform_constraints:
    - "{Environment limitations - STEP 3}"
  note: "Detailed tech stack decided during Phase 1: Discovery"
[/CONSTRAINTS_AND_RISKS]

[SUCCESS_METRICS]
quantitative_metrics:
  - "{Measurable outcome - STEP 6}"
  - "{Performance benchmark}"

qualitative_metrics:
  - "{User satisfaction measure - STEP 6}"
  - "{System quality measure}"

milestones_and_checkpoints:
  - "{Phase complete by Sprint XXX - STEP 6}"
  - "{Launch by Sprint XXX}"
[/SUCCESS_METRICS]

[PROJECT_PHASES]
# DYNAMIC STRUCTURE - Populated from STEP 5
# Phase count varies: 2 phases (simple), 4 phases (standard), 6 phases (complex)

phase_1:
  name: "Phase 1: Discovery & Analysis"
  objective: "{Research, architecture, analysis}"
  deliverables: []
  milestone: "{Technical direction decided}"
  status: "Planned|Active|Complete"
  completion: "0%"
  sprints: []
  issues_planned: []
  estimated_sprints: 2-3
  entry_criteria: []
  # Populated by setup-project STEP 5.D ("Workflow-Tree Articulation") when project-type
  # activation is Full or Light. What must be true before this phase starts.
  # Example: ["Project setup complete", "Stakeholder alignment documented"]
  exit_criteria: []
  # What must be true to advance from this phase. Read by generate-mvp STEP 3 phase-handoff
  # sub-step to derive the entry gate for the next phase.
  # Example: ["All MVP issues analyzed (scores A:≥4)", "Success criteria locked per issue"]
  depends_on: []
  # List of upstream phase ids that must complete before this phase can start.
  # Phase 1 typically has empty depends_on; later phases reference predecessor ids.

phase_2:
  name: "Phase 2: Foundation"
  objective: "{Core infrastructure}"
  deliverables: []
  milestone: "{Foundation operational}"
  status: "Planned"
  completion: "0%"
  sprints: []
  issues_planned: []
  estimated_sprints: 2-4
  entry_criteria: []
  exit_criteria: []
  depends_on: []

# Add phase_3, phase_4, etc. as needed (4-phase standard, 6-phase complex)
# Each additional phase carries the same fields including entry_criteria, exit_criteria,
# and depends_on (populated by setup-project STEP 5.D under Architect-Pattern Activation).
[/PROJECT_PHASES]

[MILESTONE_TRACKING]
# Milestones added as project progresses
# Format:
# milestone_X:
#   name: "{Milestone name}"
#   target_date: YYYY-MM-DD
#   actual_date: YYYY-MM-DD|TBD
#   status: Complete|At-Risk|Planned
#   phase_association: "{which phase}"
[/MILESTONE_TRACKING]

[PROGRESS_OVERVIEW]
overall_health: Green
current_sprint: XXX
completed_sprints:
  # Format: Populated by /nexus-update-state at sprint closure
  # - sprint: XXX
  #   date: "YYYY-MM-DD"
  #   resolved: [ISS-XXX, ISS-YYY]
  #   achievements: ["What was accomplished"]
total_issues_created: 0
total_issues_resolved: 0
blocked_issues: 0
at_risk_items: []
[/PROGRESS_OVERVIEW]

[CRITICAL_DECISIONS]
# Track architectural and strategic decisions with rationale
# Updated by: sprint closures, major pivots, user decisions

recent:
  # Last 5-10 decisions for quick reference
  - decision: "{What was decided}"
    rationale: "{Why this choice}"
    impact: "{What it affects}"
    sprint: XXX
    date: YYYY-MM-DD

architectural:
  # Foundational decisions that shape the project
  - decision: "{Core architectural choice}"
    rationale: "{Strategic reasoning}"
    impact: "{Long-term implications}"
    sprint: XXX

technical:
  # Technology and implementation decisions
  - decision: "{Technical choice}"
    rationale: "{Why this approach}"
    impact: "{What it enables/constrains}"
    sprint: XXX
[/CRITICAL_DECISIONS]

[KEY_RESOURCES]
# Project-level resources that persist across all sprints
# User-provided only - NEXUS knows system paths from [Section: Routing-Map] in CLAUDE.md

specifications:
  main: "{Primary spec/requirements document - STEP 1}"
  technical:
    - "{API spec, data schema, architecture doc - STEP 1}"

external_resources:
  - "{APIs, tools, documentation sites relevant to project - STEP 1}"

context_artifacts:  # Populated by /nexus-map-context (brownfield/context-rich projects)
  # - "CONTEXT.md"
  # - "STRUCTURE.md"
  # - "CONVENTIONS.md"
  # - "CONCERNS.md"
[/KEY_RESOURCES]

[NEXT_PHASE_NOTES]
# Living section updated during sprint work and closures
# Guides strategic planning for upcoming work

immediate_priorities:
  - "{Next critical action}"
  - "{Upcoming milestone}"

key_learnings:
  - "{Insight from recent work}"
  - "{Pattern discovered}"

watch_items:
  - "{Risk to monitor}"
  - "{Dependency to track}"

emerging_opportunities:
  - "{Potential improvement}"
  - "{Future enhancement}"
[/NEXT_PHASE_NOTES]
