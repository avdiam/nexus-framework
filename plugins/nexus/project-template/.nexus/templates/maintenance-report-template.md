# maintenance-report-template.md
*Version: 1.2.0 | Date: 2026-08-26 | Sprint: 111*

# Maintenance Report — Sprint {sprint_number}
*Date: {date} | Tier: {tier}*

## Summary

| Field | Value |
|-------|-------|
| Sprint | {sprint_number} |
| Tier | {tier} |
| Date | {date} |
| Conversations | {conversation_count} |
| Health Before | {health_before}/100 |
| Health After | {health_after}/100 |
| Improvement | {improvement} |
| Snapshot | {snapshot_type} |
| Next Predicted | {next_predicted} |

## Health Comparison

| Operation | Before | After | Delta | Status |
|-----------|--------|-------|-------|--------|
{health_comparison_rows}

## Operations Executed

{operations_detail}

## Failed/Skipped Operations

{failed_skipped_section}

## Post-Maintenance Checks

### Subsystem Verification
{subsystem_verification}

### Documentation Staleness
{documentation_staleness}

<!-- VERBATIM PLACEHOLDER — reproduce /nexus-staleness-checker's maintenance-mode summary
     EXACTLY as returned, including its terminal verdict, its bound/candidates pair, AND THE UNIT
     NAMED IN PARENTHESES — the unit is part of the figure (VC-2 item 1), and the operation counts
     a different corpus at each of its gates, so a bare number cannot say which:
       Staleness: {FILLED|ESCALATED} — {N} findings / {bound} bound / {candidates} candidates (references)
         ({checked} guides checked: {current} current, {review} review, {stale} stale, {critical} critical)
     A STEP 1 early exit returns the same shape with `(guides)`, not `(references)` — reproduce
     whichever unit the operation actually returned; do not normalise them to one word.
     A declined regeneration returns SKIP, which carries the standing verdict on its second line:
       Staleness: SKIP (justified) — regeneration declined by user
         Verdict stands: {N} findings / {bound} bound / {candidates} candidates (references)
     Do NOT summarize, round, or reword to "clean" / "no issues" / "docs are current", and do not
     drop the unit — a denominator that does not say what it counts is the defect one level up.
     `0 findings / 88 bound / 88 candidates` and `0 findings / 0 bound / 88 candidates`
     both summarize to "clean" — and telling them apart is the operation's entire purpose.
     The report is what anyone reads eight sprints later; a pair dropped here is a pair lost.
     (ISS-248 SC-08 / operation-skill-template §Verification-Class Core VC-2.) -->


## Recommendations

{recommendations}

## Rollback Information

| Field | Value |
|-------|-------|
| Regression Detected | {regression_detected} |
| Rollback Performed | {rollback_performed} |
| Last Stable Snapshot | {last_stable_snapshot} |
