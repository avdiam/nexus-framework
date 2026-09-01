---
name: nexus-changelog-scan
description: Scan file versions and rebuild changelog registry
disable-model-invocation: true
---
*Version: 3.2.0 | Date: 2026-08-27 | Sprint: 111*

# Changelog Scan

**Flow**: Load → Scan headers → Unexpected files → [T2: decisions] → Build versions → Domain analysis → Score → [Snapshot (modes 2-3)] → Write registry → Report

The file IS the source of truth. The registry is a derived index. Every NEXUS system file has a standardized header — scanning these headers gives accurate version data with zero manual maintenance.

**Always sequential** — not parallelizable. Interactive decisions (unexpected files) and full registry rewrite make agent dispatch impractical.

---

## Posture

**Skill class: verification** (detect-and-propose over the file corpus) → carries the **Verification-Class Core** per `operation-skill-template.md` §Verification-Class Core. VC-1 here, VC-2 at STEP 8's terminal verdict and in the End-of-Workflow Checklist, VC-3 co-located at STEP 8.

This skill runs adversarial by default. I assume the scan missed something until the count proves otherwise. A clean scan is earned by showing **how many files were expected and how many were actually parsed** — never by the absence of flagged files.

This skill's specific exposure: it reports on *versions*, so a scan whose regex matched nothing produces `0 flagged` — identical to a corpus where every header is valid. The registry is then rewritten from that empty result, and the derived index silently loses what the scan never saw. The scan's own arithmetic is the only thing that can tell the two apart, which is why **`bound` and `candidates`** are reported as a pair, with their unit named, rather than folded into a score.

---

### STEP 0: Load Context and Determine Mode

**A — Load previous state.** Read `.nexus/active/registries/changelog-registry.yaml` (memory-first). Extract: current_versions (known files), all snapshots (to preserve). Also resolve System Paths from [Section: Routing-Map] in memory to build the expected file list.

If changelog-registry doesn't exist or fails to parse: this is a first-ever or recovery scan. Note: no previous state available — domain analysis will be skipped, no snapshots to preserve, all scanned files treated as new. Continue normally.

**B — Determine mode.**

**[T3: Full ask | Balanced: notify | Streamlined: auto-select Quick, silent]**

If called from close-sprint, mode is 3 automatically — skip the prompt. Otherwise present via AskUserQuestion: [Quick scan (current versions only), Full scan with snapshot, Sprint closure snapshot (stable baseline)]

**Mode-3 `closing_sprint` parameter**: Mode-3 callers must supply the sprint number being closed (`closing_sprint: NNN`). If called from close-sprint: `closing_sprint = _sprint` from sprint-state at call time. If invoked manually outside close-sprint (deferred scan): user provides the sprint number of the sprint being closed. This ensures the snapshot ID always references the sprint being closed, not the current sprint-state context.

Mode routing: all modes run STEPs 1–4. Modes 2 and 3 additionally run STEP 5 (snapshot creation). All modes finish with STEPs 6–7.

> **Mental note**: Mode: {1/2/3}. Previous changelog: {exists/first-ever}. If checkpoint → save mode to continue_with.

---

### STEP 1: Scan System Files

**Scan paths:**

| Category | Path pattern | Expected |
|----------|-------------|----------|
| Core files | .nexus/active/*.md + .nexus/active/*.yaml + CLAUDE.md | ~4 files |
| Agents | .claude/agents/*.md | ~4 files |
| Skills | .claude/skills/nexus-*/SKILL.md | ~54 files |
| Skill sub-files | .claude/skills/nexus-*/**/*.md (excl. SKILL.md) | variable |
| Registries | .nexus/active/registries/*.yaml | ~4 files |
| States | .nexus/active/states/*.md | ~4 files |
| Templates | .nexus/templates/*.md + .nexus/templates/*.yaml (issues-registry-template.yaml carries a `# Version:` header) | ~13 files |
| Template profiles | .nexus/templates/project-types/*.md | ~13 files |

**Scanning approach:** Use Grep with a regex pattern matching the version header line, one search per category (~5–7 calls total). This returns all headers across a file group in a single call — far more efficient than reading each file individually. For "Skill sub-files", use a recursive glob (`**/*.md`) and exclude `SKILL.md` from results.

**Header format** (standard for all NEXUS files):

```
*Version: X.Y.Z | Date: YYYY-MM-DD | Sprint: NNN*
```

Note: Some older files may have Date before Version, or YAML files may use `# Version:` comment format. Handle both until header standardization is complete.

**Domain profile header format** (templates/project-types/):
```
*Domain Profile vX.Y.Z | Sprint: NNN*
```
Parse `Domain Profile v(\d+\.\d+\.\d+)` for version and `Sprint: (\d+)` for sprint. Date field is absent — use file modified timestamp. Group under `templates_project_types` category.

**YAML header format** (registries):
```
# Version: X.Y.Z | Date: YYYY-MM-DD | Sprint: NNN
```

Construct regex patterns that match both .md and .yaml formats.

For each file found, extract: filepath, version, date, sprint number. If a file has no parseable header: record version as "UNKNOWN", use file modified timestamp for date, flag as `missing_header`. Continue scanning.

Display progress summary: files scanned per category, total count, any flagged files.

> **Mental note**: Scan complete. {total} files found across {categories} categories. {flagged} with missing/invalid headers. If checkpoint → save scan results to continue_with.

---

### STEP 2: Identify Unexpected Files

**[T2: Balanced+Full ask | Streamlined: auto-include all, notify+log]**

Compare scanned files against the **expected file list**: files in the previous changelog-registry `current_versions` PLUS files resolved from System Paths in [Section: Routing-Map]. Any scanned file not in either list is unexpected.

If no previous changelog exists (first-ever scan), only System Paths define "expected." Anything beyond those is unexpected.

If unexpected files are found, present them:

```
⚠️ UNEXPECTED FILES FOUND ({count})
{N}. {filepath}
    Header: {version info or "no valid header"}
```

If ≤ 3 unexpected files: offer per-file decision via AskUserQuestion: [Include in registry, Delete file, Skip (handle manually later)].

If > 3 unexpected files: offer batch options first via AskUserQuestion: [Include all, Skip all, Review individually]. If "Review individually," proceed per-file.

Apply user decisions: include adds to scan results, delete removes the file, skip excludes from this scan.

**Removed files check.** If previous changelog existed, identify files that were tracked but are no longer found in the scan:

```
📋 PREVIOUSLY TRACKED — NO LONGER FOUND ({count})
{N}. {filepath} (was {version})
```

User can acknowledge each (drop from registry) or flag for investigation (keep with `missing_on_disk: true`).

---

### STEP 3: Build Current Versions

Organize scan results (minus skipped files) into the registry's `current_versions` structure, grouped by category:

```yaml
current_versions:
  agents:
    # keyed by agent name (nexus-scanner, nexus-researcher, …)
  core:
    CLAUDE.md: {version: "X.Y.Z", date: "YYYY-MM-DD", sprint: "NNN"}
  skills:
    nexus-analyze: {version: "2.1.0", date: "2026-03-30", sprint: "066"}
  skill_sub_files:
    # keyed by relative path
  registries:
    # ...
  states:
    # ...
  templates:
    # ...
  templates_project_types:
    # ...
```

Display scan results summary: total files tracked, version coverage, files with missing/invalid headers, latest and oldest sprint referenced.

> **Mental note**: Structure built. {total} files in {categories} categories. If checkpoint → save structure summary to continue_with.

---

### STEP 4: Domain Change Analysis

Skip if no previous changelog existed (noted in STEP 0A).

Compare current versions against the most recent stable snapshot in the previous changelog-registry. Group files by domain folder. For each domain, count changes since last snapshot:

| Change type | Definition |
|-------------|-----------|
| Major | First version digit changed (e.g., 2.x → 3.x) |
| Minor | Second digit changed |
| Patch | Third digit changed |
| New file | Exists now but not in previous snapshot |
| Removed | In previous snapshot but not found now |

Display a domain change summary table. If any domain has ≥3 major/new changes, flag it with a subsystem-verification recommendation.

---

### STEP 5: Initial Score Assessment

Calculate the health score from scan results BEFORE writing the registry. This captures the actual degraded state for degradation velocity tracking.

**Formula**: `100 × ((total_files - problems) / total_files)`, rounded to integer. Problems = files with missing/invalid headers + files with version drift (changelog entry doesn't match disk header).

**Persist to system-state**: Update `system-state.md` [Health-Operations] changelog_scan:

```yaml
changelog_scan:
  score: {initial_score}
  last_run_sprint: {current_sprint}
```

This write happens BEFORE the registry rewrite. STEP 7 overwrites with the final score.

Display: `📊 Initial Assessment: {initial_score}/100 (pre-write baseline)`

> **Mental note**: Initial score: {initial_score}/100. {problems} problems found. If checkpoint → save score + structure, resume at STEP 6.

---

### STEP 6: Create Snapshot (Modes 2 and 3 only)

Build a snapshot entry containing: snapshot ID, date, stability flag, description, total file count, and a flat map of all filenames to their current versions.

| Mode | Snapshot ID | Stable | Description |
|------|-------------|--------|-------------|
| 2 (full) | `scan_{YYYY-MM-DD}` | false | "Manual scan — not sprint boundary" |
| 3 (sprint closure) | `sprint_{closing_sprint}` | true | "Sprint {closing_sprint} completion — verified stable baseline" |

Sprint closure snapshots (stable: true) serve as rollback targets and known-good baselines.

**Snapshot retention:** Keep the last 5 stable snapshots (sprint closures). For non-stable scan snapshots, keep only the most recent. Drop older ones during this write.

---

### STEP 7: Write Registry

**[T3: Full ask | Balanced: notify | Streamlined: auto-write]**

Rewrite changelog-registry.yaml with the complete generated content:

```yaml
# changelog-registry.yaml
# Auto-generated by changelog-scan — DO NOT EDIT MANUALLY
# Version: {next_version} | Date: {scan_date} | Sprint: {current_sprint}

current_versions:
  # {organized by category, from STEP 3}

snapshots:
  # {new snapshot from STEP 6 if applicable}
  # {preserved previous snapshots per retention policy}

flagged_files:
  missing_header: [...]
```

Use Write tool. Verify the file after writing by reading back and checking entry count matches.

Merge new snapshot (if created) with preserved snapshots from STEP 0A, applying retention policy from STEP 6.

**Update system-state** [Health-Operations] changelog_scan with final score:

```yaml
changelog_scan:
  score: {score}
  last_run_sprint: {current_sprint}
```

Score: `100 × ((total_files - problems) / total_files)`, rounded. Verify by reading back.

---

### End-of-Workflow Checklist

⛔ GATE: All must pass before displaying report.

```
- [ ] changelog-registry.yaml written and verified on disk
- [ ] Entry count matches expected (scan results minus skipped)
- [ ] Snapshots preserved per retention policy
- [ ] system-state [Health-Operations] changelog_scan updated with final score
- [ ] system-state update verified by reading back
- [ ] Initial score captured (for Maintain degradation tracking)
- [ ] Terminal state produced: FILLED / ESCALATED / SKIP — never a bare "updated" or a score alone (VC-2)
- [ ] Bound/candidates pair reported **with its unit named**: {problems} problems / {bound} bound / {candidates} candidates (files)
- [ ] Per-category found/expected compared against STEP 1's Expected column — a category that globbed empty is ESCALATED, not a silent zero
- [ ] bound < candidates → terminated ESCALATED, never FILLED
- [ ] `bound` independently derived — counted from files whose headers actually parsed, never assigned from the candidate count. Two counters incremented in lockstep make the row above unsatisfiable (VC-2, ISS-240 Sprint 111)
```

---

### STEP 8: Completion Report

⛔ **Terminal verdict — VC-2 required.** The report headline is a FILLED / ESCALATED / SKIP state carrying the bound/candidates pair, never a bare "✅ updated" or a health score alone.

| Condition | Terminal state |
|---|---|
| Every expected file located and its header parsed (`bound == candidates`) | **FILLED** — with the pair |
| Files located but headers unparsed, or a scan path returned nothing | **ESCALATED** — `bound < candidates` means the scan did not consume its corpus |
| A scan path deliberately excluded this run | **SKIP (justified)** — name the path and the reason |

**The pair for this skill**, both figures already computed upstream — VC-2 requires them *reported*, not merely used:
- **candidates** — files located across the STEP 1 scan paths.
- **bound** — of those, files whose version header actually parsed (i.e. *parsed*, the gloss this skill's prose uses). `flagged_files.missing_header` is precisely `candidates − bound`.

⚠️ Report the figures as **`bound`** and **`candidates`** — the contract's words (`operation-skill-template.md` §Verification-Class Core VC-2), with the unit named. A deployment that renames them is invisible to any cross-file audit grepping the contract's vocabulary.

⚠️ **A health score is not a substitute for the pair.** `100 × ((total_files − problems) / total_files)` returns **100** both when 54 files parse cleanly and when a whole category never globbed at all — but it is undefined when `total_files = 0` and *misleading* when a whole category globbed empty, because the missing files were never counted as problems. The score describes the files the scan saw; the pair describes whether it saw them all.

**VC-3 — false-clean rationalizations, refuted here at the verdict step:**

| Excuse (you might think this) | Reality |
|---|---|
| "0 flagged files, so every header is valid." | 0 flagged is also what a regex matching nothing produces. State `{bound}/{candidates}`. |
| "The score came back 100, so the scan is clean." | The score's denominator is what the scan *found*. A category that globbed empty lowers neither numerator nor denominator — it vanishes. |
| "Every category returned results, so the scan was complete." | Returning results is not returning the expected count. Compare per-category counts against the Expected column in STEP 1 before accepting the total. |

```
✅ CHANGELOG REGISTRY UPDATED
════════════════════════════════════════
Verdict: {FILLED | ESCALATED}
{problems} problems / {bound} bound / {candidates} candidates (files)
{per-category: {category} {found}/{expected}}

Mode: {Quick / Full / Sprint closure}
Files tracked: {count}
Valid headers: {count} ({percentage}%)
Flagged: {count} files need attention
Unexpected: {count} found ({included} included, {deleted} deleted, {skipped} skipped)
{if snapshot}: Snapshot: {snapshot_id} ({stable/non-stable})

Changes from previous:
• Updated: {n} files with new versions
• Added: {n} new files
• Removed: {n} no longer found
{if flagged domains}:
💡 Subsystem verification recommended: {domain list}

Health score: {score}/100 (initial: {initial_score}, delta: {+/-change})
════════════════════════════════════════
```

**[T3: Full ask | Balanced: notify | Streamlined: auto-save if changes detected]**

Offer to save report to `.nexus/Maintenance-cycles/{sprint}/changelog-scan-report.md`.

> **Mental note**: Changelog scan complete. Score: {score}/100. {total} files tracked. If checkpoint → operation complete.

---

## Error Recovery

| Problem | Recovery |
|---------|----------|
| changelog-registry doesn't exist or corrupted | Build from scratch. Skip domain analysis. No snapshots to preserve. |
| Grep returns no results for a category | Verify directory exists. If empty, category may have been restructured — inform user. **Report as ESCALATED with `{found}/{expected}` for that category** — an empty category is invisible to the health score. |
| Header parse fails for a file | Flag as missing_header, continue. Don't stop the scan. |
| Registry write fails | Backup exists (git). Display error, suggest retry or manual intervention. |
| No files found across all paths | Stop — scan paths may be wrong. Display error with paths checked. **Terminate ESCALATED with `0 bound / {candidates} candidates (files)`**, never a bare stop: this is the skill's own `bound = 0` case, and it must not be reportable as an absence of problems. |
| System-state update fails | Report score to user. Can be updated manually. |

---

## Early-Exit Coverage — measured, not assumed

VC-2 requires the pair at **every verdict gate and every early-exit path**. This skill's exit set was derived by executable predicate rather than by hand (📐 PAT-121):

```bash
grep -nE '(^|[^A-Za-z])[Ee]xit([^A-Za-z-]|$)|[Rr]eturn to caller|nothing more to do|[Ss]top here|[Ss]kip to STEP|[Aa]bort|[Hh]alt\b|[Dd]one —|[Tt]erminate' .claude/skills/nexus-changelog-scan/SKILL.md
```

**Result: every hit falls into one of three classes, and none is a verdict-bearing early exit.** Stated as a classification, never as "grep returns N" (📐 PAT-142 — an exit criterion phrased as a count can be satisfied vacuously or by corrupting a correct file):

| Class | What it matches | Disposition |
|---|---|---|
| **VC-2 conformance text** | Checklist and verdict-table wording (*"terminated ESCALATED"*, *"never FILLED"*) | Not an exit — it is the discipline being described |
| **Error handling** | The Error Recovery table's stop-language | Not a verdict path. The two rows that stop on an empty corpus are the `bound = 0` case and now carry the pair |
| **Self-reference** | This section's heading, prose, and the literal predicate command | Not an exit — the pattern necessarily matches its own documentation |

**No raw count is recorded here, deliberately.** Before this section existed the count was genuinely 0; writing it up made the count non-zero, and writing up *that* raised it again — a predicate stated inline always matches itself, so the number never settles. Any figure committed to this file is falsified by the edit that commits it, which is a stale derived value inside the very file that produced it. **Re-derive the count at read time; the classification is what persists.**

The predicate is the widened form, verified to catch **3 of 3** known early exits in `/nexus-staleness-checker` before being trusted here. An earlier, narrower version caught only **1 of 3** and would have returned a zero here without meaning it — the zero would have been an artifact of a blind instrument, not a property of this file (📐 PAT-138, PAT-139).

The underlying finding is genuine and unchanged: this skill is linear STEP 0→8 with **no verdict-bearing early exit**. Its only stop-language is the Error Recovery table above; the two rows that terminate on an empty corpus now carry the pair, because a `bound = 0` stop is precisely what VC-2 exists to make visible.

### Instrument fixture — run when this skill's own output is in doubt

```bash
# candidates — skills the scan should locate
ls -d .claude/skills/nexus-*/ | wc -l                                          # → the real candidate count

# control — the header format the files actually carry
grep -rlE '^\*Version: [0-9]+\.[0-9]+\.[0-9]+' .claude/skills --include='SKILL.md' | wc -l

# sabotage — a header format no file carries
grep -rlE '^\*Revision: [0-9]+\.[0-9]+\.[0-9]+' .claude/skills --include='SKILL.md' | wc -l   # → 0
```

Control and sabotage must produce **different** reports. If both yield a clean scan, the pair is not being computed and the verdict is unfounded (📐 PAT-140). Execution evidence belongs in the issue that authored this, not here; the command stays so it cannot rot away from its gate (D-5).
