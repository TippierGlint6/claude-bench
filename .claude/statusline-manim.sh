#!/usr/bin/env bash
# Statusline segment for the manim MCP server's health, written by
# .claude/hooks/manim-health-check.sh. Never errors or blocks -- if the
# state file doesn't exist yet (no manim tool call this session), shows
# a neutral "unknown" indicator rather than a false warning.
cat >/dev/null || true

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STATE_FILE="$DIR/manim-health.json"

if [ ! -f "$STATE_FILE" ]; then
  echo "🔧 manim: unchecked"
  exit 0
fi

STATUS=$(grep -o '"status":"[a-z]*"' "$STATE_FILE" 2>/dev/null | sed -E 's/.*:"([a-z]*)"/\1/' || true)

case "$STATUS" in
  ok)
    echo "🔧 manim: ✓"
    ;;
  cold)
    echo "🔧 manim: ⚠ coldstart"
    ;;
  *)
    echo "🔧 manim: unchecked"
    ;;
esac
