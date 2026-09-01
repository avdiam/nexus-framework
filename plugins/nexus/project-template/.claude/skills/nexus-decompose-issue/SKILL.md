---
name: nexus-decompose-issue
description: Break complex issues into focused sub-issues when scope exceeds boundaries
disable-model-invocation: true
---
*Version: 2.2.0 | Date: 2026-08-20 | Sprint: 110*

# Decompose Issue

**Flow**: Load context → Analyze scope → Present plan → [T1: approve] → Create children → Close+archive original → Update sprint → Transition to analysis

Break complex issues into focused sub-issues when scope exceeds tractable boundaries. Preserves existing analysis/design work. Called from Analyze, Build, or loop-back on strong decompose signals.

---

### STEP 0: Load Context (SILENT)

**A — Memory check**: Recite files in memory. Identify what needs loading.

**B — Determine target issue**: Extract ISS-XXX from user command, caller context, or ask if ambiguous.

**C — Load issue content**: If ISS-XXX.md not in memory, load it. Extract: title, type, description, scope, success criteria, solution design (if any), implementation plan (if any).

**D — Load registry fields**: Search issues-registry.yaml for ISS-XXX status, scores, blocks, blocked_by. (`related` is **not** a registry field per issue-specification.md Registry-Schema — read the parent's Related note from its ISS `## Dependencies` section, loaded in STEP 0C.)

**E — Validate state**: Issue must be Open or In-Progress. If Resolved, Rejected, Superseded, or already Decomposed: inform user, cannot decompose.

**F — Determine invocation source**: Was this called from a methodology (Analyze `types/*` §E3 decompose-signal scan, Build `## Scope-Escalation-Check`, loop-back STEP 3) or invoked manually? If from a methodology, note which decompose signals triggered the call.

Display:

> 📋 Decomposition Context
> Issue: ISS-{XXX} — {title}
> Type: {type} | Status: {status} | Scores: A:{X} I:{Y} E:{Z}
> Triggered by: {manual / Analyze E3 scan / Build scope-escalation / loop-back STEP 3}
> Signals: {which signals fired, if from methodology}

---

### STEP 1: Analyze Scope

Review issue content and identify natural break points. Consider:

- **Independent deliverables**: Which parts have standalone value?
- **Skill domains**: Do parts require different expertise or methodology focus?
- **Sequential dependencies**: Must any part complete before another can start?
- **Risk profiles**: Are some parts higher-risk than others?
- **Existing progress**: If analysis or implementation has started, which parts have progress and which don't?

Propose 2-4 child issues. For each child, draft:

| Field | Content |
|-------|---------|
| Title | Specific, actionable — not just "Part 1" |
| Type | Inherits from parent unless a part is clearly a different type |
| Description | Focused scope, references parent for context |
| Complexity | Assessed independently — children should be simpler than parent |
| Priority / Impact | Inherit from parent unless a child clearly differs — create-issue backend mode validates the full Registry-Schema, so both must be supplied |
| Scope files | The subset of the parent's scope_files this child touches (or TBD) |
| Success criteria | Subset of parent's criteria that this child addresses |
| Sequencing | blocks/blocked_by relationships between siblings |
| Related | All siblings + original parent |

If the issue has existing Solution-Design content, propose how to distribute it across children. Analysis work already done should be preserved — children inherit relevant design decisions, not start fresh.

**Mid-implementation decomposition** (A:4-5, I:2+): When the parent has partial implementation progress, distinguish between children covering completed work and children covering remaining work. For children inheriting completed phases: note in Notes-Context that implementation is inherited and the first action should be to verify the inherited work and update scores accordingly (the scores will be set correctly when work-issue runs). For children covering new scope: standard fresh start.

---

### STEP 2: Present Decomposition Plan

> 📊 Decomposition Proposal
> ═══════════════════════════════════════
> Original: ISS-{XXX} — {title}
>
> Proposed children:
>
> **Child 1: {title}**
> Type: {type} | Complexity: {N}/5
> Scope: {brief scope}
> Criteria: {which parent criteria this addresses}
> Sequencing: {blocks/blocked_by or "independent"}
>
> **Child 2: {title}**
> Type: {type} | Complexity: {N}/5
> Scope: {brief scope}
> Criteria: {which parent criteria this addresses}
> Sequencing: {blocks/blocked_by or "independent"}
>
> Relationships:
> - Children related to each other (siblings)
> - Children related to ISS-{XXX} (origin)
>
> After creation:
> - ISS-{XXX} status → "Decomposed"
> - ISS-{XXX} archived with resolution noting children
> - Children added to sprint [OBJECTIVES] as planned
> ═══════════════════════════════════════

---

### STEP 3: User Approval (MANDATORY GATE)

**[T1: all levels ask]** Present the plan via widget:

> Approve decomposition?
> [Approve — create children / Adjust — modify proposal / Cancel — keep original]

On **Approve**: proceed to STEP 4.
On **Adjust**: ask what to modify (add/remove children, change scope, adjust sequencing). Revise and re-present STEP 2.
On **Cancel**: inform user. If called from a methodology (Analyze, Build, loop-back), control returns to the calling step. If invoked manually, conversation continues normally.

---

### STEP 4: Create Child Issues

For each proposed child, in sequence:

**A — Create issue file**: `invoke /nexus-create-issue` in backend mode with the child's fields (title, type, description, priority, impact, complexity, scope_files, success criteria).

**B — Set relationships**:
- Patch the newly created ISS-YYY in issues-registry.yaml: `blocks` / `blocked_by` as determined in STEP 1 (sequencing between siblings).
- Set `related` in the child's ISS file `## Dependencies` section (**Related**: all sibling ISS IDs + original ISS-XXX). `related` is an ISS-file field per issue-specification.md Registry-Schema (18 fields, no `related`) — never write it to the registry.

**C — Populate Notes-Context**: Patch child ISS-YYY.md [Section: Notes-Context] with:
```
### Background
Spawned from ISS-{XXX} ({parent_title}) decomposition.
Original issue scope: {brief parent scope}.
This child covers: {specific scope for this child}.
```

**D — Inherit relevant design work**: If the parent had Solution-Design content relevant to this child, copy the applicable subsections into the child's Solution-Design. Mark inherited content using the standard progress marker format: `*Analysis in progress — inherited from ISS-{XXX}, review and adapt*`. This ensures /nexus-analyze context step correctly detects the content as resumable partial analysis rather than treating it as an unknown state.

**Caller-aware context**: If decomposition was triggered from Build (partial implementation exists), note in each child's Notes-Context: "Parent had implementation progress — {summary of files modified and current state}." If triggered from loop-back (approach was wrong), mark inherited design content as: `*Analysis in progress — inherited from ISS-{XXX}, approach failed, needs re-evaluation*`

⛔ GATE: All children must be created and verified on disk before proceeding to STEP 5. If any creation fails, do not proceed — inform user with status of each child (created vs failed) and offer:
- **Retry**: attempt creation of failed children only
- **Continue partial**: proceed with successfully created children, note skipped scope in Notes-Context
- **Rollback**: delete already-created children (Bash `rm` of each child ISS file + registry entry removal), return to caller as if cancelled

---

### STEP 5: Close and Archive Original

**A — Write closure**: Patch ISS-XXX.md [Section: Closure]:
```
### Resolution
Decomposed into {child_list} to improve tractability.
Original analysis preserved in child issues' Notes-Context.

### Knowledge Captured
Decomposition triggered by: {signals}.
{Any insights from the decomposition process.}
```

**B — Update registry**: Patch issues-registry.yaml:
- `ISS-XXX.status: Decomposed`

**C — Archive original**: `load /nexus-archive-issue` in backend mode for ISS-XXX. This moves the file to `.nexus/archived/issues/` and removes the registry entry.

⛔ GATE: Original must be archived only after all children are verified created. Order matters — children first, then close original.

---

### STEP 6: Update Sprint Files

**A — Sprint-state [OBJECTIVES]**: Remove ISS-XXX from in_progress (or planned). Add the first unblocked child to `in_progress` with initial scores (A:1 I:1 E:1). Add remaining children to `planned` — template format `- ISS-XXX: {title} ({priority}, {complexity})`, no score suffix on planned lines (scores appear once a child moves to in_progress).

**B — Sprint-state [BOOTSTRAP]**: Update continue_with:
```
WHAT: Begin analysis on {first_child_title} (ISS-{first_child})
WHY: Decomposed from ISS-{XXX} — fresh analysis for focused scope
CONTEXT: {N} children created, {sequencing notes}
```

**C — Sprint-state current_focus**: Set to "analysis".

**D — Sprint-queue** (if exists): Update capacity — remove original's complexity, add children's combined complexity. If children exceed remaining capacity, flag but don't block:

> ⚠️ Children's combined complexity ({N}) exceeds original ({M}). Sprint may need reorganization.

---

### STEP 7: Transition to Analysis

Display completion summary:

> ✅ Decomposition Complete
> ═══════════════════════════════════════
> Original: ISS-{XXX} — {title} → Decomposed and archived
>
> Children created:
> - ISS-{YYY}: {title} (C:{N})
> - ISS-{ZZZ}: {title} (C:{N})
>
> Sequencing: {ISS-YYY blocks ISS-ZZZ / all independent}
> Sprint objectives updated.
>
> Next: Fresh analysis on ISS-{first_child} ({title})
> ═══════════════════════════════════════

Load /nexus-analyze (read `.claude/skills/nexus-analyze/SKILL.md` — it is not Skill-tool invokable) on the first unblocked child (per sequencing) — it becomes the active work target. Control transfers permanently; /nexus-analyze runs its full flow on the child issue.
