---
user-invocable: true
disable-model-invocation: true
allowed-tools: Read(*), Edit(*), Write(*), Glob(*), Grep(*), Bash(uvx:*), Bash(wc:*), Bash(cat:*)
description: "Review the current session and save anything worth remembering long-term. Run at session end to capture feedback, decisions, project context, and references."
---

# /sigil:wrap-up

Review the full conversation so far and extract anything worth saving long-term.

## Sigil Format

See the `sigil-syntax.md` reference file in the `remember` skill directory for the full format specification.

## Process

1. Scan the conversation for items worth keeping long-term:
   - Corrections or feedback the user gave ("don't do X", "prefer Y")
   - Decisions made about the project (architecture, approach, constraints)
   - References discovered (tools, URLs, file paths, external systems)
   - Facts about the user's role, preferences, or environment

2. Filter ruthlessly — skip anything:
   - Already in memory (check MEMORY.md first)
   - Ephemeral (only relevant to this session's task)
   - Derivable from the code or git history

3. For each item worth saving, follow the `/sigil:remember` process:
   - Compress to Sigil format
   - Route to the correct section in MEMORY.md
   - Check for duplicates before writing

4. Report what was saved and what was skipped (and why).

If nothing is worth saving, say so explicitly — that's a valid outcome.
