#!/bin/bash
# Restores the session after start-hyprland brings Hyprland back from a crash.
# The restart runs with --safe-mode, so hl.on("hyprland.start") in hyprland.lua never fires.
# Run with --now to do a single restore pass against the current session.

# "process pattern|command": relaunched after every crash (exec_cmd apps from hyprland.lua)
ALWAYS=(
	"easyeffects|flatpak run com.github.wwmm.easyeffects -w --service-mode"
	"tailscale-systray|tailscale-systray"
	"handy|handy --start-hidden"
	# 1P last, after polkit + keyring prompt are done
	"1password|1password"
)
# "coredump comm|command": relaunched only when they died in the crash
ON_CRASH=(
	"Discord|discord"
	"vivaldi-bin|vivaldi-stable"
)

hypr_exec() {
	echo "relaunching: $1"
	hyprctl dispatch "hl.dsp.exec_cmd(\"$1\")" >/dev/null
}

restore() {
	local since=$1

	# The dead instance's socket dir lingers, so only a live reply from the newest one counts
	until hyprctl version >/dev/null 2>&1; do
		sleep 1
		export HYPRLAND_INSTANCE_SIGNATURE=$(ls -t "$XDG_RUNTIME_DIR/hypr" | head -1)
	done

	# Safe mode runs a generated fallback config
	hyprctl reload >/dev/null
	# Gives systemd-coredump time to record everything that died
	sleep 5

	local crashed
	crashed=$(coredumpctl -q --no-pager -F COREDUMP_COMM --since "@$since" 2>/dev/null)

	for entry in "${ALWAYS[@]}"; do
		pgrep -f "${entry%%|*}" >/dev/null || hypr_exec "${entry#*|}"
	done
	for entry in "${ON_CRASH[@]}"; do
		grep -qx "${entry%%|*}" <<<"$crashed" || continue
		pgrep -x "${entry%%|*}" >/dev/null || hypr_exec "${entry#*|}"
	done
}

if [[ $1 == --now ]]; then
	restore "$(date -d '-1 min' +%s)"
	exit
fi

# start-hyprland colors its output, so journald stores those lines as blobs:
# --grep skips blobs, -a prints them so grep can match
journalctl --user -f -n0 -o cat -a -u wayland-wm@hyprland.desktop.service |
	grep -a --line-buffered 'exit not-cleanly' |
	while read -r _; do
		echo "Hyprland crash detected, restoring"
		restore "$(date -d '-30 sec' +%s)"
	done
