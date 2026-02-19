# Vault Structure Reference

This document describes the organization and structure of the user's Obsidian vault based on analysis of `$VAULT_PATH/`.

## Root Directory Structure

```
$VAULT_PATH/
├── .obsidian/              # Obsidian configuration and plugins
├── .claude/                # Claude Code configuration (if present)
├── assets/                 # Legacy assets (prefer internal/assets)
├── blog/                   # Blog posts
├── internal/               # Internal vault files
│   ├── assets/            # PRIMARY location for all attachments and images
│   └── templates/         # Note templates (Templater format)
├── maps of content/        # MOC (Maps of Content) notes
├── media/                  # Media-related notes (movies, books, games, etc.)
├── notes/                  # PRIMARY notes directory
│   └── daily notes/       # Daily journal notes (yyyy-mm-dd.md format)
└── tracking notes/         # Tracking and habit notes
```

## Key Directories

### notes/
The main notes directory containing the vast majority of notes. Notes here are:
- General knowledge notes
- Person notes (e.g., `Heinrich Hertz.md`)
- Concept notes (e.g., `RAID 0.md`, `Ubiquitous Language.md`)
- Technical notes
- Random facts and learnings

**File naming**: Human-readable with spaces, follows natural language patterns
- Examples: `Heinrich Hertz.md`, `RAID 0.md`, `Arctic and Antarctic means bears and no bears.md`

### notes/daily notes/
Daily journal entries in strict `yyyy-mm-dd.md` format:
- `2023-09-10.md`
- `2023-09-11.md`
- `2026-02-10.md`

**Purpose**: Daily journaling, habits tracking, TIL (Today I Learned), logs
**Template**: Uses `internal/templates/Daily Note.md`

### internal/assets/
**PRIMARY** location for all attachments:
- Images (PNG, JPG, SVG, etc.)
- Downloaded files
- Diagrams
- Any binary assets

**Important**: When adding images to notes, they should be stored here and referenced with relative paths.

### internal/templates/
Contains Templater templates for different note types:
- `Note.md` - Default general note
- `Daily Note.md` - Daily journal format
- `Book.md`, `Movie.md`, `Serie.md`, `Game.md` - Media tracking
- `Quote.md` - Quote collection
- `Thought.md` - Thoughts and insights
- `MOC.md` - Maps of Content
- `Blog Post.md` - Blog post structure
- `Year note.md` - Yearly review
- `templater-scripts/` - Custom Templater scripts

Templates use Templater syntax with:
- `<% %>` - Regular template expressions
- `<%* %>` - JavaScript execution blocks
- `tp.file.*` - File operations
- `tp.system.prompt()` - User input prompts

### maps of content/
MOC (Maps of Content) notes that serve as index/hub pages for related notes. These are high-level organizational structures linking related notes together.

### blog/
Blog posts and article drafts. These may follow a different format than regular notes.

### media/
Notes about media consumption:
- Movies watched
- Books read
- Games played
- TV series
- Music albums

May have subcategories or use templates from `internal/templates/`.

### tracking notes/
Special tracking notes for habits, goals, and metrics:
- Health logs
- Goal tracking
- Habit tracking
- Shopping lists
- Various personal metrics

## File Naming Conventions

### Regular Notes
- Use natural, human-readable names with spaces
- Capitalization follows normal English rules
- Acronyms stay uppercase (e.g., `RAID 0.md`, `API.md`)
- Person names use full names (e.g., `Heinrich Hertz.md`, `Albert Einstein.md`)

### Daily Notes
- Strict format: `yyyy-mm-dd.md`
- Examples: `2026-02-10.md`, `2023-09-10.md`
- Always in `notes/daily notes/` directory

### Special Characters
- Spaces are allowed and encouraged
- Parentheses are allowed (e.g., `L(PN) - The networked learner.md`)
- Hyphens for compound concepts (e.g., `Anti Corruption Layer.md`)
- Numbers are fine (e.g., `2-argument arctangent function.md`, `2025 Goals List.md`)

## Tag Hierarchy

### Common Tag Prefixes

#### meta/
Metadata tags about the note itself:
- `meta/incomplete` - Note is work in progress
- `meta/wikipedia` - Sourced from Wikipedia
- `meta/habits/*` - Habit tracking tags

#### type/
The type or category of note:
- `type/person` - Biography or person note
- `type/daily-note` - Daily journal entry
- `type/book` - Book note
- `type/movie` - Movie note
- `type/game` - Game note

#### topic/
Subject matter hierarchy:
- `topic/computing` - General computing
- `topic/computing/hardware` - Hardware-specific
- `topic/computing/hardware/storage` - Storage systems
- `topic/computing/infrastructure` - Infrastructure topics
- `topic/physics` - Physics-related
- `topic/math` - Mathematics
- `topic/history` - Historical topics

### Tag Best Practices
- Use hierarchical structure with `/` separators
- Be as specific as reasonable (but don't over-categorize)
- Tags in frontmatter as array:
  ```yaml
  tags:
    - topic/computing/hardware
    - meta/incomplete
  ```

## Wikilink Patterns

### What Gets Wikilinked
1. **Person names**: `[[Heinrich Hertz]]`, `[[Albert Einstein]]`, `[[James Clerk Maxwell]]`
2. **Years**: `[[1857]]`, `[[1894]]`, `[[2024]]`
3. **Concepts**: `[[parity]]`, `[[algorithm]]`, `[[API]]`
4. **Locations**: `[[Ancient Egypt]]`, `[[ancient Greece]]`
5. **Related notes**: `[[notes/Hertz|Hertz]]` (with path and display text)

### What Does NOT Get Wikilinked
- URLs and web addresses
- Code blocks and inline code
- File paths
- Already-linked text
- Text inside markdown links

### Wikilink Format
- Simple: `[[Note Name]]`
- With display text: `[[Note Name|Display Text]]`
- With path: `[[notes/Note Name|Note Name]]`

## Frontmatter Patterns

### Standard Frontmatter (Required)
```yaml
---
title: Exact Filename Without Extension
tags:
  - topic/category
  - type/notetype
aliases: []
createdAt: 2026-02-10T10:30:00Z
oneliner: Brief one-sentence description
updatedAt: 2026-02-10T10:30:00Z
---
```

### Wikipedia-Sourced Notes
```yaml
---
title: Heinrich Hertz
tags:
  - meta/wikipedia
  - type/person
  - topic/physics
aliases: []
coverUrl: https://upload.wikimedia.org/wikipedia/...
reference: https://en.wikipedia.org/wiki/Heinrich_Hertz
url: https://en.wikipedia.org/wiki/Heinrich_Hertz
oneliner: German physicist (1857–1894)
createdAt: 2026-01-05T19:31:15Z
updatedAt: 2026-01-05T19:31:15Z
---
```

### Daily Notes
```yaml
---
tags:
  - type/daily-note
aliases: []
icon: 🗓️
overallRating: 5
---
```

## Image Handling

### Storage
All images should be stored in `internal/assets/`

### Reference Formats
1. **Simple**: `![](internal/assets/image.png)`
2. **With size**: `![](internal/assets/image.png|350)`
3. **With caption and size**: `![Caption text|350](internal/assets/image.png)`

### Image Caption Plugin
The vault uses an image caption plugin that allows:
```markdown
![This is the caption|350px](internal/assets/image.png)
```

## Special Note Types

### Daily Notes Structure
```markdown
---
tags:
  - type/daily-note
aliases: []
icon: 🗓️
overallRating: 5
---
# 2026-02-10
---
## Journal
-

## Habits
- [ ] Exercised for 30 minutes at least #meta/habits/exercise
- [ ] Practiced music #meta/habits/music
- [ ] [Pages read:: 0] #meta/habits/reading

## TIL
-

## Log
[Links to tracking notes]

### Year Goals
```

### Person Notes
- Often include coverUrl (Wikipedia image)
- Include birth/death years as wikilinks
- Include reference to source (usually Wikipedia)
- Oneliner with brief description

### Technical Concept Notes
- Clear explanation of the concept
- May include diagrams from `internal/assets/`
- Related concepts as wikilinks
- Usage examples if applicable

## Obsidian-Specific Features

### Plugins in Use
Based on vault structure and note format:
- **Templater** - Template system with JavaScript execution
- **Image captions** - Caption support in images
- **Dataview** (likely) - For queries and tracking
- **Daily Notes** (core) - Daily note generation

### Internal Links
The vault uses `obsidian://` protocol for deep linking:
```markdown
[💊 Health log](obsidian://open?vault=Default&file=notes%2F%F0%9F%92%8A%20Health%20log)
```

## Writing Style Observations

Based on analyzed notes:
- Conversational but informative
- Concise explanations
- Often includes context and "why it matters"
- Uses bold for emphasis on key terms
- Includes interesting connections (e.g., "Arctic and Antarctic means bears and no bears")
- Not overly formal or academic
- Practical and grounded

## Growth Areas

When suggesting new notes or organization:
- Consider the existing folder structure
- Check if similar notes exist before creating duplicates
- Respect the tag hierarchy
- Follow the established naming conventions
- Ask before implementing organizational changes
