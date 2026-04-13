---
disable-model-invocation: false
user-invocable: true
description: "Save a memory in Sigil compressed format. TRIGGER: user says /remember, 'remember this', 'keep this in mind', 'note that', 'don't forget', or similar. Also invoke proactively when you notice something worth remembering long-term (feedback, corrections, project context, references)."
---

# Remember

Save information to the auto-memory system. The memory directory is at the path shown in the auto-memory system instructions in the system prompt.

## Argument: $ARGUMENTS

## Process

### If $ARGUMENTS is not empty:
1. Determine the memory type: `feedback`, `project`, `reference`, or `user`
2. Compress into Sigil format (see sigil-syntax.md in this directory). ALL types use Sigil — prose is a last resort only when no symbolic form is unambiguous.
3. Route by type:
   - **feedback** → append to `## Compressed Behavioral Rules` block in MEMORY.md under the matching domain code. Create a new 3-letter code if none fits.
   - **project/reference/user** → append to the appropriate section in MEMORY.md as a Sigil one-liner. Only create a separate file if the content genuinely can't fit one line.
4. Before writing, check for duplicates — update existing entries rather than adding new ones.

### If $ARGUMENTS is empty:
1. Scan the current conversation for anything worth remembering long-term.
2. For each item found, follow the process above.
3. If nothing is worth saving, say so.

## Output
- Show what was saved and where
- Show before (prose) → after (Sigil) for each entry
