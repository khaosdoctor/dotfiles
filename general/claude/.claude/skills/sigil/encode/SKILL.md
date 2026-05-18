---
user-invocable: true
disable-model-invocation: false
allowed-tools: Read(*)
description: "Encode plain prose into Sigil compressed format without saving. Use when the user wants to preview how something would look in Sigil, or to test compression before committing."
---

# /sigil:encode

Compress plain prose into Sigil format — preview only, nothing is saved.

## Sigil Format

See the `sigil-syntax.md` reference file in the `remember` skill directory for the full format specification.

## Argument: $ARGUMENTS

Encode the prose provided in `$ARGUMENTS` into Sigil format.

## Token Counting

Estimate only — no external calls:
```bash
echo $(( $(wc -w < FILE) * 13 / 10 ))
```
(word count × 1.3 ≈ BPE tokens)

## Process

1. Read `sigil-syntax.md` for the full format spec
2. Determine the appropriate memory type: `feedback`, `project`, `reference`, or `user`
3. Select or propose the correct 3-letter domain code
4. Compress into Sigil notation following all writing rules
5. Count tokens before and after using the method above

## Output format

```
Input:   "Never mock the database in tests — we got burned when mocked tests passed but the prod migration failed"
Type:    feedback
Encoded: TST:🚫mock-db,integration-only
Tokens:  ~18 → ~5 (-72%)
```

Do not write to MEMORY.md. If the user wants to save the result, tell them to run `/sigil:remember` with the original prose.
