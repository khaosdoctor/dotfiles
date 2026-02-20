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

# Daily Journal Compilation

Compile the day's journal entry from buffer jots and vault context. This skill overrides the obsidian skill's restriction on writing journal content - the user has explicitly authorized it.

## Invocation

The user types `/journal` with optional context:

```
/journal
/journal it was a rough day
/journal compile yesterday
```

If no date is specified, defaults to today.

## Buffer File

Located at `journal-buffer.md` inside your **auto memory directory** (the persistent memory path provided in your system prompt).

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
- The user may say "compile yesterday" or "compile feb 17" - resolve to the correct date

### Step 2: Read the buffer and check for stale jots

Read the buffer file and check for jots from **dates other than the target date**:

1. If there are jots from **past dates** (before today):
   a. List which dates have pending jots
   b. Ask the user: "You have uncompiled jots from [dates]. Want me to add them to those days' journal entries?"
   c. If **yes**, for each past date:
      - Check if the daily note exists at `notes/daily notes/YYYY-MM-DD.md`
      - If it **exists**: read the note, find the `## Journal` section, and insert the jots **in chronological order** under that heading (before the next `##` section). Preserve any existing journal entries and merge them in time order. Add wikilinks to the jots (see Wikilinks section).
      - If it **does not exist**: create a new daily note from the template at `internal/templates/Daily Note.md` (see "Creating Daily Notes from Template" section below), then insert the jots under `## Journal`
      - Add `lastEditedByAI` and `meta/ai-assisted` tag to the frontmatter of any daily note created or modified
      - Remove those date sections from the buffer
   d. If **no**, leave them in the buffer
2. Extract jots for the **target date** - these are the foundation of the journal entry

### Step 3: Gather vault context

Scan for additional context about what happened on the target date:

1. **Work notes**: Search for files matching `notes/work notes/TARGET_DATE-*.md` - read them to understand work activities
2. **Modified notes**: Use `find` to locate notes modified on the target date (by checking updatedAt in frontmatter or file mtime)
3. **Recent journals**: Read the 2-3 most recent daily notes that have journal entries to understand ongoing personal threads (relationships, moods, events)

### Step 4: Ask the user

Based on the context gathered, ask 2-4 targeted questions about things you **cannot** infer from the vault:

- How they're feeling / mood
- Personal events not captured in notes
- Updates on ongoing personal threads from recent journals
- Anything that happened outside of work/Obsidian

Use AskUserQuestion with relevant options based on what you found in recent journals. If the user provides free-text answers, use those directly.

### Step 5: Compile the journal entry

Build the journal entry following these rules:

#### Jot entries (from buffer)
- Include every jot preserving the user's original wording
- Keep the original `_HH:MM:SS_ :: text` format
- Keep them in their original chronological position
- **Add wikilinks** where appropriate (see Wikilinks section)

#### Additional entries (from vault context + user answers)
- Write new entries in the user's journal style (see Style Guide below)
- Each new entry gets a timestamp: use the current time from `date +%H:%M:%S`
- New entries cover things NOT already mentioned in jots: work meetings, personal updates from the Q&A
- Add proper `[[wikilinks]]` to people, places, and concepts

#### Merging
- All entries (jots + new) are sorted chronologically by timestamp
- Jots keep their original timestamps
- New entries use the current time

### Step 6: Write to the daily note

1. Check if `notes/daily notes/TARGET_DATE.md` exists
2. If it **exists**: insert journal entries under the `## Journal` heading, preserving any existing entries and merging by time order
3. If it **does not exist**: create a new daily note from the template (see "Creating Daily Notes from Template" section below), then insert journal entries under `## Journal`
4. Add `lastEditedByAI` and `meta/ai-assisted` tag to frontmatter

### Step 7: Clean up buffer

- Remove the target date's section from the buffer file
- Leave other dates untouched

## Wikilinks in Jots and Journal Entries

When compiling jots into the journal, **add wikilinks** to the jot text for:

- **People**: If a person has an existing note in the vault, link them. Use aliases where they exist (e.g., `[[Full Name|Nickname]]`)
- **Places**: Countries, cities, companies (e.g., `[[Company Name]]`, `[[City]]`, `[[Country]]`)
- **Concepts/notes**: If something referenced in the jot clearly maps to an existing note, link it

**When unsure**: If you think a wikilink could be useful but aren't sure, ask the user before adding it.

**When confident**: If you know there's an existing note for that person/place/concept (because you found it during vault scanning), add the link without asking.

Do NOT wikilink:
- Common words that don't need their own note
- Things inside code blocks or URLs
- Dates (those are already wikilinked in the timestamp format `[[YYYY-MM-DD]]` only when referencing other days)

## Style Guide for New Entries

Match the user's journaling voice. Based on existing journals:

- **Format**: `- _HH:MM:SS_ :: content`
- **Tone**: Casual, personal, stream-of-consciousness
- **No EM dashes** - use regular hyphens
- **No formal language** - write like a person talking to themselves
- **Inline tags** only for feelings: `#meta/feeling/mental/depression`, `#meta/feeling/physical/headache`, etc.
- **Length**: 1-3 sentences per entry, occasionally longer for significant events
- Use bold for emphasis on key things like the user does

## What NOT to Do

- Do NOT merge multiple jots into a single entry
- Do NOT add commentary or AI analysis
- Do NOT use hedging language or formal transitions
- Do NOT skip the user questions step - always ask about personal/mood stuff
- Do NOT fabricate events or feelings

## Creating Daily Notes from Template

When a daily note does not exist for the target date, create it from the template at `internal/templates/Daily Note.md`.

### Steps

1. **Read the template** from `internal/templates/Daily Note.md`
2. **Replace placeholders**: substitute `{{date}}` with the target date in `YYYY-MM-DD` format
3. **Create the file** at `notes/daily notes/YYYY-MM-DD.md` using the Obsidian MCP `create_vault_file` tool
4. The template produces the full note structure including frontmatter, `## Journal`, `## Habits`, `## TIL`, and `## Log` sections — do NOT modify or remove any of these sections
5. Insert journal entries under the `## Journal` heading (replacing the placeholder `- ` line)
