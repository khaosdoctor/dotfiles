#!/bin/sh
if ! command -v xrandr &>/dev/null
then
    echo "[i3-custom-scripts] Couldn't find xrandr to set screen layout" | systemd-cat -p emerg
    exit 1
fi
xrandr --output HDMI-0 --off --output DP-0 --off --output DP-1 --off --output DP-2 --mode 2560x1440 --pos 0x0 --rotate right --output DP-3 --off --output DP-4 --primary --mode 2560x1440 --pos 1440x560 --rotate normal --output DP-5 --off

echo "[i3-custom-scripts] Monitor layout set up successfully" | systemd-cat -p info
