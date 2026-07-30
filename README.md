# dotfiles

Hand-written Hyprland setup, replacing ml4w. No framework, no generator scripts —
every file here is plain and meant to be read and edited directly.

## Layout

- `hypr/` — Hyprland compositor config, monitor layout, hypridle/hyprlock/hyprpaper

Hyprland's own config is Lua (`hypr/hyprland.lua`): hyprlang `.conf` is
deprecated since 0.55 and removed in 0.57. The `.conf` files are kept for now as
a rollback — Hyprland prefers `hyprland.lua` whenever both exist, and only checks
at startup. `hypridle`/`hyprlock` are separate projects and still use hyprlang,
so `hypridle.conf` and `hyprlock.conf` stay as they are.
- `waybar/` — status bar (right-click the volume icon to pick an audio output device)
- `rofi/` — app launcher (`$mainMod + Space`)
- `swaync/` — notification daemon/center (`$mainMod + N`)
- `kitty/` — terminal
- `fish/` — shell config (prompt via starship, abbreviations, EDITOR)

## Install

```
./install.sh
```

Symlinks each directory into `~/.config`. Backs up anything real it would
overwrite to `~/backups/config-preinstall-<timestamp>/`.

After linking, reload Hyprland:

```
hyprctl reload
```

Waybar/swaync/hyprpaper/hypridle need a restart to pick up config changes —
either `hyprctl dispatch exec <name>` after killing the old process, or just
log out and back in.

## A note on config syntax drift

These are fast-moving projects (Hyprland, hyprpaper, waybar, swaync all ship
frequent breaking releases) and the config file formats here are only correct
for whatever version was installed when they were last touched. If a setting
silently stops working after a system update, don't assume the config is
still valid syntax — check first:

- `Hyprland --config ~/.config/hypr/hyprland.lua --verify-config` dry-runs the
  main config without launching a compositor. It really does execute the Lua and
  validate every key and dispatcher, so "config ok" is meaningful. Pass an
  absolute path — `require` resolves against `~/.config/hypr`, not the cwd.
- For everything else, run the daemon in the foreground with verbose logging
  (e.g. `hyprpaper --verbose`) and watch for parse errors or "invalid config
  key" warnings — a daemon that starts cleanly but does nothing is usually
  silently ignoring an option that no longer exists, not a bug in the rest of
  the setup.
- When in doubt, check the actual installed version (`hyprpaper --version`,
  etc.) against that project's source/changelog rather than trusting
  half-remembered syntax — this happened once already: `hyprpaper` v0.8.4
  replaced the old flat `preload = ` / `wallpaper = ` directives with a
  `wallpaper { }` block, and the daemon just kept quietly redisplaying
  whatever it last had loaded instead of erroring.

## Key bindings (SUPER = Windows key)

Press `SUPER + /` any time for an on-screen cheat sheet (rofi popup, powered by
`hypr/scripts/show-keybinds.sh`). It reads live from `hyprctl binds`, so it's
always accurate — every bind that should show up there passes a `description` in
its options table in `hypr/hyprland.lua`. Add one to a new bind the same way to
have it show up automatically:

```lua
hl.bind("SUPER + X", hl.dsp.exec_cmd("something"), { description = "Do the thing" })
```

| Binding | Action |
|---|---|
| `SUPER + /` | Show keybind cheat sheet |
| `SUPER + Return` | Terminal (kitty) |
| `SUPER + Space` | App launcher (rofi) |
| `SUPER + Q` | Close window |
| `SUPER + SHIFT + Q` | Exit Hyprland |
| `SUPER + F` | Fullscreen |
| `SUPER + V` | Toggle floating |
| `SUPER + L` | Lock screen |
| `SUPER + C` | Clipboard history |
| `SUPER + N` | Notification center |
| `SUPER + 1-0` | Switch workspace |
| `SUPER + SHIFT + 1-0` | Move window to workspace |
| `SUPER + arrows` | Move focus |
| `SUPER + SHIFT + arrows` | Move window |
| `Print` | Screenshot region |
| `SHIFT + Print` | Screenshot full screen |

Colors are Catppuccin Mocha, applied by hand in each config (no theme package
dependency). To change the look, edit the hex codes in `waybar/style.css`,
`kitty/kitty.conf`, `rofi/config.rasi`, `swaync/style.css`.
