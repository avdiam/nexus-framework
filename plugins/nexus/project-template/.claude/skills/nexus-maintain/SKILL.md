---
name: nexus-maintain
description: NEXUS Maintain methodology — dedicated maintenance sprint lifecycle. 5-phase orchestrator with parallel scan capability.
disable-model-invocation: true
---
*Version: 2.4.0 | Date: 2026-08-20 | Sprint: 110*

# NEXUS Maintain Methodology

Executing Maintenance sprint. No $ARGUMENTS needed — reads system-state for context.

**Flow**: Orient → Planning → Execution (sequential or parallel scan) → Verification → Report & Closure

---

## Operational Reminders

**Always active while this skill executes:**

- **Memory-First**: Check active context before any read. Re-reading loaded files is a violation.
- **Verify-after-write**: Confirm changes on disk after every edit/write. Unverified writes are violations.
- **Consent**: Follow gate annotations (**[T1]**/**[T2]**/**[T3]**) per active control level.
- **Routing discipline**: Operations are loaded from their skill files and followed step-by-step. Do not improvise operation workflows.
- **Zone checks**: Check context after every completed operation. Checkpoint after EVERY operation.
- **Dual persistence**: Maintenance state persisted to BOTH system-state.md [Maintenance-Tracking] AND sprint-state.md continue_with at every checkpoint.

---

## Operation Inventory

### Core Operations (health-tracked)

| Operation | Skill | Parallelizable? |
|---|---|---|
| health-diagnostic | /nexus-health-diagnostic | **No** — must run first |
| registry-cleanup | /nexus-registry-cleanup | **Yes** — 3 sub-agents (issues/patterns/docs) |
| issue-validation | /nexus-issue-validation | **Yes** — STEP 0-6 scan |
| changelog-scan | /nexus-changelog-scan | **No** — interactive + rewrite |
| backup-optimization | /nexus-backup-optimization | **Yes** — STEP 0-4 scan (project-type filter below) |
| pattern-maintenance | /nexus-pattern-maintenance | **No** — interactive Tiers 2-3 |

**backup-optimization filter**: Read `_project_type` from sprint-state (fallback project-state). Run only if creative/mixed. Code projects: skip (score = 100).

### Utility Operations (lifecycle-specific)

| Operation | When | Invoked by |
|---|---|---|
| Degradation-Rate-Calibration (inline — [Section: Degradation-Rate-Calibration]) | Phase 3 Post-Execution D | Automatic — /nexus-maintenance-scheduler is NOT invoked by maintain; it consumes the calibrated rates at /nexus-organize-sprint STEP 0 |
| rollback | Phase 4 (regression) | T1 conditional |
| subsystem-verification | Phase 5 (flagged domains) | T2 conditional |
| staleness-checker | Phase 5 (automatic) | Automatic |
| prune-memory | Phase 5 (optional — dry-run health report over `.nexus/memory/*.jsonl`; decay / supersession / work_debt reconciliation) | T1 at apply (dry-run is free) |

---

## Tier System

| Tier | Criteria | Operations | Exit |
|---|---|---|---|
| **Quick** | ≤1 critical OR overall > 70 | diagnostic + 1-2 targeted | Quick exit allowed |
| **Standard** | 2+ warnings OR 1 critical + warnings | diagnostic + 3-4 ops | Formal close-sprint |
| **Comprehensive** | 3+ critical OR > 30 days | All applicable | Formal close-sprint |

Priority: < 60 CRITICAL, 60-69 WARNING, 70-79 CONCERN, ≥ 80 HEALTHY.

---

## Execution Modes

**Mode A** (Sequential): Quick tier. Load each op, execute all steps, checkpoint after each.

**Mode B** (Parallel Scan): Standard/Comprehensive tiers. Agent overhead (~3x tokens) not justified for Quick tier.

---

## Operation Dependency Chain

```
health-diagnostic ─┬─→ registry-cleanup (3 sub-agents)
                   ├─→ issue-validation (1 agent)
                   ├─→ changelog-scan (sequential)
                   ├─→ backup-optimization (1 agent, env-filtered)
                   └─→ pattern-maintenance (sequential, last)
```

---

## Phase 1: Orient (Silent)

**Task-tracking (ISS-199)**: on entry, create a coarse phase-level task list per CLAUDE.md [Section: Phase-Management-Protocol] → *Methodology Task-Tracking Convention* (one entry per phase of this skill — e.g. Orient → Planning → Execution → Verification → Report/Closure); `TaskUpdate` at each phase boundary; honor user opt-out.

### A — Load System State

Read system-state.md: [Health-Aggregated], [Health-Operations], [Maintenance-Tracking], [Learned-Patterns].

### B — Mode Selection

Mode A (Sequential) for Quick tier; Mode B (Parallel Scan) for Standard/Comprehensive tiers.
Sprint-state `_project_type` for backup-optimization.

### C — Resumption Detection

| Condition | Action |
|---|---|
| `operations_in_progress: true` | Resume — restore tracking, display, skip to Phase 3 |
| continue_with references maintenance | Fresh from organize-sprint → D |
| No context | Fresh start → D |

### D — Health Freshness

Never assessed or > 2 sprints stale → invoke /nexus-health-diagnostic. Fresh → use existing.

### E — Display

```
🛠️ MAINTENANCE SPRINT INITIATED
Health: {overall}/100 | Mode: {A/B}
Operations: {list with scores}
Project type: {type}
```

> **Mental note**: Health: {overall}. Mode: {A/B}. If checkpoint → save to both.

---

## Phase 2: Planning

### A — Priority + Tier

Calculate effective_score per operation. Determine tier. Filter by environment/project-type.

### B — Mode Decision

Quick → Mode A. Standard/Comprehensive → Mode B.

### C — Present Plan

**[T2: Balanced+Full ask | Streamlined: auto-approve, notify+log]**

```
🎯 MAINTENANCE PLAN
Health: {overall}/100 | Tier: {tier} | Mode: {A/B}
{N}. {name} — {score}/100, effective {eff}/100
Estimates: ~{total}K, {convs} conversation(s)
[Execute recommended | Custom | Quick tune-up]
```

> **Mental note**: Tier: {tier}. Mode: {A/B}. Ops: [{list}]. If checkpoint → save to both.

---

## Phase 3: Execution

### Tracking Init

Write system-state [Maintenance-Tracking] with its schema keys: `operations_in_progress: true`, `operations_pending` (the approved plan list), `operations_completed: []`, `operations_failed: []`, `tier`, `health_before`, `op_initial_scores: {}`; `resume_from_operation` is set at every checkpoint. Execution mode (A/B) is conversation state — carried in sprint-state continue_with, not a system-state key.

### Mode A: Sequential

For each operation:
1. Zone check (80% mandatory, 70% note)
2. `── Operation {N}/{total}: {name} ──` → Load skill, follow all steps
3. Record op_initial_scores. Display completion.
4. Checkpoint: system-state [Maintenance-Tracking] + sprint-state continue_with
   **[T3: Full ask | Balanced: notify | Streamlined: silent]**
5. `Next: {op}. [Continue / Pause]`

### Mode B: Parallel Scan

**3A — health-diagnostic** (sequential, main context). Checkpoint.

**3B — Dispatch scan agents:**

| Agent | Operation | Scan Boundary |
|---|---|---|
| registry-cleanup ×3 | issues/patterns/docs | STEP 3 |
| issue-validation | all checks | STEP 6 |
| backup-optimization | discover+analyze | STEP 4 |

Agents write own initial_score to system-state (allowed). NO project data writes. (These are generic operation-scan agents — general-purpose Task agents running operation-skill scan STEPs — NOT the read-only `nexus-scanner` agent type, which carries no Write tool. That distinction is why their own-`initial_score` write is permitted.)

**Agent failure**: **[T2]** retry / skip / run in main context.

**3C — Consolidated review:**

**[T2: Balanced+Full ask | Streamlined: auto-approve non-destructive, notify+log]**

```
📊 PARALLEL SCAN RESULTS
{op}: {score}/100 — {findings} findings
Approve fixes? [All / Per-op / Skip]
```

**3D — Apply fixes** (sequential, main context):
Read files before patching (Mode B re-read). Load skill, execute fix steps. Checkpoint after each.

**3E — Sequential operations** (main context):
1. changelog-scan — full execution
2. pattern-maintenance — full execution (Exit = operation complete)
Checkpoint after each.

### Post-Execution (both modes)

**A** — Final health-diagnostic (if not last op). Calculate improvement.
**B** — Clear system-state in-progress markers: `operations_in_progress: false`, `resume_from_operation: ""`, `operations_pending: []`.
**C** — Update [Maintenance-Tracking]: `cycle_position.last_maintenance_sprint`, `cycle_position.maintenance_needed: false`, `health_after` + `op_scores_after` (instance keys since Sprint 109), clear `deferred_debt`, append `history`.
**D** — Execute [Section: Degradation-Rate-Calibration].

> **Mental note**: {completed}/{total}. Health: {before}→{after}. If checkpoint → results to continue_with.

---

## Phase 4: Verification

### A — Improvement

`improvement = health_after - health_before`. Per-op deltas.

### B — Regression Check

Detect: `health_after < health_before - 5` OR any op < 60.

**[T1: all levels ask]** — if regression detected.
Options: [Continue | Rollback → /nexus-rollback | Run more ops → Phase 3]

### C — Display

```
📊 MAINTENANCE VERIFICATION
Health: {before} → {after} ({+delta})
Operations: {each with deltas}
Next maintenance: Sprint {N} (from [Maintenance-Tracking].prediction — refreshed by /nexus-maintenance-scheduler at the next organize-sprint)
```

> **Mental note**: Verification done. If checkpoint → save results.

---

## Phase 5: Report & Closure

### A — Optional Checks

Subsystem verification (if flagged): **[T2]** for execution.
Staleness check (automatic): **[T2]** for regeneration.
Memory prune (`load /nexus-prune-memory`, dry-run STEP 0–3 always; apply **[T1]**): the memory layer's only scheduled decay / supersession / `work_debt` status-reconciliation pass — without it `organize-sprint` keeps surfacing already-fixed debt.

### B — Report

**[T3]** — Load template, populate, write, verify.

### C — Display

```
✅ MAINTENANCE SPRINT COMPLETE
Tier: {tier} | Mode: {A/B} | Ops: {completed}/{total}
Health: {before} → {after} (+{improvement})
Report: .nexus/Maintenance-cycles/{sprint}/maintenance-report.md
```

### D — Closure

**[T2: Balanced+Full ask | Streamlined: auto-select per tier, notify+log]**

| Tier | Default |
|---|---|
| Quick | Quick exit |
| Standard | Formal |
| Comprehensive | Formal (no quick option) |

**Formal**: /nexus-close-sprint (shortcut: STEP 0→8→9). Post-closure: changelog-scan → health-diagnostic.
**Quick**: Reset sprints_since_maintenance=0. /nexus-organize-sprint.

> **Mental note**: Closure via {type}. Operation complete.

---

## Degradation Rate Calibration
[Section: Degradation-Rate-Calibration]

EMA algorithm. For each of 5 ops:
1. `observed = (prev_after - current_initial) / sprints_elapsed`
2. `new = (old × 0.7) + (observed × 0.3)`
3. Patch [Learned-Patterns] `degradation_rates.{op}`: `current`, `last_updated` (the schema keys); record `observed_{sprint}` and the EMA arithmetic in the inline comment on `current` — it is not a schema key
4. Update prediction_accuracy (±1 tolerance)
5. Update operation_effectiveness if changed
6. Verify all 5 updated

`📈 Degradation rates recalibrated. Accuracy: {X}%.`

[/Section: Degradation-Rate-Calibration]

---

## Gate Reference
[Section: Gate-Reference]

| Gate | Tier | Full | Balanced | Streamlined | Conditional? |
|---|---|---|---|---|---|
| Plan approval | **T2** | Ask | Ask | Auto, notify+log | Always |
| Fix approval (per-op/consolidated) | **T2** | Ask | Ask | Auto non-destructive | Always |
| Op/agent failure | **T2** | Ask | Ask | Ask (risk) | If failure |
| Per-op continuation | T3 | Ask | Notify | Silent | Always |
| **Rollback** | **T1** | Ask | Ask | Ask | If regression |
| Subsystem verification | **T2** | Ask | Ask | Notify+log | If flagged |
| Doc regeneration | **T2** | Ask | Ask | Notify+log | If stale |
| Report | T3 | Ask | Notify | Auto | Always |
| Closure type | **T2** | Ask | Ask | Auto per tier | Always |

[/Section: Gate-Reference]

---

## Checkpoint Reference
[Section: Checkpoint-Reference]

| After | system-state | sprint-state |
|---|---|---|
| Orient | Health loaded | Mode, health_before |
| Planning | Tier, ops list | Tier, ops, mode |
| Each op complete | Op score, markers | {N}/{total} |
| Post-execution | History, Learned-Patterns, cleared | Complete |
| Verification | — | Outcome |
| Report | — | Path |

[/Section: Checkpoint-Reference]

---

## End-of-Workflow Checklist
[Section: End-of-Workflow-Checklist]

MANDATORY before closure.

```
- [ ] All ops executed or documented as failed/skipped
- [ ] system-state [Health-Operations] updated per operation
- [ ] system-state [Maintenance-Tracking] updated (last_sprint, history, debt cleared)
- [ ] system-state [Learned-Patterns] calibrated
- [ ] In-progress markers cleared
- [ ] Final health-diagnostic run
- [ ] Verification complete
- [ ] Report written and verified
- [ ] sprint-state continue_with set
- [ ] Context zone checked
```

[/Section: End-of-Workflow-Checklist]

---

## Error Recovery

| Problem | Recovery |
|---|---|
| system-state load fails | Conservative baselines. Continue / abort. |
| health-diagnostic fails | Use last known data. Warning. |
| Operation failure | [T2] Skip / retry / abort. Track failed. |
| Agent failure (B) | [T2] Retry / skip / main context. |
| Context overflow | Save to BOTH. Next conv resumes at Orient C. |
| Checkpoint fails | Essential only. Continue / stop / retry. |
| Regression | [T1] Accept / rollback / more ops. |
| Template missing | Generate from results. |
| All ops fail | Save available. maintenance_needed=true. |
