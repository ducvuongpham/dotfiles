local sbar = require("sketchybar")
local colors = require("colors")

-- Internal display brightness via `brightness` CLI (brew install brightness).
-- Click → popup with slider for the built-in display + button to launch
-- MonitorControl for external screens (DDC adjustment).
local brightness = sbar.add("item", "brightness", {
  position = "right",
  icon = { string = "󰃟", color = colors.yellow },
  label = { color = colors.text },
  background = { color = colors.surface0 },
  padding_left = 4,
  padding_right = 4,
  update_freq = 30,
  popup = { align = "center", height = 30 },
})

local slider = sbar.add("slider", "brightness.slider", 130, {
  position = "popup." .. brightness.name,
  background = { height = 6, color = colors.surface2, corner_radius = 3, border_width = 0 },
  slider = {
    highlight_color = colors.yellow,
    background = { height = 6, corner_radius = 3, color = colors.surface2 },
    knob = { string = "󰊠", drawing = true, color = colors.peach },
  },
  -- brightness CLI takes 0.0 - 1.0
  click_script = [[/opt/homebrew/bin/brightness "$(echo "scale=2; $PERCENTAGE / 100" | bc)"]],
  label = { drawing = false },
  icon = { string = "󰃞", color = colors.yellow, padding_left = 8, padding_right = 8 },
  padding_left = 8,
  padding_right = 8,
})

local mc_button = sbar.add("item", "brightness.mc", {
  position = "popup." .. brightness.name,
  icon = { string = "󰍹", color = colors.peach, padding_left = 10 },
  label = { string = "Open MonitorControl", color = colors.text, padding_right = 10 },
  background = { color = colors.transparent, height = 22 },
  click_script = "open -a MonitorControl",
})

local function refresh()
  sbar.exec("/opt/homebrew/bin/brightness -l", function(out)
    -- output: "display 0: brightness 0.50"; pick first display
    local frac = (out or ""):match("brightness%s+([%d%.]+)")
    local n = math.floor((tonumber(frac) or 0) * 100 + 0.5)
    brightness:set({ label = { string = n .. "%" } })
    slider:set({ slider = { percentage = n } })
  end)
end

brightness:subscribe({ "routine", "system_woke", "forced" }, refresh)
brightness:subscribe("mouse.clicked", function()
  refresh()
  brightness:set({ popup = { drawing = "toggle" } })
end)
brightness:subscribe("mouse.exited.global", function()
  brightness:set({ popup = { drawing = false } })
end)

refresh()
