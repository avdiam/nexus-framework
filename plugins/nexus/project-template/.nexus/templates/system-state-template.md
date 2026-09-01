# system-state-template.md
*Version: 3.5.0 | Date: 2026-08-20 | Sprint: 110*

<!-- Instance version: copy this header's version to instances created from this template -->

# System State - NEXUS Project
# System health tracking, maintenance coordination, and learned patterns
# Instantiate from this template for new projects

_updated: {timestamp}
_purpose: System health tracking and maintenance cycle coordination

## Health Aggregated
[Section: Health-Aggregated]
```yaml
# Written by health-diagnostic — replaced on each execution
# Do not edit manually

assessed_at: "never"
assessment_sprint: 0
overall_score: 0
overall_status: "unknown"       # HEALTHY (≥80) | NEEDS ATTENTION (≥60) | DEGRADED (≥40) | CRITICAL (<40)

structural:
  score: 0
  missing_critical: "none"
  missing_other: "none"
  orphans: "none"

adjusted_scores:
  backup_optimization: 0
  changelog_scan: 0
  issue_validation: 0
  pattern_maintenance: 0
  registry_cleanup: 0

recommendations: []

# Last 10 assessments (oldest first, drop oldest when exceeding 10)
history: []
  # - {sprint: 45, score: 72}
```
[/Section: Health-Aggregated]

## Health Operations
[Section: Health-Operations]
```yaml
# Each maintenance operation writes its own fields after execution
# All scores are 0-100. All include last_run_sprint.
# health-diagnostic reads these — never writes to this section.
# 5 tracked operations (aligned with Learned-Patterns degradation_rates)

backup_optimization:
  score: 0                       # 0-100, written by backup-optimization
  last_run_sprint: 0

changelog_scan:
  score: 0                       # 0-100, written by changelog-scan
  last_run_sprint: 0

issue_validation:
  score: 0                       # 0-100, written by issue-validation
  last_run_sprint: 0

pattern_maintenance:
  score: 0                       # 0-100, written by pattern-maintenance
  last_run_sprint: 0
  last_value_audit_sprint: 0     # STEP 1.5 value/dedup audit cadence gate — written by pattern-maintenance STEP 4A; the audit runs when absent or ≥ 3 sprints old

registry_cleanup:
  score: 0                       # 0-100, written by registry-cleanup
  last_run_sprint: 0
```
[/Section: Health-Operations]

## Maintenance Tracking
[Section: Maintenance-Tracking]
```yaml
# Consolidated maintenance cycle tracking
# Written by: /nexus-close-sprint (increment), /nexus-maintain/maintenance-scheduler (execution tracking)
#
# Section order rationale: Health-Aggregated → Health-Operations → Maintenance-Tracking →
# Learned-Patterns are contiguous so maintenance-scheduler and /nexus-maintain Phase 1A can
# read all four in a single range read. Maintenance-Decision, Subsystem-Verification, and
# Project-Status follow separately (different consumers, different timing).

cycle_position:
  sprints_since_maintenance: 0    # Incremented by /nexus-close-sprint after each sprint
  last_maintenance_sprint: 0      # Sprint number when maintenance last executed
  maintenance_needed: false       # Flag: true when sprints_since_maintenance >= 5

# Maintenance prediction (written by maintenance-scheduler)
prediction:
  next_maintenance_sprint: 0      # Predicted optimal sprint for next maintenance
  recommended_cycle: 5           # Optimal sprint interval (3-7)
  confidence: "LOW"               # HIGH | MEDIUM | LOW
  predicted_at: "never"           # When this prediction was made (sprint number)
  rationale: ""                   # One-line reason
  nearest_threshold: ""           # e.g. "pattern_maintenance at Sprint 058"

# Runtime execution tracking (written by /nexus-maintain during maintenance sprints)
operations_in_progress: false    # true when a maintenance sprint is actively executing
resume_from_operation: ""        # Operation to resume from if conversation interrupted
operations_completed: []         # Operations finished this cycle
operations_pending: []           # Operations remaining this cycle
operations_failed: []            # Operations that failed this cycle
tier: ""                         # Current maintenance tier (quick/targeted/comprehensive)
health_before: 0                 # Health score at start of maintenance sprint
op_initial_scores: {}            # Per-op scores captured at STEP start (before fixes) for degradation rate calculation
health_after: 0                  # Health score at end of the maintenance sprint (written by /nexus-maintain Post-Execution C)
op_scores_after: {}              # Per-op scores after fixes (Post-Execution C) — pairs with op_initial_scores for per-op deltas

# Deferred maintenance debt tracking
deferred_debt:
  deferral_count: 0               # How many times maintenance was deferred
  accumulated_degradation: 0.0    # Estimated health points lost due to deferrals
  last_deferral_sprint: 0         # Sprint when last deferred
  urgency: "none"                 # none | low | medium | high | critical
  reasons: []                     # List of deferral reasons with sprint numbers
    # Example entry:
    # - sprint: 042
    #   reason: "Development momentum high, health excellent"

# Maintenance history (last 5 executions)
history:
  # Example entry:
  # - sprint: 036
  #   timestamp: "2025-12-07T12:00:00Z"
  #   tier: "comprehensive"
  #   operations_executed: [health-diagnostic, pattern-maintenance, registry-cleanup]
  #   operations_failed: []
  #   health_before: 80
  #   health_after: 92
  #   improvement: 12
  #   op_initial_scores:            # Per-op scores captured at each operation's scan boundary (before fixes)
#     backup_optimization: 100
#     changelog_scan: 97
#     issue_validation: 95
#     pattern_maintenance: 80
#     registry_cleanup: 98
#   op_scores_after:              # Per-op scores after maintenance (for rate calibration)
  #     backup_optimization: 100
  #     changelog_scan: 99
  #     issue_validation: 98
  #     pattern_maintenance: 85
  #     registry_cleanup: 100
  #   duration_minutes: 90
  #   notes: "Full cycle after Sprint 033 intelligence integration"

# Cycle management rules
cycle_rules:
  default_cycle_length: 5         # Sprints between maintenance checks
  min_cycle_length: 5             # Minimum — enforces ≤20% maintenance budget
  max_cycle_length: 7             # Maximum (excellent health)
  increment_trigger: "/nexus-close-sprint STEP 8D (every sprint closure)"
  reset_trigger: "/nexus-close-sprint STEP 8D after maintenance sprint (set to 0)"
```
[/Section: Maintenance-Tracking]

## Learned Patterns
[Section: Learned-Patterns]
```yaml
# Calibrated degradation rates from observed maintenance cycles
# Written by: /nexus-maintain Phase 3E (after each maintenance sprint)
# Read by: maintenance-scheduler (velocity seeds for predictions)
#
# Calibration formula (EMA — exponential moving average):
#   observed_rate = (op_score_after_prev_maint - op_score_before_this_maint) / sprints_elapsed
#   new_current = (old_current × 0.7) + (observed_rate × 0.3)
# Source for per-op scores:
#   op_score_after_prev_maint = history[-2].op_scores_after.{op} (from Maintenance-Tracking)
#   op_score_before_this_maint = Health-Operations.{op}.score (at start of maintenance)
# If per-op history unavailable (first maintenance), use overall health as proxy.

degradation_rates:
  # Per-operation degradation velocity (health points per sprint)
  # Aligned with the 5 operations tracked in [Health-Operations]
  # Baselines set to 3.0 (matches scheduler fallback for no-data scenarios)
  # First maintenance sprint calibrates to observed reality
  # urgency_class: quick_trigger = can drive standalone maintenance recommendation
  #                cycle_only    = feeds scheduled ETA only, never triggers early/targeted sprint
  backup_optimization:
    baseline: 3
    current: 3
    last_updated: "never"
    warning_threshold: 70
    urgency_class: cycle_only
  changelog_scan:
    baseline: 3
    current: 3
    last_updated: "never"
    warning_threshold: 70
    urgency_class: quick_trigger
  issue_validation:
    baseline: 3
    current: 3
    last_updated: "never"
    warning_threshold: 70
    urgency_class: quick_trigger
  pattern_maintenance:
    baseline: 3
    current: 3
    last_updated: "never"
    warning_threshold: 70
    urgency_class: cycle_only
  registry_cleanup:
    baseline: 3
    current: 3
    last_updated: "never"
    warning_threshold: 70
    urgency_class: quick_trigger

operation_effectiveness:
  # Track which operations provide best ROI
  # Updated after each maintenance execution
  most_valuable: []
  quick_wins: []
  time_intensive: []

prediction_accuracy:
  # Track how accurate predictions are
  total_predictions: 0
  accurate_predictions: 0        # Within ±1 sprint of actual
  accuracy_percentage: 0.0
  last_calibration: "never"      # When model was last recalibrated
```
[/Section: Learned-Patterns]

## Maintenance Decision
[Section: Maintenance-Decision]
```yaml
# Communication channel between maintenance-scheduler and /nexus-organize-sprint
# Written by: maintenance-scheduler (prediction/scheduling decisions)
# Read by: /nexus-organize-sprint (to determine sprint mode)
# Cleared by: /nexus-organize-sprint (after creating sprint)

decision_type: "none"
  # Values:
  # - "none" — No pending decision
  # - "execute_now" — Maintenance should happen immediately
  # - "scheduled" — Maintenance scheduled for specific sprint
  # - "deferred" — Maintenance explicitly deferred
  # - "emergency" — Critical maintenance required

decision_timestamp: ""            # When this decision was made
next_sprint_mode: ""              # NORMAL_SPRINT | MAINTENANCE_SPRINT | EMERGENCY_MAINTENANCE

# Decision-specific details (populated based on decision_type)
details:
  # For "scheduled":
  #   scheduled_for_sprint: XXX
  #   tier: "quick"
  #   operations: [health-diagnostic, pattern-maintenance]
  #   health_at_scheduling: 97     # 0-100 scale
  #
  # For "deferred":
  #   reason: "Why deferred"
  #   health_at_deferral: 95         # 0-100 scale
  #   next_reassessment: XXX
  #
  # For "execute_now" or "emergency":
  #   tier: "comprehensive"
  #   operations: [health-diagnostic, pattern-maintenance, registry-cleanup, issue-validation, backup-optimization, changelog-scan]
  #   trigger_reason: "Why now"
```
[/Section: Maintenance-Decision]

## Subsystem Verification
[Section: Subsystem-Verification]
```yaml
# Written by /nexus-subsystem-verification after each domain verification
# Not tracked by health-diagnostic
# Isolated section — only read/written by /nexus-subsystem-verification
# Every domain block may carry an optional `notes:` free-text summary of its last pass (shown on `system:` below)

project:
  last_verified: "never"
  last_verified_sprint: 0
  findings: 0
  fixed: 0
  remaining: 0
  status: "never"              # never | clean | minor_issues | major_issues | partial
  depth: ""                    # quick | full
  mental_traces: "n/a"         # done | pending | n/a
sprint:
  last_verified: "never"
  last_verified_sprint: 0
  findings: 0
  fixed: 0
  remaining: 0
  status: "never"
  depth: ""
  mental_traces: "n/a"
issue:
  last_verified: "never"
  last_verified_sprint: 0
  findings: 0
  fixed: 0
  remaining: 0
  status: "never"
  depth: ""
  mental_traces: "n/a"
pattern:
  last_verified: "never"
  last_verified_sprint: 0
  findings: 0
  fixed: 0
  remaining: 0
  status: "never"
  depth: ""
  mental_traces: "n/a"
memory:
  last_verified: "never"
  last_verified_sprint: 0
  findings: 0
  fixed: 0
  remaining: 0
  status: "never"
  depth: ""
  mental_traces: "n/a"
maintenance:
  last_verified: "never"
  last_verified_sprint: 0
  findings: 0
  fixed: 0
  remaining: 0
  status: "never"
  depth: ""
  mental_traces: "n/a"
core_protocols:
  last_verified: "never"
  last_verified_sprint: 0
  findings: 0
  fixed: 0
  remaining: 0
  status: "never"
  depth: ""
  mental_traces: "n/a"
registries:
  last_verified: "never"
  last_verified_sprint: 0
  findings: 0
  fixed: 0
  remaining: 0
  status: "never"
  depth: ""
  mental_traces: "n/a"
documentation:
  last_verified: "never"
  last_verified_sprint: 0
  findings: 0
  fixed: 0
  remaining: 0
  status: "never"
  depth: ""
  mental_traces: "n/a"
methodology:
  last_verified: "never"
  last_verified_sprint: 0
  findings: 0
  fixed: 0
  remaining: 0
  status: "never"
  depth: ""
  mental_traces: "n/a"
cognitive:
  last_verified: "never"
  last_verified_sprint: 0
  findings: 0
  fixed: 0
  remaining: 0
  status: "never"
  depth: ""
  mental_traces: "n/a"
system:
  last_verified: "never"
  last_verified_sprint: 0
  findings: 0
  fixed: 0
  remaining: 0
  status: "never"
  depth: ""
  mental_traces: "n/a"
  notes: ""                     # optional free-text summary of the last verification pass (added by subsystem-verification)
```
[/Section: Subsystem-Verification]

## Project Status
[Section: Project-Status]
```yaml
# Written by: /nexus-setup-project (defined), /nexus-work-issue (in_progress), /nexus-close-project (closed)
# Tracks current project lifecycle status
# Isolated section — only written by close-project at project closure

status: "not_defined"            # not_defined | defined | in_progress | closed
status_changed: ""               # ISO timestamp of last status change
closure_sprint: 0                # Sprint number at project closure (0 if not closed)
archive_location: ""             # Path to project archive (empty if not closed)
```
[/Section: Project-Status]

**Instantiation:**
- Copy this template to `.nexus/active/states/system-state.md`
- Replace placeholder values with initial state
- Run health-diagnostic for first health assessment

**Key Relationships:**
- health-diagnostic writes: [Health-Aggregated] (replaced on each run)
- health-diagnostic reads: [Health-Operations] + [Learned-Patterns]
- Individual ops write: [Health-Operations] (own score + last_run_sprint)
- /nexus-maintain Phase 1A reads: [Health-Aggregated] through [Learned-Patterns] (single range read)
- /nexus-maintain Phase 3D writes: [Maintenance-Tracking] (history + op_scores_after, tracking update)
- /nexus-maintain Phase 3E writes: [Learned-Patterns] (degradation rate recalibration)
- maintenance-scheduler reads: [Health-Aggregated] through [Learned-Patterns] (single range read)
- maintenance-scheduler writes: [Maintenance-Tracking] (prediction), [Maintenance-Decision]
- organize-sprint reads: [Maintenance-Decision] + [Maintenance-Tracking]
- organize-sprint writes: [Maintenance-Decision] (clear after sprint creation)
- close-sprint writes: [Maintenance-Tracking] (increment sprints_since_maintenance)
- subsystem-verification reads/writes: [Subsystem-Verification] (isolated)
- close-project writes: [Project-Status] (isolated)
- dashboard reads: all sections (full load, read-only)

**Section order rationale:**
Sections 1-4 (Health-Aggregated → Health-Operations → Maintenance-Tracking → Learned-Patterns)
are contiguous for efficient range reads by maintenance-scheduler and /nexus-maintain Phase 1A.
Sections 5-7 (Maintenance-Decision, Subsystem-Verification, Project-Status) have separate
consumers and are read individually.