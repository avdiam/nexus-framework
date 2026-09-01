# agent-template.md
*Version: 1.3.0 | Date: 2026-06-10 | Sprint: 099*

*Scaffold for NEXUS sub-agent files (dispatched via the Claude Code Agent tool). Dual-purpose: framework-always meta-agents + project-type-gated specialists. Companion to `operation-skill-template.md` and `methodology-skill-template.md`.*

> **Source of standard.** The authoritative agent-structure rubric is `framework-audit-playbook.md` §9 — especially §9d frontmatter integrity, primary-validated against the Claude Code sub-agents 16-field table. This template was **scanned against criterion 9 and is current**: its frontmatter schema (§Part 3) matches the placed gold `agents/_template.md` 1:1 (ISS-206 F-T3), and the model-selection / handoff / exclusion-list conventions hold — no rewrite needed (ISS-210, SCAN-then-classify). Added here: the **9a line band for agent files — ≤ 150 lines** (over-band → run the playbook §9b externalization test; the four shipped framework-always agents are all in-band, 94–149), plus this cross-reference to §9 as the fuller structure standard.

---

## Part 1 — Purpose & Layering Clarification

NEXUS ships four framework-always meta-agents (`nexus-scanner`, `nexus-researcher`, `nexus-reviewer`, `nexus-batch-worker`) in `.claude/agents/` authored case-by-case with strong structural similarity but no shared template. This template is the scaffold for future agents and the retrofit target for the existing four on their next substantive revision.

### Template scope vs. file location — two separate questions

The template is **domain-neutral**: a scaffold for any agent that NEXUS or its methodology skills might dispatch. File-location policy is resolved per §Part 10 Outstanding Investigation 10.1 (Claude Code docs verification).

| Question | Answer |
|---|---|
| What fields does an agent file carry? | §Part 3 frontmatter schema |
| What sections does an agent file carry? | §Part 4 body sections |
| Where do agent files live? | **Core `.claude/agents/`** — both framework-always meta-agents and project-type-gated specialists. Profile-specific directories are not scanned by Claude Code native dispatch. Discoverability mitigated via naming convention (see §Part 7 Registration Requirements) + `project_types:` frontmatter gating. |
| Which agents exist? | **Not prescribed here** — Decision phase determines per project-type; specialists spawn on first user-project trigger |
| When does an agent activate? | §Part 4 Project-Type Activation section (for agents with activation gating) |

### Two activation axes — framework-always vs. project-type-gated

Agent files fall into two activation modes. The template structure serves both; the differences are encoded in which sections apply (per §Part 2 tier map).

| Mode | Activation | Current examples | Future examples |
|---|---|---|---|
| **Framework-always** | Active regardless of user-project type. Serves NEXUS methodology skills (analyze, build, validate, research, maintain). Dispatched by skill internals. | nexus-scanner, nexus-researcher, nexus-reviewer, nexus-batch-worker | Any future agent serving NEXUS methodology itself |
| **Project-type-gated** | Active only when `_project_type` in project-state.md matches the agent's `project_types` field. Dispatched by setup/generate-mvp or methodology skills adapted per project type. | (none yet shipped) | Live in core `.claude/agents/` with `project_types:` gating (per §10.1 resolution); spawned on first user-project trigger |

### Non-goals

- This template does NOT spawn project-type-gated agent files in Sprint 075 (or any sprint adopting the template).
- This template does NOT replace existing framework-always agents. Retrofitting happens opportunistically on their next substantive revision.
- This template does NOT resolve whether role-based specialists (Architect, Developer, Reviewer, Auditor) should exist at all — Decision phase of future user projects owns that determination per project-type.
- **This template does NOT specify the spawn mechanism** — when a project-type-gated specialist is needed, WHO creates the agent file and WHEN is an unresolved architectural question. Four options exist (see **SEED-S8**): (A) `/nexus-setup-project` writes specialist files at project setup; (B) just-in-time lazy spawn on first dispatch; (C) new `/nexus-create-agent` skill invoked explicitly; (D) pre-shipped specialist library with `project_types:` gating (activation-by-frontmatter, no spawn). Decision deferred to first real non-NEXUS user project — picking speculatively now would author against no concrete driver. Template scaffolds the structure; the mechanism crystallizes when a real project drives it.

Background (per ISS-159 3rd-pass synthesis §10.1): an earlier preference favored profile-specific directories for generalization cleanness, but verification against Claude Code docs established that only `.claude/agents/` (and `~/.claude/agents/`) are scanned by native dispatch. Resolution: specialists live in core `.claude/agents/` with `project_types:` gating; generalization-cleanness is preserved at the dispatch layer (filter by project_types before invocation), not the filesystem layer.

---

## Part 2 — Template Structure Overview

```
.claude/agents/{agent-name}.md
├── Frontmatter (---yaml---)                            REQUIRED
├── Identity paragraph                                  REQUIRED
├── Mission one-liner                                   OPTIONAL (recommended for specialists)
├── Input Contract (YAML)                               REQUIRED
├── Exclusion List ("You will NOT receive")             REQUIRED  ← NEXUS-unique strength
├── Process (numbered)                                  REQUIRED
├── Output Format (templated)                           REQUIRED
├── Constraints                                         REQUIRED
├── Failure Modes                                       REQUIRED
├── Handoff Contract                                    REQUIRED for project-type-gated, OPTIONAL for framework-always
├── Project-Type Activation                             REQUIRED for project-type-gated, OMIT for framework-always
└── <example> block (in frontmatter description)        REQUIRED (via frontmatter)
```

**Tier map**:

| Section | Framework-always | Project-type-gated |
|---|---|---|
| Frontmatter | ✅ Required | ✅ Required (+ project-type fields) |
| Identity paragraph | ✅ Required | ✅ Required |
| Mission one-liner | ➖ Optional | ✅ Recommended |
| Input Contract (YAML) | ✅ Required | ✅ Required |
| Exclusion List | ✅ Required | ✅ Required |
| Process | ✅ Required | ✅ Required |
| Output Format | ✅ Required (single form) | ✅ Required (success/soft-landing/failure subsections) |
| Constraints | ✅ Required | ✅ Required |
| Failure Modes | ✅ Required | ✅ Required |
| Handoff Contract | ➖ Optional (if agent dispatches other agents) | ✅ Required |
| Project-Type Activation | ❌ Omit | ✅ Required |
| File-Scope Write Constraint | ✅ If agent writes files (currently: `nexus-batch-worker`) | ✅ Required (specialists produce one artifact) |

---

## Part 3 — Frontmatter Schema

```yaml
---
name: {agent-name}                          # REQUIRED. Lowercase, hyphenated.
description: |                              # REQUIRED. Trigger signal + <example> block.
  {One-sentence use-when statement.}

  <example>
  Context: {realistic calling context}
  user: "{user prompt that would trigger this agent}"
  assistant: {Agent invocation with brief input}
  <commentary>
  {Why this agent was the right call here.}
  </commentary>
  </example>
model: inherit                              # Default. Override to haiku/sonnet per §Model Selection Patterns A/B/C below.
tools:                                      # REQUIRED. Minimal set.
  - {Tool1}
  - {Tool2}

# --- OPTIONAL / PROJECT-TYPE-GATED FIELDS ---

project_types:                              # PROJECT-TYPE-GATED AGENTS ONLY
  - software-product-dev
  - migration-transition

background: true                            # OPTIONAL. Default: false (foreground-synchronous dispatch). Set true for concurrent background dispatch with status/TaskStop/SendMessage support.

wave:                                       # OPT-IN. For wave-dispatched batch participation.
  phase: analysis
depends_on:                                 # OPT-IN. Other agents this must follow.
  - nexus-architect
---
```

### Version Header (required immediately after frontmatter)

Every agent file carries a version header line on the line immediately following the closing `---` of the YAML frontmatter, in the same format as skills, sub-files, and templates:

```markdown
---
{frontmatter ...}
---
*Version: X.Y.Z | Date: YYYY-MM-DD | Sprint: NNN*

# {agent-name}
```

**Bump rules**: Agents inherit the skill Version Protocol verbatim. See CLAUDE.md [Section: File-Operations-Protocol] → Version Protocol — agent body section adds/removes are listed alongside SKILL.md / complex.md / types / references in the always-Major (no judgment) row. Frontmatter contract changes (model, tools, name, description, project_types, background) follow the standard Major / Minor / Patch ladder.

The agent file's version is tracked in `.nexus/active/registries/changelog-registry.yaml` under `current_versions: agents:`.

### Model Selection — Three Patterns

`model: inherit` is the documented default when the `model` frontmatter field is omitted (verified against Claude Code sub-agents docs). Three patterns govern when to override.

#### Pattern A — `model: inherit` (or omit field entirely)

**When**: Agent's work quality should track the session's model quality. User on Opus gets better agent output; user on Sonnet saves on cost. The agent has variable per-task complexity and no floor requirement.

**Examples**:
- `nexus-batch-worker` — playbook execution complexity varies per target. Inherit lets user's Opus session deliver richer execution; Sonnet session saves tokens.
- Hypothetical `nexus-doc-synthesizer` — document synthesis quality-tracks session quality.

```yaml
model: inherit
# or omit the field — 'inherit' is the default
```

#### Pattern B — Hard-code `haiku`

**When**: Task is deterministically simple (read + classify + report). Opus brings zero benefit. Cost multiplies if dispatched in parallel. Agent has bounded complexity with no floor-risk.

**Examples**:
- `nexus-scanner` — always "read these files, return digest." Dispatched up to 5× in parallel during maintenance Mode B. Pinning `haiku` prevents parallel-dispatch cost bloat on Opus sessions.

```yaml
model: haiku
```

#### Pattern C — Hard-code `sonnet` (or higher)

**When**: Task has a quality floor below which the agent fails silently. Adversarial review, subtle-defect detection, deep investigation. Running this class of work on haiku produces false passes.

**Examples**:
- `nexus-reviewer` — independent adversarial review at Build §POST-TYPE for C:3+ work. Haiku misses subtle issues; sonnet is the minimum floor.
- Hypothetical Nyquist-style auditor — behavioral verification with bounded iteration. Sonnet minimum.

```yaml
model: sonnet
```

#### Per-invocation override — documented intended pattern

A dispatching skill can pass `model:` at the per-call level. Resolution order (first wins):
1. `CLAUDE_CODE_SUBAGENT_MODEL` environment variable
2. Per-invocation `model` parameter from the caller
3. Agent definition's `model` frontmatter
4. Main conversation's model (the `inherit` resolution)

**When to use per-invocation override**:
- Agent has **two or more distinct operating modes** where model tier should differ per mode. Example: `nexus-researcher` should be `haiku` for survey-pass calls (breadth, landscape scan) and `sonnet` for investigation-pass calls (depth, per-criterion extraction). Frontmatter says `inherit`; dispatcher passes per-call override.
- Batch dispatch wants per-target model tiering (some targets are trivially simple, others are complex).

**Codify in the dispatching skill**:

```markdown
## Dispatching this agent

For survey-mode (breadth, landscape):
  Agent({ subagent_type: "nexus-researcher", model: "haiku", prompt: ... })

For investigation-mode (depth, per-criterion):
  Agent({ subagent_type: "nexus-researcher", model: "sonnet", prompt: ... })
```

Document the override pattern in both the agent file (§Dispatching conventions block) and the dispatching skill.

#### Model-selection audit

Audit checklist items for agent files:

- [ ] Frontmatter `model` value matches one of the three patterns (inherit / haiku-pin / sonnet-pin) OR field is omitted (= inherit)
- [ ] If the agent has distinct operating modes with different model requirements, the variance is documented in a §Dispatching conventions block, and the field defaults to `inherit`
- [ ] "use sparingly" language absent — `inherit` is the documented default, not a reserved fallback

### `description` Field Discipline

- State WHEN to dispatch, not WHAT the agent does.
- Start with "Use when..." or describe the trigger condition.
- Must include at least one `<example>` block with `<commentary>` (Anthropic canonical).
- Never a workflow summary ("Reads sources and returns summaries" — bad). Instead: "Use when research requires isolated per-source extraction that shouldn't pollute main context."

### Project-Type Fields (project-type-gated agents only)

`project_types` is a YAML list of project-type identifiers from `.nexus/templates/project-types/`. The main context uses this field at dispatch time to decide whether the agent is applicable to the current user project:

```yaml
project_types:
  - software-product-dev      # Architect, Developer, Reviewer, Security-Auditor
  - migration-transition       # Architect, Codebase-mapper
  - compliance-audit           # Security-Auditor, Reality-Checker
  - system-integration         # MCP-Builder, Architect
```

Project-type mismatch = agent not dispatched. Skip list when building dispatch plan.

### Background Dispatch (`background: true`)

`background: true` declares the agent as concurrent — the caller does not block on return. Caller can check status, `SendMessage` to resume, or `TaskStop` to terminate. Foreground is default (omit field or `background: false`).

Background mode unlocks TIMEOUT enforcement in the §Handoff Contract (see §Part 4). Foreground agents omit the TIMEOUT subsection entirely.

---

## Part 4 — Body Section Specifications

### §Identity Paragraph (required)

Two to four sentences. Must contain:
1. **Isolation claim**: "You are an isolated {role} for the NEXUS framework."
2. **Three-verb role statement**: what this agent does (read / extract / report; read / evaluate / report; execute / verify / report).
3. **Single-pass constraint**: "You do not X" (where X is the thing outside scope — typically analysis, synthesis, conversation).

**Example (framework-always, from `nexus-researcher.md`)**:

> You are an isolated research agent for the NEXUS framework. You receive a curated research brief from `/nexus-research` and return structured findings. You **read**, **extract**, and **report**. You do not analyze, recommend, or synthesize across sources — that happens in the main context.

**Example (project-type-gated specialist, future `nexus-architect-software.md`)**:

> You are an isolated workflow architect for the NEXUS framework, activated for `software-product-dev` and `migration-transition` project types. You receive a project brief and produce a workflow tree + handoff contract matrix. You **analyze**, **structure**, and **hand off**. You do not implement, review, or negotiate scope — main context orchestrates those stages.

### §Mission One-Liner (optional — recommended for specialists)

Single sentence stating the agent's primary output. Dispatch-time confirmation for the caller.

**Example**: "Mission: produce a workflow tree that covers all project-type-required phases with handoff contracts between adjacent phases."

### §Input Contract (required — YAML)

Explicit machine-parseable schema of what the agent receives. Every field present in the YAML must be referenced in the §Process section; every field read in §Process must appear in the contract. Drift between contract and process is catch-worthy at audit.

**Required framework-always contract fields**:

```yaml
{issue|task}_summary:
  id: {entity_id}
  title: <string>
  # ...context-specific fields
{work_input}:
  # the actual data the agent needs to process
patterns:                    # REQUIRED (upgraded from optional)
  - <PAT-XXX with adapted guidance>
guidance: <optional — brief strategy lens>
focus_lens: <optional — for multi-mode agents>
```

**Pattern injection slot**: every agent receives a `patterns` field even if empty. The main context loads relevant patterns from sprint-state and passes adapted guidance (1-3 sentences, not full PAT file). If no patterns apply, pass `patterns: []` explicitly — absence of the field is a contract violation, not a default.

### §Exclusion List (required — "You will NOT receive")

**NEXUS strength** (no external equivalent). Context-isolation contract.

Must enumerate explicitly:
- Conversation history
- Design rationale / prior phase decisions
- User preferences
- Rejected alternatives
- Synthesis/analysis conclusions (for extract/review agents)

Format:

```markdown
You will **not** receive: conversation history, design rationale, prior phase decisions, the user's preferences, or analysis conclusions.
```

The exclusion list makes the agent's context boundary visible. Drift (agent starts assuming it has access to rejected alternatives) is traceable.

### §Process (required — numbered)

Deterministic step list. Focus-branched if the agent has modes.

**Required anti-patterns** (inherits from operation-skill-template v2.1.0 §Discipline Enforcement Layer §4):
- No over-specification (micro-step-by-micro-step is bad)
- No under-specification ("Handle the analysis" is bad)
- **Self-verification step required**: the last sub-step of Process must verify the agent's own output against §Output Format before emitting. Example: "Verify your return matches the structure in §Output Format — all required fields present, format consistent. If a field can't be populated, use the documented fallback."

**Example structure** (focus-branched, from `nexus-researcher.md`):

```markdown
## Process

### Survey Focus (broad landscape mapping)

1. For each source in the list: {...}
2. {...}
5. **Self-verify**: confirm return structure matches §Output Format Survey Return.

### Investigation Focus (deep per-criterion extraction)

1. {...}
5. **Self-verify**: confirm return structure matches §Output Format Investigation Return.
```

### §Output Format (required)

**Framework-always**: single templated return structure (as in current `nexus-researcher.md` / `nexus-reviewer.md`).

**Project-type-gated specialists**: three named subsections (success/soft-landing/failure):

```markdown
## Output Format

### Success Return

{templated success output — the normal case}

### Soft-Landing Return

{templated output for "worked partially, documented gaps" — not failure, not full success}

Examples of soft-landing cases:
- Agent completed core task but flagged a scope adjustment needed
- Primary source unavailable, secondary-source fallback used (noted)
- Ambiguity surfaced that the main context should resolve

### Failure Return

{templated error output — clear failure, no partial work to extract}

[ERROR]
Reason: {one-line error}
Partial: {anything recovered, or "none"}
```

**3-state taxonomy**:
- **keep / success** → Success Return
- **discard / soft-landing** → Soft-Landing Return (findings present, but warrant main-context decision)
- **crash / failure** → Failure Return

Framework-always agents with simple output (e.g., `nexus-researcher` returning one report) may use a single Success Return form plus an ERROR form, skipping the Soft-Landing subsection. Project-type-gated specialists MUST use all three.

### §Constraints (required)

Top-of-agent prohibition block. Current NEXUS convention is a bulleted list with 5-7 items. Two additions:

#### Negative Constraint Format — "I do not..." pattern

Each constraint states the prohibition as a first-person negation. Each "I do not" encodes a positive obligation.

```markdown
## Constraints

- **Read-only**: I do not modify project files. My tools are Read, Glob, Grep, WebSearch, WebFetch.
- **Single-pass**: I do not iterate. I complete in one pass. No follow-up questions.
- **No conversation**: I do not ask the user. I work with the brief I received.
- **No cross-source synthesis**: I do not compare across sources. Each source returned independently.
- **Token budget**: I do not exceed 2000 words per return. Structured format required.
```

The negation form is stronger than label form ("Read-only" vs "I do not modify project files") — it restates the positive obligation the agent is under.

#### File-Scope Write Constraint (required for write-capable agents) — path conventions

Write-capable agents declare a single output artifact scope. Path conventions differ by agent class:

| Agent class | Output artifact path convention | Example |
|---|---|---|
| **Framework-always meta-agents** writing outputs | `.nexus/{domain}/...` or `.nexus/Sprints/{N}/...` — framework-managed storage | `nexus-batch-worker` writes to `{target.path}` from brief (user-supplied, typically inside the sprint scope) |
| **Project-type-gated specialists producing framework-tracked artifacts** | `.nexus/projects/{project_id}/{artifact}.md` (if a project-scoped sub-tree is added) OR project-state fields | Architect workflow-tree persists as project-state `[PHASES]` schema + optional `.nexus/projects/{id}/workflow-tree.md` snapshot |
| **Project-type-gated specialists producing user-visible artifacts** | Project-root path (outside `.nexus/`) — user file the user works with directly | Developer specialist writes code files at their normal locations (e.g., `src/foo.ts`); Author specialist writes `docs/chapter-01.md` |

**Rule of thumb**: if the artifact is a NEXUS tracking/state artifact, it lives under `.nexus/`. If the artifact is a user-facing deliverable the user would commit in their own repository, it lives at project-root paths. Specialist agents declare their output artifact explicitly in §Constraints File-scope line:

```markdown
- **File-scope**: I write to exactly one output artifact: {specific path}. I do not modify other files.
```

Examples:
- Architect specialist: `.nexus/projects/{project_id}/workflow-tree.md`
- Developer specialist: `{target-file-path}` (single code file, project-root relative)
- `nexus-batch-worker`: `{target.path}` from input contract

Multi-output writes are a delegation trigger — the agent must STOP and delegate back to main context rather than write a second artifact.

### §Failure Modes (required)

Named error forms with one-line cause + template. Retain current NEXUS form (ERROR template + common error phrases). Add edge-case enumeration for soft-landings.

```markdown
## Failure Modes

### Failure Return Template

{as in Output Format — single template}

### Common Failures

- `"Source inaccessible: {URL}"` — external resource blocked or down
- `"Input contract missing: {field}"` — brief incomplete
- `"No relevant content for criteria: {criterion}"` — gap, not failure

### Soft-Landing Edge Cases (specialists only)

- `"Scope ambiguity: {what}"` — work is viable but the main context should pick between options
- `"Primary source fallback to secondary"` — findings valid, confidence downgraded
- `"Conditional pass: {criterion not yet evaluable}"` — partial result, criterion deferred

### Delegation Triggers (agents that may STOP early)

- `"STOP — {problem}"` — problem outside playbook/scope; main context handles
```

### §Handoff Contract (required for project-type-gated specialists, optional for framework-always)

**When required**: the agent's output is consumed by **another agent** (specialist-to-specialist handoff) rather than main-context synthesis.

**Framework-always agents don't ship this by default** because they return to main context, and main context orchestrates next steps. The current four framework-always agents (scanner, researcher, reviewer, batch-worker) are foreground-synchronous and return to main context — none ships a Handoff Contract.

**Project-type-gated specialists DO ship this.** Specialists invoke other specialists — Architect hands off to Developer; Developer hands off to Reviewer/Reality-Checker; etc.

#### Schema

Five components. TIMEOUT is **mode-dependent** — enforceable when the agent runs as a background subagent (`background: true` in frontmatter); N/A for foreground synchronous dispatch (caller blocks until return, no partial-return-with-timeout semantic). See rationale below.

```yaml
## Handoff Contract

### PAYLOAD
{structure of the output artifact this agent produces}

### SUCCESS RESPONSE
On success, I return:
- {artifact path or structured data}
- {success criteria met confirmation}
- {recommended next agent or step}

### FAILURE RESPONSE
On failure, I return:
- Failure taxonomy: {keep/discard/crash}
- {what I tried}
- {what's blocking}

### TIMEOUT (mode-dependent)
Conditional enforcement:
- **If agent frontmatter declares `background: true`**: TIMEOUT is enforceable. Specify threshold (e.g., "15 minutes of elapsed time"). On timeout: caller may invoke TaskStop, request partial artifact at {path}, or allow continued execution with a partial-result request.
- **If foreground (default — `background: false` or omitted)**: TIMEOUT does not apply. Caller blocks until agent returns; no partial-return-with-timeout semantic exists. Omit this subsection from the agent's Handoff Contract if the agent is foreground-only.

### ON FAILURE (of downstream agent consuming my payload)
Downstream agent failures consuming my payload indicate:
- {common handoff drift modes with corrective steps}
```

#### TIMEOUT as mode-dependent field

Claude Code sub-agents support two dispatch modes natively:
- **Foreground** (default, `background: false` or omitted): blocks main conversation until return. No partial-return semantic.
- **Background** (`background: true` in frontmatter): runs concurrently with main conversation. Agent ID persists; caller can check status, SendMessage to resume, or TaskStop.

TIMEOUT is enforceable in background mode: the caller knows agent ID and can measure elapsed time. TIMEOUT is not enforceable in foreground mode.

**Resolution**: TIMEOUT is a **mode-dependent** field in the Handoff Contract schema. Agent files declare `background: true` in frontmatter when concurrent execution is desired; those agents carry TIMEOUT with threshold values in their Handoff Contract. Foreground agents (the current default for all 4 NEXUS framework-always agents) omit TIMEOUT entirely.

**Current NEXUS state**: all 4 framework-always agents (scanner, researcher, reviewer, batch-worker) are foreground-synchronous. Their Handoff Contracts (when shipped) do not require TIMEOUT.

**Future state**: project-type specialists may benefit from background mode for long-running operations (e.g., Architect producing a large workflow tree; Developer implementing multi-file changes). When those agents are authored, declare `background: true` and include TIMEOUT per this section.

#### Prompt-Template-Per-Handoff

When this agent dispatches downstream specialists, it uses a scoped brief — not a free-form invocation. Pattern:

```markdown
### Dispatching {downstream-agent-name}

Brief template:

\```yaml
{downstream contract fields populated from my payload}
scope: "{specific bounded ask — e.g., 'Review workflow tree for circular dependencies only — do not suggest structural changes'}"
expected_output: "{exact form to return}"
\```

The `scope:` field is mandatory — it prevents the downstream agent from broadening its ask beyond what this handoff requires.
```

### §Project-Type Activation (required for project-type-gated specialists, omit for framework-always)

Declares when this agent is in scope:

```markdown
## Project-Type Activation

This agent is dispatched only when the active project's `_project_type` (from project-state.md) matches one of:

| Project Type | Activation Trigger | Work Scope |
|---|---|---|
| software-product-dev | Default activation for this type — dispatched at {phase} | {scope} |
| migration-transition | Activation when {condition} | {scope} |
| compliance-audit | {trigger} | {scope} |

**Do NOT activate when**:
- Project type is `meta-framework` (NEXUS itself — framework-always agents only)
- Project type is single-domain research-analysis and work is strictly knowledge extraction
- User has explicitly opted out of specialist dispatch for this project
```

**Framework-always agents omit this section entirely.** They are always active; the framework invokes them regardless of user-project type.

---

## Part 5 — Filled Examples

Two worked examples showing the template applied.

### Example 1 — Retrofit of existing `nexus-researcher` to template v1.1.0

**No substantive behavior change — only structural conformance to v1.1.0 template. Key diff: `model: sonnet` → `model: inherit` + new §Dispatching conventions block documenting per-invocation override.**

```yaml
---
name: nexus-researcher
description: |
  Use when research requires isolated per-source extraction that should not
  pollute the main context. Dispatched by /nexus-research for survey and
  investigation passes across external sources.

  <example>
  Context: /nexus-research Phase 2 Survey across 5 external sources for an Adoption-mode issue.
  user: "Research BMAD, obra/superpowers, and 3 other agent frameworks"
  assistant: Agent({ subagent_type: "nexus-researcher", model: "haiku", prompt: <survey brief> })
  <commentary>
  Survey-focus across multiple sources benefits from haiku per-invocation — each
  agent's context stays focused, parallelism minimizes wall-clock, haiku handles
  landscape mapping. Investigation-focus calls override with sonnet for depth.
  </commentary>
  </example>
model: inherit
tools: [Read, Glob, Grep, WebSearch, WebFetch]
---

# nexus-researcher

## Identity

You are an isolated research agent for the NEXUS framework. You receive a curated
research brief from /nexus-research and return structured findings. You **read**,
**extract**, and **report**. You do not analyze, recommend, or synthesize across
sources — that happens in the main context.

## Dispatching conventions

`/nexus-research` passes per-invocation `model:` override per focus mode (Pattern A inherit + per-invocation override):

- **Survey focus** (breadth, landscape scan): dispatcher passes `model: "haiku"` — cost-efficient for landscape mapping.
- **Investigation focus** (depth, per-criterion extraction): dispatcher passes `model: "sonnet"` — quality floor for nuanced extraction.

Frontmatter `model: inherit` is the default; the dispatcher's per-invocation override wins per resolution order.

## Input Contract

{as existing file — plus required `patterns:` field explicitly present}

## Exclusion List

You will **not** receive: conversation history, design rationale, prior phase
decisions, the user's preferences, or analysis conclusions.

## Process

{as existing file — plus final self-verification step per §Process spec}

## Output Format

### Success Return

{as existing file — Survey Return and Investigation Return templates}

### Failure Return

[ERROR]
Reason: {...}
Partial: {...}

## Constraints

- **Read-only**: I do not modify project files. My tools are Read, Glob, Grep, WebSearch, WebFetch.
- **Single-pass**: I do not iterate. No follow-up questions.
- **No conversation**: I do not ask the user. I work with the brief.
- **No cross-source synthesis**: I do not compare across sources. Each source returned independently.
- **Token budget**: I do not exceed 2000 words per return.

## Failure Modes

{as existing file — common errors section retained}

# Omitted sections (not applicable to this framework-always agent):
# - Mission one-liner (optional)
# - Handoff Contract (framework-always agent returns to main context; foreground dispatch)
# - Project-Type Activation (framework-always, no project-type gating)
# - File-scope write constraint (read-only agent)
```

**Structural changes from current `nexus-researcher.md`**:
- Frontmatter `model: sonnet` → `model: inherit` + new §Dispatching conventions block
- Frontmatter `description` gains `<example>` block
- `patterns:` field in Input Contract made explicit
- Identity paragraph labeled `## Identity`
- Exclusion List made a named section instead of an inline sentence
- Constraints rewritten with "I do not..." negation form
- Self-verification step added to Process

Zero change to runtime behavior — model selection matches documented pattern; survey vs investigation mode overrides preserved.

### Example 2 — Hypothetical project-type-gated specialist `nexus-architect-software`

**This file would NOT land in `.claude/agents/` by default. It shows what the template produces when a future user-project triggers Architect activation. Declares `background: true` since workflow synthesis is long-running.**

```yaml
---
name: nexus-architect-software
description: |
  Use when a software-product-dev, migration-transition, complex-problem-solving,
  or system-integration project needs a workflow tree with handoff contracts
  between phases. Dispatched by /nexus-setup-project or /nexus-generate-mvp at
  project structuring time.

  <example>
  Context: /nexus-setup-project Step 4 for a newly detected software-product-dev project.
  user: "Set up the workflow for a React+Postgres SaaS MVP"
  assistant: Agent({ subagent_type: "nexus-architect-software", prompt: <setup brief> })
  <commentary>
  Setup for software-product-dev benefits from Architect specialist — produces a
  workflow tree with phase handoffs. Long-running; runs background mode for
  concurrent progress while main context continues setup dialogue.
  </commentary>
  </example>
model: sonnet
background: true
tools: [Read, Glob, Grep, Write]

project_types:
  - software-product-dev
  - migration-transition
  - complex-problem-solving
  - system-integration
---

# nexus-architect-software

## Identity

You are an isolated workflow architect for the NEXUS framework, activated for
`software-product-dev`, `migration-transition`, `complex-problem-solving`, and
`system-integration` project types. You receive a project brief and produce a
workflow tree + handoff contract matrix. You **analyze**, **structure**, and
**hand off**. You do not implement, review, or negotiate scope.

## Mission

Mission: produce a workflow tree that covers all project-type-required phases with
explicit handoff contracts between adjacent phases.

## Input Contract

\```yaml
project_summary:
  id: <project id>
  title: <project title>
  project_type: <software-product-dev | migration-transition | ...>
  mvp_minimum: <one-line MVP definition>
brief:
  scope: <in-scope work>
  constraints: <technical/resource/timeline constraints>
  success_criteria: <measurable outcomes>
patterns:
  - PAT-XXX: <adapted guidance>
guidance: <optional strategy lens>
\```

## Exclusion List

You will **not** receive: conversation history, prior Architect outputs for this
project, other specialists' state, user discussion of alternative structures, or
budget/resourcing constraints outside the brief.

## Process

1. Read the project summary and classify the workflow shape (greenfield /
   migration / integration / problem-solving).
2. Propose a phase decomposition — minimum phases to meet `mvp_minimum`, no more.
3. For each phase: identify entry criteria, exit criteria, and the specialist (if
   any) whose output this phase produces.
4. For each phase boundary: specify the handoff contract (PAYLOAD schema + SUCCESS
   + FAILURE + TIMEOUT per §Handoff Contract).
5. Write the workflow tree artifact to `.nexus/projects/{project_id}/workflow-tree.md`.
6. Self-verify: output artifact present, phase count ≥ 2, all handoffs specified,
   no unreferenced specialists in the matrix.

## Output Format

### Success Return

\```
🏗️ Workflow Tree — {project_id}
Phase count: {N}
Specialists referenced: {list}
Workflow artifact: {path}
Next specialist in sequence: {downstream-agent-name or "none — main context orchestrates"}
\```

### Soft-Landing Return

\```
🏗️ Workflow Tree — {project_id} [PARTIAL]
Phase count: {N}
Gap: {scope ambiguity or deferred phase}
Recommendation: {main-context decision point}
\```

### Failure Return

\```
🏗️ Workflow Tree — {project_id} [ERROR]
Reason: {one-line}
Partial: {anything produced}
\```

## Constraints

- **Single output artifact**: I write exactly one file — `.nexus/projects/{project_id}/workflow-tree.md`. I do not write elsewhere.
- **Read-only on project code**: I do not modify implementation files. My tools are Read, Glob, Grep, Write (scoped).
- **No implementation**: I do not write code, specs, or migration scripts. My output is structural.
- **No review**: I do not evaluate another Architect's output. Review is Reality-Checker's scope.
- **Scope as given**: I do not negotiate scope. If `brief` is insufficient, I return a soft-landing with the ambiguity named.
- **Token budget**: I do not exceed 2500 words in the workflow tree artifact. Phase descriptions are terse.
- **File-scope**: I write to exactly one output artifact: `.nexus/projects/{project_id}/workflow-tree.md`. I do not modify other files.

## Failure Modes

{common errors + soft-landing edge cases + delegation triggers per template}

## Handoff Contract

### PAYLOAD

\```yaml
workflow_tree:
  path: .nexus/projects/{project_id}/workflow-tree.md
  phases:
    - name: <phase name>
      specialist: <agent-name or null>
      entry: <criteria>
      exit: <criteria>
      handoff_to: <next phase / agent / main-context>
\```

### SUCCESS RESPONSE

- Artifact: `.nexus/projects/{project_id}/workflow-tree.md`
- Phase count: {N}, all handoffs specified
- Recommended next dispatch: `{downstream-agent-name}` (or `"main context"`)

### FAILURE RESPONSE

- Failure taxonomy: crash
- What I tried: {list}
- What blocks: {missing field or ambiguity}

### TIMEOUT (mode-dependent — ENFORCEABLE because `background: true`)

If I exceed 15 minutes of elapsed time on workflow design:
- Partial artifact at `.nexus/projects/{project_id}/workflow-tree.md`
- Phase count so far, handoffs remaining
- Caller may invoke TaskStop, request continuation via SendMessage, or accept partial

### ON FAILURE (downstream agent can't consume)

If `nexus-developer-*` or `nexus-reviewer-*` fails reading my workflow-tree artifact:
- Inspect the handoff contract schema in §PAYLOAD — are required fields populated?
- Common drift: `entry` / `exit` criteria left as prose where downstream expected YAML

### Dispatching downstream specialists

When the workflow tree designates `nexus-developer-*` for a phase, brief template:

\```yaml
issue_summary: {from main context}
target_file: {from workflow-tree phase spec}
scope: "Implement the feature within {phase entry}—{phase exit} boundaries only. Do not refactor outside scope."
expected_output: "Code diff + self-verification confirmation matching phase exit criteria."
\```

## Project-Type Activation

| Project Type | Activation Trigger | Work Scope |
|---|---|---|
| software-product-dev | Dispatched by /nexus-setup-project Step 4 at project scaffolding | Greenfield workflow tree (Discovery → Build → Validate → Ship) |
| migration-transition | Dispatched when old-system-to-new-system scope detected | Migration workflow tree (Inventory → Map → Migrate → Cutover → Decom) |
| complex-problem-solving | Dispatched when multi-phase problem with dependencies detected | Problem decomposition tree (Frame → Decompose → Solve → Integrate) |
| system-integration | Dispatched when multi-system integration scope detected | Integration topology tree (Survey endpoints → Contract → Implement → Verify) |

**Do NOT activate when**:
- Project type is `meta-framework` (NEXUS itself uses /nexus-organize-sprint, not Architect)
- Project type is `research-analysis` with single-domain scope (single-agent research is appropriate)
- User has opted out via `_specialist_dispatch: false` in sprint-state
```

---

## Part 6 — Source & Adoption-Threshold Citations

| Element | Verdict | Source | Verified |
|---|---|---|---|
| 9-section tiered scaffold | Adapt | agency-agents | Investigation verified |
| `<example>` block in description | Extract | Anthropic | Verified (direct doc fetch) |
| PAYLOAD/SUCCESS/FAILURE/TIMEOUT(mode-dependent)/ON-FAILURE handoff | Adapt (R1 revision) | agency-agents + Claude Code docs | Verified; TIMEOUT enforceable when `background: true` in frontmatter; omit subsection for foreground agents |
| "I do not..." constraint-negation | Extract | agency-agents | Investigation verified |
| File-scope write constraint with path conventions | Adapt (R5 clarification) | GSD + NEXUS path conventions | Investigation verified |
| Prompt-template-per-handoff | Adapt | agency-agents | Investigation verified |
| Self-verification step | Extract | Anthropic | Investigation verified |
| Output Format success/soft-landing/failure | Refinement | Anthropic + autoresearch | Investigation verified |
| **`model: inherit` as default** | **Extract** (R2 promotion) | Claude Code docs (direct web verification) | Verified — documented default when frontmatter omitted |
| Per-invocation override codification | Extract (R2 new) | Claude Code docs | Verified — explicitly documented resolution order |
| `wave`/`depends_on` opt-in frontmatter | Adapt | GSD | Investigation verified |
| `background: true` frontmatter field | Extract | Claude Code docs | Verified — documented concurrent dispatch mode |
| Pattern-injection slot (required) | Retain+upgrade | NEXUS baseline | Internal |
| Exclusion list retain | Retain | NEXUS baseline | Internal (no external equivalent) |
| Project-Type Activation section | Adapt | Phase 4 Part I.4 | Design-level; depends on §Part 10 OI items |

**Elements NOT adopted**: color, emoji, vibe, personas, trigger-based dispatch, Python integration classes, NEVER STOP, word-count enforcement.

---

## Part 7 — Registration Requirements

When a new agent file is created using this template:

1. Create `.claude/agents/{agent-name}.md`
2. If framework-always: update the relevant methodology/operation SKILL's [Section: Agent-Contracts] or equivalent with the agent's dispatch contract
3. If project-type-gated: set `project_types:` frontmatter appropriately; dispatching skills filter by project type at dispatch time
4. Add to `changelog-registry.yaml` as new entity

**Naming convention**:
- Framework-always: `nexus-{verb}-{noun}` — e.g., `nexus-researcher`, `nexus-batch-worker`, `nexus-scanner`, `nexus-reviewer`
- Project-type-gated specialists: `nexus-{role}-{project-type-hint}` — e.g., `nexus-architect-software`, `nexus-auditor-compliance`, `nexus-author-content`

The project-type-hint in specialist names improves discoverability given all agents share one directory (core `.claude/agents/` is the only scanned location per §Part 10 OI 10.1).

---

## Part 8 — Self-Eval

### PAT-004 10-Item Validation Checklist

| # | Principle | Applies to this template | Verdict |
|---|---|---|---|
| 1 | Behavioral specification over code | Template specifies waypoints (§Process steps, §Output Format), leaves execution to LLM judgment | ✅ |
| 2 | Semantic judgment over keyword matching | Agent Process steps use semantic descriptions, not regex/keyword rules | ✅ |
| 3 | Collaborate, don't just record | §Input Contract + §Handoff Contract make the agent a participant, not a transcription tool | ✅ |
| 4 | Not a rigid template (selective sections) | Tier map (Part 2) gates sections per agent type — framework-always vs project-type-gated | ✅ |
| 5 | Single responsibility per step | Process steps are bounded; §Output Format separates concerns from §Failure Modes | ✅ |
| 6 | No CLAUDE.md duplication | References CLAUDE.md for memory-first / verification / consent — agents receive briefs, don't re-teach protocols | ✅ |
| 7 | Preserve operational specifics | Per-section authoring guidance is concrete (e.g., exact `patterns:` field requirement; path conventions table) | ✅ |
| 8 | YAML only when structure IS info | Input Contract YAML (structural); §Handoff Contract YAML (structural); Process is prose+numbered; Constraints are prose bullets | ✅ |
| 9 | Inline vs delegate for cascades | §Handoff Contract addresses cascades explicitly; framework-always omits because main context orchestrates | ✅ |
| 10 | Validation after rewriting | Self-verification step in §Process; audit checklist below | ✅ |

### PAT-085 Decision Test per Section

"Does removing this lose actionable guidance?"

| Section | Remove-and-lose test | Verdict |
|---|---|---|
| Frontmatter (with `<example>`) | Without it, dispatch signal unclear + no calling context | Keep |
| Identity | Without it, agents drift on role | Keep |
| Mission (optional) | Narrow value — recommended for specialists only | Keep-conditional |
| Input Contract | Without it, dispatch is free-form | Keep |
| Exclusion List | Without it, context-isolation contract is implicit → drifts | Keep |
| Process | Without it, behavior undefined | Keep |
| Output Format | Without it, return structure drifts across invocations | Keep |
| Constraints (with path conventions) | Without it, agents broaden scope OR write to wrong paths | Keep |
| Failure Modes | Without it, errors unstructured | Keep |
| Handoff Contract (TIMEOUT mode-dependent) | Without it, specialist-to-specialist dispatch has no contract; TIMEOUT clarity prevents foreground-TIMEOUT nonsense | Keep (specialists only; TIMEOUT conditional) |
| Project-Type Activation | Without it, specialists activate indiscriminately | Keep (specialists only) |

Zero sections fail PAT-085.

### Agent-template Audit Checklist (for using the template)

```markdown
### Structure (all agents)
- [ ] Frontmatter has name, description (with <example>), model, tools
- [ ] Agent name matches file name and NEXUS convention
- [ ] Line band checked (9a) — agent file ≤ 150 lines; over-band → playbook §9b externalization test
- [ ] Model selection matches one of 3 patterns (inherit / haiku / sonnet) — see §Part 3 Model Selection audit
- [ ] "use sparingly" language absent — `inherit` is the documented default
- [ ] `background: true` declared if concurrent dispatch needed (TIMEOUT enforcement gate)
- [ ] Identity paragraph has 3-verb role statement + isolation claim
- [ ] Input Contract YAML explicit, includes `patterns:` field (even if empty)
- [ ] Exclusion List enumerates at least 4 things not received
- [ ] Process has numbered steps, ends with self-verification step
- [ ] Output Format: Success (required) + Soft-Landing (specialists) + Failure templates
- [ ] Constraints use "I do not..." negation form
- [ ] Failure Modes table present with common errors

### Specialists (additional)
- [ ] Mission one-liner present
- [ ] project_types field in frontmatter lists valid project-type identifiers
- [ ] File-scope write constraint declared (one output artifact) — path follows conventions table
- [ ] Handoff Contract with PAYLOAD/SUCCESS/FAILURE/ON-FAILURE (TIMEOUT only if `background: true`)
- [ ] Prompt-template-per-handoff for each downstream specialist
- [ ] Project-Type Activation table with explicit "Do NOT activate when" list

### Dispatching conventions (agents with per-invocation model override)
- [ ] §Dispatching conventions block documents per-invocation override pattern
- [ ] Dispatching skill (e.g., /nexus-research) mirrors the override pattern in its skill file

### Dogfood (before shipping)
- [ ] Walk through a sample dispatch — does the agent have what it needs?
- [ ] Walk through a sample failure — does the failure mode return something actionable?
- [ ] Grep for placeholders (TBD, {describe}, TODO) — zero hits required
```

### Structural-Isolation Check

Of the 14 elements incorporated (v1.0.0 had 13; v1.1.0 adds `background: true`):

- **Structural-isolation fixes**: Identity paragraph, Exclusion list, Input contract YAML, Process numbering, Constraints structure, Failure modes, pattern-injection slot (7 of 14)
- **Genuinely new content**: `<example>` block mandated, Mission one-liner, soft-landing subsection, file-scope write constraint with path conventions, Handoff Contract, Project-Type Activation section, "I do not..." negation, self-verification step, **three-pattern model selection** (R2 promotion), **TIMEOUT mode-dependent + `background: true`** (R1 revision) (10 of 14)

Revision increases "genuinely new" count by codifying three previously-implicit elements (per-invocation model override, background dispatch, path conventions).

---

## Part 9 — Adoption Plan

When this template is accepted:

1. Land the file as `.nexus/templates/agent-template.md` at v1.1.0.
2. Log to `.nexus/active/registries/changelog-registry.yaml`: `agent-template.1.1.0 — new template created with three-pattern model selection, mode-dependent TIMEOUT, and path conventions`.
3. Update `.nexus/templates/README.md` to reference the new template — **optional, only if README exists** (as of ISS-165 adoption, no README exists; clause is a no-op).
4. Retrofit existing four framework-always agents opportunistically (ISS-166 ships this for `nexus-researcher` + `nexus-batch-worker`):
   - `nexus-scanner` — keep `model: haiku` (Pattern B confirmed correct)
   - `nexus-researcher` — change to `model: inherit`; document dispatch-time override pattern per-mode (Pattern A + per-invocation codification)
   - `nexus-reviewer` — keep `model: sonnet` (Pattern C quality floor)
   - `nexus-batch-worker` — change to `model: inherit` (Pattern A — target complexity varies)
5. Project-type-gated agents (when authored — SEED-S8 deferred): file live in `.claude/agents/` with `project_types:` frontmatter gating. Naming convention `nexus-{role}-{project-type-hint}` (e.g., `nexus-architect-software`, `nexus-auditor-compliance`) improves visual discoverability given all agents share one directory. Each specialist's file header documents its activation condition.

---

## Part 10 — Outstanding Investigation

### 10.1. Layering decision for project-type-gated agents — ✅ RESOLVED

**Resolution** (verified via Claude Code sub-agents docs): project-type-gated agent files **MUST live in `.claude/agents/`** (core) with `project_types:` frontmatter gating for dispatch-time activation.

Rationale (from Claude Code docs review):
- Claude Code sub-agent discovery scans only: `.claude/agents/` (project), `~/.claude/agents/` (user), managed settings directory, plugin-provided namespaces
- No support for custom path scanning (e.g., `.nexus/templates/project-types/{type}/agents/`)

**Adopted path**: core `.claude/agents/` with `project_types:` gating.

**Discoverability mitigation** (since core directory bloats with files that don't apply to most projects):
- Naming convention distinguishes framework-always from project-type-gated (see §Part 7)
- Each specialist file header documents its activation condition and which project types invoke it
- Dispatching skills filter by `project_types:` at dispatch time; irrelevant agents are never invoked

### 10.2. Claude Code sub-agent dispatch mechanism — ✅ RESOLVED

**Resolution**: Claude Code subagent discovery is path-restricted to the standard locations (`.claude/agents/`, `~/.claude/agents/`, managed settings). No custom path support. See §10.1 for the adoption consequence.

Background dispatch is available via `background: true` frontmatter field — see TIMEOUT section in §Part 4 Handoff Contract for implications.

### 10.3. `nexus-researcher` per-invocation override — formalize in dispatcher

**Status**: pending ISS-166 execution. Per-invocation override is documented in this template (§Part 3 Per-invocation override); the `/nexus-research` dispatcher audit and codification is ISS-166's scope. Before ISS-166 closure, grep `/nexus-research/SKILL.md` + mode files for per-invocation model parameter usage, document the override in the skill's Dispatching section, and confirm which other skills use per-invocation override.

### 10.4. Agent tool background dispatch semantics — ✅ RESOLVED

**Resolution**: background dispatch is a first-class supported mode. `background: true` is a documented frontmatter field. Background subagents run concurrently, are referenceable by agent ID, can be `SendMessage`-resumed or `TaskStop`-terminated. Foreground is default (`background: false` or field omitted).

**Implication for TIMEOUT**: mode-dependent as documented in §Part 4 Handoff Contract. Enforceable when `background: true`, N/A for foreground.

### 10.5. Soft-landing taxonomy for framework-always agents

**Status**: non-blocking. v1.0.0 draft mandated Success / Soft-Landing / Failure for project-type-gated specialists; framework-always agents may use single Success + Failure per the "simple output" carve-out. The question of whether Soft-Landing should be required for framework-always agents too remains open — the four current agents arguably have natural three-state returns. Recommendation: re-evaluate when retrofitting (ISS-166).

### 10.6. Role-based specialist inventory — Decision-phase only (not investigation)

**Status**: deferred to first real non-NEXUS user project. The role-based specialist question (are Architect/Developer/Reviewer/Auditor etc. adopted? per which project types?) is a design question, not an investigation one. No external source will answer it. Spawn mechanism (SEED-S8 — options A/B/C/D) decided when first driver appears.

---

## Part 11 — Traceability

| Element | Source | Verified |
|---|---|---|
| Two-axis activation taxonomy (framework-always vs project-type-gated) | Sandbox critical assessment §1.2 + Phase 4 Part I.2 | Design synthesis |
| 9-section tiered scaffold | agency-agents | Investigation verified |
| `<example>` block discipline | Anthropic | Direct doc verification |
| Handoff schema (PAYLOAD/SUCCESS/FAILURE/TIMEOUT-mode-dependent/ON-FAILURE) | agency-agents + Claude Code docs | R1 revision + verified |
| `model: inherit` default + 3-pattern model + per-invocation override | Claude Code docs (direct fetch) | R2 promotion; verified |
| `background: true` frontmatter field | Claude Code docs | Verified |
| Path conventions table (framework-always vs specialists vs user-facing) | 3rd-pass synthesis + NEXUS conventions | R5 clarification |
| "I do not..." negation | agency-agents | Investigation verified |
| File-scope write constraint | GSD | Investigation verified |
| Self-verification step | Anthropic | Investigation verified |
| 3-state output taxonomy | autoresearch + Anthropic edge-case enumeration | Investigation verified |
| Prompt-template-per-handoff | agency-agents | Investigation verified |
| Pattern-injection slot (`patterns:` required, empty allowed) | NEXUS internal | Internal convention |
| Exclusion list ("You will NOT receive") | NEXUS internal | NEXUS strength, no external equivalent |

---

**END OF TEMPLATE v1.1.0**

Adopt when Outstanding Investigation items 10.1 + 10.2 + 10.4 resolve (all resolved as of Sprint 075). Items 10.3, 10.5, 10.6 are non-blocking but strengthen adoption if resolved — 10.3 ships via ISS-166.
