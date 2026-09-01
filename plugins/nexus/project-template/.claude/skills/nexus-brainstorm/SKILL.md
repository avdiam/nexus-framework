---
name: nexus-brainstorm
description: NEXUS brainstorm phase — project-aware free-talking, non-executing. Selectable at boot widget or via mid-session "brainstorm" trigger; does NOT run analyze/implement/evaluate or sprint operations; CAN mutate project state via normal skill invocations under standard T1/T2/T3 gates.
disable-model-invocation: true
---
*Version: 1.3.1 | Date: 2026-08-20 | Sprint: 110*

# NEXUS Brainstorm Methodology

Free-talking strategic phase that sits **parallel** to the Analyze / Implement / Evaluate lifecycle. Brainstorm is for **direction-shaping conversations**: strategic pivots, framework-wide discussions, scope reshaping, what-if planning. It is *project-aware* (sprint-state, ISS files, registries, patterns all loadable) but *non-executing*: it does NOT run a methodology phase for any specific issue and does NOT execute sprint operations.

---

## When to use

| Signal | Example trigger |
|---|---|
| Scope reshaping at sprint level | "Let's rethink Sprint 086 composition before organizing." |
| Framework-wide discussion | "How does the audit-deferral pattern feel right now?" |

**Entry surfaces**:
- **Boot widget** — `/nexus-start` STEP 9 phase widget option (replaces former sandbox slot).
- **Mid-session** — literal "brainstorm" word (narrow trigger by design — minimizes collision with mid-Analysis "discuss" / "let's discuss" chatter). Mid-session entry fires the phase-override ask gate (see Transitions).

**NOT for**: starting work on an ISS (use the phase widget to select Analysis / Implementation / Evaluation), running a sprint operation (use `/nexus-organize-sprint`, `/nexus-close-sprint` directly), or isolated experimentation (no isolation surface — brainstorm is project-connected).

---

## Behavior Contract

### Non-executing

Brainstorm does NOT execute methodology phases for any specific issue. The flows `/nexus-analyze` → `/nexus-build` → `/nexus-validate` → `/nexus-close-issue` and the sprint operations `/nexus-organize-sprint` / `/nexus-close-sprint` are explicitly **out of scope** of this skill. If the conversation reaches a point where execution is needed, exit brainstorm by selecting the appropriate phase (see Transitions).

### Project-aware

Full read access to:
- Sprint-state, project-state, system-state, sprint-queue
- All ISS files, PAT files
- All registries (issues, patterns, changelog, documentation)
- Active patterns and behavioral preferences

### CAN mutate via normal skills

Brainstorm opens **conversation space**, not a consent bypass. Any state mutation routes through its normal skill and its normal Control-Level gates:

| Mutation | Skill | Gate |
|---|---|---|
| Create issue | `/nexus-create-issue` | T2 |
| Update issue | `/nexus-update-issue` | T3 |
| Close issue | `/nexus-close-issue` | T1 |
| Create pattern | `/nexus-create-pattern` | T2 |
| Maintenance operations | `/nexus-pattern-maintenance`, `/nexus-registry-cleanup`, etc. | per skill |
| Plug seed | `/nexus-plug-seed` | T3 |
| Sprint operations (organize / close) | `/nexus-organize-sprint`, `/nexus-close-sprint` | T1/T2 — exits brainstorm |

If the user asks for a mutation mid-brainstorm, invoke the matching skill and let its gates apply. Brainstorm itself writes only sprint-state via `/nexus-checkpoint` at save points (normal phase semantics, below).

---

## State Semantics

Brainstorm behaves as a **normal phase** for continuity purposes:

| Aspect | Behavior |
|---|---|
| Conversation count | Increments at boot like any other phase |
| Sprint-state `continue_with` | Written at `/nexus-checkpoint` save |
| Checkpoint regime | Shared `/nexus-checkpoint` — no lite mode |
| Sprint cadence | Counts toward sprint cadence like any other phase |
| ISS phase scores | Untouched (no specific-ISS phase work) |
| `current_focus` value | `brainstorm` |

`current_focus: brainstorm` is what `/nexus-start` STEP 7 (L3 phase detection, priority 0) reads on resume to re-enter brainstorm at the next conversation. No methodology load is triggered on entry — brainstorm IS the methodology, self-contained.

---

## Phase-Entry Briefing

On fresh entry (boot widget selection or mid-session switch via ask gate), display a lightweight context anchor (informational only — no approval gate):

> 🧠 Brainstorm — Sprint #{N} Conv #{M}
> Active sprint: {title}
> Open issues: {planned + in_progress count}
> Prior focus before entry: {prior current_focus or "none"}
>
> Project state available; no methodology loaded. Mutations via normal skills (T1/T2/T3 gates apply).

Then continue with the conversation. No scripted protocol from this point — free-form discussion is the methodology.

---

## Transitions

### Mid-session entry (phase override)

When the literal "brainstorm" trigger fires during another phase, the phase-override ask gate surfaces:

> ⚠️ Active phase: {X} (ISS-{YYY}). Switch to brainstorm phase? This pauses ISS-{YYY} work; resume via 'continue {X}' or boot widget.
>
> [Switch / Stay in {X}]

- **Switch** → set `current_focus: brainstorm`, load this skill, render the entry briefing
- **Stay** → no state change, continue in active phase

The gate is mandatory. Falling through silently violates `ask_dont_assume` for high-stakes routing.

**ISS-absent adaptation**: when the active phase has no ISS attached (maintenance, planning/organize-sprint, learning/close-sprint, or re-entry from brainstorm itself), omit the `(ISS-{YYY})` and `ISS-{YYY} work` clauses — render: `⚠️ Active phase: {X}. Switch to brainstorm phase? This pauses {X} work; resume via 'continue {X}' or boot widget. [Switch / Stay in {X}]`.

### Exit to a lifecycle phase

The user names the next phase explicitly. Common transitions:

| Trigger | Routes to |
|---|---|
| "analyze ISS-XXX" | `/nexus-analyze` |
| "implement / build ISS-XXX" | `/nexus-build` |
| "evaluate / validate ISS-XXX" | `/nexus-validate` |
| "organize sprint" | `/nexus-organize-sprint` |
| "close sprint" | `/nexus-close-sprint` |

At exit, the next `/nexus-checkpoint` save writes the new `current_focus` value. Brainstorm leaves no residue beyond the conversation transcript and any explicit mutations the user authorized via other skills.

### Compaction recovery

If compaction fires mid-brainstorm, compaction recovery routes through `/nexus-start`, which detects `current_focus: brainstorm` and re-loads this skill. No methodology re-load is required (self-contained).

---

## Continuous Self-Checks (SC-08 inheritance)

All CLAUDE.md continuous protocols remain active in brainstorm:

- Status line display — event-triggered (at gates, phase transitions, issue/sprint closure, checkpoints, zone crossings, user request)
- Token tracking + zone monitoring (Yellow 70% → checkpoint prompt; Red 80% → mandatory save)
- 📐 pattern transparency at every pattern application
- Violation detection + counter
- Memory-First Rule on reads
- ⛔[WRITE-VERIFIED] gate on high-stakes writes (fires when a mutation skill is invoked)
- Two-Place-Update Protocol (if a mutation skill touches issue phase scores)

Brainstorm changes the *conversational character*, not the *operational discipline*.

---

## Anti-Patterns

| Anti-pattern | Why wrong |
|---|---|
| Running analyze / build / validate steps directly inside brainstorm | Violates non-executing contract — exit to the methodology first |
| Bypassing T1/T2/T3 gates because "we're just talking" | Brainstorm opens space, not consent bypass — gates always apply |
| Writing ISS / PAT / registry files inline without invoking a skill | All mutations route through their normal skill |
| Skipping `/nexus-checkpoint` at boundaries | Normal-phase state semantics — same checkpoint discipline |
| Treating brainstorm as a no-state isolation surface | That was sandbox (retired). Brainstorm IS project-connected. |
