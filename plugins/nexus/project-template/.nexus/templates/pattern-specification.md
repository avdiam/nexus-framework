# pattern-specification.md
*Version: 3.2.2 | Date: 2026-08-20 | Sprint: 110*

**Single source of truth for pattern structure — PAT files and patterns-registry entries.**

Consumers: create-pattern loads both sections (JIT, after validation gates). update-pattern, delete-pattern, and other operations reference specific fields inline and attribute to this spec. When an operation needs the full template or schema, it loads the relevant section.

## Pattern File Structure
[Section: Pattern-File-Structure]

### Philosophy

**Patterns are for NEXUS (LLM) to match, propose, adapt, and execute.**

A pattern is NOT documentation of what happened. A pattern IS:
- Generalizable wisdom extracted from specific experiences
- Strategic guidance for FUTURE decisions
- Something NEXUS can propose for DIFFERENT issue types

**Transformation lens**: Strip concrete context, keep the principle. Test: "Can NEXUS propose this for different situations in the future?"

---

### Writing Guidance for PAT Files

#### Problem Section
**Purpose**: What problem class does this solve (general, not issue-specific)

| Do | Don't |
|----|-------|
| "File modifications fail silently when target doesn't exist" | "ISS-042 had a bug with the config file" |
| "Complex systems lack validation before major changes" | "We forgot to test in Sprint 38" |

#### Solution Section
**Purpose**: Behavioral guidance NEXUS can follow

| Do | Don't |
|----|-------|
| "Always verify file exists before modification using Read tool" | "Be careful with files" |
| "Apply systematic validation at each phase transition" | "Test more" |

Use action language: "Always...", "Before X, do Y...", "When Z, then..."

#### Context Section
**Purpose**: When to use and when NOT to use

```yaml
good_context:
  use_when:
    - "Before making any code or file modifications"
    - "When debugging with unclear root cause"
  not_when:
    - "For trivial changes with no risk"
    - "When time-critical and risk is accepted"

bad_context:
  use_when: ["testing", "validation"]  # Keywords, not scenarios
  not_when: ["sometimes"]  # Vague
```

#### Rationale Section
**Purpose**: The WISDOM element - WHY this works

This is Q4 of 4Q validation. Must explain the underlying principle, not just what to do.

| Do | Don't |
|----|-------|
| "Verification before action catches errors when correction is cheapest" | "Because it's a good practice" |
| "Existing solutions have survived real-world testing that new code lacks" | "Reuse is efficient" |

---

### PAT File Template

```markdown
# PAT-XXX: {Pattern Name}
*Version: 1.0.0 | Date: YYYY-MM-DD | Sprint: NNN*

## Metadata
- **Type**: [principle|methodology|practice|solution]
- **Status**: active
- **Created**: YYYY-MM-DD

## Problem
{General problem class this solves - not issue-specific}

## Context
- **Use When**: {scenarios as natural language}
- **Not When**: {anti-scenarios}
- **Prerequisites**: {what must exist}

## Solution
{Behavioral guidance NEXUS can follow}

### Implementation
{Concrete steps or template}

### Variations (Optional)
- **Variant A**: {for situation X}
- **Variant B**: {for situation Y}

### Quick Reference (Optional - for complex patterns)
{For patterns with many steps: provide a condensed checklist or table. Delete if pattern is simple enough without it.}

## Historical Context (Optional)
{For patterns with lineage: origin, evolution, relationship to predecessor patterns or external sources. Delete this section if not applicable.}

## Rationale
{WHY this works - the wisdom element}
- **Theoretical Basis**: {underlying principles}
- **Empirical Evidence**: {observed results}
- **Design Decisions**: {key choices made}

## Anti-Patterns
{What NOT to do - common mistakes to avoid}
- **Anti-Pattern 1**: {description}
  - **Why Wrong**: {explanation}
  - **Example**: {bad example}

## Relationships
- **Requires**: {dependencies}
- **Enhances**: {synergies}
- **Conflicts**: {incompatibilities}
- **Alternatives**: {other approaches}

## Consequences
- **Benefits**: {positive outcomes}
- **Tradeoffs**: {what you give up}
- **Risks**: {potential issues}

## Examples

### Before/After Comparison (Recommended)
**Without Pattern**: {problem in action}
**With Pattern**: {improvement}

### Application Example
{Concrete application with context and outcome}

## Validation (Optional)
How to verify this pattern is working:
- **Success Indicator**: {How you know the pattern was applied correctly}
- **Edge Cases**: {Situations where pattern might not apply or needs adaptation}

## Resources (Optional)
References to extended materials that complement this pattern — guides, skill definitions, templates, or external references. Load on demand when the pattern's core guidance isn't sufficient.

- **{resource name}**
  - Type: guide | skill | reference | template
  - Path: {relative path from project root, or future skill identifier}
  - Description: {what it provides beyond the pattern itself}
  - Load When: {scenario when loading this resource adds value}

## Evolution
- **Version History**: v1.0.0 (YYYY-MM-DD): Initial from {source}
- **Last Updated**: YYYY-MM-DD

## Notes and Observations
{Additional insights, lessons learned, or context that helps understand the pattern}
```

---

### Field Reference

| Field | Required | Notes |
|-------|----------|-------|
| Type | Yes | principle, methodology, practice, solution |
| Problem | Yes | General problem class |
| Context | Yes | Use when / Not when scenarios |
| Solution | Yes | Behavioral guidance |
| Rationale | Yes | The wisdom (Q4) |
| Anti-Patterns | Recommended | Common mistakes |
| Relationships | Optional | Fill as discovered |
| Consequences | Recommended | Benefits/Tradeoffs/Risks |
| Examples | Recommended | Before/After most valuable |
| Resources | Optional | Extended guides, skills, templates. Load on demand |
| Evolution | Yes | Track maturity |

[/Section: Pattern-File-Structure]

## Registry Entry Structure
[Section: Registry-Entry-Structure]

### Schema Overview

**Prefixed YAML format** where each field is globally unique via `PAT-XXX.fieldname: value`. This enables 100% reliable patching without mustBeNear or maxDistance concerns. Matches issues-registry.yaml format.

The registry (`patterns-registry.yaml`) enables pattern MATCHING. It contains metadata for discovery, not full pattern content.

**16 fields total** — all required for new entries.

---

### Writing Guidance for Registry Entries

#### `description` Field
**Purpose**: Help NEXUS understand WHAT the pattern IS and DOES

| Guideline | Example |
|-----------|---------|
| Start with action verb/purpose | "Validates...", "Ensures...", "Discovers..." |
| Include core principle/insight | "...by checking state before modification" |
| Mention key benefit | "...preventing silent failures" |
| Be specific enough to differentiate from other patterns | - | 
| 1-3 rich sentences | Not keywords, not paragraphs |

**Good**:
```yaml
description: "Always test current state before making changes - understand what exists before modifying. Prevents assumptions and catches issues early."

description: "Discover existing capabilities before building new ones. 80-95% of 'new' features already exist dormant - shift from builder to archaeologist mindset."
```

**Bad**:
```yaml
description: "Testing pattern."  # Too vague
description: "This pattern is about testing things before you do them which is important because..."  # Too verbose
```

#### `use_when` Field
**Purpose**: Tell NEXUS WHEN to suggest this pattern

| Guideline | Example |
|-----------|---------|
| Natural language scenarios | "Before making any code modifications" |
| NOT keywords | ~~"testing", "validation"~~ |
| 2-5 distinct triggers | Each = different situation/trigger situation |
| Include CAUTION if needed | "CAUTION: Only for multi-file architectures" |

**Good**:
```yaml
use_when:
  - "Before making any code or file modifications"
  - "When debugging with unclear root cause"
  - "Before refactoring existing functionality"

# Pattern with caution
use_when:
  - "When building LLM-powered systems with behavioral requirements"
  - "CAUTION: Only for projects requiring multi-file prompt architectures"  
```

**Bad**:
```yaml
use_when:
  - "testing"  # Keyword
  - "when needed"  # Circular
  - "for validation work"  # Vague
```

#### `domain` Field
**Purpose**: Quick filtering before detailed matching

- 1-5 words, free text
- Examples: "validation", "system-design", "knowledge-management", "file-operations"

---

### Field Specifications

#### Type Values
| Value | Meaning | Example |
|-------|---------|---------|
| `principle` | Guiding philosophy - WHY | PAT-009 (simplicity) |
| `methodology` | Structured process - HOW | PAT-063 (systematic validation) |
| `practice` | Proven technique - WHAT works | PAT-004 (prompt engineering) |
| `solution` | Specific answer to problem class | PAT-051 (file modularization) |

#### Maturity Levels
| Level | Meaning | Promotion Criteria |
|-------|---------|-------------------|
| `emerging` | New, hypothesis | Initial state |
| `validated` | Has evidence of success| 3+ successful applications |
| `proven` | Consistently effective | 0.70+ effectiveness, 5+ applications |
| `established` | Reference standard | 0.85+ effectiveness, 10+ applications |

**Note**: Patterns embedded into system files are REMOVED from registry, not promoted further.

#### `phase_affinity`

Which work phases this pattern is most relevant to. Used by `/nexus-match-pattern` (STEP 0 load-time eligibility gate, then scoring).

| Value | Meaning |
|-------|---------|
| `["analysis"]` | Primarily useful during analysis |
| `["implementation"]` | Primarily useful during implementation |
| `["evaluation"]` | Primarily useful during evaluation |
| `["all"]` | Phase-independent, broadly applicable |
| Multiple values | Useful across listed phases, e.g. `["analysis", "implementation"]` |

Valid values: `analysis`, `implementation`, `evaluation`, `research`, `all`. Use `all` sparingly — most patterns have phase preferences.

#### Outcome Verdicts (helped / neutral / hindered)

Every applied-pattern outcome recorded at closure is one of three **verdicts** — NOT an automatic success. (Origin: ISS-224, Sprint 105 — replacing the old {success/partial/failure} taxonomy where "partial" silently incremented `successes`, structurally inflating effectiveness.)

| Verdict | Meaning | Counter effect |
|---|---|---|
| **helped** | Pattern genuinely contributed to the outcome (added value beyond what the framework already enforces) | `successes += 1` |
| **neutral** | Pattern was applied but added no value beyond what CLAUDE.md / a skill already enforces (echo), or its contribution is indeterminate | `neutral += 1` — increments NEITHER `successes` NOR `failures` |
| **hindered** | Pattern misled, added friction, or caused rework | `failures += 1` |

**Dedup hard-gate** (SC-04): a pattern whose guidance merely restates an always-on CLAUDE.md core rule / preference / trait, or a skill step, **cannot** be scored `helped` — it caps at `neutral`. High application count is not value; an echo-pattern must not accrue `successes`.

**Anti-pattern — auto-success**: recording every applied pattern as a success (the pre-ISS-224 default) corrupts the learning loop. A verdict + one-line evidence is mandatory per applied pattern; there is no path that increments `successes` without a recorded `helped` verdict. See CLAUDE.md Pattern Governance.

#### Effectiveness Formula

The formula is **unchanged** by the verdict taxonomy — only what feeds `successes`/`failures` changed. **`neutral` is excluded from both the numerator and the volume-confidence denominator**: an applied-but-valueless pattern neither helps nor builds confidence, so it stays near the 0.50 seed rather than inflating.

```
effectiveness = 0.50 + ((success_rate - 0.50) × volume_confidence)

where:
  success_rate = successes / (successes + failures)  # 0.50 if both 0; neutral excluded
  volume_confidence = min(1.0, (successes + failures) / 10)  # neutral excluded
```

| Successes | Failures | Neutral | Effectiveness |
|-----------|----------|---------|---------------|
| 0 | 0 | 0 | 0.50 (untested) |
| 2 | 8 | 0 | 0.20 (problematic) |
| 5 | 5 | 0 | 0.50 (Inconsistent) |
| 3 | 0 | 0 | 0.65 |
| 8 | 2 | 0 | 0.80 |
| 10 | 0 | 0 | 1.00 (Perfect) |
| 2 | 0 | 10 | 0.60 (applied 12×, helped twice — echo-pattern stays skeptical, NOT inflated) |

---

### Complete Schema (16 Fields)

```yaml
# --- PAT-XXX ---
PAT-XXX.name: "pattern-name-kebab-case"
PAT-XXX.file: "patterns/PAT-XXX.md"
PAT-XXX.type: "principle|methodology|practice|solution"
PAT-XXX.domain: "1-5 word domain"
PAT-XXX.maturity: "emerging|validated|proven|established"
PAT-XXX.description: "1-3 rich sentences - WHAT it IS and DOES"
PAT-XXX.use_when:
  - "Scenario 1 when to apply this pattern"
  - "Scenario 2"
  - "Scenario 3 (optional)"
PAT-XXX.successes: 0
PAT-XXX.failures: 0
PAT-XXX.neutral: 0
PAT-XXX.effectiveness: 0.50
PAT-XXX.last_used: null
PAT-XXX.by_issue_type: {}
PAT-XXX.phase_affinity: ["analysis"]
PAT-XXX.synergies: []
PAT-XXX.conflicts: []
```

**Field Groups:**
- **Identity**: name, file, type
- **Classification**: domain, maturity, phase_affinity
- **Matching**: description, use_when
- **Effectiveness**: successes, failures, neutral, effectiveness, last_used
- **Track Record**: by_issue_type
- **Relationships**: synergies, conflicts

---

### Defaults for New Patterns

```yaml
# Set by /nexus-create-pattern (user input + inference)
PAT-XXX.name: "{generated-kebab-case}"
PAT-XXX.file: "patterns/PAT-{next_id}.md"
PAT-XXX.type: "{user or inferred}"
PAT-XXX.domain: "{inferred from context}"
PAT-XXX.description: "{generated per guidance}"
PAT-XXX.use_when: ["{generated scenarios}"]
PAT-XXX.phase_affinity: ["{inferred from context}"]

# Auto-set (always these values for new patterns)
PAT-XXX.maturity: "emerging"
PAT-XXX.successes: 0
PAT-XXX.failures: 0
PAT-XXX.neutral: 0
PAT-XXX.effectiveness: 0.50
PAT-XXX.last_used: null
PAT-XXX.by_issue_type: {}
PAT-XXX.synergies: []
PAT-XXX.conflicts: []
```

### Complete Example

```yaml
# --- PAT-029 ---
PAT-029.name: "test-first-validation-principle"
PAT-029.file: "patterns/PAT-029.md"
PAT-029.type: principle
PAT-029.domain: "validation"
PAT-029.maturity: established
PAT-029.description: "Always test current state before making changes - understand what exists before modifying. Prevents assumptions and catches issues early."
PAT-029.use_when:
  - "Before making any code or file modifications"
  - "When debugging with unclear root cause"
  - "Before refactoring existing functionality"
  - "When assumptions about current state need verification"
PAT-029.successes: 19
PAT-029.failures: 0
PAT-029.neutral: 0
PAT-029.effectiveness: 1.00
PAT-029.last_used: "2026-01-27"
PAT-029.by_issue_type: {refactor: 8, bug: 5, feature: 5}
PAT-029.phase_affinity: ["implementation", "evaluation"]
PAT-029.synergies: ["PAT-049"]
PAT-029.conflicts: []
```

---

### Registry Metadata

```yaml
meta.last_id: 81
meta.active: 19
```

---

### Validation Checklist

After creating or modifying a registry entry:

1. ✅ All 16 fields present
2. ✅ Prefixed format: `PAT-XXX.fieldname: value`
3. ✅ `name` is kebab-case and unique
4. ✅ `type` is valid enum value
5. ✅ `maturity` is valid enum value
6. ✅ `description` is 1-3 rich sentences (not keywords)
7. ✅ `use_when` has 2-5 scenario strings (not keywords)
8. ✅ `effectiveness` matches formula (or 0.50 for new); `successes`/`failures`/`neutral` are integers ≥ 0
9. ✅ `last_used` is null or "YYYY-MM-DD"
10. ✅ Arrays use `[]` not `null`
11. ✅ Pattern file exists at `file` path
12. ✅ `phase_affinity` has valid values (analysis, implementation, evaluation, research, all)
13. ✅ Metadata counts updated (`meta.last_id`, `meta.active`)

---

### Field Ownership

Which operations read and write each field group:

| Field Group | Written By | Read By |
|---|---|---|
| Identity (name, file, type) | create-pattern | All operations |
| Classification (domain, maturity, phase_affinity) | create-pattern; update-pattern (phase_affinity reinforcement) | match-pattern, list-patterns, merge-patterns |
| Matching (description, use_when) | create-pattern | match-pattern, merge-patterns, create-pattern (similarity) |
| Effectiveness (successes, failures, neutral, effectiveness, last_used) | update-pattern | match-pattern, list-patterns, merge-patterns, delete-pattern |
| Track Record (by_issue_type) | update-pattern | list-patterns, match-pattern |
| Relationships (synergies, conflicts) | create-pattern; merge-patterns (synergies) | match-pattern, merge-patterns |
| Metadata (`meta.last_id`, `meta.active`; registry version lives in the `# Version:` header comment) | create-pattern, delete-pattern | All operations |

[/Section: Registry-Entry-Structure]
