---
name: post-mortem
description: "Write a blame-assigning post-mortem (names the responsible agent, model or person and the act) for something that went wrong: an outage, a failed project, a bad deploy, a botched agent run, a missed deadline. Covers initial validation, impact, detection, timeline, root causes, mitigation, what went well and badly, learnings, cleanup still open, guards and owned action items. Saves the file wherever the user says. Use whenever the user says post-mortem, postmortem, PM, incident review, retro on a failure, RCA, root cause analysis, 'write up what went wrong', or 'what did we learn from X', even when they never say the word post-mortem. For saving into the AI Brainz vault use obsidian-post-mortem instead."
user-invocable: true
---

# Post-mortem

Write a record of something that went wrong so the next person (or agent) can avoid it. A good post-mortem is read when similar work starts, so it has to hold facts, causes, what is still broken, and rules that can be checked before acting. It is not a diary and not a verdict.

## Invocation

```
/post-mortem <subject> [save to <path>]
```

Infer the subject from the conversation when none is given. The save location is the user's call: if they did not name a path, ask once, then write there. Never pick a default folder silently.

## Workflow

### 1. Validate before writing

Confirm there is something to write up, and what state the world is in now. A post-mortem built on a wrong premise is worse than none.

- Name the event in one line and who judged it a failure. A verdict belongs to the person who gave it; write "Lucas judged X a failure", not "X failed", unless the failure is measurable (an outage, a failed test run).
- Read live state before stating it: `git log`, PR status, deployed version, balances, logs, the file on disk. A claim from memory, a code comment or an agent report is a claim, not a measurement. Stamp measured values with the date.
- Split what you know into **verified** (you saw it), **reported** (someone said it, name them) and **inferred** (your reading). Carry that split into the document.
- If the work involved other sessions or people, ask each for a facts-only account (what they did, in order, with times) before you write. Second-hand relays lose details. `ListAgents` then `SendMessage` reaches other local sessions.
- Ask the user only for what blocks you: save path, and whether the incident is still ongoing. Default everything else and say what you defaulted.

### 2. Draft early

Write the skeleton file as soon as the summary and timeline skeleton exist, then fill it in. Sessions restart and scratchpads vanish, so a draft on disk survives what a plan in your head does not.

### 3. Fill the sections

Use `references/template.md` as the starting file. Sections, in order:

| Section | What goes in it |
|---|---|
| **Header** | Date, subject, status (draft / open while recovery is still running / reviewed), severity or impact class when it applies, authors, sources, confidence |
| **Summary** | 2-4 sentences: what failed, how big, current state, attributed verdict |
| **Intended outcome** | What was meant to happen, so the miss is measurable |
| **Impact** | Split by cost type: time, money or usage, users or systems affected, rework, code or data state left behind, trust in reports. Numbers with units and dates |
| **Detection** | How and when it was noticed, by whom, how long after it began, and what should have caught it earlier. Note if it was found by luck |
| **Timeline** | Timestamped events from first cause to full recovery, one line each, source and confidence per row |
| **Root causes** | One chain per independent failure (planning, tooling, verification, process). Ask why until you reach something a rule or check could change. Each chain names the responsible actor and the act, with evidence (see step 5) |
| **Blame summary** | A short table: actor (agent/model/person), what they did or failed to do, evidence, cost. One row per responsible actor, including this session if involved |
| **Mitigation and recovery** | What was done to stop the damage and restore service, in order, and what each step achieved |
| **What went well / badly / was lucky** | Short bullets. Luck matters: it marks where the system had no protection. "Went well" is a keep list: practices worth repeating |
| **Outputs taken on faith** | Only when agents or automation were involved: which reports or claims were verified and which were accepted unchecked |
| **Learnings** | What this changes in how work is done. Each learning maps to a guard or action item; a learning with no guard tends to repeat |
| **Cleanup still open** | Concrete leftovers (branches, worktrees, flags, data, money), each dated "as of" |
| **Guards** | Rules phrased so someone can check them before acting. One line each |
| **Action items** | Owner, due date or TBD, tracking link. Separate fixes for this failure from changes that prevent the class of failure |
| **Open questions** | Things you could not establish |
| **Sources** | Links, paths, commit hashes, message references, verbatim |

Scale to the event. A one-hour mishap needs summary, timeline, root cause, guards. Drop sections that would be empty or padded; an honest "none" or "TBD" beats invented content. Severity and MTTR fields fit outages; for wasted spend or unreliable output, describe impact in plain terms instead.

### 4. Write the timeline carefully

- Anchor on clocks you can read: git commit and push times, PR and CI events, file mtimes, message timestamps. Tool calls and agent reports carry no times, so anything taken from them is approximate.
- One timezone for the whole file, stated once (UTC unless the user prefers local). Use `~` for approximate times and `TBD` for unknown ones; never round a guess into a clean time.
- Slow drift (many steps, compounding causes) has no single start time. Say so and anchor the timeline per step instead of inventing a start.
- Each row: time, what happened, source, confidence (`stated | high | medium | speculation`).
- Events only. Interpretation goes in root causes.
- Mark facts that exist only in closed sessions or second-hand reports as such.

### 5. Assign blame, with evidence

The user wants to know who failed and how, so this is a blame-assigning document, not a blameless one. Blameless formats protect people's willingness to talk; here the readers are future agents and the owner, and routing decisions depend on knowing which actor failed.

- Every root cause and every timeline failure names the responsible actor: the agent or session, its model (`glm-5.3`, `sonnet-5.5`), or the person, plus the specific act or omission ("subagent X reported step 4 done; `git log` shows no commit"). Unknown actor is `TBD`, never a guess.
- Blame is attached to evidence. Each blame statement cites a source (commit, log line, message, file). No source means mark it `speculation` or leave it out.
- Include the orchestrator, the reviewer and the author of this document when they contributed. Own the failures of your own session in the first person of the record ("this session accepted the report unchecked").
- Separate the actor's act from the missing check. Both go in: who did it, and which guard would have caught it. A blame list with no guards repeats the failure.
- Stay factual, not hostile: state what was done and what it cost. No sarcasm, no speculation about intent, no blame for things the actor was never in a position to know.
- If the user asks for a blameless version, drop the actor names and keep the rest.
- A document written by the party that failed needs an independent read before it is marked reviewed. If you were involved in the incident, say so in the header and ask for a second reader.
- Never fabricate to complete a section. Unknown means `TBD`.

### 6. Finish

Re-read the file for: unsourced claims, blame without evidence, causes with no named actor, times without a timezone, guards that cannot be checked, and sections that restate each other. Report the saved path and the open `TBD` items. Do not paste the whole document back into chat.

## Why these sections

The structure merges the main published formats: Google SRE (summary, impact, root cause, timeline, lessons with "where we got lucky", owned action items), Atlassian (leadup, fault, detection, response, recovery, five whys), PagerDuty (what happened, contributing factors, resolution) and Etsy-style debriefs (how decisions looked at the time; useful for the "what the actor knew" check, though this skill does not make the document blameless). Comparison and links are in `references/formats.md`; read it when the user asks for a specific house format or when adapting the template to an unusual incident.
