# Event / Campaign Management
*Domain Profile v1.0.0 | Sprint: 060*

[Section: Profile]
type_name: "Event / Campaign Management"
category: "Business"
description: "Planning and executing events, marketing campaigns, product launches, or coordinated initiatives with a fixed timeline. Choose when the work builds toward a specific moment or window — a launch date, event day, or campaign period."
wizard_emphasis: "Timeline discipline, logistics coordination, contingency planning, stakeholder coordination, post-event analysis"
phase_character: "Deadline-driven — plan, prepare, execute, analyze. Everything works backward from the event date. Parallel workstreams converge at go-live."
typical_deliverables: "Event plans, campaign materials, logistics packages, execution runbooks, post-mortem analyses"
wizard_depth: "standard"

spec_version: "1.0.0"
template_version: "1.0.0"
[/Section: Profile]

[Section: Framing-Hints]
vision_question: "What's the event or campaign, and what outcome defines success? What should be different afterward?"
scope_emphasis: "Event boundaries — what's included in this initiative vs ongoing operations, which audiences, which channels"
deliverable_framing: "Everything needed to execute successfully — plans, materials, logistics, and the post-mortem that captures learning"
risk_framing: "Timeline slippage, vendor/dependency failures, low attendance or engagement, budget overruns, day-of emergencies"
effort_framing: "Sprints work backward from the event date — each sprint must hit its milestone or downstream work is at risk"
constraint_emphasis: "Hard deadlines (event date is immovable), venue/platform constraints, budget, vendor lead times, regulatory requirements"
[/Section: Framing-Hints]

[Section: Deliverable-Templates]
### MVP Examples
- name: "Event / Campaign Plan"
  description: "Complete plan: objectives, audience, timeline, budget, logistics, responsibilities, contingencies"
  quality_criteria: "Every workstream has an owner and timeline, contingency plan for top 3 risks, stakeholders aligned"
- name: "Campaign Materials / Event Content"
  description: "All content needed for the initiative: messaging, collateral, presentations, signage, digital assets"
  quality_criteria: "On-brand, audience-appropriate, reviewed and approved, production-ready before deadline"
- name: "Execution Runbook"
  description: "Step-by-step guide for event day or campaign launch: timeline, responsibilities, escalation paths"
  quality_criteria: "Someone unfamiliar could follow it, decision points and fallbacks clearly marked"

### Enhanced Examples
- name: "Promotion & Outreach Program"
  description: "Multi-channel promotion plan with targeting, messaging variants, and tracking"
  quality_criteria: "Channels matched to audience, messaging consistent, tracking enables attribution"
- name: "Logistics & Vendor Package"
  description: "Complete logistics coordination: venue, vendors, equipment, catering, AV, travel"
  quality_criteria: "All vendors confirmed and contracted, setup timeline tested, backup vendors identified"
- name: "Post-Event Analysis"
  description: "Comprehensive debrief: what worked, what didn't, metrics vs goals, recommendations for next time"
  quality_criteria: "Quantitative metrics reported, qualitative feedback captured, actionable recommendations"

### Future Examples
- name: "Event / Campaign Playbook"
  description: "Reusable framework for running similar initiatives based on lessons learned"
  quality_criteria: "Adaptable to different contexts, incorporates learnings from multiple events"
- name: "Audience Development Program"
  description: "Ongoing relationship building with the event/campaign audience between initiatives"
  quality_criteria: "Audience engagement sustained between events, growth measurable"

### Categorization Guidance
"MVP = the event or campaign executes successfully with measurable outcomes. Enhanced = the execution is polished, promoted, and analyzed. Future = the initiative becomes a repeatable capability."
[/Section: Deliverable-Templates]

[Section: Phase-Templates]
### Simple (2-3 phases)
- phase: "Planning & Preparation"
  objective: "Define objectives, create plan, develop materials, coordinate logistics"
  typical_deliverables: "Event plan, campaign materials, logistics coordination"
  milestone: "All materials ready and logistics confirmed with buffer before event date"
- phase: "Execution & Post-Mortem"
  objective: "Execute the event or campaign, monitor in real-time, debrief afterward"
  typical_deliverables: "Executed event, execution log, post-mortem report"
  milestone: "Event completed and post-mortem delivered with key learnings"

### Standard (3-4 phases)
- phase: "Strategy & Planning"
  objective: "Define objectives, audience, budget, timeline, and success metrics"
  typical_deliverables: "Event/campaign brief, budget plan, timeline, success criteria"
  milestone: "Plan approved with budget allocated and stakeholders aligned"
- phase: "Content & Material Development"
  objective: "Create all content, collateral, and materials needed for execution"
  typical_deliverables: "Campaign materials, presentations, digital assets, messaging"
  milestone: "All materials complete, reviewed, and approved"
- phase: "Logistics & Rehearsal"
  objective: "Finalize logistics, confirm vendors, conduct dry runs, prepare contingencies"
  typical_deliverables: "Execution runbook, vendor confirmations, rehearsal results, contingency plans"
  milestone: "Full rehearsal or dry run complete with contingencies tested"
- phase: "Execution & Analysis"
  objective: "Execute, monitor, capture data, debrief, and document learnings"
  typical_deliverables: "Executed event, real-time monitoring log, post-event analysis"
  milestone: "Post-mortem complete with metrics reported and recommendations captured"

### Complex (5-6 phases)
- phase: "Concept & Strategy"
  objective: "Define the initiative concept, strategic objectives, target audience, and positioning"
  typical_deliverables: "Concept brief, audience analysis, strategic objectives, success framework"
  milestone: "Concept approved with clear strategic alignment"
- phase: "Detailed Planning"
  objective: "Translate strategy into detailed plans: timeline, budget, workstreams, responsibilities"
  typical_deliverables: "Detailed project plan, budget breakdown, workstream assignments, vendor RFPs"
  milestone: "All workstreams planned with owners, dependencies mapped"
- phase: "Content & Production"
  objective: "Create all materials, content, and assets across workstreams"
  typical_deliverables: "Campaign content, event materials, digital assets, promotional materials"
  milestone: "All content produced and approved ahead of production deadlines"
- phase: "Logistics & Coordination"
  objective: "Finalize all logistics, conduct rehearsals, coordinate parallel workstreams"
  typical_deliverables: "Logistics package, rehearsal results, coordination checkpoints"
  milestone: "Full rehearsal successful, all logistics confirmed"
- phase: "Execution"
  objective: "Execute the event or campaign launch with real-time monitoring and response"
  typical_deliverables: "Executed initiative, real-time monitoring, issue resolution log"
  milestone: "Event or campaign executed as planned (or adapted in real-time)"
- phase: "Post-Mortem & Legacy"
  objective: "Analyze results, capture learnings, document playbook for future initiatives"
  typical_deliverables: "Post-event analysis, audience feedback, playbook, follow-up plan"
  milestone: "Learnings documented and shared, follow-up actions assigned"

### Phase Naming Guidance
"Use event/campaign lifecycle language: Concept, Planning, Production, Logistics, Rehearsal, Execution, Post-Mortem. Emphasize the deadline-driven and convergent nature of the work. Avoid software terms (Sprint, Deploy) and operational terms (Assessment, Remediation)."
[/Section: Phase-Templates]

[Section: Risk-Catalog]
- risk: "Timeline slippage in preparation phases compresses execution readiness"
  probability: "High"
  impact: "High"
  mitigation_hint: "Build buffer before the event date, set intermediate milestones with hard deadlines, track daily in final phase"
- risk: "Vendor or dependency failure (no-show, wrong delivery, technical failure)"
  probability: "Medium"
  impact: "High"
  mitigation_hint: "Confirm all vendors in writing, identify backup vendors, test all technical systems before event day"
- risk: "Low attendance, engagement, or response rate"
  probability: "Medium"
  impact: "High"
  mitigation_hint: "Start promotion early, diversify channels, track registration or engagement metrics with enough time to adjust"
- risk: "Budget overruns from scope additions or unexpected costs"
  probability: "Medium"
  impact: "Medium"
  mitigation_hint: "Include contingency budget (10-15%), require approval for scope additions, track spend weekly"
- risk: "Day-of emergencies (technical failures, no-shows, weather, etc.)"
  probability: "Medium"
  impact: "Medium"
  mitigation_hint: "Create contingency plan for top 5 scenarios, assign on-site decision-maker, rehearse escalation paths"
- risk: "Stakeholder misalignment on event objectives or messaging"
  probability: "Medium"
  impact: "Medium"
  mitigation_hint: "Align on objectives in strategy phase, get sign-off on messaging before production, limit late-stage changes"
[/Section: Risk-Catalog]

[Section: Metrics]
quantitative:
  - "Attendance or reach vs target"
  - "Engagement rate (interactions, responses, conversions)"
  - "Budget spent vs allocated"
  - "Timeline milestones hit on schedule"
qualitative:
  - "Audience satisfaction and experience quality"
  - "Stakeholder satisfaction with outcomes"
  - "Team execution quality (how smoothly did it run?)"
milestone_examples:
  - "Event plan approved with budget and timeline"
  - "All materials complete and approved"
  - "Rehearsal or dry run successful"
  - "Post-mortem complete with actionable recommendations"
[/Section: Metrics]

[Section: Issue-Breakdown]
breakdown_pattern: "workstream-oriented"
pattern_description: "Issues follow parallel workstreams that converge at the event date. Each issue covers a distinct area of preparation or execution that can be planned and tracked independently."
typical_structure:
  - type: "Strategy & Planning"
    description: "Define objectives, audience, and approach for the initiative or a major component"
    typical_complexity: "3"
  - type: "Content & Materials"
    description: "Create specific content deliverables: messaging, collateral, presentations, assets"
    typical_complexity: "2-3"
  - type: "Logistics & Coordination"
    description: "Arrange and confirm specific logistics: venue, vendors, equipment, travel"
    typical_complexity: "2-3"
  - type: "Promotion & Outreach"
    description: "Plan and execute audience acquisition for a specific channel or segment"
    typical_complexity: "2-3"
  - type: "Post-Event Analysis"
    description: "Collect data, analyze outcomes, produce debrief report"
    typical_complexity: "2"
example_titles:
  - "Define conference strategy and success metrics"
  - "Create keynote presentation and supporting materials"
  - "Coordinate venue logistics and AV setup"
  - "Execute multi-channel promotion campaign for product launch"
  - "Produce post-event analysis with ROI assessment"

### Cross-Cutting Patterns
"Timeline management and stakeholder communication span all workstreams — establish a master timeline with dependencies and a communication cadence before workstream-specific planning begins."
[/Section: Issue-Breakdown]
