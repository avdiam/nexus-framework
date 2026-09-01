# human-guide-template.md
*Version: 1.0.2 | Date: 2026-08-20 | Sprint: 110*

*Flexible template for generating human-readable NEXUS documentation guides.*

---

## Template Purpose

This template provides structural guidance for /nexus-guide-creator when generating human-guides.
It is NOT a rigid form to fill — it defines **building blocks** that the LLM selects and
composes based on the guide's purpose, audience, and content type.

---

## Guide Header (Required)

```markdown
# {Guide Title}
*Version: {version} | Sprint: {sprint} | Category: {category}*

*{One-line description of what this guide covers and who it's for.}*

**Source files:** {list of system files this guide was generated from, with versions}

---
```

Categories: getting-started | domain | system-reference

---

## Building Blocks

The LLM selects from these blocks based on what the guide needs.
Not every guide uses every block. Order is flexible.

### Block: Introduction
```markdown
## What Is {Topic}?

{Clear explanation of what this guide covers, written for the target audience.}
{Why it matters in NEXUS.}
{What you'll understand after reading this guide.}
```
**Use when:** Almost always. Skip only for pure reference guides (like command reference).

### Block: Core Concepts
```markdown
## Core Concepts

{Define 3-7 key concepts the reader needs to understand.}
{Each concept: name, one-paragraph explanation, how it relates to other concepts.}
{Use concrete examples where possible.}
```
**Use when:** Guide introduces a domain or system the reader hasn't encountered.

### Block: How It Works
```markdown
## How {Thing} Works

{Explain the mechanism, workflow, or process.}
{Use diagrams (ASCII) where helpful.}
{Show the flow: trigger → steps → outcome.}
{Include "what happens when" scenarios.}
```
**Use when:** Guide covers a process, pipeline, or mechanism (e.g., learning loop, checkpoint).

### Block: Architecture / Structure
```markdown
## Architecture

{Describe the structural organization.}
{File locations, component relationships, data flows.}
{ASCII diagrams for relationships.}
{Table of components with purposes.}
```
**Use when:** Guide covers system structure, file organization, or component relationships.

### Block: Operations Guide
```markdown
## Working With {Domain}

{For each relevant operation:}

### {Operation Name}
**Command:** `{trigger command}`
**What it does:** {one-line description}
**When to use:** {context}
**Key steps:** {brief workflow summary}
**Example:** {concrete usage example}
```
**Use when:** Guide covers a domain with user-facing operations (issues, sprints, patterns).

### Block: Data & Files
```markdown
## Key Files

| File | Purpose | Location |
|------|---------|----------|
| {name} | {what it stores/does} | {path} |

{Explain data flow between files if relevant.}
{Explain persistence model if relevant.}
```
**Use when:** Guide needs to explain where information lives and how it moves.

### Block: Quick Reference
```markdown
## Quick Reference

{Compact lookup tables, command lists, or cheat sheets.}
{Organized for scanning, not reading.}
{Tables preferred over prose.}
```
**Use when:** Guide benefits from a scannable summary section at the end.

### Block: Integration Points
```markdown
## How {Topic} Connects to Other Systems

{Describe cross-domain relationships.}
{What calls what, what reads/writes where.}
{ASCII flow diagram if helpful.}
```
**Use when:** Guide covers something that heavily interacts with other NEXUS domains.

### Block: Tutorial / Getting Started
```markdown
## Getting Started

{Step-by-step walkthrough for a newcomer.}
{Concrete example scenario from start to finish.}
{Each step: what to do, what you'll see, what it means.}
```
**Use when:** Guide is aimed at newcomers or covers first-time setup/usage.

### Block: Glossary
```markdown
## Glossary

| Term | Definition |
|------|------------|
| {term} | {clear, concise definition in context of this guide's domain} |
```
**Use when:** Guide introduces domain-specific terminology that readers need as a quick lookup. Especially valuable for Getting Started and System Reference guides. Keep definitions concrete and NEXUS-specific.

### Block: Troubleshooting
```markdown
## Common Issues

{Organized by symptom — what the user sees, not what went wrong internally.}

### {Symptom description}
**Cause:** {what typically causes this}
**Fix:** {step-by-step resolution}
```
**Use when:** Guide covers a domain where users commonly hit problems (sprint management, maintenance, checkpoint/recovery). Organize by observable symptom, not internal cause.

### Block: Evolution / Self-Improvement
```markdown
## How {System} Evolves

{Describe the self-improvement mechanisms.}
{Feedback loops, learning pipelines, adaptation.}
{How the system gets better over time.}
```
**Use when:** Guide covers maintenance, evolution, or adaptive features.

---

## Composition Guidance

**Manual-Edit preservation**: a guide section that a human has hand-edited and wants kept across regenerations is tagged `[Section: Manual-Edit]` … `[/Section: Manual-Edit]` (in place of, or wrapping, its normal `[Section: Name]` markers). `/nexus-guide-creator` Regenerate mode (STEP 1B / STEP 3) preserves every such block unchanged and regenerates the rest. Untagged sections are always regenerated.

The guide-creator LLM should select blocks based on guide type:

| Guide Type | Typical Blocks |
|-----------|----------------|
| Getting Started | Introduction, Tutorial, Core Concepts, Glossary, Quick Reference |
| Domain Guide | Introduction, Core Concepts, How It Works, Operations Guide, Data & Files, Troubleshooting (optional), Quick Reference |
| System Reference | Introduction, Architecture, Data & Files, Integration Points, Glossary (optional), Quick Reference |
| Process Guide | Introduction, How It Works, Core Concepts, Integration Points, Quick Reference |
| Tool Guide | Introduction, Core Concepts, How It Works, Operations Guide, Quick Reference |

### Target Guide Set Mapping

| Guide | Type | Suggested Blocks |
|-------|------|-----------------|
| quick-start-guide | Getting Started | Introduction, Tutorial, Core Concepts, Glossary, Quick Reference |
| infrastructure-setup-guide | Getting Started | Introduction, Core Concepts, Architecture, Tutorial, Glossary, Quick Reference |
| issue-lifecycle-guide | Domain Guide | Introduction, Core Concepts, How It Works, Operations Guide, Data & Files, Troubleshooting (optional), Quick Reference |
| sprint-management-guide | Domain Guide | Introduction, Core Concepts, How It Works, Operations Guide, Data & Files, Troubleshooting (optional), Quick Reference |
| pattern-system-guide | Domain Guide | Introduction, Core Concepts, How It Works, Operations Guide, Quick Reference |
| project-management-guide | Domain Guide | Introduction, Core Concepts, Operations Guide, Quick Reference |
| maintenance-and-evolution-guide | Process Guide | Introduction, How It Works, Evolution, Operations Guide, Integration Points, Quick Reference |
| system-architecture-guide | System Reference | Introduction, Architecture, Data & Files, Integration Points, Glossary (optional), Quick Reference |
| data-and-persistence-guide | System Reference | Introduction, Architecture, Data & Files, How It Works, Quick Reference |
| navigation-and-commands-guide | System Reference | Introduction, How It Works, Operations Guide, Quick Reference |
| documentation-system-guide | Domain Guide | Introduction, Core Concepts, Operations Guide, Data & Files, Quick Reference |
| cognitive-tools-guide | Tool Guide | Introduction, Core Concepts, How It Works, Operations Guide, Quick Reference |
| troubleshooting-guide | System Reference | Introduction, Troubleshooting, Integration Points, Quick Reference |
| customization-guide | System Reference | Introduction, Core Concepts, How It Works, Data & Files, Quick Reference |

---

## Quality Standards

```yaml
writing_style:
  audience: "Humans reading documentation — clear, friendly, concrete"
  tone: "Informative but approachable, not academic"
  examples: "Use concrete NEXUS examples, not abstract descriptions"
  length: "Comprehensive but not exhaustive — link to source files for deep detail"
  diagrams: "ASCII diagrams for flows and relationships — visual > prose for structure"

structural_rules:
  section_markers: "Add [Section: Name] / [/Section: Name] to all ## sections"
  no_variable_placeholders: "All content must be resolved — no {{VARIABLE}} in output"
  source_tracking: "Header lists source files with versions (enables staleness checking)"
  self_contained: "Each guide should be readable standalone without other guides"

size_guidance:
  quick_start: "~10-15KB (concise, essential)"
  domain_guide: "~25-40KB (comprehensive, covers full domain)"
  system_reference: "~20-35KB (thorough, structural)"
  process_guide: "~20-30KB (workflow-focused)"
  tool_guide: "~15-25KB (practical, usage-oriented)"
```

---

## Registry Integration

When a guide is generated, /nexus-guide-creator STEP 5B must upsert the entry in documentation-registry.yaml:

```yaml
# Key is the guide slug (e.g., quick-start-guide)
{guide-slug}:
  title: "{Guide Title}"
  filepath: ".nexus/human-guides/{filename}"
  status: active
  category: "{getting-started|domain|system-reference}"
  target_level: "{beginner|intermediate|advanced|all}"
  topics: ["{topic1}", "{topic2}", "{topic3}"]
  description: "{one-line description}"
  size_kb: {calculated}
  created: "{timestamp}"
  last_updated: "{timestamp}"
  references:
    - file: "{source_file_1}"
      version: "{version_at_generation}"
    - file: "{source_file_2}"
      version: "{version_at_generation}"
```

This enables /nexus-staleness-checker to detect when source files have been updated
beyond the versions used to generate the guide.

