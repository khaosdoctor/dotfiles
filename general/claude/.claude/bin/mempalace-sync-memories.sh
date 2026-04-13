#!/bin/bash
# Re-mine Claude auto-memory directories into MemPalace (claude-memory wing).
# Runs on SessionStart to catch up memories saved in previous sessions.
# Backgrounded with timeout so it never blocks session start.

command -v mempalace &>/dev/null || exit 0

(
  MEMORY_BASE="$HOME/.claude/projects"
  for dir in "$MEMORY_BASE"/*/memory; do
    [ -d "$dir" ] && [ -f "$dir/mempalace.yaml" ] && \
      mempalace mine "$dir" --wing claude-memory 2>/dev/null
  done
) &>/dev/null &
disown
