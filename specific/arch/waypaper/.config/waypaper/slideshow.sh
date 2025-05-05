#!/bin/bash

SLIDESHOW_SECONDS=3600
while true; do
    waypaper --random --state-file "$HOME/.local/state/waypaper/state.ini" --folder "$HOME/.local/wallpapers/landscape"
    sleep $SLIDESHOW_SECONDS
done
