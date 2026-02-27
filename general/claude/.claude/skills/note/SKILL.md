---
disable-model-invocation: false
user-invocable: true
allowed-tools:
  - Bash:
      - find
      - ls
      - date
  - WebSearch
  - WebFetch
---

# Create Obsidian Note

Create an Obsidian note following vault conventions. Inherits all guidelines from the `obsidian` skill.

## Invocation

When the user invokes this skill, they may provide:
- A topic or title (e.g., "note about TCP/IP", "note on Nikola Tesla")
- A note type (e.g., "thought", "insight", "quote", "blog post")
- Content or context to include

If no topic is provided, **ask for it** before proceeding.

## Note Creation Flow

1. **Determine note type** from context or ask if ambiguous
2. **Locate the vault** by searching for `.obsidian/` directory (do not assume a fixed path)
3. **Check for duplicates** - search existing notes for similar titles
4. **Research the topic** using web search/Wikipedia when creating knowledge notes
5. **Find curiosities** - look for interesting facts, but **ask before adding** them
6. **Create the note** using filesystem tools (Write), never MCP
7. **Suggest wikilinks** to potentially related existing notes

## Note Types and Placement

| Type | Folder | Template Base | Key Tags |
|------|--------|---------------|----------|
| General note | `notes/` | `Note.md` | `meta/incomplete` + topic tags |
| Thought | `notes/` | `Thought.md` | `type/thought`, `type/fleeting-note`, `meta/draft` |
| Insight | `notes/` | `Insight.md` | `type/insight`, `type/literature-note` |
| Quote | `notes/` | `Quote.md` | `type/quote`, `type/literature-note` |
| Blog post | `blog/drafts/` | `Blog Post.md` | `type/blog-post`, `meta/possible-content/blog`, `meta/draft` |
| Map of Content | `maps of content/` | `MOC.md` | `type/map-of-content` |
| Person | `notes/` | `Note.md` | `type/person` + topic tags |
| Definition | `notes/` | `Note.md` | `type/definition` + topic tags |
| Book/Movie/Game/Serie | `media/` | Respective template | `type/book`, `type/movie`, etc. |

When in doubt, default to a general note in `notes/`.

## Frontmatter (Required Fields)

```yaml
---
createdAt: <current ISO 8601 timestamp, e.g. 2026-02-14T10:30:00Z>
title: "<Exact Filename Without .md>"
oneliner: "<One sentence describing this note>"
tags:
  - <type tag>
  - <topic tags - only deepest child>
  - meta/incomplete
aliases: []
updatedAt: <same as createdAt>
---
```

### Optional Fields (add when relevant)

- `icon:` - emoji for the note type (e.g., `💭` for thoughts, `💡` for insights, `🗨️` for quotes)
- `reference:` - source URL
- `coverUrl:` - cover image URL (e.g., from Wikipedia)
- `url:` - related URL
- `author:` - for quotes, use `[[wikilink]]` format

### AI Tracking

Since this skill creates content, **always** add:
- Tag: `meta/ai-assisted`
- Property: `lastEditedByAI: <current ISO timestamp>`

## Content Structure

```markdown
# Note Title

<content here, following vault writing style>
```

### Writing Rules (from obsidian skill)
- Match the user's conversational tone (check existing notes for reference)
- **Never** use EM dashes
- **Never** use text between dashes for explanations
- **Never** use hedging ("It's worth noting...", "It should be mentioned...")
- **Never** use formal transitions ("Moreover", "Furthermore")
- BCE years without commas: `3500 BCE` not `3,500 BCE`
- Use `[[wikilinks]]` for person names, years, concepts, and places
- Use callouts, code blocks, and images where appropriate

## Tag Rules

- Use hierarchical tags with `/` separators
- **Only use the deepest child** - Obsidian links parents automatically
  - `topic/computing/hardware/storage` (not also `topic/computing`)
- Prefer frontmatter tags over inline tags
- Ask before adding inline tags

## Filename Rules

- Human-readable with spaces: `Heinrich Hertz.md`
- Natural capitalization, acronyms uppercase: `RAID 0.md`
- No kebab-case, snake_case, or camelCase
- `title` field must **exactly** match the filename (minus `.md`)

## Vault Discovery

Do NOT hardcode the vault path. Prefer the **Obsidian CLI** (v1.12+) if available:

```bash
obsidian vault info=path
```

If the CLI is not installed, fall back to:

```bash
~/.claude/bin/find-obsidian --vault
```

## Examples

### General Knowledge Note
```markdown
---
createdAt: 2026-02-14T10:30:00Z
title: Acrophony
oneliner: "Letters in an alphabet that are spelled with the letter itself"
tags:
  - type/definition
  - topic/linguistics
  - meta/incomplete
  - meta/ai-assisted
aliases: [acrophony]
updatedAt: 2026-02-14T10:30:00Z
lastEditedByAI: 2026-02-14T10:30:00Z
---
# Acrophony

Means that the naming of the letters in an alphabet so that the letter starts with the letter itself.

The [[phonetic alphabet]] and the [[Greek alphabet]] are examples of such acrophonically-organized alphabets.
```

### Person Note
```markdown
---
createdAt: 2026-02-14T10:30:00Z
title: Heinrich Hertz
oneliner: "German physicist (1857-1894)"
tags:
  - type/person
  - topic/physics
  - meta/wikipedia
  - meta/ai-assisted
aliases: []
coverUrl: https://upload.wikimedia.org/...
reference: https://en.wikipedia.org/wiki/Heinrich_Hertz
updatedAt: 2026-02-14T10:30:00Z
lastEditedByAI: 2026-02-14T10:30:00Z
---

![Heinrich Hertz|350](coverUrl)

# Heinrich Hertz

> German physicist ([[1857]]-[[1894]])

Heinrich Rudolf Hertz was a German physicist who first proved the existence of electromagnetic waves proposed by [[James Clerk Maxwell]].
```

### Thought Note
```markdown
---
createdAt: 2026-02-14T10:30:00Z
title: Accept everything is a draft
oneliner: "Perfectionism kills progress"
tags:
  - type/thought
  - type/fleeting-note
  - meta/draft
  - meta/incomplete
  - meta/ai-assisted
aliases: []
updatedAt: 2026-02-14T10:30:00Z
icon: 💭
lastEditedByAI: 2026-02-14T10:30:00Z
---
# Accept everything is a draft

<content>
```
