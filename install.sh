#!/usr/bin/env bash
# Symlinks this repo's config directories into ~/.config.
# Safe to re-run: backs up any real (non-symlink) file/dir it would overwrite.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config"
BACKUP_DIR="$HOME/backups/config-preinstall-$(date +%Y%m%d-%H%M%S)"

for dir in hypr waybar rofi swaync kitty fish; do
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
