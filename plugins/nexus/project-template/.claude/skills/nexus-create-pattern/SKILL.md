---
name: nexus-create-pattern
description: Create a new pattern with 4Q validation gate
disable-model-invocation: false
---
*Version: 2.2.0 | Date: 2026-08-26 | Sprint: 111*

# Create Pattern

**Flow**: Load context → 4Q validation → Similarity check → [T1: approve] → Write PAT file → Update registry → Verify → Report

Create a new pattern with 4Q validation gate. Includes similarity gating and inline enhancement of existing patterns when overlap detected.

---

### STEP 0: Load Context & Detect Mode

Determine mode from context — this is behavioral, not parametric.

**Automatic mode**: You're currently executing /nexus-close-sprint (STEPs 3-4). Pattern candidates exist in sprint-state `[CANDIDATES_PATTERNS]` and ISS files are in memory (loaded at close-sprint STEP 0). Proceed to STEP 1A.

**Manual mode**: User typed "create pattern" as a standalone command. No active closure workflow. Proceed to STEP 1B.

---

### STEP 1A: Automatic — Extract & Generalize

This is creative intellectual work, not copy-paste. Transform specific experience into strategic wisdom.

**Scan sources in memory**: ISS files (Description, Closure, Lessons Learned, Pattern Outcomes — loaded by close-sprint), sprint-state `[CANDIDATES_PATTERNS]` and `[DISCOVERIES]`, conversation history.

**Extract raw material**: What specific problem did we solve? What solution did we use? What situation triggered this? Why did it work?

**Generalize** — this is the critical step. For each element, move from specific to strategic:

- **Problem**: From the exact problem in this issue to the CLASS of problems it represents. Example: "ISS-091 had duplicate logic" → "Systems accumulate redundancy over time when definitions are maintained in multiple locations."
- **Solution**: From the exact fix to the APPROACH for this problem class. Example: "Merged into specification" → "Consolidate to single authoritative source, make consumers reference it."
- **Rationale**: From why it worked HERE to the PRINCIPLE that works ANYWHERE. Example: "Updates in one place" → "Single source of truth eliminates drift between copies."

**Quality check**: Is it general enough for different issue types? Would NEXUS recognize when to propose this? Have I stripped specific context but kept wisdom?

**Assemble candidate** with: generalized problem, solution approach, context (use_when/not_when), inferred type (principle/methodology/practice/solution), phase_affinity (infer from which work phases the pattern is most relevant to — analysis, implementation, evaluation, research, or all), rationale, source reference (ISS-XXX or Sprint NNN), anti-patterns.

Display the candidate summary and proceed to STEP 2.

---

### STEP 1B: Manual — Interactive Gathering

Inform the user: patterns are generalizable wisdom for NEXUS to propose in future situations — not documentation of what happened, but guidance for what to do.

Gather collaboratively through conversation. You need six elements:

1. **Problem** — What general problem class does this solve? (Not issue-specific. Good: "File modifications fail silently when target doesn't exist." Bad: "ISS-042 had a bug.")
2. **Solution** — Actionable guidance NEXUS can follow. (Good: "Always verify file exists before modification." Bad: "Be careful with files.")
3. **Context** — When to use and when NOT to use.
4. **Type** — principle (WHY), methodology (HOW), practice (WHAT works), or solution (specific answer to problem class).
5. **Rationale** — Why does this approach work? The underlying principle.
6. **Phase affinity** — Which work phases benefit most? (analysis, implementation, evaluation, all, etc.)

Gather these through natural dialogue — propose content based on context, challenge vague input, help the user sharpen their thinking. Don't collect one field at a time mechanically.

Assemble candidate and proceed to STEP 2.

---

### STEP 2: 4Q Strategic Validation

All four questions must pass. No spec loading yet — validate before investing tokens.

| Question | Pass If | Fail If |
|---|---|---|
| Q1 Strategic | Guides FUTURE decisions, provides actionable framework | Only describes what happened once |
| Q2 Non-obvious | Counter-intuitive or requires experience to discover | Self-evident, common sense, standard practice |
| Q3 Generalizable | Applicable across multiple contexts, adaptable | Too narrow, specific to single case |
| Q4 Wisdom | Explains WHY and WHEN, reveals non-obvious relationships | Just procedural steps without insight |

Display results for all four questions with brief reasoning.

**If all pass**: Proceed to STEP 3.

**If any fail**: Inform the user which questions failed and why. Show the specific weaknesses. Offer via `AskUserQuestion tool`: "Revise candidate" / "Note as learning" / "Override and create anyway."

- **Revise**: Present the current candidate with the failing questions highlighted. Let the user strengthen the weak areas — refine the problem statement, sharpen the rationale, broaden the context, etc. Re-run 4Q on the revised candidate.
- **Note as learning**: Valuable observation but not pattern material. Return NOTED_AS_LEARNING.
- **Override**: Flag `validation_overridden` and proceed to STEP 3.

---

### STEP 3: Similarity Check

`Read .nexus/active/registries/patterns-registry.yaml` (memory-first). Compare the candidate against all existing patterns using semantic judgment.

**What to compare**: Read each pattern's `description` and `use_when` fields — these capture what a pattern IS and WHEN it applies. Also consider `domain` and `type` for additional signal. The question is: does an existing pattern already address the same problem class with a similar approach?

**How to judge similarity**: Ask yourself for each existing pattern: Do they solve the SAME problem class? Are the solutions conceptually similar (not just surface-level word overlap)? Do they apply in overlapping contexts? Could one absorb the other's wisdom without losing its identity?

**Reach a conclusion** for the best match:

- **Below ~40% similar (Novel)**: No meaningful overlap. Proceed automatically to STEP 4 — no user interaction needed.
- **40-70% similar (Overlap found)**: There's a related pattern. Present the finding to the user: show the existing pattern's ID, name, description, and where the overlap lies. Offer via `AskUserQuestion tool`: "Create as separate pattern" / "Enhance existing instead" / "View existing pattern" / "Cancel."
  - If create: proceed to STEP 4.
  - If enhance: proceed to STEP 3M (inline enhancement).
  - If view: display existing pattern details, then re-present the choice.
  - If cancel: return CANCELLED.
- **Above ~70% similar (Likely duplicate)**: Strong overlap. Present the existing pattern with explanation. Offer via `AskUserQuestion tool`: "Cancel (recommended)" / "Create anyway" / "Enhance existing instead."
  - If cancel: return DUPLICATE.
  - If create: flag `duplicate_override` and proceed to STEP 4.
  - If enhance: proceed to STEP 3M (inline enhancement).

---

### STEP 3M: Enhance Existing Pattern (Merge Path)

The user chose to strengthen an existing pattern with the candidate's insights rather than create a new one. This is a lightweight inline enhancement — not a full merge of two established patterns (that's `/nexus-merge-patterns`' job).

**A. Load existing pattern.** `Read .nexus/patterns/PAT-XXX.md` (memory-first). Study it fully — understand its problem class, solution, rationale, context, anti-patterns, examples.

**B. Identify unique contributions.** Compare the candidate's wisdom against the existing pattern. What does the candidate add that the existing pattern lacks? Typical contributions:

- Additional `use_when` or `not_when` scenarios in the Context section
- Supplementary rationale insights (a different angle on WHY it works)
- New anti-patterns discovered from this experience
- Additional examples or before/after comparisons
- Solution variations for different contexts
- New relationship discoveries (synergies, conflicts)

If the candidate has nothing unique to contribute (pure duplicate with no new insights), inform the user and return DUPLICATE — no enhancement needed.

**C. Present proposed enhancements.**

```
📐 ENHANCE EXISTING PATTERN
═══════════════════════════════════════════

Target: {pattern_id} — {name} (v{version})

Proposed additions from candidate:
{for each enhancement}:
• {Section}: {what will be added — brief}

No changes to: {list unchanged sections}
═══════════════════════════════════════════
```

Offer via `AskUserQuestion tool`: "Apply enhancements" / "Edit first" / "Cancel."

If edit: discuss adjustments, re-present. If cancel: return CANCELLED.

**D. Patch existing pattern.** After user approval:

Patch the PAT file sections that have new content. Use `Edit tool` and targeted find/replace for each section being enhanced. For appending to existing sections (e.g., adding a use_when scenario), find the section's closing content and insert before it.

Add to the Evolution section:
```
- v{X.Y+1} ({date}): Enhanced with insights from {source — ISS-XXX or manual candidate} (Sprint {N})
```

Increment the minor version in the file header.

**Registry sync**: After enhancing the PAT file, sync the registry:
- If new `use_when` scenarios were added to the Context section, patch the registry `PAT-XXX.use_when` array to include the new matching triggers.
- If the problem scope broadened, revise the registry `description` to reflect the expanded scope.
The registry is what match-pattern scans — stale registry = missed matches.

Verify the file after patching — `Read tool` to confirm changes applied correctly. If any patch fails, inform the user and revert from the in-memory pre-image or `git checkout HEAD -- {path}` (text files are not backed up by the binary-only hook — git checkpoints are the recovery).

**E. Report.**

```
═══════════════════════════════════════════
✅ PATTERN ENHANCED
═══════════════════════════════════════════

Pattern: {pattern_id} — {name}
Version: v{old} → v{new}

Enhancements applied:
{for each}: • {section}: {brief description}

Source: {candidate origin — ISS-XXX or manual}
═══════════════════════════════════════════
```

Return ENHANCED.

---

### STEP 4: Load Spec & Generate Content

Gates passed — now load the authoritative source for creating pattern files and registry entries.

`Read .nexus/templates/pattern-specification.md` (memory-first). Both sections needed: `[Section: Pattern-File-Structure]` for the PAT file template and writing guidance, and `[Section: Registry-Entry-Structure]` for the 16-field registry schema, defaults, and validation checklist.

**Generate ID**: Read `meta.last_id` from the registry. New ID = `PAT-{last_id + 1}`, zero-padded to 3 digits.

**Generate name**: Extract the key concept from the candidate's problem/solution, convert to kebab-case, max 50 characters.

**Populate PAT file**: Follow the template in pattern-specification.md `[Section: Pattern-File-Structure]`. Use the writing guidance for each section. Populate as many sections as possible from the candidate data:

- Metadata: type from candidate (or inferred), status = active, created = today
- Problem, Context, Solution, Rationale: from the generalized candidate
- Anti-Patterns: infer from solution — what's the opposite that fails?
- Relationships: requires = [], enhances/conflicts = any discovered during similarity check, alternatives = from similarity check
- Consequences: benefits, tradeoffs, risks
- Examples: before/after from source issue if available
- Resources: omit unless extended material exists
- Evolution: v1.0.0 with today's date and source

**Generate registry entry**: Follow the schema in pattern-specification.md `[Section: Registry-Entry-Structure]`. Use the writing guidance for `description` (action verb + core principle + benefit, 1-3 rich sentences) and `use_when` (2-5 natural language scenarios, not keywords). Apply defaults for new patterns (emerging, 0.50 effectiveness, zeroed counters).

---

### STEP 5: Preview & Approval

Display the complete pattern for user review:

```
═══════════════════════════════════════════
📐 NEW PATTERN PREVIEW
═══════════════════════════════════════════

ID: {pattern_id}
Name: {pattern_name}
Type: {type} | Domain: {domain}

PROBLEM CLASS:
{problem}

SOLUTION:
{solution summary}

CONTEXT:
Use when: {use_when scenarios}
Not when: {not_when scenarios}

RATIONALE:
{core principle}

───────────────────────────────────────────
REGISTRY ENTRY:
{full prefixed entry preview}
───────────────────────────────────────────

{if validation_overridden}: ⚠️ 4Q validation was overridden
{if duplicate_override}: ⚠️ Created despite similarity to {pattern}

═══════════════════════════════════════════
```

**[T1: all levels ask]** Offer via `AskUserQuestion tool`: "Create" / "Edit first" / "Cancel."

Wait for explicit approval. If edit requested, discuss changes and regenerate preview. If cancelled, return CANCELLED.

---

### STEP 6: Atomic Creation

Both writes must succeed together. If the second fails, roll back the first.

**A. Create PAT file:**

First verify the filename doesn't already exist. Then write:
```
Write tool(
  filepath=".nexus/patterns/{pattern_id}.md",
  content={pat_file_content}
)
```
Verify the file was created and emit the per-write marker (CLAUDE.md bulk-write strategy — new-file creation is verified per-write by the owning skill):
`⛔ [WRITE-VERIFIED] .nexus/patterns/{pattern_id}.md | anchor: "# {pattern_id}: {Pattern Name}" | status: present`
If write fails, return FAILED (nothing to roll back).

**B. Archived-ID validation — ⛔ PRE-WRITE GATE (SC-04):**

Before the registry patch, validate the candidate entry's `synergies` / `conflicts` / `alternatives` against the retired-pattern set in `.nexus/archived/patterns/`. This runs **here, at write time**, not at boot: by the time a boot-time sweep sees a dead reference it is already in a machine-read field, and the next reader has already followed it.

> **Why the gate exists.** ISS-227 (Sprint 106) purged every dead retired-pattern reference and closed after an adversarial sweep of 15 archived ids. **PAT-139, authored two sprints later, put retired PAT-123 straight back into a machine-read `synergies` field.** The purge was correct. Nothing stopped the next author from undoing it. That is ISS-240's whole thesis in one instance — a correction with no propagation path to the tools and authors downstream of it.

1. Resolve the archived-id set: `ls .nexus/archived/patterns/ | grep -oE 'PAT-[0-9]+' | sort -u`.
2. Extract every `PAT-NNN` named in the candidate entry's three relationship fields.
3. Verdict:

| Condition | Verdict | Action |
|---|---|---|
| No archived id referenced | `FILLED: 0 findings / {bound} bound (relationship-field references) / {candidates} candidates` | proceed to C |
| One or more archived ids referenced | **`ESCALATED`**, naming each id **and the field it sits in** | ⛔ **BLOCK the registry write.** Remove or replace the retired id, then re-run this gate |
| The archived-pattern directory does not resolve | **`ESCALATED: bound 0 (archived ids)`** | ⛔ Block. A gate that cannot see the retired set cannot certify the write — it must not pass by default |
| The entry declares none of the three fields | `SKIP (justified)` — nothing to validate | proceed to C |

The `SKIP` case is stated explicitly so an absent field cannot be silently reported as a passing check. A `FILLED: 0/0/0` here would be the vacuous pass this framework's own VC-2 contract exists to catch.

**Fires-on-broken proof** (📐 PAT-140, executed at ISS-240 Phase 4.3, Sprint 111): a synthetic entry whose `synergies` named archived `PAT-123` returned `ESCALATED: 1 findings / 2 bound / 2 candidates, against 17 archived ids. REGISTRY WRITE BLOCKED`. A clean candidate passed at `0 findings / 2 bound / 2 candidates`; an unreachable archive directory ESCALATED rather than certifying; and PAT-139's own live entry now reads `["PAT-125", "PAT-098"]`, so the historical instance is closed and this gate ships as a **regression guard**, not a live repair.

Declared as edge **E-11** in `.nexus/active/derivations.yaml` (`runs_at: nexus-create-pattern`).

**C. Update registry:**

Verify the pattern ID doesn't already exist in the registry. Then patch:
```
Edit tool(
  filepath=".nexus/active/registries/patterns-registry.yaml",
  patches=[
    {find: "meta.last_id: {N}", replace: "meta.last_id: {N+1}"},
    {find: "meta.active: {M}", replace: "meta.active: {M+1}"},
    {find: "# --- ADD NEW PATTERNS HERE ---",
     replace: "{full_prefixed_registry_entry}\n\n# --- ADD NEW PATTERNS HERE ---"}
  ]
)
```
Verify the entry appears in the registry and emit `⛔ [WRITE-VERIFIED] .nexus/active/registries/patterns-registry.yaml | anchor: "{pattern_id}.name:" | status: present`. If patch fails, roll back by deleting the PAT file, then return FAILED.

**D. Report:**

```
═══════════════════════════════════════════
✅ PATTERN CREATED
═══════════════════════════════════════════

ID: {pattern_id}
Name: {pattern_name}
File: patterns/{pattern_id}.md
Registry: Updated ✓

Initial: emerging, 0.50 effectiveness, 0 applications

Next: Apply when relevant, track at closure.
═══════════════════════════════════════════
```
Return status CREATED with pattern_id and file_path.
