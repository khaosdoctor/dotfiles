if [[ "$(uname -s)" == "Linux" ]]; then
    if [[ -z $DISPLAY && $(tty) == /dev/tty1 ]]; then
        exec $HOME/sway.sh
    fi
fi
