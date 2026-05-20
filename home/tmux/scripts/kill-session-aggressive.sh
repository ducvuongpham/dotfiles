#!/usr/bin/env bash
# SIGKILL each pane's process group in the session, then kill the session.
# Called from tmux bind — receives the session_id as $1.
set -u
session_id="${1:?need session_id}"

while IFS= read -r pid; do
  [ -z "$pid" ] && continue
  pgid="$(/bin/ps -o pgid= -p "$pid" 2>/dev/null | /usr/bin/tr -d ' ')"
  [ -n "$pgid" ] && /bin/kill -KILL -- "-$pgid" 2>/dev/null
done < <(tmux list-panes -s -t "$session_id" -F '#{pane_pid}' 2>/dev/null)

tmux kill-session -t "$session_id"
