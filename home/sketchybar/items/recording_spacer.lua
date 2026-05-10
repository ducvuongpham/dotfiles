local sbar = require("sketchybar")
local colors = require("colors")

-- Reserve a colored block on the far-right of the bar so the macOS Control
-- Center recording indicator (green/orange dot, camera/mic in use) sits over
-- a surface-tinted background instead of bare black bar.
sbar.add("item", "recording_spacer", {
  position = "right",
  width = 24,
  background = { color = colors.surface0 },
  padding_left = 0,
  padding_right = 0,
})
