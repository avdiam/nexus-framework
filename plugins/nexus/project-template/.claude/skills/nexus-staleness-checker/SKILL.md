---
name: nexus-staleness-checker
description: Check documentation staleness against recent file changes
disable-model-invocation: true
---
*Version: 3.1.0 | Date: 2026-08-27 | Sprint: 111*

# Staleness Checker

**Flow**: Load registries → Compare versions → Detect drift → Report stale guides → [T2: offer regeneration]

Check documentation staleness by comparing guide source versions against current file versions. Delegates to guide-creator for regeneration.

---

Staleness detection compares two registries: documentation-registry.yaml tells us which source file versions each guide was built from (`references` array, written by guide-creator at generation time), and changelog-registry.yaml tells us the current versions of those same files. Version drift between the two means the guide may be outdated.

This operation observes and reports — it never modifies files. Guide updates are guide-creator's job.

**Modes:** When called from /nexus-maintain Phase 5A, produce a compact summary for the maintenance report. Otherwise, produce a full interactive report with recommendations.

---

## Posture

**Skill class: verification** (detect-and-propose, non-mutating) → carries the **Verification-Class Core** per `operation-skill-template.md` §Verification-Class Core. VC-1 here, VC-2 at every verdict and exit below, VC-3 at STEP 3.

This skill runs adversarial by default. I assume the documentation set under check has a problem until scan evidence proves otherwise. A "clean" verdict is earned by showing **what was examined** — never reached by the absence of noticed problems.

This skill's specific exposure: it reports on *other* artifacts' freshness, so a run that parsed nothing produces the same reassuring output as a run that parsed everything and found nothing wrong. It has already failed this way once — STEP 1's filter read `status: created` against a registry holding only `active`/`planned`, matching **0 of 21 guides on every run for the skill's entire life**, and the resulting empty report read as "documentation is fine." That is why every terminal state below carries the bound/candidates pair.

---

### STEP 0: Load Context

Load documentation-registry.yaml and changelog-registry.yaml (memory-first). Both are required.

⛔ **Early exit 1 of 3 — VC-2 terminal state required.** If either registry fails to load, do NOT exit with a bare error line. This exit produces no findings, and a reader must be able to tell it apart from a clean run:

```
⚠️ Cannot run staleness check — ESCALATED
   Required: documentation-registry.yaml, changelog-registry.yaml
   Loaded: {N} of 2 — missing: {which}
   0 findings / 0 bound / — candidates (guides)  (candidates undeterminable: the registry that defines them did not load)
```

Terminate **ESCALATED**, never FILLED. `bound = 0` is the whole point — it says the instrument never consumed input, so the absence of findings carries no information.

Detect mode: if called from /nexus-maintain Phase 5A context, set mode to maintenance. Otherwise, manual.

**Changelog freshness check.** Read the `# Version: … | Date: … | Sprint: …` header line of changelog-registry.yaml (there is no `last_scan` metadata field — the header is the only freshness stamp). If its `Sprint:` is more than 2 sprints behind the current sprint, display a warning: "⚠️ Changelog registry last updated Sprint {N} ({date}) — results may be inaccurate. Run 'changelog scan' first for current versions." This is informational — don't block execution.

---

### STEP 1: Filter Checkable Guides

Scan documentation-registry.yaml for guides with `status: active` AND a `references` array containing at least one entry. These are the only guides that can be meaningfully checked — planned guides have no content or references to compare.

> **Enum note** (Sprint 109): the canonical written-guide status is `active`, not `created`. This filter read `status: created` from creation until Sprint 109 while the registry has only ever held `active` / `planned`, so it matched 0 of 21 guides and exited here on every run — a clean-looking null that read as "documentation is fine". `/nexus-guide-creator` STEP 5B was corrected in the same edit; `/nexus-help` (STEP 1.B / 2.1 / 2.2 / 3.2) still bound `created` until the Sprint 110 Documentation verification pass corrected it — so three skills bind this enum (`/nexus-registry-cleanup` checks `planned` only, which is common to both vocabularies).

**Record the filter's own arithmetic before acting on it.** Three figures, computed from the registry as loaded — not from expectation:

- **candidates** — every guide entry in `documentation-registry.yaml`.
- **bound** — those whose `status` field parsed to a recognised value (`active` / `planned`). A guide whose status is absent or unrecognised is *not* bound.
- **checkable** — of the bound, those with `status: active` AND a non-empty `references` array.

⚠️ **`bound < candidates` means the filter is reading a vocabulary the registry does not use.** That is not a thin corpus — it is a broken instrument, and it is exactly how this skill failed before (filter read `created`, registry held `active`, `bound = 0 of 21`, every run reported clean). Terminate ESCALATED and name both vocabularies:

```
⚠️ Staleness filter did not consume the registry — ESCALATED
   Filter expects status ∈ {active, planned}; registry holds: {distinct values found}
   0 findings / {bound} bound / {candidates} candidates (guides)
```

If `bound == candidates` but no guide is **checkable**:

⛔ **Early exit 2 of 3 — VC-2 terminal state required.**

**Manual mode:**
```
═══ 📊 DOCUMENTATION STALENESS REPORT ═══
FILLED — no checkable guides (this is a real result, not a silent pass)

0 findings / {bound} bound / {candidates} candidates (guides)
   {N} status: planned (no content to check)
   {N} status: active but no references array

Available to create:
{for each planned guide}:
• {guide_title} — {description}

Use "create guide {name}" to generate any of these.
═══════════════════════════════════════════
```
**Maintenance mode:** Return: `"Staleness: FILLED — 0 findings / {bound} bound / {candidates} candidates (guides) ({N} planned, {N} active-without-references)"`

Exit — nothing more to do. The pair is what distinguishes this exit from the ESCALATED case above and from a genuine clean run at STEP 3.

**Guides without references.** If any guides have `status: active` but no `references` array (manually created or guide-creator bug), they can't be assessed. Note them in the report: "ℹ️ {guide_title} has no source references — staleness cannot be assessed. Run 'regenerate guide {name}' to add tracking."

---

### STEP 2: Compare References

For each checkable guide, resolve every entry in its `references` array. **Two registries are in play, not one** — resolve against `changelog-registry.yaml` first, then `documentation-registry.yaml`, and only then classify as unresolved:

| # | Situation | Meaning |
|---|-----------|---------|
| 1 | Reference version matches current version in **changelog-registry** | Source unchanged since guide was built |
| 2 | Reference version behind current version in **changelog-registry** | Source has been updated — guide may be stale |
| 3 | Reference resolves to a guide entry in **documentation-registry** (`filepath` match), not to changelog-registry | **Guide-to-guide pointer — legitimate, not a defect.** Compare against that guide's own `version`; behind → stale, equal → current |
| 4 | Reference found in **neither** registry | File may have been renamed, moved, or removed — flag for attention |

**Why row 3 exists** (SC-03): human guides live in `documentation-registry.yaml` and are never tracked in `changelog-registry.yaml`. Before this row, a guide citing another guide fell through to row 4 and reported as *"Referenced file not found in changelog-registry"* — a **correct pointer reading as a defect on every future run**. Live instance: `architecture-quick-guide` → `.nexus/human-guides/nexus-framework-guide.md` (`documentation-registry.yaml:44`), a deliberate write-once companion pointer.

⚠️ Note the failure direction. Row 3 fixes a false **positive**; the bound/candidates pair elsewhere in this skill fixes false **negatives** (vacuous passes). They are opposite defects — row 3 working is **not** evidence that the pair works.

**Reference resolution is itself bound/candidates work.** Carry the count forward to STEP 3:
- **candidates** — total `references` entries across all checkable guides.
- **bound** — entries resolved to exactly one of rows 1–4. An entry matching no row at all is a parse failure, not a finding.

**Severity judgment.** Assess each guide's overall staleness using semantic judgment rather than numeric scoring. Consider: how many references drifted, whether the drift is major versions (significant restructuring likely) or minor/patch (incremental changes, guide may still be accurate), whether the drifted files are core sources for that guide or peripheral references. A guide built from 5 source files where 3 had major version bumps is clearly stale. A guide where one peripheral source got a patch bump is probably fine.

**Categorize each guide:**

| Category | Meaning | Icon |
|----------|---------|------|
| Current | No meaningful drift | ✅ |
| Review | Minor drift — content may still be accurate | ⚠️ |
| Stale | Significant drift — regeneration recommended | 🟠 |
| Critical | Major drift or missing references — regeneration required | 🔴 |

---

### STEP 2B: Template Version Chain Check

In addition to guide staleness, check the template version chain for drift between the wizard, meta-template, and domain profiles.

**Version chain:**
```
nexus-setup-project/SKILL.md (file header version)
  └─ project-type-template.md (built_for_wizard → should match wizard version)
       └─ project-types/*.md (spec_version → should match meta-template spec_version)
                             (template_version → profile's own version)
```
**Check 1 — Wizard → Meta-template:** Read the `/nexus-setup-project` SKILL.md version from its file header. Read `built_for_wizard` from project-type-template.md. If they don't match: the meta-template was built for an older wizard version.

**Check 2 — Meta-template → Profiles:** Read `spec_version` from project-type-template.md. For each profile in `.nexus/templates/project-types/`, read its `spec_version`. If any profile's spec_version doesn't match the meta-template's: that profile was built for an older spec.

**Report template chain results alongside guide results:**

| Situation | Category | Action |
|-----------|----------|--------|
| All versions match | ✅ Current | No action |
| Profile spec_version behind meta-template | ⚠️ Review | Profile may need section updates for new spec |
| Meta-template built_for_wizard behind wizard | 🟠 Stale | Meta-template needs update for wizard changes |
| Multiple mismatches | 🔴 Critical | Template chain out of sync — update meta-template, then profiles |

Include in the report under a separate "Template Chain" heading. In maintenance mode, append to the summary line: `Template chain: {current/review/stale/critical}`.

---

### STEP 3: Report

⛔ **Terminal verdict — VC-2 required.** The report's headline is a FILLED / ESCALATED / SKIP state carrying the pair, never a bare "✅ all current".

| Condition | Terminal state |
|---|---|
| Every reference resolved (`bound == candidates`), drift assessed | **FILLED** — with the pair |
| `bound < candidates` — some reference resolved to no row | **ESCALATED** — the unresolved count is an instrument failure, not a clean result |
| A guide deliberately not assessed (e.g. `active`, no `references`) | **SKIP (justified)** — name the guide and the rule |

**VC-3 — false-clean rationalizations, refuted here at the verdict step:**

| Excuse (you might think this) | Reality |
|---|---|
| "No drift found, so the docs are current." | Absence of *detected* drift ≠ verified-current. State `{bound}/{candidates}` references resolved. This skill reported exactly this way for its entire life while matching 0 guides. |
| "The report is empty, so there's nothing to say." | An empty report is the documented failure mode here, not a null result. Empty must be qualified by which of the three exits produced it. |
| "Both registries loaded, so the comparison ran." | Loading is not resolving. A reference can resolve to no row while both registries sit in memory — that is `bound < candidates`, and it escalates. |

**Manual mode — full interactive report:**

```
═══ 📊 DOCUMENTATION STALENESS REPORT ═══
Generated: {date}
Verdict: {FILLED | ESCALATED}
{drift_count} findings / {bound} bound / {candidates} candidates (references)
   (resolved across {checked_count} checkable guides)

SUMMARY
• Guides checked: {checked_count} (of {total} total, {planned_count} planned)
• ✅ Current: {count}
• ⚠️ Review: {count}
• 🟠 Stale: {count}
• 🔴 Critical: {count}

─── GUIDE DETAILS ───
{for each non-current guide, worst first}:

{icon} {guide_title}
   Last updated: {last_updated}
   Drifted references:
   • {source_file}: guide has v{old} → current v{new}
   {repeat for each drifted reference}
   Assessment: {brief explanation of why this category}
   Action: {recommendation — "regenerate guide {name}" for stale/critical}

{if all current}:
✅ FILLED — 0 findings / {bound} bound / {candidates} candidates (references)
   All {checked_count} checkable guides current; {bound} references resolved, 0 drifted.
   (A bare "all current" is not a permitted terminal state — the pair is what
    distinguishes this from a run that resolved nothing.)

{if any active guides without references}:
─── UNTRACKED GUIDES ───
{for each}:
ℹ️ {guide_title} — no source references. Run "regenerate guide {name}" to add tracking.

─── RECOMMENDED ACTIONS ───
{if any stale or critical, highest severity first}:
{N}. Regenerate: "regenerate guide {name}" — {reason, e.g., "3 major version drifts in core sources"}
{repeat}

{if any planned guides exist}:
📋 {planned_count} guides not yet created. Use "create guide {name}" to generate.

═══════════════════════════════════════════
```

**Maintenance mode — compact summary for /nexus-maintain Phase 5A:**

Return a single summary line for `operation_results`. **It must carry the verdict and the pair** — this string is consumed verbatim by `maintenance-report-template.md`'s `{documentation_staleness}` placeholder, and a summary that drops the pair re-creates the bare zero one boundary downstream:

```
Staleness: {FILLED|ESCALATED} — {drift_count} findings / {bound} bound / {candidates} candidates (references)
  ({checked} guides checked: {current} current, {review} review, {stale} stale, {critical} critical)
{if any stale or critical}: Regenerate: {guide_names} ({count} drifted references)
```

⚠️ Do NOT summarize this to "clean" or "no issues" when handing it to the caller. `0 findings / 88 bound / 88 candidates` and `0 findings / 0 bound / 88 candidates` both summarize to "clean" — and telling them apart is the entire purpose of this skill's verdict.
---

### STEP 4: Offer Regeneration (Manual Mode Only)

Skip this step if: maintenance mode (compact report is sufficient — regeneration is a separate decision for the user after maintenance), or no stale/critical guides found.

**A — Present regeneration options.** List stale and critical guides with estimated cost:

```
─── REGENERATE STALE GUIDES? ───
{for each stale/critical guide, worst first}:
{N}. {icon} {guide_title} — {count} drifted references, ~{estimate}K tokens
```

⚠️ Each regeneration loads source files and rewrites the guide.
Use `AskUserQuestion tool`: [Regenerate all | Select specific | Skip — I'll do it later]

⛔ **Early exit 3 of 3 — VC-2 terminal state required.** If skip: this is a **SKIP (justified)**, and the justification is the user's decision — not silence. Return to caller with:

```
Staleness: SKIP (justified) — regeneration declined by user
  Verdict stands: {drift_count} findings / {bound} bound / {candidates} candidates (references)
  Deferred: {guide_names} ({count} drifted references) — re-run "check staleness" to resume
```

The findings do not evaporate because the fix was declined. A caller that receives a bare "done" cannot tell a declined regeneration from a clean corpus.

If select specific: present guide list as `AskUserQuestion tool` multi-select, then proceed with selected only.

**B — Regenerate loop.** For each selected guide:

1. Display: "── Regenerating {current}/{total}: {guide_title} ──"
2. Invoke `/nexus-guide-creator` — guide-creator handles the full workflow (load sources, introspect, compose, review, write, update registry).
3. On return: display "✅ {guide_title} regenerated."
4. If context is approaching 70%: warn and offer to pause. Remaining guides can be regenerated in a future conversation — the staleness report will still identify them.
5. Proceed to next selected guide.

**C — Summary after loop:**

```
─── REGENERATION COMPLETE ───
Regenerated: {done}/{selected}
{if any remaining}: ⚠️ {remaining} guides deferred — run "check staleness" to resume.
```

---

## End-of-Workflow Checklist

⛔ GATE: All must pass before returning to the caller. This skill has four terminal states across three early exits and one report — **the checklist is what proves the run reached exactly one of them and said so.**

- [ ] Terminal state produced: exactly one of FILLED / ESCALATED / SKIP — no bare "✅ clean", "all current", or "done"
- [ ] Bound/candidates pair reported with that state, **with its unit named** — `{candidates} (guides)` at STEP 1, `{candidates} (references)` at STEP 2/3. The two gates count different corpora; a bare number cannot say which
- [ ] `bound < candidates` → terminated ESCALATED, never FILLED
- [ ] `bound` independently derived — counted from guides the filter actually matched, never assigned from the candidate count. Two counters incremented in lockstep make the row above unsatisfiable, and this skill's historical failure (`bound = 0 of 21`) is exactly what such a row must be able to report (VC-2, ISS-240 Sprint 111)
- [ ] Every early-exit path taken this run carried its own terminal state (STEP 0 registry-load · STEP 1 no-checkable-guides · STEP 4A regeneration-declined)
- [ ] STEP 2 resolved each reference against **both** registries before classifying it unresolved (row 3 exists so a guide-to-guide pointer is not reported as a defect)
- [ ] Maintenance-mode summary carries the verdict and the pair verbatim — not summarized to "clean" for the caller
- [ ] Template chain results (STEP 2B) reported alongside guide results

### Instrument fixture — run when this skill's own output is in doubt

This skill's failure mode is a clean-looking report from a check that consumed nothing. Fire it at a broken input and confirm the output *changes*:

```bash
R=.nexus/active/registries/documentation-registry.yaml

# candidates — guide entries (top-level keys, 2-space indent)
grep -cE '^  [a-z][a-z-]*:$' "$R"                  # → 16

# control — the status value the registry actually holds
grep -cE '^    status: active' "$R"                # → 16   bound == candidates

# sabotage — a status value it does not hold
grep -cE '^    status: nonexistent-enum' "$R"      # → 0    bound == 0, ESCALATED
```

**Predicate construction is part of the fixture, not incidental to it** (📐 PAT-135 — coverage companion; the candidate set here rests on a hand-authored pattern, so VC-2 requires the literal predicate and its enumerated variants). Both bounds are load-bearing:

| Variant | Hits | Why it is written this way |
|---|---|---|
| `^    status: active` | 16 | ✅ correct — 4-space indent anchors it to an entry field |
| `status: "active"` | 0 | ❌ **too narrow** — this registry does not quote enum values; an unanchored quoted grep returns 0 and reads exactly like a broken corpus |
| `status: planned` | 1 | ❌ **too broad** — the sole hit is a *comment* at `:13` describing delisted guides, not a guide entry. Indent-anchored: 0 |

If sabotage and control produce the same report, the pair is not being computed and the verdict is unfounded. (📐 PAT-140 — a probe that cannot respond to a broken input is not measuring anything.) Execution evidence for this fixture belongs in the issue that authored it, not in this file; the command stays here so it cannot rot away from its gate (D-5).
