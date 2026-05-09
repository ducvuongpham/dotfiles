local sbar = require("sketchybar")
local colors = require("colors")

local cpu = sbar.add("item", "cpu", {
  position = "right",
  icon = { string = "󰍛", color = colors.red },
  label = { color = colors.text },
  update_freq = 5,
  background = { color = colors.surface0 },
  padding_left = 4,
  padding_right = 4,
})

cpu:subscribe({ "routine", "forced" }, function()
  sbar.exec(
    [[ps -A -o %cpu | awk '{s+=$1} END {printf "%.0f", s/8}']],
    function(out)
      cpu:set({ label = (out:gsub("%s+$", "")) .. "%" })
    end
  )
end)
