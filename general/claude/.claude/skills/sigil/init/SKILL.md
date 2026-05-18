---
user-invocable: true
disable-model-invocation: true
allowed-tools: Read(*), Edit(*), Write(*), Glob(*), Grep(*), Bash(uvx:*), Bash(wc:*), Bash(cat:*), Bash(rm:*)
description: "Migrate all existing memory files to Sigil compressed format. Discovers, inventories, compresses, and cleans up memory across all scopes."
---

# /sigil:init — Migrate All Memories to Sigil

One-time migration that converts all existing memory files into Sigil format.

## Sigil Format

See the `sigil-syntax.md` reference file in the `remember` skill directory for the full format specification.

## Backup

Before saving the compressed memories on top of the user's memories, backup their memories to `~/.claude/backups/sigil/memories` then overwrite the memories with the Sigil ones. Tell the user where the backup is and how they can restore it.

Keep the same structure as the original memory list.

## Token Counting

Use tiktoken (exact) with word-count fallback:

**Primary** — tiktoken via uvx:
```bash
uvx --with tiktoken python3 -c "
import tiktoken,sys
enc=tiktoken.get_encoding('cl100k_base')
print(len(enc.encode(sys.stdin.read())))
" < FILE
```

**Fallback** — if tiktoken/uvx unavailable:
```bash
echo $(( $(wc -w < FILE) * 13 / 10 ))
```
(word count × 1.3 ≈ BPE tokens, ~10% margin)

Always report which method was used.

## Step 1: Discover

Scan all memory locations:
- **User scope**: `~/.claude/projects/*/memory/` (all project memory dirs)
- **Project scope**: `.claude/memory/` in the current working directory
- **Global scope**: `~/.claude/memory/` if it exists

For each location, read `MEMORY.md` and all `.md` files linked from it or found in the directory.

## Step 2: Inventory

For each discovered memory file:
1. Read contents
2. Classify type: `feedback`, `project`, `reference`, or `user`
3. Count tokens (using the token counting method above)
4. Draft the Sigil-compressed version
5. Flag entries where prose is genuinely clearer than symbolic form (for manual review)

## Step 3: Present Plan

Show the user a summary table:
```
Location: ~/.claude/projects/-Users-foo/memory/
Files found: 12
Current tokens: 1,847 (tiktoken)

Proposed changes:
  [feedback]  feedback_no_mocks.md (48 tok) → TST:🚫mock-db,integration-only (8 tok)
  [project]   project_auth_rewrite.md (92 tok) → PRJ:auth-middleware→rewrite#compliance(session-token-storage) (12 tok)
  [reference]  reference_linear.md (34 tok) → REF:pipeline-bugs@Linear(INGEST) (6 tok)
  [manual]    project_complex_one.md (67 tok) → ⚠️ needs manual review

Estimated savings: 1,847 → 312 tokens (5.9× compression)
```

**STOP and wait for user confirmation before proceeding.**

## Step 4: Execute (after confirmation)

1. Build the new MEMORY.md with all sections:
   - `## Compressed Behavioral Rules` — feedback entries grouped by domain code with legend
   - `## Project Context` — project entries as Sigil one-liners
   - `## References` — reference entries as Sigil one-liners
   - `## User Context` — user entries as Sigil one-liners
   - Keep any entries flagged for manual review as prose with a `<!-- TODO: compress -->` comment
2. Delete absorbed individual files
3. Repeat for each memory location found in Step 1
4. Report final token count per location and total compression ratio

## What it won't do
- Touch CLAUDE.md or any non-memory files
- Delete files without showing them first
- Compress anything flagged as genuinely clearer in prose (leaves for manual review)
- Proceed without explicit user confirmation
