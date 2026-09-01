# Update Mode — setup-project companion
*Version: 1.0.0 | Date: 2026-06-14 | Sprint: 104*

Externalized from `nexus-setup-project/SKILL.md` `## Update Mode` (ISS-215, stub-in-place externalization). The `## Update Mode` heading is retained in the skill as the cross-skill anchor (generate-mvp, update-state, and two internal setup-project references point to it); this companion holds the operational flow (STEP U.0–U.5 + Gates + Error Recovery), loaded on dispatch.

[Section: Update-Mode]

This is a collaboration, not a form. Understand *why* the user wants a change. Flag downstream implications proactively. Propose related changes when one edit implies another. Validate quality with the same standards the Wizard applies — vague vision, missing success criteria, and ungrounded scope get pushed back constructively.

### STEP U.0: Load Context

Silent — the user sees only the category menu.

Load if not in memory:
- `Read .nexus/active/states/project-state.md` — current project definition
- `Read .nexus/active/registries/issues-registry.yaml` — for impact analysis

**Validate**: if project-state has template placeholders (Wizard was interrupted), warn: "Project setup appears incomplete. Complete it via the Wizard first, or edit what exists?"

### STEP U.1: Category Selection

Display the project summary and category menu. This is also the return point after completing an edit cycle.

```
📝 UPDATE PROJECT PARAMETERS
════════════════════════════════════════

Project: {title}
Type: {project_type} | Domain: {project_domain}
Status: {_project_status} | Phase: {_current_phase}
Health: {_health_status}

What to update?

1. Identity (vision, type, domain)
2. Scope & Boundaries (in/out scope, success constraints, constitution)
3. Deliverables (add, remove, modify, recategorize)
4. Structure (phases, milestones)
5. Execution (constraints, risks, dependencies, technology)
6. Metrics & Resources (success metrics, key resources)
7. Stakeholders (users, decision makers, communication)
8. Review All (read-only overview)
9. Done — exit
════════════════════════════════════════
```

Use `AskUserQuestion` widget with the categories. If "Review All": display a condensed read-only overview, return here. If "Done": exit.

**Document-driven update** (preserved per audit-deliverable §3.3 mandate — Phase A.3 Disposition Map binding): If the user provides a document with the update request ("update the project based on this new spec"), process it before showing the category menu:

1. Read the document and identify its type (revised spec, new requirements, scope change memo, stakeholder feedback)
2. Compare extracted content against current project-state sections
3. Present a change summary:

> 📄 Document Analysis — {document_name}
>
> Changes detected vs current project:
> • {category}: {what changed — e.g., "2 new deliverables identified"}
> • {category}: {what changed — e.g., "scope boundary shifted"}
> • No changes: {categories with no detected differences}
>
> Process these as edits? [Yes — walk through each / Cherry-pick / Ignore document]

If accepted: pre-populate STEP U.2 with extracted changes for each affected category, walking through them in sequence. The user reviews and approves each as normal — the document accelerates input, it doesn't bypass approval.

### STEP U.2: Edit Category

Read the relevant section(s) from project-state and present current values. Collect changes through conversation, not field-by-field enumeration — the LLM reads the actual content and collaborates with the user on meaningful changes.

**Category → section mapping and guidance**:

| Category | Sections | Key validations |
|---|---|---|
| 1. Identity | `[PROJECT_DEFINITION]` | Vision needs concrete outcome + purpose + success indicator. Type change → offer to revisit phase structure. |
| 2. Scope & Constitution | `[SCOPE_AND_BOUNDARIES]`, `[PROJECT_CONSTITUTION]` | Success constraints (mvp_minimum, sufficiency_threshold, completion_criteria) must stay meaningful. Scope expansion → check resource feasibility. Constitution add/modify/remove non-negotiable principles. |
| 3. Deliverables | `[DELIVERABLES]` | Additions need full structure (name, description, quality_criteria, target_phase, `issue_refs: []`). Removals → check issue_refs for orphans AND cascade to phase data (STEP U.3). Recategorization (MVP↔Enhanced↔Future): build remove-from-old + add-to-new patches atomically. |
| 4. Structure | `[PROJECT_PHASES]`, `[MILESTONE_TRACKING]` | Phase changes → check deliverable allocation. Phase additions/removals → significant restructuring. Date changes → flag timeline impact. |
| 5. Execution | `[CONSTRAINTS_AND_RISKS]` | Constraint changes → check plan feasibility. Risk updates → ensure mitigations are concrete. Technology field: `preliminary_technology` with known_requirements, integration_requirements, platform_constraints. |
| 6. Metrics & Resources | `[SUCCESS_METRICS]`, `[KEY_RESOURCES]` | Metrics should be measurable. Milestones should align with phases. |
| 7. Stakeholders | `[STAKEHOLDERS]` | Lightweight for single-user projects; multi-stakeholder → communication plan matters. |

Apply the same quality standards as the Wizard (vague vision → push for specifics; success constraints missing → explain why they matter; deliverables disconnected from vision → flag it; risks without concrete mitigations → push back). If a section still contains template placeholders (`"{from wizard}"`, `"{STEP X}"`), note it: "This section still has placeholder values. Want to fill it in now, or focus on specific fields?"

Track all changes in memory: which fields changed, old values, new values, deliverables added/removed/modified. This feeds STEP U.3.

### STEP U.3: Impact Analysis & Approval

Analyze cascade effects before applying changes. Depth scales with scope.

**Minor changes** (clarifications, cosmetic, no deliverable/structure/constraint magnitude changes): skip detailed analysis, ask: "These are minor changes with no issue impact. Apply? [Yes / Modify / Cancel]"

**Strategic changes without issue impact** (timeline shift, resource constraint change, type change): present brief strategic summary: "No issues directly affected, but {implication — e.g., 'timeline extended 5 sprints — consider updating phase estimates and milestones'}." On loop-back, recommend reviewing related categories. For type changes specifically: apply the field edit, then on return to STEP U.1 recommend reviewing Structure (phases) next — phase names/objectives may need adaptation.

**Changes affecting issues**: use `issue_refs` from deliverables and `issues_planned` from phases to identify which issues are affected.

```
⚠️ IMPACT ANALYSIS
════════════════════════════════════════
CHANGES: • {category}: {changes summary}
ISSUE IMPACT: {specific impacts — see rules below}
SCOPE: {Minor / Moderate / Major}
════════════════════════════════════════
```

**Deliverable-related cascade rules**:
- *Deliverable removed*: check `issue_refs` for orphans (truly orphaned only if not appearing in any other deliverable's `issue_refs` — issues shared across deliverables survive). Cascade cleanup atomically: (1) close orphaned issues inline via `/nexus-close-issue` batch (offer: "Close these issues? [Close all / Review individually / Leave open]"), (2) remove closed issue IDs from parent phase `issues_planned`, (3) remove deliverable name from phase `deliverables` list.
- *Deliverable added*: 1-2 simple → "create issue" inline OR `/nexus-generate-mvp` later for full breakdown; 3+ → recommend `/nexus-generate-mvp` (auto-detects incremental mode). Don't call generate-mvp inline — too token-heavy.
- *Deliverable modified* (description/quality_criteria changed): flag affected issues for `/nexus-update-issue` review.
- *Deliverable recategorized* (MVP↔Enhanced↔Future): offer priority adjustment in registry (two-place protocol — registry + sprint-state [OBJECTIVES]). MVP→Enhanced/Future: offer to lower priority; Enhanced/Future→MVP: offer to raise.

**Phase structure cascade**:
- *Phase removed*: orphaned `issues_planned` for that phase — ask which remaining phase to reallocate; patch `target_sprint` in registry and move into receiving phase's `issues_planned`.
- *Phase added/reordered*: existing allocations may need adjustment; flag for reorganize-queue.
- *Phase dates/estimates changed*: timeline shift; milestone dates may need updating.

**Major change criteria** (triggers reorganize-queue suggestion): 3+ MVP deliverables added/removed; timeline shifts 3+ sprints; phase count changes; core constraints changed significantly.

**[T1: all levels ask]** Present full impact, ask via `AskUserQuestion`: [Apply changes / Modify edits / Cancel].

### STEP U.4: Apply Changes

**VERIFICATION GATE — STEP U.4**:
- [ ] User explicitly approved changes via STEP U.3 widget
- [ ] All cascade impacts identified and accepted

⛔ GATE: Do not write until approval is confirmed.

**A.** Patch project-state with all changed sections. Always update `_updated`. When deliverables added/removed, also patch the affected phase's `deliverables` AND `issues_planned` to stay consistent (added → add to target phase's `deliverables`; removed → remove from `deliverables` AND remove closed issue IDs from `issues_planned`). If a patch fails: backup exists (git) — report the error, offer retry or cancel.

**B.** Cascade to registry (only if issues affected). For each issue: priority changes patch `ISS-XXX.priority` (two-place protocol); target sprint changes patch `ISS-XXX.target_sprint`; closures handled inline per C below.

**C.** Execute inline closures from STEP U.3 decisions via `/nexus-close-issue` batch. Track results for the report.

**D.** Update sprint-state `[PROJECT_BRIEF]` if brief-relevant fields changed (vision, constitution, mvp_minimum, project type, or High/High risks). Keeps always-loaded project context current.

**E.** Flag context artifact staleness if scope changed significantly: "Scope changed — consider re-running /nexus-map-context to refresh CONTEXT.md / STRUCTURE.md / CONVENTIONS.md / CONCERNS.md."

**F.** Verify project-state and registry consistency (no closed issue IDs remain in any phase's `issues_planned`; no removed deliverables in any phase's `deliverables`; added deliverables appear in their target phase; sprint-state patch applied if PROJECT_BRIEF was updated).

### STEP U.5: Report & Continue

```
✅ PROJECT PARAMETERS UPDATED
════════════════════════════════════════
CHANGES: {summary per category edited}

UPDATES:
✓ project-state.md ({N} sections patched)
{if cascade}: ✓ issues-registry.yaml ({M} issues updated)
{if closures}: ✓ {N} orphaned issues closed
{if phase_cleanup}: ✓ Phase data cleaned ({N} stale refs removed)

{if deliverables_added}: 💡 NEXT: Run 'generate mvp issues' for new deliverables (incremental mode)
{if major_changes}: 💡 NEXT: Run 'reorganize queue' to reallocate issues
{if issues_flagged_for_review}: 💡 REVIEW: {N} issues may need updates ({ISS-XXX list})
════════════════════════════════════════
```

Return to STEP U.1 for another cycle: [Edit another category / Done]. On loop-back, re-read the relevant section from disk in STEP U.2 (memory is stale after STEP U.4 patch). On Done: exit.

### Update Mode Gates

| Gate | Step | Tier | Behavior |
|---|---|---|---|
| Impact approval | U.3 | **T1** | Always ask + consequences |
| Verification gate | U.4 | ⛔ | Must pass before write |

### Update Mode Error Recovery

| Problem | Recovery |
|---|---|
| project-state has placeholders | Warn; offer Wizard completion or edit-what-exists |
| Patch fails | Backup exists (git); report error, offer retry |
| Registry cascade fails | project-state is authoritative; report failed issue IDs for manual fix |
| Inline closure fails | Track; report in STEP U.5; user can retry via /nexus-close-issue |

[/Section: Update-Mode]
