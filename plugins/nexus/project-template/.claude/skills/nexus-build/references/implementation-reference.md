# Implementation Reference
*Version: 3.0.0 | Date: 2026-05-28 | Sprint: 090*

Reference material consulted during Build methodology — loaded on demand when standards checks or specific guidance is needed. See SKILL.md Operational Reminders → Reference Loading Conditions table for when to load each section.

---

## LLM Behavioral Programming
[Section: LLM-Behavioral-Programming]

Practices for writing effective behavioral definitions for LLMs.

**Simple prompt engineering** (standalone prompts):
1. Define role, purpose, scope explicitly upfront
2. Structure with headings, lists, tags
3. Detail tool usage: syntax, parameters, when to use
4. Require step-by-step planning and confirmation
5. Embed domain knowledge
6. Define refusal protocols
7. Set interaction tone
8. Illustrate complex rules with examples

**Multi-file behavioral systems** (interconnected systems like NEXUS):

Format selection — match content type to best format:

| Content Type | Best Format | Why |
|---|---|---|
| Parallel items with same fields | Table | Dense, scannable |
| Sequential procedures | Numbered steps | Order, prevent skipping |
| Simple behavioral rules | Prose | No structural overhead |
| Schemas, configurations, state | YAML | Structure IS the info |
| Conditional branching (>2 paths) | Decision table | All paths visible |
| Template definitions | Code block + field table | Exact format + sources |
| Error recovery | Inline with procedure | Available at failure point |

6-point validation:
0. Read-aloud test: sounds like guidance to colleague, not code?
1. Can I find what to DO in <5 seconds per section?
2. All steps numbered sequentially?
3. Would a fresh instance get this right without improvising?
4. Every format matched to content type?
5. Does removing this sentence lose actionable guidance?

What to preserve: structure references, approval gates, error recovery, methodology steps.
What to avoid: emotional vocabulary, strategic repetition, identity claims, deep nesting (4+), checklists after every operation.

PAT-004 selective application: When applying LLM behavioral programming patterns, evaluate each principle against the specific context. Not all principles apply universally — e.g., "define refusal protocols" matters for user-facing tools but not internal methodology files.

[/Section: LLM-Behavioral-Programming]

---

## Code Creation Rules
[Section: Code-Creation-Rules]

1. Clear naming and consistent conventions
2. Functions do one thing — small, testable units
3. Error handling at every external boundary
4. Input validation before processing
5. Handle edge cases explicitly
6. Comments explain *why*, not *what*
7. Fail safely — graceful degradation over silent corruption
8. No hardcoded secrets or environment-specific paths
9. Security: sanitize inputs, least privilege, avoid injection vectors
10. Dependencies: pin versions, minimize, document requirements

[/Section: Code-Creation-Rules]

---

## Atomic Implementation
[Section: Atomic-Implementation]

After each change, the system must be in a working state. Never break file A expecting file B to fix it later — implement in dependency order (producers before consumers).

Consumer verification: After modifying a producer file, verify at least one consumer still works. Use Grep to find consumers, spot-check critical references.

[/Section: Atomic-Implementation]

---

## NEXUS Framework Standards
[Section: NEXUS-Framework-Standards]

**Version Protocol**: Every system file modification requires version increment. Update file header (`*Version: X.Y.Z | Date: YYYY-MM-DD | Sprint: NNN*`). Track in sprint-state [FILES_MODIFIED]. Increment: PATCH (typos X.Y.Z+1), MINOR (new sections X.Y+1.0), MAJOR (architecture X+1.0.0).

**Creating new system files**:
1. Archaeological discovery — search existing before creating (80-95% already exists)
2. Design with clear purpose, check overlap
3. Create with version header and section tags
4. Integrate: feature in file ✓, routing map updated ✓, menu option ✓, triggers defined ✓, documentation ✓, help text ✓, user flow tested ✓
5. For skills: use SKILL.md format with proper frontmatter
6. Track in sprint-state [FILES_MODIFIED]

**Modifying system files**:
1. Impact check — use Grep to find all references, update them BEFORE making the change
2. Consumer verification — after modifying, verify consumers reference correctly
3. Version increment and header update
4. Track in sprint-state [FILES_MODIFIED]

**Removing system files**:
1. Verify no remaining references (Grep for filename, section tags, skill name)
2. Check routing map entries — remove or redirect
3. Check menu entries — remove or update
4. Archive if content has historical value, delete if superseded
5. Track removal in sprint-state [FILES_MODIFIED]

**Methodology files** (nexus-analyze, nexus-build, nexus-validate, etc.):

Architecture: preserve the 3-load structure — SKILL.md as always-loaded entry point, complex.md for C:3+ toolkit, types/*.md for type-specific workflows. Changes to one file must be cross-referenced against the others for consistency (section references, execution flow, gate tiers).

Design rules for methodology file creation/modification:
1. Checkpoint continuity: each logical step should end with a mental note directive stating what to persist and where — this is the handshake with [Section: Checkpoint-Protocol]
2. Simple path: define explicitly in SKILL.md with exact skip conditions and step sequence — never leave the C:1-2 path implicit
3. Trigger tables: use compact table format for decision logic (not verbose YAML) — scannable at high context
4. Single responsibility per step: if a step does both selection AND generation, split it — keeps gates clean
5. User approval gates as separate steps: never bury a gate inside a larger step where it can be skipped under context pressure

**Registry Updates** (mandatory 5-step process):
1. Read entire registry file first
2. Search for exact target locations
3. Prepare ALL updates
4. Execute in order
5. Validate final state

[/Section: NEXUS-Framework-Standards]
