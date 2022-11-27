#!/bin/bash

[[ ! -f ~/.one-time-commands-run ]] && exit 0
echo "One time commands not run, running them now..."
echo "The screen will flash a few times and you'll need to type your sudo password"

./default-screenshots-jpg.sh
./disable-disk-warning.sh
./make-dock-instant-appear.sh
./make-hidden-transparent.sh

touch ~/.one-time-commands-run
