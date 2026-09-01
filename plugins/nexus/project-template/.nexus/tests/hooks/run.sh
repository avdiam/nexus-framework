#!/bin/bash
# NEXUS hook test harness — ISS-086 Part B.
# Feeds fixtures to each of the 6 hook scripts and asserts on STABLE behavioral
# anchors (not exact output strings). Self-contained + CI-able.
#
#   bash .nexus/tests/hooks/run.sh
#
# Exit 0 = all assertions green. Non-zero = at least one FAIL (count printed).
# SKIP (e.g. missing optional dep) does not fail the run but is reported.

set -u

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO="$(cd "$SCRIPT_DIR/../../.." && pwd)"
HOOKS="$REPO/.claude/hooks"
FIX="$SCRIPT_DIR/fixtures"
EXP="$SCRIPT_DIR/expected"
cd "$REPO" || { echo "cannot cd to repo root"; exit 1; }

PASS=0; FAIL=0; SKIP=0
anchor() { cat "$EXP/$1"; }

ok()   { echo "  ✓ PASS  $1"; PASS=$((PASS+1)); }
no()   { echo "  ✗ FAIL  $1"; echo "          $2"; FAIL=$((FAIL+1)); }
sk()   { echo "  ⚠ SKIP  $1  ($2)"; SKIP=$((SKIP+1)); }

assert_contains()     { case "$2" in *"$3"*) ok "$1";; *) no "$1" "expected to contain: $3";; esac; }
assert_not_contains() { case "$2" in *"$3"*) no "$1" "expected NOT to contain: $3";; *) ok "$1";; esac; }
assert_empty()        { if [ -z "$2" ]; then ok "$1"; else no "$1" "expected empty output, got: ${2:0:60}"; fi; }
assert_exit()         { if [ "$2" -eq "$3" ]; then ok "$1"; else no "$1" "expected exit $2, got $3"; fi; }

echo "═══ NEXUS Hook Test Harness ═══"
echo "Repo: $REPO"

# Parser presence (hooks need jq or python). If neither, behavioral hooks can't be asserted.
HAVE_PARSER=0
command -v jq >/dev/null 2>&1 && HAVE_PARSER=1
command -v python >/dev/null 2>&1 && HAVE_PARSER=1
command -v python3 >/dev/null 2>&1 && HAVE_PARSER=1

# ── Hook 1: nexus-context-stop-hook.sh (UserPromptSubmit) ──────────────────────
echo "[1] nexus-context-stop-hook.sh"
if [ "$HAVE_PARSER" -eq 1 ]; then
  ENV_PRESENT="{\"transcript_path\":\"$FIX/transcript-with-statusline.jsonl\"}"
  ENV_MISSING="{\"transcript_path\":\"$FIX/transcript-missing-statusline.jsonl\"}"
  out=$(printf '%s' "$ENV_PRESENT" | bash "$HOOKS/nexus-context-stop-hook.sh" 2>/dev/null)
  assert_contains "context tag emitted (status line present)" "$out" "$(anchor context-stop.anchor)"
  assert_not_contains "no reminder when status line present" "$out" "$(anchor status-line-missing.anchor)"
  out=$(printf '%s' "$ENV_MISSING" | bash "$HOOKS/nexus-context-stop-hook.sh" 2>/dev/null)
  assert_contains "reminder fires when status line missing" "$out" "$(anchor status-line-missing.anchor)"
else
  sk "context-stop assertions" "no jq/python parser"
fi

# ── Hook 2: nexus-statusline-posttool.sh (PostToolUse) ─────────────────────────
echo "[2] nexus-statusline-posttool.sh"
if [ "$HAVE_PARSER" -eq 1 ]; then
  out=$(printf '%s' "{\"transcript_path\":\"$FIX/transcript-with-statusline.jsonl\"}" | bash "$HOOKS/nexus-statusline-posttool.sh" 2>/dev/null)
  assert_empty "silent when status line present" "$out"
  out=$(printf '%s' "{\"transcript_path\":\"$FIX/transcript-missing-statusline.jsonl\"}" | bash "$HOOKS/nexus-statusline-posttool.sh" 2>/dev/null)
  assert_contains "reminder fires when status line missing" "$out" "$(anchor status-line-missing.anchor)"
else
  sk "statusline-posttool assertions" "no jq/python parser"
fi

# ── Hook 3: nexus-statusline.sh (statusLine renderer) ──────────────────────────
echo "[3] nexus-statusline.sh"
out=$(cat "$FIX/statusline-input.json" | bash "$HOOKS/nexus-statusline.sh" 2>/dev/null)
assert_contains "renders sprint anchor"       "$out" "$(anchor statusline.anchor)"
assert_contains "renders window/percent (1M)" "$out" "/1M"

# ── Hook 4: nexus-compact-recovery.sh (SessionStart) ───────────────────────────
echo "[4] nexus-compact-recovery.sh"
out=$(printf '%s' '{}' | bash "$HOOKS/nexus-compact-recovery.sh" 2>/dev/null)
assert_contains "emits re-boot instruction" "$out" "$(anchor compact-recovery.anchor)"

# ── Hook 5: nexus-validate-yaml.sh (PostToolUse Write|Edit) ────────────────────
echo "[5] nexus-validate-yaml.sh"
# 5a — non-registry path passes silently (exit 0)
out=$(cat "$FIX/validate-yaml-nonregistry.json" | bash "$HOOKS/nexus-validate-yaml.sh" 2>/dev/null); rc=$?
assert_exit "non-registry path passes (exit 0)" 0 "$rc"
# Build a temp tree whose path matches the registry regex, without touching real registries.
TMPD="$(mktemp -d)"
mkdir -p "$TMPD/.nexus/active/registries"
cp "$FIX/valid-registry.yaml"   "$TMPD/.nexus/active/registries/good.yaml"
cp "$FIX/invalid-registry.yaml" "$TMPD/.nexus/active/registries/bad.yaml"
# 5b — valid registry yaml → exit 0
printf '{"tool_input":{"file_path":"%s"}}' "$TMPD/.nexus/active/registries/good.yaml" \
  | bash "$HOOKS/nexus-validate-yaml.sh" >/dev/null 2>&1; rc=$?
assert_exit "valid registry yaml passes (exit 0)" 0 "$rc"
# 5c — invalid registry yaml. Since ISS-232 (Sprint 107), jq is a PREFERRED-not-hard
# dependency for path extraction (ladder: jq -> python -> python3, Python-3-asserted).
# jq itself still cannot validate YAML at all — that half of the contract was always
# Python-3 + PyYAML only, unaffected by ISS-232. So the hook is FAIL-OPEN (exit 0) only
# when EITHER no parser resolves for extraction at all, OR Python 3 + PyYAML aren't
# available for the validation step itself — NOT merely because jq is absent.
# Replicate the hook's dep resolution so the test asserts the real contract branch in
# every environment, not an idealized one.
# (ISS-086 Validate fix, superseded by ISS-232 Validate fix: the branch previously
#  treated "jq absent" as unconditionally fail-open; ISS-232 made jq optional, so that
#  premise is now false — corrected here rather than left to silently mask the fix.)
HOOK_HAS_JQ=0
command -v jq >/dev/null 2>&1 && HOOK_HAS_JQ=1
HOOK_PY=""
if   command -v python  >/dev/null 2>&1 && python  -c "import sys; sys.exit(0 if sys.version_info[0]>=3 else 1)" >/dev/null 2>&1; then HOOK_PY="python"
elif command -v python3 >/dev/null 2>&1 && python3 -c "import sys; sys.exit(0 if sys.version_info[0]>=3 else 1)" >/dev/null 2>&1; then HOOK_PY="python3"; fi
HOOK_HAS_EXTRACTOR=0
{ [ "$HOOK_HAS_JQ" -eq 1 ] || [ -n "$HOOK_PY" ]; } && HOOK_HAS_EXTRACTOR=1
HOOK_HAS_YAML=0
[ -n "$HOOK_PY" ] && "$HOOK_PY" -c "import yaml" >/dev/null 2>&1 && HOOK_HAS_YAML=1
err=$(printf '{"tool_input":{"file_path":"%s"}}' "$TMPD/.nexus/active/registries/bad.yaml" \
      | bash "$HOOKS/nexus-validate-yaml.sh" 2>&1 >/dev/null); rc=$?
if [ "$HOOK_HAS_EXTRACTOR" -eq 1 ] && [ -n "$HOOK_PY" ] && [ "$HOOK_HAS_YAML" -eq 1 ]; then
  # A parser can extract the path (jq OR Python 3) AND Python 3 + PyYAML are available
  # for validation itself → registry validation ACTIVE → must BLOCK corrupt YAML.
  assert_exit     "invalid registry yaml blocks (exit 2)" 2 "$rc"
  assert_contains "invalid registry yaml reports error"   "$err" "$(anchor validate-yaml-invalid.anchor)"
else
  # No parser resolves at all, OR Python 3 + PyYAML (required for the YAML check itself,
  # regardless of jq) are unavailable → hook is FAIL-OPEN by contract → must NOT block.
  assert_exit "degrades gracefully when no full validation path is available (exit 0, fail-open)" 0 "$rc"
  if   [ "$HOOK_HAS_EXTRACTOR" -eq 0 ]; then miss="jq AND Python — hook cannot parse tool input at all"
  elif [ -z "$HOOK_PY" ];                 then miss="Python 3 (only Python 2 or none found) — needed for YAML validation regardless of jq"
  else                                         miss="PyYAML for interpreter '$HOOK_PY'"
  fi
  echo "  ⚠ ADVISORY: registry YAML validation is INACTIVE — missing: $miss."
  echo "             Corrupt registry writes would NOT be blocked on this machine (hook fails open)."
  echo "             jq is OPTIONAL since ISS-232 (Sprint 107) — Python 3 + PyYAML is the only hard requirement."
fi
rm -rf "$TMPD"

# ── Hook 6: nexus-backup-binary.sh (PreToolUse Write|Edit) ─────────────────────
echo "[6] nexus-backup-binary.sh"
out=$(cat "$FIX/backup-input.json" | bash "$HOOKS/nexus-backup-binary.sh" 2>/dev/null)
assert_contains "returns allow decision" "$out" "$(anchor backup-binary.anchor)"

# ── Summary ────────────────────────────────────────────────────────────────────
echo "───────────────────────────────"
echo "PASS=$PASS  FAIL=$FAIL  SKIP=$SKIP"
[ "$FAIL" -eq 0 ] && { echo "✅ ALL GREEN"; exit 0; } || { echo "❌ FAILURES PRESENT"; exit 1; }
