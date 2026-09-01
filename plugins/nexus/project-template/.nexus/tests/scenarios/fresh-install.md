# Scenario: Fresh Install (Plugin Route + Clone Route)
*Targets: plugin `setup` SKILL.md v1.3.0 · plugin `upgrade` SKILL.md v0.1.0 · nexus-start v2.9.2 · nexus-init-project v3.0.0 · export-dist.sh v1.4.0 · dist-manifest.txt v1.2.0 | Suite: ISS-101 | Last baselined: 2026-08-31 (Run 2)*

Mutation class: **mutating, reversible via sandbox** — every write lands in a throwaway folder outside the repo, so the framework's own state is never touched. Two exceptions are machine-level and are called out in Given: registering the marketplace and installing the plugin mutate `~/.claude/plugins/`, and are reversed at Cleanup.

This scenario earns its place in the runtime suite (see `README.md` overlap statement) because it cannot be satisfied by reading files: the question is whether an adopter's Claude, in a folder that has never seen NEXUS, actually reaches a first issue.

---

## Branch Inventory (run this before writing or reading any assertion)

📐 PAT-122 — "green" is earned on two axes: **every branch actually entered**, and **a pass that survives an environment you did not provision**. The suite's summary line cannot distinguish a branch that passed from one that never ran, so the branches are enumerated here first and each assertion below is tagged with the branch it covers.

**Axis 1 — install route** (the two routes ship together; neither substitutes for the other)

| # | Branch | Why it must run |
|---|---|---|
| R1 | Plugin route — `marketplace add` → `install` → `/nexus:setup` | The documented primary |
| R2 | Clone route — `git clone` + copy the three items + hand-write `settings.local.json` | The only route for a no-plugin user **and for Claude Code on the web**; it runs none of `setup`'s guards, so nothing R1 proves carries over |

**Axis 2 — `setup` STEP 1 target state** (R1 only; STEP 1 is the never-overwrite guard)

| # | Branch | Expected |
|---|---|---|
| S1 | Clean folder | Proceed to STEP 2 |
| S2 | `.nexus/` already present | **STOP**, do not copy, route to `/nexus:upgrade` |
| S3 | Foreign `CLAUDE.md`, no `.nexus/` | **STOP and ask**, offer `CLAUDE.md.pre-nexus` backup |
| S4 | Foreign `.claude/settings.json`, no `.nexus/` | **STOP and offer backup** before `cp -r` silently overwrites it |
| S5 | Foreign `.gitignore`, no `.nexus/` | **STOP and offer backup or append** — the template ships its own `.gitignore` and `cp -r` replaces it silently |

S2–S5 are the branches a healthy clean-folder run never enters, and S4 is the one whose failure the skill's own text calls "the worst outcome this skill can produce."

**S5 was added at Run 1** (finding F-13). This matrix originally enumerated *three* pre-existing target states because that is what `setup` STEP 1's guard table enumerated — the matrix inherited the skill's blind spot instead of testing for it. The template ships four top-level items; the guard covered three. Deriving branch inventories from the artifact under test reproduces its omissions, and the correct derivation source is *what the copy writes*, not *what the guard checks*.

**Axis 3 — prerequisite probes** (STEP 2; each is a shell-level branch and can be forced under a doctored `PATH` without a full skill run)

| # | Branch | Expected |
|---|---|---|
| P1 | `python3` resolves | Report version |
| P2 | Only `python` resolves (Windows-typical) | Ladder falls through; **PyYAML must not be reported missing on a machine that has it** |
| P3 | Neither resolves | `python MISSING` + remedy; install continues |
| P4 | PyYAML importable | `pyyaml ok` |
| P5 | PyYAML absent | `pyyaml MISSING` + `pip install pyyaml`; install continues |
| P6 | `jq` present | `jq ok` |
| P7 | `jq` absent | `jq absent` — **a passing, expected state**, never a red (the hooks resolve a parser ladder) |

**Axis 4 — remaining `setup` branches**

| # | Branch | Expected |
|---|---|---|
| C1 / C2 | No parent `CLAUDE.md` / parent present | Silent / warn-only, never act on the parent file |
| L1 / L2 | `settings.local.json` absent / present | Create / **merge preserving every existing key** |
| G1 / G2 | Not a repo / already a repo | Offer `git init` / skip; never commit |

**Axis 5 — first boot chain** (both routes converge here)

| # | Branch | Expected |
|---|---|---|
| B1 | `start` in the installed folder | `/nexus-start` detects `_project_lifecycle: not-defined` → `/nexus-init-project` (v3.0.0, first-run only) → `/nexus-setup-project` → `/nexus-generate-mvp` → `/nexus-organize-sprint` → first issue |
| B2 | Derivation sweep, **second boot** (after B1 sets `_project_lifecycle: active`) | All shipped boot rows `FILLED: 0 findings` or `SKIP (justified)` — **zero** `⚠` warnings (SC-10 / T26 regression) |

⚠ **B2 is measured at the SECOND boot, and the reason is structural** (re-baselined at Run 1, finding F-0). The first boot has `_project_lifecycle: not-defined`, so `/nexus-start` STEP 5 transfers control to `init-project` **before STEP 11** — no startup header is ever rendered, and a `⚠`-line assertion has nothing to bind to. Worse, the first boot is the *only* boot where four of the shipped edges (E-01, E-05, E-06, E-14) still satisfy their fresh-tree guard, which is keyed on `lifecycle ∈ {not-defined, defining}`. Asserting a clean sweep against boot 1 therefore measures a state the adopter occupies for exactly one unrendered screen, and certifies it as the adopter experience. Boot 2 is the first header a human ever sees and the first sweep run against a populated tree — that is the state SC-10 is about.

**Branches that CANNOT be executed on this machine — recorded, never counted toward SC-06**

| # | Branch | Why not, and when it becomes runnable |
|---|---|---|
| U1 | **GitHub-source** marketplace path resolution | The `nexus` marketplace registered here is `"source": "directory"` → `installLocation` is the export dir itself, so `${CLAUDE_PLUGIN_ROOT}` resolves to the export tree. A published adopter gets a GitHub source, which copies to `~/.claude/plugins/marketplaces/nexus/plugins/nexus` (TD-4) — a different path shape this run never touches. Runnable after ISS-100 publishes. |
| U2 | Claude Code **on the web** | No `/plugin`; clone route from a committed repo. Deferred by SC-06 until ISS-100. The web ruling's kill condition (does a cloud session emit the `[context:]` hook tag?) is settled there, not here. |
| U3 | A machine with **no Python at all** (P3, full-skill form) | The probe command can be forced under a doctored `PATH` (and is, in Axis 3), but the end-to-end install on a genuinely Python-less box is not reproducible here. The shell-level probe assertion is the honest substitute and is marked as such. |

---

## Given (preconditions)

- `../nexus-dist/` exists and is a current export — `export-dist.sh` run to completion, personal-path scan 0, two consecutive runs byte-identical.
- The installed plugin cache agrees with that export: `diff -rq ~/.claude/plugins/cache/nexus/nexus/<ver> ../nexus-dist/plugins/nexus` is empty. **A stale cache invalidates the whole run** — it was found pre-Phase-3.4 at ISS-101 Conv 6, still shipping the retired `init-project` new-project mode, which would have let SC-05 pass against the state Phase 3.4 removed.
- Two throwaway target folders outside the repo, each empty, one per route.
- Machine-level mutations acknowledged: `marketplace add` and `install` write to `~/.claude/plugins/`. Reversed at Cleanup.

## Trigger

Per route:
- **R1**: `/plugin marketplace add <export path>` → `/plugin install nexus@nexus` → in the throwaway folder, `/nexus:setup` → then `start`.
- **R2**: copy `plugins/nexus/project-template/{CLAUDE.md,.claude,.nexus}` into the throwaway folder, hand-write `.claude/settings.local.json` → then `start`.

## Expected Behavior

1. `setup` names the target directory and **asks before writing anything** (STEP 1), then runs its presence check.
2. On a clean folder it proceeds; on S2/S3/S4 it **stops** and offers the documented remedy — it never resolves a conflict on its own.
3. Prerequisite probes run on the `python3` → `python` ladder and are **reported, not enforced** — a missing prerequisite prints a remedy and the install continues.
4. A parent `CLAUDE.md` produces a warning only.
5. `cp -r "${CLAUDE_PLUGIN_ROOT}/project-template/." .` lands all three top-level items including dotfile directories; the copy is verified before the step is called done.
6. `settings.local.json` is created or **merged**, then read back — never reported done on the strength of the attempt.
7. `git init` is offered, never assumed, and nothing is committed.
8. The completion report states only verified results, and `setup` **stops** — it does not boot NEXUS itself.
9. `start` then runs the first-run chain to a first issue, with a clean `⚠`-free startup header.

## State Assertions (MANDATORY)

| Artifact | Field / Anchor | Expected value after run | Branch |
|---|---|---|---|
| `~/.claude/plugins/cache/nexus/nexus/<ver>/` vs `../nexus-dist/plugins/nexus/` | `diff -rq` output | empty (precondition, re-asserted) | R1 |
| `<target-R1>/` | `ls -a` | `CLAUDE.md`, `.claude/`, `.nexus/`, `.gitignore` all present | R1, S1 |
| `<target-R1>/.claude/settings.local.json` | `env.CLAUDE_CODE_FILE_READ_MAX_OUTPUT_TOKENS` | `"50000"` | L1 |
| `<target-R2>/.claude/settings.local.json` | same key | `"50000"` — written by hand; the clone route runs no installer | R2, L1 |
| `<target-R1>/.nexus/active/states/sprint-state.md` | `_project_lifecycle` | `not-defined` **before** first boot | R1, B1 |
| `<target-R1>/.claude/skills/nexus-init-project/SKILL.md` | version header | `3.0.0` — the retired-mode-free copy | R1 |
| same file | regex `New-Project Mode` | **absent** | R1 (SC-05) |
| `<target-R1>/.gitignore` | contains `settings.local.json`, `.context-window`, `.freshness-checked`, `backups/` | all four present | R1 (T23 regression) |
| pre-existing `<target-S4>/.claude/settings.json` | full content | **byte-identical to before the run** (or a `.pre-nexus` backup exists) | S4 |
| `<target-S2>/` | files changed by the run | **none** — `setup` refused | S2 |
| `<target-S3>/CLAUDE.md` | full content | unchanged, or backed up to `CLAUDE.md.pre-nexus` | S3 |
| (probe output) | `{ python3 -c "import yaml" \|\| python -c "import yaml"; }` under a `PATH` with no `python3` | `pyyaml ok` — the ladder's second rung reached | P2 |
| (probe output) | `command -v jq` under a `PATH` with no `jq` | `jq absent` and the run is **still green** | P7 |
| (response text) | `setup` completion report | every line reflects a verified result; no NEXUS boot performed | R1 |
| `<target>/…/sprint-state.md` after the chain | `_project_lifecycle`, `[OBJECTIVES]` | `active`; at least one issue listed | B1 |
| (startup header, **boot 2**) | `⚠` line | **absent** | B2 (SC-10) |
| (startup header, **boot 2**) | regex `NEXUS · Sprint #\d+ · Conv #\d+` | present exactly once | B1 |
| `<target-R1>/.nexus/active/registries/changelog-registry.yaml` | mtime vs `.claude/skills/**` | registry is **newest** — `setup` STEP 4's `touch` ran | R1 (F-1) |
| (status line, first session, clone route) | `{K}K [{pct}%` | real figures, not `—` — hooks registered because `.claude/` predated launch | R2 (F-5 control) |
| (`setup` completion report) | hand-off line | instructs **restart Claude Code**, not `say "start"` | R1 (F-5) |
| pre-existing `<target-S5>/.gitignore` | the user's own rules | **every original rule survives** — byte-identical, OR `.gitignore.pre-nexus` exists, OR merged with all original rules intact | S5 (F-13, re-baselined Run 2 / F-15) |

## Out of Scope

- U1 (GitHub-source marketplace), U2 (Claude Code on the web), U3 (a genuinely Python-less machine) — enumerated in the Branch Inventory as unexecuted, with the conditions that make each runnable.
- `/nexus:upgrade` behaviour beyond S2's routing message — the stub carries no write path by construction (T24); ISS-134 owns it.
- Re-verifying export reproducibility or the personal-path scan — owned by SC-02 (T8/T9/T16) and asserted here only as a precondition.
- Static wiring checks — owned by `nexus-subsystem-verification`, per the README overlap statement.

## Run Results

### Run 1 — 2026-08-28 — executor: ISS-101 Conv 7 (orchestrating) + three fresh adopter-side sessions
Mode: **live** — both routes installed to throwaway folders; `setup` invoked interactively by the user in adopter sessions, all state assertions verified from disk by the orchestrating conversation rather than read off the sessions' reports.
Targets at run time: plugin `setup` 1.0.0 · `upgrade` 0.1.0 · nexus-start 2.9.1 · nexus-init-project 3.0.0 · export-dist.sh 1.3.0 · dist-manifest.txt 1.2.0 · export 238 files (`find`), plugin cache byte-identical (T28)

| # | Assertion | Expected | Actual | Verdict |
|---|---|---|---|---|
| 1 | `diff -rq` cache vs `../nexus-dist/plugins/nexus` | empty | empty; `plugin.json` 5.16.0; `init-project` 3.0.0, `New-Project Mode` 0 hits | ✓ PASS |
| 2 | `<target-R1>/` `ls -a` | four items present | `CLAUDE.md .claude/ .nexus/ .gitignore` | ✓ PASS |
| 3 | R1 copy fidelity | template landed intact | `diff -rq` vs `project-template/` = **one line**, `Only in ./.claude: settings.local.json` | ✓ PASS |
| 4 | `<target-R1>` `settings.local.json` → read cap | `"50000"` | `"50000"` | ✓ PASS |
| 5 | `<target-R2>` same key, hand-written (clone route) | `"50000"` | `"50000"` | ✓ PASS |
| 6 | `_project_lifecycle` before first boot | `not-defined` | `not-defined` (both routes) | ✓ PASS |
| 7 | `init-project` version + retired mode | 3.0.0 / absent | 3.0.0 / 0 hits (both routes) | ✓ PASS (SC-05) |
| 8 | `.gitignore` four entries | all present | all four (both routes) | ✓ PASS (T23) |
| 9 | S2 — `.nexus/` present | refuse, route to upgrade, write nothing | refused; `md5` unchanged; 0 files created | ✓ PASS |
| 10 | S3 — foreign `CLAUDE.md` | stop and ask, offer `.pre-nexus` | stopped, offered backup-or-abort; `md5` unchanged | ✓ PASS |
| 11 | S4 — foreign `.claude/settings.json` | stop, offer backup, file survives | stopped, printed the user's own config back, offered `.pre-nexus`; **`md5` byte-identical** | ✓ PASS |
| 12 | P1 `python3` resolves | version reported | `Python 3.14.5` | ✓ PASS |
| 13 | P2 only `python` (doctored `PATH`) | ladder falls through, `pyyaml ok` | `Python 3.14.5` / `pyyaml ok` | ✓ PASS |
| 14 | P3 neither resolves | `python MISSING` | `python MISSING` | ✓ PASS |
| 15 | P4 / P5 PyYAML present / unreachable | `pyyaml ok` / `pyyaml MISSING` | as expected | ✓ PASS |
| 16 | P6 / P7 `jq` present / absent | `jq ok` / `jq absent`, still green | as expected | ✓ PASS |
| 17 | C1 parent `CLAUDE.md` | none found, warn-only if present | none; independent walk agrees | ✓ PASS |
| 18 | G1 `git init` offered, nothing committed | repo, 0 commits | repo initialised, **0 commits** at hand-off | ✓ PASS |
| 19 | L1 create vs merge | created | created and read back | ✓ PASS |
| 20 | B1 chain reaches a first issue | first sprint organised, first issue | `_sprint: 001`, `_status: in_progress`, 12 ISS files, ISS-001 in_progress (Critical, C:3), 2 commits | ✓ PASS |
| 21 | B1 clone-route convergence | `not-defined` → `init-project` | detected and dispatched; 0 files to create; cold-start registries intact | ✓ PASS |
| 22 | **B2 — `⚠` line absent, boot 2** | zero warnings | **six warnings**: `E-01` 8 findings · `E-05` ESCALATED · `E-06` ESCALATED · `E-12` 108 findings · `E-14` 1 finding · 10 unregistered derived-looking | **✗ FAIL** |
| 23 | `setup` report is verified-only, and it stops | no boot performed | report accurate; did not boot | ✓ PASS |

**B2 decomposition** (the whole point of executing rather than reading). Same install, only the wizard differs:

| Edge | t-R2 (`defining`) | t-R1 (`active`) | Family |
|---|---|---|---|
| E-12 | `108 findings / 111` | `108 findings / 111` | **install-path** — invariant to lifecycle, caused by `cp -r` mtime order |
| E-01 | `SKIP (justified)` | `ISS-001 0/28 absent` | cold-start sweep |
| E-05 | `SKIP (justified)` | `ESCALATED` | cold-start sweep |
| E-06 | `SKIP (justified)` | `ESCALATED` | cold-start sweep |
| E-14 | `SKIP (justified)` | `vision → vision: canonical and copy disagree` | cold-start sweep |

E-12 fires identically regardless of lifecycle, so the copy causes it. The other four flip purely on `_project_lifecycle`, so they are independent of installation and would fire in any project one conversation after `setup-project` — the fresh-tree guard is keyed on `lifecycle ∈ {not-defined, defining}` and expires exactly one conversation before the corpus stops being cold.

**Findings** — 13, split by family. Fixed in ISS-101 Phase 4: **F-1** E-12 install artifact (remedy `touch` proven 108 → 0) · **F-2** shipped `nexus-start` cited the curated-out E-13 · **F-4** `sprint-state-template.md` shipped `_self_hosting: true`, disagreeing with its `project-state` twin (found unprompted by two independent adopter sessions) · **F-5** hooks never register on the plugin route because `.claude/` arrives mid-session — token tracking and the 70%/80% checkpoint net dead for the whole first session, and STEP 7 steered the user straight into it · **F-11** `setup` ("first checkpoint commits") contradicted `init-project` (commits at first boot) · **F-13** `.gitignore` silently overwritten, no guard row · **F-0** this file's own B2 baseline · plus D-obs-1/2/3 (STEP 1+6 offers merged; report template one item short; S2 row invented an install path). Spun off as cold-start sweep semantics: **F-3** `_sprint: XXX` makes the escalation clock non-numeric · **F-6** `generate-mvp` output fails E-01 8/8 (`0/28` guidance comments) · **F-7** E-14 `vision` disagreement · **F-8/F-9** guard expiry (E-05/E-06 ESCALATED) · **F-10** negative-space probe reports 10 unregistered derived-looking files on an untouched adopter tree · plus: `/nexus-checkpoint`'s reactive changelog scan did **not** rewrite the registry when measured here, contradicting `nexus-start` STEP 4's claim that it closes E-12's loop.

**F-5 control case** — t-R2's first session, no restart, read `131K [13% ■□□□□□□□□□]`; t-R1's plugin-route session read `—` for its entire life and reached 32% unmonitored. Same files, same tree, only launch order differed. That pins the remedy to one sentence rather than a settings change.

Drift flagged: **B2 re-baselined from boot 1 to boot 2** (F-0) — the original assertion bound to a screen that is never rendered; the framework is not at fault, the spec was. **S5 branch added** (F-13) — the matrix had inherited `setup` STEP 1's own three-item blind spot.
Post-run: fixes applied to plugin `setup` 1.1.0, `sprint-state-template.md` 1.13.0, `nexus-start` 2.9.2; re-exported (237 receipt / 238 `find`), two consecutive runs byte-identical. **The installed plugin cache is now stale again and must be refreshed before any re-run** — the same trap step 4.0 was created to catch.
Cleanup: `t-R1`, `t-R2`, `t-S2`, `t-S3`, `t-S4` pending deletion; the `nexus` marketplace registration and installed plugin are machine-level and stay.


### Run 2 — 2026-08-31 — executor: ISS-101 Conv 8 (orchestrating) + two fresh adopter sessions
Mode: **live, targeted**. Run 1 executed `setup` **1.0.0**; 4.2b then changed the skill, so the version that ships had never been run. A diff of 1.0.0 → 1.1.0 showed the changes land on STEP 1's confirm text and guard table, STEP 4's copy + `touch`, STEP 6's commit rule and STEP 7's report — i.e. squarely on R1/S1/B1, plus **S5, which Run 1 never executed at all**. Everything the diff does not touch (P1–P7, C1, G1, L1, S2–S4, R2) stays green on Run 1 evidence and was not re-run. Four assertions, not twenty-three.

Cache refresh was **not** a plain reinstall: `plugin.json.version` derives from the CLAUDE.md header, which correctly did not move through 4.2b/4.3/4.4, so `cache/nexus/nexus/5.16.0/` still held `setup` 1.0.0 and a reinstall would have re-seated it. Both cache dirs (5.15.0 orphan included) were deleted to force fresh bytes. See IE-18.

| # | Assertion | Expected | Actual | Verdict |
|---|---|---|---|---|
| 1 | **S5 — pre-existing `.gitignore`** (first ever execution) | STOP, offer a documented remedy, never silently overwrite | stopped before writing; named the conflict; printed the user's three rules back; offered merge / backup / abort. Merge chosen: `node_modules/`, `*.log`, `secrets.env` survive verbatim at the head of the file, template block appended below | ✓ PASS |
| 2 | R1/S1 — four items land, both folders | `CLAUDE.md .claude/ .nexus/ .gitignore` | all four, both targets | ✓ PASS |
| 3 | L1 — read cap written | `"50000"` | `"50000"`, both targets | ✓ PASS |
| 4 | `init-project` 3.0.0, retired mode absent | 3.0.0 / 0 hits | 3.0.0 / 0 hits, both targets | ✓ PASS (SC-05) |
| 5 | **F-1 — `touch` fires inside a REAL install** (T36 proved the remedy, not its wiring) | registry newest | registry `09:53:26`, sources `09:53:19`, **0 framework files newer** | ✓ PASS |
| 6 | **E-12 on the adopter tree** | 0 findings | **`FILLED: 0 findings / 111 bound`** (Run 1: 108 findings) | ✓ PASS |
| 7 | B1 — chain reaches a first issue | sprint organised, ≥1 issue | `_sprint: 001`, `_status: in_progress`, lifecycle `active`, 7 ISS files, ISS-001 in_progress (Critical, C:2), 1 commit | ✓ PASS |
| 8 | **B2 — `⚠` line absent, boot 2** | zero warnings | **five warnings**: E-01 3 findings · E-05 ESCALATED · E-06 ESCALATED · E-14 1 finding · 10 unregistered derived-looking | **✗ FAIL — unchanged verdict, changed composition** |
| 9 | Sweep loads the curated row set | 10 boot rows of 14 (E-13, E-16 absent by design) | 10 of 14 | ✓ PASS |

**B2's composition is the result, not its verdict.** Every Run-1 warning that ISS-101 owned is gone; every survivor belongs to ISS-250:

| Edge | Run 1 | Run 2 | Owner |
|---|---|---|---|
| E-12 | 108 findings | **0** | ISS-101 — **fixed** |
| E-01 | 8 findings | 3 findings | ISS-250 (F-6) |
| E-05 | ESCALATED | ESCALATED | ISS-250 (F-8) |
| E-06 | ESCALATED | ESCALATED | ISS-250 (F-9) |
| E-14 | 1 finding | 1 finding | ISS-250 (F-7) |
| unregistered derived-looking | 10 | 10 | ISS-250 (F-10) |

E-01's drop from 8 to 3 is **not** an improvement — it tracks how many C:3+ issues `generate-mvp` happened to emit, which differs per wizard run. Recorded so a later reader does not read it as progress.

**Findings** — 2, both from S5, both folded in here:
- **F-14**: `setup` STEP 1's `.gitignore` row enumerated *four* runtime entries where the template ships *five* (`.nexus/.context-cache` omitted). A guard one enumeration short — the same shape as F-13, the defect that created this guard. Fixed in `setup` **1.2.0** by pointing at the template's own `.gitignore` instead of restating its contents: an enumeration in the skill is a second home for the file's contents and drifts from it; reading the real file cannot be one short.
- **F-15**: this file's own S5 assertion demanded *byte-identical or `.pre-nexus`* — two remedies, where the skill offers three and **recommends the third**. The merge that best preserves the user's rules would have scored as a failure. Same defect class as F-0: the spec enumerated the wrong outcome set. Re-baselined.

Cleanup: `r2-R1`, `r2-S5` and the Run-1 folders (`t-R1`, `t-R2`, `t-S2`, `t-S3`, `t-S4`) pending deletion at issue closure. The `nexus` marketplace registration stays; both plugin caches were deleted during this run and the current one was reinstalled from the export.
