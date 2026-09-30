// env.ts — injects env vars for all shell execution.
// Ported from ~/.claude/settings.json env + settings.local.json env.
// SessionStart hooks (herdr, obsidian vault context) are intentionally not
// ported: they were no-ops or TUI-invisible here.

import { homedir } from "node:os"
import { join } from "node:path"

// The AI Brainz vault lives in a different folder per OS.
const VAULT_BY_PLATFORM: Partial<Record<NodeJS.Platform, string>> = {
  darwin: join(homedir(), "Documents", "AI Brainz Vault") + "/",
  linux: join(homedir(), "Documents", "Obsidian", "Vaults", "AI Brainz") + "/",
}

export default async () => {
  const vault = VAULT_BY_PLATFORM[process.platform]

  return {
    "shell.env": async (_input: any, output: any) => {
      output.env.OBSIDIAN_BG_AGENT_ENABLED = "1"
      if (vault) output.env.OBSIDIAN_VAULT_PATH = vault
    },
  }
}
