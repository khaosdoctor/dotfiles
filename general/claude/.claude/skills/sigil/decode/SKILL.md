---
user-invocable: true
disable-model-invocation: false
allowed-tools: Read(*)
description: "Decode a Sigil-compressed snippet back into plain prose. Use when the user wants to verify what a Sigil entry means, or when reading memory entries that need human-readable explanation."
---

# /sigil:decode

Translate a Sigil-compressed entry into plain, readable prose.

## Sigil Format

See the `sigil-syntax.md` reference file in the `remember` skill directory for the full format specification.

## Argument: $ARGUMENTS

Decode the Sigil snippet provided in `$ARGUMENTS` into plain English.

## Token Counting

Estimate only — no external calls:
```bash
echo $(( $(wc -w < FILE) * 13 / 10 ))
```
(word count × 1.3 ≈ BPE tokens)

## Process

1. Read the Legend from `sigil-syntax.md` to ensure correct operator interpretation
2. Parse each token using the operator definitions
3. Output the decoded meaning as clear prose — one sentence or short paragraph per entry
4. Count tokens for both the Sigil input and the decoded prose output

## Output format

```
Input:   STY:🚫vowel-strip,readable-words▸symbols
Decoded: Never strip vowels. Prefer readable words over symbols in Sigil entries.
Tokens:  ~5 → ~18 (+260%)
```

If `$ARGUMENTS` is empty, ask the user to provide a Sigil snippet to decode.
