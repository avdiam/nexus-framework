# Operations / Process Improvement
*Domain Profile v1.0.0 | Sprint: 060*

[Section: Profile]
type_name: "Operations / Process Improvement"
category: "Business"
description: "Improving existing processes, workflows, or operational systems. Choose when the goal is making something that already exists work better — faster, cheaper, more reliable, or more scalable."
wizard_emphasis: "Current state assessment, measurable improvement targets, change management, pilot-before-rollout"
phase_character: "Assess-heavy upfront, then design→pilot→rollout — changes must prove value at small scale before full deployment"
typical_deliverables: "Process maps, improvement plans, pilot results, rollout documentation, training materials"
wizard_depth: "standard"

spec_version: "1.0.0"
template_version: "1.0.0"
[/Section: Profile]

[Section: Framing-Hints]
vision_question: "What process or operation needs improving, and what does 'better' look like in measurable terms?"
scope_emphasis: "Process boundaries — which steps, teams, or systems are in scope vs adjacent but untouched"
deliverable_framing: "Improvements with measured impact, not just documentation — before/after evidence matters"
risk_framing: "Resistance to change, disruption during transition, measuring the wrong thing, pilot-to-rollout gap"
effort_framing: "Sprints map to improvement cycles — assess, design, pilot, measure, adjust, expand"
constraint_emphasis: "Operational continuity — can't break the running system while improving it"
[/Section: Framing-Hints]

[Section: Deliverable-Templates]
### MVP Examples
- name: "Current State Assessment"
  description: "Documented process map, bottleneck analysis, baseline measurements"
  quality_criteria: "Stakeholders recognize the map as accurate, metrics baselined with data"
- name: "Improvement Plan"
  description: "Specific changes with expected impact, implementation sequence, success metrics"
  quality_criteria: "Each change tied to a measurable outcome, sequenced by dependency and risk"
- name: "Pilot Implementation"
  description: "Changes applied to a controlled subset — one team, one region, one workflow"
  quality_criteria: "Pilot ran long enough to measure, results documented with before/after comparison"

### Enhanced Examples
- name: "Full Rollout Package"
  description: "Scaled implementation across all affected teams/systems with transition support"
  quality_criteria: "All targets transitioned, performance meets or exceeds pilot results"
- name: "Training & Adoption Materials"
  description: "Guides, checklists, video walkthroughs for new process adoption"
  quality_criteria: "New team members can follow the improved process without shadowing"
- name: "Monitoring Dashboard"
  description: "Ongoing visibility into process performance with alerting on regression"
  quality_criteria: "Key metrics tracked automatically, deviations flagged within defined thresholds"

### Future Examples
- name: "Continuous Improvement Framework"
  description: "Recurring review cadence, feedback loops, metric-driven improvement cycles"
  quality_criteria: "Team independently identifies and implements improvements without external facilitation"
- name: "Cross-Process Optimization"
  description: "Apply learnings to adjacent processes, identify systemic improvement opportunities"
  quality_criteria: "Documented playbook for assessing and improving related processes"

### Categorization Guidance
"MVP = the problem is understood and a proven improvement exists (even if only piloted). Enhanced = the improvement is deployed and sustained. Future = the organization can improve itself."
[/Section: Deliverable-Templates]

[Section: Phase-Templates]
### Simple (2-3 phases)
- phase: "Assess & Design"
  objective: "Map current process, identify bottlenecks, design targeted improvements"
  typical_deliverables: "Current state assessment, improvement plan"
  milestone: "Improvement opportunities identified and prioritized with stakeholder buy-in"
- phase: "Implement & Measure"
  objective: "Apply changes, measure impact, document results"
  typical_deliverables: "Implemented changes, before/after measurements, lessons learned"
  milestone: "Measurable improvement demonstrated against baseline"

### Standard (3-4 phases)
- phase: "Current State Assessment"
  objective: "Map processes, collect baseline metrics, identify pain points and bottlenecks"
  typical_deliverables: "Process maps, baseline metrics, bottleneck analysis"
  milestone: "Stakeholders agree on current state and priority improvement areas"
- phase: "Solution Design"
  objective: "Design specific improvements, define success metrics, plan pilot"
  typical_deliverables: "Improvement plan, success criteria, pilot design"
  milestone: "Improvement approach approved with clear pilot scope"
- phase: "Pilot & Validate"
  objective: "Implement changes at small scale, measure results, iterate"
  typical_deliverables: "Pilot results, adjusted approach, rollout readiness assessment"
  milestone: "Pilot demonstrates target improvement with acceptable disruption"
- phase: "Rollout & Stabilize"
  objective: "Scale to full scope, train teams, establish monitoring"
  typical_deliverables: "Full implementation, training materials, monitoring dashboard"
  milestone: "All targets operating under improved process with sustained metrics"

### Complex (5-6 phases)
- phase: "Discovery & Stakeholder Mapping"
  objective: "Understand the operational landscape, identify all affected parties and systems"
  typical_deliverables: "Stakeholder map, system inventory, initial scope definition"
  milestone: "Full picture of affected processes, people, and systems"
- phase: "Deep Assessment"
  objective: "Detailed process mapping, root cause analysis, quantitative baseline"
  typical_deliverables: "Detailed process maps, root cause analysis, baseline metrics"
  milestone: "Root causes identified and quantified, not just symptoms"
- phase: "Solution Design & Planning"
  objective: "Design improvements, assess change impact, plan phased rollout"
  typical_deliverables: "Improvement designs, change impact assessment, phased rollout plan"
  milestone: "Solution validated against root causes, rollout plan approved"
- phase: "Pilot"
  objective: "Controlled implementation, measure, iterate"
  typical_deliverables: "Pilot results, refined approach, go/no-go for expansion"
  milestone: "Pilot proves viability and surfaces scaling considerations"
- phase: "Phased Rollout"
  objective: "Expand in waves, adapt to each context, build organizational capability"
  typical_deliverables: "Wave-by-wave implementation, context-specific adaptations, training"
  milestone: "All waves complete, performance consistent across contexts"
- phase: "Sustain & Optimize"
  objective: "Establish monitoring, handover to operations, continuous improvement loop"
  typical_deliverables: "Monitoring dashboard, playbook, continuous improvement framework"
  milestone: "Organization sustains improvements independently"

### Phase Naming Guidance
"Use operational improvement language: Assessment, Design, Pilot, Rollout, Stabilize, Sustain. Avoid software terms (Sprint, Deploy, Ship) and academic terms (Literature Review, Methodology)."
[/Section: Phase-Templates]

[Section: Risk-Catalog]
- risk: "Resistance to change from teams accustomed to current process"
  probability: "High"
  impact: "High"
  mitigation_hint: "Involve affected teams early, demonstrate pilot wins, address concerns directly"
- risk: "Disrupting operations during transition"
  probability: "Medium"
  impact: "High"
  mitigation_hint: "Parallel run during transition, rollback plan ready, pilot in low-risk area first"
- risk: "Measuring the wrong metrics — improvement looks good on paper but doesn't solve the real problem"
  probability: "Medium"
  impact: "High"
  mitigation_hint: "Validate metrics with front-line staff, track leading and lagging indicators"
- risk: "Pilot success doesn't translate to full rollout"
  probability: "Medium"
  impact: "Medium"
  mitigation_hint: "Identify what made the pilot context favorable, test in a contrasting context before full rollout"
- risk: "Scope creep into adjacent processes"
  probability: "High"
  impact: "Medium"
  mitigation_hint: "Define process boundaries explicitly, capture adjacent opportunities for follow-up"
- risk: "Improvement regresses after initial attention fades"
  probability: "Medium"
  impact: "Medium"
  mitigation_hint: "Build monitoring and accountability into the process itself, not just project oversight"
[/Section: Risk-Catalog]

[Section: Metrics]
quantitative:
  - "Process cycle time (before vs after)"
  - "Error/defect rate reduction"
  - "Cost per transaction or operation"
  - "Throughput or capacity change"
qualitative:
  - "Team satisfaction with the improved process"
  - "Ease of onboarding new team members"
  - "Clarity of roles and handoffs"
milestone_examples:
  - "Current state mapped and baselined with stakeholder agreement"
  - "Pilot running with measurable results"
  - "Full rollout complete with training delivered"
  - "Monitoring in place and ownership transferred to operations"
[/Section: Metrics]

[Section: Issue-Breakdown]
breakdown_pattern: "improvement-cycle-oriented"
pattern_description: "Issues follow the assess→design→pilot→rollout cycle. Each issue covers a distinct process area or improvement initiative that can be assessed and improved independently."
typical_structure:
  - type: "Process Assessment"
    description: "Map and measure a specific process area, identify improvement opportunities"
    typical_complexity: "2-3"
  - type: "Improvement Design"
    description: "Design specific changes to a process with expected outcomes and measurement plan"
    typical_complexity: "3"
  - type: "Pilot Implementation"
    description: "Apply designed changes at controlled scale, collect results"
    typical_complexity: "3-4"
  - type: "Rollout & Training"
    description: "Scale proven changes, create training materials, transition to operations"
    typical_complexity: "2-3"
  - type: "Monitoring Setup"
    description: "Establish ongoing measurement, alerting, and review cadence"
    typical_complexity: "2"
example_titles:
  - "Assess order fulfillment process and identify bottlenecks"
  - "Design streamlined approval workflow for procurement"
  - "Pilot revised onboarding process with engineering team"
  - "Roll out standardized incident response across all regions"
  - "Set up operational dashboard for supply chain metrics"

### Cross-Cutting Patterns
"Change management and stakeholder communication span all improvement initiatives — consider a foundational issue for communication plan and change readiness assessment before process-specific work begins."
[/Section: Issue-Breakdown]
