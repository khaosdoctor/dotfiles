#!/usr/bin/env zsh

# Darwin only
if [[ "$(uname -o)" == "Darwin" ]]; then
    # Exports homebrew paths
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# LOADS USER EXPORTS VARIABLES
if [[ -a $HOME/.exports ]]; then
  source $HOME/.exports
fi
