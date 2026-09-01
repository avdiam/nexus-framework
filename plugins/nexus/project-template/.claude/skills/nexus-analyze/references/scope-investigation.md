*Version: 1.1.0 | Date: 2026-08-06 | Sprint: 107*

# Analyze — Scope Investigation References

Lazy-loaded companion to `nexus-analyze/SKILL.md`. Holds the three §1 Investigate conditional sub-flows — **Scope-Discovery**, **Scanner-Offer**, **Cross-Cutting-Checklist** — externalized from the always-loaded SKILL.md body (ISS-209, Class-A externalization). Each section is single-source (PAT-113): SKILL.md's [Section: Simple-Path] Step 1.E and the `default`/`bug`/`question` type files' §1 Investigate invoke them by reference. Load this file only when a trigger below fires — the Simple Path's mandatory baseline loads nothing.

## Reference Loading Conditions

| Trigger | Load section |
|---|---|
| Registry `ISS-XXX.scope_files` + ISS `### Files Affected` both empty/broad AND `_project_type: code` | [Section: Scope-Discovery] |
| After Scope-Discovery: candidate list thin (<3) / hit safety-valve (>50) / low-confidence (C≥3) | [Section: Scanner-Offer] |
| Issue retires/renames/adds a cross-cutting concept (named token recurring across file-classes) | [Section: Cross-Cutting-Checklist] |

---

## Scope Discovery
[Section: Scope-Discovery]

Conditional discovery loop that finds the files in scope for an issue when the registry and ISS file are both empty or broad. Invoked from `types/default.md`, `types/bug.md`, and `types/question.md` §1 Investigate sections. Single-source — the spec lives here.

Discovery extends the existing §1.B "Archaeological Discovery (MANDATORY)" mindset from "search code generally" to "search for *this issue's* scope specifically."

### Trigger Condition

Run discovery when **all** of the following are true:

- `_project_type: code` in sprint-state metadata
- `ISS-XXX.scope_files` in `issues-registry.yaml` is empty `[]` OR contains only broad globs (e.g., `["**/*"]`, `["src/**"]`)
- ISS file `### Files Affected` subsection is empty, placeholder (`*Not started*`), OR only contains broad globs

**What counts as "broad"?** Use semantic judgment:
- *Specific*: a path that names a file directly (`src/auth/login.py`) or a small directory with bounded contents (`src/auth/migrations/`).
- *Broad*: a glob that covers an entire top-level concept area (`src/**`, `**/*.py`, `.claude/skills/nexus-*/`) — too wide to start work from without further narrowing.
- *Borderline*: a glob covering one focused subsystem (`src/auth/**`) — treat as specific if the subsystem is genuinely the issue's scope, broad if the scope is narrower than the whole subsystem.

When uncertain, prefer running discovery — the worst case is the loop converges quickly with the same files the broad glob already covered, and the result gets synced back as specific paths.

If **either** the registry OR the ISS Files Affected has *specific* file paths, **do not run discovery** — instead, sync the populated source to the empty one (registry ← ISS or ISS ← registry). Discovery and sync are mutually exclusive.

If `_project_type` is anything other than `code` (e.g., `creative`, `business`), discovery does not apply — file-grep doesn't make sense for non-code projects.

### Seed Extraction

The full ISS-XXX.md is already in memory at this point in §1 Investigate. Use it as a whole — semantic judgment over mechanical section selection.

1. Scan the entire ISS file (Description, Success Criteria, Solution Design, Architecture, Files Affected if partially populated, Implementation Plan, Notes & Context).
2. Use semantic judgment plus existing project knowledge (from CLAUDE.md, sprint-state, registries already loaded at boot) to propose **5–10 candidate keywords** for grep search. Prefer concrete domain terms (function names, file names, module names, distinctive vocabulary) over abstract verbs.
3. Display the proposed keywords to the user for adjustment **[T2: Balanced+Full ask | Streamlined: auto-proceed if confidence high, notify]**:

```
🔎 Scope Discovery — Proposed Search Keywords
──────────────────────────────────────────────
Based on ISS-XXX, I'd search for:
  1. {keyword_1}
  2. {keyword_2}
  ...
  5. {keyword_5}

Adjust, remove, or add keywords? [Approve / Edit / Add / Remove]
```

User adjusts once. Discovery loop then proceeds autonomously with the approved seed.

### Loop Protocol

After seed approval, iterate autonomously:

1. **Run search** with current keyword set (Glob/Grep).
2. **Refine internally**: from the results, the LLM picks the next iteration's keywords (broader if too few hits, narrower or different if too many).
3. **Track convergence**: after each iteration, count how many *new* candidate files were added to the working set.
4. **Convergence signal**: if **N=2 consecutive iterations** add zero new files, exit the loop.
5. **Safety valve**: if any single iteration returns **>50 raw matches**, pause the autonomous loop and ask the user to narrow:

```
⚠️ Scope Discovery — Safety Valve Triggered
──────────────────────────────────────────────
Iteration {N} returned {count} matches — too broad to triage usefully.
Current keywords: {list}

Narrow the search? [Suggest narrower / Edit keywords / Continue anyway]
```

After the user narrows, resume the autonomous loop from the next iteration.

### Output and Sync

When the loop converges:

1. Present the final candidate file set to the user for adjustment (add/remove entries before syncing).
2. **Sync to BOTH** sources (this is non-negotiable — the two sources can drift, and discovery doubles as a hygiene step):
   - Update `issues-registry.yaml` `ISS-XXX.scope_files` with the final list
   - Update ISS-XXX.md `### Files Affected` with the final list
3. The full candidate set is the canonical *scope* for the issue. **Do not** populate `files_to_load` here — that derivation happens later in [Section: Commit-Protocol] §E from the locked plan's first phase.

### Notes

- The seed extraction is **deliberately** based on the LLM's full-file semantic judgment, not on a mechanical "pull from sections X+Y" rule. Two reasonable LLMs may propose slightly different seeds — that is acceptable; the user-adjustment step is the calibration.
- The loop is autonomous between seed-approval and convergence. The only mid-loop interruption is the safety valve. This intentionally avoids the per-iteration "is this relevant?" chatter that would make discovery feel like an interrogation.
- Sync to both sources is mandatory even when one source is already partially populated by discovery results — this is the fastest way to keep registry and ISS files affected from drifting on issues that touch this loop.

[/Section: Scope-Discovery]

---

## Scanner Offer
[Section: Scanner-Offer]

Conditional offer to invoke the `nexus-scanner` agent for deeper relevance/state/dependency analysis on the candidate list produced by [Section: Scope-Discovery]. Invoked from `types/default.md`, `types/bug.md`, and `types/question.md` §1 Investigate sections, immediately after [Section: Scope-Discovery] completes.

The scanner is a Claude Code agent (`.claude/agents/nexus-scanner.md`, haiku tier, read-only). It runs in isolated context — receives only a curated input contract, returns a structured digest, exits. It does NOT inherit conversation history, design rationale, or anchoring.

This is single-source — the spec lives here, type files invoke by reference.

### Trigger Condition

Offer the scanner only when the issue is complex enough AND the inline discovery output suggests scanner would actually add value. The trigger is conditional, not always-on:

Offer scanner when **all** of the following are true:
- Issue complexity ≥ 3
- AND any of:
  - Scope-Discovery converged with **fewer than 3 candidate files** (thin signal — scanner can find what grep missed)
  - Scope-Discovery hit the **safety valve** (>50 raw matches in one iteration — scanner can do semantic ranking grep cannot)
  - LLM has low confidence ranking the inline candidates (mixed relevance, several borderline entries)

If none of these conditions fire and Scope-Discovery produced a clean confident list (3–7 candidates, all clearly relevant), **suppress the offer entirely**. Never train users to dismiss the prompt as noise.

### User Approval

The scanner is **always opt-in**. Even when triggers fire, never auto-invoke:

```
🔎 Scanner Agent Offer
──────────────────────────────────────────────
Inline discovery converged with {N} candidates.
Trigger: {reason — thin signal / safety valve / low confidence}

Want to run the scanner agent for deeper relevance/state/dependency
analysis? Scanner reads files in isolated context (haiku, read-only)
and returns a structured digest.

[Y] Run scanner   [N] Proceed with inline output
```

Wait for explicit user choice. **[T2: Balanced+Full ask | Streamlined: auto-recommend Y if all triggers fire, notify]**

### Input Contract

When invoking the agent, pass **only** these inputs (curated context per PAT-095):

```yaml
issue_summary:
  id: ISS-XXX
  title: {title}
  type: {type}
  description: {description from ISS}
  success_criteria: {list}
candidate_list: {file paths from Scope-Discovery output}
project_root: {absolute path}
```

**Exclude** from the input: conversation history, design rationale, prior phase decisions, discussion of rejected alternatives, the user's preferences for this issue. The scanner must evaluate files objectively, free of anchoring.

### Output Contract

The scanner returns a structured digest in this format (this is the agent's deliverable — defined here, not in the agent file):

```
🔍 Scanner Report — ISS-XXX
Candidates analyzed: {N} | Recommended: {M} | Suppressed: {K}

═══════════════════════════════════════════════════════════
{n}. {file path}     [{relevance: HIGH/MEDIUM/LOW}]
   Current state: {one-line summary of what the file does and its current state relative to the issue}
   Touches: {sections/symbols within the file relevant to the issue}
   Depends on: {other files this one references or imports}
   Modification estimate: {qualitative — minor / 1-2 sections / major}

{... per recommended file ...}

═══════════════════════════════════════════════════════════
SUPPRESSED (low relevance, briefly stated):
- {file}: {one-line reason}

═══════════════════════════════════════════════════════════
Cross-cutting observations:
- {observation about patterns spanning multiple files, missing infra, novel patterns, conflicts}
═══════════════════════════════════════════════════════════
```

### Integration Model

When the scanner returns its digest, **annotate the inline candidate list** — do not maintain two parallel lists.

1. For each entry in the digest's "Recommended" section: mark the corresponding inline candidate with the relevance tier and enrichment data (current state, touches, depends on, mod estimate).
2. For each entry in the digest's "SUPPRESSED" section: **remove** that file from the working list, but display the suppression briefly with the reason: `- {file}: suppressed by scanner — {reason}`.
3. Append the "Cross-cutting observations" to the working set as context.
4. Present the enriched list to the user for one final adjustment pass — the user can re-add any suppressed file if they disagree with the scanner's call.
5. Sync the final adjusted list to registry + ISS Files Affected (same as the Scope-Discovery sync step).

Disagreement between the scanner and the inline candidate list is **signal**, not error (per PAT-095). The user adjustment step is the arbiter.

### Failure Handling

The scanner can fail in several ways: agent spawning errors, malformed output, empty digest, timeout. In all cases:

```
⚠️ Scanner agent failed: {reason}
   Falling back to inline discovery output.
```

**Graceful degrade** — continue analysis with the unenriched inline candidate list. No retry, no user prompt, no panic. The scanner was opt-in enrichment; the inline list is the safety net.

Do **not** attempt to run the scanner a second time on the same input. If the user wants to retry after fixing whatever caused the failure, they can re-invoke /nexus-analyze and the trigger will fire again on the next eligible issue.

### Notes

- The scanner tools list (`Read`, `Glob`, `Grep` only) is enforced by the agent file's frontmatter. Per principle of least privilege, the scanner cannot write, run shell commands, fetch web content, or modify state.
- The output contract above is the **canonical specification** — the agent file's system prompt must produce exactly this structure. If a future change to the contract is needed, update this section first; the agent file follows.

[/Section: Scanner-Offer]

---

## Cross-Cutting Checklist
[Section: Cross-Cutting-Checklist]

A fixed-class enumeration aid for Files Affected. When an issue **retires, renames, or adds a cross-cutting concept** — a named token that recurs across multiple file-classes (a marker, protocol name, field, enum value, convention, hook, or status value) — these four file-classes are the ones the Files Affected enumeration most often misses, because they live *outside* the skill files where the concept is usually defined. Catching them here (Analysis) is cheaper than catching them downstream at Build grep audits (PAT-098) or P3 Integration Touchpoints.

This section is **single-source** — invoked by reference from [Section: Simple-Path] Step 1 (Research & Discovery) and the `default` / `bug` / `question` type files' §1 Investigate. It is **complementary to** [Section: Scope-Discovery], not a replacement: Scope-Discovery is a keyword-convergence loop gated on *empty/broad scope*; this checklist is a fixed-class grep gated on *concept-shape* — it fires even when the scope is already specific (the common miss case — the gap is in classes the analyst didn't think to look at, not in an unmapped scope).

### Trigger Condition

Run the checklist when **any** of the following holds:

- A **retire / rename / add / remove / migrate / consolidate** verb is applied to a **named concept** in the issue title or description (not a one-off local change).
- The issue's scope spans **≥2 skill folders**, OR mixes skill-files with any non-skill file-class.
- The concept's vocabulary is known (or likely) to **recur across file-classes** — e.g. a marker emitted by hooks, an enum duplicated in a template, a status value read by a fallback reference.

**Suppress** for simple additive single-file refactors and any change whose concept does not leave its home file. When suppressed, say so in one line — `Cross-cutting checklist: N/A — single-file additive` — and move on. Never run it silently-empty; never spam it on local changes.

### The Four File-Classes

For a triggered concept, derive its vocabulary (the concept name **plus variants/synonyms**, **plus the concept's container** — the enum-field name, status-field key, or marker label the concept lives under; for an *addition*, the literal token is absent from the target file by definition, so the container term — not the new token — is what surfaces the touchpoint. ISS-185 backtest: grepping `brainstorm`/`sandbox` across `.nexus/templates/*.md` returns 0 hits, but grepping the container `current_focus` surfaces `sprint-state-template.md`. Thin vocabulary is the load-bearing failure mode per PAT-098 grep-convergence), then grep each class glob. Any hit is a Files Affected candidate.

| # | File-class | Glob(s) |
|---|---|---|
| 1 | Hooks | `.claude/hooks/*.sh` |
| 2 | Supporting-files / architecture manifests | `.nexus/supporting-files/*.md` + `.nexus/active/NEXUS-Architecture.md` |
| 3 | Operational fallback references | `.nexus/active/Emergency-Reference.md` |
| 4 | YAML schema / template / enum files | `.nexus/templates/*.md` |

Skill files themselves are already covered by §1.B Archaeological Discovery and [Section: Scope-Discovery] — this checklist adds the four classes *beyond* skill files.

### Output

Fold every confirmed hit into the working Files Affected list, then sync to **both** registry `ISS-XXX.scope_files` and ISS `### Files Affected` (same sync discipline as [Section: Scope-Discovery]).

**Record the evidence, not the conclusion.** For each class, write the **literal grep command and its hit count** into ISS `### Files Affected` — including classes with zero hits. A bare `class N: 0 hits` line is not sufficient: it asserts a result without showing what was run, which makes a real grep indistinguishable from an eyeballed classification. An explicit zero-hit *command* is evidence the class was genuinely *scanned*, not silently skipped (SCAN-then-classify, per the Sprint 084 ISS-184 false-empty precedent).

**An SC-named glob IS the predicate — run it verbatim.** When the issue's Success Criteria already name a file-class glob (e.g. *"grep-swept across `.nexus/templates/*.md`"*), do not re-derive or narrow it: execute that glob exactly as written, at Analysis, over the whole class. Its output — not your judgment about which files in the class look relevant — is the completeness authority for Files Affected.

> **Precedent (Sprint 106, ISS-227)**: SC-01 named `.nexus/templates/*.md` explicitly and class 4 below covers it, yet Analysis classified only 2 of 4 `PAT-009` references by eye; Build's grep found the rest (`operation-skill-template.md:682`, `issue-specification.md:292`). The class was named twice over and still under-counted. Nothing in the record distinguished "I grepped the class" from "I looked at the class" — which is what the recorded command fixes.

Skip-detection for this section lives outside it, in `nexus-analyze/SKILL.md` [Section: End-of-Workflow-Checklist] → `### Verifications`, which requires the per-class evidence to exist whenever this checklist triggered. That placement is deliberate: a requirement stated only *inside* a step cannot catch that step being skipped entirely — the ISS-227 failure above produced no per-class record at all.

📐 Carrier patterns: PAT-113 (canonical single-home placement), PAT-112 (explicit-discipline-at-authoring-time), PAT-098 (grep-convergence — specifically its ISS-202 generalization: encode cross-surface completeness as an executable predicate over the whole file-class, not a manual enumeration), PAT-121 (match-remedy-form-to-failure-cause — an incomplete-enumeration failure needs an executable predicate plus a detectable artifact, not stronger prose). No new pattern — these already encode the principle.

[/Section: Cross-Cutting-Checklist]
