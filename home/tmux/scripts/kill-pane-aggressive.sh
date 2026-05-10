#!/usr/bin/env bash
# SIGKILL the pane's process group, then close the pane.
# Called from tmux bind x — receives the pane_id as $1.
set -u
pane_id="${1:?need pane_id}"

pid="$(/opt/homebrew/bin/tmux display-message -p -t "$pane_id" '#{pane_pid}' 2>/dev/null)"
if [ -n "$pid" ]; then
  pgid="$(/bin/ps -o pgid= -p "$pid" 2>/dev/null | /usr/bin/tr -d ' ')"
  [ -n "$pgid" ] && /bin/kill -KILL -- "-$pgid" 2>/dev/null
fi

/opt/homebrew/bin/tmux kill-pane -t "$pane_id"
