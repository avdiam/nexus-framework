---
name: nexus-help
description: Answers questions and explains how NEXUS works — concepts, commands, workflows, learning paths. Use when the user asks what something is, how to do something, or wants to understand a feature — not to launch an operation (that's menu).
disable-model-invocation: false
---
*Version: 3.2.0 | Date: 2026-08-20 | Sprint: 110*

# Help

**Flow**: STEP 0 Intent Router → [Q&A escalation | Browse mode | Learning-path mode]

Unified entry point for NEXUS help: answers questions, browses the documentation catalog, and generates learning paths. The router classifies user intent and dispatches to the matching mode block. Read-only — answers directly, never just points to files.

---

## STEP 0: Intent Router

Classify the user query into one of three modes, then dispatch. The router prevents modality clash on ambiguous queries (e.g., "show docs" could be browse OR Q&A) — silent defaulting is the explicit risk it exists to prevent.

| Cue class | Examples | Dispatch |
|---|---|---|
| Browse / catalog | "browse docs", "show documentation", "list guides", "what guides exist?", "documentation catalog" | STEP 2 Browse |
| Learning-path | "learning path", "where do I start", "what should I read first", role-onboarding ("I'm new — what now?") | STEP 3 Learning-path |
| Q&A / how-to / definition | "how do I X?", "what is X?", "explain X", everything else (default) | STEP 1 Q&A |

**Ambiguity gate**: when the user query plausibly matches more than one class (e.g., "tell me about NEXUS docs", "help with documentation"), use `AskUserQuestion` to disambiguate before dispatch:

Options: [Answer a question (Q&A) | Browse the catalog | Suggest a learning path]

Do not silently default on ambiguity — surfacing the choice is the load-bearing mechanism here.

**Fallback**: if no cue matches AND the query is unambiguous, default to STEP 1 Q&A (most general entry).

**Session continuity**: after dispatch, the selected mode runs to completion. The session stays in that mode until the user navigates away (menu, non-help command, or "done"). Re-entry on a fresh query re-runs the router.

---

## STEP 1: Q&A Escalation

Progressive escalation: memory first (free), then guides (cheap), then system files (expensive). The user should see answers, not loading decisions — escalate seamlessly without explaining the mechanism. Always answer the question directly; don't just point to a file and ask the user to read it.

### STEP 1.A — Answer from Memory

Check files already in memory. CLAUDE.md covers all framework protocols: principles, preferences, file operations, memory management, routing, phases, checkpoint, and the memory layer. Methodology skills cover phase-specific workflows. Sprint-state covers current context.

If the answer is in memory, answer directly and cite the source file and section. Then ask whether this was sufficient using `AskUserQuestion`: [Satisfied | Need more detail]. If satisfied, done. If more detail needed, proceed to STEP 1.B.

If memory clearly can't answer (topic not covered by any loaded file), skip directly to STEP 1.B.

### STEP 1.B — Answer from Guide

Load documentation-registry.yaml (if not already in memory). Match the user's topic against guide titles, topics, and descriptions — semantic matching, not keyword search.

If the best matching guide has status `active` (the canonical written-guide status — the registry holds only `active` / `planned`): propose loading it with `AskUserQuestion`: [Load guide (~{size}KB) | Skip to system files | Already satisfied]. If approved, load the guide, extract the relevant answer (don't dump the entire guide), answer the question, cite the guide. Then ask again: [Satisfied | Need deeper technical detail]. If deeper detail needed, proceed to STEP 1.C.

If the best matching guide is `planned` or no guide matches: skip directly to STEP 1.C. Don't tell the user a guide is missing — just proceed.

### STEP 1.C — Answer from System Files

Identify which system files contain the authoritative answer. For questions about system architecture, component relationships, data flows, cross-domain boundaries, or write contracts, NEXUS-Architecture.md is the primary source — load the relevant section(s):

| Question type | NEXUS-Architecture.md section | What it provides |
|---|---|---|
| Domain structure ("what does Sprint domain do?") | `#[Section: Domain-{Name}]` | File list, relationships, cross-domain boundaries |
| System flows ("how does sprint closure work?") | `#[Section: Flows]` | Step-by-step operation chains with data targets |
| Cross-cutting ("who writes to sprint-state?") | `#[Section: Cross-Cutting]` | Reader/writer tables for states, registries, templates |
| Overall architecture ("how is NEXUS structured?") | `#[Section: System-Overview]` | Domain statistics, most connected nodes, characteristics |
| Multiple domains ("how do issues and sprints interact?") | Multiple `#[Section: Domain-{Name}]` sections | Combined relationships and boundaries |

NEXUS-Architecture.md answers these questions directly — no need to load individual skill files for relationship context. If the user needs deeper operational detail (specific step logic, tool guidance), then load individual source files as below.

For all other topics, identify source files from this mapping:

| Topic | Source |
|---|---|
| Patterns | /nexus-list-patterns, /nexus-match-pattern, .nexus/templates/pattern-specification.md |
| Issues | /nexus-create-issue, /nexus-work-issue, .nexus/templates/issue-specification.md |
| Sprints | /nexus-organize-sprint, /nexus-close-sprint, .nexus/templates/sprint-state-template.md |
| Projects | /nexus-setup-project, /nexus-project-status, .nexus/active/states/project-state.md |
| Maintenance | /nexus-maintain, /nexus-health-diagnostic, .nexus/active/states/system-state.md |
| Documentation | STEP 2 Browse mode (this file), /nexus-guide-creator, .nexus/active/registries/documentation-registry.yaml |
| Boot | /nexus-start skill |
| Routing | [Section: Routing-Map] |
| Checkpoint | [Section: Checkpoint-Protocol] in CLAUDE.md |
| Phases | [Section: Phase-Management-Protocol] |
| Preferences | [Section: Behavioral-Preferences] |
| Cognitive tools | /nexus-mental-models, /nexus-problem-solving, /nexus-strategic |
| Templates | .nexus/templates/*.md |

Propose loading with `AskUserQuestion`: [Load {file/section} (~{size}) | Try answering from memory | Done]. Use section-based loading where possible to minimize cost.

If approved: load, answer precisely, cite source. If declined: provide best answer from what's already loaded and note the limitation.

---

## STEP 2: Browse Mode

Read-only catalog browsing of the NEXUS documentation library. Delegates to `/nexus-guide-creator` when a planned guide is selected for creation.

### STEP 2.0 — Load Context

`Read .nexus/active/registries/documentation-registry.yaml` — full guide catalog with categories, levels, descriptions, and status. This is the only dependency.

### STEP 2.1 — Display Catalog

Group guides by registry `category` field. For each guide, show status icon, title, and description. After the list, show summary stats and available commands.

**Status icons:** ✅ = active (can read) | 📋 = planned (not yet created)

**Display format:**

```
═══ 📚 NEXUS DOCUMENTATION LIBRARY ═══

GETTING STARTED
  [1] {icon} {title} — {description}
  [2] {icon} {title} — {description}

DOMAIN GUIDES
  [3] {icon} {title} — {description}
  ...

SYSTEM & REFERENCE
  [N] {icon} {title} — {description}
  ...

═══════════════════════════════════════
{total} guides ({created} created, {planned} planned)
✅ = available to read | 📋 = planned

Commands: [number] to view | "filter by [topic/level]" | "staleness check" for health
Related: "learning path" for guided journey (STEP 3) | "create guide" to generate one (/nexus-guide-creator)
```

### STEP 2.2 — Navigate

Interpret user input naturally — number selection, topic filters, keyword searches all work. No rigid parsing needed.

**When user selects a guide:**

- **planned status** (file doesn't exist): inform the user and offer to create it. If accepted: invoke `/nexus-guide-creator`.
- **active status**: load the guide file and display its content. For large guides (>30KB), show the table of contents with section markers and offer section-based reading.

After displaying a guide:

```
───────────────────────────
📄 End of: {title}
[back to catalog | next guide | learning path]
```

**When user requests details:** Show extended metadata for a specific guide — target level, topics, size, last updated, source file references.

**When user requests stats:**

```
📊 Documentation Statistics
Total guides: {count}
Created: {n} | Planned: {n}
By level: Beginner {n}, Intermediate {n}, Advanced {n}
Total size: {sum_kb}KB
```

The browse session stays active until the user navigates away (menu, non-documentation command, or "done").

---

## STEP 3: Learning-path Mode

Suggest a documentation reading path based on experience level and current work context. Read-only. Composes path from registry metadata + role profile + time budget — no hardcoded sequences.

### STEP 3.0 — Load Context

`Read .nexus/active/registries/documentation-registry.yaml` if not already in memory from STEP 1.B or STEP 2.0 (memory-first). Full guide catalog (titles, categories, levels, topics, sizes, status) is needed to compose an intelligent path.

### STEP 3.1 — Gather Profile

If the conversation already reveals the user's context (e.g., they've been doing sprint work, or they're clearly new), state the inferred profile and offer to adjust. Otherwise, use `AskUserQuestion` with up to 3 questions:

**Question 1 — Role:** "What's your relationship with NEXUS?"
Options: Newcomer (just learning), User (work with NEXUS on projects), Developer (extend/modify NEXUS), Maintainer (keep NEXUS healthy)

**Question 2 — Goal:** "What do you want to achieve?"
Options: Understand how NEXUS works, Start using it effectively, Learn to maintain/evolve it, Understand internals to extend

**Question 3 — Time budget:** "How much time do you have?"
Options: Quick (15-30 min), Moderate (1-2 hours), Deep (3+ hours)

If the user gives partial answers, infer the rest. Don't force all 3 questions.

### STEP 3.2 — Generate Path

Compose a learning path from registry metadata. No hardcoded sequences — use the guide catalog, user profile, and these principles:

**Sequencing principles:**
- Foundation before detail — architecture before domain-specific guides
- Infrastructure & quick-start first for newcomers
- Domain guides ordered by the user's stated goal
- Reference guides last (lookups, not sequential reads)
- Only include guides with status `active` — mention planned guides as "coming soon" at the end

**Role emphasis:**

| Role | Core path | Then |
|---|---|---|
| Newcomer | installation-guide → quick-start-guide → architecture-quick-guide | One domain guide matching interest |
| User | quick-start-guide → issue-lifecycle-guide → sprint-management-guide | Relevant domain guides, then pattern-system-guide |
| Developer | installation-guide → architecture-quick-guide → navigation-and-commands-guide | Domain guides as needed |
| Maintainer | architecture-quick-guide → maintenance-and-evolution-guide → troubleshooting-guide | then all domain guides |

**Time budget:**

| Budget | Guides | Reading time |
|---|---|---|
| Quick | 2-3 | ~15-30 min |
| Moderate | 4-6 | ~1-2 hours |
| Deep | 8-14 | ~3+ hours, full coverage |

**Time estimation:** ~1 min per 2KB of guide content (from registry `size_kb`).

**Display the path:**

```
🎯 Your Personalized Learning Path
═══════════════════════════════════════
Profile: {role} | Goal: {goal} | Time: ~{total_estimate}

STEP 1: {title} (~{minutes} min)
  Why: {why this guide first for this profile}
  Focus on: {key topics for this user}

STEP 2: {title} (~{minutes} min)
  Why: {why this guide next}
  Focus on: {key topics}

...

═══════════════════════════════════════
Total: {count} guides | ~{total_minutes} min

{If planned guides would be relevant: "Coming soon: {list} — not yet created."}

Commands: "start" to begin | [N] to jump | "customize" to adjust
```

### STEP 3.3 — Deliver and Exit

The path is the deliverable. After STEP 3.2 displays the sequenced path with file paths, the operation is complete. The user reads guides externally (editor, viewer) at their own pace.

```
🎯 Path ready! Open guides from:
  .nexus/human-guides/{filename}.md

Tip: Use your preferred text editor to read guides.
To revisit this path later, say "learning path" in any conversation.
```

If the user asks about a specific guide's content after path generation, re-enter the router — most queries will route back to STEP 1 Q&A (which can load and answer from the guide) or STEP 2 Browse (which displays guide content).
