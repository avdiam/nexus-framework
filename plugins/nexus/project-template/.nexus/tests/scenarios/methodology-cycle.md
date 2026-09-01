# Scenario: Methodology Cycle (analyze → build → validate)
*Targets: nexus-analyze + nexus-build v2.10.1 + nexus-validate (current) | Suite: ISS-086 | Last baselined: 2026-06-03*

Mutation class: **mutating** (phase scores + ISS body) → run **live on a sandbox issue** (reuse the `ISS-T01` sandbox from issue-lifecycle, or a dedicated `ISS-T02`) with cleanup, OR **dry-run narrated**. Never advance a real issue's scores to satisfy the test.

## Given (preconditions)
- A sandbox issue at `A:1 I:1 E:1`, `_status: in_progress`, with a valid Solution-Design + Implementation-Plan (or a minimal stub created for the test).

## Trigger
- Drive the phase chain: analyze the issue (A→4), transition to build (I→4), transition to validate (E→4/5).

## Expected Behavior
1. **Phase gate discipline**: transitions only at score ≥ 4 with explicit confirmation; phases never skipped (A→I→E or A→R→E; no jumps).
2. **Methodology load per transition**: Analysis→`/nexus-analyze`, Analysis→Implementation→`/nexus-build`, Implementation→Evaluation→`/nexus-validate` (capability loaded after confirm — phase work without its methodology is a violation).
3. **Two-place score update** at every transition with `⛔[TPU-VERIFIED] … match: yes`.
4. Build §POST-TYPE runs mandatory adversarial review (C:3+); Validate runs independent adversarial QA on the whole modification set.
5. `current_focus` in sprint-state tracks the active phase; `continue_with` updated at each handoff.

## State Assertions (MANDATORY)
| Artifact | Field / Anchor | Expected value |
|---|---|---|
| `issues-registry.yaml` | sandbox `analyzed` | reaches `4` before Implementation begins |
| `issues-registry.yaml` | sandbox `implemented` | reaches `4` before Evaluation begins |
| `issues-registry.yaml` | sandbox `evaluated` | reaches `4`/`5` at Validate completion |
| `sprint-state.md` | `[OBJECTIVES]` sandbox `A:_ I:_ E:_` | equal registry values at every checkpoint (TPU match) |
| `sprint-state.md` | `[CONVERSATION] current_focus` | tracks `analysis`→`implementation`→`evaluation` |
| (response text) | per-transition `⛔ [TPU-VERIFIED]` | emitted, `match: yes` |

## Out of Scope
- Research path (A→R→E) and loop-back / decompose (→ ISS-087).
- Batch mode (`_build_mode: batch`) execution loop.
- Full cognitive-tool-pack internals.

## Run Results
*(appended by SELF-EXECUTION-PROTOCOL; empty until a worked run is recorded)*
