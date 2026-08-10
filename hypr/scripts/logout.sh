#!/usr/bin/env bash
# End the graphical session.
#
# The session is started by uwsm (ly -> start-hyprland -> uwsm), and uwsm's docs
# are explicit that the compositor's own exit mechanism must not be used:
# `hyprctl dispatch exit` yanks Hyprland out from under its clients and skips
# uwsm's ordered teardown of graphical-session.target. `uwsm stop` brings the
# units down in order and lets the login session end, which is what returns us
# to ly.
#
# The hyprctl fallback is only for a session started without uwsm.
set -euo pipefail

if command -v uwsm >/dev/null 2>&1 && uwsm check is-active; then
    exec uwsm stop
else
    exec hyprctl dispatch exit
fi
