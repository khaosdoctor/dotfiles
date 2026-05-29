#!/bin/sh
if [ "$TERM_PROGRAM" = "ghostty" ]; then
    term=ghostty
elif [ -n "$KITTY_WINDOW_ID" ]; then
    term=kitty
else
    term=term
fi
exec $(which zellij) attach --create "${term}-$$"
