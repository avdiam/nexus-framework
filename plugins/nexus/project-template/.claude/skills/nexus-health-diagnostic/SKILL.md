---
name: nexus-health-diagnostic
description: Assess system health across all maintenance operations
disable-model-invocation: true
---
*Version: 2.3.0 | Date: 2026-08-20 | Sprint: 110*

# System Health Diagnostic

**Flow**: Load → Staleness Assessment → Structural Check → Calculate Health → Recommendations → Persist → Dashboard

Aggregates operation health scores and file existence into a unified health dashboard with recommendations. Read-only aggregator — reads scores that other operations wrote, penalizes staleness, checks system file integrity, and persists the aggregated assessment.

**Tracked operations:**

| # | Operation | What It Scores |
|---|-----------|---------------|
| 1 | backup-optimization | Backup storage health |
| 2 | changelog-scan | Version tracking coverage |
| 3 | issue-validation | Issue data accuracy |
| 4 | pattern-maintenance | Pattern system health |
| 5 | registry-cleanup | Registry data integrity |

All scores are 0–100. All operations write to `[Health-Operations]` with fields: `score` and `last_run_sprint`.

---

### STEP 0: Load Context

Read `.nexus/active/states/system-state.md` section `[Health-Operations]` — extract each operation's `score` and `last_run_sprint`. If a field is missing, treat as never run (score: 0, last_run_sprint: 0).

Get `current_sprint` from sprint-state.md `_sprint` field.

If system-state load fails: report to user, offer to continue with structural check only.

Read `.nexus/active/states/system-state.md` section `[Learned-Patterns]` — extract `degradation_rates.{op}.current` for each operation. These are the calibrated per-operation staleness velocities. If section unavailable or a specific operation's rate is missing, use flat fallback of 2.0 points per sprint. (Note: maintenance-scheduler uses 3.0 as its fallback — the difference is intentional. 2.0 here is conservative-low for dashboard display; 3.0 there is conservative-high for scheduling. Both converge once calibration runs.)

---

### STEP 1: Staleness Assessment

For each operation, calculate staleness and adjusted score using its calibrated degradation velocity:

```
sprints_since = current_sprint - last_run_sprint
velocity = degradation_rates[op].current    # from [Learned-Patterns]
           OR 2.0                           # flat fallback if unavailable
adjusted_score = max(0, score - (sprints_since × velocity))
```

If `last_run_sprint` is 0 (never run): adjusted_score = 0, status = "⚠️ Never run".

Staleness status labels:

| Sprints Since | Status |
|---------------|--------|
| 0–2 | 🟢 Fresh |
| 3–4 | 🟡 Aging |
| 5–6 | 🟠 Stale |
| 7+ | 🔴 Overdue |

---

### STEP 2: Structural Check

Verify system files exist. Build expected file list from System Paths in [Section: Routing-Map] (always in memory from boot).

**Expected files** (derived from System Paths at runtime):
- Framework file: CLAUDE.md (project root)
- Supporting files: `.nexus/active/` prefix — Emergency-Reference.md, NEXUS-Architecture.md
- State files: `.nexus/active/states/` prefix — sprint-state.md, project-state.md, system-state.md, sprint-queue.md
- Registries: `.nexus/active/registries/` prefix — issues-registry.yaml, patterns-registry.yaml, changelog-registry.yaml, documentation-registry.yaml
- Skills: `.claude/skills/nexus-*/SKILL.md` — all methodology and operation skills
- Templates: `.nexus/templates/` prefix — all templates listed

Run two Glob calls:
1. `Glob('.nexus/**/*.md')` + `Glob('.nexus/**/*.yaml')` for framework data
2. `Glob('.claude/skills/nexus-*/SKILL.md')` for skills

Compare expected vs actual:
- **Missing**: in expected list but not on disk. Severity: critical (core/state/registry) or normal (operations/templates).
- **Orphan**: on disk but not in expected list. Exclude backup files, hidden files, and `.v4` draft files. Severity: minor (informational).

Calculate structural score:
```
base = 100
per missing critical file: -15
per missing operation: -5
per missing template: -3
per orphan: -1
structural_score = max(0, base - deductions)
```

---

**Context artifact freshness** (advisory — no score impact):

If `.nexus/supporting-files/project-context/` exists with artifacts, check the `Mapped:` date in each artifact's header against current sprint number. If artifacts are 5+ sprints old:

"💡 Context artifacts (CONTEXT.md, STRUCTURE.md, CONVENTIONS.md, CONCERNS.md) were mapped {N} sprints ago. Project structure may have evolved. Consider running `/nexus-map-context` to refresh."

This is advisory only — doesn't affect health score. The user decides whether to refresh.

---

### STEP 3: Calculate Overall Health

```
overall = (structural_score + sum of 5 adjusted_scores) / 6
```

Equal weight — all 6 components (structural + 5 operations) contribute equally. Round to nearest integer.

Determine status:

| Score | Status |
|-------|--------|
| 80–100 | ✅ HEALTHY |
| 60–79 | ⚠️ NEEDS ATTENTION |
| 40–59 | 🟠 DEGRADED |
| 0–39 | 🔴 CRITICAL |

> **Mental note**: Health calculated: {overall}/100 ({status}). Structural: {structural_score}. Adjusted scores: {list}. If checkpoint → save overall + adjusted scores to continue_with.

---

### STEP 4: Generate Recommendations

Build recommendations from adjusted scores and staleness. For each operation, read its `urgency_class` from `[Learned-Patterns].degradation_rates.{op}.urgency_class` if available (default: `quick_trigger` if unknown).

| Condition | urgency_class | Recommendation |
|-----------|--------------|----------------|
| adjusted_score < 40 | any | 🚨 **Run {operation} immediately** — score critically low |
| Never run | any | 🚨 **Run {operation}** — never executed |
| adjusted_score 40–59 | quick_trigger | ⚠️ **Run {operation} soon** — score degraded |
| adjusted_score 40–59 | cycle_only | 📝 **Include {operation} in next scheduled maintenance cycle** — score declining but not urgent |
| adjusted_score 60–74 | quick_trigger | 💡 **Monitor {operation}** — approaching threshold |
| adjusted_score 60–74 | cycle_only | *(no recommendation — expected degradation, handled by cycle)* |
| sprints_since ≥ 5 | quick_trigger | ⚠️ **Run {operation}** — data stale ({N} sprints) |
| sprints_since ≥ 5 | cycle_only | 📝 **Include in next scheduled cycle** — stale ({N} sprints) |
| Missing critical files | — | 🚨 **Investigate missing files** — {list} |
| Missing operations/templates | — | 📋 **Check missing files** — {list} |
| Orphan files found | — | 💡 **Review orphans** — may be stale drafts |

Sort recommendations by urgency (🚨 first, then ⚠️, then 📋, then 📝, then 💡).

---

### STEP 4B: System-State Size Governance

Count lines in system-state.md (from memory — already loaded at STEP 0).

| Condition | Action |
|---|---|
| ≤ 500 lines | No action |
| 501-600 (warning) | [T3] Offer compression. Streamlined: auto-skip. Balanced: notify. Full: ask. |
| > 600 (cap) | Mandatory compression. |

**Compression priorities** (execute in order until under 500 lines). All are consumer-safe — no downstream skill depends on compressed content:

| Priority | Section | Action | Why Safe |
|---|---|---|---|
| 1 | Maintenance-Tracking/history | Keep last 3 detailed entries, older → `{sprint: NNN, health: NN→NN}` one-liners | Pure audit trail — scheduler reads prediction/debt, not history |
| 2 | Subsystem-Verification | Collapse domains with `status: "clean"` to `{domain}: clean (Sprint {N})` | Only written by subsystem-verification, not read by scheduler |
| 3 | Health-Aggregated/history | Enforce max 10 entries (drop oldest beyond 10) | Both health-diagnostic and scheduler document "last 10" cap |
| 4 | Learned-Patterns/observed_XXX | Keep last 3 observed values per operation, drop older | EMA calibration only uses `.current` — observed are historical record |

**Do NOT compress**: Health-Operations (active scores), Maintenance-Tracking/prediction + deferred_debt (active data), Learned-Patterns/.current + warning_threshold + urgency_class (active parameters), Maintenance-Decision, Project-Status.

If compression triggered: full rewrite of system-state.md. Verify line count after write.

---

### STEP 5: Persist to system-state

Write results to system-state.md `[Section: Health-Aggregated]` using Edit tool. This section is owned exclusively by health-diagnostic.

```yaml
# Written by health-diagnostic — do not edit manually
assessed_at: "{ISO_timestamp}"
assessment_sprint: {N}
overall_score: {N}
overall_status: "{status}"

structural:
  score: {N}
  missing_critical: [{list} or "none"]
  missing_other: [{list} or "none"]
  orphans: [{list} or "none"]

adjusted_scores:
  backup_optimization: {N}
  changelog_scan: {N}
  issue_validation: {N}
  pattern_maintenance: {N}
  registry_cleanup: {N}

recommendations:
  - "{recommendation 1}"
  - "{recommendation 2}"

# Last 10 assessments (oldest first, max 10 — drop oldest when exceeding)
history:
  - {sprint: {N}, score: {N}}
  - {sprint: {N}, score: {N}}
```

After write: verify by reading back [Health-Aggregated] from disk. Confirm overall_score matches calculated value.

**Read contract** — the keys above (`overall_score`, `overall_status`, `assessment_sprint`, `structural.score`, `adjusted_scores.*`, `history`) are what /nexus-maintenance-scheduler STEP 0, /nexus-dashboard and system-state-template read. Never rename or replace them. Richer per-component detail (raw / velocity / adjusted / status, per-component deltas, narrative) goes in *additive* keys beside the contract keys (e.g. `components:`, `notes:`), not instead of them. (Sprint 108–109 drift: the instance was written with `overall_health` / `current_sprint_at_assessment` / `components` in place of the contract keys, and the scheduler's `data_age` lost its `assessment_sprint` input — repaired at the Sprint 110 Maintenance-domain verification.)

If persist fails: inform user, results are still valid from the dashboard display.

> **Mental note**: Health persisted to system-state. Overall: {overall}/100. If checkpoint → assessment complete, resume at STEP 6 display.

---

### STEP 6: Display Dashboard

```
═══════════════════════════════════════════════════════
🏥 SYSTEM HEALTH DASHBOARD — Sprint {N}
═══════════════════════════════════════════════════════

📊 OVERALL: {score}/100 ({status})

───────────────────────────────────────────────────────
HISTORY (last 10)
───────────────────────────────────────────────────────

Sprint │ Score
───────┼──────
{for each entry in history, newest first}

───────────────────────────────────────────────────────
OPERATION SCORES
───────────────────────────────────────────────────────

Operation            │ Score │ Staleness │ Adjusted │ Status
─────────────────────┼───────┼───────────┼──────────┼────────
backup-optimization  │ {raw} │ {N} sprints ({staleness_status}) │ {adj} │ {emoji}
changelog-scan       │ {raw} │ {N} sprints ({staleness_status}) │ {adj} │ {emoji}
issue-validation     │ {raw} │ {N} sprints ({staleness_status}) │ {adj} │ {emoji}
pattern-maintenance  │ {raw} │ {N} sprints ({staleness_status}) │ {adj} │ {emoji}
registry-cleanup     │ {raw} │ {N} sprints ({staleness_status}) │ {adj} │ {emoji}

───────────────────────────────────────────────────────
STRUCTURAL CHECK
───────────────────────────────────────────────────────

Score: {N}/100
Expected files: {N} │ Found: {N} │ Missing: {N} │ Orphans: {N}

{if missing}: ⚠️ Missing: {file list}
{if orphans}: 💡 Orphans: {file list}

───────────────────────────────────────────────────────
RECOMMENDATIONS
───────────────────────────────────────────────────────

{sorted recommendation list}

{if none}: ✅ All systems healthy — no actions needed

═══════════════════════════════════════════════════════
```

**[T3: Full ask | Balanced: notify | Streamlined: silent]**

Options:
1. Start maintenance sprint → load /nexus-organize-sprint with maintenance context
2. Save report to Maintenance-cycles/{sprint}/ → write dashboard content as health-report.md
3. Return

---

## Error Recovery

| Problem | Recovery |
|---|---|
| system-state load fails | Offer: continue with structural check only, or abort |
| [Learned-Patterns] unavailable | Use flat fallback velocity (2.0/sprint) for all operations |
| Glob fails for file check | Report: "⚠️ Cannot verify file existence — structural score unavailable." Score structural as 0. |
| Persist to system-state fails | Inform user, display dashboard anyway — results valid in memory |
| Sprint-state _sprint unavailable | Use last known sprint from system-state assessment_sprint + 1 |
