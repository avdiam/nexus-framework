---
name: nexus-project-status
description: Show project progress across phases, deliverables, and milestones
disable-model-invocation: true
---
*Version: 2.0.1 | Date: 2026-06-14 | Sprint: 103*

# Project Status

**Flow**: `Load project-state + registry → Build report → Display → Suggest actions`

Read-only status report across phases, deliverables, issues, metrics, risks, and recent activity. Modifies nothing.

---

### STEP 0: Load Context

`Read .nexus/active/states/project-state.md` (full file — the report draws from 11 of 13 sections). If not found: "No project defined. Use 'setup project' to initialize." and stop.

`Read .nexus/active/registries/issues-registry.yaml` — full load for issue counts per phase, deliverable completion status, blocked counts. If load fails, continue without issue statistics — note "Issue stats unavailable" in the report.

---

### STEP 1: Display Status Report

Build the report from project-state sections. For any section that's empty or still has template placeholders, show "Not configured" rather than placeholder text. Adapt the level of detail to what's actually populated — a fresh project with only phases defined looks different from a mid-project report with sprint history.

```
╔══════════════════════════════════════════════════════════════╗
║                    PROJECT STATUS REPORT                     ║
╠══════════════════════════════════════════════════════════════╣

📋 {title}
   Type: {project_type} | Domain: {project_domain}
   {health_icon} Health: {_health_status} | Status: {_project_status}
   Updated: {_updated} | Current Sprint: {current_sprint}

   Vision: {vision — first sentence or two for summary}

────────────────────────────────────────────────────────────────
📈 OVERALL PROGRESS
────────────────────────────────────────────────────────────────

Completion: {_completion_percentage}%

PHASES:
  {icon} {phase_name}: {bar} {completion}%
     {issues_resolved}/{issues_planned count} issues | {sprints count} sprints
  ...

  Example:
  ✅ Discovery & Analysis:  ████████████ 100%  3/3 issues | 2 sprints
  🔄 Foundation:            ████████░░░░  67%  4/6 issues | 2 sprints
  🔄 Core Implementation:   ██░░░░░░░░░░  15%  1/8 issues | 0 sprints
  ⏳ Polish & Delivery:     ░░░░░░░░░░░░   0%  0/4 issues | 0 sprints

  Phase icons: ✅ = 100%, 🔄 = in progress, ⏳ = not started

────────────────────────────────────────────────────────────────
🎁 DELIVERABLES
────────────────────────────────────────────────────────────────

MVP:      {complete}/{total} complete ({percentage}%)
  {for each: name — status based on issue_refs resolution}

Enhanced: {complete}/{total} complete ({percentage}%)
  {for each: name — status}

Future:   {complete}/{total} defined
  {for each: name — not yet tracked (future scope)}

Acceptance Criteria: {list from acceptance_criteria}

────────────────────────────────────────────────────────────────
📊 ISSUES
────────────────────────────────────────────────────────────────

Created: {last_id} | Open: {total_active} | Closed: {last_id - total_active}
Progress: {bar} {closed_percentage}%

────────────────────────────────────────────────────────────────
🎯 SUCCESS TRACKING
────────────────────────────────────────────────────────────────

Completion Criteria: {completion_criteria from success_constraints}
MVP Minimum: {mvp_minimum} — {assessment: met / in progress / not started}
Sufficiency: {sufficiency_threshold}

Metrics:
  {for each quantitative_metric}: {metric} — {status if trackable}
  {for each qualitative_metric}: {metric} — {status if trackable}

{if milestones exist}:
Milestones:
  {for each milestone}: {icon} {name} — Target: {target_date} {actual if complete}
  Milestone icons: ✅ complete, 🔄 on track, ⚠️ at risk, ❌ missed

────────────────────────────────────────────────────────────────
📋 RECENT ACTIVITY
────────────────────────────────────────────────────────────────

{if completed_sprints exist — show last 5, most recent first}:
Sprints:
  • Sprint {XXX} ({date}): {resolved count} issues — {achievements summary}

{if recent decisions exist — show last 3}:
Decisions:
  • {decision} — {rationale summary} (Sprint {XXX})

────────────────────────────────────────────────────────────────
⚠️ ATTENTION & RISKS
────────────────────────────────────────────────────────────────

{Compile from multiple sources — show section only if items exist}:

{if blocked_issues > 0}: • {blocked_issues} blocked issues
{if at_risk_items}: • At risk: {items}
{if at-risk milestones}: • Milestone at risk: {name}
{for identified_risks with High probability or impact}:
  • Risk: {description} ({probability}/{impact}) — {mitigation}
{if watch_items from NEXT_PHASE_NOTES}: • Watch: {items}

{if nothing to report}: All clear — no blocked issues, at-risk items, or active concerns.

────────────────────────────────────────────────────────────────
🔮 NEXT PRIORITIES
────────────────────────────────────────────────────────────────

{from NEXT_PHASE_NOTES/immediate_priorities}:
  • {priority item}

{if emerging_opportunities}: Opportunities: {list}

╚══════════════════════════════════════════════════════════════╝
```
Adapt the report to the project's actual state:
- **Early project** (no sprints completed): Skip Recent Activity, focus on phases and deliverables setup.
- **Mid project**: Full report — all sections populated.
- **Near completion**: Emphasize success tracking, completion criteria, remaining work.
- **Sections not configured**: Show "Not configured" with a suggestion — e.g., "Milestones: Not configured. Use 'update project parameters' to add milestones."

---

### STEP 2: Suggest Next Actions

Based on what the data reveals, suggest 2-3 relevant actions. Don't suggest the same things every time — look at the actual state:

- Issues blocked? → "Use 'view issues' to examine blocked issues"
- Phase near complete? → "Phase {N} at {X}% — close to advancing"
- No milestones defined? → "Consider adding milestones via 'update project parameters'"
- Risks materializing? → "Risk '{description}' may be active — review mitigation"
- MVP minimum met? → "MVP minimum appears met — evaluate if ready for sufficiency assessment"
- No recent sprint activity? → "No sprints completed recently — check sprint status"
- Success metrics not tracked? → "Success metrics defined but not tracked — consider updating at next sprint closure"

```
💡 SUGGESTED ACTIONS:
  1. {most relevant action}
  2. {second action}
  {3. optional third}

Commands: 'sprint status' | 'view issues' | 'update project parameters'
```

---

## Error Recovery

| Problem | Recovery |
|---|---|
| project-state.md not found | "No project defined. Use 'setup project' to initialize." Stop. |
| issues-registry load fails | Continue without issue statistics. Note "Issue stats unavailable." |
| Section has template placeholders | Show "Not configured" with suggestion for relevant command. |
