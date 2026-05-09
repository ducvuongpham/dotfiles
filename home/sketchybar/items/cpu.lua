local sbar = require("sketchybar")
local colors = require("colors")

local cpu = sbar.add("item", "cpu", {
  position = "right",
  icon = { string = "󰻠", color = colors.red },
  label = { color = colors.text },
  update_freq = 5,
  background = { color = colors.surface0 },
  padding_left = 4,
  padding_right = 4,
  click_script = [[open -a "Activity Monitor"]],
})

local ram = sbar.add("item", "ram", {
  position = "right",
  icon = { string = "󰍛", color = colors.green },
  label = { color = colors.text },
  update_freq = 5,
  background = { color = colors.surface0 },
  padding_left = 4,
  padding_right = 4,
  click_script = [[open -a "Activity Monitor"]],
})

cpu:subscribe({ "routine", "forced" }, function()
  -- top -l 1 -n 0: just the header (no process list) — fast.
  -- "CPU usage: 12.34% user, 5.67% sys, 82.0% idle"
  sbar.exec(
    [[top -l 1 -n 0 | awk -F'[ ,%]+' '/^CPU usage/ {printf "%d", $3+$5}']],
    function(out)
      cpu:set({ label = (out:gsub("%s+$", "")) .. "%" })
    end
  )
end)

ram:subscribe({ "routine", "forced" }, function()
  -- macOS pressure-based "free" %; used = 100 - free.
  sbar.exec(
    [[memory_pressure | awk '/memory free/ {gsub("%",""); print 100 - $NF; exit}']],
    function(out)
      local n = tonumber((out or ""):match("(%d+)")) or 0
      ram:set({ label = n .. "%" })
    end
  )
end)
