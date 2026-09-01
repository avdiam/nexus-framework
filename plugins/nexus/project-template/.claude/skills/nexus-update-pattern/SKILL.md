---
name: nexus-update-pattern
description: Update pattern effectiveness scores and metadata
disable-model-invocation: true
---
*Version: 2.2.0 | Date: 2026-08-20 | Sprint: 110*

# Update Pattern

**Flow**: Load registry → Calculate effectiveness → Patch metrics → Check maturity promotion → Report

Update pattern effectiveness scores and metadata. Metrics-only — never modifies pattern content.

---

This operation updates metrics only — it never modifies pattern file content. It can process a single pattern or a batch (when called from close-sprint for multiple patterns used during the sprint).

### STEP 0: Load Context

`Read .nexus/active/registries/patterns-registry.yaml` — targeted extraction of specific PAT-XXX metrics (memory-first). Only the fields below are needed, not the full registry.

**Tool guidance** — use Grep to extract specific pattern fields rather than loading the entire registry:
```
Grep pattern="PAT-XXX" in .nexus/active/registries/patterns-registry.yaml
```

Or if registry is already in memory from another operation, use cached data (📌).

For each pattern to update, extract current values:

```yaml
PAT-XXX.successes: {current}
PAT-XXX.failures: {current}
PAT-XXX.neutral: {current}
PAT-XXX.effectiveness: {current}
PAT-XXX.maturity: {current}
PAT-XXX.last_used: {current}
PAT-XXX.by_issue_type: {current}
PAT-XXX.phase_affinity: {current}
```

If a pattern ID is not found in the registry, warn and skip it (continue with remaining patterns in batch mode).

---

### STEP 1: Determine Outcome (Verdict)

For each pattern, determine the usage **verdict** from {helped, neutral, hindered}. (ISS-224, Sprint 105 — replaces the old {success/partial/failure} taxonomy where "partial" silently incremented `successes`. Canonical taxonomy: pattern-specification.md → Outcome Verdicts; rule: CLAUDE.md Pattern Governance → Outcome Verdicts.)

In automatic mode (called from close-sprint), the verdict is supplied by `/nexus-close-issue`'s captured verdict table (ISS [Section: Closure]) — read it together with `Read .nexus/active/states/sprint-state.md#[PATTERNS_IN_USE]`. If both sources agree, use that verdict. If they contradict — or if no verdict was captured (e.g., "applied" with no recorded result) — present both sources to the user and ask them to make the final assessment via `AskUserQuestion tool`: "helped" / "neutral" / "hindered." **Never default a verdict-less application to `helped`** — absent a recorded `helped` verdict, the floor is `neutral` (there is no path that increments `successes` without an explicit `helped`).

In manual mode, ask the user directly.

Valid verdicts:
- **helped** — pattern genuinely contributed, *beyond* what the framework already enforces → `successes += 1`
- **neutral** — applied but added no value beyond an always-on CLAUDE.md rule/preference or skill step (echo), or contribution indeterminate → `neutral += 1` (increments neither numerator nor volume-confidence)
- **hindered** — misled, added friction, or caused rework → `failures += 1`

**Dedup re-check (SC-04 hard-gate)**: before recording `helped`, confirm the pattern's guidance does not merely restate an always-on CLAUDE.md core rule/preference/trait or a skill step. If it does, cap the verdict at `neutral` — high application count is not value, and an echo-pattern must not accrue `successes`.

---

### STEP 2: Calculate New Values

Apply in this exact order:

**A. Update counters** (verdict-driven): `helped` → increment `successes`; `hindered` → increment `failures`; `neutral` → increment `neutral` (increments NEITHER `successes` NOR `failures`). There is no path where a `neutral` or missing verdict touches `successes` — this **deletes the old "success AND partial → `successes`" rule**, the confirmed inflation source (ISS-224). Update `by_issue_type`: on `helped` only, increment the count for the current issue's type (the Registry-Schema type enum as stored in `by_issue_type`: Bug, Feature, Improvement, Refactor, Documentation, Question, Research, Creative). On `neutral`/`hindered`, don't update. Set `last_used` to today (YYYY-MM-DD) on any verdict.

**B. Reinforce phase affinity**: On `helped` only, check if the current work phase is already in the pattern's `phase_affinity`. If not, and this is the 2nd+ `helped` application in that phase, add it. This lets phase affinity evolve from genuine-value evidence rather than staying fixed at creation-time inference. (`neutral`/`hindered` do not reinforce affinity — only real contribution should shape where a pattern is surfaced.)

**C. Recalculate effectiveness** — formula **unchanged** by the verdict taxonomy (per pattern-specification.md → Effectiveness Formula). Only what feeds `successes`/`failures` changed; the denominator stays `successes + failures`. **`neutral` is excluded from both the numerator and the volume-confidence denominator** — an applied-but-valueless pattern neither helps nor builds confidence, so it stays near the 0.50 seed rather than inflating. A `neutral` verdict therefore leaves `effectiveness` untouched (recompute only on `helped`/`hindered`):

```
effectiveness = 0.50 + ((success_rate - 0.50) × volume_confidence)

where:
  success_rate = successes / (successes + failures)    # 0.50 if both are 0; neutral excluded
  volume_confidence = min(1.0, (successes + failures) / 10)    # neutral excluded
```

Round to 2 decimal places.

**D. Check maturity promotion** from the updated effectiveness (per pattern-specification.md). "total applications" = `successes + failures` (neutral excluded, consistent with the effectiveness denominator — echo-applications must not promote a pattern):

| Current | Promotes To | When |
|---|---|---|
| emerging | validated | successes ≥ 3 |
| validated | proven | effectiveness ≥ 0.70 AND total applications ≥ 5 |
| proven | established | effectiveness ≥ 0.85 AND total applications ≥ 10 |

Maturity only advances automatically, never regresses.

**E. Check maturity regression concern**: If the new effectiveness drops below the threshold for the pattern's current maturity level, flag it for review — but do NOT auto-regress.

| Current Maturity | Flag If Effectiveness Drops Below |
|---|---|
| validated | (no threshold — promoted by count only) |
| proven | 0.70 |
| established | 0.85 |

If flagged, note it in the STEP 4 report as a regression concern. The actual maturity decision is handled by pattern-maintenance, not here.

---

### STEP 3: Patch Registry

Build patches using prefixed format — each field is globally unique, no mustBeNear needed.

Patch only the fields that actually changed for each pattern.

Always (any verdict):
```yaml
- find: "PAT-XXX.last_used: {old}"
  replace: "PAT-XXX.last_used: \"{new_date}\""
```

Verdict-dependent counter (exactly ONE of these per application — `helped`→successes, `hindered`→failures, `neutral`→neutral):
```yaml
- find: "PAT-XXX.successes: {old}"      # helped only
  replace: "PAT-XXX.successes: {new}"
- find: "PAT-XXX.failures: {old}"       # hindered only
  replace: "PAT-XXX.failures: {new}"
- find: "PAT-XXX.neutral: {old}"        # neutral only
  replace: "PAT-XXX.neutral: {new}"
```

Effectiveness (only when `successes`/`failures` changed — i.e. `helped` or `hindered`; a `neutral` verdict leaves effectiveness unchanged, so skip this patch):
```yaml
- find: "PAT-XXX.effectiveness: {old}"
  replace: "PAT-XXX.effectiveness: {new}"
```

Conditional patches:
- If maturity changed: patch `PAT-XXX.maturity`
- If by_issue_type updated (helped only): patch `PAT-XXX.by_issue_type` (replace entire dict value)
- If phase_affinity updated (helped only): patch `PAT-XXX.phase_affinity` (replace entire list value)

*(The `neutral` field is guaranteed present by the schema (pattern-specification.md, 16 fields) and the Sprint-105 registry migration. Per CLAUDE.md Two-Place-Update-Protocol registry-insert rule, grep the exact `PAT-XXX.neutral:` key before patching — patch the existing line, never append a duplicate.)*

**[T3: Full ask | Balanced: notify | Streamlined: auto-write]** Execute. Verify patches applied. If a patch fails, report the error and revert from the in-memory pre-image or `git checkout HEAD -- {path}` (registries are not file-backed-up — git checkpoints are the recovery).

For batch mode: combine all patches into a single Edit tool call when possible (all targeting the same registry file).

---

### STEP 4: Report Results

**Single pattern:**

```
═══════════════════════════════════════════
✅ PATTERN UPDATED
═══════════════════════════════════════════

Pattern: {pattern_id} — {name}
Verdict: {helped|neutral|hindered}

Effectiveness: {old} → {new}
Applications: {successes}✓ {failures}✗ {neutral}∅  (effectiveness counts {successes+failures}; neutral excluded)
Last used: {date}
{if maturity_changed}: 🎯 Maturity: {old} → {new}
{if by_issue_type updated}: Issue type tracked: {type}
═══════════════════════════════════════════
```

**Batch:**

```
📐 Batch Update Results
═══════════════════════════════════════════

✅ PAT-029: {old_eff} → {new_eff} ({verdict})
✅ PAT-035: {old_eff} → {new_eff} ({verdict})
⚠️ PAT-099: Not found (skipped)

Total: {N} | Updated: {N} | Skipped: {N}
═══════════════════════════════════════════
```

**Advisories** (display after results when applicable):
- Effectiveness ≥ 0.85 and total ≥ 10: "💡 Pattern is established — consider embedding into system files."
- Effectiveness < 0.30: "⚠️ Low effectiveness — review pattern relevance or consider deletion."
- Regression concern flagged (STEP 2E): "⚠️ PAT-XXX is '{maturity}' but effectiveness dropped to {eff} (threshold: {threshold}). Flag for pattern-maintenance review."
