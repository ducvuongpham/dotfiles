#!/usr/bin/env bash
# UserPromptSubmit hook: parses /caveman <mode> and updates ~/.claude/.caveman-active.
# Mirrors the upstream caveman plugin's tracker so the statusline reflects /caveman switches.

set -u

flag="$HOME/.claude/.caveman-active"
default_mode=${CAVEMAN_DEFAULT_MODE:-full}

input=$(cat)

# Pull the prompt field out of the JSON envelope.
prompt=$(printf '%s' "$input" \
  | sed -n 's/.*"prompt"[[:space:]]*:[[:space:]]*"\(.*\)".*/\1/p' \
  | head -n1)

prompt_lc=$(printf '%s' "$prompt" | tr '[:upper:]' '[:lower:]' | sed 's/^[[:space:]]*//')

case "$prompt_lc" in
  "/caveman"|"/caveman:caveman")
    printf '%s' "$default_mode" > "$flag" ;;
  "/caveman "*|"/caveman:caveman "*)
    arg=$(printf '%s' "$prompt_lc" | awk '{print $2}')
    case "$arg" in
      lite|ultra|wenyan|wenyan-lite|wenyan-full|wenyan-ultra)
        [ "$arg" = "wenyan-full" ] && arg=wenyan
        printf '%s' "$arg" > "$flag" ;;
      off|stop)
        rm -f "$flag" ;;
      *)
        printf '%s' "$default_mode" > "$flag" ;;
    esac ;;
  "/caveman-commit"*) printf 'commit' > "$flag" ;;
  "/caveman-review"*) printf 'review' > "$flag" ;;
  "/caveman-compress"*|"/caveman:caveman-compress"*) printf 'compress' > "$flag" ;;
esac

# Deactivation phrases.
case "$prompt_lc" in
  *"stop caveman"*|*"normal mode"*|*"disable caveman"*) rm -f "$flag" ;;
esac

exit 0
