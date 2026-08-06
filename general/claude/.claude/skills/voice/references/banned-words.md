# Banned words (canonical list)

> The one place to edit. `~/.claude/bin/ban-words.py` reads this file on every turn, so a
> word added here takes effect on the next message with no code change. Explanations,
> substitutions and the research behind the list live in the AI Brainz vault under `Voice/`;
> this file is only the machine-readable list.
>
> One entry per line under each heading. Blank lines, `#` comments and `>` prose are
> skipped, so any explanation added to this file must be a blockquote. Matching is
> case-insensitive, and code spans, fenced blocks and URLs are skipped before matching,
> so technical usage inside backticks is always allowed.

## words

> Stems only. One entry covers its variations, so `land` also blocks lands, landed and
> landing. No plurals or -ing forms needed. Senses that need narrowing (a real gate versus
> "gated behind") live under regex instead.

gap
land
sweep
turns out
smoking gun
entirely
clobber
flip
delve
showcase
underscore
pivotal
crucial
meticulous
intricate
intricacies
tapestry
testament
realm
seamless
holistic
streamline
myriad
plethora
paramount
leverage
utilize
moreover
furthermore
groundbreaking
advancement
bolster
foster
multifaceted
nuanced
embark
unleash
elevate
resonate
exemplify
indelible
renowned
nestled
beacon
demystify
unparalleled
unprecedented
unwavering
visionary
cutting-edge
commendable
aforementioned
endeavor
transformative

## phrases

> Literal multi-word strings.

plays a crucial role
plays a pivotal role
plays a significant role
underscores the importance of
showcasing the potential of
in the realm of
a comprehensive understanding of
valuable insights into
gain valuable insights
recent advancements in
a testament to
serves as a reminder
it's worth noting that
it is worth noting
it's important to note
it is important to note
when it comes to
paving the way for
setting the stage for
in today's fast-paced world
in this digital age
in the ever-evolving landscape
nestled in the heart of
a rich tapestry of
a diverse array of
shedding light on
treasure trove
unsung hero
game-changer
first and foremost
in a nutshell
at its core
at the heart of
let's dive in
let's dive deeper
a deep dive into
let's break this down
left an indelible mark
deeply rooted in
navigating the complexities of
unlock the potential of
despite these challenges
in conclusion
at the end of the day
here's the thing
that said
with that said
great question
you're absolutely right
i hope this helps
let me know if
happy to dig deeper
is there anything else
studies show
research suggests
reports indicate
experts argue
industry reports suggest
while specific details are limited

## regex

> `pattern | label shown when it matches`. Python regex, case-insensitive.

\b(it'?s|that'?s|this is)\b[^,.;!?]{1,60},\s+not\b | "it's X, not Y" negated contrast
\b(surfaced|surfacing)\b|\b(to|will|would|can|could|should|may|might)\s+surface\b | "surface" as a verb
\b(flagged|flagging)\b|\b(to|will|would|can|could|should|may|might)\s+flag\b | "flag" as a verb
\b(that|this|it|which)\s+stands\b|\bstands as\b | "stands" meaning holds or remains
— | em-dash
\btrip(s|ped|ping)\b | "trips/tripped" as a verb
\blean(s|ed|ing)?\s+(toward|towards|to|into)\b|\bi'?d?\s+lean\b | "lean toward" as choosing (lean code, lean on someone are fine)
\bgat(ed|ing)\b|\bgates?\s+(behind|off|on|it|this|that)\b|\bversion[ -]gate | "gate/gated" in the blocking sense (a real gate or gateway is fine)
\bsits\b|\bsat\b(?=[^.]{0,20}\b(idle|untouched|unmerged|open)\b) | "sits" in the state sense (sit down, sitting on a chair are fine)
\bcheap(er|est)?\s+(to|enough to)\b|\bcheap\s+(check|fix|win|question)\b | "cheap" in the effort sense (cheap hardware, cheap flight are fine)
\bnot only\b[^.]{1,60}\bbut also\b | "not only X but also Y"

## exempt-paths

> A file whose path contains any of these is never checked, because these files
> legitimately quote the banned words.

ban-words.py
banned-words.md
index.md
CLAUDE.md
voice.md
tropes.md
hard-banned-words.md
MEMORY.md
/Voice/
Banned Words
Sounding Like a Human
Ghost Writing as Lucas
Talking to Lucas in a Session
AI Writing Tells

## false-positives

Real engineering vocabulary. Never add these to `words`, they only read badly as
prose filler and a hook cannot tell the difference: configuration, efficiency,
robust, key, potential, findings, significant, confidence, verification, unified,
align, optimize, scalable, dynamic, harness, facilitate, landscape.
