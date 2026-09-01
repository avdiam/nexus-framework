---
name: nexus-plug-seed
description: Capture a forward-looking idea as a seed file with trigger and prune-when conditions for future surfacing. Classifies proposals (which become seeds) from findings (which route to the memory layer instead)
disable-model-invocation: false
---
*Version: 1.2.1 | Date: 2026-08-19 | Sprint: 108*

# Plug Seed

**Flow**: Classify proposal-vs-finding → Infer fields for that class → [T2: review+confirm] → Write seed file *or* append discovery → Confirm

Capture a forward-looking idea as a seed file. Seeds are conditional possibilities — ideas that might become relevant when specific conditions change. Fast capture, minimal interruption: infer fields from conversation context, present for review, write and get back to work.

**When to suggest this skill**: When a forward-looking idea surfaces during work (any phase) that the user doesn't want to stop for but doesn't want to lose. The idea depends on a future condition — it's not actionable now.

**When NOT to use**: Known problems or gaps that are actionable now → those are system issues. Deferred work we intend to do → that's a backlog issue. Assertions about how something actually behaves → those are findings, not proposals; STEP 1A catches them and routes them to `.nexus/memory/discoveries.jsonl` rather than turning them away.

**Promotion is gated separately**: Creation here is intentionally low-friction so discovery stays cheap. The substantive critical evaluation runs at promotion time (`/nexus-organize-sprint` STEP 1D.5 — Adoption Gate) where the seed is checked for concrete user-pain articulation and meaningful differentiation from existing NEXUS safety layers. Weak seeds are held in seed state with an annotated `## Adoption Attempts` entry until rewritten, not promoted prematurely.

---

### STEP 0: Load Context (silent)

Read `.nexus/seeds/.counter` — extract the next seed number.

Scan `.nexus/seeds/` for existing seed files (Glob `SEED-*.md`) to avoid ID collisions. If counter value already exists as a file, increment until a free ID is found.

**Discovery id** — consumed only if STEP 1A classifies the input as a *finding*: scan `.nexus/memory/discoveries.jsonl` for the highest `V{current_sprint}-{NN}` id. Next id is that `NN` + 1, zero-padded to two digits; if the current sprint has no record yet, start at `V{current_sprint}-01`. Allocate here rather than at the write step — a finding that reaches STEP 3 without an id is stranded at the one point where nothing can be re-inferred.

Store: `next_number`, `next_discovery_id`, `current_issue` (from sprint-state in memory), `current_sprint`.

---

### STEP 1A: Classify — Proposal or Finding (silent)

`.nexus/seeds/` holds **proposals**. It does not hold **findings** — and the difference is not cosmetic, because the two decay differently. A stale proposal is inert: it costs attention at grooming time and nothing else. A stale finding is *wrong*, and acting on it causes harm. (Sprint 107: SEED-031 asserted a harness contract, empirically confirmed by three tests when planted; the contract later inverted, and the seed's documented fix would now throw.)

| Class | Tell | Home |
|---|---|---|
| **Proposal** | Proposes future work. Has a moment it becomes actionable. Can only become *irrelevant*. | `.nexus/seeds/SEED-{NNN}-{slug}.md` |
| **Finding** | Asserts a verifiable fact about the external world — a tool's behavior, a harness contract, a library's API. Can be *inverted* by a change elsewhere. | `.nexus/memory/discoveries.jsonl` — carries `still_valid`, decay governed by `/nexus-prune-memory` |

**The kill-condition test** — one test serves both this classification and the `Prune when` field at STEP 1B: *can you name an observable event that would make this dead?* A proposal dies when its premise dissolves or its work ships elsewhere. If no such event can be stated, the input is almost always a finding wearing a proposal's clothes — classify it as a finding and let STEP 2 present that reading for the user to confirm or override.

Classification is **inferred, never asked**. Capture stays as fast as it is today: the gate count at STEP 2 remains exactly one.

---

### STEP 1B: Infer Fields (silent)

Infer fields for the class chosen at STEP 1A. Extract from conversation context — the triggering idea, surrounding discussion, and any relevant references.

**Proposal fields:**

| Field | Source | Marker |
|---|---|---|
| **Title** | Short phrase capturing the idea (Noun + Context pattern) | `[inferred]` |
| **Idea** | 2-3 sentences describing the possibility | `[inferred]` |
| **Trigger** | The moment this becomes relevant — free text | `[inferred]` |
| **Prune when** | The observable event that would make this seed dead. Same grammar as Trigger (see STEP 3A). **No fallback default.** | `[inferred]` |
| **Origin** | What prompted this: current ISS, sprint, external source, conversation topic | `[inferred]` |
| **References** | Optional — file paths, URLs, project names, articles that informed the idea | `[inferred]` or omitted |

All fields except **Prune when** can take a reasonable inference. If trigger is unclear, default to: "Review at next sprint planning."

**`Prune when` has no such fallback.** A default like "when no longer relevant" makes the field present-but-empty: the completeness predicate passes, the reader learns nothing, and the check looks like it works. If no kill condition can be inferred, do **not** invent one — carry `Prune when: [cannot infer]` forward to STEP 2 and display it as-is. That inability is the strongest single signal that STEP 1A should have classified this as a finding.

Generate slug from title: lowercase, hyphens, max 40 chars. Example: "stale-detection-scanner-agent".

**Finding fields** — canonical schema: `.nexus/memory/SCHEMA.md` § 2 discoveries.jsonl. Infer these:

| Field | Source | Marker |
|---|---|---|
| **content** | The assertion itself plus what confirmed it (test, observation, doc) — 2-4 sentences. State what *is true*, not what to do about it. | `[inferred]` |
| **tags** | 3-6 keywords for grep retrieval — keyed to the moment someone would need this, not the subject it is about | `[inferred]` |
| **related_to** | ISS / PAT / record ids the finding touches | `[inferred]` |
| **importance** | high / medium / low | `[inferred]` |
| **durability** | enduring / bounded | `[inferred]` |

`id` (`next_discovery_id`), `sprint`, `issue`, `conv`, `date` come from STEP 0 context. `still_valid` is always `true` at write.

---

### STEP 2: Review & Confirm

One gate, two renderings — the class from STEP 1A picks the block. This is still the single interruption the skill has always had.

**Proposal rendering:**

```
───────────────────────────────────────
🌱 SEED CAPTURE: SEED-{NNN}
───────────────────────────────────────
Title: {title} [inferred]
Origin: {origin} [inferred]

Idea:
{description} [inferred]

Trigger:
{trigger condition} [inferred]

Prune when:
{kill condition} [inferred]

{if references:}
References:
{references} [inferred]
───────────────────────────────────────
```

**Finding rendering:**

```
───────────────────────────────────────
🔎 FINDING — routing to the memory layer, not to seeds
   {next_discovery_id} → .nexus/memory/discoveries.jsonl
───────────────────────────────────────
Content:
{content} [inferred]

Tags: {tags} [inferred]
Related: {related_to} [inferred]
Importance: {importance} [inferred] | Durability: {durability} [inferred]

Why not a seed:
{the STEP 1A tell that fired — e.g. "asserts how the Workflow harness
 serializes args, and that contract can invert" or "no observable event
 could be named that would make this dead"}
───────────────────────────────────────
⚠️  One-way door: the memory layer is append-only. Obsolescence is expressed
    via still_valid:false, never deletion — a misclassified finding cannot be
    cleanly withdrawn once written. Nothing has been written yet.
```

**[T2: Balanced+Full ask | Streamlined: auto-plant if all fields solid, notify+log]**

Options via `AskUserQuestion tool`:

| Rendering | Options |
|---|---|
| Proposal | `[Plant / Adjust / Skip]` |
| Finding | `[Record as discovery / Plant as seed anyway / Skip]` |

| Choice | Action |
|--------|--------|
| Plant | Proceed to STEP 3A. |
| Record as discovery | Proceed to STEP 3B. |
| Plant as seed anyway | **Re-run STEP 1B for the proposal class before writing.** The finding rendering inferred no seed fields, so proceeding straight to STEP 3A would emit a seed with no `## Prune When` — the exact section this format requires. Re-display the proposal block, then proceed to STEP 3A. If the kill condition still cannot be inferred, say so at the re-display; the user supplies one or picks Skip. |
| Adjust | User provides corrections. Apply, re-display the same rendering, confirm again. |
| Skip | Display "Seed skipped." / "Finding skipped." Return to previous work — no file written, no counter moved. |

---

### STEP 3: Write & Confirm

Two write paths. Exactly one runs — **A** for proposals, **B** for findings.

#### STEP 3A — Seed path

**A1 — Write seed file** to `.nexus/seeds/SEED-{NNN}-{slug}.md`:

```markdown
# SEED-{NNN}: {title}
*Created: {date} | Origin: {origin} | Status: dormant*

## Idea

{description}

## Trigger

{trigger condition}

## Prune When

{kill condition}

## Notes

{any additional context from conversation, or omit section if empty}

## References

{file paths, URLs, project names — or omit section if none}
```

Omit **only** `## Notes` and `## References` if empty — they are the sole optional sections. `## Idea`, `## Trigger`, and `## Prune When` are required; a seed missing any of the three is malformed. `## Prune When` has **no fallback default** — never emit filler to satisfy the section.

**Grammar for `## Trigger` and `## Prune When`** — both name an **observable event**: the moment the seed becomes actionable, and the moment it becomes dead. Write the *moment*, not the *subject* — "Once the two-layer reference check ships in organize-sprint STEP 1D" fires for a reader standing in that moment; "reference checking" does not. A date is not an event. "When no longer relevant" is not an event. If no event can end this seed, do not invent one — say so at the STEP 2 review.

**A2 — Increment counter**: Write `next_number + 1` to `.nexus/seeds/.counter`.

**A3 — Verify**: Confirm seed file exists on disk and counter updated.

**A4 — Confirm** (one line, back to work):

```
🌱 Planted SEED-{NNN}: {title}
```

#### STEP 3B — Finding path

**B1 — Append** one JSON object as a **single line** to `.nexus/memory/discoveries.jsonl` (inline-append route per CLAUDE.md [Section: Memory-Layer]):

```json
{"id": "{next_discovery_id}", "content": "...", "sprint": {current_sprint}, "issue": "{current_issue or null}", "conv": {conv}, "date": "{YYYY-MM-DD}", "tags": [...], "related_to": [...], "importance": "...", "durability": "...", "still_valid": true}
```

**B2 — Verify the append parses** (MANDATORY) — every line of the file must still be valid JSON:

```bash
python -c "import io,json;[json.loads(l) for l in io.open('.nexus/memory/discoveries.jsonl',encoding='utf-8') if l.strip()]" && echo PARSE-OK
```

A malformed hand-append breaks every reader of the file, not just this record. If it fails: remove the appended line, fix it, re-append, re-verify.

**B3 — Do NOT touch `.nexus/seeds/.counter`.** No seed was planted; incrementing burns a seed id and leaves a permanent gap in the sequence.

**B4 — Confirm** (one line, back to work):

```
🔎 Recorded {next_discovery_id} in discoveries.jsonl: {one-line summary}
```

---

## Error Recovery

| Problem | Recovery |
|---|---|
| Counter file missing | Create `.nexus/seeds/.counter` with value 1, proceed |
| Seeds directory missing | Create `.nexus/seeds/`, proceed |
| Seed file write fails | Retry once. If still fails: display seed content as text for user to save manually |
| Counter collision (file already exists) | Increment until free ID found |
| `.nexus/memory/discoveries.jsonl` missing on the finding path | Memory layer not initialized — do **not** create the file here (line 1 carries a safety marker that must not be fabricated). Surface it: offer `Plant as seed anyway` (re-running STEP 1B per STEP 2) or `Skip`. |
| Appended discovery line fails B2 parse | Remove the appended line immediately, correct the JSON, re-append, re-verify. Never leave a malformed line in place — it breaks every reader of the file, not just this record. |
| Finding path taken but `next_discovery_id` was never allocated | STEP 0 was skipped. Re-run STEP 0's discovery-id scan before writing; do not guess an id. |
