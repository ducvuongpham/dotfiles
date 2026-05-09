local sbar = require("sketchybar")
local colors = require("colors")

local clock = sbar.add("item", "clock", {
  position = "right",
  icon = {
    string = "󰥔",
    color = colors.peach,
  },
  label = {
    color = colors.text,
  },
  background = { color = colors.surface0 },
  update_freq = 30,
  padding_left = 4,
  padding_right = 4,
  -- Click toggles Notification Center via the macOS menu bar clock item.
  -- Requires Accessibility permission for the process invoking this (sketchybar).
  click_script = [[$HOME/.local/share/sketchybar_lua/focus-mouse-monitor; osascript -e 'tell application "System Events" to tell process "Control Center" to click menu bar item "Clock" of menu bar 1']],
})

clock:subscribe({ "routine", "system_woke", "forced" }, function()
  clock:set({ label = os.date("%a %d %b  %H:%M") })
end)
