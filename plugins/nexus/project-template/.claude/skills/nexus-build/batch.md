*Version: 1.5.0 | Date: 2026-08-25 | Sprint: 110*

# Build — Batched Implementation

Conditional reference loaded by SKILL.md when `_build_mode: batch` is detected in sprint-state, or when [Section: Batch-Transition-Detection] fires during a Build session.

**Purpose**: Execute a proven playbook across remaining targets with minimal methodology overhead.

**Depends on SKILL.md for**: Operational Reminders, Scope-Escalation-Check, Commit Protocol, Gate Reference, Checkpoint Reference, End-of-Workflow Checklist.

---

## Batch Orient

### A — Load Batch Context

Read from ISS [Section: Implementation-Log]:
- **### Playbook**: proven procedure with steps, inputs/outputs, proven-on targets
- **### Batch Progress**: table with target status (completed/remaining)

Extract: total targets, completed count, next target, playbook steps.

If Playbook or Batch Progress missing → cannot enter batch mode. Fall back to full Build: clear `_build_mode`, notify user, resume normal Orient.

### B — Resumption Detection

| Condition | Action |
|---|---|
| Fresh entry (from Batch-Transition-Detection) | Start from first remaining target in Batch Progress |
| Resumption (new conversation, `_build_mode: batch`) | Find last completed target in Batch Progress. Display summary. Resume from next target. |
| continue_with references "Apply fallback" returning | Target was fixed in full Build. Update Batch Progress. Playbook is re-read from ISS (may have been revised during Build detour). Ask: resume batch or continue in full Build? |
| All targets in Batch Progress already ✅/⏭️ | Skip Execution Loop → go directly to Batch Completion. |

Display:
```
📋 Batch Mode Active
• Playbook: {1-line summary}
• Progress: {completed}/{total} targets
• Next: {target name}
• Remaining: {count}
```

### C — Playbook Validation

Quick sanity check before executing:
- Does the playbook still apply to the next target? (File exists, structure matches expectations)
- Any targets blocked by external changes since last session?

If issues found: surface to user before proceeding. **[T2: Balanced+Full ask | Streamlined: auto-skip problematic target, notify]**

---

## Parallel Dispatch (Optional)
[Section: Parallel-Dispatch]

After Playbook Validation, before the sequential Execution Loop. Offers parallel agent dispatch for all remaining targets.

### Dispatch Offer

**[T2: Balanced+Full ask | Streamlined: auto-recommend if ≥3 targets, notify]**

```
🤖 Dispatch {N} remaining targets in parallel?
Each agent assesses fit, then executes if clean. Problems delegate back.
Mode: {N}× {tier} agents (computed per §Tier Selection below)
[Y / Skip — continue sequentially]
```

### Tier Selection (mandatory — emits per-invocation `model:` always)

**Cross-reference**: For research-mode tier selection (phase-based — Survey/Investigation/Codebase-audit/Synthesis with override triggers), see `.claude/skills/nexus-research/SKILL.md` §Sub-Agent Tier Selection. The two policies are complementary: that section governs research-phase dispatch (phase-based); the table below governs batch-execution dispatch (signal-based).

`nexus-batch-worker`'s frontmatter is `model: inherit`. Tier policy lives here, not in the agent file. Compute `tier` from signals already in hand at dispatch time. **First-match-wins; default `haiku`.**

| Signal | Source | → tier |
|---|---|---|
| ISS complexity ≥ 4 | issues-registry.yaml `ISS-XXX.complexity` (already loaded at /nexus-build boot) | `sonnet` |
| Playbook > 8 steps | ISS ### Playbook step count (counted at brief construction) | `sonnet` |
| Any prior-wave target returned `fit: partial` with adaptation note | ISS ### Batch Progress (already inspected during proven-on phase) | `sonnet` |
| Otherwise | — | `haiku` |

**Tier MUST be computed and passed at every dispatch.** The agent's frontmatter `inherit` is a fallback contract; absence of per-invocation `model:` would inherit the user's session model and risk parallel-dispatch cost bloat (e.g., N parallel Opus agents). Treat tier emission as a contract violation if absent — there is no abstain path in this dispatch step.

### On Accept

1. For each remaining target, construct input contract:
   - `playbook`: from ISS ### Playbook (steps + proven_on)
   - `target`: name, path, context from Batch Progress
   - `success_criteria`: from ISS ## Success Criteria (target-scoped)
2. Compute `tier` per §Tier Selection above (mandatory).
3. Dispatch all agents via Agent tool with `.claude/agents/nexus-batch-worker.md`, passing `model: {tier}` per invocation.
4. Read `<usage>` total_tokens from each → add to agent running total

### Process Returns

For each agent result:

| Agent Output | Action |
|---|---|
| `fit: yes` + `Conformance: PASS` + `Delegation: none` | Update Batch Progress: target ✅ |
| `fit: partial` + `Conformance: PASS` + `Delegation: none` | Update Batch Progress: target ✅ with adaptation notes |
| `fit: partial` + `Conformance: PARTIAL` | Update Batch Progress: target ✅ with deviation notes |
| `fit: no` or `Delegation: STOP` | Mark target ⚠️ → route to Novel Problem Detection (step E in sequential loop) |
| Agent error / malformed output | Mark target ⚠️ → route to sequential loop for manual handling |

After processing all returns: display summary.

```
✅ Parallel Dispatch Complete
• Succeeded: {N}/{total}
• Delegated back: {N} (will handle sequentially)
• Agent cost: {N}K tokens total
```

#### Cross-Report Reconciliation (before accepting ANY return)

📐 PAT-143. The table above grades each report against its own target. Nothing in it compares the reports **to each other** — so two workers can return opposite verdicts on the same shared fact with both reports internally clean and both `Conformance: PASS`, because each consulted a different authoritative file. Per-target conformance is blind to this by construction.

1. **At dispatch** — name the SHARED facts in the brief (triggers, thresholds, file existences, vocabulary decisions that more than one worker must form a view on) and require each return to carry `fact | verdict | source consulted`, not only per-target diffs. A verdict without its source cannot be reconciled after the workers are gone.
2. **On return, before accepting anything** — build the verdict matrix (shared facts × workers). Every row carrying more than one distinct verdict is BLOCKED.
3. **Resolve each blocked row against a primary source** — never by majority, stated confidence, or the more senior reviewer. Disagreement is evidence the QUESTION is underspecified, and both reports may be wrong; any tie-break inherits the option neither side raised.
4. Record the resolution and which reports were wrong, then accept the per-target work.

⚠️ Existence claims, counts, and verdicts in a worker report are **hypotheses**. Spot-check any that will drive a delete-vs-repoint decision. Reports can be high-quality AND require verification — both are true at once.

*Origin: Sprint 110 ISS-089 — two workers split on `"switch to themed/mixed"` (one kept it as a live trigger, one deleted it as dead; resolved against the routing map, where it appears in neither the map nor any skill), and one conversation later two reviewers split on whether a set of identifiers was live or fabricated — **both wrong**, the identifiers were retired, a third state neither had considered.*

### On Skip

Fall through to sequential Execution Loop as before.

[/Section: Parallel-Dispatch]

---

## Execution Loop

For remaining targets (all targets if parallel skipped, delegated-back targets if parallel ran).

### For Each Remaining Target

#### A — Target Assessment (before execution)

Quick fit check (~30 seconds) before committing effort:
- Same structural pattern as proven targets?
- No unique dependencies playbook doesn't account for?
- Playbook steps apply without significant adaptation?

> 🎯 Target {N}/{total}: {name}. Playbook fit: {yes / partial / no}

If partial: note adaptation needed, proceed with awareness — document adaptation in step D Batch Progress Notes. If no: skip to Novel Problem Detection (D).

#### B — Execute Playbook

Apply each playbook step to the current target:

> 🔨 Target {N}/{total}: {name}
> Step 1: {action} — {result} ✓
> Step 2: {action} — {result} ✓

Note deviations from playbook: `📐 Deviation: {what differed} — {why}`

**[T3: Full ask | Balanced: notify | Streamlined: silent]** Per-target gate.

#### C — Conformance Check

Compare result against playbook specification:
- Does output follow expected structure/format?
- Are naming conventions consistent with proven targets?
- Do cross-references resolve correctly?
- If renames/moves involved: search for broken references

| Result | Action |
|---|---|
| Conforms | Proceed to Update |
| Minor variance | Note in Batch Progress Notes, proceed |
| Significant deviation | Stop — surface to user as novel problem (D) |

#### D — Update Batch Progress

Patch ISS ### Batch Progress: mark target ✅, update Progress counter, set next target. Include deviation notes if any.

```
| # | Target | Status | Conv | Notes |
|---|--------|--------|------|-------|
| N | {name} | ✅     | {N}  | {any notes} |
```

#### E — Novel Problem Detection

**Does the playbook fit this target?** Check after execution attempt or during if something breaks mid-step.

| Signal | Meaning |
|---|---|
| Step fails or produces unexpected result | Target has structural differences |
| Target needs additional steps not in playbook | Scope beyond playbook |
| Target has dependencies playbook doesn't account for | Cross-target interaction |

If novel problem detected:

**[T2: Balanced+Full ask | Streamlined: ask (significant decision)]**

> ⚠️ Target {name}: playbook doesn't fit
> Problem: {what's different}
>
> Options:
> [Fix inline (minor adaptation) / Escalate to full Build / Skip target / Update playbook]

| Choice | Action |
|---|---|
| Fix inline | Apply minor adaptation, document in Batch Progress Notes, continue loop |
| Escalate to full Build | **Same conversation (type file in memory)**: re-enter type file §1 for this target ONLY as a sub-procedure. After target resolved, return to this Execution Loop — continue with next target. `_build_mode` stays `batch`. **New conversation needed**: set `_build_mode: full`, continue_with: "Apply fallback — target {name}: {problem}". Checkpoint. Build Orient C handles resumption and re-entry offer. |
| Skip target | Mark as ⏭️ in Batch Progress, document reason, continue to next |
| Update playbook | Modify Playbook steps in ISS, apply updated playbook to this and remaining targets |

#### F — Scope Escalation Check

After every 3 targets (or if total targets > 10, after every 5): invoke [Section: Scope-Escalation-Check] in SKILL.md with batch-adapted signals:

| Signal | Detection |
|---|---|
| More targets discovered than originally listed | Batch Progress grew beyond initial count |
| Playbook modifications accumulating | 3+ inline fixes suggest playbook needs redesign |
| Time exceeding estimates | Conversation count > expected for remaining targets |

If 2+ signals: surface to user with options including "Return to full Build for remaining targets."

#### G — Zone Check + Checkpoint

After each target (small batches, <8 total) or every 2-3 targets (large batches):
- Green: continue
- Yellow: offer checkpoint per [Section: Checkpoint-Protocol]
- Red: mandatory checkpoint

**MANDATORY ordering**: Batch Progress must be updated (step D) before any checkpoint fires. If zone threshold crosses mid-target before step D, complete D first, then checkpoint. Saving with an un-updated Batch Progress creates inconsistent state.

**Checkpoint content**: Batch Progress table is the primary artifact. continue_with captures: `_build_mode: batch`, next target, playbook summary.

---

## Batch Completion

When all targets in Batch Progress are ✅ (or ⏭️ skipped):

```
✅ Batch Execution Complete
• Targets: {completed}/{total} ({skipped} skipped)
• Playbook modifications: {count or "none"}
• Novel problems: {count or "none"}
```

**Score guidance**: 4 = all targets complete (deviations or skipped targets documented). 5 = all targets complete, zero deviations, zero skipped. This feeds into SKILL.md Transition score calculation.

### A — Aggregate Results

Compile batch results into ISS Implementation-Log subsections:
- ### Changes Made: all target changes (if not already accumulated per-target)
- ### Tests Created: tests from playbook execution
- ### Deviations: any playbook modifications or skipped targets

### B — Return to Build §POST-TYPE

Batch execution replaces type file §1 Implementation — it IS the implementation. Now need §POST-TYPE for quality assurance.

**If complex.md is in active context** (same conversation as batch start): fall through to §POST-TYPE directly.

**If complex.md is NOT in context** (resumed in new conversation): load complex.md (1 load). Execute §POST-TYPE from Test Execution onward.

After §POST-TYPE: return to SKILL.md → [Section: End-of-Workflow-Checklist] → [Section: Commit-Protocol] → clear `_build_mode` → [Section: Transition].

---

## Batch-Specific Gate Reference

All gates present LLM recommendation regardless of tier or control level.

| Gate | Tier | Rationale |
|---|---|---|
| Per-target execution | T3 | Playbook already approved |
| Novel problem escalation | T2 | Significant decision — affects remaining work |
| Playbook update | T2 | Changes proven procedure |
| Skip target | T2 | Work being deferred |
| Scope escalation | T2 | May redirect remaining work |
| Batch Progress writes | T3 | Routine tracking |
| Return to full Build | T2 | Mode change |

Note: these supplement (not replace) the gates in SKILL.md Gate Reference.
