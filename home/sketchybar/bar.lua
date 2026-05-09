local sbar = require("sketchybar")
local colors = require("colors")

sbar.bar({
  position = "top",
  height = 36,
  color = colors.base,
  border_width = 0,
  border_color = colors.surface0,
  margin = 0,
  padding_left = 6,
  padding_right = 6,
  blur_radius = 0,
  topmost = "off",
  sticky = "on",
  shadow = "off",
  display = "all",
})
