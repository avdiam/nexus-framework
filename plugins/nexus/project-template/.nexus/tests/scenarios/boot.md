# Scenario: Boot / Startup Sequence
*Targets: nexus-start v2.3.0 | Suite: ISS-086 | Last baselined: 2026-06-09*

Mutation class: **read-only** (boot writes only the two runtime hint files, never mutates sprint-state/registries) → safe to run **live**.

## Given (preconditions)
- A valid `.nexus/active/states/sprint-state.md` with `_status: in_progress` (or `ready` / `closing` / `complete`).
- `_project_lifecycle: active`.
- Model with a `[1m]` suffix in its ID (→ 1M window) OR `[200k]`/default (→ 200K).

## Trigger
- First user message of the conversation: `start` (or `hi`, or any command).

## Expected Behavior
1. **Silence rule honored** — no step labels / progress narration before the boot log (only the STEP 9 widget surfaces earlier).
2. `.nexus/.context-window` written with the numeric denominator and read back to verify.
3. sprint-state read; **derivation sweep** runs (unless rate-limited by `.freshness-checked` **line 1** matching current sprint+conv). The sweep reads `.nexus/active/derivations.yaml` and executes every `runs_at: boot` row's predicate non-fatally.
4. STEP 9 widget: Control Level (always) + Phase (always); Cognitive only if complexity > 3.
5. Exactly one output: the **startup header** (4–5 lines) — line 1 `NEXUS · Sprint #{N} · Conv #{N}`, line 2 `{phase_label} · Control: {level} · {model} [{window}]`, a `Focus →` line, and a `Context:` line. **No** `═══ NEXUS BOOT LOG ═══` border, no per-step `[TAG] ✓` receipts.
6. The `⚠` warnings line appears **only** when an abnormal condition fired (sweep-stale edge, edge predicate ESCALATED/failed, unregistered derived-looking artifact, unreadable manifest, malformed state, degraded methodology, no git repository, files_to_load section-not-found); omitted entirely on a clean boot → 4 lines clean, 5 lines with a warning.
7. Status line emitted at end of the response.

## State Assertions (MANDATORY)
| Artifact | Field / Anchor | Expected value after run |
|---|---|---|
| `.nexus/.context-window` | full content | `1000000` (1M model) or `200000` (200K model) — numeric, no `1M`/`200K` string |
| `.nexus/.freshness-checked` | **line 1** | `sprint={current _sprint} conv={current conversation_number}` — unchanged since Sprint 096; this line alone is the rate-limit key |
| `.nexus/.freshness-checked` | **lines 2+** | zero or more staleness-ledger lines `stale: E-NN=SSS` ({edge id}={sprint first seen stale}), one per edge the sweep reported stale; **no lines when nothing is stale** (ISS-240 Phase 3.4) |
| `.nexus/active/derivations.yaml` | full file | **unchanged** — boot executes the manifest's predicates, never writes to the manifest (the ledger is the only runtime state) |
| `.nexus/active/states/sprint-state.md` | `_status`, `_sprint` | **unchanged** from pre-boot (boot does not mutate sprint-state) |
| (response text) | regex `NEXUS · Sprint #\d+ · Conv #\d+` | present exactly once (startup header line 1) |
| (response text) | literal `═══ NEXUS BOOT LOG ═══` | **absent** (boot-log block removed) |
| (response text) | regex `Sprint:\s*#\d+\s*\|\s*Conv:\s*#\d+` | present (status line) in last 3 lines |

## Out of Scope
- Compaction-recovery boot path (→ ISS-087).
- First-run / setup-resuming lifecycle branches (`not-defined` / `defining`).
- Malformed / missing sprint-state recovery branches.

## Run Results

### Run 1 — 2026-06-03 — executor: Sprint 096 Conv 5 (live, self-observed)
Mode: live (read-only scenario — boot mutates only the two runtime hint files)
Targets at run time: nexus-start v2.1.0 | model claude-opus-4-8[1m] (1M window)

| # | Assertion | Expected | Actual | Verdict |
|---|---|---|---|---|
| 1 | `.nexus/.context-window` content | `1000000` (1M model) | `1000000` (written + read back in STEP 1B) | ✓ PASS |
| 2 | `.nexus/.freshness-checked` content | `sprint=096 conv=5` | `sprint=096 conv=5` | ✓ PASS |
| 3 | `sprint-state.md` `_status`/`_sprint` unchanged by boot | `in_progress` / `096` | `in_progress` / `096` (no boot mutation) | ✓ PASS |
| 4 | boot-log block present exactly once | 1× `═══ NEXUS BOOT LOG ═══` | 1× emitted | ✓ PASS |
| 5 | status-line regex in last lines | `Sprint:\s*#\d+\s*\|\s*Conv:\s*#\d+` present | present each response | ✓ PASS |
| 6 | required boot-log entries present | ROOT…FILES (+FRESHNESS, no GIT on Conv 5) | all present; `[GIT]` correctly omitted (Conv 5, not Conv 1); `[FRESHNESS]` present (not rate-limit-suppressed: conv changed 4→5) | ✓ PASS |

Drift flagged: none at run time — observed boot behavior matched nexus-start v2.1.0 spec.
**NOTE (Sprint 111, ISS-240 Phase 3.8): Run 1's row 2 records the format observed at Sprint 096 and is left as recorded — a historical run result, not a live assertion. The live assertion is the State Assertions table above, now updated for the line-1 + ledger format written by `/nexus-start` v2.7.0. Row 2 will read the new shape at the next re-baseline run.**
**NOTE (Sprint 099): Run 1 was baselined against the pre-simplification v2.1.0 boot-log + welcome format. The spec changed to the v2.3.0 exception-based startup header — this scenario needs a re-baseline run (assertions above already updated to the v2.3.0 format).**
Cleanup: n/a — read-only run; hint-file writes are boot's normal idempotent output, not test mutations.
