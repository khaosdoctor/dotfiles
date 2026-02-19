# Vault Analysis & Observations

This file contains analysis and observations about the user's specific Obsidian vault to help provide better assistance.

**Vault Path**: `$VAULT_PATH/`

## Analyzed Notes Summary

### Sample Note: Heinrich Hertz.md

**Type**: Person note (Wikipedia-sourced)

**Frontmatter**:
```yaml
aliases: []
coverUrl: https://upload.wikimedia.org/wikipedia/commons/3/30/HEINRICH_HERTZ.JPG
oneliner: "German physicist (1857–1894)"
reference: https://en.wikipedia.org/wiki/Heinrich_Hertz
tags: [meta/wikipedia, type/person, topic/physics, topic/math]
title: "Heinrich Hertz"
updatedAt: 2026-01-05T19:31:15Z
url: https://en.wikipedia.org/wiki/Heinrich_Hertz
```

**Observations**:
- Uses `coverUrl` (not `coverURL`) for Wikipedia-sourced notes
- Includes both `reference` and `url` (both point to Wikipedia)
- Tags as array notation: `[tag1, tag2, tag3]` (alternate to list format)
- Oneliner includes birth/death years in parentheses
- Image with size specification: `![Heinrich Hertz Thumbnail | 350](...)`
- Quote block for oneliner: `> German physicist ([[1857]]–[[1894]])`
- Years as wikilinks: `[[1857]]`, `[[1894]]`
- Related person as wikilink: `[[James Clerk Maxwell]]`

### Sample Note: RAID 0.md

**Type**: Technical concept note

**Frontmatter**:
```yaml
tags:
  - topic/computing
  - topic/computing/hardware
  - topic/computing/hardware/storage
  - topic/computing/infrastructure
  - meta/wikipedia
aliases: []
```

**Observations**:
- Missing required fields: `title`, `createdAt`, `oneliner`, `updatedAt` ⚠️
- Uses OLD tag format with both parent and child tags
  - Modern format should only use deepest child: `topic/computing/hardware/storage`
  - Obsidian automatically links hierarchical tags
- Includes diagram image: `![](150px-RAID_0.svg.png)`
  - Image exists in `internal/assets/` but uses short reference
  - Better to use full path: `internal/assets/150px-RAID_0.svg.png`
- Uses bold for emphasis: "**not**"
- Includes wikilink to concept: `[[parity]]`
- Has "Usage" section with practical explanation

### Daily Note Template Structure

**Format**: `yyyy-mm-dd.md` in `notes/daily notes/`

**⚠️ CRITICAL**: Daily notes are deeply personal. NEVER write or change journal content, reflections, or meaning. Only edit structure (tags, headings, formatting) if explicitly requested.

**Key sections**:
1. **Journal** - Free-form daily entry (NEVER edit content)
2. **Habits** - Checkbox tracking with inline tags
   - Exercise: `#meta/habits/exercise`
   - Music: `#meta/habits/music`
   - Reading: `[Pages read:: 0]` (Dataview syntax)
3. **TIL** - Today I Learned (NEVER edit content)
4. **Log** - Links to tracking notes using `obsidian://` protocol
5. **Year Goals** - Reference to yearly goals

**Habit Tracking Pattern**:
```markdown
- [ ] Task description #meta/habits/category
```

**Dataview Pattern**:
```markdown
- [Pages read:: 0] #meta/habits/reading
```

## Writing Style Analysis

Based on analyzed notes:

### Tone Characteristics
- **Direct and clear**: No fluff, gets to the point
- **Informative**: Provides context and explanation
- **Practical**: Often includes usage or "why it matters"
- **Conversational**: Feels like explaining to a friend
- **Curious**: Includes interesting connections and trivia
- **Natural**: Avoids AI-like patterns such as text between dashes for explanations

### Structural Patterns
- **Short paragraphs**: Usually 1-3 sentences
- **Bold for emphasis**: Key terms or important warnings
- **Sections with headers**: Organized with `##` headers
- **Examples when relevant**: Practical usage examples
- **Images for clarification**: Diagrams and photos where helpful

### AI Writing Patterns to AVOID
- ❌ **Text between dashes for explanations**: "This concept—which is important—should be understood"
- ❌ **Overly formal transitions**: "Moreover", "Furthermore", "Subsequently"
- ❌ **Hedging language**: "It's worth noting that...", "It should be mentioned..."
- ❌ **List-heavy structure**: Everything broken down into bullet points
- ✅ **Natural flow**: Write as the user would naturally explain something

### Example Phrases
From "RAID 0":
> "RAID 0 is also known as *stripe set* or *striped volume*."

> "Raid 0 does **not** provide redundancy..."

Notice:
- Uses italics for terminology/alternate names
- Uses bold for critical information (negations, warnings)
- Clear, factual language
- No dashes for asides or explanations

### Interesting Tidbits Pattern
From filename: `Arctic and Antarctic means bears and no bears.md`

This shows the user appreciates:
- Etymology and word origins
- Clever connections between concepts
- Memorable mnemonics
- "Aha!" moments in understanding

## Tag System Analysis

### Observed Tag Hierarchies

**meta/** - Metadata about notes
- `meta/incomplete` - Work in progress
- `meta/wikipedia` - Wikipedia-sourced
- `meta/habits/exercise` - Exercise tracking
- `meta/habits/music` - Music practice
- `meta/habits/reading` - Reading tracking

**type/** - Note classification
- `type/person` - Biography/person
- `type/daily-note` - Daily journal
- `type/book` - Book notes
- `type/movie` - Movie notes
- `type/game` - Game notes

**topic/** - Subject matter (most hierarchical)
- `topic/computing/hardware/storage` - Storage systems
- `topic/computing/infrastructure` - Infrastructure
- `topic/physics` - Physics
- `topic/math` - Mathematics
- `topic/history` - History

### Tagging Philosophy - MODERN FORMAT

**ONLY use the deepest child tag**. Obsidian automatically creates parent links.

✅ **Correct (modern format)**:
```yaml
tags:
  - topic/computing/hardware/storage
  - topic/computing/infrastructure
  - meta/wikipedia
```

❌ **Incorrect (old format - don't use)**:
```yaml
tags:
  - topic/computing
  - topic/computing/hardware
  - topic/computing/hardware/storage  # Only this one is needed!
```

**Why?** Obsidian's tag hierarchy system automatically links child tags to parents. Adding parent tags is redundant and clutters the frontmatter.

### Tag Best Practices
- Use only the most specific tag applicable
- Go as deep in the hierarchy as makes sense
- Obsidian will automatically show `topic/computing/hardware/storage` under `topic/computing` and `topic/computing/hardware`
- Multiple top-level categories are fine (e.g., `topic/computing/hardware`, `meta/incomplete`)

## File Naming Observations

### Patterns Found
- **Full sentences as filenames**:
  - ✅ `Arctic and Antarctic means bears and no bears.md`
  - ✅ `Ancient Egyptology was a profession in Ancient Egypt.md`
  - ✅ `Apply ROT13 in Vim natively.md`
- **Technical terms preserved**:
  - ✅ `RAID 0.md` (not "raid-0" or "Raid0")
  - ✅ `API.md` (uppercase acronym)
  - ✅ `ADM-3A.md` (preserves exact model number)
- **Person names**:
  - ✅ `Heinrich Hertz.md`
  - ✅ `Albert Einstein.md`
  - ✅ `Alexander Graham Bell.md`
- **Natural language**:
  - ✅ `Opening hours of restaurant.md`
  - ✅ `Accept everything is a draft.md`

### Anti-patterns to Avoid
- ❌ Kebab-case: `heinrich-hertz.md`
- ❌ Snake_case: `heinrich_hertz.md`
- ❌ CamelCase: `HeinrichHertz.md`
- ❌ All lowercase: `heinrich hertz.md`
- ✅ Natural capitalization: `Heinrich Hertz.md`

## Template System

### Templater Usage

The vault uses Templater plugin with JavaScript execution.

**Common patterns**:
```markdown
<% tp.file.creation_date() %>          # Insert creation date
<%* ... %>                              # Execute JavaScript
tp.system.prompt('Question', 'default') # Prompt user for input
tp.file.title                          # Get/set file title
tp.file.rename(newName)                # Rename file
```

**Example from Note.md template**:
```markdown
<%*
if (tp.file.title === 'Untitled') {
  const result = await tp.system.prompt('Enter file Title:', tp.file.title || 'Untitled', false, true);
  tp.file.title = result;
  tp.file.rename(result);
}
tR+= tp.file.title
%>
```

This prompts for a title and renames the file automatically.

### Available Templates
1. **Note.md** - Default, includes meta/incomplete tag
2. **Daily Note.md** - Structured journal with habits
3. **Book.md**, **Movie.md**, **Serie.md**, **Game.md** - Media tracking
4. **Quote.md** - Quote collection
5. **Thought.md** - Insights and thoughts
6. **MOC.md** - Maps of Content (hub pages)
7. **Blog Post.md** - Blog article structure
8. **Year note.md** - Annual review

## Image and Asset Handling

### Asset Directory Structure

```
internal/assets/
├── (root) - General images, diagrams, photos
├── canvases/ - Obsidian Canvas files
├── excalidraw/ - Excalidraw drawings
└── media/ - Media files (videos, audio, etc.)
```

### Image Reference Best Practices

**ALWAYS use full path** to be explicit:
```markdown
![Description|350](internal/assets/image.png)
```

**NOT** just the filename (even though Obsidian might auto-resolve it):
```markdown
![](image.png)  ❌ Unclear where the image is
```

### Organizing Assets

When adding new assets, place them in the appropriate location:
- **Diagrams, photos, screenshots** → `internal/assets/` (root)
- **Canvas files** → `internal/assets/canvases/`
- **Excalidraw drawings** → `internal/assets/excalidraw/`
- **Videos, audio** → `internal/assets/media/`

### Image Caption Format

Use the image caption plugin format:
```markdown
![Caption text|sizepx](internal/assets/path/to/image.png)
```

Examples:
```markdown
![RAID 0 striping diagram|150](internal/assets/150px-RAID_0.svg.png)
![Heinrich Hertz portrait|350](internal/assets/heinrich-hertz.jpg)
```

## Wikilink Patterns

### Observed Patterns

**Years as links**:
```markdown
[[1857]]–[[1894]]
```
Note: Uses regular en-dash between wikilinked years (not EM dash)

**Names as links**:
```markdown
[[Heinrich Hertz]]
[[James Clerk Maxwell]]
[[Albert Einstein]]
```

**Concepts as links**:
```markdown
[[parity]]
[[algorithm]]
[[API]]
```

**Locations as links**:
```markdown
[[ancient Greece]]
[[Ancient Egypt]]
```

**Path-based links** (rare):
```markdown
[[notes/Hertz|Hertz]]
```

### Link Philosophy
- Create links liberally for concepts that should/could have notes
- Don't worry if the target note doesn't exist yet (that's fine in Obsidian)
- Use display text `|` when path is needed or text should differ

## Quality Checklist for New Notes

Based on existing note analysis:

### Must Have
- [ ] Title field matches filename exactly
- [ ] All 6 required frontmatter fields present
- [ ] Tags use modern format (only deepest child tags)
- [ ] Oneliner is concise and descriptive
- [ ] Timestamps in ISO 8601 format
- [ ] No EM dashes (—) anywhere
- [ ] No text between dashes for explanations
- [ ] Person names are wikilinked
- [ ] Years are wikilinked
- [ ] Writing matches user's natural conversational style
- [ ] No AI-like hedging phrases or formal transitions

### Should Have
- [ ] Cover image (if person or major concept)
- [ ] Reference link (if from Wikipedia/web)
- [ ] Images in `internal/assets/` (proper subdirectory) with full paths
- [ ] Sections with `##` headers
- [ ] Related concepts wikilinked
- [ ] Practical examples or usage (if applicable)

### Nice to Have
- [ ] Interesting curiosity or fun fact (ask first!)
- [ ] Etymology or word origin (if interesting)
- [ ] Diagram or visual aid
- [ ] Related notes section
- [ ] Historical context

## Common Mistakes to Avoid

1. **Frontmatter**
   - ❌ `title: Heinrich-Hertz` (should match filename: `Heinrich Hertz`)
   - ❌ Missing required fields
   - ❌ Using EM dash in oneliner: `German physicist (1857—1894)`
   - ✅ Use regular dash: `German physicist (1857–1894)`
   - ❌ Old tag format with parents: `topic/computing`, `topic/computing/hardware`
   - ✅ Only deepest child: `topic/computing/hardware/storage`

2. **Tags**
   - ❌ Including parent tags: `topic/computing`, `topic/computing/hardware`, `topic/computing/hardware/storage`
   - ✅ Only child tag: `topic/computing/hardware/storage` (Obsidian links parents automatically)
   - ❌ Inline tags (without asking)
   - ✅ Frontmatter tags (preferred)

3. **Wikilinks**
   - ❌ Wikilinking URLs: `[[https://example.com]]`
   - ✅ Regular markdown link: `[Example](https://example.com)`
   - ❌ Wikilinking in code: `[[API]]` inside code block
   - ✅ Code stays as-is: `` `API` ``

4. **Images**
   - ❌ Short reference: `![](image.png)`
   - ✅ Full path: `![Description|350](internal/assets/image.png)`
   - ❌ Storing in wrong location
   - ✅ Use appropriate subdirectory (root, canvases, excalidraw, media)

5. **Writing Style**
   - ❌ Overly academic: "The aforementioned physicist Heinrich Rudolf Hertz..."
   - ❌ Text between dashes: "This concept—which is important—should be understood"
   - ❌ Hedging: "It's worth noting that...", "It should be mentioned..."
   - ✅ Conversational: "Heinrich Hertz was a German physicist..."
   - ✅ Natural: Write as the user would naturally explain

## Workflow Recommendations

### Creating a New Note

1. **Determine note type** → Choose template
2. **Check existing notes** → Avoid duplicates, understand conventions
3. **Research** → Wikipedia, web search for information
4. **Find curiosities** → Interesting facts (ask before adding)
5. **Draft content** → Match user's natural style, avoid AI patterns
6. **Add frontmatter** → All required fields, modern hierarchical tags (only deepest child)
7. **Add wikilinks** → Names, years, concepts
8. **Add images** → Store in appropriate `internal/assets/` subdirectory, use full paths, add captions
9. **Review** → No EM dashes, no text between dashes, title matches filename, natural writing style

### Updating an Existing Note

1. **Read current content** → Understand existing structure
2. **Check frontmatter** → Update `updatedAt`, verify required fields, modernize tags if needed
3. **Match style** → Keep consistent with existing content
4. **Preserve formatting** → Don't reorganize without asking
5. **Add wikilinks** → For any new names, years, concepts
6. **Update tags** → Use modern format (only deepest child tags)

### Research Pattern

When creating notes about people, places, or concepts:

1. **Wikipedia first** → Reliable, structured information
2. **Extract key facts**:
   - For people: Birth/death, occupation, key achievements
   - For concepts: Definition, usage, history
   - For places: Location, significance, history
3. **Find curiosities** → Etymology, interesting connections, trivia
4. **Ask about curiosities** → Don't add without permission
5. **Cite source** → Add `reference` field in frontmatter

## Examples of Well-Formed Notes

### Person Note
```markdown
---
title: Heinrich Hertz
tags:
  - meta/wikipedia
  - type/person
  - topic/physics
  - topic/math
aliases: []
coverUrl: https://upload.wikimedia.org/wikipedia/commons/3/30/HEINRICH_HERTZ.JPG
reference: https://en.wikipedia.org/wiki/Heinrich_Hertz
oneliner: German physicist (1857–1894)
createdAt: 2026-01-05T19:31:15Z
updatedAt: 2026-01-05T19:31:15Z
---

> _Reference Article_: [Heinrich Hertz](https://en.wikipedia.org/wiki/Heinrich_Hertz)

![Heinrich Hertz|350](https://upload.wikimedia.org/wikipedia/commons/3/30/HEINRICH_HERTZ.JPG)

# Heinrich Hertz

> German physicist ([[1857]]–[[1894]])

Heinrich Rudolf Hertz was a German physicist who first conclusively proved the existence of the electromagnetic waves proposed by [[James Clerk Maxwell]]'s equations of electromagnetism.
```

### Technical Concept Note (Modern Format)
```markdown
---
title: RAID 0
tags:
  - topic/computing/hardware/storage
  - topic/computing/infrastructure
  - meta/incomplete
aliases: []
createdAt: 2025-06-15T14:20:00Z
oneliner: Disk striping without redundancy for increased performance
updatedAt: 2025-06-15T14:20:00Z
---

# RAID 0

RAID 0 is also known as *stripe set* or *striped volume*. It will split data evenly in stripes across two or more disks without [[parity]] information.

![RAID 0 striping diagram|150](internal/assets/150px-RAID_0.svg.png)

Raid 0 does **not** provide redundancy of fail safes. If one of the discs is lost, it will cause the entire array to fail with total data loss.

## Usage

Increased performance, splitting large logical volumes into two smaller discs.
```

Note: Uses only the deepest child tags. Obsidian automatically links to parents.

## Key Takeaways

1. **Consistency is king** - Match existing patterns
2. **User's voice matters** - Check daily notes for tone
3. **Wikilinks freely** - Don't worry about missing targets
4. **Research thoroughly** - Wikipedia + web search
5. **Ask before adding** - Curiosities, inline tags, structural changes
6. **Filesystem over MCP** - For creating/updating (better diffs)
7. **Title = Filename** - Always match exactly
8. **No EM dashes** - Ever! Use regular hyphens
9. **No dashed explanations** - Avoid text between dashes (AI pattern)
10. **Templates are your friend** - Check `internal/templates/` first
11. **Modern tag format** - Only deepest child tags (Obsidian links parents)
12. **Full image paths** - Always use `internal/assets/path/to/image.ext`
13. **Organize assets** - Use appropriate subdirectories (root, canvases, excalidraw, media)
14. **Write naturally** - Avoid AI-like hedging, formal transitions, or overly structured lists
