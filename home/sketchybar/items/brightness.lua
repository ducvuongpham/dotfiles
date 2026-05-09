local sbar = require("sketchybar")
local colors = require("colors")

-- Apple Silicon Macs don't expose brightness via the legacy IOKit API used by
-- the `brightness` CLI; sending F1/F2 key events through System Events works
-- on every Mac (built-in display + DDC-aware externals via MonitorControl).
local brightness = sbar.add("item", "brightness", {
  position = "right",
  icon = { string = "󰃟", color = colors.yellow },
  label = { drawing = false },
  background = { color = colors.surface0 },
  padding_left = 4,
  padding_right = 4,
  popup = { align = "center", height = 30 },
})

-- Popup row: down button | label | up button | open MC
local btn_down = sbar.add("item", "brightness.down", {
  position = "popup." .. brightness.name,
  icon = { string = "󰃞", color = colors.yellow, padding_left = 12, padding_right = 12 },
  label = { drawing = false },
  background = { color = colors.transparent, height = 24 },
  -- key code 145 = F2 (brightness down)
  click_script = [[osascript -e 'tell application "System Events" to key code 145']],
})

local label = sbar.add("item", "brightness.label", {
  position = "popup." .. brightness.name,
  icon = { drawing = false },
  label = { string = "Brightness", color = colors.text, padding_left = 4, padding_right = 4 },
  background = { color = colors.transparent, height = 24 },
})

local btn_up = sbar.add("item", "brightness.up", {
  position = "popup." .. brightness.name,
  icon = { string = "󰃠", color = colors.yellow, padding_left = 12, padding_right = 12 },
  label = { drawing = false },
  background = { color = colors.transparent, height = 24 },
  -- key code 144 = F1 (brightness up)
  click_script = [[osascript -e 'tell application "System Events" to key code 144']],
})

local mc_button = sbar.add("item", "brightness.mc", {
  position = "popup." .. brightness.name,
  icon = { string = "󰍹", color = colors.peach, padding_left = 10 },
  label = { string = "Open MonitorControl", color = colors.text, padding_right = 10 },
  background = { color = colors.transparent, height = 22 },
  click_script = "open -a MonitorControl",
})

brightness:subscribe("mouse.clicked", function()
  brightness:set({ popup = { drawing = "toggle" } })
end)
brightness:subscribe("mouse.exited.global", function()
  brightness:set({ popup = { drawing = false } })
end)
