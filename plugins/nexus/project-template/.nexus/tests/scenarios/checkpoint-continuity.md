# Scenario: Checkpoint / Continuity
*Targets: nexus-checkpoint (current) + nexus-start v2.1.0 | Suite: ISS-086 | Last baselined: 2026-06-03*

Mutation class: **mutating** (checkpoint writes sprint-state) → run **live with a sandbox copy** of sprint-state, or **dry-run narrated** against the real file. Never assert by corrupting the live lifeline.

## Given (preconditions)
- An active sprint mid-work with a known `conversation_number = N` and a non-trivial `continue_with`.
- Context below 80% (Progress checkpoint) OR a user "save checkpoint" request.

## Trigger
- User says `save checkpoint` (or yellow-zone accept, or red-zone auto at 80%).

## Expected Behavior
1. `/nexus-checkpoint` is **invoked via the Skill tool** — the workflow is NOT improvised (improvising = CRITICAL violation).
2. sprint-state `[BOOTSTRAP] continue_with` rewritten with WHAT/WHY/PLAN/FIRST for the next conversation.
3. `[CONVERSATION] conversation_number` and `sprint_state_saved_at_conv` updated; `checkpoint_saves` incremented.
4. `[CONVERSATION_HISTORY]` gains a one-line entry for this conversation.
5. Git commit made at checkpoint (project-wide `git add -A`).
6. **Continuity proof**: a subsequent fresh `start` resumes at exactly the point `continue_with` describes (Core Principle #1).

## State Assertions (MANDATORY)
| Artifact | Field / Anchor | Expected value after run |
|---|---|---|
| `sprint-state.md` | `[BOOTSTRAP] continue_with` | non-empty; contains `WHAT:` and `FIRST:` lines |
| `sprint-state.md` | `[CONVERSATION] conversation_number` | equals the saved value used by the next boot's increment rule |
| `sprint-state.md` | `[CONVERSATION] checkpoint_saves` | incremented by 1 vs. pre-checkpoint |
| git | `git log -1 --oneline` | new commit present, message references checkpoint/sprint |
| next boot | resumed phase/ISS | matches `continue_with.WHAT` (continuity holds) |

## Out of Scope
- Red-zone forced-save behavior under real 80% pressure (→ ISS-087).
- Checkpoint-error-recovery paths (save failure after retry).
- Compaction-recovery interaction with conversation_number (→ ISS-087).

## Run Results
*(appended by SELF-EXECUTION-PROTOCOL; empty until a worked run is recorded)*
