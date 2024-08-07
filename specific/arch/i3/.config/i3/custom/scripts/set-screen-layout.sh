#!/bin/bash
if ! command -v xrandr &>/dev/null; then
  echo "[i3-custom-scripts] Couldn't find xrandr to set screen layout" | systemd-cat -p emerg -t $(pwd)
  exit 1
fi
xrandr --output HDMI-0 --off --output DP-0 --mode 2560x1440 --pos 2560x0 --rotate normal --output DP-1 --off --output DP-2 --mode 2560x1440 --pos 0x0 --rotate normal --output DP-3 --off --output DP-4 --off --output DP-5 --off

echo "[i3-custom-scripts] Monitor layout set up successfully" | systemd-cat -p info -t $(pwd)
