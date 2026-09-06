#!/bin/bash
# Single full-width spectrum: bars in natural low-to-high order, no mirroring.
FADE=8
MAX_OPACITY=70

cava -p ~/.config/eww/scripts/cava-eww.conf 2>/dev/null | while IFS= read -r line; do
  IFS=';' read -ra v <<< "$line"
  n=${#v[@]}
  out="["

  for (( i = 0; i < n; i++ )); do
    val=${v[$i]}
    [[ ! "$val" =~ ^[0-7]$ ]] && val=0
    dist=$i
    (( (n - 1 - i) < dist )) && dist=$(( n - 1 - i ))
    if (( dist >= FADE )); then
      op=$MAX_OPACITY
    else
      op=$(( MAX_OPACITY * dist / FADE ))
    fi
    printf -v op_str "%02d" "$op"
    (( i > 0 )) && out+=","
    out+="{\"v\":$val,\"o\":\"0.${op_str}\"}"
  done

  echo "${out}]"
done
