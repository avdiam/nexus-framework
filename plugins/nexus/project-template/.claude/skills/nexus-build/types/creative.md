*Version: 1.0.0 | Date: 2026-03-30 | Sprint: 066*

# Build — Creative Type

Loaded by SKILL.md Router for creative-type issues, complexity ≥ 3. Execute after complex.md §PRE-TYPE completes.

**Flow**: §1 Implementation (section-by-section content production) → return to complex.md §POST-TYPE

**Key differences from default**:
- Unit of work = content section (draft), not implementation phase
- Track draft versions, not file patches
- Mid-process steering every 2-3 sections
- Batch Transition threshold: 3+ sections (higher than default's 2+)
- Quality gate = audience-fit + coherence, not tests passing

---

## §1 Implementation

### A — For Each Section in Content Outline

> 🔨 Section: {name} | Draft: {version}
> Content: {what produced}
> Coherence: {fits with previous sections? ✓}

**[T3: Full ask | Balanced: notify | Streamlined: silent]** Per-section gate.

### B — Mid-Process Steering

**[T3: Full ask | Balanced: notify | Streamlined: silent]**

Every 2-3 sections:

> Content so far: {brief summary}
> Continue? [Y / adjust tone / restructure / feedback]

### C — ISS Update + Checkpoint

After every 2-3 sections:

1. Update ISS ### Drafts & Versions table (or create if first update):
   `| Version | Sections | Focus | Key Changes |`
2. Update Implementation-Plan ⬜ → ✅ for completed sections
3. Progress marker: `*Creative implementation in progress — Draft N, done/total sections*`
4. Follow [Section: Checkpoint-Protocol] in CLAUDE.md

**[T3: Full ask | Balanced: notify | Streamlined: auto]** ISS write + checkpoint.

### D — Scope Escalation

Invoke [Section: Scope-Escalation-Check] in SKILL.md.

**Creative-type adapted signals**: Brief growing beyond original scope / new deliverables emerging / sections substantially deeper than estimated.

### D2 — Brief Drift Check (mid-implementation)

At 50%+ sections complete, re-read ISS Solution-Design ### Approach (the creative brief) and compare to what's been produced:
- Is the tone consistent with the brief?
- Has the audience shifted?
- Are we still serving the original purpose?

If drift detected: surface immediately **[T2]** before remaining sections lock in the deviation. Options: [Realign to brief / Update brief to match direction / Accept drift with noted deviation]. This is the mid-implementation steering check — complex.md §POST-TYPE runs the final comprehensive drift detection after all sections complete.

### E — Batch Transition

Invoke [Section: Batch-Transition-Detection] in SKILL.md after 3+ implementation targets (sections) with repeating structure.

Higher count threshold than default's 2+ because creative sections are smaller units than implementation phases and need more evidence before concluding the pattern is established.

---

After all sections complete:
> ✅ All sections complete. Return to complex.md §POST-TYPE.

**§POST-TYPE adaptations** (handled in complex.md):
- Test Execution = audience-fit review + coherence scan + accuracy vs creative brief (no automated tests)
- Decision Drift = check against creative brief for tone/audience/purpose drift
- Quality Review = tone consistency, audience-fit, narrative coherence
