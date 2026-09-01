# Pattern System Guide
*Version: 1.2.0 | Date: 2026-08-24 | Sprint: 110 | Category: domain*

*How patterns capture reusable wisdom in NEXUS — creating, matching, tracking effectiveness, and evolving the knowledge base over time.*

**Source files:**
- .claude/skills/nexus-create-pattern/SKILL.md v2.2.0
- .claude/skills/nexus-delete-pattern/SKILL.md v2.2.0
- .claude/skills/nexus-list-patterns/SKILL.md v2.1.0
- .claude/skills/nexus-match-pattern/SKILL.md v2.3.0
- .claude/skills/nexus-merge-patterns/SKILL.md v2.1.0
- .claude/skills/nexus-update-pattern/SKILL.md v2.2.0
- .nexus/templates/pattern-specification.md v3.2.2
- .nexus/active/registries/patterns-registry.yaml v11.0.0
- CLAUDE.md v5.16.0

---

## What Are Patterns?
[Section: Introduction]

Patterns are NEXUS's long-term memory — generalizable wisdom extracted from specific project experiences. When you solve a problem in a particularly effective way, or discover that a certain approach consistently works across different contexts, that knowledge becomes a pattern.

A pattern is NOT documentation of what happened on a specific issue. A pattern IS:

- **Strategic guidance** for future decisions — it tells NEXUS what to do when it recognizes a similar situation
- **Generalizable wisdom** — it applies across multiple issue types and contexts, not just the one it came from
- **Actionable instruction** — it contains concrete behavioral guidance, not vague advice

Patterns form a feedback loop: you work on issues, discover what works, extract that wisdom into patterns, and NEXUS proposes those patterns when similar situations arise in future work. Over time, the system gets smarter about how it approaches problems.

After reading this guide you'll understand how patterns are created and validated, how NEXUS matches them to your current work, how effectiveness tracking works, and how the pattern ecosystem stays healthy through merging and cleanup.

[/Section: Introduction]

---

## Core Concepts
[Section: Core-Concepts]

### Pattern Types

Every pattern has a type that describes the kind of wisdom it captures:

| Type | What It Captures | Example |
|------|-----------------|---------|
| **Principle** | Guiding philosophy — WHY something works | "Always search before creating" |
| **Methodology** | Structured process — HOW to approach a problem class | "E2E mental simulation before declaring complete" |
| **Practice** | Proven technique — WHAT works in specific contexts | "LLM behavioral programming principles" (PAT-004) |
| **Solution** | Specific answer to a recurring problem class | Targeted fix patterns for known failure modes |

Principles are foundational — they're never deleted and never merged. They shape how NEXUS thinks. Methodologies and practices are the workhorses, proposed during analysis and implementation. Solutions are the most specific, applied to narrow problem classes.

### The 4Q Validation Gate

Not every lesson learned deserves to become a pattern. Before any pattern is created, it must pass four questions:

1. **Q1 Strategic**: Does it guide FUTURE decisions, not just document the PAST?
2. **Q2 Non-obvious**: Would someone NOT do this without being told?
3. **Q3 Generalizable**: Does it apply across multiple contexts?
4. **Q4 Wisdom**: Does it explain WHY and WHEN, revealing non-obvious relationships?

All four must pass. If a lesson fails any question, it returns `NOTED_AS_LEARNING` — not promoted, but recorded in `rejected_patterns.jsonl` at sprint closure — rather than elevated to a pattern. This gate prevents the pattern registry from filling with trivial or overly specific entries.

### Maturity Lifecycle

Patterns grow through four maturity levels based on usage evidence:

```
emerging → validated → proven → established
   0 apps     3+ apps    5+ apps, ≥70% eff    10+ apps, ≥85% eff
```

- **Emerging**: New pattern, hypothesis only. Effectiveness starts at 0.50 (untested baseline).
- **Validated**: Has 3+ successful applications — the approach works.
- **Proven**: 5+ applications with ≥70% effectiveness — consistently reliable.
- **Established**: 10+ applications with ≥85% effectiveness — reference standard. Candidates for embedding directly into system files.

Maturity only advances automatically, never regresses. If effectiveness drops below threshold, it's flagged for review but not auto-demoted.

### Outcome Verdicts

Every applied pattern is scored at closure as one of three verdicts — never an automatic success:

| Verdict | Meaning | Counter Effect |
|---|---|---|
| **helped** | Genuinely contributed, beyond what the framework already enforces | `successes += 1` |
| **neutral** | Applied but added no value beyond an always-on rule/skill, or contribution indeterminate | `neutral += 1` (increments neither successes nor failures) |
| **hindered** | Misled, added friction, or caused rework | `failures += 1` |

**Dedup hard-gate**: a pattern whose guidance merely restates an always-on CLAUDE.md rule/preference or a skill step caps at `neutral` — it cannot be scored `helped` regardless of application count. Each verdict requires a one-line evidence note, captured at issue closure and applied at sprint closure.

### Effectiveness Score

Effectiveness is calculated from actual usage outcomes:

```
effectiveness = 0.50 + ((success_rate - 0.50) × volume_confidence)

where:
  success_rate = successes / (successes + failures)          # neutral excluded
  volume_confidence = min(1.0, (successes + failures) / 10)  # neutral excluded
```

This formula means untested patterns start at 0.50 (neutral baseline), early results move the score modestly (low confidence), and patterns with 10+ helped/hindered applications fully reflect their actual success rate. A pattern with 8 successes and 2 failures scores 0.80 — high enough for "proven" status. A pattern applied 12 times but helping only twice (2 successes, 0 failures, 10 neutral) stays at 0.60 — the echo-pattern stays skeptical rather than inflating.

### Pattern Governance in CLAUDE.md

CLAUDE.md defines how patterns are used during active work through transparency rules:

| Fit Assessment | Action |
|---------------|--------|
| Above 80% fit | Auto-applied: "📐 Applying: PAT-XXX" |
| 70-80% fit | Strongly recommended: "📐 Strongly recommend: PAT-XXX" |
| 50-70% fit | Mentioned: "📐 Consider: PAT-XXX" |
| Below 50% fit | Not mentioned |

You always have the final say — you can reject or modify any pattern suggestion.

[/Section: Core-Concepts]

---

## How the Pattern System Works
[Section: How-It-Works]

### The Pattern Lifecycle

```
 ┌─────────────┐     4Q Gate      ┌──────────────┐
 │ Experience   │ ───────────────► │ New Pattern   │
 │ (ISS work,   │    passes all 4  │ (emerging,    │
 │  sprint       │                  │  0.50 eff)    │
 │  closure)    │                  └──────┬───────┘
 └─────────────┘                         │
        │                                │ Applied to issues
        │ fails 4Q                       ▼
        ▼                         ┌──────────────┐
 ┌─────────────┐                  │ Track Usage   │
 │ NOTED_AS_    │                  │ (helped/      │
 │ LEARNING     │                  │  neutral/     │
 └─────────────┘                  │  hindered)    │
                                   └──────┬───────┘
                                         │
                          ┌──────────────┼──────────────┐
                          ▼              ▼              ▼
                   ┌───────────┐  ┌───────────┐  ┌───────────┐
                   │ Promote   │  │ Maintain  │  │ Flag for  │
                   │ maturity  │  │ current   │  │ review    │
                   │ (if meets │  │ level     │  │ (low eff) │
                   │ threshold)│  └───────────┘  └───────────┘
                   └───────────┘
```

### When Patterns Get Proposed

NEXUS proposes patterns at specific points during issue work:

- **During analysis** (`/nexus-analyze` STEP 4): After understanding the problem, NEXUS searches for patterns that address similar problem classes. These shape the analysis approach.
- **During implementation** (`/nexus-build` STEP 3): Before building, NEXUS checks for implementation-relevant patterns — coding practices, architectural approaches, or methodology patterns.
- **On demand**: You can say "match patterns" or "find matching patterns" anytime to trigger a search against the current context.

The matching process (`/nexus-match-pattern`) reads the full patterns registry, scores every pattern against your current work context using semantic judgment — not keyword matching — and recommends the top 1-4 matches with rationale.

### When Patterns Get Updated

Pattern effectiveness is tracked at sprint closure:

1. **`/nexus-close-sprint`** reads `[PATTERNS_IN_USE]` from sprint-state — which patterns were applied to which issues
2. For each pattern used, **`/nexus-update-pattern`** determines the verdict (helped/neutral/hindered) with a one-line evidence note from issue closure data
3. Counters are incremented per verdict, effectiveness is recalculated, maturity promotion is checked
4. Registry is patched with updated metrics

This means patterns earn their reputation through actual project results, not through declaration.

### When Patterns Get Created

Two paths lead to new patterns:

**Automatic (sprint closure)**: When closing a sprint, NEXUS reviews the sprint's experience captured in `[CANDIDATES_PATTERNS]` and `[DISCOVERIES]`. Promising candidates go through create-pattern's automatic mode — extraction, generalization, 4Q validation, similarity check, and creation.

**Manual**: You say "create pattern" and describe the wisdom you want to capture. NEXUS helps you generalize from specifics, validates through 4Q, checks for duplicates, and creates the pattern collaboratively.

Both paths enforce the same quality gates: 4Q validation and similarity checking against existing patterns.

[/Section: How-It-Works]

---

## Working With Patterns
[Section: Operations-Guide]

### Browsing Patterns

**Command:** `show patterns` or `list patterns`

Displays all active patterns grouped by type (principles, methodologies, practices, solutions), sorted by maturity then effectiveness. From the list you can filter by type, domain, or keywords, view statistics (distribution by type, maturity, top performers), or drill into any pattern's detail view.

The detail view shows the full pattern — problem, solution, rationale, metrics, and relationships — with options to apply it, view the full PAT file, or delete it.

### Creating a Pattern

**Command:** `create pattern` or `new pattern`

The creation workflow:

1. **Gather** — NEXUS helps you articulate the problem class, solution approach, context (when to use / when not), type, and rationale. This is collaborative — NEXUS proposes content and challenges vague input.
2. **4Q Validate** — All four strategic questions must pass. If any fail, the candidate returns `NOTED_AS_LEARNING` (recorded in `rejected_patterns.jsonl` at sprint closure) — you can also revise the candidate or override.
3. **Similarity Check** — Compares against all existing patterns semantically. If a close match exists (40-70% similar), you choose: create as separate, merge with existing, or cancel. Above 70%, cancellation is recommended but not forced.
4. **Generate** — Loads pattern-specification.md, generates the PAT file and registry entry following the spec's writing guidance.
5. **Preview & Approve** — Full preview of both the PAT file content and the registry entry before any writes.
6. **Create** — Atomic write: PAT file first, then registry update (meta.last_id increment, meta.active increment, new entry). If registry fails, PAT file is rolled back.

**Example scenario:** After discovering that verifying API capabilities through testing before relying on documentation consistently prevents integration failures, you say "create pattern." NEXUS helps you generalize from "our API had wrong docs" to the pattern class "verify actual capabilities through testing before documenting or relying on them" — which becomes a new PAT entry.

### Matching Patterns to Current Work

**Command:** `match patterns` or `find matching patterns`

NEXUS reads the full registry and scores every pattern against your current context — the issue you're working on, the phase you're in, what's been discussed, and what patterns are already in use.

Scoring considers problem relevance (most important), track record (effectiveness and volume), domain fit, and type alignment. Synergies with already-applied patterns boost scores; conflicts are flagged but don't auto-exclude.

You receive up to 4 recommendations with fit assessments and rationale. After accepting, NEXUS loads the full PAT files, adapts the guidance to your specific situation (targeting 70-90% reuse with 10-30% customization), and records the application in sprint-state `[PATTERNS_IN_USE]`.

### Updating Pattern Metrics

**Command:** `update pattern PAT-XXX` or `track effectiveness`

Typically called automatically by `/nexus-close-sprint`, but can be triggered manually. Determines the verdict (helped/neutral/hindered) with a one-line evidence note for each pattern used, recalculates effectiveness, checks maturity promotion thresholds, and patches the registry.

This operation only touches metrics — it never modifies the PAT file content itself.

### Merging Similar Patterns

**Command:** `merge patterns` or `consolidation opportunities`

Scans the registry for semantically similar patterns (same problem class, overlapping approaches). Principles are excluded — they're never merged.

For each candidate pair, NEXUS loads both PAT files, does a deep comparison, and recommends a keeper (stronger foundation) and a merge-from (contributing unique wisdom). You approve the direction, and the merge executes: keeper is enhanced with the merge-from's unique insights, then merge-from is deleted via delete-pattern (which handles registry cleanup and stale reference removal).

### Deleting Patterns

**Command:** `delete pattern` or `remove pattern`

Identifies candidates based on low effectiveness (<0.50 with 3+ applications), long unused (10+ sprints), or superseded status. Principles are protected — never deletable. Established patterns trigger a strong warning.

Before deletion, you're offered the chance to capture any remaining lessons in sprint-state `[SYSTEM_ISSUES]`. The deletion itself is thorough: stale synergy/conflict references are cleaned from other patterns' registry entries, the registry entry is removed (meta.active decremented), and the PAT file is deleted with backup.

[/Section: Operations-Guide]

---

## Key Files and Data Flow
[Section: Data-And-Files]

### File Inventory

| File | Location | Purpose |
|------|----------|---------|
| patterns-registry.yaml | `.nexus/active/registries/` | Metadata store for all active patterns — 16 prefixed fields per entry. Source of truth for matching, effectiveness, and discovery. |
| PAT-XXX.md | `.nexus/patterns/` | Individual pattern files — full content including problem, solution, rationale, examples, anti-patterns. Loaded only when needed (detail view, matching, merging). |
| pattern-specification.md | `.nexus/templates/` | Authoritative schema for both PAT files and registry entries. Loaded by `/nexus-create-pattern` after validation gates pass. |
| 6 operation skills | `.claude/skills/nexus-{name}/SKILL.md` | The workflows described in the Operations Guide above (create-pattern, delete-pattern, list-patterns, match-pattern, merge-patterns, update-pattern). |

### Registry Structure

The patterns registry uses a **prefixed key-value format** where every field is globally unique:

```yaml
meta.last_id: 141       # Highest PAT number assigned
meta.active: 52          # Count of active patterns

# --- PAT-004 ---
PAT-004.name: "llm-behavioral-programming"
PAT-004.file: "patterns/PAT-004.md"
PAT-004.type: practice
PAT-004.domain: "prompt-engineering"
PAT-004.maturity: established
PAT-004.description: "10 principles for LLM behavioral programming organized in 4 categories: structural, guidance, efficiency, safety. Clarity over compression as governing philosophy."
PAT-004.use_when:
  - "Creating new system files or agent definitions"
  - "Refactoring existing prompts for efficiency"
  - "Building behavioral specifications for LLMs"
  - "Optimizing token usage while maintaining functionality"
  - "NOT for human documentation or API specs"
PAT-004.successes: 28
PAT-004.failures: 0
PAT-004.neutral: 0
PAT-004.effectiveness: 1.00
PAT-004.last_used: "2026-06-05"
PAT-004.by_issue_type: {Improvement: 17, Feature: 7, Research: 1}
PAT-004.phase_affinity: ["analysis", "implementation", "evaluation"]
PAT-004.synergies: []
PAT-004.conflicts: []
```

This prefixed format enables reliable patching — `PAT-004.successes` is unique across the entire file, so patches never hit the wrong line.

### Data Flow

```
                    ┌─────────────────────┐
                    │ patterns-registry    │
                    │ .yaml               │
                    │ (16 fields per      │
                    │  pattern + meta)    │
                    └──────┬──────────────┘
                           │
           ┌───────────────┼───────────────┐
           │               │               │
     ┌─────▼─────┐  ┌─────▼─────┐  ┌─────▼──────┐
     │ create-   │  │ match-    │  │ update-    │
     │ pattern   │  │ pattern   │  │ pattern    │
     │ (ADD)     │  │ (READ)    │  │ (METRICS)  │
     └─────┬─────┘  └─────┬─────┘  └─────┬──────┘
           │               │               │
           ▼               ▼               │
     ┌───────────┐  ┌───────────┐         │
     │ PAT-XXX   │  │ sprint-   │◄────────┘
     │ .md       │  │ state     │  (reads [PATTERNS_IN_USE]
     │ (content) │  │ [PATTERNS │   for outcome data)
     └───────────┘  │ _IN_USE]  │
                    └───────────┘

  merge-patterns: READ registry + PAT files → WRITE keeper → CALL delete-pattern
  delete-pattern: REMOVE registry entry + DELETE PAT file + CLEAN stale refs
  list-patterns: READ registry + PAT files (display only)
```

### Field Ownership

Not every operation touches every field. Here's who writes what:

| Field Group | Written By | Read By |
|---|---|---|
| Identity (name, file, type) | create-pattern | All operations |
| Classification (domain, maturity, phase_affinity) | create-pattern; update-pattern (phase_affinity reinforcement) | match-pattern, list-patterns, merge-patterns |
| Matching (description, use_when) | create-pattern | match-pattern, merge-patterns, create-pattern (similarity) |
| Effectiveness (successes, failures, neutral, effectiveness, last_used) | update-pattern | match-pattern, list-patterns, merge-patterns, delete-pattern |
| Track Record (by_issue_type) | update-pattern | list-patterns, match-pattern |
| Relationships (synergies, conflicts) | create-pattern; merge-patterns (synergies) | match-pattern, merge-patterns |
| Metadata (last_id, active) | create-pattern (+1), delete-pattern (-1) | All operations |

[/Section: Data-And-Files]

---

## How Patterns Connect to Other Systems
[Section: Integration-Points]

The pattern domain has clear boundaries — it doesn't call into other operational domains, but several domains call into it.

### Inbound Callers

| Caller | Operation | When | What Happens |
|--------|-----------|------|--------------|
| /nexus-analyze | CALL /nexus-match-pattern | STEP 4 (analysis patterns) | Proposes patterns relevant to the analysis phase |
| /nexus-build | CALL /nexus-match-pattern | STEP 3 (implementation patterns) | Proposes patterns relevant to implementation |
| /nexus-close-sprint | CALL /nexus-update-pattern | STEP 3 (effectiveness updates) | Batch-updates metrics for all patterns used during sprint |
| /nexus-close-sprint | CALL /nexus-create-pattern | STEP 4E (pattern extraction) | Creates patterns from sprint candidates |
| /nexus-close-project | CALL /nexus-create-pattern | Optional | Project-level pattern extraction |
| /nexus-pattern-maintenance | CALL /nexus-delete-pattern | Backend mode | Removes low-performing patterns |
| /nexus-pattern-maintenance | CALL /nexus-merge-patterns | Backend mode | Consolidates similar patterns |
| /nexus-list-patterns | CALL /nexus-match-pattern | STEP 4 (Apply from detail) | User applies pattern from browsing view |
| /nexus-list-patterns | CALL /nexus-delete-pattern | STEP 4 (Delete from detail) | User deletes pattern from browsing view |

### State File Touchpoints

| State File | Operation | Direction | What |
|------------|-----------|-----------|------|
| sprint-state.md `[PATTERNS_IN_USE]` | /nexus-match-pattern | WRITE | Records which patterns were accepted for which issues |
| sprint-state.md `[PATTERNS_IN_USE]` | /nexus-update-pattern | READ | Reads outcome data at sprint closure |
| sprint-state.md `[CANDIDATES_PATTERNS]` | /nexus-create-pattern (auto) | READ | Source of pattern candidates at sprint closure |
| sprint-state.md `[SYSTEM_ISSUES]` | /nexus-delete-pattern | WRITE | Optional learning capture before deletion |

### The Sprint Feedback Loop

Patterns participate in a complete feedback cycle across sprint boundaries:

```
Sprint N:
  /nexus-match-pattern → applies PAT-004 to ISS-120
  → recorded in sprint-state [PATTERNS_IN_USE]

Sprint N closure:
  /nexus-update-pattern → reads verdict (helped/neutral/hindered) from ISS-120 closure
  → if helped: increments PAT-004.successes; recalculates effectiveness

Sprint N+1:
  /nexus-match-pattern → PAT-004 now has higher effectiveness
  → ranked higher in future recommendations
```

This means the pattern system genuinely learns from experience — patterns that work get promoted and recommended more often, patterns that don't get flagged for review.

[/Section: Integration-Points]

---

## Quick Reference
[Section: Quick-Reference]

### Commands

| Command | What It Does |
|---------|-------------|
| `show patterns` / `list patterns` | Browse all patterns with filtering and stats |
| `create pattern` / `new pattern` | Create a new pattern (4Q validated) |
| `match patterns` / `find matching patterns` | Find patterns relevant to current work |
| `update pattern PAT-XXX` / `track effectiveness` | Update metrics after usage |
| `merge patterns` / `consolidation opportunities` | Find and merge similar patterns |
| `delete pattern` / `remove pattern` | Remove low-performing patterns |
| `read PAT-XXX` / `load PAT-XXX` | View a specific pattern's details |

### Pattern Types at a Glance

| Type | Question It Answers | Protection |
|------|-------------------|------------|
| Principle | WHY should we do this? | Never deleted, never merged |
| Methodology | HOW should we approach this? | Normal lifecycle |
| Practice | WHAT technique works here? | Normal lifecycle |
| Solution | WHAT specific fix applies? | Normal lifecycle |

### Maturity Thresholds

| Level | Requirements | Effectiveness Formula Result |
|-------|-------------|-----|
| Emerging | New (default) | 0.50 (untested) |
| Validated | ≥3 successes | Typically 0.60-0.65 |
| Proven | ≥5 apps AND ≥0.70 eff | 0.70+ |
| Established | ≥10 apps AND ≥0.85 eff | 0.85+ |

### Key Files

| File | Path | Purpose |
|------|------|---------|
| Registry | `.nexus/active/registries/patterns-registry.yaml` | All pattern metadata (16 fields each) |
| PAT files | `.nexus/patterns/PAT-XXX.md` | Full pattern content |
| Spec | `.nexus/templates/pattern-specification.md` | Authoritative schema |
| Operations | `.claude/skills/nexus-{name}/SKILL.md` | 6 operation skills |

[/Section: Quick-Reference]
