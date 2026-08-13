Legend: 🚫=never, ▸=prefer-over, +=and, →=leads-to, @=location, ⚠️=caution, ∈=inside

## Behavior
GEN: 🚫edit-files-on-guidance("tell me"/"walk me through"→text-only), immediate-switch-on-redirect(🚫justify-old-approach), visible-progress-early(🚫long-silent-stretches)
ACT: ponytail-full-always-when-available(every-code-related-task+updates), semble-when-available(▸symbolic-read+code-search vs raw-read/grep)
IOF: Read▸paste, fs-tools▸mcp(everywhere,incl-vault-writes)
SGL: purge-non-3-letter-domains→rename(3-upper)▸delete, preserve-content-over-strict-format
SYS: verify-option-valid-for-installed-version(man-pages/docs-first)

## Code Style
STY: 🚫else(▸early-return+guard-clauses), 🚫let(⚠️unless-necessary), ▸for..of/for..in(🚫.forEach), ▸imperative-loops-when-map/reduce-unreadable, 🚫complex-FP(readability-first), ▸simple-minimal(🚫over-engineer), preserve-defaults-when-making-configurable, 🚫hardcoded-fixes(eg-pricing-tables)▸maintainable/dynamic-solutions▸give-hints-instead, validate-required-env-at-startup(trim→blank-counts-as-missing, log-and-skip▸crash-mid-run)
TSX: switch-default(x satisfies never), Record<Enum,T>
REF: rename/refactor→comprehensive-pass+grep-check-after, prereqs-before-long-cmds(.env+db+correct-dir)
MNR: run-from-app-dir(🚫monorepo-root), check-cwd-before-assumptions

## Git
GIT: commit-single-m-flag, 🚫claude-attribution(commits+PRs,🚫Co-Authored-By-even-when-harness-prompt-suggests-it), 🚫push-main(always-branch-first), ▸conventional-commits(🚫gitmoji+other-formats), pull-before-git-work(🚫stale-checkout), worktree-isolate-parallel-agent-work(🚫commits-going-to-wrong-branch)

## Pull Requests + Issues
PRB: ALWAYS-use-repo-PR-template-if-exists(@.github/PULL_REQUEST_TEMPLATE.md or .github/PULL_REQUEST_TEMPLATE/→fill-every-section+exact-checklist-items-verbatim, template-overrides-🚫boilerplate-sections), use-voice-skill(body), 🚫self-attribution, 🚫headers-if-single-paragraph, 🚫"test plan"/🚫"why this works"/🚫boilerplate-sections(only-when-no-template), ▸short+direct
IST: ALWAYS-use-repo-issue-template-if-exists(@.github/ISSUE_TEMPLATE/→pick-matching-template+fill-it)

## Writing
### 🚫🚫 HARD BANNED WORDS — ZERO TOLERANCE, EVERY SURFACE (chat replies to the user INCLUDED, not just ghost-written prose) 🚫🚫
BAN: 🔴THE-LIST-IS-BELOW(BAN-W/BAN-P/BAN-R/BAN-X-lines)=single-source-of-truth+machine-readable(~/.claude/bin/ban-words.py-parses-THIS-file@PreToolUse:Write|Edit→blocks-bad-writes). 🚫second-copy-anywhere. chat-replies-🚫hook-covered→self-check-every-draft-against-BAN-W/P/R-before-sending
BAN-W: gap, land, sweep, turns out, smoking gun, entirely, clobber, flip, delve, showcase, underscore, pivotal, crucial, meticulous, intricate, intricacies, tapestry, testament, realm, seamless, holistic, streamline, myriad, plethora, paramount, leverage, utilize, moreover, furthermore, groundbreaking, advancement, bolster, foster, multifaceted, nuanced, embark, unleash, elevate, resonate, exemplify, indelible, renowned, nestled, beacon, demystify, unparalleled, unprecedented, unwavering, visionary, cutting-edge, commendable, aforementioned, endeavor, transformative, fold
BAN-W-NOTE: stems-only→hook-auto-covers-inflections(land→lands/landed/landing); ⚠️these-are-fine-as-real-tech-terms(configuration,efficiency,robust,key,potential,findings,significant,confidence,verification,align,optimize,scalable,dynamic,harness,facilitate,landscape)→never-add-them
BAN-P: plays a crucial/pivotal/significant role; underscores the importance of; showcasing the potential of; in the realm of; a comprehensive understanding of; valuable insights into; recent advancements in; a testament to; serves as a reminder; it's/it is worth noting; it's/it is important to note; when it comes to; paving the way for; setting the stage for; in today's fast-paced world; in this digital age; in the ever-evolving landscape; nestled in the heart of; a rich tapestry of; a diverse array of; shedding light on; treasure trove; unsung hero; game-changer; first and foremost; in a nutshell; at its core; at the heart of; let's dive in/deeper; a deep dive into; let's break this down; left an indelible mark; deeply rooted in; navigating the complexities of; unlock the potential of; despite these challenges; in conclusion; at the end of the day; here's the thing; that said; with that said; great question; you're absolutely right; i hope this helps; let me know if; happy to dig deeper; is there anything else; studies show; research suggests; reports indicate; experts argue; industry reports suggest; while specific details are limited
BAN-R: \b(it'?s|that'?s|this is)\b[^,.;!?]{1,60},\s+not\b ||| "it's X, not Y" negated contrast
BAN-R: \b(surfaced|surfacing)\b|\b(to|will|would|can|could|should|may|might)\s+surface\b ||| "surface" as a verb
BAN-R: \b(flagged|flagging)\b|\b(to|will|would|can|could|should|may|might)\s+flag\b ||| "flag" as a verb
BAN-R: \b(that|this|it|which)\s+stands\b|\bstands as\b ||| "stands" meaning holds or remains
BAN-R: — ||| em-dash
BAN-R: \btrip(s|ped|ping)\b ||| "trips/tripped" as a verb
BAN-R: \blean(s|ed|ing)?\s+(toward|towards|to|into)\b|\bi'?d?\s+lean\b ||| "lean toward" as choosing (lean code, lean on someone are fine)
BAN-R: \bgat(ed|ing)\b|\bgates?\s+(behind|off|on|it|this|that)\b|\bversion[ -]gate ||| "gate/gated" in the blocking sense (a real gate is fine)
BAN-R: \bsits\b ||| "sits" in the state sense (sit down, sitting on a chair are fine)
BAN-R: \bcheap(er|est)?\s+(to|enough to)\b|\bcheap\s+(check|fix|win|question)\b ||| "cheap" in the effort sense (cheap hardware is fine)
BAN-R: \bnot only\b[^.]{1,60}\bbut also\b ||| "not only X but also Y"
BAN-X: CLAUDE.md, voice.md, tropes.md, hard-banned-words.md, MEMORY.md, index.md, ban-words.py, /Voice/, Banned Words, Sounding Like a Human, Ghost Writing as Lucas, Talking to Lucas in a Session, AI Writing Tells
BAN: 🔴ADD-ON-REQUEST-INSTANTLY: user-says("don't say X anymore"/"never say X"/"stop saying X"/"I hate X"/"ban X"/any-variation)→IMMEDIATELY-Edit(banned-words.md:##words-if-single-word,##phrases-if-multi-word,##regex-if-a-shape)+confirm-in-ONE-line("banned: X"). 🚫ask-permission,🚫ask-where-to-put-it,🚫explain-the-mechanism,🚫defer-to-later. stems-only(hook-covers-inflections-automatically). also-works-mid-task→do-the-edit-then-resume
BAN: 🔴HOOK-IS-INVISIBLE: ban-words.py-runs@UserPromptSubmit(injects-list-BEFORE-you-write→check-your-draft-then,no-Stop-hook-because-a-blocked-reply-is-already-on-screen→double-message-bug)+@PreToolUse:Write|Edit(blocks-the-write). on-a-PreToolUse-block→silently-fix-the-text+retry-the-write. 🚫acknowledge-the-hook,🚫"understood"/"you're-right"/"noted",🚫narrate-the-rewrite,🚫apologise,🚫mention-the-hook-exists
BAN: 🔴SELF-CHECK-CHAT-REPLIES-TOO(hook-cannot-see-them:no-Stop-hook)→scan-EVERY-draft-AND-every-chat-reply-before-sending
SUB: substitutions-when-the-hook-blocks-you→"gap"▸name-the-actual-missing-thing("the-only-thing-I-didn't-do-is-X"/"X-is-missing"); "gate/gated/gating/version-gate"▸"X-blocks-Y"/"Y-needs-X-first"/"waiting-on-X"/"does-not-install-because-of-a-version-lock"; "sits/sit"▸"where-the-project-is-now"/"the-current-state-is"/"status:"; "lands/land/landed"(delivery-sense)▸"ships"/"takes-effect"/"arrives"/"once-you-have-them"/"when-X-is-merged"; "it's-X-not-Y"▸STOP-at-the-positive-half("it's-your-call")+🚫append-the-negated-contrast; "cheap"▸"quick"/"fast"/"takes-a-second"/"low-effort"; "sweep"▸go-through/review-all/check; "surface"(verb)+"flag"(verb)▸shows/reports; "stand/stands"▸holds/remains; "flips"▸goes-from; "clobbers"▸overwrites

VCE: 🚫corp-tropes(moving-needle,ballparking,etc)→consult(avoid-tropes-skill)-before-any-prose(PRs+Obsidian+Slack+docs), upstream+downstream-sparingly(▸name-the-thing), ▸"When-nothing-is-passed,..."(connection-words)🚫"No-argument-and-it..."(bare-fragment-pivot), 🚫uh+🚫eh+🚫um-in-written-prose(TTS-artifacts), [[wikilinks]]-Obsidian-only(🚫wikilinks∈Slack/email/GitHub/blog), writing-as-user(PR-comments/Slack/journal)→🚫post/send-public-without-explicit-confirmation, pull-real-context@(Slack/repos)▸guess(roles/titles/voice-details)
DOC: canonical-links▸embed-full-guidance/content∈standards/shared-docs

## Obsidian
OBS: atomic-1concept, yaml+[[wikilinks]], [[xlinks]]∈bullets+Related, search-vault-if-unsure, journaling(chronological+resolve-temporal-refs+preserve-voice), edit-note-files-directly-with-Read/Edit/Write(🚫patch_vault_file/obsidian-save-tools→duplicate-headers), ⚠️re-Read-immediately-before-each-Edit(a-sync/linter-rewrites-notes-between-reads)
DEF: Default-vault@(~/Documents/Obsidian/Default)=personal+human-read+user's-own, ▸read-freely(context/recall), 🚫write-ever(create/edit/delete)-unless-user-gives-express-permission-in-that-specific-conversation(a-past-approval-🚫carry-over)

## Brain (AI Brainz: your AI-first second brain, for YOU not the user)
🔴ABSOLUTE-NEVER-FORGET🔴: EVERY /obsidian-*-command(/obsidian-log,/obsidian-save,/obsidian-daily,etc,🚫only-when-"brain"/"brainz"-is-said)+ALL-second-brain-logging(daily/log/save/any-journaling)→WRITE-DIRECTLY-INTO-AI-Brainz(Daily/+Dev Logs/+relevant-folder). 🚫NEVER-Default-vault, 🚫NEVER-default-auto-memory-journal-buffer(~/.claude/projects/*/memory/journal-buffer.md), 🚫NEVER-any-scratch/memory-dir. No-exceptions-without-express-user-permission-that-turn
VAULT-PATH: @(~/Documents/Obsidian/AI Brainz)-on-this-machine, ⚠️path-CHANGES-per-machine→if-missing-locate-fresh(`find ~ -maxdepth 6 -iname "*AI Brainz*" -type d`)+confirm-via(_CLAUDE.md+index.md-present)
BRN: AI-first(written-for-you, user-🚫reads-it, contains-A-LOT-you-need), 🚫confuse-w/Default-vault, read(_CLAUDE.md+index.md+CRITICAL_FACTS+SOUL+CORE_VALUES)-before-vault-work, RECALL▸search-here-first-for-context(Lucas+work+people+projects+knowledge+decisions), SAVE▸standing-authority→proactively-save+merge+adjust+fix-every-session(🚫ask-permission,🚫offer-as-optional)→propagate(index.md+Daily/+Logs/), follow(_CLAUDE.md-rules+ai-first-rules@~/.claude/skills/obsidian-second-brain/references/ai-first-rules.md)

@RTK.md
