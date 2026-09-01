*Version: 1.0.1 | Date: 2026-06-21 | Sprint: 106*

# Validate — Sprint-Level Type

Loaded by SKILL.md Router when scope = sprint (argument prefix `SPRINT-NNN`). Implements 4 cross-cuts that no per-issue Validate can see. Always type-file driven; complexity is fixed by the cross-cut surface, not the argument.

**Flow**: §1 Cross-Cut 1 → §2 Cross-Cut 2 → §3 Cross-Cut 3 → §4 Cross-Cut 4 → §5 Consolidated Verdict → return to SKILL.md Step 5

**§DE Layer reuse**: this type file does NOT redefine the Discipline Enforcement Layer — see SKILL.md §DE Layer §1-§8 (Default Adversarial Posture, Red Flags Vocabulary, Rationalizations, Anti-Patterns, Bounded Iteration Cap, Reality Check, FILLED/ESCALATED/SKIP, Nyquist Audit). Each cross-cut below applies §6 Reality Check + §7 terminal classification per its own findings (per-cross-cut, not consolidated — D9 from ISS-173).

**Scope distinction**: subject = the SET of closed issues; question = "do these closed issues *as a set* not drift, contradict, or leave gaps that none of them owned individually?" — see SKILL.md Operational Reminders ### Scope (issue/sprint).

**Patterns**: PAT-102 (§DE Layer single-source reuse), PAT-084 (Sprint 075 Conv 5 ad-hoc transcript = empirical anchor), critical-source-evaluation (generalize Sprint 075's specifics into domain-agnostic checks).

---

## §1 Cross-Cut 1: Theme Self-Prove Chain

**Question**: For THEMED sprints — does the issue chain *prove* the sprint theme? For MIXED — does the cross-issue work *cohere*?

### Inputs

- sprint-state.md `_mode`, `_title`, `_sprint`, [OBJECTIVES] completed list
- Each closed ISS file's Description, Solution-Design, Closure (### Resolution + ### Knowledge Captured)

### Process

1. **Branch on `_mode`**:
   - **THEMED** → ALL rule: every closed ISS must contribute to `_title`. Trace each issue's resolution back to the sprint theme. An issue that closed cleanly but did not advance the theme is a finding (theme drift or scope-creep into the sprint).
   - **MIXED** → COHERE-ACROSS rule: closed issues do not need to share a theme, but where their work touches shared surfaces (skills, files, registries), the resulting state must be coherent — no contradictory choices, no half-finished hand-offs between issues.
   - **DEDICATED** → not reachable (close-sprint STEP 0 trigger never offers DEDICATED — see /nexus-close-sprint STEP 0).
2. **Per-issue contribution trace** (THEMED): for each closed ISS, capture one sentence: "ISS-XXX advanced the theme by {evidence from Closure}." Issues without a credible sentence get flagged.
3. **Cross-issue coherence trace** (MIXED): for any two issues sharing surface (per close-sprint STEP 0 signals), capture: "ISS-XXX and ISS-YYY interact at {surface} → state is {coherent/contradictory/incomplete}."

### Reality Check (§DE Layer §6)

- "What's the actual evidence this issue advanced the theme?" — name the Closure section content, not the title.
- "What's the simplest way this contribution could be wrong?" — issue closed for reasons orthogonal to the sprint theme.
- "If I were wrong about coherence, what would I see?" — divergent vocabulary across issues, conflicting protocol additions, or one issue's deliverable invalidated by another's.

### Terminal Classification (§DE Layer §7)

- **FILLED** — every closed ISS has a credible theme-contribution sentence (THEMED) or coherence trace (MIXED). Carry forward.
- **ESCALATED** — one or more issues lack credible contribution/coherence after 3 evidence-gathering rounds. Log to ISS Findings with names of the issues + reason.
- **justified SKIP** — single-issue THEMED (close-sprint STEP 0 should have auto-skipped; if reached here, document why); or MIXED with no shared surfaces detected (then STEP 0 should not have fired the trigger; investigate).

---

## §2 Cross-Cut 2: Cross-Skill / Cross-File Surface Drift

**Question**: For files or skills modified by ≥2 issues this sprint, has the resulting state drifted in vocabulary, posture, or contract?

### Inputs

- sprint-state.md [FILES_MODIFIED] across all sprint issues (per-conversation entries)
- issues-registry.yaml `scope_files` per closed sprint issue
- The actual modified files (read sections touched by ≥2 issues)

### Process

1. **Identify shared surfaces**: build a map `{file_or_skill → [ISS-XXX list]}`. Filter to entries with ≥2 issues. Surfaces with only one issue do not qualify (per-issue Validate already covered them).
2. **Vocabulary check**: for each shared surface, scan for terminology drift between modifications by different issues. Examples — one issue introduces "PASS/FAIL" while another adds "PASSED/FAILED"; one issue uses "CONCERNS" and another "WARNING" for the same concept; one issue uses `applied → success` lifecycle and another uses `pending → done`.
3. **Posture drift**: did one issue soften a gate that another tightened? Did one add an adversarial requirement that a later issue silently downgraded?
4. **Contract drift**: did one issue add a producer (e.g., a registry key) and a later issue add a consumer that doesn't quite match (different field name, different shape)?

### Reality Check (§DE Layer §6)

- "What's the actual evidence vocabulary drifted?" — quote both terms with file/line.
- "If posture drift were real, what would I see?" — gate annotations relaxed, "MUST" downgraded to "SHOULD".
- "If contract drift were real, what would I see?" — producer's output not matching consumer's expected shape.

### Terminal Classification (§DE Layer §7)

- **FILLED** — every shared surface scanned; no drift, or drift documented and justified by issue resolution.
- **ESCALATED** — drift detected and unresolvable in current scope (must spawn issue or block close).
- **justified SKIP** — no shared surfaces (then trigger signals were wrong; investigate).

---

## §3 Cross-Cut 3: Version Stack Consistency

**Question**: Does the version stack across sprint-modified files honor CLAUDE.md Version Protocol — and was no file silently mis-bumped or skipped?

### Inputs

- changelog-registry.yaml `current_versions:` block + recent edit_history entries for sprint-modified files
- sprint-state.md [FILES_MODIFIED] (every file modified this sprint)
- CLAUDE.md [Section: File-Operations-Protocol] Version Protocol (Major/Minor/Patch rules + always-Major scope list)

### Process

1. **Coverage check**: every file in [FILES_MODIFIED] that is in version-protocol scope (system files under `.nexus/active/`, `.claude/skills/nexus-*/`, `.claude/agents/`) must have a corresponding bump entry in changelog-registry. Files missing from changelog = potential silent edits.
2. **Bump-magnitude check**: for each entry, compare the change to CLAUDE.md's Major/Minor/Patch rules. Always-Major rule: structural changes (sections added/removed) in SKILL.md, complex.md, types/*.md, references/*.md, or `.claude/agents/*.md` body. A structural change with only a Minor bump is a finding.
3. **Eager-update timing**: did any registry edit happen *before* its corresponding file edit was verified (reverse-order writes that PAT-098-style grep would catch)? Look for changelog entries ahead of their referenced file's edit_history.
4. **Duplicate-key / drift check**: spot-check changelog-registry for duplicate `{file}.field:` keys (mirror of CLAUDE.md "Registry insert rule").

### Reality Check (§DE Layer §6)

- "What's the actual evidence the bump magnitude was correct?" — name the rule (Major/Minor/Patch) AND the structural change category from CLAUDE.md's table.
- "What would prove a missing bump?" — a file in [FILES_MODIFIED] with no corresponding changelog edit_history line for this sprint.
- "What would prove duplicate-key corruption?" — two YAML keys with the same path under same parent.

### Terminal Classification (§DE Layer §7)

- **FILLED** — every sprint-modified system file has a properly-magnitude'd bump; no duplicate keys; no out-of-order writes.
- **ESCALATED** — missing bump or wrong magnitude detected. Block close until reconciled or explicitly overridden.
- **justified SKIP** — sprint modified zero version-protocol-scope files (rare; usually only for documentation-only sprints).

---

## §4 Cross-Cut 4: Constitution Holism

**Question**: Did the sprint-set *collectively* honor each project constitution principle? Per-principle evidence required (D10 from ISS-173 — NOT yes/no).

### Inputs

- project-state.md `[PROJECT_CONSTITUTION]` (skip cross-cut if absent — log as N/A, not SKIP)
- All closed ISS files (Description, Solution-Design, Implementation-Log, Closure)
- sprint-state.md [PATTERNS_IN_USE] across sprint issues
- sprint-state.md [DECISIONS] (look for [OVERRIDE] entries)

### Process

For each constitution principle, ask the principle's specific evidence question. Do not accept a yes/no answer — require a citation.

**Worked examples** (adapt to actual constitution principles):

- **Elegant Minimum** ("prefer simple solutions, resist over-engineering"):
  - Evidence prompt: "Did any sprint issue introduce a pattern, abstraction, helper, or config flag where a one-shot edit would have done? Cite the ISS and the introduced complexity."
  - Decision: did the ISS Solution-Design defend the abstraction's reusability, or did it appear because "it might be useful later"?

- **Protocol Discipline** ("follow methodology steps, don't skip for convenience"):
  - Evidence prompt: "Were any methodology steps skipped, abbreviated, or bypassed without an explicit override entry in [DECISIONS]? List the issue, the step, and the rationale."
  - Decision: silent skips count against the principle; documented overrides do not.

- **Continuity** ("lost work = system failure"):
  - Evidence prompt: "Were sprint-state writes verified after every checkpoint? Were [WRITE-VERIFIED] / [TPU-VERIFIED] gates emitted at the required points? Cite missing gates."

For each principle: **per-principle outcome** = honored / partially / violated, with the cited evidence.

### Reality Check (§DE Layer §6)

- "What's the actual evidence the principle was honored?" — refuse "all issues seemed fine"; require a citation per principle.
- "What's the simplest way I could be wrong?" — anchoring on issue Closure summaries (which are author-written) instead of reading Solution-Design + Implementation-Log directly.
- "If a principle were silently violated, what would I see?" — patterns introduced as `applied` and never resolved; gates skipped without [OVERRIDE]; cross-cut findings already escalated upstream.

### Terminal Classification (§DE Layer §7)

- **FILLED** — every constitution principle has cited evidence and a per-principle outcome.
- **ESCALATED** — one or more principles violated with no documented override; block close until override logged or finding spawned.
- **justified SKIP** — `[PROJECT_CONSTITUTION]` absent (then this cross-cut is N/A, not SKIP — record that explicitly).

---

## §5 Consolidated Verdict

Aggregate the four cross-cut outcomes into one verdict.

| Verdict | Condition |
|---|---|
| **PASS** | All 4 cross-cuts FILLED (or §4 N/A with constitution absent) |
| **CONCERNS** | ≥1 cross-cut justified SKIP with cited rationale, OR ≥1 cross-cut surfaces only LOW-severity findings (improvement opportunities, not contradictions) |
| **FAIL** | ≥1 cross-cut ESCALATED, OR ≥1 cross-cut surfaces HIGH-severity finding (blocking contradiction, missing version bump on structural change, constitution violation without override) |

**Output format**:

```
🚦 Sprint-Level Validate Verdict
═══════════════════════════════════════
Sprint: #{NNN} ({mode}) — "{title}"

Cross-cut 1 (Theme Self-Prove): {FILLED/ESCALATED/SKIP} — {1-line summary}
Cross-cut 2 (Surface Drift):    {FILLED/ESCALATED/SKIP} — {1-line summary}
Cross-cut 3 (Version Stack):    {FILLED/ESCALATED/SKIP} — {1-line summary}
Cross-cut 4 (Constitution):     {FILLED/ESCALATED/SKIP/N/A} — {1-line summary}

Findings: {count by severity HIGH/MEDIUM/LOW}
Verdict: {PASS / CONCERNS / FAIL}
═══════════════════════════════════════
```

After verdict: return to SKILL.md Step 5 (Pattern Finalization) — sprint-scope path skips per-issue pattern records (those were finalized at each issue's per-issue Validate). Step 6 Quality Gate consumes this verdict directly. /nexus-close-sprint STEP 0 receives PASS / CONCERNS / FAIL and routes accordingly (PASS → resume closure; FAIL/CONCERNS → 3-option widget).

---

## §6 Layer Audit Checklist

Verify when reviewing this type file (mirrors SKILL.md §DE Layer Layer Audit Checklist for the type-file scope):

- [ ] Default Adversarial Posture inherited from SKILL.md §1 (not redeclared, not softened)
- [ ] Red Flags / Rationalizations / Anti-Patterns inherited from SKILL.md §2-§4 (not duplicated here)
- [ ] Bounded Iteration Cap inherited from SKILL.md §5 (3-attempt rule applies per-cross-cut Reality Check)
- [ ] §6 Reality Check applied per cross-cut (4×, not once consolidated — D9)
- [ ] §7 FILLED / ESCALATED / SKIP terminal classification per cross-cut
- [ ] §4 Constitution Holism enforces per-principle evidence (not yes/no — D10)
- [ ] §1 Theme Self-Prove branches on `_mode` (THEMED ALL / MIXED COHERE / DEDICATED unreachable)
- [ ] No softened gate phrasing in cross-cut steps
- [ ] §DE Layer §1-§8 cross-referenced, NOT copied (PAT-102 single-source-of-truth)
