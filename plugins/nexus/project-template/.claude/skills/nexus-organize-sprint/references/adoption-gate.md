*Version: 1.0.1 | Date: 2026-06-21 | Sprint: 106*

# Organize-Sprint — Adoption Gate Reference

Lazy-loaded companion to `nexus-organize-sprint/SKILL.md`. Holds the **Adoption Gate** (formerly inline STEP 1D.5) — the per-seed critical-source-evaluation run at the seed→issue promotion boundary — externalized from the SKILL.md body (ISS-209, Class-A; audit §2.6). Single-source (PAT-113): SKILL.md STEP 1D's `[Promote to issue]` path invokes [Section: Adoption-Gate] by reference. **Load this file only when a seed is promoted** — the "no Promote picked" path never loads it.

---

## Adoption Gate
[Section: Adoption-Gate]

Runs **per-seed, inline** when the user picked `[Promote to issue]` for that seed in STEP 1D. Fires once per promoted seed, before the `/nexus-create-issue` invocation. Skip entirely if no `[Promote to issue]` was picked.

**Purpose**: Critical-source-evaluation (the 5-step structure below) applied at seed→issue promotion. Low-friction seed creation means weak ideas can survive months in `.nexus/seeds/` until a sprint slot is allocated to them and Analysis-time `adapt-not-adopt` finally fires. This gate moves the rigorous critical evaluation up to the promotion boundary, where cost-of-being-wrong rises sharply — sparing sprint budget and Analysis context on seeds that don't survive a structured comparison against existing NEXUS safety layers.

### Step 1 — Identify source

Load the SEED file content (already read in STEP 1D). If the file contains a `## Adoption Attempts` section, surface prior verdicts to the user before asking for new justification:

```
🌱 SEED-{NNN} — Prior adoption history
  Attempt 1 (Sprint {N}): HOLD — vs_existing_layers field weak (LLM judged restated current mechanism)
  Attempt 2 (Sprint {M}): DISCARD — user_pain blacklisted generic phrase "would be nice"

This seed has not yet passed the adoption gate. Sharpen the justification or accept dormant retention.
```

Absent section = zero prior attempts; render no history block.

### Step 2 — Extract concepts

Two sequential `AskUserQuestion` prompts. Each prompt collects free-text via the "Other" option (NEXUS standard text-entry pattern — the question text is the prompt; the user picks "Other" and types the response). Both responses must be non-empty to clear Layer 1 hard-block.

| Field | Prompt | Tier |
|---|---|---|
| `user_pain` | "What concrete cost does *not* doing this incur? Name the user/system impact in specific terms — not 'would be nice', not 'for flexibility'." | T2 |
| `vs_existing_layers` | "Which existing safety layer fails to cover this need? Compare against: T1 step gates per Control Level, git checkpoints at conversation boundaries, [WRITE-VERIFIED]/[TPU-VERIFIED] markers, Claude Code native checkpoint system. Explain in 1-2 sentences why these don't already address the seed's pain." | T2 |

Capture both responses verbatim — they propagate to Step 3 verdict logic, Step 5 PASS-branch description payload, and (on HOLD/DISCARD) the `## Adoption Attempts` annotation reason field.

### Step 3 — Validate relevance (two-layer check)

Apply in order — first match wins, later layers skipped:

**Layer 1 — Mechanical (hard-block)**:
- `user_pain` is empty or whitespace-only → verdict **DISCARD**
- `user_pain` matches generic-phrase blacklist regex (case-insensitive, whole-phrase boundaries): `\b(would be nice|for flexibility|in case|seems important|might be useful|nice to have)\b` → verdict **DISCARD**
- `vs_existing_layers` is empty or whitespace-only → verdict **DISCARD**

**Layer 2 — LLM semantic (soft-warning)**:
- Read `vs_existing_layers` content. Does it concretely differentiate from at least one enumerated safety layer, or does it restate / trivially vary one of them (claiming a layer's existing capability as the differentiator)?
- Concrete differentiation = **continue to Step 4 PASS**
- Restatement / trivial variation / vague hand-waving = verdict **HOLD**

The Layer 1 blacklist is **extensible** — add observed generic phrases over time. The Layer 2 semantic threshold is **tunable** — calibrated across sprints via SA-002 Iterative Refinement based on observed friction (false-positives = legitimate seeds blocked, false-negatives = weak seeds promoted).

### Step 4 — Decide action

Three verdicts, each with a different user choice surface:

| Verdict | Display | User choice |
|---|---|---|
| **PASS** | `✅ Adoption gate cleared for SEED-{NNN}.` | Proceeds automatically to Step 5 PASS branch — no widget |
| **HOLD** (Layer 2) | `⚠️ Adoption gate — soft warning for SEED-{NNN}.`<br>Reason: `{specific Layer-2 finding, e.g., "vs_existing_layers restates 'git checkpoints already handle rollback' — same mechanism, not differentiation"}` | **[T2]** `AskUserQuestion`: [Override and promote / Hold for rewrite / Discard] |
| **DISCARD** (Layer 1) | `❌ Adoption gate — hard block for SEED-{NNN}.`<br>Reason: `{specific Layer-1 trigger, e.g., "user_pain field empty" or "user_pain matched blacklisted phrase 'would be nice'"}` | **[T2]** `AskUserQuestion`: [Rewrite and re-evaluate / Keep dormant / Discard] |

Layer-1 DISCARD cannot be "Override and promoted" — hard-block means the structured fields themselves failed the minimum. Rewrite re-runs Step 2.

### Step 5 — Implement cleanly

Branch by Step 4 outcome:

**PASS** → flow unchanged from current STEP 1D: `invoke /nexus-create-issue` in Assisted mode with seed content (title, description from Idea, context from Origin/References + user_pain + vs_existing_layers appended to description). After issue created, delete the seed file. New issue enters the registry and is considered in STEP 3 sprint planning.

**HOLD with "Override and promote"** → treated as PASS (user authority), but annotate the SEED file's `## Adoption Attempts` section first with verdict `HOLD-overridden` for telemetry. Then proceed to create-issue.

**HOLD with "Hold for rewrite" / "Keep dormant"** → patch SEED file: append entry under `## Adoption Attempts` (create section if absent). Seed retained, not deleted.

**HOLD with "Discard"** → delete SEED file. No `## Adoption Attempts` patch needed (seed gone).

**DISCARD with "Rewrite and re-evaluate"** → return to Step 2 with same SEED loaded. User restates user_pain and vs_existing_layers. Verdict re-computed.

**DISCARD with "Keep dormant"** → patch SEED file: append entry under `## Adoption Attempts` with verdict `DISCARD` and the specific Layer-1 reason.

**DISCARD with "Discard"** → delete SEED file.

`## Adoption Attempts` annotation format (appended; section header added if absent):

```
## Adoption Attempts
- {YYYY-MM-DD} (Sprint {NNN}): {HOLD|HOLD-overridden|DISCARD} — {specific reason: empty user_pain | blacklisted phrase "X" | weak vs_existing_layers: "{LLM finding}"}
```

### Worked examples (anchors for verdict consistency)

**Example A — PASS verdict** *(synthetic clean seed)*

> SEED-XXX: Snapshot-restore for ISS files
> Idea: `/nexus-rollback` should support per-issue restore from git history. Today only file-level rollback works.

| Field | User input |
|---|---|
| `user_pain` | "When Evaluation reveals a bad direction, recovering ISS state means manual diff-and-revert across multiple files. Multi-file ISS state is fragile during recovery." |
| `vs_existing_layers` | "Git checkpoints cover project-wide rollback but not selective per-issue; `/nexus-rollback` is single-file scope. None compose into per-issue restore." |

Layer 1: both fields populated, no blacklisted phrases → continue.
Layer 2: `vs_existing_layers` explicitly differentiates against three named layers with concrete why-not for each → **PASS**.

**Example B — HOLD verdict** *(soft-warning, borderline)*

> SEED-XXX: Auto-cache hook outputs for faster boot
> Idea: Hook outputs could be cached to speed up boot.

| Field | User input |
|---|---|
| `user_pain` | "Boot feels slow when many hooks fire." |
| `vs_existing_layers` | "Memory-first rule already handles caching of files; this would extend that idea to hook outputs." |

Layer 1: both fields populated, no blacklisted phrases → continue.
Layer 2: `vs_existing_layers` acknowledges the seed *extends* an existing mechanism rather than addressing a gap none of them cover. LLM finding: "Seed restates Memory-First Rule's mechanism rather than differentiating — if Memory-First already handles caching, the seed proposes a refinement of an existing layer, not a new safety property." → **HOLD**.

**Example C — DISCARD verdict** *(hard-block)*

> SEED-XXX: Sprint dashboard view
> Idea: Could be nice to have a dashboard summarizing sprint progress visually.

| Field | User input |
|---|---|
| `user_pain` | "Would be nice to see sprint progress at a glance." |
| `vs_existing_layers` | (skipped — Layer 1 already failed on user_pain) |

Layer 1: `user_pain` matches blacklist regex `\bwould be nice\b` → **DISCARD**. User options: rewrite, keep dormant, discard.

[/Section: Adoption-Gate]
