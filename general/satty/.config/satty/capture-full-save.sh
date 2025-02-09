#!/bin/bash

grim -g "$(slurp -orc '#ff0000ff')" -t ppm - | satty --filename - --early-exit --initial-tool pointer --output-filename "$HOME/Pictures/Screenshots/screenshot-%Y-%m-%d_%H:%M:%S.png"
