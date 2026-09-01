# NEXUS Memory Layer — Schema Reference
*Version: 1.3.1 | Date: 2026-08-20 | Sprint: 110 | Owner issue: ISS-152*

Canonical field schemas for the 7 JSONL memory files under `.nexus/memory/`. This is the operational reference (the design rationale lives in archived ISS-152). The LLM is the semantic engine — these files are read via **grep (keyword/tag) → LLM scan → follow pointers** (the hybrid query pattern). No embeddings, no database, no MCP server.

**Architecture principle:** *"Indexes are accelerators, not dependencies."* NEXUS works identically without the memory layer — these files are derived caches rebuildable from archived sprint-states and ISS files.

---

## Conventions (all files)

- **Format:** JSONL — one complete, standalone, valid-JSON record per line. `grep {tag}` returns whole records; `json.loads` parses every line. (Empirically re-confirmed in Claude Code CLI 2026-06-20.)
- **Safety marker (line 1 of every file):** `{"type":"_nexus_memory","source":"nexus-memory-layer","version":"1.0","file":"{name}"}` — skip this line when scanning data records.
- **`contradicts: []`** (optional, on `decisions` + `discoveries`): IDs of records in *known unresolved tension* (distinct from `superseded_by`/`still_valid:false` = *resolved replacement*). **Stored asymmetrically** — only the newer record carries the edge. `grep {old-id}` still finds both (old id appears as substring in the new record's array), so symmetric *discoverability* without back-patching the old record ⇒ append-only + KV-cache preserved. **Scope limit**: this discoverability holds only for a grep of the old `id` *within the same file*. The index-sprint contradiction scan greps by tags within `decisions`/`discoveries` separately, so a cross-file tension (e.g. a new discovery vs an old decision) is **not** auto-linked — surface those manually when noticed.
- **NO `confidence` field.** Trust is inferred at read time from `importance` + recency + `contradicts`-presence — see the shared read rule (CLAUDE.md [Section: Memory-Read-Rule]). Storing a precomputed judgment would contradict the LLM-as-engine thesis.
- **`source_ref`** added *only* where source is not derivable from `id`/`archived_file` (rare — `id` like `D069-05` maps deterministically to `.nexus/Sprints/069/final-sprint-state.md`).
- **Path pointers are project-root-relative.** `sprint_index.file` and `issues_learnings.archived_file` MUST carry the `.nexus/` prefix (e.g. `.nexus/Sprints/069/final-sprint-state.md`, `.nexus/archived/issues/ISS-139-{slug}.md`) — readers follow these pointers from the project working directory (CLAUDE.md path-resolution rule), the same base as every other NEXUS path. A bare `Sprints/…` / `archived/…` pointer will not resolve.
- **Durability:** `enduring` = valid until explicitly superseded (never auto-decays); `bounded` = decays after its linked issue/sprint closes (consolidation candidate after N sprints, removal after 2N). `/nexus-prune-memory` governs decay.

---

## 1. decisions.jsonl
What was chosen. Written: close-sprint. Read: analyze (prior art), organize-sprint (planning), on-demand.

| Field | Type | Purpose |
|---|---|---|
| id | string | `D{sprint}-{conv}` — unique anchor, grep target |
| content | string | decision text — semantic target |
| sprint | int | sprint number — range filter |
| issue | string/null | related issue — keyword filter + fulfillment anchor for bounded |
| conv | int | conversation number |
| date | string | YYYY-MM-DD |
| tags | array | topic keywords |
| related_to | array | pointers (ISS IDs / other decision IDs) |
| superseded_by | string/null | (optional — absent = null) ID of replacement, null = active |
| contradicts | array | (optional) IDs in unresolved tension — asymmetric |
| importance | string | high / medium / low |
| durability | string | enduring / bounded |

## 2. discoveries.jsonl
What was learned (technical findings, insights). Written: close-sprint, `/nexus-plug-seed` (STEP 3B — finding route, mid-sprint). Read: analyze, on-demand.
Same as decisions **minus** `superseded_by`, **plus**:

| Field | Type | Purpose |
|---|---|---|
| still_valid | bool | maintenance marks false when obsoleted |
| contradicts | array | (optional) unresolved-tension IDs — asymmetric |

## 3. work_debt.jsonl
Unresolved problems / deferred improvements. Written: close-sprint. Read: organize-sprint.
Base fields (id `WD{sprint}-{n}`, content, sprint, issue, conv, date, tags, related_to, importance) **plus**:

| Field | Type | Purpose |
|---|---|---|
| status | string | unresolved / resolved / deferred — primary organize-sprint filter |
| resolved_by | string/null | (optional — absent = null) ISS ID or sprint that resolved it |
| carried_from | int/null | (optional — absent = null) original sprint if carried forward |

## 4. rejected_patterns.jsonl
Pattern candidates not promoted at closure. Written: close-sprint. Read: close-sprint STEP 4 ("seen this before?").
Base fields (id `RP{sprint}-{n}`, content, sprint, issue, conv, date, tags) **plus**:

| Field | Type | Purpose |
|---|---|---|
| rejection_reason | string | why not promoted |
| times_seen | int | counter — incremented on reappearance |
| previously_seen_in | array | sprint IDs where seen before |

## 5. issues_learnings.jsonl
Closure knowledge from resolved/rejected issues (brief + pointer to archived ISS). Written: close-sprint archival step. Read: analyze (prior art), on-demand.

| Field | Type | Purpose |
|---|---|---|
| id | string | `IL{sprint}-{issuenum}` |
| content | string | brief learning summary |
| sprint | int | sprint number |
| issue | string | ISS ID |
| date | string | YYYY-MM-DD |
| resolution | string | resolved / rejected / deferred |
| tags | array | topic keywords |
| what_worked | array | positive learnings (brief) |
| lessons | array | key takeaways (brief) |
| patterns_applied | array | PAT IDs used |
| scores | object | {A, I, E} final scores |
| complexity | int | original complexity |
| archived_file | string | pointer to full archived ISS |

## 6. sprints_summaries.jsonl
One entry per sprint. Replaces work-history.md (functionally, going forward). Written: close-sprint. Read: context orientation, close-project (STEP 0 timeline + summary), on-demand.

| Field | Type | Purpose |
|---|---|---|
| id | string | `SS{sprint}` |
| sprint | int | sprint number |
| title | string | sprint title |
| date_range | string | YYYY-MM-DD/YYYY-MM-DD |
| issues_resolved | array | ISS IDs |
| issues_open | array | ISS IDs |
| key_outcomes | string | narrative summary |
| tags | array | topic keywords |
| convs | int | conversation count |
| mode | string | THEMED / MIXED / DEDICATED |

**Backfill provenance** (one-time, Sprint 107 — ISS-228): the historical span was transcribed from `work-history.md` before that file was retired to `.nexus/archived/states/`. The denominator is **104 records, sprints 001–105**, plus the going-forward records close-sprint has written since (`SS106` onward). Three source realities shape it:

- **Sprint 054 has no record and never will.** There is no `work-history.md` entry, `.nexus/Sprints/054/` exists but is **empty**, and there are zero references across registries, memory JSONL, or archived issues. Most likely a folder pre-created for a sprint that never ran. A fabricated placeholder would be worse than an explained absence, so the gap is **documented, not filled** — `104 = 105 sprint numbers − 054`. A re-run that expects 105 will mis-count.
- **Sprint 053 was duplicated in the source** with conflicting content (`MAINTENANCE`/16 convs vs `DEDICATED (Maintenance)`/17 convs — a corrected entry appended without removing the original). `SS53` transcribes the **second** entry, which is richer and self-reconciling. One record, not a merge; nothing invented.
- **Sprints 001–014 are field-sparse by era, not by omission.** They predate sprint modes, conversation counts, and ISS IDs, so `mode: ""` and `convs: 0` on those records mean *the project had not yet invented the field* — they are not missing data to be back-filled. `mode` first carries a real value at `SS13`.

Transcription was LLM-read rather than scripted: the source spanned three incompatible header formats plus one `###`-level outlier (sprint 034), which a `^## Sprint` parser would have silently dropped.

## 7. sprint_index.jsonl
Lightweight keyword index → pointer to archived final-sprint-state. Written: close-sprint (+ one-time backfill). Read: cross-sprint search (scan keywords → targeted archive load, no blind loading).

| Field | Type | Purpose |
|---|---|---|
| sprint | int | sprint number |
| title | string | sprint title |
| keywords | array | searchable keyword set |
| file | string | path to `.nexus/Sprints/NNN/final-sprint-state.md` (project-root-relative — `.nexus/` prefix required) |
| issues | array | ISS IDs in the sprint (empty `[]` is valid — maintenance/special sprints have no ISS work) |

**Backfill provenance** (one-time, Sprint 106): the index was backfilled from **every** `.nexus/Sprints/NNN/final-sprint-state.md` that exists = **65 records, sprints 40–105**. Sprints 1–39 predate the `final-sprint-state.md` convention and are not indexable (no pointer target); sprint **054** has an *empty* folder and no source record anywhere (known gap — see §6 Backfill provenance) and **106** was the current sprint at backfill time. So a non-contiguous sprint sequence in this file is expected, not data loss — the denominator is "folders with a final-sprint-state.md", not the raw sprint count. A re-run that expects "67" will mis-count.

---

## Deferred / dormant (documented, not built — ISS-152)

- **`general_knowledge.jsonl` (8th file)** — Entity/Relation/Observations graph for cross-domain facts. Deferred: no writer in close-sprint flow, speculative scope.
- ~~**work-history.md → sprints_summaries historical backfill**~~ — **DONE** (Sprint 107, ISS-228). 104 records for sprints 001–105 transcribed; `work-history.md` retired to `.nexus/archived/states/`. See §6 Backfill provenance.
- **Dense escalation layer** — flat numpy/cosine over `all-MiniLM-L6-v2` (384d, cosine mandatory). Trigger: measured paraphrase-miss OR memory digest > ~6K tokens. NOT Zvec until corpus is 1–2 orders larger.
