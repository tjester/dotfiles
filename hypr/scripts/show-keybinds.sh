#!/usr/bin/env bash
# Cheat sheet: shows every keybind that has a description (bindd/bindmd/...)
# in hyprland.conf. Reads live from `hyprctl binds`, so it's always in sync
# with whatever is actually bound, not a separate hand-maintained list.
#
# Parses the plain-text `hyprctl binds` output rather than `-j`: on
# Hyprland 0.56.0 the JSON form is broken (field values shifted, emitting
# unquoted barewords), while the plain-text form is stable.
set -euo pipefail

hyprctl binds | awk -v RS='' -v FS='\n' '
  function bit(n, k) { return int(n / k) % 2 }

  function modname(m,    parts, out) {
    out = ""
    if (bit(m, 64)) out = out (out == "" ? "" : " + ") "SUPER"
    if (bit(m, 8))  out = out (out == "" ? "" : " + ") "ALT"
    if (bit(m, 4))  out = out (out == "" ? "" : " + ") "CTRL"
    if (bit(m, 1))  out = out (out == "" ? "" : " + ") "SHIFT"
    return out
  }

  function keyname(k) {
    if (k == "left")       return "←"
    if (k == "right")      return "→"
    if (k == "up")         return "↑"
    if (k == "down")       return "↓"
    if (k == "slash")      return "/"
    if (k == "mouse:272")  return "Left Click"
    if (k == "mouse:273")  return "Right Click"
    if (k == "mouse_down") return "Scroll Down"
    if (k == "mouse_up")   return "Scroll Up"
    return k
  }

  {
    modmask = ""; key = ""; desc = ""
    for (i = 1; i <= NF; i++) {
      line = $i
      sub(/^\t/, "", line)
      colon = index(line, ": ")
      if (!colon) continue
      field = substr(line, 1, colon - 1)
      value = substr(line, colon + 2)
      if (field == "modmask") modmask = value
      else if (field == "key") key = value
      else if (field == "description") desc = value
    }
    if (desc == "") next
    mods = modname(modmask + 0)
    label = (mods == "") ? keyname(key) : mods " + " keyname(key)
    print label "\t" desc
  }
' | column -t -s $'\t' \
  | rofi -dmenu -p "Keybinds" -i \
      -theme-str 'window {width: 750px;} listview {lines: 15;} element {padding: 4px 10px;}'
