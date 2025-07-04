# Turns on the computer and if the tty is the 1 then call sway
# if [[ "$(uname -s)" == "Linux" ]]; then
#     if [[ -z $DISPLAY && $(tty) == /dev/tty1 ]]; then
#         exec $HOME/sway.sh
#     fi
# fi
# Darwin only
if [[ "$(uname -o)" == "Darwin" ]]; then
    # Exports homebrew paths
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi
