---
name: nexus-index-sprint
description: Internal memory-layer writer — extracts decisions, discoveries, work-debt, rejected-patterns, issue-learnings, sprint summary, and sprint index from a frozen sprint-state + archived ISS files into .nexus/memory/*.jsonl. Invoked by /nexus-close-sprint (not user-facing).
disable-model-invocation: true
---
*Version: 1.3.0 | Date: 2026-08-19 | Sprint: 108*

# Index Sprint → Memory

Writes the 7 cross-sprint memory files (`.nexus/memory/*.jsonl`) from a **frozen** sprint-state and the sprint's archived ISS files. The LLM is the extraction engine — read sprint-state sections, classify, format schema-valid JSONL records, append.

**Invoked by**: `/nexus-close-sprint` STEP 8B (after STEP 5 archival, so `archived_file` paths exist; before STEP 9C-2 clears sprint-state sections). **Load** this file (`disable-model-invocation`); do not call via the Skill tool.

**Reference**: field schemas + conventions → `.nexus/memory/SCHEMA.md`. Read-rule → CLAUDE.md [Section: Memory-Read-Rule].

**Principle**: append-only. Never rewrite or reorder existing records (preserves KV-cache + audit trail). Line 1 of each file is the safety marker — never touch it.

---

## Preconditions (verify before writing)

1. `.nexus/memory/` exists with the 7 files + safety markers. If a file is missing → recreate it with its safety-marker line (see SCHEMA.md), then proceed.
2. Sprint-state sections are in memory (close-sprint STEP 0 loaded them). Need: metadata (`_sprint`, `_mode`, `_title`, dates), `[OBJECTIVES]`, `[DECISIONS]`, `[DISCOVERIES]`, `[CANDIDATES_PATTERNS]`, `[PATTERNS_IN_USE]`. **Not** `[SYSTEM_ISSUES]` — already consumed/cleared by STEP 6 at index time (see Ordering note below); do not rely on it.
3. Archived ISS files reachable (STEP 5 done) — for `issues_learnings`.

Compute `{S}` = current sprint number, `{conv}` = closing conversation number. Used in all IDs.

**Ordering note**: this skill runs at close-sprint STEP 8B — *after* STEP 6 Experience Processing, which already routes `[SYSTEM_ISSUES]` to created issues / fixes / seeds / skip and clears them. So do **not** re-capture system issues as `work_debt` (they are tracked elsewhere or consciously skipped) — `work_debt` here is genuinely-deferred work from `[DISCOVERIES] issues_found` and `[DECISIONS] options_for_next`, which persist until STEP 9C-2.

---

## Extraction Map (sprint-state section → memory file)

| Memory file | Source | ID format |
|---|---|---|
| `decisions.jsonl` | `[DECISIONS] made` (one record per decision) | `D{S}-{conv}` (suffix `-a/-b` if multiple in same conv) |
| `discoveries.jsonl` | `[DISCOVERIES] insights` + `innovations` | `V{S}-{nn}` |
| `work_debt.jsonl` | `[DISCOVERIES] issues_found` + deferred `[DECISIONS] options_for_next` | `WD{S}-{nn}` |
| `rejected_patterns.jsonl` | `[CANDIDATES_PATTERNS]` **not** promoted this sprint — cross-check `patterns-registry.yaml` for PATs created at STEP 4E; candidates with no matching new PAT were rejected | `RP{S}-{nn}` |
| `issues_learnings.jsonl` | each archived ISS `[Section: Closure]` + registry scores | `IL{S}-{issuenum}` |
| | *Slug resolution*: STEP 5 archival renames files to `ISS-{num}-{slug}.md`. Glob `.nexus/archived/issues/ISS-{num}*.md` to locate each file; write that exact **project-root-relative** slug path as `archived_file` (e.g. `.nexus/archived/issues/ISS-{num}-{slug}.md` — `.nexus/` prefix required; never the bare `archived/…` or `ISS-{num}.md`). Same prefix rule for `sprint_index.file` = `.nexus/Sprints/{S}/final-sprint-state.md`. | |
| `sprints_summaries.jsonl` | metadata + `[OBJECTIVES]` + `[DISCOVERIES]` key outcomes | `SS{S}` |
| `sprint_index.jsonl` | title + harvested keywords + final-state path + issue list | (keyed by `sprint`) |

**Title guard** (sprints_summaries + sprint_index): use `_title`; if `_title` is empty/blank, fall back to `Sprint {S}` — **never** a section tag (`[...]`) or an adjacent line. (A blank `_title` once produced a garbage `"[CONVERSATION]"` index title.)

**Field population**: follow SCHEMA.md exactly. Set `durability` per The-Art-of-Forgetting: architectural/principle decisions = `enduring`; issue/sprint-scoped = `bounded`. Set `importance` from the decision's framing (high if it shaped architecture/scope; medium default; low for minor). `tags` = topic keywords harvested from the source text. `related_to` = ISS IDs / other record IDs mentioned. Omit `contradicts` unless the Contradiction Handling step adds it. Never add `confidence`. Add `source_ref` only when source is not derivable from `id`/`archived_file`.

---

## Write Procedure (per file)

**ID allocation first** (`{nn}`-sequenced files — `discoveries`, `work_debt`, `rejected_patterns`): do **not** assume this sprint's sequence starts at `01`. `grep` the target file for existing `{PREFIX}{S}-` ids and continue from the highest. This skill is no longer the only writer: `/nexus-plug-seed` STEP 3B allocates a `V{S}-{nn}` mid-sprint on the finding route (ISS-233), and the on-demand *"remember this"* route in CLAUDE.md [Section: Memory-Layer] can append to any file at any time. A duplicate id still parses, so step 3 below will **not** catch it — and `id` is the unique grep anchor every `contradicts` / `superseded_by` / `related_to` pointer resolves through, in a store that is append-only.

For each target file, build the candidate records, then:

1. **Contradiction scan (grep-first, token-safe)** — for `decisions` + `discoveries` only: for each candidate, `grep` the existing file by the candidate's `tags` (and any `issue`/domain keyword). Read **only** the overlapping records (not the whole file). Apply Contradiction Handling (below).
2. **Append** the records (each a single-line valid JSON) after the last line. Do not modify existing lines.
3. **Parse-validate (write-verify, pre-mortem mit. #1)** — run per-line `json.loads` over the file:
   ```
   python -c "import json,sys; [json.loads(l) for l in open(sys.argv[1],encoding='utf-8') if l.strip()]; print('OK')" .nexus/memory/{file}.jsonl
   ```
   Non-OK → a record is malformed. Fix the offending line and re-validate before moving on. A silent malformed file is the dominant failure mode — do not skip this.

---

## Contradiction Handling — "describe, don't resolve"

(Locked behavioral delta — softens the older "halt and escalate".)

When a new `decisions`/`discoveries` record overlaps an existing one on tags/domain:

| Situation | Action |
|---|---|
| No conflict — new record complements/extends | Append normally. No edge. |
| **Tension** — new record disagrees with / partially negates an existing record, but both can stand as positions | Append the new record **with** `"contradicts":["{old-id}"]` (asymmetric — only the new record carries the edge). Surface a `⚠️ contradiction` note to the human (file, both IDs, one-line each). Do NOT back-patch the old record. Do NOT pick a winner. |
| **Resolved replacement** — new decision explicitly supersedes the old | This is supersession, NOT contradiction. Append the new record; set `"superseded_by":"{new-id}"` on the old record (the one exception to append-only — a resolved pointer, not a reordering). Do not add a `contradicts` edge. |
| **Direct policy contradiction** — new record contradicts a standing NEXUS policy/constitution/core preference | **Hard-halt.** Do not write. Escalate to the human with both statements; let them resolve. |

`⚠️ contradiction` note format:
```
⚠️ contradiction logged in {file}: {new-id} contradicts {old-id}
   {new-id}: {one-line}
   {old-id}: {one-line}
   (both preserved — describe-don't-resolve; reader applies CLAUDE.md [Section: Memory-Read-Rule])
```

---

## Output (return to close-sprint)

```
🧠 Sprint {S} indexed to memory:
• decisions: +{n}   • discoveries: +{n}   • work_debt: +{n}
• rejected_patterns: +{n}   • issues_learnings: +{n}
• sprints_summaries: +1   • sprint_index: +1
Contradictions logged: {n} (described, not resolved)
All files json.loads-valid ✓
```

⛔ MANDATORY OUTPUT (must appear in response):
⛔ [WRITE-VERIFIED — BATCHED] memory index Sprint {S}
| File | Anchor (literal substring from disk) | Status |
|---|---|---|
| decisions.jsonl | {a new D{S}- id} | present/missing |
| discoveries.jsonl | {a new V{S}- id} | present/missing |
| work_debt.jsonl | {a new WD{S}- id, or "none this sprint"} | present/missing |
| rejected_patterns.jsonl | {a new RP{S}- id, or "none"} | present/missing |
| issues_learnings.jsonl | {a new IL{S}- id} | present/missing |
| sprints_summaries.jsonl | SS{S} | present/missing |
| sprint_index.jsonl | {"sprint":{S}} | present/missing |

Any `missing` row blocks return — re-apply and re-verify.

---

## Notes

- **`sprints_summaries.jsonl` is the sole cross-sprint history file.** The former `work-history.md` was backfilled into it (104 records, sprints 001–105) and retired to `.nexus/archived/states/` in Sprint 107 — see SCHEMA.md §6 Backfill provenance. Sprint 054 has no record by design; do not "repair" that gap.
- **Backfills are one-time operations, not this per-sprint write** — both the `sprints_summaries` historical backfill (SCHEMA.md §6) and the `sprint_index` backfill (65 archived folders with a `final-sprint-state.md`, SCHEMA.md §7).
- **No embeddings.** The dormant dense-escalation layer (SCHEMA.md §Deferred) is documented, not built.
