# Project Type Template Specification
*Version: 1.0.1 | Date: 2026-08-20 | Sprint: 110*

*Meta-template: defines the spec for domain profile files in .nexus/templates/project-types/*

spec_version: "1.0.0"
built_for_wizard: "5.1.0"

## Purpose

Each project type has a domain profile — a single markdown file loaded by the wizard
after type selection. Profiles provide domain-specific content the LLM uses to make
informed proposals instead of generic questions.

**Location**: `.nexus/templates/project-types/{type-slug}.md` (one file per type, kebab-case)

**Reference implementations**: See software-product-dev.md, research-analysis.md, and
operations-process.md as pilot profiles demonstrating expected content density and style.

**Design principles**:
- Domain-specific only — if content would be identical across all types, it belongs in the wizard engine
- Guide the LLM, don't script dialogue — framing hints say WHAT to emphasize, not HOW to phrase it
- Use domain-native language — "Literature Review" not "Discovery Phase" for Research
- Target ≤ 4KB per profile — loaded every project setup, bloat costs tokens
- Examples over abstractions — concrete deliverable/phase/risk examples beat definitions

## Section Specification

Every profile has exactly 7 sections with standard `[Section:]`/`[/Section:]` markers.
All sections required. The wizard loads the full file in one Read call.

---

### Section 1: Profile

Behavioral frame for the wizard. Loaded first, shapes all subsequent steps.

```markdown
[Section: Profile]
type_name: "{Display name — e.g., Software / Product Development}"
category: "{Technical | Research | Business | Creative}"
description: "{1-2 sentences — when to choose this type}"
wizard_emphasis: "{What the wizard should focus on for this type}"
phase_character: "{How phases tend to look — e.g., build-heavy with feedback loops}"
typical_deliverables: "{High-level deliverable categories}"
wizard_depth: "{light | standard | thorough}"
# light    — familiar domain, straightforward
# standard — moderate domain complexity
# thorough — unfamiliar or high-stakes

spec_version: "1.0.0"
template_version: "1.0.0"
[/Section: Profile]
```

---

### Section 2: Framing-Hints

Consumed per-step throughout the wizard. Each step checks relevant hints to adapt
its questions and proposals.

```markdown
[Section: Framing-Hints]
vision_question: "{Type-specific vision prompt}"
scope_emphasis: "{What scope boundaries matter most}"
deliverable_framing: "{How to frame deliverables}"
risk_framing: "{What risk areas to emphasize}"
effort_framing: "{How to discuss effort}"
constraint_emphasis: "{Key constraints for this type}"
[/Section: Framing-Hints]
```

---

### Section 3: Deliverable-Templates

Consumed at wizard STEP 4 (Deliverables). The LLM proposes from these examples,
user validates and extends. Include 2-4 examples per tier.

Maps to project-state fields: MVP → `mvp_deliverables`, Enhanced → `enhanced_deliverables`,
Future → `future_deliverables`.

```markdown
[Section: Deliverable-Templates]
### MVP Examples
- name: "{Deliverable name}"
  description: "{What this typically includes}"
  quality_criteria: "{What 'done' looks like}"

### Enhanced Examples
- name: "{Deliverable name}"
  description: "{What this typically includes}"
  quality_criteria: "{What 'done' looks like}"

### Future Examples
- name: "{Deliverable name}"
  description: "{What this typically includes}"
  quality_criteria: "{What 'done' looks like}"

### Categorization Guidance
"{How to categorize for this type — what makes something MVP vs Enhanced vs Future}"
[/Section: Deliverable-Templates]
```

---

### Section 4: Phase-Templates

Consumed at wizard STEP 5 (Phases & Effort). Wizard proposes a structure based on
project complexity, calibrates against timeline constraints from STEP 3.

Phase names MUST use domain-native language.

```markdown
[Section: Phase-Templates]
### Simple (2-3 phases)
- phase: "{Phase name in domain language}"
  objective: "{What this phase achieves}"
  typical_deliverables: "{Which deliverable types land here}"
  milestone: "{Key achievement marking phase completion}"

### Standard (3-4 phases)
- phase: "..."
  objective: "..."
  typical_deliverables: "..."
  milestone: "..."

### Complex (5-6 phases)
- phase: "..."
  objective: "..."
  typical_deliverables: "..."
  milestone: "..."

### Phase Naming Guidance
"{How phases should be named in this domain}"
[/Section: Phase-Templates]
```

---

### Section 5: Risk-Catalog

Consumed at wizard STEP 6 (Risks & Validation). LLM proposes from catalog,
user validates and adds project-specific risks. Aim for 5-8 risks per type.

Risks should be genuinely domain-specific, not generic project risks
(those are handled by the wizard engine).

```markdown
[Section: Risk-Catalog]
- risk: "{Domain-specific risk description}"
  probability: "{Low | Medium | High}"
  impact: "{Low | Medium | High}"
  mitigation_hint: "{Common mitigation approach}"
[/Section: Risk-Catalog]
```

---

### Section 6: Metrics

Consumed at wizard STEP 6 during metrics derivation. Combined with project-specific
vision and deliverables to propose metrics. User validates rather than inventing.

```markdown
[Section: Metrics]
quantitative:
  - "{Measurable metric relevant to this domain}"
qualitative:
  - "{Quality/experience metric}"
milestone_examples:
  - "{Typical milestone checkpoint for this type}"
[/Section: Metrics]
```

---

### Section 7: Issue-Breakdown

Consumed by /nexus-generate-mvp when breaking deliverables into issues. Provides
archetypes the LLM uses to propose domain-appropriate issue structures.

```markdown
[Section: Issue-Breakdown]
breakdown_pattern: "{Pattern name — e.g., component-oriented, methodology-oriented}"
pattern_description: "{How deliverables naturally break into issues}"
typical_structure:
  - type: "{Issue archetype}"
    description: "{What this issue typically covers}"
    typical_complexity: "{1-5}"
example_titles:
  - "{Domain-native example issue title}"

### Cross-Cutting Patterns
"{Common cross-deliverable issues for this type}"
[/Section: Issue-Breakdown]
```

---

## The 13 Project Types

| # | Slug | Display Name | Category |
|---|------|-------------|----------|
| 1 | software-product-dev | Software / Product Development | Technical |
| 2 | research-analysis | Research & Analysis | Research |
| 3 | complex-problem-solving | Complex Problem Solving | Research |
| 4 | product-design | Product Design | Creative |
| 5 | system-integration | System Integration | Technical |
| 6 | data-analytics | Data & Analytics | Technical |
| 7 | strategic-business-planning | Strategic / Business Planning | Business |
| 8 | educational-training | Educational / Training | Creative |
| 9 | creative-content | Creative / Content | Creative |
| 10 | operations-process | Operations / Process Improvement | Business |
| 11 | event-campaign | Event / Campaign Management | Business |
| 12 | compliance-audit | Compliance / Audit | Business |
| 13 | migration-transition | Migration / Transition | Technical |

## Version Chain

```
/nexus-setup-project SKILL.md (wizard version)
  └─ project-type-template.md (this file: built_for_wizard)
       └─ project-types/*.md (each: spec_version → this file's version)
```

/nexus-staleness-checker detects version mismatches across this chain.
