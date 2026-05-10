local sbar = require("sketchybar")
local colors = require("colors")

sbar.bar({
  position = "top",
  height = 32,
  y_offset = 0,             -- sketchybar at y=0; native menu bar (auto-hide) overlays it on cursor reveal
  color = 0xff000000,       -- pure black so the notch on internal display blends in
  border_width = 0,
  border_color = colors.surface0,
  margin = 0,
  padding_left = 6,
  -- Reserve room for the macOS Control Center recording indicator (the
  -- green/orange dot shown when camera or microphone is in use). Without
  -- entitlements the mic side of that state isn't reliably detectable from
  -- shell, so use a static buffer that's wide enough for the dot.
  padding_right = 30,
  blur_radius = 0,
  topmost = "window",
  sticky = "on",
  shadow = "off",
  display = "all",
})
