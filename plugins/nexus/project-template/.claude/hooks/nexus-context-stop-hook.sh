#!/bin/bash
# UserPromptSubmit hook — reads token usage and emits the [context: ...] tag
# (ISS-221 token-telemetry feed — keeps zone-monitoring accurate on every turn).
#
# Output (stdout becomes additionalContext for the upcoming prompt):
#   [context: N tokens]
#
# Supports environments:
#   CC Desktop/CLI (Windows): transcript_path = C:\Users\... -> MSYS /c/Users/...
#   Cowork (Linux VM):        transcript_path = C:\Users\... -> /sessions/*/mnt/.claude/projects/**/*.jsonl
#
# Parser priority: jq (no Windows Store issues) > python (validated) > python3 (validated)

# Save stdin to temp file (needed for multiple reads)
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

# === Extract transcript_path from hook input ===
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

# === Resolve path to accessible file ===
BASH_PATH=""

# Strategy 1: path as-is (works on Linux if path is native)
[[ -f "$RAW_TRANSCRIPT" ]] && BASH_PATH="$RAW_TRANSCRIPT"

# Strategy 2: Windows C:\... -> MSYS /c/... (CC Desktop/CLI on Windows)
if [[ -z "$BASH_PATH" && "$RAW_TRANSCRIPT" =~ ^([A-Za-z]):\\ ]]; then
  drive="${BASH_REMATCH[1]}"
  drive="${drive,,}"
  MSYS_PATH="/${drive}${RAW_TRANSCRIPT:2}"
  MSYS_PATH="${MSYS_PATH//\\//}"
  [[ -f "$MSYS_PATH" ]] && BASH_PATH="$MSYS_PATH"
fi

# Strategy 3: Cowork mount — find by filename under /sessions
if [[ -z "$BASH_PATH" && -d "/sessions" ]]; then
  FILENAME="${RAW_TRANSCRIPT##*\\}"  # basename from Windows path
  FILENAME="${FILENAME##*/}"          # basename from Unix path (fallback)
  if [[ -n "$FILENAME" ]]; then
    FOUND=$(find /sessions -path "*/mnt/.claude/projects/*" -name "$FILENAME" -type f 2>/dev/null | head -1)
    [[ -f "$FOUND" ]] && BASH_PATH="$FOUND"
  fi
fi

[[ -z "$BASH_PATH" ]] && exit 0

# === Read last assistant message token usage ===
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
[[ "$TOTAL" -eq 0 ]] && exit 0

# === Compute display values ===
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

echo "[context: ${USED_K}K/${WINDOW_LABEL} | ${PCT}% | ${BAR}]"
