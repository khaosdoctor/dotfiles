// sigil-hooks.ts — ports the Sigil Claude Code SessionStart hook to opencode.
//
// Sigil's other hooks (PreCompact context-% gate, Stop nudges) have no clean
// opencode equivalent: context % comes from Claude's statusline protocol and
// opencode has no Stop hook. The recall / remember / wrap-up skills cover
// those flows on-demand instead.
//
// Also sets SIGIL_ROOT process-wide so the sigil skills' `${SIGIL_ROOT}/...`
// references resolve when they run bash commands.

import { homedir } from "node:os";
import { join } from "node:path";

const SIGIL_ROOT =
  process.env.SIGIL_ROOT ||
  join(homedir(), ".claude", "plugins", "marketplaces", "sigil", "plugins", "sigil");

process.env.SIGIL_ROOT = SIGIL_ROOT;

async function runHook(script: string): Promise<string | null> {
  try {
    const proc = Bun.spawn(["bash", join(SIGIL_ROOT, script)], {
      stdin: "pipe",
      stdout: "pipe",
      stderr: "ignore",
      env: { ...process.env, SIGIL_ROOT },
    });
    proc.stdin.write("{}");
    proc.stdin.end();
    const out = await new Response(proc.stdout).text();
    await proc.exited;
    return out || null;
  } catch {
    return null;
  }
}

let sessionStartMsg: string | null = null;

function stashSessionStart() {
  return runHook("bin/session-start.sh").then((out) => {
    if (!out) return;
    try {
      const parsed = JSON.parse(out);
      sessionStartMsg = parsed?.additionalContext ?? null;
    } catch {
      sessionStartMsg = null;
    }
  });
}

export default async () => {
  // Factory-time run: covers the race where session.created publishes before
  // the event handler is wired (one-shot `opencode run`).
  await stashSessionStart();

  return {
    event: async ({ event } = {}) => {
      if (event && event.type === "session.created") {
        await stashSessionStart();
      }
    },

    "experimental.chat.system.transform": async (_input, output) => {
      if (!output || !Array.isArray(output.system)) return;
      if (sessionStartMsg) {
        output.system.push(sessionStartMsg);
        sessionStartMsg = null;
      }
    },
  };
};
