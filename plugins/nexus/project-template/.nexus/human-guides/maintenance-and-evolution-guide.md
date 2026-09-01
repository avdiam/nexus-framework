# Maintenance & Evolution Guide
*Version: 1.2.0 | Date: 2026-08-25 | Sprint: 110 | Category: domain*

*Comprehensive reference to NEXUS system maintenance — health monitoring, predictive scheduling, 10 maintenance operations, the self-evolution pipeline, and system integrity verification. For users managing or understanding how NEXUS keeps itself healthy.*

**Source files:**
- `.claude/skills/nexus-maintain/SKILL.md` v2.4.0 (orchestrator)
- `.claude/skills/nexus-health-diagnostic/SKILL.md` v2.3.0
- `.claude/skills/nexus-pattern-maintenance/SKILL.md` v2.2.0
- `.claude/skills/nexus-registry-cleanup/SKILL.md` v2.4.0
- `.claude/skills/nexus-issue-validation/SKILL.md` v2.6.0
- `.claude/skills/nexus-backup-optimization/SKILL.md` v3.2.1
- `.claude/skills/nexus-maintenance-scheduler/SKILL.md` v2.0.2
- `.claude/skills/nexus-rollback/SKILL.md` v2.1.0
- `.claude/skills/nexus-changelog-scan/SKILL.md` v3.2.0
- `.claude/skills/nexus-subsystem-verification/SKILL.md` v2.4.0
- `.claude/skills/nexus-rebuild-architecture/SKILL.md` v2.4.0
- `.claude/skills/nexus-index-sprint/SKILL.md` v1.3.0
- `.claude/skills/nexus-staleness-checker/SKILL.md` v3.1.0
- `.nexus/templates/system-state-template.md` v3.5.0
- `CLAUDE.md` v5.11.0

---

## What Is Maintenance in NEXUS?
[Section: Introduction]

NEXUS is a self-maintaining system. As you work through sprints — creating issues, applying patterns, closing sprints — the system accumulates drift: registries grow stale, patterns lose relevance, backups pile up, and version tracking falls behind. Maintenance is the set of operations that detect, measure, and correct this drift.

Unlike traditional maintenance that runs on a fixed schedule, NEXUS uses **predictive maintenance**: it monitors health degradation rates per operation, projects when thresholds will be breached, and recommends maintenance at the optimal time. The system tracks its own health through a unified scoring framework (0–100 per operation), and an orchestrator (`/nexus-maintain`) coordinates execution during dedicated maintenance sprints.

The maintenance domain is also the engine behind NEXUS's **self-evolution**: observations captured during sprint work flow through sprint closure into preference adjustments, new issues, and the cross-sprint memory layer. Patterns are monitored for effectiveness and pruned or merged when they underperform. The system literally gets better at maintaining itself over time, calibrating degradation rates from observed data and adjusting maintenance cycles accordingly.

After reading this guide, you'll understand: how NEXUS measures its own health, when and why maintenance runs, what each of the 10 operations does, how the learning-to-evolution pipeline works, and how to intervene when something needs attention.

> Gate tiers (**T1** critical / **T2** decision / **T3** routine) and the Control Levels that decide which of them stop and ask you are explained in [The Three Unbreakable Principles](nexus-framework-guide.md#the-three-unbreakable-principles) — this guide uses that vocabulary without restating it.

[/Section: Introduction]

---

## Core Concepts
[Section: Core-Concepts]

**Health Score (0–100)**: Every maintenance operation produces a health score on a 0–100 scale. These scores are stored in system-state.md under `[Health-Operations]`. The health-diagnostic operation aggregates them into an overall system health score with staleness penalties.

**Staleness Penalty**: A score degrades over time. If registry-cleanup scored 100 three sprints ago, its *effective* score today is lower. The penalty is calculated using calibrated per-operation degradation velocities stored in `[Learned-Patterns].degradation_rates`. Fresh projects use conservative defaults until real data is available.

**Degradation Velocity**: The rate at which an operation's health score decays per sprint. Observed from actual maintenance data: `velocity = score_drop / sprints_elapsed`. These are calibrated after each maintenance sprint (`/nexus-maintain` Phase 3 Post-Execution D) using exponential smoothing: `new = (old × 0.7) + (observed × 0.3)`.

**Urgency Class**: Each operation has an urgency classification that determines whether it can trigger standalone maintenance recommendations. `quick_trigger` operations (changelog-scan, issue-validation, registry-cleanup) can drive early maintenance if their health drops fast. `cycle_only` operations (pattern-maintenance, backup-optimization) only feed scheduled cycle calculations.

**Maintenance Cycle**: The interval between maintenance sprints, typically 5 sprints (enforcing a ≤20% maintenance budget). Adjusted adaptively between 5–7 sprints based on health trajectory. The only exception allowing the cycle to drop below 5 is three or more consecutive deferrals — a genuine emergency override to 3 sprints.

**Maintenance Tiers**: Maintenance runs at different depths depending on need. **Quick** (≤1 critical, or overall > 70) runs health-diagnostic plus 1–2 targeted operations and may exit early. **Standard** (2+ warnings, or 1 critical with warnings) runs health-diagnostic plus 3–4 operations. **Comprehensive** (3+ critical, or > 30 days) runs all applicable operations with pre/post health measurement. Standard and Comprehensive close formally through `/nexus-close-sprint`.

**Deferred Debt**: When maintenance is recommended but deferred (the user decides to continue development instead), the system tracks this as debt — accumulated degradation points, deferral count, and urgency level. This ensures the system doesn't silently lose health.

**Experience Capture**: The pipeline that transforms sprint observations into system improvements. Entries accumulate in sprint-state's `[EXPERIENCE_CAPTURE]` block during normal work — `[SYSTEM_ISSUES]` and `[BEHAVIORAL_INSIGHTS]` nest inside it — and `/nexus-close-sprint` processes them at sprint closure into concrete outputs: new issues, preference adjustments, and durable records in `.nexus/memory/`.

**Subsystem Verification**: A deep structural audit of an entire domain — not health scoring but architectural integrity checking. Verifies that every operation's connections, targets, and compliance are aligned across three independent sources.

[/Section: Core-Concepts]

---

## Architecture
[Section: Architecture]

### Domain Overview

The Maintenance domain consists of 10 operation skills coordinated by 1 methodology skill, 1 domain-governed state file, and 1 domain-governed template:

```
.claude/skills/
├── nexus-maintain/                 Maintenance-sprint orchestrator (methodology)
├── nexus-health-diagnostic/        Aggregate health dashboard
├── nexus-pattern-maintenance/      Pattern system health (3-tier)
├── nexus-registry-cleanup/         Registry validation (2-tier)
├── nexus-issue-validation/         Issue semantic validation
├── nexus-backup-optimization/      Backup lifecycle management
├── nexus-maintenance-scheduler/    Predictive scheduling
├── nexus-rollback/                 Git-based restoration
├── nexus-changelog-scan/           Version tracking from headers
├── nexus-subsystem-verification/   Domain structural audit
└── nexus-rebuild-architecture/     Regenerates NEXUS-Architecture.md

.nexus/active/states/
└── system-state.md                 Health accumulator (7 sections)

.nexus/templates/
└── system-state-template.md        Schema for system-state
```

### system-state.md — The Health Accumulator

system-state.md is the central data store for the Maintenance domain, with 7 sections:

| Section | Written By | Purpose |
|---------|-----------|---------|
| Health-Aggregated | health-diagnostic | Overall score, structural check, adjusted scores, recommendations, history (last 10) |
| Health-Operations | Each of the 5 scored ops | Per-operation score (0–100) and last_run_sprint |
| Subsystem-Verification | subsystem-verification | Per-domain verification dates, findings, status |
| Maintenance-Tracking | close-sprint, /nexus-maintain, maintenance-scheduler | Cycle position, prediction, runtime execution state, deferred debt, history |
| Maintenance-Decision | maintenance-scheduler | Communication channel to organize-sprint (decision type, next sprint mode) |
| Learned-Patterns | /nexus-maintain Phase 3 (calibration) | Calibrated degradation rates, operation effectiveness, prediction accuracy |
| Project-Status | /nexus-setup-project, /nexus-close-project | Project lifecycle state |

The design pattern is **scatter-gather**: each maintenance operation writes only its own score to Health-Operations (scatter), and health-diagnostic reads all scores and aggregates them (gather). Contention stays low because every writer touches non-overlapping fields.

### Data Flow

```
Sprint Work → sprint-state [EXPERIENCE_CAPTURE]
                    ├── [SYSTEM_ISSUES]
                    └── [BEHAVIORAL_INSIGHTS]
                              │
                    ┌─────────┘
                    ▼
         /nexus-close-sprint (STEP 6)
         ├── → /nexus-create-issue (system issues)
         ├── → CLAUDE.md [Section: Behavioral-Preferences] (behavioral insights)
         └── → /nexus-index-sprint → .nexus/memory/*.jsonl

Each scored operation → system-state [Health-Operations] (own score)
                              │
                    ┌─────────┘
                    ▼
      /nexus-health-diagnostic → system-state [Health-Aggregated]
                              │
                    ┌─────────┘
                    ▼
  /nexus-maintenance-scheduler → system-state [Maintenance-Decision]
                              │
                    ┌─────────┘
                    ▼
       /nexus-organize-sprint (reads decision → creates sprint)
```

### Cross-Domain Boundaries

**Inbound** (who calls maintenance):
- `/nexus-maintain` orchestrates the applicable operations during maintenance sprints
- `/nexus-organize-sprint` STEP 0 loads `/nexus-maintenance-scheduler` before reading planning context (full path only)
- `/nexus-checkpoint` and `/nexus-close-sprint` trigger `/nexus-changelog-scan` reactively when the registry is stale

**Outbound** (what maintenance calls in other domains):
- health-diagnostic → organize-sprint (offer maintenance sprint)
- pattern-maintenance → delete-pattern, merge-patterns (pattern domain)
- subsystem-verification → create-issue (for major findings)
- rebuild-architecture → NEXUS-Architecture.md (regenerated from disk)

[/Section: Architecture]

---

## How Maintenance Works
[Section: How-It-Works]

### The Maintenance Lifecycle

Maintenance follows a predictable lifecycle tied to the sprint rhythm:

**1. Accumulation** (during normal sprints): As you work, health scores degrade through staleness. Sprint-state's `[EXPERIENCE_CAPTURE]` accumulates observations. close-sprint increments `sprints_since_maintenance`.

**2. Prediction** (at sprint planning): When the next sprint is organized, `/nexus-organize-sprint` STEP 0 loads `/nexus-maintenance-scheduler` before it reads any planning context. The scheduler reads health trajectory data, calculates when maintenance will be needed, and writes a decision to system-state `[Maintenance-Decision]`.

**3. Decision** (during sprint planning): organize-sprint reads the Maintenance-Decision. If maintenance is scheduled for this sprint, it offers to create a maintenance sprint instead of a normal one. The user decides.

**4. Execution** (maintenance sprint): `/nexus-maintain` orchestrates operations along a defined dependency chain. Each operation runs its workflow, writes its health score, and checkpoints between operations for continuity.

**5. Calibration** (post-maintenance): After all operations complete, health-diagnostic runs again to measure improvement. `/nexus-maintain` Phase 3 Post-Execution D calibrates degradation rates from observed data, updating Learned-Patterns for more accurate future predictions.

### The `/nexus-maintain` Orchestrator

`/nexus-maintain` is the methodology skill loaded during maintenance sprints. It runs five phases:

| Phase | Purpose |
|-------|---------|
| 1 Orient | Load system-state, select mode, detect resumption, check health freshness |
| 2 Planning | Calculate effective scores, determine tier, filter by project type, present the plan |
| 3 Execution | Run the approved operations (Mode A sequential or Mode B parallel scan), then calibrate degradation rates |
| 4 Verification | Measure improvement, check for regressions (rollback is T1-conditional here) |
| 5 Report & Closure | Optional checks — staleness-checker (automatic), subsystem-verification (T2 conditional), prune-memory (dry-run free, T1 at apply) — then report and close |

Operations run against a dependency chain: health-diagnostic must run first and pattern-maintenance runs last, with registry-cleanup, issue-validation, changelog-scan and backup-optimization between them. Registry-cleanup, issue-validation and backup-optimization are parallelizable; changelog-scan and pattern-maintenance are not. Mode A (sequential) serves the Quick tier; Mode B (parallel scan) serves Standard and Comprehensive, where the ~3× agent overhead is justified.

Runtime state tracking fields in system-state `[Maintenance-Tracking]` enable resumption if a conversation is interrupted mid-maintenance: `operations_completed`, `operations_pending`, `operations_failed`, `resume_from_operation`, and `tier`. Execution mode is conversation state, carried in sprint-state `continue_with` rather than as a system-state key.

### Predictive Scheduling

maintenance-scheduler calculates when the next maintenance sprint should occur:

**Per-operation projection**: For each of the 5 scored operations, it computes an ETA to threshold breach: `sprints_until = (effective_score - warning_threshold) / velocity`. The threshold is 70 by default.

**Adaptive cycle**: Starting from a base of 5 sprints, adjustments are made for rapid degradation (any quick_trigger op velocity > 6 → shorten by 1), slow degradation (all velocities < 1.5 → lengthen by 1), and deferred debt (3+ deferrals → emergency override to 3). The result is clamped to 5–7 (with the sole exception of the emergency override).

**Confidence**: HIGH with 3+ history points and stable velocity, MEDIUM with 2 points or moderate variance, LOW with insufficient data or stale health assessment.

**Early warnings**: If any quick_trigger operation's ETA falls before the scheduled maintenance sprint, the system surfaces a warning — but does not mechanically alter the cycle. The user can respond by requesting earlier maintenance or running targeted operations.

### Documentation Staleness Cadence

Guide freshness is not on a schedule of its own — it rides the adaptive maintenance cycle above. `/nexus-staleness-checker` runs **automatically** at `/nexus-maintain` Phase 5, so documentation gets checked every time a maintenance sprint runs (every 5–7 sprints, or sooner under the deferral override). There is no separate cadence to remember, and nothing to configure. Between maintenance sprints you can run it on demand by saying **"check staleness"**.

**What it compares**: each guide's recorded `references:` in `documentation-registry.yaml` against the current versions in `changelog-registry.yaml`. A guide whose sources have moved on is flagged Review, Stale, or Critical depending on how many references drifted and how far. It also checks the template version chain — the setup wizard, the meta-template's `built_for_wizard`, and every domain profile's `spec_version`.

**It reports; it never edits.** Regeneration is `/nexus-guide-creator`'s job, offered as a choice when stale guides are found. Accuracy depends on `changelog-registry.yaml` being current, so the checker warns if that registry's header is more than 2 sprints behind and points you at **"changelog scan"** first.

**What this cadence cannot catch.** Version drift is a *proxy* for staleness, not a check on truth. Two blind spots follow from that, and both need a deliberate truth-pass rather than a staleness run:

- A guide whose sources never changed can still be wrong — a claim that was inaccurate when written stays inaccurate, and every version will match.
- Human guides are not tracked in `changelog-registry.yaml`, so where one guide cites another, the checker has no version to compare and reports the reference as unmatched rather than as drift.

[/Section: How-It-Works]

---

## The 10 Operations
[Section: Operations-Guide]

### health-diagnostic
**Command:** `run health diagnostic` / `health diagnostic` (`show system health status` reads the last stored result without re-assessing)
**What it does:** Reads the 5 scored operations from Health-Operations, applies staleness penalties using calibrated degradation velocities, checks system file existence, and produces a unified health dashboard. It is a read-only aggregator — it never writes another operation's score.
**When to use:** To assess current system health, after completing maintenance operations, or when the system feels sluggish.
**Key workflow:** Load scores → calculate staleness-adjusted scores → structural file check → compute overall health (`(structural + the 5 adjusted scores) ÷ 6`, equal weight) → generate recommendations sorted by urgency → persist to Health-Aggregated → display dashboard.
**Output:** Dashboard with overall score, per-operation breakdown (raw/adjusted/staleness), structural check results, and prioritized recommendations. Offers to create a maintenance sprint via organize-sprint.
**Scores:** 0–100 overall. Status: HEALTHY (≥80), NEEDS ATTENTION (≥60), DEGRADED (≥40), CRITICAL (<40).

---

### pattern-maintenance
**Command:** `pattern review` / `consolidate knowledge`
**What it does:** Three-tier escalating analysis of the pattern system. Tier 1 always runs — it scans registry metadata for all patterns and scores them. Tiers 2 and 3 are user-initiated (auto-selected at Streamlined): Tier 2 deep-examines selected patterns (4Q validation, completeness, trigger quality), Tier 3 finds similarity candidates for merging.
**When to use:** During scheduled maintenance, or when pattern effectiveness seems low, or after creating several new patterns.
**Key workflow:** Load patterns-registry → Tier 1 registry scan (categorize: strong/adequate/attention/poor) → present findings → user selects Tier 2 or 3 → Tier 2: load PAT files, 4Q validate, enhance or delete → Tier 3: identify similar pairs, delegate to merge-patterns → calculate health score → persist.
**Cross-domain calls:** delete-pattern (for failed patterns), merge-patterns (for similar pairs).
**Health score formula:** `(usage_weighted_effectiveness × 0.70) + (maturity_distribution × 0.30)`. Usage-weighted means high-application proven patterns dominate; new emerging patterns don't penalize the system.

---

### registry-cleanup
**Command:** `cleanup registries`
**What it does:** Two-tier validation of the 4 active registries. Tier 1 validates issues-registry and patterns-registry against their governing specs (11 checks each). Tier 2 validates documentation-registry structurally (4 checks). Changelog-registry is not audited here — it is rebuilt from file headers by changelog-scan.
**When to use:** During scheduled maintenance, after bulk issue/pattern operations, or when suspecting data integrity issues.
**Key workflow:** Load registries + governing specs → Tier 1: ghost entries, orphan files, duplicates, schema compliance, score bounds, enum validity, cross-references, sprint-state score drift → Tier 2: documentation guide existence, status accuracy → aggregate findings by severity (CRITICAL/IMPORTANT/MINOR) → user approves fixes → apply in severity order (ghosts first for cascade resolution) → post-fix revalidation → health score.
**Important detail:** Fix ordering matters — ghost entries are removed first because they cause cascading cross-reference breaks. After ghost fixes, cross-references are re-validated and many IMPORTANT findings auto-resolve.
**Valid issue types:** Bug, Feature, Improvement, Refactor, Documentation, Question, Research, Creative.

---

### issue-validation
**Command:** `validate issues`
**What it does:** Six registry-level validation checks across all active issues: phase evidence (scores ≥4 have supporting ISS content?), status consistency (Resolved issues actually complete?), scope file existence, priority logic (blocker priority inversions), deliverable coverage (project-state refs valid?), and project-state cross-validation (completion percentages accurate?). It detects and proposes — it never auto-fixes. At the Comprehensive tier an optional deep ISS-level pass runs behind a T2 gate.
**When to use:** During scheduled maintenance, after bulk issue modifications, or before sprint closure.
**Key workflow:** Load issues-registry + project-state + sprint-queue → run 6 checks → aggregate findings by severity → user approves fixes → apply (including two-place updates for score changes) → health score.
**Graceful degradation:** If project-state or sprint-queue aren't found, those specific checks are skipped rather than blocking the entire operation.

---

### backup-optimization
**Command:** `backup optimization`
**What it does:** Project-type-aware backup lifecycle management. Classifies backups by content significance (not just age), preserves milestones and critical coverage, recommends cleanup with safety validation.
**When to use:** During scheduled maintenance, when `.nexus/backups/` grows large, or when backup counts seem excessive.
**Two execution tracks:** *Git* — for code-only projects, where text files are covered by checkpoint commits; this track is a lightweight health check and always scores 100. *Binary* — for projects with binary deliverables (.docx, .pptx, .xlsx, .pdf, images, archives), which are the only files copied into `.nexus/backups/`.
**Key workflow (Binary track):** Discovery (inventory `.nexus/backups/`) → content analysis (classify changes as major/moderate/minor, detect milestones) → retention decisions (always preserve: <7 days, milestones, only-backup, minimum critical coverage) → cleanup by tier (corrupted first, then minor-old, then moderate-old) → post-execution validation → health score.
**Safety:** Pre-execution check verifies no preservation rules are violated. Post-execution spot-checks critical file backups.

---

### maintenance-scheduler
**Command:** `maintenance prediction`
**What it does:** Predictive maintenance scheduling — analyzes health trajectory, calculates adaptive cycle length, projects threshold breaches, and writes actionable decisions for organize-sprint.
**When to use:** Loaded by `/nexus-organize-sprint` STEP 0 on the full planning path, or run manually to check when maintenance is due.
**Two modes:** Silent (analyze, predict, write, return) and Interactive (adds dashboard display with schedule/defer/analytics options).
**Key workflow:** Load system-state sections → per-operation staleness + velocity → acceleration detection → threshold projection per op (using urgency_class) → adaptive cycle calculation (5–7, clamped) → write prediction to Maintenance-Tracking → write decision to Maintenance-Decision → (interactive: display dashboard with options).
**Deferred debt tracking:** When user defers, records: incremented deferral count, accumulated degradation, urgency level (LOW at 1 deferral → CRITICAL at 3+), and the reason for historical tracking.

---

### rollback
**Command:** `rollback` / `undo last change` / `restore file`
**What it does:** Version-aware restoration built as a git wrapper. Text and code files restore from git history (checkpoint commits, tags); binary deliverables restore from the timestamped copies in `.nexus/backups/`. Five workflows differ by scope and risk: single-file version restore, quick undo, full system snapshot rollback, known-good-state recovery, and binary restore.
**When to use:** After a bad write, when a file needs to return to a known version, or for system-wide recovery.
**Key insight:** changelog-registry snapshots supply the *version*; git supplies the *content*. The registry is searched for the target version, then matched to the closest commit — so rollback degrades gracefully when the registry is missing (quick undo still works, the other workflows are limited).
**Critical safety:** System snapshot rollback requires typing `ROLLBACK {snapshot_ID}` exactly to confirm — no accidental bulk restorations. Every workflow previews a `git diff` before restoring.

---

### changelog-scan
**Command:** `changelog scan` / `rebuild changelog`
**What it does:** Auto-generates changelog-registry.yaml by scanning system file headers. The files ARE the source of truth; the registry is a derived index.
**When to use:** During sprint closure (mode 3 — stable snapshot), during maintenance (mode 2 — full scan), or to rebuild after corruption (mode 1 — quick).
**Three modes:** Quick (current versions only), Full (+ non-stable snapshot), Sprint closure (+ stable snapshot for rollback targets).
**Key workflow:** Load previous registry + the tracked path set → scan all system file headers via regex search per category → identify unexpected/removed files → build current_versions grouped by category → domain change analysis (vs last stable snapshot) → create snapshot (modes 2/3) → rewrite registry → health score.
**Runs reactively too:** `/nexus-checkpoint` and `/nexus-close-sprint` trigger a scan when the registry is older than its source files, so the registry rarely drifts far.
**Snapshot retention:** Last 5 stable (sprint closure) snapshots + most recent non-stable scan.

---

### subsystem-verification
**Command:** `verify subsystem`
**What it does:** Systematic deep audit of an entire NEXUS domain. Three-source triangulation (`CLAUDE.md` routing map × `NEXUS-Architecture.md` × disk), then per-file examination of every operation: connection alignment, outbound target verification, compliance checks, and mental execution traces. Findings follow a fix-or-defer rule — minor fixes (single file, under 5 patches) apply inline with consent; major fixes defer as new issues.
**When to use:** After major rewrites to a domain, periodically (every 3–5 sprints per domain), or when changelog-scan flags a domain with many changes.
**Key workflow:** Select domain → triangulate file lists across the 3 sources → load the architecture map for context → for each file: load+inspect, align connections, verify all outbound targets exist with correct fields, run the compliance checklist → after all files: systemic pattern detection → mental execution traces (2–3 scenarios) → domain report → update system-state.
**Pattern:** PAT-063 domain-coherence checklist — 7 dimensions (routing, scale/unit, memory-first, N-place update, cross-op compatibility, info flow, field/schema) plus caller/consumer stale-reference checks.
**Scale:** This is the most thorough and token-expensive maintenance operation. A full domain verification can span multiple conversations. File boundary gates offer checkpoints between files.
**Constraint:** One domain at a time.

---

### rebuild-architecture
**Command:** `rebuild architecture` / `regenerate architecture map`
**What it does:** Regenerates `NEXUS-Architecture.md` by scanning every skill, framework file, state file, registry and template. This is a *generation* operation, not a verification — it builds the map from reality rather than checking existing claims against it.
**When to use:** After a major port or restructuring (skills added, removed, or reorganized), or when subsystem-verification reports widespread architecture discrepancies.
**Key workflow:** Discover skills → scan connections → cross-reference → classify domains → generate document → [T1 gate: write] → verify → git commit → report.
**Relationship to subsystem-verification:** verification *finds* drift in one domain; rebuild-architecture *eliminates* it across all of them by regenerating the map. Rebuild is the heavier operation — reach for it when drift is widespread, not for a handful of stale rows.

[/Section: Operations-Guide]

---

## The Self-Evolution Pipeline
[Section: Evolution]

NEXUS improves itself through a structured pipeline that converts raw observations into system changes:

### Stage 1: Observation (During Sprints)

As you work, Claude records observations in sprint-state.md inside `[EXPERIENCE_CAPTURE]`, which nests two sections:
- `[SYSTEM_ISSUES]`: Technical problems — violations detected, gaps found, bugs encountered, anti-patterns noticed, improvements needed.
- `[BEHAVIORAL_INSIGHTS]`: Working style observations — user preferences, corrections, character moments, insights about how you like to work.

These are raw notes, not processed decisions. `/nexus-checkpoint` appends them as work happens, asking approval first at Balanced and Full Control.

### Stage 2: Processing (Sprint Closure)

`/nexus-close-sprint` STEP 6 processes the accumulated entries — this happens at closure, not at maintenance, so nothing waits on a maintenance sprint to be acted on.

**System issues** are grouped by semantic similarity (e.g., three separate write-failure reports become one group). For each group, you choose: create a formal issue (spawns `/nexus-create-issue`), apply a quick fix right now, defer, or skip.

**Behavioral insights** are matched against existing preferences in `CLAUDE.md` [Section: Behavioral-Preferences]. For each group, you choose: elevate an existing preference's importance level (e.g., medium → high), add a new preference, defer, or skip.

### Stage 3: Indexing

`/nexus-index-sprint` writes what the sprint learned into the cross-sprint memory layer at `.nexus/memory/` — decisions, discoveries, work debt, rejected pattern candidates, issue learnings, a sprint summary, and a keyword index. These are append-only JSONL records that later sprints read back during analysis and planning.

### Stage 4: Integration

The outputs flow back into the system:
- New issues enter the sprint queue for future work
- Quick fixes are applied immediately to system files
- Preference changes modify `CLAUDE.md`, shaping how Claude behaves in all future conversations
- Deferred entries carry forward in the next sprint's `[EXPERIENCE_CAPTURE]`
- Memory records stay queryable across every future sprint

### Stage 5: Calibration (Post-Maintenance)

After maintenance completes, `/nexus-maintain` Phase 3 Post-Execution D updates degradation rates in `[Learned-Patterns]` based on observed vs predicted health changes, using exponential smoothing. This makes future maintenance predictions more accurate, and the recorded prediction accuracy drives recalibration when drift is detected.

### The Feedback Loop

```
Work → Observe → Accumulate → Process → Integrate → Better Work
                                  ↓
                          Calibrate Predictions
                                  ↓
                        More Accurate Scheduling
                                  ↓
                      Right Maintenance at Right Time
```

This is not aspirational — it's operational. Degradation rates are calibrated from real data, predictions are tracked for accuracy, and the maintenance cycle adapts based on measured system behavior.

*Note the split*: experience processing runs at **sprint closure** (every sprint), while degradation calibration runs at **maintenance** (every 5–7 sprints). Only the health half waits for a maintenance sprint.

[/Section: Evolution]

---

## Key Files and Data
[Section: Data-And-Files]

### State Files

| File | Location | Purpose | Key Sections |
|------|----------|---------|-------------|
| system-state.md | `.nexus/active/states/` | Health accumulator — 7 sections spanning health, maintenance tracking, learned patterns | Health-Aggregated, Health-Operations, Subsystem-Verification, Maintenance-Tracking, Maintenance-Decision, Learned-Patterns, Project-Status |
| sprint-state.md | `.nexus/active/states/` | Carries the observation buffer the evolution pipeline drains at closure | [EXPERIENCE_CAPTURE] → [SYSTEM_ISSUES], [BEHAVIORAL_INSIGHTS] |

### Templates

| Template | Location | Governs | Used By |
|----------|----------|---------|---------|
| system-state-template.md | `.nexus/templates/` | system-state.md schema | close-project (archival), subsystem-verification (schema reference) |

### Registries Touched

The maintenance domain interacts with all 4 registries:
- **issues-registry.yaml**: Read+write by registry-cleanup (Tier 1 validation), issue-validation (semantic checks)
- **patterns-registry.yaml**: Read+write by registry-cleanup (Tier 1 validation), pattern-maintenance (health analysis)
- **documentation-registry.yaml**: Read+write by registry-cleanup (Tier 2 validation)
- **changelog-registry.yaml**: Rewritten by changelog-scan (the file headers are the source of truth); read by rollback for version lookup

### Output Locations

Maintenance reports are written to `.nexus/Maintenance-cycles/{sprint}/`, where `{sprint}` is the sprint number:

| Report | Written by |
|--------|-----------|
| `maintenance-report.md` | `/nexus-maintain` — the cycle summary |
| `health-report.md` | health-diagnostic |
| `registry-cleanup-report.md` | registry-cleanup |
| `issue-validation-report.md` | issue-validation |
| `pattern-maintenance-report.md` | pattern-maintenance |
| `backup-optimization-report.md` | backup-optimization |
| `changelog-scan-report.md` | changelog-scan |
| `verification-{domain}-{date}.md` | subsystem-verification |

Most operations *offer* the export rather than writing it unconditionally, so a cycle folder holds only the reports you accepted.

[/Section: Data-And-Files]

---

## Integration Points
[Section: Integration-Points]

### How Maintenance Connects to Other Domains

**Sprint Domain**: close-sprint increments `sprints_since_maintenance` and triggers changelog-scan reactively when the registry is stale. organize-sprint loads maintenance-scheduler at STEP 0 and reads Maintenance-Decision to determine whether to offer a maintenance sprint.

**Issue Domain**: close-sprint can create new issues via create-issue when `[SYSTEM_ISSUES]` entries need formal tracking; subsystem-verification does the same for major findings. issue-validation reads issues-registry and ISS files for semantic checks.

**Pattern Domain**: pattern-maintenance delegates to delete-pattern and merge-patterns for pattern lifecycle management. registry-cleanup validates patterns-registry against pattern-specification.

**Project Domain**: issue-validation reads project-state for deliverable coverage and completion accuracy checks. close-project uses system-state-template for archival.

**Core Protocols**: health-diagnostic reads the System Paths block in `CLAUDE.md` [Section: Routing-Map] for its structural file checks. close-sprint can patch `CLAUDE.md` [Section: Behavioral-Preferences] when a behavioral insight is promoted.

### The Organizer → Scheduler → Decision Chain

This is the most important integration path:

1. **`/nexus-start`** detects a properly closed sprint (`_status: complete`, `_closure_time` exists) and routes to Planning
2. **`/nexus-organize-sprint`** STEP 0 loads `/nexus-maintenance-scheduler` *before* reading planning context, so the prediction is fresh
3. Scheduler reads health data, calculates trajectory, writes the prediction to `[Maintenance-Tracking]` and the decision to `[Maintenance-Decision]`
4. organize-sprint reads `[Maintenance-Decision]` and offers the user a maintenance sprint if one is scheduled — clearing the decision after reading it

The scheduler is pulled by the planner, not pushed by the boot sequence. That ordering is what guarantees the prediction informing a sprint plan was computed against the health data current at planning time.

[/Section: Integration-Points]

---

## Troubleshooting
[Section: Troubleshooting]

### Health score seems wrong or outdated
**Cause:** health-diagnostic hasn't run recently, or degradation rates are uncalibrated.
**Fix:** Run `run health diagnostic` manually. If rates seem off (scores dropping too fast or too slow), the next full maintenance sprint will recalibrate via Phase 3 Post-Execution D.

### Maintenance keeps getting recommended too often
**Cause:** A quick_trigger operation is degrading faster than expected, or degradation rates are overcalibrated.
**Fix:** Run `maintenance prediction` to see the detailed analytics. Check which operation's velocity is driving the recommendation. If the rate seems unreasonable, it will self-correct after the next maintenance calibration.

### Maintenance was deferred and now urgency is HIGH
**Cause:** Multiple deferrals have accumulated degradation debt.
**Fix:** Run a maintenance sprint. If urgency is CRITICAL (3+ deferrals), the system will override the minimum cycle to 3 sprints. After maintenance completes, debt resets.

### Registry has ghost entries (IDs without files)
**Cause:** An issue or pattern was deleted or archived without updating the registry.
**Fix:** Run `cleanup registries`. Tier 1 detects ghosts as CRITICAL findings and proposes removal. Ghost fixes run first to resolve cascade reference breaks.

### subsystem-verification found many NEXUS-Architecture.md gaps
**Cause:** Skills were added, removed, or reorganized without the architecture map being regenerated.
**Fix:** For a handful of stale rows, accept the patches verification proposes. For widespread drift, run `rebuild architecture` instead — it regenerates the whole map from disk rather than patching claims one at a time.

### Checkpoint interrupted mid-maintenance
**Cause:** Context limit reached during a maintenance sprint.
**Fix:** The next conversation will detect `operations_in_progress: true` in Maintenance-Tracking and offer to resume from `resume_from_operation`. Completed operations won't re-run.

### changelog-registry seems out of sync
**Cause:** Files were modified without version bumps, or changelog-scan hasn't run recently.
**Fix:** Run `changelog scan` (mode 1 for quick, mode 2 for full). It rebuilds the registry from actual file headers — the files are always the source of truth. Checkpoints and sprint closure also trigger this reactively when the registry falls behind its sources.

[/Section: Troubleshooting]

---

## Quick Reference
[Section: Quick-Reference]

### Commands

| Command | Operation | What It Does |
|---------|-----------|-------------|
| `run health diagnostic` | health-diagnostic | System health dashboard |
| `pattern review` | pattern-maintenance | 3-tier pattern health |
| `cleanup registries` | registry-cleanup | 2-tier registry validation |
| `validate issues` | issue-validation | 6-check issue validation |
| `backup optimization` | backup-optimization | Backup lifecycle management |
| `maintenance prediction` | maintenance-scheduler | Predictive scheduling |
| `rollback` | rollback | Git-based restoration |
| `changelog scan` | changelog-scan | Version tracking rebuild |
| `verify subsystem` | subsystem-verification | Domain structural audit |
| `rebuild architecture` | rebuild-architecture | Regenerate the architecture map |
| `maintenance menu` | — | Show all maintenance options |
| `show system health status` | — | Quick health read (no re-assessment) |
| `maintenance status` | — | Read cycle position and deferred debt |

### Health Score Thresholds

| Range | Status | Action |
|-------|--------|--------|
| 80–100 | HEALTHY | Normal operations |
| 60–79 | NEEDS ATTENTION | Monitor, consider targeted maintenance |
| 40–59 | DEGRADED | Maintenance recommended soon |
| 0–39 | CRITICAL | Immediate maintenance required |

### Staleness Labels

| Sprints Since | Status |
|---------------|--------|
| 0–2 | 🟢 Fresh |
| 3–4 | 🟡 Aging |
| 5–6 | 🟠 Stale |
| 7+ | 🔴 Overdue |

### Operation Urgency Classes

| Class | Operations | Behavior |
|-------|-----------|----------|
| quick_trigger | changelog-scan, issue-validation, registry-cleanup | Can drive standalone early maintenance |
| cycle_only | pattern-maintenance, backup-optimization | Feeds scheduled cycle only |

### Typical Maintenance Sprint Sequence

```
1. health-diagnostic (baseline, always first)
2. registry-cleanup
3. issue-validation
4. changelog-scan (sprint snapshot)
5. backup-optimization (binary-track projects only)
6. pattern-maintenance (always last)
7. health-diagnostic (post-measurement)
8. calibrate degradation rates
9. staleness-checker (automatic, Phase 5)
10. subsystem-verification (conditional, Phase 5)
```

Which of these actually run depends on the tier: Quick takes health-diagnostic plus 1–2 targeted operations; Standard adds 3–4; Comprehensive runs all applicable.

### Key system-state Sections

| Section | Who Writes | Who Reads |
|---------|-----------|-----------|
| Health-Aggregated | health-diagnostic | dashboard, organize-sprint, maintenance-scheduler |
| Health-Operations | Each of the 5 scored ops | health-diagnostic, maintenance-scheduler |
| Subsystem-Verification | subsystem-verification | subsystem-verification (previous results) |
| Maintenance-Tracking | close-sprint, /nexus-maintain, maintenance-scheduler | organize-sprint, maintenance-scheduler |
| Maintenance-Decision | maintenance-scheduler | organize-sprint (clears after reading) |
| Learned-Patterns | /nexus-maintain Phase 3 (calibration) | health-diagnostic, maintenance-scheduler |

[/Section: Quick-Reference]
