#!/bin/bash
if ! command -v xrandr &>/dev/null; then
    echo "[i3-custom-scripts] Couldn't find xrandr to set screen layout" | systemd-cat -p emerg -t $(pwd)
    exit 1
fi
xrandr --dpi 120 --output DP-0 --mode 2560x1440 --scale 1x1 --pos 3840x415 --rotate normal --output DP-2 --primary --mode 3840x2160 --pos 0x0 -r 240 --rotate normal

echo "[i3-custom-scripts] Monitor layout set up successfully" | systemd-cat -p info -t $(pwd)
