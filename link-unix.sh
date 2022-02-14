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
    echo "would have ran: ln \"$file\" \"$HOME/$(basename $file)\""
done
