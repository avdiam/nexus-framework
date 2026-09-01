# sprint-queue.md
*Version: 4.0.1 | Date: 2026-08-20 | Sprint: 110*

<!-- Instance version: copy this header's version to instances created from this template -->

# Sprint Queue - {Project Name}
# Forward-looking queue for upcoming sprints
# Last Updated: Sprint XXX

## Active Sprint
<!-- 
Current sprint in progress. Format:

### Sprint XXX - Title (ACTIVE)
```yaml
id: "XXX"
mode: "THEMED|MIXED|DEDICATED"
focus: "Brief description of sprint focus"
status: "ACTIVE"
priority: "High|Medium|Low"
planned_work:
  - ISS-XXX: Title (priority, complexity)
  - ISS-YYY: Title (priority, complexity)
total_complexity: 9  # Target ~9 per sprint
rationale: |
  Why this sprint configuration was chosen.
  Include synergy analysis, mode reasoning.
dependencies:
  - Any cross-issue dependencies or "None"
notes: "Additional context or special considerations"
```

Updated by: /nexus-organize-sprint STEP 4D.3 (creation), /nexus-close-sprint STEP 8C (completion)
-->

## Queued Sprints
<!-- 
Future planned sprints. Each sprint follows same format as Active Sprint
but with status: "PLANNED". List in execution order (next sprint first).

Example:
### Sprint XXX+1 - Future Focus (PLANNED)
```yaml
id: "XXX+1"
mode: "THEMED"
focus: "Description"
status: "PLANNED"
...
```

Updated by: /nexus-organize-sprint STEP 4D.3 (multi-sprint planning) and its Diagnostic path (queue fixes)
-->

## Issue Dependency Map
```yaml
# Document critical blocking relationships across sprints
# Helps visualize dependencies and plan sequencing

critical_chains:
  # Example:
  # infrastructure_chain:
  #   - ISS-040 blocks ISS-041 blocks ISS-042
  #   reason: "Foundation must complete before features"
```

## Backlog (Not Yet Scheduled)
```yaml
# Ideas and work not yet converted to issues or scheduled

future_considerations:
  # High-level ideas for future exploration
  # - Idea description

post_mvp:
  # Work explicitly deferred until after MVP
  # - Feature or improvement description
```

## Sprint Planning Summary
```yaml
# Quick reference for queue state

current_sprint: "XXX"
next_sprint: "XXX+1"
total_planned_sprints: 0
total_issues_scheduled: 0

sprint_goals:
  # High-level goals across planned sprints

critical_milestones:
  # Key dates or deliverables

system_evolution:
  immediate: "Current focus"
  near_term: "Next 2-3 sprints"
  medium_term: "Next 5-10 sprints"
  long_term: "Project vision"
```

## Risk Mitigation
```yaml
# Track identified risks and mitigation strategies

identified_risks:
  # Example:
  # - risk: "Dependency on external API"
  #   impact: "High"
  #   mitigation: "Build abstraction layer first"
  #   sprint: "XXX"
```

## Queue Management Rules
```yaml
# Operational guidance for queue management

when_completing_sprint:
  - Mark sprint-state as complete
  - Experience processing at sprint closure (close-sprint STEP 6)
  - Archive sprint-state to /Sprints/XXX/final-sprint-state.md
  - Create FRESH sprint-state.md from template
  - Pull next sprint from this queue to Active Sprint
when_injecting_urgent_work:
  - Assess impact on dependencies
  - Insert at appropriate priority point
  - Adjust downstream sprints if needed
  - Never lose planned work (move to backlog if displaced)
  
when_replanning:
  - Triggered by: project change, major blocker, user request
  - Preserve good organization where possible
  - Update issues-registry target_sprint fields
  - Maintain dependency chains

```

