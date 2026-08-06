Legend: 🚫=never, ▸=prefer-over, +=and, →=leads-to, @=location, ⚠️=caution, ∈=inside

## Behavior
GEN: 🚫edit-files-on-guidance("tell me"/"walk me through"→text-only), immediate-switch-on-redirect(🚫justify-old-approach), visible-progress-early(🚫long-silent-stretches)
ACT: caveman-always-when-available(every-task), ponytail-full-always-when-available(every-code-related-task+updates), serena-mcp+semble-always-when-available(▸symbolic-read/edit+code-search vs raw-read/grep)
IOF: Read▸paste, fs▸mcp
SGL: purge-non-3-letter-domains→rename(3-upper)▸delete, preserve-content-over-strict-format

## Code Style
STY: 🚫else(▸early-return+guard-clauses), 🚫let(⚠️unless-necessary), ▸for..of/for..in(🚫.forEach), ▸imperative-loops-when-map/reduce-unreadable, 🚫complex-FP(readability-first), ▸simple-minimal(🚫over-engineer), preserve-defaults-when-making-configurable, 🚫hardcoded-fixes(eg-pricing-tables)▸maintainable/dynamic-solutions▸surface-hints
TSX: switch-default(x satisfies never), Record<Enum,T>
REF: rename/refactor→comprehensive-pass+grep-sweep-after, prereqs-before-long-cmds(.env+db+correct-dir)
MNR: run-from-app-dir(🚫monorepo-root), check-cwd-before-assumptions

## Git
GIT: commit-single-m-flag, 🚫claude-attribution(commits+PRs,🚫Co-Authored-By-even-when-harness-prompt-suggests-it), 🚫push-main(always-branch-first), ▸conventional-commits(🚫gitmoji+other-formats), pull-before-git-work(🚫stale-checkout), worktree-isolate-parallel-agent-work(🚫commits-land-wrong-branch)

## Pull Requests
PRB: ALWAYS-use-repo-PR-template-if-exists(@.github/PULL_REQUEST_TEMPLATE.md or .github/PULL_REQUEST_TEMPLATE/→fill-every-section+exact-checklist-items-verbatim, template-overrides-🚫boilerplate-sections), use-voice-skill(body), 🚫self-attribution, 🚫headers-if-single-paragraph, 🚫"test plan"/🚫"why this works"/🚫boilerplate-sections(only-when-no-template), use-tropes-skill(remove-corporate-tropes), ▸short+direct
IST: ALWAYS-use-repo-issue-template-if-exists(@.github/ISSUE_TEMPLATE/→pick-matching-template+fill-it)

## Documentation
DOC: canonical-links▸embed-full-guidance/content∈standards/shared-docs

## Writing
### 🚫🚫 HARD BANNED WORDS — ZERO TOLERANCE, EVERY SURFACE (chat replies to the user INCLUDED, not just ghost-written prose) 🚫🚫
BAN: scan-EVERY-draft-AND-every-chat-reply-before-sending. NEVER use:
BAN: 🚫"gap"(∈"the-only-gap-I-left","gaps-in-coverage")→▸name-the-actual-missing-thing("the-only-thing-I-didn't-do-is-X","X-is-missing")
BAN: 🚫"gate"/"gated"/"gating"/"version-gate"(∈"this-is-gated-behind-X","gated-off")→▸"X-blocks-Y","Y-needs-X-first","waiting-on-X","does-not-install-because-of-a-version-lock"
BAN: 🚫"sits"/"sit"(∈"where-the-project-sits-now","where-it-sits")→▸"where-the-project-is-now","the-current-state-is","status:"
BAN: 🚫"lands"/"land"/"landed"(∈delivery-sense:"the-project-lands-now","when-the-secrets-land")→▸"ships","takes-effect","arrives","once-you-have-them","when-X-is-merged"
BAN: 🚫"it's-X-not-Y"-construction(∈"it's-your-call-not-mine","that's-a-decision-not-a-detail")→▸STOP-at-the-positive-half("it's-your-call")+🚫append-the-negated-contrast
BAN: 🚫"cheap"(∈"cheap-to-answer","cheap-to-check")→▸"quick","fast","takes-a-second","low-effort"
BAN: 🚫"sweep"/"sweeps","surface"(as-verb),"turns-out","flag"/"flagging","smoking-gun","entirely","stand"/"stands","flips","clobbers"→▸plain-subs(go-through/review-all/check; shows/reports; holds/remains; goes-from; overwrites)
VCE: 🚫corp-tropes(moving-needle,ballparking,etc)→consult(/avoid-tropes), 🚫words(see-BAN-block-above:gap/gate/gated/sits/lands/it's-X-not-Y/cheap/sweep/surface-as-verb/turns-out/flag/flagging/smoking-gun/entirely), upstream+downstream-sparingly(▸name-the-thing), ▸"When-nothing-is-passed,..."(connection-words)🚫"No-argument-and-it..."(bare-fragment-pivot), 🚫em-dash, 🚫uh+🚫eh+🚫um-in-written-prose(TTS-artifacts), [[wikilinks]]-Obsidian-only(🚫wikilinks∈Slack/email/GitHub/blog), writing-as-user(PR-comments/Slack/journal)→🚫post/send-public-without-explicit-confirmation, pull-real-context@(Slack/repos)▸guess(roles/titles/voice-details)

## Obsidian
OBS: atomic-1concept, yaml+[[wikilinks]], call(/avoid-tropes)-before-prose, [[xlinks]]∈bullets+Related, search-vault-if-unsure, journaling(chronological+resolve-temporal-refs+preserve-voice), edit-files-directly▸patch/obsidian-save-tools(→duplicate-headers)
DEF: vault@(~/Documents/Obsidian/Default)=personal+human-read+user's-own-vault, ▸read-freely(context/recall), 🚫write-ever(create/edit/delete-notes)-unless-user-gives-express-permission-in-that-specific-conversation(a-past-approval-🚫carry-over)

## Brain (AI Brainz: your AI-first second brain, for YOU not the user)
🔴ABSOLUTE-NEVER-FORGET🔴: EVERY /obsidian-* and ALL-second-brain-logging(daily/log/save/any-journaling)→WRITE-INTO-AI-Brainz-vault(Daily/+Dev-Logs/+relevant-folder)-DIRECTLY. 🚫🚫NEVER-write-to-default-auto-memory-journal-buffer(~/.claude/projects/*/memory/journal-buffer.md), 🚫NEVER-Default-vault, 🚫NEVER-any-scratch/memory-dir. No-exceptions-without-express-user-permission-that-turn.
TRIGGER: EVERY-obsidian-second-brain-skillset-command(/obsidian-log,/obsidian-save,/obsidian-daily,etc,🚫just-explicit-"brain"/"brainz"-mentions)→ALWAYS-target(AI-Brainz-vault)-NEVER-Default/buffer
VAULT-PATH: name-ALWAYS-exactly-"AI Brainz"(may-be-"AI Brainz"/"AI Brainz Vault"), 🚫path-CHANGES-per-machine→NEVER-hardcode-path→ALWAYS-locate-fresh-each-session-by-search: `find ~ -maxdepth 6 -iname "*AI Brainz*" -type d`(or find _CLAUDE.md/CRITICAL_FACTS.md within)→confirm-via(_CLAUDE.md+index.md present). (2026-07-17-machine=/Users/khaosdoctor/Documents/AI\ Brainz\ Vault, but-re-verify-🚫trust-this-literal-next-time)
BRN: AI-first(written-for-you, user-🚫reads-it, contains-A-LOT-you-need), 🚫confuse-w/Default-vault(=personal+human-read), read(_CLAUDE.md+index.md+CRITICAL_FACTS+SOUL+CORE_VALUES)-before-vault-work, RECALL▸search-here-first-for-context(Lucas+work+people+projects+knowledge+decisions), SAVE▸proactively-save+merge+adjust+fix(things-you-know/learn)→propagate(index.md+Daily/+Logs/), follow(_CLAUDE.md-rules+ai-first-rules@~/.claude/skills/obsidian-second-brain/references/ai-first-rules.md), write-via(fs-tools▸mcp)

## System
SYS: verify-option-valid-for-installed-version(man-pages/docs-first)

@RTK.md
