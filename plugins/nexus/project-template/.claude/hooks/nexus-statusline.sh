#!/bin/bash
input=$(cat)

# === Parse context data from Claude Code JSON ===
if command -v jq &>/dev/null; then
  PCT=$(echo "$input" | jq -r '.context_window.used_percentage // 0' 2>/dev/null | cut -d. -f1)
  SIZE=$(echo "$input" | jq -r '.context_window.context_window_size // 200000' 2>/dev/null)
  USED_TOKENS=$(echo "$input" | jq -r '(.context_window.used_percentage // 0) * (.context_window.context_window_size // 200000) / 100 | floor' 2>/dev/null)
  MODEL_ID=$(echo "$input" | jq -r '.model.id // ""' 2>/dev/null)
else
  PCT=$(echo "$input" | grep -o '"used_percentage"[[:space:]]*:[[:space:]]*[0-9.]*' | head -1 | grep -o '[0-9.]*$' | cut -d. -f1)
  SIZE=$(echo "$input" | grep -o '"context_window_size"[[:space:]]*:[[:space:]]*[0-9]*' | head -1 | grep -o '[0-9]*$')
  USED_TOKENS=$(( ${PCT:-0} * ${SIZE:-200000} / 100 ))
  MODEL_ID=$(echo "$input" | grep -o '"id"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*"\([^"]*\)"$/\1/')
fi

PCT=${PCT:-0}
SIZE=${SIZE:-200000}
USED_TOKENS=${USED_TOKENS:-0}
USED_K=$((USED_TOKENS / 1000))
SIZE_LABEL=$( [ "$SIZE" -ge 1000000 ] && echo "1M" || echo "$((SIZE / 1000))K" )

# === Model shorthand ===
case "$MODEL_ID" in
  *opus*)   MODEL="opus" ;;
  *sonnet*) MODEL="sonnet" ;;
  *haiku*)  MODEL="haiku" ;;
  *)        MODEL="?" ;;
esac

# === NEXUS data from sprint-state.md ===
NEXUS_STATE=".nexus/active/states/sprint-state.md"
SPRINT="—"; FOCUS="—"; ISS=""
if [ -f "$NEXUS_STATE" ]; then
  SPRINT=$(grep '^_sprint:' "$NEXUS_STATE" | awk '{print $2}')
  FOCUS=$(grep '^current_focus:' "$NEXUS_STATE" | awk '{print $2}')
  ISS=$(grep -A1 '^in_progress:' "$NEXUS_STATE" | grep 'ISS-' | \
        sed 's/.*\(ISS-[0-9]*\).*/\1/' | head -1)
fi

# === Git branch + dirty marker ===
GIT=""
if git rev-parse --git-dir &>/dev/null; then
  BRANCH=$(git branch --show-current 2>/dev/null)
  [ -z "$BRANCH" ] && BRANCH="detached"
  if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
    GIT="${BRANCH}*"
  else
    GIT="${BRANCH}"
  fi
fi

# === Progress bar ===
FILLED=$((PCT / 10)); EMPTY=$((10 - FILLED))
BAR=""
[ "$FILLED" -gt 0 ] && printf -v F "%${FILLED}s" && BAR="${F// /■}"
[ "$EMPTY" -gt 0 ] && printf -v E "%${EMPTY}s" && BAR="${BAR}${E// /□}"

# === Color by zone ===
if [ "$PCT" -ge 85 ]; then C='\033[31m'
elif [ "$PCT" -ge 70 ]; then C='\033[33m'
else C='\033[32m'; fi
D='\033[2m'   # dim for metadata
R='\033[0m'

# === Phase code ===
case "$FOCUS" in
  analysis) P="A" ;; research) P="R" ;; implementation) P="I" ;;
  application) P="P" ;; evaluation) P="E" ;; maintenance) P="M" ;;
  planning) P="plan" ;; learning) P="learn" ;;
  *) P="$FOCUS" ;;
esac

# === Output ===
PREFIX="${D}${MODEL}${R}"
[ -n "$GIT" ] && PREFIX="${PREFIX} ${D}| ${GIT}${R}"

if [ -n "$ISS" ]; then
  echo -e "${PREFIX} | Sprint: #${SPRINT} | ${ISS} → ${P} | ${C}${USED_K}K/${SIZE_LABEL} [${PCT}% ${BAR}]${R}"
else
  echo -e "${PREFIX} | Sprint: #${SPRINT} | ${FOCUS} | ${C}${USED_K}K/${SIZE_LABEL} [${PCT}% ${BAR}]${R}"
fi
