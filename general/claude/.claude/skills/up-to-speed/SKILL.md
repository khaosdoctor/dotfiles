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
  - mcp__obsidian-mcp-tools__list_vault_files
---

# Up to Speed

Catch the user up on activity since the last run (or since a given date) across **Slack, Gmail, Google Calendar, Google Drive, and GitHub**, cross-check findings against their Obsidian work tracker, and produce a concise digest note in the vault.

All Slack / Gmail / Calendar / Drive MCP tools are pre-approved for the user — use them freely. GitHub is accessed through the `gh` CLI (and `git` where useful).

All shell commands must be prefixed with `rtk` per the user's global RTK rule (e.g. `rtk gh pr list`, `rtk date -u +%Y-%m-%dT%H:%M:%SZ`).

## Invocation

### Direct command

```
/up-to-speed                  # since the saved checkpoint
/up-to-speed since=2026-05-01 # explicit start date (ISO 8601)
```

### Implicit triggers

Activate when the user says things like:
- "bring me up to speed (on slack / on work)"
- "what did I miss"
- "catch me up"
- "what's been happening at work"

Resolve any natural-language dates ("since last Monday", "in the past week") to absolute ISO dates before proceeding.

## State

State file: `~/.claude/skills/up-to-speed/state.json`

Shape:

```json
{
  "last_run_at": "2026-05-20T14:00:00Z",
  "range_end_of_last_run": "2026-05-20T14:00:00Z",
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
- If the file does not exist, **ask the user for a baseline start date** before running, then create the file after the run.
- `range_end_of_last_run` is the new run's start date. The new run's end is "now" (UTC).
- Update `last_run_at` and `range_end_of_last_run` only after a successful digest write.
- Treat `skip_channels` and `skip_keywords` as case-insensitive substring matches.

## Vault discovery

```bash
rtk ~/.claude/bin/find-obsidian --vault
```

Within the vault:
- Tracking note: `notes/tracking notes/What's going on at work.md`
- Diary to **ignore**: `notes/tracking notes/Diary of a Staff Engineer.md`
- Digest folder: `notes/work notes/automated summaries/` (lowercase; create if missing)

## Workflow

### 1. Resolve the date range

1. Read `state.json`. If absent, ask the user for `since` and stop until answered.
2. If the user passed `since=...`, that overrides the checkpoint for this run only.
3. `range_start = since or range_end_of_last_run`. `range_end = now (UTC)`.

### 2. Fan-out collection

Launch parallel `Agent` calls (subagent_type `general-purpose`) — one per topic bucket. Each agent gets the same `range_start`/`range_end` and the skip / include lists from `state.json`. Each agent should pull from **all relevant sources**, not just one.

Buckets:

1. **Initiatives & product** — Slack channels on strategy/OKRs/launches; Calendar review/strategy/roadmap events; Drive docs in initiative folders updated in range; GitHub product-repo PRs/issues with the `feature`, `initiative`, or roadmap labels.
2. **Backend platform & infra** — Slack platform/infra channels; Drive RFCs / design docs touched in range; Calendar architecture reviews; GitHub infra repos: merged PRs, new issues, releases, dependency bumps.
3. **Incidents & postmortems** — Slack incident channels; Gmail PagerDuty / status-page threads; Drive postmortem docs; GitHub: issues labeled `incident`/`postmortem`, hotfix branches/PRs, revert commits.
4. **DMs and @-mentions** — Slack DMs/mentions; Gmail threads where the user is To/Cc with an open ask; GitHub: `gh api notifications`, PRs requesting review from the user, @-mentions on issues/PRs/comments.
5. **Org & leadership** — Slack announce channels; Gmail HR/leadership threads; Calendar all-hands / 1:1s / skip-levels.
6. **Threads & meetings I'm in** — Slack threads the user replied to; Calendar meetings the user attended (or declined) in range with linked agendas/docs; GitHub PRs/issues the user has commented on with new activity.

Per-source guidance for each subagent:

- **Slack**: search restricted to the date range. Cover public channels, private channels the user is in, and DMs/mentions. Filter out messages from `skip_channels` and messages containing any `skip_keywords`. Return bullet summaries with **Slack permalinks**, key people, explicit asks/decisions.
- **Gmail**: search threads in range; honor `gmail_labels_include` (if non-empty) and always exclude `gmail_labels_exclude`. Surface threads where the user is on To/Cc and there's an unread reply or open ask. Return Gmail web links per thread.
- **Google Calendar**: list events in range across `calendars_include` (default: primary). Note attendees, attended/declined status, linked docs/agendas. Highlight only noteworthy reschedules/cancels for recurring 1:1s.
- **Google Drive**: list recently-modified files in range that the user owns or has been shared on. Focus on substantive doc changes (new docs, ownership transfers, comments where the user is @-mentioned). Skip media.
- **GitHub** (via `rtk gh ...`): for each org in `github_orgs` (skipping `github_skip_repos`):
  - `gh search prs --owner <org> --updated ">=<range_start>"` and same for `issues` — focus on the user's involvement (author, reviewer, assignee, mentions).
  - `gh api notifications --paginate` filtered to the range for the user's review requests and mentions.
  - For `github_repos_pinned`: also pull recent releases (`gh release list`), README/CHANGELOG/`docs/` changes, and ADR additions (`docs/adr/`, `architecture/`, `rfcs/`). Read those files when they look load-bearing.
  - For each repo touched in range, scan commit subjects on the default branch to spot themes (use `gh api repos/{owner}/{repo}/commits?since=...`).
  - Return GitHub URLs per item.

If a source returns no relevant results for a bucket, the subagent must say so explicitly — never fabricate.

### 3. Cross-check with Obsidian

After fan-out completes:
1. Read `What's going on at work.md` and skim the work notes folder.
2. **Skip** `Diary of a Staff Engineer.md` entirely.
3. For each finding, classify:
   - **Already tracked** — link to the existing work note.
   - **Suggested new entry** — would belong under `### Ongoing`, `### Waiting`, etc.
   - **Suggested status change** — existing entry whose status looks stale given new evidence.

Do **not** edit work notes automatically — surface suggestions in the digest and let the user decide via `/followup`.

### 4. Write the digest note

Path: `notes/work notes/automated summaries/{YYYY-MM-DD-HHmm} - Up to Speed.md` (UTC timestamp; folder is lowercase).

Frontmatter is what makes the Dataview index work — keep `type: up-to-speed`, `range_start`, and `range_end` exactly as named.

Template:

```markdown
---
type: up-to-speed
created: {ISO timestamp}
range_start: {ISO}
range_end: {ISO}
sources: [slack, gmail, calendar, drive, github]
aliases: []
tags: [automated-summary, up-to-speed]
---

# Up to Speed — {range_start} → {range_end}

## TL;DR
- 3–6 bullets, highest-signal items only.

## Action required
> Anything addressed to the user, decisions needed, questions awaiting reply.
- [ ] [Short description]([source permalink]) — context, who's asking, source (slack/email/calendar/github).

## By topic

### Initiatives & product
- …

### Backend platform & infra
- …

### Incidents & postmortems
- …

### DMs and @-mentions
- …

### Org & leadership
- …

### Threads & meetings I'm in
- …

## People watchlist
{Only render if state.json has watchlist_people. One bullet per person hit.}

## Cross-check with Obsidian

### Already tracked
- [[Existing work note]] — what changed vs. note (slack/email/calendar/github).

### Suggested new entries
- **Title** (proposed status: Ongoing/Waiting/…) — rationale, source permalink.

### Suggested status changes
- [[Existing note]] — current status → suggested status, evidence.

## Track-over-time candidates
- Recurring threads / multi-week topics worth a dedicated note or running ledger entry.

## Coverage notes
- Channels skipped: …
- Repos skipped: …
- Sources queried: slack ✓ / gmail ✓ / calendar ✓ / drive ✓ / github ✓
- Any gaps, truncations, or access errors.
```

### 5. Ensure the index exists on `What's going on at work.md` (one-time)

Read the tracking note. **If** it already contains a `## Recent catch-ups` heading, do nothing — Dataview will refresh the table automatically as new digest notes are written.

If the section is missing, append the following block **once** to the end of the file, then never touch it again:

````markdown

## Recent catch-ups

```dataview
TABLE WITHOUT ID
  file.link AS "Catch-up",
  range_start AS "From",
  range_end AS "To"
FROM "notes/work notes/automated summaries"
WHERE type = "up-to-speed"
SORT file.name DESC
LIMIT 5
```
````

The Dataview query is the source of truth. Subsequent runs must never edit `What's going on at work.md` again.

### 6. Update state

After the digest is written successfully:
- Set `last_run_at` and `range_end_of_last_run` to `range_end` (UTC, ISO 8601).
- Write `state.json`.

### 7. Present the summary in chat

Print to the user:
- A 5–10 line synopsis of the digest (TL;DR + count of action items).
- The path to the new note.
- Suggested follow-up additions and status changes, asking which (if any) to apply via `/followup`.

## Guardrails

- **Never** ingest or summarize `Diary of a Staff Engineer.md`.
- **Never** edit existing work notes. The tracking note is edited at most **once** to add the `## Recent catch-ups` section; after that, never again.
- **Never** send messages, post in Slack, send email, modify calendar/drive, or open/comment on GitHub — read-only across all sources.
- If a source returns no results for a bucket, say so explicitly in `Coverage notes`; do not fabricate.
- If the date range exceeds 30 days, warn the user and offer to chunk the run into weekly slices.

## Tuning

The user can edit `state.json` directly to:
- Add people to `watchlist_people` (Slack user IDs or display names).
- Extend `skip_channels` / `skip_keywords`.
- Pin a `channel_allowlist_override` — if non-empty, restricts the Slack sweep to just those channels.
- Adjust `gmail_labels_include` / `gmail_labels_exclude` and `calendars_include`.
- Edit `github_orgs`, `github_repos_pinned`, `github_skip_repos`.
