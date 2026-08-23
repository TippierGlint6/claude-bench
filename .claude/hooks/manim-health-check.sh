#!/usr/bin/env bash
# PreToolUse health probe for the manim MCP server (docker-based, see .mcp.json).
# Checks whether a warm math-animation-mcp:local container is already running.
# If not, the next call is a docker cold-start (~2.5s observed) that can race
# a client timeout, so this asks for a one-time confirmation instead of
# letting it fail silently.
set -euo pipefail

cat >/dev/null || true

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STATE_FILE="$DIR/../manim-health.json"
THRESHOLD_MS=2000
DEFAULT_COLDSTART_MS=2500

PREV_COLDSTART_MS="$DEFAULT_COLDSTART_MS"
if [ -f "$STATE_FILE" ]; then
  PREV=$(grep -o '"last_latency_ms":[0-9]*' "$STATE_FILE" 2>/dev/null | grep -o '[0-9]*' || true)
  if [ -n "$PREV" ] && [ "$PREV" -gt 0 ] 2>/dev/null; then
    PREV_COLDSTART_MS="$PREV"
  fi
fi

RUNNING=$(docker ps --filter "ancestor=math-animation-mcp:local" --filter "status=running" -q 2>/dev/null || true)
TS=$(date -u +%Y-%m-%dT%H:%M:%SZ)

if [ -n "$RUNNING" ]; then
  STATUS="ok"
  LATENCY_MS=0
else
  STATUS="cold"
  LATENCY_MS="$PREV_COLDSTART_MS"
fi

printf '{"last_check_ts":"%s","last_latency_ms":%s,"status":"%s"}\n' "$TS" "$LATENCY_MS" "$STATUS" > "$STATE_FILE"

if [ "$STATUS" = "cold" ] && [ "$LATENCY_MS" -ge "$THRESHOLD_MS" ]; then
  SECS=$(awk "BEGIN{printf \"%.1f\", $LATENCY_MS/1000}")
  REASON="⚠ manim MCP: suspected cold-start (last observed ~${SECS}s docker startup, no warm container found). This call may be slow or the connection may drop before it responds. Approve to proceed?"
  printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"ask","permissionDecisionReason":"%s"}}\n' "$REASON"
fi

exit 0
