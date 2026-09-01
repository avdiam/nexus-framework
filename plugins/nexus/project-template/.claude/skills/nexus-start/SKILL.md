---
name: nexus-start
description: NEXUS unified startup — initializes sessions, loads sprint state, detects work phase, handles compaction recovery.
disable-model-invocation: true
---
*Version: 2.9.2 | Date: 2026-08-28 | Sprint: 112*

# NEXUS Start 

**Flow**: Setup (window, hooks, git) → Compaction flag → Load sprint-state → Derivation sweep → Lifecycle → Status → Phase → Complexity + ISS → [Widget: phase + control level] → files_to_load → Startup header → Route

Runs setup, detects mode.

**⚠️ SILENCE RULE**: No text output until the Display step. No step labels, no progress narration, no "loading..." messages. 

Execute tool calls and steps below silently (except STEP 9 widget), then produce ONE output: the startup header.

Cognitive anchor: "The user sees NOTHING until Step 9. No step labels, no intermediate results."

## Rules

1. Startup-header values MUST come from actual file reads — never fabricate entries.
2. All header fields + any warnings must be computed BEFORE displaying the header.

---

## STEP 1: Setup (silent)

1. **STEP 1A — Project Root**: `project_root` = the working directory — all NEXUS paths are relative to it (CLAUDE.md [Section: Memory-Context-Management] Path Resolution; CLAUDE.md carries no project-root field). Verify `.nexus/` exists under it.
If `.nexus/` is missing: report to user, stop.

2. **STEP 1B — Environment + Token Tracking Mode**: Perform the three sub-steps below in order. The `.context-window` write is the load-bearing one — when skipped, the UserPromptSubmit hook denominator stays stale and the entire conversation displays wrong percentages (STI-001 Sprint 088 + Sprint 089 origin).

  **1B.1 — Detect window**: Read `model_id` and context window from the system prompt per CLAUDE.md [Section: Memory-Context-Management] Window detection (first-match-wins on `[1m]` / `[200k]` suffix / "(with 1M context)" prose / default 200K).

  **1B.2 — Write denominator**: Write detected window to `.nexus/.context-window` in **numeric form** via Bash (`echo 1000000 > .nexus/.context-window` for 1M; `echo 200000 > .nexus/.context-window` for 200K — never literal `1M`/`200K` strings; the UserPromptSubmit hook uses this as a denominator).

  **1B.3 — Verify**: Bash `cat .nexus/.context-window` and confirm the printed value matches the detected window numeric (`1000000` or `200000`). Mismatch or empty file = STEP 1B failed; re-run 1B.2 before proceeding. The hook returns pre-computed display values via `[context: {K}K/{W} | {pct}% | {bars}]` — extract and use directly, no math needed.

  **1B.4 — jq probe**: Bash `command -v jq >/dev/null 2>&1`. If absent: add `jq not found — hooks fall back to Python (fully functional); install jq for faster JSON parsing: jqlang.org/download` to the header `⚠` line. Once per conversation (this step runs once, at boot) — not per-write nagging. Not a functional degradation: `nexus-validate-yaml.sh` / `nexus-backup-binary.sh` resolve a parser-priority ladder (`jq` → `python` → `python3`) and degrade gracefully to Python when `jq` is absent (ISS-232); this notice is visibility for a non-broken state, per the user's stated preference that degraded-but-working dependencies should be surfaced with a remedy, not silently absorbed.

  Hold `{model_id}` + `{window}` for the startup header (line 2: `{model_family} [{window}]`). No standalone display line.

  For hook-arrival timing, /model-switch re-detection, and fabrication prevention rules: see CLAUDE.md [Section: Memory-Context-Management] — single source of truth.

3. **STEP 1C — Memory Mantra** : Initialize 2-tier protocol. Files in context so far: CLAUDE(Nexus Harness) + Nexus-start.

4. **STEP 1D — Continuous Protocols**: CLAUDE.md is loaded — status line, token tracking, zone monitoring, violation detection, and any other protocol / principle / preference / rule at CLAUDE.md are NOW ACTIVE for the rest of this conversation.

5. **STEP 1E — Git Check**  (Conv 1 only — the saved `conversation_number` is not known until sprint-state is read at STEP 3; evaluate this step right after STEP 3 and skip it when the saved value is > 1):
Run `git status`. If no repository → add warning `no git repository` for the header `⚠` line. If active → silent.

---

## STEP 2: Compaction Recovery Flag (silent)

- If compact recovery hook injected "NEXUS: Context was compacted" in this conversation → store `compaction_recovery = true`.
- Otherwise → store `compaction_recovery = false`.

---

## STEP 3: Load Sprint-State (Silent)

Read `.nexus/active/states/sprint-state.md`.

Extract: `_sprint`, `_status`, `_project_lifecycle`, `continue_with.WHAT`.

Hold `{_sprint}` + `{_status}` for the startup header (line 1). No standalone display line.

| Condition | Action |
|---|---|
| Not found | Check if `.nexus/archived/projects/` exists with content → previous project was closed and archived. If so: "Previous project archived. Run 'init project' to start a new project." If no archive found: report to user, offer backup restore. If restored: re-read. If declined: prompt for new project init. |
| Malformed | Inform user, offer recovery. Add `state malformed` to the header `⚠` line. |

Cannot proceed without valid sprint-state.

## STEP 4: Derivation Sweep (Silent)

Sweeps `.nexus/active/derivations.yaml` — the derivation edge manifest — executing every `runs_at: boot` row's predicate against the live tree. Detects derived artifacts that no longer agree with the source they were derived from: stale mtimes, template corrections that never reached their instances, canonical values with a hand-copied twin, and producer vocabularies a consumer's filter no longer spans.

Through v2.6.0 this step compared **two** hardcoded artifacts against two hardcoded source sets. Those two edges are now manifest rows **E-12** (`changelog-registry.yaml`) and **E-13** (`NEXUS-Architecture.md`), and the sweep must reproduce their behaviour exactly — a regression here silently removes the only freshness signal boot has ever emitted (ISS-240 Phase 3.1).

**In a distributed install, E-13 is absent — and that is correct, not a broken manifest.** `NEXUS-Architecture.md` does not ship (it is a meta-project artifact), so the export curates E-13 out along with E-16, leaving 14 rows rather than 16. A sweep that finds no E-13 in an adopter tree has nothing to repair; only a *dev* tree missing E-13 is a regression. Named here because this paragraph ships as written and an adopter-side session reading it will otherwise report the gap as a defect — one did, at ISS-101 step 4.2.

Boot-log emit only; no interactive offer. Rate-limited per sprint+conv to avoid noise during active framework development.

⛔ **NON-FATAL EXECUTION — R6.** This step runs on the boot path; a broken sweep would break every boot in the project. A predicate that errors, hangs, or returns an unparseable verdict is recorded as a warning and **the sweep continues to the next row**, mirroring boot's existing *"boot never fails on a missing section"* discipline (STEP 10). No predicate may abort a boot. If the manifest itself is missing or does not parse: emit `derivations.yaml unreadable — sweep skipped` to the `⚠` line and continue to STEP 5. Boot degrades to no freshness signal; it never fails.

**Rate-limit gate**: Read **line 1** of `.nexus/.freshness-checked` (`sprint=NNN conv=N`). `N` is the conversation number STEP 6 will derive — compute it here by the STEP 6 rule (its inputs — saved `conversation_number`, `_status`, `compaction_recovery` — are all known after STEPs 2–3).
- If line 1 matches current sprint+conv **and conv > 0** → skip silently (compaction-recovery loop protection), no warning emitted.
- If the file is missing, line 1 differs, **or conv = 0** (post-closure boots on a `complete` sprint all share `conv=0` — they are distinct sessions and the key cannot tell them apart) → proceed with the sweep.

Only **line 1** is the rate-limit key. Lines 2+ are the staleness ledger (sub-step D) and are never part of the match.

### A — Load the manifest

Read `.nexus/active/derivations.yaml`. Select rows where `runs_at: boot`. Each supplies an `id`, a `source`, a `derived` and an executable `predicate`.

Rows whose `runs_at` names a skill (`nexus-registry-cleanup`, `nexus-create-pattern`) are **not** run here — they need registry semantics boot does not load, and execute inside their owning skill. They are listed in the manifest so the edge set stays enumerable by one command, which is the point of declaring edges at all.

### B — Run the boot predicates (non-fatal)

**Extraction is specified, not improvised** — every boot must do it the same way, or the sweep's behaviour varies by conversation:

1. Parse the manifest with a YAML parser (`yaml.safe_load`), not by grepping block scalars — a predicate *contains* `#`, `:` and `-`, so line-oriented extraction mangles it.
2. Select `runs_at == 'boot'`, preserving manifest order.
3. Emit one shell script: per row, an id banner then the predicate body wrapped in `( … )` so a row's `exit` cannot terminate the sweep.
4. Run that script in **one** Bash invocation. Not one call per row — the rate-limiter bounds the sweep to once per sprint+conv, and a single call keeps the cost flat as the manifest grows.

**Measured cost (R4), not estimated** — Sprint 111, 11 boot rows, 14-edge manifest: **~12.4 s wall time** for the whole sweep plus a **55 KB** manifest read, once per sprint+conv. The plan's risk table rated R4 *"Low"* without measuring; the honest figure is *~12 s and ~14K tokens per conversation*, which is acceptable but is not nothing. If it grows: predicates are the cost, not the parse — prune `disposition: eliminable` rows that have been clean for several sprints before touching the sweep's shape.

Each predicate terminates on the VC-2 verdict contract declared in the manifest header:

| Verdict | Meaning | Sweep action |
|---|---|---|
| `FILLED: 0 findings / N bound / N candidates` | Edge current | Silent |
| `FILLED: {n>0} findings / …` | Edge **stale** — the derived side disagrees with its source | Record for sub-steps D and E |
| `ESCALATED: …` (exit 2) | The predicate could not consume its input — bound 0, candidates 0, or an unreadable source | Record as a warning; **never** read as clean |
| `SKIP (justified): …` (exit 0) | The question has no subject on this corpus yet — the fresh-tree guard fired (manifest header, ISS-101 step 2.4). Not a finding and not a failure | Silent. Never counted as stale, never laddered as a broken predicate |
| anything else / non-zero exit / no output | Predicate broken | Warning `E-NN predicate failed`; continue to the next row |

A verdict is never inferred from an exit code alone. `ESCALATED` and a crashed predicate are both warnings but they say different things and are reported differently: one means the check ran and refused to certify, the other means the check did not run. `SKIP` shares `exit 0` with a clean `FILLED` and is silent like one, but it is a third thing again: the check ran, found no subject to examine, and said so. Classifying it by exit code alone would read it as clean; classifying it by the catch-all row would report `predicate failed` on a working predicate. It gets its own row because it is neither.

### C — Negative-space probe (R1)

The manifest is itself hand-maintained, so it can drift into an instance of the defect it exists to catch — a file set that *looks* enumerated because a manifest exists. This probe reports derived-looking artifacts carrying **no manifest row on either side**.

Grep the live tree (`CLAUDE.md`, `.claude/skills`, `.nexus/active`, `.nexus/templates`, `.claude/agents`) for the drift-signal vocabulary — a value that announces its own provenance in prose is a derivation edge written in English, which is exactly why the prose caveat never travelled with its value:

`carried forward` · `is an estimate` · `schema aligned` · `hand-maintained` · `hardcoded`

For each hit, check whether that file appears as `source` or `derived` in any manifest row. Files with no row → `Unregistered derived-looking: {file} ({signal})` on the `⚠` line.

Exit criterion is **"every hit registered or classified"**, never "returns 0" — these tokens have live homonyms, and a file legitimately using one is classified, not edited into silence (PAT-142).

### D — Staleness ledger + escalation (R2)

A header warning that prints every boot and is walked past every boot is not a signal. `NEXUS-Architecture.md` proved it inside this issue's own build: 2 source files newer at Sprint 111 Conv 1, **8** by Conv 6, its warning printed on all six boots and acted on at none.

**The ledger** lives in `.nexus/.freshness-checked` lines 2+, one line per **unresolved** edge — an edge that reported `findings > 0` *or* terminated `ESCALATED`. Both persist across boots and both would otherwise print the same header line forever, so both run on one clock. A `SKIP` edge is neither: it is not unresolved, so it never earns a ledger line — otherwise an adopter's untouched tree would accumulate a staleness clock on five edges that have nothing to be stale about and escalate them to `[SYSTEM_ISSUES]` two sprints later:

```
sprint=111 conv=7          <- line 1: the rate-limit key. Format unchanged since Sprint 096.
stale: E-07=111            <- lines 2+: {edge id}={sprint first seen stale}
stale: E-13=111
```

**Precedence — the ledger is authoritative, the manifest field is a seed.** For an edge reporting stale:

| Ledger state | `first_seen_stale` resolves to |
|---|---|
| Ledger carries a `stale:` line for this edge | **the ledger's value** — the manifest's `first_seen_stale` is not read |
| No ledger line; manifest carries `first_seen_stale: NNN` | the manifest value, seeded into the ledger on this write |
| No ledger line; manifest carries `first_seen_stale: null` | the current sprint |

The seed exists because edges declared at Phase 0 carry history no boot could reconstruct — E-01 and E-02 were first seen stale at Sprint **109**, two sprints before any ledger existed. It is read once per edge and never again. A manifest `first_seen_stale` that disagrees with a **populated** ledger entry is a finding, asserted by E-08's predicate — without that assertion the seed would be a second home for one value, which is this manifest's own defect class.

An edge that resolves clean (`FILLED: 0 findings`) drops its `stale:` line entirely; the clock restarts if it goes unresolved again.

> **Why `ESCALATED` shares the clock.** E-13 reports `ESCALATED` whenever `NEXUS-Architecture.md` is newer than every source while declaring an older rebuild sprint — the map was *edited* without being *rebuilt*, so mtime carries no information. That state is stable across many boots, exactly like staleness. Excluding it from the ledger would reintroduce the wallpaper this sub-step exists to remove (ISS-240 Conv 7).

**Escalation**: when `{current _sprint} − {first_seen_stale} >= 2`, the edge stops printing a header line and becomes a sprint-state `[SYSTEM_ISSUES]` entry instead. Boot does not write it — **boot never mutates sprint-state**. The ledger is the hand-off: `/nexus-checkpoint` STEP 4 reads it and files the entry at the next checkpoint.

### E — Warning emission

To the header `⚠` line (no dedicated boot-log line):

| Condition | Header warning |
|---|---|
| Every boot edge reports `FILLED: 0 findings` or `SKIP` | (silent) |
| Edge reports `SKIP (justified)` | (silent — a guarded edge on a corpus that does not exist yet is not a warning) |
| Edge stale, below the escalation threshold | `Stale: {derived} ({n} findings, E-NN)` per edge, consolidated onto the single `⚠` line |
| Edge stale, at or past the threshold | (suppressed from the header — it escalates to `[SYSTEM_ISSUES]` via the ledger) |
| Predicate `ESCALATED` or failed | `E-NN did not verify: {reason}` |
| Unregistered derived-looking artifact (C) | `Unregistered derived-looking: {file} ({signal})` |
| Manifest missing / unparseable | `derivations.yaml unreadable — sweep skipped` |
| Rate-limit suppressed | (silent) |

The header surfaces; it does not prompt. The reactive auto-scan in `/nexus-checkpoint` STEP 4 closes the loop for `changelog-registry.yaml` (E-12); `NEXUS-Architecture.md` (E-13) rebuild stays manual and heavyweight (~50–100K), which is precisely why its remedy is escalation rather than an auto-rebuild.

### F — Ledger write

After the sweep (regardless of outcome), write `.nexus/.freshness-checked`:
- **line 1** — `sprint={current _sprint} conv={current conversation_number}`. Format unchanged; the rate-limit gate and every documented consumer of this file's first line depend on it.
- **lines 2+** — one `stale: E-NN=SSS` line per edge that reported stale in this sweep, in manifest order. No lines when nothing is stale.

---

## STEP 5: Lifecycle Check (Silent)

| `_project_lifecycle` | Action |
|---|---|
| `not-defined` | Invoke `/nexus-init-project` — boot ends here (no header shown). |
| `defining` | Invoke `/nexus-setup-project` — boot ends here (no header shown). |
| `active` | Proceed to STEP 6. (silent — default, not shown in header) |
| `closed` | Proceed to STEP 6. Hold `Closed` for header line-1 suffix (`· Closed`). |
| Missing | Treat as `active`. Proceed to STEP 6. |
| Any other value | Add warning `lifecycle: unexpected '{value}' — treating as active`; warn user. Proceed to STEP 6. |

For `not-defined` and `defining`: boot does NOT continue — control transfers permanently.

---

## STEP 6: Handle Status (Silent)

| `_status` | Action | Then |
|---|---|---|
| `ready` | Set conversation_number in memory = 1. Use conversation_number for status/welcome | → STEP 7 |
| `in_progress` | **If compaction_recovery**: conversation_number = saved (no increment). **Otherwise**: conversation_number = saved + 1. Use conversation_number for status/welcome and continue_with for work context. | → STEP 7 |
| `closing` | **If compaction_recovery**: conversation_number = saved (no increment). **Otherwise**: conversation_number = saved + 1. Use conversation_number for status/welcome. Sprint ready for closure — Learning phase. | → STEP 7 |
| `complete` (properly closed: if `_closure_time` exists) | Set Display_sprint in memory = _sprint + 1, conversation_number = 0. Use display_sprint and conversation_number for status/welcome. | → STEP 7 |
| `complete` (not closed: no `_closure_time`) | Set flag `unclosed_sprint = true`. Use saved _Sprint and conversation_number (not incremented — no work permitted; only close-sprint is dispatched). Redirect to close-sprint via STEP 9. | → STEP 7 |

---

## STEP 7: Detect Phase (Silent)

**Detection only — DO NOT load any methodology skill yet.**

**Lifecycle phase detection** (checked first):

| `_status` | Phase | Methodology |
|---|---|---|
| `closing` | Learning (close-sprint) | None (self-contained) |
| `complete` (properly closed) | Planning (organize-sprint) | None (self-contained) |

If either matches: skip operational detection. Hold `{phase}` (Learning/Planning) for the header (line 2).

**Operational level detection:**

| Level | Signals | Methodology |
|---|---|---|
| L1_PROJECT | "project setup", "update project vision", "update project scope" | None |
| L2_SPRINT | "organize sprint", "close sprint" | None |
| L4_META | "system maintenance", "health diagnostic" | /nexus-maintain |
| L3_ISSUE | Default | Phase-dependent (below) |

**L3 phase detection priority** (first match wins):

| Priority | Source | Rule |
|---|---|---|
| 0 | `current_focus` | If "maintenance" → /nexus-maintain; if "brainstorm" → /nexus-brainstorm |
| 1 | User intent | Explicit "analyze" / "implement" / "test" / "brainstorm" → that phase |
| 2 | `current_focus` | Use stored value |
| 3 | Issue scores | A < 4 → Analysis. A ≥ 4, I < 4 → Implementation (or Research). I ≥ 4, E < 4 → Evaluation |
| 4 | Operations mentioned | Infer from context |
| 5 | Fallback | Default to Analysis |

**Multi-issue resolution**: Use issue from `continue_with.WHAT`. Fallback: highest A+I+E sum.

**Phase → Skill mapping:**
Analysis → /nexus-analyze | Research → /nexus-research | Implementation → /nexus-build
Batch Implementation → /nexus-build (batch mode via `_build_mode`) | Evaluation → /nexus-validate | Maintenance → /nexus-maintain
Learning → /nexus-close-sprint | Planning → /nexus-organize-sprint | Brainstorm → /nexus-brainstorm

Hold `{phase}` (and A/I/E scores, for phase-monitoring) for the header (line 2 `{phase_label}`). No standalone display line.

---

## STEP 8: Assess Complexity + Load Active ISS (Silent)

1. STEP 8A — **Complexity detection**: Read complexity from [OBJECTIVES] entries (`ISS-XXX: {title} ({priority}, C:{N})`). Highest complexity if multiple. Default 3 if not found.

2. STEP 8B — **Load ISS**: Identify active issue from `continue_with.WHAT` or highest-priority in_progress. 
- Read `.nexus/issues/ISS-XXX.md`.
Skip if no active issue (lifecycle phase, sprint operations).

Compute `{N}` complexity (drives cognitive gating — not shown in header). Hold the active ISS id for the Focus line. No `[COMPLEXITY]`/`[ISS]` display lines.

---

## STEP 9: Cognitive Tools + User Phase Confirmation (First STEP to display at user)

**DO NOT load any cognitive skill before this step.** The user's response determines what gets loaded.

Cognitive assessment (drives the STEP 9 widget only if complexity > 3 — not shown in the header):

| Complexity | Action |
|---|---|
| ≤ 2 | None suggested |
| 3 | Note availability — "Cognitive tools available for this complexity"|
| 4 | Recommend: thinking → /nexus-mental-models, investigation → /nexus-problem-solving, decisions → /nexus-strategic |
| 5 | Recommend preloading all cognitive tools |

(Cognitive availability is conveyed via the widget when complexity > 3; it is not surfaced in the startup header.)

**DO NOT load any methodology skill before this step.** The user's response determines what gets loaded.

**If `unclosed_sprint = true`**: Sprint is complete but not formally closed — close-sprint must run before new work can begin. No choice offered.
`"⚠️ Sprint #{N} complete but not closed. Close-sprint must run before starting new work."`
Action: set detected_phase = Learning (header line-2 `Learning (unclosed sprint)`). Load `/nexus-close-sprint` after boot. Redirect is mandatory.

**Widget via AskUserQuestion:**

Phase question (presented first, always):
`"📚 Phase: Sprint-state suggests {detected_phase}. Confirm or override:"`

| Detection | Options |
|---|---|
| Research issue | [Research (detected), Analysis, Evaluation, Brainstorm] |
| L3/L4 detected | [{Detected} (detected), {Alt1}, {Alt2}, Brainstorm] |
| L1/L2 (None) | [None (detected), Analysis, Implementation, Brainstorm] |
| Lifecycle | [{Learning/Planning} (detected), Analysis, Implementation, Brainstorm] |

Brainstorm occupies the 4th slot uniformly across rows (replaces the former sandbox slot; preserves the 4-option cap). When the detected phase is itself brainstorm (via priority-0 `current_focus: brainstorm` route), render: `[Brainstorm (detected), Analysis, Implementation, Evaluation]` — exit alternatives become lifecycle phases.

Control Level question (presented second, always, every conversation):
`"⚙️ Control Level: Default is Balanced. Set session consent level:"`

Options: [Streamlined (T1 only), Balanced (default), Full Control (all gates), What's this?]

| Response | Action |
|---|---|
| Streamlined | Set active_control_level = 1 in memory |
| Balanced | Set active_control_level = 2 in memory |
| Full Control | Set active_control_level = 3 in memory |
| What's this? | Display [Section: Control-Levels] summary, then re-ask |

Hold `{control_level}` for the startup header (line 2: `Control: {control_level}`).

Cognitive Tools question (only if complexity > 3):
`"🧠 Cognitive Tools: Complexity {N}/5 — recommend {category}. Proceed?"`
Options: [Load recommended, Skip, Show all tools]

**Process responses — methodology loads AFTER user confirms:**

| Cognitive response | Action |
|---|---|
| Load recommended | Invoke recommended tool pack skill |
| Skip | Continue — auto-suggest active |
| Show all | Invoke /nexus-menu cognitive-tools |

| Phase response | Action | Header line-2 note |
|---|---|---|
| Confirmed (methodology) | Invoke mapped skill | `(/nexus-{skill})` |
| Overridden | Invoke user's selected skill | `(override → /nexus-{skill})` |
| None confirmed | No load | `(self-contained)` |
| Lifecycle confirmed | No load | `(self-contained)` |

---

## STEP 10: Load Essential Files (Silent)

Read `files_to_load` from sprint-state [BOOTSTRAP]. Skip files already in memory (ISS loaded in STEP 8B — skip if listed). For entries with a `[Section: Name]` suffix, parse per CLAUDE.md [Section: Checkpoint-Protocol] BOOTSTRAP format — extract section only; warn and load full file if section not found.

Load silently — no `[FILES]` display line. When a `[Section: Name]` entry is not found: add warning `files_to_load: section '{name}' not found in {file} — loaded full file` to the header `⚠` line.

---

## STEP 11: Display Startup Header (Display at user)

The boot log and welcome are merged into ONE compact startup header — **exception-based**: identity + the two session-config facts the user chose + the actionable focus line, plus a `⚠` line **only when warnings were detected** (STEPs 1B/1E/3/4/5/9/10). No per-step ✓ receipts.

**Before displaying, verify**: line-1 fields (`{_sprint}`, `{N}` conv), line-2 fields (`{phase_label}`, `{control_level}`, `{model_family}`, `{window}`), the Focus line (`{continue_with_summary}`), and the Context line are all populated; and every warning detected in STEPs 1B/1E/3/4/5/9/10 appears on the `⚠` line. If a required field is missing: trace back and execute the skipped step.

**Header template** (per CLAUDE.md [Section: Display-Templates] → Startup Display):

```
NEXUS · Sprint #{XXX} · Conv #{N}{ · {lifecycle suffix if not Active}}
{phase_label} · Control: {control_level} · {model_family} [{window}]
Focus → {continue_with_summary}
⚠ {warnings joined}            ← line present ONLY when one or more warnings fired
Context: {token_display} · 💡 "show menu" for operations
```

- `{phase_label}` = `{phase}` + the methodology note from STEP 9 (`(/nexus-{skill})` · `(override → /nexus-{skill})` · `(self-contained)` · `(⚠ degraded)`).
- 4 lines on a clean boot (no `⚠` line); 5 lines when a warning fired.

**Pre-hook display rule** (Conv 1 first turn only — accurate mode, before the first `[context: {K}K/{W} | {pct}% | {bars}]` arrives): render the Context line as `Context: — (awaiting first hook)`, and `—` in the status line. Do not fabricate a percentage. The hook fires on the user's *second* message; normal accurate-mode display resumes from that point.

---

## STEP 12: Begin Work

Self-check: sprint-state loaded, status handled, phase detected, methodology loaded or skipped, complexity assessed, cognitive tools decided, essential files handled, startup header displayed, memory mantra current.

**Lifecycle routing:**

| Phase | Action |
|---|---|
| Learning | Invoke /nexus-close-sprint |
| Planning | Invoke /nexus-organize-sprint |
| Other | Begin from continue_with, [OBJECTIVES], [DECISIONS] |

---

## Error Recovery

| Problem | Recovery |
|---|---|
| Sprint-state corrupted | Check git history, offer restore |
| Sprint-state not found | Offer backup restore or new project init |
| Methodology skill fails | Continue with CLAUDE.md only. Header line-2 note: `(⚠ degraded)` |
| Essential file missing | Inform user, proceed without |
| Startup header incomplete at STEP 11 | Trace back, find skipped step, execute it |
