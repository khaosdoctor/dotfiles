#!/bin/bash
DIRNAME=$(cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd)
[[ -f ~/.one-time-commands-run ]] && exit 0
echo "One time commands not run, running them now..."
echo "The screen will flash a few times and you'll need to type your sudo password"

"$DIRNAME/default-screenshots-jpg.sh"
"$DIRNAME/disable-disk-warning.sh"
"$DIRNAME/make-dock-instant-appear.sh"
"$DIRNAME/make-hidden-transparent.sh"

touch ~/.one-time-commands-run
