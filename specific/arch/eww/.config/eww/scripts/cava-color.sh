#!/bin/bash
# Pick the pywal accent color (1-6) with highest contrast against background
# Outputs comma-separated RGB: "R,G,B"
COLORS_FILE="$HOME/.cache/wal/colors.json"
[[ ! -f "$COLORS_FILE" ]] && echo "194,194,197" && exit

bg=$(jq -r '.special.background' "$COLORS_FILE")

hex_to_lum() {
  local hex="${1#\#}"
  local r=$((16#${hex:0:2})) g=$((16#${hex:2:2})) b=$((16#${hex:4:2}))
  echo $(( 2126 * r + 7152 * g + 722 * b ))
}

bg_lum=$(hex_to_lum "$bg")
best_color=""
best_diff=0

for i in 1 2 3 4 5 6; do
  color=$(jq -r ".colors.color${i}" "$COLORS_FILE")
  [[ "$color" == "null" || -z "$color" ]] && continue
  lum=$(hex_to_lum "$color")
  diff=$(( lum - bg_lum ))
  [[ $diff -lt 0 ]] && diff=$(( -diff ))
  if (( diff > best_diff )); then
    best_diff=$diff
    best_color=$color
  fi
done

hex="${best_color:-#c2c2c5}"
hex="${hex#\#}"
r=$((16#${hex:0:2}))
g=$((16#${hex:2:2}))
b=$((16#${hex:4:2}))
echo "${r},${g},${b}"
