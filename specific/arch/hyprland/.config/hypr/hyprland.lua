-- Hyprland config, lua format (0.55+). Migrated from hyprland.conf.
-- Wiki: https://wiki.hypr.land/Configuring/Start/
-- Stubs for LSP autocomplete: /usr/share/hypr/stubs/

------------------
---- MONITORS ----
------------------

require("monitors")
require("workspaces")

-- pywal writes hyprlang ($var = value) because hyprlock/hypridle still use it.
-- Read that same file here so both stay in sync from one template.
local wal = {}
do
	local f = io.open(os.getenv("HOME") .. "/.cache/wal/colors-hyprland.conf", "r")
	if f then
		for line in f:lines() do
			local k, v = line:match("^%$(%S+)%s*=%s*(.-)%s*$")
			if k then
				wal[k] = v
			end
		end
		f:close()
	end
end

hl.config({
	xwayland = {
		-- https://wiki.hypr.land/Configuring/Advanced-and-Cool/XWayland/#hidpi-xwayland
		force_zero_scaling = true,
	},
})

---------------------
---- MY PROGRAMS ----
---------------------

-- hl.dsp.exec_cmd spawns from Hyprland itself, so the child gets the full
-- wayland env (this is what the old `hyprctl dispatch exec` hop was for).
local terminal = "rio"
local fileManager = "nemo"
local menu = "vicinae toggle"

-----------------
--- PLUGINS -----
-----------------

hl.permission({ binary = "/usr/(bin|local/bin)/hyprpm", type = "plugin", mode = "allow" })

-------------------
---- AUTOSTART ----
-------------------

hl.on("hyprland.start", function()
	-- uwsm already exports the session env to systemd/dbus

	-- XWayland primary output: Steam draws its notification toasts there
	hl.exec_cmd("xrandr --output DP-1 --primary")

	hl.exec_cmd("systemctl --user start hyprpolkitagent")

	-- Start easyEffects for EQ
	hl.exec_cmd("flatpak run com.github.wwmm.easyeffects -w --service-mode")

	hl.exec_cmd("tailscale-systray")
	hl.exec_cmd("systemctl --user start graphical-session-apps.target")
	-- Overlay flickers on WebKitGTK 2.54 with DMA-BUF off (Handy #2166). 0.9.8 overrides this var;
	-- the release after it honours it (PR #2249), so this takes effect on that update.
	hl.exec_cmd("env WEBKIT_DISABLE_DMABUF_RENDERER=0 handy --start-hidden")

	-- Start 1P last, after polkit + keyring prompt are done
	hl.exec_cmd("1password")
end)

-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/
-- Theme name is the icon dir name (/usr/share/icons/Colloid-cursors), not index.theme's Name=
hl.env("XCURSOR_THEME", "Colloid-cursors")
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_THEME", "Colloid-cursors")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")

-- Input method (Fcitx5) for proper dead key compose on Wayland
hl.env("QT_IM_MODULES", "wayland;fcitx;ibus")
hl.env("XMODIFIERS", "@im=fcitx")

-----------------------
---- LOOK AND FEEL ----
-----------------------

-- Refer to https://wiki.hypr.land/Configuring/Basics/Variables/
hl.config({
	general = {
		gaps_in = 2,
		gaps_out = 5,

		border_size = 3,

		col = {
			active_border = {
				colors = { wal.color2 or "rgba(33ccffee)", wal.color6 or "rgba(00ff99ee)" },
				angle = 45,
			},
			inactive_border = wal.color0 or "rgba(595959aa)",
		},

		-- Set to true enable resizing windows by clicking and dragging on borders and gaps
		resize_on_border = true,

		-- Please see https://wiki.hypr.land/Configuring/Advanced-and-Cool/Tearing/ before you turn this on
		allow_tearing = false,

		layout = "dwindle",
	},

	decoration = {
		rounding = 10,
		rounding_power = 2,

		-- Change transparency of focused and unfocused windows
		active_opacity = 1.0,
		inactive_opacity = 0.9,

		shadow = {
			enabled = false,
			range = 4,
			render_power = 10,
			color = wal.foreground or "rgba(1a1a1aee)",
		},

		blur = {
			enabled = true,
			size = 10,
			passes = 3,

			vibrancy = 0.1696,
		},
	},

	animations = {
		enabled = true,
	},

	-- See https://wiki.hypr.land/Configuring/Layouts/Dwindle-Layout/ for more
	dwindle = {
		preserve_split = true, -- You probably want this
	},

	-- See https://wiki.hypr.land/Configuring/Layouts/Master-Layout/ for more
	master = {
		new_status = "master",
	},

	render = {
		direct_scanout = false,
	},

	misc = {
		force_default_wallpaper = 0, -- Set to 0 or 1 to disable the anime mascot wallpapers
		disable_hyprland_logo = true, -- If true disables the random hyprland logo / anime girl background. :(
		disable_splash_rendering = true,
		vrr = 2, -- fullscreen only; 1 = always on
	},

	ecosystem = {
		no_donation_nag = true,
	},

	debug = {
		vfr = true,
	},
})

-- https://wiki.hypr.land/Configuring/Advanced-and-Cool/Animations/
hl.curve("easeOutQuint", { type = "bezier", points = { { 0.23, 1 }, { 0.32, 1 } } })
hl.curve("easeInOutCubic", { type = "bezier", points = { { 0.65, 0.05 }, { 0.36, 1 } } })
hl.curve("linear", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })
hl.curve("almostLinear", { type = "bezier", points = { { 0.5, 0.5 }, { 0.75, 1.0 } } })
hl.curve("quick", { type = "bezier", points = { { 0.15, 0 }, { 0.1, 1 } } })

hl.animation({ leaf = "global", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "border", enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows", enabled = true, speed = 4.79, bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 4.1, bezier = "easeOutQuint", style = "gnomed" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 1.49, bezier = "linear", style = "popin 87%" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade", enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers", enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 4, bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 1.5, bezier = "linear", style = "fade" })
hl.animation({ leaf = "fadeLayersIn", enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesIn", enabled = true, speed = 1.21, bezier = "almostLinear", style = "slidefade" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 1.94, bezier = "almostLinear", style = "slidefade" })

-- Ref https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/
-- "Smart gaps" / "No gaps when only"
hl.workspace_rule({ workspace = "w[tv1]", gaps_out = 0, gaps_in = 0 })
hl.workspace_rule({ workspace = "f[1]", gaps_out = 0, gaps_in = 0 })
hl.window_rule({ match = { float = false, workspace = "w[tv1]" }, border_size = 0 })
hl.window_rule({ match = { float = false, workspace = "w[tv1]" }, rounding = 0 })
hl.window_rule({ match = { float = false, workspace = "f[1]" }, border_size = 0 })
hl.window_rule({ match = { float = false, workspace = "f[1]" }, rounding = 0 })

---------------
---- INPUT ----
---------------

hl.config({
	input = {
		kb_layout = "us",
		kb_variant = "intl",
		kb_model = "",
		kb_options = "caps:escape",
		kb_rules = "",

		follow_mouse = 0,

		sensitivity = -0.5, -- -1.0 - 1.0, 0 means no modification.
		-- This only works for left handed mice
		-- on the Razer Naga LH it will make the mouse work normally
		-- But if you ever change the mouse to a "normal" one, you will need to set this to false
		left_handed = false,

		touchpad = {
			natural_scroll = false,
		},
	},
})

---------------------
---- KEYBINDINGS ----
---------------------

-- See https://wiki.hypr.land/Configuring/Basics/Binds/
local mainMod = "SUPER" -- Sets "Windows" key as main modifier

-- Clipboard Screenshots (grimshot = grimblast wrapper with focus-restore workaround)
hl.bind("PRINT", hl.dsp.exec_cmd("grimshot --freeze copy output"))
hl.bind(mainMod .. " + ALT + 3", hl.dsp.exec_cmd("grimshot --freeze copy active"))
hl.bind(mainMod .. " + ALT + 4", hl.dsp.exec_cmd("grimshot --freeze copy area"))

-- File Screenshots
hl.bind(
	"CTRL + PRINT",
	hl.dsp.exec_cmd("grimshot --freeze copysave output ~/Pictures/Screenshots/$(date +%Y-%m-%d-%H%M%S).png")
)
hl.bind(
	mainMod .. " + CTRL + 3",
	hl.dsp.exec_cmd("grimshot --freeze copysave active ~/Pictures/Screenshots/$(date +%Y-%m-%d-%H%M%S).png")
)
hl.bind(
	mainMod .. " + CTRL + 4",
	hl.dsp.exec_cmd("grimshot --freeze copysave area ~/Pictures/Screenshots/$(date +%Y-%m-%d-%H%M%S).png")
)

-- SwayNC Notification center
hl.bind(mainMod .. " + SHIFT + N", hl.dsp.exec_cmd("swaync-client -t -sw"))

hl.bind(mainMod .. " + RETURN", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + SHIFT + R", hl.dsp.exec_cmd('hyprctl reload && notify-send "Notice" "Hyprland was reloaded"'))
hl.bind("CTRL + ALT + SPACE", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + SHIFT + SPACE", hl.dsp.window.float())
hl.bind(mainMod .. " + SPACE", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + E", hl.dsp.layout("togglesplit")) -- dwindle
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ mode = "fullscreen" })) -- Real fullscreen
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.fullscreen({ mode = "maximized" })) -- Maintains top bar
hl.bind(mainMod .. " + ALT + C", hl.dsp.exec_cmd("vicinae vicinae://launch/clipboard/history"))
hl.bind(mainMod .. " + CTRL + C", hl.dsp.exec_cmd("copyq show"))
hl.bind(mainMod .. " + CTRL + SPACE", hl.dsp.exec_cmd("vicinae vicinae://launch/core/search-emojis"))
hl.bind("ALT + " .. mainMod .. " + SPACE", hl.dsp.exec_cmd("1password --quick-access"))
hl.bind("ALT + SHIFT + D", hl.dsp.exec_cmd(os.getenv("HOME") .. "/.config/hypr/handy-toggle"))

-- Behaves like tabbed i3 containers
hl.bind(mainMod .. " + G", hl.dsp.group.toggle())

-- Move focus with mainMod + hjkl
hl.bind(mainMod .. " + H", hl.dsp.focus({ direction = "l" }))
hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "r" }))
hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "u" }))
hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = "d" }))

-- Move windows in the workspace
hl.bind(mainMod .. " + SHIFT + H", hl.dsp.window.move({ direction = "l", group_aware = true }))
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.window.move({ direction = "r", group_aware = true }))
hl.bind(mainMod .. " + SHIFT + K", hl.dsp.window.move({ direction = "u", group_aware = true }))
hl.bind(mainMod .. " + SHIFT + J", hl.dsp.window.move({ direction = "d", group_aware = true }))

-- ALT TAB
hl.bind(mainMod .. " + TAB", hl.dsp.window.cycle_next({ next = false }))

------------------
--     RESIZE   --
------------------

-- will switch to a submap called resize
hl.bind(mainMod .. " + R", hl.dsp.submap("resize"))

hl.define_submap("resize", function()
	-- sets repeatable binds for resizing the active window
	hl.bind("L", hl.dsp.window.resize({ x = 10, y = 0, relative = true }), { repeating = true })
	hl.bind("H", hl.dsp.window.resize({ x = -10, y = 0, relative = true }), { repeating = true })
	hl.bind("K", hl.dsp.window.resize({ x = 0, y = -10, relative = true }), { repeating = true })
	hl.bind("J", hl.dsp.window.resize({ x = 0, y = 10, relative = true }), { repeating = true })

	-- use reset to go back to the global submap
	hl.bind("escape", hl.dsp.submap("reset"))
end)

------------------
--     system   --
------------------

-- will switch to a submap called system
hl.bind(mainMod .. " + CTRL + Q", function()
	hl.dispatch(hl.dsp.exec_cmd("nwg-bar"))
	hl.dispatch(hl.dsp.submap("system"))
end)

hl.define_submap("system", function()
	-- These don't need to exit because will turn off the compositor
	-- `poweroff -ff` because the normal path crashes the CPU during device teardown and the
	-- board resets instead of entering S5. See the 2026-08-30 devlog in AI Brainz.
	-- -ff never signals a process, never unmounts and never syncs, so do those by hand first.
	-- sudo is fine here: /etc/sudoers.d/00_khaosdoctor grants NOPASSWD:ALL, and Hyprland's exec
	-- runs the string through a shell, so the `;` chain works with no tty and no askpass.
	-- Network and NTFS mounts go by type, since none of those can ever be the root filesystem.
	-- The two local data volumes go by path: `-a -t ext4` would try `/` and just fail.
	-- Root stays mounted; it is ext4, so it replays its journal on the next boot.
	-- `;` and not `&&`, a busy unmount must not stop the poweroff.
	hl.bind(
		"Q",
		hl.dsp.exec_cmd(
			"sudo sync; "
				.. "sudo umount -a -t nfs4,fuse.sshfs,fuse.rclone,fuseblk,ext4; "
				.. "sudo sync; "
				.. "sudo systemctl poweroff -ff"
		),
		{ repeating = true }
	)
	hl.bind("E", hl.dsp.exit(), { repeating = true })
	hl.bind("R", hl.dsp.exec_cmd("hyprctl dispatch 'hl.dsp.exit()' && systemctl reboot"), { repeating = true })

	-- Needs to exit after the action otherwise we end up in the same submap
	hl.bind("L", function()
		hl.dispatch(hl.dsp.exec_cmd("pkill nwg-bar"))
		hl.dispatch(hl.dsp.exec_cmd("pidof hyprlock || hyprlock"))
		hl.dispatch(hl.dsp.submap("reset"))
	end, { repeating = true })
	hl.bind("S", function()
		hl.dispatch(hl.dsp.exec_cmd("pkill nwg-bar"))
		hl.dispatch(hl.dsp.exec_cmd("systemctl suspend"))
		hl.dispatch(hl.dsp.submap("reset"))
	end, { repeating = true })

	-- use reset to go back to the global submap
	hl.bind("escape", function()
		hl.dispatch(hl.dsp.exec_cmd("pkill nwg-bar"))
		hl.dispatch(hl.dsp.submap("reset"))
	end)
end)

-- Pin floating windows
hl.bind(mainMod .. " + P", hl.dsp.window.pin())

-- Switch workspaces with mainMod + [0-9]
-- Move active window to a workspace with mainMod + SHIFT + [0-9]
for i = 1, 10 do
	local key = i % 10 -- 10 maps to key 0
	hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
	hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Example special workspace (scratchpad)
hl.bind(mainMod .. " + MINUS", hl.dsp.workspace.toggle_special())
hl.bind(mainMod .. " + SHIFT + MINUS", hl.dsp.window.move({ workspace = "special" }))

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Laptop multimedia keys for volume and LCD brightness
hl.bind(
	"XF86AudioRaiseVolume",
	hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioLowerVolume",
	hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioMicMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
	{ locked = true, repeating = true }
)
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl s 10%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl s 10%-"), { locked = true, repeating = true })

-- Requires playerctl
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/

-- Ignore maximize requests from apps. You'll probably like this.
hl.window_rule({ match = { class = ".*" }, suppress_event = "maximize" })

-- Fix some dragging issues with XWayland
hl.window_rule({
	match = { class = "^$", title = "^$", xwayland = true, float = true, fullscreen = false, pin = false },
	no_initial_focus = true,
})

------------------
-- Floating apps + custom
------------------

hl.window_rule({ match = { class = "^(vlc)$" }, float = true, center = true })
hl.window_rule({ match = { class = "^(com.gabm.satty)$" }, float = true })

-- Open spotify on the special workspace (scratchpad) without notifying
hl.window_rule({
	name = "spotify",
	match = { class = "^(spotify)$" },
	float = true,
	center = true,
	size = { 1260, 1024 },
	workspace = "special silent",
})

hl.window_rule({
	name = "terminals",
	match = { class = "^(rio|kitty|com.mitchellh.ghostty)$" },
	size = { 1200, 830 },
	focus_on_activate = true,
	float = true,
	animation = "gnomed",
	center = true,
})

-- 1P quick access
hl.window_rule({
	name = "1password",
	match = { class = "^(1password)$" },
	center = true,
	float = true,
	pin = true,
	size = { 800, 600 },
	animation = "gnomed",
})

-- Hidden from screen shares (shows as a black box)
hl.window_rule({
	name = "no-screen-share",
	match = {
		class = "^(1password|com.onepassword.OnePassword|protonvpn-app|proton.vpn.app.gtk|md.obsidian.Obsidian|com.rtosta.zapzap|org.telegram.desktop)$",
	},
	no_screen_share = true,
})

hl.window_rule({ match = { class = "^(virt-manager)$" }, float = true })

-- App categories: add a class to a list below to apply that category's rule to it.
local app_categories = {
	float_center = {
		"nemo",
		"org.pulseaudio.pavucontrol",
		"nm-connection-editor",
		"gparted",
		"io.missioncenter.MissionCenter",
		"btrfs-assistant",
		"org.qbittorrent.qBittorrent",
		"FreeFileSync",
		"com.github.wwmm.easyeffects",
		"io.github.ilya_zlobintsev.LACT",
		"io.github.thetumultuousunicornofdarkness.cpu-x",
		"hardinfo2",
		"nwg-displays",
		"openrgb",
		"org.gnome.World.PikaBackup",
		"protonvpn-app",
		"proton.vpn.app.gtk",
		"org.gnome.DiskUtility",
		"org.gnome.baobab",
		"org.gnome.FileRoller",
		"org.gnome.Logs",
		"org.gnome.Evince",
		"org.gnome.TextEditor",
	},
	float_center_small = {
		"io.github.kaii_lb.Overskride",
		"nwg-look",
		"qt6ct",
		"org.fcitx.fcitx5-config-qt",
		"waypaper",
		"org.gnome.Characters",
		"org.gnome.font-viewer",
	},
}

hl.window_rule({
	match = { class = "^(" .. table.concat(app_categories.float_center, "|") .. ")$" },
	float = true,
	center = true,
	size = { 1200, 830 },
})

hl.window_rule({
	match = { class = "^(" .. table.concat(app_categories.float_center_small, "|") .. ")$" },
	float = true,
	center = true,
	size = { 900, 650 },
})

-- Remember last floating size for apps that get resized by hand
hl.window_rule({
	match = { class = "^(io.github.ilya_zlobintsev.LACT|io.github.kaii_lb.Overskride)$" },
	persistent_size = true,
})

-- Telegram media viewer (title from tdesktop lng_mediaview_title)
hl.window_rule({
	name = "telegram-media-viewer",
	match = { class = "^(org.telegram.desktop)$", title = "^(Media viewer)$" },
	float = true,
	center = true,
	no_anim = true,
	persistent_size = true,
	size = { "monitor_w*0.8", "monitor_h*0.85" },
})

hl.window_rule({
	name = "pip",
	-- Vivaldi titles it "Picture in picture" (spaces), Firefox "Picture-in-Picture"
	match = { title = "^([Pp]icture[- ][Ii]n[- ][Pp]icture)$" },
	float = true,
	center = true,
	pin = true,
	keep_aspect_ratio = true,
	size = { 800, 450 },
	idle_inhibit = "always",
})

-- Keep hypridle from locking during fullscreen video/games
hl.window_rule({
	name = "idle-fullscreen",
	match = { class = "^(vivaldi-stable|steam_app_.*)$" },
	idle_inhibit = "fullscreen",
})
hl.window_rule({ name = "idle-media", match = { class = "^(mpv|vlc)$" }, idle_inhibit = "focus" })

hl.window_rule({
	name = "copyq",
	match = { class = "^(com.github.hluk.copyq)$" },
	float = true,
	pin = true,
	size = { 550, 600 },
	center = true,
})

-- Bring the polkit agent up to the top layer
hl.window_rule({
	name = "hyprpolkitagent",
	match = { class = "^(hyprpolkitagent)$" },
	pin = true,
	center = true,
	float = true,
	focus_on_activate = true,
	stay_focused = true,
	animation = "popin",
	dim_around = true,
})

-- Gnome calculator
hl.window_rule({
	name = "calculator",
	match = { class = "^(org.gnome.Calculator)$" },
	center = true,
	float = true,
	focus_on_activate = true,
	size = { "window_w/6", "window_h*0.5" },
	-- min_size / max_size take a plain vec2 ({ 800, 600 }), not expressions, so
	-- the old `(window_w/6) (window_h*0.5)` values are dropped rather than
	-- kept as a permanent type error. Put concrete pixels here to pin the size.
})

------------------
-- Open on workspace 2
------------------
hl.window_rule({ match = { class = "^(com.rtosta.zapzap)$" }, workspace = "2" })
hl.window_rule({ match = { class = "^(org.telegram.desktop)$" }, workspace = "2" })
hl.window_rule({ match = { class = "^(discord)$" }, workspace = "2" })
hl.window_rule({ match = { class = "^(vivaldi-stable)$" }, workspace = "1" })
hl.window_rule({ match = { class = "^(BambuStudio)$" }, monitor = "DP-1" })
hl.window_rule({ match = { class = "^(OrcaSlicer)$" }, monitor = "DP-1" })
hl.window_rule({ match = { class = "^(com.tibia.Tibia)$" }, workspace = "3" })

---------------
-- STEAM GAMES
---------------
hl.window_rule({ match = { class = "^(steam_app_)(.*)" }, monitor = "DP-1" })
hl.window_rule({ match = { content = "game" }, monitor = "DP-1" })
hl.window_rule({ match = { class = "^(steam_app_)(.*)" }, workspace = "3" })
hl.window_rule({ match = { content = "game" }, workspace = "3" })

---------------
-- STEAM CLIENT (titles from ~/.steam/steam/logs/webhelper.txt; main window "Steam" stays tiled)
---------------
hl.window_rule({
	name = "steam-friends",
	match = { class = "^(steam)$", title = "^(Friends List)$" },
	float = true,
	center = true,
	size = { 400, 700 },
})
hl.window_rule({
	name = "steam-login",
	match = { class = "^(steam)$", title = "^(Sign in to Steam)$" },
	float = true,
	center = true,
})
-- XWayland toasts can't be moved by rules; DP-1 placement comes from xrandr --primary in autostart
hl.window_rule({
	name = "steam-toasts",
	match = { class = "^(steam)$", title = "^(notificationtoasts_.*)$" },
	float = true,
	pin = true,
	no_initial_focus = true,
	no_focus = true,
	no_anim = true,
})

------------------
-- Exiled Exchange 2 (PoE2 price overlay, XWayland)
-- Its transparent fullscreen overlay otherwise makes Hyprland blur the
-- game behind it. no_blur stops that.
------------------
hl.window_rule({ match = { class = "^(exiled-exchange-2)$" }, no_blur = true })

------------------
-- Frameless Chromium/CEF popups (Spotify mini player) paint a transparent
-- shadow margin inside their surface, so Hyprland blurs and borders it.
-- Add more classes to the list when another app shows the same halo.
------------------
local transparent_margin = { "chromium-browser" }
hl.window_rule({
	name = "transparent-margin",
	match = { class = "^(" .. table.concat(transparent_margin, "|") .. ")$", float = true },
	no_blur = true,
	no_shadow = true,
	border_size = 0,
	rounding = 0,
})

------------------
-- Floating based on roles/types
------------------
hl.window_rule({
	match = { title = "^(File Operation Progress)$" },
	float = true,
	border_color = "rgb(000000)", -- closest to border pixel 1
	pin = true,
	size = { "monitor_w*0.4", "monitor_h*0.3" },
})
hl.window_rule({
	match = { title = "^(File Upload)$" },
	float = true,
	border_color = "rgb(000000)", -- closest to border pixel 1
	pin = true,
	size = { "monitor_w*0.4", "monitor_h*0.3" },
})
-- Nemo's multi-file rename (bulk-rename-tool = thunar --bulk-rename)
hl.window_rule({
	name = "thunar-bulk-rename",
	match = { class = "^(thunar)$", title = "^(Bulk Rename).*" },
	float = true,
	center = true,
	size = { 928, 690 },
})
hl.window_rule({
	name = "center-floating-windows",
	match = { float = true, xwayland = false, title = "negative:^(menu)$" },
	center = true,
})

-- Portal dialogs (GTK file chooser used by Vivaldi downloads/uploads, etc).
-- These report as xwayland so center-floating-windows above skips them.
hl.window_rule({
	name = "portal-dialogs",
	match = { class = "^([Xx]dg-desktop-portal-gtk)$" },
	float = true,
	center = true,
})

hl.layer_rule({ match = { namespace = "waybar" }, blur = true })

-- eww widgets: no focus, no input
hl.layer_rule({
	match = { namespace = "eww*" },
	no_anim = true,
})

-- swaync popups + control center hidden from screen shares
hl.layer_rule({
	match = { namespace = "^swaync-(notification-window|control-center)$" },
	no_screen_share = true,
})

-- VICINAE
hl.layer_rule({
	name = "vicinae-blur",
	match = { namespace = "vicinae" },
	blur = true,
	ignore_alpha = 0,
})

-- disable animation for vicinae only
hl.layer_rule({
	name = "vicinae-no-animation",
	match = { namespace = "vicinae" },
	no_anim = true,
})
