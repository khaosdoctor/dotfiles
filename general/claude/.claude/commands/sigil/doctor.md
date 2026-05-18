---
user-invocable: true
disable-model-invocation: true
allowed-tools: Bash(*)
description: "Diagnose the health of Sigil memories. Checks format validity, duplicates, stale entries, and compression opportunities."
---

# /sigil:doctor

Run the Sigil diagnostics script and report the findings to the user verbatim.

```bash
${CLAUDE_PLUGIN_ROOT}/node_modules/.bin/tsx ${CLAUDE_PLUGIN_ROOT}/src/doctor.ts
```

Report the full output without modification.
