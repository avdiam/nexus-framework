#!/bin/bash
# PostToolUse hook — emits the [context: ...] tag on tool-driven turns
# (ISS-221 token-telemetry feed — keeps zone-monitoring accurate on widget/skill
# turns that the UserPromptSubmit hook structurally cannot reach).
#
# Output (stdout becomes additionalContext for the next assistant turn):
#   [context: N tokens]   (when usage data available)
#
# Silent (exit 0, no stdout) when transcript inaccessible, parser missing,
# or no usage data in last assistant message.
#
# Parser priority: jq > python > python3 (same as UserPromptSubmit hook).

TMPFILE=$(mktemp)
cat > "$TMPFILE"


# === Detect available parser ===
PARSER=""
PY_CMD=""
if command -v jq &>/dev/null; then
  PARSER="jq"
elif command -v python &>/dev/null && python -c "pass" 2>/dev/null; then
  PARSER="python"; PY_CMD="python"
elif command -v python3 &>/dev/null && python3 -c "pass" 2>/dev/null; then
  PARSER="python"; PY_CMD="python3"
fi

if [[ -z "$PARSER" ]]; then
  rm -f "$TMPFILE"
  exit 0
fi

# === Extract transcript_path from PostToolUse stdin envelope ===
RAW_TRANSCRIPT=""
if [[ "$PARSER" == "jq" ]]; then
  RAW_TRANSCRIPT=$(jq -r '.transcript_path // empty' "$TMPFILE" 2>/dev/null)
else
  RAW_TRANSCRIPT=$($PY_CMD -c "
import json, sys
try:
    d = json.load(open(sys.argv[1]))
    print(d.get('transcript_path', ''))
except Exception:
    pass
" "$TMPFILE" 2>/dev/null)
fi

rm -f "$TMPFILE"

if [[ -z "$RAW_TRANSCRIPT" ]]; then
  exit 0
fi

# === Resolve path to accessible file (Windows MSYS / Cowork mount fallbacks) ===
BASH_PATH=""
[[ -f "$RAW_TRANSCRIPT" ]] && BASH_PATH="$RAW_TRANSCRIPT"

if [[ -z "$BASH_PATH" && "$RAW_TRANSCRIPT" =~ ^([A-Za-z]):\\ ]]; then
  drive="${BASH_REMATCH[1]}"
  drive="${drive,,}"
  MSYS_PATH="/${drive}${RAW_TRANSCRIPT:2}"
  MSYS_PATH="${MSYS_PATH//\\//}"
  [[ -f "$MSYS_PATH" ]] && BASH_PATH="$MSYS_PATH"
fi

if [[ -z "$BASH_PATH" && -d "/sessions" ]]; then
  FILENAME="${RAW_TRANSCRIPT##*\\}"
  FILENAME="${FILENAME##*/}"
  if [[ -n "$FILENAME" ]]; then
    FOUND=$(find /sessions -path "*/mnt/.claude/projects/*" -name "$FILENAME" -type f 2>/dev/null | head -1)
    [[ -f "$FOUND" ]] && BASH_PATH="$FOUND"
  fi
fi

[[ -z "$BASH_PATH" ]] && exit 0

# === ISS-221: Emit the [context:] token tag on tool-driven turns ===
# The model-facing tag is otherwise produced ONLY by the UserPromptSubmit hook
# (nexus-context-stop-hook.sh / a2), which fires only on free-text user messages.
# Boot, AskUserQuestion widgets, and skill cascades run tool-driven turns that a2
# structurally cannot reach, so the model's status line shows '—' and its 70%/80%
# zone-monitoring goes blind. This PostToolUse hook (matcher ".*") fires after every
# tool call — including AskUserQuestion — so emitting the tag here closes the gap.
# Token-read + denominator + display blocks are grafted verbatim from the a2 hook
# (single source of truth for the display contract). The TOTAL=0 guard mirrors a2:
# no usage data -> emit nothing rather than a bogus 0K tag.
TOTAL=0
if [[ "$PARSER" == "jq" ]]; then
  TOTAL=$(tail -50 "$BASH_PATH" | \
    jq -s '[.[] | select(.type=="assistant" and .isSidechain!=true and .message.usage.input_tokens!=null)
            | .message.usage | (.input_tokens//0)+(.cache_read_input_tokens//0)+(.cache_creation_input_tokens//0)]
           | last // 0' 2>/dev/null)
else
  TOTAL=$($PY_CMD -c "
import json, sys, collections
last = 0
with open(sys.argv[1], encoding='utf-8') as f:
    for line in collections.deque(f, maxlen=50):
        try:
            e = json.loads(line)
            if e.get('type') == 'assistant' and not e.get('isSidechain'):
                u = e.get('message', {}).get('usage', {})
                t = (u.get('input_tokens', 0)
                     + u.get('cache_read_input_tokens', 0)
                     + u.get('cache_creation_input_tokens', 0))
                if t > 0:
                    last = t
        except Exception:
            pass
print(last)
" "$BASH_PATH" 2>/dev/null)
fi

TOTAL=${TOTAL:-0}
if [[ "$TOTAL" -gt 0 ]]; then
  SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd 2>/dev/null)" || SCRIPT_DIR=""
  PROJECT_ROOT=""
  [[ -n "$SCRIPT_DIR" ]] && PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd 2>/dev/null)" || true

  WINDOW=200000
  if [[ -n "$PROJECT_ROOT" && -f "${PROJECT_ROOT}/.nexus/.context-window" ]]; then
    W=$(tr -cd '0-9' < "${PROJECT_ROOT}/.nexus/.context-window" 2>/dev/null)
    [[ -n "$W" && "$W" -gt 0 ]] && WINDOW="$W"
  fi

  USED_K=$((TOTAL / 1000))
  WINDOW_LABEL=$( [ "$WINDOW" -ge 1000000 ] && echo "1M" || echo "$((WINDOW / 1000))K" )
  PCT=$((TOTAL * 100 / WINDOW))
  [[ "$PCT" -gt 100 ]] && PCT=100

  FILLED=$((PCT / 10)); EMPTY=$((10 - FILLED))
  BAR=""
  for ((i=0; i<FILLED; i++)); do BAR="${BAR}■"; done
  for ((i=0; i<EMPTY; i++)); do BAR="${BAR}□"; done

  TAG="[context: ${USED_K}K/${WINDOW_LABEL} | ${PCT}% | ${BAR}]"
  if [[ "$PCT" -ge 80 ]]; then
    REMINDER=" 🔴 RED ZONE — invoke /nexus-checkpoint immediately"
  elif [[ "$PCT" -ge 70 ]]; then
    REMINDER=" ⚠ Yellow zone — checkpoint recommended"
  else
    REMINDER=""
  fi
  printf '{"hookSpecificOutput":{"hookEventName":"PostToolUse","additionalContext":"%s%s"}}' "$TAG" "$REMINDER"
fi

exit 0
