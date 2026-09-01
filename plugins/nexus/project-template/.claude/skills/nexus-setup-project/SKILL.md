---
name: nexus-setup-project
description: Define project vision, scope, deliverables, and success criteria
disable-model-invocation: true
---
*Version: 5.2.0 | Date: 2026-08-31 | Sprint: 112*

# Setup Project

**Flow**: `Load context → Initial intake → Mode detect → [Full: Identity → Vision → Scope → Deliverables → Phases → Risks & Validation] [Assisted: Silent analysis] → Review & Finalize → Next steps` — OR — `Update Mode (when project already exists)`

Interactive wizard for complete project definition AND in-place parameter updates. The Wizard (STEP 0–7 below) creates and progressively populates project-state.md through a collaborative flow with Full or Assisted modes. **Update Mode** (## Update Mode section near the end of this file) edits parameters of an existing project with impact analysis and registry cascade. Called by init-project (first-run, Wizard), by user directly ("setup project" → Wizard, "update project parameters" → Update Mode), or by STEP 0A routing when an existing fully-populated project-state is detected.

**Scope**: Creates project-state.md (Wizard) or updates it in place (Update Mode). Does NOT generate issues (/nexus-generate-mvp), update sprint progress (/nexus-update-state), or organize sprints (/nexus-organize-sprint).

---

## Wizard Principles

**Collaboration, not a form.** After type selection, a domain-specific template is loaded and used throughout to propose content, frame questions, and suggest risks. The LLM proposes first, the user validates — never present blank forms when domain knowledge is available.

**Navigation**: User can revisit any previous step (progressive writes make this safe). If the user skips ahead, note what context from earlier steps is missing and flag for revisit at STEP 7.

**Type changes**: If the user realizes mid-wizard that the project type is wrong:
1. Update PROJECT_DEFINITION with new type
2. Reload the correct template
3. Re-derive `_project_type` from the new type (STEP 1E logic)
4. If context_artifacts exist (context mapping already ran): offer "Your context artifacts were mapped for {old_type}. Re-map for {new_type}? [Yes / Keep existing]"
5. Offer to revisit earlier steps that were framed differently

**Thin answers**: If the user gives persistently brief answers after prompting, accept gracefully: "I'll capture this for now — we can refine at review." Fill gaps with reasonable defaults from the loaded template, marked as `{inferred from project type}` so the user knows what was defaulted. Flag thin sections for revisit at STEP 7.

**Wizard depth**: After type selection, `wizard_depth` from the loaded template (light/standard/thorough) guides step depth throughout. Light: accept answers faster, fewer push-backs, 2-3 risks. Standard: moderate depth, 3-4 risks. Thorough: push harder on all elements, 5+ risks with Socratic depth. When no template is loaded, default to standard.

**Stop enforcement**: Every interactive sub-step must produce a hard stop. Use `AskUserQuestion` for structured choices (2-4 options). For open-ended input, present the question and add: **STOP. Wait for user response before proceeding.** Never generate answers on the user's behalf and continue.

---

## Architect-Pattern Activation

The setup-project wizard can activate three Architect-derived sub-steps — **scope negation** ("I do not..."), **deliverable handoff contracts**, and **workflow-tree articulation** (entry/exit/depends_on per phase). These are **project-type gated**: not every project benefits equally, so the matrix below decides which sub-steps fire at which depth per project type. The matrix is consumed at STEP 1E (after `_project_type` derivation) and referenced by STEP 3.D, STEP 4.F, and STEP 5.D.

**Matrix lookup key**: rows are indexed by the lowercase-hyphenated **project-type profile name** (matching the `.nexus/templates/project-types/{name}.md` filename), NOT by the metadata `_project_type` value (which is `code|creative|mixed`) and NOT by the `PROJECT_DEFINITION.project_type` title-cased label (e.g., "Software/Product Dev"). The profile name is derived at STEP 1C/1D when the type template is loaded — that derivation is the matrix's keying input.

**Activation matrix** (13 project types × 3 sub-steps):

| Project Type | STEP 3.D Scope Negation | STEP 4.F Handoff Contracts | STEP 5.D Workflow Tree |
|---|---|---|---|
| software-product-dev | Full | Full | Full |
| migration-transition | Full | Full | Full |
| complex-problem-solving | Full | Light (ask) | Full |
| system-integration | Full | Full | Full |
| compliance-audit | Full | Light | Light |
| research-analysis | Skip | Skip | Light |
| creative-content | Skip | Skip | Skip (linear) |
| educational-training | Light | Skip | Light |
| data-analytics | Light | Light | Light |
| strategic-business-planning | Light | Light | Light |
| operations-process | Full | Full | Light |
| event-campaign | Full | Light | Light |
| product-design | Full | Light | Full |

**Activation levels**:

| Level | Behavior |
|---|---|
| **Full** | Sub-step always runs. Wizard prompts and writes are non-optional. |
| **Light** | Sub-step offered with explicit skip option. Wizard explains why the sub-step is offered and lets the user opt in/out. |
| **Skip** | Sub-step does not fire. Schema fields remain empty (`[]`). |

**Self-hosting carve-out** (gates ONLY this matrix and STEP 5.D row defaults): If `_self_hosting == true` in the project-state instance being created, the matrix above is bypassed and the three matrix-driven activation values are forced to **Skip** for all three sub-steps. STEP 3.D / STEP 4.F / STEP 5.D do not fire. Rationale: when NEXUS sets up its own meta-project, /nexus-organize-sprint handles workflow concerns — the Architect pattern is not the right tool for the meta-framework's own state. **S1–S3 sub-step CONTENT remains framework-neutral** (the sub-steps themselves are not framework-specific — only their *activation* is gated by this matrix; the same sub-steps are reused unchanged when matrix activation says Full/Light).

**Future inverse-dependency consideration** (R3 from ISS-159 v1.1.0-revised, deferred): If the project-type roster grows beyond 13, the matrix may be more ergonomic as activation metadata declared inside each `project-types/{type}.md` profile rather than centralized here. At 13 profiles, centralized matrix is manageable; revisit if/when the roster expands.

---

## STEP 0: Context Setup & Mode Detection

### A. Existence Check (silent)

Check if project-state.md exists at `.nexus/active/states/project-state.md`.

First: verify `.nexus/active/states/` directory exists. If not, the NEXUS directory structure is missing — suggest running `/nexus-init-project` first. Do not proceed without the directory structure.

| State | Action |
|---|---|
| Does not exist | Load `.nexus/templates/project-state-template.md`, create project-state.md as copy. Proceed to 0B. |
| Exists with template placeholders | Resume detection (see below). |
| Exists and fully populated | **[T1: all levels ask]** "A project is already defined: '{title}'. Overwriting replaces ALL definitions." Backup existing project-state.md first (git commit with message "nexus: backup project-state before overwrite" or file copy to `.nexus/backups/`). On confirmation: create fresh from template. **On decline**: route to ## Update Mode (near end of this file) to edit specific parameters without overwrite. |

**Resume detection** — determine where previous wizard stopped:

| If populated | Resume at |
|---|---|
| Nothing beyond template defaults | STEP 1 |
| PROJECT_DEFINITION has type/domain, brownfield=true, no context_artifacts, context_mapping_skipped != true | STEP 1F (context mapping) |
| PROJECT_DEFINITION has type/domain, brownfield=true, context_artifacts contains PROJECT_DRAFT.md, no vision | STEP 1F.5 (draft review notice) with payload loaded from disk |
| PROJECT_DEFINITION has type/domain but no vision | STEP 2 |
| PROJECT_DEFINITION has vision, no scope | STEP 3 |
| SCOPE_AND_BOUNDARIES populated | STEP 4 |
| DELIVERABLES populated | STEP 5 |
| PROJECT_PHASES populated | STEP 6 |
| CONSTRAINTS_AND_RISKS + SUCCESS_METRICS populated | STEP 7 |

**PROJECT_DRAFT.md resume handling** (runs before the table check above when `_project_lifecycle: defining` and a partial setup-project wizard is resuming):

1. Check if `.nexus/supporting-files/project-context/PROJECT_DRAFT.md` exists
2. If exists AND `draft_consumed_at` frontmatter field is ABSENT: the draft is unconsumed, load it from disk into `draft_payload` working memory (matches map-context STEP 5A companion §F Rule 2 — disk is resume authority)
3. If exists AND `draft_consumed_at` is PRESENT: the draft was already consumed in a prior wizard run — load for reference but flag as stale
4. **Stale detection via mtime comparison**: compare mtime of `PROJECT_DRAFT.md` against mtime of scanned source files at project root. Check: `package.json`, `pyproject.toml`, `Cargo.toml`, `go.mod`, `Gemfile`, `README.md`, `CLAUDE.md`, `AGENTS.md`, `tsconfig.json`, `environment.yml`, `.nvmrc`, `.python-version`, `Dockerfile`. If any present source file has mtime > PROJECT_DRAFT.md mtime, the draft may be stale.

**Stale draft user prompt** (when mtime detection fires):

```
⚠️ Draft may be stale — source files changed since scan.
   Scanned at: {draft scanned_at from frontmatter}
   Source files newer than draft ({count} total):
     • {file_path_1} (modified {mtime})
     • {file_path_2} (modified {mtime})
     • ... (up to 5 files shown)
     + {N} more changes  ← only if count > 5

   [Re-map now / Use stale draft / Proceed without draft]
```

**Display rule**: List at most 5 files in the bullet list. If more than 5 files are newer, append `+ {N} more changes` line where N = total_newer_count - 5. This prevents the prompt from becoming noisy during bulk dependency updates or refactors.

- **Re-map now**: invoke `/nexus-map-context` in full mode to regenerate PROJECT_DRAFT.md, then continue resume at STEP 1F.5
- **Use stale draft**: set `draft_payload` from disk as-is, continue resume at STEP 1F.5
- **Proceed without draft**: set `draft_payload = None`, continue resume at the step indicated by the resume table above (skipping STEP 1F.5)

If no PROJECT_DRAFT.md exists, proceed with the existing resume table unchanged.

Present: "Your previous session completed through {last step}. Resume from {next step}, or start fresh?" Use AskUserQuestion: [Resume from {step} (recommended) / Start fresh].

On resume: reload template from `.nexus/templates/project-types/{type}.md` using existing `project_type` (memory-first — skip if already loaded). Steps 4-6 depend on it. On resume, skip 0B/0C — mode is always Full when resuming a partial wizard.

### B. Initial Intake

Ask regardless of whether a description was provided with the command — user might have both.

"Do you have project documents to feed in? (architecture specs, PRDs, tech stack requirements, reference material, etc.)" Use AskUserQuestion: [No documents / Yes, I have documents].

If yes: "Where are they located? Provide file paths or describe what you have." **STOP. Wait for user response.**

On paths provided: Read each document. Extract project information:

| Document Type | Extraction Priority |
|---|---|
| PRD / Requirements | Features, user stories, acceptance criteria → deliverables and scope |
| Research brief | Questions, hypotheses, methodology → vision and scope |
| Technical spec | Components, APIs, architecture → deliverables and constraints |
| Planning doc | Timeline, milestones, resources → phases and constraints |
| Reference material | Domain context → inform guidance, not direct extraction |

For multiple documents: extract independently, then synthesize. Flag contradictions explicitly — mark as `[needs input]` for STEP 7 resolution. For large documents (>30KB): prioritize executive summary, scope, and deliverable sections.

### C. Mode Detection

| Signal | Mode | Flow |
|---|---|---|
| Called by init-project (first-run) | Full | Interactive wizard, all steps prompted |
| Bare command, no description | Full | Interactive wizard, all steps prompted |
| Description provided with command | Assisted | Silent analysis → STEP 7 review |
| Documents provided (with or without description) | Assisted+Docs | Extract from docs → silent analysis → STEP 7 review |

**Mode execution principle**: Assisted mode is a **UX optimization, not an analysis shortcut**. All steps (1-6) run with full analytical logic — the difference is interaction style, not depth.

**Full mode**: Proceed to STEP 1. In Full mode with documents: present relevant extractions at each interactive step as starting points ("From your documents: {extracted}. Does this capture it?").

**Assisted modes**: Proceed to 0D.

### D. Silent Analysis (Assisted modes only)

Run ALL step logic in sequence — same analytical depth as Full mode, only interaction skipped. For each field: extract from input/docs → mark `[inferred]`, apply template default → mark `[default]`, cannot determine → mark `[needs input]`.

**Mandatory checklist** (every item must execute):

- [ ] Derive project mode → default "Starting fresh" unless docs suggest existing codebase
- [ ] Infer type + domain from description/docs
- [ ] Load matching template (`.nexus/templates/project-types/{type}.md`)
- [ ] Derive `_project_type` (code/creative/mixed) from type
- [ ] Generate vision from input — check for 3 elements (outcome, purpose, success)
- [ ] Derive scope and constraints from input/docs/template
- [ ] Propose deliverables categorized MVP/Enhanced/Future from template
- [ ] Propose phases from template, allocate deliverables, calibrate effort
- [ ] Assess risks from template + context
- [ ] Write ALL sections progressively to project-state.md — same writes as Full mode
- [ ] Cross-step coherence check (STEP 6D logic)

After silent analysis → skip to STEP 7 review.

---

## STEP 1: Identity

*Full mode: interactive. Assisted mode: covered by silent analysis (0D).*

Establish the project identity, select type, and gather existing materials.

### A. Project Mode

Determine starting point. Use AskUserQuestion with 3 options:

- **Starting fresh** — blank slate, nothing exists yet
- **New with existing context** — new project, but you have prior research, standards, or reference material
- **Ongoing/brownfield** — connecting NEXUS to a project that's already underway

| Mode | Action |
|---|---|
| Starting fresh | Set `brownfield: false`. Skip context mapping (STEP 1F). |
| New with existing context | Set `brownfield: false`. Flag for partial context mapping. |
| Ongoing/brownfield | Set `brownfield: true`. Flag for full context mapping. |

### B. Project Name

"What's the working title for this project?" **STOP. Wait for user response.**

Working title — revisited at STEP 7 review when the full picture is clear.

### C. Project Type

Present via AskUserQuestion in two rounds:

1. First widget — category: Technical / Research / Business / Creative / Other
2. Second widget — types within selected category (3-4 options each)

Types: Software/Product Dev, Research & Analysis, Complex Problem Solving, Product Design, System Integration, Data & Analytics, Strategic/Business Planning, Educational/Training, Creative/Content, Operations/Process Improvement, Event/Campaign Management, Compliance/Audit, Migration/Transition, Other/Custom.

After selection: "Purely {type}, or blends with another type?" **STOP. Wait for user response.** Accept hybrid types. Capture primary type, note secondary aspects.

### D. Load Domain Template

Read `.nexus/templates/project-types/{type}.md`. This template guides all remaining steps — all 7 sections (Profile, Framing-Hints, Deliverable-Templates, Phase-Templates, Risk-Catalog, Metrics, Issue-Breakdown) are now available. Extract `wizard_depth` from Profile section.

If no match: Read `.nexus/templates/project-type-template.md` as structural reference and rely on domain knowledge. Inform user: "No pre-built template for this type — I'll draw on general knowledge and adapt as we go." Default wizard_depth to standard.

### E. Project Type Classification

Auto-derive `_project_type` from the selected project type:

| Project Type | `_project_type` | Rationale |
|---|---|---|
| Software/Product Dev, System Integration, Data & Analytics, Migration/Transition | `code` | Text/code files — git handles backups |
| Creative/Content, Educational/Training | `creative` | Binary deliverables (docx/pptx/jpg) — needs `.nexus/backups/` |
| Research & Analysis, Product Design, Strategic/Business, Event/Campaign | `mixed` | Code + binary deliverables — hybrid backup |
| Operations/Process, Compliance/Audit, Complex Problem Solving | `code` | Default unless user specifies binary outputs |

**Draft cross-check** (conditional — only if `draft_payload` from 1F.1 is present and has `_project_type`): Compare the category-derived value against `draft_payload._project_type` (from scan file inventory). The scan value is CERTAIN confidence.

| Situation | Display |
|---|---|
| Category and scan agree | No extra prompt — confirm as normal (scan result silently reinforces the category default) |
| Category and scan disagree | Surface the disagreement via AskUserQuestion: "📋 Scan detected `{scan_value}` based on file inventory, but your project category suggests `{category_value}`. Which matches reality?" Options: [Use scan result ({scan_value}) / Use category default ({category_value}) / Choose a different type]. If "Choose a different type": follow-up AskUserQuestion: "Which backup strategy type?" Options: [code / creative / mixed]. |

If no draft_payload or no `_project_type` in payload, skip the cross-check and use existing behavior.

Confirm via AskUserQuestion: "Based on your project type, backup strategy: **{code/creative/mixed}**. Code files use git, binary deliverables backed up to `.nexus/backups/`. Correct?" Options: [Correct / Change to code / Change to creative / Change to mixed]. (Draft cross-check prompt above replaces this widget when draft disagrees with category.)

If creative or mixed: ensure `.nexus/backups/` exists and is in `.gitignore`.

**Architect-Pattern Activation Decision** (silent — runs once `project_type` is final):

After the project type is locked (and the backup-strategy cross-check above is resolved), read the §Architect-Pattern Activation matrix at the top of this skill and store the three activation values for the session:

- `scope_negation` ∈ {Full, Light, Skip} — consumed by STEP 3.D
- `handoff_contracts` ∈ {Full, Light, Skip} — consumed by STEP 4.F
- `workflow_tree` ∈ {Full, Light, Skip} — consumed by STEP 5.D

**Self-hosting carve-out**: If the project-state being created has `_self_hosting: true`, force all three values to **Skip** regardless of matrix row. This is the meta-framework guard — NEXUS-on-NEXUS does not activate the Architect-pattern sub-steps because /nexus-organize-sprint owns that workflow. S1–S3 *sub-step content* remains framework-neutral; only the *matrix-driven activation values* are gated by this flag.

**No user prompt at STEP 1E**: activation decisions are deterministic from project type and `_self_hosting`. The wizard surfaces activation transparency only when each affected sub-step fires (Light variant shows a skip option; Skip variant is silent).

### F. Context Mapping

Offered for ALL project modes — even greenfield projects may have standards, references, or preferences to capture.

| Project Mode (from 1A) | map-context Mode | Question |
|---|---|---|
| Starting fresh | capture | "Do you have any standards, preferences, or reference material to capture? (coding standards, style guides, reference architectures, brand guidelines)" |
| New with existing context | partial | "Map your existing context now? This captures prior work, standards, and known issues into reference artifacts." |
| Ongoing/brownfield | full | "Map your existing project? This scans your codebase and captures structure, conventions, and known issues." |

Use AskUserQuestion: [Map/Capture context now (recommended) / Skip for now].

| Choice | Action |
|---|---|
| Map/Capture now | `load /nexus-map-context` passing mode (full/partial/capture) and project_type. On return: if mode was `full`, capture the returned draft payload (see F.1); otherwise continue to 1F.5 with no payload. |
| Skip for now | Note in project-state.md: `context_mapping_skipped: true`. Continue to 1G with no payload. |

#### F.1 — Draft Payload Capture (Full mode only)

When map-context was invoked in `full` mode, it returns a structured draft payload alongside the usual artifacts. The payload matches the format specified in `nexus-map-context/references/project-state-draft-generator.md [Section: Project-State-Draft-Generator]` — it may contain up to 10 fields derived from the codebase scan.

**Capture**: Store the returned payload in the wizard's working memory as `draft_payload`. The disk copy lives at `.nexus/supporting-files/project-context/PROJECT_DRAFT.md` (per map-context STEP 5A companion §F Rules 1–2 — disk is resume authority and matches the in-memory payload at handoff).

**Do NOT mutate** the in-memory `draft_payload` during the wizard. Per map-context STEP 5A companion §F Rule 3, if the user overrides a drafted value at any wizard step, the override goes into `project-state.md` directly, not back into the payload. The payload remains faithful to the scan output for audit purposes.

**If no draft_payload returned** (e.g., greenfield mode, map-context skipped, or scan yielded a graceful-fallback empty result): set `draft_payload = None` and proceed to 1F.5 — the transparency notice will be suppressed and all subsequent conditional reads will fall back to their existing behavior.

### F.5 Draft Transparency Notice (conditional)

Fires only if `draft_payload` is present and contains ≥1 drafted field. Pure transparency — no prompt, no user decision required. Suppresses entirely if no payload.

**Display**:

```
📋 Scanner drafted {N} of 10 possible fields from your codebase scan:
   • {field_1_label} ({confidence_tier})
   • {field_2_label} ({confidence_tier})
   • ...

These values will be presented as starting points at each wizard step —
you can override any of them. See .nexus/supporting-files/project-context/PROJECT_DRAFT.md
for the full draft with source citations.
```

Where `field_X_label` is a human-readable field name (e.g., "Project type category", "Technology stack", "Primary spec file"), not the raw YAML path. Confidence tier is the CERTAIN/HIGH/MEDIUM from the payload.

**If `draft_confidence: low`** in payload frontmatter: append a line:

```
ℹ️ Scan yielded minimal evidence — wizard will proceed with your input as primary source.
```

Then continue to 1G unconditionally.

### G. Project Domain

**Draft pre-population** (conditional — only if `draft_payload` from 1F.1 is present and has `PROJECT_DEFINITION.project_domain`):

Present the drafted value first with its source citation, then ask:

```
📋 From scan: "{draft_payload.PROJECT_DEFINITION.project_domain.value}" [inferred]
   Source: {draft_payload.PROJECT_DEFINITION.project_domain.source}

Use this, refine, or replace?
```

**STOP. Wait for user response.** Accept the drafted value, a refinement of it, or a complete replacement. User sovereignty is absolute — drafted value is a starting point, not a commitment.

**If no draft_payload or no project_domain in payload**, fall back to existing behavior:

"What's the specific domain within {type}? (e.g., Web App, Genomics, Market Analysis, Documentary)" **STOP. Wait for user response.**

### H. Key Resources

**Draft pre-population** (conditional — only if `draft_payload` is present and has any of `KEY_RESOURCES.specifications.main`, `.specifications.technical`, or `external_resources`):

Present the drafted values first with citations, then ask:

```
📋 From scan:
   Main spec: {draft_payload.KEY_RESOURCES.specifications.main.value} [inferred]
     (ranking rule matched: {source})
   Technical specs: {list from draft_payload.KEY_RESOURCES.specifications.technical.value} [inferred]
     (detected patterns: {source})
   External resources: {list from draft_payload.KEY_RESOURCES.external_resources.value} [inferred]
     (extracted from: {source})

Accept these, adjust, or add more? You can also add resources the scanner couldn't find (APIs, datasets, design systems, etc.).
```

**STOP. Wait for user response.** Handle partial payloads gracefully — emit only those lines where the corresponding sub-field has ≥1 value in the draft payload. Skip a line entirely if its sub-field is absent OR empty (e.g., `specifications.technical: []`). If ALL three sub-fields are absent or empty, fall back to existing behavior (no draft pre-population at all) — use the plain open-ended prompt below.

**If no draft_payload or no KEY_RESOURCES sub-fields in payload**, fall back to existing behavior:

"Do you have existing resources — APIs, datasets, design systems, specs? Provide paths/URLs or 'will create later'." **STOP. Wait for user response.**

### I. Novel Detection

If project type doesn't fit templates well or user describes unfamiliar territory, offer First Principles: invoke `/nexus-mental-models first-principles`.

### J. Progressive Write

**[T3: Full ask | Balanced: notify | Streamlined: silent]**

Patch `[PROJECT_DEFINITION]` with title, project_type, project_domain, brownfield (from 1A), context_mapping_skipped (from 1F, default false). Patch project-state metadata `_project_type`. Patch `[KEY_RESOURCES]`.

---

## STEP 2: Vision & Purpose

*Full mode: interactive. Assisted mode: covered by silent analysis (0D).*

The most important step. A clear vision anchors every decision that follows. When answers are vague or incomplete, load the **Questioning Technique Catalog** and apply its techniques: **Read** `.claude/skills/nexus-setup-project/references/questioning-catalog.md` **[Section: Questioning-Technique-Catalog]** (vague-answer path only; also used at STEP 3 Scope).

Use `Framing-Hints.vision_question` from the loaded template to frame the question in domain-native language:

| Type | Framing |
|---|---|
| Software | "What are we building, and what problem does it solve for users?" |
| Research | "What question are we trying to answer, and why does it matter?" |
| Problem solving | "What problem are we tackling, and what would success look like?" |
| Product design | "What experience are we creating, and for whom?" |
| Strategic | "What decision or direction are we trying to inform?" |
| Creative | "What are we creating, and what impact should it have?" |

Present the framing question. If documents were extracted (0B), present extracted vision first: "From your documents, I've captured: {extracted}. Does this capture it?" **STOP. Wait for user response.**

Guide to three required elements: **concrete outcome** (what), **purpose** (why), **observable success** (how we'd know).

**Validation** — push back based on wizard_depth (light: accept after brief check, thorough: push on each missing element):

| Gap | Push-back |
|---|---|
| Too vague | "When you say '{part}', what concrete outcome do you envision?" |
| Missing purpose | "This tells me what, but not why. What problem does this solve?" |
| No success criteria | "How would we know this succeeded? What would we observe?" |
| Too broad | "Could we narrow to what's essential? Broader aspirations become future deliverables." |

**STOP after each push-back. Wait for user response.**

**Synthesis reflection**: After the user provides their vision, reflect back a 1-sentence synthesis: "So we're building {X} because {Y}, and we'll know it works when {Z}. Does that capture it?" Use AskUserQuestion: [Yes, that captures it / Needs adjustment].

Accept thin answers after one round — flag for STEP 7 revisit. Derive `problem_domain` from the vision.

**[T3: Full ask | Balanced: notify | Streamlined: silent]** Patch `[PROJECT_DEFINITION]` — vision and problem_domain.

---

## STEP 3: Scope & Constraints

*Full mode: interactive. Assisted mode: covered by silent analysis (0D).*

Constraints first (they frame what's possible), then scope shaped by those constraints.

### A. Constraints

Use `Framing-Hints.constraint_emphasis` from template if available.

"What constraints are we working with?" Present each category, **STOP after presenting. Wait for user response.**

| Constraint | What to capture |
|---|---|
| Timeline | Hard deadlines, external dependencies, open-ended? If open-ended, note scope creep risk |
| Resources | Effort limits, budget, tool availability, team size |
| Technical | Platform, compatibility, must-use technologies, data availability |
| Methodological | Required approaches, ethics, reproducibility (research/analysis types) |

**Draft pre-population for Technical constraints** (conditional — only if `draft_payload` is present AND has any of `CONSTRAINTS_AND_RISKS.preliminary_technology.known_requirements` / `.integration_requirements` / `.platform_constraints`):

When presenting the Technical row, surface drafted values first with citations:

```
📋 From scan (Technical constraints pre-populated):
   Known requirements: {list from preliminary_technology.known_requirements.value} [inferred]
     (detected in: {source})
   Integration requirements: {list from preliminary_technology.integration_requirements.value} [inferred]
     (detected in: {source})
   Platform constraints: {list from preliminary_technology.platform_constraints.value} [inferred]
     (detected via: {source})

Accept these, adjust, or replace? Add any constraints the scanner couldn't detect
(team-specific requirements, future platform needs, compliance mandates, etc.).
```

Handle partial payloads gracefully — display only the sub-fields that are present. If `preliminary_technology` is fully absent from payload (non-code project, or scan found nothing), skip this block entirely and use existing open-ended prompt.

**If no draft_payload or no preliminary_technology in payload**, ask the Technical row as currently specified (open-ended).

For significant constraints, discuss implications: "A hard deadline of {date} with this scope means roughly {X} sprints — that's {tight/comfortable/generous}."

### B. Scope (shaped by constraints)

"Given these constraints, what's in and out?" Use `Framing-Hints.scope_emphasis` from template to frame what matters most. **STOP. Wait for user response.**

- **In scope**: Specific inclusions. Push for specificity: "user authentication" beats "security stuff."
- **Out of scope**: Explicit exclusions. LLM proposes likely exclusions based on type + domain + constraints: "Given your timeline, I'd suggest excluding {X} and {Y}. Agree?" If the user struggles: "What might someone assume is part of this that actually isn't?"
- **Boundaries**: Process or approach constraints.

If scope seems too broad relative to constraints: "This is a lot of ground for {timeline/resources}. The core scope seems to be {assessment}. Move some items to enhanced deliverables?"

### C. Constitution (optional)

"Any non-negotiable principles — things that must always be true? Most projects don't need these." Use AskUserQuestion: [No constitution needed / Yes, I have principles].

If yes: capture with name, rationale, and enforcement points. **STOP. Wait for user response.**

### D. Scope Negation ("I do not...")

**Activation**: read `scope_negation` from session memory (set at STEP 1E by §Architect-Pattern Activation).

| Activation | Behavior |
|---|---|
| Full | Sub-step always runs — wizard prompts for negations and writes them. |
| Light | Wizard explains the sub-step and offers an explicit skip via AskUserQuestion: [Capture negations / Skip negations]. On capture, proceed as Full; on skip, leave `negations: []`. |
| Skip | Sub-step does not fire. `negations` remains `[]`. Move on to the progressive write. |

If activation is **Full** or the user opts in at **Light**:

> Beyond what's in scope, we want to state what this project is explicitly NOT responsible for. This makes the project boundary crisp for downstream work — generate-mvp, future issue creation, and phase handoffs all consume this list to decide when out-of-scope work escalates as a new proposal rather than expanding the current project silently.
>
> What are 3–5 things this project is NOT responsible for?
>
> Examples by project type:
> - software-product-dev: "not responsible for mobile app", "not responsible for SOC 2 compliance"
> - migration-transition: "not responsible for feature parity beyond MVP column", "not responsible for data cleanup pre-migration"
> - compliance-audit: "not responsible for remediation execution — findings only"
> - system-integration: "not responsible for source system changes — integration layer only"
> - product-design: "not responsible for engineering implementation — handoff at spec"
> - operations-process: "not responsible for headcount decisions — process redesign only"

**STOP. Wait for user response.**

**Negations vs out_of_scope**: These are distinct semantic surfaces and *both* fields are retained. `out_of_scope` is *features the project does not deliver* (the boundary of what is built). `negations` is *responsibilities the project disclaims* ("I do not..."). A project might exclude a feature from scope while still being responsible for handing off the boundary to another team — and vice versa. The wizard prompts each via a distinct sub-step (STEP 3.B for `out_of_scope`, STEP 3.D for `negations`).

**Thin answers**: Accept gracefully after one round per general Wizard Principles guidance. If the list ends up empty after the prompt, log internally "Scope negation declined or not applicable" and proceed — empty `negations: []` is legal.

**Write**: append to project-state `[SCOPE_AND_BOUNDARIES].negations` (list of strings). The progressive write below patches this along with the rest of `[SCOPE_AND_BOUNDARIES]`.

**[T3: Full ask | Balanced: notify | Streamlined: silent]** Patch `[SCOPE_AND_BOUNDARIES]` (in_scope, out_of_scope, boundaries, negations), `[CONSTRAINTS_AND_RISKS]` (constraints only, risks in STEP 6), `[PROJECT_CONSTITUTION]` if applicable.

---

## STEP 4: Deliverables & Success Thresholds

*Full mode: interactive. Assisted mode: covered by silent analysis (0D).*

The LLM proposes first, the user validates.

### A. Propose from Template

Load `Deliverable-Templates` from project-type template. Combined with vision + scope + constraints, propose deliverables adapted to this project:

"Based on your {type} project about {domain}, typical deliverables include: {proposed list}. Which apply? What would you add or remove?" **STOP. Wait for user response.**

### B. Categorize Together

Work with the user to sort into three tiers:
- **MVP**: Must-have for first valuable version. Drive initial sprints.
- **Enhanced**: Notable value but not essential for first release.
- **Future**: Aspirational goals that inform architecture but don't drive immediate work.

Use template's Categorization Guidance if available. Present proposed categorization. **STOP. Wait for user response.**

### C. Quality Criteria

Two levels:
- **Per-deliverable**: LLM proposes from template: "For {deliverable}, I'd suggest: {proposed criteria}. Adjust?"
- **Overall acceptance criteria**: Project-wide quality bar.

**STOP. Wait for user response.**

### D. Success Constraints

Now that deliverables are concrete, define what "enough" means:

| Constraint | Question |
|---|---|
| MVP Minimum | "Looking at these MVP deliverables — what's the absolute minimum subset that would be valuable?" |
| Sufficiency Threshold | "Where do diminishing returns start? What's 'good enough'?" |
| Completion Criteria | "When do we declare done? What conditions must be met?" |

**STOP. Wait for user response.**

If skipped: "These help us know when we've done enough. Without them, projects tend to either under-deliver or never finish. Even rough answers help."

### E. Priority Pressure Test

"If you could only deliver {ceil(N/2)} of {N} MVP items, which ones?" Use AskUserQuestion with multiSelect if useful. Accept "all of them" after one push.

**Validate**:
- Minimum one MVP deliverable with criteria
- Cross-check against vision — flag disconnects: "I notice {deliverable} doesn't connect to the vision. Essential, or move to enhanced?"
- If too granular: "A deliverable is what you'd show someone — 'working authentication system' rather than 'set up database.' Restructure?"

### F. Handoff Contracts Between Deliverables

**Note on handoff-contract levels**: This is a **project-level** handoff contract (between deliverables in project-state, typically spanning conversations/sprints). The project-level vs agent-level distinction is canonical in the section below.

[Section: Handoff-Contract-Levels]
Agent-level handoff contracts (between sub-agents dispatched via the Agent tool, per agent-template v1.1.0) use the same PAYLOAD/SUCCESS/FAILURE/ON-FAILURE schema as project-level contracts, but TIMEOUT at agent level is aspirational only (NEXUS sub-agent dispatch is synchronous). At project level, TIMEOUT is first-class: an upstream phase or deliverable exceeding its time budget has real downstream consequences — phase delay, scope renegotiation, or handoff renegotiation with the receiving entity. *(Forward-pointing reference: the matching agent-template wiring lands at ISS-165.)*
[/Section: Handoff-Contract-Levels]

**Activation**: read `handoff_contracts` from session memory (set at STEP 1E by §Architect-Pattern Activation).

| Activation | Behavior |
|---|---|
| Full | Sub-step always runs for every deliverable pair where A feeds B. |
| Light | Sub-step is offered via AskUserQuestion: [Declare handoff contracts / Skip handoff contracts]. On capture, proceed as Full; on skip, leave `handoff_to: []` on each deliverable. |
| Skip | Sub-step does not fire. `handoff_to` remains `[]` on all deliverables. |

If activation is **Full** or the user opts in at **Light**:

**Identify deliverable pairs**: For each ordered pair (A, B) in `mvp_deliverables ∪ enhanced_deliverables` where Deliverable A's output is consumed by Deliverable B (typically: A is in an earlier `target_phase` than B, OR A's `quality_criteria` describes an artifact that B's description references), propose a handoff contract.

> Deliverable A ({name}) feeds Deliverable B ({name}). What's the handoff contract?
>
> - **PAYLOAD**: what A produces for B (artifact path, structured data shape, user-facing output)
> - **SUCCESS**: conditions under which B can consume A's output
> - **FAILURE**: what A does if it cannot produce the expected payload — escalate, partial delivery, or defer
> - **TIMEOUT**: what happens if A runs long — partial payload, rollback, or stop

**Collaborative mode**: propose likely handoff contracts based on project type, deliverable names, and `quality_criteria`. User confirms or adjusts. **Do not force a handoff contract where deliverables are genuinely independent** — only prompt for pairs that actually feed each other. If the user says no pair feeds another, accept and leave `handoff_to: []` on all deliverables.

**STOP. Wait for user response** for each pair surfaced.

**Write**: per-deliverable `handoff_to:` list. Each entry references the downstream deliverable by its `name:` field (Option β — no separate `id:` field on deliverables, the `name` is the implicit key):

```yaml
mvp_deliverables:
  - name: "Data Model"
    # ...
    handoff_to:
      - target: "CRUD UI"
        payload: "data schema spec + migration scripts"
        success: "schema validates and migrations apply cleanly to a fresh DB"
        failure: "escalate as ISS — block downstream UI build"
        timeout: "deliver partial schema with documented gaps; renegotiate UI scope"
```

If two deliverables share the same `name` (collision), surface to user and ask for disambiguation (typically by renaming the more-recent deliverable). The schema deliberately reuses `name` rather than introducing a separate identifier — collisions are caught at write time, not at handoff resolution.

**[T3: Full ask | Balanced: notify | Streamlined: silent]** Patch `[DELIVERABLES]` with full structure per deliverable: name, description, quality_criteria, target_phase, empty issue_refs, handoff_to (populated when this sub-step fires, otherwise `[]`). Set overall acceptance_criteria. Patch `[SCOPE_AND_BOUNDARIES]` success_constraints.

---

## STEP 5: Phases & Effort

*Full mode: interactive. Assisted mode: covered by silent analysis (0D).*

Template-driven phase planning with scope-effort calibration.

### A. Assess Project Complexity

Simple (2-3 deliverables, familiar domain), Standard (moderate scope, some uncertainty), Complex (novel domain, many deliverables, significant research). Cross-reference with `wizard_depth` from template Profile. If they diverge, use the higher.

### B. Propose from Template

Load `Phase-Templates` from the project-type template for matching complexity. Use domain-native naming — the project's natural language, not generic software terminology.

A documentary doesn't have "Foundation" and "Implementation" — it has Concept Development → Research → Pre-Production → Production → Post-Production. A research project has Literature Review → Methodology Design → Data Collection → Analysis → Writing.

If no template loaded, propose from domain knowledge: Simple (2-3 phases), Standard (3-4), Complex (5-6).

### C. Allocate Deliverables to Phases

Map each deliverable to a phase. MVP to earlier phases, enhanced to middle/later, future noted but not allocated.

### D. Workflow-Tree Articulation

**Activation**: read `workflow_tree` from session memory (set at STEP 1E by §Architect-Pattern Activation).

| Activation | Behavior |
|---|---|
| Full | Sub-step always runs — entry/exit/depends_on captured for every phase. |
| Light | Sub-step offered via AskUserQuestion: [Articulate workflow tree / Skip workflow tree]. On capture, proceed as Full; on skip, leave `entry_criteria: []`, `exit_criteria: []`, `depends_on: []` on every phase. |
| Skip | Sub-step does not fire. The three fields remain `[]` on every phase. |

If activation is **Full** or the user opts in at **Light**:

**For each phase in the allocation above, capture three fields**:

| Field | Meaning | Example (software-product-dev Build phase) |
|---|---|---|
| `entry_criteria` | What must be true before this phase starts | "Analysis complete; success criteria approved per issue; deliverable scope locked" |
| `exit_criteria` | What must be true to advance to the next phase | "All MVP issues Resolved; user acceptance documented per issue; evaluation scores ≥4" |
| `depends_on` | List of upstream phase ids that must complete first | `[analysis]` for Build; `[]` for Phase 1 |

**Propose defaults by project type** (use these to pre-fill the wizard, then ask for adjustments):

| Project Type | Default phase sequence | Default dependency graph |
|---|---|---|
| software-product-dev | Discovery → Build → Validate → Ship | Linear |
| migration-transition | Inventory → Map → Migrate → Cutover → Decom | Linear with validate gates |
| compliance-audit | Scope → Evidence → Findings → Remediation Plan | Linear |
| system-integration | Survey → Contract → Implement → Verify | Linear |
| research-analysis | Scoping → Investigation → Analysis → Deliverable | Usually linear, may branch |
| creative-content | Brief → Draft → Refine → Publish | Linear |
| complex-problem-solving | Frame → Decompose → Solve → Integrate | May branch at Decompose |

For project types not in this table, propose a reasonable default from the loaded `Phase-Templates` and let the user adjust.

**Wizard prompt**:

> Based on your {project_type} project and the {N} phases we just laid out, I propose these entry/exit criteria and dependency edges:
>
> {per-phase block showing proposed entry_criteria, exit_criteria, depends_on}
>
> Adjust?

**STOP. Wait for user response.**

**Write**: project-state `[PROJECT_PHASES].{phase-id}.entry_criteria` / `.exit_criteria` / `.depends_on` per phase. The progressive write below patches this along with the rest of `[PROJECT_PHASES]`.

```yaml
phase_1:
  name: "Phase 1: Discovery"
  # ... existing fields ...
  entry_criteria:
    - "Project setup complete"
    - "Stakeholder alignment documented"
  exit_criteria:
    - "All MVP issues analyzed (scores A:≥4)"
    - "Success criteria locked per issue"
  depends_on: []
```

**Cycle detection**: After capture, before writing, walk the `depends_on` graph to confirm no cycles. If a cycle is detected: surface immediately and ask the user to resolve by removing one edge. Do not proceed to the progressive write until the graph is acyclic.

### E. Scope-Effort Calibration

Calculate total estimated effort from deliverable complexities and phase count. Compare to timeline from STEP 3.

- If fits: "Your scope and timeline align — ~{X} sprints, you have ~{Y} available."
- If too tight: "These deliverables estimate ~{X} sprints but your timeline implies ~{Y}. Options: reduce MVP scope, simplify deliverables, extend timeline, or accept the risk."
- If very loose: "You have more time than needed. Consider deeper analysis phases or additional deliverables."

Use ~9 complexity points per sprint as rough guide.

```
📊 PHASE ANALYSIS
════════════════════════════════════════
Project Type: {type} | Complexity: {assessment}
MVP Deliverables: {count} | Domain: {domain}

RECOMMENDED: {N}-Phase Structure
{For each: name, objective, allocated deliverables, estimated sprints}
════════════════════════════════════════
```

### F. User Accepts

**[T2: Balanced+Full ask | Streamlined: auto-accept, notify+log]**

Use AskUserQuestion: [Accept as proposed / Customize phases / Different structure entirely].

If customizing: work iteratively. If choosing different structure: collaborate from scratch.

**[T3: Full ask | Balanced: notify | Streamlined: silent]** Patch `[PROJECT_PHASES]` with full structure per phase: name, objective, allocated deliverables, milestone, status ("Planned"), completion ("0%"), estimated_sprints, entry_criteria, exit_criteria, depends_on (the last three populated when §D Workflow-Tree Articulation fires, otherwise `[]`).

---

## STEP 6: Risks & Validation

*Full mode: interactive. Assisted mode: covered by silent analysis (0D).*

Quality gate — everything gets validated before final review.

### A. Risks

Load `Risk-Catalog` from the project-type template if available. Combined with conversation context:

"For {type} projects, common risks include: {from template}. Given your specific scope, I'd also flag: {context-specific risks}. Which apply? What else concerns you?" **STOP. Wait for user response.**

For each identified risk, use Socratic questioning: "How likely? What evidence?" / "If it happens — delay, degraded quality, or failure?" / "'Be careful' isn't a mitigation — what specifically?"

Structure each: description, probability (Low/Medium/High), impact (Low/Medium/High), concrete mitigation.

Scale depth to `wizard_depth`: light → 2-3 risks, standard → 3-4, thorough → 5+ with Socratic depth.

### B. Metrics

Use template `Metrics` section. Combined with vision + deliverables:

"Based on your vision and deliverables, I'd suggest tracking:
Quantitative: {2-3 proposed}
Qualitative: {2-3 proposed}
Milestones: {tied to phases}
Adjust?" **STOP. Wait for user response.**

Push back on vague metrics: "'Make it good' isn't measurable. Perhaps {specific suggestion}?"

### C. Stakeholders

Use AskUserQuestion: "Are you the sole user and decision maker?" Options: [Solo — just me / Team — others involved].

If team: brief capture of who and how feedback flows. **STOP. Wait for user response.** Not a full stakeholder analysis.

### D. Cross-Step Coherence Check

Silently validate, then report findings:

| Check | What to verify |
|---|---|
| Vision → Deliverables | Every MVP deliverable connects to vision? Anything in vision not served? |
| Deliverables → Phases | All allocated? Dependencies make sense? |
| Constraints → Scope | Effort fits timeline? Out-of-scope items truly excluded? |
| Scope → Risks | Biggest risks mitigated? Any constraint that should be a risk? |
| Success constraints → Deliverables | MVP minimum aligns with actual MVP deliverables? |

Flag any misalignment explicitly: "I notice {issue}. Should we adjust?" Offer to return to the relevant step.

### E. Elevator Pitch

"Here's your project in two sentences: {synthesis}. Does this feel right?" A wrong-feeling pitch surfaces subtle misalignment that individual checks miss. **STOP. Wait for user response.**

**[T3: Full ask | Balanced: notify | Streamlined: silent]** Patch `[CONSTRAINTS_AND_RISKS]` (risks + dependencies), `[SUCCESS_METRICS]`, `[STAKEHOLDERS]`.

---

## STEP 7: Review & Finalize

*All modes arrive here. In Assisted mode, this is the primary interaction surface.*

### A. Read from Disk

Read full project-state.md from file (not memory) to verify all progressive patches applied correctly.

### B. Present Complete Summary

```
📋 PROJECT DEFINITION REVIEW
════════════════════════════════════════

📂 {project_name} {source_marker}
   Type: {project_type} {source_marker} | Domain: {project_domain} {source_marker}

🎯 VISION: {source_marker}
{vision — all 3 elements}

📦 SCOPE: {source_marker}
In: {in_scope items}
Out: {out_of_scope items}
Success Constraints:
  Minimum: {mvp_minimum}
  Enough: {sufficiency_threshold}
  Done: {completion_criteria}

🎁 DELIVERABLES: {source_marker}
MVP ({count}): {list with per-deliverable criteria}
Enhanced ({count}): {list}
Future ({count}): {list}
Acceptance: {overall acceptance criteria}

📅 PHASES ({N} phases, ~{total} sprints): {source_marker}
{For each: name, objective, deliverables, sprint estimate}

⚠️ RISKS ({count}): {source_marker}
{Top risks with probability/impact/mitigation}

📊 METRICS: {source_marker}
{Quantitative + Qualitative + Milestones}

📚 RESOURCES: {key resources}
👥 STAKEHOLDERS: {summary}

🗣️ ELEVATOR PITCH:
{2-sentence synthesis}

════════════════════════════════════════
```

**Source markers** (Assisted mode only):
- `[inferred]` — Extracted from user input or documents
- `[default]` — Applied from template/type/domain knowledge
- `[needs input]` — Could not determine, requires user input

In Full mode: no source markers needed (user provided everything interactively).

### C. Highlight Gaps

Flag thin sections and `[needs input]` fields. "These need attention: {list}. Fill now or accept as-is?"

### D. Name Revisit

With the full project defined, reconsider the title. If a better name suggests itself: "Now that I see the full picture, you might consider '{alternative}' which reflects {reasoning}. Prefer the original or the new name?"

### E. User Decision

**[T2: Balanced+Full ask | Streamlined: auto-accept if no gaps, notify+log; ask if gaps remain]**

Use AskUserQuestion:

| Mode | Options |
|---|---|
| Full | [Accept as-is / Modify sections / Accept with name change] |
| Assisted (no gaps) | [Accept all / Modify sections / Full wizard (start over interactively)] |
| Assisted (with gaps) | [Fill gaps ({N} fields) / Accept with gaps / Modify sections / Full wizard] |

**"Fill gaps"**: Jump only to steps with `[needs input]` fields — skip everything already captured. After filling, return here.

**"Modify sections"**: Ask which section, jump to relevant step interactively, return here.

### F. Finalize

**[T1: all levels ask]** "This will finalize the project definition, write to project-state.md, and set project lifecycle to active. Proceed?"

On approval:

1. Patch project name if changed.
2. Clean runtime sections:
   - `[PROGRESS_OVERVIEW]`: current_sprint: "Not started", counters to 0, empty arrays.
   - `[CRITICAL_DECISIONS]`: Clear placeholders, empty lists.
   - `[MILESTONE_TRACKING]`: Clear placeholders.
   - `[NEXT_PHASE_NOTES]`: immediate_priorities: ["Begin Phase 1: {first_phase_name}"], others empty.
3. Update metadata: _project_status: "Planning", _current_phase: "Phase 1: {name}", _completion_percentage: "0%", _health_status: "Green", _updated: current timestamp.
4. Patch `.nexus/active/states/sprint-state.md`:
   - Set `_project_lifecycle: active`
   - Populate `[PROJECT_BRIEF]` with condensed project context:
     - `title`: project name
     - `type`: project_type
     - `domain`: project_domain
     - `vision`: condensed 1-2 sentence vision (what + why + success)
     - `current_phase`: "Phase 1: {first_phase_name} — {objective}"
     - `constitution`: principles from [PROJECT_CONSTITUTION] (empty if none)
     - `mvp_minimum`: from success_constraints.mvp_minimum
     - `active_risks`: High probability + High impact risks only (empty if none)
   This brief ensures every conversation has project context without loading project-state.
5. Verify: Read project-state.md from disk. Scan for remaining placeholder text. Flag any found.
6. **PROJECT_DRAFT.md consumed-at metadata** (conditional — only if PROJECT_DRAFT.md exists and was used during this wizard run): Append `draft_consumed_at: {current ISO timestamp}` to PROJECT_DRAFT.md frontmatter via a single targeted Edit. Do NOT modify any other content in PROJECT_DRAFT.md — per map-context STEP 5A companion §F Rule 4, the disk artifact is an immutable audit record except for this one metadata field. This flag is what distinguishes "draft consumed" from "draft pending review" on future resume detection (STEP 0A).

   Exact patch anchor: locate the `---` closing fence of the frontmatter block, insert `draft_consumed_at: {ISO timestamp}` on a new line before the closing `---`. If the frontmatter already contains `draft_consumed_at` (unusual — implies re-consumption): update it in place rather than duplicating.

```
✅ PROJECT CREATED
════════════════════════════════════════
Project: {project_name}
Type: {project_type} | Domain: {project_domain}
Location: .nexus/active/states/project-state.md
Status: Planning | Phase 1: {phase_name}
Phases: {N} | MVP Deliverables: {N}
════════════════════════════════════════
```

### G. Next Steps

**[T2: Balanced+Full ask | Streamlined: auto-select based on context (<60% → generate, >60% → done), notify+log]**

Use AskUserQuestion: [Generate MVP issues from deliverables (recommended) / Done for now].

If "Generate MVP issues": `load /nexus-generate-mvp`

If "Done": Make a final checkpoint. Show: "Project ready. Use 'generate mvp issues' when you're ready."

---

## Gate Reference

| Gate | Step | Tier | Full | Balanced | Streamlined |
|---|---|---|---|---|---|
| Overwrite existing project | 0A | **T1** | Ask + backup | Ask + backup | Ask + backup |
| Phase structure acceptance | 5F | **T2** | Ask | Ask | Auto-accept, notify+log |
| Review decision | 7E | **T2** | Ask | Ask | Auto-accept if no gaps, notify+log |
| Finalize & activate | 7F | **T1** | Ask | Ask | Ask |
| Next steps | 7G | **T2** | Ask | Ask | Auto-select by context %, notify+log |
| Progressive writes (×6) | After 1-6 | **T3** | Ask | Notify | Silent |

---

## End-of-Workflow Checklist

Before STEP 7G (next steps), verify:

- [ ] project-state.md fully populated — no template placeholders remaining
- [ ] Runtime sections cleaned (PROGRESS_OVERVIEW, CRITICAL_DECISIONS, MILESTONE_TRACKING, NEXT_PHASE_NOTES)
- [ ] Metadata set: _project_status, _current_phase, _completion_percentage, _health_status, _updated
- [ ] `_project_type` set in project-state metadata
- [ ] sprint-state `_project_lifecycle` set to `active`
- [ ] Both files verified on disk after writing
- [ ] If creative/mixed: `.nexus/backups/` exists and in `.gitignore`

---

## Error Recovery

| Problem | Recovery |
|---|---|
| project-state-template.md missing | Alert user. Suggest /nexus-init-project to create directory structure, or manual restoration from git. Cannot proceed without template. |
| Type template not found | Use project-type-template.md as structural reference + domain knowledge. Inform user. |
| project-state.md corrupt on resume | Check git history for last good version. Offer restore or fresh start. |
| Progressive write fails mid-wizard | Retry the patch. If still fails: note which section, continue wizard, retry at STEP 7F finalize. |
| Checkpoint fires mid-wizard | project-state.md already has progress through current step. Note in sprint-state continue_with: "Resume setup-project wizard at STEP {N}." STEP 0A detects partial state on next conversation. |
| Context mapping fails (STEP 1F) | Note: "Context mapping unavailable. Continue without — you can run 'map project context' later." Set context_mapping_skipped: true. |
| Document extraction unclear | Mark ambiguous fields as `[needs input]`. User resolves at STEP 7 review. |

---

## Update Mode

Edit any project parameter — vision, scope, deliverables, phases, constraints, resources, stakeholders — with impact analysis on affected issues and cascade updates to the registry. Entered from STEP 0A when project-state.md is fully populated and the user declines overwrite, or invoked directly via "update project parameters" / "modify project scope".

> 📂 **Externalized — load on entry.** Update Mode's full execution flow (STEP U.0–U.5, Update Mode Gates, Update Mode Error Recovery) lives in a companion file to keep this skill lean. When Update Mode is dispatched — from STEP 0A (project-state fully populated, user declines overwrite) or a direct "update project parameters" / "modify project scope" invocation — load it now and execute from STEP U.0 onward:
> **Read** `.claude/skills/nexus-setup-project/references/update-mode.md` **[Section: Update-Mode]**
