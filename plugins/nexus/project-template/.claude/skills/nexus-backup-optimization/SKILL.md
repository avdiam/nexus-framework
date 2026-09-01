---
name: nexus-backup-optimization
description: Assess and optimize backup storage health — environment and project-type aware
disable-model-invocation: true
---
*Version: 3.2.1 | Date: 2026-06-15 | Sprint: 104*

# Backup Optimization

**Flow**: Detect track → Mode selection → Discovery → Analysis → Retention → [Scan boundary] → Present → [T2: approve] → Cleanup → Report

Project-type aware backup lifecycle management for Claude Code. Classifies backups by content significance (not just age), preserves milestones and critical coverage, recommends cleanup with safety validation.

**Two execution tracks** based on project type:

| Track | When | Backup Source | Tools |
|---|---|---|---|
| **Git** | Claude Code, code-only files | Git commits | Lightweight health check only — score always 100 |
| **Binary** | Claude Code, binary deliverables | `.nexus/backups/` | Glob, Read, Bash |

Claude Code on Creative or Mixed projects uses **hybrid strategy**: Git for text/code + Binary track for deliverables (.docx, .pptx, .jpg, .pdf, etc.). Both tracks contribute to the health score.

**Binary files** requiring `.nexus/backups/` management: the binary extension set defined in CLAUDE.md [Section: File-Operations-Protocol] Modification Workflow step 3 (`BINARY_EXTENSIONS`). Location: outside `.nexus/` framework folder, INCLUDING `Sprints/XXX/` output folders. Backup trigger (per CLAUDE.md [Section: File-Operations-Protocol]): before editing or overwriting a binary deliverable, copy current version to `.nexus/backups/{filename}-{YYYY-MM-DD-HHMMSS}.{ext}`. `.nexus/backups/` must be in `.gitignore`.

---

### STEP 0: Detect Track + Mode Selection

**A — Detect project type.** From sprint-state `_project_type` (or project-state fallback): code / creative / mixed (default code).

| Project Type | Active Tracks |
|---|---|
| Code | Git track only (score = 100) |
| Creative or Mixed | Git track + Binary track |

If Git track only: display "✅ Code project — git handles backups. Score: 100/100." → skip to STEP 6 (report). Operation is effectively a no-op for code projects.

**B — Mode selection.** **[T3: Full ask | Balanced: notify | Streamlined: auto-select Quick]**

Present via AskUserQuestion: **Quick** (automated smart cleanup — 7-day focus, critical files only) / **Detailed** (full review — all backups analyzed, user controls every decision) / **File-specific** (single file backup history and cleanup, prompt for filepath).

> **Mental note**: Track: {Git/Binary/Hybrid}. Mode: {Quick/Detailed/File-specific}. Project type: {type}. If checkpoint → save track + mode.

---

### STEP 1: Discovery

**A — Inventory.**

- **Binary**: `Glob('.nexus/backups/*')` + parse filenames for original/timestamp/extension. Total size: `Bash du -sh .nexus/backups/`.
- **Hybrid**: Run both Git status check + Binary inventory.

If zero backups: display health status, inform no cleanup needed for that track.

**B — Sampling strategy** (token-cost management):

| Mode | Sample |
|------|--------|
| Quick | Recent 7 days + 10% random older. Critical files only. |
| Detailed | < 20 backups: all. 20–100: 7 days + 20% older. > 100: 7 days + 15% older. |
| File-specific | All backups for the target file. |

**Critical files** (Binary track): all tracked deliverables (any file with a backup in `.nexus/backups/`).

---

### STEP 2: Content Analysis

**Binary track**: Binary files can't be meaningfully diffed. Classify by size change, timestamp gap, version count.

**A — Change classification**:

| Class | Detection |
|---|---|
| Major | > 50% size change OR > 14 days between versions |
| Moderate | 10-50% size change OR 7-14 days |
| Minor | < 10% size change AND < 7 days |

**B — Milestone detection.** Flag as milestone: first version, or dramatic size change (new major version of deliverable). Milestones are auto-preserved.

**C — Integrity check** (critical files only). Binary: file exists + size > 0. Corruption: zero-byte files.

> **Mental note**: Analysis done. {total} analyzed, {milestones} milestones, {corrupt} integrity issues. If checkpoint → save analysis results.

---

### STEP 3: Retention Decision

**Always preserve** (filter out before building cleanup candidates):
- All backups < 7 days old
- Milestone backups (from STEP 2B)
- The only backup of any file
- All backups if a critical file has ≤ 2 total
- The most recent backup per file
- The first backup per file (creation baseline)
- Error recovery checkpoints

**Cleanup tiers** (in order, applied only to non-preserved):

| Tier | Candidates | Risk |
|------|-----------|------|
| High priority | Corrupted, zero-byte, duplicates (same size + timestamp within 1 hour) | None — safe |
| Medium priority | Minor changes > 14 days old. Files with > 5 backups/day (keep first, last, largest). > 5 versions per file (keep first, last, milestones). | Low |
| Low priority | Moderate changes > 30 days old where newer milestone exists | Medium |

**Binary-specific retention**: Keep last 5 versions per file + first version + milestones. When a new version is created and count exceeds 5, delete the oldest non-milestone, non-first version.

Conservative by default — when uncertain, preserve.

---

### STEP 4: Initial Score Assessment
<!-- SCAN BOUNDARY — Agent contract stops here in Mode B -->

Calculate health score BEFORE any cleanup.

**Health formula**:
- **Coverage** (50%): Do all critical/tracked files have minimum backup count? (≥2 Binary)
- **Integrity** (30%): % of backups that passed integrity check
- **Storage** (20%): Total backup size reasonable (warn if > 100MB)

`Score = (coverage_pct × 0.5) + (integrity_pct × 0.3) + (storage_pct × 0.2)`, scale 0-100.

**Git-only (code project)**: Score = 100 (no assessment).

**Persist to system-state** `[Health-Operations]` backup_optimization:

```yaml
backup_optimization:
  score: {initial_score}
  last_run_sprint: {current_sprint}
```

Display: `📊 Initial Assessment: {initial_score}/100 (pre-cleanup baseline)`

**When run as scan agent (Mode B)**: Write initial_score to system-state (allowed — own health score field). Return structured results and stop here. Do not proceed to STEP 5. Agents must NOT write to project data.

```
## Backup Optimization Scan Results
### Initial Score: {initial_score}/100
### Track: {Git / Binary / Hybrid}
### Findings ({total_count})
#### High Priority ({count})
- {filepath}: {reason} — proposed action: {action}
#### Medium Priority ({count})
- {filepath}: {reason} — proposed action: {action}
#### Low Priority ({count})
- {filepath}: {reason} — proposed action: {action}
### Milestones Preserved: {count}
### Files Examined: {count}
### Storage: {current_size}
```

> **Mental note**: Scan complete. Score: {initial_score}/100. Track: {track}. {candidates} cleanup candidates. Scan boundary reached.

---

### STEP 5: Present Recommendations

**[T2: Balanced+Full ask | Streamlined: auto-approve High priority, notify+log]**

Display present-format per mode. Header always shows: track, backup count, milestones preserved, cleanup candidates grouped by tier with reason and size, projected storage impact.

- **Quick mode**: terse summary + `Proceed with cleanup? [Y/n/details]`
- **Detailed mode**: full ecosystem health report (track, total backups + size, critical file coverage, milestone list, cleanup tiers) + `[Review & select | Accept all | Cancel]`
- **File-specific mode**: file's backup history chronological with classification, milestone/candidate flags

**Mode B note**: If findings came from scan agents, read each file you need to access before applying cleanup actions.

---

### STEP 6: Execute Cleanup

**A — Pre-execution safety check.** Before any deletion: verify no preservation rules violated, spot-check 3 critical file backups accessible. If safety check fails: abort, display violation, offer adjusted list.

**B — Process deletions.** Binary: `Bash rm "{backupPath}"`. Track each removal (filepath, backup path, size, reason). On failure: skip, log, continue. In Detailed mode: pause every 5 removals for user confirmation.

**C — Post-execution validation.** Verify preserved backups still accessible (spot-check 3). If issues: alert user immediately. After all cleanup: re-run Glob to confirm deletions.

> **Mental note**: Cleanup done. Removed: {count} ({saved_mb}MB freed). Preserved: {count}. If checkpoint → save results.

---

### End-of-Workflow Checklist

⛔ GATE: All must pass before displaying report.

```
- [ ] All approved cleanup actions executed and verified
- [ ] Preserved backups still accessible (spot-check passed)
- [ ] system-state [Health-Operations] backup_optimization updated with final score
- [ ] system-state update verified by reading back
- [ ] Initial score captured (for Maintain degradation tracking)
```

---

### STEP 7: Report and Update Health

**A — Calculate final health score** using post-cleanup state (same formula as STEP 4).

**B — Update system-state** `[Health-Operations]` backup_optimization with final score and current_sprint. Verify by reading back.

**C — Display report**:

```
✅ BACKUP OPTIMIZATION COMPLETE
════════════════════════════════════════
Track: {Git / Binary / Hybrid}
Backups removed: {count} ({saved_mb}MB freed)
Backups preserved: {count} (including {milestone_count} milestones)

Health: {score}/100 ({status})
• Initial: {initial_score} → Final: {final_score} (delta: {+/-change})
• Coverage: {detail}
• Integrity: {detail}
• Storage: {detail}

{if recommendations}: 💡 {suggestion}
════════════════════════════════════════
```

**[T3: Full ask | Balanced: notify | Streamlined: auto-save if cleanup performed]**

**D — Report export.** Offer to save to `.nexus/Maintenance-cycles/{sprint}/backup-optimization-report.md`.

> **Mental note**: Backup optimization complete. Score: {score}/100 (delta: {change}). Track: {track}. Operation complete.

---

## Error Recovery

| Problem | Recovery |
|---------|----------|
| Glob fails (Binary) | Check if `.nexus/backups/` exists. Create if missing. |
| Binary file can't be read for integrity | Flag as potentially corrupted. Preserve unless zero-byte. |
| Deletion fails | Skip, log error, continue. Report at end. |
| Pre-execution safety fails | Abort cleanup. Show violation. Offer adjusted list. |
| Post-execution issue | Alert user. Advise re-creating backup from current if file unchanged. |
| `.nexus/backups/` doesn't exist | Create it. Add to `.gitignore` if not already there. |
| Git track for code project | Score = 100, no assessment needed. Skip to report. |
