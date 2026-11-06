#!/usr/bin/env bash
# PreToolUse(Bash) guard: commands that print process argv/env must pipe through redact-secrets.
# Denies instead of rewriting, because rtk's hook already rewrites Bash commands.
cmd=$(jq -r '.tool_input.command // ""')

[[ "$cmd" == *redact-secrets* ]] && exit 0

sep='(^|[|;&(`]|\$\(|[[:space:]])'
pattern="${sep}(ps|pstree|procs|top|htop|btop)([[:space:]]|$)"
pattern+="|${sep}pgrep[[:space:]]+(-[A-Za-z]*a|--list-full)"
pattern+="|/proc/[^[:space:]]*/(cmdline|environ)"
pattern+="|${sep}(env|printenv)([[:space:]]*($|[|;&]))"
pattern+="|${sep}(docker|podman)[[:space:]]+(inspect|exec[^|]*[[:space:]](env|printenv))"
pattern+="|${sep}systemctl[[:space:]]+(show|cat)"

echo "$cmd" | grep -qE "$pattern" || exit 0

jq -n '{hookSpecificOutput: {
  hookEventName: "PreToolUse",
  permissionDecision: "deny",
  permissionDecisionReason: "This command can print process arguments or environment variables, which may hold secrets. Re-run it with output piped through the redactor: `{ <command>; } 2>&1 | ~/.claude/bin/redact-secrets`"
}}'
