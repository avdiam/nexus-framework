---
name: nexus-checkpoint
description: When a NEXUS checkpoint trigger fires (yellow zone accepted, red zone auto, user request, sprint closure detection) — execute this workflow. Do not improvise: improvising is a CRITICAL NEXUS violation. Prepares sprint-state, verifies ISS on disk, captures experience, writes & commits, reports. NOT for the "start" / "boot" / "initialize" trigger — that routes to /nexus-start (Read .claude/skills/nexus-start/SKILL.md directly; has disable-model-invocation).
disable-model-invocation: false
---
*Version: 2.5.0 | Date: 2026-08-26 | Sprint: 111*

# NEXUS Checkpoint Skill

**Flow**: Load → Prepare (save mode, file size) → Verify ISS → Capture experience → Write & commit → Report

## Purpose

Persist conversation progress into sprint-state and the active ISS file, capture experience for the sprint-closure learning loop, commit to git, and hand off to the next conversation with enough context to resume immediately. Invoked only when a trigger fires — never improvised. Triggers and the invocation rule live in CLAUDE.md [Section: Checkpoint-Protocol]; this skill is the HOW, not the WHEN.

**Cognitive anchor**: "Checkpoints preserve work, they do not end conversations."

---

## Checkpoint Type (recap)

| Type | Condition | Behavior |
|---|---|---|
| Progress | Context < 80% | Full checkpoint. Save and continue working normally. |
| Final | Context ≥ 80% OR user signals ending OR phase complete | Comprehensive save with full handoff context. Then continue — prefer reads over writes. |

---

## File Size Governance

| File | Cap (lines) | Warning | Compression |
|---|---|---|---|
| sprint-state.md | 450 | 350 | Sprint-state priorities (STEP 1A-bis + table below) |
| Active ISS file | 700 | 500 | ISS phase compression (STEP 1A-bis + table below) |

**Gate behavior** (T3 — routine housekeeping) per CLAUDE.md [Section: Control-Levels]:

| Level | At Warning | At Cap |
|---|---|---|
| Streamlined | Auto-skip (no compression) | Auto-compress, notify |
| Balanced | Notify: "{file} at {N} lines — compress? [Y/n]" (default: n) | Auto-compress, notify |
| Full Control | Ask: "Compress? [Y/n]" (default: n) | Ask (but must compress) |

---

## Workflow

When invoked, execute these steps in order.

**⛔ CHECKPOINT GATE PROTOCOL — 3 mandatory outputs, in sequence. Skipping any = violation.**
```
⛔ [CP-1] Save mode: {full_write|patch} — changed sections: {N}, structural issues: {N}, tag pairs: {N}
⛔ [CP-2] Experience: {N} items captured — approval: {asked|auto-logged|skipped (none)}
⛔ [CP-3] Verified: sprint-state {size} lines, tags {pre}/{post} pairs, conv fields {consistent|MISMATCH|n/a (post-closure)}, ISS on disk: {yes|no|n/a}, git: {committed|failed|n/a}
```
**These outputs must appear in the response. No checkpoint is complete without all three. If you find yourself writing sprint-state without having produced [CP-1], STOP — you skipped the protocol.**

### STEP 0: Load Context (silent)

- **sprint-state.md**: already in memory from boot (memory-first rule — do not re-read). **Scope: patch mode only.** If STEP 1A selects *full write*, its verbatim-disk-read precondition overrides this line and the file must be re-read in full before rebuilding — see STEP 1A. Reading here at STEP 0 is still unnecessary; the override applies at the point the rebuild is about to happen.
- **Active ISS file**: if an issue is active and its file is not yet in memory, load only the section the current phase needs. Skip entirely if no issue is active (closure, planning, brainstorm).
- **sprint-state-template.md**: do NOT load now. STEP 1 loads it lazily only if full-write mode is chosen.

No display output. If sprint-state is missing from memory (compaction edge case), read it from disk once — this is the one exception to memory-first at checkpoint time, because everything downstream depends on it.

### STEP 1: Prepare

**A — Determine save mode.** Sprint-state is in memory from boot. Check structural integrity:

1. **Tag pair validation**: Verify both `[SECTION]` and `[/SECTION]` tags exist for each section.
2. **Duplicate detection**: No tag appears more than once.
3. Count structural issues found.

**Full write mode** when ANY of:
- Structural issues ≥ 6 (rebuild with template validation)
- Changed sections > 6 (more reliable than many individual patches)
- Compaction due: `(conversation_number - last_full_write_conv) >= 5` AND context < 80% (with history compression). If context ≥ 80%: skip, note "compaction overdue" in `continue_with`.
- File size flag = `cap` (from A-bis, below)

Otherwise **Patch mode**: Edit tool on individual sections. Structural issues < 6 → patch the specific issues and continue.

**Post-closure mode** — when `_status: complete` AND `_closure_time` is set (a closed sprint; work happened in a brainstorm/maintenance conversation between close-sprint and the next organize): always patch mode, and `[CONVERSATION]` is **not** bumped. `/nexus-start` STEP 6 displays such conversations as Conv 0 of the next sprint and never reads `conversation_number`, and organize-sprint discards the block — a bump would manufacture a phantom Conv N+1. Write only: METADATA `_updated`, `[BOOTSTRAP]/continue_with` (append a `POST-CLOSURE WORK #{n}` block — organize-sprint reads it for awareness, it is not sprint work), `[EXPERIENCE_CAPTURE]` entries (they carry forward to the next sprint via organize), then git commit. [CP-1]/[CP-2]/[CP-3] are still emitted; CP-3 reports `conv fields n/a (post-closure)` and the STEP 1B field table below is skipped. Mirrors the ISS-222 post-closure semantics.

⛔ **Full-write precondition — verbatim disk read before rebuilding.** A full write rebuilds sprint-state *from memory* and replaces the file wholesale, so anything not actually in context is dropped, not preserved. Before building the replacement content:

**Read sprint-state verbatim from disk, in full, immediately before the rebuild.** This is not a "is it in context?" check — after a long conversation the boot copy plus a series of patches is exactly the picture most likely to have diverged from what is on disk, and a mental confidence check will pass anyway. Perform the read.

This **overrides STEP 0's do-not-re-read rule**, which is scoped to patch mode (see STEP 0). The two rules are not in tension: patch mode edits named anchors and needs no fresh copy; full write reconstructs everything and cannot safely proceed without one.

**If the read cannot be performed** (file locked, tool failure): do **not** rebuild from memory. Remain in **patch mode** when no structural issues were detected — patching a stale-but-intact file is strictly safer than replacing it with a reconstruction. If structural issues *were* detected and a rebuild is genuinely required, follow Error Recovery and surface to the user rather than guessing at content.

Note the inversion this exists to close: the `changed sections > 6` trigger fires precisely when the most has changed this conversation — which is when the in-memory picture is *least* likely to match disk. The trigger correlates with reconstruction risk in the wrong direction, so the read is mandatory rather than advisory.

**A-bis — File size check.** Count lines of sprint-state (from memory) and active ISS file (if loaded). Set flags:

| File | Lines | Flag |
|---|---|---|
| sprint-state.md | ≤ 350 | `sprint_state_compress = none` |
| sprint-state.md | 351-450 | `sprint_state_compress = warning` → T3 gate (File Size Governance table above) |
| sprint-state.md | > 450 | `sprint_state_compress = cap` → mandatory compression |
| Active ISS | ≤ 500 | `iss_compress = none` |
| Active ISS | 501-700 | `iss_compress = warning` → T3 gate + decompose hint (if implementation phases remain) |
| Active ISS | > 700 | `iss_compress = cap` → mandatory compression + decompose hint |

If any flag = cap or user accepted warning → override save mode to **full write**. (Compression requires rebuild, not patches. Compression applies during the single write pass — no redundant writes.)

**Archive-imminent exception** (ISS compression only): If `_status: closing` OR the active ISS appears in sprint-state `[OBJECTIVES]/completed` (next conversation will archive it via `/nexus-close-sprint` STEP 5), **skip ISS compression** regardless of flag — compression on a file about to leave the active state space is wasted protocol enforcement (elegant_minimum: don't do work that's about to be undone). Sprint-state compression rules still apply. Note skip in [CP-1] output: `iss_compress = skipped-archive-imminent`.

**ISS decompose hint** (at warning or cap, only if implementation phases remain):
Display: "💡 Consider `/nexus-decompose-issue` — this issue may benefit from splitting."
Skip if: issue is in Evaluation phase or has only 1 phase remaining.

⛔ **Output [CP-1] now.** Display: `⛔ [CP-1] Save mode: {mode} — changed sections: {N}, structural issues: {N}, tag pairs: {N}, compress: {sprint_state_compress}/{iss_compress}`
Cannot proceed to STEP 2 without this output.

`tag pairs: {N}` is the **pre-write baseline** that STEP 4 reconciles its post-write count against. Without it CP-3 has nothing to compare to.

- **Count from disk, not from memory — and count BOTH halves.** Run `grep -cE '^\[[A-Z_]+\]$' .nexus/active/states/sprint-state.md` **and** `grep -cE '^\[/[A-Z_]+\]$' .nexus/active/states/sprint-state.md`. `tag pairs: {N}` is the **matched** figure: report `{N}` when the two agree, `{open}/{close}` when they do not. Counting open tags alone is what makes an *asymmetric* loss invisible — deleting a single close tag leaves the open count unchanged, so a STEP 4 delta computed the same way reads 0 on a structurally broken file. STEP 4 reconciles against this figure using the identical pair of commands. Both are counts, not file loads — this is the one read STEP 0's rule does not cover, and it removes the memory-vs-disk ambiguity that would otherwise make the delta meaningless (a baseline taken from a stale in-memory copy reports a phantom mismatch, or masks a real one).
- **Count every structural tag at every nesting level**, line-anchored. Sprint-state nests `[SYSTEM_ISSUES]` and `[BEHAVIORAL_INSIGHTS]` inside `[EXPERIENCE_CAPTURE]`; counting only top-level tags yields 12 where counting all levels yields 14. Either convention is defensible in isolation — but pre-write and post-write **must use the same one**, or the delta is noise. The line-anchored regex above is the convention.
- The figure must be **mechanical** (an actual count), never estimated.

**Template validation on all full writes**: Load `sprint-state-template.md` for structure reference. Build complete sprint-state from the verbatim disk read required by the full-write precondition above (never from memory alone), validate before writing:
- All section tag pairs present and matched
- No duplicate tags
- All expected sections present (PROJECT_BRIEF, CONVERSATION, BOOTSTRAP, OBJECTIVES, DECISIONS, CANDIDATES_PATTERNS, PATTERNS_IN_USE, FILES_MODIFIED, DISCOVERIES, EXPERIENCE_CAPTURE, MOMENTUM, CONVERSATION_HISTORY)
- Field formats match reference (scores as integers, dates as YYYY-MM-DD)

**B — Scan conversation content.** Prepare content for each sprint-state section.

**Always update**:
- METADATA (_updated: today's date + time if available, verify _sprint/_status/_mode/_title)
- CONVERSATION (every field — enumerated below, not summarized)
- BOOTSTRAP (continue_with with full handoff + files_to_load)
- OBJECTIVES (scores from two-place updates or work progress)

**`[CONVERSATION]` field-by-field** — checkpoint is the **sole persister** of this block. No other skill writes these fields, so a field this step does not name is a field nothing updates. Set every one, by name (skip the whole table in **post-closure mode**, STEP 1A):

| Field | Set to |
|---|---|
| `conversation_number` | the current conversation number, N |
| `sprint_state_saved_at_conv` | **the same N** — these two encode one fact and MUST be equal on disk after the write |
| `sprint_state_saved_at_context` | context percentage at save time |
| `checkpoint_saves` | previous value + 1 |
| `last_checkpoint` | `Conv {N} {type}` + a one-line description of what was saved |
| `last_full_write_conv` | N — **full write only**; leave unchanged in patch mode |

`conversation_number` and `sprint_state_saved_at_conv` are deliberately redundant, and the redundancy is load-bearing: `/nexus-start` STEP 6 derives the next conversation number by incrementing the saved value, so a counter that fails to bump produces a *colliding* conversation number whose checkpoint labels, `[CONVERSATION_HISTORY]` entries and `[AUTO]` decision prefixes all duplicate an earlier conversation's. Two fields disagreeing is the only signal that this happened — STEP 4 reconciles them and hard-blocks on `MISMATCH`.

This list is enumerated rather than summarized on purpose. The Sprint 107 Conv 6 checkpoint read the prior instruction — *"CONVERSATION (context %, conv #, ...)"* — and bumped one of the two fields, leaving `conversation_number: 5` against `sprint_state_saved_at_conv: 6`. "conv #" named neither field, so which one got written was left to the writer.

**Update when changed** — scan conversation for:
- DECISIONS, CANDIDATES_PATTERNS, PATTERNS_IN_USE
- FILES_MODIFIED, DISCOVERIES
- EXPERIENCE_CAPTURE, MOMENTUM, CONVERSATION_HISTORY

**Preserve if present**: CRITICAL_CONTEXT, REFERENCE_FILES — optional sections, never delete.

**Closure detection sub-behavior**: If all objectives complete, none planned/in_progress, during evaluation or later → set during the METADATA scan: `_status: closing`, `current_focus: learning`, `continue_with → close-sprint`. Do NOT invoke `/nexus-close-sprint` inline — `/nexus-start` dispatches it next conversation.

**Scan rules**:
- `continue_with`: must be specific enough to start immediately. "Continue working on issue" = too vague. "Complete validation of phase 3, run edge case tests" = specific enough.
- `files_to_load`: 3-5 max. Always include active ISS. In MIXED mode: only the ISS currently being addressed.
- `counts` (measurement discipline): Any count written to `continue_with` or progress sections (MOMENTUM / DISCOVERIES / CONVERSATION_HISTORY) that a downstream phase will consume as an authoritative figure must be **mechanical** or **explicitly marked provisional** — never a bare eyeball estimate. Eyeballed counts consumed downstream cause correction churn (ISS-207: Conv-2 estimates 13/20/22 → Conv-3 mechanical recount 15/23/27). Distinguish three kinds:

  | Kind | What it is | How to write it |
  |---|---|---|
  | Mechanical | Actually enumerated (`grep -c`, `wc -l`, hand-count) | Bare number: `15 anomalies` |
  | Provisional | Eyeballed, but will be consumed downstream as a figure | Mark it: `~13 (provisional — recount at consolidation)` |
  | Ballpark | Narrative magnitude, not consumed as a precise figure | Plain prose: `dozens of`, `several` — no precise number |

  Complements (does not duplicate) framework-audit-playbook §6, which governs *edit-size* measurement (bytes/chars/tokens) for optimization work — a distinct surface.
- **Subsequent checkpoints**: If not the first checkpoint this conversation, scan only from previous checkpoint forward. For append-only sections (FILES_MODIFIED, DISCOVERIES, EXPERIENCE_CAPTURE, CONVERSATION_HISTORY), verify entries aren't already present before appending — duplicates waste tokens.

### STEP 2: Verify ISS

Check: did methodology work happen this conversation? Consult the active methodology skill's last completed step to determine what needs persisting.

If ISS content exists only in conversation (not on disk): write/patch to ISS file now. Preserve any progress markers placed by methodology steps.

**Prior-commitment scan**: Before declaring methodology work verified, scan the conversation for explicit promises made earlier this conversation (`"I'll {action}"`, `"I will surface {X}"`, `"verify after writing"`, `"address inline"`). Confirm each was honored. Unhonored commitments are gaps — address inline now, or document in `continue_with` for next conversation. Especially relevant pre-compaction: commitments made before context loss are easy to drop. Compaction-recovery boots should re-scan continue_with for such carry-overs.

Display: "✓ ISS-XXX verified (content current on disk)" or "✓ No ISS changes to persist"

⛔ GATE: Cannot save sprint-state until ISS content is verified on disk.

### STEP 2-bis: ISS Implementation-Log Self-Audit

Lightweight reconciliation that catches paperwork drift `[WRITE-VERIFIED]` cannot see — Status fields, Changes Made tables, and section-tag positions inside ISS files modified across a sequence of writes in the same conversation. Advisory by design (flags, not blocks); no `[CP-N]` gate output.

**Trigger gate**: skip this sub-step entirely when no ISS files were modified this conversation. Detection (best-effort introspection):
- Scan conversation output for `⛔ [WRITE-VERIFIED]` markers whose path matches `.nexus/issues/ISS-*.md`, AND/OR
- Scan FILES_MODIFIED entries added since the previous checkpoint for paths matching `.nexus/issues/ISS-*.md`.

If no modified ISS files detected → display `✓ No ISS modifications — self-audit skipped` and continue to STEP 3. Otherwise, run the three checks below against each modified ISS file. Each modified ISS is already cache-warm from STEP 2 (Verify ISS) — no fresh reads required unless the conversation introspection is ambiguous about post-STEP-2 state.

**Check A — Section-tag integrity**:
Scan for the 5 expected section tag-pairs: `Solution-Design`, `Implementation-Plan`, `Implementation-Log`, `Evaluation-Results`, `Closure`. Flag any of:
- Open tag (`[Section: X]`) without matching close (`[/Section: X]`), or vice versa.
- Duplicate of the same open or close tag.
- An open tag positioned inside another section's body region (between its sibling's open and close) — i.e., misplaced. Scope this check to actual structural tags at line-start positions, not literal mentions of `[Section: X]` inside prose.

**Check B — Implementation-Log Status diff**:
For each modified ISS, introspect the conversation's `⛔ [WRITE-VERIFIED]` markers + new FILES_MODIFIED entries to identify which phase(s) of that ISS produced disk writes this conversation. If the ISS Implementation-Log `### Status` still reads `pending`, `*Not started*`, or otherwise contradicts a write-verified phase → flag.

**Check C — Changes Made completeness**:
For each file appearing in a `⛔ [WRITE-VERIFIED]` marker this conversation (excluding `.nexus/active/states/*`, `.nexus/active/registries/*`, and the ISS file itself), check the corresponding ISS Implementation-Log `### Changes Made` table for a row referencing that path. Missing row → flag.

**Output format**:
- Clean: `✓ Self-audit clean ({N} ISS file{s} checked)`
- Flags: `⚠️ Self-audit flags ({N}):` followed by one-line `{ISS-XXX} {Check A|B|C}: {description}` entries.

**Behavior**: flags are advisory — the user can address them inline (patch the ISS now), acknowledge and continue (note in `continue_with`), or override. This sub-step does NOT block; STEP 3 proceeds regardless of flag count.

**Best-effort scope**: marker introspection is best-effort across the conversation. A missed marker produces a missed flag, never a false hard-block. The next fresh-conversation read remains the safety net (the way Sprint 082 ISS-177 paperwork drift was originally caught) — this sub-step is an earlier, not perfect, checkpoint.

### STEP 3: Capture Experience

Collect experience observations from this conversation. These feed the learning loop at sprint closure.

**[SYSTEM_ISSUES]** — problems that could recur or friction that could be reduced:

| Type | Meaning | Example |
|---|---|---|
| violation | Protocol not followed | Skipped memory-first check, skipped zone-check |
| gap | Missing functionality or guidance | No skill for X, unclear protocol for Y |
| bug | Something broken | File write silently failed, wrong path resolved |
| anti-pattern | Bad practice observed | Over-engineering, premature abstraction |
| improvement-needed | Clear improvement opportunity | Skill step could be streamlined |
| improvement-mentioned | User suggestion not yet an issue | "We should add X someday" |

**[BEHAVIORAL_INSIGHTS]** — how the user prefers to work:

| Type | Meaning | Example |
|---|---|---|
| preference | User expresses like/dislike, usually/always/never | "I prefer seeing the diff before committing" |
| correction | User explicitly corrects NEXUS behavior | "Don't consolidate that, keep the detail" |
| character-defining-moment | Fundamental principle or philosophy stated | "Quality over speed, always" |
| insight | Realization about working style or approach | User thinks in terms of runtime cost optimization |

**Candidate patterns** [CANDIDATE] — novel solutions that could generalize:
- Approach that worked but wasn't obvious
- User notes "this could be a pattern"
- Solution applicable beyond the current issue

**Capture filters** — before adding any entry, ask:
- "Does this describe a problem that could recur or friction that could be reduced?" → SYSTEM_ISSUES
- "Does this reveal how the user prefers to work?" → BEHAVIORAL_INSIGHTS
- "Is this a novel solution that could generalize?" → CANDIDATE
- "Is this just a one-time instruction or routine event?" → skip — do not log

**Friction triggers** — actively watch for these during the conversation:
- File operation required retry or workaround
- Workflow step felt unnecessary or counterproductive
- User had to correct or redirect approach

**Approval behavior** — **[T2: Balanced+Full ask | Streamlined: auto-log+notify | Zone ≥ 80%: auto-log regardless (save-quality override)]**:

- **Auto-triggered (zone ≥ 80%)**: auto-log without asking, at any control level. Rationale: at red zone the priority is preserving quality, not permission-gathering. Note in the response that entries were auto-logged.
- **User-requested / progress checkpoint (< 80%)**: follow the tier behavior — Balanced and Full Control ask approval before writing `[SYSTEM_ISSUES]`, `[BEHAVIORAL_INSIGHTS]`, `[CANDIDATE]`; Streamlined auto-logs and notifies (per [AUTO] decision-log convention in CLAUDE.md [Section: Control-Levels]).
- **Always save directly** (no approval, any mode): Discoveries, decisions, files modified, momentum, conversation history. These are factual audit trail, not learning-loop input.

**Presentation format when asking** (by item count):
- 1 → prose `"Save? [Y/n]"`
- 2–4 → single AskUserQuestion (multiSelect)
- 5–8 → 2 questions by category
- 9–12 → 3 questions
- 12+ → text format

**Skip this step entirely if**: no experience items and no Candidate patterns to capture.

🌱 **Seed check**: Any forward-looking ideas worth parking? If so, `invoke /nexus-plug-seed`. Reminder, not a gate.

⛔ **Output [CP-2] now.** Display: `⛔ [CP-2] Experience: {N} items captured — approval: {asked|auto-logged|skipped (none)}`
Cannot proceed to STEP 4 without this output.

### STEP 4: Write & Commit

**Patch mode** (≤6 sections changed): Use Edit tool (old_string → new_string) for each changed section. If Edit fails (non-unique match) → fall back to full write.

**Full write mode**: Build complete sprint-state from the verbatim disk read mandated by STEP 1A's full-write precondition — not from memory alone. Validate all tag pairs. Use Write tool. Update `last_full_write_conv`.

**Post-write structural verification** (both save modes — patch and full write):

Read the file back from disk and run the same structural checks STEP 1A ran pre-write. Size and field spot-checks are **not** sufficient: a file whose sections have been destroyed by a bad programmatic patch stays plausibly sized and its spot-checked fields stay correct. Structure is what has to be verified, and it must be verified *after* the write, not only before it.

1. **Tag-pair count** — count matched `[SECTION]`/`[/SECTION]` pairs with the same line-anchored, all-nesting-levels convention CP-1 used (`grep -cE '^\[[A-Z_]+\]$'` and `grep -cE '^\[/[A-Z_]+\]$'`), and reconcile against CP-1's `tag pairs: {N}` baseline. Same convention on both sides or the delta means nothing. This is a **pre-vs-post delta**, not a fixed expected-section list: `CRITICAL_CONTEXT` and `REFERENCE_FILES` are optional ("Preserve if present"), so an absolute list false-positives on any sprint-state legitimately carrying them. Delta ≠ 0 without an intentional section add/remove = structural loss.
2. **Duplicate detection** — no tag appears more than once.
3. **Conversation-field consistency** — read `conversation_number` and `sprint_state_saved_at_conv` back from disk and confirm they are equal (STEP 1B's invariant). Report `consistent` or `MISMATCH` from the values on disk, never from the values you intended to write.

**Hard block on failure.** If the tag-pair delta is non-zero **and not explained by a section you intentionally added or removed during this save**, a duplicate appears, or the conversation fields disagree:

An intentional change is reconciled *in the CP-3 line*, not by blocking — write `tags 14/15 (+[CRITICAL_CONTEXT])` and proceed. Blocking on it would restore from HEAD, re-apply, fail the same check again, and ESCALATE a save that was correct all along. The carve-out is deliberate and narrow: it covers only a section this checkpoint meant to add or remove, never an unexplained delta.

- **Do NOT commit.** Restore the file from git HEAD with `git checkout HEAD -- .nexus/active/states/sprint-state.md`, then re-apply the changes by a different route (patch mode if the full write failed; the Edit tool if a script failed), and re-verify.

  Use `git checkout`, **not** `git show HEAD:{path} > {path}`. The shell truncates the redirect target *before* `git show` runs, so a failed `git show` — bad ref, wrong path, detached HEAD — leaves sprint-state empty and turns the recovery step into a second data-loss event. `git checkout` writes only on success.
- Report the failure in the CP-3 line rather than suppressing it — `tags 14/9` and `conv fields MISMATCH` are the evidence that the block worked.
- Staging a structurally damaged sprint-state makes git a *carrier* of the corruption instead of the recovery path. The Sprint 107 Conv 7 wipe was recoverable in full only because nothing had been committed yet.

⛔ GATE: Cannot proceed until the post-write structural verification passes on disk.

**Programmatic patching of sprint-state** (scripts, `sed`, `python` — not the Edit tool):

Section names appear inside sprint-state's own prose **by design**: `[FILES_MODIFIED]`, `[DISCOVERIES]` and `[BOOTSTRAP]` narrate work done *to other sections*, so they mention those sections' names in running text. Any predicate that matches a tag as a bare substring will therefore hit a prose mention before the real tag.

| Rule | Why |
|---|---|
| Match section tags by **exact full-line comparison** (`line.strip() == "[MOMENTUM]"`), or anchor the regex to line start and end (`^\[MOMENTUM\]$`) | `s.index("[MOMENTUM]")` matched a prose mention ~70 lines above the real tag and the resulting slice deleted `[FILES_MODIFIED]`'s tail, all of `[DISCOVERIES]`, and the whole `[EXPERIENCE_CAPTURE]` block (V107-09, Sprint 107 Conv 7) |
| Never use unanchored `sed` ranges (`/\[SECTION\]/,/\[\/SECTION\]/`) | The range re-triggers on prose mentions and runs past the close tag — silently returning or rewriting the wrong region |
| Count tag pairs before **and** after any scripted write | Recovery in Conv 7 worked only because a tag-integrity count happened to run immediately afterwards (28 → 18 tags) |
| Set `PYTHONIOENCODING=utf-8` before any Python that reads or prints sprint-state | On Windows, Python stdout defaults to cp1252 and raises `UnicodeEncodeError` mid-output on emoji/box-drawing characters — a silent partial write (V107-01) |

**Prefer the Edit tool** for section-scoped changes: it matches literal strings and fails loudly on an ambiguous match, where a script fails silently on the wrong one.

**Git commit** (after sprint-state verified):

```bash
git add -A
git commit -m "nexus: checkpoint Conv {N}, {ISS}, {%}% context" --quiet
```

Scope: `git add -A` stages all tracked and new files — `.nexus/`, `.claude/`, and project files.

If git not initialized or fails: note in continue_with, continue without backup.

**Reactive freshness scan** (Bash environments only — between `git add -A` and `git commit`):

After staging, list staged files via `git diff --cached --name-only` and match them against **edge `E-12`'s `source` field in `.nexus/active/derivations.yaml`** — the manifest row that declares `changelog-registry.yaml`'s source set. Read the set from there. Do not restate it here.

> Through v2.4.0 this step carried its own hardcoded copy of that list, labelled in-file as *"the core files changelog-scan tracks"* — a hand-maintained twin of `/nexus-start` STEP 4's source set, two copies of one value living in the two steps that read it. The manifest declares that duplication as edge **E-07** with `disposition: eliminable`, and this change takes the elimination branch (ISS-240 Phase 3.7). E-07's predicate is now a regression guard: it fires if the second copy is ever reintroduced here.

If the manifest cannot be read, **run the scan unconditionally** rather than falling back to a restated path list — a needless scan costs ~5K, a skipped one leaves the registry stale, and a fallback copy would reintroduce exactly the edge this step just eliminated.

On a match, auto-invoke `/nexus-changelog-scan` mode 1 (Quick scan — current versions only, ~5K) before the commit. After the scan modifies `.nexus/active/registries/changelog-registry.yaml`, run `git add .nexus/active/registries/changelog-registry.yaml` so the refreshed registry rides the same commit.

| Level | Behavior |
|---|---|
| Streamlined | Auto-fire silently |
| Balanced | Auto-fire + notify: `📐 [AUTO] Reactive freshness scan triggered — changelog-registry refreshed` |
| Full Control | Auto-fire + notify (T3 housekeeping convention; not a T2 decision gate) |

If no staged paths match → skip the scan silently. If the scan itself fails → log the failure in `continue_with`, proceed to commit without registry update; the next boot's derivation sweep surfaces the drift again.

**Stale-edge escalation intake** (ISS-240 Phase 3.4 — the boot hand-off):

Boot's derivation sweep never mutates sprint-state, so an edge that has been stale for two or more sprints is handed here instead of printing the same header warning forever. Read `.nexus/.freshness-checked` lines 2+ — the staleness ledger, one `stale: E-NN=SSS` line per **unresolved** edge (the sweep reported `findings > 0` or the predicate terminated `ESCALATED`), where `SSS` is the sprint the edge was **first** left unresolved.

For each ledger line where `{current _sprint} − SSS >= 2`, add a `[SYSTEM_ISSUES]` entry during STEP 3 (Capture Experience), type `gap`:

`gap: derivation edge {E-NN} stale since Sprint {SSS} ({N} sprints) — {source} → {derived}. Boot has warned every conversation since; the header is not being acted on.`

Ledger absent, empty, or carrying no line past the threshold → no entry, no output. This is intake only: checkpoint files the entry, it does not repair the edge. Line 1 of the file is the rate-limit key and is never parsed here.

Pair: complements `/nexus-start` STEP 4 Derivation Sweep — boot warns, checkpoint self-heals and escalates.

⛔ **Output [CP-3] now.** Display: `⛔ [CP-3] Verified: sprint-state {N} lines, tags {pre}/{post} pairs, conv fields {consistent|MISMATCH|n/a (post-closure)}, ISS on disk: {yes|no|n/a}, git: {committed|failed|n/a}`
Cannot proceed to STEP 5 without this output.

The structural fields are emitted on **every** checkpoint — patch mode and full write alike. A check that reports only when it fires cannot be distinguished from a check that never ran, so `tags 14/14` on a clean save is as load-bearing as `tags 14/9` on a broken one. All values come from the post-write disk read.

### STEP 5: Report

**Progress checkpoint** (mid-work — minimal, don't break flow):
```
✅ Progress saved (Conv {N}, ~{XX}%)
   {1-line what was captured}
   ISS-XXX: ✓ verified on disk
```

**Final checkpoint** (context ≥ 80% or phase complete):
```
✅ Checkpoint saved — progress preserved
═══════════════════════════════════════
Accomplished:
• {accomplishment 1}
• {accomplishment 2}

Next conversation picks up with:
  {WHAT from continue_with}

Files to load: {count}
Context: ~{XX}%
═══════════════════════════════════════

{Agent costs (if any — render AFTER closing border so table displays correctly):}

| Agent | Model | Tokens | Purpose |
|---|---|---|---|
| {name} | {tier} | {N}K | {purpose} |
| Total | — | {N}K | — |
```

**Model recommendation** (final checkpoint only — append to final checkpoint display):
Inspect next objective from `continue_with` and [OBJECTIVES]. Display:

| Next Task | Recommendation |
|---|---|
| C:1-2 issue | "💡 Next conversation: Sonnet recommended — simple issue, lower cost" |
| C:3 issue | "💡 Next conversation: Your choice — Sonnet for speed, Opus for depth" |
| C:4-5 issue | "💡 Next conversation: Opus recommended — complex reasoning benefits" |
| Sprint closure | "💡 Next conversation: Sonnet recommended — procedural workflow" |
| Sprint planning | "💡 Next conversation: Opus recommended — dependency analysis and planning" |
| Unknown / multiple options | "💡 Next conversation: Check next issue complexity before choosing" |

Display-only. No enforcement, no runtime cost. User decides at boot.

After completing checkpoint: suppress zone warnings in the same response.

---

## Error Recovery

| Problem | Recovery |
|---|---|
| Edit fails (patch mode) | Fall back to full write with template validation |
| Full write fails | Retry → essential sections only (METADATA + CONVERSATION + BOOTSTRAP + OBJECTIVES) → alert user |
| Corruption after save | Git restore → verify → retry → if still broken, alert user |
| ISS write fails | Save sprint-state anyway. Note in continue_with: "⚠️ ISS write failed — verify next conv" |
| Context critical during save | Complete with minimum content, skip experience capture. Any save > no save. |
| Stale `.git/index.lock` blocking commit | **Investigate before deleting.** POSIX: `lsof .git/index.lock` (or `ps aux \| grep git`). Windows: check Task Manager for active `git.exe`. If an active process holds the lock — wait for completion, do NOT delete. If no process holds it (orphan from crashed/killed git) — delete the lock file and retry the commit. Blind-deleting an active lock corrupts the index. Surface to user before deleting if uncertain. |

For detailed recovery: read `.nexus/active/Emergency-Reference.md`.

---

## Sprint-State Compression Priorities

When `sprint_state_compress = cap` (or user accepted warning), apply these during the full write pass. Execute in priority order until under 450 lines:

| Priority | Section | Action | Safety Rule |
|---|---|---|---|
| 1 | CONVERSATION_HISTORY | Keep recent 5 detailed, older → single-line summaries. Entries >10 conv old → consolidated group summaries. | Verify sprint-relevant content exists in active ISS before removing |
| 2 | EXPERIENCE_CAPTURE | Drop resolved [SYSTEM_ISSUES] (addressed or converted to issues). Drop [BEHAVIORAL_INSIGHTS] already persisted to auto-memory or behavioral preferences. | Keep unresolved. If uncertain → keep. |
| 3 | MOMENTUM | Keep latest 3 entries only. | Older momentum is stale by definition |
| 4 | DECISIONS/made | Consolidate entries older than 3 conversations into group summaries. | Keep recent 3 conversations' decisions verbatim |
| 5 | FILES_MODIFIED | Deduplicate: same file modified multiple times → keep latest entry with cumulative description. | Never drop unique file entries |
| 6 | DISCOVERIES | Merge related insights. Drop discoveries already captured in patterns or ISS files. | Keep discoveries not yet persisted elsewhere |

**Before compacting any section**: verify content being removed exists elsewhere (ISS file, auto-memory, patterns). If ISS not current, patch it first — then compact.

---

## ISS File Compression Priorities

When `iss_compress = cap` (or user accepted warning), apply during the ISS write pass. Compress completed phases while preserving what active/future phases need:

| Completed Section | Compress To | Preserve |
|---|---|---|
| Solution-Design (if past Build) | Keep Approach + Files Affected. Collapse Architecture/Tools/Risks to 1-line summaries. | Key Decisions (may inform future phases) |
| Implementation-Plan (done phases) | Collapse completed step tables to "Phase N: X steps, all ✅" | Pending/active phase tables in full |
| Implementation-Log (done phases) | Keep Changes Made (audit trail). Collapse Status/Decisions/Issues to summaries. | Pattern Outcomes (needed at evaluation), unresolved Issues |

**Safety rule**: Before compressing any ISS section, verify no `continue_with`, active implementation step, or pending phase references content being compressed. If referenced → preserve in full.

---

## Discipline Enforcement Layer
[Section: Discipline-Enforcement-Layer]

Full Layer (write/close class) per operation-skill-template §Discipline Enforcement Layer — checkpoint declares progress *saved* and commits to git. Its over-claiming surface: a false "saved" before the disk write is verified, a fabricated `[CP-3]` line, skipping experience capture, or premature "Checkpoint saved" before STEP 4 completes. The existing `[CP-1]/[CP-2]/[CP-3]` mandatory outputs **are** this layer's terminal-state mechanism; this section names the posture and the failure-vocabulary around them.

### 1. Default Adversarial Posture

This operation runs adversarial by default. I assume the save is **incomplete** until disk read-back proves otherwise — "saved" is earned by verification, not by running the Write tool. I do not assume the write landed; I confirm it (STEP 4 read-back ⛔ GATE).

Not complexity-conditional, and not relaxed under context pressure: red zone (≥80%) is exactly when a rushed, unverified save corrupts continuity. The save-quality override *adds* discipline (auto-log experience) — it does not remove the verify gate.

### 2. Red Flags Vocabulary

| Red Flag | Signal | Corrective |
|---|---|---|
| "Saved!" / "Checkpoint complete" before [CP-3] | Premature completion — write not verified | Emit [CP-3] with read-back values first |
| "git probably committed" | Unverified commit claim | Check the commit result; [CP-3] git field is {committed\|failed\|n/a}, never assumed |
| "context is tight, skip experience" | Silent scope drop | At ≥80% auto-log (don't skip); at <80% follow the tier gate — [CP-2] = skipped only when genuinely none |
| "sprint-state looks fine, no need to read back" | Verification shortcut | STEP 4 read-back is mandatory — confirm size + key fields on disk |
| "continue_with is good enough" (vague) | Continuity risk | "Continue working on X" is too vague; require a resume-immediately handoff |

### 3. Rationalizations to Watch For

| Excuse (you might think this) | Reality (why the excuse is wrong) |
|---|---|
| "I wrote the file, so it's saved." | Write-tool success ≠ verified content. Corruption/truncation is caught only by read-back (STEP 4 ⛔ GATE). |
| "Nothing important changed, skip the ISS verify." | STEP 2 ⛔ GATE is unconditional — undisked methodology work is exactly what checkpoints exist to preserve. |
| "Red zone — save fast, skip the gates." | Context pressure is when continuity matters most. Save means SAVE at full rigor, not rush (CLAUDE.md). |
| "I emitted [CP-3] last checkpoint, this one's the same." | Each checkpoint's [CP-3] reports *this* save's read-back. Reusing prior values is fabrication. |

### 4. Anti-Patterns

The 9 base anti-patterns inherit from operation-skill-template §Discipline Enforcement Layer §4 (Gate-Dressed Conditional, Cross-Reference-Only Gate, Post-Hoc Adversarial, Constraint-Wall-Only, Placeholder Shipping, Premature-Completion Vocabulary, Silent Downgrade, Over-Specified Step, Under-Specified Step). checkpoint-specific additions:

#### ❌ Fabricated CP-Line

**What it looks like**: Emitting [CP-1]/[CP-2]/[CP-3] with plausible values not read from the actual save/scan.
**Why bad**: The CP markers are the verification evidence. Fabricated values defeat the entire gate protocol — the user believes work is preserved when it may not be.
**Corrective**: Each CP value comes from the real operation (mode determination, experience count, disk read-back).

#### ❌ Premature "Saved" Celebration

**What it looks like**: "✅ Checkpoint saved" in STEP 5 before STEP 4's read-back ⛔ GATE passed.
**Why bad**: Celebration vocabulary signals success before it's earned; if the write failed, the user is misled into ending the conversation on lost work.
**Corrective**: The STEP 5 report fires only after [CP-3] confirms disk + git.

### 5. Bounded Iteration Cap

If a save step fails (write corrupt, Edit non-unique, git lock), retry up to **3 times** per the STEP 4 / Error Recovery ladder (patch → full write → essential sections). On the 3rd consecutive failure:

ESCALATE — surface to the user with the gate name, what was attempted (3 bullets), and what blocks. Do not silently report "saved" on an unverified write. "Any save > no save" (Error Recovery) means save minimum content *and say so* — not claim a full save.

### 6. FILLED / ESCALATED / SKIP Classification

The checkpoint's terminal states are carried by its mandatory CP outputs — no parallel mechanism:

| State | Carried by | Meaning |
|---|---|---|
| **FILLED** | [CP-3] with read-back values **and its structural fields resolved clean** — tag-pair delta 0, no duplicates, conv fields `consistent` | Save verified on disk *structurally*, not merely present; git committed or explicitly n/a. A [CP-3] line carrying `MISMATCH` or a non-zero tag delta is **never** FILLED — it is a hard block per STEP 4, and remains ESCALATED until the restore-and-retry resolves it |
| **ESCALATED** | Error Recovery → user surface | Save failed after iteration cap; continuity at risk, user informed |
| **SKIP (justified)** | [CP-2] = skipped (none); [CP-1] iss_compress = skipped-archive-imminent | Step deliberately N/A with the stated rule |

No STEP 5 report fires without [CP-3] resolved to FILLED (or an explicit ESCALATED surface).

### Layer Audit Checklist

- [ ] Default Adversarial Posture declared (not complexity-conditional, not red-zone-relaxed)
- [ ] Red Flags table reproduced in-file
- [ ] Rationalization table present with ≥4 excuse/reality pairs
- [ ] Anti-Patterns: 9 base inherited + checkpoint-specific (Fabricated CP-Line, Premature "Saved" Celebration)
- [ ] Bounded Iteration Cap specified (3-attempt rule, maps to Error Recovery ladder)
- [ ] FILLED / ESCALATED / SKIP mapped to [CP-1]/[CP-2]/[CP-3] + Error Recovery
- [ ] No softened gate phrasing

[/Section: Discipline-Enforcement-Layer]
