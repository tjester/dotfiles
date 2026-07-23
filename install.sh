#!/usr/bin/env bash
# Symlinks this repo's config directories into ~/.config.
# Safe to re-run: backs up any real (non-symlink) file/dir it would overwrite.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config"
BACKUP_DIR="$HOME/backups/config-preinstall-$(date +%Y%m%d-%H%M%S)"

for dir in hypr waybar rofi swaync kitty fish theme autostart; do
    target="$CONFIG_DIR/$dir"
    source="$REPO_DIR/$dir"

    if [ -L "$target" ]; then
        rm "$target"
    elif [ -e "$target" ]; then
        mkdir -p "$BACKUP_DIR"
        mv "$target" "$BACKUP_DIR/"
        echo "Backed up existing $target -> $BACKUP_DIR/"
    fi

    ln -s "$source" "$target"
    echo "Linked $target -> $source"
done

# Pick waybar's modules-right (battery module included or not) based on
# whether this machine actually has battery hardware.
if compgen -G "/sys/class/power_supply/BAT*" > /dev/null; then
    WAYBAR_HOST="laptop"
else
    WAYBAR_HOST="desktop"
fi
ln -sf "$REPO_DIR/waybar/hosts/$WAYBAR_HOST.jsonc" "$REPO_DIR/waybar/host.jsonc"
echo "Linked waybar/host.jsonc -> hosts/$WAYBAR_HOST.jsonc"

# $browser/$BROWSER is set to "zen", but the AUR package (zen-browser-bin)
# only provides a "zen-browser" binary on PATH. Give it the shorter name via
# ~/.local/bin, which is already first on both fish's and the systemd user
# session's PATH (so Hyprland's own `exec` keybinds pick it up too).
if command -v zen-browser >/dev/null 2>&1; then
    mkdir -p "$HOME/.local/bin"
    ln -sf "$(command -v zen-browser)" "$HOME/.local/bin/zen"
    echo "Linked ~/.local/bin/zen -> $(command -v zen-browser)"
fi
