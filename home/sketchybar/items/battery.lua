local sbar = require("sketchybar")
local colors = require("colors")

local battery = sbar.add("item", "battery", {
  position = "right",
  icon = { color = colors.green },
  label = { color = colors.text },
  update_freq = 60,
  background = { color = colors.surface0 },
  padding_left = 4,
  padding_right = 4,
})

local function update()
  sbar.exec("pmset -g batt", function(stdout)
    local pct = stdout:match("(%d+)%%")
    if not pct then return end
    local n = tonumber(pct)
    local charging = stdout:find("AC Power") ~= nil

    local icon, color
    if charging then
      icon = "󰂄"; color = colors.yellow
    elseif n >= 80 then
      icon = "󰁹"; color = colors.green
    elseif n >= 60 then
      icon = "󰂀"; color = colors.green
    elseif n >= 40 then
      icon = "󰁾"; color = colors.peach
    elseif n >= 20 then
      icon = "󰁻"; color = colors.peach
    else
      icon = "󰁺"; color = colors.red
    end

    battery:set({
      icon = { string = icon, color = color },
      label = { string = pct .. "%" },
    })
  end)
end

battery:subscribe({ "routine", "system_woke", "power_source_change", "forced" }, update)
update()
