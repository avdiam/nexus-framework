---
name: nexus-guide-creator
description: Create or regenerate documentation guides for NEXUS components
disable-model-invocation: true
---
*Version: 2.2.1 | Date: 2026-08-20 | Sprint: 110*

# Guide Creator

**Flow**: Load context → Discover sources → Introspect files → [T2: approve structure] → Generate guide → Write file → Update documentation-registry → Report

Create or regenerate documentation guides from system file introspection. Uses NEXUS-Architecture.md for source discovery and human-guide-template.md for quality standards.

---

### STEP 0: Load Context

Load: `.nexus/templates/human-guide-template.md` (block selection + composition + quality standards), `.nexus/active/registries/documentation-registry.yaml` (existing-guide check + metadata), `.nexus/active/registries/changelog-registry.yaml` (current source versions for guide header), `.nexus/active/NEXUS-Architecture.md#[Section: System-Overview]` (domain stats, used in STEP 1C).

### STEP 1: Identify Guide and Mode

**A. Determine which guide.** Match the user's request against documentation-registry.yaml. If known, use its metadata. If unknown, collect from user: title, category (getting-started / domain / system-reference), target_level (beginner / intermediate / advanced / all), topics, one-line description.

**B. Determine mode.** Guide doesn't exist → **Create** (full generation). Guide exists + user said "create" → inform exists, offer regenerate or overwrite. Guide exists + user said "regenerate" / "update" → **Regenerate** (preserve `[Section: Manual-Edit]` sections unchanged, regenerate rest).

**C. Identify source files.** Use NEXUS-Architecture.md as the primary source for discovering which files to introspect:

| Guide scope | NEXUS-Architecture.md section |
|-------------|------------------------|
| Domain-specific | `#[Section: Domain-{Name}]` |
| Cross-cutting | `#[Section: Cross-Cutting]` + `#[Section: Flows]` |
| Multi-domain | Relevant `#[Section: Domain-{Name}]` sections |
| Full system | `#[Section: System-Overview]` (already loaded) |

Extract domain core files, cross-domain boundaries, governing templates. If NEXUS-Architecture.md is unavailable, fall back to convention-based discovery: domain skills (e.g., issue-lifecycle → `.claude/skills/nexus-*-issue/SKILL.md`) + governing spec/template files + methodology skills. For cross-cutting guides, include state files and registries. For custom guides, propose source files based on stated scope.

Propose discovered source list with versions from changelog-registry, then wait for approval. **[T2: Balanced+Full ask | Streamlined: auto-proceed if sources look complete, notify]**

### STEP 2: Introspect Source Files

In regenerate mode, load existing guide first to identify manual-edit sections and what needs updating. Then load each source file (section-based where possible). For each, extract: purpose, key concepts, workflows, commands, examples. Note current versions for the guide header.

Use NEXUS-Architecture.md relationship data to describe file interconnections rather than reverse-engineering from individual files.

If loading all sources would exceed context budget, offer section-by-section generation: compose one or two blocks at a time, writing each to disk before loading the next batch.

### STEP 3: Compose Guide

Select blocks from human-guide-template.md Target Guide Set Mapping based on guide type — not every guide uses every block. Write content from introspected sources: clear, friendly, concrete; real NEXUS commands and workflows as examples; ASCII diagrams where they clarify structure. Assemble with required header (title, version, category, description, source files with versions) and `[Section: Name]` / `[/Section: Name]` markers on all `##` sections. Guide must be self-contained. Quality-check against human-guide-template.md standards: concrete + NEXUS-specific, no unresolved placeholders, source versions tracked, appropriate size.

**Regenerate mode**: Load existing guide first. Preserve `[Section: Manual-Edit]` sections unchanged. Regenerate all others. Merge and update header with new source versions.

### STEP 4: Review with User

Present the guide for review before writing. For smaller guides (<15KB), show full content. For larger, show table of contents plus first section with option to expand.

```
═══ 📄 GENERATED GUIDE PREVIEW ═══
Title: {title}
Type: {category}
Size: ~{kb}KB
Blocks: {block list}
Sources: {count} files referenced
{content or summary}
═══════════════════════════════════
[1=Write to disk | 2=Show full | 3=Edit section | 4=Regenerate with changes | 5=Deliver as artifact | 6=Cancel]
```

If user requests edits, adjust and return to preview.

### STEP 5: Write and Register

**A. Write guide** to `.nexus/human-guides/{guide-filename}.md`. Verify after writing.

**B. UPDATE `.nexus/active/registries/documentation-registry.yaml`** — upsert the guide entry with current metadata. For new guides, append after the last entry. For existing guides, Edit with enough unique context (e.g., `{guide-id}:\n  title:`):

```yaml
{guide-id}:
  title: "{title}"
  filepath: ".nexus/human-guides/{filename}"
  status: active
  category: {category}
  target_level: {level}
  topics: [{topic list}]
  description: "{one-line}"
  size_kb: {calculated}
  created: "{date}"          # new guide only
  last_updated: "{date}"
  references:
    - file: "{source_file}"
      version: "{version}"
```

The `references` array enables staleness-checker to detect when sources have changed.

**C. Verify** registry update applied correctly, then report:

```
✅ Guide Written: {title}
Location: {filepath} ({kb}KB)
Sources: {count} files referenced | Registry: {created|updated}
Next: "browse docs" to view | "create guide" for another | "staleness check" to verify
```

---

## Error Recovery

| Problem | Recovery |
|---|---|
| Source file fails to load | Skip that source. Note gap in guide. Continue with remaining. |
| Guide write fails | Retry. If retry fails, offer as artifact instead. |
| Registry update fails | Warn. Guide file exists — suggest "registry cleanup" to sync. |
| NEXUS-Architecture.md unavailable | Fall back to convention-based source discovery. |
| Context budget exceeded during introspection | Offer section-by-section generation. |
