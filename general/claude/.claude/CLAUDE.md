Legend: 🚫=never, ▸=prefer-over, +=and, →=leads-to, @=location, ⚠️=caution, ∈=inside

## Behavior
GEN: 🚫edit-files-on-guidance("tell me"/"walk me through"→text-only), immediate-switch-on-redirect(🚫justify-old-approach), visible-progress-early(🚫long-silent-stretches)
ACT: caveman-always-when-available(every-task), ponytail-always-when-available(every-code-related-task)
IOF: Read▸paste, fs▸mcp
SGL: purge-non-3-letter-domains→rename(3-upper)▸delete, preserve-content-over-strict-format

## Code Style
STY: 🚫else(▸early-return+guard-clauses), 🚫let(⚠️unless-necessary), ▸for..of/for..in(🚫.forEach), ▸imperative-loops-when-map/reduce-unreadable, 🚫complex-FP(readability-first), ▸simple-minimal(🚫over-engineer), preserve-defaults-when-making-configurable, 🚫hardcoded-fixes(eg-pricing-tables)▸maintainable/dynamic-solutions▸surface-hints
TSX: switch-default(x satisfies never), Record<Enum,T>
REF: rename/refactor→comprehensive-pass+grep-sweep-after, prereqs-before-long-cmds(.env+db+correct-dir)
MNR: run-from-app-dir(🚫monorepo-root), check-cwd-before-assumptions

## Git
GIT: commit-single-m-flag, 🚫claude-attribution(commits+PRs), 🚫push-main(always-branch-first), ▸conventional-commits(🚫gitmoji+other-formats), pull-before-git-work(🚫stale-checkout), worktree-isolate-parallel-agent-work(🚫commits-land-wrong-branch)

## Pull Requests
PRB: ALWAYS-use-repo-PR-template-if-exists(@.github/PULL_REQUEST_TEMPLATE.md or .github/PULL_REQUEST_TEMPLATE/→fill-every-section+exact-checklist-items-verbatim, template-overrides-🚫boilerplate-sections), use-voice-skill(body), 🚫self-attribution, 🚫headers-if-single-paragraph, 🚫"test plan"/🚫"why this works"/🚫boilerplate-sections(only-when-no-template), use-tropes-skill(remove-corporate-tropes), ▸short+direct
IST: ALWAYS-use-repo-issue-template-if-exists(@.github/ISSUE_TEMPLATE/→pick-matching-template+fill-it)

## Documentation
DOC: canonical-links▸embed-full-guidance/content∈standards/shared-docs

## Writing
VCE: 🚫corp-tropes(moving-needle,ballparking,etc)→consult(/avoid-tropes), 🚫words(sweep/lands/surface-as-verb/turns-out/gated), upstream+downstream-sparingly(▸name-the-thing), ▸"When-nothing-is-passed,..."(connection-words)🚫"No-argument-and-it..."(bare-fragment-pivot), 🚫em-dash, 🚫uh+🚫eh+🚫um-in-written-prose(TTS-artifacts), [[wikilinks]]-Obsidian-only(🚫wikilinks∈Slack/email/GitHub/blog), writing-as-user(PR-comments/Slack/journal)→🚫post/send-public-without-explicit-confirmation, pull-real-context@(Slack/repos)▸guess(roles/titles/voice-details)

## Obsidian
OBS: atomic-1concept, yaml+[[wikilinks]], call(/avoid-tropes)-before-prose, [[xlinks]]∈bullets+Related, vault@(~/Documents/Obsidian/Default), search-vault-if-unsure, journal-jots(chronological+resolve-temporal-refs+preserve-voice), pull-correct-vault-first+confirm-target(Default-vs-AI-Brainz), edit-files-directly▸patch/obsidian-save-tools(→duplicate-headers)

## Brain (AI Brainz: your AI-first second brain, for YOU not the user)
BRN: vault@(~/Documents/Obsidian/"AI Brainz"/; usually a sibling of the Default vault under ~/Documents/Obsidian/, exact path varies per machine→if-unsure search(~/Documents/Obsidian/*/_CLAUDE.md)+(*/CRITICAL_FACTS.md)), AI-first(written-for-you, user-🚫reads-it, contains-A-LOT-you-need), 🚫confuse-w/Default-vault(@~/Documents/Obsidian/Default=personal+human-read), read(_CLAUDE.md+index.md+CRITICAL_FACTS+SOUL+CORE_VALUES)-before-vault-work, RECALL▸search-here-first-for-context(Lucas+work+people+projects+knowledge+decisions), SAVE▸proactively-save+merge+adjust+fix(things-you-know/learn)→propagate(index.md+Daily/+Logs/), follow(_CLAUDE.md-rules+ai-first-rules@~/.claude/skills/obsidian-second-brain/references/ai-first-rules.md), write-via(fs-tools▸mcp)

## System
SYS: verify-option-valid-for-installed-version(man-pages/docs-first)

@RTK.md
