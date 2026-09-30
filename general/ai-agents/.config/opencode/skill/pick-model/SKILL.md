---
name: pick-model
description: Use when choosing which model should handle a request, or when the user asks "which model", "what model should I use", "best model for this", "switch model", "/model", or when picking a model for a subagent or Task call. Routes a prompt to one of the opencode-go models by task shape. Also use before spawning a subagent on the opencode-go provider, to pick the model for that subagent.
---

# Pick a model

Pick the model from the shape of the request, then say which one in one line.
Do not ask the user to choose. Do not list the table unless asked.

## Routing table

| The request is | Use | Why |
|---|---|---|
| Hard refactor, architecture, subtle bug, wide-reaching change | `opencode-go/glm-5.3` | Highest measured score on the plan (index 60), 1M context |
| Multi-hour unattended run, 500+ tool calls, whole-repo work | `opencode-go/kimi-k3` | LiveBench 79.2 first, 1M context, best long-horizon numbers |
| Long agentic work where volume matters | `opencode-go/deepseek-v4.1-flash` | DeepSWE 74.2, 130k requests/month, cheap |
| Small edit, one file, obvious change, quick question | `opencode-go/qwen3.8-flash` | DeepSWE 58.7 at $0.15/$0.47, 27k requests/month |
| Repetitive or bulk work, many similar tasks | `opencode-go/mimo-v2.6-flash` | 150k requests/month, index 46 for the pro tier |
| Screenshot, image, or diagram in the request | `opencode-go/deepseek-v4.1-flash` | Natively multimodal, no vision surcharge |
| Math, quant, formulas, derivations | `opencode-go/glm-5.3` | GPQA 92.6, HLE 43.6, best on the plan |
| Frontend or UI build | `opencode-go/qwen3.8-flash` | Highest IFBench in the cheap tier |
| Frontend where quality beats cost | `opencode-go/kimi-k3` | First on Arena WebDev at 1679 Elo |
| Speed matters, user is waiting on each turn | `opencode-go/minimax-m3` | 1.26s to first token, 130 tok/s |
| Unfamiliar territory, no clear category | `opencode-go/deepseek-v4.1-flash` | Safe default, cheap to retry |
| Throwaway work, nothing proprietary | `opencode-go/space-bunny-free` | Unlimited, no benchmark data at all |
| User wants the most capable model, cost irrelevant | `opencode-go/kimi-k3` | Then `opencode-go/grok-4.7` for multi-hour only |

## Rules

1. Never pick `opencode-go/deepseek-v4-flash`, `opencode-go/deepseek-v4-pro`, or
   `opencode-go/deepseek-v4-flash-vision-exp`. All three reroute to
   `deepseek-v4.1-flash` since 14 September 2026. Only the `.1-flash` id is real.
2. Never pick a `muse-spark-*-contributor` model. The user excluded them.
   They train Meta on the prompts and are region-locked.
3. Never pick `qwen3.7-max`, `qwen3.7-plus`, `qwen3.6-plus`, `glm-5.1`,
   `mimo-v2.5`, `mimo-v2.5-pro`, or `minimax-m2.7`. Each is dominated by a
   cheaper, stronger sibling.
4. Treat `qwen3.8-max`, `gpt-6-luna`, `gpt-5.6-luna`, `mimo-v2.6-pro`,
   `hy4-preview`, and `grok-4.7` as escalation only. Each has a $15 or $30
   monthly cap that runs out fast. Do not pick them for routine work.
5. `longcat-2.0` and `longcat-2.5-preview-free` are acceptable when the user
   asks for them, and fine for cheap exploratory work. `longcat-2.5-preview-free`
   has no published benchmark from anyone, so never present it as reliable.
6. When spawning a subagent with the Task tool, set `model` on the task to the
   picked id. Cheap read-only exploration goes to `qwen3.8-flash` or
   `deepseek-v4.1-flash`. Subagents that write code go to `glm-5.3`.

## Usage math that decides close calls

Monthly request caps on the $10 plan. When two models are close on quality,
pick the one with the bigger number.

```
space-bunny-free         unlimited
mimo-v2.6-flash          150,400
deepseek-v4.1-flash      130,000
glm-5.3-flash             31,580
qwen3.8-flash             27,000
minimax-m3                16,000
mimo-v2.6-pro             16,300
glm-5.2 / glm-5.3          4,300 / 1,080
kimi-k2.6                  5,750
hy4-preview                6,770
longcat-2.0               57,200
grok-4.6 / grok-4.7          845
kimi-k3                      490
qwen3.8-max                  810
gpt-6-luna / gpt-5.6-luna 21,130 / 10,250
```

`qwen3.8-max` beats `qwen3.8-flash` on paper and gives you 30x fewer requests.
Default to flash, escalate to max only when the task is genuinely hard.
