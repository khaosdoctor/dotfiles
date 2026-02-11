---
disable-model-invocation: false
user-invocable: false
allowed-tools:
  # Note: Read, Glob, Grep are ALWAYS implicitly allowed (global guideline)
  - Bash:
      - find
      - ls
      - tree
  - WebSearch
  - WebFetch
---

# Obsidian Vault Guidelines

Guidelines for working with Obsidian vaults. This skill is automatically activated when working in an Obsidian vault directory.

## Purpose

Provide consistent, high-quality assistance when creating, updating, or managing notes in an Obsidian vault. Ensure all modifications follow the vault's existing conventions, formatting, and organizational structure.

## When This Skill Applies

This skill is active when working in a directory that contains:
- A `.obsidian/` folder, OR
- A `notes/daily notes/yyyy-mm-dd.md` structure, OR
- A `notes/` folder with many `.md` files (indicating an Obsidian vault)

## Core Principles

### 1. Research and Information Gathering
- **USE** Wikipedia and web search tools to gather information when creating or updating notes
- Research should be thorough but not overly academic
- Find interesting connections, curiosities, and fun facts (but always ask before adding them)

### 2. File Operations
- **NEVER** use MCP servers for creating or updating notes
- **ALWAYS** use filesystem tools (Read, Write, Edit) for note modifications
- Filesystem tools provide better diffs and version control integration
- **MAY** use MCP servers for:
  - Reading notes (when context search or Dataview queries are useful)
  - Complex searches across many notes
  - Obsidian-specific features (backlinks, graph queries)
- For large operations, prefer GNU tools (find, grep) over MCP for performance

### 3. Note Format and Structure
- **FOLLOW** the existing format conventions in the vault exactly
- Check similar notes in the same folder to understand formatting expectations
- Check `internal/templates/` for template files when creating new notes
- Use the appropriate template based on note type (Note, Daily Note, Book, Movie, etc.)
- If no specific template exists, default to `Note.md` template

### 4. Writing Style
- **MATCH** the user's writing style by examining related notes or daily notes
- Write for a normal person explaining to another normal person (not in the field)
- Not overly technical, but not explaining to a 5-year-old either
- **NEVER** use EM dashes (—) in any note
- Use regular hyphens (-) for ranges and dashes
- **BCE dates**: When referring to years in BC, always use the term "BCE" (e.g., `3500 BCE`). **NEVER** format BCE years with commas or periods (e.g., ❌ `3,500 BCE`, ❌ `3.500 BCE` → ✅ `3500 BCE`)
- **AVOID** AI writing patterns:
  - Text between dashes for explanations (e.g., "This concept—which is important—should...")
  - Overly formal transitions (e.g., "Moreover", "Furthermore", "Subsequently")
  - Hedging language (e.g., "It's worth noting that...", "It should be mentioned...")
  - Write naturally and conversationally, as the user would

### 5. Rich Formatting
- **USE** callouts for important information or asides
- **USE** code blocks with appropriate syntax highlighting
- **USE** headings to structure longer notes
- **USE** images with the image caption plugin format: `![caption|sizepx](path)`
- Images should be stored in `internal/assets/` folder
- Take advantage of Obsidian's markdown extensions

### 6. Linking and Wikilinks
- **CREATE** wikilinks for person names (e.g., `[[Albert Einstein]]`)
- **CREATE** wikilinks for years (e.g., `[[1857]]`, `[[2024]]`)
- **CREATE** wikilinks for concepts that might have or should have their own notes
- **WHEN ADDING ALIASES** to a note, references to that note using the alias should use the format `[[Original Title|Alias]]` (e.g., if adding alias "EM waves" to `Electromagnetic Waves.md`, link as `[[Electromagnetic Waves|EM waves]]`)
- **WHEN RENAMING** a note or changing its aliases, **CHECK** for other notes that reference the old name/alias and update them accordingly. Use grep/search to find all references and fix broken links.
- **NEVER** create wikilinks in:
  - URLs or web addresses
  - Code blocks
  - File paths
  - Places where it would break formatting

### 7. Frontmatter
All notes must have YAML frontmatter with these **required** fields:
- `title:` - Title of the note, must be EXACTLY the same as the filename (without .md extension)
- `tags:` - Array of hierarchical tags (e.g., `meta/incomplete`, `type/person`, `topic/physics`)
- `aliases:` - Array of alternative names for the note (can be empty: `[]`)
- `createdAt:` - ISO timestamp of creation
- `oneliner:` - Brief description of the note (one sentence)
- `updatedAt:` - ISO timestamp of last update

Optional frontmatter fields:
- `coverURL:` - URL to a cover image
- `reference:` - URL to reference source
- `url:` - Related URL
- `icon:` - Emoji icon for the note
- `lastEditedByAI:` - Date when AI last edited the note content (see AI Tracking below)

Example for a file named `Heinrich Hertz.md`:
```yaml
---
title: Heinrich Hertz
tags:
  - topic/physics
  - type/person
  - meta/incomplete
aliases: []
createdAt: 2026-02-10T10:30:00Z
oneliner: German physicist who first proved the existence of electromagnetic waves
updatedAt: 2026-02-10T10:30:00Z
---
```

**CRITICAL**: The `title` field must always match the filename exactly (minus the `.md` extension). If the file is named `RAID 0.md`, the title must be `title: RAID 0`.

### 8. Tags
- **PREFER** frontmatter tags over inline tags
- Use hierarchical tag structure (e.g., `topic/computing/hardware/storage`)
- **IMPORTANT**: Only use the deepest child tag. Obsidian automatically links to parent tags.
  - ✅ Correct: `topic/computing/hardware/storage`
  - ❌ Wrong: Include both `topic/computing` AND `topic/computing/hardware` AND `topic/computing/hardware/storage`
- Common tag prefixes:
  - `meta/` - Metadata tags (incomplete, wikipedia, etc.)
  - `type/` - Note type (person, daily-note, book, etc.)
  - `topic/` - Subject matter (physics, computing, history, etc.)
- **ONLY** add inline tags if it makes contextual sense
- **ASK** before adding inline tags

### 9. File Naming
- Use human-readable filenames with spaces
- Follow the naming convention of other notes in the same folder
- Examples: `Heinrich Hertz.md`, `RAID 0.md`, `Ancient Egypt.md`
- For daily notes: Always use `yyyy-mm-dd.md` format in `notes/daily notes/`

### 10. Suggestions and Autonomy
- **ASK** before implementing new organizational ideas
- **ASK** before adding curiosities or fun facts to notes
- **ASK** before adding inline tags
- **ASK** before deleting any notes
- Feel free to suggest:
  - New notes to create
  - New organizational methods
  - Interesting connections between notes
  - Improvements to existing notes
- But always get approval before implementing suggestions

### 11. Curiosities and Fun Facts
- **ALWAYS** search for interesting curiosities or fun facts when working on notes
- These add value and make notes more engaging
- **NEVER** add them directly without asking
- If you find a good one, present it and ask if it should be included
- If you don't find anything interesting, that's okay - don't force it
- If unsure whether a fact is "curious enough", ask

### 12. AI Content Tracking
When you add, modify, or change the actual content of a note (not just formatting/structure):

**ALWAYS add these to the frontmatter:**
1. **Tag**: Add `meta/ai-assisted` to the tags array (if not already present)
2. **Property**: Add `lastEditedByAI` with current ISO timestamp (if doesn't exist) OR update it (if it exists)

**What counts as content changes:**
- Adding new information or context
- Changing existing information
- Rewriting sections
- Adding facts, explanations, or details

**What does NOT require tracking:**
- Fixing typos or formatting
- Updating tags or metadata
- Normalizing headings
- Fixing broken links
- Purely structural changes

**Example:**
```yaml
---
title: Example Note
tags:
  - topic/computing
  - meta/ai-assisted  # ← Added this
aliases: []
createdAt: 2025-01-01T10:00:00Z
oneliner: Example note description
updatedAt: 2026-02-10T12:00:00Z
lastEditedByAI: 2026-02-10T12:34:56Z  # ← Added/updated with full timestamp
---
```

**CRITICAL**:
- If `lastEditedByAI` already exists → UPDATE it with current timestamp
- If `lastEditedByAI` does NOT exist → ADD it with current timestamp
- Same for `meta/ai-assisted` tag → add if missing, keep if present

**Never skip these tracking fields when making content changes!**

## Vault Structure Reference

See `vault-structure.md` for detailed breakdown of the vault organization.

## Templates Reference

Templates are located in `internal/templates/`:
- `Note.md` - Default template for general notes
- `Daily Note.md` - Template for daily journal notes
- `Book.md`, `Movie.md`, `Serie.md`, `Game.md` - Media templates
- `Quote.md` - Template for quotes
- `Thought.md` - Template for thoughts/insights
- `MOC.md` - Maps of Content template
- `Blog Post.md` - Template for blog posts
- `Year note.md` - Template for yearly review notes

Templates use Templater syntax (`<% %>` and `<%* %>`).

## Cheat Sheet

See `cheatsheet.md` for quick reference of common patterns and conventions.

## Important Notes

- **Detection**: This skill activates when `.obsidian/` folder is detected or vault structure is recognized
- **Version Control**: Always use filesystem tools to get proper git diffs
- **Consistency**: When in doubt, look at similar existing notes for guidance
- **User Style**: The user's voice and style should shine through - check daily notes for tone
- **Efficiency**: For very large operations, consider GNU tools over MCP for better performance

## Safety Guidelines

### Critical: Daily Notes and Personal Journals

**Daily notes are deeply personal and require special care.**

**ALLOWED changes to daily notes:**
- Structural edits: removing/updating tags, normalizing headings, fixing formatting
- Metadata changes: frontmatter updates
- Technical corrections: fixing broken links, image paths

**NEVER allowed in daily notes:**
- Writing or adding journal content
- Changing the text or meaning of entries
- Updating personal reflections, thoughts, or experiences
- Adding to Journal, TIL, or personal log sections

**Rule of thumb**: You can change HOW the note is structured, but NEVER WHAT the note says.

**Before editing any daily note**:
1. **DOUBLE CHECK** if you're changing content vs structure
2. If touching any text content or meaning, **STOP and ASK**
3. Only proceed with structural/metadata changes

### General Safety
- Never delete notes without explicit user confirmation
- Always preserve existing formatting conventions
- Don't make organizational changes without approval
- Respect the existing tag hierarchy and structure
- Ask before adding new types of content (inline tags, callouts, etc.)
