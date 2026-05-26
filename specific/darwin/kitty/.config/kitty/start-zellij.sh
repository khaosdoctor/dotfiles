#!/bin/sh
if [ "$TERM_PROGRAM" = "ghostty" ]; then
    term=ghostty
elif [ -n "$KITTY_WINDOW_ID" ]; then
    term=kitty
else
    term=term
fi
exec /opt/homebrew/bin/zellij attach --create "${term}-$$"
