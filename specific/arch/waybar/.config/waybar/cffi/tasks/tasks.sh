#!/usr/bin/env bash
# Backend for the cffi/tasks waybar module. Minimized windows live on workspace 99.
#   tasks.sh list MONITOR      -> JSON array: windows on MONITOR + every minimized window
#   tasks.sh hide              -> minimize the focused window (SUPER + M)
#   tasks.sh ACTION ADDRESS    -> focus | minimize | restore | close | float | fullscreen | pin | kill | forcekill
WS=99
CACHE=${XDG_CACHE_HOME:-$HOME/.cache}/waybar-tasks-icons.tsv

refresh() { pkill -RTMIN+8 waybar; }
dispatch() { hyprctl dispatch "$1" >/dev/null; }
active_addr() { hyprctl activewindow -j | jq -r '.address // empty'; }

# Hyprland dispatchers without a window selector act on the focused window, so focus the
# target first and refuse to act if focus didn't move there
focused_on() {
  dispatch "hl.dsp.focus({ window = \"address:$1\" })"
  [[ $(active_addr) == "$1" ]] || { notify-send "tasks" "Could not focus $1, action skipped"; exit 1; }
}

# class -> icon path: .desktop Icon= -> GTK icon theme -> hicolor -> pixmaps, cached per class
icon_for() {
  local class=$1 theme desktop icon
  icon=$(awk -F'\t' -v c="$class" '$1 == c { print $2; exit }' "$CACHE" 2>/dev/null)
  [[ -n $icon && -e $icon ]] && { echo "$icon"; return; }
  theme=$(gsettings get org.gnome.desktop.interface icon-theme | tr -d "'")
  desktop=$(grep -lis "^StartupWMClass=$class$" /usr/share/applications/*.desktop ~/.local/share/applications/*.desktop | head -1)
  [[ -z $desktop ]] && desktop=$(ls /usr/share/applications/"$class".desktop ~/.local/share/applications/"$class".desktop 2>/dev/null | head -1)
  icon=$(grep -m1 '^Icon=' "$desktop" 2>/dev/null | cut -d= -f2)
  icon=${icon:-$class}
  [[ $icon == /* ]] || icon=$( {
    find -L /usr/share/icons/"$theme" -path '*apps*' -name "$icon.svg" 2>/dev/null
    ls /usr/share/icons/hicolor/{scalable,256x256,128x128,48x48}/apps/"$icon".{svg,png} /usr/share/pixmaps/"$icon".{svg,png} 2>/dev/null
  } | head -1)
  icon=${icon:-$(find -L /usr/share/icons/"$theme" -name application-x-executable.svg | head -1)}
  printf '%s\t%s\n' "$class" "$icon" >>"$CACHE"
  echo "$icon"
}

action=$1 addr=$2
case $action in
  list)
    mon_id=$(hyprctl monitors -j | jq --arg m "$addr" '.[] | select(.name == $m) | .id')
    active=$(active_addr)
    # Pinned windows go first; minimized go last, so restoring one doesn't shuffle the others
    # siblings = windows sharing the process, i.e. what a kill takes down
    hyprctl clients -j | jq -r --argjson ws "$WS" --argjson mon "${mon_id:-0}" '
      (group_by(.pid) | map({key: (.[0].pid | tostring), value: length}) | from_entries) as $per_pid
      | [.[] | select(.mapped and .workspace.id > 0 and (.monitor == $mon or .workspace.id == $ws))]
      | sort_by((.pinned | not), (.workspace.id == $ws), .workspace.id, .address)
      | .[] | [.address, .class, .workspace.id, .floating, .pinned, .fullscreen, $per_pid[.pid | tostring], .title] | @tsv' |
      while IFS=$'\t' read -r a class ws floating pinned fullscreen siblings title; do
        jq -nc --arg a "$a" --arg i "$(icon_for "$class")" --arg t "$title" --arg c "$class" --argjson s "$siblings" \
          --argjson m "$([[ $ws == "$WS" ]] && echo true || echo false)" \
          --argjson act "$([[ $a == "$active" ]] && echo true || echo false)" \
          --argjson f "$floating" --argjson p "$pinned" --argjson fs "$([[ $fullscreen != 0 ]] && echo true || echo false)" \
          '{address: $a, icon: $i, title: $t, class: $c, minimized: $m, active: $act, floating: $f, pinned: $p, fullscreen: $fs, siblings: $s}'
      done | jq -sc .
    exit 0
    ;;
  hide)
    dispatch "hl.dsp.window.move({ workspace = $WS, follow = false })"
    ;;
  focus) focused_on "$addr" ;;
  minimize)
    dispatch "hl.dsp.window.move({ workspace = $WS, window = \"address:$addr\", follow = false })"
    ;;
  restore)
    ws=$(hyprctl activeworkspace -j | jq -r .id)
    dispatch "hl.dsp.window.move({ workspace = $ws, window = \"address:$addr\" })"
    focused_on "$addr"
    ;;
  close) focused_on "$addr" && dispatch "hl.dsp.window.close()" ;;
  float) focused_on "$addr" && dispatch "hl.dsp.window.float()" ;;
  fullscreen) focused_on "$addr" && dispatch "hl.dsp.window.fullscreen()" ;;
  pin) focused_on "$addr" && dispatch "hl.dsp.window.pin()" ;;
  kill | forcekill)
    pid=$(hyprctl clients -j | jq -r --arg a "$addr" '.[] | select(.address == $a) | .pid')
    [[ -z $pid ]] && exit 1
    kill "$([[ $action == kill ]] && echo -TERM || echo -KILL)" "$pid"
    # A process blocked in the kernel (D state, usually a hung disk or network mount) only dies once that I/O returns
    sleep 1
    if [[ $(ps -o stat= -p "$pid") == D* ]]; then
      notify-send -u critical "tasks: $pid not dead yet" \
        "$(ps -o comm= -p "$pid") is stuck waiting on disk/network I/O (D state). The signal is queued and applies once that I/O returns."
    fi
    ;;
  *)
    echo "unknown action: $action" >&2
    exit 1
    ;;
esac
refresh
