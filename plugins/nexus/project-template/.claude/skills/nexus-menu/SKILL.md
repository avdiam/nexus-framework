---
name: nexus-menu
description: Browse and launch NEXUS operations from a categorized command index. Use when the user wants to see available commands or jump to an operation by name — not to explain how something works (that's help).
disable-model-invocation: false
---
*Version: 3.5.0 | Date: 2026-08-20 | Sprint: 110*

# NEXUS Menu System

**Flow**: Route by argument → Display menu → Invoke selected skill

Guided navigation for exploring NEXUS operations. Read-only dispatcher — no files modified. All menus inline — no sub-file loading needed.

## Usage

- `/nexus-menu` → shows main menu
- `/nexus-menu sprint` → shows sprint menu directly
- `/nexus-menu issue` → shows issue menu directly
- Available domains: project, sprint, issue, pattern, maintenance, documentation, cognitive-tools

## Router

| Argument | Section |
|---|---|
| *(empty)* | [Main Menu](#main-menu) |
| project | [Project](#project-menu) |
| sprint | [Sprint](#sprint-menu) |
| issue | [Issue](#issue-menu) |
| pattern | [Pattern](#pattern-menu) |
| maintenance | [Maintenance](#maintenance-menu) |
| documentation | [Documentation](#documentation-menu) |
| cognitive-tools | [Cognitive Tools](#cognitive-tools-menu) |
| *(unrecognised)* | [Main Menu](#main-menu) — note the argument was not recognised, then show the main menu |

Display the matching section. When user selects a numbered option, invoke the corresponding `/nexus-*` skill.

---

## Main Menu

```
==================================================
    NEXUS COMMAND CENTER
==================================================
1. PROJECT: status | define | re-define
2. SPRINT:  status | organize | checkpoint | close
3. ISSUE:   create | update | list | close | archive
4. PATTERN: list | apply | stats | consolidate
5. BRAINSTORM: discuss / talk things through
6. COGNITIVE TOOLS: Mental models | Problem-solving | Strategic reflection
7. SYSTEM:  System health & maintenance operations
8. HELP:    Help with Nexus | Read Documentation | Learning paths
9. DASHBOARD: Issues | Patterns | Project | Sprint | Maintenance
0. Exit menus

Enter choice or describe what you need:
==================================================
```

| Choice | Action |
|---|---|
| 1 | Show [Project](#project-menu) |
| 2 | Show [Sprint](#sprint-menu) |
| 3 | Show [Issue](#issue-menu) |
| 4 | Show [Pattern](#pattern-menu) |
| 5 | Invoke `/nexus-brainstorm` (parallel non-executing phase — discuss/talk things through) |
| 6 | Show [Cognitive Tools](#cognitive-tools-menu) |
| 7 | Show [Maintenance](#maintenance-menu) |
| 8 | Show [Documentation](#documentation-menu) |
| 9 | Invoke `/nexus-dashboard` |
| 0 | Exit menu system |

---

## Project Menu

```
==================================================
    PROJECT MANAGEMENT
==================================================
1. Project Status & Overview
2. Define New Project
3. Generate MVP Issues
4. Close Project
5. Initialize Project (first-run)
6. Map Project Context (brownfield)
7. Update Project Parameters (re-define)
8. Update Project State (progress)
0. Return to main menu
==================================================
```

| Choice | Invoke |
|---|---|
| 1 | `/nexus-project-status` then show actions |
| 2 | `/nexus-setup-project` |
| 3 | `/nexus-generate-mvp` |
| 4 | `/nexus-close-project` |
| 5 | `/nexus-init-project` |
| 6 | `/nexus-map-context` |
| 7 | `/nexus-setup-project` (Update Mode) |
| 8 | `/nexus-update-state` |
| 0 | Return to [Main Menu](#main-menu) |

**Context flows:**
- After defining: "Project created! Next: Generate MVP issues or skip to sprint planning?"
- After generating issues: "Created {X} issues. Ready to organize sprints? [Y/n]" → `/nexus-organize-sprint`

---

## Sprint Menu

```
==================================================
    SPRINT MANAGEMENT
==================================================
1. Show Current Sprint Status
2. Organize & Check Queue
3. Save Checkpoint
0. Return to main menu
==================================================
```

| Choice | Invoke |
|---|---|
| 1 | `/nexus-sprint-status` then show actions submenu |
| 2 | `/nexus-organize-sprint` |
| 3 | `/nexus-checkpoint` |
| 0 | Return to [Main Menu](#main-menu) |

**Actions submenu** (after status):

| Choice | Invoke |
|---|---|
| 1 | `/nexus-move-issues` |
| 2 | `/nexus-close-sprint` |
| 0 | Back to sprint menu |

If `_status == complete` or no sprint organized: "No active sprint. Use option 2 to organize your next sprint."

---

## Issue Menu

```
==================================================
    ISSUE MANAGEMENT
==================================================
1. List Open Issues
2. Show Ready Issues
3. Show Blocked Issues
4. Search/Query Issues
5. Create New Issue
6. Quick Log Issue
7. Park an Idea as a Seed
8. Show Seeds
0. Return to main menu
==================================================
```

| Choice | Invoke |
|---|---|
| 1 | `/nexus-view-issues open` then show selection |
| 2 | `/nexus-view-issues ready` then show selection |
| 3 | `/nexus-view-issues blocked` then show selection |
| 4 | `/nexus-view-issues ask` then show selection |
| 5 | `/nexus-create-issue` |
| 6 | `/nexus-create-issue quick` |
| 7 | `/nexus-plug-seed` |
| 8 | List `.nexus/seeds/` (per CLAUDE.md [Section: Routing-Map] seeds: "show seeds") |
| 0 | Return to [Main Menu](#main-menu) |

**Issue selection** (after list — user enters ISS-XXX):

| Choice | Invoke |
|---|---|
| 1 | `/nexus-work-issue ISS-{id}` |
| 2 | `/nexus-update-issue ISS-{id}` |
| 3 | `/nexus-close-issue ISS-{id}` |
| 4 | `/nexus-archive-issue ISS-{id}` |
| 5 | `/nexus-decompose-issue ISS-{id}` |
| 0 | Back to list |

---

## Pattern Menu

```
==================================================
    PATTERN MANAGEMENT
==================================================
1. Browse & View Patterns
2. Match Patterns (context-aware)
3. Merge Patterns (find similar)
4. Create New Pattern
5. Delete Patterns
6. Update Pattern Effectiveness
0. Return to main menu
==================================================
```

| Choice | Invoke |
|---|---|
| 1 | `/nexus-list-patterns` |
| 2 | `/nexus-match-pattern` |
| 3 | `/nexus-merge-patterns` |
| 4 | `/nexus-create-pattern` |
| 5 | `/nexus-delete-pattern` |
| 6 | `/nexus-update-pattern` |
| 0 | Return to [Main Menu](#main-menu) |

---

## Maintenance Menu

```
==================================================
    SYSTEM MAINTENANCE
==================================================
ASSESS:
 1. System Health Diagnostic
 2. Maintenance Prediction
 3. Subsystem Verification

EXECUTE:
 4. Pattern Maintenance
 5. Registry Cleanup
 6. Issue Validation
 7. Backup Optimization
 8. Prune Memory

UTILITIES:
 9. System Rollback
10. Changelog Scan
11. Rebuild Architecture Map

 0. Return to main menu
==================================================
```

| Choice | Invoke |
|---|---|
| 1 | `/nexus-health-diagnostic` |
| 2 | `/nexus-maintenance-scheduler` |
| 3 | `/nexus-subsystem-verification` |
| 4 | `/nexus-pattern-maintenance` |
| 5 | `/nexus-registry-cleanup` |
| 6 | `/nexus-issue-validation` |
| 7 | `/nexus-backup-optimization` |
| 8 | `/nexus-prune-memory` |
| 9 | `/nexus-rollback` |
| 10 | `/nexus-changelog-scan` |
| 11 | `/nexus-rebuild-architecture` |
| 0 | Return to [Main Menu](#main-menu) |

---

## Documentation Menu

```
==================================================
    DOCUMENTATION & HELP
==================================================
1. Help with NEXUS
2. Check Staleness
3. Create/Update Guide
0. Return to main menu
==================================================
```

| Choice | Invoke |
|---|---|
| 1 | `/nexus-help` |
| 2 | `/nexus-staleness-checker` |
| 3 | `/nexus-guide-creator` |
| 0 | Return to [Main Menu](#main-menu) |

---

## Cognitive Tools Menu

```
==================================================
    COGNITIVE TOOLS
==================================================
MENTAL MODELS:
 1. First Principles        6. Analogical Reasoning
 2. Systems Thinking        7. Load all Mental Models
 3. Inversion Thinking
 4. Decision Trees
 5. Probabilistic Thinking

PROBLEM-SOLVING:
 8. Blind Spot Check       13. Pre-mortem Analysis
 9. Mental Simulation      14. Adversarial Review
10. Hypothesis Testing     15. Load all Problem-Solving
11. Root Cause Analysis
12. Counterfactual Reasoning

STRATEGIC:
16. Strategic Reflection
17. Load all Strategic Approaches

OTHER:
18. Load all cognitive tools
19. Show what's currently loaded
 0. Return to main menu
==================================================
```

### Which Tool When

| Tool | Use When |
|---|---|
| First Principles | Starting fresh, challenging assumptions |
| Systems Thinking | Component interactions, feedback loops |
| Inversion | Avoiding failure, finding obstacles |
| Decision Trees | Multiple options, sequential choices |
| Probabilistic | Uncertain outcomes, risk assessment |
| Analogical Reasoning | Parallel problems in other domains |
| Blind Spot | About to decide, need validation |
| Mental Simulation | Validating designs before finalizing, walking through execution |
| Hypothesis Testing | Multiple causes, need structured investigation |
| Root Cause | Symptom vs cause, deep investigation |
| Counterfactual | Exploring what-if alternatives |
| Adversarial Review | Challenging complex proposals, mandatory for Build self-eval C:3+ |
| Pre-mortem Analysis | Validating a plan by assuming it failed and backtracking the causes |
| Strategic Reflection | Architecture decisions, high-stakes |

### Routing

| Choice | Invoke |
|---|---|
| 1-6 | `/nexus-mental-models {name}` |
| 7 | `/nexus-mental-models all` |
| 8-13 | `/nexus-problem-solving {name}` |
| 14 | `/nexus-problem-solving adversarial-review` |
| 15 | `/nexus-problem-solving all` |
| 16 | `/nexus-strategic strategic-reflection` |
| 17 | `/nexus-strategic all` |
| 18 | Load all three packs |
| 19 | Display loaded cognitive tools from memory |
| 0 | Return to [Main Menu](#main-menu) |
