---
user-invocable: true
disable-model-invocation: true
allowed-tools: Bash(*)
description: "Remove invalid and duplicate entries from Sigil memory. Shows a dry run first, then asks for confirmation before writing."
---

# /sigil:purge

Remove invalid entries (no domain code, duplicates) from MEMORY.md.

## Process

1. Run dry run and show what would be removed:
```bash
${CLAUDE_PLUGIN_ROOT}/node_modules/.bin/tsx ${CLAUDE_PLUGIN_ROOT}/src/purge.ts --dry-run
```

2. Show the output to the user and ask for confirmation before proceeding.

3. If confirmed, run for real:
```bash
${CLAUDE_PLUGIN_ROOT}/node_modules/.bin/tsx ${CLAUDE_PLUGIN_ROOT}/src/purge.ts
```

4. Report the final output verbatim.
