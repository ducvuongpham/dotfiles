#!/usr/bin/env bash
# alt-enter handler. If focused workspace has exactly 1 window, force
# side-by-side (h_tiles) so the next window lands to the right of the
# existing one — regardless of whatever orientation the prior split left.
# Otherwise keep the Fibonacci dwindle behaviour via `split opposite`.
#
# Spawning: reuse an existing Alacritty process via its IPC socket so
# macOS treats every window as belonging to one app instance (single
# dock icon). The previous approach (`open -na Alacritty`) launched a
# fresh process per window, which macOS rendered as separate dock icons.
set -u

AERO=/opt/homebrew/bin/aerospace
ALACRITTY=/run/current-system/sw/bin/alacritty

count=$("$AERO" list-windows --workspace focused 2>/dev/null | /usr/bin/wc -l | /usr/bin/tr -d ' ')

if [ "${count:-0}" -eq 1 ]; then
  "$AERO" layout tiles horizontal
elif [ "${count:-0}" -gt 1 ]; then
  "$AERO" split opposite
fi

# Try every live IPC socket; first one that accepts the create-window
# message wins. Stale sockets fail silently and we fall through.
spawned=0
while IFS= read -r sock; do
  [ -S "$sock" ] || continue
  if "$ALACRITTY" msg --socket "$sock" create-window 2>/dev/null; then
    spawned=1
    break
  fi
done < <(/usr/bin/find "$TMPDIR" -maxdepth 1 -name 'Alacritty-*.sock' -type s 2>/dev/null)

if [ "$spawned" -eq 0 ]; then
  /usr/bin/open -a Alacritty   # cold start: no running process found
fi
