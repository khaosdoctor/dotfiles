When a task is long, mechanical, or parallelizable, delegate to opencode-go via the MCP bridge instead of doing it inline. Where the bridge is unavailable (no `mcp__opencode__*` tools, OpenCode 2.x), use `opencode run` from Bash instead. Claude plans and reviews; Go executes.

Full MCP and CLI workflows: `@~/.claude/skills/opencode-delegate/SKILL.md`

## Model routing

- **Free first, for everything:** execution, triage and planning all start on a free model. The free models are good thinkers too, so try them before any paid one. Use a paid `opencode-go/` model only when the task needs more than the free models can do.
- **`glm-5.3` and `kimi-k3` never execute.** They are for planning only, and only as a last resort when neither Claude nor a free model can plan the task.
- **Never use** any `*contributor*` model, any `nemotron` model, any `*-fin-*` (finance-tuned) model, or the free `mimo` (`mimo-v2.6-flash-free`).
- Free models come and go. Run `opencode models | grep -iE 'free|pickle'` before picking, and skip any listed here that has disappeared.
- Free-tier data terms (OpenCode Zen docs, 2026-10): `space-bunny` and `longcat` keep nothing and do not train on prompts; `big-pickle` may use prompts to improve the model. Personal or confidential content (the Default vault, secrets, private notes) goes to `space-bunny`, `longcat`, or nowhere.
- `space-bunny` and `longcat` are limited-time previews; expect them to disappear.

| Task shape | Model |
|---|---|
| Planning, reasoning, quick triage (free) | `opencode/space-bunny-free`, then `opencode/longcat-2.5-preview-free` |
| Default executor (exec plans, multi-file edits, codemods, bumps) | `opencode/longcat-2.5-preview-free`, then `opencode/space-bunny-free` |
| Third executor, non-private code only | `opencode/big-pickle` |
| Hard refactor, architecture, subtle bug | `opencode-go/glm-5.3` (planning only, last resort) |
| Multi-hour unattended, 500+ tool calls | `opencode-go/kimi-k3` (planning only, last resort) |
| Long agentic work at volume | `opencode-go/deepseek-v4.1-flash` |
| Small edit, one file, quick question | `opencode-go/qwen3.8-flash` |
| Repetitive or bulk work | `opencode-go/mimo-v2.6-flash` |
| Screenshot or image | `opencode-go/deepseek-v4.1-flash` |
| Math, quant, formulas | `opencode-go/glm-5.3` (planning only, last resort) |
| Frontend or UI build | `opencode-go/qwen3.8-flash` |
| Speed matters | `opencode-go/minimax-m3` |
| Throwaway, nothing proprietary | `opencode/space-bunny-free`, then `opencode/longcat-2.5-preview-free` |

**Never delegate to:** `qwen3.7-max` `qwen3.7-plus` `qwen3.6-plus` `glm-5.1` `mimo-v2.5` `mimo-v2.5-pro` `minimax-m2.7` `deepseek-v4-flash` `deepseek-v4-pro` `deepseek-v4-flash-vision-exp`, `mimo-v2.6-flash-free`, any `nemotron` or `*-fin-*` model, or any `*contributor*` model (`muse-spark-1.2-contributor`, `muse-spark-1.3-contributor`, `muse-spark-1.3-contributor-free`)

## Cap budget

| Model | Cap/mo | Give it to |
|---|---|---|
| `opencode/*-free`, `big-pickle` | unlimited | Default for execution, triage and planning |
| `longcat-2.5-preview-free` | unlimited | Throwaway triage, planning |
| `deepseek-v4.1-flash` | 130,000 | Default worker when free is not enough |
| `qwen3.8-flash` | 27,000 | Mechanical edits when free is not enough |
| `mimo-v2.6-flash` | 150,400 | Bulk repetitive when free is not enough |
| `glm-5.3` | 1,080 | Hard problems only; planning only, last resort |
| `kimi-k3` | 490 | Genuinely difficult; planning only, last resort |

`Insufficient account funds` blocks every `opencode-go/` model; the free ones still run.
