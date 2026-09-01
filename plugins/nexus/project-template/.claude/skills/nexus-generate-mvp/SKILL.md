---
name: nexus-generate-mvp
description: Generate issues from project deliverables for MVP planning
disable-model-invocation: true
---
*Version: 3.1.1 | Date: 2026-08-20 | Sprint: 110*

# Generate MVP Issues

**Flow**: `Load context → Mode detect → Analyze & break down → Assess → Plan allocation → [T1: Approve] → Phase-batched creation → Report`

Generate a complete issue backlog from project deliverables — analyzed, assessed, dependency-mapped, and allocated to phases. Phase-batched creation with progressive project-state updates makes this checkpoint-safe across conversations.

Three modes (auto-detected): **fresh** (first-time), **incremental** (new deliverables added), **resumption** (interrupted session).

---

## Architect-Pattern Activation (read from project-state)

generate-mvp consumes the Architect-pattern activation decided at setup-project STEP 1E. Two activation sources are checked in order:

1. **Project-state `[PROJECT_PHASES].*.entry_criteria` / `.exit_criteria` / `.depends_on` AND/OR `[DELIVERABLES].*.handoff_to` populated** → Architect-pattern landed at setup-project. Activation is derived directly from project-state.
   - If `[PROJECT_PHASES]` has populated entry/exit criteria → `workflow_tree` is active.
   - If any deliverable has populated `handoff_to` → `handoff_contracts` is active.
   - Phase Handoff Contracts (M1, STEP 3) reads phase `exit_criteria` to derive entry gates for the next phase.
   - **Partial-population handling**: If *some* phases have populated criteria and others are empty (e.g., setup-project was interrupted before all phases were articulated), `workflow_tree` is still considered active — but the M1 Phase Handoff Contracts sub-step must check each individual transition's source phase: a transition with empty `exit_criteria` falls back to inferring the entry gate from deliverable dependencies or to project-type defaults, exactly as for a legacy project. Same rule for `handoff_to`: a deliverable with empty `handoff_to` is treated as "no handoff declared for this deliverable" rather than blocking M1. The activation flag is project-wide; the per-transition / per-deliverable population is checked at consumption time.
2. **Project-state has empty Architect-pattern fields (legacy projects predating Architect landing)** → fall back to the §Architect-Pattern Activation matrix in `/nexus-setup-project` SKILL.md, keyed by `[PROJECT_DEFINITION].project_type`. Store the same three activation values (`scope_negation`, `handoff_contracts`, `workflow_tree`) for this session — generate-mvp consumes only `handoff_contracts` (M1) and the universal-depth-gated dependency graph (M2); `scope_negation` is setup-project-only.

**Self-hosting carve-out**: If project-state has `_self_hosting: true`, force all activation values to **Skip**. M1 Phase Handoff Contracts and the depth-gated M2 sub-step do not fire — NEXUS-on-NEXUS uses /nexus-organize-sprint for workflow concerns. M2 dependency-graph build still runs at minimum (universal — every project type needs blocked_by/blocks coherence) but without phase-handoff cross-referencing.

Store decisions in session memory for STEP 3 (Phase Handoff Contracts, Issue Dependency Graph) and STEP 5 (Dependency enforcement at creation).

---

### STEP 0: Load Context

Silent — the user sees only the outcome.

**Load these files** (check memory first for each):
- `Read .nexus/active/states/project-state.md` — deliverables, phases, project type, success constraints, constitution, risks, key resources
- `Read .nexus/active/registries/issues-registry.yaml` — existing issue IDs, duplicate detection, current numbering
- `Read .nexus/templates/issue-specification.md#[Section: Registry-Schema]` — field list and defaults for assessments. create-issue loads ISS-File-Structure independently when creating files.

**Extract from project-state for use throughout:**
- `[PROJECT_CONSTITUTION]` — if principles exist, these are constraints on ALL issues. Extract and hold for STEP 1 (issue design must respect them) and STEP 2 (flag issues that could violate).
- `[CONSTRAINTS_AND_RISKS].identified_risks` — extract High probability or High impact risks. In STEP 1: propose dedicated mitigation issues for High/High risks. In STEP 2: increase complexity/priority for risk-adjacent issues.
- `[KEY_RESOURCES]` — extract specifications, APIs, datasets. Reference in issue descriptions where relevant (STEP 1).
- `[PROJECT_PHASES].*.entry_criteria` / `.exit_criteria` / `.depends_on` — Architect-pattern phase scaffolding (populated by setup-project STEP 5.D). STEP 3 Phase Handoff Contracts reads `exit_criteria` to derive the entry gate for each phase transition.
- `[DELIVERABLES].*.handoff_to` — Architect-pattern deliverable handoff contracts (populated by setup-project STEP 4.F). Carries PAYLOAD/SUCCESS/FAILURE/TIMEOUT per deliverable pair. Read for issue-level dependency derivation in STEP 1 (cross-deliverable dependencies) and for Phase Handoff Contracts in STEP 3.
- `_self_hosting` — boolean flag. If `true`, Architect-pattern sub-steps in this skill skip (see §Architect-Pattern Activation above).

**Architect-Pattern Activation detection** (silent, runs once project-state is loaded):

Apply the two-source rule from §Architect-Pattern Activation at the top of this skill:

1. **Read from project-state first**: If any phase has populated `entry_criteria` / `exit_criteria` / `depends_on`, set `workflow_tree = active`. If any deliverable has populated `handoff_to`, set `handoff_contracts = active`.
2. **Fall back to project-type matrix**: If both fields are empty across the project (legacy state predating Architect landing), look up `[PROJECT_DEFINITION].project_type` in the matrix at `/nexus-setup-project` SKILL.md §Architect-Pattern Activation and store the three values.
3. **Self-hosting carve-out**: If `_self_hosting: true`, force all activation values to **Skip** regardless of project-state contents.

Store `handoff_contracts` and `workflow_tree` (and `scope_negation`, even though this skill doesn't consume it — kept for symmetry) in session memory. Consumed by STEP 3 (M1 Phase Handoff Contracts, M2 Issue Dependency Graph depth) and STEP 5 (M2 Dependency enforcement at creation).

**Load domain template**: Extract `project_type` from project-state `[PROJECT_DEFINITION]`. Load `.nexus/templates/project-types/{type}.md`. If no match, proceed without — use domain knowledge for breakdown proposals.

The template's `[Section: Issue-Breakdown]` provides: `breakdown_pattern` (how deliverables decompose), `typical_structure` (issue archetypes with typical complexity), `example_titles` (domain-native naming), and `Cross-Cutting Patterns` (common cross-deliverable issues). These guide STEP 1 proposals.

**Validate**: If project-state doesn't exist or has no deliverables, inform user and suggest running setup-project first.

**Context artifacts** (conditional): If `.nexus/supporting-files/project-context/` exists, read available artifacts:

| Artifact | Load? | Use in this operation |
|---|---|---|
| CONTEXT.md | If exists | STEP 1: "what exists" context for issue descriptions (Context element) |
| STRUCTURE.md | If exists | STEP 1: "where this fits" context for issue scope (Scope element) |
| CONVENTIONS.md | If exists | STEP 1: add "follows project conventions" to issue criteria when relevant |
| CONCERNS.md | If exists | STEP 0: severity filtering below. STEP 1: concern → issue proposals |

**CONCERNS.md severity extraction** — extract unresolved concerns (`- [ ]` entries) by severity tag `[HIGH/MEDIUM/LOW]`:

| Severity | Action |
|----------|--------|
| HIGH | Flag for issue proposal in STEP 1 — these should become dedicated issues |
| MEDIUM | Note for STEP 1 — may warrant issues or may fold into deliverable issues |
| LOW | Note for context only — unlikely to need dedicated issues |

Store concerns by severity for STEP 1. If concerns exist, note in display: "Known project concerns: {count} unresolved ({HIGH count} HIGH, {MEDIUM count} MEDIUM)."

**Detect operating mode**: Check `mvp_deliverables` + `enhanced_deliverables` for existing issue references. **Exclude `future_deliverables`** — these are intentionally not processed until promoted to MVP/Enhanced (their empty `issue_refs` is by design, not a signal for generation).

| Condition | Mode | Action |
|-----------|------|--------|
| No MVP/Enhanced deliverables have `issue_refs` populated | **Fresh** | First-time generation. Proceed to STEP 1 with all MVP + Enhanced deliverables. |
| ALL MVP/Enhanced deliverables have `issue_refs` populated | **Regeneration** | See Regeneration handling below. |

**Regeneration handling** (all deliverables already have issues):

Use AskUserQuestion: "All deliverables already have issues linked. What would you like to do?"
- **Add cross-cutting issues** — propose issues for shared concerns, infrastructure, or gaps not covered by existing issues. Proceeds as targeted incremental with existing issues as context.
- **Regenerate for specific deliverables** — choose which deliverables to redo. Archive selected issues first, then regenerate only those.
- **Full regeneration** — archive ALL existing issues, start fresh.
- **Cancel**

If "Full regeneration" or "Regenerate specific": **[T1: all levels ask]** "This will archive {N} existing ISS files to `.nexus/archived/issues/`, remove their registry entries, and clear issue_refs from project-state. This is reversible via /nexus-rollback but significant. Proceed?"

On confirmation:
1. Move ISS-*.md files to `.nexus/archived/issues/`
2. Remove entries from issues-registry.yaml
3. Clear `issue_refs` from affected deliverables in project-state
4. Clear `issues_planned` from affected phases in project-state
5. Verify all changes
6. Proceed as Fresh mode (full) or process selected deliverables (specific)
| SOME MVP/Enhanced deliverables have `issue_refs`, SOME don't | Check further → **Resumption** or **Incremental** | See below |

**Distinguishing resumption from incremental** (when some MVP/Enhanced deliverables have issue_refs and some don't):

| Signal | Mode | Meaning |
|--------|------|---------|
| sprint-state continue_with references generate-mvp with a plan summary | **Resumption** | Previous session was interrupted mid-generation |
| No continue_with reference to generate-mvp | **Incremental** | New deliverables were added (via /nexus-setup-project Update Mode) after a previous generation completed |

**Resumption mode**: A previous session was interrupted between phases or mid-batch.

Determine granularity:

| Boundary | Detection | Action |
|----------|-----------|--------|
| Between phases | All issues for completed phases exist in registry AND project-state has matching issue_refs and issues_planned | Clean resume at next phase |
| Mid-batch | Phase has some issues in registry but project-state issue_refs/issues_planned incomplete | Match existing issues by title against approved plan (from continue_with) to identify which remain |

Present what's done:

```
📋 RESUMPTION DETECTED
════════════════════════════════════════
Previous session created issues for:
  Phase 1 ({phase_name}): {N}/{total} issues ✓
  Phase 2 ({phase_name}): {N}/{total} issues {✓ or "partial"}

Still needed:
  {Phase with remaining issues}: {N} issues remaining

Resume from {next point}, or start fresh (will archive existing)?
```

Load existing issues from registry for dependency coherence. For mid-batch, match by title against plan. Skip to STEP 1 with remaining deliverables, or to STEP 5 if planning was complete.

**Incremental mode**: New deliverables were added after a previous generation. This is NOT a resumption — it's a new generation scoped to deliverables without issues.

1. Identify deliverables WITH `issue_refs` (existing — already have issues) vs WITHOUT (new — need issues)
2. Load existing issues from registry — these are dependency candidates for new issues
3. Check phase `issues_planned` for current capacity (existing issues already consuming sprint points)

```
📋 INCREMENTAL GENERATION
════════════════════════════════════════
Existing: {N} deliverables with {M} issues already created
New: {K} deliverables need issues

Existing issues loaded as dependency context.
Phase capacity accounts for existing allocations.

Generate issues for new deliverables? [Yes / Full regeneration / Cancel]
```

If "Yes": proceed to STEP 1 with only new deliverables, carrying existing issues as context. If "Full regeneration": warn about archiving existing, proceed as fresh if confirmed.

After loading (all modes), display:

```
📋 PROJECT LOADED
════════════════════════════════════════
Project: {title}
Type: {project_type} | Domain: {project_domain}
Template: {template name or "none — using domain knowledge"}
Breakdown pattern: {from template Issue-Breakdown or "general"}
Deliverables: {target_count} to process {+ "{existing_count} existing" if incremental}
Phases: {phase_count}
Existing issues: {count from registry}
Mode: {Fresh / Incremental / Resumption}
════════════════════════════════════════
If 8+ deliverables (fresh mode): "Systems Thinking is available if you'd like to map deliverable relationships before breakdown — just say 'load systems thinking.'"

---

### STEP 1: Analyze & Break Down Deliverables

Work through each deliverable and propose how it breaks down into issues. This is the collaborative core — use the loaded template's Issue-Breakdown section for domain-native language and structure.

**Template-guided breakdown**: If a domain template is loaded, use its `breakdown_pattern`, `typical_structure`, `example_titles`, and `Cross-Cutting Patterns` to shape proposals. If no template, use domain knowledge appropriate to the project type.

**Incremental mode context**: Before analyzing new deliverables, present a brief summary of existing issues that may be relevant: "Existing issues in this project: {ISS-XXX: title, ISS-YYY: title, ...}. I'll consider these as potential dependencies for the new deliverables."

**Large project batching** (10+ target deliverables): Process in groups of 4-5 deliverables. After each group: present group summary, get approval, offer checkpoint. This prevents STEP 1 from exhausting context before reaching creation. "Group 1 of {N}: {deliverable names}. Processing..."

**For each deliverable** (MVP first, then Enhanced — in incremental mode, only deliverables without issue_refs. **Never process future_deliverables** — they get issues only after promotion to MVP/Enhanced via /nexus-setup-project Update Mode):

**Deliverable quality gate** — before attempting breakdown, check:
- Description has substance (not just "build X" or a single word)
- Quality criteria has at least one specific, verifiable item (not just "it works")

If too thin: "Deliverable '{name}' doesn't have enough detail for meaningful issue creation. The description says '{description}' and criteria says '{criteria}'. Can you elaborate on what this includes and how we'd know it's done?" **STOP. Wait for user response.** If user can't elaborate: suggest returning to `/nexus-setup-project` ## Update Mode to refine this deliverable, or skip it and proceed with others.

Read name, description, quality_criteria, and target_phase. Consider how this deliverable relates to others (including deliverables that already have issues in incremental mode).

**Assess breakdown complexity**:

| Level | Issues | Signal | Example |
|-------|--------|--------|---------|
| Simple | 1-2 | Single component, clear approach | Config file, single report section |
| Moderate | 3-4 | Multiple components, some integration | Auth system, data pipeline with multiple sources |
| Complex | 5-7 | Sub-systems, novel approach, heavy integration | Real-time collaboration, full experimental study |

**Propose the breakdown** with reasoning. Match the template's breakdown pattern when the deliverable fits:

| Template Pattern | Typical Breakdown |
|-----------------|-------------------|
| Component-oriented | Analysis → foundation → implementation → integration |
| Methodology-oriented | Literature review → methodology design → data collection → analysis |
| Improvement-cycle | Assessment → design → pilot → rollout |

If a deliverable doesn't match the loaded template's pattern, adapt — use domain knowledge for that deliverable while following the template for others.

"For **{deliverable_name}** ({quality_criteria summary}), I'd suggest {N} issues:
1. {Issue title} — {brief rationale}
2. {Issue title} — {brief rationale}
..."

Ask: "Does this breakdown work? Would you split or merge any of these?"

**Cross-deliverable dependencies**: Note shared components or prerequisites — both among new deliverables AND with existing issues (incremental mode). "Both {deliverable A} and {deliverable B} need {shared component} — should that be its own issue?" In incremental mode: "{new deliverable} likely depends on existing ISS-{XXX} ({title}) — include as blocked_by?" Check the template's Cross-Cutting Patterns for common cross-deliverable issues.

**For each proposed issue, build a complete spec** (not just a title — this is the bridge to actionable work):

**A. Description** — must include all five elements:

| Element | What to write | Bad example | Good example |
|---|---|---|---|
| **What** | Concrete outcome | "Build auth" | "Implement JWT authentication with refresh tokens, password hashing (bcrypt), and session management" |
| **Why** | Connection to deliverable + vision | (missing) | "Enables secure user access for the Core Application deliverable" |
| **Scope** | In/out for THIS issue | (missing) | "Includes: register, login, logout, refresh. Excludes: OAuth, 2FA (separate issue)" |
| **Context** | What exists, what this builds on | (missing) | "Builds on User model from ISS-001. Uses Express middleware pattern." If CONTEXT.md loaded: reference relevant prior work. |
| **Approach hints** | Direction, not design | "Do it well" | "Backend feature: DB schema change + 3 API endpoints + auth middleware." If STRUCTURE.md loaded: reference where this fits in the architecture. |

A description missing any element is too thin for /nexus-analyze to work with effectively. The LLM proposes all five from the deliverable context + template patterns + key resources. The user validates.

**B. Success Criteria** — derive systematically, not generically:

1. Start from parent deliverable's `quality_criteria`
2. Extract the portion relevant to THIS issue's scope
3. Make each criterion **testable**: "User can X" or "System returns Y when Z" or "Document contains sections A, B, C"
4. Cover the issue's full scope — not just happy path:
   - Normal flow (the thing works)
   - Edge cases (boundary conditions relevant to this issue)
   - Error handling (what happens when it fails)
5. **Convention compliance**: if CONVENTIONS.md was loaded, add "Follows project conventions (CONVENTIONS.md)" as a standard criterion for implementation issues. Not needed for pure research or documentation issues.
6. **Bidirectional check**: if ALL issues' criteria pass → does the deliverable's quality_criteria fully pass? If not, a criterion is missing somewhere.

Bad: "Authentication works"
Good: "User can register with email+password (validation: email format, password 8+ chars). Login returns JWT (1h) + refresh token (7d). Invalid credentials return 401. Expired token returns 401 with refresh hint. Logout invalidates refresh token."

**C. Type and Dependencies**:

| Element | What to capture | Source |
|---|---|---|
| Type | Feature, Infrastructure, Research, etc. | Template typical_structure types |
| Dependencies | blocked_by, blocks, with narrative context (including existing issues) | Cross-deliverable analysis |

Priority, impact, and complexity are assessed in STEP 2. Target sprint is allocated in STEP 3.

**D. Deliverable Coverage Check** (after all issues for a deliverable are proposed):

Before moving to the next deliverable, verify coverage:

| Check | Question | If gap found |
|---|---|---|
| Forward | Every aspect of the deliverable description → at least one issue? | Add issue or expand existing issue's scope |
| Reverse | Every proposed issue → contributes to this deliverable? | Remove or reassign orphan issues |
| Criteria | If all issues' criteria pass → deliverable quality_criteria fully satisfied? | Add missing criterion to an issue |

"Coverage check for {deliverable}: {N}/{N} aspects covered. {gaps if any}."

This check is what prevents discovering missing work at /nexus-validate.

**Success constraints**: Use `success_constraints.mvp_minimum` to inform breakdown granularity — deliverables serving the minimum viable outcome deserve finer breakdown.

**Novel or exploratory deliverables**: When a deliverable involves significant uncertainty, propose an exploration/feasibility issue before committing to full implementation issues.

**Concerns as issues** (if CONCERNS.md was loaded in STEP 0): After processing deliverables, review the unresolved concerns:

- **HIGH severity**: Propose a dedicated issue for each. Frame as: "This concern ({concern}) should be addressed directly. Proposed issue: {title} — {approach}."
- **MEDIUM severity**: Evaluate whether the concern is already addressed by a deliverable issue. If yes, note the connection. If no, propose either a dedicated issue or suggest folding it into an existing deliverable issue.
- **LOW severity**: Note for awareness but don't propose issues unless the user requests.

Cross-reference: Some deliverable issues may already address concerns. Flag these connections: "{Deliverable issue} addresses concern: {concern}". This prevents duplicate work and shows coverage.

**Risks as issues** (if identified_risks were loaded in STEP 0): After concerns, review High/High risks:

- **High probability + High impact**: Propose a dedicated mitigation issue unless an existing deliverable issue already addresses it. Frame as: "Risk: {risk}. Proposed mitigation issue: {title} — {approach from risk.mitigation}."
- **High probability OR High impact (not both)**: Note for STEP 2 — these influence assessment scoring but don't necessarily need dedicated issues.

Cross-reference: Flag risks already covered by deliverable issues: "{Deliverable issue} mitigates risk: {risk}."

**Constitution compliance** (if [PROJECT_CONSTITUTION] has principles): After all issues proposed, check each proposed issue against constitution principles. Flag any issue whose approach could violate a principle:

> ⚠️ Constitution check: "{issue title}" may conflict with principle "{principle}". Adjust approach to: {suggested adjustment}.

Constitution violations must be resolved before proceeding — they are non-negotiable by definition.

**Key resources** (if [KEY_RESOURCES] populated): Reference relevant resources in issue descriptions where they provide implementation context (e.g., "Integrates with {API} from key resources", "Uses {dataset} documented in resources").

After all target deliverables, compile and present:

```
📊 DELIVERABLE BREAKDOWN
════════════════════════════════════════

{Deliverable 1 name} → {N} issues ({pattern from template})
  1. {Issue title} ({type})
     {1-line description summary}
     Criteria: {count} items | Deps: {blocked_by summary}
  2. {Issue title} ({type})
     ...

Cross-cutting (from template patterns + project context):
  1. {Shared component issue}
     ...

{if CONCERNS.md had unresolved entries}:
From project concerns (CONCERNS.md):
  HIGH severity — recommend dedicated issues:
  1. {Concern} → Proposed: {Issue title} ({type})
     {Why this concern warrants its own issue}
  
  MEDIUM severity — consider issues or fold into deliverables:
  1. {Concern} → {Proposed action: dedicated issue / fold into ISS-XXX / monitor only}

Concerns addressed by deliverable issues: {list concerns that existing deliverable breakdowns already cover}

{if identified_risks had High/High entries}:
From project risks:
  1. {Risk} → Proposed mitigation: {Issue title}
  Risks covered by deliverable issues: {list}

{if constitution principles exist}:
Constitution compliance: {N}/{N} proposed issues checked
  ⚠️ Adjustments needed: {list any conflicts, or "none"}

{if incremental}:
Dependencies on existing issues:
  • {new issue} → blocked_by ISS-{XXX} ({title})
  ...

────────────────────────────────────────
TOTAL: {N} new issues from {M} deliverables
Full specs prepared (descriptions, criteria, dependencies)
════════════════════════════════════════
```

**[T2: Balanced+Full ask | Streamlined: auto-approve if ≤10 issues, notify+log; ask if >10]**

Present the summary first. The user can ask to see the full spec for any individual issue. **STOP. Wait for user response.** Adjust breakdown per feedback before proceeding.

**Mental note**: If checkpoint fires, write the proposed breakdown to sprint-state continue_with. The breakdown can be recreated from project-state + template, but saving it avoids re-discussion.

---

### STEP 2: Assess Issues

For each proposed issue, assess priority, impact, complexity, and dependencies. Use the template's `typical_complexity` values as starting points, adjusted for this project's context.

**Priority** (when should this be done?):

| Level | Signal |
|-------|--------|
| Critical | Blocks multiple issues, on critical path to MVP minimum |
| High | Important for MVP, blocks at least one other issue |
| Medium | Valuable but other work can proceed without it |
| Low | Enhancement, polish, or future-phase work |

**Impact** (how much does this matter?):

| Level | Signal |
|-------|--------|
| Critical | Core architecture, data model, foundational methodology — failure cascades everywhere |
| High | Key user-facing deliverable, primary output |
| Medium | Supporting functionality, secondary deliverable |
| Low | Enhancement, convenience, nice-to-have |

**Complexity** (how much effort?):

| Score | Signal |
|-------|--------|
| 1-2 | Single file, straightforward, obvious approach |
| 3 | Multiple files, moderate decisions, some design needed |
| 4 | Significant design or multi-component work |
| 5 | System-wide impact, major architecture, or novel research |

Use template's typical_structure complexity as baseline and adjust per deliverable scope.

**Risk influence on scoring**: If identified risks from project-state relate to specific issues, factor them in:
- Risk-adjacent issues get +1 complexity (risk increases implementation uncertainty)
- Issues that mitigate High/High risks get priority bump toward Critical/High
- Note the risk connection: "Complexity adjusted +1 due to risk: {risk description}"

**Dependencies**: Map blocked_by and blocks. Include existing issues as valid dependency targets (incremental mode). The template's breakdown_pattern indicates the natural flow — component-oriented types chain analysis → foundation → implementation → integration; methodology-oriented types chain scoping → collection → analysis. Cross-phase dependencies follow from phase ordering.

**Circular dependency check**: After mapping all blocked_by/blocks relationships, trace dependency chains. If any issue appears in its own dependency path (A → B → C → A), flag:

> ⚠️ Circular dependency detected: {chain}
> This would prevent any issue in the cycle from starting.
> Break the cycle by removing one dependency? [Show options]

Present the cycle and let user choose which link to remove. Circular dependencies must be resolved before proceeding to STEP 3.

Present the full assessment:

```
📊 ISSUE ASSESSMENTS
════════════════════════════════════════

{Grouped by deliverable}:

  {Issue title}
    Priority: {P} | Impact: {I} | Complexity: {C}
    Blocked by: {deps or "none"} | Blocks: {list or "none"}

────────────────────────────────────────
SUMMARY:
  Total: {N} issues | {sum} complexity points
  Priority: {Critical} C / {High} H / {Medium} M / {Low} L
  Dependency depth: {max levels}
════════════════════════════════════════
```

**[T2: Balanced+Full ask | Streamlined: auto-approve, notify+log]**

"Do these assessments look right? Any priorities or dependencies you'd adjust?" **STOP. Wait for user response.**

**Mental note**: If checkpoint fires, write assessment results to continue_with. These involve nuanced judgment calls harder to recreate than the breakdown.

---

### STEP 3: Plan Phase Allocation

Map issues to project phases and estimate sprint allocation. Use actual phase names and objectives from project-state `[PROJECT_PHASES]`.

**Phase Handoff Contracts** (M1, project-type gated per §Architect-Pattern Activation):

**Note on handoff-contract levels**: This is a **project-level** handoff contract (between phases in project-state, typically spanning conversations/sprints). For how project-level and agent-level handoff contracts differ (shared PAYLOAD/SUCCESS/FAILURE schema; TIMEOUT first-class at project level, aspirational at agent level), read `nexus-setup-project/SKILL.md [Section: Handoff-Contract-Levels]`.

**Activation**: read `handoff_contracts` from session memory (set at STEP 0 by §Architect-Pattern Activation).

| Activation | Behavior |
|---|---|
| Full | Phase Handoff Contracts always declared for every phase transition. |
| Light | Sub-step offered via AskUserQuestion: [Declare phase handoffs / Skip phase handoffs]. On capture, proceed as Full. |
| Skip | Sub-step does not fire. Phases allocate without explicit entry-gate records. |

If activation is **Full** or the user opts in at **Light**:

**For each phase transition (Phase N → Phase N+1)**, declare:

- **Which issues in Phase N must complete before Phase N+1 issues can start** (typically: all issues in Phase N, or a designated subset)
- **Which deliverables cross the phase boundary** (from project-state `[DELIVERABLES]` — payload references)
- **The handoff contract** — PAYLOAD from Phase N's deliverables, SUCCESS condition for Phase N+1's entry

**Source**: Read project-state `[PROJECT_PHASES].{phase-id}.exit_criteria` (written by setup-project STEP 5.D). If `exit_criteria` is populated, use it directly as the entry gate condition for the next phase. If empty (legacy project), infer from deliverable dependencies or propose based on project-type defaults from the matrix.

**Write**: per-phase allocation record (in-memory for STEP 5 issue creation; the criteria themselves live in project-state):

```yaml
phase_allocation:
  - phase: analysis
    issues: [ISS-001, ISS-002, ISS-003]
    handoff_to_build:
      required_issue_scores: "all analysis scores ≥4"   # derived from phase.exit_criteria
      deliverables_ready: ["Data Model", "API Contract"]
      open_questions_resolved: true
  - phase: build
    issues: [ISS-004, ISS-005]
    depends_on: analysis
    entry_gate: "phase:analysis complete per handoff_to_build"
```

**Rationale**: Without explicit handoff contracts, phase transitions happen by convention ("Build starts when Analysis feels done"). Explicit contracts support checkpoint-safe multi-conversation work — the next conversation reads the entry gate and knows whether Build can proceed without re-deriving the phase boundary.

**Issue Dependency Graph** (M2, universal — depth gated by activation):

This sub-step **always runs** (every project benefits from explicit blocked_by/blocks declaration). Depth scales with activation:

| Activation | Depth |
|---|---|
| Full / Light | Algorithmic graph build + cycle detection + cross-reference to phase allocation (flag independent issues in later phases). |
| Skip | Minimum: blocked_by/blocks declared per issue + cycle detection. No cross-phase coherence flagging. |

**For each issue proposed in STEP 1, declare**:

- `blocked_by` — which other issues (existing or proposed in this batch) must Resolve before this can start
- `blocks` — which other issues depend on this (inverse of blocked_by, for graph completeness)

**Build the graph algorithmically**:

- If ISS-A's Solution-Design references output from ISS-B → ISS-A `blocked_by` ISS-B
- If ISS-A modifies a file ISS-B reads → order by functional dependency
- If ISS-A is a migration prerequisite for ISS-B → `blocked_by`
- If ISS-A's parent deliverable has a `handoff_to` entry pointing at ISS-B's parent deliverable (from `[DELIVERABLES].handoff_to`) → ISS-A `blocks` at least one issue under the target deliverable; resolve to the specific issue at user-confirmation time

**Collaborative mode**: Present the proposed graph. User adjusts, merges, or challenges. Final graph writes to issues-registry per-issue `blocked_by:` and `blocks:` fields at STEP 5 creation.

**Cycle detection** (hard halt): Before writing anything, walk the graph and verify no cycles. If a cycle is detected (A → B → C → A), surface immediately and ask the user to break one edge. **Do not proceed to STEP 5 creation until the graph is acyclic.** Preserves the existing STEP 2 "Circular dependency check" as the post-assessment validation; this M2 graph build is the formalization.

**Cross-reference to phase allocation** (Full/Light only): Issues in later phases should be `blocked_by` at least one issue in the preceding phase, unless genuinely independent. Flag independent issues — sometimes correct (parallel tracks), sometimes a missed dependency.

**Allocation approach:**
1. Group issues by their parent deliverable's `target_phase`
2. Within each phase, order by dependency level (no-dependency issues first)
3. Estimate sprints: ~9 complexity points per sprint, respecting dependency ordering
4. **In incremental mode**: account for existing `issues_planned` capacity — read complexity of existing issues from registry to calculate how many points are already allocated per phase
5. Cross-check: does total allocation (existing + new) match the phase's `estimated_sprints`? Flag significant differences

All issues get `target_sprint: "TBD"` — actual sprint numbers are assigned by organize-sprint, which has sprint-queue context. This operation handles phase allocation and dependency ordering; sprint allocation is a separate concern.

```
📊 PHASE ALLOCATION PLAN
════════════════════════════════════════

Phase 1: {phase_name} ({estimated_sprints} sprints estimated)
  {if incremental: "Existing: {N} issues, {P} points"}
  New Group 1: {points} points
    • {Issue title} ({priority}, complexity {C})
    • {Issue title} ({priority}, complexity {C})
  {if incremental: "Phase total: {total} points (~{sprint_est} sprints)"}

Phase 2: {phase_name} ({estimated_sprints} sprints estimated)
  ...

────────────────────────────────────────
TOTAL: {N} new issues | {sum} new points
{if incremental: "Combined with existing: {total} issues | {total_points} points"}
~{sprint_count} sprints estimated
Target sprints: TBD (use organize-sprint to allocate)
════════════════════════════════════════
```

**[T2: Balanced+Full ask | Streamlined: auto-approve, notify+log]**

**STOP. Wait for user response.** If allocation doesn't fit estimated sprint counts: "Phase 2 was estimated at 2-3 sprints but the issues total {X} points, suggesting {Y} sprints. Options: adjust phase estimate, simplify issues, or defer deliverables to a later phase."

---

### STEP 4: Spec Review & Approval

**[T1: all levels ask]** Final review gate before any issues are created.

**Always present the spec summary** — not just counts. This is the last chance to catch thin specs before they become ISS files.

```
📋 ISSUE SPECS FOR REVIEW — {N} issues from {M} deliverables
════════════════════════════════════════

PHASE 1: {phase_name} — {N} issues, {P} points
─────────────────────────────────────────

  ▸ {Issue title} ({type}, C:{complexity}, {priority})
    {2-3 sentence description summary — What + Why + Scope}
    Criteria: {count} items — {first criterion preview}...
    Deps: {blocked_by summary or "none"}
    Coverage: serves {deliverable_name}

  ▸ {Issue title} ({type}, C:{complexity}, {priority})
    ...

PHASE 2: {phase_name} — {N} issues, {P} points
─────────────────────────────────────────
  ...

────────────────────────────────────────
COVERAGE: {N}/{N} deliverables fully covered
CONSTITUTION: {N}/{N} issues compliant {or "⚠️ {count} adjustments needed"}
TOTAL: {sum} points | ~{sprint_count} sprints
════════════════════════════════════════
```

**STOP. Wait for user response.**

Use AskUserQuestion:
- **Create all** — specs look good, proceed to phase-batched creation
- **Deep review** — walk through each issue one by one with full spec (complete description, all criteria, all dependencies). Modify/accept/skip per issue.
- **Adjust** — return to STEP 1 (breakdown) or STEP 2 (assessment)
- **Cancel** — abort operation

**"Deep review"**: For each issue, present the complete spec:

```
ISS: {title}
Type: {type} | Priority: {P} | Impact: {I} | Complexity: {C}
Deliverable: {parent_name}

DESCRIPTION:
  What: {concrete outcome}
  Why: {connection to deliverable + vision}
  Scope: {in/out for this issue}
  Context: {what exists, builds on}
  Approach: {direction hints}

SUCCESS CRITERIA:
  1. {testable criterion}
  2. {testable criterion}
  ...

DEPENDENCIES:
  Blocked by: {list or none}
  Blocks: {list or none}

[Accept / Modify / Skip]
```

After all reviewed, return to approval with revised plan.

---

### STEP 5: Phase-Batched Creation

Create issues one phase at a time. After each phase batch, update project-state and offer a checkpoint.

**Before starting**: Load /nexus-create-issue skill if not in memory. Initialize a **title→ID mapping** — in incremental mode, pre-populate with existing issues from registry (`{title} → ISS-{XXX}`) so new issues can reference them as dependencies immediately.

**For each phase** (in order, only phases with new issues to create):

**Large phase handling**: If a phase has more than 8 new issues, split into sub-batches of ~8 with intermediate checkpoints.

**A. Create the batch.** Process issues in dependency order (no-dependency issues first). For each issue:

Resolve dependency references: replace working titles in `blocked_by` and `blocks` with actual ISS-XXX IDs using the title→ID mapping. This includes references to existing issues (pre-populated in incremental mode). Issues referencing not-yet-created issues in `blocks` are resolved in STEP 5B/5E.

**Dependency enforcement at creation** (M2): When creating each issue, populate `blocked_by:` and `blocks:` from the graph built in STEP 3 Issue Dependency Graph. Verify each referenced target either (a) already exists in the registry (resolved via title→ID mapping) or (b) is scheduled for creation in the current batch (deferred to STEP 5B within-phase linking or STEP 5E cross-phase resolution). If a referenced target is neither present nor scheduled, surface immediately — this is a graph drift (something was removed from the plan after STEP 3 approval). On drift: surface to user with options [Remove the dependency reference / Add the missing target back to the plan / Cancel and re-run STEP 3].

Invoke /nexus-create-issue in backend mode with the issue's full context. Display progress: `[{n}/{N}] ✓ ISS-{XXX}: "{title}"` for each success, `[{n}/{N}] ❌ Failed: "{title}" — {error}` for failures. On success, add to title→ID mapping.

If an issue creation fails, track it but continue with the batch. Failed issues can be retried individually after the operation completes.

**B. Link within-phase dependencies.** After the batch, resolve forward references within this phase. For each created issue that listed `blocks` targets (by working title), check if the target was created in the SAME batch. If so, patch the target's `blocked_by` in the registry with the blocker's actual ID. Cross-phase forward references are handled in STEP 5E after all phases.

**C. Update project-state.** Patch two sections:
- `[DELIVERABLES]`: Update `issue_refs` with created issue IDs for each deliverable in this batch
- `[PROJECT_PHASES]`: Append new issue IDs to `issues_planned` for this phase (preserving existing IDs in incremental mode)

Verify both patches applied.

**D. Phase batch report and checkpoint.**

```
✅ Phase {N}: {phase_name} — COMPLETE
────────────────────────────────────────
Created: {success}/{total} issues
Failed: {fail_count} {if any: "(retry individually via create-issue)"}
Project state: ✓ Updated (deliverable refs + phase plan)
────────────────────────────────────────
```

After each batch, check context level. If approaching yellow zone (~70%), strongly recommend checkpoint. If in yellow zone or above, save checkpoint with continue_with:

```
WHAT: Resume generate-mvp at Phase {N+1}. Phases 1-{N} complete ({X} issues created).
WHY: Phase-batched issue generation in progress.
CONTEXT: Remaining phases {N+1}-{M} have {Y} issues to create.
PLAN SUMMARY: {For each remaining: title, type, priority, impact, complexity, blocked_by, blocks.
  Include descriptions/criteria. Mark user-modified specs with [USER-MODIFIED] suffix
  so resuming session preserves user choices instead of re-deriving.}
ID MAPPING: {title→ISS-XXX for all created issues, for dependency references}
```

If context hits 80% **mid-batch**, auto-save immediately. Note: "Resume mid-Phase {N}, issue {X} of {Y} created. Remaining: {titles and plan fields}."

**On resumption**: Load domain template. For each remaining issue in plan summary:
- Fields marked `[USER-MODIFIED]`: use exactly as saved — these reflect user decisions
- Unmarked descriptions/criteria: re-derive from deliverable context + template (minor wording variation acceptable)
- Structural fields (priority, complexity, dependencies): use from plan summary as-is

If more phases remain and context allows, proceed to next batch.

**E. Final cross-phase dependency resolution.** After ALL phases are created, resolve remaining forward references. For each issue with `blocks` targets in other phases (by working title), look up the target's ISS-XXX ID from the title→ID mapping and patch:
- The target's registry entry `blocked_by` with the blocker's ID
- The blocker's registry entry `blocks` with the target's ID

If a resumed session only created some phases, this step runs on whatever exists — partial cross-phase linking is better than none.

---

### STEP 6: Completion Report

**If all phases complete:**

```
✅ MVP ISSUE GENERATION COMPLETE
════════════════════════════════════════

CREATED: {N} issues from {M} deliverables
EFFORT: {sum} points | ~{sprint_count} sprints

BY PHASE:
  Phase 1: {name} — {N} issues, {P} points
  Phase 2: {name} — {N} issues, {P} points
  ...

{if any failures}:
FAILED ({count}):
  • {title} — {error} (retry via 'create issue')

PROJECT STATE: ✓ All deliverables linked, all phases populated
════════════════════════════════════════
```

**[T2: Balanced+Full ask | Streamlined: auto-select based on context (<60% → organize, >60% → done), notify+log]**

If sufficient context remains (green zone), offer next step via AskUserQuestion:
- **Organize sprint now** — invoke /nexus-organize-sprint
- **Done for now** — save checkpoint

If context is in yellow zone or above, don't offer organize-sprint. Save checkpoint: "Context at ~{X}%. Organize-sprint will be first objective next conversation."

**If partial completion** (context ran out mid-generation):

```
📋 PARTIAL COMPLETION — CHECKPOINT SAVED
════════════════════════════════════════

COMPLETED:
  {Phase list with issue counts}

REMAINING:
  {Phase list with deliverable counts}

Total so far: {N}/{total} issues created
Project state: ✓ Updated through Phase {last_complete}

Next conversation will resume at Phase {next}.
════════════════════════════════════════
```

---

## Gate Reference

| Gate | Step | Tier | Full | Balanced | Streamlined |
|---|---|---|---|---|---|
| Regeneration archive | 0 | **T1** | Ask + consequences | Ask + consequences | Ask + consequences |
| Breakdown approval | 1 (end) | **T2** | Ask | Ask | Auto-approve ≤10 issues, notify+log |
| Assessment approval | 2 (end) | **T2** | Ask | Ask | Auto-approve, notify+log |
| Allocation approval | 3 (end) | **T2** | Ask | Ask | Auto-approve, notify+log |
| Create issues | 4 | **T1** | Ask | Ask | Ask |
| Next steps | 6 | **T2** | Ask | Ask | Auto-select by context %, notify+log |

---

## End-of-Workflow Checklist

Before STEP 6 completion report, verify:

- [ ] All approved issues created via /nexus-create-issue (or failures tracked)
- [ ] project-state [DELIVERABLES] `issue_refs` updated for all processed deliverables
- [ ] project-state [PROJECT_PHASES] `issues_planned` updated for all phases with new issues
- [ ] Cross-phase dependencies resolved (STEP 5E)
- [ ] Within-phase dependencies resolved (STEP 5B per batch)
- [ ] All project-state patches verified on disk
- [ ] Failed issues (if any) listed with error details for manual retry

---

## Error Recovery

| Problem | Recovery |
|---|---|
| project-state has no deliverables | Inform user: "No deliverables defined. Run /nexus-setup-project first." |
| Domain template not found | Proceed without — use domain knowledge. Inform user. |
| create-issue fails for one issue | Track failure, continue batch. List in completion report for manual retry. |
| create-issue fails repeatedly | Stop batch. Report which issues succeeded. Checkpoint for resumption. |
| Circular dependency detected | Present cycle to user. Let user choose which link to remove (STEP 2). |
| Context runs out mid-batch | Auto-checkpoint at 80%. STEP 5D saves continue_with with plan summary + ID mapping. |
| Resumption detects stale plan | Plan in continue_with doesn't match current project-state. Offer: re-derive from project-state (safe) or use saved plan (if user made specific modifications). |
| Incremental mode capacity overflow | Phase total exceeds estimated sprints. Flag in STEP 3 and let user adjust. |
