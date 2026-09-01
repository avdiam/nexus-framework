---
name: nexus-maintenance-scheduler
description: Predict and schedule next maintenance sprint — health trajectory analysis, adaptive cycles, deferred debt
disable-model-invocation: true
---
*Version: 2.0.2 | Date: 2026-08-20 | Sprint: 110*

# Maintenance Scheduler

**Flow**: Load health data → Calculate trajectory → Adaptive cycle → Write prediction → [Interactive: Dashboard → User decision]

Two modes: **silent** (called by /nexus-organize-sprint STEP 0 on the full planning path — analyze, predict, write, return) and **interactive** (user requests prediction — adds dashboard display and decision options).

Silent path: STEP 0 → 1 → 2 → 3 → return.
Interactive path: STEP 0 → 1 → 2 → 3 → 4 → 5.

---

### STEP 0: Load Context

Load system-state sections needed for prediction. Silent — no user display.

Read `.nexus/active/states/system-state.md` sections [Health-Aggregated] through [Learned-Patterns] — 4 contiguous sections. Use `degradation_rates.current` per operation as velocity seed. Also read `warning_threshold` and `urgency_class` per operation. If unavailable, fall back to flat 3.0/sprint velocity and threshold 70.

Extract:

**From [Health-Aggregated]**: `overall_score`, `assessment_sprint`, `history` (last 10).

**From [Health-Operations]**: Per-operation `score` and `last_run_sprint`.

**From [Maintenance-Tracking]**: `sprints_since_maintenance`, `last_maintenance_sprint`, `maintenance_needed`, existing `prediction`, `deferred_debt`.

**Data age check**: `data_age = current_sprint - assessment_sprint`. If `data_age >= 2`: force confidence cap = LOW regardless of later calculations.

If load fails: use conservative baselines (flat 3.0/sprint, threshold 70). Confidence = LOW.

> **Mental note**: Health data loaded. Overall: {score}/100. Data age: {N} sprints. If checkpoint → save loaded state.

---

### STEP 1: Calculate Health Trajectory

Analyze degradation patterns to predict when maintenance will be needed.

**A — Per-operation staleness**: For each of the 5 tracked operations:
```
sprints_stale = current_sprint - last_run_sprint
effective_score = max(0, score - (sprints_stale × op_velocity))
```
Use calibrated velocity from `degradation_rates.{op}.current`. Fallback: 3.0/sprint.

**B — Velocity**: Use `degradation_rates.{op}.current` directly. If unavailable and history has 2+ points: `velocity = score_delta / sprint_delta`. Otherwise: baseline -2/sprint.

**C — Acceleration detection**:

| Condition | Flag | Impact |
|---|---|---|
| Velocity > 150% of previous | ACCELERATING | Urgency +1 |
| Velocity 80-120% of previous | STABLE | Nominal |
| Velocity < 80% of previous | IMPROVING | Urgency -1 |

**D — Threshold prediction**: For each operation, using its `warning_threshold` (default 70) and `urgency_class`:

```
sprints_until_threshold = (effective_score - warning_threshold) / abs(velocity)
eta_sprint = current_sprint + sprints_until_threshold
```

If effective_score ≤ warning_threshold: `eta_sprint = current_sprint` (needs attention now).

**Urgency class rules**:
- `quick_trigger` ops (changelog_scan, issue_validation, registry_cleanup): ETA can drive standalone targeted recommendation. Flag if `eta_sprint ≤ current_sprint + 2`.
- `cycle_only` ops (pattern_maintenance, backup_optimization): feed scheduled cycle only. Never trigger early/targeted.

Record `nearest_threshold` (earliest ETA across all classes).

> **Mental note**: Trajectory calculated. Nearest threshold: {op} at Sprint {N}. If checkpoint → save trajectory data.

---

### STEP 2: Calculate Adaptive Cycle

Determine optimal maintenance interval.

**A — Base cycle**: 5 sprints.

**B — Adjustments**:

| Factor | Condition | Adjustment |
|---|---|---|
| Rapid degradation | Any quick_trigger op velocity > 6 pts/sprint | -1 sprint |
| Slow degradation | All quick_trigger op velocities < 1.5 pts/sprint | +1 sprint |
| System improving | All operations trending up | +1 sprint |
| Deferred 1-2× | deferral_count 1-2 | No adjustment — tracked in debt |
| Deferred 3+ | deferral_count ≥ 3 | Override to 3 sprints (floor breach) |

Note: cycle_only ops do not trigger adjustments.

**C — Calculate**: `cycle = base + sum(adjustments)`, clamped to **5-7**. Exception: deferred 3+ override = 3 sprints.

`next_maintenance_sprint = last_maintenance_sprint + cycle`

**Quick-trigger early warning**: If any quick_trigger op has `eta_sprint < next_maintenance_sprint`, flag: "⚠️ {op} may breach threshold (Sprint {eta}) before scheduled maintenance (Sprint {next})." Surfaces in rationale and dashboard — does not mechanically alter cycle.

**D — Confidence**:

| Data Quality | Confidence |
|---|---|
| 3+ history points, stable velocity | HIGH |
| 2 history points or moderate variance | MEDIUM |
| 1 or 0 history, or high variance | LOW |

Apply data age cap from STEP 0 if applicable.

---

### STEP 3: Write Prediction

**A — Write prediction.** Edit system-state.md [Maintenance-Tracking] prediction fields:

```yaml
prediction:
  next_maintenance_sprint: {calculated}
  recommended_cycle: {5-7 or 3}
  confidence: {HIGH|MEDIUM|LOW}
  predicted_at: {current_sprint}
  rationale: "{one-line reason}"
  nearest_threshold: "{op} at Sprint {N}"
```

Verify patch applied.

**B — Write actionable decision.** Edit system-state.md [Maintenance-Decision]:

```yaml
decision_type: "scheduled"
decision_timestamp: "{ISO_timestamp}"
next_sprint_mode: "MAINTENANCE_SPRINT"
details:
  scheduled_for_sprint: {next_maintenance_sprint}
  tier: "{recommended_tier}"
  operations: [{recommended_operations}]
  health_at_scheduling: {overall_score}
```

If `next_maintenance_sprint <= current_sprint` (overdue): `decision_type: "execute_now"`.
If LOW confidence + no critical ops: `decision_type: "scheduled"` (let organize-sprint offer choice).

Verify patch applied.

**If silent mode**: Return to caller. /nexus-organize-sprint reads [Maintenance-Decision] during planning.

**If interactive mode**: Continue to STEP 4.

> **Mental note**: Prediction written. Next maintenance: Sprint {N}. Confidence: {level}. If checkpoint → prediction persisted.

---

### STEP 4: Present Dashboard (Interactive Only)

**[T3: Full ask | Balanced: notify | Streamlined: auto-select Schedule if HIGH confidence, else present]**

```
═══════════════════════════════════════════════════════════
🔮 MAINTENANCE PREDICTION
═══════════════════════════════════════════════════════════

📊 HEALTH STATUS:
├─ Overall: {score}/100 (assessed Sprint {N})
├─ Sprints since maintenance: {N}
└─ Adaptive cycle: {N} sprints ({reasoning})

📈 OPERATION HEALTH:
{for each with effective_score < 80 or notable trend}:
• {operation}: {effective_score}/100 ({velocity}/sprint, {flag})
  └─ Threshold ETA: Sprint {N} ({confidence})

🔮 PREDICTION:
├─ Next maintenance: Sprint {N} ({sprints_away} sprints)
├─ Nearest threshold: {operation} at Sprint {N}
├─ Confidence: {HIGH|MEDIUM|LOW}
└─ Rationale: {why}

{if deferred_debt.deferral_count > 0}:
💳 DEFERRED DEBT:
├─ Deferrals: {N} time(s)
├─ Accumulated degradation: {X} points
├─ Urgency: {LOW|MEDIUM|HIGH|CRITICAL}
└─ Safe to defer again: {yes|risky|no}

═══════════════════════════════════════════════════════════
```

Options via AskUserQuestion:
- Schedule maintenance at Sprint {N}
- Defer (track debt)
- View detailed analytics
- Return

---

### STEP 5: Handle User Decision (Interactive Only)

**A — Schedule**:

**[T3: Full ask | Balanced: notify | Streamlined: silent]**

Prediction already written in STEP 3. Confirm: "✅ Maintenance scheduled for Sprint {N} ({confidence}). organize-sprint will surface this during planning."

**B — Defer**:

**[T2: Balanced+Full ask | Streamlined: notify+log — deferral impacts scheduling]**

Calculate impact: `new_degradation = avg_velocity × predicted_cycle_length`.
Edit system-state.md [Maintenance-Tracking] deferred_debt:

```yaml
deferred_debt:
  deferral_count: {previous + 1}
  last_deferral_sprint: {current}
  accumulated_degradation: {previous + new_degradation}
  urgency: {calculated}
  reasons:
    - sprint: {current_sprint}
      reason: "{user-provided or auto-generated}"
```

Urgency rules:

| Deferral Count | Base Urgency | If any op < 60 |
|---|---|---|
| 1 | LOW | MEDIUM |
| 2 | MEDIUM | HIGH |
| 3+ | HIGH | CRITICAL |

Update [Maintenance-Decision]: `decision_type: "deferred"`.

Display:

```
⚠️ DEFERRAL RECORDED
├─ Debt: {accumulated} points ({count} deferrals)
├─ Urgency: {level}
├─ Projected health at next check: {estimate}/100
└─ {if CRITICAL}: ⚠️ Further deferral risks emergency maintenance
```

Verify patches applied.

**C — View Analytics**:

```
═══════════════════════════════════════════════════════════
📊 DETAILED ANALYTICS
═══════════════════════════════════════════════════════════

🏥 ALL OPERATIONS:

Operation          | Score | Stale | Effective | Velocity | ETA
-------------------|-------|-------|-----------|----------|--------
{name}             | {s}   | {n}sp | {eff}     | {v}/sp   | Spr {N}
{repeat for all 5}

📉 HEALTH HISTORY (last 10):

Sprint | Overall | Trend
-------|---------|------
{N}    | {score} | {emoji}

🔮 CONFIDENCE FACTORS:
├─ History depth: {N} data points
├─ Velocity stability: {stable|variable|erratic}
└─ Prediction basis: {description}

═══════════════════════════════════════════════════════════
```

After display: return to STEP 4 dashboard.

**D — Return**: No action. Return to caller.

---

## Error Recovery

| Problem | Recovery |
|---------|----------|
| system-state load fails | Use conservative baselines (3.0/sprint, threshold 70). Confidence = LOW. |
| [Learned-Patterns] unavailable | Use flat fallback velocities. Note degraded prediction quality. |
| Prediction patch fails | Retry once. If still fails: display prediction to user, suggest manual update. |
| [Maintenance-Decision] patch fails | Prediction still valid. organize-sprint can read prediction fields directly. |
| No health history (first project) | All baselines. Confidence = LOW. Recommend first maintenance at Sprint 5. |
| Deferred debt section missing | Initialize with deferral_count: 0. Continue normally. |
