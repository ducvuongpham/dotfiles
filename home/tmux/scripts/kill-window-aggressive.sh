#!/usr/bin/env bash
# SIGKILL each pane's process group, then close the window.
# Called from tmux bind & — receives the window_id as $1.
set -u
window_id="${1:?need window_id}"

while IFS= read -r pid; do
  [ -z "$pid" ] && continue
  pgid="$(/bin/ps -o pgid= -p "$pid" 2>/dev/null | /usr/bin/tr -d ' ')"
  [ -n "$pgid" ] && /bin/kill -KILL -- "-$pgid" 2>/dev/null
done < <(/opt/homebrew/bin/tmux list-panes -t "$window_id" -F '#{pane_pid}' 2>/dev/null)

/opt/homebrew/bin/tmux kill-window -t "$window_id"
