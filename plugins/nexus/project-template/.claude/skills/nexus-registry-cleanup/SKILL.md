---
name: nexus-registry-cleanup
description: Clean and optimize registry data integrity
disable-model-invocation: true
---
*Version: 2.4.0 | Date: 2026-08-27 | Sprint: 111*

# Registry Cleanup

**Flow**: Load → Tier 1 (entities) → Tier 2 (docs) → Tier 2-bis (cross-consumer) → [Scan boundary] → Propose fixes → [T2: approve] → Apply → Report

Three-tier validation of all 4 active registries. Tier 1 (issues + patterns): full spec-based validation with 11 checks each, plus check L (derived-value recompute) on patterns. Tier 2 (documentation): structural validation with 4 checks. Tier 2-bis (cross-consumer enum): validates each registry against the SKILLS THAT FILTER ON IT, not against its spec — the tier that catches a consumer whose filter matches nothing while every structural check passes (ISS-240 instance 5).

Severity levels: CRITICAL (ghosts, duplicates, missing required schema fields), IMPORTANT (orphans, empty mandatory content, broken cross-references, score drift), MINOR (count mismatch, invalid enums/scores, extra fields, unexpected directory files).

Fix ordering: ghosts first — they cause cascading cross-reference breaks. Then by severity descending. After ghost fixes, re-validate cross-references for cascade resolution.

---

### STEP 0: Load Resources

Load all 4 registries (memory-first):
- `Read .nexus/active/registries/issues-registry.yaml`
- `Read .nexus/active/registries/patterns-registry.yaml`
- `Read .nexus/active/registries/documentation-registry.yaml`
- `Read .nexus/active/registries/changelog-registry.yaml`

Extract entry counts and verify against declared totals.

Load spec sections:
- `Read .nexus/templates/issue-specification.md` section [Registry-Schema]
- `Read .nexus/templates/pattern-specification.md` section [Registry-Entry-Structure]

These are the authoritative field definitions for schema compliance checks.

List directories: `.nexus/issues/`, `.nexus/patterns/`, `.nexus/human-guides/`.

Display summary: entry counts per registry, specs loaded, directories scanned. If any registry fails to load, inform user and skip that tier.

---

### STEP 1: Tier 1 — Entity Registry Validation

Run the checks below against both issues-registry.yaml and patterns-registry.yaml. The checks are structurally identical — apply to ISS entries against issues/ directory, then PAT entries against patterns/ directory. Record each finding with severity, entity ID, problem description, and proposed fix.

**Differences between the two registries:**

| Aspect | Issues (ISS) | Patterns (PAT) |
|--------|-------------|----------------|
| Format | Prefixed (`ISS-XXX.field:`) | Prefixed (`PAT-XXX.field:`) |
| Count field | `total_active` | `meta.active` |
| Schema source | issue-specification [Registry-Schema] | pattern-specification [Registry-Entry-Structure] |
| Entity directory | .nexus/issues/ | .nexus/patterns/ |
| Score fields | analyzed, implemented, evaluated (1–5) | effectiveness (0.0–1.0), successes/failures (≥ 0) |
| Enum fields | status, type, priority, impact | type, maturity |
| Cross-ref fields | blocks, blocked_by (check bidirectional symmetry) | synergies, conflicts (no bidirectional check) |
| Ghost hint | "Check archived/issues/ — may have been archived without cleanup" | "Check archived/patterns/ + retired-registry.yaml — /nexus-delete-pattern archives on retirement; may have been retired without registry cleanup" |
| Sprint-state check (J/K) | J: issues in [OBJECTIVES] exist, A/I/E scores match | K: pattern IDs in [PATTERNS_IN_USE] exist in registry |

**Checks to run for each registry:**

| # | Check | What to verify | Severity |
|---|-------|---------------|----------|
| A | Ghost entries | ID in registry but file missing in entity directory. Consult differences table for archive hint. | CRITICAL |
| B | Orphan files | File in entity directory matching ID pattern but no registry entry | IMPORTANT |
| B2 | Unexpected files | Files in entity directory not matching the ID pattern | MINOR |
| C | Duplicates | Same ID prefix appears more than once. Also check for different entities accidentally assigned the same ID. Show all anomalies with details. | CRITICAL |
| D | Count | Declared count field ≠ actual entry count | MINOR |
| E | Schema compliance | Missing required fields per loaded spec. Note extra fields not in spec. | CRITICAL (required missing), MINOR (extra) |
| F | Mandatory content | Required fields present but empty, null, or placeholder | IMPORTANT |
| G | Score bounds | Scores outside valid range per registry type | MINOR |
| H | Enum validity | Enum fields contain values not in allowed set | MINOR |
| I | Cross-references | Referenced IDs don't exist in registry. Check bidirectional symmetry per differences table. Run AFTER ghost check — flag refs to ghosts specifically as cascade. | IMPORTANT |
| L | Derived-value recompute (**patterns only**) | Any stored value derivable from its own stated formula is RECOMPUTED and diffed, never trusted. Applies to `effectiveness`. **Parse the formula from `pattern-specification.md` at run time — never restate it here.** See the note below. | IMPORTANT |

**Sprint-state additional checks** (only during active non-maintenance sprint):

| # | Registry | Check | Severity |
|---|----------|-------|----------|
| J | Issues | Issues in sprint-state [OBJECTIVES] exist in registry. A/I/E scores match between registry and sprint-state for in_progress issues. | IMPORTANT |
| K | Patterns | Pattern IDs in sprint-state [PATTERNS_IN_USE] exist in patterns-registry. | IMPORTANT |

Run check J during the issues pass and check K during the patterns pass.

**Allowed enum values:**

| Registry | Field | Allowed values |
|----------|-------|---------------|
| Issues | status | Open, In-Progress, Resolved, Rejected, Superseded |
| Issues | type | Bug, Feature, Improvement, Refactor, Documentation, Question, Research, Creative |
| Issues | priority, impact | Critical, High, Medium, Low |
| Patterns | type | principle, methodology, practice, solution |
| Patterns | maturity | emerging, validated, proven, established |

**Check L — parse the formula, do not remember it.** `pattern-specification.md` states the effectiveness formula in a fenced block; read it there and recompute each pattern from its own `successes`/`failures` (neutral excluded). Restating the formula in this file would make this check a hand-copied second copy of the thing it validates — the exact defect class it exists to catch.

> This is not hypothetical caution. At ISS-240 Phase 0 a recompute was run against a formula that had been **assumed** rather than read — Laplace `(s+1)/(s+f+2)` — and it reported **31 of 56 patterns drifting**: a confident, well-formatted, entirely false finding set. Against the formula the spec actually states, drift was **zero**. An unaudited instrument produces findings that look exactly like real ones (📐 PAT-138).

| Condition | Verdict |
|---|---|
| Formula parses, all rows recomputable | `FILLED: {drift} findings / {bound} bound (patterns recomputed) / {candidates} candidates (rows with an effectiveness field)` |
| The stated formula does not parse from the spec | **`ESCALATED: bound 0 (formula)`** — do **not** fall back to a remembered formula |
| A row carries `effectiveness` with no `successes`/`failures` pair | counted as a candidate, not as bound → `bound < candidates` → **`ESCALATED`** |

**Instrument-audit arm** (📐 PAT-138, run once when the check changes): re-run with a deliberately wrong formula and confirm the output is *visibly different* from the correct-formula run. Executed at ISS-240 Phase 4.2 (Sprint 111): correct formula `0 findings / 56 bound / 56 candidates`; Laplace `31 findings / 56 bound / 56 candidates` — reproducing the recorded delta exactly. A third arm perturbed one stored value by 0.05 and it was reported; a fourth reworded the formula in the spec and the check ESCALATED rather than guessing.

Run issues registry first, then patterns. Display results per registry with error count per severity. If a registry has no errors, show "✅ All checks passed ({n} entries validated)."

> **Mental note**: Tier 1 complete. Issues: {n} findings. Patterns: {n} findings (incl. check L recompute). If checkpoint → save findings summary to continue_with.

---

### STEP 2: Tier 2 — Documentation Registry

Structural validation of documentation-registry.yaml:

| # | Check | What to verify | Severity |
|---|-------|---------------|----------|
| A | Ghost guides | status ≠ 'planned' but file missing in human-guides/ | CRITICAL |
| B | Status accuracy | status = 'planned' but file exists on disk | IMPORTANT |
| C | Schema completeness | Always required: title, filepath, status, category, target_level, topics, description. Additionally required when status ≠ 'planned': size_kb, created, last_updated. | MINOR |
| D | Category consistency | Guide's category field doesn't match its listing in categories groups. Category group lists a non-existent guide key. | MINOR |

Display results.

> **Mental note**: Tier 2 complete. Documentation: {n} findings. If checkpoint → save all findings to continue_with.

---

### STEP 2-bis: Tier 2-bis — Cross-Consumer Enum Validation

Tiers 1 and 2 validate a registry against its **spec**. This tier validates it against its **consumers** — the external skills that filter on its fields. It exists because the other two cannot see the defect it catches.

> **The anchor case, and why structural validation missed it for years.** `/nexus-staleness-checker` STEP 1 filtered `status: created` while `documentation-registry.yaml` has only ever held `active` / `planned`. It matched **0 of 21 guides on every run for its entire life**, and the resulting empty report read as *"documentation is fine"*. Throughout, **this skill scored that registry 100** — because every field was present, every enum value was in the allowed set, and every guide file existed. Structure was flawless. The registry and its consumer simply did not share a vocabulary, and nothing compared them. (ISS-240 instance 5, the severest of the nine: the other eight produce stale data a careful reader can catch; this one produced **no data at all**.)

**The consumer table** — for each registry field an external skill filters on, name the producer, the consumer, and the field. Extend this table when a new skill starts filtering on a registry field:

| Registry | Field | Producer (writes it) | Consumer (filters on it) | Manifest edge |
|---|---|---|---|---|
| documentation-registry | `status` | `/nexus-guide-creator` STEP 5B | `/nexus-staleness-checker` STEP 1 | E-09 |
| documentation-registry | `status` | `/nexus-guide-creator` STEP 5B | `/nexus-help` STEP 1.B / 2.1 / 2.2 / 3.2 | E-09 |
| documentation-registry | `status` | `/nexus-guide-creator` STEP 5B | **this skill**, Tier 2 check B (`planned` only) | E-09 |
| patterns-registry | `effectiveness` | `/nexus-update-pattern` | `/nexus-match-pattern` STEP 2 (scores on it), STEP 0 (filters on it) | E-10 (see Tier 1 check L) |
| issues-registry | `status` | `/nexus-close-issue` (`Resolved`/`Rejected`), `/nexus-work-issue` (`In-Progress`), `/nexus-decompose-issue` (`Decomposed`) | `/nexus-view-issues` STEP 1 (`status IN [Open, In-Progress]`) | **E-15** |

⚠️ **Coverage is partial and the table says so rather than implying otherwise.** Only rows whose `Manifest edge` column names an edge with an *executable* predicate are mechanically checked; the `/nexus-help` and *this skill* rows share E-09's edge but E-09's filter-locator regex is shaped to `staleness-checker`'s scan wording and will report `ESCALATED: bound 0 (filter not locatable)` if pointed at them. Treat those two as **declared, not yet executable**. SC-03's clause "for every registry field an external skill filters on" is an *obligation on this table*, not a claim that it is already complete — and at ISS-240 Phase 4/5 it was found incomplete by exactly the grep it mandates.

Edge ids refer to `.nexus/active/derivations.yaml`, which declares the full derivation-edge set. A consumer relationship added here without a manifest row is an undeclared edge — add the row.

> **Enumerate this table FROM SOURCE, never from memory.** Its first version listed one consumer for `documentation-registry.status`; `grep` across `.claude/skills` found **three** — `staleness-checker`, `help`, and this skill's own Tier 2 check B. A table claiming *"every registry field an external skill filters on"* while listing a remembered subset is the same defect the tier exists to catch, one level up (ISS-240 Phase 4/5 adversarial review, 📐 PAT-137). Re-run the grep when adding a row.

**The check** (per table row):

1. **Candidates** = registry rows carrying the field.
2. **Locate the consumer's filter vocabulary** from the scan instruction in its source — *not* a whole-file grep. Consumers frequently **document** a superseded value in an explanatory note (`staleness-checker` records the historical `created` in an Enum note at STEP 1), and a whole-file union silently widens the vocabulary until it spans everything: a false negative wearing a passing verdict.
3. **Bound** = registry rows the located filter would actually match.
4. **Verdict**:

| Condition | Verdict |
|---|---|
| `bound > 0` | `FILLED: 0 findings / {bound} bound (matched registry rows) / {candidates} candidates (registry rows with the field)` |
| `bound == 0` while `candidates > 0` | **`ESCALATED`** — the consumer's filter matches no row. A run under this filter produces an empty report indistinguishable from a clean one. This is instance 5 exactly. |
| Filter could not be located in the consumer's source | **`ESCALATED: bound 0`** with a *different* message — a filter that cannot be found is not a filter that matches nothing, and reporting them identically hides which one happened |
| `candidates == 0` | **`ESCALATED`** — an empty candidate set is a wrong path or a real finding and the check cannot tell which |

5. **Values present but outside the filter are CLASSIFIED, never counted.** A consumer may exclude a value deliberately — `staleness-checker` skips `planned` because planned guides have no content to compare. Counting deliberate exclusions as findings makes the check satisfiable only by widening filters that are already correct (📐 PAT-142's too-broad direction). Report them as `status '{v}' present but outside the filter [CLASSIFIED — confirm deliberate exclusion, not a blind spot]`.

Findings from this tier fold into the **owning registry's** score in STEP 3 — documentation-registry findings into the documentation score, patterns-registry findings into the patterns score. No new score component.

**Fires-on-broken proof** (📐 PAT-140 — a check that reports clean on a known-broken input is instance 5 one level up). Re-run row 1 against the pre-fix consumer from git and confirm it ESCALATES:

```sh
git show b3ecaaf7:.claude/skills/nexus-staleness-checker/SKILL.md > /tmp/sc_prefix.md
# then run the check with the consumer path pointed at /tmp/sc_prefix.md
```

Executed at ISS-240 Phase 4.1 (Sprint 111) — pre-fix returned `ESCALATED: bound 0 < candidates 17 (registry rows) — the consumer's filter [created] matches NO row`; the live post-fix tree returned `FILLED: 0 findings / 16 bound / 17 candidates` with `planned` classified. A third arm renamed the registry's own values so a *correct* filter matched nothing, and it ESCALATED too — the check catches drift from either side, not only the consumer's.

Display results.

> **Mental note**: Tier 2-bis complete. Cross-consumer: {n} findings, {n} ESCALATED. If checkpoint → save findings to continue_with.

---

### STEP 3: Initial Score Assessment
<!-- SCAN BOUNDARY — Agent contract stops here in Mode B -->

Calculate the health score from validation findings BEFORE any fixes are applied. This captures the actual degraded state for degradation velocity tracking.

**Formula per registry**: `100 × (1 - (weighted_errors / max_possible))` where:
- weighted_errors = (critical × 3) + (important × 2) + (minor × 1)
- max_possible = total_entities × 3

**Changelog registry**: Score from changelog-registry.yaml entry count vs expected file count. `100 × (1 - (missing_entries / total_expected))`. If changelog-registry has no issues, score = 100.

**Overall**: `(issues × 0.35) + (patterns × 0.35) + (documentation × 0.15) + (changelog × 0.15)`, rounded to integer.

**Persist to system-state**: Update `system-state.md` [Health-Operations] registry_cleanup:

```yaml
registry_cleanup:
  score: {initial_score}
  last_run_sprint: {current_sprint}
```

This write happens BEFORE fixes so that /nexus-maintain can capture it as `op_initial_scores.registry_cleanup`. If fixes are applied later, STEP 6 overwrites with the final score.

**Display**:
```
📊 Initial Assessment: {initial_score}/100 (pre-fix baseline)
   Issues: {score}, Patterns: {score}, Documentation: {score}, Changelog: {score}
```

**When run as scan agent (Mode B)**: Write initial_score to system-state (allowed — own health score field). Return structured results and stop here. Do not proceed to STEP 4. Agents must NOT write to project data (registries, ISS files, project-state, sprint-state).

```
## Registry Cleanup Scan Results
### Initial Score: {initial_score}/100
### Findings ({total_count})
#### CRITICAL ({count})
- [{registry}] {entity}: {problem} — proposed fix: {action}
#### IMPORTANT ({count})
- [{registry}] {entity}: {problem} — proposed fix: {action}
#### MINOR ({count})
- [{registry}] {entity}: {problem} — proposed fix: {action}
### Per-Registry Scores
- Issues: {score}, Patterns: {score}, Documentation: {score}, Changelog: {score}
### Files Examined: {count}
```

> **Mental note**: Scan complete. Initial score: {initial_score}/100. Findings: {count} ({c}C, {i}I, {m}M). If checkpoint → save initial_score + findings summary. Scan boundary reached.

---

### STEP 4: Generate Fix Proposals

**[T2: Balanced+Full ask | Streamlined: auto-approve non-destructive, notify+log]**

Aggregate all errors from STEPs 1–2. Sort by severity: CRITICAL → IMPORTANT → MINOR. Ghost entries listed first within CRITICAL.

Display the proposal list:

```
🔨 FIX PROPOSALS
════════════════════════════════════════

CRITICAL ({count}):
{for each, numbered}:
{N}. [{registry}] {entity}: {problem}
    Fix: {proposed_fix}

IMPORTANT ({count}):
{for each, numbered}:
{N}. [{registry}] {entity}: {problem}
    Fix: {proposed_fix}
    {if cascade}: ↳ May auto-resolve after ghost fixes

MINOR ({count}):
{for each, numbered}:
{N}. [{registry}] {entity}: {problem}
    Fix: {proposed_fix}

════════════════════════════════════════
Total: {total} ({c}C, {i}I, {m}M)
```

Options via AskUserQuestion: [Apply all, Apply critical only, Select specific fixes, Skip fixes]

If no errors found across all tiers: display "✅ All registries healthy!" and skip to STEP 6.

---

### STEP 5: Apply Fixes

Collect user selection. Confirm the list before applying.

**Mode B note**: If findings came from scan agents, the relevant registry files were read in agent context, not main context. Read each registry section you need to patch before applying fixes.

Apply in severity order, ghosts first. Both entity registries use **prefixed format** — entries are a set of lines sharing the same ID prefix (e.g., `ISS-042.title:`, `ISS-042.status:`, etc.), not delimited YAML blocks.

**Fix procedures:**

| Fix type | Procedure |
|----------|-----------|
| Ghost entry removal | Remove all lines with the entity's ID prefix from the registry. Decrement count field. See tool guidance below. |
| Orphan file | Offer: (1) archive via move to archived/{entity_type}/, or (2) create registry entry from file metadata. |
| Duplicate entries | Display both side-by-side. User picks which to keep. Remove the other's prefixed lines. |
| Missing required field | Insert new prefixed line after entity's last field. Populate from entity file or ask user. |
| Empty mandatory field | Read entity file for value. If not derivable, ask user. Patch the prefixed line. |
| Broken cross-reference | Remove stale ID from the array field. |
| Ghost cascade reference | If ghost already removed this batch → remove ref. Otherwise treat as broken cross-ref. |
| Asymmetric reference (issues) | Add missing reciprocal. If A.blocks contains B, add A to B.blocked_by. |
| Score drift | Ask user which source is authoritative. Patch per two-place update protocol. |
| Count/enum/score bounds | Patch the specific prefixed line with corrected value. |
| Documentation fixes | Update field in nested YAML. Status 'planned' → 'active' (the guide-creator / staleness-checker enum since Sprint 109 — `created` is no longer a value) also requires size_kb, created, last_updated. |

**Tool guidance — ghost entry removal:**

Use Edit tool: `old_string` = the full entity block (comment header `# --- ISS-XXX ---` through last prefixed field line), `new_string` = `""`. Build `old_string` from the actual loaded registry content — never construct from templates. After removal, decrement count field in a separate edit.

Keys:
1. Construct find from LOADED values (not hardcoded templates)
2. Include comment header line (# --- ISS-XXX ---)
3. Include ALL prefixed lines in order they appear in the file
4. Include trailing newline after last field
5. After removal, separately patch count field (total_active or meta.active)

**Post-fix revalidation:** After all ghost fixes are applied, re-run cross-reference checks (1I). Display how many cascade errors auto-resolved vs how many remain.

After all fixes: verify each modified registry by reading back and spot-checking patched entries.

Display results: fixes applied vs failed, with brief details for any failures.

> **Mental note**: Fixes applied: {applied}/{total}. Cascades auto-resolved: {n}. If checkpoint → save fix results to continue_with.

---

### STEP 6: Health Score and System-State Update

Calculate per-registry health on a 0–100 scale using remaining errors after fixes:

**Formula**: `100 × (1 - (weighted_errors / max_possible))` where weighted_errors = (critical × 3) + (important × 2) + (minor × 1), max_possible = total_entities × 3. Clamp to 0–100.

**Changelog**: `100 × (1 - (missing_entries / total_expected))`.

**Overall**: `(issues × 0.35) + (patterns × 0.35) + (documentation × 0.15) + (changelog × 0.15)`, rounded to integer.

Update system-state.md [Health-Operations] registry_cleanup:

```yaml
registry_cleanup:
  score: {overall_score}
  last_run_sprint: {current_sprint}
```

After write: verify by reading back the score from system-state.

Display: `📊 Final Score: {overall_score}/100 (was {initial_score}/100, delta: {+/-change})`

> **Mental note**: Final score: {overall_score}/100 (delta: {change}). If checkpoint → score persisted, resume at STEP 7 report.

---

### End-of-Workflow Checklist

⛔ GATE: All must pass before displaying final report.

```
- [ ] All approved fixes applied and verified on disk
- [ ] Post-fix cascade revalidation completed (cross-refs re-checked)
- [ ] system-state [Health-Operations] registry_cleanup updated with final score + last_run_sprint
- [ ] system-state update verified by reading back
- [ ] Initial score captured (for Maintain degradation tracking)
```

---

### STEP 7: Final Report

```
🔧 REGISTRY VALIDATION COMPLETE
════════════════════════════════════════
Sprint: {XXX} | Date: {YYYY-MM-DD}

📋 TIER 1 — Issues + Patterns:
• Issues: {n} entries, {e} errors ({c}C {i}I {m}M)
• Patterns: {n} entries, {e} errors ({c}C {i}I {m}M)

📚 TIER 2 — Documentation:
• {n} guides, {e} errors

🔨 FIXES:
• Proposed: {total} | Applied: {applied} | Skipped: {skipped}
• Post-fix cascade: {n} auto-resolved

📊 HEALTH (0–100):
• Issues:        {score}
• Patterns:      {score}
• Documentation: {score}
• Changelog:     {score}
• Overall:       {score} (initial: {initial_score}, delta: {+/-change})

{if remaining errors}: ⚠️ {count} issues remaining
════════════════════════════════════════
```

**[T3: Full ask | Balanced: notify | Streamlined: auto-save if fixes were applied]**

If remaining unfixed errors or significant fixes applied: offer to save report to `.nexus/Maintenance-cycles/{sprint}/registry-cleanup-report.md`.

---

## Parallel Scan — Mode B Agent Contracts

When dispatched by /nexus-maintain in Mode B, registry-cleanup can run as **4 parallel sub-agents** instead of one:

| Agent | Scope | Loads | Checks |
|---|---|---|---|
| Agent 1: Issues | issues-registry.yaml + issue-specification [Registry-Schema] + .nexus/issues/ listing | 3 reads | Checks A-K (issues pass) |
| Agent 2: Patterns | patterns-registry.yaml + pattern-specification [Registry-Entry-Structure] + .nexus/patterns/ listing | 3 reads | Checks A-**L** (patterns pass; L = derived-value recompute) |
| Agent 3: Documentation | documentation-registry.yaml + human-guides/ listing | 2 reads | Checks A-D |
| Agent 4: Cross-consumer | `.nexus/active/derivations.yaml` (**every row whose `runs_at` is this skill** — currently E-09, E-10, E-15; read the field, do not trust this list) + each consumer skill named in the STEP 2-bis table | 1 + N reads | **Tier 2-bis** — cross-registry by construction, so it cannot be folded into Agents 1-3 |

> ⛔ **This table is a derived copy of the tier definitions above it — re-derive it whenever a check or tier is added.** It was found stale at ISS-240 Phase 4/5 (independent review, Sprint 111): check L and Tier 2-bis had both landed *before* the `<!-- SCAN BOUNDARY -->`, so both were inside the agent contract while no agent owned them — meaning neither would have run on the Mode B path `/nexus-maintain` dispatches every cycle. The literal string `checks A-K` was corrected in `NEXUS-Architecture.md` in the same change set and missed **here, in the skill that changed**. Declared as the reason this row exists.

Each agent returns findings in the structured format from STEP 3. Main context aggregates, calculates overall initial_score, and proceeds to STEP 4.

---

## Error Recovery

| Problem | Recovery |
|---------|----------|
| Registry load fails | Skip that tier. Inform user, suggest backup restore. |
| Spec section not found | Fall back to hardcoded required field list for that registry type. |
| Fix patch fails | Report what was intended. User can apply manually. Continue with next fix. |
| System-state update fails | Report score to user, continue — score can be updated manually. |
| Changelog-registry empty or missing | Score changelog component as 0, note gap. Other tiers unaffected. |
