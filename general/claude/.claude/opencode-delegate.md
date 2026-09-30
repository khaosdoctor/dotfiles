When a task is long, mechanical, or parallelizable, delegate to opencode-go via the MCP bridge instead of doing it inline. Claude plans and reviews; Go executes.

Full MCP tool workflow: `@~/.claude/skills/opencode-delegate/SKILL.md`

## Model routing

| Task shape | Model |
|---|---|
| Hard refactor, architecture, subtle bug | `opencode-go/glm-5.3` |
| Multi-hour unattended, 500+ tool calls | `opencode-go/kimi-k3` |
| Long agentic work at volume | `opencode-go/deepseek-v4.1-flash` |
| Small edit, one file, quick question | `opencode-go/qwen3.8-flash` |
| Repetitive or bulk work | `opencode-go/mimo-v2.6-flash` |
| Screenshot or image | `opencode-go/deepseek-v4.1-flash` |
| Math, quant, formulas | `opencode-go/glm-5.3` |
| Frontend or UI build | `opencode-go/qwen3.8-flash` |
| Speed matters | `opencode-go/minimax-m3` |
| Throwaway, nothing proprietary | `opencode-go/space-bunny-free` |

**Never delegate to:** `qwen3.7-max` `qwen3.7-plus` `qwen3.6-plus` `glm-5.1` `mimo-v2.5` `mimo-v2.5-pro` `minimax-m2.7` `deepseek-v4-flash` `deepseek-v4-pro` `deepseek-v4-flash-vision-exp` `muse-spark-1.2-contributor` `muse-spark-1.3-contributor`

## Cap budget

| Model | Cap/mo | Give it to |
|---|---|---|
| `space-bunny-free` | unlimited | Throwaway triage |
| `deepseek-v4.1-flash` | 130,000 | Default worker |
| `qwen3.8-flash` | 27,000 | Mechanical edits |
| `mimo-v2.6-flash` | 150,400 | Bulk repetitive |
| `glm-5.3` | 1,080 | Hard problems only |
| `kimi-k3` | 490 | Genuinely difficult |
