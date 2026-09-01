*Version: 1.2.0 | Date: 2026-08-06 | Sprint: 107*

# Analyze — Readiness Gate Reference

Lazy-loaded companion to `nexus-analyze/SKILL.md`. Holds the **Readiness Gate** — the deterministic PASS/CONCERNS/FAIL verdict run at every **C:3+** analysis-phase transition — externalized from the always-loaded SKILL.md body (ISS-209, Class-A; deep-audit F5). Single-source (PAT-113): each type file's §6 Transition (`default`/`bug`/`creative`/`question`/`research`) invokes [Section: Readiness-Gate] by reference with a branch parameter. The C:1-2 Simple Path transition does **not** invoke this gate — load this file only on a C:3+ §6 Transition.

---

## Readiness Gate
[Section: Readiness-Gate]

Runs at every **C:3+** analysis-phase transition (A→I, A→R, A→V). Invoked from each type file's §6 Transition with a branch parameter. *(The C:1-2 Simple Path transition does not invoke this gate.)* Computes a verdict from three inputs, renders it, and routes the next action based on verdict.

This is single-source — the spec lives here, not in type files. Type files invoke by reference.

### Inputs

| Input | Source |
|---|---|
| Analyzed score | `issues-registry.yaml` → `ISS-XXX.analyzed` |
| End-of-Workflow **Verifications** group | `nexus-analyze/SKILL.md` [Section: End-of-Workflow-Checklist] → `### Verifications` — run before invoking the gate. The *Transition actions* group is explicitly **not** an input: those items are performed by §6 after this gate returns PASS. |
| One-way doors | ISS Solution-Design ### Risks & Mitigations + ### Key Decisions — flag any decision that is hard or costly to reverse once implemented |

### One-Way Door Format (hybrid)

Free-text tag with an *optional* mitigation line. Use the mitigation line only when the door is non-trivial enough to warrant a plan:

```
⚠️ One-way door: {description}
   → Mitigation: {plan}
```

A one-way door without a mitigation line is acceptable when the cost of reversal is fully captured in the description and no further plan is needed. A door *with* a mitigation line signals that the user has thought through how to recover or de-risk.

### Verdict Logic

Compute verdict deterministically from the inputs:

| Verdict | Condition |
|---|---|
| **PASS** | Analyzed score ≥4 AND checklist passes 100% AND (no one-way doors flagged OR all flagged doors carry mitigation lines) |
| **CONCERNS** | Analyzed score ≥4 AND checklist mostly passes (best-effort gaps acceptable) AND any of: one-way door without mitigation, low-confidence design topic, deferred preference area that affects scope |
| **FAIL** | Analyzed score <4 OR the Verifications group has hard failures (ISS not written, plan not approved, score not calculated) OR critical structural gap (Files Affected empty, no Implementation-Plan) |

### Checklist Branches

The checklist items differ by transition target. All branches share the same verdict logic, display format, and behavior — only the items differ. Branches:

| Branch | Used by | Transition target | Items added beyond core |
|---|---|---|---|
| `default` | `types/default.md` (Feature/Improvement/Refactor/Documentation) | A→I `/nexus-build` | None — uses core only |
| `research` | `types/research.md` | A→R `/nexus-research` | Research-tailored: Research Design written (mode, subjects, questions, criteria), Research Plan written (phases, milestones, deliverable target), source strategy mapped, mode confirmed |
| `bug` | `types/bug.md` | A→I `/nexus-build` | Regression risk explicitly addressed in Risks & Mitigations; reproduction steps documented |
| `creative` | `types/creative.md` | A→I `/nexus-build` | Audience and purpose recorded in Approach; tone/format constraints documented |
| `question/standard` | `types/question.md` (implementation path) | A→I `/nexus-build` | None — same as `default` |
| `question/informational` | `types/question.md` (informational path) | A→V `/nexus-validate` | Findings recorded in Solution-Design; evidence documented with sources; **does NOT check Implementation-Plan** (intentionally absent on this path); expects that `I:5` **will be** set in the two-place update — the gate verifies the *intent*, never a completed two-place update, which is a Transition action |

**Core checklist items** (apply to every branch): the gate does **not** restate them here. The single authority is `nexus-analyze/SKILL.md` [Section: End-of-Workflow-Checklist] → `### Verifications` — read that group and evaluate it (PAT-113 canonical single-home placement).

A duplicated copy previously lived here and had already drifted from the authority (it silently omitted the anchored-text-locations item), which is exactly the failure mode single-sourcing prevents. Do not re-inline the list; extend the authority instead.

Note the deliberate asymmetry: the authority's `### Transition actions` group — the two-place score update and the boundary checkpoint — is **out of scope for this gate**. Those run at §6 *after* a PASS verdict, so the gate must not treat them as verifiable inputs. This matters concretely: the gate can return FAIL at score ≥4 (via a Verifications hard failure or a critical structural gap), and a two-place update performed before that verdict would persist a phase score behind a blocked transition.

The `default`, `bug`, `creative`, and `question/standard` branches add: `- [ ] ISS Implementation-Plan written and verified on disk`. The `research` branch substitutes: `- [ ] Research Plan (phases + milestones + deliverable target) written`. The `question/informational` branch omits Implementation-Plan entirely.

### Display Templates

Render the verdict as a clearly-bounded block. Use these templates exactly — they are display structures that prevent drift.

#### PASS

```
🚦 Readiness Gate: PASS
─────────────────────────────────────────────────────────
✅ Analyzed score: {X}/5
✅ End-of-Workflow checklist: {N}/{N}
✅ One-way doors: {none flagged | N flagged, all mitigated}

→ Proceeding to transition.
─────────────────────────────────────────────────────────
```

#### CONCERNS

```
🚦 Readiness Gate: CONCERNS
─────────────────────────────────────────────────────────
{✅|⚠️} Analyzed score: {X}/5
{✅|⚠️} End-of-Workflow checklist: {N}/{N}
{✅|⚠️} One-way doors ({N}):
   - {description}
     {→ Mitigation: {plan} | (no mitigation)}

Concerns to address:
1. {issue}
   → Suggested fix: {concrete action with location}

How to proceed?
[A] Acknowledge & proceed   [F] Fix the above   [D] Decompose
─────────────────────────────────────────────────────────
```

The "Suggested fix" is mandatory on every concern — never just list the problem without a proposed action. The fix must point to a specific section or step the user can act on (e.g., "add a Mitigation line to ### Risks & Mitigations entry 3" or "return to §2 Design and resolve topic 4").

#### FAIL

```
🚦 Readiness Gate: FAIL
─────────────────────────────────────────────────────────
{✅|❌} Analyzed score: {X}/5 (target: ≥4)
{✅|❌} End-of-Workflow checklist: {N}/{N}
   - {failed item 1}
   - {failed item 2}
{✅|❌} One-way doors: {state}

Cannot transition. Routing back to:
→ {specific section/step that produced the failure}

[Continue from {step}]   [Decompose this issue]
─────────────────────────────────────────────────────────
```

### Behavior Matrix

| Verdict | Behavior |
|---|---|
| **PASS** | Render verdict, hand off to the existing §6 transition steps unchanged. The gate is silent flow-through on PASS — no user prompt. |
| **CONCERNS** | Render verdict + concerns + suggested fixes. Stop and present 3 options: `[A] Acknowledge & proceed` (transition continues with concerns visible in continue_with for the next phase), `[F] Fix the above` (return to the relevant analysis step using the suggested fix as guidance), `[D] Decompose` (invoke /nexus-decompose-issue if concerns reveal scope is too large). Wait for explicit choice. |
| **FAIL** | Render verdict + failed items + routing. Block the transition entirely. Present 2 options: `[Continue from {step}]` (return to the specific analysis step that produced the failure), `[Decompose this issue]`. No "proceed anyway" override at FAIL. |

### Invocation

Each type file's §6 Transition begins with this invocation:

```markdown
**Step 0 — Readiness Gate**: Run [Section: Readiness-Gate] in references/readiness-gate.md with branch `{branch}`.
On PASS, proceed to step 1 below. On CONCERNS, follow the gate's branching. On FAIL, do not execute steps 1+ — return to the routed step per gate output.
```

Where `{branch}` is the appropriate branch name from the table above.

`question.md` §6 is the only type file with two distinct invocations — one at the informational path (`question/informational` branch) and one at the standard path (`question/standard` branch). Each path's invocation is co-located with the path's other transition steps.

### Notes

- The gate is **always shown** at every transition, regardless of verdict. PASS is the silent flow-through case in *behavior*, not in *display* — the user always sees the verdict block.
- The gate does NOT replace any existing §6 transition logic. It runs *before* the existing steps and acts as a guard. On PASS, control passes through to the existing steps unchanged.
- The gate does NOT carry a "proceed anyway" override at FAIL. The existing methodology already allows user override at score <4 (the existing §6 "User override" path) — that override is upstream of the gate, not a bypass of it.
- One-way door identification is the analyst's responsibility during §2 Design and §4 Planning. The gate only *checks* whether doors were flagged and mitigated; it does not discover them.
- Branch-specific checklist items (regression-risk for `bug`, audience-fit for `creative`, etc.) are qualitative checks that rely on analyst judgment. Two reasonable analysts may disagree on whether a given description is "specific enough." This is intentional — the gate's value is forcing the question to be asked, not enforcing a deterministic rule. When in doubt, mark as best-effort gap (CONCERNS) rather than hard failure (FAIL).

[/Section: Readiness-Gate]
