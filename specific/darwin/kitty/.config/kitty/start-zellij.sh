#!/bin/sh
export PATH="/opt/homebrew/bin:/usr/local/bin:$HOME/.cargo/bin:$HOME/.local/bin:$PATH"

if [ "$TERM_PROGRAM" = "ghostty" ]; then
    term=ghostty
elif [ "$TERM_PROGRAM" = "rio" ]; then
    term=rio
elif [ -n "$KITTY_WINDOW_ID" ]; then
    term=kitty
else
    term=term
fi
exec zellij attach --create "${term}-$$"
