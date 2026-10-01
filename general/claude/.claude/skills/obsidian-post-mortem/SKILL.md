---
name: obsidian-post-mortem
description: "Write a post-mortem and save it into the AI Brainz vault (Postmortems/) following the vault's own rules: AI-first note, signed with host and agent, indexed, guards copied to papercuts, linked from the daily note and Logs. Use when the user says obsidian post-mortem, /obsidian-post-mortem, 'post-mortem into the vault', 'save the PM to AI Brainz', or asks for a post-mortem of an agent run, outage or failed project and the vault is the destination. For any other save location use the post-mortem skill."
user-invocable: true
---

# Obsidian post-mortem

Same job as the `post-mortem` skill, with one fixed destination: the AI Brainz vault. The method (validation, sections, timeline rules, blame rules) lives in `~/.claude/skills/post-mortem/SKILL.md` and `references/template.md`. Read them first and follow them; this file only adds what the vault changes. Do not copy their content here.

## Vault rules that change the work

1. **Locate the vault.** Path differs per machine. Check MEMORY.md for `OBS:vault@`, else `find ~ -maxdepth 6 -iname "*AI Brainz*" -type d`. Confirm `_CLAUDE.md` and `index.md` exist. Still missing: ask the user.
2. **Read before writing.** `_CLAUDE.md`, then `CRITICAL_FACTS`, `SOUL`, `CORE_VALUES` as the Identity Layer asks, and `~/.claude/skills/obsidian-second-brain/references/ai-first-rules.md`. Read `Postmortems/index.md` and any related post-mortem so you can link it.
3. **Filesystem only.** Read, Write and Edit on the vault path. Never the obsidian-mcp-tools MCP (it is bound to the Default vault). Never write to the Default vault. Re-Read a note right before each Edit, because sync rewrites notes between reads.
4. **Gather context from sources.** Per the vault's context rule, pull facts from Slack, Drive, Jira, local repos and `gh` where they apply, and keep each source as a verbatim path or URL. Fan out parallel agents for MCP lookups; keep the writes on the main thread.
5. **Search before claiming absence.** List and grep the vault for the project, people and earlier post-mortems under every alias before saying a note does not exist. Create a stub for a linked note that is missing.
6. **Never assume relationships.** Do not call someone a colleague or owner unless a source says so. Unknown is `TBD`.

## Steps

1. **Run the post-mortem method.** Validation, evidence, facts-only requests to involved sessions, timeline, root causes. Use the vault template as the base file (step 2), not the generic one.
2. **Create the note.** Copy `Templates/Post-mortem.md` (never edit templates) to `Postmortems/Post-mortem - <Subject> (YYYY-MM-DD).md`. Keep its headings and order, then add the generic sections that apply, in this order:
   - `## For future agent` (2-3 sentences: what failed, who judged it, "read the guards before repeating this kind of work"; link related post-mortems)
   - `## What was meant to happen`
   - `## What happened` (with `### Timeline` and `### Detection` underneath when they apply)
   - `## Root causes` (one numbered chain per cause, each with Responsible, Act, Evidence)
   - `## Blame summary` (table: actor, did or failed to do, evidence, cost)
   - `## Costs` (Time, Funds / usage, Other: rework, state left, trust in reports)
   - `## Mitigation and recovery`
   - `## What went well / badly / was lucky`
   - `## Outputs taken on faith` (agent runs only)
   - `## Learnings`
   - `## Cleanup still open (as of YYYY-MM-DD)`
   - `## Guards that would have prevented it`
   - `## Action items` (owner, due, tracking; TBD when unknown)
   - `## Open questions`
   - `## Related`

   Drop a section when it would be empty. The vault's own sections (For future agent, What was meant to happen, What happened, Root causes, Costs, Cleanup, Guards, Related) stay.
3. **Frontmatter.** Per the template: `date`, `type: postmortem`, `tags: [postmortem, ...]`, `ai-first: true`, `severity: low | medium | high`, `related-projects`, `related-people`, `sources`, `confidence`, `written-by`. Add `status: draft | open | reviewed`. The date is the real `YYYY-MM-DD`, never "today". `confidence` is `stated | high | medium | speculation`.
4. **Sign it.** `written-by` item format: `"YYYY-MM-DD · <host> · <agent>/<model>"`, host from `uname -n`, agent `claude-code`, model the short name you run on. Unknown means `TBD`. On update, append; never replace earlier items. Every Logs line and daily bullet you add ends with the signature in backticks.
5. **Write for the next agent.** Self-contained (no "see above"), `[[wikilinks]]` for every person, project and concept, recency date on external facts with the URL inline, no em-dash or curly quotes or Unicode math (use ` - `, straight quotes, ASCII operators), bullets over prose. Short: the vault's voice rule is least tokens that answer the thing. Check the text against the ban lists in `~/.claude/CLAUDE.md` before saving.
6. **Verdicts and blame.** This is a blame-assigning note (Lucas's instruction 2026-10-02): name the responsible agent, session, model and person for each root cause, with the act and the evidence, and fill the Blame summary table. Lucas's verdict is his own: attribute it. Unknown actor is `TBD`, never a guess; blame without a source is `speculation`. Include the orchestrator and your own session when involved. Refer to agents by their session name and model, e.g. `second-brain-analyser-main (opus-5.5)`.
7. **Propagate.** One pass, each with the signature:
   - `Postmortems/index.md`: add one line at the top of Entries (newest first): link, date, severity, one-sentence summary, guard count. The index is hand-maintained.
   - `papercuts.md` at the vault root: one line per guard group, format `YYYY-MM-DD | symptom | guard | project`, linking the post-mortem.
   - Today's `Daily/YYYY-MM-DD.md` Work section: one bullet linking the note.
   - `Logs/YYYY-MM-DD.md`: a `knowledge-create | [[note]]: root causes, costs, N guards` line.
   - The project note's Recent Activity gets a link; add person-note links only when a source ties them to it.
   - If a guard is a standing rule for all sessions, tell the user and let them decide where it lives. Do not edit `_CLAUDE.md` or `~/.claude/CLAUDE.md` on your own.
8. **Regenerate catalogs only if the generator exists.** Read `Scripts/README.md`; if `Scripts/build_index.py` is present on this machine, run `python3 Scripts/build_index.py YYYY-MM-DD` from the vault root. If it is absent, do not reimplement it; hand-edit the one catalog line the README describes and say so.
9. **Report.** Give the saved path, the files touched, the `TBD` items, and who should read it independently. If you were part of the incident, say so and ask for a second reader before the status moves to `reviewed`.

## Ask before

Deleting or archiving an existing note, and anything personal or financial beyond run costs. Everything else in the steps above is saved without asking, per the vault's auto-save rules.
