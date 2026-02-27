---
disable-model-invocation: false
user-invocable: true
allowed-tools:
  - Bash:
      - date
      - find
      - ls
  - mcp__obsidian-mcp-tools__search_vault_smart
  - mcp__obsidian-mcp-tools__search_vault_simple
  - mcp__obsidian-mcp-tools__get_vault_file
  - mcp__obsidian-mcp-tools__create_vault_file
  - mcp__obsidian-mcp-tools__patch_vault_file
  - mcp__obsidian-mcp-tools__list_vault_files
---

# /writeup — Session Knowledge Writeup

Synthesize everything learned, fixed, debugged, or discovered during the current conversation into structured Obsidian notes, then link them in today's daily note TIL section.

## Invocation

```
/writeup
/writeup focus on the systemd part only
/writeup title: "How to configure keyd for Hyprland"
```

The user may optionally:
- Narrow scope with natural language ("focus on X")
- Provide a title override for a single-topic session
- Provide no args — in that case, infer everything from the conversation

---

## Step 1 — Extract knowledge from the conversation

Read the full conversation history and extract all distinct knowledge units:

- **Fixes**: things that were broken and got resolved
- **Root causes**: why something was failing
- **Learnings**: things discovered along the way (even dead ends)
- **Hypotheses**: things that were tried but didn't work (and why)
- **Configurations**: files, flags, settings that ended up working
- **Errors encountered**: exact error messages and what caused them
- **Caveats**: edge cases, version-specific behavior, gotchas

### Topic splitting rules

Group the extracted knowledge into **topics**. A topic is a coherent unit that a future reader would search for independently. Rules:

- If the session was about one problem with one fix: **single topic**
- If the session touched multiple unrelated systems (e.g. udev AND a Python bug): **split into separate topics**
- If a topic is a direct follow-up to a previous note (e.g. "we fixed the thing from last time"): **mark it as a follow-up** — you'll link to the original note later
- Keep topics focused. A good title is something you'd Google: `How to fix X`, `How to set up Y`, `Why Z happens`

---

## Step 2 — Search the vault for existing related notes

For **each topic**, search the vault using the MCP tools:

1. Use `search_vault_smart` with the topic as a semantic query
2. Also use `search_vault_simple` with key terms from the topic
3. Look for notes with `type/til` or `type/insight` tags that cover the same ground

### Merge decision

| Situation | Action |
|-----------|--------|
| Exact same topic, same note | **Update** — add new information, expand existing sections |
| Related note (same system, different angle) | **Create new** + link to the related note with a `> [!note] Follow-up to` callout |
| No related note found | **Create new** note |
| Partial overlap on one section | **Update** only the relevant section, don't duplicate |

When updating, always:
- Preserve existing content
- Add new findings under the relevant heading or append a new dated sub-section
- Update `updatedAt` and `lastEditedByAI` frontmatter fields

---

## Step 3 — Write or update each note

### Filename rules

- Human-readable with spaces: `How to fix udev hidraw permissions.md`
- Start with `How to` for procedural fixes, or a descriptive noun phrase for conceptual notes
- Natural capitalization, no kebab-case or snake_case
- `title` field in frontmatter must **exactly** match the filename minus `.md`

### Vault location

Prefer the **Obsidian CLI** (v1.12+) if available:

```bash
obsidian vault info=path
```

If the CLI is not installed, fall back to `~/.claude/bin/find-obsidian --vault`.

Place all writeup notes in `notes/` (root of notes folder, not a subfolder, consistent with existing TIL notes).

### Frontmatter (required)

```yaml
---
createdAt: <ISO 8601 timestamp>
title: "<Exact filename without .md>"
oneliner: "<One sentence: what this note is about>"
tags:
  - type/til
  - topic/<deepest relevant child>
  - meta/ai-assisted
aliases: []
updatedAt: <ISO 8601 timestamp>
lastEditedByAI: <ISO 8601 timestamp>
---
```

Get the current timestamp via:
```bash
date -u +"%Y-%m-%dT%H:%M:%SZ"
```

### Tag rules

- `type/til` always
- Use `topic/` hierarchy — **only the deepest child**: `topic/computing/software/linux/systemd` not `topic/computing`
- Add `meta/ai-assisted` always
- Add `meta/incomplete` only if the issue was not fully resolved in the session

### Content structure

Use this structure, including only the sections that apply:

```markdown
# <Note Title>

> [!note] Follow-up to
> This note is related to [[Previous Note Title]]. <One sentence on the relationship.>
(Only include this callout if there's a directly related existing note.)

## What happened

<Describe the situation, symptom, or starting point. What did the user observe? What was broken or unknown?>

## Root cause

<Why was it happening? Be specific — version numbers, file paths, subsystem behavior. This is the most valuable part.>

## What I tried (that didn't work)

<Dead ends, wrong hypotheses, misleading errors. Include these — they're as valuable as the fix.>

## Fix

<Exact steps to resolve. Include commands, config snippets, file paths. Use code blocks.>

## Key takeaways

<2-5 bullet points: the generalizable lessons. What would someone need to know to avoid this or understand it faster next time?>
```

Omit sections that aren't applicable (e.g., skip "What I tried" if there were no dead ends, skip "Root cause" if it was pure setup with no failure).

### Writing rules

- **No EM dashes** — use commas, hyphens, or restructure
- No hedging ("It's worth noting", "It should be mentioned")
- No formal transitions ("Moreover", "Furthermore")
- Direct, technical, first-person-aware but impersonal tone (like the existing VIRPIL note)
- Use `[[wikilinks]]` for other notes, tools, concepts that have vault pages
- Use code blocks for all commands, file contents, config snippets
- Use `**bold**` for key terms on first use

---

## Step 4 — Update today's daily note

### Find today's date

```bash
date +%Y-%m-%d
```

### Check if today's daily note exists

Look for `notes/daily notes/YYYY-MM-DD.md` in the vault.

**If it exists**: patch the `## TIL` section by appending new wikilinks.

**If it does not exist**: create it from the template at `internal/templates/Daily Note.md`:
1. Read the template
2. Replace `{{date}}` with today's date (`YYYY-MM-DD`)
3. Create the file at `notes/daily notes/YYYY-MM-DD.md`
4. Add `lastEditedByAI` and `meta/ai-assisted` to its frontmatter

### TIL entry format

For each note created or updated, add a line under `## TIL`:

```markdown
- [[Note Title]]
```

If the Obsidian CLI is available, use:
```bash
obsidian append path="notes/daily notes/YYYY-MM-DD.md" content="- [[Note Title]]"
```

Otherwise, use filesystem Edit tool to append under the `## TIL` heading. Avoid `patch_vault_file` with heading targets (known bug with duplicate headings).

Do NOT add duplicate entries if the note is already listed in TIL.

---

## Step 5 — Report back

After completing, tell the user:

- Which notes were **created** (with their titles)
- Which notes were **updated** (with what was added)
- Whether the daily note was created or already existed
- A one-line summary of each note

Example:

```
Created: "How to fix udev hidraw permissions after firmware update"
Updated: "How to set up HOTAS in Wayland" — added caveat about vendor-only matching
Daily note (2026-02-22): TIL entries added
```

---

## What NOT to do

- Do NOT fabricate information not present in the conversation
- Do NOT add speculative root causes — only include what was confirmed
- Do NOT overwrite existing note content — only extend it
- Do NOT create notes for things that were not resolved or are still unclear (use `meta/incomplete` tag instead and note the open question)
- Do NOT add multiple TIL entries for the same note
- Do NOT skip the vault search step — always check for existing notes before creating
