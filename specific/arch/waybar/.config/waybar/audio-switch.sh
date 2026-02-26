#!/usr/bin/env bash
# Sets the default sink by index from the generated mapping file.

MAP_FILE="$HOME/.config/waybar/.audio-sinks"
index="$1"

[[ -z "$index" || ! -f "$MAP_FILE" ]] && exit 1

sink_name=$(sed -n "$((index + 1))p" "$MAP_FILE")
[[ -z "$sink_name" ]] && exit 1

pactl set-default-sink "$sink_name"
