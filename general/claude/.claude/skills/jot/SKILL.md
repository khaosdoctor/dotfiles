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

## Tool Usage for Vault Files

- **MCP tools**: use only for searching, fetching, and deleting vault files
- **Filesystem tools** (Read, Edit, Write): use for all edits and file creation — this keeps changes visible in diffs

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

## Temporal Relative Notations

When the jot contains natural-language time references (not inside `@@...@@`), resolve them to wikilinks with the original text as the alias.

### Resolution Rules

| Expression | Resolves to | Link format |
|---|---|---|
| `yesterday` | Current date − 1 day | `[[YYYY-MM-DD\|yesterday]]` |
| `today` | Current date | leave as plain text `today` — linking is redundant since jots live in the daily note |
| `tomorrow` | Current date + 1 day | `[[YYYY-MM-DD\|tomorrow]]` |
| `last [weekday]` (e.g. "last Monday") | Most recent past occurrence of that weekday | `[[YYYY-MM-DD\|last Monday]]` |
| `next [weekday]` (e.g. "next Friday") | Next upcoming occurrence of that weekday | `[[YYYY-MM-DD\|next Friday]]` |
| `last week` | Monday of the previous week | `[[YYYY-MM-DD\|last week]]` |
| `this week` | Monday of the current week | `[[YYYY-MM-DD\|this week]]` |
| `next week` | Monday of the next week | `[[YYYY-MM-DD\|next week]]` |
| `last month` | 1st of the previous month | `[[YYYY-MM-DD\|last month]]` |
| `this month` | 1st of the current month | `[[YYYY-MM-DD\|this month]]` |
| `next month` | 1st of the next month | `[[YYYY-MM-DD\|next month]]` |
| `last year` | Previous year number | `[[YYYY\|last year]]` |
| `this year` | Current year number | `[[YYYY\|this year]]` |
| `next year` | Next year number | `[[YYYY\|next year]]` |

### Format

Replace the expression in-place with a wikilink using the original text as the display alias:

```
I cried yesterday → I cried [[2026-02-22|yesterday]]
we went out last Friday → we went out [[2026-02-20|last Friday]]
I spent too much last week → I spent too much [[2026-02-16|last week]]
I bought a car last year → I bought a car [[2025|last year]]
```

### Notes

- Only link expressions that clearly refer to a specific day, period, or year
- Do NOT link vague temporal phrases like "a while ago", "recently", "someday", "at some point"
- Do NOT link when the expression is inside a `@@...@@` block (already handled separately)
- Use `date` to compute the current date before resolving

## Flow

1. **Get current time and date** via Bash: `date +%H:%M:%S` and `date +%Y-%m-%d`
2. **Read the buffer file** (if it doesn't exist, create it)
3. **Process inline comments**: extract, resolve, and replace all `@@...@@` blocks (see above)
4. **Resolve temporal relative notations**: scan the message for time references and replace them with wikilinks (see above)
5. **Resolve nicknames, aliases, and first names**: scan the message for unlinked proper nouns that look like person names or nicknames. For each:
   - Search the vault for notes whose `aliases` frontmatter contains that word (nickname/alias match)
   - If no alias match, search for person notes (`type/person`) whose title starts with that word (first-name-only match)
   - If found unambiguously in either case, replace with `[[Full Note Title|Original Word]]`
   - If multiple notes match or it's unclear, leave as-is
   - Do NOT over-resolve — only replace when confident it refers to a specific person in the vault
6. **Resolve media titles**: scan the message for titles of books, games, movies, or series. Check for a matching note under `media/`. If found, link it. If NOT found but you're confident it's a media title (book, game, movie, or series):
   - Still add the wikilink `[[Title]]` so it becomes an unresolved link in Obsidian
   - **Notify the user** at the end of the confirmation message: "Note: I linked `[[Title]]` but no vault note exists yet — add it manually via the plugin."
   - Do NOT create the note yourself
7. **Fix typos that match vault notes**: if a word is a near-match (typo) of an existing vault note title or alias, fix the typo AND link it in one step. Only do this when the match is unambiguous and the fix is obvious (e.g., "Kurzgezact" → `[[Kurzgesagt]]`).
8. **Check the date header** (using the date from step 1, NOT a cached/session date):
   - If the file has no `## YYYY-MM-DD` header for today's date, add one — even if an earlier date header was added in the same session (day rollover at midnight)
   - If today's header already exists, append under it
   - **Day rollover**: Jots may span midnight. Each jot's date header must match the actual date at the time `date` was called in step 1. For example, if you started jotting at 23:50 on 2026-02-19 and the next jot is at 00:05 on 2026-02-20, the second jot goes under a new `## 2026-02-20` header
9. **Append the resolved jot**:
   ```
   - _HH:MM:SS_ :: <user's message with @@...@@ blocks resolved and replaced>
   ```
10. **Confirm** with a single word: "Noted." or "Saved." or "Got it." Append any media note warnings from step 6 on the same line.

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
