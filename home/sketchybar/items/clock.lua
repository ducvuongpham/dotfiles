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
})

clock:subscribe({ "routine", "system_woke", "forced" }, function()
  clock:set({ label = os.date("%a %d %b  %H:%M") })
end)
