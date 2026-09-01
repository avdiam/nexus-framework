---
name: nexus-map-context
description: Map project context into persistent reference artifacts used by all methodology skills
disable-model-invocation: true
---
*Version: 2.3.0 | Date: 2026-06-14 | Sprint: 104*

# Map Project Context

**Flow**: `Detect mode → Scope → [Full: scan codebase | Partial: user describes | Capture: collect preferences] → CONTEXT.md → STRUCTURE.md → CONVENTIONS.md → CONCERNS.md → Integration`

Create persistent context artifacts that methodology skills consume throughout the project lifecycle. Produces 4 files in `.nexus/supporting-files/project-context/` — each artifact has specific consumers with specific format expectations.

**Consumers and their format contracts:**

| Artifact | Consumers | What they expect |
|---|---|---|
| CONTEXT.md | /nexus-analyze (investigation context) | Prior work, dependencies, integrations — prose sections |
| STRUCTURE.md | /nexus-analyze (understanding) + /nexus-build (file placement) | Architecture, modules, data flow — navigable sections |
| CONVENTIONS.md | /nexus-build (style compliance) + /nexus-validate (convention check) + /nexus-analyze (locked standards) | Rules and patterns — specific, testable statements |
| CONCERNS.md | /nexus-generate-mvp (severity filtering) + /nexus-analyze (scope flags) + /nexus-validate (known issues checklist) | Checkbox items with `[HIGH/MEDIUM/LOW]` severity tags |
| PROJECT_DRAFT.md | /nexus-setup-project (STEPs 1E/1F.5/1G/1H/3A wizard pre-population) | Structured draft payload (frontmatter + fenced YAML block) with 10 fields keyed by project-state path + `source:` citations + `[inferred]` markers. Dual persistence (disk artifact + in-memory return payload). Full mode only. |

**Living documents**: These artifacts should be updated as the project evolves — not just created once. Re-run map-context to refresh, or append manually during sprint work.

---

## STEP 0: Scope & Mode

### A. Memory Check (silent)

Recite files in memory. Avoid reloads.

### B. Detect Project Type

| Source | Action |
|---|---|
| Called from setup-project | Type passed as parameter — use directly |
| Standalone, project-state.md exists | Read `PROJECT_DEFINITION.project_type` |
| Standalone, no project-state.md | "Run setup-project first, or provide project type to proceed standalone." If user proceeds: prompt for type. Note: "Artifacts created standalone — run setup-project to integrate." |

### C. Detect Mode

| Source | Action |
|---|---|
| Called from setup-project with mode param | Use directly |
| Standalone | Ask via AskUserQuestion: [Full mapping (existing project with code/work) / Partial mapping (existing context/standards/research) / Capture preferences (new project, bring standards/references)] |

**Three modes:**

| Mode | When | Behavior |
|---|---|---|
| **Full** (brownfield) | Ongoing project with existing work | Actively scan — examine files, structure, patterns using tools. Comprehensive prompting. |
| **Partial** (existing context) | New project with prior standards, research, references | User describes — record known standards, prior work. Adapted prompting. |
| **Capture** (greenfield) | NEW — blank slate but user has preferences | Collect preferences — coding standards, reference architectures, brand guides, methodology preferences, tech stack decisions. Lightweight. |

All artifacts are optional within each mode — capture what exists, don't force fabrication for inapplicable dimensions.

### D. Check Existing Artifacts

Check if `.nexus/supporting-files/project-context/` exists and contains artifacts.

| State | Action |
|---|---|
| Directory doesn't exist | Create it. Proceed. |
| Directory exists, no artifacts | Fresh mapping — proceed. |
| Some artifacts exist | **[T2: Balanced+Full ask \| Streamlined: notify+log]** "Found existing: {list}." AskUserQuestion: [Update specific / Skip existing / Re-map all] |
| All 4 artifacts exist | **[T2: Balanced+Full ask \| Streamlined: notify+log]** "All context artifacts exist." AskUserQuestion: [Update specific / Re-map all / Cancel] |

| Choice | Action |
|---|---|
| Update specific | Ask which. Jump to corresponding STEP(s) only. |
| Skip existing | Jump to first missing STEP. |
| Re-map all | Proceed to STEP 1 (overwrite existing). |

### E. Identify Scope

Adapt based on mode + project type. **STOP. Wait for user response.**

**Full mode**:

"What should I scan? Provide the key directories or areas." Then actively scan using:
- `Glob` — discover file structure, identify key directories, count files by type
- `Grep` — find patterns (imports, config, conventions, TODOs, known issues)
- `Read` — examine key files (README, config, package.json, main entry points)

**Partial mode**:

| Type Category | Question |
|---|---|
| Software / Technical | "What existing work should I capture? (prior code, APIs, specs, architecture decisions)" |
| Research / Analysis | "What existing research should I review? (papers, data, prior analysis, methodology)" |
| Creative / Content | "What existing material should I capture? (brand assets, prior content, style references)" |
| Business / Strategic | "What context should I capture? (market research, prior strategy, competitive analysis)" |

**Capture mode** (greenfield):

| Type Category | Question |
|---|---|
| Software / Technical | "What standards or preferences do you want to establish? (coding style, naming conventions, tech stack, testing approach, reference architectures)" |
| Research / Analysis | "What methodology preferences? (citation style, terminology, analysis approach, documentation standards)" |
| Creative / Content | "What creative standards? (brand guidelines, voice/tone, format rules, quality bar)" |
| Business / Strategic | "What process standards? (document formats, communication style, decision protocols)" |

---

## STEP 1: Current State → CONTEXT.md

Capture what already exists or what the starting context is.

### A. Type-Adapted Investigation

| Type Category | Key Dimensions |
|---|---|
| **Software** | Stack, dependencies, prior work, external integrations, deployment setup |
| **Research** | Literature, datasets, hypotheses, prior findings, methodology precedents |
| **Creative** | Brand, assets, prior content, audience understanding, platform constraints |
| **Business** | Market context, competitive landscape, prior strategy, stakeholder landscape |

### B. Gather Information

**Full mode**: Actively scan the project:
- `Glob "**/*.{json,yaml,toml,cfg}"` — find config files, extract tech stack
- `Read README.md` or equivalent — project description, setup instructions
- `Read package.json` / `requirements.txt` / `Cargo.toml` etc. — dependencies
- `Glob "src/**"` or main source directory — understand codebase shape
- Ask user for what scanning can't reveal: architectural decisions, external service context

**Partial mode**: Ask user to describe what exists. Probe for completeness.

**Capture mode**: Ask what the user wants to establish. Propose defaults from domain knowledge: "For {type} projects, common starting context includes: {proposals}. What applies?" **STOP. Wait for user response.**

### C. Write Artifact

Create `.nexus/supporting-files/project-context/CONTEXT.md`:

```markdown
# CONTEXT.md
*Project: {project_name} | Type: {project_type} | Mapped: {date} | Mode: {full/partial/capture}*
*Living document — update as project evolves. Re-run /nexus-map-context to refresh.*

## Overview
{1-2 sentence summary of what exists or starting context}

## {Type-adapted section 1}
{e.g., "Technology Stack" / "Existing Research" / "Brand Foundation" / "Market Context"}

## {Type-adapted section 2}
{e.g., "Prior Work" / "Available Data" / "Existing Assets" / "Competitive Landscape"}

## {Type-adapted section 3}
{e.g., "External Dependencies" / "Key Sources" / "Platform Constraints" / "Stakeholder Context"}

## Notes
{Caveats, confidence levels, gaps in information}
```

### D. Update & Confirm

Patch `project-state.md [KEY_RESOURCES].context_artifacts` — append "CONTEXT.md".

Display: "✓ CONTEXT.md created — {brief summary}"

---

## STEP 2: Organization → STRUCTURE.md

Capture how the project is organized or should be organized.

### A. Type-Adapted Investigation

| Type Category | Key Dimensions |
|---|---|
| **Software** | Architecture, modules, data flow, file organization, component boundaries |
| **Research** | Methodology stages, data organization, analysis pipeline |
| **Creative** | Content structure, narrative arc, format organization, channel structure |
| **Business** | Organizational structure, process flow, decision hierarchy |

### B. Gather Information

**Full mode** (Claude Code):
- `Glob` — map directory tree, identify module boundaries
- `Grep "import|require|from"` — trace dependency graph between modules
- `Read` key architectural files — main entry, config, routers

**Full/Partial/Capture mode**: Adapt per mode (scan, describe, or establish).

**STOP after gathering. Present findings/proposal for user validation.**

### C. Write Artifact

Create `.nexus/supporting-files/project-context/STRUCTURE.md`:

```markdown
# STRUCTURE.md
*Project: {project_name} | Type: {project_type} | Mapped: {date} | Mode: {mode}*
*Living document — update as project evolves.*

## Overview
{1-2 sentence summary of organization}

## {Type-adapted section 1}
{e.g., "Architecture" / "Methodology" / "Content Structure" / "Process Flow"}

## {Type-adapted section 2}
{e.g., "Module Organization" / "Data Organization" / "Format Structure" / "Team Structure"}

## {Type-adapted section 3}
{e.g., "Data Flow" / "Analysis Pipeline" / "Distribution Channels" / "Decision Flow"}

## Notes
{Structural debt, areas of uncertainty, planned reorganization}
```

### D. Update & Confirm

Append "STRUCTURE.md" to `[KEY_RESOURCES].context_artifacts`.

Display: "✓ STRUCTURE.md created — {brief summary}"

---

## STEP 3: Standards → CONVENTIONS.md

Capture how things are done or should be done. **This artifact is consumed by /nexus-build for compliance AND /nexus-validate for verification** — conventions must be specific and testable, not vague aspirations.

### A. Type-Adapted Investigation

| Type Category | Key Dimensions |
|---|---|
| **Software** | Naming, imports, code style, testing patterns, commit conventions, error handling |
| **Research** | Citation style, terminology, analysis conventions, documentation standards, data format |
| **Creative** | Voice, tone, format rules, brand guidelines, editorial standards, asset naming |
| **Business** | Communication style, document formats, decision protocols, reporting conventions |

### B. Gather Information

**Full mode** (Claude Code):
- `Grep` for pattern consistency — naming conventions, import styles, test patterns
- `Read` config files — linters, formatters, style configs (eslint, prettier, rubocop, etc.)
- `Read` existing tests — testing patterns, assertion style, fixture approach
- Look for CONTRIBUTING.md, style guides, coding standards docs

**Convention quality standard**: Each convention should be **specific enough to verify**:
- Bad: "Use good naming" → Not testable
- Good: "Functions use camelCase, classes use PascalCase, constants use UPPER_SNAKE" → Testable
- Bad: "Write clean code" → Not testable
- Good: "Functions under 30 lines, max 3 parameters, early return pattern" → Testable

**Partial/Capture mode**: Ask user. Propose conventions from domain knowledge: "Common {type} conventions include: {list}. Which apply? What would you add?" **STOP. Wait for user response.**

### C. Write Artifact

Create `.nexus/supporting-files/project-context/CONVENTIONS.md`:

```markdown
# CONVENTIONS.md
*Project: {project_name} | Type: {project_type} | Mapped: {date} | Mode: {mode}*
*Living document — update as conventions evolve.*
*Consumed by: /nexus-build (compliance during implementation), /nexus-validate (convention check during evaluation)*

## Overview
{1-2 sentence summary of key conventions}

## {Type-adapted section 1}
{e.g., "Naming Conventions" / "Citation Style" / "Voice & Tone" / "Document Formats"}
- {Specific, testable convention}
- {Specific, testable convention}

## {Type-adapted section 2}
{e.g., "Code Style" / "Terminology" / "Format Rules" / "Communication Standards"}
- {Specific, testable convention}

## {Type-adapted section 3}
{e.g., "Testing Patterns" / "Documentation Standards" / "Brand Guidelines" / "Decision Protocols"}
- {Specific, testable convention}

## Notes
{Conventions that are implicit vs explicit, areas without clear standards}
```

### D. Update & Confirm

Append "CONVENTIONS.md" to `[KEY_RESOURCES].context_artifacts`.

Display: "✓ CONVENTIONS.md created — {N} conventions captured"

---

## STEP 4: Issues & Gaps → CONCERNS.md

Capture known problems, gaps, and areas of uncertainty. **This is the most consumed artifact** — read by generate-mvp (severity filtering → issues), analyze (scope flags), and validate (known issues checklist).

### A. Type-Adapted Investigation

| Type Category | Key Dimensions |
|---|---|
| **Software** | Tech debt, security concerns, performance issues, missing tests, dependency risks |
| **Research** | Methodological gaps, open questions, data limitations, validity concerns |
| **Creative** | Unresolved constraints, audience gaps, consistency issues, rights/permissions |
| **Business** | Strategic uncertainties, market risks, capability gaps, compliance gaps |

### B. Gather Information

**Full mode** (Claude Code):
- `Grep "TODO|FIXME|HACK|XXX|DEPRECATED"` — find flagged issues in code
- `Grep "security|vulnerability|injection|XSS"` — surface security concerns
- Check for missing test files — `Glob "**/*.test.*"` vs `Glob "src/**/*.{js,ts,py}"`
- Look for outdated dependencies, missing configs, documented known issues

**Partial/Capture mode**: Ask user about known issues. Probe: "What worries you about this project? What's the biggest risk? What's untested?"

### C. Severity Classification

**After collecting all concerns, classify each one.** This is critical — generate-mvp filters by severity to decide which concerns become dedicated issues.

| Severity | Criteria | generate-mvp action |
|---|---|---|
| **HIGH** | Blocks progress, security risk, data integrity risk, violates constitution | → Becomes a dedicated issue |
| **MEDIUM** | Technical debt, missing coverage, quality risk, could cause problems later | → May become issue or fold into deliverable issue |
| **LOW** | Cosmetic, preference, future consideration, minor inconsistency | → Noted for context only |

Present the classified list: "I've identified {N} concerns. Here's my severity assessment:" **STOP. Wait for user to validate/adjust severity ratings.** Severity drives issue creation — user must agree.

### D. Write Artifact

Create `.nexus/supporting-files/project-context/CONCERNS.md`:

```markdown
# CONCERNS.md
*Project: {project_name} | Type: {project_type} | Mapped: {date} | Mode: {mode}*
*Living document — append new concerns as discovered. Check off resolved items.*
*Consumed by: /nexus-generate-mvp (HIGH→issues, MEDIUM→consider), /nexus-analyze (scope flags), /nexus-validate (known issues checklist)*

## Overview
{1-2 sentence summary of concern landscape}

## {Type-adapted section 1}
{e.g., "Technical Debt" / "Methodological Gaps" / "Unresolved Constraints" / "Strategic Uncertainties"}
- [ ] [HIGH] {Specific concern with enough context to act on}
- [ ] [MEDIUM] {Specific concern}
- [ ] [LOW] {Specific concern}

## {Type-adapted section 2}
{e.g., "Security Concerns" / "Open Questions" / "Audience Gaps" / "Market Risks"}
- [ ] [HIGH] {Specific concern}
- [ ] [MEDIUM] {Specific concern}

## {Type-adapted section 3}
{e.g., "Known Limitations" / "Data Limitations" / "Consistency Issues" / "Capability Gaps"}
- [ ] [MEDIUM] {Specific concern}
- [ ] [LOW] {Specific concern}

## Summary
HIGH: {count} | MEDIUM: {count} | LOW: {count} | Total: {count}
```

### E. Update & Confirm

Append "CONCERNS.md" to `[KEY_RESOURCES].context_artifacts`.

Display: "✓ CONCERNS.md created — {N} concerns ({HIGH} HIGH, {MEDIUM} MEDIUM, {LOW} LOW)"

---

## STEP 5A: Project-State Draft Generation

**Triggers only in Full mode (brownfield scan)**. Partial and Capture modes skip this step entirely and proceed to STEP 5B.

> 📂 **Full mode only — externalized.** STEP 5A's draft-generation logic (10-field derivation table, confidence tiers, PROJECT_DRAFT.md format spec, PAT-083 ownership discipline, graceful fallback) lives in a companion file to keep this skill lean. When in Full mode, load it now and execute its A–H steps:
> **Read** `.claude/skills/nexus-map-context/references/project-state-draft-generator.md` **[Section: Project-State-Draft-Generator]**
> Partial/Capture modes skip directly to STEP 5B without loading.

---

## STEP 5B: Artifact Registration

### A. Final project-state updates

Patch `[KEY_RESOURCES].context_artifacts` with full list of created artifacts (only those actually created — some may have been skipped). If `context_artifacts:` field doesn't exist in [KEY_RESOURCES] (pre-Sprint 060 instance), add it after `external_resources:` with the artifact list.

If CONCERNS.md has HIGH severity items, append to `[CONSTRAINTS_AND_RISKS].identified_risks`:
```
- risk: "{HIGH concern from CONCERNS.md}"
  probability: "High"
  impact: "High"
  mitigation: "Dedicated issue will be created at generate-mvp"
```

If `brownfield` not already set in `[PROJECT_DEFINITION]`: set based on mode (full → true, partial/capture → false).

Verify all patches applied.

### B. Completion Display

```
✅ Project Context Mapped
════════════════════════════════════════
Mode: {full/partial/capture}
Type: {project_type}

Artifacts created:
• CONTEXT.md — {brief summary}
• STRUCTURE.md — {brief summary}
• CONVENTIONS.md — {N} conventions captured
• CONCERNS.md — {N} concerns ({HIGH} HIGH, {MEDIUM} MED, {LOW} LOW)

Location: .nexus/supporting-files/project-context/

These artifacts are now available to:
• /nexus-generate-mvp — concerns → issues, context → descriptions
• /nexus-analyze — prior work, structure, known concerns
• /nexus-build — conventions compliance, file placement
• /nexus-validate — convention check, known issues checklist

💡 These are living documents — re-run /nexus-map-context to refresh.
════════════════════════════════════════
```

### C. Return to Caller

If called from setup-project: return control.
If standalone: operation complete.

---

## Gate Reference

| Gate | Step | Tier | Full | Balanced | Streamlined |
|---|---|---|---|---|---|
| Existing artifacts handling | 0D | **T2** | Ask | Ask | Notify+log |
| Concern severity validation | 4C | **T2** | Ask | Ask | Auto-classify, notify+log |
| Per-artifact write | 1-4 D | **T3** | Ask | Notify | Silent |

---

## End-of-Workflow Checklist

- [ ] All created artifacts verified on disk
- [ ] project-state `[KEY_RESOURCES].context_artifacts` updated with actual list
- [ ] HIGH concerns from CONCERNS.md appended to `[CONSTRAINTS_AND_RISKS]`
- [ ] `brownfield` field set in `[PROJECT_DEFINITION]` if applicable
- [ ] All patches to project-state verified

---

## Error Recovery

| Problem | Recovery |
|---|---|
| project-context/ directory creation fails | Check permissions. Create manually if needed. |
| Artifact write fails | Retry. If still fails: display content to user for manual save. |
| Scanning finds nothing meaningful (Full mode) | Inform user. Offer to switch to Partial or Capture mode. |
| User can't describe context (Partial/Capture) | Propose defaults from domain knowledge. Accept thin input and flag for future update. |
| Interrupted mid-flow | Each artifact written immediately — resume detects existing artifacts (STEP 0D). |
| Stale artifacts from previous mapping | Re-map all option overwrites. Update specific targets individual artifacts. |

---

## Type-Artifact Quick Reference

| Artifact | Software | Research | Creative | Business |
|---|---|---|---|---|
| **CONTEXT** | Stack, deps, prior code | Literature, data, findings | Brand, assets, audience | Market, competitors, strategy |
| **STRUCTURE** | Architecture, modules, data flow | Methodology, data org | Content structure, arc | Org structure, processes |
| **CONVENTIONS** | Code style, naming, testing | Citation, terminology, docs | Voice, tone, format | Doc formats, protocols |
| **CONCERNS** | Tech debt, security, missing tests | Method gaps, open Qs | Constraints, consistency | Uncertainties, risks |
