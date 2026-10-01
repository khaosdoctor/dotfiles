// sigil-hooks.ts — ports the Sigil Claude Code SessionStart hook to opencode.
//
// Sigil's other hooks (PreCompact context-% gate, Stop nudges) have no clean
// opencode equivalent: context % comes from Claude's statusline protocol and
// opencode has no Stop hook. The recall / remember / wrap-up skills cover
// those flows on-demand instead.
//
// Also sets SIGIL_ROOT process-wide so the sigil skills' `${SIGIL_ROOT}/...`
// references resolve when they run bash commands.
//
// Dual format: OpenCode 2.x reads `id` + `setup(ctx)`; its `context` hook only
// changes the outgoing model call, so the session-start text is added to every
// agent-loop request of a session. OpenCode 1.x (>= 1.18.29) calls `server()`.

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

async function sessionStartContext(): Promise<string | null> {
  const out = await runHook("bin/session-start.sh");
  if (!out) return null;
  try {
    return JSON.parse(out)?.additionalContext ?? null;
  } catch {
    return null;
  }
}

export default {
  id: "sigil-hooks",

  async setup(ctx: any) {
    // ponytail: one entry per session for the server's lifetime; prune if sessions pile up
    const bySession = new Map<string, string | null>();

    await ctx.session.hook("context", async (event: any) => {
      if (!bySession.has(event.sessionID)) bySession.set(event.sessionID, await sessionStartContext());
      const text = bySession.get(event.sessionID);
      if (text) event.system.push({ type: "text", text });
    });
  },

  async server() {
    let sessionStartMsg: string | null = null;
    const stash = async () => {
      sessionStartMsg = await sessionStartContext();
    };

    // Factory-time run: covers the race where session.created publishes before
    // the event handler is wired (one-shot `opencode run`).
    await stash();

    return {
      event: async ({ event }: any = {}) => {
        if (event?.type === "session.created") await stash();
      },

      "experimental.chat.system.transform": async (_input: any, output: any) => {
        if (!output || !Array.isArray(output.system)) return;
        if (!sessionStartMsg) return;
        output.system.push(sessionStartMsg);
        sessionStartMsg = null;
      },
    };
  },
};
