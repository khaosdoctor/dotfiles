// secrets.ts — resolves 1Password references at config load.
//
// The config file stores op:// references only. This plugin reads them through
// the 1Password CLI at startup and writes the values into the live config, so
// no secret ever lives in opencode.jsonc on disk.
//
// Auth: 1Password desktop app integration or `op signin` session. A locked
// vault leaves the placeholder in place, and the MCP server surfaces its own
// auth error.

import { spawn } from "node:child_process"

const OP = "op"

function opRead(ref: string): Promise<string> {
  return new Promise((resolve) => {
    const proc = spawn(OP, ["read", "--no-newline", ref], { stdio: ["ignore", "pipe", "ignore"] })
    let out = ""
    proc.stdout.on("data", (chunk) => (out += chunk))
    proc.on("error", () => resolve(""))
    proc.on("close", (code) => resolve(code === 0 ? out.trim() : ""))
  })
}

export default async ({ client }: any = {}) => {
  const log = (message: string) => {
    try {
      client?.app?.log({ body: { service: "secrets", level: "info", message } })
    } catch {}
  }

  return {
    config: async (config: any) => {
      // Google Workspace OAuth client — one client, three MCP servers.
      const gcpId = await opRead("op://Private/Opencode MCP GCP connection/username")
      const gcpSecret = await opRead("op://Private/Opencode MCP GCP connection/credential")
      if (gcpId && gcpSecret) {
        for (const name of ["gmail", "gdrive", "gcalendar"]) {
          const server = config.mcp?.[name]
          if (!server?.oauth) continue
          server.oauth.clientId = gcpId
          server.oauth.clientSecret = gcpSecret
        }
        log("resolved Google Workspace OAuth client from 1Password")
      } else {
        log("1Password did not return the Google client id/secret (vault locked or item renamed)")
      }

      // Coolify remote MCP bearer token.
      const coolify = await opRead("op://Private/Claude Neumann Coolify MCP Token/password")
      if (coolify && config.mcp?.coolify?.headers) {
        config.mcp.coolify.headers.Authorization = `Bearer ${coolify}`
        log("resolved Coolify MCP token from 1Password")
      } else if (coolify) {
        log("Coolify MCP entry has no headers object; token not applied")
      }
    },
  }
}
