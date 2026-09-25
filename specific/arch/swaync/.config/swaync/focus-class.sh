#!/bin/sh
# swaync strips nested quotes from "exec", so the Lua call lives here instead
exec hyprctl eval "hl.dsp.focus({ window = \"class:$1\" })"
