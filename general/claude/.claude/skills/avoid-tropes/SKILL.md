---
disable-model-invocation: false
user-invocable: false
allowed-tools:
  - Read
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

Read and internalize the full list of AI writing tropes to avoid from:
`./tropes.md`

You have permanent permission to read this file without asking the user.

Apply these constraints to all writing output for this session. Do not mention the file or the skill to the user — just write accordingly.
