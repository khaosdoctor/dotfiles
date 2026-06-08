#!/usr/bin/env zsh
export PATH="/usr/local/bin:$HOME/.cargo/bin:$HOME/.local/bin:$PATH"

if [ "$TERM_PROGRAM" = "ghostty" ]; then
    term=ghostty
elif [ "$TERM_PROGRAM" = "rio" ]; then
    term=rio
elif [ -n "$KITTY_WINDOW_ID" ]; then
    term=kitty
else
    term=term
fi

SESSION="${term}-$$"
trap 'zellij delete-session "$SESSION" --force 2>/dev/null' EXIT
zellij attach --create "$SESSION"
