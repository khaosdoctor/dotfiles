#!/bin/bash

grim -g "$(slurp -oc '#0000ffff')" -t ppm - | satty --filename - --early-exit --initial-tool pointer
