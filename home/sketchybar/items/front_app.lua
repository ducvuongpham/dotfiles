local sbar = require("sketchybar")
local colors = require("colors")

local front_app = sbar.add("item", "front_app", {
  position = "left",
  icon = { drawing = false },
  label = {
    font = {
      family = "JetBrainsMono Nerd Font",
      style = "Bold",
      size = 13.0,
    },
    color = colors.lavender,
  },
  background = { color = colors.transparent },
  updates = true,
  padding_left = 12,
  click_script = [[$HOME/.local/share/sketchybar_lua/focus-mouse-monitor]],
})

front_app:subscribe("front_app_switched", function(env)
  front_app:set({ label = { string = env.INFO } })
end)
