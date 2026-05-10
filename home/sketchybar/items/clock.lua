local sbar = require("sketchybar")
local colors = require("colors")
local popups = require("popups")

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
})

-- Click: focus the monitor under cursor, close any open sketchybar popups,
-- then toggle macOS Notification Center via the menu-bar Clock item.
local FMM = os.getenv("HOME") .. "/.local/share/sketchybar_lua/focus-mouse-monitor"
local TOGGLE_NC = [[osascript -e 'tell application "System Events" to tell process "Control Center" to click (first menu bar item of menu bar 1 whose description is "Clock")']]
clock:subscribe("mouse.clicked", function()
  sbar.exec(FMM, function()
    popups.close_all_except("nothing")
    sbar.exec(TOGGLE_NC)
  end)
end)

clock:subscribe({ "routine", "system_woke", "forced" }, function()
  clock:set({ label = os.date("%a %d %b  %H:%M") })
end)
