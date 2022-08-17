#!/bin/bash

echo "########################"
echo "##  Linking dotfiles  ##"
echo "########################"
echo ""
echo "do NOT stop this process in the middle of execution, otherwise your files might be corrupted"

shopt -s dotglob # enable "*" to show hidden files (aka dotfiles)
DIRS="./Global/*
./MacOSX/*"
for file in $DIRS; do
    echo "~> Linking $file to $HOME/$(basename $file)"
    echo "would have ran: ln -sf \"$file\" \"$HOME/$(basename $file)\""
done

# Install all from Brewfile

# Install ASDF (already done in brewfile)
# install asdf plugins
asdf plugin-add python
asdf plugin-add deno
asdf plugin-add bun
asdf plugin-add nodejs
asdf plugin-add golang

# install asdf versions
asdf install nodejs lts
asdf install nodejs latest
asdf install deno latest
asdf install bun latest
asdf install golang latest
asdf install python "$(asdf list-all python | grep -e "^\d*\.\d*\.\d*$" | tail -n 1)"

# set asdf global
asdf global nodejs lts
asdf global nodejs latest
asdf global deno latest
asdf global bun latest
asdf global golang latest
asdf global python "$(asdf list-all python | grep -e "^\d*\.\d*\.\d*$" | tail -n 1)"

# Install lunarvim
bash <(curl -s https://raw.githubusercontent.com/khaosdoctor/lunarvim/main/utils/installer/install.sh) -y
