#!/bin/bash
swaybg -o DP-2 -i "$(find ~/.local/wallpapers/landscape/. -type f | shuf -n1)" -m fill &
swaybg -o DP-1 -i "$(find ~/.local/wallpapers/landscape/. -type f | shuf -n1)" -m fill &
