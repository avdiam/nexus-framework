---
name: nexus-organize-sprint
description: Plan and create a new sprint from project priorities, queue, and capacity
disable-model-invocation: true
---
*Version: 2.11.0 | Date: 2026-08-20 | Sprint: 110*

# Organize Sprint

**Flow**: Load context → [Full: Assess landscape → Evaluate queue → Plan sprints → [T1: confirm] → Create | Diagnostic: Evaluate queue → Fix → Report]

Plan and create a new sprint from project priorities, queue, and capacity. Also serves as standalone queue diagnostic. Dual-path: full (sprint creation) or diagnostic (queue health check).

---

### STEP 0: Load Context

Detect entry path from user's trigger or calling operation's context:

| Signal | Path | Flow |
|--------|------|------|
| "organize sprint", called by Bootstrap or close-sprint | **Full** | Landscape → Evaluate → Plan → Create |
| "check queue", "queue health", "reorganize queue", "analyze queue" | **Diagnostic** | Evaluate → Fix if needed → Report |

**Resumption check (full path only)**: If re-running organize-sprint after a partial creation (previous attempt failed mid-way), detect completed steps:

| Evidence | Meaning | Action |
|----------|---------|--------|
| New sprint-state.md exists with `_sprint` = planned sprint number | STEP 4C completed | Skip to STEP 4D (system file updates) |
| issues-registry `target_sprint` already set for planned issues | STEP 4D.1 completed | Skip registry patches |
| Sprint folder already exists in `.nexus/Sprints/` | STEP 4D.5 completed | Skip folder creation |

When in doubt, re-run — registry patches and queue updates are idempotent when values match.

**Maintenance scheduling (full path only):** `load /nexus-maintenance-scheduler` — produces maintenance decision in system-state. Run before loading context so the maintenance check below has fresh data.

**Full path — load all:**

| File | What You Need |
|------|---------------|
| system-state.md | `Read .nexus/active/states/system-state.md#[Section: Maintenance-Decision]` + `#[Section: Maintenance-Tracking]` |
| project-state.md | `Read .nexus/active/states/project-state.md` — phases, deliverables, constraints, priorities, [NEXT_PHASE_NOTES] |
| sprint-queue.md | `Read .nexus/active/states/sprint-queue.md` |
| issues-registry.yaml | `Read .nexus/active/registries/issues-registry.yaml` |
| sprint-queue-template.md | `Read .nexus/templates/sprint-queue-template.md` (STEP 4 only) |

**Diagnostic path — load subset:** project-state.md, sprint-queue.md, issues-registry.yaml.

**Memory-layer planning context** (full path only; CLAUDE.md [Section: Memory-Layer]; skip silently if `.nexus/memory/` absent or files hold only the safety marker):

- `grep` `work_debt.jsonl` for `"status":"unresolved"` (and `"deferred"`) → surface outstanding debt as candidate work when assessing the landscape (STEP 1) and evaluating the queue (STEP 2). Note `carried_from` to flag debt that has persisted across multiple sprints ("this keeps slipping").
- `grep` `decisions.jsonl` by the planned domain's tags for prior planning/architecture decisions that constrain or inform sequencing. Apply CLAUDE.md [Section: Memory-Read-Rule] (recency + `superseded_by` exclusion; surface `contradicts` rather than silently picking).

Surface as: "Outstanding work-debt: {N} unresolved ({M} carried >1 sprint). Relevant prior decisions: {list or none}." Do not auto-create issues from debt here — present it so the user can choose to promote items into the plan.

**Context artifacts** (conditional, full path only): If `.nexus/supporting-files/project-context/CONCERNS.md` exists, read it for sprint planning context:

- Note unresolved concerns (`- [ ]` entries) that may affect sprint priorities
- Flag HIGH severity concerns that should influence issue selection or sequencing
- Use as passive context when assessing risks in STEP 1 and evaluating queue in STEP 2

Do not actively generate issues from CONCERNS.md here — that's /nexus-generate-mvp's responsibility. Just note: "Known project concerns: {count} unresolved. HIGH severity: {list or 'none'}." if relevant.

If sprint-queue.md is missing or empty: full path → display "Queue empty — full planning needed" → STEP 1. Diagnostic path → display "No queue to evaluate — run 'organize sprint' to create one" and stop.

**State file size check** (full path, after loading project-state.md and sprint-queue.md):
- project-state.md > 700 lines: "⚠️ project-state at {N} lines (warning: 700)." [T3] Offer compression: consolidate completed phase descriptions, compress old [NEXT_PHASE_NOTES]. > 800: mandatory compression.
- sprint-queue.md > 300 lines: "⚠️ sprint-queue at {N} lines (warning: 300)." [T3] Offer compression: remove completed/cancelled sprint entries, compress old queue history. > 400: mandatory compression.
If compression needed: full rewrite of affected file after compression, verify line count.

**Queue cleanup**: Scan sprint-queue.md for sprints marked `"COMPLETE ✅"` or with status `complete`. Remove their entire entry block (id, mode, focus, status, planned_work, total_complexity, rationale) from the queue — completed sprints should not accumulate. Also update `## Sprint Planning Summary` counts to reflect the removal. This keeps the queue focused on future work only.

**Maintenance check (full path only)**:

| Condition | Action |
|-----------|--------|
| `decision_type: "emergency"` | → Jump to MAINTENANCE PATH |
| `decision_type: "scheduled"` and due this sprint | Offer maintenance option. If `prediction.confidence` is LOW (read from [Maintenance-Tracking] — the scheduler writes confidence there, not into [Maintenance-Decision]): "⚠️ Maintenance scheduled (LOW confidence) — recommend health-diagnostic first." |
| `decision_type: "scheduled"` and NOT due | Note: "Next maintenance: Sprint {N} ({prediction.confidence})". If LOW: add "— verify with health-diagnostic" |
| User explicitly requests maintenance sprint | → Jump to MAINTENANCE PATH |
| Otherwise | → STEP 1 |

Diagnostic path: skip maintenance check → STEP 2.

---

### STEP 1: Assess Landscape (full path only)

Three things to extract and present concisely:

**A. Project Context**

From project-state.md, extract and display compactly in one block:
- Current phase name, objective, and completion %
- Phase handoff contracts (`entry`, `exit`, `depends_on`, `handoff_to`) if present — surface any `entry` or `depends_on` conditions as potential blockers when planning near a phase boundary
- MVP progress: primary deliverables complete vs total. If MVP < 50% and current phase > 2, flag — MVP-linked issues need priority boost
- Active risks and timeline constraints (only if approaching deadlines or high-probability)
- `[NEXT_PHASE_NOTES]`: immediate priorities, watch items, key learnings
- If phase completion > 80%, note next-phase setup work may be worth including

**B. Dependency Chains**

Trace `blocks`/`blocked_by` relationships across registry. 

Identify:
- The critical path
- Any chain leading to a high-impact or MVP-linked issue

Display chains of length 2+:
```
🔗 Dependency chains:
   ISS-040 → ISS-055 → ISS-068 (3 sprints min)
   Critical path: ISS-040 chain (longest, leads to MVP deliverable)
```
Issues on critical path get priority boost in STEP 3.

**C. Candidate Issues**

An issue is a candidate when ALL true: status Open or In Progress, not blocked (or all blockers resolved), target_sprint empty or "TBD".

Display grouped by selection tier:

```
📋 Candidates: {count} issues

Tier 1 — Must do:
  • ISS-XXX: {title} (Critical, C:{N}) — {reason}

Tier 2 — Should do:
  • ISS-AAA: {title} (High impact, C:{N}) — {reason}

Tier 3 — Could do:
  • ISS-CCC: {title} (Medium, C:{N})
```

**Selection tier criteria:**

| Tier | Criteria |
|------|----------|
| 1 — Must do | Critical priority, in-progress issues (context continuity), high unblocking value (frees 2+ issues), critical path position |
| 2 — Should do | High impact / low complexity (best ROI), MVP-linked (boost when MVP < 80%), phase-aligned or `[NEXT_PHASE_NOTES]` priorities, risk-mitigating |
| 3 — Could do | Medium priority improvements, future-proofing, not phase-aligned but still valuable |

Freshly unblocked issues carry deferred value — give attention. At equal priority, bugs before features (defects erode existing value).

### STEP 1D: Seed Review & Grooming

Scan `.nexus/seeds/` for seed files (Glob `SEED-*.md`). If no seed files found: "🌱 Seeds: none." → continue to STEP 1E.

**One read per seed, four verdict lanes out.** Read each seed file once and evaluate it against all four lanes below. Lane A is the judgment this step has always made; B, C, and D ride the same read. Nothing here opens a file this step was not already opening.

| Lane | Question | Verdict |
|---|---|---|
| **A — Triggered** | Does `## Trigger` match current state? | TRIGGERED → `[Promote to issue / Keep dormant / Discard]` |
| **B — Prunable** | Does `## Prune When` match current state? | PRUNABLE → `[Discard / Keep dormant / Promote anyway]` |
| **C — References** | Do the tokens in `## References` still resolve? | premise-dissolution CANDIDATE — surfaced, never auto-discarded |
| **D — Missing condition** | Is `## Prune When` absent? | MISSING-CONDITION report line |

A seed that fires no lane is dormant and healthy: counted in the summary line, not presented.

**When A and B both fire on the same seed**, surface it **once** with both reasons — not twice in two blocks. The seed's moment to be built and its moment to die arrived together; that is a genuine decision for the user, not a bug:

```
🌱🪦 SEED-{NNN}: {title} — TRIGGERED and PRUNABLE
  Trigger:    "{condition}" → MATCHED: {what matched}
  Prune when: "{condition}" → MET: {what met it}
```

Offer the union once via `AskUserQuestion tool`: `[Promote to issue / Discard / Keep dormant]`. This block **replaces** both lane presentations for that seed — do not re-present it in lane A or lane B.

---

#### A — Trigger lane

For each seed, evaluate its `## Trigger` section against current state:
- Issues closed in the previous sprint (from sprint-state [OBJECTIVES] completed)
- Patterns promoted or matured (from patterns-registry changes during the sprint)
- Project phase progression (from project-state current phase vs previous)
- Sprint count milestones (current sprint number)
- Any other condition described in the trigger text

Matching is **semantic** — the LLM reads the free-text trigger and judges whether current conditions satisfy it. No rigid taxonomy.

If seeds triggered, present each:

```
🌱 Triggered Seeds ({count}/{total})
───────────────────────────────────────
SEED-{NNN}: {title}
  Trigger: "{condition}" → MATCHED: {what matched}
  Idea: {description summary}
───────────────────────────────────────
```

**[T2: Balanced+Full ask | Streamlined: auto-recommend per seed, notify+log]** Per seed via `AskUserQuestion tool`: [Promote to issue / Keep dormant / Discard].

| Choice | Action |
|--------|--------|
| Promote to issue | Route through STEP 1D.5 (Adoption Gate). On PASS: `invoke /nexus-create-issue` in Assisted mode with seed content (title, description from Idea + user_pain + vs_existing_layers, context from Origin/References); after issue created, delete the seed file; new issue enters the registry and is considered in STEP 3 sprint planning. On HOLD/DISCARD: STEP 1D.5 annotates `## Adoption Attempts` on the SEED file; seed remains in `.nexus/seeds/`. |
| Keep dormant | No change — seed stays for future evaluation. |
| Discard | Delete the seed file. |

If any seeds were promoted, display as candidate addendum after the STEP 1D block — these won't appear in the STEP 1C list (1C ran before 1D) but are available for sprint planning in STEP 3:

```
🌱 Promoted from seeds (added to registry, consider in STEP 3):
  • ISS-{XXX}: {title} — {brief description from seed}
```

Seed processing model: when the user picks `[Promote to issue]` for a seed, immediately enter STEP 1D.5 for THAT seed (per-promotion-inline). After STEP 1D.5 resolves (either via create-issue + seed deletion, or seed annotation, or seed discard), return to the STEP 1D loop and process the next seed.

---

#### B — Prune-when lane

Evaluate `## Prune When` against current state by the same semantic read lane A uses. The section names an **observable event**; the judgment is "has that event happened?" — not "is this still interesting?". Keep the two apart: a seed can be perfectly interesting and still dead, and a seed whose author wrote a clean kill condition has already made this call for you.

If seeds are prunable, present each:

```
🪦 Prunable Seeds ({count}/{total})
───────────────────────────────────────
SEED-{NNN}: {title}
  Prune when: "{condition}" → MET: {what met it}
  Idea: {one-line summary}
───────────────────────────────────────
```

**[T2: Balanced+Full ask | Streamlined: auto-recommend per seed, notify+log]** Per seed via `AskUserQuestion tool`: [Discard / Keep dormant / Promote anyway].

| Choice | Action |
|--------|--------|
| Discard | Delete the seed file. The kill condition its own author wrote has fired — this is the disposal path working, not a call to agonize over. |
| Keep dormant | Seed stays — **annotate it** per the kept-candidate rule below, so it does not re-surface identically every sprint. |
| Promote anyway | The condition fired but the idea is worth building now. Route through STEP 1D.5 exactly as lane A does. |

**Kept-candidate annotation** (fires on `Keep dormant` from lane B, from the both-lanes-fired block, or on a CANDIDATE from lane C that the user keeps — every path where a surfaced seed stays in place). Append to the seed file, adding the section header if absent — modeled on the `## Adoption Attempts` convention, whose canonical format is defined in `references/adoption-gate.md` (Step 5). Distinct section, because a deferred prune is not a deferred adoption:

```
## Prune Deferrals
- {YYYY-MM-DD} (Sprint {NNN}): KEPT — {which lane fired and why the user kept it: prune-when met but "{reason}" | reference candidate "{token}" but "{reason}"}
```

Next sprint, read this section before presenting the same seed again: if the same lane fires for the same reason and the user already ruled on it, say so in the presentation (`previously kept {date}: "{reason}"`) rather than asking the identical question cold.

---

#### C — Reference-resolution check (two layers)

Resolve the tokens in each seed's `## References` against the live tree. A broken anchor is the fastest mechanical tell for premise dissolution — a seed pointing at a section deleted three sprints ago is arguing from a premise that no longer exists.

This mirrors the shape STEP 1D.5's Adoption Gate already uses on these same files: Layer 1 mechanical, Layer 2 LLM semantic.

**Layer 1 — form classifier.** A token is mechanically checkable when it is:
- a **repo path** — contains `/` and is not a `/nexus-` skill route (e.g. `.claude/hooks/nexus-context-stop-hook.sh`, `.nexus/memory/SCHEMA.md`)
- a **bare filename** ending `.md` / `.sh` / `.yaml` — resolve by name search anywhere in the tree

Check each with a single existence test. A token that resolves is finished and never reaches Layer 2. Everything else — skill routes, ISS/PAT/SEED ids, section anchors, prose references, external URLs — passes to Layer 2.

**Layer 2 — adjudication.** For each token Layer 1 could not resolve, judge which of these it is:
- it names something that **once existed and is now gone** → premise-dissolution CANDIDATE
- it names something that **was never meant to exist yet** — typically the seed's own proposal → not a finding
- it names a live referent under a **different form** — an ISS id written as a bare filename, a renamed section → not a finding

Only the first is a candidate. Surface candidates for the user's judgment; **never auto-discard on a reference miss.**

##### Worked examples (anchors for verdict consistency)

> **Case A — Layer 1 resolves.** SEED-003 `## References` lists `.claude/hooks/nexus-context-stop-hook.sh`.
> Layer 1: contains `/`, not a `/nexus-` route → repo path → existence check → present.
> **Verdict: resolved.** Never reaches Layer 2.
> *Why*: the mechanical layer is the whole check for well-formed paths; spending judgment here is what makes the lane expensive and skimmed.

> **Case B — Layer 1 misses, Layer 2 acquits.** SEED-021 `## References` lists `/nexus-create-agent`, and no such skill exists.
> Layer 1: `/nexus-` route → not mechanically checkable → Layer 2.
> Layer 2: this is the seed's own proposed Option C — a thing it argues *should* be built, not a thing that vanished.
> **Verdict: not a candidate.** The same acquittal covers form drift: SEED-010's `ISS-159.md` fails a bare-name search because the archived file carries a slug (`ISS-159-<slug>.md`), yet the referent is alive.
> *Why*: a judgment-free predicate would flag one of the healthiest seeds in the corpus, every sprint, forever. Nag-fatigue kills the lane faster than a missed candidate does.

> **Case C — Layer 2 finds a candidate.** (Retrospective: SEED-008, discarded at Sprint 107 organize.) Its `## References` pointed at a CLAUDE.md environment table that ISS-186 had deleted sprints earlier.
> Layer 1: section anchor → not mechanically checkable → Layer 2.
> Layer 2: the table demonstrably existed and was removed by a named issue — the seed's premise dissolved underneath it.
> **Verdict: premise-dissolution CANDIDATE.** Surface it; the user decides.
> *Why*: this is the failure mode the lane exists for — the seed still reads as sensible, and only its dead anchor gives it away.

Present candidates:

```
🔗 Premise-dissolution candidates ({count})
───────────────────────────────────────
SEED-{NNN}: {title}
  Unresolved: "{token}" — {Layer 2 finding: what it named, and what happened to it}
───────────────────────────────────────
```

**[T2: Balanced+Full ask | Streamlined: auto-recommend per seed, notify+log]** Per seed via `AskUserQuestion tool`: [Discard / Keep dormant / Update references]. `Keep dormant` writes the `## Prune Deferrals` annotation above. `Update references` patches the seed's `## References` to the live referent and leaves the seed in place.

---

#### D — Missing-condition report

Any seed with no `## Prune When` section gets its own report line. An un-prunable seed must be visible as un-prunable — silently treating it as not-prunable is how the corpus rotted in the first place:

```
⚠️ No kill condition ({count}): SEED-{NNN}, SEED-{NNN}
   These cannot be evaluated by lane B. Add a `## Prune When` section
   (format + grammar: `/nexus-plug-seed` STEP 3A) or discard.
```

Every seed planted after ISS-233 carries the section by construction — this report exists for seeds that predate it, for hand-written files, and as the standing check that the format has not quietly stopped being applied.

---

#### Summary line

When no lane fires for any seed, the entire step is one line:

```
🌱 Seeds: {N} dormant — none triggered, none prunable, all references resolve.
```

Otherwise, one line before the lane blocks:

```
🌱 Seeds: {total} total — {triggered} triggered, {prunable} prunable, {candidates} premise-dissolution candidates, {missing} without a kill condition, {dormant} dormant.
```

After all seeds are processed, continue to STEP 1E.

---

### STEP 1D.5: Adoption Gate (Seed Promotion)

Runs **per-seed, inline** when the user picked `[Promote to issue]` for that seed in STEP 1D. Fires once per promoted seed, before the `/nexus-create-issue` invocation. **Skip entirely if no `[Promote to issue]` was picked** — this is the conditional load gate (the "no Promote" path never loads the reference).

**Purpose**: Critical-source-evaluation (5-step structure in references/adoption-gate.md) at the seed→issue promotion boundary — moves rigorous `adapt-not-adopt` evaluation up to where cost-of-being-wrong rises sharply, sparing sprint budget and Analysis context on weak seeds that don't survive a structured comparison against existing NEXUS safety layers.

📂 **Full gate procedure → `references/adoption-gate.md` [Section: Adoption-Gate]** — load when a seed is promoted. The reference carries the complete 5-step gate verbatim: **Step 1** Identify source (+ prior `## Adoption Attempts` history block) · **Step 2** Extract concepts (`user_pain` / `vs_existing_layers` via two `AskUserQuestion` prompts; both non-empty to clear Layer 1) · **Step 3** Validate relevance (Layer 1 mechanical hard-block incl. blacklist regex + Layer 2 LLM semantic soft-warning) · **Step 4** Decide action (PASS / HOLD / DISCARD verdict surfaces with their `AskUserQuestion` choices) · **Step 5** Implement cleanly (branch per verdict; `## Adoption Attempts` annotation format) · plus 3 Worked Examples (PASS / HOLD / DISCARD anchors).

---

After STEP 1D.5 completes for all promoted seeds, continue to STEP 1E.

---

### STEP 1E: Strategic-Pivot Cleanup Surface Check (full path only)

Fires when planning a sprint that follows a recent **strategic-pivot decision** — a project-wide directional change (capability dropped/added, target environment shifted, scope pivot). Detection signals: project-state `[NEXT_PHASE_NOTES]` or the previous sprint's `[DECISIONS]` reference "pivot", "drop", "removal cascade", or the current phase brief is the "polish/cleanup-after-pivot" type.

When triggered, scope review must cover **all artifact surfaces** — historically under-scoped relative to the code surface:

| Surface | Examples | In-scope when stale? |
|---|---|---|
| Code | `.claude/skills/`, `.claude/hooks/`, `.claude/agents/` | Yes — touched by default in cleanup waves |
| Structural | Templates, architecture references, registry schemas | Yes — touched by default |
| **Live-content** | Active ISS files (Description, Success Criteria, Notes & Context); project-state vision; active-state narrative fields | **Yes — historically missed** |
| Archived / historical | `.nexus/Sprints/**`, `.nexus/archived/**`, active-state historical narrative, `.nexus/Maintenance-cycles/**` | No — process artifacts, preserve per ISS-169 D1 |

If live-content surface has stale-premise hits, consider a dedicated cleanup ISS (precedent: ISS-197 Sprint 090 — ISS-file-content vocab refresh; ISS-193 — SKILL-file-content vocab refresh).

Reference: ISS-197 D3 scope precedent (extends ISS-169 D1 — live-content IN-scope; archived/historical OUT-of-scope).

After STEP 1E completes, continue to STEP 2.

---

### STEP 2: Evaluate Queue

Runs on BOTH paths — shared diagnostic and fix engine.

If queue empty: full path → "Queue empty" → STEP 3. Diagnostic → "No queue to evaluate" → stop.

#### A. Structural Validation

Check every planned sprint against these criteria:

| Check | Flag When |
|-------|-----------|
| Dependency ordering | A blocker is scheduled AFTER its dependent issue |
| Capacity balance | Any sprint overloaded (sprint's total complexity>12) or significantly underutilized (<5 when others near capacity) |
| Data consistency | Issues in queue but missing from registry (dangling), or registry target_sprint points to queue but issue not in planned_work (orphaned) |
| Priority alignment | High-priority or critical issues pushed to late sprints while earlier sprints have lower-priority work |

#### B. Change Detection

Compare queue against current state for staleness:

| Change Type | What to Check |
|-------------|---------------|
| New/changed issues | Issues reprioritized since the queue was built; High-priority newcomers not in any sprint |
| Blocker changes | Planned issues now blocked by something new; deferred issues now unblocked |
| Phase alignment | Project advanced to new phase but queue prioritizes old phase; MVP behind but queue doesn't prioritize MVP-linked; completed deliverable issues still queued |
| Mode fit | THEMED sprint where issues are now independent; MIXED sprint where remaining issues are tightly related |

#### C. Present Findings and Decide

Display findings concisely — actionable items only:

```
📋 Queue Evaluation

{if structural issues:}
Structural:
  ⚠️ {issue_id} (Sprint {N}) depends on {blocker_id} (Sprint {M}) — wrong order
  ⚠️ Sprint {N} overloaded: {X} complexity (target ~9)
  ⚠️ {issue_id} in queue but missing from registry
  ✓ Priority alignment OK

{if changes detected:}
Changes since last plan:
  • {issue_id} created (High priority) — not in queue
  • {issue_id} now resolved — {dependent_id} unblocked
  • Project now in Phase {N} — queue still prioritizes Phase {N-1}

{if nothing found:}
✓ Queue structure sound, no changes detected.
```

**Decision — diagnostic path:**

| Findings | Action |
|----------|--------|
| No issues | "Queue healthy, no action needed." → STEP 5 |
| Issues found | Propose fixes (Fix Protocol below) → apply → STEP 5 |

**Decision — full path** — **[T2: Balanced+Full ask | Streamlined: auto-select best option, notify+log]** (via `AskUserQuestion tool`):

| Findings | Options |
|----------|---------|
| No issues, queue exists | Activate as planned / Pick different sprint / Full replan |
| Issues found | Fix and activate / Modify specific sprint / Full replan |
| Queue empty | → STEP 3 automatically |

"Activate as planned" and "Fix and activate" → STEP 4.
"Modify specific sprint" → user specifies changes, re-validate, → STEP 4.
"Full replan" → confirm discarding queue. Before STEP 3: clear `target_sprint` to `"TBD"` for all issues currently assigned to queued sprints (so they appear as candidates again). Then → STEP 3.
"Pick different sprint" → user selects which queued sprint to activate, → STEP 4.

#### Fix Protocol

1. Generate specific fixes for each problem found:
  For each problem found, generate a specific fix (swap sprint assignments, move issues between sprints, remove dangling references, inject high-priority issues, recommend mode change). Present the fix package with before/after sprint compositions.

  **Cascade principle**: When inserting a higher-priority issue into a full sprint, bump the lowest-value issue to the next sprint. If that overflows too, cascade forward. Last displaced issue returns to unassigned pool. Re-check whether each affected sprint's mode fit after changes.

2. Present the fix package:
```
📋 Proposed Fixes

1. Move {issue_id} from Sprint {N} to Sprint {M} (fixes dependency order)
2. Move {issue_id} from Sprint {N} to Sprint {M} (rebalances capacity: {N}→{X}, {M}→{Y})
3. Remove dangling reference to {issue_id} from Sprint {N}
4. Add {issue_id} (High, C:{X}) to Sprint {N} (new high-priority, displaces {issue_id} to {N+1})

After fixes:
  Sprint {N}: {count} issues, {complexity} complexity
  Sprint {M}: {count} issues, {complexity} complexity
```

3. **[T2: Balanced+Full ask | Streamlined: auto-approve if no structural issues, notify]** User approves via `AskUserQuestion tool`: Approve all | Adjust | Cancel.

4. Apply fixes atomically: patch issues-registry.yaml (target_sprint) and sprint-queue.md (planned_work, total_complexity, mode). If fixes affect current sprint, also patch sprint-state.md [OBJECTIVES]. All. Verify after writing.

---

### STEP 3: Plan Sprints (full path only)

Plan up to 3 sprints sequentially (default). Up to 5 if user requests — note plans beyond N+2 are increasingly speculative.

**For each sprint:**

1. **Select anchor** — highest-value unallocated issue. Value = priority × impact × unblocking potential. Boost for: phase priorities, MVP-linked (when MVP < 80%), critical path, freshly unblocked.

2. **Select companions** — issues clustering naturally with the anchor:

| Signal Strength | Indicators |
|-----------------|------------|
| Strong (likely same sprint) | Shared theme/scope, overlapping files, direct dependencies, same deliverable, phase/MVP aligned |
| Moderate | Same type, related domain, sequential work |
| Not enough alone | Same priority or complexity only |

3. **Determine mode:**

| Mode | When |
|------|------|
| THEMED | High coherence — same domain/theme, tightly related (2-3 issues) |
| MIXED | Diverse — different domains, variety, risk distribution (2-3 issues) |
| DEDICATED | Single complex issue — complexity 4-5, large scope (1 issue) |

4. **Check capacity** — total complexity around 9 (guidance, not rigid).

5. **Present proposal:**
```
📋 Sprint {N} Proposal
Mode: {THEMED|MIXED|DEDICATED} — {brief focus}

Issues:
  • ISS-XXX: {title} (P:{priority}, C:{complexity}) — {why selected}
  • ISS-YYY: {title} (P:{priority}, C:{complexity}) — {why selected}

Total Complexity: {sum}/~9
Rationale: {why these together, why this mode}
```
**[T2: Balanced+Full ask | Streamlined: auto-accept if capacity ok, notify]** Offer via `AskUserQuestion tool`: Accept | Adjust | Skip an issue.

If adjust: user specifies changes. Re-validate complexity, re-present.
After acceptance, repeat for the next sprint.

After all sprints approved → STEP 3.5.

---

### STEP 3.5: Dependency Validation & Parallelization Flagging (full path only)

Runs after sprint composition is approved but BEFORE finalize-write. Ensures the dependency graph across ALL planned sprints (active + queued) is internally consistent and surfaces parallelization opportunities per wave.

**A — Invoke lightweight dependency validation**

Call `nexus-issue-validation` in deps-only mode (see its Lightweight Dependency-Only Mode section). Pass the full active registry — validation computes cycle/missing-ref/wave results for the entire issue graph, not just this-sprint issues. Capture return structure:

```yaml
deps_result:
  cycles: [...]
  missing_refs: [...]
  waves: [...]
  clean: true|false
```

**B — On cycles OR missing-refs found: block finalize**

**[T2: Balanced+Full ask | Streamlined: surface + auto-block, notify]**

Display findings:
```
⚠️ Dependency Graph Issues — blocks sprint finalization

CYCLES ({cycle_count}):
  • ISS-XXX → ISS-YYY → ISS-XXX

MISSING REFS ({missing_count}):
  • ISS-AAA.blocked_by contains ISS-ZZZ (not in registry)

These must be resolved before the sprint can be created.
Options: [Fix via /nexus-update-issue / Defer issues to later sprint / Cancel sprint creation]
```

Via `AskUserQuestion tool`: Fix now | Defer blocking issues | Cancel.

- **Fix now** — open `/nexus-update-issue` for each affected issue, user patches `blocked_by`/`blocks`. After ALL fixes applied (verified by reading affected registry entries back), **re-invoke validation from STEP 3.5.A** (loop). Iteration cap: 5 passes — if graph still dirty after 5 user-correction passes, escalate to Cancel and recommend `/nexus-issue-validation` full diagnostic. When clean → C.
- **Defer blocking issues** — remove affected issues from this sprint's composition, return them to `target_sprint: "TBD"`. Re-validate. If still unclean, escalate to Cancel.
- **Cancel** — abort finalize. Return user to STEP 3 for replanning, or end.

⛔ GATE: cannot proceed to STEP 4 while cycles or missing-refs remain in the graph.

**C — On clean graph: consume wave data + flag parallelization**

Wave data returned by validation covers ALL active issues. Filter to issues planned in this sprint. For each wave with 2+ issues in this sprint:

1. Read `scope_files` for each issue in the wave (from registry).
2. Pairwise compare — two issues are flagged `parallelizable` if their `scope_files` sets are DISJOINT (no overlap) AND both belong to the same wave.
3. Issues with empty `scope_files` are skipped (cannot prove disjointness).

Display in planning view (merged into STEP 3's sprint proposal presentation, shown again here for confirmation):

```
🔄 Dependency-Aware Sprint View

Sprint {N} — Wave distribution:
  Wave 1: ISS-086 (scope: .claude/hooks/)
          ISS-141 (scope: .claude/skills/nexus-issue-validation/)
          ↪ parallelizable (disjoint scopes)
  Wave 2: ISS-087 (blocked by ISS-086)

Cross-sprint dependency preview:
  Sprint {N+1} Wave 3: ISS-095 (blocked by ISS-087)
```

Forward-compatible annotation: parallelization flags are informational now; consumed by future batch/sub-agent dispatch.

**D — Confirm and proceed**

**[T3: Full ask | Balanced: notify | Streamlined: silent]**

> Dependencies validated: graph clean, {parallelizable_pairs} parallelization opportunities flagged.
> Proceed to sprint creation? [Y / back to STEP 3]

On Y → STEP 4. On back → STEP 3 (user can adjust composition knowing wave structure).

> **Mental note**: Dependency validation done. Cycles: {N}, missing: {N}, parallel pairs: {N}. If checkpoint → save deps_result to continue_with.

---

### STEP 4: Confirm & Create

**Diagnostic path**: If fixes were applied in STEP 2C, writes already happened. Skip to STEP 5.

**Full path**:

**A. Display final plan:** 
```
✅ Sprint Plan

Sprint {N}: {MODE} — {issue_list} (C:{total})
Sprint {N+1}: {MODE} — {issue_list} (C:{total})
Sprint {N+2}: {MODE} — {issue_list} (C:{total})

Create Sprint {N} and queue the rest?
```

**B. User confirms** — **[T1: all levels ask]** via `AskUserQuestion tool`.

⛔ GATE: User must explicitly approve before any writes.

**C. Create sprint-state.md**

Load sprint-state-template.md for structure reference. Populate using these value sources:

| Section | Value Source |
|---------|-------------|
| Metadata _updated: {now}, _sprint: {N}, _status: in_progress, _mode: {MODE}, _title: {theme}, _sprint_type: normal, _project_lifecycle: {carry forward from previous sprint-state}, _project_type: {carry forward from previous sprint-state, or read from project-state.md _project_type if first sprint} | From approved plan |
| [PROJECT_BRIEF] | **Carry forward from previous sprint-state** (preserve all fields unchanged). If first sprint: populate from project-state.md (title, type, domain, vision, current_phase, constitution, mvp_minimum, active_risks, `_self_hosting` if present). Update `current_phase` from project-state `_current_phase` if it changed since last sprint. |
| [CONVERSATION] conversation_number | `0` (Conv 0 = planning), all rest counters at 0 |
| [CONVERSATION] current_focus | First issue's phase: A<4 → analysis, A≥4 I<4 → implementation, I≥4 → evaluation |
| [BOOTSTRAP] continue_with | First issue with WHAT/WHY/CONTEXT |
| [BOOTSTRAP] files_to_load | ISS file for first sprint issue; ALL ISS files if THEMED mode|
| [OBJECTIVES] in_progress | First issue with A:I:E scores from registry |
| [OBJECTIVES] planned | Remaining issues with priority and complexity |
| All other sections | Empty/default per template |

Write.

**Defer carry-forward**: The previous sprint's sprint-state is already in memory from bootstrap. Check its `[EXPERIENCE_CAPTURE]` (`[SYSTEM_ISSUES]` and `[BEHAVIORAL_INSIGHTS]`) for deferred entries. If deferred entries exist, patch them into the new sprint-state's `[EXPERIENCE_CAPTURE]` sections. These are entries the user chose to defer during close-sprint STEP 6 — they need another review cycle.

**D. Update system files** (all):

1. **issues-registry.yaml** — patch `target_sprint` for each Sprint N issue

2. **project-state.md — phase mapping for ad-hoc issues**: For each issue selected for this sprint, check if it appears in any phase's `issues_planned` in project-state `[PROJECT_PHASES]`. If NOT (ad-hoc issue created during sprint work, not from generate-mvp):
   - Infer target phase from issue type, scope, and current project phase
   - Briefly confirm: "ISS-{XXX} '{title}' is not mapped to any project phase. Assign to {inferred_phase}? [Y / Different phase]"
   - Patch that phase's `issues_planned` array to include the issue ID
   - If issue clearly serves a deliverable, also patch `[DELIVERABLES].{deliverable}.issue_refs`
   This ensures update-state phase completion calculations include ALL work, not just generate-mvp's original plan.

3. **sprint-queue.md** — Sprint N as Active, remaining sprints as Queued under `## Queued Sprints` — every sprint block carries the full field set the template's Active-Sprint example defines: id, mode, focus, status, priority, planned_work, total_complexity, rationale, dependencies, notes (`dependencies: - None` / `notes: ""` when nothing applies). Update `## Issue Dependency Map`: write `critical_chains` from STEP 1B dependency analysis (chains of length 2+ with reason and scheduled sprint). Update `## Sprint Planning Summary`: patch `current_sprint`, `next_sprint`, `total_planned_sprints`, `total_issues_scheduled`. Load sprint-queue-template.md for structure reference if needed.
4. **project-state.md** — patch `current_sprint` in `[PROGRESS_OVERVIEW]`
5. **system-state.md** — clear `[Maintenance-Decision]` fully: all fields blanked (`decision_type: "none"`, timestamps and details empty). Stale values cause false reads on replanning.
6. **Create folder**: `.nexus/Sprints/{N}/` — verify path resolves to `{project_root}/.nexus/Sprints/{N}/`. After creation, write a `.keep` file inside and `Read tool` on it to confirm the directory exists at the correct path. If path is wrong (missing `.nexus/`), delete and recreate.

**E. Verify** all writes applied correctly. If any write fails: report which succeeded and which failed. Don't rollback successful writes — partial state is recoverable.

**F. Commit planning changes** (full path)

organize-sprint runs as a standalone **Planning conversation (Conv 0)** that ends by handing off to the next conversation — there is **no closing checkpoint** (unlike Work conversations, which end via `/nexus-checkpoint`, and sprint closure, which commits in `/nexus-close-sprint`). Without this step the freshly created sprint-state plus the registry / sprint-queue / project-state patches stay **uncommitted** until the next work conversation's checkpoint, leaving the planning boundary unprotected in git history.

Commit all planning writes now (project-wide, per CLAUDE.md Backup Strategy):

```
git add -A && git commit -m "nexus: organize Sprint {N} — {MODE} {title} ({issue_count} issues, C:{total})"
```

Follow the project's commit-message conventions (e.g. the Co-Authored-By trailer) per the harness. Commit to the working branch (`main` for the self-hosting NEXUS meta-project — consistent with every checkpoint/closure commit). If the working tree is clean (resumption re-run where writes were already committed), skip silently.

---

### STEP 5: Report

**Diagnostic path:**
```
{if no issues were found:}
✅ Queue Health: Sound
No structural issues or changes detected. Queue ready for execution.

{if fixes were applied:}
✅ Queue Fixes Applied

  • {fix_1 summary}
  • {fix_2 summary}

Updated: ✓ issues-registry.yaml ✓ sprint-queue.md

Queue ready for execution.
```

**Full path:**
```
✅ Sprint {N} Created

Mode: {MODE} | Title: {title}
Issues: {count} ({total_complexity} complexity)
  • ISS-XXX: {title}
  • ISS-YYY: {title}

{if queued}: Planned ahead:
  Sprint {N+1}: {MODE} — {summary}

Sprint organization complete. Begin work in the next conversation.
```

---

### MAINTENANCE PATH (full path only)

Branch from STEP 0 when maintenance sprint is triggered.

**A. Confirm** — **[T2: Balanced+Full ask | Streamlined: auto-proceed if emergency, ask for scheduled]** display trigger reason. Ask via `AskUserQuestion tool`: proceed with maintenance sprint or normal planning?

If declined → update deferred_debt in system-state.md [Maintenance-Tracking]:
- Increment `deferral_count + 1`
- Set `last_deferral_sprint: {current_sprint}`
- Estimate `accumulated_degradation += (100 - current_health) × 0.1`
- Update `urgency` based on deferral_count: 1→low, 2→medium, 3+→high
- Append to `reasons`: `{sprint: {N}, reason: "User chose normal sprint over scheduled maintenance"}`

Then → STEP 1 for normal planning.

**B. Determine tier and operations:**

| Source | Action |
|--------|--------|
| From maintenance-scheduler decision | Use tier and operations from `[Maintenance-Decision]` |
| From user request | Invoke `/nexus-maintain` — delegate tier selection |

**C. Create sprint-state.md** — same as STEP 4C but with:
- `_mode: DEDICATED`, `_title: "Maintenance Sprint - {tier} tier"`, `_sprint_type: maintenance`
- `current_focus: maintenance` (triggers /nexus-maintain at boot)
- `continue_with:` references tier and operations
- `[OBJECTIVES]`: empty (maintenance works through operations, not issues)

**D. Update system files** — same as STEP 4D: sprint-queue (active, mode DEDICATED, focus "maintenance"), project-state (current_sprint), system-state (clear decision).

**E. Report:**
```
✅ Maintenance Sprint {N} Created
Mode: DEDICATED | Tier: {tier}
Operations: {list}
Maintenance begins next conversation (/nexus-maintain loads at boot).
```

---

## Gate Reference

| Gate | Step | Tier | Full | Balanced | Streamlined |
|---|---|---|---|---|---|
| Adoption gate (seed promotion) | STEP 1D.5 | T2 | Ask + rec | Ask + rec | Auto-block hard-fail; ask on soft-warning; notify |
| Queue decision (full path) | STEP 2C | T2 | Ask | Ask | Auto-select best option, notify+log |
| Fix protocol approval | STEP 2C Fix | T2 | Ask | Ask | Auto-approve if no structural issues, notify |
| Per-sprint proposal | STEP 3 | T2 | Ask | Ask | Auto-accept if capacity ok, notify |
| Dependency blockers | STEP 3.5 | T2 | Ask + rec | Ask + rec | Surface + auto-block, notify |
| Proceed after deps clean | STEP 3.5 | T3 | Ask | Notify | Silent |
| Pre-write confirmation | STEP 4B | T1 | Ask | Ask | Ask |
| Maintenance confirm | MAINT A | T2 | Ask | Ask | Auto-proceed if emergency, ask for scheduled |

---

## End-of-Workflow Checklist (full path)

Before STEP 5 report, verify:

- [ ] Dependency validation ran clean or blockers resolved (STEP 3.5)
- [ ] Sprint-state.md created with correct metadata, [PROJECT_BRIEF], [OBJECTIVES] (STEP 4C)
- [ ] Deferred experience entries carried forward from previous sprint (STEP 4C)
- [ ] issues-registry target_sprint patched for all selected issues (STEP 4D.1)
- [ ] Ad-hoc issues mapped to project phases (STEP 4D.2)
- [ ] Sprint-queue.md updated — active + queued sprints, dependency map, summary (STEP 4D.3)
- [ ] Project-state current_sprint updated (STEP 4D.4)
- [ ] System-state maintenance decision cleared (STEP 4D.5)
- [ ] Sprint folder created and verified (STEP 4D.6)
- [ ] All writes verified on disk (STEP 4E)
- [ ] Planning changes committed to git (STEP 4F) — no closing checkpoint runs after organize

---

## Error Recovery

| Problem | Recovery |
|---|---|
| sprint-state.md write fails | Retry. If retry fails, provide field values for manual creation. |
| issues-registry patch fails | Retry with broader Edit context. Report which issues need manual target_sprint. |
| sprint-queue.md patch fails | Rebuild queue section from approved plan and retry. |
| Sprint folder creation fails | Try alternative path. If still fails, note for manual creation. |
| Maintenance-scheduler fails | Skip maintenance check. Note in report. Proceed with normal planning. |
| Partial completion (interrupted) | Resumption detection in STEP 0 identifies completed steps. Re-run safely — patches are idempotent. |
