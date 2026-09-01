# Scenario: Issue Lifecycle (create → work → close)
*Targets: nexus-create-issue + nexus-work-issue + nexus-close-issue (current) | Suite: ISS-086 | Last baselined: 2026-06-03*

Mutation class: **mutating, reversible via sandbox** → run **live with a sandbox issue ID** (e.g. `ISS-T01`) and **clean up** at the end (delete the sandbox ISS file + revert registry/state rows). Never use a real issue ID.

## Given (preconditions)
- An active sprint, `_status: in_progress`.
- A free sandbox ID not colliding with any real issue (verify by grep before creating).

## Trigger
- `create issue` → wizard/assisted creation of the sandbox issue.
- Then `work on ISS-T01` → analysis; then drive A→I→E to completion.
- Then `close issue ISS-T01`.

## Expected Behavior
1. **Create**: `/nexus-create-issue` runs the testability gate on success criteria; writes `.nexus/issues/ISS-T01.md` and an `issues-registry.yaml` entry; per-write `⛔[WRITE-VERIFIED]` on the new ISS file.
2. **Work**: phase methodology loads (Analysis → `/nexus-analyze`); scores updated via **two-place update** (registry + sprint-state) with `⛔[TPU-VERIFIED]` emitted each time.
3. **Close**: `/nexus-close-issue` sets resolution, extracts knowledge, sets registry `status: Resolved`.
4. Registry and sprint-state `[OBJECTIVES]` scores stay in sync at every transition (no single-place update).

## State Assertions (MANDATORY)
| Artifact | Field / Anchor | Expected value |
|---|---|---|
| `.nexus/issues/ISS-T01.md` | file exists after create | present (then removed at cleanup) |
| `issues-registry.yaml` | `ISS-T01.analyzed/implemented/evaluated` | match `sprint-state [OBJECTIVES]` A/I/E exactly (TPU match: yes) |
| `issues-registry.yaml` | `ISS-T01.status` | `Open`→`In-Progress`→`Resolved` across the run |
| (response text) | `⛔ [TPU-VERIFIED] ISS-T01` … `match: yes` | emitted at each score update |
| (response text) | `⛔ [WRITE-VERIFIED]` on ISS-T01 create | emitted with `status: present` |

## Out of Scope
- Decompose / move / reject-as-rejected paths (→ ISS-087).
- Real-issue lifecycle (forbidden — sandbox only).
- Pattern-application transparency internals.

## Run Results
*(appended by SELF-EXECUTION-PROTOCOL; empty until a worked run is recorded — live run MUST record sandbox-ID cleanup on the Cleanup line)*
