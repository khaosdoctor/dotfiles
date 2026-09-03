#!/bin/bash
CACHE="$HOME/.cache/eww-weather.json"
CACHE_TTL="${WEATHER_CACHE_TTL:-900}"

# Refresh cache if older than TTL or missing
if [ ! -f "$CACHE" ] || [ $(( $(date +%s) - $(stat -c %Y "$CACHE") )) -gt "$CACHE_TTL" ]; then
  curl -s --max-time 5 "wttr.in/?format=j1" > "${CACHE}.tmp" 2>/dev/null
  if [ -s "${CACHE}.tmp" ]; then
    mv "${CACHE}.tmp" "$CACHE"
  else
    rm -f "${CACHE}.tmp"
  fi
fi

field="${1:-all}"

if [ ! -f "$CACHE" ]; then
  case "$field" in
    icon) echo "?" ;; temp|min|max|feels|humidity|wind|desc|color|location) echo "--" ;; *) echo "?" ;;
  esac
  exit 0
fi

case "$field" in
  icon)
    code=$(jq -r '.current_condition[0].weatherCode' "$CACHE" 2>/dev/null)
    case "$code" in
      113) echo "☀️" ;; 116) echo "⛅" ;; 119|122) echo "☁️" ;;
      143|248|260) echo "🌫️" ;; 176|263|266|293|296) echo "🌦️" ;;
      179|182|185|281|284|311|314|317) echo "🌨️" ;;
      200|386|389|392|395) echo "⛈️" ;;
      227|230|320|323|326|329|332|335|338|350|368|371|374|377) echo "❄️" ;;
      299|302|305|308|356|359) echo "🌧️" ;; *) echo "🌡️" ;;
    esac ;;
  temp)     printf '%s°\n' "$(jq -r '.current_condition[0].temp_C' "$CACHE" 2>/dev/null)" ;;
  min)      printf '%s°\n' "$(jq -r '.weather[0].mintempC' "$CACHE" 2>/dev/null)" ;;
  max)      printf '%s°\n' "$(jq -r '.weather[0].maxtempC' "$CACHE" 2>/dev/null)" ;;
  feels)    printf '%s°\n' "$(jq -r '.current_condition[0].FeelsLikeC' "$CACHE" 2>/dev/null)" ;;
  humidity) printf '%s%%\n' "$(jq -r '.current_condition[0].humidity' "$CACHE" 2>/dev/null)" ;;
  wind)
    speed=$(jq -r '.current_condition[0].windspeedKmph' "$CACHE" 2>/dev/null)
    dir=$(jq -r '.current_condition[0].winddir16Point' "$CACHE" 2>/dev/null)
    printf '%s km/h %s\n' "$speed" "$dir" ;;
  desc)     jq -r '.current_condition[0].weatherDesc[0].value' "$CACHE" 2>/dev/null ;;
  location) jq -r '.nearest_area[0] | "\(.areaName[0].value), \(.country[0].value)"' "$CACHE" 2>/dev/null ;;
  color)
    t=$(jq -r '.current_condition[0].temp_C' "$CACHE" 2>/dev/null)
    if   [ "$t" -le 0 ]  2>/dev/null; then echo "freezing"
    elif [ "$t" -le 10 ] 2>/dev/null; then echo "cold"
    elif [ "$t" -le 20 ] 2>/dev/null; then echo "mild"
    elif [ "$t" -le 30 ] 2>/dev/null; then echo "warm"
    else echo "hot"
    fi ;;
  humidity-icon)
    h=$(jq -r '.current_condition[0].humidity' "$CACHE" 2>/dev/null)
    if   [ "$h" -le 25 ] 2>/dev/null; then echo "🌵"
    elif [ "$h" -le 60 ] 2>/dev/null; then echo "😊"
    else echo "🥵"
    fi ;;
esac
