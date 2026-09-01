# Emergency-Reference.md
*Version: 2.0.2 | Date: 2026-08-20 | Sprint: 110*

*JIT-loaded on problems. Not part of bootstrap — load only when recovery is needed.*
*Called by: CLAUDE.md `## Emergency Procedures` (problem-type → section table), /nexus-checkpoint Error Recovery escalation.*

## Emergency Procedures
[Section: Emergency-Procedures]

### Prevention First

- Verify files before all write operations (Read before Edit)
- Maintain memory mantra constantly
- Update sprint-state at every checkpoint
- Git commits at checkpoints preserve recovery points

### Quick Recovery

| Problem | Recovery |
|---------|----------|
| Sprint-state corrupted | `git log --oneline -- .nexus/active/states/sprint-state.md` → find good commit → `git checkout {commit} -- {file}` → Read to verify |
| Template load fails | Check path spelling → Read with correct path → if missing, use template from `.nexus/templates/` |
| Tool operation fails | Retry once → try alternate approach (Edit→Write, Grep→Read+scan) → report to user |
| Memory mantra lost | Scan conversation for loaded files → rebuild list from tool call history |
| Context overflow | Save checkpoint immediately → continue with caution (reads over writes) |
| Registry corrupted | `git checkout {last_good_commit} -- {registry_file}` → Read to verify YAML integrity |

### Common Failure Patterns

**Edit tool fails (non-unique match):**
Causes: old_string appears multiple times, whitespace mismatch, file changed since read.
Fixes: include more surrounding context in old_string, re-Read file first, use replace_all if appropriate.

**Section not found:**
Causes: markers don't match, missing `Section:` prefix, case mismatch.
Fixes: verify `[Section: Name]` format exactly, use Grep to search for actual marker text.

**Git restore not available:**
Causes: no git repo initialized, no commits yet.
Fixes: check with `git status`. If no repo: inform user, suggest manual backup. If no commits: current file is the only version — extra caution on writes.

**YAML parse error:**
Causes: indentation, missing quotes, duplicate keys.
Fixes: restore from git, use smaller targeted Edit patches.

### Issue Severity

**Yellow (Self-Recoverable):**
File not found → verify path spelling, use Glob to list parent directory, ask user for correct path. Tool transient failure → retry per quick recovery table.

**Orange (May Need User):**
Memory mantra lost → scan conversation for all file loads, rebuild from history. Sprint-state corrupted → offer restore from git. Template unavailable → degraded mode, notify user.

**Red (Immediate Action):**
Context overflow (>80%) → save checkpoint immediately, then continue cautiously. Checkpoint save failure → retry simpler Edit operations, save critical `continue_with` to temp file, alert user. Critical file corrupted → DO NOT edit further, restore from git, Read to verify before continuing.

### Recovery Priority

```
User work > Continuity > Tracking > Documentation
```

[/Section: Emergency-Procedures]

## Degraded Mode Operations
[Section: Degraded-Mode]

When components are unavailable, continue with reduced capability rather than stopping.

| Missing Component | Action |
|-------------------|--------|
| No methodology skills | Continue with Framework + Protocols only (basic operations available, phase management works) |
| No sprint-state | Offer recovery from git or backup restore |
| No registries | Warn user, operate from memory cache, suggest git restore |
| No patterns | Continue without pattern matching — all work still possible |
| No cognitive tools | Continue with methodology only — tools available on explicit request |
| No git history | Operate without backup safety net — extra caution on writes, warn user |

**Principle**: Any degraded operation is better than no operation. Inform the user what's missing and continue.

[/Section: Degraded-Mode]

## Checkpoint Error Recovery
[Section: Checkpoint-Error-Recovery]

Detailed recovery for checkpoint save failures. [Section: Checkpoint-Protocol] contains inline retry logic (retry → full write → alert). Escalate here when inline recovery fails.

| Problem | Recovery Steps |
|---------|---------------|
| Edit fails repeatedly | 1. Try with broader old_string context. 2. If still fails, fall back to a full write — built from a verbatim disk read taken immediately before the rebuild, never from memory alone (/nexus-checkpoint STEP 1A full-write precondition, ISS-235); if that read cannot be performed, stay in patch mode. 3. Alert user with details. |
| Write fails | 1. Retry once. 2. Try writing essential sections only (METADATA + CONVERSATION + BOOTSTRAP + OBJECTIVES). 3. Alert user — partial save > no save. |
| Corruption after save | 1. `git checkout HEAD~1 -- {file}` → Read to verify restored state. 2. Retry full save. 3. If still broken, `git log` and alert user with commit list for manual recovery. |
| ISS write fails | Save sprint-state anyway. Note in `continue_with`: "⚠️ ISS write failed — verify next conv". ISS can be reconstructed from conversation; sprint-state cannot. |
| Context critical during save | Complete with minimum content, skip user validation. Any save > no save. |

**Last resort**: If all file writes fail, display the critical `continue_with` content directly in the conversation so the user can manually preserve it. Sprint continuity through any means available.

[/Section: Checkpoint-Error-Recovery]
