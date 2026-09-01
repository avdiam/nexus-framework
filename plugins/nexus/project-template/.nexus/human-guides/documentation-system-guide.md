# Documentation System Guide
*Version: 1.1.1 | Sprint: 110 | Category: domain*

*How NEXUS documentation works — browsing guides, generating new ones, checking freshness, getting help, and following learning paths.*

**Source files:**
- `.claude/skills/nexus-help/SKILL.md` v3.2.0 (unified help — Q&A, Browse mode, Learning-path mode)
- `.claude/skills/nexus-dashboard/SKILL.md` v2.2.0
- `.claude/skills/nexus-guide-creator/SKILL.md` v2.2.1
- `.claude/skills/nexus-staleness-checker/SKILL.md` v3.1.0
- `.nexus/templates/human-guide-template.md` v1.0.2
- `.nexus/active/registries/documentation-registry.yaml` v4.0.0
- `.nexus/active/NEXUS-Architecture.md` v4.1.0

---

## What Is the Documentation System?
[Section: Introduction]

NEXUS generates its own human-readable documentation. Rather than maintaining guides by hand (which inevitably drift from the system they describe), NEXUS introspects its own operation files, registries, and state files, then composes guides written for humans — clear prose with examples, diagrams, and practical walkthroughs.

The documentation system is a closed loop: guides are generated from source files, tracked in a registry with version references, and automatically checked for staleness when those source files change. When drift is detected, guides can be regenerated from the updated sources.

This guide covers the four skills that make up the documentation domain — help alone unifies three former separate operations (Q&A, browse catalog, and learning-path) behind one intent router — how they connect to each other and the rest of NEXUS, and how the documentation-registry ties everything together.

**After reading this guide you'll understand:**

- How to browse and discover existing guides
- How guides are generated from system file introspection
- How staleness detection works and when to regenerate
- How the help system answers questions with progressive depth
- How learning paths are personalized to your role and goals
- How the documentation-registry tracks everything
- How dashboards visualize NEXUS data

[/Section: Introduction]

---

## Core Concepts
[Section: Core-Concepts]

### Guides

Guides are markdown files in `.nexus/human-guides/` written for human readers. Each guide is self-contained — you can read it without needing other guides. Guides are organized into three categories:

- **Getting Started** — onboarding and orientation (quick-start, infrastructure setup, architecture overview)
- **Domain** — deep dives into specific NEXUS domains (issues, sprints, patterns, projects, maintenance)
- **System Reference** — cross-cutting topics (navigation, data persistence, methodology files, cognitive tools)

Every guide has a header that records which source files it was generated from and their versions at generation time. This is what enables staleness detection.

### Documentation Registry

The file `documentation-registry.yaml` is the catalog of all guides — both active and planned. Each entry records the guide's title, category, target audience level, topics, description, file size, and a `references` array listing every source file with its version. This registry is the single source of truth for "what documentation exists and how fresh is it."

Three of the four documentation skills read from this registry (help, staleness-checker, dashboard). Only guide-creator writes to it (when creating or updating a guide entry).

### Source File Introspection

Guide generation doesn't copy-paste from source files. Instead, guide-creator reads the operation files, extracts key concepts, workflows, and commands, then composes human-friendly prose. NEXUS-Architecture.md provides the relationship context — which files connect to which, what data flows where — so guides can explain how things fit together without reverse-engineering it from individual files.

### Staleness

A guide becomes stale when its source files have been updated beyond the versions recorded in the guide's `references` array. Staleness-checker compares these recorded versions against changelog-registry.yaml (which tracks current versions of all system files). Version drift doesn't necessarily mean the guide is wrong — a patch bump to a peripheral source might not affect the guide content — but significant drift warrants regeneration.

[/Section: Core-Concepts]

---

## How It Works
[Section: How-It-Works]

### The Documentation Lifecycle

```
Source files updated
       │
       ▼
staleness-checker detects version drift
       │
       ▼
User reviews staleness report
       │
       ▼
guide-creator regenerates stale guides
       │
       ▼
Registry updated with new versions
       │
       ▼
Guides are current again
```

This cycle runs on demand — there's no automatic regeneration. You trigger staleness checks manually, or the check itself runs automatically as part of system maintenance (`/nexus-maintain` Phase 5). Either way, regeneration is always offered, never auto-applied — the decision to regenerate is always yours.

### How Guide Generation Works

When you say "create guide" or "regenerate guide," guide-creator follows this flow:

1. **Identify the guide** — match your request against the registry catalog. If the guide exists, offer regeneration. If it's planned or new, start creation.

2. **Discover source files** — NEXUS-Architecture.md is the primary source for figuring out which files to introspect. For a domain guide like "issue lifecycle," it reads NEXUS-Architecture.md's Issue domain section to get the complete file list, relationships, and cross-domain boundaries. A static fallback table exists if NEXUS-Architecture.md is unavailable.

3. **Introspect sources** — load each source file (section-based where possible to save context) and extract purposes, concepts, workflows, commands, and examples.

4. **Compose the guide** — select appropriate building blocks from human-guide-template.md (Introduction, Core Concepts, How It Works, Operations Guide, etc.), then write human-friendly content from the extracted information. NEXUS-Architecture.md's relationship data flows directly into how the guide describes connections between components.

5. **Review** — the full guide is presented for your review before writing to disk. You can edit sections, request changes, or regenerate with different emphasis.

6. **Write and register** — the guide file is written to `.nexus/human-guides/` and the documentation-registry is updated with the new entry (or updated entry for regenerations), including the current versions of all source files in the `references` array.

### How Staleness Detection Works

Staleness-checker reads two registries and cross-references them:

- **documentation-registry.yaml** — each guide's `references` array records which source files were used and their versions at generation time
- **changelog-registry.yaml** — records the current version of every system file

For each guide, every reference is compared. If the recorded version is behind the current version, that reference has drifted. The checker then uses semantic judgment to categorize the guide's overall staleness — a single patch bump to a peripheral source is "Review" (⚠️), while multiple major version bumps to core sources is "Critical" (🔴).

### How Help Escalates

The help system uses progressive disclosure — it tries the cheapest answer source first:

1. **Memory** (free) — CLAUDE.md is always loaded and covers principles, routing, phases, preferences, and more. If the answer is there, you get it instantly.

2. **Guides** (cheap) — if memory can't answer, help matches your topic against the documentation-registry and loads the best matching guide. It extracts the relevant answer rather than dumping the whole guide.

3. **System files** (expensive) — for deep technical questions, help loads the authoritative source files directly. For architecture and relationship questions, it uses NEXUS-Architecture.md sections. For operational details, it loads the specific skill files.

At each level, you're asked whether the answer was sufficient before escalating further.

[/Section: How-It-Works]

---

## Working With Documentation
[Section: Operations-Guide]

### Help
**Command:** `help` / `how do I {topic}` / `explain {concept}` / `what is {thing}` (Q&A mode) — also `browse docs` / `show documentation` / `list guides` (Browse mode) and `learning path` / `where do I start` (Learning-path mode)
**What it does:** Single unified entry point for the documentation domain's question-answering, catalog-browsing, and learning-path generation. A STEP 0 intent router classifies your query into one of the three modes and dispatches to it. If your query plausibly matches more than one mode, help asks you to disambiguate rather than silently picking one.
**When to use:** Anytime you have a question about how NEXUS works, want to see what documentation exists and read a guide, or want a structured sequence to learn an area.
**Key workflow — Q&A:** Check memory (CLAUDE.md) → if insufficient, load the best-matching guide from the registry and extract the relevant answer → if still insufficient, load authoritative system files directly. At each level you confirm whether the answer is sufficient before it escalates further.
**Key workflow — Browse:** Catalog display grouped by category (Getting Started, Domain, System Reference) with status icons → select a guide by number → guide content is loaded and displayed. For large guides (>30KB), you're offered section-based reading. After reading, you can navigate back to the catalog, move to the next guide, or start a learning path.
**Key workflow — Learning-path:** Gather your profile (role, goal, time budget) → compose a sequenced path from registry metadata → display with estimated reading times per guide and focus areas tailored to your profile. The path is the deliverable — it shows which guides to read and in what order, with file paths so you can open them in your preferred editor.
**Example:** `help with patterns` (Q&A) → tries memory (CLAUDE.md pattern governance) → offers pattern-system-guide → if needed, loads individual pattern skill files. `browse docs` (Browse) → shows the catalog. `learning path` (Learning-path) → asks your role/goal/time, then sequences guides.

### Create / Regenerate Guide
**Command:** `create guide {name}` or `regenerate guide {name}`
**What it does:** Generates a new guide from system file introspection, or regenerates an existing one from updated sources while preserving any manually-edited sections.
**When to use:** When a planned guide needs to be created, when staleness-checker reports drift, or when you want to refresh a guide after significant system changes.
**Key workflow:** Identify guide and mode → discover source files via NEXUS-Architecture.md → introspect sources → compose using building blocks from human-guide-template.md → review with user → write to disk and update registry.
**Example:** `create guide documentation-system` generates this guide. `regenerate guide quick-start` refreshes the quick-start guide from current sources.
**Important:** In regenerate mode, sections marked `[Section: Manual-Edit]` are preserved unchanged — only auto-generated content is refreshed.

### Staleness Check
**Command:** `check staleness` or `stale docs`
**What it does:** Compares every active guide's source references against current file versions to detect drift.
**When to use:** After significant system changes (sprint of rewrites, major version bumps), during maintenance, or whenever you want to verify documentation freshness.
**Key workflow:** Load both registries → filter guides with references → compare versions → categorize each guide (Current ✅, Review ⚠️, Stale 🟠, Critical 🔴) → report with details → offer to regenerate stale guides.
**Two modes:** In manual mode, you get a full interactive report with regeneration options. When called automatically from `/nexus-maintain` Phase 5, it returns a compact summary line for the maintenance report.
**Tip:** If the changelog-registry is outdated (hasn't been scanned recently), staleness-checker warns you. Run `changelog scan` first for accurate results.

### Dashboard
**Command:** `dashboard` or `documentation dashboard`
**What it does:** Generates an interactive React visualization of NEXUS data. The documentation scope shows guide cards by category with status indicators, level distribution, topic coverage, and created vs planned ratios.
**When to use:** When you want a visual overview rather than text-based listings.
**Key workflow:** Select scope (documentation, or 5 other scopes) → load data source → transform to JSON → generate React artifact with filters, sorting, and expandable cards.
**Note:** Dashboards are read-only — they visualize live data but never modify files. Six scopes are available: Issues, Patterns, Project, Sprint, Maintenance, and Documentation.

[/Section: Operations-Guide]

---

## Key Files
[Section: Data-And-Files]

### File Inventory

| File | Purpose | Location |
|------|---------|----------|
| nexus-help/SKILL.md | Unified help — Q&A, browse catalog, learning paths | `.claude/skills/nexus-help/` |
| nexus-dashboard/SKILL.md | Generate interactive React dashboards | `.claude/skills/nexus-dashboard/` |
| nexus-guide-creator/SKILL.md | Generate and regenerate guides | `.claude/skills/nexus-guide-creator/` |
| nexus-staleness-checker/SKILL.md | Detect outdated guides | `.claude/skills/nexus-staleness-checker/` |
| human-guide-template.md | Building blocks and quality standards for guides | `.nexus/templates/` |
| documentation-registry.yaml | Guide catalog with metadata and version references | `.nexus/active/registries/` |
| Generated guides | Human-readable documentation | `.nexus/human-guides/` |

### Data Flow

```
changelog-registry.yaml ──READ──► staleness-checker ──CALL──► guide-creator
                                                                    │
documentation-registry.yaml ◄──READ── help (all 3 modes)           │
         ▲                  ◄──READ── staleness-checker             │
         │                  ◄──READ── dashboard                     │
         └──────UPDATE──────────────── guide-creator ◄──────────────┘
                                            │
                                            ▼
human-guide-template.md ──USE──► guide-creator ──WRITE──► human-guides/*.md
                                            │
NEXUS-Architecture.md ───────READ──► guide-creator
                         READ──► help
```

Key observations: documentation-registry.yaml is the hub — 3 of the 4 skills read it (help, staleness-checker, dashboard), 1 writes it (guide-creator). Only guide-creator modifies any files. The other three are purely read-only. NEXUS-Architecture.md serves as the source discovery engine for both guide-creator and help.

### Registry Entry Structure

Each guide in documentation-registry.yaml follows this schema:

```yaml
guide-slug:
  title: "Guide Title"
  filepath: ".nexus/human-guides/guide-slug.md"
  status: active | planned
  category: getting-started | domain | system-reference
  target_level: beginner | intermediate | advanced | all
  topics: [topic1, topic2, topic3]
  description: "One-line description"
  size_kb: 15
  created: "2026-03-06"
  last_updated: "2026-03-06"
  references:
    - file: "source-file.md"
      version: "1.0.0"
```

The `references` array is what connects the documentation lifecycle — guide-creator writes it at generation time, and staleness-checker reads it to detect drift.

[/Section: Data-And-Files]

---

## How Documentation Connects to Other Systems
[Section: Integration-Points]

### Inbound Connections

Two operations from other domains call into the documentation system:

- **`/nexus-validate` (Step 8D)** checks whether an evaluated issue touched `.nexus/active/` or `.claude/skills/` files and, if so, offers to update stale guides via `/nexus-guide-creator`. This is how documentation stays connected to the development workflow — when framework files are validated, their docs can be refreshed.

- **`/nexus-maintain` (Phase 5)** calls staleness-checker automatically to assess documentation health as part of the overall system maintenance cycle. The compact summary is included in the maintenance report alongside other health metrics.

### Outbound Connections

The documentation domain has no outbound calls to other operational domains. It reads from shared registries and state files but doesn't trigger operations elsewhere. This makes it a "leaf" domain — it consumes system data to produce human-facing output.

### Shared Resources

The documentation operations read from several cross-cutting resources:

- **documentation-registry.yaml** — the domain's own registry (3 readers, 1 writer)
- **changelog-registry.yaml** — read by guide-creator (for version tracking in guide headers) and staleness-checker (for current version comparison)
- **NEXUS-Architecture.md** — read by guide-creator (source file discovery and relationship context) and help (architecture and relationship questions)
- **dashboard** additionally reads issues-registry, patterns-registry, project-state, sprint-state, and system-state — one per dashboard scope

### Maintenance Integration

Documentation health is tracked in system-state.md under the Subsystem-Verification section. The maintenance-scheduler considers documentation staleness when predicting the next maintenance cycle. Regular staleness checks during maintenance keep the feedback loop running — source files change → staleness detected → guides regenerated → registry updated.

[/Section: Integration-Points]

---

## Quick Reference
[Section: Quick-Reference]

### Commands at a Glance

| Command | Skill | What It Does |
|---------|-----------|-------------|
| `help` / `how do I` / `explain` | nexus-help (Q&A mode) | Answer NEXUS questions progressively |
| `browse docs` / `show documentation` | nexus-help (Browse mode) | Show guide catalog, read guides |
| `learning path` / `where do I start` | nexus-help (Learning-path mode) | Personalized guide sequence |
| `create guide {name}` | nexus-guide-creator | Generate new guide from sources |
| `regenerate guide {name}` | nexus-guide-creator | Refresh existing guide |
| `check staleness` / `stale docs` | nexus-staleness-checker | Detect outdated guides |
| `dashboard` | nexus-dashboard | Interactive data visualization |

### Key Paths

| What | Where |
|------|-------|
| Skills | `.claude/skills/nexus-help/`, `nexus-dashboard/`, `nexus-guide-creator/`, `nexus-staleness-checker/` |
| Generated guides | `.nexus/human-guides/` |
| Guide template | `.nexus/templates/human-guide-template.md` |
| Guide registry | `.nexus/active/registries/documentation-registry.yaml` |
| Version registry | `.nexus/active/registries/changelog-registry.yaml` |

[/Section: Quick-Reference]
