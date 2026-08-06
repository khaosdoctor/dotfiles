#!/bin/sh
# Shared zellij launcher for every terminal on every machine.
# Terminals point their shell/command option at this one path
# ($HOME/.local/bin/start-zellij.sh) instead of keeping a per-terminal,
# per-OS copy under each terminal's config dir.
#
# Why a script and not `shell zellij` / `command = zellij`:
#   - kitty eats the first `$` of `$$`, so the session name can't be built
#     inline in kitty.conf.
#   - Ghostty runs a single-word `command` directly via execvp with no shell
#     expansion, so `$HOME/...` there has to be wrapped (`shell:` prefix).
# A real file on disk sidesteps both.

export PATH="/opt/homebrew/bin:/usr/local/bin:$HOME/.cargo/bin:$HOME/.local/bin:$PATH"

# Session name is "<terminal>-<pid of this script>", so every window gets its
# own session and reattaches to it across reloads.
if [ "$TERM_PROGRAM" = "ghostty" ] || [ -n "$GHOSTTY_RESOURCES_DIR" ]; then
    term=ghostty
elif [ "$TERM_PROGRAM" = "rio" ]; then
    term=rio
elif [ -n "$KITTY_WINDOW_ID" ]; then
    term=kitty
elif [ -n "$WEZTERM_PANE" ]; then
    term=wezterm
else
    term=term
fi

# No zellij on this machine yet (fresh install, mid-bootstrap): fall back to a
# plain shell instead of leaving an unusable terminal.
if ! command -v zellij >/dev/null 2>&1; then
    exec "${SHELL:-/bin/sh}" -l
fi

exec zellij attach --create "${term}-$$"
