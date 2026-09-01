---
name: nexus-dashboard
description: Generate read-only visual dashboards from live NEXUS data
disable-model-invocation: true
---
*Version: 2.2.0 | Date: 2026-08-20 | Sprint: 110*

# Dashboard

**Flow**: Select scope → Load live data → Generate visualization → Display

Generate read-only visual dashboards from live NEXUS data (6 scopes: issues, patterns, project, sprint, maintenance, documentation). No files modified.

---

Dashboards are read-only visualizations generated from live data. They never write, patch, or modify files — no consent protocol needed. Always generate the artifact fresh from current data (no cached HTML).

### STEP 0: Detect Scope

Interpret the user's request to determine which dashboard to generate. If the scope is ambiguous or unspecified, present the selection menu:

```
═══ 📊 NEXUS DASHBOARDS ═══

Available dashboards:
[1] Issues — Open issues with priorities, phases, dependencies
[2] Patterns — Active patterns with effectiveness and domains
[3] Project — Deliverables, milestones, phase progress
[4] Sprint — Current objectives, decisions, momentum
[5] Maintenance — System health, operation scores, subsystem status
[6] Documentation — Guide catalog, coverage, staleness status

Which dashboard? [1-6 or name]
```

### STEP 1: Load Data Source

Load only the data source needed for the selected scope.

| Scope | Primary source | Secondary source | Extract |
|---|---|---|---|
| Issues | issues-registry.yaml | — | All ISS-XXX entries: title, type, priority, impact, status, complexity, blocks, blocked_by, analyzed, implemented, evaluated, notes, target_sprint |
| Patterns | patterns-registry.yaml | — | All PAT-XXX entries: name, type, domain, effectiveness, maturity, phase_affinity, description, successes, failures, neutral, last_used, synergies, conflicts (16-field schema — no `applications` / `status` fields exist) |
| Project | project-state.md | issues-registry.yaml | Phases with completion %, deliverables, milestones, success metrics, critical decisions. Cross-reference with live issue data for accurate counts per phase. |
| Sprint | sprint-state.md | issues-registry.yaml | [OBJECTIVES] with scores, [DECISIONS] made/pending, [MOMENTUM], [CONVERSATION_HISTORY], _mode, _title, _status. Enrich objectives with registry metadata (type, description, dependencies). |
| Maintenance | system-state.md | — | [Health-Aggregated]: overall_score, adjusted_scores (5 ops, 0-100), recommendations, history. [Health-Operations]: per-op score + last_run_sprint. [Subsystem-Verification]: 12 domains with last_verified, findings, status. [Maintenance-Tracking]: cycle_position, prediction, deferred_debt, history. [Learned-Patterns]: degradation_rates, operation_effectiveness. |
| Documentation | documentation-registry.yaml | — | All guide entries: title, status, category, target_level, topics, description, size_kb, last_updated, references. Categories with guide lists. Counts computed from the entries (the registry has no metadata block): total, active, planned. |

If the file is already in memory, use it (📌). Otherwise load it (🔍).

### STEP 2: Transform to JSON

Convert loaded data into a JavaScript const for artifact embedding. The shape depends on scope:

**Issues:**
```javascript
// Array of { id, title, type, priority, impact, status, complexity,
//   created, target, blocks: [], blocked_by: [], analyzed, implemented, evaluated, notes }
```
**Patterns:**
```javascript
// Array of { id, name, type, domain, effectiveness, successes, failures, neutral,
//   maturity, phase_affinity, description }
```
**Project:**
```javascript
// { vision, phases: [{ name, status, issues_total, issues_complete }],
//   deliverables: [{ name, completion_pct, status }], milestones: [...] }
```
**Sprint:**
```javascript
// { number, title, mode, status, objectives: [{ id, title, priority,
//   complexity, scores: {a, i, e} }], decisions: [...], momentum: {...},
//   conversation_count, history_summary }
```
**Maintenance:**
```javascript
// { overall_score, overall_status,
//   operations: [{ name, score, last_run_sprint, adjusted_score, degradation_rate }],
//   subsystems: [{ name, last_verified_sprint, findings, remaining, status }],
//   cycle: { sprints_since, next_predicted, deferred_debt_count },
//   history: [{ sprint, score }] }
```
**Documentation:**
```javascript
// { counts: { total_guides, active_guides, planned_guides },
//   categories: { name: { description, guides: [] } },
//   guides: [{ id, title, status, category, target_level, topics: [],
//     description, size_kb, last_updated, references: [] }] }
```
### STEP 3: Generate React Artifact

Create a React artifact with the embedded data and scope-appropriate visualization.

**Common features (all scopes):** Search/filter, sort controls, expandable detail cards, summary statistics header, color-coded status indicators, responsive layout.

**Per-scope features:**

| Scope | Key visualizations |
|---|---|
| Issues | Priority grouping with color coding. Phase score dots (A/I/E). Dependency badges (blocks/blocked-by). Complexity dots. Filter: all, in-progress, ready, blocked, by priority. Sort by priority/complexity/progress/ID. |
| Patterns | Effectiveness score bars. Domain grouping. Maturity level indicators. Application count. Filter by domain/maturity/effectiveness. Sort by effectiveness/applications/name. |
| Project | Phase progress bars. Deliverable completion percentages. Milestone timeline. Issue count per phase. Overall project health indicator. |
| Sprint | Objective cards with phase scores. Decision timeline. Conversation history visualization. Mode indicator. Momentum/energy display. |
| Maintenance | Overall health score with color gradient. 5-operation score bars with staleness indicators (sprints since last run). Subsystem verification grid (12 domains). Cycle position and next prediction. Deferred debt indicator. History sparkline. |
| Documentation | Guide catalog cards by category. Status indicators (planned/active). Level distribution chart. Topic tag cloud. Coverage: categories with guide counts. Created vs planned ratio. |

**Design guidelines:**

The artifact should use a dark, modern aesthetic. Background: true black (#000000) or near-black (#0a0a0a). Cards: dark gray (#111111) with lighter borders (#222222 or #333333). Accent colors: indigo/purple (#818cf8, #c084fc) for primary actions, semantic colors for status (green=healthy, amber=warning, red=critical). Typography: system font stack with clear hierarchy. Interactions: hover effects, click to expand, smooth transitions.

**CRITICAL: Use inline styles with explicit hex colors, NOT Tailwind classes.** Tailwind utility classes may not render reliably in the artifact environment, causing light backgrounds despite dark class names. Always use inline `style={{}}` attributes with hard-coded color values to guarantee dark mode rendering.

### STEP 4: Display

After generating the artifact, confirm:

```
📊 {Scope} Dashboard generated with {count} entries.

Tip: Click items to expand details. Use filters and sort controls.
Data source: {file} (read-only view)
```

Offer: switch scope ("show [other] dashboard"), return to text view ("view issues", "sprint status"), or refresh ("refresh dashboard").
