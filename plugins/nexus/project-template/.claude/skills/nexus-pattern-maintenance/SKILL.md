---
name: nexus-pattern-maintenance
description: Review and maintain pattern system health — three-tier escalating analysis
disable-model-invocation: true
---
*Version: 2.2.0 | Date: 2026-06-16 | Sprint: 105*

# Pattern Maintenance

**Flow**: Load → Tier 1 (registry scan + score) → Menu → [Tier 2 (deep qualification per pattern)] → [Tier 3 (similarity/merge)] → Finalize

Three-tier escalating analysis. Tier 1 always runs. Tiers 2 and 3 are user-initiated (or auto-selected at Streamlined). Detect issues, present findings, user decides what to fix.

**Always sequential** — not parallelizable. Interactive at Tiers 2-3 (user selects patterns, approves enhancements, confirms deletions/merges).

**Tiers**: Tier 1 (registry scan, ~5K) → Tier 2 (deep qualification per pattern, ~3-5K each) → Tier 3 (similarity merge detection).

---

### STEP 0: Load Registry

Read `.nexus/active/registries/patterns-registry.yaml` (memory-first). If load fails: inform user and return — no operation possible.

Count active patterns from `meta.active`, verify against actual entry count. If mismatch, warn user.

If zero patterns: display "No patterns in registry — nothing to maintain." Return. Skip system-state update.

**Resumption note**: Pattern-maintenance does not persist mid-tier state across conversations. On re-invocation, Tier 1 re-scans from current registry state. Previously applied changes (deletes, enhances, merges) are already reflected in the registry. User re-selects patterns for further examination if needed.

---

### STEP 1: Tier 1 — Registry Scan

Assess every pattern using registry fields only. No PAT file loading.

**A — Per-pattern assessment.** For each pattern, evaluate:

| Check | Fields used | Flag if |
|-------|------------|---------|
| Effectiveness | `effectiveness` | Below 0.55 |
| Usage volume | `successes`, `failures` | Total applications < 3 |
| Failure rate | `failures / (successes + failures)` | Above 0.30 |
| Activity | `last_used` | Unused > 90 days or null (never used) |
| Description quality | `description` | Vague, too short, or too generic |
| Trigger quality | `use_when` entries | Fewer than 2, or too broad/vague |
| Maturity vs usage | `maturity` vs `successes + failures` | Maturity not justified by usage data |
| Domain coverage | `domain` | Missing or "general" when clearly domain-specific |
| Issue type breadth | `by_issue_type` | Only 1 issue type despite broad description |
| Phase affinity | `phase_affinity` | Empty, or contains deprecated values (e.g., "application") |
| Relationships | `synergies`, `conflicts` | Empty synergies on related patterns. Stale refs to deleted patterns. |

**Age-gate overlay (apply to the usage-based flags above):** patterns **created within the last ~2 sprints** are exempt from the usage-driven flags — Effectiveness, Usage volume, and Activity. A young pattern has not had time to fire, and `0.50` is the default *seed* effectiveness a pattern is born with — so "low effectiveness / never used" on a recent pattern is expected, not a weakness. Judge recent patterns on **wisdom (4Q) + overlap** only; do not flag them for retire-for-non-use. (Rubric origin: ISS-223 Sprint 105.)

**Framework-redundancy note:** the single strongest retire signal is *framework subsumption* — a pattern whose guidance is already carried by a CLAUDE.md principle/preference/trait or a skill step (it double-counts rather than adds). Tier 1 registry fields cannot detect this directly; it surfaces in Tier 2 deep examination (Q1/Q4) and — now registry-legible via the `neutral` counter (ISS-224) — in the periodic **Value/Dedup Audit Lens (STEP 1.5)**.

**B — Categorize results:**

- **Strong** — effectiveness ≥ 0.75, applications ≥ 5, clear triggers and description
- **Adequate** — no major flags, minor gaps
- **Needs Attention** — 1-2 flags
- **Poor** — 3+ flags, or effectiveness < 0.40, or never used with weak metadata

Principle-type patterns are assessed but marked as protected from deletion. **Age-gated recent patterns** (per the overlay above) are never classified Poor on usage grounds alone — a recent, never-used pattern with sound wisdom is "Adequate (keep-watch)", not Poor.

**C — Display findings:**

```
════════════════════════════════════════════════════════════
🌡️ PATTERN SYSTEM HEALTH — Tier 1 Registry Scan
════════════════════════════════════════════════════════════

Active Patterns: {count}
Avg Effectiveness: {percentage}%

📊 DISTRIBUTION
   Strong: {count} | Adequate: {count} | Needs Attention: {count} | Poor: {count}

⭐ STRONG ({count})
{for each}: {id} {name} — {eff}%, {apps} apps

⚠️ NEEDS ATTENTION ({count})
{for each}:
   {N}. {id} {name}
       Flags: {list}

❌ POOR ({count})
{for each}:
   {N}. {id} {name}
       Flags: {list}
       💡 Recommend: Deep examination (Tier 2)

════════════════════════════════════════════════════════════
```

**D — Calculate and persist initial score.**

```
score = (usage_weighted_effectiveness × 0.70) + (maturity_distribution × 0.30)
```

**Component 1 — Usage-Weighted Effectiveness (70%)**:
`sum(effectiveness_i × max(1, applications_i)) / sum(max(1, applications_i)) × 100`
Where `applications_i = successes + failures`. The `max(1, ...)` floor prevents zero-usage patterns from being invisible.

**Component 2 — Maturity Distribution (30%)**:
Weight each pattern: proven=100, established=80, validated=60, emerging=35. Average across all.

> ⚠️ **Telemetry caveat (ISS-224 resolved).** This usage-weighted-effectiveness score still *structurally rewards* high-effectiveness patterns, but the redundancy blind spot is now addressed: ISS-224 (Sprint 105) replaced the auto-success taxonomy with verdicts {helped/neutral/hindered} and added a `neutral` counter, so framework-redundant echo-patterns accrue `neutral` (excluded from effectiveness) instead of inflated `successes`. The periodic **Value/Dedup Audit Lens (STEP 1.5)** consumes that `neutral` signal to surface redundancy directly. Treat this score as a rough health proxy, not a value measure; do not let it veto a redundancy-driven retirement — defer to the audit lens. (Origin: ISS-223 Conv 4 discovery; resolved ISS-224.)

Round to integer. Persist to system-state [Health-Operations] pattern_maintenance:

```yaml
pattern_maintenance:
  score: {initial_score}
  last_run_sprint: {current_sprint}
```

Display: `📊 Initial Assessment: {initial_score}/100 (pre-maintenance baseline)`

> **Mental note**: Tier 1 complete. {count} patterns. Strong: {n}, Attention: {n}, Poor: {n}. Initial score: {score}/100. If checkpoint → save scan results + score.

**E — Present menu.**

**[T3: Full ask | Balanced: notify | Streamlined: auto-sweep — Tier 2 (Poor first, then Needs Attention) → Tier 3 Similarity → Exit. Stops only at T1 gates (delete/merge).]**

Options via AskUserQuestion: [Examine patterns (Tier 2), Similarity check (Tier 3), Save report, Exit]

| Selection | Action |
|---|---|
| Examine | → STEP 2 |
| Similarity | → STEP 3 |
| Save report | Write report (see STEP 4B), return to menu |
| Exit | → STEP 4 (**operation complete** signal for /nexus-maintain) |

---

### STEP 1.5: Value/Dedup Audit Lens (Periodic — SC-06)

A periodic full-library sweep scoring each pattern on the two axes Tier 1's registry checks cannot see directly: **does it change behavior in a way that matters, and is that guidance already carried by the framework?** This is the standing successor to the per-pattern dedup check close-issue applies at closure (SC-04) — that gate guards *new* verdicts; this lens re-audits the *whole surviving library* on a cadence. (ISS-224, Sprint 105.)

**Cadence gate**: run only when due. Read `last_value_audit_sprint` from system-state [Health-Operations] pattern_maintenance. Run if absent, or if `current_sprint − last_value_audit_sprint ≥ 3`; otherwise skip silently (one-line "Value/dedup audit not due — last ran S{N}"). The user may force it on demand ("run value audit").

**Two axes** (judge per pattern):

| Axis | Question | Levels | Signals |
|---|---|---|---|
| **Behavioral leverage** | Does applying this change a decision/action in a way that matters? | high / medium / low | match-pattern surfacing relevance, `successes` from genuine `helped` verdicts, breadth of `by_issue_type` |
| **Framework redundancy** | Is this guidance already carried by an always-on CLAUDE.md core rule/preference/trait or a skill step? | unique / partial / redundant | high `neutral` count or neutral-ratio `neutral / (successes + failures + neutral)` is the registry-level redundancy proxy (ISS-224); confirm against CLAUDE.md + skill steps |

**Quadrant → action**:

| Leverage × Redundancy | Reading | Action |
|---|---|---|
| high × unique | Core value — genuinely additive | Keep (protect) |
| low × unique | Niche but non-duplicative | Keep-watch |
| high × redundant | Leverage is real but the *framework already delivers it* — the pattern is an echo | Escalate to Tier 2 → retire/embed candidate |
| low × redundant | Dead weight — no value and duplicative | Escalate to Tier 2 → strong retire candidate |

The neutral-ratio is the objective entry point: a pattern applied often but mostly scored `neutral` is, by definition, an echo — surface it regardless of its (now neutral-excluded) effectiveness. Patterns flagged `redundant` on either axis are added to the Tier 2 examine list at Poor priority with reason "value/dedup audit: framework-redundant".

**Age-gate**: the recent-pattern exemption from STEP 1 applies here too — do not audit patterns created within the last ~2 sprints for redundancy-retirement (no neutral history yet).

**After the sweep**: set `last_value_audit_sprint: {current_sprint}` (persisted at STEP 4A alongside the score). Display a compact quadrant summary and feed flagged patterns into the STEP 1E menu's Tier 2 recommendation.

```
🔎 VALUE/DEDUP AUDIT (periodic) — {count} patterns
   high×unique (keep): {n}   low×unique (watch): {n}
   high×redundant (retire/embed): {n}   low×redundant (retire): {n}
   → Flagged for Tier 2: {list or "none"}
```

---

### STEP 2: Tier 2 — Deep Qualification

User selects patterns to examine. Process one at a time.

**A — Select patterns.**

**[T3: Full ask | Balanced: notify | Streamlined: auto-select Poor first, then Needs Attention, notify]**

Display Needs Attention and Poor lists (numbered). Ask user which to examine. Recommend starting with Poor.

**B — Load and examine.** For each selected pattern, Read `.nexus/patterns/PAT-XXX.md` fully.

**4Q Validation:**

| Question | Pass if | Fail if |
|----------|---------|---------|
| Q1 Strategic | Provides decision framework, actionable guidance | Only describes past, no forward guidance |
| Q2 Non-obvious | Counter-intuitive or discovery-derived | Common sense, standard practice |
| Q3 Generalizable | Broad use_when, adaptable across domains | Too narrow, single-case specific |
| Q4 Wisdom | Transferable insight, reveals non-obvious relationships | Just procedural steps, no deeper principle |

**Completeness check — every PAT file section:**

| Section | Check | Flag if |
|---------|-------|---------|
| Description | Clear problem statement, context, scope | Vague or missing |
| Context (use_when) | Specific, actionable triggers | Generic or too few |
| Context (not_when) | Boundaries defined | Missing entirely |
| Solution | Step-by-step or principle-based guidance | Too abstract or too narrow |
| Rationale | Explains WHY, not just WHAT | Missing or trivial |
| Examples | At least one concrete application | Missing |
| Anti-Patterns | Common mistakes to avoid | Missing (acceptable for simple patterns) |
| Relationships | Synergies and conflicts current | Stale references |

**Trigger actionability:** For each `use_when` — would this realistically fire during pattern matching? "When designing systems" = too broad. "When facing multiple architectural approaches with unclear trade-offs" = actionable.

**Solution applicability:** Could a fresh instance read and apply without improvising? Check: concrete steps, clear scope, enough context.

**Registry metadata validation** (cross-check PAT file content against registry fields):

| Field | Check against PAT content |
|---|---|
| `description` | Matches PAT file's actual scope and purpose? |
| `use_when` | Triggers match PAT file's Context section? |
| `domain` | Matches the actual problem domain described? |
| `type` | Classification correct (principle/methodology/practice/solution)? |
| `maturity` | Justified by usage data AND content quality? |
| `phase_affinity` | Matches where the pattern actually applies? No deprecated values? |
| `by_issue_type` | Matches PAT file's described applicability? |
| `synergies/conflicts` | References valid? Missing obvious connections? |

Flag any mismatches between PAT content and registry metadata as findings.

**C — Present examination results:**

```
════════════════════════════════════════════════════════════
🔬 DEEP EXAMINATION: {id} — {name}
════════════════════════════════════════════════════════════

📝 4Q VALIDATION
   Q1 Strategic:     {PASS/FAIL} — {brief reason}
   Q2 Non-Obvious:   {PASS/FAIL} — {brief reason}
   Q3 Generalizable: {PASS/FAIL} — {brief reason}
   Q4 Wisdom:        {PASS/FAIL} — {brief reason}

📋 COMPLETENESS
{for each section}: {section}: {✅ / ⚠️ / ❌} — {note}

🎯 TRIGGERS: {Good / Weak / Poor}
{for each}: • {trigger} — {assessment}

📖 SOLUTION: {Actionable / Vague / Too narrow}

🔗 REGISTRY METADATA
{for each mismatch}: • {field}: registry says "{value}" but PAT content suggests "{correct}"

─────────────────────────────────────────────────────────────
🩺 VERDICT: {STRONG / ENHANCE / DELETE}

{if ENHANCE}: Suggested enhancements:
• {specific suggestion}

{if DELETE}: Pattern fails qualification. Recommend deletion.
════════════════════════════════════════════════════════════
```

**D — User decision.**

| Verdict | Options | Gate |
|---|---|---|
| STRONG | [Keep as-is, Enhance anyway, Next] | T3 |
| ENHANCE | [Apply enhancements, Edit suggestions, Keep as-is, Delete] | **[T3]** for enhance, **[T1: all levels ask]** for delete |
| DELETE | [Delete, Keep anyway, Enhance instead] | **[T1: all levels ask]** for delete |

**If Apply enhancements**: Present specific patches (which sections, what content, which registry fields). Approve → patch PAT file and registry fields. Verify after patching.

**[T3: Full ask | Balanced: notify | Streamlined: auto-approve enhancements, log [AUTO]]**

**If Delete**: **[T1: all levels ask]** — "Retire PAT-XXX ({name})? This archives the pattern (reversible — moved to .nexus/archived/patterns/), not a hard-delete."
If confirmed: load `/nexus-delete-pattern` in backend mode with pattern ID (it archives by default).

**If Keep**: Move to next pattern.

> **Mental note**: {id} examined. Verdict: {verdict}. Action: {taken}. If checkpoint → save examination results.

**E — Loop.** After completing one pattern: "Examine another? [Y/n]"
- Yes → return to 2A (re-display list minus examined patterns)
- No → return to 1E menu

If patterns were deleted/enhanced: recalculate Tier 1 metrics before re-displaying menu.

---

### STEP 3: Tier 3 — Similarity Analysis

Find patterns that overlap enough to consider merging. Registry-level analysis first, deep comparison delegated to /nexus-merge-patterns.

**A — Identify candidate pairs.** For each unique pair of non-principle patterns, assess overlap using registry fields:
- `description`: Similar problem domain or concept?
- `use_when`: Overlapping trigger scenarios?
- `domain`: Same domain?
- `type`: Same type?

Use semantic judgment — different words, same concern. Flag pairs where one could absorb the other.

If no candidates found: display "Patterns are sufficiently distinct — no merge candidates." Return to 1E menu.

**B — Present candidates.**

**[T3: Full ask | Balanced: notify | Streamlined: auto-present, notify]**

```
════════════════════════════════════════════════════════════
🔍 SIMILARITY ANALYSIS — Candidate Pairs
════════════════════════════════════════════════════════════

{N}. {id_a} {name_a}  ↔  {id_b} {name_b}
    Overlap: {description}
    Why merge might help: {rationale}

════════════════════════════════════════════════════════════
```

**C — Per pair decision.**

**[T1: all levels ask]** — Merging retires the absorbed pattern (archived via /nexus-delete-pattern, reversible — not a hard-delete).

Options via AskUserQuestion per pair: [Merge (deep analysis), Keep separate, Skip]

If Merge: load `/nexus-merge-patterns` in backend mode with `candidate_pair: {id_a, id_b}`. merge-patterns handles loading, comparison, keeper determination, execution.

On return: note result (merged or kept-separate). If merged, registry has changed.

**D — After all pairs processed.** Return to 1E menu. If merges occurred, recalculate Tier 1 metrics before re-displaying.

---

### STEP 4: Finalize

Runs after Exit from menu (**operation complete** signal for /nexus-maintain).

**A — Calculate final score.** Same formula as STEP 1D, using current registry state (post-changes).

Update system-state [Health-Operations] pattern_maintenance:

```yaml
pattern_maintenance:
  score: {final_score}
  last_run_sprint: {current_sprint}
  {if Value/Dedup Audit ran this cycle (STEP 1.5)}: last_value_audit_sprint: {current_sprint}
```

After write: verify by reading back. (Per Two-Place-Update registry-insert rule, grep `last_value_audit_sprint` first — patch the existing key if present, do not append a duplicate.)

**[T3: Full ask | Balanced: notify | Streamlined: silent]**

**B — Save report** (if requested, or if significant changes were made).

**[T3: Full ask | Balanced: notify | Streamlined: auto-save if changes, silent]**

Write to `.nexus/Maintenance-cycles/{sprint}/pattern-maintenance-report.md`:

```markdown
# Pattern Maintenance Report — Sprint {NNN}
*Date: {YYYY-MM-DD}*

## Tier 1: Registry Scan
- Active patterns: {count}
- Avg effectiveness: {percentage}%
- Strong: {count} | Adequate: {count} | Attention: {count} | Poor: {count}

## Initial Assessment
- Score before changes: {initial_score}/100

## Tier 2: Deep Qualification
- Examined: {count}
- Enhanced: {list or "none"}
- Deleted: {list or "none"}
- Kept as-is: {list or "none"}
- Registry metadata corrected: {list or "none"}

## Tier 3: Similarity
- Candidate pairs: {count}
- Merges executed: {list or "none"}
- Kept separate: {list or "none"}

## Final Health Score
- Score: {score}/100 (delta: {+/-N} from initial)
```

### End-of-Workflow Checklist

⛔ GATE: All must pass before displaying completion summary.

```
- [ ] All PAT file changes verified on disk
- [ ] All registry field updates verified (triggers, description, metadata corrections)
- [ ] system-state [Health-Operations] pattern_maintenance updated with final score
- [ ] system-state update verified by reading back
- [ ] Initial score captured (for Maintain degradation tracking)
- [ ] Deleted patterns confirmed removed (if any deletions)
- [ ] Merged patterns confirmed (if any merges)
```

**C — Display completion summary:**

```
════════════════════════════════════════════════════════════
✅ PATTERN MAINTENANCE COMPLETE
════════════════════════════════════════════════════════════

Initial score: {initial_score}/100
Tier 1: {count} patterns scanned
Tier 2: {examined} examined, {enhanced} enhanced, {deleted} deleted
        {metadata_corrected} registry fields corrected
Tier 3: {pairs} pairs analyzed, {merged} merged

Final score: {final_score}/100 (delta: {+/-N})
{if report}: Report: Maintenance-cycles/{sprint}/pattern-maintenance-report.md
════════════════════════════════════════════════════════════
```

> **Mental note**: Pattern maintenance complete. Score: {initial}→{final}. Changes: {enhanced} enhanced, {deleted} deleted, {merged} merged. Operation complete — returning to caller.

---

## Gate Reference

| Gate | Step | Tier | Full | Balanced | Streamlined |
|---|---|---|---|---|---|
| Value/dedup audit (periodic) | 1.5 | T3 | Notify | Notify | Auto-run if due (≥3 sprints), notify |
| Menu selection | 1E | T3 | Ask | Notify | Auto-sweep: Tier2 (Poor→Attention) → Tier3 → Exit |
| Pattern selection | 2A | T3 | Ask | Notify | Auto: Poor first, then Needs Attention |
| Enhancement approval | 2D | T3 | Ask | Notify | Auto-approve, log [AUTO] |
| **Pattern deletion** | **2D** | **T1** | **Ask + rec** | **Ask + rec** | **Ask + rec** |
| Merge pair review | 3B | T3 | Ask | Notify | Auto-present, notify |
| **Pattern merge** | **3C** | **T1** | **Ask + rec** | **Ask + rec** | **Ask + rec** |
| System-state write | 4A | T3 | Ask | Notify | Silent |
| Report save | 4B | T3 | Ask | Notify | Auto-save if changes, silent |

---

## Error Recovery

| Problem | Recovery |
|---------|----------|
| Registry load fails | Cannot proceed. Offer backup restore or cancel. |
| PAT file load fails (Tier 2) | Skip pattern, inform user. Suggest registry-cleanup. |
| Enhancement patch fails | Show intended changes. User can apply manually or retry. Continue. |
| merge-patterns delegation fails | Report failure, both patterns unchanged. Continue. |
| delete-pattern delegation fails | Report failure, pattern remains. Continue. |
| System-state update fails | Report score to user. Can be updated manually. |
