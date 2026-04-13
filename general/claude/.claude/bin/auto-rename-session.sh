#!/usr/bin/env bash
# SessionEnd hook: delegates session renaming to a headless `claude -p` call.
#
# Reads the hook payload from stdin, extracts session_id + transcript_path,
# and spawns a detached `claude -p` process to pick a title and append the
# rename lines. Runs detached so /exit is not delayed.

set -eu

command -v jq &>/dev/null || exit 0
command -v claude &>/dev/null || exit 0

payload="$(cat)"

transcript_path="$(printf '%s' "$payload" | jq -r '.transcript_path // empty')"
session_id="$(printf '%s' "$payload" | jq -r '.session_id // empty')"

# Nothing to do if the hook payload is malformed or transcript is gone.
[ -n "$transcript_path" ] || exit 0
[ -n "$session_id" ] || exit 0
[ -f "$transcript_path" ] || exit 0

# Skip trivial sessions (<2KB — matches the bulk-rename rules).
size=$(stat -c%s "$transcript_path" 2>/dev/null || echo 0)
[ "$size" -ge 2048 ] || exit 0

# Skip if already renamed (idempotent).
if grep -q '"type":"custom-title"' "$transcript_path" 2>/dev/null; then
  exit 0
fi

log_dir="$HOME/.claude/debug/auto-rename"
mkdir -p "$log_dir"
log_file="$log_dir/$(date +%Y%m%d).log"

prompt=$(cat <<PROMPT
You are renaming a just-ended Claude Code session transcript.

Transcript path: $transcript_path
Session ID: $session_id

## Context budget
The transcript may be large (hundreds of KB). DO NOT Read the whole file — it will blow your context window. You must filter it down to a small excerpt before reasoning.

## Extraction procedure
1. Run this Bash command to pull just the user messages into a compact excerpt (first ~10 of them, text content only, 200 chars each, tool results and system reminders stripped):
   jq -c 'select(.type=="user") | .message.content' "$transcript_path" 2>/dev/null \\
     | grep -v '"tool_use_id"' \\
     | grep -v 'system-reminder' \\
     | head -10 \\
     | cut -c1-200
2. That excerpt is your only source of truth. Do not Read more of the file.
3. If the excerpt is empty or only shows slash-command metadata (e.g. /compact, /clear), skip — print "SKIPPED: no substantive user content" and stop.

## Title rules
Pick a short kebab-case title: 3-6 words, lowercase, hyphens only, no punctuation, max 60 chars. It should describe the main topic of the conversation (e.g. bash-hook-debugging, obsidian-daily-template, traefik-coolify-routing).

## Append procedure (append-only, never rewrite)
1. Re-check with: grep -q '"type":"custom-title"' "$transcript_path"  — if it matches, stop and print "SKIPPED: already renamed".
2. Append the two lines with printf:
   printf '%s\n%s\n' \\
     '{"type":"custom-title","customTitle":"YOUR-TITLE","sessionId":"$session_id"}' \\
     '{"type":"agent-name","agentName":"YOUR-TITLE","sessionId":"$session_id"}' \\
     >> "$transcript_path"
3. Do not use Edit on the transcript. Do not read the file after writing.

## Output
When done, print a single line: RENAMED: <title>
If you skipped, print: SKIPPED: <reason>
PROMPT
)

# Detach: we don't want to block /exit waiting for the rename to finish.
# Narrow permissions: only the shell utilities needed to filter and append.
# Output goes to today's log for debugging.
nohup /usr/bin/claude -p "$prompt" \
  --allowed-tools "Bash(jq:*)" "Bash(grep:*)" "Bash(printf:*)" "Bash(stat:*)" "Bash(head:*)" "Bash(cut:*)" \
  >>"$log_file" 2>&1 </dev/null &
disown || true

exit 0
