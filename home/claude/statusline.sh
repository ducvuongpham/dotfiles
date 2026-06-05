#!/usr/bin/env bash
# Claude Code status line: shows model, cwd, and indicators for caveman/rtk/grill-me.
# Reads session JSON from stdin (per Claude Code statusLine spec).

set -u

input=$(cat)

# Extract a few fields without requiring jq. Fall back gracefully.
get() {
  printf '%s' "$input" | sed -n "s/.*\"$1\"[[:space:]]*:[[:space:]]*\"\([^\"]*\)\".*/\1/p" | head -n1
}

model=$(get display_name)
[ -z "$model" ] && model=$(get model)
cwd=$(get current_dir)
[ -z "$cwd" ] && cwd=$PWD
short_cwd=${cwd/#$HOME/\~}

parts=()

# Caveman: file is current mode (written by caveman-track.sh hook). No file = off.
caveman_file="$HOME/.claude/.caveman-active"
if [ -f "$caveman_file" ]; then
  level=$(tr -d '[:space:]' < "$caveman_file")
  parts+=("CAVE:${level:-on}")
fi

# RTK: show version if installed
if command -v rtk >/dev/null 2>&1; then
  rtk_ver=$(rtk --version 2>/dev/null | awk '{print $2}')
  [ -n "$rtk_ver" ] && parts+=("RTK:$rtk_ver") || parts+=("RTK")
fi

# Grill-me: static label (skill always available)
if [ -d "$HOME/.claude/skills/grill-me" ]; then
  parts+=("GRILL")
fi

badges=""
if [ ${#parts[@]} -gt 0 ]; then
  badges=" [$(IFS='|'; echo "${parts[*]}")]"
fi

printf '%s · %s%s' "${model:-claude}" "$short_cwd" "$badges"
