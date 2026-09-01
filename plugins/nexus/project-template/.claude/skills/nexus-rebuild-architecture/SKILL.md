---
name: nexus-rebuild-architecture
description: Regenerate NEXUS-Architecture.md by scanning all skills and framework files
disable-model-invocation: true
---
*Version: 2.4.0 | Date: 2026-08-26 | Sprint: 111*

# Rebuild NEXUS Architecture Map

**Flow**: Discover skills → Scan connections → Cross-reference → Classify domains → Generate document → [T1: write] → Verify → Git commit → Report

Scans all skills, framework files, state files, registries, and templates to generate a comprehensive NEXUS-Architecture.md. This is a **generation** operation, not a verification — it builds the map from reality, not from existing claims.

**When to run:**
- After a major port or restructuring (skills added/removed/reorganized)
- When subsystem-verification reports widespread Architecture.md discrepancies
- Periodically (every 5-10 sprints) to keep the map current
- After first project setup (to create the initial map)

**Output**: Overwrites `.nexus/active/NEXUS-Architecture.md` with a freshly generated map.

**Token estimate**: ~50-100K (reads many files). Consider running at the start of a conversation, not mid-work.

---

### STEP 0: Load Context

**A — Discover all skills:** Use `Glob` with pattern `.claude/skills/nexus-*/**/*.md` to enumerate all skill files.
For each skill directory, note: name, has SKILL.md?, companion files (complex.md, batch.md, types/, modes/, references/) and their count.

**B — Load framework files list:** Use `Glob` to enumerate each set:
- `.nexus/active/*.md`
- `.nexus/active/states/*`
- `.nexus/active/registries/*`
- `.nexus/templates/*`
- `.nexus/templates/project-types/*`

**C — Load routing map:**
Read [Section: Routing-Map] from memory — this defines the command→skill mappings and system paths.

**D — Load current Architecture.md** (if exists) for version comparison. Note what sections exist.

Display:
> 📊 Architecture Rebuild
> Skills found: {count}
> Framework files: {count}
> Templates: {count}
> Current Architecture.md: {exists with {N} sections / not found}
> Proceed with full scan? [Y/n]

**[T1: all levels ask]** — Architecture.md overwrite is hard to undo manually.

---

### STEP 1: Scan Skills — Connection Discovery

For each skill SKILL.md (read file, extract connections):

**A — Frontmatter**: Extract name, description, disable-model-invocation.

**B — Content scan** — search for these patterns in the skill content:

| Pattern | Connection Type |
|---|---|
| `Read .nexus/{path}` or `Read tool` with .nexus path | **Reads** file |
| `Edit .nexus/{path}` or `Edit tool` with .nexus path | **Writes** file |
| `Write .nexus/{path}` or `Write tool` with .nexus path | **Writes** file (create) |
| `Grep` or `search` with .nexus path | **Reads** file (search) |
| `/nexus-{name}` or `invoke /nexus-{name}` or `load /nexus-{name}` | **Invokes** skill |
| `[Section: {Name}]` references | **Section target** (read or write) |
| `ISS-XXX` or `ISS-{XXX}` references | **ISS file** interaction |
| `PAT-XXX` or `PAT-{XXX}` references | **Pattern file** interaction |
| `issues-registry` | **Registry** interaction |
| `patterns-registry` | **Registry** interaction |
| `changelog-registry` | **Registry** interaction |
| `documentation-registry` | **Registry** interaction |
| `sprint-state` | **State file** interaction |
| `project-state` | **State file** interaction |
| `system-state` | **State file** interaction |
| `sprint-queue` | **State file** interaction |

**C — For methodology skills with companion files** (complex.md, types/*.md, modes/*.md, references/*.md): Scan companion files too. Aggregate connections from SKILL.md + all companions. Note which file produces each connection.

**D — Build connection record per skill:**
```yaml
skill_name:
  reads: [{file, section (if specific), step (if methodology)}]
  writes: [{file, section (if specific), step (if methodology)}]
  invokes: [{skill_name, context}]
  invoked_by: []  # populated in STEP 2
```

**Progress**: After every 10 skills, display progress: "Scanned {N}/{total} skills..."

If context > 70%: offer checkpoint. Architecture data collected so far can be written partially — the generation in STEP 3 works with whatever's collected.

---

### STEP 2: Cross-Reference — Build Invocation Graph

From STEP 1 data, build the `invoked_by` relationships:

For each skill A that invokes skill B: add A to B's `invoked_by` list.

Also verify against the routing map: every skill in the routing map should have been discovered in STEP 1. Flag any routing entries pointing to non-existent skills.

---

### STEP 3: Classify Into Domains

Group skills by domain using the routing map categories + these rules:

| Domain | Skills |
|---|---|
| **Project** | nexus-init-project, nexus-setup-project, nexus-project-status, nexus-generate-mvp, nexus-close-project, nexus-update-state, nexus-map-context |
| **Sprint** | nexus-organize-sprint, nexus-sprint-status, nexus-close-sprint, nexus-move-issues, nexus-loop-back |
| **Issue** | nexus-create-issue, nexus-update-issue, nexus-view-issues, nexus-work-issue, nexus-close-issue, nexus-archive-issue, nexus-decompose-issue |
| **Pattern** | nexus-list-patterns, nexus-match-pattern, nexus-create-pattern, nexus-update-pattern, nexus-merge-patterns, nexus-delete-pattern |
| **Maintenance** | nexus-health-diagnostic, nexus-pattern-maintenance, nexus-registry-cleanup, nexus-issue-validation, nexus-backup-optimization, nexus-maintenance-scheduler, nexus-rollback, nexus-changelog-scan, nexus-subsystem-verification, nexus-rebuild-architecture |
| **Documentation** | nexus-help, nexus-staleness-checker, nexus-guide-creator, nexus-dashboard |
| **Methodology** | nexus-analyze, nexus-build (includes batch mode), nexus-validate, nexus-research, nexus-maintain, nexus-loop-back |
| **Cognitive** | nexus-mental-models, nexus-problem-solving, nexus-strategic |
| **System** | nexus-start, nexus-menu, nexus-checkpoint |

Skills may appear in multiple categories (e.g., nexus-loop-back is Sprint domain + Methodology). nexus-brainstorm is a parallel phase (not in the A/I/E lifecycle) — classify under Methodology as a parallel/self-contained entry.

---

### STEP 4: Generate Architecture Document

Build the complete NEXUS-Architecture.md with these sections:

**[Section: System-Overview]**
- File statistics table (count per category)
- Domain summary table (skills per domain, primary state, governing spec)
- Total governed files count

**[Section: Methodology-Flow]**
- Phase lifecycle diagram (A→I→E, A→R→E)
- Phase → Skill → ISS Section mapping table
- Handoff points table (From/To/What's Passed/Where)
- Extracted from methodology transition steps

**[Section: Domain-{Name}]** — one per domain (10 at Sprint 109: System, Project, Sprint, Issue, Pattern, Memory, Methodology, Cognitive, Documentation, Maintenance):

For each skill in the domain, generate the detailed relationship table:

```
| From | To | Op | Trigger | Section | Notes |
|---|---|---|---|---|---|
| /nexus-create-issue | issues-registry.yaml | Write | STEP 6 | entry block | Creates 18-field prefixed entry |
| /nexus-create-issue | ISS-XXX.md | Write | STEP 5 | full file | Scaffolded from issue-specification |
| /nexus-create-issue | sprint-queue.md | Read | STEP 0 | — | Queue context for mode detection |
```

Also generate:
- **Cross-domain boundaries**: which skills in this domain invoke skills in other domains
- **State file ownership**: which state files this domain primarily owns vs reads

**[Section: Cross-Cutting]**
- State file readers/writers table (aggregated from all domains)
- Registry readers/writers table (aggregated)
- Two-Place Update Protocol summary
- Templates → Instances chain

**[Section: Infrastructure]**
- Boot sequence summary
- Hooks list
- Git backup lifecycle

**[Section: Flows]** — key multi-skill sequences:
- Sprint closure flow (close-sprint → close-issue → archive-issue → update-pattern → update-state → health-diagnostic)
- Issue lifecycle flow (create → work → analyze → build → validate → close → archive)
- Maintenance flow (maintain → health-diagnostic → operations → health-diagnostic → report)
- Pattern lifecycle (create → match → track → update → merge/delete)

Extract flow sequences from skill invocation chains discovered in STEP 1-2.

**[Section: Routing-Map-Verification]**
- The STEP 2 routing check, recorded in the map: every CLAUDE.md [Section: Routing-Map] route → an existing skill; orphan skills (no route) listed

**[Section: File-Inventory]**
- Category-count table with paths (skills, skill `.md` files, agents, hooks, templates, project-type profiles, active/archived issues and patterns, seeds, guides, sprint + maintenance-cycle folders) — consumed by /nexus-subsystem-verification STEP 1B for count consistency

---

### STEP 5: Write and Verify

**A — Write NEXUS-Architecture.md:**
Use Write tool to create `.nexus/active/NEXUS-Architecture.md` with all generated sections. Include version header:

```
# NEXUS-Architecture.md — System Architecture Map
*Version: {N}.0.0 | Date: {today} | Sprint: {current}*
*Auto-generated by /nexus-rebuild-architecture (Sprint {current}). Source: full skill-content scan.*
```

⛔ **The `(Sprint {current})` is load-bearing — do not drop it, and do not reword the line.** It is this file's only **rebuild** provenance, and it is a different fact from the `Sprint:` in the version header above it: the version header advances on any edit, while this advances only on a genuine regeneration. `derivations.yaml` edge **E-13** parses it to tell "this map was rebuilt at Sprint N" apart from "this map was *touched* at Sprint N" — a distinction mtime cannot express, because a one-row patch makes the map newer than all 100+ of its sources while its tables stay N sprints behind.

Without this token E-13 terminates `ESCALATED: bound 0 (rebuild provenance)` on every boot thereafter. Found at ISS-240 Phase 4/5 adversarial review (Sprint 111): the template omitted the sprint, so **the first genuine rebuild would have broken the very check built to detect an un-rebuilt map** — a derived value depending on a format its producer did not guarantee, which is ISS-240's own defect class. Source-fixed here rather than worked around in the consumer (📐 PAT-130).

**B — Verify**: Read back the file, confirm all sections present, spot-check 2-3 relationship entries against skill content.

**C — Git commit:**
```bash
git add .nexus/active/NEXUS-Architecture.md
git commit -m "nexus: rebuild NEXUS-Architecture.md — {skills_scanned} skills, {domains} domains"
```

**D — Report:**
```
═══════════════════════════════════════════════
✅ NEXUS-Architecture.md Regenerated
═══════════════════════════════════════════════
Skills scanned: {total}
Connections discovered: {count}
  Reads: {count} | Writes: {count} | Invokes: {count}
Domains: {count}
Sections generated: {count}
Flow sequences: {count}

Routing map alignment:
  All routes → existing skills: {yes/no}
  Orphan skills (no route): {list or "none"}

File: .nexus/active/NEXUS-Architecture.md ({size}KB)
═══════════════════════════════════════════════
```

---

### Context Management

This operation reads many files. Strategies:
- **Methodology skills**: Read SKILL.md router + list companion filenames (complex.md, batch.md, types/, modes/, references/). Only read individual companions if step-level detail is needed (for Flows section). Aggregate from the router's step sequence + type routing table.
- **Simple operation skills**: Full read of SKILL.md (most are < 300 lines).
- **Registries/state files**: Don't read contents — just note their existence and which skills reference them.
- **If context > 80%**: Write what's generated so far, note remaining domains in continue_with. Next conversation resumes.

### Checkpoint Continuity

**Mental note**: Architecture rebuild: {domains_completed}/{total}. Skills scanned: {N}. If checkpoint → write partial Architecture.md with completed domains, note remaining.
