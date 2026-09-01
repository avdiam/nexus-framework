# Project-State Draft Generation — map-context STEP 5A companion
*Version: 1.0.0 | Date: 2026-06-14 | Sprint: 104*

Externalized from `nexus-map-context/SKILL.md` STEP 5A (ISS-215, stub-in-place externalization). Lazy-loaded in **Full mode only**. This is the canonical section-scoped load target of map-context STEP 5A and the `nexus-setup-project` STEP 0A draft pointer — both resolve the `[Section: Project-State-Draft-Generator]` anchor below.

[Section: Project-State-Draft-Generator]

**Triggers only in Full mode (brownfield scan)**. Partial and Capture modes skip this step entirely and proceed to STEP 5B.

After STEPs 1-4 have gathered scan findings (file inventory, config files, dependency lists, README and alternatives, CONCERNS.md classified), transform those findings into a structured draft payload covering 10 project-state fields. The draft is persisted as `PROJECT_DRAFT.md` AND returned in-memory to the caller (typically /nexus-setup-project). The draft is NOT a final project-state content — it's a starting point for the setup-project wizard, to be reviewed and enriched by the user.

**Philosophy**: Lean + conditional + confidence-tiered. Only emit fields with high-confidence derivation from structured or prose evidence. Suppress everything else rather than stub. Every drafted value wears an `[inferred]` source marker (except CERTAIN values which are facts known from the scan itself).

### A. Inputs (from STEPs 1-4, already in memory)

- File inventory from STEP 2: extensions, counts, directory tree
- Config files read during STEPs 1-3: package.json, pyproject.toml, Cargo.toml, go.mod, Gemfile, tsconfig.json, environment.yml, etc.
- Dependency lists extracted from those config files
- Top-level documentation read during STEP 1: README and alternatives (see fallback chain in §D)
- CONCERNS.md content from STEP 4 (already classified)
- Type parameter (passed from setup-project or detected from scan)

### B. Confidence tiers

| Tier | Meaning | Marker |
|---|---|---|
| **CERTAIN** | Fact known from the scan itself, not inference (e.g., "this is a brownfield scan") | No marker — value is authoritative |
| **HIGH** | Direct extraction from structured source with minimal interpretation | `[inferred]` |
| **MEDIUM** | Requires interpretation or pattern-matching | `[inferred]` — always emit with citation |
| **LOW** | NOT ATTEMPTED in this version — field is suppressed | (absent from draft) |

**Suppression rule**: If a field's derivation rule cannot find sufficient evidence, the field is **absent from the draft payload**. Do not emit stub values or `[needs input]` placeholders here — those are setup-project's responsibility.

### C. Tier 1 — Explicit Derivation Table (8 structured-evidence fields)

For each row: if the source inputs yield evidence matching the derivation rule, emit the field with the specified confidence tier. Otherwise suppress. The **Type applicability** column gates fields that only make sense for specific `_project_type` values.

| # | Field | Source inputs | Derivation rule | Confidence | Output format | Type applicability |
|---|---|---|---|---|---|---|
| 1 | `_project_type` | File extension inventory from STEP 2 | Count files by extension into three buckets: **Code** — `.md .py .js .ts .tsx .jsx .go .rs .java .kt .rb .php .c .cpp .h .hpp .yaml .yml .json .toml .sh .ps1 .ipynb .tex .bib .R .Rmd .qmd`. **Creative** — `.docx .pptx .xlsx .pdf .jpg .jpeg .png .gif .svg .mp4 .mp3 .mov .blend .psd .afphoto .ai .prproj .fcpxml .drp`. **Data** — `.csv .tsv .parquet .arrow .jsonl .sqlite .db .h5 .hdf5` (counted separately — data files alone are neither code nor creative deliverables). **Decision**: Whichever non-data bucket has the higher ratio wins, with threshold ≥70% required to resolve as pure code or creative. If code > creative but code < 70% of non-data files, OR if creative > code but creative < 60% of non-data files, OR if data files exceed 40% of total → **Mixed**. If no files detected at all → suppress entire draft (fallback to greenfield behavior). | CERTAIN | `code` / `creative` / `mixed` | All |
| 2 | `[PROJECT_DEFINITION].brownfield` | Scan mode parameter | Always `true` when this step runs (§5A executes only in Full mode). | CERTAIN | `true` | All |
| 3 | `[CONSTRAINTS_AND_RISKS].preliminary_technology.known_requirements` | **Primary**: `package.json engines`, `pyproject.toml [project.requires-python]`, `go.mod go` directive, `Cargo.toml rust-version`, `Gemfile ruby`, `.nvmrc`, `.python-version`, `.tool-versions`, `tsconfig.json compilerOptions.target`. **Secondary**: shebang lines in top-level scripts (`#!/bin/bash`, `#!/usr/bin/env python3`, `#!/usr/bin/env node`), presence of `Makefile` / `build.sh` / `justfile` / `Taskfile.yml`, detected framework imports. | Extract declared language + runtime versions. Format each as `"{Language} {operator}{version}"` (e.g., `"Python ≥3.11"`, `"Node.js ≥20.x"`) when primary evidence is found. When ONLY secondary evidence is found, format as `"{language} detected via {evidence}"` (e.g., `"Bash shell scripts detected in hooks"`). Emit if ≥1 entry found. | HIGH (primary) or MEDIUM (secondary-only) | List of strings | Code only — suppress entirely for `creative`; suppress for `mixed` unless code signals are significant |
| 4 | `[CONSTRAINTS_AND_RISKS].preliminary_technology.integration_requirements` | Dependency lists from config files + detected imports in top-level source | Framework/library list limited to significant entries: major frameworks (React, Vue, Angular, Svelte, Django, Flask, FastAPI, Rails, Express, Next.js, Nuxt, Spring, Laravel, etc.), major SDK integrations detected in imports (database clients, HTTP clients, cloud SDKs, ML frameworks). Filter out transitive dependency noise — include only deps appearing at top level of manifests. | HIGH | List of strings | Code only |
| 5 | `[CONSTRAINTS_AND_RISKS].preliminary_technology.platform_constraints` | `Dockerfile`, `docker-compose.yml`, CI config files (`.github/workflows/`, `.gitlab-ci.yml`, `.circleci/config.yml`), OS-specific dependencies in manifests, engine constraints, shebang lines in hook/build scripts | Emit ONLY IF explicit platform signal detected. Format: `"Must run in Docker (Dockerfile present)"`, `"Linux-only (detected via {evidence})"`, `"Unix-like shell required for hook scripts in {paths}"`, `"CI targets: {OS list}"`. | MEDIUM | List of strings | Code only — emit only if ≥1 platform signal |
| 6 | `[KEY_RESOURCES].specifications.main` | File existence check + type-adapted ranking | **Type-adapted ranking** (first match wins): **Code**: `README.md` > `CLAUDE.md` > `AGENTS.md` > `ARCHITECTURE.md` > `docs/README.md` > `docs/index.md` > `SPEC.md`. **Research**: `METHODOLOGY.md` > `PROTOCOL.md` > `README.md` > `docs/methodology.md` > `docs/README.md`. **Creative**: `BRIEF.md` > `CREATIVE-BRIEF.md` > `PITCH.md` > `README.md`. **Business**: `STRATEGY.md` > `PLAN.md` > `BUSINESS-PLAN.md` > `README.md`. **Fallback**: any top-level `*.md` file whose first H1 heading contains 2+ words matching the project directory name. | HIGH | String (file path) | All — ranking varies by type |
| 7 | `[KEY_RESOURCES].specifications.technical` | Existence check for type-adapted patterns | **Code**: API specs (`openapi.yaml`, `swagger.json`, `*.proto`, `*.graphql`, `schema.graphql`), data schemas (`*schema*.{json,yaml,sql}`, `models.py`), architecture docs (`ARCHITECTURE.md`, `docs/architecture*.md`). **Research**: methodology docs, data-dictionary files, analysis plans, notebook templates. **Creative**: `brand/` directory (emit as `"brand/ (asset directory)"`), `style-guide.md`, `voice-and-tone.md`, `editorial-standards.md`. **Business**: market research docs, competitive analyses, strategy docs. Directory paths are valid outputs for asset-oriented types; suffix with `" (directory)"` to distinguish. List must be non-empty to emit. | HIGH | List of strings (file or directory paths) | All — patterns vary by type |
| 8 | `[KEY_RESOURCES].external_resources` | URLs extracted from: `package.json` (`homepage`, `repository.url`, `bugs.url`), top-level README markdown links (`[text](URL)`), `.env.example` service URLs, CI config webhook URLs | Unique list of external URLs. Exclude: `localhost`, `127.0.0.1`, `example.com`, `github.com/username/repo` (project's own repo unless explicitly relevant), relative links, and mailto: links. | MEDIUM | List of strings (URLs) | All — emit if ≥1 URL after filtering |

### D. Tier 2 — Principled LLM Judgment (2 prose-evidence fields)

These fields derive from natural-language content (README first paragraphs, project-level description prose). Use semantic judgment with a **mandatory citation format** — every drafted value must include the exact source text from which it was derived.

**README fallback chain** — use for both Tier 2 fields when `README.md` is missing. Check in order; first match is the primary evidence file:

1. `README.md` at project root (primary)
2. `CLAUDE.md` at project root (NEXUS-managed framework config)
3. `AGENTS.md` at project root (alternative agent config)
4. `DESCRIPTION.md` at project root
5. `BRIEF.md` / `CREATIVE-BRIEF.md` / `PITCH.md` at project root (creative projects)
6. `docs/README.md` or `docs/overview.md`
7. Any top-level `*.md` file whose first H1 heading contains 2+ words matching the project directory name

If none of the above exists: suppress both Tier 2 fields.

#### Field 9 — `[PROJECT_DEFINITION].project_type` (category)

**Goal**: Pick the best-match project type from the 13 NEXUS project types based on evidence.

**Process**:
1. Read the first 50 lines of the primary evidence file (from fallback chain)
2. Combine with detected tech/domain cues from STEP 1-3 findings (dependency patterns, file patterns)
3. Match against: `Software/Product Dev`, `Research & Analysis`, `Complex Problem Solving`, `Product Design`, `System Integration`, `Data & Analytics`, `Strategic/Business Planning`, `Educational/Training`, `Creative/Content`, `Operations/Process Improvement`, `Event/Campaign Management`, `Compliance/Audit`, `Migration/Transition`
4. Pick one best match. If ambiguous, prefer the category with strongest tech/file-pattern evidence

**Output format (mandatory — must include `source:` with exact quote)**:

```yaml
project_type:
  value: "{category from the 13}"
  confidence: MEDIUM
  marker: "[inferred]"
  source: "{exact quote from primary file, ≤2 lines} + {tech evidence summary}"
```

#### Field 10 — `[PROJECT_DEFINITION].project_domain`

**Goal**: Specific domain description within the project_type. Must be specific: avoid generic terms like "Software", "Application", "Project". Target 3-8 words that distinctively characterize what the project is.

**Process**:
1. Read the first paragraph of the primary evidence file
2. Summarize the specific domain in 3-8 words
3. Examples of good vs bad:
   - Good: `"Real-time collaborative editor"`, `"Genomic variant analysis pipeline"`, `"LLM behavioral programming framework"`
   - Bad: `"Software project"`, `"A web app"`, `"Tool for developers"`

**Output format (mandatory — must include `source:` with exact quote)**:

```yaml
project_domain:
  value: "{specific 3-8 word description}"
  confidence: MEDIUM
  marker: "[inferred]"
  source: "{exact quote from primary file — the sentence or phrase that justifies the description}"
```

### E. PROJECT_DRAFT.md Format Spec

Write the draft to `.nexus/supporting-files/project-context/PROJECT_DRAFT.md`.

**Full format**:

```markdown
# PROJECT_DRAFT.md
*Project: {project_name} | Type hint: {project_type_hint} | Scanned: {YYYY-MM-DD HH:MM} | Mode: full*
*5th context artifact — structured draft payload for setup-project wizard pre-population.*
*Consumed by: /nexus-setup-project STEPs 1E, 1F.5, 1G, 1H, 3A*

---
draft_version: 1
draft_confidence: {high|medium|low}
project_type_hint: "{best-guess category for tracking}"
scanned_at: {YYYY-MM-DD HH:MM}
scan_mode: full
---

## Overview
Scanner drafted {N} of 10 possible fields from codebase scan. All drafted values wear `[inferred]` markers (except CERTAIN values) and are presented as starting points for user review during the setup-project wizard.

## Draft Payload

\`\`\`yaml
_project_type:
  value: "{code|creative|mixed}"
  confidence: CERTAIN
  source: "{evidence summary — file ratios}"

PROJECT_DEFINITION:
  brownfield:
    value: true
    confidence: CERTAIN
    source: "full-scan mode"
  project_type:
    value: "{category from 13}"
    confidence: MEDIUM
    marker: "[inferred]"
    source: "{exact quote + tech summary}"
  project_domain:
    value: "{specific 3-8 words}"
    confidence: MEDIUM
    marker: "[inferred]"
    source: "{exact quote from README first paragraph}"

CONSTRAINTS_AND_RISKS:
  preliminary_technology:
    known_requirements:
      value:
        - "{Language ≥version}"
        - "..."
      confidence: HIGH
      marker: "[inferred]"
      source: "{config files read}"
    integration_requirements:
      value:
        - "{Framework or SDK}"
        - "..."
      confidence: HIGH
      marker: "[inferred]"
      source: "{dependency files}"
    platform_constraints:
      value:
        - "{constraint}"
      confidence: MEDIUM
      marker: "[inferred]"
      source: "{detection evidence}"

KEY_RESOURCES:
  specifications:
    main:
      value: "{file path}"
      confidence: HIGH
      marker: "[inferred]"
      source: "{ranking rule that matched}"
    technical:
      value:
        - "{file or directory path}"
      confidence: HIGH
      marker: "[inferred]"
      source: "{pattern that matched}"
  external_resources:
    value:
      - "{URL}"
    confidence: MEDIUM
    marker: "[inferred]"
    source: "{where extracted}"
\`\`\`

## Suppressed Fields
{For each field attempted but suppressed, one line with reason. Example:
- `preliminary_technology.platform_constraints`: no platform-specific signals detected
- `external_resources`: no URLs found in README or manifests}

## Notes
{Any caveats, thin-evidence notes, or recommendations for the user reviewing this draft. Graceful fallback note goes here when `draft_confidence: low`.}
```

**Frontmatter fields**:

| Field | Type | Meaning |
|---|---|---|
| `draft_version` | integer | Format version. Currently `1`. Future format changes increment this — do not break compatibility with `v1` readers, add `v2` handling alongside. |
| `draft_confidence` | enum | `high` / `medium` / `low` — overall based on number of fields drafted and evidence richness. ≥8 fields with ≥4 HIGH → high. ≥5 fields → medium. <5 fields → low. |
| `project_type_hint` | string | Scanner's best-guess category for its own tracking. NOT authoritative — setup-project wizard still asks the user to confirm. |
| `scanned_at` | ISO datetime | When the scan ran. Used for stale detection via mtime comparison (see Rule 5 in §F). |
| `scan_mode` | string | Always `full` in this version. |
| `draft_consumed_at` | ISO datetime (appended later) | Appended by setup-project STEP 7F Finalize when the draft has been consumed. Absence indicates draft has not been reviewed by wizard yet. |

### F. Ownership Discipline (PAT-083 structured-persistence-ownership)

The dual-path model (disk artifact + in-memory return payload) works cleanly under **5 rules**. These rules preserve PAT-083 single-persister semantics and prevent drift between the two paths.

**Rule 1 — Write-then-return sequence (non-negotiable)**: Write `PROJECT_DRAFT.md` to disk FIRST with `createBackup: true`. Verify the write (read back, confirm size > 0, frontmatter intact). THEN return the in-memory payload to the caller. The in-memory payload is guaranteed to match what's on disk at the moment of handoff.

**Rule 1 failure path**: If the disk write fails (permission error, tool error, disk full) OR the verify step fails (file missing, empty, corrupt frontmatter): **do not return the in-memory payload**. Return `None` / empty signal to the caller. Display a graceful-degrade message: `⚠️ PROJECT_DRAFT.md write failed: {reason}. Proceeding without draft — setup-project will fall back to greenfield wizard path.` The setup-project caller's STEP 1F.1 clause handles the no-payload case by setting `draft_payload = None` and suppressing all subsequent conditional draft reads. This is the unified no-draft path — whether the cause is greenfield mode, skipped map-context, empty scan, or write failure, the downstream behavior is identical.

**Rule 2 — Disk is authority for resume**: In same-conversation flow, setup-project uses the in-memory payload (free, fast). In cross-session resume, setup-project STEP 0A reads `PROJECT_DRAFT.md` from disk. The two code paths are never active simultaneously; mode is determined by whether map-context just ran in this conversation.

**Rule 3 — No in-memory mutation**: Setup-project reads the payload but NEVER modifies it. If the user overrides a drafted value at a wizard step, the override goes into `project-state.md` directly, NOT back into the in-memory payload. This keeps the payload faithful to the scan output.

**Rule 4 — Disk artifact is the audit record**: `PROJECT_DRAFT.md` is NEVER patched by setup-project except for the `draft_consumed_at` frontmatter flag at STEP 7F Finalize. The YAML body content is immutable from map-context's perspective. Map-context is the sole writer of the draft payload content.

**Rule 5 — Divergence detection at read time**: When setup-project STEP 0A reads `PROJECT_DRAFT.md` in a resume scenario, it compares mtime of the draft against mtime of scanned source files (package.json, README.md, pyproject.toml, CLAUDE.md, tsconfig.json, etc.). If any source file is newer than the draft, display:

```
⚠️ Draft may be stale — source files changed since scan.
   Scanned at: {draft scanned_at}
   Source files newer: {list}

   [Re-map now / Use stale draft / Proceed without draft]
```

This is the drift mitigation for the dual-path model.

### G. Graceful Fallback

If the scan yields minimal evidence (no package manifests found, no README or fallback file found, thin directory structure with few significant files):

1. Emit a minimal draft with only fields 1 (`_project_type`) and 2 (`brownfield`) — these are CERTAIN and always available
2. Set `draft_confidence: low` in frontmatter
3. Add a note in the `## Notes` section: `"Scan yielded minimal evidence. Wizard should proceed with user input as primary source. Consider running map-context again after more project content exists."`
4. Still write `PROJECT_DRAFT.md` and return the in-memory payload — the caller sees exactly what was drafted (or not)
5. Setup-project STEP 1F.5 transparency notice will state "Scanner drafted 2 fields" and the user knows not to expect more

### H. Update & Return

1. After writing `PROJECT_DRAFT.md` and verifying on disk:
2. `PROJECT_DRAFT.md` is appended to `project-state.md [KEY_RESOURCES].context_artifacts` during STEP 5B Artifact Registration (same mechanism as the other 4 artifacts)
3. Return the in-memory payload (as a structured dict/YAML object) to the caller

Display on completion:
```
✓ PROJECT_DRAFT.md created — {N} fields drafted, {M} suppressed, confidence: {tier}
```

**Pre-flight for STEP 5B**: STEP 5B continues with the normal integration flow (HIGH concerns → risks, `brownfield` flag, context_artifacts list). The new `PROJECT_DRAFT.md` entry in context_artifacts is added by STEP 5B alongside the other 4 artifacts.

[/Section: Project-State-Draft-Generator]
