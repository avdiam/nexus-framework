*Version: 1.3.1 | Date: 2026-06-11 | Sprint: 101*

# Analysis — Creative Type

Loaded by SKILL.md Router for creative-type issues, complexity ≥ 3.

**Flow**: Investigate → Design → **[T1] Choice** → Plan → **[T1] Plan Approval** → [Section: Commit-Protocol] → Transition

**Key differences from default**:
- Investigate focuses on audience, purpose, tone, format
- Design produces content outline, not technical architecture
- Plan phases = Draft → Content → Polish
- Risk = audience misalignment, not technical cascade

---

## 1. Investigate

Focus: audience analysis, creative constraints, reference material.

### A — Context Artifacts (conditional)

Same as default — check `.nexus/supporting-files/project-context/` for CONTEXT.md, STRUCTURE.md, CONCERNS.md.

### B — Audience & Purpose Analysis

- Who is the intended audience? (demographics, expertise, expectations)
- Primary purpose? (inform, persuade, entertain, educate, inspire)
- Appropriate tone? (formal, conversational, technical, creative, authoritative)
- Format constraints? (length, medium, structure, visual requirements)

### C — Reference Material Review

- Existing examples, style guides, reference material
- Brand guidelines or voice documentation
- Competing or comparable content
- What works in references, what doesn't

### D — Creative Constraints Mapping

- Hard constraints: word count, format, platform requirements, deadline
- Soft constraints: tone preferences, style tendencies, audience expectations
- Opportunities: unique angles, underserved perspectives, creative formats

### E — Gap Identification

> 📊 Creative Brief Analysis
>
> Audience: {who}
> Purpose: {why}
> Tone: {how}
> Format: {what}
> Key constraints: {list}
> Reference material: {available/needed}

---

## 2. Design — Content Approach

"Architecture" becomes content flow. Options focus on tone/style, format, structure.

### A — Content Options

> **Option A**: {approach — e.g., narrative structure}
> Tone: {tone}. Format: {format}. Sections: {outline}. Pros: {benefits}. Cons: {drawbacks}.
>
> **Option B**: {approach — e.g., instructional structure}
> Tone: {tone}. Format: {format}. Sections: {outline}. Pros: {benefits}. Cons: {drawbacks}.
>
> **My recommendation: Option {X}**
> **Reasoning**: {why this best serves audience and purpose}

### B — Complex Format (if multiple creative decisions)

Break into decision topics: tone decision, structure decision, format decision. Present each with options and recommendation.

**[T2: Balanced+Full ask | Streamlined: auto-select best-fit, notify]** Per-topic decisions.

### C — Strategic Reflection

- Does this serve the audience?
- Is the tone consistent throughout?
- Are we optimizing for the right creative dimension?

### D — Post-Generation Elicitation (complexity ≥ 3)

Before user commits, offer one re-examination pass through an unused cognitive lens:

| If unused | Suggest when |
|---|---|
| Systems Thinking | Options with different integration implications |
| Inversion | High confidence (>85%) — check what could fail |
| Pre-mortem | High-stakes or hard-to-reverse decision |
| Analogical Reasoning | Novel domain |
| Blind Spot Check | Strong anchoring risk |
| Mental Simulation | Complex workflows or multi-file changes |

> 🔄 Challenge these options before deciding?
>
> Suggested lens: {tool} — {one-line reason}
> [Apply suggested / Pick different / Proceed to choice]

If applied: focused pass (~2-3 paragraphs) on the *options*, not the original problem. Re-display with insights.

---

## 3. Choice Selection

**[T1: all levels ask]** Present content approach with recommendation. Wait for user choice.

---

## 4. Planning — Creative Production Plan

Phases = Draft → Content → Polish:

> 📋 Creative Production Plan
>
> **Phase 1: Draft** ({estimate})
> - Produce initial draft following chosen outline
> - Focus on structure and content flow
> - Don't polish — get ideas down
>
> **Phase 2: Content** ({estimate})
> - Refine content section by section
> - Ensure tone consistency
> - Add examples, evidence, supporting material
> - Mid-process steering pause — present draft for user feedback
>
> **Phase 3: Polish** ({estimate})
> - Final refinement pass
> - Coherence review (end-to-end flow)
> - Audience-fit check
> - Formatting and presentation
>
> **Risk**: Audience misalignment (not technical cascade)
> **Verification**: User review at each phase boundary

### Feasibility

- Scope realistic for available context?
- Reference materials accessible?
- User input needed at specific points?

---

## 5. Plan Approval

**[T1: all levels ask]** Present creative plan with recommendation.

On approval: → [Section: Commit-Protocol], then Transition.

---

## 6. Transition

**[T3: Full ask | Balanced: notify | Streamlined: silent]**

Same as default — run checklist, score, two-place update, load /nexus-build or defer.

**Step 0 — Readiness Gate**: Run [Section: Readiness-Gate] in references/readiness-gate.md with branch `creative`. The creative branch adds explicit checks for audience and purpose recorded in Approach, plus tone/format constraints documented. On PASS, proceed with the standard transition. On CONCERNS, follow the gate's branching. On FAIL, do not transition — return to the routed step per gate output.

> ✅ Analysis → Implementation (Creative)
> • Audience: {who}
> • Format: {what}
> • Score: {X}/5

**On decline**: Ask what needs attention. Offer: revisit creative brief, adjust tone/format, reconsider audience.

**User override**: If user says "start creating" with score < 4, warn about gaps in creative direction but proceed if insisted.
