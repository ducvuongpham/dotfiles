#!/bin/bash
# Runs on every wake from sleep (invoked by sleepwatcher via ~/.wakeup).
# After sleep the AeroSpace<->sketchybar IPC link sometimes drops trigger
# events, leaving the workspace indicator stuck on its pre-sleep state.
# Restarting sketchybar rebuilds all subscriptions; the spaces item's
# refresh_query() on init re-syncs the indicator immediately.
/opt/homebrew/bin/brew services restart sketchybar >/dev/null 2>&1
