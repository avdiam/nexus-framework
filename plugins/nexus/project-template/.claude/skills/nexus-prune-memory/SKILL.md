---
name: nexus-prune-memory
description: Memory-layer maintenance — durability-based decay, supersession cleanup, obsolescence marking, cascade-flagging, and health reporting over .nexus/memory/*.jsonl. Run during maintenance sprints or on-demand ("prune memory").
disable-model-invocation: true
---
*Version: 1.0.1 | Date: 2026-08-20 | Sprint: 110*

# Prune Memory

Maintenance for the cross-sprint memory layer (`.nexus/memory/*.jsonl`). Keeps the active scan surface small without losing information — **removed content is preserved in archived sprint-states**, so memory removal reduces scan cost, it does not lose history.

**Invoked**: maintenance sprints (`/nexus-maintain` Phase 5A Optional Checks — dry-run always, apply [T1]), or on-demand ("prune memory" / "memory maintenance"). Load this file and follow it.

**References**: schemas → `.nexus/memory/SCHEMA.md`; read/trust rule → CLAUDE.md [Section: Memory-Read-Rule]; durability classes → SCHEMA.md §Conventions.

**Default mode is dry-run**: identify + present candidates, then act only on approval. Deletions are **[T1: all control levels ask]** — they change what future reads see.

---

## Decay thresholds

| Class | Action | Threshold |
|---|---|---|
| `enduring` | Never auto-decay | — (only superseded/obsolete handling applies) |
| `bounded` | **Consolidate** | linked issue/sprint closed AND `(current_sprint − record.sprint) ≥ N` |
| `bounded` | **Remove** | linked issue/sprint closed AND `(current_sprint − record.sprint) ≥ 2N` |

`N = 10` (consolidate after 10 sprints, remove after 20). A `bounded` record whose linked issue is still Open never decays regardless of age.

---

## Process

### STEP 0 — Load
Read the 7 `.nexus/memory/*.jsonl` files + `issues-registry.yaml` (for issue Open/Resolved status) + current `_sprint` from sprint-state. Skip files holding only the safety marker.

### STEP 1 — Health report (always, even in dry-run)
Per file: record count, byte size, oldest/newest sprint, count by `durability`, count `superseded`/`still_valid:false`, count carrying `contradicts`. Flag any file > 200KB (SCHEMA.md scale projection ceiling).

```
🧠 Memory Health
| file | records | size | bounded | enduring | superseded/invalid | contradicts |
...
Flags: {file > 200KB, or "none"}
```

### STEP 2 — Identify candidates (no writes yet)

1. **Decay** — `bounded` records past the consolidate/remove thresholds (linked issue Resolved/Rejected in registry, or its sprint archived).
2. **Supersession** — `decisions` with `superseded_by:set` older than N sprints → removal candidates (chain preserved in archives).
3. **Obsolescence** — `discoveries` a maintenance pass judges no longer true → mark `still_valid:false` (do not delete; demotes from active reads).
4. **rejected_patterns reconciliation** — duplicates/near-duplicates → merge, summing `times_seen` and unioning `previously_seen_in`.
5. **work_debt status reconciliation** — for each `work_debt` record with `status:"unresolved"`, check `issues-registry.yaml`: if its `issue` (or a later ISS that addressed it) is now Resolved/Rejected, set `status:"resolved"` + `resolved_by:{ISS-id or sprint}` (sanctioned in-place edit). Without this, organize-sprint keeps surfacing already-fixed debt as outstanding.
6. **Cascade flag** (locked rule) — for every record gaining `still_valid:false` or `superseded_by` (this pass or already set), walk its `related_to` + `contradicts` edges and flag the *dependents* for human review ("a record this one depends on was just invalidated"). Reuses existing fields — no new field.

### STEP 3 — Present (dry-run output)
Group candidates by action (Consolidate / Remove / Mark-invalid / Merge / Cascade-review). Show id, sprint, one-line content, and the reason per candidate. Totals per group.

### STEP 4 — Apply **[T1: all levels ask]**
Confirm per group (or "apply all"). Then:
- **Consolidate**: replace a cluster of bounded records with one summary record (`durability` stays `bounded`, `id` = earliest id + `+`); keep the summary, drop the originals.
- **Remove**: delete the line(s). (Content lives in archives.)
- **Mark-invalid**: set `still_valid:false` in place (the sanctioned in-place edit; not a reorder).
- **Reconcile work_debt**: flip `status` → `resolved` + set `resolved_by` in place for debt whose issue is now closed.
- **Merge**: combine rejected_patterns records.
- **Cascade-review**: surface the flagged dependents to the user — do NOT auto-mutate them.

Never touch line 1 (safety marker). Preserve append order for untouched records. **Consolidate/remove reorder/shift lines and therefore invalidate the prompt-prefix KV-cache from the edit point onward** — this is precisely why pruning is **maintenance-only, never inline** during normal work (the append-only write path preserves the cache; pruning consciously trades it at maintenance cadence).

### STEP 5 — Verify (MANDATORY)
Per modified file, run per-line `json.loads`:
```
python -c "import json,sys;[json.loads(l) for l in open(sys.argv[1],encoding='utf-8') if l.strip()];print('OK')" .nexus/memory/{file}.jsonl
```
Non-OK → fix the offending line and re-validate before finishing.

⛔ MANDATORY OUTPUT after applying (must appear in response):
⛔ [WRITE-VERIFIED — BATCHED] prune-memory
| File | Anchor (literal substring from disk) | Status |
|---|---|---|
| {each modified file} | {an id that survived / was edited} | present/missing |

### STEP 6 — Report
```
🧹 Prune complete
• Consolidated: {n}   • Removed: {n}   • Marked invalid: {n}   • Merged: {n}
• Cascade-review flagged: {n} (surfaced, not mutated)
• Size before → after: {per file}
All modified files json.loads-valid ✓
```

---

## Safety notes
- **Append-only is the default**; this skill is the *only* sanctioned in-place editor of memory files, and only for: `still_valid` flips, `superseded_by` sets, rejected_patterns merges, decay consolidation/removal.
- **No information loss** — every removal's content remains in `Sprints/NNN/final-sprint-state.md` and archived ISS files. Memory is a derived cache.
- **Dormant dense layer** (SCHEMA.md §Deferred) is not touched here — it is unbuilt.
