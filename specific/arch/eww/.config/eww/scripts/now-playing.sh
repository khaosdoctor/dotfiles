#!/bin/bash
field="${1:-status}"
CACHE_DIR="$HOME/.cache/eww-np"
mkdir -p "$CACHE_DIR"

cached() {
  val=$(playerctl metadata --format "$1" 2>/dev/null)
  if [ -n "$val" ]; then
    echo "$val" | tee "$CACHE_DIR/$2"
  else
    cat "$CACHE_DIR/$2" 2>/dev/null || echo "$3"
  fi
}

case "$field" in
  status)
    s=$(playerctl status 2>/dev/null)
    if [ -z "$s" ]; then echo "Stopped"
    else echo "$s"
    fi ;;
  title)  cached '{{title}}' title "" ;;
  artist) cached '{{artist}}' artist "" ;;
  album)  cached '{{album}}' album "" ;;
  icon)
    status=$(playerctl status 2>/dev/null)
    case "$status" in
      Playing) echo "▶" ;; Paused) echo "⏸" ;; *) echo "⏹" ;;
    esac ;;
  progress)
    pos=$(playerctl position 2>/dev/null)
    len=$(playerctl metadata --format '{{mpris:length}}' 2>/dev/null)
    if [ -z "$pos" ] || [ -z "$len" ] || [ "$len" = "0" ]; then
      cat "$CACHE_DIR/progress" 2>/dev/null || echo "0"
    else
      awk "BEGIN {printf \"%.0f\n\", $pos * 1000000 * 100 / $len}" | tee "$CACHE_DIR/progress"
    fi ;;
  time-str)
    pos=$(playerctl position 2>/dev/null)
    len=$(playerctl metadata --format '{{mpris:length}}' 2>/dev/null)
    if [ -z "$pos" ] || [ -z "$len" ] || [ "$len" = "0" ]; then
      cat "$CACHE_DIR/time" 2>/dev/null || echo ""
      exit 0
    fi
    p=$(printf "%.0f" "$pos")
    d=$(( len / 1000000 ))
    result=$(printf "%d:%02d / %d:%02d" $((p/60)) $((p%60)) $((d/60)) $((d%60)))
    echo "$result" | tee "$CACHE_DIR/time" ;;
  art-path)
    art_url=$(playerctl metadata --format '{{mpris:artUrl}}' 2>/dev/null)
    cache="$CACHE_DIR/art.png"
    if [ -z "$art_url" ]; then
      [ -f "$cache" ] && echo "$cache" || echo ""
    elif [[ "$art_url" == file://* ]]; then
      echo "${art_url#file://}"
    else
      curl -sL --max-time 3 "$art_url" -o "$cache" 2>/dev/null && echo "$cache" || echo ""
    fi ;;
esac
