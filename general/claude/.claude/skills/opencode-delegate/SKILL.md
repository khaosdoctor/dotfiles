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

Pick the model from the task shape. These are `opencode-go/` ids.

| Task shape | Model | Why |
|---|---|---|
| Hard refactor, architecture, subtle bug | `glm-5.3` | Highest measured score, 1M context |
| Multi-hour unattended, 500+ tool calls | `kimi-k3` | Best long-horizon numbers |
| Long agentic work at volume | `deepseek-v4.1-flash` | DeepSWE 74.2, 130k req/mo |
| Small edit, one file, quick question | `qwen3.8-flash` | DeepSWE 58.7 at $0.15/$0.47 |
| Repetitive or bulk work | `mimo-v2.6-flash` | 150k req/mo, cheap |
| Screenshot or image in the task | `deepseek-v4.1-flash` | Natively multimodal |
| Math, quant, formulas | `glm-5.3` | GPQA 92.6, HLE 43.6 |
| Frontend or UI build | `qwen3.8-flash` | Highest IFBench in cheap tier |
| Speed matters, user waiting | `minimax-m3` | 1.26s TTFT, 130 tok/s |
| Throwaway, nothing proprietary | `space-bunny-free` | Unlimited, no benchmark data |

Never delegate to: `qwen3.7-max`, `qwen3.7-plus`, `qwen3.6-plus`, `glm-5.1`, `mimo-v2.5`, `mimo-v2.5-pro`, `minimax-m2.7`, `deepseek-v4-flash`, `deepseek-v4-pro`, `deepseek-v4-flash-vision-exp`, `muse-spark-1.2-contributor`, `muse-spark-1.3-contributor`.

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

Pass the `model` parameter as `opencode-go/<id>`. If omitted, the server uses its default. Always pass it explicitly.

## CLI workflow

Run each task as a one-shot `opencode run` from the Bash tool:

```sh
cd <project dir> && timeout 1800 opencode run -m opencode-go/<id> --auto --title "<short title>" "<prompt>"
```

- `-m` takes the same `opencode-go/<id>` ids as the routing table.
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
| `space-bunny-free` | unlimited | Throwaway triage, classification |
| `deepseek-v4.1-flash` | 130,000 | Default worker |
| `qwen3.8-flash` | 27,000 | Mechanical edits, codemods |
| `glm-5.3` | 1,080 | Hard problems only |
| `kimi-k3` | 490 | Genuinely difficult tasks |
| `mimo-v2.6-flash` | 150,400 | Bulk repetitive work |

## Rules

1. Always pass `model` explicitly. Never rely on the server default.
2. For parallel tasks, fire all `opencode_start_task` calls (or background `opencode run` calls) in one message, then wait.
3. If a task fails, read the error, fix the prompt, and retry with the same model before switching.
4. Do not delegate to a blocked model. The list above is exhaustive.
5. `space-bunny-free` and `longcat-2.5-preview-free` have no published benchmarks. Use them only for low-stakes work.
6. When the user asks you to review Go output, do it yourself. Do not delegate review back to Go.
