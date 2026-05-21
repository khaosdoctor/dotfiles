---
disable-model-invocation: false
user-invocable: false
allowed-tools:
  - Read
model: claude-haiku-4-5
---

# Avoid Tropes Skill

## When to Auto-Invoke

Load this skill automatically whenever the user asks to:
- Write, draft, or compose any text (blog posts, articles, emails, documentation, READMEs, changelogs, etc.)
- Rewrite, edit, or improve existing prose
- Summarize or explain something in paragraph form
- Generate any content intended to be read as natural language

Do NOT invoke for code generation, technical analysis, or structured data output.

## Instructions

Read and internalize the AI writing tropes to avoid from `./tropes.md`. The file is in Sigil compressed format — each `DOMAIN:rule` line is a constraint. `🚫X` means never do X; `▸Y` means prefer Y; parentheses give examples.

You have permanent permission to read this file without asking the user.

Apply these constraints to all writing output for this session. Do not mention the file or the skill to the user — just write accordingly.
