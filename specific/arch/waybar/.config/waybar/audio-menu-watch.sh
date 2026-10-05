#!/usr/bin/env bash
# Keeps audio_menu.xml in sync: regenerates it when the default output/input changes
# or a device is added/removed, and reloads waybar only when the menu changed.
# Run by waybar-audio-menu.service.

DIR="$HOME/.config/waybar"
XML_FILE="$DIR/audio_menu.xml"

refresh() {
    local before
    before=$(cat "$XML_FILE" 2>/dev/null)
    "$DIR/audio-menu-gen.sh"
    [[ "$(cat "$XML_FILE")" == "$before" ]] && return
    systemctl --user reload waybar.service 2>/dev/null
}

refresh
pactl subscribe | grep --line-buffered -E "on server|'(new|remove)' on (sink|source) #" | while read -r _; do
    # Plugging a device fires a burst of events, wait for it to settle
    while read -r -t 0.5 _; do :; done
    refresh
done
