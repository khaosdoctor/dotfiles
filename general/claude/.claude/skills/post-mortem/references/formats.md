# Published post-mortem formats

Read when the user wants a specific house style, or an incident does not fit the default template. Findings checked 2026-10-02.

| Source | Sections | Notable idea |
|---|---|---|
| [Google SRE Workbook, Postmortem Culture](https://sre.google/workbook/postmortem-culture/) | Executive summary, problem summary, background, impact, root causes and trigger, timeline and recovery, lessons learned (went well / poorly / lucky), action items, appendix | "Where we got lucky" exposes unprotected spots. Every user-affecting outage gets tracked action items with a single owner |
| [Atlassian postmortem template](https://www.atlassian.com/incident-management/postmortem/templates) | Summary, leadup, fault, impact, detection, response, recovery, timeline, five whys, lessons, corrective actions | Splits detection from response; five whys for root cause. Applied to severity 2 and above |
| [PagerDuty postmortem template](https://postmortems.pagerduty.com/resources/post_mortem_template/) | Overview, what happened, contributing factors, resolution, impact, timeline | Meeting within 5 business days; "contributing factors" instead of a single root cause |
| Etsy debriefing facilitation guide (Code as Craft blog) | Narrative of decisions as they made sense at the time, with the "morgue" tool as the record | Ask how a decision looked reasonable then, not who erred |

## What the default template takes from each

- Google: impact quantified, lessons split three ways, owned action items.
- Atlassian: detection as its own section, five whys.
- PagerDuty: several contributing factors, not one root cause.
- Etsy: what the actor knew at the time of the decision. Used to check that blame is fair; the document itself names actors (user's instruction 2026-10-02: blameful, name the agent).

## What agent-run incidents need that these formats lack

Gathered from sessions that ran multi-agent work (2026-10-02):

- Several independent failure chains in one event (planning, model choice, verification, unattended run). Write one root-cause entry per chain.
- Naming the model or agent that gave a false success report. Routing decisions depend on it.
- Cleanup still open, dated. Agent runs leave branches, worktrees and untracked files that humans forget.
- Guards phrased as checkable rules. These get copied into global rules and papercut logs.
- Impact measured in time, funds and usage limits rather than users and MTTR.
- A separate reader. The agent that failed should not be the only reviewer of its own post-mortem.
- Provenance per claim. Timestamps from agents are often "~", and some facts live only in closed sessions.
