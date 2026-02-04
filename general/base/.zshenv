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

# If Mise is present, loads the activation scripts
# This will add shims to PATH
if [[ -f $HOME/.mise_shim && -x "$(command -v mise)" ]]; then
  source $HOME/.mise_shim
fi
