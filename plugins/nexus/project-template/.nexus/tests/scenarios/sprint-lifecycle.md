# Scenario: Sprint Lifecycle (organize → close)
*Targets: nexus-organize-sprint + nexus-close-sprint (current) | Suite: ISS-086 | Last baselined: 2026-06-03*

Mutation class: **destructive / hard-to-reverse** — close-sprint archives issues, resets sprint-state, processes patterns/experience. → **Dry-run narrated only.** Do NOT execute live against the real sprint.

## Given (preconditions)
- For organize: `_status: complete` (properly closed prior sprint, `_closure_time` set) → Planning phase, or a fresh sprint to plan.
- For close: a sprint with all `[OBJECTIVES]` resolved and `_status: closing`.

## Trigger
- Organize: `organize sprint` (or boot detecting Planning phase).
- Close: `close sprint` (or boot dispatching `_status: closing` → Learning conversation).

## Expected Behavior (narrate; do not mutate)
1. **Organize**: `/nexus-organize-sprint` selects mode (THEMED/MIXED/DEDICATED), populates `[OBJECTIVES]`, sets `_sprint`, `_status: ready`/`in_progress`, `_mode`.
2. **Close STEP 0**: Sprint-Level Validate trigger computed BEFORE any destructive op, per `_mode` rule (THEMED always; MIXED ≥2/3 signals; DEDICATED never).
3. **Close** resolves issues, processes candidate patterns (4Q), processes experience → behavioral_preferences, archives issues to `.nexus/archived/issues/`, updates project-state.
4. Closure writes use the **hybrid WRITE-VERIFIED** cadence: per-write for new PAT/ISS files, one BATCHED table at the STEP 9A-2 verification gate.
5. `⛔[SKILL-INVOKED]` markers emitted at invoke-required closure steps (update-pattern, create-pattern, archive-issue, create-issue).

## State Assertions (MANDATORY — expressed as expected post-close state; verified by narration)
| Artifact | Field / Anchor | Expected value after close |
|---|---|---|
| `sprint-state.md` | `_status` | `complete` with `_closure_time` set |
| `sprint-state.md` | `[OBJECTIVES]` | all issues under `completed:` (none planned/in_progress) |
| `.nexus/archived/issues/` | resolved ISS files | each closed issue archived |
| `issues-registry.yaml` | closed ISS `status` | `Resolved` / `Rejected` |
| project-state.md | sprint count / history | reflects the closed sprint |

## Out of Scope
- Live execution (forbidden — destructive). Real coverage comes from actual sprint closures, narrated here for protocol shape.
- Sprint-Level Validate four-cross-cut internals (owned by nexus-validate types/sprint-level.md).
- Pattern 4Q internals (owned by nexus-create-pattern).

## Run Results

### Run 1 — 2026-06-03 — executor: Sprint 096 Conv 5 (dry-run narrated)
Mode: dry-run-narrated (destructive scenario — close-sprint archives/resets; live execution forbidden per protocol Step 2)
Targets at run time: nexus-close-sprint + nexus-organize-sprint (current Sprint 096 state)

Narration (expected transitions, NOT executed):
1. With Sprint 096 `_mode: MIXED` and (at real closure) all objectives resolved, close-sprint **STEP 0** would compute the Sprint-Level Validate trigger: MIXED offers when ≥2/3 signals fire (shared scope_files / shared skill in [FILES_MODIFIED] / blocks-edge). ISS-204 + ISS-086 share no scope_files and no blocks-edge → likely **<2 signals → no offer** (narrated expectation; confirm at real closure).
2. close-sprint would resolve ISS-086, process the two candidate patterns (PAT-102 reconciliation already done; ISS-086 SC-07 overlap-statement 4Q), process carried-forward [SYSTEM_ISSUES] + [BEHAVIORAL_INSIGHTS], archive ISS-204/ISS-086 to `.nexus/archived/issues/`, set `_status: complete` + `_closure_time`, update project-state.
3. Closure writes would follow hybrid WRITE-VERIFIED (per-write new PAT/ISS; one BATCHED table at STEP 9A-2).

| # | Assertion | Expected | Actual (narrated) | Verdict |
|---|---|---|---|---|
| 1 | `sprint-state.md` `_status` post-close | `complete` + `_closure_time` set | would be set by close-sprint STEP final | ⚠ DRY-RUN (not executed) |
| 2 | `[OBJECTIVES]` post-close | all under `completed:` | ISS-204 already completed; ISS-086 would join | ⚠ DRY-RUN |
| 3 | `.nexus/archived/issues/` | ISS-204 + ISS-086 archived | would be archived | ⚠ DRY-RUN |
| 4 | Sprint-Level Validate trigger (MIXED) | offer iff ≥2/3 signals | narrated <2 → no offer (verify live) | ⚠ DRY-RUN |

Drift flagged: none observed in protocol shape; trigger-signal count is a live-confirm item at actual Sprint 096 closure.
Cleanup: dry-run — no mutation.
