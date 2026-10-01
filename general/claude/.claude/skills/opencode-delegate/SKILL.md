---
name: opencode-delegate
description: Use when delegating coding tasks to OpenCode via the MCP bridge or the `opencode run` CLI, or when the user says "delegate", "fan out", "use opencode", "run this in parallel", "spawn agents", or asks to offload work to the Go provider. Routes tasks to the right opencode-go model and explains the MCP and CLI workflows.
---

# Delegate to OpenCode

Offload coding work to the opencode-go provider. Claude plans and reviews; Go executes.

Pick the workflow by what this machine has:

- **`mcp__opencode__*` tools are available** (OpenCode 1.x, e.g. the Mac): use the [MCP tool workflow](#mcp-tool-workflow).
- **No `mcp__opencode__*` tools, or `opencode --version` is 2.x** (e.g. neumann-arch): use the [CLI workflow](#cli-workflow). `mcp-server-opencode` 1.2.0 cannot drive an OpenCode 2.x server (the 2.x API replaced the one the SDK speaks), so the bridge is not registered there.

## When to delegate

| Do it yourself | Delegate |
|---|---|
| Architecture decisions | Multi-file refactors |
| Reviewing a diff | Writing the implementation |
| Debugging a subtle bug | Test generation, codemods |
| Anything under 5 minutes | Anything that takes 15+ minutes |
| You need to see every token | You only need the result |

## Model routing

**Read this before delegating anything.** The free OpenCode models, except `longcat-2.5-preview-free`, are fit only for extremely small work, and only when heavily guided. This goes double for `nemotron`, `big-pickle` and `space-bunny`. In practice (scriba refactor, 2026-10-01) they:

- are weak at reasoning and miss things a careful reader would catch
- do not always do what you ask: they ignore stop conditions, skip steps, edit files they were told not to, and report success that never happened
- have small context windows and limited abilities, so a multi-file task overwhelms them
- fall into endless loops (debugging the environment, re-reading the same files) instead of stopping

So, for any free model other than `longcat-2.5-preview-free`:

- give it one tiny task at a time: one file, one change, the exact code to write
- spell out every command and every forbidden action, and the exact point at which to stop
- wrap every run in `timeout` and watch it; kill it the moment it loops
- never trust its report: check the diff, the commit and the remote yourself
- never use it for planning, review, refactors or anything that needs judgement; do those in Claude

Among the free models, `longcat-2.5-preview-free` is the only one that can take larger, plan-driven work, and it still needs an exact plan and a review. The paid `opencode-go/` models are not covered by this warning.

Two rules decide the model:

1. **Free first, for everything.** Execution, triage and planning all start on a free model. The free models are good thinkers too, so try them before any paid one. Use a paid `opencode-go/` model only when the task needs more than the free models can do (multimodal input, a free run that failed again after a clearer prompt, a genuinely hard change).
2. **`glm-5.3` and `kimi-k3` never execute.** They are for planning only, and only as a last resort when neither Claude nor a free model can plan the task. Never give them a task that edits files.
3. **Never use** any `*contributor*` model, any `nemotron` model, any `*-fin-*` (finance-tuned) model, or the free `mimo` (`mimo-v2.6-flash-free`).

Free models come and go. Run `opencode models | grep -iE 'free|pickle'` before picking, and skip any model listed here that has disappeared. The numbers below come from a web check on 2026-10-01 (OpenCode Zen docs and model cards; several figures are third-party or from an earlier version), so treat them as a rough ranking.

Personal or confidential content (the Default vault, secrets, private notes) goes only to `space-bunny` or `longcat` (zero retention, no training per the Zen docs) or nowhere. `big-pickle` may use prompts to improve the model.

Both `space-bunny` and `longcat` are limited-time previews (longcat was announced for about two weeks from 2026-09-26), so expect them to disappear.

| Task shape | Model | Why |
|---|---|---|
| Planning, reasoning, quick triage (free) | `opencode/space-bunny-free` | Stealth, rumoured MiniMax family; 1M context, 512K output, reasoning; zero retention; users rate it good for planning |
| Planning, second opinion (free) | `opencode/longcat-2.5-preview-free` | Meituan LongCat 2.5 preview, ~1.6T MoE / 48B active, 1M context; zero retention; no published numbers |
| Default executor (exec plans, multi-file edits, codemods, bumps) | `opencode/longcat-2.5-preview-free` | Confirmed lab, 131K max output, tool calling |
| Second executor | `opencode/space-bunny-free` | Tool calling, zero retention |
| Third executor, non-private code only | `opencode/big-pickle` | Stealth, rumoured GLM-4.6 (backend may rotate); 200K context, 32K output; may train on prompts. Did the undici bump cleanly on 2026-10-01 |
| Hard refactor, architecture, subtle bug | `glm-5.3` | Highest measured score, 1M context. Planning only, last resort |
| Multi-hour unattended, 500+ tool calls | `kimi-k3` | Best long-horizon numbers. Planning only, last resort |
| Long agentic work at volume | `deepseek-v4.1-flash` | DeepSWE 74.2, 130k req/mo |
| Small edit, one file, quick question | `qwen3.8-flash` | DeepSWE 58.7 at $0.15/$0.47 |
| Repetitive or bulk work | `mimo-v2.6-flash` | 150k req/mo, cheap |
| Screenshot or image in the task | `deepseek-v4.1-flash` | Natively multimodal |
| Math, quant, formulas | `glm-5.3` | GPQA 92.6, HLE 43.6. Planning only, last resort |
| Frontend or UI build | `qwen3.8-flash` | Highest IFBench in cheap tier |
| Speed matters, user waiting | `minimax-m3` | 1.26s TTFT, 130 tok/s |
| Throwaway, nothing proprietary | `opencode/space-bunny-free`, then `opencode/longcat-2.5-preview-free` | Free, unlimited |

Never delegate to: `qwen3.7-max`, `qwen3.7-plus`, `qwen3.6-plus`, `glm-5.1`, `mimo-v2.5`, `mimo-v2.5-pro`, `minimax-m2.7`, `deepseek-v4-flash`, `deepseek-v4-pro`, `deepseek-v4-flash-vision-exp`, `mimo-v2.6-flash-free`, any `nemotron` or `*-fin-*` model, or any `*contributor*` model (`muse-spark-1.2-contributor`, `muse-spark-1.3-contributor`, `muse-spark-1.3-contributor-free`).

## MCP tool workflow

The bridge exposes these tools:

| Tool | Use |
|---|---|
| `opencode_start_server` | Start the opencode server (auto-starts if not running) |
| `opencode_list_agents` | See available models on the server |
| `opencode_start_task` | Delegate a task. Takes `prompt`, `model`, `directory` |
| `opencode_wait_for_task` | Block until a task finishes. Takes `task_id`, `timeout_ms` |
| `opencode_get_task_result` | Fetch the final result |
| `opencode_get_task_status` | Poll a running task |
| `opencode_cancel_task` | Abort a running task |
| `opencode_continue_task` | Send a follow-up to an existing session |

### Single task

1. `opencode_start_task` with the prompt and model
2. `opencode_wait_for_task` with the returned `task_id`
3. `opencode_get_task_result` to read the output

### Parallel fan-out

Call `opencode_start_task` multiple times in one message. Each gets its own `task_id`. Then `opencode_wait_for_task` with `mode: "all"` to block until every task finishes.

Use this when tasks are independent: writing tests for different modules, codemods across files, research on separate areas.

### Model selection per task

Pass the `model` parameter as the full id from the routing tables (`opencode/<id>` or `opencode-go/<id>`). If omitted, the server uses its default. Always pass it explicitly.

## CLI workflow

Run each task as a one-shot `opencode run` from the Bash tool:

```sh
cd <project dir> && timeout 1800 opencode run -m opencode-go/<id> --auto --title "<short title>" "<prompt>"
```

- `-m` takes the full ids from the routing tables, `opencode/<id>` for free models and `opencode-go/<id>` for paid ones.
- `--auto` approves permission prompts that the config does not explicitly deny, so the task does not stall waiting on a prompt nobody answers. Run it from the project directory so edits stay inside it.
- The final answer prints to stdout. Add `--format json` when you need to parse it.
- Put the rails in the prompt itself: which files it may touch, what it must not do (no push, no installs outside the project, no heredocs for file edits), and what to report back.
- Wrap it in `timeout` so a stuck task cannot run forever.

For a single task, run it in the foreground. For parallel fan-out, start each task as its own Bash call with `run_in_background: true` in one message; you are notified as each one finishes. Read the output files, then review the combined result yourself.

Starting OpenCode can make 1Password ask the user to approve SSH. Do not start OpenCode tasks when the user is away, because an unanswered prompt hangs the run.

## Cap budget

Each Go model has a monthly request cap. Pin one agent type per model so a runaway task cannot eat the month.

| Model | Cap/mo | Give it to |
|---|---|---|
| `opencode/*-free`, `big-pickle` | unlimited | Default for execution, triage and planning |
| `longcat-2.5-preview-free` | unlimited | Throwaway triage, classification, planning |
| `deepseek-v4.1-flash` | 130,000 | Default worker when free is not enough |
| `qwen3.8-flash` | 27,000 | Mechanical edits, codemods when free is not enough |
| `glm-5.3` | 1,080 | Hard problems only; planning only, last resort |
| `kimi-k3` | 490 | Genuinely difficult tasks; planning only, last resort |
| `mimo-v2.6-flash` | 150,400 | Bulk repetitive work when free is not enough |

The paid `opencode-go/` models also draw on the account balance. `Insufficient account funds` means every `opencode-go/` model is out until the balance is topped up; the `opencode/*-free` models still work.

## Rules

1. Always pass `model` explicitly. Never rely on the server default.
2. For parallel tasks, fire all `opencode_start_task` calls (or background `opencode run` calls) in one message, then wait.
3. If a task fails, read the error, fix the prompt, and retry with the same model before switching.
4. Do not delegate to a blocked model. The list above is exhaustive.
5. Free models have no published benchmarks, so give them an exact plan (file, symbol, new code) and always review their diff yourself before using it.
6. Never let `glm-5.3` or `kimi-k3` edit files. Use them for planning only, and only as a last resort.
7. When the user asks you to review Go output, do it yourself. Do not delegate review back to Go.
