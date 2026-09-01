# sprint-state.md
*Version: 1.13.0 | Date: 2026-08-28 | Sprint: 112*

<!-- Instance version: copy this header's version to instances created from this template -->
_updated: YYYY-MM-DD HH:MM
_sprint: XXX
_status: ready|in_progress|closing|complete
# _closure_time: {YYYY-MM-DD HH:MM}
# Written by /nexus-close-sprint at its final step. Absence with _status: complete
# is how /nexus-start STEP 6 detects "sprint complete but not closed" (unclosed_sprint flag).
_mode: THEMED|MIXED|DEDICATED
_title: {Human-readable sprint title/focus}
_sprint_type: normal|maintenance
# Set by organize-sprint. Used by close-sprint STEP 8D for maintenance tracking.
_project_lifecycle: not-defined
# Values: not-defined | defining | active | closed
_project_type: code
# Propagated from project-state at sprint creation by organize-sprint.
# Values: code | creative | mixed. Determines backup strategy and backup-optimization behavior.
_self_hosting: false
# true ONLY when this project IS NEXUS's own meta-project (NEXUS building NEXUS); false for every
# other project. Carried forward by organize-sprint STEP 4C "if present", and gates the
# §Architect-Pattern Activation matrix in /nexus-setup-project STEP 1E — so a wrong value here
# silently skips scope negation, handoff contracts and the workflow tree, and then propagates into
# every subsequent sprint. Must agree with project-state-template.md's twin field, which is false.
# This template shipped `true` until Sprint 112; ISS-101 step 4.2 caught it in the distributed
# tree, where two independent adopter-side sessions flagged the disagreement unprompted.
_control_level: 2
# Control level default preference: 1=Streamlined, 2=Balanced, 3=Full Control
# Active session level is set at boot (Question 0) — this is only the default.
_build_mode: none
# Build methodology mode: none (default) | full (normal Build active) | batch (batched implementation active)
# Set by Build Orient (→full) or Batch-Transition-Detection (→batch). Cleared by Build Commit Protocol (→none).
# Used by Build Orient to determine whether to load batch.md on resumption.
# Write ownership: installation→not-defined, setup-project→defining/active, close-project→closed
# Preserved by organize-sprint across sprints

[PROJECT_BRIEF]
# Condensed project context — always available in sprint-state without loading project-state.
# Populated by setup-project (STEP 7F). Preserved by organize-sprint across sprint recreations.
# Updated by update-state when phase changes.
title: "{project name}"
type: "{project type}"
domain: "{project domain}"
vision: "{1-2 sentence condensed vision — what + why + success}"
current_phase: "{Phase N: name — objective}"
constitution:
  # Non-negotiable principles from [PROJECT_CONSTITUTION]. Empty if none.
  # - "{principle}"
mvp_minimum: "{absolute minimum that would be valuable}"
active_risks:
  # High probability + High impact risks only. Empty if none.
  # - "{risk description}"
[/PROJECT_BRIEF]

[CONVERSATION]
conversation_number: 1
current_focus: planning|analysis|research|implementation|application|evaluation|maintenance|learning|brainstorm
# Lifecycle phases: planning (Conv 0, organize-sprint), learning (Conv N+1, close-sprint)
# Work phases: analysis, research, implementation, application, evaluation, maintenance
# Parallel phase: brainstorm (non-executing project-aware discussion, parallel to A/I/E lifecycle)
sprint_state_saved_at_context: 0
sprint_state_saved_at_conv: 0
# INVARIANT: sprint_state_saved_at_conv MUST equal conversation_number after every checkpoint.
# They encode one fact; /nexus-start increments the saved value, so a field that fails to bump
# produces a colliding conversation number. /nexus-checkpoint sets both (STEP 1B) and
# reconciles them at CP-3, hard-blocking on MISMATCH. Do not "simplify" one of them away.
last_checkpoint: none
checkpoint_saves: 0
last_full_write_conv: 0
[/CONVERSATION]

[BOOTSTRAP]
continue_with: |
  WHAT: {Specific next task}
  WHY: {Reason this is next}
  CONTEXT: {Key decisions, state of work}

  NEXT CONVERSATION PLAN:
  1. {First specific action}
  2. {Second specific action}
  3. {Third specific action}

  COMPLETED TODAY:
  - {Recent accomplishment}

  STATUS: {One-line current state}

files_to_load:
- {key files for resumption}
[/BOOTSTRAP]

[OBJECTIVES]
planned:
- ISS-XXX: {title} ({priority}, {complexity})
in_progress:
- ISS-XXX: {title} ({priority}, {complexity}) - A:X I:Y E:Z
completed:
- ISS-XXX: {title} - {outcome}
[/OBJECTIVES]

[DECISIONS]
made:
- {YYYY-MM-DD} Conv {N}: {decision} - {reasoning}
pending:
- {what needs deciding} - {context}
options_for_next:
- Option A: {description}
- Recommendation: {which and why}
[/DECISIONS]

[CANDIDATES_PATTERNS]
# Format: "ISS-XXX - {context} - {solution that worked}"
[/CANDIDATES_PATTERNS]

[PATTERNS_IN_USE]
# Format:
# ISS-XXX:
#   PAT-YYY: applied|helped|neutral|hindered
[/PATTERNS_IN_USE]

[FILES_MODIFIED]
# Conv {N} - {theme}
# - {filepath}: {what changed}
[/FILES_MODIFIED]

[DISCOVERIES]
issues_found:
- Conv {N}: {issue description}
insights:
- Conv {N}: {learning or realization}
innovations:
- Conv {N}: {new approach or method}
[/DISCOVERIES]

[EXPERIENCE_CAPTURE]
[SYSTEM_ISSUES]
# Types: violation | gap | bug | anti-pattern | improvement-needed | improvement-mentioned
# Format: "- {type}: {description}"
[/SYSTEM_ISSUES]

[BEHAVIORAL_INSIGHTS]
# Types: preference | correction | character-moment | insight
# Format: "- {type}: {description}"
[/BEHAVIORAL_INSIGHTS]
[/EXPERIENCE_CAPTURE]

[MOMENTUM]
discussion_thread: {Current topic/focus}
awaiting_decision: {Open question or "none"}
energy_level: high|medium|low
loop_history: []
[/MOMENTUM]

[CONVERSATION_HISTORY]
# Format: Conv {N}: {YYYY-MM-DD}, ~{XX}%, {summary}
[/CONVERSATION_HISTORY]

# ============================================================================
# OPTIONAL SECTIONS - Add when sprint complexity requires additional structure
# ============================================================================

[CRITICAL_CONTEXT]
# USE WHEN: Sprint exceeds 15 conversations, multi-stage work, or conversation
# history becomes unwieldy but context still needed.

sprint_history:
  - Started: Conv X (YYYY-MM-DD)
  - Current: Conv Y (YYYY-MM-DD)
  - Duration: N conversations over M days
  - Scope: {High-level sprint purpose}

stage_status:
  stage_1_name:
    status: COMPLETE|IN_PROGRESS|PLANNED
    conversations: Conv X-Y
    achievement: {Summary}

key_context:
  - {Important architectural decision}
  - {Critical constraint or requirement}

architectural_decisions:
  - {Decision}: {Rationale}

work_completed_summary:
  - {Major milestone}

work_remaining_summary:
  - {What's still ahead}
[/CRITICAL_CONTEXT]

[REFERENCE_FILES]
# USE WHEN: Sprint has analysis documents, design specs, external sources,
# or ad-hoc documents needed across conversations.
# Structure is flexible — use whatever keys make sense.
#
# architecture_doc: {path}
# proposal: {path}
# external_sources:
#   - {path}
# mini_plan: {path}
[/REFERENCE_FILES]
