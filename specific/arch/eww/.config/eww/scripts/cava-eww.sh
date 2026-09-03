#!/bin/bash
FADE=8
MAX_OPACITY=70

cava -p ~/.config/eww/scripts/cava-eww.conf 2>/dev/null | while IFS= read -r line; do
  IFS=';' read -ra v <<< "$line"
  n=${#v[@]}
  half=$(( n / 2 ))
  total=$n
  out="["

  idx=0
  for (( i = half - 1; i >= 0; i-- )); do
    val=${v[$i]}
    [[ ! "$val" =~ ^[0-7]$ ]] && val=0
    dist=$idx
    (( (total - 1 - idx) < dist )) && dist=$(( total - 1 - idx ))
    if (( dist >= FADE )); then
      op=$MAX_OPACITY
    else
      op=$(( MAX_OPACITY * dist / FADE ))
    fi
    printf -v op_str "%02d" "$op"
    (( idx > 0 )) && out+=","
    out+="{\"v\":$val,\"o\":\"0.${op_str}\"}"
    (( idx++ ))
  done

  for (( i = half; i < n; i++ )); do
    val=${v[$i]}
    [[ ! "$val" =~ ^[0-7]$ ]] && val=0
    dist=$idx
    (( (total - 1 - idx) < dist )) && dist=$(( total - 1 - idx ))
    if (( dist >= FADE )); then
      op=$MAX_OPACITY
    else
      op=$(( MAX_OPACITY * dist / FADE ))
    fi
    printf -v op_str "%02d" "$op"
    out+=",{\"v\":$val,\"o\":\"0.${op_str}\"}"
    (( idx++ ))
  done

  echo "${out}]"
done
