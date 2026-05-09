local sbar = require("sketchybar")
local colors = require("colors")

-- BetterDisplay's CLI handles internal + external brightness reliably on
-- Apple Silicon. Install via brew cask `betterdisplay`.
local BDCLI = "/opt/homebrew/bin/betterdisplaycli"

local brightness = sbar.add("item", "brightness", {
  position = "right",
  icon = { string = "󰃟", color = colors.yellow },
  label = { color = colors.text },
  background = { color = colors.surface0 },
  padding_left = 4,
  padding_right = 4,
  popup = {
    align = "center",
    height = 32,
    background = {
      color = colors.mantle,
      border_color = colors.surface2,
      border_width = 1,
      corner_radius = 9,
    },
  },
})

local slider = sbar.add("slider", "brightness.slider", 200, {
  position = "popup." .. brightness.name,
  background = { drawing = false },
  slider = {
    highlight_color = colors.peach,
    background = { height = 6, corner_radius = 3, color = colors.surface2 },
    knob = { string = "󰊠", drawing = true, color = colors.yellow },
  },
  -- BetterDisplay accepts 0.0–1.0; sketchybar passes 0–100 in $PERCENTAGE.
  click_script = [[bash -c ']] .. BDCLI .. [[ set -brightness="$(echo "scale=2; $PERCENTAGE/100" | bc)"']],
  label = { drawing = false },
  icon = {
    string = "󰃟",
    color = colors.yellow,
    padding_left = 14,
    padding_right = 10,
    font = { size = 14.0 },
  },
  padding_left = 4,
  padding_right = 14,
})

local mc_button = sbar.add("item", "brightness.mc", {
  position = "popup." .. brightness.name,
  icon = { string = "󰍹", color = colors.peach, padding_left = 14, padding_right = 8 },
  label = { string = "Open MonitorControl", color = colors.text, padding_right = 14 },
  background = { color = colors.transparent, height = 24 },
  click_script = "open -a MonitorControl",
})

local function refresh()
  sbar.exec(BDCLI .. " get -brightness", function(out)
    -- output line: "Brightness: 0.50" or just "0.50"
    local frac = (out or ""):match("([%d%.]+)")
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
