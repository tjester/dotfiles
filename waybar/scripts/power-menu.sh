#!/usr/bin/env bash
# Simple rofi-based power menu (replacement for sysact, which isn't installed).
set -euo pipefail

options="  Lock\n  Logout\n  Suspend\n  Reboot\n  Shutdown"

chosen="$(printf '%b' "$options" | rofi -dmenu -p "Power" -i)"

case "$chosen" in
    *Lock) hyprlock ;;
    *Logout) hyprctl dispatch exit ;;
    *Suspend) systemctl suspend ;;
    *Reboot) systemctl reboot ;;
    *Shutdown) systemctl poweroff ;;
esac
