Legend: 🚫=never, ▸=prefer-over, +=and, →=leads-to, @=location, ⚠️=caution, ∈=inside

## Behavior
GEN: 🚫edit-files-on-guidance("tell me"/"walk me through"→text-only), immediate-switch-on-redirect(🚫justify-old-approach), visible-progress-early(🚫long-silent-stretches)
IOF: Read▸paste, fs▸mcp
SGL: purge-non-3-letter-domains→rename(3-upper)▸delete, preserve-content-over-strict-format

## Code Style
STY: 🚫else(▸early-return+guard-clauses), 🚫let(⚠️unless-necessary), ▸for..of/for..in(🚫.forEach), ▸imperative-loops-when-map/reduce-unreadable, 🚫complex-FP(readability-first), ▸simple-minimal(🚫over-engineer), preserve-defaults-when-making-configurable
TSX: switch-default(x satisfies never), Record<Enum,T>
REF: rename/refactor→comprehensive-pass+grep-sweep-after, prereqs-before-long-cmds(.env+db+correct-dir)
MNR: run-from-app-dir(🚫monorepo-root), check-cwd-before-assumptions

## Git
GIT: commit-single-m-flag, 🚫claude-attribution(commits+PRs), 🚫push-main(always-branch-first), ▸conventional-commits(🚫gitmoji+other-formats)

## Pull Requests
PRB: use-voice-skill(body), 🚫self-attribution, 🚫headers-if-single-paragraph, 🚫"test plan"/🚫"why this works"/🚫boilerplate-sections, use-tropes-skill(remove-corporate-tropes), ▸short+direct

## Writing
VCE: 🚫corp-tropes(moving-needle,ballparking,etc)→consult(/avoid-tropes), 🚫em-dash, 🚫uh+🚫eh+🚫um-in-written-prose(TTS-artifacts), [[wikilinks]]-Obsidian-only(🚫wikilinks∈Slack/email/GitHub/blog)

## Obsidian
OBS: atomic-1concept, yaml+[[wikilinks]], call(/avoid-tropes)-before-prose, [[xlinks]]∈bullets+Related, vault@(~/Documents/Obsidian/Default), search-vault-if-unsure, journal-jots(chronological+resolve-temporal-refs+preserve-voice)

## System
SYS: verify-option-valid-for-installed-version(man-pages/docs-first)

@RTK.md
