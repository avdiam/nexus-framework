#!/bin/bash
# nexus-validate-yaml.sh — PostToolUse hook for Write|Edit
# Validates YAML syntax on registry file writes to prevent silent corruption.
# Only fires for .nexus/active/registries/*.yaml — all other paths pass silently.
# Preferred: jq (fast JSON extraction) + Python 3 + PyYAML (YAML validation — required;
# jq has no YAML support). Degrades gracefully, never silently, when a parser is missing.
# ISS-139, ISS-232 (jq hardened from hard dependency to preferred/optional)

input=$(cat)

# Resolve a Python 3 interpreter (command-name ladder: python -> python3, matching the
# house idiom in nexus-statusline-posttool.sh / nexus-context-stop-hook.sh). Explicitly
# asserts version 3 — a bare `python -c "pass"` check also accepts Python 2, and the
# PyYAML block below uses f-strings that SyntaxError under Python 2, producing a FALSE
# "Invalid YAML" block on a valid write. A false block is worse than the silent skip
# this hook exists to prevent, so this deviates from the siblings' looser check.
resolve_py3() {
  if command -v python >/dev/null 2>&1 && python -c "import sys; sys.exit(0 if sys.version_info[0]>=3 else 1)" >/dev/null 2>&1; then
    echo "python"
  elif command -v python3 >/dev/null 2>&1 && python3 -c "import sys; sys.exit(0 if sys.version_info[0]>=3 else 1)" >/dev/null 2>&1; then
    echo "python3"
  fi
}

# === Single parser-resolution block ===
# Ladder: jq (preferred — faster JSON extraction) -> python -> python3. Python 3 is
# always required later for YAML validation, so it is resolved once here and reused
# for extraction too when jq is absent, rather than re-detected further down.
PY_CMD=$(resolve_py3)
if command -v jq >/dev/null 2>&1; then
  EXTRACT="jq"
elif [[ -n "$PY_CMD" ]]; then
  EXTRACT="python"
else
  EXTRACT=""
fi

if [[ -z "$EXTRACT" ]]; then
  echo "⚠ No parser found (jq or Python 3) — YAML registry validation skipped. Install jq (jqlang.org) or Python 3 (python.org) to restore validation." >&2
  exit 0
fi

if [[ "$EXTRACT" == "jq" ]]; then
  file_path=$(echo "$input" | jq -r '.tool_input.file_path // empty')
else
  file_path=$("$PY_CMD" -c '
import json, sys
try:
    d = json.load(sys.stdin)
    print(d.get("tool_input", {}).get("file_path", "") or "")
except Exception:
    pass
' <<< "$input")
fi

# No path -> nothing to validate
if [[ -z "$file_path" ]]; then
  exit 0
fi

# Normalize Windows backslashes to forward slashes so the regex filter
# works across Claude Code CLI (Linux/macOS paths) and Cowork/Windows paths.
file_path="${file_path//\\//}"

# Only validate registry YAML files
if [[ ! "$file_path" =~ \.nexus/active/registries/.*\.yaml$ ]]; then
  exit 0
fi

# YAML validation always needs Python (jq cannot parse YAML). Already resolved above
# when extraction fell back to Python; resolve now only if jq handled extraction instead.
if [[ -z "$PY_CMD" ]]; then
  PY_CMD=$(resolve_py3)
fi

if [[ -z "$PY_CMD" ]]; then
  echo "⚠ Python 3 not found — YAML registry validation skipped for: $file_path" >&2
  exit 0
fi

# Validate YAML with PyYAML; degrade gracefully if module missing
result=$("$PY_CMD" - "$file_path" <<'PYEOF' 2>&1
import sys
try:
    import yaml
except ImportError:
    print("MISSING_PYYAML")
    sys.exit(0)
try:
    with open(sys.argv[1], "r", encoding="utf-8") as f:
        yaml.safe_load(f.read())
    sys.exit(0)
except yaml.YAMLError as e:
    print(f"YAML_ERROR: {e}")
    sys.exit(1)
except Exception as e:
    print(f"READ_ERROR: {e}")
    sys.exit(1)
PYEOF
)
status=$?

if [[ "$result" == "MISSING_PYYAML" ]]; then
  echo "⚠ PyYAML missing — run: pip install pyyaml (registry validation skipped for $file_path)" >&2
  exit 0
fi

if [[ $status -ne 0 ]]; then
  echo "❌ Invalid YAML in registry file: $file_path" >&2
  echo "$result" >&2
  echo "The write may have left the registry corrupted. Please fix the YAML syntax." >&2
  exit 2
fi

# Valid YAML — silent pass
exit 0
