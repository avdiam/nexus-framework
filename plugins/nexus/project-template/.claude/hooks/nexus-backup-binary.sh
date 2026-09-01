#!/bin/bash
# nexus-backup-binary.sh — PreToolUse hook for Write|Edit
# Auto-backs up binary/large files to .nexus/backups/ before overwrite
# ISS-232: jq hardened from hard dependency to preferred/optional (parser-priority ladder)

input=$(cat)

# Resolve parser: jq (preferred) -> python -> python3 — house idiom shared with
# nexus-statusline-posttool.sh / nexus-context-stop-hook.sh. No Python-3 assertion needed
# here (unlike nexus-validate-yaml.sh): this hook only extracts two JSON string fields,
# no f-string/PyYAML code path a Python 2 interpreter could break.
PARSER=""
PY_CMD=""
if command -v jq >/dev/null 2>&1; then
  PARSER="jq"
elif command -v python >/dev/null 2>&1 && python -c "pass" >/dev/null 2>&1; then
  PARSER="python"; PY_CMD="python"
elif command -v python3 >/dev/null 2>&1 && python3 -c "pass" >/dev/null 2>&1; then
  PARSER="python"; PY_CMD="python3"
fi

if [[ "$PARSER" == "jq" ]]; then
  tool_name=$(echo "$input" | jq -r '.tool_name // empty')
  file_path=$(echo "$input" | jq -r '.tool_input.file_path // empty')
elif [[ "$PARSER" == "python" ]]; then
  extracted=$("$PY_CMD" -c '
import json, sys
try:
    d = json.load(sys.stdin)
    print(d.get("tool_name", "") or "")
    print(d.get("tool_input", {}).get("file_path", "") or "")
except Exception:
    print("")
    print("")
' <<< "$input")
  tool_name=$(echo "$extracted" | sed -n 1p)
  file_path=$(echo "$extracted" | sed -n 2p)
else
  # No parser resolved — a broken guard must never block a write.
  echo '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"allow"}}'
  exit 0
fi

# Only process Write and Edit tools
if [[ -z "$file_path" ]]; then
  echo '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"allow"}}'
  exit 0
fi

# Binary extensions that need .nexus/backups/ management
BINARY_EXTENSIONS="docx|pptx|xlsx|pdf|jpg|jpeg|png|gif|svg|mp4|mp3|zip|tar|gz"

# Exclude .nexus/active/ (framework internals — text-only, git-managed)
# Include everything else: project files, .nexus/Sprints/, .nexus/sandbox-work/, etc.
if [[ "$file_path" == *".nexus/active/"* ]]; then
  echo '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"allow"}}'
  exit 0
fi

# Check if file has a binary extension
if [[ "$file_path" =~ \.($BINARY_EXTENSIONS)$ ]]; then
  # Only backup if file already exists (new files don't need backup)
  if [[ -f "$file_path" ]]; then
    # Create backup directory if needed
    mkdir -p .nexus/backups

    # Extract filename and extension
    filename=$(basename "$file_path")
    timestamp=$(date +%Y-%m-%d-%H%M%S)
    backup_path=".nexus/backups/${filename%.*}-${timestamp}.${filename##*.}"

    # Copy current version to backup
    cp "$file_path" "$backup_path" 2>/dev/null

    if [[ $? -eq 0 ]]; then
      # Enforce retention: keep last 5 + first version per file
      base_pattern="${filename%.*}"
      ext="${filename##*.}"

      # Count backups for this file
      backup_count=$(ls -1 .nexus/backups/${base_pattern}-*.${ext} 2>/dev/null | wc -l)

      if [[ $backup_count -gt 5 ]]; then
        # Get all backups sorted by date (oldest first), skip first (creation baseline) and last 4
        ls -1t .nexus/backups/${base_pattern}-*.${ext} 2>/dev/null | tail -n +5 | head -n -1 | while read old_backup; do
          rm -f "$old_backup"
        done
      fi
    fi
  fi
fi

# Always allow the write to proceed
echo '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"allow"}}'
