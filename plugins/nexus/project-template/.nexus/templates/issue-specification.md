# issue-specification.md
*Version: 3.10.0 | Date: 2026-08-20 | Sprint: 110*

**Single source of truth for issue structure — ISS files and issues-registry entries.**

```yaml
specification_context:
  purpose: "Define structure and guidance for issues"
  version_note: "v3.0.0 — Unified ISS structure, working-guide eliminated"
  
  key_principles:
    unified_structure: "One ISS template — complexity affects depth, not structure"
    registry_is_source_of_truth: "All queryable metadata lives in registry only"
    iss_file_is_datastore: "ISS files contain ALL phase work, persisted across conversations"
    section_markers_for_patching: "7 section markers enable reliable Edit tool patching"
    scaffolding_at_creation: "ALL markers scaffolded at creation — capabilities patch without existence checks"
    two_place_updates: "Phase scores update registry + sprint-state (not ISS file)"
    guidance_comments_embedded: "HTML comments in ISS guide capabilities in-context"
  
  consumers:
    # Issue Operations
    create_issue: "READ #[Section: ISS-File-Structure] for template + scaffolding rules, #[Section: Registry-Schema] for fields"
    update_issue: "READ #[Section: Registry-Schema] for field rules + #[Section: ISS-File-Structure] for content"
    view_issues: "READ #[Section: Registry-Schema] for filter fields"
    close_issue: "READ #[Section: Issue-Lifecycle] for closure rules"
    archive_issue: "READ #[Section: Issue-Lifecycle] for archival rules"
    work_issue: "Uses registry for scores, ISS file for content"
    
    # NEXUS Phase Work (methodology skills)
    nexus_analysis: "/nexus-analyze → writes [Section: Solution-Design] + [Section: Implementation-Plan]"
    nexus_research: "/nexus-research → writes [Section: Implementation-Log] (findings), updates [Section: Implementation-Plan] status"
    nexus_implementation: "/nexus-build → writes [Section: Implementation-Log], updates [Section: Implementation-Plan] status"
    nexus_evaluation: "/nexus-validate → writes [Section: Evaluation-Results]"
    nexus_closure: "/nexus-close-issue → writes [Section: Closure]"
  
```

---

## ISS File Structure
[Section: ISS-File-Structure]

### Philosophy

**Issues are work units that flow through a lifecycle: Create → Analyze → Implement → Evaluate → Close → Archive.**

**Key Design Principles:**
- **One structure, two depths** — Same section names regardless of complexity. Simple issues have brief content; complex issues have rich content. Capabilities always write to the same targets.
- **Registry = queryable metadata** (scores, status, priority, dependencies)
- **ISS file = cross-conversation datastore** — ALL phase work persists here. Each phase accumulates work across conversations until complete.
- **Section markers for Edit tool patching** — 7 markers (`[Section: X]...[/Section: X]`) enable reliable targeted updates by capabilities and checkpoint protocol.
- **Scaffolding at creation** — /nexus-create-issue pre-creates ALL section markers so methodology skills can patch without existence checks.
- **Embedded guidance** — HTML comments (`<!-- GUIDANCE -->`) in ISS files guide capabilities in-context. The ISS file IS the format — capabilities don't need their own format templates.
- **No duplication** — Metadata lives in registry ONLY. Phase content lives in ISS ONLY. sprint-state tracks orchestration ONLY.

---

### Scaffolding Rules

```yaml
create_issue_scaffolding:
  principle: "Scaffold ALL section markers at creation so capabilities can patch reliably"
  
  simple_issues_1_2:
    scaffolded_with_markers:
      - "[Section: Solution-Design]...[/Section: Solution-Design]"
      - "[Section: Implementation-Plan]...[/Section: Implementation-Plan]"
      - "[Section: Implementation-Log]...[/Section: Implementation-Log]"
      - "[Section: Evaluation-Results]...[/Section: Evaluation-Results]"
      - "[Section: Closure]...[/Section: Closure]"
    placeholder_content: "*Not started*"
    skipped_sections: "Notes & Context, Work Log (optional — add later if needed)"
    guidance_comments: "Minimal — core guidance only"
  
  complex_issues_3_5:
    scaffolded_with_markers:
      - "All 7 sections (5 mandatory + 2 optional)"
    placeholder_content: "Subsection headers (###) pre-populated"
    guidance_comments: "Full embedded guidance for each subsection"
    guidance_rule: "Include only complex (3-5) guidance — omit simple (1-2) references to keep the ISS file focused"
  
  benefit: "Capabilities and checkpoint can always patch between markers reliably"
```

---

### ISS File Template

```markdown
# ISS-XXX: {Title}
*Type: {type} | Created: {YYYY-MM-DD} | Complexity: {1-5}*

## Description

{Problem statement, context, rationale}

<!-- GUIDANCE: Description
Simple (1-2): Brief — what needs to happen and why (1-2 sentences)
Complex (3-5): Full context — what, why, impact, urgency, background

Example (Simple):
  Error message shows "recieved" instead of "received" in validation feedback.

Example (Complex):
  The current pattern system tracks effectiveness in 5 different locations,
  creating maintenance burden and data inconsistency. Users report confusion
  about which source to trust. This impacts pattern adoption and system
  reliability. Consolidation to 2 locations will reduce cognitive load and
  ensure single source of truth.
-->

## Success Criteria

- [ ] {Criterion 1}
- [ ] {Criterion 2}
- [ ] {Criterion 3}

<!-- GUIDANCE: Success Criteria
Simple (1-2): 1-3 simple, verifiable criteria
Complex (3-5): Multi-dimensional criteria (Functional, Quality, Performance)

Make each VERIFIABLE — avoid vague terms like "works correctly"
These drive the entire issue lifecycle and are checked in Evaluation Results.

For complexity ≥ 3: prefix each criterion with a short ID (SC-01, SC-02, ...) to enable
traceability mapping between criteria and implementation steps during analysis (/nexus-analyze
documentation step) and evaluation (/nexus-validate criteria step). Optional for complexity 1-2.

Example (Simple):
  - [ ] Typo corrected in messages.md
  - [ ] No regressions in message display

Example (Complex):
  - [ ] Functional: Pattern tracking consolidated to 2 locations
  - [ ] Functional: All existing patterns migrated without data loss
  - [ ] Quality: No duplicate tracking logic remains
  - [ ] Quality: Documentation updated to reflect new structure
  - [ ] Performance: Pattern lookup time unchanged or improved

### Testability Guidance

Criteria drive Evaluation. A criterion is testable when a concrete test can measure whether it is met. Subjective phrasing ("works well", "feels right", "properly") produces criteria that evaluators cannot objectively verify. At complexity ≥ 3, /nexus-create-issue's testability gate scans criteria at authoring time and offers measurable rewrites; /nexus-build's §PRE-TYPE Step D echoes the check at implementation handoff.

Good vs. bad criteria:

Bad: "Validation works well in production"
Good: "Validation rejects 100% of malformed inputs across the 12 test fixtures with zero false-positives on valid inputs"

Bad: "Feature is fast"
Good: "Feature responds in <200ms at p95 under 100 req/s sustained load"

Bad: "Error handling is robust"
Good: "All 7 documented error paths produce structured error responses with non-empty message field and correct HTTP status"

Bad: "Migration works correctly"
Good: "Migration preserves all N existing records, adds target fields with expected defaults, and passes the 3 post-migration integrity queries"

Pattern: replace qualitative adjectives ("well", "fast", "robust", "properly", "correctly") with quantified thresholds, counts, or enumerable behaviors.

### Registry Reference Guidance — Direct Edit vs Registration

Some NEXUS files are append-only / closure-reconciled and carry a `DO-NOT-EDIT-MANUALLY` header — the canonical example is `.nexus/active/registries/changelog-registry.yaml` (CLAUDE.md Version Protocol: "updated at sprint closure for all sprint-modified files, not on every individual edit"). When a success criterion *references* such a file, it must distinguish two paths:

- ❌ **Direct edit** — forbidden by the file's header and Version Protocol. SC phrasing like "changelog-registry updated" is ambiguous and reads as direct-edit unless qualified.
- ✅ **Registration** — the correct path: list the modified file under `[FILES_MODIFIED]` in sprint-state; sprint closure reconciles the registry.

Good vs. bad criteria:

Bad: "changelog-registry updated"
Good: "changelog-registry updated **at sprint closure** for files modified by this issue" — OR — "this issue's modified files registered in sprint-state `[FILES_MODIFIED]` for closure reconciliation"

Bad: "Append entry to patterns-registry"
Good: "Pattern outcome captured in ISS ### Pattern Outcomes; effectiveness aggregated at sprint closure"

The rule generalizes to any append-only / closure-reconciled registry. When an SC names such a file, anchor the action to its actual write path (sprint-state registration, ISS section) rather than the registry itself.
-->

## Dependencies

**Blocked by**: []
**Blocks**: []
**Related**: {Brief note or "None"}

<!-- GUIDANCE: Dependencies
Simple (1-2): Often empty or brief note. Can skip "Related" if none.
Complex (3-5): Full dependency mapping with context.

Example (Simple):
  **Blocked by**: []
  **Blocks**: []
  **Related**: None

Example (Complex):
  **Blocked by**: [ISS-089]
  **Blocks**: [ISS-095, ISS-096]
  **Related**: Part of Sprint 045 pattern system overhaul. Depends on
  registry format decision from ISS-089.

### Dependency Hygiene

`blocked_by` and `blocks` form a directed dependency graph across active issues. NEXUS enforces graph integrity through a self-healing loop: /nexus-issue-validation STEP 3b detects cycles and missing references; /nexus-organize-sprint blocks sprint finalization on unresolved issues; /nexus-close-issue atomically clears downstream `blocked_by` entries when an issue closes (Resolved or Rejected). Avoid cycles (A blocks B blocks A — would stall both) and stale references (pointing at ISS IDs that were renamed or archived). Use `blocked_by` only for true blocking — if one issue merely informs another, use `Related:` instead.
-->

---

## Solution Design
[Section: Solution-Design]

### Approach

{What we're doing and why — core strategy}

<!-- GUIDANCE: Approach
Simple (1-2): 1-2 sentences stating the fix/change
Complex (3-5): Full rationale — what, why this over alternatives, core insight

This is the ANCHOR for the entire issue. Future phases read this to understand intent.

Example (Simple):
  Direct fix of typo in messages.md line 42.

Example (Complex):
  Consolidate pattern tracking from 5 locations to 2 (patterns-registry.yaml
  for metadata, sprint-state [PATTERNS_IN_USE] for active applications).
  This follows the single-source-of-truth principle and eliminates the
  synchronization burden that caused data drift in Sprint 043.
-->

### Implementation Preferences

{Captured during /nexus-analyze preferences step — skip for complexity 1–2}

<!-- GUIDANCE: Implementation Preferences
Simple (1-2): Skip — not scaffolded, preferences step is skipped for simple issues
Complex (3-5): Populated by /nexus-analyze preferences step via widget-driven preference capture

Structure:
  Locked (user decided):
  - {area}: {decision}

  Claude's Discretion:
  - {area}: {context for Claude's judgment}

  Deferred:
  - {idea}: captured for future consideration

Read by: /nexus-build plan-verify step (preference compliance), implement step (decision drift detection)
Do NOT modify during implementation — these are analysis-time decisions.
If implementation reveals a locked decision should change, document the deviation in
Implementation-Log ### Deviations with rationale.
-->

### Architecture

{System design, component structure — skip for simple issues}

<!-- GUIDANCE: Architecture
Simple (1-2): Skip — usually not applicable for simple fixes
Complex (3-5): Component diagram, relationships, responsibilities

Use when issue involves multiple interacting parts.

Example (Complex):
  | Component | Responsibility |
  |-----------|---------------|
  | patterns-registry.yaml | Single source of truth for pattern metadata |
  | sprint-state [PATTERNS_IN_USE] | Active application tracking per issue |
  | Capability files | Read registry, write [PATTERNS_IN_USE] |
  | /nexus-close-issue | Aggregate outcomes, update registry |
-->

### Tools & Patterns

{Cognitive tools, strategic approaches, patterns chosen — or "None"}

<!-- GUIDANCE: Tools & Patterns
Simple (1-2): Usually "None" — skip subsection if not applicable
Complex (3-5): Document what was used and HOW it influenced the design

Records WHAT tools/patterns were chosen during analysis.
Pattern VERDICTS (helped/neutral/hindered) go in Implementation Log ### Pattern Outcomes.
This feeds pattern effectiveness tracking at closure.

Example (Simple):
  None

Example (Complex):
  - **Cognitive Tools**: MM-002 Systems Thinking — mapped component relationships,
    identified 5 tracking locations, found leverage point in registry consolidation
  - **Strategic Approach**: SA-006 Technical Debt Paydown — clean existing before
    building new features
  - **Patterns**: PAT-009 applied — simplicity principle guided consolidation to
    minimum viable tracking locations
-->

### Key Decisions

{Non-trivial choices with rationale — or "None"}

<!-- GUIDANCE: Key Decisions
Simple (1-2): Usually "None" — skip subsection if not applicable
Complex (3-5): Table with decision and rationale

Capture NON-OBVIOUS choices. Rationale should answer "why not the alternative?"

Example (Complex):
  | Decision | Rationale |
  |----------|-----------|
  | Keep [PATTERNS_IN_USE] in sprint-state | Cross-issue index needed for sprint-level tracking |
  | Remove effectiveness from sprint-state | Registry is single source, avoid sync |
  | Use prefixed YAML format | Enables reliable Edit tool patching |
-->

### Risks & Mitigations

{Identified risks with mitigation strategy — or "None"}

<!-- GUIDANCE: Risks & Mitigations
Simple (1-2): Usually "None" — skip subsection if not applicable
Complex (3-5): Table with risk, impact, and mitigation

Focus on LIKELY risks, not theoretical edge cases.

Example (Complex):
  | Risk | Impact | Mitigation |
  |------|--------|------------|
  | Data loss during migration | High | Backup all files before migration, verify counts |
  | Existing code references old locations | Medium | Search all files, update systematically |

Section / symbol rename — grep-scope rule:
  When an issue renames a section heading, anchor name, or referenced symbol, the
  Mitigation MUST grep both `.claude/skills/` AND `.claude/agents/` for stale
  references. Agent files cross-reference skill sections (e.g., nexus-researcher.md
  cites nexus-research §Sub-Agent Tier Selection) and are easy to miss when grep
  scope is anchored only to skills/. Naming only `.claude/skills/` in a rename
  Mitigation is a known gap (ISS-169 D1, Sprint 078).
-->

### Files Affected

{List of files with brief change description}

<!-- GUIDANCE: Files Affected
Simple (1-2): Simple list
Complex (3-5): Table with change type and phase

Overview of impact scope. Implementation Plan has per-step detail.

Example (Simple):
  - messages.md: Fix typo line 42

Example (Complex):
  | File | Changes | Phase |
  |------|---------|-------|
  | patterns-registry.yaml | Add effectiveness fields | A |
  | sprint-state-template.md | Simplify [PATTERNS] section | A |
  | /nexus-analyze | Update pattern tracking logic | B |
  | /nexus-build | Update pattern tracking logic | B |
-->

[/Section: Solution-Design]

## Implementation Plan
[Section: Implementation-Plan]

{Steps to implement the solution}

<!-- GUIDANCE: Implementation Plan
Simple (1-2): Flat table with steps
Complex (3-5): Phased tables with objectives, verification, sequence rationale

Status column updated by /nexus-build as work progresses (⬜→✅).

Example (Simple):
  | Step | Task | Status |
  |------|------|--------|
  | 1 | Fix typo in messages.md | ⬜ |
  | 2 | Verify message displays correctly | ⬜ |

Example (Complex):
  ### Phase A: Registry Updates
  **Objective**: Establish new tracking structure
  **Est. Effort**: 1 conversation

  | Step | Task | Files | Verification | Status |
  |------|------|-------|--------------|--------|
  | A1 | Add effectiveness fields to registry | patterns-registry.yaml | Fields exist | ⬜ |
  | A2 | Simplify sprint-state template | sprint-state-template.md | Section reduced | ⬜ |

  **Phase Complete When**: New structure in place, old structure still works

  ### Phase B: Code Updates
  **Objective**: Update all tracking logic
  **Est. Effort**: 2 conversations

  | Step | Task | Files | Verification | Status |
  |------|------|-------|--------------|--------|
  | B1 | Update /nexus-analyze tracking | nexus-analyze skill | Tests pass | ⬜ |
  | B2 | Update /nexus-build tracking | nexus-build skill | Tests pass | ⬜ |

  **Phase Complete When**: All code uses new structure

  ### Sequence Rationale
  **Why this order**: Registry first (foundation), then code (depends on registry)
  **Critical path**: Registry schema must be stable before code updates
  **Strategy**: Stable-first
-->

*Status: ⬜ Pending | 🔄 Active | ✅ Done | ⏭️ Skipped | ❌ Blocked*

[/Section: Implementation-Plan]

## Implementation Log
[Section: Implementation-Log]

### Status

{Current progress snapshot}

<!-- GUIDANCE: Status
Simple (1-2): Brief — "Complete" or "Step X of Y"
Complex (3-5): Phase, step, and percentage

Updated by /nexus-build at each significant milestone.

Example (Simple):
  Complete

Example (Complex):
  **Phase**: B | **Step**: B2 | **Progress**: 75%
-->

### Changes Made

{Audit trail of what changed}

<!-- GUIDANCE: Changes Made
Simple (1-2): Simple list
Complex (3-5): Table with conversation reference

Example (Simple):
  - messages.md: Fixed "recieved" → "received" on line 42

Example (Complex):
  | Conv | File | Change |
  |------|------|--------|
  | 5 | patterns-registry.yaml | Added effectiveness fields |
  | 6 | nexus-analyze skill | Updated pattern tracking to use registry |
  | 7 | nexus-build skill | Updated pattern tracking to use registry |
-->

### Tests Created

{Tests created during implementation for Validate phase to execute}

<!-- GUIDANCE: Tests Created
Simple (1-2): May be empty or informal verification steps
Complex (3-5): Table tracking test creation and execution status

Build creates tests, Validate executes them.

Example (Simple):
  - Visual verification of corrected message

Example (Complex):
  | Test | Purpose | Created | Executed |
  |------|---------|---------|----------|
  | Pattern create flow | Verify new pattern gets registry entry | Conv 6 | ⬜ |
  | Pattern update flow | Verify effectiveness updates work | Conv 6 | ⬜ |
  | Migration validation | Verify all patterns migrated | Conv 7 | ⬜ |
-->

### Deviations

{Plan changes with reasons — or "None"}

<!-- GUIDANCE: Deviations
Simple (1-2): Usually "None" — skip if not applicable
Complex (3-5): Table with planned vs actual and reason

Critical for learning — where did reality differ from plan?

Example (Complex):
  | Planned | Actual | Reason |
  |---------|--------|--------|
  | Update 4 capability files | Updated 6 files | Discovered Operate.md also had tracking |
  | Complete in 2 conversations | Required 3 | Phase B more complex than estimated |
-->

### Pattern Outcomes

{Results of pattern applications — or "None"}

<!-- GUIDANCE: Pattern Outcomes
Simple (1-2): "None" or brief verdict
Complex (3-5): Detailed with evidence

Track patterns from "applied" (in Solution Design ### Tools & Patterns) to a verdict.
Each applied pattern gets ONE verdict + a one-line evidence note (consumed at closure by close-issue → close-sprint → update-pattern).
Values (ISS-224 taxonomy): helped | neutral | hindered
  - helped   — genuinely contributed beyond what the framework already enforces (→ successes++)
  - neutral  — applied but added no value beyond an always-on CLAUDE.md rule/skill (echo), or indeterminate (→ neutral++; excluded from effectiveness)
  - hindered — misled, added friction, or caused rework (→ failures++)
Dedup hard-gate: a pattern that merely echoes a core rule/preference caps at `neutral`, never `helped`.
(Canonical: pattern-specification.md → Outcome Verdicts; rule: CLAUDE.md Pattern Governance.)

Example (Complex):
  - PAT-098 (grep-before-rename): helped — grep surfaced 3 cross-file callers a manual scan would have missed; not enforced by any always-on rule
  - PAT-XXX (a pattern that merely restates the elegant_minimum core preference): neutral — applied but added nothing beyond the always-on rule
-->

### Technical Decisions

{Implementation-time decisions — or "None"}

<!-- GUIDANCE: Technical Decisions
Simple (1-2): Skip if not applicable
Complex (3-5): Decisions made DURING implementation (not in analysis)

Example (Complex):
  - Used patch_between_markers instead of patch_file for section replacement
  - Added backward compatibility shim (can remove in Sprint 047)
-->

### Issues Encountered

{Problems and resolutions — or "None"}

<!-- GUIDANCE: Issues Encountered
Simple (1-2): Skip if not applicable
Complex (3-5): Table with problem and resolution

Example (Complex):
  | Issue | Resolution |
  |-------|------------|
  | Registry format incompatible | Migrated to prefixed format first |
  | Test file missing | Created from template |
-->

<!-- GUIDANCE: Optional mode/type subsections (added by /nexus-build when the mode/type applies — not scaffolded at creation)
- ### Playbook — Batch mode: the proven procedure (steps, proven-on targets, remaining targets). Written by nexus-build [Section: Batch-Transition-Detection] Step 1.
- ### Batch Progress — Batch mode: per-target status table (# | Target | Status | Conv | Notes) + Progress counter. Written by batch.md per target; primary checkpoint artifact in batch mode.
- ### Drafts & Versions — Creative type: draft-version table (Version | Sections | Focus | Key Changes). Written by nexus-build types/creative.md §1C.
-->

[/Section: Implementation-Log]

## Evaluation Results
[Section: Evaluation-Results]

### Test Execution

{Results from running tests}

<!-- GUIDANCE: Test Execution
Simple (1-2): Brief pass/fail
Complex (3-5): Detailed results from Tests Created table

Example (Simple):
  ✅ All verifications passed

Example (Complex):
  | Test | Result | Evidence |
  |------|--------|----------|
  | Pattern create flow | ✅ Pass | New pattern PAT-099 created, registry updated |
  | Pattern update flow | ✅ Pass | Effectiveness changed from 0.75 to 0.80 |
  | Migration validation | ✅ Pass | 45/45 patterns have registry entries |
-->

### Criteria Verification

{Success criteria status}

<!-- GUIDANCE: Criteria Verification
Map DIRECTLY to Success Criteria section. Every criterion must have a row.

Example (Simple):
  - Typo corrected: ✅
  - No regressions: ✅

Example (Complex):
  | Criterion | Status | Evidence |
  |-----------|--------|----------|
  | Pattern tracking consolidated to 2 locations | ✅ | Only registry + sprint-state remain |
  | All patterns migrated without data loss | ✅ | 45/45 verified |
  | No duplicate tracking logic remains | ✅ | Search found 0 old references |
-->

### Quality Assessment

{Multi-dimension quality evaluation}

<!-- GUIDANCE: Quality Assessment
Simple (1-2): Brief overall assessment or skip
Complex (3-5): Multi-dimension table

Example (Complex):
  | Dimension | Result | Notes |
  |-----------|--------|-------|
  | Functionality | ✅ | All features work as designed |
  | Edge Cases | ✅ | Empty registry, concurrent updates tested |
  | Integration | ✅ | All 6 files work together |
  | Maintainability | ✅ | Single source of truth, clear ownership |
-->

### Issues Found

{Problems discovered during evaluation — or "None"}

<!-- GUIDANCE: Issues Found
Simple (1-2): "None" or brief
Complex (3-5): Table with severity and resolution

Example (Complex):
  | Issue | Severity | Resolution |
  |-------|----------|------------|
  | Old comment referenced removed field | Low | Fixed in Conv 8 |
  | Edge case: empty pattern list | Medium | Added guard clause |
-->

### Lessons Learned

{What worked, what didn't, insights for future}

<!-- GUIDANCE: Lessons Learned
Simple (1-2): "None" or brief insight if unexpected
Complex (3-5): Structured reflection

Feeds closure knowledge capture and pattern effectiveness tracking.

Example (Complex):
  **What Worked Well**:
  - Prefixed YAML format made patching reliable
  - Phased approach allowed incremental validation
  
  **Challenges**:
  - More files affected than initially identified
  - Backward compatibility needed for active sprint
  
  **For Next Time**:
  - Search ALL files for pattern references before scoping
  - Consider compatibility shim for active work
-->

[/Section: Evaluation-Results]

---

## Closure
[Section: Closure]

### Resolution

{How the issue was resolved}

<!-- GUIDANCE: Resolution
Simple (1-2): 1 sentence
Complex (3-5): Summary paragraph

Example (Simple):
  Typo fixed and verified in context.

Example (Complex):
  Pattern tracking successfully consolidated from 5 locations to 2.
  All 45 existing patterns migrated with full data preservation.
  Six files updated with new tracking logic.
-->

### Knowledge Captured

{Learnings worth preserving}

<!-- GUIDANCE: Knowledge Captured
Simple (1-2): "None" or brief if something unexpected
Complex (3-5): Structured with candidate patterns

Written by /nexus-close-issue at closure.

Example (Complex):
  **What Worked**:
  - Prefixed YAML format for reliable patching
  - Systems thinking to find all affected components
  
  **Lessons Learned**:
  - Always search entire codebase before scoping refactoring
  - Compatibility shims enable safer migrations
  
  **Candidate Patterns**:
  - "Prefixed registry format" — enables 100% reliable Edit tool patching
  - "Compatibility shim pattern" — bridge old/new during migration
-->

[/Section: Closure]

---

## Notes & Context
[Section: Notes-Context]

{Ad-hoc content for issue-specific needs}

<!-- GUIDANCE: Notes & Context
Simple (1-2): NOT scaffolded at creation (add later if needed)
Complex (3-5): Scaffolded with section marker, use flexible subsections

Use ONLY the subsections you need. Add custom subsections as needed.

Possible subsections:
- ### Origin — Where the issue came from (seed promotion, verification finding, sprint-closure spin-off, user request). Read by the methodology Phase-Entry Briefings (analyze/build/validate/research Orient) — render "not recorded" when absent
- ### Research Findings — External research, references, sources
- ### Edge Cases — Complex boundary handling analysis
- ### Migration Strategy — For refactoring with data migration
- ### Rollback Plan — Safety net for high-risk changes
- ### Technology Stack — Tools and technologies used
- ### Important Considerations — Critical mindset, warnings
- ### {Custom} — Any issue-specific need
-->

[/Section: Notes-Context]

## Work Log
[Section: Work-Log]

{Cross-conversation milestones}

<!-- GUIDANCE: Work Log
Simple (1-2): NOT scaffolded at creation (add later if needed)
Complex (3-5): Scaffolded for multi-conversation tracking

NOT for: Next conversation planning (that's sprint-state [BOOTSTRAP])
USE for: Issue journey overview — significant milestones only

WRITE (valuable):
  - Milestone completed: "Analysis complete, 5-step plan approved"
  - Key decision made: "Decided prefixed YAML over nested"
  - Blocker hit: "Edit tool non-unique match, researching alternatives"

DON'T WRITE (fluff):
  - "Continued working on implementation"
  - "Discussed options with user"

Example:
  | Date | Conv | Milestone | Notes |
  |------|------|-----------|-------|
  | 2026-01-28 | 5 | Phase A complete | Registry structure established |
  | 2026-01-29 | 7 | Phase B complete | All code updated |
  | 2026-01-30 | 8 | Evaluation complete | Ready for closure |
-->

[/Section: Work-Log]
```

---

### Section Reference

| Section | Marker | Owner | Simple (1-2) | Complex (3-5) |
|---------|--------|-------|--------------|---------------|
| Header (Title, Type, Created, Complexity) | No | create-issue | ✅ | ✅ |
| Description | No | create-issue | Brief | Full context |
| Success Criteria | No | create-issue | 1-3 items | Multi-dimensional |
| Dependencies | No | create-issue | Often minimal | Full mapping |
| **Solution Design** | `[Section: Solution-Design]` | /nexus-analyze | Core subsections | All subsections |
| **Implementation Plan** | `[Section: Implementation-Plan]` | /nexus-analyze → /nexus-build | Flat table | Phased tables |
| **Implementation Log** | `[Section: Implementation-Log]` | /nexus-build | Core subsections | All subsections |
| **Evaluation Results** | `[Section: Evaluation-Results]` | /nexus-validate | Core subsections | All subsections |
| **Closure** | `[Section: Closure]` | /nexus-close-issue | Brief | Full |
| **Notes & Context** | `[Section: Notes-Context]` | Any | NOT scaffolded | Scaffolded if needed |
| **Work Log** | `[Section: Work-Log]` | Any | NOT scaffolded | Scaffolded if needed |

**Section markers**: 7 total (5 mandatory + 2 optional)

---

### Subsection Inclusion by Complexity

#### Solution Design
| Subsection | Simple (1-2) | Complex (3-5) |
|------------|--------------|---------------|
| Approach | ✅ Include | ✅ Include |
| Implementation Preferences | Skip | ✅ Include |
| Architecture | Skip | ✅ Include |
| Tools & Patterns | Skip if none | ✅ Include |
| Key Decisions | Skip if none | ✅ Include |
| Risks & Mitigations | Skip if none | ✅ Include |
| Files Affected | ✅ Include | ✅ Include |

#### Implementation Log
| Subsection | Simple (1-2) | Complex (3-5) |
|------------|--------------|---------------|
| Status | ✅ Include | ✅ Include |
| Changes Made | ✅ Include | ✅ Include |
| Tests Created | ✅ Include | ✅ Include |
| Deviations | Skip if none | ✅ Include |
| Pattern Outcomes | ✅ Include | ✅ Include |
| Technical Decisions | Skip if none | ✅ Include |
| Issues Encountered | Skip if none | ✅ Include |
| Playbook · Batch Progress | — | Batch mode only (nexus-build Batch-Transition-Detection / batch.md) |
| Drafts & Versions | — | Creative type only (nexus-build types/creative.md) |

#### Evaluation Results
| Subsection | Simple (1-2) | Complex (3-5) |
|------------|--------------|---------------|
| Test Execution | ✅ Include | ✅ Include |
| Criteria Verification | ✅ Include | ✅ Include |
| Quality Assessment | Brief or skip | ✅ Include |
| Issues Found | Skip if none | ✅ Include |
| Lessons Learned | Skip if none | ✅ Include |

---

### Capability Write Protocol

| Capability | Primary Section | What It Writes |
|------------|-----------------|----------------|
| **/nexus-analyze** | `[Section: Solution-Design]` | Approach, Implementation Preferences, Architecture, Tools, Decisions, Risks, Files |
| **/nexus-analyze** | `[Section: Implementation-Plan]` | Phases, steps, sequence |
| **/nexus-build** | `[Section: Implementation-Plan]` | Status updates (⬜→✅) |
| **/nexus-build** | `[Section: Implementation-Log]` | Status, Changes, Tests, Deviations, Outcomes, Decisions, Issues; Playbook + Batch Progress (batch mode); Drafts & Versions (Creative) |
| **/nexus-validate** | `[Section: Evaluation-Results]` | Test results, Criteria, Quality, Issues, Lessons |
| **/nexus-close-issue** | `[Section: Closure]` | Resolution, Knowledge |

---

### Pattern Lifecycle Across ISS Sections

```
Analysis:  ### Tools & Patterns    → "We will use PAT-XXX, SA-YYY"    (chosen)
Build:     ### Pattern Outcomes    → "PAT-XXX: helped/neutral/hindered + evidence" (verdict)
Evaluate:  ### Lessons Learned     → "PAT-XXX was effective because…"  (reflection)
Closure:   ### Knowledge Captured  → feeds registry effectiveness      (extraction)
```

Key distinction: Solution Design records what was CHOSEN. Implementation Log records what HAPPENED.

---

### Checkpoint Protocol Integration

```yaml
checkpoint_saves_to_iss:
  principle: "Checkpoint must save ALL work done in ISS during the conversation"
  scope: "Not limited to active-phase section — any modified content"
  
  includes:
    - "Active phase section (Solution-Design, Implementation-Log, Evaluation-Results)"
    - "Implementation-Plan if status updates made"
    - "Any other sections modified (Notes-Context, Work-Log)"
  
  how: |
    Capability files guide WHAT to write and WHERE during active work.
    Checkpoint protocol ensures the ISS file on disk reflects ALL work done.
    If any ISS content was added or modified during the conversation,
    checkpoint must persist it before the conversation ends.
  
  critical_rule: "ISS is the datastore — ANY unsaved ISS work = lost work"
```

---

### Writing Guidance

#### Title
**Purpose**: Quick identification of the work

| Do | Don't |
|----|-------|
| "Fix login validation to reject invalid emails" | "Login bug" |
| Start with action verb | Start with noun |

**Format**: Verb + Object + Context (5-100 chars)

#### Description
**Purpose**: Explain WHAT needs to happen and WHY

| Do | Don't |
|----|-------|
| Full context, background, rationale | One-line summary |
| Include the problem AND the impact | Just state the symptom |

Simple issues: 1-2 sentences. Complex issues: multiple paragraphs.

#### Success Criteria
**Purpose**: Verifiable definition of DONE

| Do | Don't |
|----|-------|
| "Response time under 200ms" | "Fast enough" |
| "All 45 patterns migrated" | "Patterns work" |
| Quality and capability statements | Implementation steps |

#### Work Log
**Purpose**: Issue journey overview — significant milestones only

| Write (valuable) | Don't write (fluff) |
|-------------------|---------------------|
| "Analysis complete, 5-step plan approved" | "Continued working" |
| "Decided prefixed YAML over nested" | "Discussed options" |
| "Tool issue discovered, researching alternatives" | "Made progress" |

[/Section: ISS-File-Structure]

---

## Research ISS File Structure
[Section: Research-ISS-File-Structure]

Research issues use the same parent sections as standard issues but with research-specific subsections and guidance. Used by /nexus-create-issue when type=Research.

**Differences from standard ISS structure**:
- Solution-Design → **Research Design** (same section tags, research-oriented subsections)
- Implementation-Plan → **Research Plan** (milestones, not file changes)
- Implementation-Log → **Research Log** (findings, not changes made)
- Evaluation-Results → unchanged (/nexus-validate assesses research quality)

### Scaffolding Rules

Research issues are always scaffolded as complex (all 7 section markers, full guidance comments) regardless of complexity score — research inherently needs the structure for multi-conversation tracking.

### Research ISS Template

```markdown
# ISS-XXX: {Title}
*Type: Research | Created: {YYYY-MM-DD} | Complexity: {1-5}*

## Description

{Research question, context, what we need to learn and why}

## Success Criteria

- [ ] {What defines thorough, complete research}

## Dependencies

**Blocked by**: []
**Blocks**: []
**Related**: []

---

## Research Design
[Section: Solution-Design]

### Approach
<!-- GUIDANCE: Approach — Research methodology: mode (Adoption/Comparative/Exploratory), rationale, core research questions, what we're trying to learn and why. -->

*Not started*


### Subjects & Scope
<!-- GUIDANCE: Subjects & Scope — What we're researching: specific frameworks, tools, methodologies, technologies, or topics. Boundaries on what's in/out of scope. Depth expectations. -->

*Not started*


### Tools & Patterns
<!-- GUIDANCE: Tools & Patterns — Document what was used and HOW it influenced the research design. Cognitive tools, patterns, strategic approaches chosen during analysis. Records WHAT tools/patterns were chosen. Pattern OUTCOMES go in Research Log ### Pattern Outcomes. -->

*Not started*


### Evaluation Criteria
<!-- GUIDANCE: Evaluation Criteria — For Adoption: criteria that determine adopt/reject. For Comparative: dimensions of comparison. For Exploratory: questions to answer. -->

*Not started*


### Source Strategy
<!-- GUIDANCE: Source Strategy — Where to look: official docs, papers, code repos, community resources. Priority sources for deep investigation. Known information gaps. -->

*Not started*


### Key Decisions
<!-- GUIDANCE: Key Decisions — Scoping decisions: why these subjects, why this mode, depth vs breadth trade-offs. Rationale should answer "why not the alternative?" -->

*Not started*


### Risks & Mitigations
<!-- GUIDANCE: Risks — Research risks: confirmation bias, incomplete coverage, unreliable sources, scope creep, outdated information. -->

*Not started*


[/Section: Solution-Design]

## Research Plan
[Section: Implementation-Plan]
<!-- GUIDANCE: Research Plan — Research phases with milestones. Which subjects/sources per conversation. Deliverable targets. Not file changes — knowledge milestones. -->

*Not started*


*Status: ⬜ Pending | 🔄 Active | ✅ Done | ⏭️ Skipped | ❌ Blocked*

[/Section: Implementation-Plan]

## Research Log
[Section: Implementation-Log]

### Status
<!-- GUIDANCE: Status — Research phase, step, and progress. Updated by /nexus-research at each significant milestone. -->

*Not started*


### Findings Summary
<!-- GUIDANCE: Findings — Key discoveries per conversation. Source references. Organized by subject or research question. Append per conversation with conv reference. -->

*Not started*


### Quality Checks
<!-- GUIDANCE: Quality — Source credibility verification, coverage assessment across research questions, bias checks performed. Did we look at opposing viewpoints? -->

*Not started*


### Scope Changes
<!-- GUIDANCE: Scope Changes — New questions that emerged, subjects added or dropped during research, with reasoning. Planned vs actual research trajectory. -->

*Not started*


### Pattern Outcomes
<!-- GUIDANCE: Pattern Outcomes — Detailed with evidence. Track patterns from "applied" to a verdict. Values (ISS-224 taxonomy): helped | neutral | hindered — one verdict + one-line evidence per pattern; dedup hard-gate (echo of a core rule caps at neutral). Canonical: pattern-specification.md → Outcome Verdicts. -->

*Not started*


### Research Pivots
<!-- GUIDANCE: Research Pivots — Methodology changes during research: shifted focus, changed sources, new approach. Decisions made DURING research, not in scoping. -->

*Not started*

### Issues Encountered
<!-- GUIDANCE: Issues Encountered — Problems and resolutions: sources unavailable, conflicting information, scope too broad/narrow. -->

*Not started*

[/Section: Implementation-Log]

## Evaluation Results
[Section: Evaluation-Results]

### Criteria Verification
<!-- GUIDANCE: Criteria Verification — Map DIRECTLY to Success Criteria. Every criterion must have a row. Was the research thorough? -->

*Not started*


### Quality Assessment
<!-- GUIDANCE: Quality Assessment — Research quality dimensions: source diversity, depth of analysis, objectivity, actionability of conclusions, coverage completeness. -->

*Not started*


### Deliverable Review
<!-- GUIDANCE: Deliverable Review — Assessment of the research output (report/comparison/analysis). Is it well-structured? Are claims supported? Are limitations stated? -->

*Not started*


### Issues Found
<!-- GUIDANCE: Issues Found — Gaps in research, weak conclusions, unsupported claims, areas needing further investigation. -->

*Not started*


### Lessons Learned
<!-- GUIDANCE: Lessons Learned — Research methodology reflection. What worked in the research process? What would we do differently? Feeds pattern extraction. -->

*Not started*


[/Section: Evaluation-Results]

---

## Closure
[Section: Closure]

### Resolution
<!-- GUIDANCE: Resolution — Research outcome summary: what was decided, what was learned, what issues were spawned. -->

*To be completed upon issue closure*


### Knowledge Captured
<!-- GUIDANCE: Knowledge Captured — Research insights worth preserving. Candidate patterns from the research process. Written by /nexus-close-issue. -->

*To be completed upon issue closure*


[/Section: Closure]

---

## Notes & Context
[Section: Notes-Context]

*Research context, background, related work*

[/Section: Notes-Context]

## Work Log
[Section: Work-Log]
<!-- GUIDANCE: Work Log — Research journey overview, significant milestones only. NOT for next conversation planning (that's sprint-state). -->

*Not started*


[/Section: Work-Log]
```

### Subsection Mapping (Research vs Standard)

| Parent Section | Standard Subsection | Research Subsection | Why Different |
|---|---|---|---|
| Solution-Design | Approach | Approach | Same header, research-oriented guidance |
| Solution-Design | Architecture | Subjects & Scope | Research has subjects, not components |
| Solution-Design | Tools & Patterns | Tools & Patterns | Same |
| Solution-Design | — | Evaluation Criteria | New — research-specific |
| Solution-Design | Key Decisions | Key Decisions | Same |
| Solution-Design | Risks & Mitigations | Risks & Mitigations | Same — different risk types |
| Solution-Design | Files Affected | Source Strategy | Research has sources, not files |
| Implementation-Plan | Phased step tables | Research phases | Milestones not file changes |
| Implementation-Log | Changes Made | Findings Summary | Knowledge not file modifications |
| Implementation-Log | Tests Created | Quality Checks | Source verification not test cases |
| Implementation-Log | Deviations | Scope Changes | Research scope evolution |
| Implementation-Log | Technical Decisions | Research Pivots | Methodology changes during research |
| Implementation-Log | Issues Encountered | Issues Encountered | Same |
| Evaluation-Results | Test Execution | Deliverable Review | Assess research output quality |
| Evaluation-Results | Criteria Verification | Criteria Verification | Same |
| Evaluation-Results | Quality Assessment | Quality Assessment | Research quality dimensions |

[/Section: Research-ISS-File-Structure]

---

## Registry Schema
[Section: Registry-Schema]

### Schema v7.0.0 Overview

**Format: Prefixed YAML** — Each field is globally unique via `ISS-XXX.fieldname: value` pattern.
This enables 100% reliable patching without mustBeNear or maxDistance concerns.

The registry is the **single source of truth** for all queryable issue metadata.

**18 fields total** — all required for new entries.

---

### Key Design Decisions

```yaml
v7_design:
  prefixed_format:
    pattern: "ISS-XXX.fieldname: value"
    benefit: "100% reliable patching - every field globally unique"
  
  registry_only_metadata:
    moved_from_iss: "Priority, Impact, Status, Complexity, A/I/E scores, Blocks, Blocked-by"
    benefit: "Single source of truth, simpler score updates"
  
  two_place_update:
    locations: "Registry + sprint-state (2 places)"
    benefit: "Simpler, less error-prone"
  
  description_field:
    purpose: "1-2 sentence summary for organize-sprint matching"
    benefit: "Find similar issues without loading ISS files"
```

---

### Complete Schema (18 Fields)

```yaml
# --- ISS-XXX ---
ISS-XXX.title: "Action verb + object + context"
ISS-XXX.type: "Bug|Feature|Improvement|Refactor|Documentation|Question|Research|Creative"
ISS-XXX.file: "issues/ISS-XXX.md"
ISS-XXX.description: "1-2 sentence summary for matching"
ISS-XXX.priority: "Critical|High|Medium|Low"
ISS-XXX.impact: "Critical|High|Medium|Low"
ISS-XXX.status: "Open|In-Progress|Resolved|Rejected|Superseded|Decomposed"
ISS-XXX.complexity: 1-5
ISS-XXX.created: "YYYY-MM-DD"
ISS-XXX.created_in_sprint: "NNN"
ISS-XXX.target_sprint: "NNN|TBD"
ISS-XXX.blocks: []
ISS-XXX.blocked_by: []
ISS-XXX.scope_files: []
ISS-XXX.analyzed: 1-5
ISS-XXX.implemented: 1-5
ISS-XXX.evaluated: 1-5
ISS-XXX.notes: ""
```

**Field Groups:**
- **Identity**: title, type, file, description
- **Classification**: priority, impact, status, complexity
- **Timeline**: created, created_in_sprint, target_sprint
- **Relationships**: blocks, blocked_by, scope_files
- **Progress**: analyzed, implemented, evaluated
- **Context**: notes

---

### Field Specifications

#### Type Values
| Value | Meaning | Example |
|-------|---------|---------|
| `Bug` | Something broken | Login accepts invalid emails |
| `Feature` | New functionality | Add dark mode toggle |
| `Improvement` | Enhancement to existing | Optimize search performance |
| `Refactor` | Internal restructuring | Reorganize module structure |
| `Documentation` | Doc-only changes | Update API documentation |
| `Question` | Investigation/research | How should caching work? |
| `Research` | Systematic research producing structured knowledge | Evaluate framework X for adoption |
| `Creative` | Content/artifact production | Presentation, report, marketing copy, tutorial |

#### Priority Values (Urgency)
| Value | Meaning | Guidance |
|-------|---------|----------|
| `Critical` | Blocks everything | System down, data loss risk |
| `High` | Important, soon | Blocks other work, user-facing bug |
| `Medium` | Normal priority | Standard feature work |
| `Low` | When time permits | Nice to have, minor polish |

#### Impact Values (Importance)
| Value | Meaning | Guidance |
|-------|---------|----------|
| `Critical` | Foundational | Core architecture, security |
| `High` | Significant value | Key feature, major improvement |
| `Medium` | Normal value | Standard work |
| `Low` | Minor value | Polish, minor enhancement |

#### Status Values
| Value | Meaning | Transitions To |
|-------|---------|----------------|
| `Open` | Created, not started | In-Progress |
| `In-Progress` | Being worked on | Resolved, Rejected, Decomposed |
| `Resolved` | Successfully completed | (archive) |
| `Rejected` | Won't do, invalid | (archive) |
| `Superseded` | Replaced by another issue | (archive) |
| `Decomposed` | Split into focused sub-issues | (archive) |

#### Complexity Scale
| Score | Meaning | Typical Scope |
|-------|---------|---------------|
| 1 | Trivial | Single file, obvious fix |
| 2 | Simple | 1-2 files, clear approach |
| 3 | Moderate | 2-3 files, some decisions |
| 4 | Complex | 4+ files, significant design |
| 5 | Very Complex | System-wide, major architecture |

#### Phase Scores (A/I/E)
| Score | Meaning |
|-------|---------|
| 1 | Not started |
| 2 | Initial work, basic progress |
| 3 | Partial completion |
| 4 | Well advanced, ready to proceed |
| 5 | Fully complete |

**Phase Transition Rule**: Score ≥ 4 indicates ready to advance to next phase.

#### Description Field
**Purpose**: Enable organize-sprint to find similar issues without loading ISS files.

| Do | Don't |
|----|-------|
| "Comprehensive review of all 50+ system files for optimization" | Copy entire description |
| 1-3 sentences, ~200-400 chars (soft guidance — carry the rationale organize-sprint needs) | Paragraphs |

---

### Defaults for New Issues

```yaml
new_issue_defaults:
  # Set by create-issue from user input
  title: "{from user}"
  type: "{detected or user choice}"
  file: "issues/ISS-{next_id}.md"
  description: "{extracted summary from full description}"
  priority: "{estimated or user choice}"
  impact: "{estimated or user choice}"
  complexity: "{estimated or user choice}"
  created: "{current date YYYY-MM-DD}"
  created_in_sprint: "{current sprint or empty}"
  target_sprint: "{from context or 'TBD'}"
  blocks: []
  blocked_by: "{detected or []}"
  scope_files: "{detected or []}"
  notes: "{optional}"
  
  # Auto-set (always these values)
  status: "Open"
  analyzed: 1
  implemented: 1
  evaluated: 1
```

---

### Complete Example

```yaml
# --- ISS-092 ---
ISS-092.title: "Fix login validation to reject invalid emails"
ISS-092.type: "Bug"
ISS-092.file: "issues/ISS-092.md"
ISS-092.description: "Login form accepts invalid email formats like 'user@', causing downstream notification errors."
ISS-092.priority: "High"
ISS-092.impact: "High"
ISS-092.status: "In-Progress"
ISS-092.complexity: 3
ISS-092.created: "2026-01-27"
ISS-092.created_in_sprint: "045"
ISS-092.target_sprint: "045"
ISS-092.blocks: []
ISS-092.blocked_by: []
ISS-092.scope_files: ["login.md", "validation.md"]
ISS-092.analyzed: 4
ISS-092.implemented: 2
ISS-092.evaluated: 1
ISS-092.notes: "Analysis complete, implementation started"
```

---

### Registry Structure

```yaml
# issues-registry.yaml
# Version: 7.0.0 | Schema: v7.0.0

# --- Metadata --- 
last_id: 106
total_active: 17

# --- ISS-086 ---
ISS-086.title: "Integration Testing Suite Phase 1 - Core Workflows"
ISS-086.type: "Improvement"
# ... all 18 fields ...

# --- INSERT NEW ISSUES HERE ---
```

---

### Validation Checklist

After creating/modifying a registry entry:

1. ✅ All 18 fields present
2. ✅ `title` is 5-100 chars, Verb + Object pattern
3. ✅ `description` is 1-3 sentences (~200-400 chars, soft guidance)
4. ✅ `type` is valid enum
5. ✅ `priority` is valid enum
6. ✅ `impact` is valid enum
7. ✅ `status` is valid enum
8. ✅ `complexity` is 1-5 integer
9. ✅ `created` is YYYY-MM-DD format
10. ✅ Phase scores are 1-5 integers
11. ✅ Arrays use `[]` format, quoted strings for IDs
12. ✅ Issue file exists at `file` path
13. ✅ Prefixed format: `ISS-XXX.fieldname: value`
14. ✅ Metadata counts updated

[/Section: Registry-Schema]

---

## Issue Lifecycle
[Section: Issue-Lifecycle]

### State Transitions

```
                    ┌─────────────────────────────────────┐
                    │              CREATE                 │
                    │       (/nexus-create-issue)         │
                    └──────────────┬──────────────────────┘
                                   │
                                   ▼
                    ┌─────────────────────────────────────┐
                    │              OPEN                   │
                    │          Status: Open               │
                    │        A:1  I:1  E:1                │
                    └──────────────┬──────────────────────┘
                                   │ work-issue / update-issue
                                   ▼
                    ┌─────────────────────────────────────┐
                    │          IN-PROGRESS                │
                    │      Status: In-Progress            │
                    │   A:1-5  I:1-5  E:1-5               │
                    │                                     │
                    │   Phases flow:                      │
                    │   Analysis (A≥4) →                  │
                    │   Implementation (I≥4) →            │
                    │   Evaluation (E≥4)                  │
                    └───────┬─────────────┬─────────────────────┘
                            │             │             │
              ┌─────────────┘             │             └──────────────────┐
              ▼                           ▼                                ▼
┌─────────────────────────┐  ┌─────────────────────────┐  ┌───────────────────────────┐
│        RESOLVED         │  │        REJECTED         │  │        DECOMPOSED         │
│    Status: Resolved     │  │    Status: Rejected     │  │    Status: Decomposed     │
│   A:4-5  I:4-5  E:4-5   │  │   (any scores)          │  │   (any scores)            │
│                         │  │                         │  │                           │
│   /nexus-close-issue:   │  │   /nexus-close-issue:   │  │   /nexus-decompose-issue:  │
│   - Knowledge extracted │  │   - Reason documented   │  │   - Children created      │
│   - Verdicts captured   │  │                         │  │   - Original archived     │
└───────────┬─────────────┘  └───────────┬─────────────┘  └─────────────┬─────────────┘
            │                            │                               │
            └────────────────┬───────────┘                               │
                             │               ┌───────────────────────────┘
                             │               │
                             └───────┬───────┘
                                     │ /nexus-archive-issue
                                     ▼
              ┌─────────────────────────────────────────┐
              │              ARCHIVED                   │
              │                                         │
              │   - Removed from issues-registry.yaml   │
              │   - File moved to archived/issues/      │
              │   - Knowledge preserved                 │
              └─────────────────────────────────────────┘
```

### Phase Flow & ISS File Sections

```yaml
analysis_phase:
  scores: "A: 1→5"
  capability: "/nexus-analyze skill"
  writes_to:
    - "[Section: Solution-Design] — approach, architecture, tools, decisions, risks, files"
    - "[Section: Implementation-Plan] — phases, steps, sequence"
  complete_when: "A ≥ 4"

research_phase:
  scores: "I: 1→5"
  capability: "/nexus-research skill"
  writes_to:
    - "[Section: Implementation-Log] — findings summary, quality checks, scope changes, pattern outcomes"
  updates:
    - "[Section: Implementation-Plan] — status column (⬜→✅)"
  complete_when: "I ≥ 4"
  note: "Research issues use Research-ISS-File-Structure for scaffolding. Phase flow: A → R → E"

implementation_phase:
  scores: "I: 1→5"
  capability: "/nexus-build skill"
  writes_to:
    - "[Section: Implementation-Log] — status, changes, tests, deviations, outcomes, decisions, issues"
  updates:
    - "[Section: Implementation-Plan] — status column (⬜→✅)"
  complete_when: "I ≥ 4"

evaluation_phase:
  scores: "E: 1→5"
  capability: "/nexus-validate skill"
  writes_to:
    - "[Section: Evaluation-Results] — test execution, criteria, quality, issues found, lessons"
  complete_when: "E ≥ 4"

closure:
  trigger: "All phases ≥ 4 AND user confirms"
  operation: "/nexus-close-issue"
  writes_to:
    - "[Section: Closure] — resolution, knowledge captured"
  also_updates:
    - "issues-registry.yaml: status → Resolved"
    - "patterns-registry.yaml: NOT written here — pattern verdicts (helped/neutral/hindered + evidence) land in [Section: Closure]; effectiveness is applied at /nexus-close-sprint STEP 3 via /nexus-update-pattern"
```

### Two-Place Update Protocol

When updating phase scores (A/I/E), update exactly TWO places:

```yaml
place_1_registry:
  location: ".nexus/active/registries/issues-registry.yaml"
  fields: "ISS-XXX.analyzed, ISS-XXX.implemented, ISS-XXX.evaluated"
  format: "ISS-XXX.{field}: {value}"

place_2_sprint_state:
  condition: "If sprint work (not standalone)"
  location: ".nexus/active/states/sprint-state.md"
  section: "[OBJECTIVES]"
  format: "ISS-XXX: {title} ({priority}, {complexity}) - A:{X} I:{Y} E:{Z}"

NOT_updated:
  iss_file: "ISS file has NO metadata — registry is source of truth"
```

### Closure Requirements

```yaml
resolution_closure:
  minimum_scores: "A:4, I:4, E:4"
  required_actions:
    - "[Section: Closure] populated in ISS file"
    - "Pattern outcomes recorded in ISS (### Pattern Outcomes) — effectiveness aggregated at sprint closure"
    - "Candidate patterns identified (if any)"
  registry_update: "status: Resolved"

rejection_closure:
  required_actions:
    - "Reason documented in [Section: Closure]"
    - "Registry status: Rejected, Superseded, or Decomposed"
  no_minimum_scores: true

archival:
  trigger: "After closure (Resolved, Rejected, Superseded, or Decomposed)"
  actions:
    - "Remove entry from issues-registry.yaml"
    - "Move file to archived/issues/ISS-XXX-{slug}.md (slug from title — the memory layer's archived_file pointers depend on it)"
    - "Update metadata.total_active -= 1"
```

[/Section: Issue-Lifecycle]

---

## CRUD Operations Reference
[Section: CRUD-Operations]

### Operation Responsibilities

| Operation | Registry | ISS File |
|-----------|----------|----------|
| **create-issue** | Creates entry (18 fields) | Creates file (scaffolded template) |
| **/nexus-view-issues** | Reads (queries/filters) | — |
| **update-issue** | Updates any field | Updates content sections |
| **work-issue** | Updates target_sprint, status→In-Progress | — (sets active focus; methodology handles phase sections) |
| **close-issue** | Updates status | Writes `[Section: Closure]` |
| **archive-issue** | Removes entry | Moves file |
| **decompose-issue** | Status → Decomposed, creates children | Writes `[Section: Closure]`, archives original |
| **NEXUS (Analysis)** | Updates analyzed score | Writes `[Section: Solution-Design]` + `[Section: Implementation-Plan]` |
| **NEXUS (Implementation)** | Updates implemented score | Writes `[Section: Implementation-Log]`, updates `[Section: Implementation-Plan]` status |
| **NEXUS (Research)** | Updates implemented score | Writes `[Section: Implementation-Log]` (research findings), updates `[Section: Implementation-Plan]` status |
| **NEXUS (Evaluation)** | Updates evaluated score | Writes `[Section: Evaluation-Results]` |

### Two-Place Update Protocol

```yaml
when_updating_scores:
  always_update:
    - "issues-registry.yaml: ISS-XXX.{analyzed|implemented|evaluated}"
    - "sprint-state.md [OBJECTIVES]: A:{X} I:{Y} E:{Z}"
  
  never_update:
    - "ISS file (no metadata section)"
  
  rule: "Always update both or none"
  verification: "🔄 Updated scores in 2 locations"
```

### Integration Points
```yaml
calling_operations:
  generate_mvp_issues: "Calls create-issue in backend mode"
  organize_sprint: "Reads registry for planning"
  close_sprint: "Calls close-issue for sprint issues"

field_usage_by_operation:
  organize_sprint:
    reads: "status, blocked_by, target_sprint, priority, impact, complexity, blocks, title, description, scope_files, notes"
  list_issues:
    reads: "status, blocked_by, priority, complexity, title, type, A/I/E scores"
  query_issues:
    reads: "All fields (search/filter)"
```
[/Section: CRUD-Operations]

