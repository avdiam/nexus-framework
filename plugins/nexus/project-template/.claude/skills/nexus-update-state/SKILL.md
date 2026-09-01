---
name: nexus-update-state
description: Update project state progress and phase tracking
disable-model-invocation: true
---
*Version: 2.1.0 | Date: 2026-08-20 | Sprint: 110*

# Update Project State

**Flow**: `Load context → Calculate phase completion → [T2: Approve sprint data] → Assess health → Apply all patches → Report`

This operation feeds sprint closure results into project-state.md — phase completion, sprint log, health status, key decisions, and learnings. It's primarily called by /nexus-close-sprint with sprint data already in context.

**Scope**: This operation updates project *progress*. It does NOT modify project definition, scope, deliverables, constraints, or resources (use `/nexus-setup-project` ## Update Mode for those).

**Sections it updates**: metadata fields, `[PROJECT_PHASES]`, `[PROGRESS_OVERVIEW]`, `[CRITICAL_DECISIONS]`, `[NEXT_PHASE_NOTES]`, `[MILESTONE_TRACKING]`.

**Sections it never touches**: `[PROJECT_DEFINITION]`, `[SCOPE_AND_BOUNDARIES]`, `[DELIVERABLES]`, `[STAKEHOLDERS]`, `[CONSTRAINTS_AND_RISKS]`, `[SUCCESS_METRICS]`, `[KEY_RESOURCES]`.

---

### STEP 0: Load Context

Silent. Load if not in memory:
- `Read .nexus/active/states/project-state.md`
- `Read .nexus/active/states/sprint-state.md` (should already be in context if called from close-sprint)
- `Read .nexus/active/registries/issues-registry.yaml`

If project-state doesn't exist, inform the caller and return — nothing to update.

---

### STEP 1: Calculate Phase Completion

For each phase in `[PROJECT_PHASES]`:
- Count issues in `issues_planned` array
- Count resolved issues: `status: Resolved` in issues-registry, PLUS issues that have already been archived with a Resolved outcome. Archived issues LEAVE the registry (at most a `# --- ISS-XXX --- ARCHIVED Sprint NNN (Resolved)` stub remains) — check `.nexus/archived/issues/ISS-XXX.md` (Closure status) or the stub for each `issues_planned` ID missing from the registry. `Archived` is NOT a registry status value (Registry-Schema enum: Open | In-Progress | Resolved | Rejected | Superseded | Decomposed); counting only live registry entries undercounts every phase with archived work.
- Calculate completion: `(resolved / planned) × 100`, rounded to integer. If `issues_planned` is empty, treat as 0%.
- Determine status: 0% → Planned, 1-99% → Active, 100% → Complete
- Append current sprint number to phase's `sprints` list if this sprint worked on issues in that phase

Determine the current phase (first non-Complete phase). Calculate overall completion as average across all phases.

Detect phase transitions: if `_current_phase` will change, flag it for STEP 3.

---

### STEP 2: Sprint Closure Data (User Approval)

Prepare the sprint's contribution to project state. Present everything in one pass for efficient approval.

**Sprint summary entry** for `[PROGRESS_OVERVIEW]/completed_sprints`:

```yaml
- sprint: {XXX}
  date: "{YYYY-MM-DD}"
  resolved: [ISS-XXX, ISS-YYY]
  achievements: ["{achievement 1}", "{achievement 2}"]
```
Derive achievements from the sprint's completed objectives — what was accomplished in user-meaningful terms, not issue IDs. Keep it to 2-4 items. If no issues were resolved, capture progress made (e.g., "Advanced analysis of X," "Completed Phase 2 optimization planning").

**Key decisions**: Scan sprint-state `[DECISIONS]/made` for decisions with architectural or strategic significance. Propose which to capture at project level, pre-categorized as recent, architectural, or technical.

**Next phase notes**: Scan sprint-state `[DISCOVERIES]/insights` and `[EXPERIENCE_CAPTURE]` for items that should guide future work. Propose entries for:
- `immediate_priorities` — what should happen next
- `key_learnings` — insights worth remembering
- `watch_items` — risks or concerns to monitor
- `emerging_opportunities` — potential improvements noticed

Present everything together:

```
📋 SPRINT {XXX} → PROJECT STATE
════════════════════════════════════════

ACHIEVEMENTS:
• {achievement 1}
• {achievement 2}

KEY DECISIONS TO CAPTURE ({N} found):
{for each}: [ ] {decision summary} → {category}

NEXT PHASE NOTES ({N} items):
Priorities: {proposed}
Learnings: {proposed}
Watch: {proposed}
Opportunities: {proposed}

Accept all / Select items / Skip: _
════════════════════════════════════════
```
**[T2: Balanced+Full ask | Streamlined: auto-accept, notify+log]**

Use AskUserQuestion: [Accept all / Select items / Skip].

If "Select items": let user pick which decisions and notes to include.
If no key decisions or learnings found in sprint-state, show only the sprint summary and skip that portion: "No key decisions or learnings to capture this sprint."

If "Skip": proceed with only phase completion and sprint log (no decisions/notes).

---

### STEP 3: Assess Health & Apply

**VERIFICATION GATE — STEP 3:**
- [ ] User has approved sprint summary, decisions, and notes in STEP 2

⛔ GATE: Do not patch project-state.md until STEP 2 approval is confirmed.

**Health assessment** — quick signals, not deep analysis (/nexus-project-status does detailed analysis):

| Signal | Green | Yellow | Red |
|---|---|---|---|
| Phase progress | On track | Minor delays | Significant delays |
| Blocked issues | 0 | 1-3 | 4+ |
| MVP deliverable progress | MVP deliverables mostly on track | Some behind | Critical deliverables stalled |

Overall health: most restrictive signal wins.

**Build and apply all patches** to project-state.md:

Metadata:
- `_updated`: current datetime
- `_current_phase`: from STEP 1
- `_completion_percentage`: overall from STEP 1
- `_health_status`: from health assessment
- `_project_status`: "Complete" if all phases at 100%, otherwise "Active"

`[PROJECT_PHASES]`: per-phase completion, status, sprints list.

`[PROGRESS_OVERVIEW]`:
- `overall_health`: from assessment
- `current_sprint`: next sprint number (current + 1)
- `completed_sprints`: append sprint summary entry from STEP 2
- `total_issues_resolved`: increment by count resolved this sprint
- `total_issues_created`: update from registry count
- `blocked_issues`: current count from registry
- `at_risk_items`: issues with status concerns (if any identified)

`[CRITICAL_DECISIONS]`: append user-approved decisions from STEP 2 to appropriate category (recent/architectural/technical).

`[NEXT_PHASE_NOTES]`: update with user-approved items from STEP 2.

`[MILESTONE_TRACKING]`: if any phase reached 100%, check milestones with matching `phase_association`. Set `actual_date` and `status: Complete` for matched milestones.

`[PROJECT_BRIEF]`: if `_current_phase` changed (phase transition detected in STEP 1), update `current_phase` field to new phase name + objective.

Verify the patch applied.

If patch fails: backup exists — report error, offer retry. Project-state will be consistent on next attempt since all patches are in one operation.

---

### STEP 4: Report

```
✅ PROJECT STATE UPDATED
════════════════════════════════════════

PHASE PROGRESS:
{for each phase}:
• {name}: {X}% ({status}) {"+N%" if changed}

Overall: {Y}% | Health: {status}

SPRINT {XXX} LOGGED:
• Resolved: {issue list}
• Achievements: {count}
• Decisions captured: {count}
• Learnings captured: {count}

{if phase_transition}:
📊 Phase transition: {old} → {new}
   Reorganize sprint queue for new phase? [Y/n]

{if project_complete}:
🎉 ALL PHASES COMPLETE
   Consider: final review, project closure, celebration.
════════════════════════════════════════
```
If phase transition and user wants reorganization: suggest running reorganize-queue as a next step (don't call inline — context may be tight at sprint closure).

Return to caller (/nexus-close-sprint).

---

## Gate Reference

| Gate | Step | Tier | Full | Balanced | Streamlined |
|---|---|---|---|---|---|
| Sprint data approval | 2 | **T2** | Ask | Ask | Auto-accept, notify+log |
| Verification gate | 3 | ⛔ | Must pass | Must pass | Must pass |

---

## Error Recovery

| Problem | Recovery |
|---|---|
| project-state not found | Inform caller, return. Nothing to update. |
| issues-registry load fails | Phase completion calculation incomplete. Continue with available data, note gaps. |
| Patch fails | Backup exists. Report error, offer retry. Single-operation patch so retry is safe. |
| No issues resolved this sprint | Normal — capture progress made as achievements instead of resolved issue list. |
