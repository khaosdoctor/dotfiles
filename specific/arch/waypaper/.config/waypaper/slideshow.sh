#!/bin/bash

SLIDESHOW_SECONDS=3600
while true; do
    waypaper --random --state-file "$HOME/.local/state/waypaper/state.ini" --folder "$HOME/.local/wallpapers/landscape"
    sleep 0.5
    eww update cava-color="$("$HOME/.config/eww/scripts/cava-color.sh")" 2>/dev/null
    sleep $SLIDESHOW_SECONDS
done
