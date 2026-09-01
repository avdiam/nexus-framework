#!/usr/bin/env bash
# filter-patterns.sh | Version: 1.1.0 | Sprint: 111 | ISS-220, ISS-248
#
# Emits the phase-eligible subset of patterns-registry.yaml for /nexus-match-pattern
# STEP 0 scoring. Cuts the dominant load cost (description + use_when are ~67% of the
# registry and scale with row count) by dropping patterns that cannot apply this phase.
#
# Usage:  filter-patterns.sh <phase> [registry_path]
#   <phase>         analysis | implementation | evaluation | research | "" (all-mode)
#   [registry_path] defaults to .nexus/active/registries/patterns-registry.yaml
#                   (run from project root, or pass an explicit path)
#
# Inclusion (hard load-time gate, FAIL-OPEN):
#   A PAT block is emitted iff its phase_affinity contains the given phase or "all",
#   OR phase_affinity is missing/empty (fail-open — never silently drop on a data gap),
#   OR no phase argument was given (all-mode).
#
# Projection: drops the .file and .last_used lines (never read by scoring;
#   file path is re-derived as patterns/PAT-XXX.md in match-pattern STEP 4).
#
# Output: a valid, compact subset of the registry on stdout (preamble preserved),
#   preceded by a scan-evidence comment line carrying the phase-gate denominator:
#     # nexus-filter: phase={phase} total={N} scored={N} excluded={N}
#   The gate is a HARD load-time filter — excluded patterns are never scored, and
#   "not scored" is invisible in a result that only lists matches. match-pattern
#   STEP 3 reports these counts so a pattern dropped by a mis-tagged phase_affinity
#   is distinguishable from one that scored below the governance floor. (ISS-248 SC-07)
set -euo pipefail
phase="${1:-}"
registry="${2:-.nexus/active/registries/patterns-registry.yaml}"

awk -v phase="$phase" '
  BEGIN { allmode = (phase == "") ? 1 : 0; inblock = 0; total = 0; scored = 0 }

  function flush() {
    if (inblock) {
      if (!haspa)  include = 1          # fail-open: missing phase_affinity
      if (allmode) include = 1          # all-mode: no phase filter
      if (include) { scored++; buf_out = buf_out buf }
    }
  }

  /^# --- PAT-/ { flush(); inblock = 1; total++; include = 0; haspa = 0; buf = $0 ORS; next }

  inblock == 0 { pre = pre $0 ORS; next }   # preamble (meta.*, comments) — buffered, emitted after the counts

  {
    if ($0 ~ /\.file:/)      next       # drop projected fields
    if ($0 ~ /\.last_used:/) next
    buf = buf $0 ORS
    if ($0 ~ /\.phase_affinity:/) {
      haspa = 1
      if ($0 ~ /phase_affinity:[ \t]*\[\][ \t]*$/) include = 1                 # empty [] -> fail-open
      else if ($0 ~ /"all"/ || index($0, "\"" phase "\"") > 0) include = 1     # "all" or this phase
    }
  }

  END {
    flush()
    printf "# nexus-filter: phase=%s total=%d scored=%d excluded=%d\n", \
           (allmode ? "(all)" : phase), total, scored, total - scored
    printf "%s", pre
    printf "%s", buf_out
  }
' "$registry"
