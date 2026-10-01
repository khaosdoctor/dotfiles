// env.ts — injects env vars for all shell execution.
// Ported from ~/.claude/settings.json env + settings.local.json env.
// SessionStart hooks (herdr, obsidian vault context) are intentionally not
// ported: they were no-ops or TUI-invisible here.
//
// Dual format: OpenCode 2.x reads `id` + `setup(ctx)`, OpenCode 1.x (>= 1.18.29)
// calls `server()` and uses the hooks map it returns.

import { homedir } from "node:os"
import { join } from "node:path"

// The AI Brainz vault lives in a different folder per OS.
const VAULT_BY_PLATFORM: Partial<Record<NodeJS.Platform, string>> = {
  darwin: join(homedir(), "Documents", "AI Brainz Vault") + "/",
  linux: join(homedir(), "Documents", "Obsidian", "Vaults", "AI Brainz") + "/",
}

function applyEnv(env: Record<string, string | undefined>) {
  const vault = VAULT_BY_PLATFORM[process.platform]
  env.OBSIDIAN_BG_AGENT_ENABLED = "1"
  if (vault) env.OBSIDIAN_VAULT_PATH = vault
}

export default {
  id: "env",

  async setup(ctx: any) {
    await ctx.shell.hook("create.before", (event: any) => applyEnv(event.env))
  },

  async server() {
    return {
      "shell.env": async (_input: any, output: any) => applyEnv(output.env),
    }
  },
}
