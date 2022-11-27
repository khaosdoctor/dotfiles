#!/bin/bash

[[ ! -f ~/.one-time-commands-run ]] && echo false > /dev/null

./default-screenshots-jpg.sh
./disable-disk-warning.sh
./make-dock-instant-appear.sh
./make-hidden-transparent.sh

touch ~/.one-time-commands-run
