---
name: nexus-list-patterns
description: List, view, and search active patterns with effectiveness data
disable-model-invocation: true
---
*Version: 2.1.0 | Date: 2026-08-20 | Sprint: 110*

# List Patterns

**Flow**: Load registry → Filter/sort → Display (list/stats/detail) → Handle response

List, view, and search active patterns with effectiveness data. Read-only browsing.

---

This is a read-only browsing operation. It loads the registry once, then responds to user navigation — listing, filtering, statistics, and detail views. PAT files are only loaded when the user requests a specific pattern's details.

### STEP 0: Load Registry

`Read .nexus/active/registries/patterns-registry.yaml` (memory-first). If load fails, suggest registry-cleanup and return.

---

### STEP 1: Display Pattern List

Show all patterns grouped by type, sorted within each group by maturity (established first) then effectiveness (highest first).

```
📐 Active Patterns ({total})
═══════════════════════════════════════════════════════════════════════════

{TYPE_NAME} ({count})
ID       Name                           Maturity      Eff    Domain
─────────────────────────────────────────────────────────────────────────────
{patterns in group}

{repeat for each type: PRINCIPLES, METHODOLOGIES, PRACTICES, SOLUTIONS}

═══════════════════════════════════════════════════════════════════════════

Choices:
  1. View pattern details (enter PAT-XXX)
  2. Filter by type / domain / keywords
  3. Show pattern statistics
  4. Return to main menu
```

---

### STEP 2: Handle Navigation

Interpret user input flexibly — they may type a PAT ID, a filter keyword, a menu number, or a natural language request like "show me validated patterns for refactoring."

- **PAT ID** (e.g., "PAT-029", "029"): Go to STEP 4 (detail view).
- **Filter request** (e.g., "principles", "validation domain", "proven patterns"): Re-display the list filtered accordingly. Show a "back to full list" option.
- **Statistics** (e.g., "3", "stats"): Go to STEP 3.
- **Main menu** (e.g., "4", "back", "menu"): Exit operation.

---

### STEP 3: Statistics View

```
📊 Pattern Statistics
═══════════════════════════════════════════════════════════════════════════
Total Active: {count} patterns

By Type:                    By Maturity:              By Effectiveness:
  principles:    {n}          established:  {n}         ≥80%:   {n}
  methodologies: {n}          proven:       {n}         60-79%: {n}
  practices:     {n}          validated:    {n}         <60%:   {n}
  solutions:     {n}          emerging:     {n}

Top Performers:
  {top 4: ID  name  eff%}

Average Effectiveness: {mean}%
═══════════════════════════════════════════════════════════════════════════

Choices:
  1. View pattern details (enter PAT-XXX)
  2. Return to full list
  3. Return to main menu
```

---

### STEP 4: Detail View

Load the PAT file for the requested pattern (memory-first). If the file can't be loaded, show registry data only with a warning.

Display essential sections:

```
═══════════════════════════════════════════════════════════════════════════
📐 {pattern_id}: {name}
═══════════════════════════════════════════════════════════════════════════

Type: {type} | Domain: {domain} | Maturity: {maturity}

─── METRICS ──────────────────────────────────────────────────────────────
Effectiveness: {eff}% {visual_bar}  ({successes}✓ {failures}✗ {neutral}∅)
Last Used: {last_used}
By Issue Type: {by_issue_type or 'none recorded'}
Synergies: {synergies or 'none'}

─── PROBLEM ──────────────────────────────────────────────────────────────
{from PAT file ## Problem section}

─── USE WHEN ─────────────────────────────────────────────────────────────
{from registry use_when array — as bullet list}

─── SOLUTION ─────────────────────────────────────────────────────────────
{from PAT file ## Solution section}

─── RATIONALE ────────────────────────────────────────────────────────────
{from PAT file ## Rationale section}

{if Resources section exists}:
─── RESOURCES ────────────────────────────────────────────────────────────
{list available resources with type and description}

═══════════════════════════════════════════════════════════════════════════

Choices:
  1. Apply this pattern (requires active issue context)
  2. View full pattern file
  3. Delete this pattern
  4. Return to pattern list
```

Visual bar: `████████░░` (filled = effectiveness × 10, rounded).

**Handling choices:**

- **Apply**: Check if there's active issue context (sprint-state loaded with current issue in `[OBJECTIVES]`). If yes, invoke `/nexus-match-pattern`. If no, inform: "Apply requires active issue context — start issue work first."
- **Full file**: Display entire PAT file content, then re-show the choices.
- **Delete**: Invoke `/nexus-delete-pattern` with this pattern ID in backend mode. delete-pattern handles protection checks, learning capture, and removal.
- **Return to list**: Go back to STEP 1.
