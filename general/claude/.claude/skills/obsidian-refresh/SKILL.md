---
name: obsidian-refresh
description: "Run Lucas's whole AI Brainz vault maintenance routine in one go: health, learn, board, emerge, catchup, projects, reconcile, visualize, synthesize. Use when the user says obsidian refresh, /obsidian-refresh, refresh the vault, or run the full vault routine. Optional argument: only <steps> or skip <steps>."
user-invocable: true
---

# Obsidian refresh

Runs nine vault commands as three parallel waves instead of nine separate runs. This skill only orchestrates. The steps of each command live in its own file, so read the file and follow it. Do not restate or copy it.

## Paths

Paths change per machine. Resolve these before anything else and never hardcode them:

| Placeholder | Meaning | Confirm by |
|---|---|---|
| `<vault>` | AI Brainz vault | holds `_CLAUDE.md` and `index.md` |
| `<default>` | Default vault (read-only) | holds `.obsidian/`, is not `<vault>` |
| `<repos>` | root of Lucas's git repos | holds git repos |

For each one:

1. Look for an entry in the memory files (`MEMORY.md` and what it points to), like `OBS:vault@...`.
2. If none, search the disk, for example `find ~ -maxdepth 6 -iname "*AI Brainz*" -type d` for `<vault>`, or `find ~ -maxdepth 6 -name .obsidian -type d` for `<default>`.
3. Accept a candidate only if it passes the confirm check.
4. If no candidate passes, or more than one does, ask Lucas for the path and wait. Never guess.

Every placeholder in this file means its resolved absolute path. Paste the resolved paths into agent prompts, never the placeholders.

## Vault pin

- Write only to `<vault>`, through the filesystem (Read, Write, Edit, Bash). Never the obsidian MCP, which is bound to the Default vault.
- Read-only context sources, never written: `<default>` and Claude Code transcripts under `~/.claude/projects/`.
- The command files below carry a "VAULT LOCATION" header that pins AI Brainz. Keep that pin when you quote or summarize them.
- Writing as Lucas, posting, sending or anything outward-facing is never part of this skill.

## Arguments

Optional. `only health,projects` runs just those. `skip visualize` runs all but those. Default is all nine. Drop skipped steps from every wave.

## Command files

All under `~/.claude/commands/` (symlinks into `~/.claude/skills/obsidian-second-brain/commands/`, inside the dotfiles repo). The plugin copies under `~/.claude/plugins/cache/obsidian-second-brain/` (any version) have no vault pin, so never use those.

| Step | File |
|---|---|
| health | `obsidian-health.md` |
| learn | `obsidian-learn.md` |
| board | `obsidian-board.md` |
| emerge | `obsidian-emerge.md` |
| catchup | `obsidian-catchup.md` |
| projects | `obsidian-projects.md` |
| reconcile | `obsidian-reconcile.md` |
| visualize | `obsidian-visualize.md` |
| synthesize | `obsidian-synthesize.md` |
| recap | `obsidian-recap.md` |

Projects scope for this skill: every repo under `<repos>`, plus Claude Code transcripts, plus Default vault mentions (read-only).

Learn scope: from the day after the newest `Knowledge/YYYY-MM-DD — Learnings Review.md` to today, so no stretch goes unreviewed. Recap scope: the last 2 months unless the argument says otherwise.

Folder mapping: this vault has no `wiki/` or `raw/`. Read `wiki/concepts/` and `wiki/decisions/` as `Knowledge/` (ADRs are `Knowledge/ADR-*.md`, pattern reports are `Knowledge/Synthesis — *.md`), `wiki/projects/` as `Projects/`, `wiki/entities/` as `People/`, and `raw/` sources as recent `Knowledge/`, `Dev Logs/` and `Daily/` notes. The learnings review is saved as `Knowledge/<today> — Learnings Review.md`.

Read `<vault>/_CLAUDE.md` and `<vault>/index.md` once before starting, and pass the relevant rules into agent prompts.

## Setup

1. `today` = `date +%F`. `host` = `uname -n` (or `/etc/hostname`). `model` = the orchestrator's short model name.
2. Signature = `<host> · claude-code/<model>`. Subagents sign with their own model name.
3. Make a folder in the session scratchpad for raw findings. Each gatherer writes `<step>-<topic>.md` there.

## Model tiering

- Haiku for mechanical scans: health script and category checks, git state, file listing, link checks.
- Sonnet for judgment: contradictions, synthesis, postmortem clustering, transcript summaries.
- Never a tier above the orchestrator. Try Haiku first.

## Wave 1: read-only gatherers

Launch all in one message. Nothing in the vault is written in this wave.

- **health**: run the health script named in `obsidian-health.md` first, then one agent per category from that file.
- **learn**: gatherers per `obsidian-learn.md`.
- **emerge**: gatherers per `obsidian-emerge.md`. Share the daily-note, dev-log and decisions readers with learn. Read them once.
- **board**: board check per `obsidian-board.md`, report only.
- **catchup**: check the queue per `obsidian-catchup.md`. List what waits. Processing needs Lucas.
- **projects**: git state of every repo under `<repos>` (one agent per group of repos), transcript summaries (Sonnet), Default vault mentions (read-only).

Each agent saves raw findings to the scratchpad and returns a short summary with file paths.

## Wave 2: writers

Launch together once wave 1 is done. Agents read the scratchpad findings.

- **reconcile** per `obsidian-reconcile.md`. Auto-resolve clear winners. Document ambiguous cases in the note and in the report.
- **synthesize** per `obsidian-synthesize.md`.
- **visualize** per `obsidian-visualize.md` (the canvas).
- **projects**: write each project note's `## Last overview` section per `obsidian-projects.md`. Split the notes across 3 or 4 agents by batch, no note in two batches.
- **learnings review**: one writer for the learnings review note, from the learn and emerge findings.

Writers never touch `Logs/`, the daily note, `index.md` or the folder catalogs. Each returns the files it wrote or changed, plus one log line.

## Wave 3: main thread only

1. Run `python3 "<vault>/Scripts/build_index.py" <today>` once, after all notes are added, renamed or deleted. The script finds the vault from its own location, so no `cd`. It keeps any description already in a catalog, so first delete the catalog row of every note whose `description:` reconcile or a writer changed; the rebuild then re-extracts it.
2. Append every operation-log line to `Logs/<today>.md`, each ending with the signature in backticks.
3. Update today's daily note: a `## Work` bullet ending with the signature. Add `written-by` to frontmatter.
4. Write the recap per `obsidian-recap.md` from the daily notes, using the wave 1 dev-log and decisions findings. The daily notes for 2 months are about 40k tokens, so the main thread can read them directly.
5. Print one combined report grouped by command: what ran, what changed (paths), what needs Lucas.

## Safety

- Safe fixes may run: frontmatter on a log note, unwrapping a fenced note, adding a missing link.
- Destructive fixes (merge, archive, delete, rename) are only listed with paths and reasons. They run after Lucas confirms.
- Unknown facts are marked TBD. Never guess.

## Prompt block for every subagent

Paste this into each subagent prompt in plain English. Haiku does not follow shorthand.

- Never use shell heredocs to create or edit files. Use Edit for existing files and Write for new files.
- Re-read a note right before you edit it. Sync tools rewrite notes between reads.
- Do not use `cd`. Use absolute paths only.
- Do not use `pkill -f` or `pgrep -f` (they match your own shell), do not `echo` lines starting with `=`, and wrap any recursive grep or long loop over the vault in `timeout 60`.
- The only vault you may write is `<vault>`. Never write `<default>`, `<repos>`, or `~/.claude/projects/`. Those are read-only.
- Use the filesystem, never the obsidian MCP.
- Never invent facts. Write TBD for anything you cannot confirm. Cite the file path for every claim.
- No em-dashes. Plain, short sentences. Use straight quotes and `->` arrows.
- Sign every note you write or change. Add to frontmatter `written-by:` a new item `"<today> · <host> · claude-code/<your model>"`, and never replace earlier items. Do not sign older notes by guessing.
- Do not write `Logs/`, the daily note, `index.md` or any folder catalog. Return a log line instead. The main thread writes those.
- Do not merge, archive, delete or rename notes. List them in your report instead.
- Do not post, send or write anything outward-facing, and do not write as Lucas.
- Your model tier is fixed by the orchestrator. Do not spawn agents above it.
