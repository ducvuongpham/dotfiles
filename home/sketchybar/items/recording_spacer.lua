local sbar = require("sketchybar")
local colors = require("colors")
local popups = require("popups")

-- Reserve a colored block on the far-right of the bar so the macOS Control
-- Center recording indicator (green/orange dot, camera/mic in use) sits over
-- a surface-tinted background instead of bare black bar. Clicking it toggles
-- Notification Center (same behavior as the clock item).
local spacer = sbar.add("item", "recording_spacer", {
  position = "right",
  width = 24,
  background = { color = colors.surface0 },
  padding_left = 0,
  padding_right = 0,
})

local FMM = os.getenv("HOME") .. "/.local/share/sketchybar_lua/focus-mouse-monitor"
local TOGGLE_NC = [[osascript -e 'tell application "System Events" to tell process "Control Center" to click (first menu bar item of menu bar 1 whose description is "Clock")']]
spacer:subscribe("mouse.clicked", function()
  sbar.exec(FMM, function()
    popups.close_all_except("nothing")
    sbar.exec(TOGGLE_NC)
  end)
end)
