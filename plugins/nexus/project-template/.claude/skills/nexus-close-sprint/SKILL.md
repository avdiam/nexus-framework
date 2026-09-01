---
name: nexus-close-sprint
description: Orchestrate sprint closure — resolve issues, extract patterns, capture experience
disable-model-invocation: true
---
*Version: 2.10.0 | Date: 2026-08-20 | Sprint: 110*

# Close Sprint

**Flow**: Load → Assess completion → [T1: resolve issues] → Update patterns → [T2: process candidates] → Archive → [T2: process experience] → Unblock → Admin updates → [T1: verify+finalize] → Git tag

Close a sprint by resolving all issues, extracting pattern effectiveness, processing experience into preferences/issues, archiving, and updating administrative state. Called by Sprint-Closure protocol or user request.

**Step order rationale**: Pattern processing (STEPs 3-4) runs before archival (STEP 5) — ISS files must remain accessible for pattern context.

**Maintenance sprint shortcut**: When `_sprint_type: maintenance` in sprint-state, STEPs 1-7 are skipped entirely (no ISS issues, no patterns, no experience, no archival). Flow: STEP 0 → STEP 8 → STEP 9. Checked at STEP 0 — jump directly to STEP 8.

### STEP 0: Load Context

Silent step — load what's needed for the closure workflow.

From sprint-state.md (should be available from bootstrap), extract:
- `[OBJECTIVES]`: count issues and parse scores across planned, in_progress, completed
- `[PATTERNS_IN_USE]`: for effectiveness processing (STEP 3)
- `[CANDIDATES_PATTERNS]`: for pattern candidate processing (STEP 4)
- `[EXPERIENCE_CAPTURE]`: for processing (STEP 6)

if not in memory:
- `Read .nexus/active/registries/issues-registry.yaml` — status verification and unblocking
- `Read .nexus/issues/ISS-XXX.md` for all sprint issues (from all three objective lists) — needed repeatedly across closure, patterns, and candidates. Loading once here avoids repeated file reads later.

**Resumption check**: If re-running close-sprint after a partial closure (previous attempt failed mid-way), detect completed steps and skip them:

| Evidence | Meaning | Skip to |
|----------|---------|--------|
| Issues already in `.nexus/archived/issues/` | Archival completed | STEP 6 |
| `[PATTERNS_IN_USE]` all have final status (not "applied") | Pattern processing done | STEP 5 |
| `[EXPERIENCE_CAPTURE]` empty or only deferred entries | Experience processed | STEP 7 |
| `_closure_time` exists but `_status` ≠ `complete` | STEP 9B partially done | STEP 9 |
| Sprint-level Validate verdict already in [DECISIONS] this closure (entry tagged `[SPRINT-VALIDATE]`) | Trigger already ran this closure | Skip re-prompt; resume at STEP 1 (PASS path) or post-Validate branch as previously recorded |

When in doubt, re-run the step — individual operations (close-issue, archive-issue, update-pattern) handle already-completed items gracefully.

**Maintenance sprint detection**: Check `_sprint_type` from sprint-state. If `maintenance`: display "🛠️ Maintenance sprint — skipping ISS steps (1-7), proceeding to administrative updates." → Jump directly to STEP 8.

#### Sprint-Level Validate Trigger (end of STEP 0)

Runs after Load Context and Resumption Check, before STEP 1. Computes whether sprint-level Validate should fire — gives the closure flow one chance to catch cross-cutting issues per-issue Validates couldn't see (theme drift, surface drift, version stack, constitution holism).

Skip the trigger entirely when `_sprint_type: maintenance` (no ISS work to validate cross-issue).

**A. Compute trigger signals** from sprint-state `_mode` + issues-registry + sprint-state [FILES_MODIFIED]:

| `_mode` | Rule |
|---|---|
| `THEMED` | Trigger fires unconditionally (theme implies cross-cutting). Single-issue THEMED auto-skip with notify (rare misconfiguration). |
| `MIXED` | Compute three signals with single-edge thresholds (D4 from ISS-173). Trigger fires when **≥2 of 3** signals fire. |
| `DEDICATED` | Trigger never fires (single issue, no set). Skip silently. |

MIXED single-edge signals:

| Signal | Threshold | How to detect |
|---|---|---|
| Shared `scope_files` | ≥1 file overlap between any two sprint issues | Compare each pair of closed issues' `scope_files` in issues-registry |
| Shared modified skills | ≥1 skill in 2 issues' [FILES_MODIFIED] entries | Cross-reference per-conversation [FILES_MODIFIED] blocks; group by issue |
| Blocks / blocked_by chain within sprint | ≥1 edge where both endpoints are issues in this sprint | Walk issues-registry blocks/blocked_by; filter to within-sprint edges |

Combined with the ≥2-of-3 meta-threshold, a sprint must show edges across at least two distinct interaction surfaces before the trigger fires.

**B. T2 widget** (when trigger fires) **[T2: Balanced+Full ask | Streamlined: auto-recommend Run, notify]**:

```
🔍 Sprint-Level Validate Recommended
═══════════════════════════════════════
Sprint #{NNN} ({mode}) has {N} closed issues with structural interaction:
  • {signal A — e.g., "ISS-XXX and ISS-YYY share scope_file: nexus-validate/SKILL.md"}
  • {signal B — e.g., "ISS-XXX → blocks → ISS-YYY"}

A sprint-level Validate runs 4 cross-cuts (theme self-prove, cross-skill drift,
version stack consistency, constitution holism) that per-issue Validates cannot catch.

Run sprint-level Validate? [Run (recommended) / Skip / What's the difference?]
═══════════════════════════════════════
```

"What's the difference?" expansion (cite SKILL.md Operational Reminders ### Scope wording from /nexus-validate):
> Per-issue Validate (already run for each issue) checks "did THIS issue meet ITS criteria?" against single-ISS evidence.
> Sprint-level Validate checks "do these closed issues *as a set* not drift, contradict, or leave gaps that none of them owned individually?" against multi-ISS + sprint-state + registry evidence. The two are complementary; neither replaces the other.

After expansion: re-present the [Run / Skip] choice.

**C. Run branch**:

1. Invoke `/nexus-validate SPRINT-{sprint_number}` (sentinel-style first argument; Router §E.0 in nexus-validate SKILL.md branches on prefix → loads types/sprint-level.md).
2. Capture the verdict (PASS / CONCERNS / FAIL) and per-cross-cut summary lines.
3. Log the verdict to sprint-state [DECISIONS] with prefix `[SPRINT-VALIDATE]` for the resumption check (table above): `[SPRINT-VALIDATE] {date} Conv {N}: {PASS|CONCERNS|FAIL} — {1-line summary, cross-cut breakdown}`.

| Verdict | Routing |
|---|---|
| **PASS** | Resume STEP 1 unchanged (zero regression on existing closure flow). |
| **CONCERNS** | Surface the cross-cut summary; offer to proceed (CONCERNS allows close with documented gaps) OR open the FAIL/CONCERNS 3-option widget. **[T2]** |
| **FAIL** | Halt closure flow — present FAIL/CONCERNS 3-option widget (D below). |

**D. FAIL / CONCERNS 3-option widget** **[T2: Balanced+Full ask | Streamlined: surface + auto-recommend Spawn for HIGH findings, notify]**:

```
⚠️ Sprint-Level Validate: {FAIL | CONCERNS}
═══════════════════════════════════════
Findings:
  {list with severity prefix per finding — HIGH/MEDIUM/LOW}

Action per finding (and overall):
  [Spawn issue(s) for next sprint / Fix inline (bounded) / Override and close]
═══════════════════════════════════════
```

| Branch | Action |
|---|---|
| **Spawn issue(s)** | For each finding selected, invoke `/nexus-create-issue` with synthesized title (from cross-cut + 1-line finding summary) and description (cross-cut name + evidence cited + suggested resolution). Each spawned ISS targets the next sprint. After spawn(s) complete: resume STEP 1 (closure proceeds; the spawned issues become part of next sprint's planned work). |
| **Fix inline (bounded)** | Only for findings small enough to resolve in current conversation without phase regression — examples: a single registry edit, a vocabulary fix in one file, a single missing version bump. Anything that would re-open Build is out of bounds. After fix: **MANDATORY re-invocation** of `/nexus-validate SPRINT-{N}` (re-run cross-cuts on the post-fix state). The resumption-check row in STEP 0 does NOT short-circuit this re-invocation — Fix-inline always re-runs the cross-cuts before close resumes. The new verdict must be PASS or CONCERNS-with-no-blocking-findings before STEP 1 begins. Log the re-run verdict to [DECISIONS] as a fresh `[SPRINT-VALIDATE]` entry (not overwriting the prior FAIL entry — both are kept for audit-trail). |
| **Override and close** | Log explicit `[OVERRIDE]` entry to sprint-state [DECISIONS] citing each finding being overridden + reason. Then resume STEP 1. Override does not silence the finding — it records the conscious choice to ship the sprint with the known gap. |

After any branch (or PASS / Skip / auto-skip): proceed to STEP 1.

**Skip / auto-skip path**: trigger declined (Skip) or never fired (DEDICATED, single-issue THEMED, MIXED <2 signals). Log to [DECISIONS]: `[SPRINT-VALIDATE] {date} Conv {N}: SKIP — {reason: user-declined | DEDICATED | single-issue THEMED | MIXED <2 signals}`. Resume STEP 1.

---

### STEP 1: Assess Completion

User already approved closure before this operation was called (via Sprint-Closure protocol). This step checks for problems — not for permission.

```
═══════════════════════════════════════════════
📊 SPRINT {sprint_number} CLOSURE
═══════════════════════════════════════════════

Objectives: {completed}/{total} complete ({percentage}%)
{all complete}: ✅ All objectives achieved!
{incomplete or debt}: ⚠️ See below
```

**If all complete and no debt** (unresolved decisions, pending experience items, open patterns_in_use without outcomes): proceed to STEP 2.

**If incomplete or debt detected**: **[T1: all levels ask]** Present issues, ask via `AskUserQuestion tool` (single_select): "⚠️ Sprint has {N} incomplete objectives / unresolved items." → [Proceed with closure, Cancel — return to work]

If cancelled, exit — no changes made.

---

### STEP 2: Resolve All Issues

Ensure every sprint issue reaches a final state before proceeding.

**A. Handle open issues.** **[T1: all levels ask]** For each issue in planned or in_progress, ask via `AskUserQuestion tool` (single_select):

"ISS-{XXX}: {title} (A:{X} I:{Y} E:{Z}) — still {status}." → [Close as Resolved, Close as Rejected, Move to next sprint]

For issues moved to next sprint: patch registry `ISS-XXX.target_sprint: "TBD"` (the Registry-Schema field that organize-sprint's candidate filter reads — there is no `sprint` key), remove from sprint-state [OBJECTIVES]. Issue stays Open — organize-sprint will collect it.

**B. Verify completed issues.** For each issue in the completed list, verify across 3 locations:

| Location | Check |
|----------|-------|
| Registry | Status is Resolved or Rejected, scores ≥ 4 for Resolved |
| ISS file | `[Section: Closure]` has actual content (not placeholder) |
| Sprint-state | Appears in completed list |

Issues passing all 3 need no action. Issues failing any check go to the closure list.

**C. Close issues.** For each issue in the closure list:
- If user chose Resolve override and scores < 4, patch registry scores to 5 first
- `invoke /nexus-close-issue` in batch mode
- If any fail, log error and continue with remaining

```
✅ Issue Closure Complete
• Already properly closed: {count}
• Closed this step: {count}
• Deferred to next sprint: {count}
{if failures}: • Failed: {count} — see below
```
For failed closures, **[T2: Balanced+Full ask | Streamlined: auto-retry once, then notify]** ask per issue via `AskUserQuestion tool`: → [Retry, Manual edit, Skip (defer)]. Skipped failures follow the same deferred path as STEP 2A.

---

### STEP 3: Pattern Effectiveness Update

Update patterns-registry with usage outcomes from this sprint.

Read `[PATTERNS_IN_USE]` from sprint-state. Also check ISS files for the `### Closure` → **Pattern Outcome Verdicts** table (captured by close-issue STEP 2A) and pattern references in `### Tools & Patterns` / `### Pattern Outcomes` — patterns may have been applied but not recorded in sprint-state. If no pattern usage found in any source, skip to STEP 4.

**For each pattern**, determine the **verdict** {helped, neutral, hindered} from these sources (priority order):

| Priority | Source | Location | Note |
|---|--------|----------|------|
| 1 (primary) | Captured verdict table | ISS [Section: Closure] → **Pattern Outcome Verdicts** | Consolidated verdict + evidence written by close-issue — the canonical source |
| 2 | ISS Pattern Outcomes | Implementation-Log → ### Pattern Outcomes | Validate override annotations take precedence |
| 3 | Sprint-state | `[PATTERNS_IN_USE]` | May still show "applied" if Validate didn't update |
| 4 | ISS Lessons Learned | Evaluation-Results → ### Lessons Learned | Supporting evidence |

When the captured verdict table exists, use its verdict + evidence directly. When a Validate override is present, it takes precedence. When contradictory or unclear, **[T2: Balanced+Full ask | Streamlined: use best evidence, notify]** present conflicting evidence and ask user.

⛔ **No-verdict guard (anti-success)**: a pattern that shows only "applied" with **no captured verdict and no grounding evidence anywhere** is NOT a success. Do NOT pass `helped` to update-pattern for it — either record `neutral` (applied, value indeterminate) or, on user confirmation of "unknown", skip the update entirely. There is **no path that increments `successes` without a grounded `helped` verdict** (ISS-224). Apply the dedup hard-gate here too: a pattern that merely echoes an always-on CLAUDE.md rule/preference/trait caps at `neutral` regardless of how it was recorded upstream.

For each pattern with a determined verdict: `load /nexus-update-pattern` with pattern ID, **verdict** {helped|neutral|hindered}, and issue context.

⛔ MANDATORY OUTPUT once for this step (must appear in response):
⛔ [SKILL-INVOKED] /nexus-update-pattern | invoked: {yes|no} | reason: {patterns updated / none with determined verdict}

```
📐 Pattern Effectiveness Updated:
• PAT-XXX: {verdict: helped|neutral|hindered} (from ISS-YYY)
{if skipped}: • Skipped: {count} (unknown — no verdict)
```

---

### STEP 4: Pattern Candidates

Identify, consolidate, and create new patterns from sprint work.

**A. Collect candidates** from:
1. Sprint-state `[CANDIDATES_PATTERNS]` — observations from checkpoints
2. ISS `[Section: Closure]` → Knowledge Captured → Candidate Patterns — from close-issue
3. Full ISS content (Description, Solution Design, Implementation Log) — problem domain and applicability context needed for generalization.

If no candidates from sources 1 and 2, skip to STEP 5.

**A.5. Recurrence check — rejected_patterns memory** (CLAUDE.md [Section: Memory-Layer]; read-rule N/A here — this is a recurrence/dedup match, not trust-weighting; skip silently if `.nexus/memory/rejected_patterns.jsonl` absent or holds only the safety marker). For each collected candidate, `grep` `rejected_patterns.jsonl` by the candidate's tags/keywords → LLM-scan returned records for a match. If a candidate matches a previously-rejected pattern:

- Surface it: "🔁 Candidate '{name}' resembles {RP-id} (seen in sprint(s) {previously_seen_in}, times_seen={n})."
- A recurring candidate is a **promotion signal**, not an auto-skip — "this keeps coming up" is evidence it may now warrant a real pattern. Weigh it in the 4Q assessment (B) and the create/skip decision (D).
- If the candidate is again **not** promoted at this closure, `/nexus-index-sprint` will record/increment it in `rejected_patterns.jsonl` (write side) — no manual edit here.

**B. Quick 4Q prefilter.** For each candidate, assess against the 4Q gate:
- Q1: Guides future decisions (not just documents past)?
- Q2: Non-obvious (wouldn't do without being told)?
- Q3: Generalizable (applies beyond this specific case)?
- Q4: Has an underlying principle worth remembering?

Candidates scoring < 2/4 are filtered out. Display filtered candidates briefly so user sees what was dropped.

**C. Consolidate if needed.** If more than 4 candidates pass prefilter, merge similar ones into stronger, more generalizable patterns by combining insights — identify candidates addressing the same problem class or approach. Present at most 4 focused, strategic proposals after consolidation, rather than overlapping suggestions.

**D. Present to user.** Show candidates with 4Q scores, source issues, descriptions. Note any merges.

**[T2: Balanced+Full ask | Streamlined: auto-create if 4Q ≥ 3, notify]** Via `AskUserQuestion tool`: 1 candidate → single_select [Create / Skip]. 2-4 → multi_select with candidate names as options.

**E. Create approved patterns.** For each approved: `invoke /nexus-create-pattern` with candidate context. Full ISS files remain in memory for create-pattern to build well-scoped patterns.

⛔ **Bulk-write discipline** (fires at write-emit, not retrospectively):
- **Red Flag**: about to write a pattern's registry keys or `patterns/PAT-XXX.md` *directly* (Edit/Write to `patterns-registry.yaml` or a PAT file) instead of invoking `/nexus-create-pattern`. Catch the instant you reach for Edit/Write here.
- **Rationalization to defeat**: "I already know the pattern content / the 4Q gate is obvious / inlining is faster mid-closure." None are valid — `/nexus-create-pattern` runs the 4Q validation gate, the similarity/duplicate check, and the registry insert-rule grep that a direct write skips. Skill-bypass corrupts pattern telemetry and risks duplicate-key YAML corruption.
- **Anti-Pattern — Closure bulk-write skill-bypass**: inline registry/file writes during high-volume closure instead of routing through the owning skill (origin: Sprint 085 Conv 10 — 3 inline writes against high-stakes registries without skill invocation; carried Sprint 086 unresolved). The discipline check is the most-skipped output at the moment it is most required.

⛔ MANDATORY OUTPUT per approved candidate (must appear in response):
⛔ [SKILL-INVOKED] /nexus-create-pattern | invoked: {yes|no} | reason: {candidate ID / why skipped}

New-file verification (SC-02 hybrid — per-write for new files): the PAT file + registry keys are created *inside* `/nexus-create-pattern`, which emits its own `⛔[WRITE-VERIFIED]` per new file. Do not re-verify here — the invoked skill owns that write.

Handle returns: CREATED (track ID), ENHANCED (existing improved), DUPLICATE (skipped), NOTED_AS_LEARNING (didn't pass full 4Q), CANCELLED.

Display summary:
```
📐 Pattern Candidates Processed:
• Collected: {raw} → After 4Q: {filtered} → After consolidation: {final}
• Created: {N} | Enhanced: {N} | Skipped: {N}
```

---

### STEP 5: Archive Closed Issues

Runs after pattern processing — ISS files no longer needed in original location.

**⚠️ MANDATORY: Use /nexus-archive-issue — do NOT move files manually.**
Manual `mv` skips slug-based rename, registry entry removal, total_active decrement, cascade checks, and verification. All of these are required.

**Procedure:**
1. **Collect archivable issues (SC-04 — registry scan, not just STEPs 1-2):** Build the closure list from BOTH sources, union-merged:
   - (a) Issues **Resolved or Rejected** in STEPs 1-2 of this closure.
   - (b) **Orphan-archivable scan**: Grep `issues-registry.yaml` for every issue with status ∈ {Resolved, Rejected, Superseded, Decomposed} whose ISS file is still present in `.nexus/issues/`. This catches issues closed *mid-sprint during Build of another issue* (non-[OBJECTIVES] closures) that STEPs 1-2 never processed — origin: Sprint 090 Conv 6 closed ISS-150-as-Rejected during ISS-197 Build's triage; ISS-150 stayed in `.nexus/issues/` after close-sprint completed (caught only by post-close user review).
   - **Exclude any issue whose status is still Open** — deferred and moved-to-next issues (STEP 2A patches them to `target_sprint: "TBD"` but they stay Open) must remain active for organize-sprint to collect. The status filter in (b) already excludes them; this guard also applies to (a).
   - Deduplicate the union (an issue may appear in both (a) and (b)); the merged list is the archival set.
2. `load /nexus-archive-issue` in **backend mode** with the closed issues list
   ⛔ MANDATORY OUTPUT once for this step (must appear in response):
   ⛔ [SKILL-INVOKED] /nexus-archive-issue | invoked: {yes|no} | reason: {N issues archived / none archivable}
3. The skill handles: slug filename generation, file move, registry entry removal, total_active decrement, cascade dependency cleanup, verification
4. **Post-archive verification** (mandatory): Confirm for each archived issue:
   - File exists in `archived/issues/` with slug filename (not bare `ISS-XXX.md`)
   - Registry entry removed (Grep for `ISS-XXX.title:` returns no match)
   - `total_active` decremented correctly

If archive-issue returns failures: present per STEP 2C pattern (retry/skip).

Display:
```
📦 Archival Complete:
• Archived: {count} issues (slug-named, registry cleaned)
{if failures}: • Failed: {count} (manual fix needed)
```

---

### STEP 6: Experience Processing

Process accumulated experience from sprint-state inline. Two streams: system issues become issues or quick fixes, behavioral insights become preference additions or elevations.

Read `[SYSTEM_ISSUES]` and `[BEHAVIORAL_INSIGHTS]` from sprint-state (already in memory from STEP 0). If both empty, skip to STEP 7.

Load `[Section: Behavioral-Preferences]` (always in memory from bootstrap) — needed for matching insights to existing preferences.

Display:
```
📚 Experience Processing
- System issues: {count} entries
- Behavioral insights: {count} entries
```

**A — Process system issues.** If none, skip to B.

If more than 4 system issues, merge similar / relevant ones into stronger, more concrete grouped entries by combining insights — identify issues about the same underlying problem or topic.

Present at most the 4 most important and well captured issues that have clear solutions, rather than overlapping suggestions.

For each group:
```
─────────────────────────────────────────────────
🔧 System Issue Group {N}: {topic_summary}
─────────────────────────────────────────────────

Entries ({count}):
- {entry_1}
- {entry_2}

Analysis: {severity, pattern, root cause if clear}
Recommendation: {issue / fix / seed / skip}
Reasoning: {why}
```
**[T2: Balanced+Full ask | Streamlined: auto-select recommendation, notify+log]** Offer choice via `AskUserQuestion tool`: [Issue, Fix, Seed, Skip].

| Choice | Action |
|--------|--------|
| Issue | `invoke /nexus-create-issue` with synthesized title and description. |
| Fix | Ask user for target file and what to change. Apply with Edit tool. |
| Seed | `invoke /nexus-plug-seed` with the system issue content as context (idea = the issue description; trigger and prune-when inferred from context). Its STEP 1A may classify the content as a **finding** rather than a proposal — a system issue frequently asserts how something behaves — in which case it lands in `.nexus/memory/discoveries.jsonl` instead of `.nexus/seeds/`. Either outcome consumes the entry: remove it from sprint-state once the skill confirms its write. |
| Skip | Entry processed, remove from sprint-state. |

⛔ **Bulk-write discipline** (fires at write-emit, not retrospectively):
- **Red Flag**: on the **Issue** choice, about to write a new ISS file + `issues-registry.yaml` keys *directly* instead of invoking `/nexus-create-issue`. Catch the instant you reach for Write/Edit here.
- **Rationalization to defeat**: "I know the issue fields / mode detection doesn't matter here / inlining is faster at closure." None are valid — `/nexus-create-issue` runs mode detection, scope/dependency analysis, the testability gate, and the registry insert-rule grep that a direct write skips. Skill-bypass risks duplicate-key YAML and an under-specified issue.
- **Anti-Pattern — Closure bulk-write skill-bypass**: same failure-class as STEP 4E (origin: Sprint 085 Conv 10 — 3 inline registry writes without skill invocation; carried Sprint 086). The **Fix** choice writes via Edit by design (bounded, user-directed target) — it is *not* a bypass; the bypass concern applies to the **Issue** choice's create-issue routing.

⛔ MANDATORY OUTPUT on the **Issue** choice (must appear in response):
⛔ [SKILL-INVOKED] /nexus-create-issue | invoked: {yes|no} | reason: {system-issue ID / why skipped}

New-file verification (SC-02 hybrid — per-write for new files): the ISS file + registry keys are created *inside* `/nexus-create-issue`, which emits its own `⛔[WRITE-VERIFIED]`. Do not re-verify here.

**B — Process behavioral insights.** If none, skip to C.

Group entries by same preference or behavior pattern. For each group, search `[Behavioral-Preferences]` for an existing preference that covers this behavior. Display:
```
─────────────────────────────────────────────────
🧠 Behavioral Insight Group {N}: {topic_summary}
─────────────────────────────────────────────────

Entries ({count}):
- {entry_1}

{if existing preference found}:
Existing preference: {preference_name}
  do: "{current_do}"
  importance: {current_importance}

{if no existing preference}:
No existing preference found.

Recommendation: {elevate / add / defer / skip}
Reasoning: {why}
```

**[T2: Balanced+Full ask | Streamlined: auto-select recommendation, notify+log]** Offer choices via `AskUserQuestion tool` — options depend on match result:

| Condition | Options |
|-----------|---------|
| Existing preference found | [Elevate, Skip, Defer] |
| No existing preference | [Add, Skip, Defer] |

| Choice | Action |
|--------|--------|
| Elevate | Ask for new importance level. Patch CLAUDE.md `[Section: Behavioral-Preferences]`. |
| Add | Propose name, do, importance, context. User confirms. Patch CLAUDE.md `[Section: Behavioral-Preferences]` under matching importance header. |
| Defer | Entry stays in sprint-state — organize-sprint carries it forward. |
| Skip | Entry processed — remove from sprint-state. |

If any preference patch fails: show manual edit instructions and continue.

**C — Summary.**
```
✅ Experience Processing Complete:
- System Issues: {issues_created} issues, {fixes_applied} fixes, {seeds_planted} seeded, {discoveries_recorded} recorded as findings, {skipped} skipped
- Behavioral Preferences: {elevated} elevated, {added} added, {deferred} deferred, {skipped} skipped
```
**D — Cleanup [EXPERIENCE_CAPTURE].** Remove all consumed entries from sprint-state. Only deferred BEHAVIORAL_INSIGHTS entries remain.

For `[SYSTEM_ISSUES]`: rewrite to empty — all outcomes (Issue, Fix, Seed, Skip) are consumed. Seeded entries are persisted in `.nexus/seeds/` (or, when the Seed choice classified the content as a finding, in `.nexus/memory/discoveries.jsonl`) — not in sprint-state.

For `[BEHAVIORAL_INSIGHTS]`: rewrite to contain only entries marked Defer. All other outcomes (Elevate, Add, Skip) are consumed.

Use `Edit tool` — one call per subsection. If no deferred entries remain, leave the subsection empty (tag pair with no content between).

Verify after cleanup: scan `[EXPERIENCE_CAPTURE]` — only deferred entries should remain. If consumed entries persist, retry the patch.

---

### STEP 7: Unblock Dependencies

Scan issues-registry for issues whose `blocked_by` includes issues resolved this sprint. Remove resolved IDs from blocked_by. If blocked_by becomes empty, the issue is now unblocked.

Display:
```
{if unblocked}:
🔓 Issues Now Unblocked ({count}):
• ISS-XXX: {title}

{if none}: No issues unblocked by this sprint's resolutions.
```

---

### STEP 8: Administrative Updates

Four updates in sequence. All important for continuity but none complex.

**A. Update project state.** `load /nexus-update-state` with sprint closure context. If it fails — warn user and continue.

**B. Index sprint to memory.** Write the cross-sprint memory layer from the frozen sprint-state + archived ISS files. `sprints_summaries.jsonl` is the sole cross-sprint history file — it replaced the former `work-history.md` append (CLAUDE.md [Section: Memory-Layer]).

`load /nexus-index-sprint` (Read `.claude/skills/nexus-index-sprint/SKILL.md` and follow it). It writes all 7 `.nexus/memory/*.jsonl` files (decisions, discoveries, work_debt, rejected_patterns, issues_learnings, sprints_summaries, sprint_index) from sprint-state sections + archived ISS `[Section: Closure]` sections, with per-line `json.loads` write-verify and "describe-don't-resolve" contradiction handling. It emits its own `⛔[WRITE-VERIFIED — BATCHED]` table — do not re-verify the memory files in STEP 9A-2.

Runs here (STEP 8B) deliberately: **after** STEP 5 archival (so `archived_file` pointers resolve) and **before** STEP 9C-2 clears the sprint-state sections it reads.

⛔ MANDATORY OUTPUT once for this step (must appear in response):
⛔ [SKILL-INVOKED] /nexus-index-sprint | invoked: {yes|no} | reason: {memory indexed / skipped — why}

If index-sprint fails — warn user and continue (non-blocking; memory is a derived cache, rebuildable from archives).

**C. Update sprint queue.** `UPDATE: .nexus/active/states/sprint-queue.md` — mark current sprint as `"COMPLETE ✅"`, add completion_date (use mustBeNear sprint ID for targeting).

**D. Update maintenance tracking.** 

Check `_sprint_type` from sprint-state metadata (default: `normal` when field absent). Patch `system-state.md#[Section: Maintenance-Tracking]`:

| `_sprint_type` | Action |
|-------------|--------|
| `maintenance` | `SET sprints_since_maintenance = 0`, `maintenance_needed = false` |
| `normal` (or absent) | `Increment sprints_since_maintenance + 1`, then evaluate the **maintenance-due trigger** below. |

**Maintenance-due trigger** (`normal` sprints only). After incrementing, set `maintenance_needed = true` and display "⚠️ Maintenance recommended" when **either**:
- the closing sprint number ≥ `[Maintenance-Tracking].prediction.next_maintenance_sprint` (the recalibrated scheduled cycle is due/overdue), **or**
- `sprints_since_maintenance ≥ cycle_position.recommended_cycle` (the **active** cycle length, sourced from `cycle_rules.default_cycle_length` — currently 8; **never a hardcoded constant**).

Otherwise keep `maintenance_needed = false`. The maintenance-scheduler's nearest-threshold early-trigger (an op projected below its `warning_threshold` before the cycle fires) overrides this independently.

> **Why schedule-derived, not a fixed number**: the former hardcoded "≥ 5" *was* the pre-Sprint-100 `default_cycle_length`. That value was recalibrated 5→8 at Sprint 100 (`cycle_rules`), but the literal threshold here was never updated — so every `normal` closure from Sprint 100 onward had to consciously override "≥ 5 → true" back to `false` with a documented rationale (system-state Conv 100–106). Reading the trigger from `prediction.next_maintenance_sprint` / `recommended_cycle` keeps STEP 8D consistent with the cycle governance by construction.

---

### STEP 9: Finalize

**A. Verification gate.** Confirm these critical items succeeded:

| Item | Step | Critical? |
|------|------|-----------|
| All issues resolved, deferred, or failed with user awareness | STEP 2 | Yes |
| Pattern effectiveness updated | STEP 3 | Yes |
| Pattern candidates | STEP 4 | No — logged if failed, don't block |
| Issues archived | STEP 5 | Yes |
| Experience processed | STEP 6 | Yes |
| Project state updated | STEP 8A | Yes |
| memory index (7 files), sprint queue, maintenance counter | STEPs 8B-D | No — logged if failed, don't block |

If any item failed, **[T1: all levels ask]** present the gaps and use `AskUserQuestion tool` (single_select): "Gaps found during closure. Action:" → [Proceed anyway, Address gaps first].

**A-2. Batched write-verification (SC-02 hybrid — batched for registry/state patches).** close-sprint patches many high-stakes files across STEPs 2–9 (sprint-state, issues-registry, patterns-registry, system-state, project-state, sprint-queue). Emitting a per-write `⛔[WRITE-VERIFIED]` for each is the marker-fatigue source that caused the original discipline collapse (Sprint 085 Conv 10: 17+ unmarked writes). Instead, emit ONE consolidated table here — read each patched file's anchor back from disk to populate it. This is the auditable evidence that every closure write landed.

⛔ MANDATORY OUTPUT — batched verification table (must appear in response; one row per high-stakes file patched this closure):

```
⛔ [WRITE-VERIFIED — BATCHED] Sprint {NNN} closure
| File | Anchor (literal substring from disk) | Status |
|---|---|---|
| sprint-state.md | _status: complete / _closure_time: {ts} | present/missing |
| issues-registry.yaml | {ISS-XXX.status: Resolved ...} | present/missing |
| patterns-registry.yaml | {PAT-XXX effectiveness fields patched by STEP 3 — successes / failures / neutral / effectiveness} | present/missing |
| system-state.md | {maintenance counter value} | present/missing |
| project-state.md | {updated field} | present/missing |
| sprint-queue.md | {COMPLETE ✅} | present/missing |
```

Any `missing` row blocks finalization until the write is re-applied and re-verified. New-file creations (PAT/ISS via invoked skills at STEPs 4E/6A) are NOT in this table — they were verified per-write by their owning skills. The `.nexus/memory/*.jsonl` writes are likewise NOT in this table — `/nexus-index-sprint` (STEP 8B) verified them via its own `⛔[WRITE-VERIFIED — BATCHED]` marker.

**B. Mark sprint complete.** This is critical — Bootstrap uses `_status` and `_closure_time` to detect a closed sprint. Patch sprint-state.md:
- `_status: in_progress` → `_status: complete`
- Update `_updated` to current timestamp
- Add `_closure_time: {ISO_timestamp}` before `_sprint` field
- Update continue_with:
  ```
  continue_with: |
    SPRINT CLOSED: Sprint {N} completed {date}
    NEXT ACTION: Run 'organize sprint' to plan the next sprint
  ```

**C. Archive final state.** Copy sprint-state.md to `.nexus/Sprints/{N}/final-sprint-state.md`.

**C-2. Clean sprint-state for next sprint.** Archive preserves full state. Clear sprint-specific sections so organize-sprint starts clean.

| Target | Method | Replacement |
|--------|--------|-------------|
| `files_to_load` | `Edit tool` | `files_to_load: []` |
| `[FILES_MODIFIED]`, `[MOMENTUM]`, `[CONVERSATION_HISTORY]`, `[PATTERNS_IN_USE]`, `[CANDIDATES_PATTERNS]` | `Edit tool` (each) | Empty (tags only) |

Idempotent — safe on re-run. Verify: spot-check one cleared section — tags present, content empty.

**D. Post-closure maintenance.** Check `_sprint_type` from sprint-state metadata (default: `normal` when absent):

**MANDATORY: Execute both operations sequentially in the main conversation context. Do NOT delegate to sub-agents.** Reasons: (1) system-state.md is modified by both — concurrent writes cause race conditions, (2) health-diagnostic reads changelog scores — must run after changelog-scan, (3) sub-agents duplicate context (~60K tokens each) for work the main context can do cheaply with files already loaded. The time saving from parallelization does not justify the token cost, collision risk, and verification overhead.

| `_sprint_type` | Operations |
|-------------|------------|
| `normal` (or absent) | **Sequentially, in main context**: 1) `load /nexus-changelog-scan` mode=3 (sprint snapshot — captures version state). 2) `load /nexus-health-diagnostic` (post-closure assessment — measures health WITH fresh changelog data). |
| `maintenance` | Skip /nexus-health-diagnostic (/nexus-maintain Phase 3 already produced baseline). Skip /nexus-changelog-scan if changelog-registry header sprint matches current sprint (already ran during maintenance). Otherwise run /nexus-changelog-scan first, then health-diagnostic. |

If health-diagnostic fails due to file write error: note in continue_with as first task of next conversation.

Display completion:
```
═══════════════════════════════════════════════
✅ SPRINT {sprint_number} CLOSED SUCCESSFULLY
═══════════════════════════════════════════════

Summary:
• Issues Closed: {count}
• Issues Archived: {count}
• Issues Deferred: {count}
• Patterns Created: {count} | Updated: {count}
• Experience Processed: ✓

Statistics:
• Duration: {conversations} conversations
• Completion: {percentage}%
• Mode: {mode}

Next: Fresh sprint creation (Bootstrap → organize-sprint)
═══════════════════════════════════════════════
```

**E. Git baseline commit.** Create a tagged stable commit marking this sprint's completion:

```bash
git add -A
git commit -m "sprint-close: Sprint {sprint_number} complete — {issues_closed} issues, {completion}%" --quiet
git tag -a "sprint-{sprint_number}" -m "Sprint {sprint_number}: {sprint_title}" 2>/dev/null
```

If git fails: note in continue_with, non-blocking. The tag enables `/nexus-rollback` Workflow 4 (Known Good State) to find sprint baselines.

---

## Gate Reference

| Gate | Step | Tier | Full | Balanced | Streamlined |
|---|---|---|---|---|---|
| Sprint-level Validate Run/Skip | STEP 0 | T2 | Ask + rec | Ask + rec | Auto-recommend Run, notify |
| Sprint-level Validate FAIL/CONCERNS routing | STEP 0 | T2 | Ask + rec | Ask + rec | Surface + auto-recommend Spawn for HIGH, notify |
| Incomplete sprint proceed/cancel | STEP 1 | T1 | Ask | Ask | Ask |
| Per open issue disposition | STEP 2A | T1 | Ask | Ask | Ask |
| Failed closure retry/skip | STEP 2C | T2 | Ask | Ask | Auto-retry once, then notify |
| Pattern verdict (unclear) | STEP 3 | T2 | Ask | Ask | Use best evidence, notify |
| Pattern candidate create/skip | STEP 4D | T2 | Ask | Ask | Auto-create if 4Q ≥ 3, notify |
| System issue disposition | STEP 6A | T2 | Ask | Ask | Auto-select recommendation, log |
| Behavioral insight disposition | STEP 6B | T2 | Ask | Ask | Auto-select recommendation, log |
| Verification gate gaps | STEP 9A | T1 | Ask | Ask | Ask |

---

## End-of-Workflow Checklist

Before STEP 9B (mark complete), verify:

- [ ] All issues resolved, deferred, or failed with user awareness (STEP 2)
- [ ] Pattern effectiveness updated in registry (STEP 3)
- [ ] Pattern candidates processed (STEP 4)
- [ ] Closed issues archived (STEP 5)
- [ ] Experience processed — system issues + behavioral insights (STEP 6)
- [ ] Experience capture cleaned — only deferred entries remain (STEP 6D)
- [ ] Dependencies unblocked in registry (STEP 7)
- [ ] Project state updated via /nexus-update-state (STEP 8A)
- [ ] Sprint indexed to memory via /nexus-index-sprint — 7 files written + verified (STEP 8B)
- [ ] Sprint queue marked complete (STEP 8C)
- [ ] Maintenance tracking counter updated (STEP 8D)
- [ ] Sprint-state `_status: complete` + `_closure_time` set (STEP 9B)
- [ ] Final state archived to Sprints/{N}/ (STEP 9C)
- [ ] Sprint-state sections cleared for next sprint (STEP 9C-2)
- [ ] Post-closure maintenance run: changelog-scan → health-diagnostic (STEP 9D)
- [ ] Git baseline commit + tag (STEP 9E)

---

## Error Recovery

| Problem | Recovery |
|---|---|
| close-issue fails for one issue | Log error, continue with remaining. Offer retry/skip per issue (STEP 2C). |
| Pattern update fails | Warn user, skip pattern. Non-blocking — continue closure. |
| Archive fails | Warn user, note in continue_with. Issues stay in `.nexus/issues/` — manual move later. |
| Experience patch fails | Show manual edit instructions. Continue closure. |
| Project state update fails | Warn user, continue. Note in continue_with for next conversation. |
| Memory index (/nexus-index-sprint) fails | Warn user, continue. Non-blocking — derived cache, rebuildable from archives. |
| Sprint-state mark-complete fails | CRITICAL — retry. If retry fails, provide manual patch instructions. |
| Git commit/tag fails | Note in continue_with. Non-blocking. |
| Partial closure (interrupted mid-way) | Resumption detection in STEP 0 identifies completed steps and resumes. |
