#!/bin/bash

# This script is used to launch polybar on multiple monitors
# It will launch a polybar on each monitor that is connected
# in the config, the LANDSCAPE and PORTRAIT monitors need to be set on the [bar/...] section
# This WILL NOT work if you have a different setup than the one I have
# for this to work you need to change the grep values to match your setup
# run xrandr --query | grep " connected" and look for the resolution of your monitors and change the values accordingly

if type "xrandr"; then
    # this is the original code that will assign a polybar to each monitor
    # but they will be the same on both
    for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
        MONITOR=$m polybar --reload landscape &
    done
    # this is if you have a portrait and landscape monitor
    # PORTRAIT_MONITOR=$(xrandr --query | grep " connected" | grep "1440x2560" | cut -d" " -f1) \
    # polybar --reload portrait &
    #
    # LANDSCAPE_MONITOR=$(xrandr --query | grep " connected" | grep "2560x1440" | cut -d" " -f1) \
    # polybar --reload landscape &
else
    polybar --reload landscape &
fi
