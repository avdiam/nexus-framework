---
name: nexus-view-issues
description: List and filter active issues by status, priority, type, or sprint
disable-model-invocation: true
---
*Version: 2.0.0 | Date: 2026-04-02 | Sprint: 066*

# View Issues

**Flow**: Load registry → Interpret query → Filter & sort → Display (list/detail/no-results) → Handle response

List and filter active issues by status, priority, type, phase scores, sprint, or natural language query. Read-only — routes to work-issue, update-issue, or create-issue based on user response.

---

### STEP 0: Load Registry

`Read .nexus/active/registries/issues-registry.yaml` if not in memory. Extract total_active count and parse all issue entries.

Display: "📋 Registry loaded: {total_active} active issues"

If registry fails to load: inform user, suggest retry or registry-cleanup operation.

---

### STEP 1: Interpret Query

Determine what to show based on how the operation was invoked.

**Preset filters** (from menu routing or command keywords):

| Preset | Trigger | Filter |
|---|---|---|
| open | "list issues", "open issues", Menu Option 1 | status IN [Open, In-Progress] |
| ready | "ready issues", Menu Option 2 | status IN [Open, In-Progress] AND blocked_by = [] |
| blocked | "blocked issues", Menu Option 3 | blocked_by NOT empty |
| ask | "search issues", "query issues", Menu Option 4 | Prompt user for criteria |

If preset is `ask`, prompt:

```
🔍 Search Issues

Enter criteria (examples: "high priority bugs", "sprint 048",
"analyzed but not implemented", "authentication"):

Search:
```

**Natural language interpretation**: For any input — preset or freeform — interpret flexibly using semantic judgment. Most queries ("high priority bugs", "what's blocking progress") are semantically transparent. For NEXUS-specific filter terms, use this reference:

| Term | Filter | Why |
|---|---|---|
| "analyzed" / "analysis complete" | analyzed >= 4 | Phase score >= 4 = phase complete (NEXUS convention) |
| "not analyzed" | analyzed < 3 | Score 1-2 = not meaningfully started |
| "implemented" | implemented >= 4 | Same threshold convention |
| "ready to evaluate" | analyzed >= 4 AND implemented >= 4 AND evaluated < 3 | Both prerequisite phases complete, evaluation not started |
| "ready to implement" | analyzed >= 4 AND implemented < 3 | Analysis complete, implementation not started |
| "nearly done" | analyzed >= 4 AND implemented >= 4 AND evaluated >= 3 | All phases in progress or complete |
| "complex" / "hard" | complexity >= 3 | Aligns with simple/complex scaffolding boundary |
| "simple" / "easy" | complexity <= 2 | Aligns with simple/complex scaffolding boundary |
| "current sprint" | target_sprint = {_sprint from sprint-state} | Resolves to active sprint number |

Common filter dimensions: status, type, priority, impact, complexity, phase scores, target sprint, dependencies (ready/blocked/blocking), and text search across title and description.

Multiple criteria combine with AND logic.

**Single issue detection**: If input contains an ISS-XXX pattern matching exactly one issue, show the detailed single-issue view (STEP 3B) instead of a list.

---

### STEP 2: Filter & Sort

Apply interpreted criteria against all active issues. Collect matching results.

**Default sort**: ISS number ascending (creation order).

**Alternative sorts** — apply when user requests: by priority (Critical first), by complexity (ascending or descending), by progress (highest A+I+E sum first), by sprint.

**Result analysis:**

| Count | Action |
|---|---|
| 0 | Show no-results response with suggestions (STEP 3C) |
| 1 | Show detailed single-issue view (STEP 3B) |
| 2-20 | Show list view (STEP 3A) |
| >20 | Show top 20 with refinement prompt |

---

### STEP 3: Display Results

**A. List view** (2+ results)

Two display modes — compact table (default) and expanded cards. User can toggle between them.

**Compact table:**

```
═══════════════════════════════════════════════════════════════════════════════
📋 {TITLE} ({count})                                    Ready: {ready} │ Blocked: {blocked}
═══════════════════════════════════════════════════════════════════════════════
ID       Title                                      Type  Pri  Cpx  A I E  Dep
───────────────────────────────────────────────────────────────────────────────
ISS-XXX  {title_40_chars}                            Feat  High ███░░ 4 2 1  ✓
ISS-YYY  {title_40_chars}                            Bug   Med  █░░░░ 1 1 1  🔒1
───────────────────────────────────────────────────────────────────────────────
📊 {priority_counts}                        Avg Complexity: {avg} │ In-Progress: {ip}
═══════════════════════════════════════════════════════════════════════════════
```

**Expanded cards:**

```
═══════════════════════════════════════════════════════════════════════════════
📋 {TITLE} ({count})                                    Ready: {ready} │ Blocked: {blocked}
═══════════════════════════════════════════════════════════════════════════════

── {PRIORITY} ({group_count}) ────────────────────────────────────────────────

ISS-XXX │ {full_title}
        │ {type} │ {cpx_bars} {complexity} │ A:{a} I:{i} E:{e} │ {dep_status} │ Sprint {sprint}

═══════════════════════════════════════════════════════════════════════════════
```

**Formatting rules:**

| Element | Format |
|---|---|
| Title (compact) | Max 40 chars, append "..." if truncated |
| Title (cards) | Full, no truncation |
| Type | Bug, Feat, Impr, Refr, Doc, Ques, Res, Crea |
| Priority | Crit, High, Med, Low |
| Complexity bars | █░░░░ through █████ (1-5) |
| Dependencies | ✓ (ready), 📍{n} (blocks n), 🔒{n} (blocked by n), 🔄 (in-progress) |

**B. Single issue view** (1 result or ISS-XXX specified)

```
═══════════════════════════════════════════════════════
📋 ISS-{XXX}: {title}
═══════════════════════════════════════════════════════

Type: {type} | Priority: {priority} | Impact: {impact}
Status: {status} | Complexity: {complexity_bars} ({X}/5)
Sprint: {target_sprint} | Created: {created}

Scores: Analysis {a}/5 | Implementation {i}/5 | Evaluation {e}/5

───────────────────────────────────────────────────────
Description: {description}

Scope: {scope_files}

Dependencies:
📍 Blocks: {blocks or "None"}
🔒 Blocked by: {blocked_by or "None"}
═══════════════════════════════════════════════════════
```

**C. No results**

```
📋 No Issues Found

Query: {interpreted_query}
Filters: {applied_filters}

Suggestions:
• Broaden criteria: {specific_suggestion}
• Try: "list open issues" for all active
```

---

### STEP 4: Handle Response

After displaying results, the user can:

| Input | Action |
|---|---|
| ISS-XXX | `load /nexus-work-issue` or show single-issue detail |
| "details" / "cards" / "expand" | Toggle to expanded card view, re-display |
| "compact" / "table" / "list" | Toggle to compact table view, re-display |
| Refinement (additional criteria) | Re-run from STEP 1 with added filters |
| "create issue" | `invoke /nexus-create-issue` |
| "modify" / "update" / "update issue ISS-XXX" | `invoke /nexus-update-issue` |
| "back" / "menu" | Return to Issue Menu |

For list views, use `AskUserQuestion tool` widget when offering the standard options (enter ISS-XXX, toggle view, refine, update, back).
