if [[ "$(uname -s)" == "Linux" ]]; then
    if [[ -z $DISPLAY && $(tty) == /dev/tty2 ]]; then
        exec $HOME/sway.sh
    fi
fi
