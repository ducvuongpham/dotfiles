local sbar = require("sketchybar")
local colors = require("colors")

sbar.bar({
  position = "top",
  height = 30,
  y_offset = 0,             -- sketchybar at y=0; native menu bar (auto-hide) overlays it on cursor reveal
  color = 0xff000000,       -- pure black so the notch on internal display blends in
  border_width = 0,
  border_color = colors.surface0,
  margin = 0,
  padding_left = 6,
  padding_right = 6,
  blur_radius = 0,
  topmost = "window",
  sticky = "on",
  shadow = "off",
  display = "all",
})
