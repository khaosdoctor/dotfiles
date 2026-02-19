---
disable-model-invocation: false
user-invocable: true
allowed-tools:
  - Bash:
      - date
---

# Quick Journal Jot

Save a quick thought or event to the journal buffer for later compilation via `/journal`.

## Invocation

The user types `/jot` followed by their message:

```
/jot had a meeting about the api redesign, went well
/jot feeling a bit tired today, long week
/jot played games with friends after work
```

If invoked without a message, ask "What do you want to jot down?"

## Buffer File

Store the buffer at `journal-buffer.md` inside your **auto memory directory** (the persistent memory path provided in your system prompt). This file persists across conversations and lives outside the vault.

## Flow

1. **Get current time and date** via Bash: `date +%H:%M:%S` and `date +%Y-%m-%d`
2. **Read the buffer file** (if it doesn't exist, create it)
3. **Check the date header**:
   - If the file has no `## YYYY-MM-DD` header for today, add one
   - If today's header exists, append under it
4. **Append the jot** exactly as the user wrote it:
   ```
   - _HH:MM:SS_ :: <user's message exactly as typed>
   ```
5. **Confirm** with a single word: "Noted." or "Saved." or "Got it."

## Jot Format Rules

- **NEVER** rewrite, expand, or clean up the user's message
- **NEVER** add wikilinks, tags, or formatting
- **NEVER** change the language (if they write in Portuguese, keep it)
- **NEVER** repeat the content back or add commentary
- Keep the exact words the user typed, only adding the timestamp prefix
- The only structural addition is the date header if missing

## Buffer Format

```markdown
## 2026-02-18
- _09:15:23_ :: morning standup, nothing too exciting
- _16:00:12_ :: good meeting about the api redesign, kicking off next week

## 2026-02-19
- _10:00:00_ :: started working on the new endpoint
```
