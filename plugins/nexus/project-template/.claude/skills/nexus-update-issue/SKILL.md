---
name: nexus-update-issue
description: Update fields on an existing issue — status, priority, scope, dependencies
disable-model-invocation: false
---
*Version: 2.0.1 | Date: 2026-08-20 | Sprint: 110*

# Update Issue

**Flow**: Parse intent → Load context → Validate → [T2: preview+confirm] → Apply updates → Verify → Report

Update any issue field — metadata (registry), content (ISS sections), or scores (two-place). Handles complexity threshold crossing with scaffolding upgrade. Delegates pattern matching to /nexus-match-pattern.

---

### STEP 0: Parse Intent & Load Context

**A. Extract issue ID** — Find `ISS-XXX` in user message. If not found, ask.

**B. Classify requested changes** — Parse the user's request to determine update types:

| Update Type | Fields | Target |
|---|---|---|
| Metadata | priority, complexity, impact, status, type, target_sprint, blocks, blocked_by, scope_files, notes | Registry (+ sprint-state sync for priority/complexity) |
| Content | description, success criteria, solution design, implementation plan/log, evaluation results, closure, notes & context, work log | ISS file sections |
| Scores | analyzed, implemented, evaluated | Registry + sprint-state (two-place) |
| Pattern request | "match patterns", "find patterns" | load /nexus-match-pattern |

**C. Load context proportional to need**

- `Read .nexus/active/registries/issues-registry.yaml` (targeted search for metadata-only updates)
- `Read .nexus/active/registries/issues-registry.yaml`  (full load when broader context needed)
- `Read .nexus/issues/ISS-{XXX}.md` (content updates or pattern delegation only)
- `Read .nexus/templates/issue-specification.md#[Section: Registry-Schema]` (field validation, when needed)
- `Read .nexus/templates/issue-specification.md#[Section: ISS-File-Structure]` (scaffolding upgrade, when needed)

Metadata-only updates need only a registry search. Content updates need the ISS file. Load spec sections only when validation or structure reference is required. If issue not found in registry: "❌ ISS-{XXX} not found." Exit.

**D. Handle pattern request** — If user requests pattern matching: ensure ISS file and registry are loaded, then `load /nexus-match-pattern`. On return, offer to note applied patterns in Solution Design ### Tools & Patterns. If accepted, proceed as content update. If no other updates remain, exit.

---

### STEP 1: Validate Changes

**A. Enum and range validation** — Validate against Registry-Schema allowed values. For invalid values, suggest closest match with fuzzy matching (e.g., "high priority" → High, "done" → Resolved). Wait for confirmation.

**B. Logical consistency checks** — Warn (user can override with acknowledgment):

- **Status vs scores**: Resolved requires all scores ≥ 4. If not met, suggest In-Progress.
- **Phase progression**: High implementation but low analysis (or high evaluation but low implementation) is unusual.
- **Circular dependencies**: If adding blocked_by creates A→B→A cycle, reject.
- **Resolved blocker**: If blocked_by references an already-resolved issue, note it.

**C. Complexity threshold crossing** — When complexity changes from ≤2 to ≥3 (simple→complex boundary):

The ISS file may be missing complex scaffolding (subsection headers, guidance, optional markers). Offer upgrade:

```
⚠️ Complexity crossing simple→complex ({old} → {new})

1. ✅ Upgrade ISS structure to complex format
2. ⏭️ Skip — capabilities can write without scaffolding

Recommended: Option 1
```

If accepted: add subsection headers and guidance from ISS-File-Structure spec, preserving existing content. Add Notes-Context and Work-Log markers if missing.

Complexity ≥3 to ≤2 (downgrade): no structural change needed — extra structure is harmless.

**D. Ambiguous field routing** — Clarify when ambiguous (e.g., "dependencies" → registry arrays vs ISS narrative, "notes" → registry field vs Work Log). If context makes intent clear, route without asking.

---

### STEP 2: Preview & Confirm

Display the change preview grouped by type:

```
═══════════════════════════════════════════════════════
📝 UPDATE PREVIEW: ISS-{XXX}
═══════════════════════════════════════════════════════

{if metadata:}
METADATA:
{for each: • {field}: {current} → {new}}

{if content:}
CONTENT:
{for each: • {section}: {summary of change}}

{if scores:}
SCORES:
• A:{old_a}→{new_a} I:{old_i}→{new_i} E:{old_e}→{new_e}

───────────────────────────────────────────────────────
Will update: {list affected files}
═══════════════════════════════════════════════════════
```

**[T2: Balanced+Full ask | Streamlined: auto-apply if no warnings, notify]** Use `AskUserQuestion tool`: Apply changes / Modify / Cancel.

If modify: ask which change to adjust, allow edit, return to preview.

---

### STEP 3: Apply Updates

Build all patches in memory first, then apply sequentially.

**A. Metadata** — Patch issues-registry.yaml using prefixed format (`ISS-{XXX}.{field}: {value}`). Array fields use `["item1", "item2"]` or `[]`.

**B. Sprint-state sync** — When priority, complexity, or scores change for an issue in sprint objectives, patch the [OBJECTIVES] line accordingly.

**C. Content** — Patch ISS file sections. Use `Edit tool` with section markers for marker-bounded sections. Use `Edit tool` for subsection-level updates within a section. For optional sections that don't exist yet, insert markers at the appropriate location. For Work-Log, append rather than replace.

**D. Scores (two-place)** — Patch both registry and sprint-state per two-place protocol. After applying, surface phase hints:

- Analyzed reached 4: "💡 Ready for implementation phase"
- Implemented reached 4: "💡 Ready for evaluation phase"
- Evaluated reached 4: "💡 Ready for closure"

**Rollback on failure**: If any write fails after a previous write succeeded, revert the already-applied patches in reverse order from their in-memory pre-images (text files have no file-level backup — if a pre-image is unavailable, `git checkout HEAD -- {path}` restores the last checkpointed version). Report the inconsistent state and offer retry or manual resolution.

---

### STEP 4: Verify & Report

Verify each change: search registry for updated values, check sprint-state objectives line, confirm ISS modification, confirm both registry and sprint-state for scores changes.

**All succeeded:**

```
═══════════════════════════════════════════════════════
✅ UPDATED: ISS-{XXX}
═══════════════════════════════════════════════════════

Changes applied:
{for each: ✓ {field}: {old} → {new}}

{if patterns_added: "📐 Patterns: {list}"}
{if phase_transition: "💡 {phase_transition_message}"}
═══════════════════════════════════════════════════════
```

**Partial success:** List ✓ and ❌ per change with reasons. Recommend manual fix for failures.
