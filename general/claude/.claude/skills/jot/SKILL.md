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

## Inline Comments (`@@...@@`)

The user can include instructions to you inside `@@...@@` delimiters anywhere in their jot message. These are **not** part of the jot text — they are commands for you to resolve before saving.

Example:
```
/jot had a meeting about @@check my calendar for the project name@@ and it went well
```

### Comment Resolution Flow

1. **Extract** all `@@...@@` blocks from the message
2. **Resolve** each comment by executing the instruction (search, look up, fetch, etc.)
3. **Replace** each `@@...@@` block in the message with the resolved result
4. **Save** the final, clean jot with no `@@` markers remaining

If a comment cannot be resolved, ask the user what to substitute.

## Flow

1. **Get current time and date** via Bash: `date +%H:%M:%S` and `date +%Y-%m-%d`
2. **Read the buffer file** (if it doesn't exist, create it)
3. **Process inline comments**: extract, resolve, and replace all `@@...@@` blocks (see above)
4. **Check the date header** (using the date from step 1, NOT a cached/session date):
   - If the file has no `## YYYY-MM-DD` header for today's date, add one — even if an earlier date header was added in the same session (day rollover at midnight)
   - If today's header already exists, append under it
   - **Day rollover**: Jots may span midnight. Each jot's date header must match the actual date at the time `date` was called in step 1. For example, if you started jotting at 23:50 on 2026-02-19 and the next jot is at 00:05 on 2026-02-20, the second jot goes under a new `## 2026-02-20` header
5. **Append the resolved jot**:
   ```
   - _HH:MM:SS_ :: <user's message with @@...@@ blocks resolved and replaced>
   ```
6. **Confirm** with a single word: "Noted." or "Saved." or "Got it."

## Jot Format Rules

- **NEVER** rewrite, expand, or clean up the user's message beyond light punctuation fixes
- **NEVER** add wikilinks, tags, or formatting
- **NEVER** change the language (if they write in Portuguese, keep it)
- **NEVER** repeat the content back or add commentary
- **NEVER** use em dashes (—), use commas, periods, or regular hyphens instead
- **NEVER** change the meaning, tone, or word choice
- **Fix punctuation**: correct missing periods, commas, capitalization at sentence starts, and obvious typos. Keep everything else as-is
- The only structural addition is the date header if missing

## Buffer Format

```markdown
## 2026-02-18
- _09:15:23_ :: morning standup, nothing too exciting
- _16:00:12_ :: good meeting about the api redesign, kicking off next week

## 2026-02-19
- _10:00:00_ :: started working on the new endpoint
```
