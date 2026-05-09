local sbar = require("sketchybar")
local colors = require("colors")

sbar.default({
  updates = "when_shown",
  icon = {
    font = {
      family = "JetBrainsMono Nerd Font",
      style = "Bold",
      size = 14.0,
    },
    color = colors.text,
    padding_left = 6,
    padding_right = 6,
  },
  label = {
    font = {
      family = "JetBrainsMono Nerd Font",
      style = "Medium",
      size = 13.0,
    },
    color = colors.text,
    padding_left = 4,
    padding_right = 6,
  },
  background = {
    height = 28,
    corner_radius = 6,
    color = colors.surface0,
    border_width = 0,
  },
  padding_left = 4,
  padding_right = 4,
})
