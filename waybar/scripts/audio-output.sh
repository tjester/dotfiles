#!/usr/bin/env bash
# Pick the default audio output sink via rofi, and move any currently
# playing streams over to it so switching doesn't require restarting apps.
set -euo pipefail

current="$(pactl get-default-sink)"

mapfile -t names < <(pactl -f json list sinks | jq -r '.[].name')
mapfile -t descs < <(pactl -f json list sinks | jq -r '.[].description')

menu=""
for i in "${!names[@]}"; do
    marker="○"
    [ "${names[$i]}" = "$current" ] && marker="●"
    menu+="${marker} ${descs[$i]}"$'\n'
done

chosen="$(printf '%s' "$menu" | rofi -dmenu -p "Audio Output")"
[ -z "$chosen" ] && exit 0
chosen="${chosen#??}"

for i in "${!names[@]}"; do
    if [ "${descs[$i]}" = "$chosen" ]; then
        sink="${names[$i]}"
        pactl set-default-sink "$sink"
        pactl list short sink-inputs | cut -f1 | while read -r input; do
            pactl move-sink-input "$input" "$sink" || true
        done
        exit 0
    fi
done
