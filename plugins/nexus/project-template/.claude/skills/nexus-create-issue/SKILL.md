---
name: nexus-create-issue
description: Create a new NEXUS issue with guided wizard, assisted mode, or backend API
disable-model-invocation: false
---
*Version: 2.6.0 | Date: 2026-08-20 | Sprint: 110*

# Create Issue

**Flow**: Load context → Detect mode → Core identity → Context & relationships → Assessment → [T2: review+confirm] → Create ISS file → Update registry → Verify → Report

Create a new NEXUS issue with guided wizard, assisted mode (from description), quick capture, or backend API. Multi-mode wizard with dependency detection and complexity-based scaffolding.

---

### STEP 0: Load Context & Detect Mode

- `Read .nexus/active/registries/issues-registry.yaml` 
Extract `last_id` → `next_number = last_id + 1` (zero-padded to 3 digits). Collect existing titles and scope_files for duplicate and dependency detection.

- `Read .nexus/templates/issue-specification.md#[Section: ISS-File-Structure]`
- `Read .nexus/templates/issue-specification.md#[Section: Registry-Schema]`
These define the ISS template and registry field schema. If either fails to load, warn user and offer fallback or abort.

Display: `📝 Next issue: ISS-{next_number}`

**Mode detection:**

| Signal | Mode | Action |
|---|---|---|
| Called by operation with complete issue data | Backend | Validate fields → skip to STEP 5 |
| Input starts with "quick issue:" | Quick | Run STEPs 1-3 silently → present at STEP 4 |
| Input contains a description (problem statement, context, or detailed request) | Assisted | Run STEPs 1-3 silently → present at STEP 4 |
| Bare command with no description ("create issue", "new issue") | Full | Load sprint-queue.md, run wizard interactively from STEP 1 |

**Mode execution principle — CRITICAL:**

Assisted and Quick modes are **UX optimizations, not analysis shortcuts**. All steps (1-3) run with full logic — the difference is interaction style, not depth:
- **Full mode**: Each step prompts the user interactively
- **Assisted/Quick mode**: Each step runs silently using available context, results presented together at STEP 4
- **Backend mode**: Caller provides all data, validate and skip to STEP 5

The goal: when the user provides enough context, gain interactive steps — never lose analytical accuracy.

**Backend mode**: Honor all caller values. Validate against Registry-Schema enums and ranges. If valid, proceed to STEP 5. For batch calls: always read registry from disk to get latest `last_id` — (memory copy is stale from previous calls).

**Quick mode**: Triggered by explicit "quick issue:" prefix. Parse all fields from input — type from keywords ("fix"→Bug, "add"→Feature), title from main phrase, description (full text), priority/complexity/scope from context. Then run STEPs 1-3 silently (see mode execution principle above).

**Assisted mode** (most common): The user provided a description alongside the create command. Parse all fields from input using deeper analysis than Quick mode. For each field:
- Extract from input → mark `[inferred]`
- Apply reasonable default from type/context → mark `[default]`
- Cannot determine → mark `[needs input]`

For type choices with lifecycle implications, add a brief note:
- Question vs Research: "Question = internal investigation (project files, structure, implementations) — can close after findings. Research = external research (web search, external docs, tool comparisons) — follows structured A→R→E."

When input suggests investigation/analysis:
- References project internals (folder structure, file organization, our patterns, our workflows) → infer Question
- References external sources (frameworks, tools, industry practices, comparisons with outside solutions) → infer Research
- References BOTH internal and external → default to Research (broader scope), mark as `[inferred — could also be Question]` so user sees the ambiguity at STEP 4

Then run STEPs 1-3 silently (see mode execution principle above). All fields are presented at STEP 4 review. User can accept all, or select "Modify fields" to enter the relevant wizard sub-step for specific field adjustment.

Type shortcuts (all modes): b=Bug, f=Feature, i=Improvement, r=Refactor, d=Documentation, q=Question, re=Research, cr=Creative.

---

### STEP 1: Core Identity

*Full mode: run all sub-steps interactively. Assisted/Quick mode: run all sub-steps silently, results presented at STEP 4. Entered interactively via "Modify fields" from STEP 4 for specific field adjustment.*

**A. Type** — Present the eight types with lifecycle descriptions. Validate against Registry-Schema.

```
📋 Issue Type
1. Bug            — Something broken, fix needed
2. Feature        — New functionality
3. Improvement    — Enhancement to existing
4. Refactor       — Internal restructuring, no behavior change
5. Documentation  — Doc-only changes
6. Question       — Internal investigation (project files, structure, implementations). Can close after findings without implementation.
7. Research       — External research (web search, external docs, tool comparisons). Structured A→R→E methodology with milestones.
8. Creative       — Content production (documents, presentations, creative artifacts). Section-by-section with mid-process steering.

Choice (1-8 or b/f/i/r/d/q/re/cr):
```

**B. Description** — Ask for full problem statement (minimum 10 characters). If too brief: "What exactly needs to happen? Why is this needed?"

**C. Title** — Auto-generate from description using Verb + Object + Context pattern (5-100 chars). Run duplicate check against existing titles — if similarity > 80%:
- Full mode: warn: "⚠️ Similar to '{existing}'. Continue? [Y/n]". Present: "Suggested: '{title}'. Accept or enter custom:"
- Assisted/Quick mode: mark title as `[inferred — ⚠️ similar to '{existing}']` and flag prominently at STEP 4 review. Do not silently proceed — the user must see the duplicate warning before confirming.

---

### STEP 2: Context & Relationships

*Full mode: run all sub-steps interactively. Assisted/Quick mode: run all sub-steps silently, results presented at STEP 4. Entered interactively via "Modify fields" from STEP 4 for specific field adjustment.*

**A. Scope Files** — Auto-detect file paths and component names from description. Present detected list — accept, modify, or TBD. Stored in registry only (`ISS-XXX.scope_files`); analysis populates ### Files Affected later.

**B. Dependencies** — Analyze existing issues in the registry for relationships. This analysis is MANDATORY in all modes (including Assisted/Quick — run silently, present findings at STEP 4).

Scan method — all three checks run independently (not as a fallback chain). Even if scope_files is TBD, keyword and logical sequence checks still apply:
1. **Component overlap**: Compare new issue's scope_files against all existing issues' scope_files. Overlapping files/paths = potential relationship.
2. **Keyword match**: Compare description terms against existing issue titles and descriptions. Strong semantic overlap = potential relationship.
3. **Logical sequence**: Does the new issue's outcome affect or depend on another issue's work? (e.g., restructuring affects release, investigation findings may block implementation)

For each detected relationship, classify using these heuristics:
- **blocks/blocked_by**: Output of one issue feeds input of the other, OR there is a temporal constraint (one must finish first for the other to proceed safely)
- **Related** (noted in ISS Dependencies section, not registry): Same files or domain but different concerns (e.g., content changes vs structural changes), OR shared context without hard dependency

Present detected blocks/blocked_by with accept/modify/none options. In Assisted/Quick mode, present findings with reasoning at STEP 4 marked as `[inferred]`.

**C. Target Sprint** — Consider blocker constraints, priority alignment, thematic fit. If blocked_by exists, earliest possible = max(blocker target_sprints). Present suggestion with reasoning. If no good fit → suggest TBD.

---

### STEP 3: Assessment

*Full mode: run all sub-steps interactively. Assisted/Quick mode: run all sub-steps silently, results presented at STEP 4. Entered interactively via "Modify fields" from STEP 4 for specific field adjustment.*

**A. Complexity (1-5)** — Score using five dimensions:

| Dimension | Low (toward 1) | High (toward 5) |
|---|---|---|
| Scope | Single file, isolated | 4+ files, system-wide |
| Dependencies | None | Multiple blocking/cascading |
| Novelty | Known patterns, routine | Novel domain, no precedent |
| Risk | Easy rollback, low impact | Hard to reverse, high stakes |
| Integration | Self-contained | Cross-component coordination |

Present estimate with reasoning. Accept or override.

**B. Priority** — Auto-suggest: Critical if Bug AND complexity ≥ 4 or blocks ≥ 3. High if complexity ≥ 3, or blocks ≥ 1, or Bug. Low if Question or no dependencies. Medium otherwise. Present with reasoning.

**C. Impact** — Estimate (Critical/High/Medium/Low) based on value delivered, reach, enabling future work, blocking value, risk of not doing. 

| Value | Meaning |
|---|---|
| Critical | Foundational — blocks major progress, security/stability risk |
| High | Significant value — key feature, enables multiple issues |
| Medium | Standard value — normal improvement |
| Low | Minor value — nice to have, polish |

Present estimate with reasoning. Accept or enter Critical/High/Medium/Low.

---

**Size advisory** (C:3+ only, after complexity determined):
Display: "📏 Complex issues grow with phases — aim under 500 lines, plan for decomposition at 700."

### STEP 3.5: Testability Gate (C:3+ only)

Skip for complexity 1-2 (simple issues use 5-marker scaffolding without pre-drafted criteria; testability is deferred to analysis).

**Triggered at complexity ≥ 3** — optional initial criteria drafting with subjective-language scan. **Soft warning only** (user-locked preference) — never blocks issue creation.

**Audit-shape signal** (helper used by Class 3 scan in §C and §D below):

`audit_shape_signal` returns **true** when ALL of:
- Issue type = `Research`
- AND any of:
  - **Deliverable-class title pattern** — title contains "audit", "inventory", "classification", "registry sweep", "appendix", "report", or similar deliverable-noun phrasing
  - **Audit/inventory/classify verb in description** — description body contains a verb like "audit", "inventory", "classify", "enumerate", "scan exhaustively", "flag", "collect findings"
  - **Visibility-phrasing in any drafted SC** — any criterion contains phrasing like "appendix", "flagged but not classified", "visibility", "no findings", "empty unless"

The third disjunct gives a single-SC-input fallback when title and verb cues are missing. Returns **false** for non-Research types — audit-shape Research issues are the canonical case where visibility-class SC defaults need pre-baked SCAN discipline; non-Research types do not exhibit the false-empty failure mode.

**C:1-2 audit-shape Research issues** are not gated here (STEP 3.5 is C:3+ only). They are caught downstream by `/nexus-analyze` SC framing surfacing on the deferred-SC path.

**A — Offer criteria drafting**

> 📝 Complex issue (C:{N}) — draft initial success criteria now?
> Drafting a few criteria at creation time lets us sanity-check them for testability before analysis begins.
> [Draft 2-3 now / Defer to analysis]

Via `AskUserQuestion tool`. If "Defer to analysis": skip to STEP 4 — testability check will run later in `/nexus-analyze` during criteria authoring.

**B — Draft criteria** (when user chose "Draft 2-3 now")

Draft 2-3 candidate success criteria using this heuristic:

1. **Criterion 1 (functional completeness)** — restate the primary outcome from description as a verifiable completion check. Template: "{artifact/behavior} {action verb: exists/produces/supports} {observable output/state}"
2. **Criterion 2 (quality or correctness)** — extract one quality dimension implicit in description (correctness, safety, integrity) and state a pass condition. Template: "{condition} holds across {input set / scenarios}"
3. **Criterion 3 (optional, only if scope warrants)** — performance, compatibility, or regression-safety criterion. Template: "{metric} stays within {threshold} under {conditions}"

For each draft: aim to use concrete nouns and action verbs; avoid adjectives entirely in the initial draft. Full mode: present each for user accept/adjust. Assisted/Quick mode: draft silently, show at STEP 4 with `[inferred]` marker.

**C — Pattern Scan (three flag classes)**

Three pattern libraries — each criterion is scanned against all three, but a criterion only fires one flag class at a time. **Precedence** (when a single criterion matches multiple libraries): **Class 1 (subjective) > Class 3 (visibility) > Class 2 (registry)**. Rationale: subjective language is the highest-frequency and most user-fixable issue; visibility-class is the next most actionable (and overlaps with Class 1 on phrases like "no findings"); registry-reference is the rarest and most binary (either it triggers or it doesn't). Final order may be revisited at sprint closure if telemetry shows different overlap rates than expected.

*Class 1 — Subjective-language* (~15 phrases, contextual matches with word boundaries):

```
works well | works fine | is fast | is slow | feels right | is good |
is better | is clear | is easy | is smooth | is robust | is intuitive |
is nice | is simple | properly | correctly | appropriately
```

*Class 2 — Append-only / closure-reconciled registry phrasing* (regex patterns, case-insensitive):

```
(changelog.?registry|registry) .* updated (?!at .*? closure|in sprint-state|in \[FILES_MODIFIED\])
patterns.?registry .* updated    | registry entry added
append .* registry               | direct.? edit .* registry
```

Class 2 fires when an SC implies direct edit of a DO-NOT-EDIT-MANUALLY / append-only registry (canonical: `changelog-registry.yaml`; see CLAUDE.md Version Protocol). The negative lookahead spares phrasings already anchored to the correct closure-reconciled path ("updated at sprint closure", "in sprint-state").

*Class 3 — Visibility-class phrasing* (contextual matches with word boundaries; gated by `audit_shape_signal` from STEP 3.5 header):

```
appendix | flagged but not classified | visibility | no findings |
empty unless | unclassified findings | out-of-scope contamination |
contamination appendix | findings flagged | findings collected
```

Class 3 fires when (a) `audit_shape_signal` returns true (see STEP 3.5 header) AND (b) the criterion contains any of the above phrases. It catches the failure mode where a visibility-class SC element (e.g., "out-of-scope contamination appendix") defaults to **empty = no findings** instead of the correct **SCAN exhaustively first, THEN classify**. Class 3 does not fire on non-Research types or on Research issues without audit-shape signals — the SCAN-then-classify discipline is specific to deliverable-class audit work.

**Class 1/Class 3 overlap resolution**: Phrases like "no findings" can read as either subjective ("everything works fine, no findings") or visibility-class ("appendix is empty because no findings were classified"). Precedence rule above resolves this: Class 1 fires first; only non-overlapping visibility cues fall through to Class 3. When Class 1 fires on a phrase that *also* has visibility-class semantics, the Class 1 rewrite suggestion may not address the visibility default — the author should consider both rewrites manually. Future telemetry may justify a context-aware classifier; current precedence is a safe default.

For each criterion: scan against all three libraries in precedence order (Class 1 → Class 3 → Class 2). Record trigger phrase and the *single* flag class that fired (per precedence).

**D — Flag + offer rewrite (branched by class)**

For each flagged criterion, surface the trigger phrase and offer **one** rewrite tailored to the flag class.

*Class 1 (subjective) — measurable rewrite*:

```
⚠️ Subjective criterion detected (C:{N}):
  "{criterion}"
  Flagged: "{trigger phrase}"
  Suggested rewrite: "{measurable rewrite from domain cues}"
  Options: [Accept rewrite / Modify / Skip / Keep original]
```

*Class 2 (registry phrasing) — registration rewrite*:

```
⚠️ Registry-reference criterion detected (C:{N}):
  "{criterion}"
  Flagged: "{trigger phrase}" — implies direct edit of an append-only registry
  Note: `{registry}` is closure-reconciled; direct edit is forbidden by its DO-NOT-EDIT-MANUALLY header.
  Suggested rewrite: "{action} registered in sprint-state [FILES_MODIFIED] for closure reconciliation"
              — OR — "{registry} updated at sprint closure for files modified by this issue"
  Options: [Accept rewrite / Modify / Skip / Keep original]
```

*Class 3 (visibility-class) — SCAN-then-classify rewrite*:

```
⚠️ Visibility-class criterion detected (C:{N}, audit-shape Research):
  "{criterion}"
  Flagged: "{trigger phrase}" — visibility-class SC defaulting to empty = no findings
  Note: For audit-shape Research issues, the correct discipline is SCAN exhaustively
        first, THEN classify findings into the appendix. Empty-appendix without an
        explicit scan invites false-empties (Sprint 084 ISS-184 P2.6 R2-H1 precedent).
  Suggested rewrite: "Exhaustive scan of {scope} performed; findings classified into
                     {appendix/section}; empty {appendix/section} requires explicit
                     'scan completed, no qualifying findings' note in the audit log"
              — OR — "{appendix/section} populated from scan results; absence of
                     entries is verifiable against scan execution evidence, not
                     assumed by default"
  Options: [Accept rewrite / Modify / Skip / Keep original]
```

Via `AskUserQuestion tool`. User can:
- Accept rewrite → replace criterion with the suggested measurable version
- Modify → user types their own rewrite
- Skip → criterion excluded from ISS (will redraft in analysis)
- Keep original → warning noted but criterion preserved as-is

**E — Soft-warning enforcement**

Never block issue creation regardless of user choice. If user keeps all originals: note "⚠️ {N} subjective criteria retained — will be re-evaluated at analysis" and continue.

**F — Record outcome**

Store drafted (and possibly rewritten) criteria into the ISS file Success Criteria section at STEP 5 template substitution (replacing GUIDANCE placeholder for Success Criteria only; other sections keep their guidance).

> **Mental note**: Testability gate — {N} criteria drafted, {M} flagged, {K} rewrites accepted. Continue to STEP 4.

---

### STEP 4: Review & Confirm

*All modes except Backend arrive here.*

**Registry summary**: Auto-generate a 1-3 sentence description summary (~200-400 chars, soft guidance — it must carry the rationale organize-sprint matches on) from the full description. This goes in the registry `description` field. Shown in review for user to adjust via "Modify fields" if needed.

Display the complete review. In Assisted/Quick mode, mark each field with its source:

```
═══════════════════════════════════════════════════════
📋 REVIEW NEW ISSUE: ISS-{next_number}
═══════════════════════════════════════════════════════

Title: {title} {[inferred]|[default]|[needs input]}
Type: {type} | Priority: {priority} | Impact: {impact}
Complexity: {bars} ({X}/5)

───────────────────────────────────────────────────────
Description:
{full_description}

Registry Summary: {description_summary}
───────────────────────────────────────────────────────

📍 Blocks: {blocks or "None"} {[inferred]|[default]}
🔒 Blocked by: {blocked_by or "None"} {[inferred]|[default]}
📁 Scope: {scope_files or "TBD"} {[inferred]|[default]}
🎯 Target Sprint: {target_sprint or "TBD"} {[inferred]|[default]}

{if C:3+ AND criteria drafted at STEP 3.5:}
📋 Success Criteria (drafted, {N} items):
  1. {criterion_1} {⚠️ subjective "{phrase}" retained | ✓ testable}
  2. {criterion_2} {status marker}
  3. {criterion_3} {status marker}
{if criteria deferred: "📋 Success Criteria: deferred to analysis"}

═══════════════════════════════════════════════════════
**[T2: Balanced+Full ask | Streamlined: auto-create if no [needs input] fields, notify]** Use `AskUserQuestion tool`: Create issue / Modify fields / Cancel.

If modify: ask which field, jump to relevant wizard sub-step (STEP 1/2/3), then return here.
If cancel: "❌ Cancelled", exit.

**Source markers (Assisted/Quick mode)**:
- `[inferred]` — Extracted from user input or derived from registry analysis
- `[default]` — Applied from type/context heuristics
- `[needs input]` — Could not determine, requires user input before creation

If any field is marked `[needs input]`, prompt for those specific fields before allowing "Create issue."

---

### STEP 5: Create Issue File

Pre-check: verify ISS-{next_number}.md doesn't already exist. If it does: next available ID, offer overwrite (with backup), or cancel.

**Determine template**: Research type → `issue-specification.md#[Section: Research-ISS-File-Structure]` (always complex scaffolding). All other types → `issue-specification.md#[Section: ISS-File-Structure]`, scaffolded by complexity.

| Complexity | Markers | Subsections | Guidance | Optional Sections |
|---|---|---|---|---|
| 1-2 (Simple) | 5 mandatory | None | None | Not scaffolded |
| 3-5 (Complex) | All 7 | Pre-populated | Full `<!-- GUIDANCE -->` from spec | Notes-Context, Work-Log |

Construct the ISS file from the loaded specification template, substituting wizard values into placeholders.

Write the ISS file (new file). On failure: stop, offer retry.

---

### STEP 6: Update Registry

For backend mode without description summary: generate one from full_description (1-3 sentences, ~200-400 chars, soft guidance).

Build registry entry from Registry-Schema — wizard values for collected fields, `new_issue_defaults` for auto-set fields (status=Open, scores=1, etc.).

Apply three patches to issues-registry.yaml:

1. Insert entry block above `# --- INSERT NEW ISSUES HERE ---`
2. Update `last_id` to `{next_number}`
3. Update `total_active` to `{old + 1}`

On failure: offer retry or to delete the ISS file from STEP 5 (rollback). If user chooses delete, report "🔄 Rolled back — no changes made".

---

### STEP 7: Verify & Report

Verify:
- ISS file exists at `.nexus/issues/ISS-{next_number}.md`
- Registry entry found (search for `ISS-{next_number}.title:`)
- `last_id` updated to `{next_number}`

**All passed:**

```
═══════════════════════════════════════════════════════
✅ ISSUE CREATED: ISS-{next_number}
═══════════════════════════════════════════════════════

Title: {title}
Type: {type} | Priority: {priority} | Complexity: {complexity}/5

📁 File: .nexus/issues/ISS-{next_number}.md
📋 Registry: Updated (last_id: {next_number}, total: {new_total})
🏗️ Scaffolding: {simple|complex} ({5|7} section markers)

{if quick_mode: "💡 Use 'update issue ISS-{next_number}' to add details"}
═══════════════════════════════════════════════════════
```

**Any failed:** Display specific ✓/✗ per check. Recommend manual verification or retry.

Return: `{ issue_id: ISS-{next_number}, title, scaffolding: simple|complex }`
