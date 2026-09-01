---
name: nexus-issue-validation
description: Validate issue data accuracy and consistency
disable-model-invocation: true
---
*Version: 2.6.0 | Date: 2026-08-26 | Sprint: 111*

# Issue Validation

**Flow**: Load → Status Check → Scope Files → Template Conformance → Priority → Deliverables → Project-State → [Scan boundary] → Propose fixes → [T2: approve] → Apply → [T2: Deep Validation (Comprehensive)] → Report

Six registry-level validation checks across all active issues, plus a template-conformance check that validates ISS files against the template they were scaffolded from (STEP 2b — the direction the registry checks cannot see), plus optional deep ISS-level validation for Comprehensive maintenance tier. Detect and propose — never auto-fix.

Severity levels: CRITICAL (score/status mismatches — data integrity), IMPORTANT (missing evidence, scope issues, alignment drift, unmapped issues), MINOR (priority inversions, deliverable gaps, counter drift).

---

### Posture (Verification-Class Core VC-1)

This skill runs **adversarial by default**. I assume the issue data has an inconsistency until the checks prove otherwise — a "✅ all checks passed" / "no findings" report is *earned* by stating what was examined (issue count × checks run), never reached by the mere absence of anything that surfaced. I challenge my own clean reports rather than confirming them.

Not complexity-conditional, and not gated on issue count: a small or recently-validated registry gets the same adversarial scan — low finding-counts are exactly where a false-empty report slips through. (operation-skill-template §Discipline Enforcement Layer → Verification-Class Core.)

---

### STEP 0: Load Context

**A** — Read `.nexus/active/registries/issues-registry.yaml` (memory-first). Extract all ISS entries with: scores (analyzed, implemented, evaluated), status, blocked_by, blocks, scope_files, priority.

**B** — Read `.nexus/active/states/project-state.md` — extract [DELIVERABLES] issue_refs, [PROJECT_PHASES] issues_planned and completion percentages, [PROGRESS_OVERVIEW] blocked_issues. If not found: note that deliverable and project-state checks (STEPs 4–5) will be skipped.

**C** — List `.nexus/issues/` directory for file existence reference.

**D** — Read `.nexus/active/states/sprint-queue.md` — for queue alignment check (STEP 5C). If not found: note that queue alignment check will be skipped.

Display:

```
🔍 Issue Validation Starting...

Checks: Status, Scope Files, Priority, Dep-Integrity (cycles/missing-refs/waves), Deliverables, Project-State
Deep Validation: Available (Comprehensive tier, T2 gate)
Scope: {n} active issues, {n} deliverables
{if skipped checks}: ⚠️ Skipping: {list}
```

---

### STEP 1: Status Consistency Check

**Resolved issues** must have: analyzed ≥ 4 AND implemented ≥ 4 AND evaluated ≥ 4, plus [Section: Closure] with Resolution content (not just placeholder). Score mismatch = CRITICAL (revert status to In-Progress OR complete missing phases). Missing closure = IMPORTANT (recommend /nexus-close-issue).

**In-Progress issues** should have at least one score > 1 (work has started). All scores = 1 with In-Progress status = MINOR (revert to Open OR update scores).

**Open issues with all scores ≥ 4** should not still be Open — likely completed but never formally closed. All three scores ≥ 4 with status Open = IMPORTANT (recommend status update or /nexus-close-issue).

Display:

```
📊 Status Consistency:
Resolved: {n} checked — {pass} OK, {fail} findings
In-Progress: {n} checked — {pass} OK, {fail} findings
Open (high scores): {n} flagged — scores ≥ 4 but status still Open
```

> **Mental note**: Status check done. {n} findings. If checkpoint → save findings to continue_with.

---

### STEP 2: Scope File Existence Check

For each issue with non-empty scope_files: verify each listed file exists via Glob or Read tool. Missing file = IMPORTANT (remove from scope_files OR correct path). File found at a different path = MINOR (update path).

Display:

```
📁 Scope Files:
Issues with scope_files: {n} | Files checked: {total}
Found: {found} | Missing: {missing} | Path issues: {path}
```

---

### STEP 2b: Template Conformance Check

Every check above validates an issue against the **registry**. This one validates ISS files against the **template they were scaffolded from** — the direction nothing else covers, and the one an mtime comparison cannot express at all. A template corrected today leaves every file created before that correction holding the old shape, and nothing ever reads them again.

Declared as edges **E-01** and **E-02** in `.nexus/active/derivations.yaml`. Run both: they are one edge *pair*, not two independent checks.

**E-01 — guidance-comment conformance** (complex ISS files, complexity ≥ 3):

- **Derive the threshold from the template at run time.** Count `<!-- GUIDANCE` markers inside `issue-specification.md`'s ISS File Template section, anchored on its literal headings (`### ISS File Template` … `### Section Reference`), and flag files below half that count. **Never hardcode the number, and never anchor on line numbers** — a line-number anchor is itself a hand-maintained derived copy, i.e. this check reproducing the defect it exists to catch.
- Report per file as `absent` (zero markers) or **`PARTIAL`** (some, but under threshold). The partial class is not cosmetic: a zero/non-zero predicate calls a C:4 file carrying **one** guidance comment against a 28 bound fully conforming.

**E-02 — post-port residue** (all ISS files): the ISS template dropped its pre-port `Build.md` boilerplate; files scaffolded before that still carry it.

- E-02 is **E-01's judgment-shaped companion, not a separate check.** E-01 counts guidance *presence* and is structurally incapable of seeing guidance that is present but **wrong**: `ISS-087/100/101/116` each carry 25–26 comments — sailing past E-01's threshold — and two stale `Build.md` references **inside those very comments**. Neither predicate certifies this corpus alone.
- **Classify every hit; never demand zero.** The token appears in files that legitimately *document* the defect, so hits are split `[RESIDUE]` (inside a GUIDANCE comment — a real finding) vs `[LIVE HOMONYM]` (prose describing the instance). An exit criterion of *"returns 0"* here is satisfiable only by corrupting a correct file (📐 PAT-142). Counts are re-derived at read time and never committed as a figure — ISS-240's own homonym count moved 2 → 8 purely by being documented.

**Verdict** — both report the pair with the unit named:

| Condition | Verdict |
|---|---|
| Corpus read | `FILLED: {findings} findings / {bound} bound ({unit}) / {candidates} candidates ({unit})` |
| Template unreadable, or its guidance set parses to zero | **`ESCALATED: bound 0`** — the threshold could not be derived, and a derived check with no derivable threshold must not certify |
| Zero ISS files matched | **`ESCALATED: candidates 0`** — an empty candidate set is a wrong path or a real finding and the check cannot tell which |
| Source template still carries the removed token (E-02) | **`ESCALATED`** — the correction never landed; validating instances against an uncorrected source is meaningless |

Severity: **IMPORTANT** (residue and absent-guidance), **MINOR** (partial conformance).

Findings here are **reported, not auto-fixed** — consistent with this skill's detect-and-propose posture, and because several are deliberately-preserved fixtures for other mechanisms. Check the owning issue before proposing a repair.

Executed at ISS-240 Phase 4.4 (Sprint 111): E-01 `FILLED: 11 findings / 20 bound (complex ISS files) / 20 candidates` — 10 `absent` + 1 `PARTIAL`; E-02 `FILLED: 4 findings / 23 bound (ISS files) / 23 candidates` — 4 RESIDUE + 1 LIVE HOMONYM, every hit dispositioned. False-positive arm: the five newest complex ISS files (24–27 comments each) were **not** flagged.

Display:

```
📐 Template Conformance:
E-01 guidance: {findings} findings / {bound} bound (complex ISS files) / {candidates} candidates
     {absent} absent, {partial} PARTIAL
E-02 residue:  {findings} findings / {bound} bound (ISS files) / {candidates} candidates
     {residue} RESIDUE, {homonym} LIVE HOMONYM (classified)
```

---

### STEP 3: Priority Logic Check

For each issue with non-empty blocked_by: compare blocker priority to dependent priority. Priority order: Critical > High > Medium > Low. A blocker with lower priority than its dependent = MINOR finding (priority inversion).

Display:

```
🔗 Priority Logic:
Dependency relationships: {total} | Aligned: {aligned} | Inversions: {inverted}
```

---

### STEP 3b: Dependency Graph Integrity

Three checks on the dependency graph built from registry `blocked_by`/`blocks` fields: (a) cycle detection, (b) missing-ref detection, (c) wave computation. Wave computation runs only when cycles=0 AND missing-refs=0 (clean-graph precondition — output is garbage otherwise).

**A — Cycle detection (DFS 3-color marking)**

Build adjacency list from `blocked_by`: for each issue X, `edges[X] = X.blocked_by` (X depends on every issue in its blocked_by). Traverse with 3-color DFS:

- **white** (unvisited), **gray** (on current path), **black** (fully processed)
- For each white node: DFS. Mark gray on entry, recurse into neighbors, mark black on exit.
- On encountering a gray neighbor during traversal: cycle detected. Extract cycle path by walking the recursion stack from the gray node back to the current node.
- Depth safeguard: max 20 levels — pathological graphs abort with a warning.

Each cycle reported once (dedupe by sorted node set). Severity: **CRITICAL** (blocks valid dependency ordering).

Finding format:
```
CYCLE (N issues): ISS-XXX → ISS-YYY → ISS-ZZZ → ISS-XXX
```

**B — Missing-ref detection**

For every `blocked_by` and `blocks` entry across all active issues, verify the referenced ISS ID exists in the registry. For each orphan reference, report the owning issue, the field, and the missing target.

Severity: **IMPORTANT** (stale reference signals stale graph but doesn't block execution).

Finding format:
```
MISSING REF: ISS-XXX.blocked_by contains ISS-YYY (not in registry)
MISSING REF: ISS-XXX.blocks contains ISS-ZZZ (not in registry)
```

**C — Wave computation (Kahn's topological sort)**

Precondition: runs only when A reported 0 cycles AND B reported 0 missing-refs.

Algorithm:
1. Wave 1 = all issues with empty `blocked_by` (no unresolved blockers).
2. Remove Wave 1 nodes from the graph. Wave 2 = remaining issues whose `blocked_by` entries are now all empty (i.e., all belonged to Wave 1).
3. Repeat: Wave N = remaining issues whose `blocked_by` entries all belong to waves 1..N-1.
4. Continue until graph is empty (or depth safeguard trips).

Closed/Resolved issues count as "satisfied" blockers — they contribute to Wave 1 eligibility of their dependents.

**Consumer note**: When waves are not computed (due to cycles OR missing-refs elsewhere in the graph), consumers see `waves: []` and `clean: false`. Consumers should surface this explicitly to the user ("wave data unavailable — graph not clean") rather than silently omitting parallelization info. A single stale reference in an unrelated legacy issue can suppress wave data for the entire graph; this is intentional (wave output is meaningful only over a validated graph) but should be visible to users.

Output structure (returned to consumers + displayed):
```yaml
waves:
  - wave: 1
    issues: [ISS-086, ISS-140, ISS-141]
  - wave: 2
    issues:
      - {id: ISS-087, blocked_by: [ISS-086]}
      - {id: ISS-138, blocked_by: [ISS-140]}
```

Display:
```
🔄 Dependency Graph Integrity:
Cycles: {cycle_count} | Missing refs: {missing_count}
{if clean}: Waves: {wave_count} (Wave 1: {n} issues, Wave 2: {n} issues, ...)
{if not clean}: Wave computation skipped — fix cycles/missing-refs first
```

Findings feed into STEP 7 aggregation using the standard severity vocabulary (CRITICAL/IMPORTANT/MINOR).

> **Mental note**: Graph integrity done. {cycle_count}C + {missing_count}M refs. Waves computed: {yes/no}. If checkpoint → save findings + wave data to continue_with.

---

### Lightweight Dependency-Only Mode (Consumer API)

**Invoked by**: `/nexus-organize-sprint` dependency-validation step (and any future consumer that needs dep integrity without full health diagnostic).

**Activation**: When invoked with flag `_mode: deps-only` (set by caller in sprint-state or passed inline), skip STEPs 1–3, 4, 5, 9. Run only:
1. STEP 0 (Load Context) — registry only, skip project-state/queue reads
2. STEP 3b (Dependency Graph Integrity) — all three checks
3. Return structured result

**Return structure** (for consumer consumption, not user display):
```yaml
deps_result:
  cycles: [{path: [ISS-X, ISS-Y, ISS-X]}, ...]   # empty if none
  missing_refs: [{owner: ISS-X, field: blocked_by, target: ISS-Y}, ...]
  waves: [{wave: 1, issues: [...]}, ...]          # empty if graph not clean
  clean: true|false                               # cycles==0 AND missing_refs==0
```

Consumers decide how to surface findings to the user — the lightweight mode does not present fixes or update health scores. Full validation workflow (STEPs 1–10) handles presentation.

---

### STEP 4: Deliverable Coverage Check

Skip if project-state was not loaded (noted in STEP 0B).

**A — Invalid refs.** For each deliverable's issue_refs: verify the ISS exists in the registry. Invalid ref = MINOR. Note: resolved *and archived* issues in refs are valid (completed work) — check `.nexus/archived/issues/` before calling a ref invalid; archived issues are no longer in the registry.

**B — Orphaned deliverables.** Deliverables with empty issue_refs = MINOR (no linked issues — may need supporting issues created). **Exception — dispositioned deliverables are resolved, not flagged**: if a deliverable carries a terminal `disposition:` field (e.g. `foundational-permanent`), it has an explicit decision on record and is NOT an orphan finding — exclude it from the orphaned count (report separately as `Dispositioned: {n}` if any). A `disposition: pending-backfill` is non-terminal — still flag it MINOR until the backfill lands. This is the terminal-disposition path: a recurring MINOR finding is *resolved by an explicit disposition*, not by ignoring it (ISS-198).

Display:

```
🎯 Deliverable Coverage:
Deliverables: {total} | Valid refs: {valid} | Invalid: {invalid} | Orphaned: {orphaned} | Dispositioned: {dispositioned}
```

**Convention — recurring MINOR findings need a terminal disposition (ISS-198, generalizable).** Any audit finding whose only resolutions are "create work" or "ignore" will re-fire every cycle without ever closing — the *M-consecutive-flag-without-decision* anti-pattern (orphaned deliverables flagged Sprints 074/080/087 before a decision was forced). The standing default: offer an explicit *terminal disposition* (an on-record decision that the finding is accepted/permanent) alongside fix-it and ignore, so the loop can close honestly rather than by suppression. Apply this shape whenever a MINOR/IMPORTANT finding here recurs across cycles.

---

### STEP 5: Project-State Cross-Validation

Skip if project-state was not loaded (noted in STEP 0B).

**A — Phase issues alignment.** For each phase in [PROJECT_PHASES]: verify issues_planned refs exist in the registry. Missing ref = IMPORTANT. Skip completed phases with empty issues_planned.

**B — Completion accuracy.** For phases with non-empty issues_planned: calculate actual completion as `round((resolved_count / total_planned) × 100)`, where `resolved_count` = refs in `issues_planned` whose registry status is Resolved **or** whose ISS file sits in `.nexus/archived/issues/` (archived issues leave the registry at /nexus-close-sprint STEP 5 — a registry-only count under-reports every sprint's own closures). Compare with recorded completion %. Drift > 5% = IMPORTANT (auto-fixable: recalculate from registry).

**C — Queue alignment.** Skip if sprint-queue not loaded (STEP 0D). Queue planned_work issues must exist in registry (orphan = IMPORTANT). Registry issues with target_sprint set should appear in queue (missing = MINOR).

**D — Blocked counter.** Count registry entries with non-empty blocked_by. Compare to [PROGRESS_OVERVIEW] blocked_issues. Mismatch = MINOR (auto-fixable).

**E — Unmapped issues.** For each open issue in registry: check if it appears in ANY project phase's issues_planned OR any deliverable's issue_refs. Issues not referenced anywhere in project-state = IMPORTANT — "ISS-XXX not mapped to any project phase or deliverable." Fix options: assign to phase, link to deliverable, or acknowledge as sprint-scoped (no project mapping needed).

Display:

```
🏗️ Project-State Cross-Validation:
Phase alignment: {checked} phases, {missing} missing refs
Completion accuracy: {accurate}/{total} phases accurate
Queue alignment: {orphans} orphans, {missing} missing from queue
Blocked counter: {status}
Unmapped issues: {count} issues not in any project phase/deliverable
```

> **Mental note**: All registry-level checks complete. {total} findings across 5 checks. If checkpoint → save all findings to continue_with.

---

### STEP 6: Initial Score Assessment
<!-- SCAN BOUNDARY — Agent contract stops here in Mode B -->

Calculate the health score from validation findings BEFORE any fixes are applied. This captures the actual degraded state for degradation velocity tracking.

**Formula**: `100 × (1 - weighted_findings / max_possible)`, where:
- weighted = (critical × 3) + (important × 2) + (minor × 1)
- max_possible = total_issues × checks_run × 3
- Clamp 0–100

**Persist to system-state**:
Update `system-state.md` [Health-Operations] issue_validation:

```yaml
issue_validation:
  score: {initial_score}
  last_run_sprint: {current_sprint}
```

This write happens BEFORE fixes so that /nexus-maintain can capture it as `op_initial_scores.issue_validation`. If fixes are applied later, STEP 10 overwrites with the final score.

Display: `📊 Initial Assessment: {initial_score}/100 (pre-fix baseline)`

**When run as scan agent (Mode B)**: Write initial_score to system-state (allowed — own health score field). Return structured results and stop here. Do not proceed to STEP 7. Agent skips STEP 9 (Deep Validation) — that runs only in main context. Agents must NOT write to project data (registries, ISS files, project-state, sprint-state).

```
## Issue Validation Scan Results
### Initial Score: {initial_score}/100
### Findings ({total_count})
#### CRITICAL ({count})
- ISS-{id}: {problem} — proposed fix: {action}
#### IMPORTANT ({count})
- ISS-{id}: {problem} — proposed fix: {action}
#### MINOR ({count})
- ISS-{id}: {problem} — proposed fix: {action}
### Checks Run: Status, Scope Files, Template Conformance (E-01/E-02), Priority, Dep-Integrity, Deliverables, Project-State
### Checks Skipped: Phase Evidence (main context only)
### Files Examined: {count}
```

> **Mental note**: Scan complete. Initial score: {initial_score}/100. Findings: {total} ({c}C, {i}I, {m}M). Scan boundary reached.

---

### STEP 7: Present Findings + Fix Selection

**[T2: Balanced+Full ask | Streamlined: auto-approve non-destructive, notify+log]**

Aggregate all findings from STEPs 1–5. Sort by severity: CRITICAL → IMPORTANT → MINOR.

If no findings — terminate as **FILLED**, not a bare "all passed" (Verification-Class Core VC-2). A clean result is a FILLED verdict carrying scan evidence — *what was checked across how many issues* — never a silent "healthy!":

```
✅ FILLED — all checks passed
   Examined: {n} active issues × {checks_run} checks (Status, Scope Files, Priority, Dep-Integrity, Deliverables, Project-State)
   Evidence anchor: {concrete proof the checks ran — e.g. "0 status mismatches across 14 issues; 23/23 scope files resolved; dep-graph clean, 4 waves computed"}
```

A "no findings" report without an evidence anchor for what was scanned is **not** a permitted terminal state — it is the documented false-empty failure mode (Sprint 084 ISS-184). A check genuinely not run (e.g. project-state absent per STEP 0B) is a justified **SKIP**, stated explicitly — not a silent omission. Then skip to STEP 9.

> **False-empty rationalization (VC-3) — pre-refute at this gate:**
> - "No findings, so everything's healthy." → Absence of *detected* problems ≠ verified-healthy. State what was examined (issue count × checks), or the report is unfounded.
> - "The registry parsed fine, so the data's consistent." → A clean parse ≠ a clean cross-validation. FILLED still requires the per-check evidence (status / scope / priority / deps / deliverables / project-state).

Display:

```
🔨 VALIDATION FINDINGS
════════════════════════════════════════

CRITICAL ({count}):
{N}. ISS-{id}: {problem}
    Fix: {action}

IMPORTANT ({count}):
{N}. ISS-{id}: {problem}
    Fix: {action}

MINOR ({count}):
{N}. ISS-{id}: {problem}
    Fix: {action}

════════════════════════════════════════
Total: {total} ({c}C, {i}I, {m}M)
```

Present via AskUserQuestion (multiSelect): list all findings as selectable options, grouped by severity. Include "Apply all" and "Skip all" as options.

---

### STEP 8: Apply Fixes

Collect user selection. Confirm the selected fixes before applying.

**Mode B note**: If findings came from scan agents, read each file section you need to patch before applying fixes.

Fix procedures by finding type:

| Finding | Fix Procedure |
|---------|--------------|
| Status/score mismatch | Revert status to In-Progress in registry. |
| Missing closure content | Recommend running /nexus-close-issue (cannot auto-generate). |
| Scope file missing | Remove file path from registry scope_files array. |
| Scope file wrong path | Update path in registry scope_files. |
| Priority inversion | AskUserQuestion: raise blocker priority, lower dependent, or ignore. |
| Invalid issue ref | Remove ref from project-state deliverable's issue_refs. |
| Orphaned deliverable | Offer: create supporting issues, mark accepted (set terminal `disposition:` — e.g. `foundational-permanent`), or ignore. The disposition path *terminally resolves* the flag; "ignore" leaves it to re-fire next cycle. |
| Phase issue missing | Offer: remove from issues_planned, create the issue, or ignore. |
| Completion drift | Recalculate from registry, patch project-state completion field. |
| Queue orphan | Offer: remove from queue, create the issue, or ignore. |
| Queue missing | Offer: add to queue sprint, clear target_sprint, or ignore. |
| Blocked counter drift | Recalculate from registry, patch project-state blocked_issues. |
| Unmapped issue | AskUserQuestion: assign to phase, link to deliverable, or acknowledge as sprint-scoped. |

**Tool guidance:** Use Edit tool with exact content from loaded file.

For two-place updates (score changes): update both registry and sprint-state [OBJECTIVES] per [Section: Two-Place-Update-Protocol].

After all fixes: verify each modified file by reading back patched entries.

Display:

```
✅ Fixes Applied: {success}/{selected}
{for each}: • Fix {n}: ✓ Applied
{if failures}: ❌ Failed: {n}: {reason}
```

> **Mental note**: Fixes applied: {applied}/{selected}. If checkpoint → save fix results to continue_with.

---

### STEP 9: Deep Issue Validation

**Comprehensive maintenance tier only.** Skip for Quick and Standard tiers.

**[T2: Balanced+Full ask | Streamlined: skip, notify+log]**

> "Run deep issue validation? Examines all open issues for relevance
> and accuracy against current system state. (~token-heavy, reads all ISS files)"
> [Yes / Skip]

If declined or non-Comprehensive tier: skip to STEP 10.

**For each issue with status Open or In-Progress:**

Read full ISS file. Then assess:

**A — Relevance check:**
- Use semantic judgment — search framework files, project deliverables, or relevant artifacts depending on project type
- Has the problem been addressed by another issue, sprint, or refactoring work?
- Is the described gap/feature still missing?
- → OBSOLETE: "ISS-XXX may be obsolete — {evidence}"

**B — Accuracy check:**
- Does the description match current system state?
- Have dependencies or context changed since creation?
- Are scope_files still the right targets?
- Has the approach or architecture evolved since the issue was written?
- → NEEDS UPDATE: "ISS-XXX description outdated — {what changed}"

**C — Phase evidence check:**
- For each score ≥ 4: verify the corresponding ISS section has content (not placeholder)
- analyzed ≥ 4 → [Section: Solution-Design] must have content
- implemented ≥ 4 → [Section: Implementation-Log] must have content
- evaluated ≥ 4 → [Section: Evaluation-Results] must have content
- → EVIDENCE GAP: "ISS-XXX scored {phase} {score}/5 but section is empty"
- Fix: lower score to 1 (two-place update) or flag for manual content addition

**D — Assess per issue:**

| Verdict | Recommendation |
|---|---|
| OBSOLETE | Close as Superseded or Rejected via /nexus-close-issue |
| NEEDS UPDATE | Specific description/scope/dependency changes |
| EVIDENCE GAP | Lower inflated score or add missing content |
| STILL VALID | Confirm — no action needed |

Present deep findings:

```
🔬 DEEP ISSUE VALIDATION
════════════════════════════════════════
Issues examined: {total}

OBSOLETE ({count}):
• ISS-{id}: {title} — {evidence}

NEEDS UPDATE ({count}):
• ISS-{id}: {title} — {what changed}

STILL VALID ({count}):
• ISS-{id}: {title} ✓

════════════════════════════════════════
```

Present via AskUserQuestion (multiSelect) per issue: [Update description / Close as obsolete / Keep as-is]. Apply approved changes.

> **Mental note**: Deep validation done. {obsolete} obsolete, {update} need update, {valid} valid. If checkpoint → save deep findings.

---

### End-of-Workflow Checklist

⛔ GATE: All must pass before displaying final report.

```
- [ ] All approved fixes from STEP 8 applied and verified on disk
- [ ] system-state [Health-Operations] issue_validation updated with final score + last_run_sprint
- [ ] system-state update verified by reading back
- [ ] Initial score captured (for Maintain degradation tracking)
- [ ] Deep validation findings acted on (if STEP 9 ran)
- [ ] Two-place updates completed for any score changes
```

---

### STEP 10: Report + Update Health

**A — Calculate final health score.** Formula: `100 × (1 - weighted_findings / max_possible)`. Use post-fix finding counts (resolved findings excluded). Include deep validation findings if STEP 9 ran.

If total_issues = 0 and no project-state findings: score = 100.

| Score | Status |
|-------|--------|
| 90–100 | EXCELLENT |
| 70–89 | GOOD |
| 50–69 | FAIR |
| 30–49 | NEEDS_ATTENTION |
| 0–29 | CRITICAL |

**B — Update system-state** [Health-Operations] issue_validation:

```yaml
issue_validation:
  score: {final_score}
  last_run_sprint: {current_sprint}
```

After write: verify by reading back the score.

**C — Display final report:**

```
🔍 ISSUE VALIDATION COMPLETE
════════════════════════════════════════
Sprint: {XXX} | Date: {YYYY-MM-DD}

📋 VALIDATION SUMMARY:
• Issues Validated: {count}
• Checks: Status, Scope, Priority, Dep-Integrity, Deliverables, Project-State
{if deep ran}: • Deep Validation: {examined} issues examined

📊 FINDINGS:
• Critical: {count} | Important: {count} | Minor: {count}
{if deep ran}: • Obsolete: {count} | Needs Update: {count}

🔄 DEPENDENCY GRAPH:
• Cycles: {cycle_count} | Missing refs: {missing_count}
{if clean}: • Waves: {wave_count}
  {for each wave}: Wave {N} ({count} issues): {ISS-IDs}
{if not clean}: • Wave computation deferred (fix cycles/missing-refs first)

🔧 FIXES: {applied}/{total}

📈 HEALTH:
• Score: {score}/100 ({status})
• Initial: {initial_score} → Final: {final_score} (delta: {+/-change})

{if unfixed}: ⚠️ Remaining: {count} unfixed findings
{if obsolete unfixed}: ⚠️ {count} potentially obsolete issues

💡 RECOMMENDATIONS:
{if critical unfixed}: • Address critical findings before next sprint
{if unmapped}: • Map unmapped issues to project phases
{if obsolete}: • Review and close obsolete issues

🧭 TERMINAL VERDICT (Verification-Class Core VC-2):
• FILLED: {checks passed with evidence — n issues × checks run}
• ESCALATED: {unfixed / deferred findings handed forward, or 0}
• SKIP: {checks not run — e.g. project-state / queue absent, or none}
════════════════════════════════════════
```

**[T3: Full ask | Balanced: notify | Streamlined: auto-save if fixes applied]**

**D — Report export.** Offer to save to `.nexus/Maintenance-cycles/{sprint}/issue-validation-report.md`.

> **Mental note**: Issue validation complete. Score: {final_score}/100 (delta: {change}). Deep validation: {ran/skipped}. If checkpoint → report done, operation complete.

---

## Error Recovery

| Problem | Recovery |
|---------|----------|
| ISS file not found for evidence/deep check | Flag as IMPORTANT finding (file missing for tracked issue). Continue with remaining. |
| ISS section empty or missing markers | Treat as empty — evidence not found. Record finding, continue. |
| Registry parse fails | Stop — registry integrity needed. Suggest registry-cleanup first. |
| Project-state not found | Skip STEPs 4–5. Run remaining checks normally. |
| Sprint-queue not found | Skip STEP 5C only. Run remaining checks. |
| Fix patch fails | Report failure. User can apply manually. Continue with remaining. |
| System-state update fails | Report score to user. Can be updated manually. |
| Deep validation search inconclusive | Note as "unclear" — don't flag as obsolete without evidence. |
