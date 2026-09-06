#!/bin/bash
field="${1:-listen}"
CACHE_DIR="$HOME/.cache/eww-np"
mkdir -p "$CACHE_DIR"
PLAYER=(playerctl -p spotify)

art_path() {
  cache="$CACHE_DIR/art.png"
  case "$1" in
    "") echo "" ;;
    file://*) echo "${1#file://}" ;;
    *) curl -sL --max-time 3 "$1" -o "$cache" 2>/dev/null && echo "$cache" || echo "" ;;
  esac
}

case "$field" in
  listen)
    # \x1f as the field separator, a track title can contain any printable character
    fmt=$(printf '{{status}}\x1f{{title}}\x1f{{artist}}\x1f{{album}}\x1f{{mpris:artUrl}}')
    "${PLAYER[@]}" -F metadata --format "$fmt" 2>/dev/null |
      while IFS=$'\x1f' read -r status title artist album arturl; do
        case "$status" in
          Playing) icon="▶" ;;
          Paused)  icon="⏸" ;;
          *)       icon="⏹" ;;
        esac
        if [ "$arturl" != "$last_url" ]; then
          last_art=$(art_path "$arturl")
          last_url="$arturl"
        fi
        jq -nc --arg status "${status:-Stopped}" --arg title "$title" \
          --arg artist "$artist" --arg album "$album" --arg icon "$icon" \
          --arg art "$last_art" '{$status,$title,$artist,$album,$icon,$art}'
      done ;;
  position)
    pos=$("${PLAYER[@]}" position 2>/dev/null)
    len=$("${PLAYER[@]}" metadata --format '{{mpris:length}}' 2>/dev/null)
    if [ -z "$pos" ] || [ -z "$len" ] || [ "$len" = "0" ]; then
      echo '{"progress":0,"time":""}'
      exit 0
    fi
    p=$(printf "%.0f" "$pos")
    d=$(( len / 1000000 ))
    progress=$(awk "BEGIN {printf \"%.0f\", $pos * 1000000 * 100 / $len}")
    time=$(printf "%d:%02d / %d:%02d" $((p/60)) $((p%60)) $((d/60)) $((d%60)))
    jq -nc --argjson progress "$progress" --arg time "$time" '{$progress,$time}' ;;
esac
