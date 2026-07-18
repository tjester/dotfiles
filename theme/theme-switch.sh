#!/usr/bin/env bash
# Switch the system theme: waybar, swaync, kitty, rofi and Hyprland border
# colors all pull their colors from theme.* files symlinked here into a
# theme in theme/themes/<name>/, plus the wallpaper and GTK theme/icons.
#
# Usage:
#   theme-switch.sh            # pick a theme via rofi
#   theme-switch.sh <name>     # apply a theme directly (e.g. mocha, latte)
set -euo pipefail

THEME_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
THEMES_DIR="$THEME_ROOT/themes"
DOTFILES="$(dirname "$THEME_ROOT")"
CURRENT_FILE="$THEME_ROOT/current"

mapfile -t THEMES < <(find "$THEMES_DIR" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | sort)

if [ "${#THEMES[@]}" -eq 0 ]; then
    echo "theme-switch: no themes found in $THEMES_DIR" >&2
    exit 1
fi

pick_theme() {
    printf '%s\n' "${THEMES[@]}" | rofi -dmenu -p "Theme" -i
}

THEME="${1:-}"
if [ -z "$THEME" ]; then
    THEME="$(pick_theme)"
fi
[ -n "$THEME" ] || exit 0

THEME_DIR="$THEMES_DIR/$THEME"
if [ ! -d "$THEME_DIR" ]; then
    echo "theme-switch: unknown theme '$THEME' (have: ${THEMES[*]})" >&2
    exit 1
fi

# ---- App color files ----
ln -sf "$THEME_DIR/colors.css" "$DOTFILES/waybar/theme.css"
ln -sf "$THEME_DIR/colors.css" "$DOTFILES/swaync/theme.css"
ln -sf "$THEME_DIR/kitty.conf" "$DOTFILES/kitty/theme.conf"
ln -sf "$THEME_DIR/hyprland-colors.conf" "$DOTFILES/hypr/theme.conf"
ln -sf "$THEME_DIR/rofi-colors.rasi" "$DOTFILES/rofi/theme-colors.rasi"

# ---- GTK theme / icons / color-scheme ----
if [ -f "$THEME_DIR/gtk.conf" ]; then
    # shellcheck disable=SC1090
    . "$THEME_DIR/gtk.conf"
    gsettings set org.gnome.desktop.interface gtk-theme "$GTK_THEME" 2>/dev/null || true
    gsettings set org.gnome.desktop.interface icon-theme "$ICON_THEME" 2>/dev/null || true
    gsettings set org.gnome.desktop.interface color-scheme "$COLOR_SCHEME" 2>/dev/null || true
fi

# ---- Wallpaper (all connected monitors) ----
if [ -f "$THEME_DIR/wallpaper" ]; then
    WALLPAPER="$(cat "$THEME_DIR/wallpaper")"
    if [ -f "$WALLPAPER" ] && command -v hyprctl >/dev/null 2>&1; then
        hyprctl hyprpaper preload "$WALLPAPER" >/dev/null 2>&1 || true
        while read -r mon; do
            hyprctl hyprpaper wallpaper "$mon,$WALLPAPER" >/dev/null 2>&1 || true
        done < <(hyprctl monitors -j | python3 -c 'import json,sys; [print(m["name"]) for m in json.load(sys.stdin)]')
    fi
fi

# ---- Reload apps ----
hyprctl reload >/dev/null 2>&1 || true

pkill waybar 2>/dev/null || true
setsid waybar >/tmp/waybar.log 2>&1 &
disown

command -v swaync-client >/dev/null 2>&1 && swaync-client -rs >/dev/null 2>&1 || true

echo "$THEME" > "$CURRENT_FILE"
echo "theme-switch: applied '$THEME' (rofi/new kitty windows pick it up next launch)"
