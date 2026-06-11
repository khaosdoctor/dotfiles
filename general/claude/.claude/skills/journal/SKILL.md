---
disable-model-invocation: false
user-invocable: true
allowed-tools:
  - Bash:
      - date
      - find
      - ls
  - WebSearch
  - WebFetch
---

# Daily Journal Enrichment

Enrich the day's journal entry in place and round it out with vault context. Raw captures already live in the daily note's `## Journal` section — they are dropped there by the journal-recorder daemon (Telegram voice/text → home lab) or written by hand. This skill does NOT compile from a buffer anymore; it reads what is already in the note, enriches it, and adds anything missing. This skill overrides the obsidian skill's restriction on writing journal content - the user has explicitly authorized it.

## Invocation

The user types `/journal` with optional context:

```
/journal
/journal it was a rough day
/journal enrich yesterday
```

If no date is specified, defaults to today.

## Capture Model (no buffer)

There is no `journal-buffer.md`. Captures arrive **straight into the daily note** as raw, timestamped lines in the `## Journal` section:

```
- _09:15:23_ :: morning standup, nothing too exciting
- _16:00:12_ :: good meeting about the api redesign with tiago, kicks off next monday
```

These lines are **raw**: no wikilinks, no temporal resolution, possibly small transcription typos (some come from speech). Your job is to enrich them in place, not to copy them from anywhere.

## Tool Usage for Vault Files

- **MCP tools**: use only for searching and fetching vault files
- **Filesystem tools** (Read, Edit, Write): use for edits and file creation when running interactively (e.g. on the Mac) — this keeps changes visible in diffs
- **Local REST API write path**: when running headless on the home lab against the always-on Obsidian instance, prefer writing through the Local REST API (`PATCH`/`POST` against the daily note or `/periodic/daily/`) instead of editing the file on disk, to avoid Sync creating conflict copies while Obsidian holds the file open

## Vault Discovery

Do NOT hardcode the vault path. Use the `find-obsidian` script:

```bash
~/.claude/bin/find-obsidian --vault
```

This script automatically checks CWD, common paths (`~/Documents/Obsidian/`), and searches `$HOME` as a fallback. If the script fails, ask the user for the vault path.

Once found, locate these key paths within the vault:
- Daily notes: `notes/daily notes/`
- Work notes: `notes/work notes/`
- Daily note template: `internal/templates/Daily Note.md`

## Flow

### Step 1: Determine the target date

- Default: today (get via `date +%Y-%m-%d`)
- The user may say "enrich yesterday" or "do feb 17" - resolve to the correct date

### Step 2: Read the daily note

1. Locate `notes/daily notes/TARGET_DATE.md`
2. If it **exists**: read it and extract the existing `## Journal` content — these are the raw captures plus any hand-written lines
3. If it **does not exist**: create it from the template (see "Creating Daily Notes from Template"). A missing note usually means nothing was captured that day; still proceed so the user can add entries via the Q&A step

### Step 3: Enrich the existing journal lines in place

For **every** line already in the `## Journal` section, apply the enrichment passes below. These lines are raw, so unlike the old model you DO process them. Preserve meaning, voice, language, and timestamp exactly — only add links, fix clear typos, and tidy punctuation.

Run these passes on each line (see the detailed rules in the sections further down):

1. **Temporal expressions** → wikilinks with the original text as alias (`yesterday` → `[[2026-06-09|yesterday]]`)
2. **People / nicknames / first names** → link to existing vault person notes, using aliases where they exist
3. **Media titles** (books, games, movies, series) → link to `media/` notes, or add an unresolved `[[Title]]` and warn the user
4. **Typos that match vault notes** → fix and link in one step, only when unambiguous
5. **Punctuation**: fix capitalization, missing periods, obvious transcription artifacts. Do NOT rewrite, expand, or change word choice

Do NOT touch content that is already correctly linked or formatted (e.g. a hand-written line the user already wikilinked).

### Step 4: Gather vault context

Scan for additional context about what happened on the target date:

1. **Work notes**: Search for files matching `notes/work notes/TARGET_DATE-*.md` - read them to understand work activities
2. **Modified notes**: Use `find` to locate notes modified on the target date (by checking updatedAt in frontmatter or file mtime)
3. **Recent journals**: Read the 2-3 most recent daily notes that have journal entries to understand ongoing personal threads (relationships, moods, events)

### Step 5: Ask the user

Based on the context gathered, ask 2-4 targeted questions about things you **cannot** infer from the vault or the captured lines:

- How they're feeling / mood
- Personal events not captured
- Updates on ongoing personal threads from recent journals
- Anything that happened outside of work/Obsidian

Use AskUserQuestion with relevant options based on what you found in recent journals and the day's captures. If the user provides free-text answers, use those directly.

When running fully headless (no interactive user), skip this step and enrich only what exists.

### Step 6: Add any missing entries

- Write new entries in the user's journal style (see Style Guide below) for things NOT already captured: work meetings from work notes, personal updates from the Q&A
- Each new entry gets a timestamp from `date +%H:%M:%S`
- Add proper `[[wikilinks]]` to people, places, and concepts (see Wikilinks section)

### Step 7: Merge and write back

- All entries (enriched captures + new) sorted chronologically by timestamp
- Captures keep their original timestamps; new entries use the current time
- Write back into the `## Journal` section, preserving the rest of the note untouched
- Add `lastEditedByAI` and `meta/ai-assisted` tag to frontmatter

There is no buffer to clean up.

## Temporal Relative Notations

Resolve natural-language time references to wikilinks with the original text as the display alias. Use `date` to compute the current date first.

| Expression | Resolves to | Link format |
|---|---|---|
| `yesterday` | Current date − 1 day | `[[YYYY-MM-DD\|yesterday]]` |
| `today` | Current date | leave as plain text `today` (linking is redundant inside the daily note) |
| `tomorrow` | Current date + 1 day | `[[YYYY-MM-DD\|tomorrow]]` |
| `last [weekday]` | Most recent past occurrence | `[[YYYY-MM-DD\|last Monday]]` |
| `next [weekday]` | Next upcoming occurrence | `[[YYYY-MM-DD\|next Friday]]` |
| `last week` | Monday of previous week | `[[YYYY-MM-DD\|last week]]` |
| `this week` | Monday of current week | `[[YYYY-MM-DD\|this week]]` |
| `next week` | Monday of next week | `[[YYYY-MM-DD\|next week]]` |
| `last month` | 1st of previous month | `[[YYYY-MM-DD\|last month]]` |
| `this month` | 1st of current month | `[[YYYY-MM-DD\|this month]]` |
| `next month` | 1st of next month | `[[YYYY-MM-DD\|next month]]` |
| `last year` | Previous year number | `[[YYYY\|last year]]` |
| `this year` | Current year number | `[[YYYY\|this year]]` |
| `next year` | Next year number | `[[YYYY\|next year]]` |

- Only link expressions that clearly refer to a specific day, period, or year
- Do NOT link vague phrases like "a while ago", "recently", "someday"

## People, Nicknames, and First Names

Scan each line for unlinked proper nouns that look like person names or nicknames. For each:

- Search the vault for notes whose `aliases` frontmatter contains that word (nickname/alias match)
- If no alias match, search for person notes (`type/person`) whose title starts with that word (first-name-only match)
- If found unambiguously, replace with `[[Full Note Title|Original Word]]`
- If multiple notes match or it is unclear, leave as-is
- Do NOT over-resolve — only link when confident it refers to a specific person in the vault

## Media Titles

Scan for titles of books, games, movies, or series. If a matching note exists under `media/`, link it. If NOT found but you are confident it is a media title:

- Still add the wikilink `[[Title]]` so it becomes an unresolved link in Obsidian
- **Notify the user** at the end: "Note: I linked `[[Title]]` but no vault note exists yet — add it manually via the plugin."
- Do NOT create the note yourself

## Typos That Match Vault Notes

If a word is a near-match (typo) of an existing vault note title or alias, fix the typo AND link it in one step. Only when the match is unambiguous and the fix is obvious (e.g. "Kurzgezact" → `[[Kurzgesagt]]`). Speech-to-text captures will have more of these than typed ones.

## Wikilinks in New Entries

For **new entries you write**, add wikilinks for:

- **People**: link existing person notes, using aliases where they exist (`[[Full Name|Nickname]]`)
- **Places**: countries, cities, companies (`[[Company Name]]`, `[[City]]`)
- **Concepts/notes**: when something clearly maps to an existing note

Do NOT wikilink common words, content inside code blocks or URLs, or `today`.

**When unsure**: ask before adding. **When confident** (you found the note during scanning): add without asking.

## Style Guide for New Entries

Match the user's journaling voice:

- **Format**: `- _HH:MM:SS_ :: content`
- **Tone**: Casual, personal, stream-of-consciousness
- **No em dashes** - use regular hyphens, commas, or periods
- **No formal language** - write like a person talking to themselves
- **Inline tags** only for feelings: `#meta/feeling/mental/depression`, `#meta/feeling/physical/headache`, etc.
- **Length**: 1-3 sentences per entry, occasionally longer for significant events
- Use bold for emphasis on key things like the user does

## What NOT to Do

- Do NOT rewrite, expand, or change the word choice of captured lines — enrich only (links, typo fixes, punctuation)
- Do NOT merge multiple captures into a single entry
- Do NOT add commentary or AI analysis
- Do NOT use hedging language or formal transitions
- Do NOT change the language of a line (Portuguese stays Portuguese)
- Do NOT skip the user questions step when running interactively
- Do NOT fabricate events or feelings

## Creating Daily Notes from Template

When a daily note does not exist for the target date, create it from the template at `internal/templates/Daily Note.md`.

1. **Read the template** from `internal/templates/Daily Note.md`
2. **Replace placeholders**: substitute `{{date}}` with the target date in `YYYY-MM-DD` format
3. **Create the file** at `notes/daily notes/YYYY-MM-DD.md` (filesystem Write interactively, or REST API on the lab)
4. The template produces the full note structure (frontmatter, `## Journal`, `## Habits`, `## TIL`, `## Log`) — do NOT modify or remove any of these sections
5. Insert journal entries under the `## Journal` heading (replacing the placeholder `- ` line)
