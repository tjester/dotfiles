# dotfiles

Hand-written Hyprland setup, replacing ml4w. No framework, no generator scripts —
every file here is plain and meant to be read and edited directly.

## Layout

- `hypr/` — Hyprland compositor config, monitor layout, hypridle/hyprlock/hyprpaper
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

## Key bindings (SUPER = Windows key)

| Binding | Action |
|---|---|
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
