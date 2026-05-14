#!/usr/bin/env bash
# alt-enter handler. If focused workspace has exactly 1 window, force
# side-by-side (h_tiles) so the next window lands to the right of the
# existing one — regardless of whatever orientation the prior split left.
# Otherwise keep the Fibonacci dwindle behaviour via `split opposite`.
set -u

AERO=/opt/homebrew/bin/aerospace

count=$("$AERO" list-windows --workspace focused 2>/dev/null | /usr/bin/wc -l | /usr/bin/tr -d ' ')

if [ "${count:-0}" -eq 1 ]; then
  "$AERO" layout tiles horizontal
elif [ "${count:-0}" -gt 1 ]; then
  "$AERO" split opposite
fi

/usr/bin/open -na Alacritty
