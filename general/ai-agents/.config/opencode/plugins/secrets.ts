// secrets.ts — resolves 1Password references at config load.
//
// The config file stores op:// references only. This plugin reads them through
// the 1Password CLI at startup and writes the values into the live config, so
// no secret ever lives in opencode.jsonc on disk.
//
// Auth: 1Password desktop app integration or `op signin` session. A locked
// vault leaves the placeholder in place, and the MCP server surfaces its own
// auth error.
//
// Dual format: OpenCode 2.x reads `id` + `setup(ctx)` and edits MCP servers
// through `ctx.mcp.transform` (snake_case oauth keys); OpenCode 1.x
// (>= 1.18.29) calls `server()` and edits the config object (camelCase keys).

import { spawn } from "node:child_process"

const OP = "op"
const GOOGLE_MCPS = ["gmail", "gdrive", "gcalendar"]

function opRead(ref: string): Promise<string> {
  return new Promise((resolve) => {
    const proc = spawn(OP, ["read", "--no-newline", ref], { stdio: ["ignore", "pipe", "ignore"] })
    let out = ""
    proc.stdout.on("data", (chunk) => (out += chunk))
    proc.on("error", () => resolve(""))
    proc.on("close", (code) => resolve(code === 0 ? out.trim() : ""))
  })
}

async function readSecrets() {
  return {
    gcpId: await opRead("op://Private/Opencode MCP GCP connection/username"),
    gcpSecret: await opRead("op://Private/Opencode MCP GCP connection/credential"),
    coolify: await opRead("op://Private/Claude Neumann Coolify MCP Token/password"),
  }
}

export default {
  id: "secrets",

  async setup(ctx: any) {
    const { gcpId, gcpSecret, coolify } = await readSecrets()
    if (!gcpId || !gcpSecret) console.warn("secrets: 1Password did not return the Google client id/secret (vault locked or item renamed)")

    await ctx.mcp.transform((editor: any) => {
      const googleNames = gcpId && gcpSecret ? GOOGLE_MCPS : []
      for (const name of googleNames) {
        editor.update(name, (server: any) => {
          if (!server.oauth) return
          server.oauth.client_id = gcpId
          server.oauth.client_secret = gcpSecret
        })
      }

      if (!coolify) return
      editor.update("coolify", (server: any) => {
        if (!server.headers) return
        server.headers.Authorization = `Bearer ${coolify}`
      })
    })
  },

  async server({ client }: any = {}) {
    const log = (message: string) => {
      try {
        client?.app?.log({ body: { service: "secrets", level: "info", message } })
      } catch {}
    }

    return {
      config: async (config: any) => {
        const { gcpId, gcpSecret, coolify } = await readSecrets()

        // Google Workspace OAuth client — one client, three MCP servers.
        if (gcpId && gcpSecret) {
          for (const name of GOOGLE_MCPS) {
            const server = config.mcp?.[name]
            if (!server?.oauth) continue
            server.oauth.clientId = gcpId
            server.oauth.clientSecret = gcpSecret
          }
          log("resolved Google Workspace OAuth client from 1Password")
        }
        if (!gcpId || !gcpSecret) log("1Password did not return the Google client id/secret (vault locked or item renamed)")

        // Coolify remote MCP bearer token.
        if (!coolify) return
        if (!config.mcp?.coolify?.headers) {
          log("Coolify MCP entry has no headers object; token not applied")
          return
        }
        config.mcp.coolify.headers.Authorization = `Bearer ${coolify}`
        log("resolved Coolify MCP token from 1Password")
      },
    }
  },
}
