--
-- Hyprland config — hand-written, minimal core.
-- Docs: https://wiki.hypr.land/Configuring/Start/
--
-- Lua replaces the old hyprlang `.conf` format, which Hyprland 0.57 drops.
-- hypridle/hyprlock are separate projects and still use hyprlang, so their
-- .conf files next to this one are not stale.
--

-- `require` searches package.path, which does not include this directory by
-- default, so put it on the front. Everything below requires by bare name.
local configDir = (os.getenv("XDG_CONFIG_HOME") or (os.getenv("HOME") .. "/.config")) .. "/hypr"
package.path = configDir .. "/?.lua;" .. package.path

require("monitors")

-- theme.lua is a symlink into theme/themes/<name>/, swapped by theme-switch.sh.
-- It returns a table of border colors rather than setting anything itself.
local theme = require("theme")

-- ---- Autostart ----
-- The old `exec-once =` lines: run once, when the compositor comes up.
hl.on("hyprland.start", function()
    hl.exec_cmd("waybar")
    hl.exec_cmd("awww-daemon")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")
    hl.exec_cmd("wl-paste --watch cliphist store")
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")

    -- Secret Service: started AND unlocked by pam_gnome_keyring at login (see /etc/pam.d/ly).
    -- Do NOT start gnome-keyring-daemon here — a passwordless start races PAM, wins the
    -- org.freedesktop.secrets bus first, and leaves the login keyring locked (Nextcloud
    -- then re-prompts every boot). The systemd gnome-keyring-daemon.socket is masked for
    -- the same reason. PAM is the single starter/unlocker.

    -- Wait for Tailscale to actually be connected before starting the client — otherwise
    -- nextcloud.*.ts.net doesn't resolve yet at boot and the client shows as signed-out
    -- until its next retry. Falls through after 60s so it still starts if the tailnet is down.
    -- hl.exec_cmd already runs through `sh -c`, so no wrapping `sh -c` is needed.
    hl.exec_cmd([[n=0; until tailscale status >/dev/null 2>&1 || [ "$n" -ge 60 ]; do n=$((n+1)); sleep 1; done; exec nextcloud --background]])

    hl.exec_cmd("hyprctl setcursor Bibata-Modern-Ice 24")
end)

-- ---- Environment ----
hl.env("XCURSOR_SIZE", "24")
hl.env("XCURSOR_THEME", "Bibata-Modern-Ice")

-- ---- Look and feel ----
hl.config({
    input = {
        kb_layout    = "us",
        follow_mouse = 1,
        sensitivity  = 0,

        touchpad = {
            natural_scroll = false,
        },
    },

    general = {
        gaps_in     = 4,
        gaps_out    = 8,
        border_size = 2,

        col = {
            active_border   = theme.active_border,
            inactive_border = theme.inactive_border,
        },

        layout           = "dwindle",
        resize_on_border = true,
    },

    decoration = {
        rounding = 8,

        active_opacity   = 1.0,
        inactive_opacity = 0.95,

        shadow = {
            enabled      = true,
            range        = 12,
            render_power = 3,
            color        = "rgba(11111bcc)",
        },

        blur = {
            enabled  = true,
            size     = 4,
            passes   = 2,
            vibrancy = 0.1696,
        },
    },

    animations = {
        enabled = true,
    },

    dwindle = {
        preserve_split = true,
    },

    master = {
        new_status = "master",
    },

    misc = {
        disable_hyprland_logo   = true,
        disable_splash_rendering = true,
        force_default_wallpaper = 0,
    },
})

-- ---- Animations ----
-- `bezier = name,x1,y1,x2,y2` became hl.curve; `animation = leaf,on,speed,curve,style`
-- became hl.animation.
hl.curve("easeOutQuint",   { type = "bezier", points = { { 0.23, 1 },    { 0.32, 1 } } })
hl.curve("easeInOutCubic", { type = "bezier", points = { { 0.65, 0.05 }, { 0.36, 1 } } })

hl.animation({ leaf = "windows",    enabled = true, speed = 4, bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 4, bezier = "easeOutQuint",   style = "popin 80%" })
hl.animation({ leaf = "border",     enabled = true, speed = 8, bezier = "default" })
hl.animation({ leaf = "fade",       enabled = true, speed = 3, bezier = "default" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 4, bezier = "easeInOutCubic", style = "slide" })

-- ---- Keybindings ----
-- `description` replaces the `d` suffix on bindd/bindmd/bindeld — scripts/show-keybinds.sh
-- reads them back out of `hyprctl binds`, so only the binds that should appear in the
-- cheat sheet carry one.
local mainMod  = "SUPER"
local terminal = "kitty"
local launcher = "rofi -show drun"
local browser  = "zen"

hl.bind(mainMod .. " + Return",  hl.dsp.exec_cmd(terminal),          { description = "Open terminal" })
hl.bind(mainMod .. " + B",       hl.dsp.exec_cmd(browser),           { description = "Launch browser" })
hl.bind(mainMod .. " + Q",       hl.dsp.window.close(),              { description = "Close window" })
hl.bind(mainMod .. " + SHIFT + Q", hl.dsp.exit(),                    { description = "Exit Hyprland" })
hl.bind(mainMod .. " + Space",   hl.dsp.exec_cmd(launcher),          { description = "App launcher" })
hl.bind(mainMod .. " + V",       hl.dsp.window.float(),              { description = "Toggle floating" })
hl.bind(mainMod .. " + F",       hl.dsp.window.fullscreen(),         { description = "Toggle fullscreen" })
hl.bind(mainMod .. " + P",       hl.dsp.window.pseudo(),             { description = "Toggle pseudotile" })
hl.bind(mainMod .. " + L",       hl.dsp.exec_cmd("hyprlock"),        { description = "Lock screen" })
hl.bind(mainMod .. " + slash",   hl.dsp.exec_cmd(configDir .. "/scripts/show-keybinds.sh"),
                                                                     { description = "Show this keybind list" })

-- Clipboard history
hl.bind(mainMod .. " + C", hl.dsp.exec_cmd("cliphist list | rofi -dmenu | cliphist decode | wl-copy"),
                                                                     { description = "Clipboard history" })

-- Screenshots
hl.bind("Print",         hl.dsp.exec_cmd([[grim -g "$(slurp)" - | wl-copy]]), { description = "Screenshot region" })
hl.bind("SHIFT + Print", hl.dsp.exec_cmd("grim - | wl-copy"),                 { description = "Screenshot full screen" })

-- Move focus
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }), { description = "Move focus (arrows)" })
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))

-- Move window
hl.bind(mainMod .. " + SHIFT + left",  hl.dsp.window.move({ direction = "left" }), { description = "Move window (SHIFT + arrows)" })
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + up",    hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + down",  hl.dsp.window.move({ direction = "down" }))

-- Workspaces 1-10. Key 0 is workspace 10; only the first bind of each row is
-- described, so the cheat sheet gets one line instead of ten.
for i = 1, 10 do
    local key = i % 10
    hl.bind(mainMod .. " + " .. key,           hl.dsp.focus({ workspace = i }),
        i == 1 and { description = "Switch workspace (1-0)" } or nil)
    hl.bind(mainMod .. " + SHIFT + " .. key,   hl.dsp.window.move({ workspace = i }),
        i == 1 and { description = "Move window to workspace (SHIFT + 1-0)" } or nil)
end

hl.bind(mainMod .. " + S",         hl.dsp.workspace.toggle_special("magic"),          { description = "Toggle scratchpad" })
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Mouse move/resize windows
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true, description = "Drag window with mouse" })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true, description = "Resize window with mouse" })

-- Media / volume / brightness. `locked` keeps them working over the lock screen,
-- `repeating` makes them repeat when held — the old `bindel`/`bindl` flags.
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true, description = "Volume up" })
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true, repeating = true, description = "Mute audio" })
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl set 5%+"),                          { locked = true, repeating = true, description = "Brightness up" })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 5%-"),                          { locked = true, repeating = true })
hl.bind("XF86AudioPlay",         hl.dsp.exec_cmd("playerctl play-pause"),                           { locked = true, description = "Media play/pause" })
hl.bind("XF86AudioNext",         hl.dsp.exec_cmd("playerctl next"),                                 { locked = true })
hl.bind("XF86AudioPrev",         hl.dsp.exec_cmd("playerctl previous"),                             { locked = true })

-- Notification center
hl.bind(mainMod .. " + N", hl.dsp.exec_cmd("swaync-client -t -sw"), { description = "Notification center" })

-- Theme switcher
hl.bind(mainMod .. " + T", hl.dsp.exec_cmd((os.getenv("XDG_CONFIG_HOME") or (os.getenv("HOME") .. "/.config")) .. "/theme/theme-switch.sh"),
                                                                    { description = "Theme switcher" })
