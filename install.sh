#!/bin/bash
DIRNAME=$(cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd)
command -v brew >/dev/null 2>&1 || { echo "Homebrew is not installed. Installing now" >&2; /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; }
command -v stow >/dev/null 2>&1 || { echo "GNU Stow is not installed. Installing now" >&2; brew install stow; }


if [[ ! $(stow -n --target="$HOME" global) -eq 0 ]]; then
  echo "Error: There are conflicts with the dotfiles. Please resolve them and run this script again."
  exit 1
fi

stow --target="$HOME" global

cd MacOS || return
if [[ ! $(stow -n --target="$HOME" dotfiles) -eq 0 ]]; then
  echo "Error: There are conflicts with the dotfiles. Please resolve them and run this script again."
  exit 1
fi
stow --target="$HOME" dotfiles

if [[ ! $(stow -n --target="$HOME" binaries) -eq 0 ]]; then
  echo "Error: There are conflicts with the dotfiles. Please resolve them and run this script again."
  exit 1
fi
stow --target="/usr/local/bin" binaries

# Execute one time scripts depending on OS
if [[ $(uname -s) == "Darwin" ]]; then
  "$DIRNAME/MacOS/one-time-commands/run-one-time-commands.sh"
fi

# Install Homebrew packages
cd "$HOME" || return
brew bundle install

echo "Dotfiles installed. Please restart your terminal."
