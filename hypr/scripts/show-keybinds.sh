#!/usr/bin/env bash
# Cheat sheet: shows every keybind that has a description (bindd/bindmd/...)
# in hyprland.conf. Reads live from `hyprctl binds`, so it's always in sync
# with whatever is actually bound, not a separate hand-maintained list.
set -euo pipefail

hyprctl binds -j | jq -r '
  def bit(n; k): ((n / k) | floor) % 2;

  def modname:
    . as $m
    | [
        (if bit($m; 64) == 1 then "SUPER" else empty end),
        (if bit($m; 8)  == 1 then "ALT"   else empty end),
        (if bit($m; 4)  == 1 then "CTRL"  else empty end),
        (if bit($m; 1)  == 1 then "SHIFT" else empty end)
      ]
    | join(" + ");

  def keyname:
    if .   == "left"      then "←"
    elif . == "right"     then "→"
    elif . == "up"        then "↑"
    elif . == "down"      then "↓"
    elif . == "slash"     then "/"
    elif . == "mouse:272" then "Left Click"
    elif . == "mouse:273" then "Right Click"
    elif . == "mouse_down" then "Scroll Down"
    elif . == "mouse_up"   then "Scroll Up"
    else .
    end;

  .[]
  | select(.description != "")
  | ((.modmask | modname) as $mods
     | (.key | keyname) as $key
     | (if $mods == "" then $key else $mods + " + " + $key end))
    + "\t" + .description
' | column -t -s $'\t' \
  | rofi -dmenu -p "Keybinds" -i \
      -theme-str 'window {width: 750px;} listview {lines: 15;} element {padding: 4px 10px;}'
