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
            if k then wal[k] = v end
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
local terminal = "ghostty"
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
    -- Export dbus variables to systemd so it knows when wayland has started
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_RUNTIME_DIR XDG_CURRENT_DESKTOP HYPRLAND_INSTANCE_SIGNATURE GTK_IM_MODULE QT_IM_MODULE XMODIFIERS")
    hl.exec_cmd("systemctl --user import-environment WAYLAND_DISPLAY XDG_RUNTIME_DIR XDG_CURRENT_DESKTOP HYPRLAND_INSTANCE_SIGNATURE GTK_IM_MODULE QT_IM_MODULE XMODIFIERS")

    -- Start Fcitx5 input method daemon
    hl.exec_cmd("fcitx5 -d")

    -- Overall app drawer launchpad
    hl.exec_cmd("nwg-drawer -r")

    -- Start 1P
    hl.exec_cmd("1password")

    -- Start easyEffects for EQ
    hl.exec_cmd("flatpak run com.github.wwmm.easyeffects -w --service-mode")

    hl.exec_cmd("tailscale-systray")
    hl.exec_cmd("systemctl --user start hyprpolkitagent")
    hl.exec_cmd("systemctl --user start graphical-session-apps.target")
    hl.exec_cmd("uwsm app -- copyq --start-server")
    -- Slideshow for wallpapers
    hl.exec_cmd(os.getenv("HOME") .. "/.config/waypaper/slideshow.sh")
    hl.exec_cmd("handy --start-hidden")
end)

-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/
-- hl.env("XCURSOR_THEME", "Colloid Cursors")
hl.env("XCURSOR_THEME", "phinger-cursors-light")
hl.env("XCURSOR_SIZE", "32")
-- hl.env("HYPRCURSOR_THEME", "Colloid Cursors")
hl.env("HYPRCURSOR_THEME", "phinger-cursors-light")
hl.env("HYPRCURSOR_SIZE", "32")
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

    cursor = {
        no_hardware_cursors = 1,
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
            size = 9,
            passes = 1,

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

hl.animation({ leaf = "global",        enabled = true, speed = 10,   bezier = "default" })
hl.animation({ leaf = "border",        enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows",       enabled = true, speed = 4.79, bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsIn",     enabled = true, speed = 4.1,  bezier = "easeOutQuint", style = "gnomed" })
hl.animation({ leaf = "windowsOut",    enabled = true, speed = 1.49, bezier = "linear",       style = "popin 87%" })
hl.animation({ leaf = "fadeIn",        enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut",       enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade",          enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers",        enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn",      enabled = true, speed = 4,    bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut",     enabled = true, speed = 1.5,  bezier = "linear",       style = "fade" })
hl.animation({ leaf = "fadeLayersIn",  enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces",    enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesIn",  enabled = true, speed = 1.21, bezier = "almostLinear", style = "slidefade" })
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

-- Clipboard Screenshots
hl.bind("PRINT", hl.dsp.exec_cmd("hyprshot -m output --clipboard-only"))
hl.bind(mainMod .. " + ALT + 3", hl.dsp.exec_cmd("hyprshot -z -m active -m output --clipboard-only"))
hl.bind(mainMod .. " + ALT + 4", hl.dsp.exec_cmd("hyprshot -z -m region --clipboard-only"))

-- File Screenshots
hl.bind("CTRL + PRINT", hl.dsp.exec_cmd("hyprshot -z -m output -o ~/Pictures/Screenshots"))
hl.bind(mainMod .. " + CTRL + 3", hl.dsp.exec_cmd("hyprshot -z -m active -m output -o ~/Pictures/Screenshots"))
hl.bind(mainMod .. " + CTRL + 4", hl.dsp.exec_cmd("hyprshot -z -m region -o ~/Pictures/Screenshots"))

-- SwayNC Notification center
hl.bind(mainMod .. " + SHIFT + N", hl.dsp.exec_cmd("swaync-client -t -sw"))

hl.bind(mainMod .. " + RETURN", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + SHIFT + R", hl.dsp.exec_cmd('hyprctl reload && notify-send "Notice" "Hyprland was reloaded"'))
hl.bind(mainMod .. " + ALT + SPACE", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + SHIFT + SPACE", hl.dsp.window.float())
hl.bind(mainMod .. " + SPACE", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + E", hl.dsp.layout("togglesplit")) -- dwindle
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ mode = "fullscreen" })) -- Real fullscreen
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.fullscreen({ mode = "maximized" })) -- Maintains top bar
hl.bind(mainMod .. " + ALT + C", hl.dsp.exec_cmd("vicinae vicinae://launch/clipboard/history"))
hl.bind(mainMod .. " + SHIFT + TAB", hl.dsp.exec_cmd("walker --maxheight 300 --width 800 -m windows"))
hl.bind(mainMod .. " + CTRL + C", hl.dsp.exec_cmd("copyq show"))
hl.bind(mainMod .. " + CTRL + SPACE", hl.dsp.exec_cmd("vicinae vicinae://launch/core/search-emojis"))
hl.bind("ALT + CTRL + SPACE", hl.dsp.exec_cmd("1password --quick-access"))
hl.bind("ALT + SHIFT + D", hl.dsp.exec_cmd(os.getenv("HOME") .. "/.config/hypr/handy-toggle"))
hl.bind(mainMod .. " + ESCAPE", hl.dsp.exec_cmd("nwg-drawer"))

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
    hl.bind("Q", hl.dsp.exec_cmd("shutdown -P now"), { repeating = true })
    hl.bind("E", hl.dsp.exit(), { repeating = true })
    hl.bind("R", hl.dsp.exec_cmd("hyprctl dispatch 'hl.dsp.exit()' && systemctl reboot"), { repeating = true })

    -- Needs to exit after the action otherwise we end up in the same submap
    hl.bind("L", function()
        hl.dispatch(hl.dsp.exec_cmd("pkill nwg-bar"))
        hl.dispatch(hl.dsp.exec_cmd("pidof hyprlock | hyprlock"))
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
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true, repeating = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true, repeating = true })
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

hl.window_rule({ match = { class = "^(vlc)$" }, float = true })
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
    size = { 800, 600 },
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

hl.window_rule({ match = { class = "^(virt-manager)$" }, float = true })

hl.window_rule({
    name = "pip",
    match = { title = "^([Pp]icture-[iI]n-[Pp]icture)$" },
    float = true,
    center = true,
    size = { 800, 600 },
})

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

---------------
-- STEAM GAMES
---------------
hl.window_rule({ match = { class = "^(steam_app_)(.*)" }, monitor = "DP-1" })
hl.window_rule({ match = { content = "game" }, monitor = "DP-1" })
hl.window_rule({ match = { class = "^(steam_app_)(.*)" }, workspace = "3" })
hl.window_rule({ match = { content = "game" }, workspace = "3" })

------------------
-- Exiled Exchange 2 (PoE2 price overlay, XWayland)
-- Its transparent fullscreen overlay otherwise makes Hyprland blur the
-- game behind it. no_blur stops that.
------------------
hl.window_rule({ match = { class = "^(exiled-exchange-2)$" }, no_blur = true })

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
-- hl.layer_rule({ match = { namespace = "nwg-drawer" }, blur = true })  -- disabled: causes freeze when searching

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
