---
disable-model-invocation: false
user-invocable: true
allowed-tools:
  - Bash:
      - date
      - find
      - ls
  - Read
  - Edit
  - Write
  - Glob
  - Grep
  - mcp__obsidian-mcp-tools__search_vault
  - mcp__obsidian-mcp-tools__search_vault_simple
  - mcp__obsidian-mcp-tools__search_vault_smart
  - mcp__obsidian-mcp-tools__get_vault_file
  - mcp__obsidian-mcp-tools__get_active_file
  - mcp__obsidian-mcp-tools__list_vault_files
  - mcp__obsidian-mcp-tools__get_server_info
---

# Follow Up on Work

Follow up on work initiatives and update work notes in the Obsidian vault. This skill manages the cycle of checking in on projects, updating individual work notes, and keeping the tracking note current.

For Obsidian vault conventions, note format, wikilinks, and frontmatter rules, refer to the [Obsidian skill](../obsidian/SKILL.md) and its [vault structure](../obsidian/vault-structure.md) and [cheatsheet](../obsidian/cheatsheet.md).

## Invocation

### Direct command

```
/followup
```

### Implicit triggers

Also activates when the user says things like:
- "let me update my work for the day"
- "update my work notes"
- "update the tracking note"
- "let me update [specific project name]"

## Tool Usage for Vault Files

- **MCP tools**: use only for searching, fetching, and reading vault files
- **Filesystem tools** (Read, Edit, Write): use for all edits and file creation — this keeps changes visible in diffs

## Vault Discovery

Do NOT hardcode the vault path. Use the `find-obsidian` script:

```bash
~/.claude/bin/find-obsidian --vault
```

Once found, locate these key paths within the vault:
- Work notes: `notes/work notes/`
- Tracking note: `notes/tracking notes/What's going on at work.md`
- Brag document: `notes/tracking notes/Brag Document.md`
- Staff diary: `notes/tracking notes/Diary of a Staff Engineer.md`

## Key Concepts

### Tracking note structure

The tracking note (`What's going on at work.md`) contains:
- **Competence Matrix Goals** — long-term goals with action items
- **Projects and initiatives** — organized under status headers:
  - `### Ongoing` — active work
  - `### Waiting` — blocked or waiting on someone
  - `### Not started or parked` — planned but not active
  - `### Stalled` — no progress, unclear path forward
  - `### Abandoned` — dead initiatives
  - `### Done` — completed work
- **Other Tasks** — standalone to-dos (ignored by this skill)

Each project line looks like:
```
- [ ] [[note-id - Project Name]] _status summary in italics_
```

### Work note structure

Individual work notes live in `notes/work notes/` and follow this format:
- YAML frontmatter with tags, title, createdAt, updatedAt
- H1 title matching the filename
- Date-headed sections (`## [[YYYY-MM-DD]]`) in chronological order
- Bullet points describing what happened
- Optional `### Updated to-dos` or `### Todo` subsections

New entries follow the same pattern: add a new `## [[YYYY-MM-DD]]` section at the bottom with bullet points.

## Flow

### Mode 1: Full follow-up (`/followup`)

#### Step 1: Ask about new initiatives

Ask: "Do you have any new initiatives to add before we start?"

If yes:
1. Ask for the initiative name and a brief description
2. Create a new work note in `notes/work notes/` following the naming convention: `YYYY-MM-DD-XXX - Initiative Name.md` where XXX is a random 3-character alphanumeric ID
3. Use the standard frontmatter format (see work note structure above)
4. Add the initiative to the appropriate status header in the tracking note
5. Then continue with the rest of the follow-up

#### Step 2: Collect projects

Read the tracking note. Extract all project entries from the **Projects and initiatives** section (everything under `### Ongoing`, `### Waiting`, `### Not started or parked`, `### Stalled`). Ignore `### Abandoned` and `### Done`.

#### Step 3: Ask one by one

For each project, present the current status (the italic text from the tracking note) and ask: "Any updates on **[Project Name]**? (current: _status_)"

The user may respond with:
- An update — record it
- "skip" or "no updates" — move on
- "done" — mark as completed
- "stalled" / "abandoned" / "waiting" — change status category
- A longer narrative — capture the key points

#### Step 4: Apply updates

For each project that had an update, **confirm all changes before applying them**:

1. **Update the work note**: Add a new `## [[YYYY-MM-DD]]` section at the bottom with the update as bullet points. Use today's date (get via `date +%Y-%m-%d`). Match the existing format exactly.
2. **Update the tracking note**: Update the italic status text on the project's line. If the status category changed (e.g., from Ongoing to Waiting), move the line to the correct header section.
3. If marked done, check the checkbox (`- [x]`) and move to `### Done`.

#### Step 5: Competence matrix check

After all updates are applied, review the updates against the **Competence Matrix Goals** section in the tracking note. For each update that could relate to a goal:

- Suggest the connection: "Your update on **[Project]** could tie to your **[Goal Name]** goal — specifically the action about [action item]."
- Ask if they want to add it to the **Brag Document** and/or the **Staff Diary**.
- If yes, read the target note first to match the existing format, then append the entry. Always confirm before writing.

### Mode 2: Update specific notes (implicit trigger)

When the user says they want to update work notes without specifying which:

1. Read the tracking note
2. Present a numbered list of all active projects (from Ongoing, Waiting, Stalled, Not started)
3. Ask: "Which ones do you want to update? (numbers, or 'all')"
4. Then follow Steps 4-5 from Mode 1 for the selected projects

### Mode 3: Update a specific project (implicit trigger with project name)

When the user mentions a specific project:

1. Read the tracking note
2. Best-effort match the project name against entries in the Projects and initiatives section
3. If ambiguous, ask for clarification
4. If found, ask for the update and then follow Steps 4-5 from Mode 1

## What NOT to Do

- Do NOT modify the "Other Tasks" section
- Do NOT change the format of existing entries — match what's already there
- Do NOT update notes without confirming with the user first
- Do NOT fabricate progress or invent status changes
- Do NOT skip the competence matrix check at the end
- Do NOT touch the Competence Matrix Goals section itself (only reference it for suggestions)
