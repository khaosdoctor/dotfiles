#!/usr/bin/env bash

input=$(cat)

cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // empty')
model=$(echo "$input" | jq -r '.model.display_name // empty')
model_id=$(echo "$input" | jq -r '.model.id // empty')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
total_tokens=$(echo "$input" | jq -r '.context_window.total_input_tokens // 0')
total_out_tokens=$(echo "$input" | jq -r '.context_window.total_output_tokens // 0')
effort=$(echo "$input" | jq -r '.effort.level // empty')
session_name=$(echo "$input" | jq -r '.session_name // .session_id // empty')

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
# Source: platform.claude.com/docs/en/docs/about-claude/pricing (verified 2026-05-22).
# Naive estimate: ignores prompt-cache reads (0.1x) and /fast mode (6x), so this
# is a worst-case ceiling rather than actual spend.
cost_str=""
if [ -n "$model_id" ] && { [ "$total_tokens" -gt 0 ] || [ "$total_out_tokens" -gt 0 ]; } 2>/dev/null; then
  case "$model_id" in
    claude-opus-4-7*|claude-opus-4-6*|claude-opus-4-5*) price_in=5.00;  price_out=25.00 ;;
    claude-opus-4*)                                     price_in=15.00; price_out=75.00 ;;
    claude-sonnet-4*)                                   price_in=3.00;  price_out=15.00 ;;
    claude-haiku-4*)                                    price_in=1.00;  price_out=5.00  ;;
    claude-haiku-3*)                                    price_in=0.80;  price_out=4.00  ;;
    *)                                                  price_in=3.00;  price_out=15.00 ;;
  esac
  cost=$(awk "BEGIN {printf \"%.4f\", ($total_tokens * $price_in + $total_out_tokens * $price_out) / 1000000}")
  cost_str=" ${DIM}·${RESET} ${DIM}~\$${cost}${RESET}"
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
  fi
  if [ -n "$line2" ]; then
    line2="$line2 ${DIM}|${RESET} ${ctx_color}ctx: ${printf_pct}%${RESET}${tok_str}${cost_str}"
  else
    line2="${ctx_color}ctx: ${printf_pct}%${RESET}${tok_str}${cost_str}"
  fi
fi

if [ -n "$line2" ]; then
  printf "%b\n%b\n" "$line1" "$line2"
else
  printf "%b\n" "$line1"
fi
