#!/bin/bash

grim -g "$(slurp -orc '#0000ffff')" -t ppm - | satty --filename - --early-exit --initial-tool pointer
