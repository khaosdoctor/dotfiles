---
disable-model-invocation: false
user-invocable: true
allowed-tools:
  - Bash:
      - rtk
      - date
      - find
      - ls
      - cat
      - jq
      - mkdir
      - gh
      - git
  - Read
  - Edit
  - Write
  - Glob
  - Grep
  - Agent
  - Skill
  - mcp__claude_ai_Slack__slack_search_public
  - mcp__claude_ai_Slack__slack_search_public_and_private
  - mcp__claude_ai_Slack__slack_search_channels
  - mcp__claude_ai_Slack__slack_search_users
  - mcp__claude_ai_Slack__slack_read_channel
  - mcp__claude_ai_Slack__slack_read_thread
  - mcp__claude_ai_Slack__slack_read_user_profile
  - mcp__claude_ai_Slack__slack_list_channel_members
  - mcp__claude_ai_Gmail__search_threads
  - mcp__claude_ai_Gmail__get_thread
  - mcp__claude_ai_Gmail__list_labels
  - mcp__claude_ai_Google_Calendar__list_events
  - mcp__claude_ai_Google_Calendar__get_event
  - mcp__claude_ai_Google_Calendar__list_calendars
  - mcp__claude_ai_Google_Drive__list_recent_files
  - mcp__claude_ai_Google_Drive__search_files
  - mcp__claude_ai_Google_Drive__get_file_metadata
  - mcp__claude_ai_Google_Drive__read_file_content
  - mcp__obsidian-mcp-tools__search_vault
  - mcp__obsidian-mcp-tools__search_vault_simple
  - mcp__obsidian-mcp-tools__search_vault_smart
  - mcp__obsidian-mcp-tools__get_vault_file
  - mcp__obsidian-mcp-tools__get_active_file
  - mcp__obsidian-mcp-tools__list_vault_files
  - mcp__obsidian-mcp-tools__get_server_info
---

# Follow Up on Work

Follow up on work initiatives and update work notes in the Obsidian vault. This skill does two things at once:

1. **Discovers** what's been happening across **Slack, Gmail, Google Calendar, Google Drive, and GitHub** since the last follow-up — so updates arrive pre-filled with real context, and brand-new projects that aren't in the tracking note yet get surfaced as candidates to add. Every discovered fact carries an explicit source citation; uncited claims are never asserted.
2. **Updates** the cycle as before: check in on each project, update individual work notes, keep the tracking note current, and connect progress to the competence-matrix goals.

The follow-up is **not bound to the projects already in the file**. Evidence from the sources can propose new initiatives, and existing projects come to the loop with a drafted update already in hand.

Nothing is written to the vault until it passes a **reconciliation gate** (Step 6): the target vault is confirmed, every claim is traced to a citation or flagged `needs confirmation`, and the voice file is loaded. Only then, and only after the user approves, do entries get written.

For Obsidian vault conventions, note format, wikilinks, and frontmatter rules, refer to the [Obsidian skill](../obsidian/SKILL.md) and its [vault structure](../obsidian/vault-structure.md) and [cheatsheet](../obsidian/cheatsheet.md).

## Writing as the user

Anything written into the vault is the user's own voice. **Before drafting any prose** — work-note updates, suggested initiative descriptions, brag entries, diary entries — internalize the `avoid-tropes` and `voice` skills if they are not already loaded in this session. Strip corporate tropes, no em-dashes, no TTS filler ("uh"/"eh"/"um"), and match the user's register.

## Invocation

### Direct command

```
/followup                   # discover + follow up since the saved checkpoint
/followup since=2026-05-01   # explicit start date for the discovery sweep (ISO 8601)
/followup no-sweep           # skip discovery, run the classic project-by-project loop only
```

### Implicit triggers

Also activates when the user says things like:
- "let me update my work for the day"
- "update my work notes" / "update the tracking note"
- "follow up on my projects"
- "let me update [specific project name]"

Resolve any natural-language dates ("since last Monday", "in the past week") to absolute ISO dates before proceeding.

## Tool Usage

- **Source MCP tools** (Slack / Gmail / Calendar / Drive) are pre-approved — use them freely, read-only. GitHub goes through the `gh` CLI (and `git`).
- **All shell commands must be prefixed with `rtk`** per the user's global RTK rule (e.g. `rtk gh pr list`, `rtk date -u +%Y-%m-%dT%H:%M:%SZ`).
- **Vault files**: MCP tools only for searching/fetching/reading; **filesystem tools** (Read, Edit, Write) for all edits and file creation — this keeps changes visible in diffs.

## Vault Discovery

Do NOT hardcode the vault path. Use the `find-obsidian` script:

```bash
rtk ~/.claude/bin/find-obsidian --vault
```

This skill writes to the **Default** vault (the human-read personal vault, `~/Documents/Obsidian/Default`). It is **never** the "AI Brainz" second-brain vault and never your own memory. If the discovered path resolves to anything other than the Default vault, stop and confirm the target with the user before writing.

Once found, locate these key paths within the vault:
- Work notes: `notes/work notes/`
- Up-to-speed digests: `notes/work notes/automated summaries/`
- Tracking note: `notes/tracking notes/What's going on at work.md`
- Brag document: `notes/tracking notes/Brag Document.md`
- Staff diary: `notes/tracking notes/Diary of a Staff Engineer.md` (read-only reference; never ingest or summarize)

## State

State file: `~/.claude/skills/followup/state.json` — a **symlink to `~/.claude/skills/up-to-speed/state.json`**. Both skills read and write the same checkpoint, so a sweep run by either advances the shared range.

```json
{
  "last_run_at": "2026-06-08T14:06:08Z",
  "range_end_of_last_run": "2026-06-08T14:06:08Z",
  "watchlist_people": [],
  "skip_channels": ["deploys", "alerts", "standup", "github-notifications"],
  "skip_keywords": ["Diary of a Staff Engineer"],
  "channel_allowlist_override": [],
  "gmail_labels_include": [],
  "gmail_labels_exclude": ["CATEGORY_PROMOTIONS", "CATEGORY_SOCIAL"],
  "calendars_include": [],
  "github_orgs": ["hemnet"],
  "github_repos_pinned": [],
  "github_skip_repos": []
}
```

Rules:
- If the file does not exist, **ask the user for a baseline start date** for the discovery sweep before running, then create the file after a successful run.
- `range_end_of_last_run` is the new run's discovery start date; the end is "now" (UTC).
- Update `last_run_at` and `range_end_of_last_run` only after a successful follow-up.
- Treat `skip_channels` and `skip_keywords` as case-insensitive substring matches.
- The state is **shared with `up-to-speed`** via the symlink, so editing skip/include lists or the checkpoint in one place affects both. If `up-to-speed` ran recently, its checkpoint is already the `range_start` here.

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
- **Other Tasks** — standalone to-dos (never modified by this skill unless the user asks)

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
- Optional `### Updated to-dos` or `### Todo` subsections — checkbox tasks live here, inside the project note, so they surface in the daily notes

New entries add a new `## [[YYYY-MM-DD]]` section at the bottom with bullet points.

## Flow

### Mode 1: Full follow-up (`/followup`)

#### Step 1: Resolve the discovery range

1. Read `state.json`. If absent, ask the user for a baseline start date and stop until answered.
2. If the user passed `since=...`, that overrides the checkpoint for this run only.
3. `range_start = since or range_end_of_last_run`; `range_end = now (UTC)`.
4. If the user passed `no-sweep`, skip Steps 2–3 entirely and go straight to the classic loop in Step 5 (no pre-filled context, no new-project discovery).

#### Step 2: Gather context (reuse a digest, or fan out)

First check for a shortcut: list `notes/work notes/automated summaries/` for an `up-to-speed` digest whose `range_end` is at or after `range_start`. If one covers the range, **read it and use its findings as the evidence base** — do not re-run the sweep. Tell the user you're reusing it.

Otherwise, run the fan-out. Launch parallel `Agent` calls (subagent_type `general-purpose`), one per bucket, each given `range_start`/`range_end` and the skip/include lists from `state.json`. Each agent pulls from **all relevant sources**, not just one.

Buckets:

1. **Initiatives & product** — Slack strategy/OKR/launch channels; Calendar review/strategy/roadmap events; Drive docs in initiative folders updated in range; GitHub product-repo PRs/issues with `feature`/`initiative`/roadmap labels.
2. **Backend platform & infra** — Slack platform/infra channels; Drive RFCs/design docs touched in range; Calendar architecture reviews; GitHub infra repos: merged PRs, new issues, releases, dependency bumps.
3. **Incidents & postmortems** — Slack incident channels; Gmail PagerDuty/status-page threads; Drive postmortem docs; GitHub issues labeled `incident`/`postmortem`, hotfix branches/PRs, reverts.
4. **DMs and @-mentions** — Slack DMs/mentions; Gmail threads where the user is To/Cc with an open ask; GitHub `gh api notifications`, review requests, @-mentions on issues/PRs/comments.
5. **Org & leadership** — Slack announce channels; Gmail HR/leadership threads; Calendar all-hands/1:1s/skip-levels.
6. **Threads & meetings I'm in** — Slack threads the user replied to; Calendar meetings the user attended/declined with linked docs; GitHub PRs/issues the user commented on with new activity.

Per-source guidance for each subagent:
- **Slack**: search restricted to the date range; public channels, private channels the user is in, DMs/mentions. Drop `skip_channels` and `skip_keywords` matches. Return bullet summaries with **Slack permalinks**, key people, explicit asks/decisions.
- **Gmail**: threads in range; honor `gmail_labels_include` (if non-empty), always exclude `gmail_labels_exclude`. Surface threads where the user is To/Cc with an unread reply or open ask. Return Gmail web links.
- **Google Calendar**: events in range across `calendars_include` (default: primary). Note attendees, attended/declined, linked docs. Highlight noteworthy reschedules/cancels only.
- **Google Drive**: recently-modified files in range the user owns or is shared on. Substantive doc changes only (new docs, ownership transfers, @-mentions in comments). Skip media.
- **GitHub** (`rtk gh ...`): for each org in `github_orgs` (skip `github_skip_repos`): `gh search prs --owner <org> --updated ">=<range_start>"` and the same for `issues`, focused on the user's involvement; `gh api notifications --paginate` filtered to range; for `github_repos_pinned` also pull releases, README/CHANGELOG/`docs/` changes, ADR additions; scan default-branch commit subjects per touched repo for themes. Return GitHub URLs.

**Citation discipline.** Every fact a subagent returns must carry an explicit citation: a permalink, message link, file URL, PR/issue/commit link, or calendar event reference. A fact the subagent cannot cite is not returned as fact — it is either dropped or returned flagged `needs confirmation`, never asserted. If a source returns nothing for a bucket, the subagent must say so explicitly — never fabricate.

#### Step 3: Match evidence to projects, and find the orphans

Read the tracking note. Extract all project entries from **Projects and initiatives** under `### Ongoing`, `### Waiting`, `### Not started or parked`, and `### Stalled`. Ignore `### Abandoned` and `### Done`.

Now reconcile the gathered evidence against that list:

- **Matched** — evidence that maps to an existing project. Draft a one-or-two-bullet update from it, with the source links, ready to pre-fill the loop. Note if the evidence suggests a status change (e.g. an entry under `Waiting` that clearly moved).
- **Orphan** — substantive activity (a launch, an RFC the user authored, a recurring thread, an incident the user owned, a new workstream) that maps to **no** existing project. These are candidate new initiatives.
- **Quiet** — existing projects with no evidence this period. They still go through the loop, just with no pre-filled update.

#### Step 4: Propose new initiatives

If there are orphans, present them first as a numbered list:

> Found activity that isn't tracked yet:
> 1. **[Proposed name]** (proposed status: Ongoing/Waiting/…) — one-line rationale + source link
> 2. …
> Which should I add as new work notes? (numbers, 'all', or 'none')

For each accepted initiative:
1. Create a work note in `notes/work notes/` named `YYYY-MM-DD-XXX - Initiative Name.md` (XXX = random 3-char alphanumeric ID), using the standard frontmatter and an initial `## [[YYYY-MM-DD]]` section seeded with the discovered context and source links.
2. Add its line under the right status header in the tracking note.
3. Confirm the name and proposed status with the user before writing.

The user can also volunteer initiatives the sweep missed — handle those the same way.

#### Step 5: Project-by-project loop (now pre-filled)

**Ask about every active project, one by one. Never silently skip a project just because the sweep found no evidence for it** — a quiet project still gets an explicit "any updates?" prompt. The only projects you don't prompt are ones already discussed earlier in this same conversation (don't re-ask what's been covered).

For each project (existing + newly added), present the current status and any drafted update:

> **[Project Name]** (current: _status_)
> Based on the sources: _drafted update bullets, with links_
> Apply this, edit it, or skip? (for quiet projects with no evidence: just "Any updates on this?")

The user may respond with:
- "yes" / "looks good" — accept the drafted update
- An edit or a fuller narrative — use their version
- "skip" / "no updates" — move on
- "done" — mark completed
- "stalled" / "abandoned" / "waiting" — change status category

**Never add tasks on your own.** If the work suggests follow-up to-dos, propose them and wait for explicit approval before writing anything: "I think these might be suitable tasks: 1. … 2. …". Only after the user picks do you add them as checkbox items in the project note's `### Updated to-dos` / `### Todo` subsection (so they surface in the daily notes), following the same format and voice standards as the rest. Never touch the standalone **Other Tasks** list unless the user explicitly asks.

Before moving to Step 6, re-scan the full active-project list against what you actually prompted and confirm none was missed. If any project never got an ask, ask about it now.

#### Step 6: Reconciliation pass (validate before writing)

Nothing is written to the vault until everything queued for it clears this gate. Run it over the full set of drafted updates, new initiatives, and proposed tasks:

1. **Confirm the target vault.** Resolve the write destination and verify it is the **Default** vault (`~/Documents/Obsidian/Default`), not the AI Brainz second-brain and not memory. If it resolves anywhere else, stop and confirm with the user.
2. **Trace every claim to a citation.** Each drafted bullet must map back to a cited fact from Step 2. Any claim with no citation is rewritten to drop the unsupported part, or marked `needs confirmation` and surfaced to the user — it is never written as established fact.
3. **Load the voice file before drafting prose.** Read the voice reference so the wording matches the user's register; do not invent personal details or tone.

Then present a **validated digest**: the per-project updates and new initiatives, each with its citations inline, and a separate short list of anything flagged `needs confirmation` or any project that stayed quiet/ambiguous. Ask the user to resolve the flagged items and confirm the digest. Only proceed to Step 7 after they approve.

#### Step 7: Apply updates

For each project that had an update, **confirm all changes before applying them**:

1. **Work note**: add a new `## [[YYYY-MM-DD]]` section at the bottom with the update as bullets (today's date via `rtk date +%Y-%m-%d`). Include source links where they add value. Match the existing format exactly.
2. **Tracking note**: update the italic status text on the project's line. If the status category changed, move the line to the correct header.
3. If done, check the box (`- [x]`) and move to `### Done`.

#### Step 8: Competence matrix check

After updates are applied, review them against the **Competence Matrix Goals** section. For each update that could relate to a goal:
- Suggest the connection: "Your update on **[Project]** could tie to your **[Goal Name]** goal — specifically the action about [action item]."
- Ask if they want to add it to the **Brag Document** and/or the **Staff Diary**.
- If yes, read the target note first to match its format, then append. Always confirm before writing.

#### Step 9: Update state

After the follow-up completes successfully, set `last_run_at` and `range_end_of_last_run` to `range_end` (UTC, ISO 8601) and write `state.json`.

### Mode 2: Update specific notes (implicit trigger)

When the user wants to update work notes without specifying which:
1. Read the tracking note.
2. Present a numbered list of all active projects (Ongoing, Waiting, Stalled, Not started).
3. Ask: "Which ones do you want to update? (numbers, or 'all')"
4. Optionally run the Step 2 sweep scoped to just those projects to pre-fill context, then follow Steps 5–8.

### Mode 3: Update a specific project (implicit trigger with project name)

When the user names a specific project:
1. Read the tracking note.
2. Best-effort match the name against entries in Projects and initiatives.
3. If ambiguous, ask for clarification.
4. Optionally pull recent source context for that project to pre-fill, then ask for the update and follow Steps 5–8.

## What NOT to Do

- Do NOT send messages, post in Slack/email, modify calendar/drive, or open/comment on GitHub — every source is read-only.
- Do NOT ingest or summarize `Diary of a Staff Engineer.md` (it's a destination only, on user request).
- Do NOT add tasks on your own — ever, even inside a project note. Always propose them as a numbered list and wait for explicit approval before writing. Never touch the standalone **Other Tasks** section unless the user asks.
- Do NOT change the format of existing entries — match what's already there.
- Do NOT update notes, create new initiatives, or apply pre-filled updates without confirming first.
- Do NOT fabricate progress or invent status changes — every pre-filled update must trace to real evidence, and if a source was empty, say so.
- Do NOT skip the competence matrix check at the end.
- Do NOT touch the Competence Matrix Goals section itself (only reference it for suggestions).
- If the discovery range exceeds 30 days, warn the user and offer to chunk it into weekly slices.

## Tuning

The user can edit `state.json` directly to add `watchlist_people`, extend `skip_channels`/`skip_keywords`, pin a `channel_allowlist_override` (restricts the Slack sweep when non-empty), adjust Gmail labels and `calendars_include`, or edit `github_orgs`/`github_repos_pinned`/`github_skip_repos`.
