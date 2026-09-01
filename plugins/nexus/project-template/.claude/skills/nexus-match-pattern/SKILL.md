---
name: nexus-match-pattern
description: Find and apply patterns matching current issue context
disable-model-invocation: true
---
*Version: 2.3.0 | Date: 2026-08-26 | Sprint: 111*

# Match Pattern

**Flow**: Load registry → Score candidates → Present matches → [T2: accept/adapt] → Load PAT files → Apply → Update sprint-state

Find and apply patterns matching current issue context. Called by the methodology skills (Analyze, Build, Research, Validate), by `/nexus-update-issue` (pattern request) and by `/nexus-list-patterns` (detail-view Apply).

---

### STEP 0: Load Phase-Eligible Registry Subset

Determine the **current phase** (from sprint-state `current_focus` or the calling methodology — analysis / implementation / evaluation / research). Then load only the phase-eligible, field-projected subset via the skill-local helper:

`bash .claude/skills/nexus-match-pattern/scripts/filter-patterns.sh <phase>` — run from project root; **memory-first** (if the subset for this phase is already in context, reuse it).

The script emits only patterns whose `phase_affinity` contains the current phase or `"all"` — a **hard load-time eligibility gate**, **fail-open** (patterns with missing or empty `phase_affinity` are always included; never silently dropped on a data gap) — with `file` and `last_used` projected out. This cuts ~30–55% of the load: `description` + `use_when` are ~67% of the registry and scale with row count, so loading fewer rows is the only lever that cuts the bulk.

Every field scoring actually uses is preserved in the subset (`description`, `use_when`, `domain`, `type`, `phase_affinity`, `by_issue_type`, `effectiveness`, `maturity`, `synergies`, `conflicts`, and the success/failure/neutral counts). The dropped `file` path is re-derived in STEP 4 as `patterns/PAT-XXX.md`.

**Fallbacks**: if no clear phase is available, call the script with an empty phase (`filter-patterns.sh ""`) for all-mode (field-trim only, no phase filter). If the script fails, fall back to `Read .nexus/active/registries/patterns-registry.yaml`. Cannot proceed without the registry.

---

### STEP 1: Understand Context

The entire conversation is your context — everything discussed, analyzed, designed, and decided so far. Use all of it to understand what problem or task you're matching patterns for.

Within that conversation, focus especially on these structured anchors:

- **Sprint-state `[OBJECTIVES]`**: Current issue — its type, complexity, phase scores. What kind of work is this?
- **Sprint-state `current_focus`**: Which phase — analysis, implementation, evaluation? Phase shapes which patterns are relevant.
- **Sprint-state `continue_with`**: What specifically we're working on right now.
- **Sprint-state `[PATTERNS_IN_USE]`**: Patterns already applied this sprint — for synergy detection and avoiding redundant suggestions.
- **ISS file** (if loaded): Problem statement, success criteria, solution design, dependencies — the structured definition of what we're solving.

From all of this, form a clear understanding of: what problem or task we're addressing, what kind of work it is (issue type and current phase — needed for `phase_affinity` and `by_issue_type` scoring), what constraints exist, and what patterns are already in play.

If the context is insufficient to judge pattern relevance — ask the user: "What problem or task should I match patterns for?"

---

### STEP 2: Score & Recommend (Internal — Do Not Display)

For each pattern in the registry, assess fit across these dimensions. Use semantic judgment — read the pattern's description and use_when, and ask yourself whether it genuinely applies to the current situation.

**What to evaluate:**

- **Problem relevance** (most important): Does this pattern address the kind of problem we're facing? Read `description` and `use_when` — do the scenarios match our situation? A pattern about file validation is irrelevant when we're doing sprint planning.
- **Phase affinity**: Already settled at STEP 0 — `phase_affinity` is a **hard load-time eligibility gate**, so every pattern still in context either includes the current phase or `"all"`, or was kept fail-open (missing/empty affinity). Do not re-penalize phase here; treat eligibility as given. Patterns with `["all"]` remain broadly applicable.
- **Issue type evidence**: Does `by_issue_type` show successful applications on the current issue type? A pattern applied 5 times on Improvement issues is evidence-backed for another Improvement. Empty `by_issue_type` is neutral (no evidence either way), not negative.
- **Track record**: What does `effectiveness` tell us? How many applications? A pattern with 0.90 effectiveness over 12 applications is more trustworthy than one with 0.70 over 2.
- **Domain fit**: Does `domain` align with our current work area? A "system-design" pattern may still apply to a "validation" task if the problem class fits, but exact domain match is a positive signal.
- **Type alignment**: Does the pattern type match what we need? Principles are broadly applicable. Methodologies fit process-heavy work. Practices fit execution. Solutions fit specific problem classes.

**Adjustments:**
- If a pattern appears in `synergies` of an already-applied pattern, that's a positive signal — they work well together.
- If a pattern appears in `conflicts` of an already-applied pattern, flag it but don't exclude — let the user decide.

**Select top matches**: Filter to patterns with genuine relevance — ≥ ~50% fit, the CLAUDE.md Pattern Governance floor (below 50% is not mentioned). Take the top 4. Label each `fit_assessment` with the governance band: >80% Applying · 70–80% Strongly recommend · 50–70% Consider. If fewer match, show fewer. If none match meaningfully, that's a valid outcome.

**Carry the phase-gate denominator forward to STEP 3.** STEP 0's filter is a *hard load-time gate*: patterns it drops are never scored, and "not scored" is invisible in a result that only lists matches. Record from the STEP 0 run:

- **total** — patterns in the registry (`grep -c '^# --- PAT-' patterns-registry.yaml`)
- **scored** — patterns the filter emitted for this phase
- **excluded** — `total − scored`, dropped by the phase gate before scoring

**Formulate recommendation**: From the top matches, determine what to recommend. Options:
- Single pattern: one clearly fits best, or multiple would conflict.
- Multiple patterns (2-4): they complement each other — different types addressing different aspects, or explicit synergy.
- None: no patterns are relevant enough. Proceed without.

Build a brief rationale explaining why the recommended pattern(s) fit and why alternatives are less suitable.

---

### STEP 3: Present & Wait

Display the matches and recommendation:

```
📐 Pattern Recommendations ({N} matches)
{scored} of {total} scored, {excluded} excluded by phase gate ({phase})
═══════════════════════════════════════════

1. PAT-XXX ({fit_assessment})
   "{description}"
   Effectiveness: {X}% | Maturity: {level} | Phase: {affinity_match}
   {Issue type: {N}x on {type} | No data for {type}}
   {🤝 Synergy with PAT-YYY}
   {⚠️ Conflict with PAT-ZZZ}

2. PAT-YYY ({fit_assessment})
   "{description}"
   Effectiveness: {X}% | Maturity: {level} | Phase: {affinity_match}

[... up to 4 ...]

───────────────────────────────────────────

**Recommendation:** {PAT-XXX or PAT-XXX + PAT-YYY or None}

**Rationale:** {Why these fit, why alternatives less suitable,
how they complement if multiple}

═══════════════════════════════════════════
```

**[T2: Balanced+Full ask | Streamlined: auto-accept recommendation after displaying, notify]** Offer via `AskUserQuestion tool` with the relevant choices (pattern numbers, combinations, "none").

**All levels**: Always display the recommendation — user must SEE what patterns are proposed. Streamlined skips the wait, not the display.

If no patterns matched:

```
📐 No patterns matched the current context.
{scored} of {total} scored, {excluded} excluded by phase gate ({phase}).
Proceed without patterns.
```

⚠️ **The denominator is load-bearing on this branch, not decoration.** "No matches" from 44 scored and "no matches" from 0 scored are the same sentence and different facts. A pattern dropped by a mis-tagged `phase_affinity` is indistinguishable from one that scored below the governance floor unless the excluded count is stated — and the excluded set is exactly where a mis-tag hides, because a pattern that is never scored can never be reported.

If `excluded` is large relative to `total`, or a pattern you expected is absent, list the excluded ids before concluding: the gate is fail-open by design, so an exclusion is always an explicit `phase_affinity` value and always inspectable. (📐 PAT-131 — a surface-when-relevant field only works if it is keyed to the *moment* you would apply the item, not the *subject* it is about; a subject-tagged affinity silently mis-files the pattern so it never surfaces at the moment of need.)

Return to caller.

---

### STEP 4: Load & Adapt

`Read .nexus/patterns/PAT-XXX.md` for each accepted pattern (memory-first) — the path is derived directly from the pattern id (the `file` field is not present in STEP 0's projected subset). If multiple accepted, load all.

**Study each pattern**: Read the full PAT file. Understand the problem class it addresses, the solution guidance, the rationale (the underlying principle), the anti-patterns to avoid, and the context boundaries (use_when/not_when). Check the Resources section — if extended materials exist that would add value for our situation, offer to load them.

**Adapt to current context**: Map the pattern's general guidance to our specific situation. What applies directly? What needs customization? What doesn't apply? The goal is 70-90% reuse with 10-30% customization. If more than ~40% needs customization, the pattern may be a poor fit — mention this.

**For multiple patterns**: Identify how they relate — complementary (different aspects), sequential (one feeds the other), or overlapping (both address the same thing). Resolve overlaps by using the higher-effectiveness pattern's approach for the shared concern. Create a unified sequence of guidance.

---

### STEP 5: Present Adapted Guidance

```
📐 Pattern Guidance Adapted
═══════════════════════════════════════════

{If single}: Based on **PAT-XXX: {name}** ({effectiveness}% effective):
{If multi}: Based on **PAT-XXX + PAT-YYY** (synthesized):

**Core Principle:**
{The wisdom/rationale — WHY this works}

**Adapted Guidance for Our Context:**
• {Concrete guidance mapped to our specific situation}
• {Another adapted point}

**Avoid:**
• {Anti-pattern relevant to our context}

**Success Indicators:**
• {How we know we're applying the pattern correctly}

{If multi}: **Synthesis:** {How the patterns work together}

═══════════════════════════════════════════
```

`UPDATE: .nexus/active/states/sprint-state.md#[PATTERNS_IN_USE]` with accepted patterns.

**Tool guidance** — use Edit tool to append pattern entry into the section. Two cases:

*If an entry for the current issue already exists in `[PATTERNS_IN_USE]`*:
Use Edit tool with old_string containing the existing ISS-XXX block and new_string adding the new PAT line.

*If the section is empty or no entry for this issue exists yet*:
Use Edit tool with old_string `[PATTERNS_IN_USE]` and new_string `[PATTERNS_IN_USE]\nISS-XXX:\n  PAT-YYY: applied`.
Check memory for the current sprint-state `[PATTERNS_IN_USE]` content to determine which case applies before patching.

Return to caller with pattern guidance integrated.
