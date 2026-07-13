#!/usr/bin/env bash

input=$(cat)

cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // empty')
model=$(echo "$input" | jq -r '.model.display_name // empty')
model_id=$(echo "$input" | jq -r '.model.id // empty')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
total_tokens=$(echo "$input" | jq -r '.context_window.total_input_tokens // 0')
total_out_tokens=$(echo "$input" | jq -r '.context_window.total_output_tokens // 0')
last_msg_tokens=$(echo "$input" | jq -r '.context_window.current_usage.output_tokens // 0')
effort=$(echo "$input" | jq -r '.effort.level // empty')
session_name=$(echo "$input" | jq -r '.session_name // .session_id // empty')
five_h_pct=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
seven_d_pct=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
five_h_reset=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
seven_d_reset=$(echo "$input" | jq -r '.rate_limits.seven_day.resets_at // empty')

# ANSI colors
BLUE="\033[38;5;75m"
MAGENTA="\033[38;5;183m"
GREEN="\033[38;5;114m"
YELLOW="\033[38;5;221m"
ORANGE="\033[38;5;208m"
WHITE="\033[38;5;255m"
DIM="\033[2m"
RESET="\033[0m"

# Shorten home directory to ~
if [ -n "$cwd" ]; then
  home="$HOME"
  display_dir="${cwd/#$home/\~}"
else
  display_dir="$(pwd)"
fi

# Git branch (skip locks)
git_branch=""
if [ -d "$cwd/.git" ] || env -i HOME="$HOME" PATH=/usr/bin:/bin:/usr/sbin:/sbin:/opt/homebrew/bin /usr/bin/git -C "$cwd" rev-parse --git-dir >/dev/null 2>&1; then
  git_branch=$(env -i HOME="$HOME" PATH=/usr/bin:/bin:/usr/sbin:/sbin:/opt/homebrew/bin /usr/bin/git --no-pager -C "$cwd" symbolic-ref --short HEAD 2>/dev/null)
fi

# Effort color: low=dim, medium=green, high=yellow, xhigh=orange, max=red
effort_color=""
if [ -n "$effort" ]; then
  case "$effort" in
    low)    effort_color="${BLUE}" ;;
    medium) effort_color="${GREEN}" ;;
    high)   effort_color="${YELLOW}" ;;
    xhigh)  effort_color="${ORANGE}" ;;
    max)    effort_color="\033[38;5;196m" ;;
  esac
fi

# Line 1: session + path + git branch
line1=""
if [ -n "$session_name" ]; then
  line1="${DIM}${WHITE}[${session_name}]${RESET}"
fi

# Directory segment
line1="$line1 ${BLUE}${display_dir}${RESET}"

# Git branch segment
if [ -n "$git_branch" ]; then
  line1="$line1  ${MAGENTA}${git_branch}${RESET}"
fi

# Line 2: model (effort) + ctx + tokens + cost
line2=""
if [ -n "$model" ]; then
  if [ -n "$effort" ]; then
    line2="${MAGENTA}${model}${RESET} ${DIM}(${RESET}${effort_color}${effort}${RESET}${DIM})${RESET}"
  else
    line2="${MAGENTA}${model}${RESET}"
  fi
fi

# Pricing per 1M tokens [input, output] by model ID prefix.
# Source: platform.claude.com/docs/en/docs/about-claude/pricing (verified 2026-07-02).
# Naive estimate: ignores prompt-cache reads (0.1x) and /fast mode (6x), so this
# is a worst-case ceiling rather than actual spend.
cost_str=""
if [ -n "$model_id" ] && { [ "$total_tokens" -gt 0 ] || [ "$total_out_tokens" -gt 0 ]; } 2>/dev/null; then
  case "$model_id" in
    claude-fable-5*)                                                     price_in=10.00; price_out=50.00 ;;
    claude-opus-4-8*|claude-opus-4-7*|claude-opus-4-6*|claude-opus-4-5*) price_in=5.00;  price_out=25.00 ;;
    claude-sonnet-5*)                                                    price_in=2.00;  price_out=10.00 ;;
    claude-haiku-4*)                                                     price_in=1.00;  price_out=5.00  ;;
    *)                                                                   price_in=2.00;  price_out=10.00 ;;
  esac
  cost=$(awk "BEGIN {printf \"%.4f\", ($total_tokens * $price_in + $total_out_tokens * $price_out) / 1000000}")
  cost_str=" ${DIM}·${RESET} ${DIM}~\$${cost}${RESET}"
fi

# Rate limit color scale: <50=green, <70=yellow, <85=orange, >=85=red
rate_color() {
  local pct_int
  pct_int=$(printf "%.0f" "$1")
  if [ "$pct_int" -ge 85 ]; then
    echo "\033[38;5;196m"
  elif [ "$pct_int" -ge 70 ]; then
    echo "${ORANGE}"
  elif [ "$pct_int" -ge 50 ]; then
    echo "${YELLOW}"
  else
    echo "${GREEN}"
  fi
}

# Render a compact unicode progress bar scaled to a percentage.
# Usage: progress_bar <pct> <width> <color>
progress_bar() {
  local pct="$1" width="$2" color="$3"
  local pct_int filled empty bar
  pct_int=$(printf "%.0f" "$pct")
  filled=$(( pct_int * width / 100 ))
  [ "$filled" -gt "$width" ] && filled="$width"
  empty=$(( width - filled ))
  bar=""
  local i
  for ((i = 0; i < filled; i++)); do bar="${bar}▓"; done
  for ((i = 0; i < empty; i++)); do bar="${bar}░"; done
  printf "%s%s%s%s" "${color}" "${bar}" "${RESET}" ""
}

# Format a future unix epoch as an absolute time ("14:30")
absolute_time() {
  local target_epoch="$1"
  [ -z "$target_epoch" ] && return
  date -r "$target_epoch" "+%H:%M" 2>/dev/null || date -d "@$target_epoch" "+%H:%M" 2>/dev/null
}

# Format a future unix epoch as an absolute day + time ("Sat 14:30")
absolute_day_time() {
  local target_epoch="$1"
  [ -z "$target_epoch" ] && return
  date -r "$target_epoch" "+%a %H:%M" 2>/dev/null || date -d "@$target_epoch" "+%a %H:%M" 2>/dev/null
}

# Line 3: rate limit usage windows (5h / 7d) with reset times
line3=""
if [ -n "$five_h_pct" ]; then
  five_h_color=$(rate_color "$five_h_pct")
  five_h_abs=$(absolute_time "$five_h_reset")
  five_h_bar=$(progress_bar "$five_h_pct" 5 "$five_h_color")
  seg="${DIM}5h:${RESET}${five_h_color}$(printf "%.0f" "$five_h_pct")%${RESET} ${five_h_bar}"
  [ -n "$five_h_abs" ] && seg="$seg ${DIM}(${five_h_abs})${RESET}"
  line3="$seg"
fi
if [ -n "$seven_d_pct" ]; then
  seven_d_color=$(rate_color "$seven_d_pct")
  seven_d_abs=$(absolute_day_time "$seven_d_reset")
  seven_d_bar=$(progress_bar "$seven_d_pct" 6 "$seven_d_color")
  seg="${DIM}7d:${RESET}${seven_d_color}$(printf "%.0f" "$seven_d_pct")%${RESET} ${seven_d_bar}"
  [ -n "$seven_d_abs" ] && seg="$seg ${DIM}(${seven_d_abs})${RESET}"
  if [ -n "$line3" ]; then
    line3="$line3 ${DIM}·${RESET} $seg"
  else
    line3="$seg"
  fi
fi

# Context usage segment
if [ -n "$used_pct" ]; then
  printf_pct=$(printf "%.0f" "$used_pct")
  if [ "$printf_pct" -ge 85 ]; then
    ctx_color="\033[38;5;196m"
  elif [ "$printf_pct" -ge 70 ]; then
    ctx_color="${ORANGE}"
  elif [ "$printf_pct" -ge 50 ]; then
    ctx_color="${YELLOW}"
  else
    ctx_color="${GREEN}"
  fi
  tok_str=""
  if { [ -n "$total_tokens" ] && [ "$total_tokens" -gt 0 ]; } || { [ -n "$total_out_tokens" ] && [ "$total_out_tokens" -gt 0 ]; } 2>/dev/null; then
    total_combined=$(( total_tokens + total_out_tokens ))
    fmt_num() {
      local n=$1
      if [ "$n" -ge 1000 ]; then
        awk "BEGIN {printf \"%.1fk\", $n/1000}"
      else
        echo "$n"
      fi
    }
    in_fmt=$(fmt_num "$total_tokens")
    out_fmt=$(fmt_num "$total_out_tokens")
    total_fmt=$(fmt_num "$total_combined")
    tok_str=" ${DIM}·${RESET} ${DIM}↓${RESET}${ctx_color}${in_fmt}${RESET} ${DIM}↑${RESET}${ctx_color}${out_fmt}${RESET} ${DIM}Σ${RESET}${ctx_color}${total_fmt}${RESET}"
    if [ -n "$last_msg_tokens" ] && [ "$last_msg_tokens" -gt 0 ] 2>/dev/null; then
      last_msg_fmt=$(fmt_num "$last_msg_tokens")
      tok_str="$tok_str ${DIM}(last msg:${RESET}${ctx_color}${last_msg_fmt}${RESET}${DIM})${RESET}"
    fi
  fi
  if [ -n "$line2" ]; then
    line2="$line2 ${DIM}|${RESET} ${ctx_color}ctx: ${printf_pct}%${RESET}${tok_str}${cost_str}"
  else
    line2="${ctx_color}ctx: ${printf_pct}%${RESET}${tok_str}${cost_str}"
  fi
fi

output="$line1"
[ -n "$line2" ] && output="$output"$'\n'"$line2"
[ -n "$line3" ] && output="$output"$'\n'"$line3"

printf "%b\n" "$output"
