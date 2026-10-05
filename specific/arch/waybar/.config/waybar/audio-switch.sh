#!/usr/bin/env bash
# Sets the default output or input by index from the generated mapping files.
# waybar-audio-menu.service picks up the change and moves the selection marker.
# Usage: audio-switch.sh <output|input> <index>

DIR="$HOME/.config/waybar"
kind="$1"
index="$2"
MAP_FILE="$DIR/.audio-${kind}s"

[[ "$kind" == "output" ]] && pactl_kind="sink"
[[ "$kind" == "input" ]] && pactl_kind="source"
[[ -z "$pactl_kind" ]] && exit 1
[[ -z "$index" || ! -f "$MAP_FILE" ]] && exit 1

device_name=$(sed -n "$((index + 1))p" "$MAP_FILE")
[[ -z "$device_name" ]] && exit 1

pactl "set-default-${pactl_kind}" "$device_name"
