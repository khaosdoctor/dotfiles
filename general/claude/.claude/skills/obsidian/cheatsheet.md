# Obsidian Vault Quick Reference

Quick reference for common patterns and conventions when working with the user's Obsidian vault.

## Quick Detection Checklist

Is this an Obsidian vault?
- [ ] `.obsidian/` folder exists?
- [ ] `notes/daily notes/` with `yyyy-mm-dd.md` files?
- [ ] `notes/` folder with many `.md` files?

**If any are true → Obsidian guidelines apply**

## Frontmatter Template

```yaml
---
tags:
  - topic/category
  - type/notetype
  - meta/status
aliases: []
createdAt: 2026-02-10T10:30:00Z
oneliner: One sentence describing this note
updatedAt: 2026-02-10T10:30:00Z
---
```

### Required Fields
- `tags` - Array of hierarchical tags
- `aliases` - Array (can be empty `[]`)
- `createdAt` - ISO timestamp
- `oneliner` - Brief description
- `updatedAt` - ISO timestamp

### Optional Fields
- `coverURL` - Cover image URL
- `reference` - Reference source URL
- `url` - Related URL
- `icon` - Emoji icon
- `lastEditedByAI` - ISO timestamp of last AI content edit

## Common Tag Patterns

**IMPORTANT**: Only use the deepest child tag. Obsidian automatically links parents!

```yaml
# Meta tags (about the note itself)
- meta/incomplete
- meta/wikipedia
- meta/habits/exercise

# Type tags (what kind of note)
- type/person
- type/daily-note
- type/book
- type/movie

# Topic tags (subject matter) - only use the deepest child!
- topic/computing/hardware/storage  # ✅ Correct - only the deepest
# NOT: topic/computing, topic/computing/hardware, ... ❌ Wrong - too many
- topic/physics
- topic/math
- topic/history
```

**Tag Rule**: If you're tagging something as `topic/computing/hardware/storage`, do NOT also add `topic/computing` or `topic/computing/hardware`. Obsidian links them automatically.

## Wikilink Checklist

### DO wikilink:
- ✅ Person names: `[[Albert Einstein]]`
- ✅ Years: `[[1857]]`, `[[2024]]`
- ✅ Concepts: `[[algorithm]]`, `[[API]]`
- ✅ Places: `[[Ancient Egypt]]`
- ✅ Related notes: `[[RAID 0]]`

### Aliases in wikilinks:
- When a note has an alias, reference it as: `[[Original Title|Alias]]`
- Example: `[[Electromagnetic Waves|EM waves]]`

### Renaming notes or changing aliases:
- **ALWAYS** search for other notes referencing the old name/alias
- Fix all broken references across the vault

### DON'T wikilink:
- ❌ URLs: `https://example.com`
- ❌ In code blocks: `` `code` ``
- ❌ File paths: `/path/to/file`
- ❌ Already linked text

## File Naming Quick Guide

| Type | Format | Example |
|------|--------|---------|
| Regular notes | Human readable with spaces | `Heinrich Hertz.md` |
| Daily notes | yyyy-mm-dd | `2026-02-10.md` |
| Acronyms | Uppercase | `RAID 0.md`, `API.md` |
| People | Full name | `Albert Einstein.md` |
| Concepts | Natural language | `Ubiquitous Language.md` |

## Image Reference Formats

```markdown
# Simple (no caption, no size)
![](internal/assets/image.png)

# With size only
![](internal/assets/image.png|350)

# With caption and size (preferred)
![Caption describing the image|350](internal/assets/image.png)
```

**Storage location**: Always `internal/assets/`

## Template Quick Reference

Located in `internal/templates/`:

| Template | Use Case |
|----------|----------|
| `Note.md` | Default for general notes |
| `Daily Note.md` | Daily journal (auto-created) |
| `Book.md` | Book notes |
| `Movie.md` | Movie notes |
| `Serie.md` | TV series notes |
| `Game.md` | Game notes |
| `Quote.md` | Quotes and sayings |
| `Thought.md` | Thoughts and insights |
| `MOC.md` | Maps of Content (index pages) |
| `Blog Post.md` | Blog posts |
| `Year note.md` | Yearly reviews |

## Writing Style Reminders

- 📝 Match the user's voice (check daily notes)
- 🎯 Write for normal person → normal person
- 🚫 NEVER use EM dashes (—)
- 🚫 NEVER use text between dashes for explanations
- 🚫 BCE years: NO commas/periods (`3500 BCE` not `3,500 BCE`)
- ✅ Use regular hyphens (-)
- 💬 Conversational but informative
- 🎓 Not overly technical, not overly simple
- 🔍 Include interesting connections
- ⚠️ Avoid AI patterns (hedging, formal transitions, dashed asides)

## Before/Ask Checklist

Always ASK before:
- ❓ Adding curiosities or fun facts
- ❓ Adding inline tags
- ❓ Deleting any notes
- ❓ Implementing new organizational ideas
- ❓ Making structural changes

## Daily Notes - CRITICAL RULES ⚠️

**Daily notes are sacred. Handle with extreme care.**

✅ **CAN edit**:
- Tags and frontmatter
- Heading structure
- Formatting and broken links

❌ **NEVER edit**:
- Journal entries
- Personal reflections
- TIL content
- Any text that conveys meaning

**Rule**: Change the structure, NEVER the content. When in doubt, ask first!

## AI Content Tracking 🤖

When you add/change actual content (not just structure):

**Add to frontmatter:**
```yaml
tags:
  - meta/ai-assisted  # ← Add this tag (if not present)
lastEditedByAI: 2026-02-10T12:34:56Z  # ← Add if missing, update if exists
```

**Content changes** = Adding info, changing meaning, rewriting
**Not content** = Fixing typos, updating tags, fixing links

**ALWAYS add/update both fields** when making content changes:
- Tag doesn't exist? → Add `meta/ai-assisted`
- Tag exists? → Keep it
- Property doesn't exist? → Add `lastEditedByAI: <timestamp>`
- Property exists? → Update `lastEditedByAI: <timestamp>`

## File Operations Decision Tree

```
Need to create/update a note?
│
├─ Use Filesystem tools ✅
│  ├─ Read (to read notes)
│  ├─ Write (to create notes)
│  └─ Edit (to modify notes)
│
└─ Use MCP? Only for:
   ├─ Reading with context search
   ├─ Dataview queries
   ├─ Complex searches across many notes
   └─ Obsidian-specific features

NEVER use MCP for creating/updating notes!
(Filesystem gives better diffs)
```

## Common Frontmatter Examples

### Person Note (Wikipedia-sourced)
```yaml
---
tags:
  - meta/wikipedia
  - type/person
  - topic/physics
aliases: []
coverUrl: https://upload.wikimedia.org/...
reference: https://en.wikipedia.org/wiki/Heinrich_Hertz
oneliner: German physicist (1857–1894)
createdAt: 2026-01-05T19:31:15Z
updatedAt: 2026-01-05T19:31:15Z
---
```

### Technical Concept Note
```yaml
---
tags:
  - topic/computing/hardware/storage  # Only deepest child!
  - topic/computing/infrastructure    # Separate hierarchy
  - meta/incomplete
aliases: []
createdAt: 2026-02-10T10:00:00Z
oneliner: Disk striping without redundancy for increased performance
updatedAt: 2026-02-10T10:00:00Z
---
```

Note: Only use the deepest child tags. Don't include `topic/computing` or `topic/computing/hardware` since `topic/computing/hardware/storage` already covers them.

### Daily Note
```yaml
---
tags:
  - type/daily-note
aliases: []
icon: 🗓️
overallRating: 5
---
```

## Callout Formats

Obsidian supports various callout types:

```markdown
> [!note]
> This is a note callout

> [!info]
> This is an info callout

> [!tip]
> This is a tip callout

> [!warning]
> This is a warning callout

> [!danger]
> This is a danger callout

> [!quote]
> This is a quote callout
```

## Research Workflow

When creating/updating notes:

1. 🔍 **Search** for information (Wikipedia, web search)
2. 📚 **Gather** facts, context, and curiosities
3. ❓ **Ask** about interesting facts before adding
4. 📝 **Write** in user's style
5. 🔗 **Link** relevant names, years, concepts
6. 🖼️ **Add** images if relevant (to `internal/assets/`)
7. 🏷️ **Tag** appropriately (use hierarchical tags)
8. ✅ **Check** there is no `title` property (the filename is the title)

## Directory Quick Reference

```
notes/              → Main notes (general knowledge)
notes/daily notes/  → Daily journal (yyyy-mm-dd.md)
internal/assets/    → ALL images and attachments
internal/templates/ → Note templates (Templater)
maps of content/    → MOC index pages
blog/               → Blog posts
media/              → Media notes (books, movies, etc.)
tracking notes/     → Habit and goal tracking
```

## Timestamp Format

Always use ISO 8601 format with timezone:

```yaml
createdAt: 2026-02-10T10:30:00Z
updatedAt: 2026-02-10T15:45:00Z
```

## Quick Pre-flight Check

Before creating a note:
- [ ] Checked for similar existing notes?
- [ ] Have the right template?
- [ ] No `title` property, filename in sentence case?
- [ ] Required frontmatter fields present?
- [ ] Tags use modern format (only deepest child)?
- [ ] Images stored in correct `internal/assets/` subdirectory?
- [ ] Images use full paths (internal/assets/...)?
- [ ] Wikilinks for names and years?
- [ ] Writing style matches user's voice?
- [ ] No AI patterns (dashed explanations, hedging)?
- [ ] Found any curiosities? (Ask before adding!)
- [ ] No EM dashes (—) used?

After adding/changing content:
- [ ] Added `meta/ai-assisted` tag?
- [ ] Added/updated `lastEditedByAI` with current timestamp?

## Emergency Recovery

If you're unsure about something:
1. 📖 Check similar notes in the same folder
2. 📅 Check daily notes for writing style
3. 🔍 Grep for similar tags/patterns
4. 🗂️ Check templates for structure
5. ❓ Ask the user when in doubt

## Key Performance Patterns

For efficiency:
- **Small operations**: Use Read/Write/Edit directly
- **Large searches**: Use `find` and `grep` (GNU tools)
- **Context search**: Use MCP (if available)
- **Dataview queries**: Use MCP (Obsidian-specific)

## Remember

> When in doubt, match existing patterns. Consistency > perfection.

The vault is a reflection of the user's thinking. Respect the existing structure and voice while helping it grow organically.
