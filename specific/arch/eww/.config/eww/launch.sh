#!/bin/bash
eww kill 2>/dev/null
# a daemon started against a different config path answers on another socket,
# so eww kill misses it and you end up with two of every widget
pkill -x eww 2>/dev/null
sleep 0.5
eww daemon
sleep 1
eww open clock
eww open clock-dp2
eww open now-playing
eww open now-playing-dp2
eww open sysmon
