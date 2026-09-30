// rtk-hook.ts — ports the Claude Code PreToolUse bash hooks to opencode.
//
// 1. `rtk hook claude` command rewrite (rtk prefix injection) — same engine
//    Claude Code uses, invoked identically (JSON in on stdin, JSON out).
// 2. Bare `git ...` fallback: rewrite to `env -i ... /usr/bin/git --no-pager`
//    so mise/shell hooks can't hang the call (from settings.json hook #1).
// 3. Branch freshness before `git push`: run fetch + status -sb first so the
//    output lands in the same tool result (from settings.json hook #3).

import { existsSync } from "node:fs"

// Homebrew git first: on macOS /usr/bin/git is the Command Line Tools shim,
// which can pop the CLT installer dialog. Linux falls through to /usr/bin/git.
const GIT_BIN = existsSync("/opt/homebrew/bin/git") ? "/opt/homebrew/bin/git" : "/usr/bin/git"
const CLEAN_PATH = "/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
const CLEAN_GIT = `env -i HOME=$HOME PATH=${CLEAN_PATH} ${GIT_BIN} --no-pager`

async function rtkRewrite(command: string): Promise<string | null> {
  const payload = JSON.stringify({ tool_input: { command } })
  const proc = Bun.spawn(["rtk", "hook", "claude"], {
    stdin: "pipe",
    stdout: "pipe",
    stderr: "ignore",
  })
  proc.stdin.write(payload)
  proc.stdin.end()

  const timeout = new Promise<null>((resolve) =>
    setTimeout(() => {
      proc.kill()
      resolve(null)
    }, 3000),
  )

  const result = (async () => {
    const out = await new Response(proc.stdout).text()
    await proc.exited
    const parsed = JSON.parse(out)
    return parsed?.hookSpecificOutput?.updatedInput?.command ?? null
  })().catch(() => null)

  return Promise.race([result, timeout])
}

export default async () => {
  return {
    "tool.execute.before": async (input: any, output: any) => {
      if (input.tool !== "bash") return

      let command: string = output.args.command

      // 1. rtk rewrite (adds `rtk ` prefix where it saves tokens)
      const rewritten = await rtkRewrite(command)
      if (rewritten && rewritten !== command) command = rewritten

      // 2. bare leading `git` -> clean-env git (rtk-prefixed git doesn't hang)
      if (/^\s*(git\s|git$|\/usr\/bin\/git\s)/.test(command)) {
        command = command.replace(
          /^\s*(?:\/usr\/bin\/)?git\s?/,
          `${CLEAN_GIT} `,
        )
      }

      // 3. branch freshness before any git push
      if (/\bgit\s+push\b/.test(command)) {
        command = `${CLEAN_GIT} fetch 2>&1; ${CLEAN_GIT} status -sb 2>&1; ${command}`
      }

      output.args.command = command
    },
  }
}
