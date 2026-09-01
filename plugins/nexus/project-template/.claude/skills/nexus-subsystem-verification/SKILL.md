---
name: nexus-subsystem-verification
description: Verify subsystem integrity across NEXUS domains
disable-model-invocation: true
---
*Version: 2.4.0 | Date: 2026-08-26 | Sprint: 111*

# Subsystem Verification

**Flow**: Select domain → Three-source triangulation → Load all domain files → Per-file examination (connections + targets + compliance) → [T2: approve fixes per file] → Systemic patterns → Mental traces → Report

Deep domain-level verification. Three-source triangulation establishes truth (routing map × NEXUS-Architecture.md × disk), then per-file examination cross-checks connections, targets, and compliance. Mental execution traces validate active workflow files end-to-end.

**Constraint**: One domain at a time. All domain files loaded together for cross-reference capability (adaptive — falls back to one-at-a-time if context constrained).
**Pattern**: PAT-063 domain-coherence checklist (formerly PAT-082, merged Sprint 110) — 7 dimensions (routing, scale/unit, memory-first, N-place update, cross-op compatibility, info flow, field/schema) + caller/consumer stale-reference checks.

Findings follow a fix-or-defer rule: minor fixes (single file, < 5 patches) applied inline with consent. Major fixes (multi-file or architectural) deferred as new issues.

---

### Posture (Verification-Class Core VC-1)

This skill runs **adversarial by default**. I assume the artifact under verification has a problem until scan evidence proves otherwise — a "✅ clean" verdict is *earned* by showing what was examined, never reached by the mere absence of anything that caught the eye. I challenge my own clean verdicts rather than confirming them.

Not complexity-conditional: a small or familiar domain gets the same adversarial scan as a large one — familiarity is exactly where skim-and-pass happens. (operation-skill-template §Discipline Enforcement Layer → Verification-Class Core.)

---

### STEP 0: Load Context and Select Domain

**A — Load verification status.** `Read system-state.md#[Section: Subsystem-Verification]` (memory-first). Extract last-verified dates and status per domain. If section doesn't exist (first run): all domains show "never" — fields will be created at STEP 6.

**B — Present domain menu:**

```
═══ SUBSYSTEM VERIFICATION ═══

Select a domain to verify:

│ #  │ Domain           │ Last Verified      │ Status       │
│ 1  │ Project          │ {date|never}       │ {status}     │
│ 2  │ Sprint           │ {date|never}       │ {status}     │
│ ...│ ...              │ ...                │ ...          │

Enter domain number or name: _
Wait for user selection.

---

### STEP 1: Three-Source Triangulation

Establish the authoritative file list for the selected domain by cross-checking three independent sources. Any discrepancy is a finding.

**A — Source 1: System Paths.** Extract from [Section: Routing-Map] in memory (always loaded at bootstrap). System Paths defines files per domain under `operations:` keys and `core:` / `registries:` lists.

**B — Source 2: NEXUS-Architecture.md.** Load three sections:

1. `Read NEXUS-Architecture.md#[Section: System-Overview]` — domain file count from Domain Summary table, skill counts, and summary prose line for internal consistency check.
2. `Read NEXUS-Architecture.md#[Section: Domain-{Name}]` — relationship table (From/To/Op/Trigger/Section/Notes format, map 4.0.0+) for connection data, plus the section's **Skills** line carrying each skill's version inline — those are the version cells to check against disk.
3. `Read NEXUS-Architecture.md#[Section: File-Inventory]` — category-count table (skills, skill `.md` files, templates, active/archived issues and patterns, seeds, guides, sprint and maintenance-cycle folders …). Since map 4.0.0 per-file versions live in each Domain section's Skills line, not here — use File-Inventory for count consistency against disk (e.g. active patterns, cycle folders).

While System-Overview is loaded, run a quick internal consistency check: does the summary prose sentence match the File Statistics table and Domain Summary totals? If mismatch: record as a finding and propose a prose patch. This check applies regardless of which domain is being verified — it costs nothing since System-Overview is already loaded.

**C — Source 3: Disk reality.** For skill domains (Project, Sprint, Issue, Pattern, Maintenance, Documentation): `Glob '.claude/skills/nexus-{domain-related}*/SKILL.md'`. For Core Protocols: the CLAUDE.md `[Section: …]` blocks + `Bash ls` on `.nexus/active/` (framework files). For Memory: `Glob '.claude/skills/nexus-{index-sprint,prune-memory}/SKILL.md'` + `Bash ls .nexus/memory/` (7 JSONL + SCHEMA.md). For Registries: `Bash ls` on `.nexus/active/registries/`. For Methodology skills: `Glob '.claude/skills/nexus-{methodology}/SKILL.md'` + check companion files (types/, modes/, complex.md, batch.md, references/). For Cognitive: `Glob '.claude/skills/nexus-{mental-models,problem-solving,strategic}/SKILL.md'`. For System: `Glob '.claude/skills/nexus-{start,menu,checkpoint}/SKILL.md'`.

**D — Cross-check all three sources.** Build a unified file inventory:

```
📊 Three-Source Triangulation: {domain}

│ File                    │ Sys Paths │ Arch.md │ Disk │ Status    │
│ {filename}              │ ✓          │ ✓       │ ✓    │ ✅ aligned │
│ {filename}              │ ✓          │ ✗       │ ✓    │ ⚠️ not in map │
│ {filename}              │ ✗          │ ✓       │ ✗    │ 🔧 registered but missing │
│ ...                     │            │         │      │           │
| Discrepancy | Severity | Action |
|-------------|----------|--------|
| On disk but not in System Paths | ⚠️ | Propose CLAUDE.md [Section: Routing-Map] patch or ask user |
| On disk but not in NEXUS-Architecture.md | ⚠️ | Propose NEXUS-Architecture.md patch |
| In System Paths but not on disk | 🔧 | Ask user — deleted file? wrong path? |
| In NEXUS-Architecture.md but not on disk | 🔧 | Propose NEXUS-Architecture.md removal or ask user |
| In System Paths but not in NEXUS-Architecture.md (or vice versa) | ⚠️ | Propose patch to align |
| All three aligned | ✅ | No action |

Prompt user with proposed patches for any discrepancies. Wait for approval before proceeding.

**E — Produce "domain core" file list.** After resolving discrepancies, the aligned list becomes the verification target. Order files for examination: operation files first (active workflow), then supporting files.

"Governed by this domain" means **lifecycle ownership** — the domain creates, defines the schema for, writes to meaningfully, and archives the file. Physical location (e.g., `states/` folder) or Cross-Cutting table membership does not determine governance. Example: project-state.md is governed by Project domain (created by setup-project, 4 of 6 Project ops write to it, archived by close-project), even though it appears in Cross-Cutting as a shared state file.

**Note**: system-state.md is governed by the Maintenance domain (11 of 13 writers are maintenance ops, health-diagnostic aggregates it, /nexus-maintain orchestrates its lifecycle). When verifying the Maintenance domain, include system-state.md as a domain-governed state file and verify its structure against system-state-template.md.

Include domain-governed state files for full template-vs-file examination. State files that are merely consumed (read-only by this domain) get only outbound target verification in STEP 3C.

Include domain-governed templates and specs. Ownership follows the same lifecycle principle: the domain whose primary instantiation operation creates files from the template governs it. Consult NEXUS-Architecture.md Cross-Cutting > Templates (Domain Owner column) for the full ownership mapping. Domain-governed templates are examined in STEP 3D using the three-source bidirectional check — not the same unidirectional check used for state files.

```
📋 Domain Core Files for {domain} ({N} files):
  Operations: {list}
  Domain state files: {list — if governed by this domain}
  Domain templates/specs: {list — if governed by this domain}
**VERIFICATION GATE — STEP 1:**
- [ ] All three sources cross-checked
- [ ] Discrepancies resolved (patched or acknowledged by user)
- [ ] Domain core file list produced and ordered

⛔ GATE: Do not proceed to file examination with an unresolved file list — misaligned baseline invalidates all downstream checks.

---

### STEP 2: Load Map Context

Load NEXUS-Architecture.md sections that will be reused across all file examinations in this domain. Load once, keep in memory for the entire domain verification.

**A — Domain relationships.** `Read NEXUS-Architecture.md#[Section: Domain-{Name}]`. This provides the complete relationship table (From/To/Op/Trigger/Section/Notes) and Cross-Domain Boundaries narrative for the selected domain.

**B — Cross-cutting context.** `Read NEXUS-Architecture.md#[Section: Cross-Cutting]`. This provides registry readers/writers tables, state file readers/writers tables, and template governance chains.

**C — Load audit template.** Select the appropriate template based on domain type:

| Domain | Template | Rationale |
|---|---|---|
| Methodology (Analyze, Build, Validate, Research, Maintain) | `methodology-skill-template.md` | Multi-file architecture, type routing, checkpoint continuity |
| All other domains (Issue, Sprint, Project, Pattern, Maintenance ops, Documentation) | `operation-skill-template.md` | Single-file workflows, gate annotations, scan boundaries |

Read the selected template (memory-first). Used as audit checklist in STEP 3D compliance checks.

**Maintenance domain note**: When verifying the Maintenance domain, operation-skill-template.md is simultaneously the audit reference and a subject of examination. Examine by structural inspection — are checklist items current? — not by applying the checklist to itself.

**D — Load domain-specific references.** From NEXUS-Architecture.md Cross-Cutting templates table, identify which templates and specs govern files in this domain. Load them now — they'll be reused across all file examinations:
- Templates: e.g., `project-state-template.md` for Project domain, `issue-specification.md` for Issue domain
- Specs: e.g., `issue-specification.md#[Section: Registry-Schema]` for operations touching issues-registry

```
📚 Verification References Loaded:
  Map context: NEXUS-Architecture.md [{domain}] + [Cross-Cutting]
  Audit: {methodology-skill-template.md or operation-skill-template.md}
  Templates: {list}
  Specs: {list}
All references remain in memory throughout the domain verification — do not reload per file.

**E — Load all domain files.** Read all files from the domain core list (STEP 1E) into context at once. This enables cross-referencing between domain files during examination.

```
📂 Loading {N} domain files for cross-reference:
{for each}: • {filename} ({lines} lines)
Total: ~{tokens}K estimated
```

**Context check**: Before loading, estimate total size. If loading all files would push context above 60%, fall back to one-at-a-time loading (load each at STEP 3A instead). Display: "⚠️ Domain too large for bulk loading at current context ({current}%). Loading files individually."

> **Mental note**: Domain context loaded. {N} files in memory. References: {template}, {specs}. If checkpoint → save domain, files loaded, references loaded.

---

### STEP 3: Per-File Deep Examination

For each file in the domain core list from STEP 1E, execute this full examination sequence. Process one file at a time — complete all sub-steps before moving to the next file.

---

#### STEP 3A: Load and Inspect

**Cognitive anchor** — before examining this file, confirm readiness:
- Operation file loaded? Governing template/spec already in memory from STEP 2D?
- Verification depth: section + field level for writes, not just file existence.
- Widget rule: 2+ findings → `AskUserQuestion tool` for approval.

Use file from memory (loaded at STEP 2E). If one-at-a-time mode: Read the file now. Process in this cognitive order:

1. **Frontmatter first** — extract name, description, disable-model-invocation. Verify name matches directory name, description is accurate.
2. **Content scan** — scan for all file operations (Read, Write, Edit, Grep references) and skill invocations (`/nexus-*` references). Build the connection inventory: what files it reads, what files it writes, what skills it invokes.
3. **Version** from file header (if present — skills may not have version headers).

---

#### STEP 3B: Three-Way Connection Alignment

Cross-check every connection across two primary sources: **SKILL.md content** (ground truth — what the skill actually does) and **NEXUS-Architecture.md** (map claim). The **routing map** in [Section: Routing-Map] is a third source for command trigger alignment.

Build alignment table:

```
📊 Connection Alignment: {skill_name}

│ Connection (To)           │ Op      │ Content │ Arch.md │ Routing │ Status    │
│ {target_file}             │ {Read}  │ ✓       │ ✓       │ N/A     │ ✅ aligned │
│ {/nexus-X skill}          │ {invoke}│ ✓       │ ✓       │ ✓       │ ✅ aligned │
│ {target_file}             │ {Write} │ ✓       │ ✗       │ N/A     │ ⚠️ map missing │
│ ...                       │         │         │         │         │           │
| Discrepancy | Meaning | Fix Target |
|-------------|---------|------------|
| In content but not in NEXUS-Architecture.md | Map incomplete — missed relationship | Patch NEXUS-Architecture.md |
| In NEXUS-Architecture.md but not in content | Map stale — relationship no longer exists | Patch NEXUS-Architecture.md |
| Skill invocation in content but not in routing map | Routing incomplete | Patch CLAUDE.md [Section: Routing-Map] |
| In routing map but skill doesn't exist | Routing stale | Patch CLAUDE.md [Section: Routing-Map] |
| Section target mismatch (map says #[Section: X], content reads different) | Precision error | Fix map to match content |

**NEXUS-Architecture.md relationship updates — always bundle, never defer**: When any discrepancy of the form Content ✓ / Arch.md ✗ is found (new relationship, changed op type, changed section target), the NEXUS-Architecture.md Domain-{Name} relationship table patch is always included in the STEP 3E approval batch. Never defer NEXUS-Architecture.md relationship updates to a later conversation — the map must stay current as a direct output of every verification pass. If the domain section for the target file doesn't exist in NEXUS-Architecture.md, that itself is a finding.

**Additional dimension checks during alignment** (PAT-063 domain-coherence checklist dims 1b, 3, 6 — formerly PAT-082):

- **Update Protocol (Dim 3)**: For connections that write scores or state — does the operation perform the correct number of updates? (e.g., issue phase scores require two-place update: registry + sprint-state). If only one target is present, flag as protocol violation.
- **Scale/Unit Consistency (Dim 1b)**: For connections that read/write numeric values — are scales consistent between producer and consumer? (e.g., 0-5 vs 0-10 vs 0-100, percentages vs decimals). Compare across all connections touching the same field.
- **Information Flow Clarity (Dim 6)**: For each connection, verify the data flow is unambiguous: WHAT data is passed (field names), WHERE it goes (target section/field), HOW it's formatted (prefixed YAML, Edit tool, etc.), WHEN it triggers (condition or step). NEXUS-Architecture.md Notes column captures this — cross-check those notes against SKILL.md content reality.

**Caller verification**: For each skill that invokes this skill (found via Grep for `/nexus-{this-skill}` across all skill files), verify the invocation is correct and the caller's NEXUS-Architecture.md entry reflects this relationship. Stale caller references are a maintenance risk — callers get refactored but callees' NEXUS-Architecture.md entries are not updated.

For each discrepancy: record the finding with proposed fix. Do NOT present for approval yet — track findings mentally across 3B, 3C, and 3D, then present all together at STEP 3E (single approval point per file).

---

#### STEP 3C: Outbound Target Deep Verification

##### Target Loading Strategy

NEXUS-Architecture.md already declares all outbound targets for every file in the domain before examination begins. Use this to batch target loading rather than making individual Read calls per connection.

**Before examining the first file's outbound targets:**
1. From NEXUS-Architecture.md domain relationships (loaded in STEP 2A), collect all unique target files across the entire domain
2. Identify high-overlap targets — files targeted by multiple domain core files (e.g., project-state.md targeted by 4 of 6 Project ops)
3. For high-overlap targets: load fully at the start of STEP 3C for the first file that needs them — they stay in context for all subsequent files
4. For single-use targets: load when the file that needs them is being examined

**For each subsequent file's STEP 3C:**
- Check memory first — if the target is already loaded from a previous file's examination, verify against cached content (📌). Zero additional Read calls.
- Only load targets not yet in context.

**Loading depth per target:**
- Target referenced by multiple domain files at multiple sections → load full file
- Target referenced at a single section → load that section only
- Registry/state files with write contracts to verify → load full file (need field-level inspection)

This amortizes target loading cost across all domain files. For domains with high target overlap, most targets are cached after the first 1-2 file examinations.

---

For each outbound connection confirmed in STEP 3B (present in Execute), verify target accessibility AND data contract against loaded targets. Verification depth depends on operation type:

**READ / LOAD targets:**
1. `Read tool(target)` — file exists
2. If section specified: `Read tool(target, startMarker, endMarker)` — confirm section markers exist
3. If specific fields referenced in the operation's logic: verify those field names appear in the target section

**WRITE / UPDATE / PATCH targets:**
1. `Read tool(target)` — file exists
2. If section specified: partial read to confirm section markers exist
3. Load governing template/spec for this target (should be in memory from STEP 2D)
4. Extract ALL field names the operation writes to
5. Verify EVERY field name exists in the template/spec
6. Verify field formats match (array vs scalar, YAML vs markdown, prefixed vs nested)

**Skill invocation targets** (`/nexus-*`):
1. Verify `.claude/skills/nexus-{name}/SKILL.md` exists via Read tool
2. If step files referenced: verify `steps/` directory contents

**Registry AND state file data contract verification** — for operations that read or write registries OR state files, trace the exact data contract with equal depth:

For EACH registry or state file this operation touches:
1. `Read tool(target)` — file exists
2. If section specified: partial read to confirm section markers exist
3. Extract ALL field names the operation reads/searches — **`grep -c` each one in the target** (see Mechanical Field Verification below)
4. Extract ALL field names the operation writes/updates — **`grep -c` each one in the target**
5. Load governing template/spec (from STEP 2D memory) — verify field names match authoritative schema
6. Verify data formats match between operation expectations and actual target (array vs scalar, YAML vs markdown, prefixed vs nested, numeric scale)
7. For write operations: verify the skill's write method is compatible with the target's structure (e.g., prefixed YAML needs unique context for Edit tool, section content needs section markers for Edit tool)

##### Mechanical Field Verification (not read-and-judge)

⚠️ **Reading the target and judging that a field "looks present" is not verification.** A phantom key — a field the operation reads or writes that exists nowhere in the target — survives a careful read, because the reader confirms the fields they *see* rather than the fields the operation *names*. One survived two full verification passes this way (`ISS-XXX.sprint:`, where the schema field is `target_sprint`).

For every field name extracted at steps 3–4, run the count **against the target file**, not the tree:

```bash
grep -c '^ISS-[0-9]*\.{field}:' .nexus/active/registries/issues-registry.yaml   # prefixed registry key
grep -c '{field}:' {target_state_file}                                          # state-file field
```

- **`0` is a finding**, not an absence of one. Record it as a phantom field and flag `🔧`.
- Report the **Fields column as `{resolved}/{extracted}`** — never a bare ✓. `12/12` and `11/12` are different verdicts; a ✓ cannot express the second.
- `resolved < extracted` → the operation names a field its target does not have. Flag the file, do not pass it.

**Before classifying a reference as dangling, grep the whole live tree** — a field may have moved rather than vanished:

```bash
grep -rn '{field}' .claude .nexus --include='*.md' --include='*.yaml'
```

⚠️ **Classify prose separately from keys** (📐 PAT-142, too-broad direction). A tree-wide grep returns narrative mentions — issue descriptions, sprint-state decisions, verification notes — that are *descriptions of* a key, not instances of it. A key is at key position (line start, or `^{PREFIX}-[0-9]*\.`); anything else is prose. Reporting prose hits as live occurrences is how a genuine phantom gets dismissed as "still referenced somewhere."

```
📊 Outbound Targets: {filename}

│ Target                    │ Exists │ Section │ Fields  │ Format │ Status    │
│ {file#section}            │ ✓      │ ✓       │ 8/8     │ ✓      │ ✅        │
│ {registry.yaml}           │ ✓      │ N/A     │ 11/12   │ ✓      │ ⚠️ field X renamed │
│ {state.md#section}        │ ✓      │ ✓       │ 6/7     │ —      │ 🔧 field Y phantom (0 hits) │
│ ...                       │        │         │         │        │           │
```

**Fields totals across the file are a FILLED verdict carrying the pair** (Verification-Class Core VC-2): report `{resolved}/{extracted} fields resolved across {N} targets`, never "fields ✓". A bare ✓ is identical whether 12 of 12 resolved or the extraction step returned an empty field list.

Track findings mentally — approval deferred to STEP 3E.

---

#### STEP 3D: Compliance Checks

The following checks should be verified by the end of STEP 3A-3D — they are not a sequential pass but a set of criteria. Many are naturally checked during frontmatter/content scan (3A), connection alignment (3B), and target verification (3C).

**For operation files** — operation-skill-template compliance + PAT-063 domain-coherence checklist dimensions (formerly PAT-082):

Audit checklist from `.nexus/templates/operation-skill-template.md`:
1. Frontmatter present — name, description, disable-model-invocation
2. Version header — first content line after frontmatter
3. Flow summary — one-line execution path overview
4. Purpose stated — 1-2 sentences
5. STEP 0 loads only what's needed
6. Each step has single responsibility
7. Clean sequential numbering — no gaps
8. Format matches content — prose for procedures, YAML for fields, tables for parallel data
9. Gate annotations present — [T1]/[T2]/[T3] with behavior hints (if approval points exist)
10. User approval before writes — explicit step
11. State/registry interactions explicit — specific fields, paths, formats
12. Verify after writing — read back to confirm
13. Display templates defined — user-facing output with next steps
14. Error recovery — known common failure modes addressed
15. No CLAUDE.md duplication — references protocols, doesn't restate
16. No over-engineered error handling
17. Modes only if genuinely needed
18. **Routing alignment (PAT-063 checklist Dim 1)**: Routing map in [Section: Routing-Map] has entry? Triggers accurate?
19. **Memory-first protocol (PAT-063 checklist Dim 2)**: Memory-first discipline before loads? No redundant reads?
**Maintenance domain additions** (if applicable):
20. Scan boundary marked — `<!-- SCAN BOUNDARY -->`
21. Initial score calculation — outputs score before fixes
22. System-state health update — updates [Health-Operations]
23. Agent contract compatible — structured return format
24. Mental note directives — checkpoint support
25. Report export — offers save to `Maintenance-cycles/{sprint}/`
26. End-of-workflow checklist — if multi-write operation
27. **Displayed artifacts resolve to real writes** — every Gate Reference row, End-of-Workflow checklist item, and displayed artifact names a concrete write target or invoke that **exists on disk**. `grep` the artifact's token across the skill: a step that displays it, a gate that governs it, and a checklist that confirms it, with **no write anywhere**, is dead ceremony that reads as protocol. Verify by target, not by presence of the mention.

Score: ✅ pass, ⚠️ minor issue, 🔧 needs fix, N/A not applicable.

⚠️ **`N/A` requires a stated reason** — the item number, and one line saying which property of this file makes the check inapplicable (e.g. *"27 N/A — read-only display op, no write targets and no gate table"*). A bare `N/A` is indistinguishable from an unconsidered check, and the conditional items (20–27) are exactly where that happens: an auditor who never considered the check marks it not-applicable and passes. 📐 PAT-135 — the not-triggered branch must demand its own recorded line.

**Why item 27 exists.** `nexus-maintain` Phase 4C carried a `### C — Snapshot` step, a display line, a Gate Reference row, and an End-of-Workflow checklist item — **four mutually-reinforcing mentions across the file, and no write target anywhere.** It survived *three* verification passes: each mention corroborated the others, so the artifact looked more real the more thoroughly the file was read. Items 1–26 all passed on it. Retired at Sprint 110 by hand, not by any check.

Fixture (immutable, re-runnable after this skill's own edits land):
```bash
git show 6a8725ca:.claude/skills/nexus-maintain/SKILL.md | grep -n -i 'snapshot'
# → L225 step · L236 display · L307 Gate Reference row · L346 checklist item — item 27 must FLAG this
git show 8ec74e64:.claude/skills/nexus-close-sprint/SKILL.md | grep -n 'ISS-XXX\.sprint:'
# → L159 phantom registry key — STEP 3C Mechanical Field Verification must FLAG this
```

**For methodology skills** (/nexus-analyze, /nexus-build, /nexus-validate, /nexus-maintain, /nexus-research) — only when verifying Methodology domain. Use methodology-skill-template.md audit checklist:
- SKILL.md has flow summary, Operational Reminders, type/mode adaptations table, cognitive tools table
- Orient follows pattern: Load → Readiness → Progress → Score Gate → Path Decision
- Simple Path (C:1-2) is self-contained with zero external loads (N/A for Research, Maintain)
- Router (C:3+) has load sequence, type/mode mapping, execution sequence, zone checks
- Companion files (complex.md, type/mode files) have flow headers, key differences, mental notes, zone checks
- Gate annotations present with behavior hints ([T1]/[T2]/[T3])
- Gate Reference table consolidates all gates
- Checkpoint Reference maps every step to persist/where
- Resumption reload mandate: Router reloads companions on resume
- End-of-Workflow Checklist present (hard gate before transition)
- Commit Protocol and Transition sections present with smart T3 logic
- Phase outputs target correct ISS sections (Solution-Design, Implementation-Log, Evaluation-Results)
- Two-place score update at phase completion
- Score < 4 recovery path (return to companion file, no transition)

**For operation files touching registries** — CRUD against governing spec:
Identify which spec governs this registry (issue-specification.md for issues-registry, pattern-specification.md for patterns-registry). Load the relevant spec section (memory-first):
- `Read .nexus/templates/issue-specification.md#[Section: Registry-Schema]` — for issues-registry CRUDs
- `Read .nexus/templates/pattern-specification.md#[Section: Registry-Entry-Structure]` — for patterns-registry CRUDs

Verify operations align on three dimensions:

| Dimension | What to check |
|-----------|---------------|
| **Schema** | Field names match spec exactly. Field types correct (string, number, array). Required vs optional fields handled properly. No hardcoded old field names from previous schema versions. |
| **Lifecycle** | Status transitions follow spec-defined rules (e.g., Open → In-Progress → Resolved). Operations enforce valid transitions — no operation allows illegal state jumps. |
| **CRUD responsibility** | Each operation's CRUD role matches what the spec assigns. No operation oversteps its defined bounds. All spec-defined CRUD operations are covered — no gaps where a spec-defined action has no implementing operation. |

Common drift patterns: hardcoded old field names after schema updates, wrong version in comments, missing new required fields, operations allowing transitions the spec doesn't define.

```
📋 Specification Alignment: {spec_name}

Schema alignment:    {✅/🔧} {notes}
Lifecycle alignment: {✅/🔧} {notes}
CRUD responsibility: {✅/🔧} {notes}
**For domain-governed state files** — template-vs-instance verification:
Load governing template/spec (memory-first from STEP 2D). Compare the actual file on disk against the template as the authoritative schema:

| Check | What to verify |
|-------|---------------|
| Section presence | Every section defined in template exists in actual file (by marker) |
| No orphans | No sections in actual file that are absent from template |
| Field names | Spot-check 3-5 fields per section — names match template exactly |
| Field types | Fields match template type expectations (array vs scalar, string vs number, YAML vs markdown) |
| Field restrictions | Any constraints in template (required vs optional, allowed values, format patterns) are respected |
| No placeholders | No template placeholder text remaining (`{...}`, `{STEP X}`, `TODO`, etc.) |
| Metadata | Metadata fields present, correctly typed, and populated |

If governing template doesn't exist for this file type: note N/A, skip.

**For domain-governed registries** — spec compliance:
Load governing spec. Verify: schema compliance, entry format, metadata fields (last_id, total_active, etc.), no structural drift.

If no governing spec or template exists for this file type: note N/A, skip compliance.

**For domain-governed templates and specs** — three-source bidirectional verification:

When the file under examination IS a template or spec (not just loaded as authority), reverse the verification direction: check whether the template/spec still accurately reflects operational practice. Templates can be stale in either direction — instances and operations may have evolved past them, or they may define things that operations have stopped doing.

Load three sources (all should be in memory or cheaply available):
1. **The template/spec itself** — already under examination
2. **The instantiation operation** — from NEXUS-Architecture.md Cross-Cutting Domain Owner mapping (e.g., create-issue for issue-specification.md, organize-sprint for sprint-state-template.md); load its write-contract steps only if not already in memory
3. **2–3 most recent instances** — use highest ID/number as recency proxy: for ISS files, load the 2–3 highest-numbered ISS-XXX.md files from the issues directory; for PAT files, highest PAT-XXX.md; for sprint-state, current file; for other types, most recently modified by name order

Cross-check all three sources using this signal table:

| Instances | Operation | Template | Signal | Fix Direction |
|-----------|-----------|----------|--------|---------------|
| ✓ field X consistently | ✓ writes field X | ✗ missing field X | Template stale — practice evolved correctly | Update template to add field X |
| ✓ field X consistently | ✗ doesn't write X | ✓ defines field X | Operation stale — template authoritative | Fix operation to write field X |
| ✗ inconsistent | ✓ writes field X | ✓ defines field X | Execution drift — old instances or ad-hoc creation | Note old instances as acceptable drift; no template/op fix needed |
| ✓ field X consistently | ✓ writes field X | ✓ defines field X | All aligned | ✅ no action |
| ✓ consistently | ✗ doesn't write X | ✓ defines field X | Coordinated drift — operation changed, instances + template still agree | **Present bidirectional choice at STEP 3E**: "Recent instances have field X and template defines it, but operation no longer writes it. Which is authoritative? [Restore field X in operation \| Remove from template + note instances have stale field]" |
| ✗ inconsistent | ✗ doesn't write X | ✓ defines field X | Both operation and instances diverged — template may be aspirational or obsolete | **Flag for user decision at STEP 3E**: "Template defines field X but neither current operation nor recent instances use it. Dead field? [Remove from template \| Fix operation to write it]" |

Never auto-resolve coordinated drift — the user decides which direction is correct. Include both options in the STEP 3E findings widget.

**Template files special case** (operation-skill-template.md, methodology-skill-template.md) — examine both roles independently:
- *Audit checklist role*: Load 2–3 recently redesigned skills (highest version numbers). Do the checklist items reflect what a well-formed skill actually looks like? Flag items that no skills follow (possibly obsolete) and patterns that skills exhibit but the checklist doesn't capture (possibly missing).
- *Creation blueprint role*: Step through the scaffolding mentally — would following it from scratch produce a skill that passes STEP 3D compliance? Flag structural gaps.
Do NOT apply the checklist to itself.

---

#### STEP 3E: File Examination Summary, Approval, and Boundary Gate

This is the **single stop point per file**. All findings from 3B, 3C, and 3D are presented here together for approval. Do not stop mid-examination for individual findings.

**For files with 0 findings — terminate as FILLED, not a bare "clean" (Verification-Class Core VC-2):**

A clean file is a **FILLED** verdict carrying scan evidence — what was examined to earn it — not a silent pass:

```
✅ FILLED — {filename} v{version} clean
   Examined: {N} connections cross-checked (3B) · {M} outbound targets verified (3C) · {score}/18 compliance (3D)
   Evidence anchor: {a concrete substring / line-ref / count proving the scan ran — e.g. "all 4 Read targets resolved to existing #[Section] markers; 0 stale caller refs"}
```

A "clean" verdict without an evidence anchor is **not** a permitted terminal state — if you cannot name what you examined, the file is not verified, it is unscanned (complete the scan, or **ESCALATE**). A check genuinely N/A to this file is a justified **SKIP** with the reason stated. Files with findings → the verdict is **ESCALATED** for those findings (presented in the widget below).

> **False-clean rationalization (VC-3) — pre-refute at this gate:**
> - "Nothing jumped out, so it's clean." → Absence of *noticed* problems ≠ verified-absent. Name the scan evidence, or keep examining.
> - "Triangulation aligned, so the file's fine." → Triangulation (STEP 1) checks the *file list*, not a file's internal connections/targets/compliance. A FILLED verdict still needs 3B/3C/3D evidence for *this* file.

**For files with findings** — present ALL accumulated findings via `AskUserQuestion tool` widget:

```
═══════════════════════════════════════
{filename} v{version} — EXAMINATION COMPLETE
═══════════════════════════════════════
Connection alignment:  {N} connections — {aligned} ✅ / .nexus/issues/ ⚠️🔧
Outbound targets:      {N} verified — {pass} ✅ / .nexus/issues/ ⚠️🔧
Compliance:            {audit_score} | {spec_status}

Findings:
1. {source: 3B/3C/3D} {description} → Patch {target}: {change}
2. {source: 3B/3C/3D} {description} → Patch {target}: {change}
...

**[T2: Balanced+Full ask | Streamlined: auto-apply minor fixes, defer major, notify+log]**

[Apply all | Select which to apply | Defer all]
Apply approved fixes with verify before and after.

**Caller/consumer stale-reference check (PAT-063 Phase 2 consumer verification, formerly PAT-082 Part E):** After applying fixes — if any fix changed a section marker name, field name, or file path, search all consumers for stale references: `Grep pattern="{old_name}" in .claude/skills/ and .nexus/active/`. Any hits are new findings. Propose patches or note for deferred fix. Skip this check for fixes that don't change names or paths (e.g., frontmatter fixes, notes corrections).

**Running totals**: `Domain progress: {N}/{total} files | Findings so far: {fixed} fixed, {deferred} deferred`

**Mandatory file boundary gate.** Before proceeding to the next file, check context zone and present options via `AskUserQuestion tool` widget:

**[T3: Full ask | Balanced: notify | Streamlined: auto-proceed if no findings, checkpoint if yellow zone]**

Options: `[Proceed to {next_filename} | Checkpoint first then continue | Stop here (save progress)]`

If context is in yellow zone (≥70%) or above: explicitly note this in the prompt text. If user selects checkpoint: follow [Section: Checkpoint-Protocol], then continue. If user selects stop: export partial report, record progress in sprint-state `continue_with`.

Move to next file in domain core list → return to STEP 3A.

**VERIFICATION GATE — STEP 3:**
- [ ] All domain core files examined (or partial status recorded)
- [ ] All applied fixes verified
- [ ] No unresolved discrepancies blocking mental traces

⛔ GATE: Mental traces (STEP 4) must run against corrected files. If fixes are pending user approval, resolve before tracing.

---

### STEP 3F: Systemic Pattern Detection

After all files are examined, before mental traces: scan findings across the domain for patterns appearing in 3+ files.

If systemic patterns found: "Systemic finding: {description} appeared in {N}/{total} files. Consider codifying as a checklist rule or protocol note rather than tracking as {N} individual fixes. Apply batch fix? [Y/n]"

This converts individual findings into protocol-level improvements where warranted.

---

### STEP 4: Mental Execution Traces

**Applies to active workflow files only**: operations, methodology files, protocol sections from CLAUDE.md. Skip for registries, state files, and templates (passive data stores with no execution logic).

Execute after all domain core files have been examined and corrected in STEP 3. This ensures traces run against verified, corrected files.

**If resuming from a previous conversation** (STEP 3 completed earlier, STEP 4 pending): load only the operation files needed for traces — skip NEXUS-Architecture.md, alignment files, and compliance specs (those checks are already done).

**A — Select scenarios.** Define 2-3 realistic scenarios for this domain that exercise:
- A happy path (most common use case end-to-end)
- An edge case or error path
- A cross-domain flow (involves calls to/from other domains)

**B — Trace execution.** For each scenario: describe initial state and trigger, trace step-by-step through the operation(s), verify expected end state matches what operations produce. Pay attention to: data handoffs between operations, state mutations at each step, error handling at boundaries, return flow after CALL operations.

**C — Report bugs.**

```
🧪 Mental Execution Traces: {domain}

Scenario 1: {name}
  Path: {op_A} STEP X → {op_B} STEP Y → ...
  Result: {✅ PASS / 🔧 BUG}
  {if bug}: Expected: {X}, Actual: {Y}, Fix: {proposal}

Scenario 2: {name} — {✅ / 🔧}
Scenario 3: {name} — {✅ / 🔧}
---

### STEP 5: Domain Report and Fixes

**A — Compile domain summary:**

```
═══════════════════════════════════════════════════════
{DOMAIN_NAME} SUBSYSTEM VERIFICATION COMPLETE
═══════════════════════════════════════════════════════
Date: {date} | Sprint: #{sprint}
Status: {Complete / Partial (files remaining)}

Source Triangulation:
  System Paths: {aligned/discrepancies}
  NEXUS-Architecture.md:  {aligned/discrepancies}
  Disk:             {aligned/discrepancies}

Files Examined: {N}/{total}
┌─────────────────────────┬─────────┬────────────┬──────────┬────────────┬────────┐
│ File                    │ Version │ Connections │ Outbound │ Compliance │ Status │
├─────────────────────────┼─────────┼────────────┼──────────┼────────────┼────────┤
│ {filename}              │ v{X.Y}  │ {N} ✅/⚠️  │ {N} ✅/⚠️│ {score}    │ {✅/🔧}│
│ ...                     │         │            │          │            │        │
└─────────────────────────┴─────────┴────────────┴──────────┴────────────┴────────┘

Systemic Patterns: {N found — codified / batch-fixed / noted}
Mental Traces: {N} scenarios — {pass} ✅ / {bugs} 🔧 {or "N/A — passive files only"}
Fixes Applied: {N} patches across {N} files
Fixes Deferred: {N} (recommend issues)

═══════════════════════════════════════════════════════
OVERALL: {PASS / {N} ISSUES FOUND}
═══════════════════════════════════════════════════════
**B — Handle deferred fixes.** For major issues not fixed inline: "Create issue(s)? [Y/n/select]". If yes: invoke `/nexus-create-issue`.

---

### End-of-Workflow Checklist

⛔ GATE: All must pass before recording results.

```
- [ ] All domain core files examined (or partial status recorded)
- [ ] All approved fixes applied and verified on disk
- [ ] Systemic patterns detected and handled (STEP 3F)
- [ ] Mental traces completed for active workflow files (STEP 4)
- [ ] Deferred fixes documented with issue creation offered (STEP 5B)
```

---

### STEP 6: Record Results and Export

**A — Update system-state.** `UPDATE: system-state.md#[Section: Subsystem-Verification]` for the verified domain:

```yaml
{domain}:
  last_verified: "{YYYY-MM-DD}"
  last_verified_sprint: {sprint}
  depth: "full"
  findings: {total_count}
  fixed: {fixed_count}
  remaining: {unfixed_count}
  status: "{clean | minor_issues | major_issues | partial}"
  mental_traces: "{done | pending | n/a}"
  notes: "{one-paragraph summary: files examined, findings/fixes, accept-as-is, version bumps staged}"
If first run and section structure doesn't exist: load system-state-template.md (memory-first) for schema reference, then create the section.

**B — Export report.** Write to `.nexus/Maintenance-cycles/{sprint}/verification-{domain}-{date}.md` containing: triangulation results, per-file examination details, connection alignment tables, outbound verification results, compliance scores, systemic patterns, mental trace results, actions taken, remaining issues.

**C — Next steps.** Propose checkpoint. Then offer to continue with another domain:

```
📊 Verification Complete

Domain: {name} — {status}
Findings: {total} ({fixed} fixed, {remaining} remaining)
Report: Maintenance-cycles/{sprint}/verification-{domain}-{date}.md

Other domains:
{for each unverified or stale}: • {domain} — last: {date|never}

Continue with another domain? [select / done]
If user selects another domain: return to STEP 1 (STEP 0 context still in memory, NEXUS-Architecture.md Cross-Cutting may still be in memory).

---

### Conversation Boundary Handling

If verification spans multiple conversations:

| Scenario | What to reload | What to skip |
|----------|---------------|-------------|
| STEP 3 interrupted (some files remain) | NEXUS-Architecture.md domain section + Cross-Cutting, audit template, resume from next file | Already-examined files |
| STEP 3 complete, STEP 4 pending | Only operation files needed for mental traces | NEXUS-Architecture.md, alignment/compliance files |
| Domain complete, starting next domain | NEXUS-Architecture.md domain section for new domain (Cross-Cutting may still be in memory) | Previous domain's files |

Sprint-state `continue_with` should record: domain being verified, files completed, files remaining, current step, mental traces status.

**Context usage caution**: Verification sessions involve many file reads (full files, sections, Grep searches). With 1M context, this is rarely a concern. With 200K, track usage carefully. When approaching yellow zone, verify context via `/context` command before halting — actual usage may be lower than estimated.

---

### Error Recovery

| Problem | Recovery |
|---------|----------|
| Triangulation finds major discrepancies | Resolve discrepancies before proceeding — don't verify against incorrect baseline |
| NEXUS-Architecture.md section missing for domain | Inform user — map incomplete. Proceed with content-scan-only verification (degraded). Note as finding. |
| Skill file missing frontmatter | Record as finding. Use content scan only for connection discovery. |
| Cross-domain target doesn't exist | 🔧 finding — broken reference. Note in report. |
| Context approaching 70% mid-file | Complete current file examination, then STEP 3E gate handles checkpoint offer. |
| Context approaching 70% between files | STEP 3E gate handles — widget offers checkpoint before next file. |
| Governing spec not found for domain | Note N/A for spec compliance. Not all domains have specs. |
