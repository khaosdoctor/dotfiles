#!/usr/bin/env zsh
SESSION="kitty-$$"
trap 'zellij delete-session "$SESSION" --force 2>/dev/null' EXIT
zellij attach --create "$SESSION"
